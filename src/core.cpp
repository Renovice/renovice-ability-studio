#include "renovice/core.hpp"

#include <algorithm>
#include <array>
#include <charconv>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <limits>
#include <map>
#include <regex>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string_view>
#include <unordered_map>

#include <windows.h>
#include <bcrypt.h>

namespace renovice
{
    namespace
    {
        using RegistryRow = std::unordered_map<std::string, std::string>;

        struct ProcessResult
        {
            DWORD exit_code = static_cast<DWORD>(-1);
            std::string output;
        };

        [[nodiscard]] std::string read_text(const fs::path& path)
        {
            std::ifstream input(path, std::ios::binary);
            if (!input)
            {
                throw std::runtime_error("Unable to open " + path.string());
            }
            return std::string(std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>());
        }

        void write_text(const fs::path& path, const std::string& value)
        {
            fs::create_directories(path.parent_path());
            std::ofstream output(path, std::ios::binary | std::ios::trunc);
            if (!output)
            {
                throw std::runtime_error("Unable to write " + path.string());
            }
            output.write(value.data(), static_cast<std::streamsize>(value.size()));
            if (!output)
            {
                throw std::runtime_error("Incomplete write to " + path.string());
            }
        }

        [[nodiscard]] std::vector<std::string> split_tsv_line(const std::string& line)
        {
            std::vector<std::string> fields;
            std::size_t start = 0;
            while (true)
            {
                const std::size_t tab = line.find('\t', start);
                if (tab == std::string::npos)
                {
                    fields.emplace_back(line.substr(start));
                    break;
                }
                fields.emplace_back(line.substr(start, tab - start));
                start = tab + 1;
            }
            if (!fields.empty() && !fields.back().empty() && fields.back().back() == '\r')
            {
                fields.back().pop_back();
            }
            return fields;
        }

        [[nodiscard]] std::vector<RegistryRow> load_registry(const fs::path& path)
        {
            std::ifstream input(path);
            if (!input)
            {
                throw std::runtime_error("Missing registry " + path.string());
            }

            std::string line;
            if (!std::getline(input, line))
            {
                throw std::runtime_error("Empty registry " + path.string());
            }
            const std::vector<std::string> headers = split_tsv_line(line);
            std::vector<RegistryRow> rows;
            std::size_t line_number = 1;
            while (std::getline(input, line))
            {
                ++line_number;
                if (line.empty())
                {
                    continue;
                }
                const std::vector<std::string> fields = split_tsv_line(line);
                if (fields.size() != headers.size())
                {
                    throw std::runtime_error(
                        "Registry column mismatch at " + path.string() + ":" + std::to_string(line_number));
                }
                RegistryRow row;
                for (std::size_t index = 0; index < headers.size(); ++index)
                {
                    row.emplace(headers[index], fields[index]);
                }
                rows.emplace_back(std::move(row));
            }
            return rows;
        }

        [[nodiscard]] const RegistryRow* find_binding(
            const std::vector<RegistryRow>& rows,
            const std::string& binding_id)
        {
            const auto found = std::find_if(rows.begin(), rows.end(), [&](const RegistryRow& row) {
                const auto entry = row.find("binding_id");
                return entry != row.end() && entry->second == binding_id;
            });
            return found == rows.end() ? nullptr : &*found;
        }

        [[nodiscard]] bool has_errors(const std::vector<Diagnostic>& diagnostics)
        {
            return std::any_of(diagnostics.begin(), diagnostics.end(), [](const Diagnostic& item) {
                return item.severity == Severity::error;
            });
        }

        void add(
            std::vector<Diagnostic>& diagnostics,
            Severity severity,
            std::string code,
            std::string message)
        {
            diagnostics.push_back(Diagnostic{severity, std::move(code), std::move(message)});
        }

        [[nodiscard]] std::string json_string(
            const Json& object,
            const char* key,
            std::vector<Diagnostic>& diagnostics,
            const std::string& path,
            bool allow_empty = false)
        {
            if (!object.is_object() || !object.contains(key) || !object.at(key).is_string())
            {
                add(diagnostics, Severity::error, "PROJECT_FIELD", path + "." + key + " must be a string");
                return {};
            }
            const std::string value = object.at(key).get<std::string>();
            if (!allow_empty && value.empty())
            {
                add(diagnostics, Severity::error, "PROJECT_FIELD", path + "." + key + " must not be empty");
            }
            return value;
        }

        [[nodiscard]] std::optional<double> json_number(
            const Json& object,
            const char* key,
            std::vector<Diagnostic>& diagnostics,
            const std::string& path,
            bool required)
        {
            if (!object.is_object() || !object.contains(key) || object.at(key).is_null())
            {
                if (required)
                {
                    add(diagnostics, Severity::error, "PROJECT_FIELD", path + "." + key + " must be a number");
                }
                return std::nullopt;
            }
            if (!object.at(key).is_number())
            {
                add(diagnostics, Severity::error, "PROJECT_FIELD", path + "." + key + " must be a number");
                return std::nullopt;
            }
            const double value = object.at(key).get<double>();
            if (!std::isfinite(value))
            {
                add(diagnostics, Severity::error, "NONFINITE_STAT", path + "." + key + " must be finite");
                return std::nullopt;
            }
            return value;
        }

        [[nodiscard]] std::string format_number(const double value)
        {
            std::array<char, 64> buffer{};
            const auto result = std::to_chars(
                buffer.data(), buffer.data() + buffer.size(), value, std::chars_format::general);
            if (result.ec != std::errc{})
            {
                throw std::runtime_error("Unable to format numeric stat");
            }
            return std::string(buffer.data(), result.ptr);
        }

        [[nodiscard]] std::string lua_quote(const std::string& value)
        {
            std::string output = "\"";
            for (const unsigned char character : value)
            {
                switch (character)
                {
                case '\\': output += "\\\\"; break;
                case '"': output += "\\\""; break;
                case '\n': output += "\\n"; break;
                case '\r': output += "\\r"; break;
                case '\t': output += "\\t"; break;
                default:
                    if (character < 0x20)
                    {
                        std::ostringstream escaped;
                        escaped << "\\x" << std::hex << std::uppercase << std::setw(2)
                                << std::setfill('0') << static_cast<int>(character);
                        output += escaped.str();
                    }
                    else
                    {
                        output.push_back(static_cast<char>(character));
                    }
                    break;
                }
            }
            output.push_back('"');
            return output;
        }

        [[nodiscard]] std::string lua_identifier(const std::string& value)
        {
            std::string output;
            output.reserve(value.size() + 1);
            if (value.empty() || std::isdigit(static_cast<unsigned char>(value.front())) != 0)
            {
                output.push_back('_');
            }
            for (const unsigned char character : value)
            {
                if (std::isalnum(character) != 0 || character == '_')
                {
                    output.push_back(static_cast<char>(character));
                }
                else
                {
                    output.push_back('_');
                }
            }
            return output;
        }

        [[nodiscard]] std::wstring utf8_to_wide(const std::string& value)
        {
            if (value.empty())
            {
                return {};
            }
            const int count = MultiByteToWideChar(
                CP_UTF8, MB_ERR_INVALID_CHARS, value.data(), static_cast<int>(value.size()), nullptr, 0);
            if (count <= 0)
            {
                throw std::runtime_error("Invalid UTF-8 text");
            }
            std::wstring result(static_cast<std::size_t>(count), L'\0');
            MultiByteToWideChar(
                CP_UTF8,
                MB_ERR_INVALID_CHARS,
                value.data(),
                static_cast<int>(value.size()),
                result.data(),
                count);
            return result;
        }

        [[nodiscard]] std::string quote_process_argument(const fs::path& value)
        {
            std::string text = value.string();
            std::string result = "\"";
            std::size_t backslashes = 0;
            for (const char character : text)
            {
                if (character == '\\')
                {
                    ++backslashes;
                    continue;
                }
                if (character == '"')
                {
                    result.append(backslashes * 2 + 1, '\\');
                    result.push_back('"');
                    backslashes = 0;
                    continue;
                }
                result.append(backslashes, '\\');
                backslashes = 0;
                result.push_back(character);
            }
            result.append(backslashes * 2, '\\');
            result.push_back('"');
            return result;
        }

        [[nodiscard]] ProcessResult run_process(const std::string& command, const fs::path& working_directory)
        {
            wchar_t temporary_directory[MAX_PATH + 1]{};
            if (GetTempPathW(MAX_PATH, temporary_directory) == 0)
            {
                throw std::runtime_error("GetTempPathW failed");
            }
            wchar_t temporary_file[MAX_PATH + 1]{};
            if (GetTempFileNameW(temporary_directory, L"rae", 0, temporary_file) == 0)
            {
                throw std::runtime_error("GetTempFileNameW failed");
            }

            SECURITY_ATTRIBUTES security{};
            security.nLength = sizeof(security);
            security.bInheritHandle = TRUE;
            HANDLE log_handle = CreateFileW(
                temporary_file,
                GENERIC_WRITE,
                FILE_SHARE_READ | FILE_SHARE_WRITE,
                &security,
                CREATE_ALWAYS,
                FILE_ATTRIBUTE_TEMPORARY,
                nullptr);
            if (log_handle == INVALID_HANDLE_VALUE)
            {
                DeleteFileW(temporary_file);
                throw std::runtime_error("Unable to create process log");
            }

            STARTUPINFOW startup{};
            startup.cb = sizeof(startup);
            startup.dwFlags = STARTF_USESTDHANDLES;
            startup.hStdOutput = log_handle;
            startup.hStdError = log_handle;
            startup.hStdInput = GetStdHandle(STD_INPUT_HANDLE);

            PROCESS_INFORMATION process{};
            std::wstring mutable_command = utf8_to_wide(command);
            mutable_command.push_back(L'\0');
            const std::wstring working = working_directory.wstring();
            const BOOL created = CreateProcessW(
                nullptr,
                mutable_command.data(),
                nullptr,
                nullptr,
                TRUE,
                CREATE_NO_WINDOW,
                nullptr,
                working.empty() ? nullptr : working.c_str(),
                &startup,
                &process);
            if (!created)
            {
                CloseHandle(log_handle);
                DeleteFileW(temporary_file);
                throw std::runtime_error("CreateProcessW failed for: " + command);
            }

            WaitForSingleObject(process.hProcess, INFINITE);
            DWORD exit_code = static_cast<DWORD>(-1);
            GetExitCodeProcess(process.hProcess, &exit_code);
            CloseHandle(process.hThread);
            CloseHandle(process.hProcess);
            CloseHandle(log_handle);

            ProcessResult result;
            result.exit_code = exit_code;
            try
            {
                result.output = read_text(fs::path(temporary_file));
            }
            catch (...)
            {
                DeleteFileW(temporary_file);
                throw;
            }
            DeleteFileW(temporary_file);
            return result;
        }

        [[nodiscard]] std::string sha256_file(const fs::path& path)
        {
            BCRYPT_ALG_HANDLE algorithm = nullptr;
            BCRYPT_HASH_HANDLE hash = nullptr;
            DWORD object_size = 0;
            DWORD hash_size = 0;
            DWORD returned = 0;

            auto require_success = [](const NTSTATUS status, const char* operation) {
                if (status < 0)
                {
                    throw std::runtime_error(std::string("BCrypt failure: ") + operation);
                }
            };

            require_success(
                BCryptOpenAlgorithmProvider(&algorithm, BCRYPT_SHA256_ALGORITHM, nullptr, 0),
                "open SHA-256 provider");
            try
            {
                require_success(
                    BCryptGetProperty(
                        algorithm,
                        BCRYPT_OBJECT_LENGTH,
                        reinterpret_cast<PUCHAR>(&object_size),
                        sizeof(object_size),
                        &returned,
                        0),
                    "query object length");
                require_success(
                    BCryptGetProperty(
                        algorithm,
                        BCRYPT_HASH_LENGTH,
                        reinterpret_cast<PUCHAR>(&hash_size),
                        sizeof(hash_size),
                        &returned,
                        0),
                    "query hash length");
                std::vector<UCHAR> object(object_size);
                std::vector<UCHAR> digest(hash_size);
                require_success(
                    BCryptCreateHash(algorithm, &hash, object.data(), object_size, nullptr, 0, 0),
                    "create hash");

                std::ifstream input(path, std::ios::binary);
                if (!input)
                {
                    throw std::runtime_error("Unable to hash " + path.string());
                }
                std::array<char, 64 * 1024> buffer{};
                while (input)
                {
                    input.read(buffer.data(), static_cast<std::streamsize>(buffer.size()));
                    const std::streamsize count = input.gcount();
                    if (count > 0)
                    {
                        require_success(
                            BCryptHashData(
                                hash,
                                reinterpret_cast<PUCHAR>(buffer.data()),
                                static_cast<ULONG>(count),
                                0),
                            "hash data");
                    }
                }
                require_success(BCryptFinishHash(hash, digest.data(), hash_size, 0), "finish hash");

                std::ostringstream output;
                output << std::hex << std::uppercase << std::setfill('0');
                for (const UCHAR byte : digest)
                {
                    output << std::setw(2) << static_cast<unsigned int>(byte);
                }
                BCryptDestroyHash(hash);
                BCryptCloseAlgorithmProvider(algorithm, 0);
                return output.str();
            }
            catch (...)
            {
                if (hash != nullptr)
                {
                    BCryptDestroyHash(hash);
                }
                BCryptCloseAlgorithmProvider(algorithm, 0);
                throw;
            }
        }

        [[nodiscard]] std::string sha256_text(const fs::path& directory, const std::string& value)
        {
            fs::create_directories(directory);
            const fs::path temporary = directory / ".project-hash-input.tmp";
            write_text(temporary, value);
            const std::string hash = sha256_file(temporary);
            fs::remove(temporary);
            return hash;
        }

        [[nodiscard]] const Json& find_stat(const Json& project, const std::string& id)
        {
            for (const Json& stat : project.at("stats"))
            {
                if (stat.at("id").get<std::string>() == id)
                {
                    return stat;
                }
            }
            throw std::runtime_error("Unknown linked stat: " + id);
        }

        [[nodiscard]] std::string definition_name(const Json& stat)
        {
            return "linkedDefinition_" + lua_identifier(stat.at("id").get<std::string>());
        }

        [[nodiscard]] std::string getter_name(const Json& stat)
        {
            return "linkedStat_" + lua_identifier(stat.at("id").get<std::string>());
        }

        [[nodiscard]] std::string emit_stat_definition(const Json& stat)
        {
            const std::string name = definition_name(stat);
            std::ostringstream output;
            output << "local " << name << " = {\n"
                   << "    base = " << format_number(stat.at("base").get<double>()) << ",\n";
            if (stat.contains("minimum") && stat.at("minimum").is_number())
            {
                output << "    minimum = " << format_number(stat.at("minimum").get<double>()) << ",\n";
            }
            if (stat.contains("maximum") && stat.at("maximum").is_number())
            {
                output << "    maximum = " << format_number(stat.at("maximum").get<double>()) << ",\n";
            }
            output << "}\n\n";
            return output.str();
        }

        [[nodiscard]] std::string emit_clamp(
            const Json& stat,
            const std::string& definition,
            const std::string& expression)
        {
            std::string result = expression;
            if (stat.contains("minimum") && stat.at("minimum").is_number())
            {
                result = "math.max(" + definition + ".minimum, " + result + ")";
            }
            if (stat.contains("maximum") && stat.at("maximum").is_number())
            {
                result = "math.min(" + definition + ".maximum, " + result + ")";
            }
            return result;
        }

        [[nodiscard]] std::string emit_stat_getter(const Json& stat)
        {
            const std::string function_name = getter_name(stat);
            const std::string definition = definition_name(stat);
            const std::string family = stat.at("modifier").at("family").get<std::string>();
            const Json& binding_value = stat.at("modifier").at("binding");
            const std::string binding = binding_value.is_string() ? binding_value.get<std::string>() : std::string{};

            std::ostringstream output;
            output << "local function " << function_name << "(avatar)\n";
            if (family == "NONE")
            {
                output << "    return " << emit_clamp(stat, definition, definition + ".base") << "\n";
            }
            else if (binding == "mallet.strength.channel_10")
            {
                output << "    local modified = Engine.UpgradedValue(" << definition << ".base)\n"
                       << "    if not IsNull(avatar) then\n"
                       << "        local inventoryControl = avatar:InventoryControl()\n"
                       << "        local activePowerSuit = inventoryControl:GetActivePowerSuit()\n"
                       << "        if not IsNull(activePowerSuit) then\n"
                       << "            inventoryControl:ModifyValue(\n"
                       << "                modified,\n"
                       << "                10,\n"
                       << "                activePowerSuit:GetType(),\n"
                       << "                activePowerSuit\n"
                       << "            )\n"
                       << "        end\n"
                       << "    end\n"
                       << "    return " << emit_clamp(stat, definition, "modified:GetModifiedValue()") << "\n";
            }
            else
            {
                throw std::runtime_error("No code generator exists for modifier binding " + binding);
            }
            output << "end\n\n";
            return output.str();
        }

        [[nodiscard]] std::string card_value_expression(const Json& stat, const std::string& value)
        {
            if (stat.at("kind").get<std::string>() == "FRACTION")
            {
                return "(" + value + " * 100)";
            }
            return value;
        }

        [[nodiscard]] std::string artifact_stem(const std::string& project_id)
        {
            std::string result;
            result.reserve(project_id.size());
            for (const unsigned char character : project_id)
            {
                result.push_back(
                    (std::isalnum(character) != 0 || character == '_' || character == '-')
                        ? static_cast<char>(character)
                        : '_');
            }
            return result;
        }

        [[nodiscard]] bool contains_text(const std::string& value, const std::string_view needle)
        {
            return value.find(needle) != std::string::npos;
        }

        [[nodiscard]] fs::path locate_workspace_root(const fs::path& project_root)
        {
            fs::path cursor = fs::absolute(project_root);
            for (int depth = 0; depth < 10; ++depth)
            {
                if (fs::exists(cursor / "WORKSPACE.json"))
                {
                    return cursor;
                }
                if (!cursor.has_parent_path() || cursor.parent_path() == cursor)
                {
                    break;
                }
                cursor = cursor.parent_path();
            }
            throw std::runtime_error(
                "Unable to locate WORKSPACE.json above the Ability Editor root");
        }

        [[nodiscard]] fs::path resolve_workspace_path(
            const fs::path& project_root,
            const std::string& section,
            const std::string& key)
        {
            const fs::path workspace_root = locate_workspace_root(project_root);
            const Json manifest = Json::parse(read_text(workspace_root / "WORKSPACE.json"));
            if (!manifest.contains(section) || !manifest.at(section).is_object()
                || !manifest.at(section).contains(key)
                || !manifest.at(section).at(key).is_string())
            {
                throw std::runtime_error(
                    "WORKSPACE.json is missing " + section + "." + key);
            }
            return fs::weakly_canonical(
                workspace_root / manifest.at(section).at(key).get<std::string>());
        }
    }

    std::string severity_name(const Severity severity)
    {
        switch (severity)
        {
        case Severity::info: return "INFO";
        case Severity::warning: return "WARNING";
        case Severity::error: return "ERROR";
        }
        return "ERROR";
    }

    std::string diagnostics_text(const std::vector<Diagnostic>& diagnostics)
    {
        std::ostringstream output;
        for (const Diagnostic& diagnostic : diagnostics)
        {
            output << severity_name(diagnostic.severity) << " [" << diagnostic.code << "] "
                   << diagnostic.message << '\n';
        }
        return output.str();
    }

    fs::path locate_editor_root(const fs::path& executable_path)
    {
        fs::path cursor = fs::absolute(executable_path).parent_path();
        for (int depth = 0; depth < 10; ++depth)
        {
            if (fs::exists(cursor / "SCHEMA" / "ability_edit.schema.json")
                && fs::exists(cursor / "REGISTRIES" / "hook_registry.tsv"))
            {
                return cursor;
            }
            if (fs::exists(cursor / "WORKSPACE.json"))
            {
                const fs::path configured = resolve_workspace_path(
                    cursor,
                    "repos",
                    "ability_editor");
                if (fs::exists(configured / "SCHEMA" / "ability_edit.schema.json")
                    && fs::exists(configured / "REGISTRIES" / "hook_registry.tsv"))
                {
                    return configured;
                }
                throw std::runtime_error(
                    "WORKSPACE.json points to an invalid Ability Editor repository: "
                    + configured.string());
            }
            if (!cursor.has_parent_path() || cursor.parent_path() == cursor)
            {
                break;
            }
            cursor = cursor.parent_path();
        }
        throw std::runtime_error("Unable to locate RENOVICE Ability Editor root");
    }

    Json load_project(const fs::path& path)
    {
        return Json::parse(read_text(path));
    }

    void save_project(const fs::path& path, const Json& project)
    {
        write_text(path, project.dump(2) + "\n");
    }

    Json make_linked_overguard_project(const LinkedAddonForm& form)
    {
        const double base_fraction = form.base_percent / 100.0;
        const double maximum_fraction = form.maximum_percent / 100.0;
        return Json{
            {"project_version", 1},
            {"id", form.project_id},
            {"status", "READY_TO_BUILD"},
            {"authoring_mode", "HYBRID_ADDON_CARD"},
            {"mode_selection", "AUTOMATIC_RECOMMENDATION"},
            {"mode_reason", "Use the proven explicit target-module damage dispatcher while the addon owns gameplay and native card rows."},
            {"target", {
                {"warframe", form.warframe},
                {"ability", form.ability},
                {"ability_identifier", form.ability_identifier},
                {"ability_localize_tag", form.ability_localize_tag},
                {"module_path", form.module_path},
                {"module_body_key", form.module_body_key},
                {"installed_build", form.installed_build},
                {"expected_source_sha256", nullptr},
            }},
            {"effect", {
                {"summary", "Convert a linked percentage of the ability's actual damage result into caster Overguard."},
                {"owner", "ADDON"},
                {"hook", form.hook_binding},
                {"hook_evidence_id", "WF-LIVE-MALLET-EXACT-PIPELINE-2026-08-25"},
                {"authority", "OWNER"},
                {"lifetime", "Current target-addon generation and current DE shared-table generation."},
                {"cleanup", "Restore the previous handler only while this generation still owns the handler slot."},
                {"stacking", "ADD_OVERGUARD_UNTIL_LINKED_CAP"},
            }},
            {"stats", Json::array({
                Json{
                    {"id", form.rate_id},
                    {"label", form.rate_label},
                    {"kind", "FRACTION"},
                    {"base", base_fraction},
                    {"minimum", 0.0},
                    {"maximum", maximum_fraction},
                    {"modifier", {
                        {"family", form.modifier_family},
                        {"binding", form.modifier_binding},
                        {"evidence_id", form.modifier_evidence},
                    }},
                    {"gameplay", {
                        {"consumer", "GRANT_CASTER_OVERGUARD_FROM_EVENT_DAMAGE"},
                        {"expression", "$event.actualDamage * $stat." + form.rate_id},
                    }},
                    {"card", {
                        {"enabled", true},
                        {"ability", form.ability_identifier},
                        {"unit", "/Lotus/Language/Game/UNIT_PERCENT"},
                        {"icon", nullptr},
                        {"order", 101},
                        {"base_expression", nullptr},
                        {"modded_expression", nullptr},
                    }},
                },
                Json{
                    {"id", form.cap_id},
                    {"label", form.cap_label},
                    {"kind", "RAW"},
                    {"base", form.cap_value},
                    {"minimum", 0.0},
                    {"maximum", nullptr},
                    {"modifier", {
                        {"family", "NONE"},
                        {"binding", nullptr},
                        {"evidence_id", nullptr},
                    }},
                    {"gameplay", {
                        {"consumer", "GRANT_CASTER_OVERGUARD_FROM_EVENT_DAMAGE"},
                        {"expression", "$stat." + form.cap_id},
                    }},
                    {"card", {
                        {"enabled", true},
                        {"ability", form.ability_identifier},
                        {"unit", nullptr},
                        {"icon", nullptr},
                        {"order", 100},
                        {"base_expression", nullptr},
                        {"modded_expression", nullptr},
                    }},
                },
            })},
            {"addon_generation", {
                {"template", "LINKED_DAMAGE_TO_CASTER_OVERGUARD"},
                {"hook_binding", form.hook_binding},
                {"handler_slot", form.handler_slot},
                {"ability_localize_tag", form.ability_localize_tag},
                {"trace_prefix", form.trace_prefix},
                {"damage_argument", "actualDamage"},
                {"fraction_stat_id", form.rate_id},
                {"cap_stat_id", form.cap_id},
            }},
            {"description", {
                {"enabled", false},
                {"localization_key", nullptr},
                {"text", nullptr},
            }},
            {"deployment", {
                {"requires_addon", true},
                {"requires_card_extension", false},
                {"requires_native_module", true},
                {"requires_description_override", false},
                {"live_manifest", nullptr},
            }},
        };
    }

    std::vector<Diagnostic> validate_project(const Json& project, const fs::path& editor_root)
    {
        std::vector<Diagnostic> diagnostics;
        if (!project.is_object())
        {
            add(diagnostics, Severity::error, "PROJECT_ROOT", "Project root must be an object");
            return diagnostics;
        }

        try
        {
            const std::string project_id = json_string(project, "id", diagnostics, "project");
            if (!std::regex_match(project_id, std::regex("^[a-z0-9][a-z0-9._-]*$")))
            {
                add(diagnostics, Severity::error, "PROJECT_ID", "Project id must match ^[a-z0-9][a-z0-9._-]*$");
            }
            if (!project.contains("project_version") || project.at("project_version") != 1)
            {
                add(diagnostics, Severity::error, "PROJECT_VERSION", "Only project_version 1 is currently supported");
            }
            const std::string mode = json_string(project, "authoring_mode", diagnostics, "project");
            if (mode != "HYBRID_ADDON_CARD" && mode != "MANAGED_ADDON_CARD_EXTENSION")
            {
                add(
                    diagnostics,
                    Severity::error,
                    "GENERATOR_MODE",
                    "Linked damage-to-Overguard generation currently requires HYBRID_ADDON_CARD or MANAGED_ADDON_CARD_EXTENSION");
            }

            if (!project.contains("target") || !project.at("target").is_object())
            {
                add(diagnostics, Severity::error, "TARGET", "project.target must be an object");
                return diagnostics;
            }
            const Json& target = project.at("target");
            static_cast<void>(json_string(target, "warframe", diagnostics, "target"));
            static_cast<void>(json_string(target, "ability", diagnostics, "target"));
            const std::string ability_identifier = json_string(target, "ability_identifier", diagnostics, "target");
            static_cast<void>(json_string(target, "module_path", diagnostics, "target"));
            static_cast<void>(json_string(target, "installed_build", diagnostics, "target"));
            const std::string body_key = json_string(target, "module_body_key", diagnostics, "target");
            if (!std::regex_match(body_key, std::regex("^[0-9a-fA-F]{16}$")))
            {
                add(diagnostics, Severity::error, "BODY_KEY", "target.module_body_key must contain exactly 16 hexadecimal characters");
            }

            if (!project.contains("effect") || !project.at("effect").is_object())
            {
                add(diagnostics, Severity::error, "EFFECT", "project.effect must be an object");
                return diagnostics;
            }
            const Json& effect = project.at("effect");
            const std::string hook_id = json_string(effect, "hook", diagnostics, "effect");

            const std::vector<RegistryRow> hook_registry =
                load_registry(editor_root / "REGISTRIES" / "hook_registry.tsv");
            const RegistryRow* hook = find_binding(hook_registry, hook_id);
            if (hook == nullptr)
            {
                add(diagnostics, Severity::error, "HOOK_UNKNOWN", "Hook binding is not registered: " + hook_id);
            }
            else if (hook->at("status") != "LIVE_CONFIRMED")
            {
                add(diagnostics, Severity::error, "HOOK_UNPROVEN", "Hook binding is not LIVE_CONFIRMED: " + hook_id);
            }
            else
            {
                const std::string scoped_body = hook->at("target_module_body_key");
                const std::string scoped_ability = hook->at("target_ability_identifier");
                if ((scoped_body != "*" && scoped_body != body_key)
                    || (scoped_ability != "*" && scoped_ability != ability_identifier))
                {
                    add(
                        diagnostics,
                        Severity::error,
                        "HOOK_TARGET_SCOPE",
                        hook_id + " is registered for body " + scoped_body + " / ability "
                            + scoped_ability + ", not the selected target");
                }
            }

            if (!project.contains("stats") || !project.at("stats").is_array() || project.at("stats").empty())
            {
                add(diagnostics, Severity::error, "STATS", "project.stats must be a non-empty array");
                return diagnostics;
            }

            const std::vector<RegistryRow> modifier_registry =
                load_registry(editor_root / "REGISTRIES" / "modifier_bindings.tsv");
            std::set<std::string> stat_ids;
            for (std::size_t index = 0; index < project.at("stats").size(); ++index)
            {
                const Json& stat = project.at("stats").at(index);
                const std::string path = "stats[" + std::to_string(index) + "]";
                const std::string id = json_string(stat, "id", diagnostics, path);
                if (!std::regex_match(id, std::regex("^[a-z0-9][a-z0-9._-]*$")))
                {
                    add(diagnostics, Severity::error, "STAT_ID", path + ".id has an invalid format");
                }
                if (!stat_ids.emplace(id).second)
                {
                    add(diagnostics, Severity::error, "STAT_DUPLICATE", "Duplicate stat id: " + id);
                }
                static_cast<void>(json_string(stat, "label", diagnostics, path));
                const std::string kind = json_string(stat, "kind", diagnostics, path);
                const std::optional<double> base = json_number(stat, "base", diagnostics, path, true);
                const std::optional<double> minimum = json_number(stat, "minimum", diagnostics, path, false);
                const std::optional<double> maximum = json_number(stat, "maximum", diagnostics, path, false);
                if (minimum && maximum && *minimum > *maximum)
                {
                    add(diagnostics, Severity::error, "STAT_RANGE", path + " minimum exceeds maximum");
                }
                if (base && minimum && *base < *minimum)
                {
                    add(diagnostics, Severity::error, "STAT_RANGE", path + " base is below minimum");
                }
                if (base && maximum && *base > *maximum)
                {
                    add(diagnostics, Severity::error, "STAT_RANGE", path + " base is above maximum");
                }

                if (!stat.contains("modifier") || !stat.at("modifier").is_object())
                {
                    add(diagnostics, Severity::error, "MODIFIER", path + ".modifier must be an object");
                    continue;
                }
                const Json& modifier = stat.at("modifier");
                const std::string family = json_string(modifier, "family", diagnostics, path + ".modifier");
                if (family == "NONE")
                {
                    if (modifier.contains("binding") && !modifier.at("binding").is_null())
                    {
                        add(diagnostics, Severity::error, "MODIFIER_NONE", path + " uses family NONE but still declares a binding");
                    }
                }
                else
                {
                    const std::string binding_id = json_string(modifier, "binding", diagnostics, path + ".modifier");
                    const RegistryRow* binding = find_binding(modifier_registry, binding_id);
                    if (binding == nullptr)
                    {
                        add(diagnostics, Severity::error, "MODIFIER_UNKNOWN", "Modifier binding is not registered: " + binding_id);
                    }
                    else
                    {
                        if (binding->at("family") != family)
                        {
                            add(diagnostics, Severity::error, "MODIFIER_FAMILY", "Modifier binding family does not match stat family: " + binding_id);
                        }
                        if (binding->at("status") == "UNRESOLVED")
                        {
                            add(diagnostics, Severity::error, "MODIFIER_UNRESOLVED", "Modifier binding remains unresolved: " + binding_id);
                        }
                        else if (binding->at("status") != "LIVE_CONFIRMED")
                        {
                            add(
                                diagnostics,
                                Severity::warning,
                                "MODIFIER_LIVE_REMAINING",
                                binding_id + " is " + binding->at("status") + "; " + binding->at("live_acceptance_remaining"));
                        }
                        const std::string scoped_body = binding->at("target_module_body_key");
                        const std::string scoped_ability = binding->at("target_ability_identifier");
                        if ((scoped_body != "*" && scoped_body != body_key)
                            || (scoped_ability != "*" && scoped_ability != ability_identifier))
                        {
                            add(
                                diagnostics,
                                Severity::error,
                                "MODIFIER_TARGET_SCOPE",
                                binding_id + " is registered for body " + scoped_body + " / ability "
                                    + scoped_ability + ", not the selected target");
                        }
                    }
                }

                if (!stat.contains("card") || !stat.at("card").is_object())
                {
                    add(diagnostics, Severity::error, "CARD", path + ".card must be an object");
                }
                else if (stat.at("card").value("enabled", false) && kind == "FRACTION")
                {
                    const std::string unit = stat.at("card").value("unit", "");
                    if (unit != "/Lotus/Language/Game/UNIT_PERCENT")
                    {
                        add(diagnostics, Severity::error, "FRACTION_UNIT", path + " is FRACTION and must use the native percent unit");
                    }
                }
            }

            if (!project.contains("addon_generation") || !project.at("addon_generation").is_object())
            {
                add(diagnostics, Severity::error, "ADDON_GENERATION", "project.addon_generation must be an object");
                return diagnostics;
            }
            const Json& generation = project.at("addon_generation");
            const std::string template_id = json_string(generation, "template", diagnostics, "addon_generation");
            if (template_id != "LINKED_DAMAGE_TO_CASTER_OVERGUARD")
            {
                add(diagnostics, Severity::error, "TEMPLATE_UNKNOWN", "Unsupported addon template: " + template_id);
            }
            const std::string generation_hook = json_string(generation, "hook_binding", diagnostics, "addon_generation");
            if (generation_hook != hook_id)
            {
                add(diagnostics, Severity::error, "HOOK_MISMATCH", "effect.hook and addon_generation.hook_binding must be identical");
            }
            const std::string handler_slot = json_string(generation, "handler_slot", diagnostics, "addon_generation");
            if (!std::regex_match(handler_slot, std::regex("^[A-Z][A-Z0-9_]*$")))
            {
                add(diagnostics, Severity::error, "HANDLER_SLOT", "handler_slot must be an uppercase Lua field identifier");
            }
            const std::string localize_tag = json_string(generation, "ability_localize_tag", diagnostics, "addon_generation");
            if (localize_tag.rfind("/Lotus/", 0) != 0)
            {
                add(diagnostics, Severity::error, "ABILITY_TAG", "ability_localize_tag must be an existing /Lotus/ localization path");
            }
            const std::string fraction_id = json_string(generation, "fraction_stat_id", diagnostics, "addon_generation");
            const std::string cap_id = json_string(generation, "cap_stat_id", diagnostics, "addon_generation");
            if (stat_ids.count(fraction_id) == 0)
            {
                add(diagnostics, Severity::error, "STAT_REFERENCE", "fraction_stat_id does not reference a declared stat: " + fraction_id);
            }
            else if (find_stat(project, fraction_id).at("kind") != "FRACTION")
            {
                add(diagnostics, Severity::error, "STAT_KIND", "fraction_stat_id must reference a FRACTION stat");
            }
            if (stat_ids.count(cap_id) == 0)
            {
                add(diagnostics, Severity::error, "STAT_REFERENCE", "cap_stat_id does not reference a declared stat: " + cap_id);
            }
            if (generation.value("damage_argument", "") != "actualDamage")
            {
                add(diagnostics, Severity::error, "EVENT_ARGUMENT", "The proven damage-dispatch template exposes the numeric argument as actualDamage");
            }

            if (!project.contains("deployment") || !project.at("deployment").is_object())
            {
                add(diagnostics, Severity::error, "DEPLOYMENT", "project.deployment must be an object");
            }
            else
            {
                const Json& deployment = project.at("deployment");
                if (!deployment.value("requires_addon", false))
                {
                    add(diagnostics, Severity::error, "DEPLOYMENT", "Linked addon generation requires requires_addon=true");
                }
                if (mode == "HYBRID_ADDON_CARD" && !deployment.value("requires_native_module", false))
                {
                    add(diagnostics, Severity::error, "DEPLOYMENT", "Compatibility hybrid requires requires_native_module=true for the proven dispatch shim");
                }
            }
        }
        catch (const std::exception& exception)
        {
            add(diagnostics, Severity::error, "PROJECT_EXCEPTION", exception.what());
        }

        if (!has_errors(diagnostics))
        {
            add(
                diagnostics,
                Severity::info,
                "LINKED_STAT_INVARIANT",
                "Gameplay and card projections will be generated from the same canonical stat accessors");
        }
        return diagnostics;
    }

    std::string generate_target_addon_source(const Json& project, const fs::path& editor_root)
    {
        const std::vector<Diagnostic> diagnostics = validate_project(project, editor_root);
        if (has_errors(diagnostics))
        {
            throw std::runtime_error("Project validation failed:\n" + diagnostics_text(diagnostics));
        }

        const Json& generation = project.at("addon_generation");
        const std::string handler_slot = generation.at("handler_slot").get<std::string>();
        const std::string localize_tag = generation.at("ability_localize_tag").get<std::string>();
        const std::string trace_prefix = generation.value("trace_prefix", "renovice.addon");
        const std::string fraction_stat_id = generation.at("fraction_stat_id").get<std::string>();
        const std::string cap_stat_id = generation.at("cap_stat_id").get<std::string>();
        const Json& fraction_stat = find_stat(project, fraction_stat_id);
        const Json& cap_stat = find_stat(project, cap_stat_id);

        std::ostringstream output;
        output << "-- Generated by RENOVICE Ability Editor. Do not hand-edit generated sections.\n"
               << "-- Canonical project: " << project.at("id").get<std::string>() << "\n\n"
               << "local shared = _T\n"
               << "if shared == nil then\n"
               << "    error(\"RENOVICE_LINKED_ADDON_SHARED_T_MISSING\")\n"
               << "end\n\n"
               << "local ABILITY_LOCALIZE_TAG = " << lua_quote(localize_tag) << "\n"
               << "local previousHandler = nil\n"
               << "local active = false\n\n"
               << "local function trace(stage, ...)\n"
               << "    local bridge = shared.RENOVICE_TRACE\n"
               << "    if type(bridge) == \"function\" then\n"
               << "        bridge(stage, ...)\n"
               << "    end\n"
               << "end\n\n"
               << "local function matchesAbility(ability)\n"
               << "    if IsNull(ability) then\n"
               << "        return false\n"
               << "    end\n"
               << "    return ability:GetLocalizeTag():c_str() == ABILITY_LOCALIZE_TAG\n"
               << "end\n\n";

        for (const Json& stat : project.at("stats"))
        {
            output << emit_stat_definition(stat);
        }
        for (const Json& stat : project.at("stats"))
        {
            output << emit_stat_getter(stat);
        }

        const std::string rate_getter = getter_name(fraction_stat);
        const std::string cap_getter = getter_name(cap_stat);
        output << "local function onLinkedDamage(caster, sourceAbility, targetEntity, actualDamage)\n"
               << "    trace(" << lua_quote(trace_prefix + ".damage.enter")
               << ", caster, sourceAbility, targetEntity, actualDamage)\n"
               << "    if IsNull(caster) then\n"
               << "        trace(" << lua_quote(trace_prefix + ".damage.reject") << ", \"caster-null\")\n"
               << "        return\n"
               << "    end\n"
               << "    if type(actualDamage) ~= \"number\" or actualDamage <= 0 then\n"
               << "        trace(" << lua_quote(trace_prefix + ".damage.reject") << ", \"invalid-damage\", actualDamage)\n"
               << "        return\n"
               << "    end\n\n"
               << "    local damageControl = caster:DamageControl()\n"
               << "    if IsNull(damageControl) then\n"
               << "        trace(" << lua_quote(trace_prefix + ".damage.reject") << ", \"damage-control-null\")\n"
               << "        return\n"
               << "    end\n\n"
               << "    local cap = " << cap_getter << "(caster)\n"
               << "    local current = damageControl:GetOverguardAmount()\n"
               << "    if current >= cap then\n"
               << "        trace(" << lua_quote(trace_prefix + ".damage.reject") << ", \"at-cap\", current, cap)\n"
               << "        return\n"
               << "    end\n\n"
               << "    local fraction = " << rate_getter << "(caster)\n"
               << "    local grant = actualDamage * fraction\n"
               << "    local newAmount = math.min(cap, current + grant)\n"
               << "    trace(" << lua_quote(trace_prefix + ".damage.computed")
               << ", actualDamage, fraction, current, grant, newAmount)\n"
               << "    if current < newAmount then\n"
               << "        damageControl:SetOverguardAmount(newAmount)\n"
               << "        caster:NotifyOverguardGain(caster:GetPlayer(), newAmount - current)\n"
               << "        trace(" << lua_quote(trace_prefix + ".overguard.done") << ", newAmount - current, newAmount)\n"
               << "    end\n"
               << "end\n\n";

        std::vector<const Json*> card_stats;
        for (const Json& stat : project.at("stats"))
        {
            if (stat.at("card").value("enabled", false))
            {
                card_stats.push_back(&stat);
            }
        }
        std::sort(card_stats.begin(), card_stats.end(), [](const Json* left, const Json* right) {
            const int left_order = left->at("card").value("order", 0);
            const int right_order = right->at("card").value("order", 0);
            if (left_order != right_order)
            {
                return left_order < right_order;
            }
            return left->at("id").get<std::string>() < right->at("id").get<std::string>();
        });

        output << "local function augmentAbilityCard(rows, query)\n";
        for (const Json* stat : card_stats)
        {
            const std::string local_name = "card_" + lua_identifier(stat->at("id").get<std::string>());
            output << "    local " << local_name << " = " << definition_name(*stat) << ".base\n"
                   << "    if query ~= nil and query.Modded == true then\n"
                   << "        " << local_name << " = " << getter_name(*stat) << "(query.Avatar)\n"
                   << "    end\n"
                   << "    table.insert(rows, {\n"
                   << "        Label = " << lua_quote(stat->at("label").get<std::string>()) << ",\n"
                   << "        Value = " << card_value_expression(*stat, local_name) << ",\n";
            const Json& unit = stat->at("card").at("unit");
            if (unit.is_string())
            {
                output << "        ValueUnit = " << lua_quote(unit.get<std::string>()) << ",\n";
            }
            const Json& icon = stat->at("card").at("icon");
            if (icon.is_string())
            {
                output << "        ValueIcon = " << lua_quote(icon.get<std::string>()) << ",\n";
            }
            output << "    })\n\n";
        }
        output << "    return rows\n"
               << "end\n\n"
               << "local function activate()\n"
               << "    trace(" << lua_quote(trace_prefix + ".activate.enter") << ", active, shared." << handler_slot << ")\n"
               << "    if active then\n"
               << "        return\n"
               << "    end\n"
               << "    previousHandler = shared." << handler_slot << "\n"
               << "    shared." << handler_slot << " = onLinkedDamage\n"
               << "    active = true\n"
               << "    trace(" << lua_quote(trace_prefix + ".activate.done") << ", shared." << handler_slot << ", previousHandler)\n"
               << "end\n\n"
               << "local function cleanup()\n"
               << "    trace(" << lua_quote(trace_prefix + ".cleanup.enter") << ", active, shared." << handler_slot << ")\n"
               << "    if not active then\n"
               << "        return\n"
               << "    end\n"
               << "    if shared." << handler_slot << " == onLinkedDamage then\n"
               << "        shared." << handler_slot << " = previousHandler\n"
               << "    end\n"
               << "    previousHandler = nil\n"
               << "    active = false\n"
               << "    trace(" << lua_quote(trace_prefix + ".cleanup.done") << ", shared." << handler_slot << ")\n"
               << "end\n\n"
               << "return {\n"
               << "    activate = activate,\n"
               << "    cleanup = cleanup,\n"
               << "    hooks = {\n"
               << "        matchesAbility = matchesAbility,\n"
               << "        afterAbilityCard = augmentAbilityCard,\n"
               << "    },\n"
               << "}\n";
        return output.str();
    }

    BuildResult build_staged_addon(
        const Json& project,
        const fs::path& editor_root,
        const fs::path& staging_root,
        const bool run_external_gates)
    {
        BuildResult result;
        result.diagnostics = validate_project(project, editor_root);
        if (has_errors(result.diagnostics))
        {
            return result;
        }

        try
        {
            const std::string canonical_project = project.dump(2) + "\n";
            const fs::path hash_work = staging_root / ".hash-work";
            const std::string project_hash = sha256_text(hash_work, canonical_project);
            if (fs::exists(hash_work) && fs::is_empty(hash_work))
            {
                fs::remove(hash_work);
            }

            const std::string project_id = project.at("id").get<std::string>();
            const std::string body_key = project.at("target").at("module_body_key").get<std::string>();
            const std::string stem = artifact_stem(project_id);
            result.generation_directory = staging_root / stem / project_hash.substr(0, 12);
            const fs::path source_directory = result.generation_directory / "source";
            const fs::path artifact_directory = result.generation_directory / "artifacts";
            fs::create_directories(source_directory);
            fs::create_directories(artifact_directory);

            result.project_snapshot = result.generation_directory / "ability_edit.json";
            result.generated_source = source_directory / (body_key + "." + stem + ".target.addon.luau");
            result.generated_bytecode = artifact_directory / (body_key + "." + stem + ".target.addon.lua_B");
            result.manifest = result.generation_directory / "BUILD_MANIFEST.json";

            const std::string generated_source = generate_target_addon_source(project, editor_root);
            write_text(result.project_snapshot, canonical_project);
            write_text(result.generated_source, generated_source);
            const std::string source_hash = sha256_file(result.generated_source);

            bool gates_pass = true;
            Json gates = Json::array();
            auto record_gate = [&](const std::string& name, const ProcessResult& process, const bool semantic_pass) {
                result.gate_log += "===== " + name + " =====\n" + process.output;
                if (result.gate_log.empty() || result.gate_log.back() != '\n')
                {
                    result.gate_log.push_back('\n');
                }
                const bool pass = process.exit_code == 0 && semantic_pass;
                gates.push_back({
                    {"name", name},
                    {"exit_code", process.exit_code},
                    {"pass", pass},
                });
                if (!pass)
                {
                    gates_pass = false;
                    add(result.diagnostics, Severity::error, "EXTERNAL_GATE", name + " failed; inspect BUILD_GATES.log");
                }
            };

            if (run_external_gates)
            {
                const fs::path decompiler_root = resolve_workspace_path(
                    editor_root,
                    "repos",
                    "de_luau_toolchain");
                const fs::path derecomp = decompiler_root / "bin" / "derecomp.exe";
                const fs::path api_checker = decompiler_root / "check_ability_api.bat";
                if (!fs::exists(derecomp) || !fs::exists(api_checker))
                {
                    add(result.diagnostics, Severity::error, "TOOLCHAIN", "Canonical DeNativeDecompiler tools are missing");
                    gates_pass = false;
                }
                else
                {
                    const ProcessResult compile = run_process(
                        quote_process_argument(derecomp) + " recompile "
                            + quote_process_argument(result.generated_source) + " "
                            + quote_process_argument(result.generated_bytecode),
                        decompiler_root);
                    record_gate("recompile", compile, contains_text(compile.output, "re-parses=yes"));

                    if (compile.exit_code == 0 && fs::exists(result.generated_bytecode))
                    {
                        const ProcessResult roundtrip = run_process(
                            quote_process_argument(derecomp) + " de-roundtrip "
                                + quote_process_argument(result.generated_bytecode),
                            decompiler_root);
                        record_gate(
                            "de-roundtrip",
                            roundtrip,
                            contains_text(roundtrip.output, "FULL BODY identical: True"));

                        const ProcessResult plan = run_process(
                            quote_process_argument(derecomp) + " plan-verify "
                                + quote_process_argument(result.generated_bytecode),
                            decompiler_root);
                        record_gate(
                            "plan-verify",
                            plan,
                            !contains_text(plan.output, "failures=1")
                                && contains_text(plan.output, "failures=0"));

                        const std::string checker_command =
                            "cmd.exe /d /s /c \"\"" + api_checker.string() + "\" \""
                            + result.generated_source.string() + "\" --strict-unknown\"";
                        const ProcessResult api = run_process(checker_command, decompiler_root);
                        record_gate(
                            "focused-api-check",
                            api,
                            contains_text(api.output, "violations=0")
                                && contains_text(api.output, "focused script check PASS"));
                    }
                    else
                    {
                        gates_pass = false;
                    }
                }
            }
            else
            {
                gates.push_back({{"name", "external-gates"}, {"pass", false}, {"skipped", true}});
                add(result.diagnostics, Severity::warning, "GATES_SKIPPED", "External compile and semantic gates were skipped");
            }

            write_text(result.generation_directory / "BUILD_GATES.log", result.gate_log);
            Json manifest{
                {"format", "RENOVICE_ABILITY_EDITOR_BUILD_V1"},
                {"status", gates_pass ? "STAGED_PASS" : "STAGED_FAILED"},
                {"project_id", project_id},
                {"project_sha256", project_hash},
                {"source", {
                    {"path", fs::relative(result.generated_source, result.generation_directory).generic_string()},
                    {"sha256", source_hash},
                }},
                {"artifact", nullptr},
                {"intended_live_relative_path", "OpenWF/CustomScripts/Inject/" + result.generated_bytecode.filename().string()},
                {"live_write_performed", false},
                {"gates", gates},
                {"diagnostics", Json::array()},
            };
            if (fs::exists(result.generated_bytecode))
            {
                manifest["artifact"] = {
                    {"path", fs::relative(result.generated_bytecode, result.generation_directory).generic_string()},
                    {"sha256", sha256_file(result.generated_bytecode)},
                    {"size", fs::file_size(result.generated_bytecode)},
                };
            }
            for (const Diagnostic& diagnostic : result.diagnostics)
            {
                manifest["diagnostics"].push_back({
                    {"severity", severity_name(diagnostic.severity)},
                    {"code", diagnostic.code},
                    {"message", diagnostic.message},
                });
            }
            write_text(result.manifest, manifest.dump(2) + "\n");
            result.success = gates_pass && !has_errors(result.diagnostics);
        }
        catch (const std::exception& exception)
        {
            add(result.diagnostics, Severity::error, "BUILD_EXCEPTION", exception.what());
            result.success = false;
        }
        return result;
    }

    bool run_self_tests(const fs::path& editor_root, std::string& report)
    {
        int passed = 0;
        int failed = 0;
        std::ostringstream output;
        auto check = [&](const bool condition, const std::string& name) {
            if (condition)
            {
                ++passed;
                output << "PASS " << name << '\n';
            }
            else
            {
                ++failed;
                output << "FAIL " << name << '\n';
            }
        };

        try
        {
            const Json project = make_linked_overguard_project(LinkedAddonForm{});
            const std::vector<Diagnostic> diagnostics = validate_project(project, editor_root);
            check(!has_errors(diagnostics), "valid linked-stat project");
            check(
                std::any_of(diagnostics.begin(), diagnostics.end(), [](const Diagnostic& diagnostic) {
                    return diagnostic.code == "LINKED_STAT_INVARIANT";
                }),
                "linked-stat invariant emitted");

            const std::string source = generate_target_addon_source(project, editor_root);
            const auto occurrences = [](const std::string& text, const std::string& needle) {
                std::size_t count = 0;
                std::size_t position = 0;
                while ((position = text.find(needle, position)) != std::string::npos)
                {
                    ++count;
                    position += needle.size();
                }
                return count;
            };
            check(contains_text(source, "local function linkedStat_damage_to_overguard(avatar)"), "rate accessor generated");
            check(contains_text(source, "local fraction = linkedStat_damage_to_overguard(caster)"), "gameplay uses rate accessor");
            check(contains_text(source, "card_damage_to_overguard = linkedStat_damage_to_overguard(query.Avatar)"), "card uses same rate accessor");
            check(contains_text(source, "local cap = linkedStat_overguard_cap(caster)"), "gameplay uses cap accessor");
            check(contains_text(source, "card_overguard_cap = linkedStat_overguard_cap(query.Avatar)"), "card uses same cap accessor");
            check(contains_text(source, "ValueUnit = \"/Lotus/Language/Game/UNIT_PERCENT\""), "native percent unit generated");
            check(contains_text(source, "shared.RENOVICE_AFTER_MALLET_DAMAGE = onLinkedDamage"), "proven handler slot generated");
            check(occurrences(source, "0.01") == 1, "base fraction literal emitted once");
            check(occurrences(source, "0.05") == 1, "maximum fraction literal emitted once");
            check(occurrences(source, "15000") == 1, "cap literal emitted once");

            Json changed = project;
            changed["stats"][0]["base"] = 0.02;
            const std::string changed_source = generate_target_addon_source(changed, editor_root);
            check(source != changed_source, "canonical base change regenerates output");
            check(contains_text(changed_source, "base = 0.02"), "changed base reaches canonical Lua definition");

            Json duplicate = project;
            duplicate["stats"].push_back(duplicate["stats"][0]);
            check(has_errors(validate_project(duplicate, editor_root)), "duplicate stat rejected");

            Json unknown_modifier = project;
            unknown_modifier["stats"][0]["modifier"]["binding"] = "invented.selector";
            check(has_errors(validate_project(unknown_modifier, editor_root)), "unknown modifier rejected");

            Json unknown_hook = project;
            unknown_hook["effect"]["hook"] = "invented.hook";
            unknown_hook["addon_generation"]["hook_binding"] = "invented.hook";
            check(has_errors(validate_project(unknown_hook, editor_root)), "unknown hook rejected");

            Json wrong_target = project;
            wrong_target["target"]["module_body_key"] = "1111111111111111";
            wrong_target["target"]["ability_identifier"] = "NOT_MALLET";
            check(has_errors(validate_project(wrong_target, editor_root)), "scope-bound Mallet bindings reject another target");

            Json invalid_slot = project;
            invalid_slot["addon_generation"]["handler_slot"] = "slot; injected";
            check(has_errors(validate_project(invalid_slot, editor_root)), "unsafe handler slot rejected");

            Json invalid_range = project;
            invalid_range["stats"][0]["maximum"] = 0.005;
            check(has_errors(validate_project(invalid_range, editor_root)), "base above cap rejected");

            Json wrong_unit = project;
            wrong_unit["stats"][0]["card"]["unit"] = nullptr;
            check(has_errors(validate_project(wrong_unit, editor_root)), "fraction without percent unit rejected");

            check(source == generate_target_addon_source(project, editor_root), "generation is deterministic");
            check(load_project(editor_root / "SCHEMA" / "ability_edit.schema.json").is_object(), "schema parses");
            check(load_project(editor_root / "EXAMPLES" / "gyre_movement_speed_addon.json").is_object(), "existing example parses");
        }
        catch (const std::exception& exception)
        {
            ++failed;
            output << "FAIL unexpected exception: " << exception.what() << '\n';
        }

        output << "SUMMARY passed=" << passed << " failed=" << failed << '\n';
        report = output.str();
        return failed == 0;
    }
}
