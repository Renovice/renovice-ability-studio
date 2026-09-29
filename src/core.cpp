#include "renovice/core.hpp"

#include <algorithm>
#include <array>
#include <bit>
#include <charconv>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <functional>
#include <iomanip>
#include <limits>
#include <map>
#include <regex>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string_view>
#include <tuple>
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
                output << "    if IsNull(avatar) then\n"
                       << "        return " << emit_clamp(stat, definition, definition + ".base") << "\n"
                       << "    end\n"
                       << "    local inventoryControl = avatar:InventoryControl()\n"
                       << "    local activePowerSuit = inventoryControl:GetActivePowerSuit()\n"
                       << "    if IsNull(activePowerSuit) then\n"
                       << "        return " << emit_clamp(stat, definition, definition + ".base") << "\n"
                       << "    end\n"
                       << "    local modified = inventoryControl:GetUpgradeModifiedValue(\n"
                       << "        " << definition << ".base,\n"
                       << "        10,\n"
                       << "        activePowerSuit:GetType(),\n"
                       << "        activePowerSuit\n"
                       << "    )\n"
                       << "    return " << emit_clamp(stat, definition, "modified") << "\n";
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
            {"authoring_mode", "MANAGED_ADDON_CARD_EXTENSION"},
            {"mode_selection", "AUTOMATIC_RECOMMENDATION"},
            {"mode_reason", "Use the universal exact-target addon host for reported damage, card rows, and instruction-addressed native calls."},
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
                {"hook_evidence_id", "WF-LIVE-MALLET-EXACT-PIPELINE-2026-08-25;WF-V49-LOW-LEVEL-NATIVE-CALLS"},
                {"authority", "OWNER"},
                {"lifetime", "Current target-addon generation in the exact target DE VM and prototype graph."},
                {"cleanup", "The host removes this generation's rooted callbacks and native-call declarations transactionally."},
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
                        {"expression", "$event.reportedDamage * $stat." + form.rate_id},
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
                        {"family", form.modifier_family},
                        {"binding", form.modifier_binding},
                        {"evidence_id", "WF-STOCK-PAGEMASTERLIFE-OVERGUARD-CAP-OP10"},
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
                {"ability_localize_tag", form.ability_localize_tag},
                {"damage_argument", "reportedDamage"},
                {"fraction_stat_id", form.rate_id},
                {"cap_stat_id", form.cap_id},
                {"native_argument_rewrites", Json::array({
                    Json{
                        {"method", form.native_method},
                        {"prototype", form.native_prototype},
                        {"instruction", form.native_instruction},
                        {"argument", form.native_argument},
                        {"expected", form.native_expected_value},
                        {"replacement", form.native_replacement_value},
                        {"evidence_id", form.native_evidence},
                    },
                })},
            }},
            {"description", {
                {"enabled", false},
                {"localization_key", nullptr},
                {"text", nullptr},
            }},
            {"deployment", {
                {"requires_addon", true},
                {"requires_card_extension", true},
                {"requires_native_module", false},
                {"requires_description_override", false},
                {"live_manifest", nullptr},
            }},
        };
    }

#include "mission_profiles.inl"

    Json discover_linked_card_stats_file(const fs::path& source, const fs::path& names,
        const std::string& body, const fs::path& editor_root) {
        auto result = discover_card_stats_file(source, names, body);
        auto automatic = discover_automatic_card_links(read_text(source), result);
        result["controls"] = automatic.at("controls");
        result["link_rejections"] = automatic.at("rejections");
        result["link_status"] = result["controls"].empty() ? "NO_VERIFIED_GAMEPLAY_BINDING" : "AUTOMATIC_SHARED_STAT_LINKS";
        const auto registry = Json::parse(read_text(editor_root / "REGISTRIES/linked_card_stats.json"));
        if (!registry.at("modules").contains(body)) return result;
        const auto& binding = registry.at("modules").at(body);
        if (sha256_file(source) != binding.at("source_sha256").get<std::string>()) {
            result["controls"] = Json::array();
            result["link_status"] = "SOURCE_CHANGED_REQUIRES_REVIEW";
            return result;
        }
        std::set<std::size_t> used;
        // Reviewed per-rank controls take precedence over automatic whole-stat
        // scales for the same variable; never expose overlapping edits.
        for (const auto& control : binding.at("controls"))
            result["controls"].erase(std::remove_if(result["controls"].begin(), result["controls"].end(),
                [&](const Json& c) { return c.at("variable") == control.at("variable"); }), result["controls"].end());
        for (const auto& control : binding.at("controls")) {
            Json inputs = Json::array();
            std::set<std::string> roles;
            for (const auto& assignment : control.at("assignments")) {
                Json match;
                for (const auto& row : result.at("rows")) {
                    if (row.at("variable") != control.at("variable") || row.at("label_tag") != control.at("label_tag")) continue;
                    for (const auto& input : row.at("inputs"))
                        if (input.at("line") == assignment.at("line")) match = input;
                }
                if (match.is_null() || match.at("original") != control.at("original"))
                    throw std::runtime_error("Linked stat assignment no longer matches native card analysis");
                if (!used.insert(match.at("offset").get<std::size_t>()).second)
                    throw std::runtime_error("Linked stat assignments overlap");
                inputs.push_back(match);
                roles.insert(assignment.at("role").get<std::string>());
            }
            if (!roles.contains("card") || !roles.contains("gameplay"))
                throw std::runtime_error("Linked stat requires both card and gameplay evidence");
            auto linked = control;
            linked["inputs"] = inputs;
            result["controls"].push_back(linked);
        }
        result["link_status"] = "VERIFIED_SOURCE_BINDINGS";
        result["scope"] = binding.at("scope");
        return result;
    }

    std::vector<Diagnostic> validate_project(const Json& project, const fs::path& editor_root)
    {
        std::vector<Diagnostic> diagnostics;
        if (!project.is_object())
        {
            add(diagnostics, Severity::error, "PROJECT_ROOT", "Project root must be an object");
            return diagnostics;
        }

        if (project.contains("mission_profile")) return validate_profile_mission(project, editor_root);

        const std::string managed_mode = project.value("authoring_mode", "");
        if (managed_mode == "MANAGED_MISSION_EXACT_REPLACEMENT")
        {
            try
            {
                const std::string project_id = json_string(project, "id", diagnostics, "project");
                if (!std::regex_match(project_id, std::regex("^[a-z0-9][a-z0-9._-]*$")))
                    add(diagnostics, Severity::error, "PROJECT_ID", "Project id has an invalid format");
                if (!project.contains("project_version") || project.at("project_version") != 1)
                    add(diagnostics, Severity::error, "PROJECT_VERSION", "Only project_version 1 is currently supported");
                if (!project.contains("target") || !project.at("target").is_object())
                    throw std::runtime_error("project.target must be an object");
                const Json& target = project.at("target");
                static_cast<void>(json_string(target, "warframe", diagnostics, "target"));
                static_cast<void>(json_string(target, "ability", diagnostics, "target"));
                const std::string ability_identifier = json_string(target, "ability_identifier", diagnostics, "target");
                const std::string body_key = json_string(target, "module_body_key", diagnostics, "target");
                const std::string module_path = json_string(target, "module_path", diagnostics, "target");
                static_cast<void>(json_string(target, "installed_build", diagnostics, "target"));

                if (!project.contains("effect") || !project.at("effect").is_object())
                    throw std::runtime_error("project.effect must be an object");
                const Json& effect = project.at("effect");
                static_cast<void>(json_string(effect, "summary", diagnostics, "effect"));
                static_cast<void>(json_string(effect, "lifetime", diagnostics, "effect"));
                static_cast<void>(json_string(effect, "cleanup", diagnostics, "effect"));
                if (effect.value("owner", "") != "NATIVE_MODULE"
                    || !effect.contains("hook") || !effect.at("hook").is_null()
                    || effect.value("authority", "") != "OWNER")
                    add(diagnostics, Severity::error, "MISSION_REPLACEMENT_EFFECT", "Exact mission replacement requires NATIVE_MODULE ownership, no runtime hook, and OWNER authority");

                if (!project.contains("stats") || !project.at("stats").is_array()
                    || !project.at("stats").empty())
                    add(diagnostics, Severity::error, "MISSION_REPLACEMENT_STATS", "Mission duration ownership is encoded in replacement_generation; stats must be an empty array");
                if (project.contains("addon_generation"))
                    add(diagnostics, Severity::error, "MISSION_REPLACEMENT_ADDON", "Exact mission replacement cannot retain addon_generation metadata");
                if (!project.contains("replacement_generation") || !project.at("replacement_generation").is_object())
                    throw std::runtime_error("project.replacement_generation must be an object");
                const Json& generation = project.at("replacement_generation");

                const std::string replacement_template = generation.value("template", "");
                std::vector<const char*> duration_fields;
                std::string invariant;
                if (replacement_template == "MISSION_MOBILE_DEFENSE_TIMERS_EXACT_REPLACEMENT")
                {
                    if (body_key != "89329f85c8575b84"
                        || module_path != "Lotus.Scripts.MobileDefense"
                        || ability_identifier != "MOBILE_DEFENSE_TIMER_PATCH")
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_TARGET", "Mobile Defense exact replacement is locked to its stock module and body key");
                    if (generation.value("stock_corpus_file", "") != "Lotus_Scripts_MobileDefense.lua_B"
                        || generation.value("stock_sha256", "") != "E9CBBEF4B6BECA2AC61EC741F3F9A22BA45DF06878708C429176843222B47541"
                        || generation.value("stock_minimum_total_seconds", -1) != 180
                        || generation.value("stock_maximum_total_seconds", -1) != 240)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_STOCK", "Mobile Defense stock artifact or duration constants drifted from the verified body");
                    if (generation.value("minimum_prototype", -1) != 22
                        || generation.value("minimum_instruction", -1) != 120
                        || generation.value("minimum_loadn_occurrence", -1) != 9
                        || generation.value("maximum_prototype", -1) != 22
                        || generation.value("maximum_instruction", -1) != 121
                        || generation.value("maximum_loadn_occurrence", -1) != 10)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_SITE", "Mobile Defense LOADN patch sites drifted from the verified DefenseStage instruction map");
                    duration_fields = {"minimum_total_seconds", "maximum_total_seconds"};
                    const auto minimum = json_number(generation, "minimum_total_seconds", diagnostics, "replacement_generation", true);
                    const auto maximum = json_number(generation, "maximum_total_seconds", diagnostics, "replacement_generation", true);
                    if (minimum && maximum && *minimum > *maximum)
                        add(diagnostics, Severity::error, "TIMER_ORDER", "Mobile Defense minimum total time cannot exceed maximum total time");
                    invariant = "Mobile Defense body 89329f85c8575b84: proto22/i120 180 and i121 240 are the only permitted duration operand edits";
                }
                else if (replacement_template == "MISSION_EXCAVATION_TIMERS_EXACT_REPLACEMENT")
                {
                    if (body_key != "303f809a05c1fbaa"
                        || module_path != "Lotus.Scripts.Modes.ExcavationMission"
                        || ability_identifier != "EXCAVATION_TIMER_PATCH")
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_TARGET", "Excavation exact replacement is locked to its stock module and body key");
                    if (generation.value("stock_corpus_file", "") != "Lotus_Scripts_Modes_ExcavationMission.lua_B"
                        || generation.value("stock_sha256", "") != "A2326FD92DDC2075E03CAB08300744BFA15ED8BDEC7C13FA98DD5071EEEC20C2"
                        || generation.value("stock_standard_seconds", -1) != 100
                        || generation.value("stock_old_world_salvage_seconds", -1) != 60
                        || generation.value("stock_elite_alert_seconds", -1) != 140)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_STOCK", "Excavation stock artifact or duration constants drifted from the verified body");
                    if (generation.value("standard_prototype", -1) != 49
                        || generation.value("standard_instruction", -1) != 76
                        || generation.value("standard_loadn_occurrence", -1) != 33
                        || generation.value("old_world_salvage_prototype", -1) != 32
                        || generation.value("old_world_salvage_instruction", -1) != 81
                        || generation.value("old_world_salvage_loadn_occurrence", -1) != 5
                        || generation.value("elite_alert_prototype", -1) != 32
                        || generation.value("elite_alert_instruction", -1) != 102
                        || generation.value("elite_alert_loadn_occurrence", -1) != 6)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_SITE", "Excavation LOADN patch sites drifted from the verified instruction map");
                    duration_fields = {"standard_dig_seconds", "old_world_salvage_dig_seconds", "elite_alert_dig_seconds"};
                    invariant = "Excavation body 303f809a05c1fbaa: proto49/i76 100 and proto32/i81 60 plus i102 140 are the only permitted operand edits";
                }
                else if (replacement_template == "MISSION_CONTROL_AREA_PLAINS_TIMER_EXACT_REPLACEMENT")
                {
                    if (body_key != "bf3c901cb4058c47"
                        || module_path != "Lotus.Scripts.Eidolon.Encounters.DynamicDefend"
                        || ability_identifier != "CONTROL_AREA_PLAINS_TIMER_PATCH")
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_TARGET", "Plains Control Area exact replacement is locked to its stock module and body key");
                    if (generation.value("stock_corpus_file", "") != "Lotus_Scripts_Eidolon_Encounters_DynamicDefend.lua_B"
                        || generation.value("stock_sha256", "") != "ECC204753DB9BDED69F6A764C919DF5DD2240B5EE907E35C046E99C624D23386"
                        || generation.value("stock_duration_seconds", -1) != 90)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_STOCK", "Plains Control Area stock artifact or duration constant drifted from the verified body");
                    if (generation.value("duration_prototype", -1) != 17
                        || generation.value("duration_instruction", -1) != 44
                        || generation.value("duration_loadn_occurrence", -1) != 3
                        || generation.value("timer_argument_prototype", -1) != 8
                        || generation.value("timer_argument_instruction", -1) != 100
                        || generation.value("timer_argument_move_occurrence", -1) != 0)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_SITE", "Plains Control Area duration owner or SetObjTimer argument site drifted from the verified instruction map");
                    duration_fields = {"duration_seconds"};
                    invariant = "Plains Control Area body bf3c901cb4058c47: root proto17/i44 owns pacing and proto8/i100 supplies SetObjTimer; both are set to the configured duration";
                }
                else if (replacement_template == "MISSION_CONTROL_AREA_DEIMOS_TIMER_EXACT_REPLACEMENT")
                {
                    if (body_key != "d9541341dfd466a3"
                        || module_path != "Lotus.Scripts.InfestedMicroplanet.Encounters.DynamicAreaDefense"
                        || ability_identifier != "CONTROL_AREA_DEIMOS_TIMER_PATCH")
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_TARGET", "Deimos Control Area exact replacement is locked to its stock module and body key");
                    if (generation.value("stock_corpus_file", "") != "Lotus_Scripts_InfestedMicroplanet_Encounters_DynamicAreaDefense.lua_B"
                        || generation.value("stock_sha256", "") != "ECBED12E85416CE5FBB25995D9252F4AD29042F1AE7DAA3C2E4C8A2F25AEDF49"
                        || generation.value("stock_duration_seconds", -1) != 90)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_STOCK", "Deimos Control Area stock artifact or duration constant drifted from the verified body");
                    if (generation.value("duration_prototype", -1) != 15
                        || generation.value("duration_instruction", -1) != 56
                        || generation.value("duration_loadn_occurrence", -1) != 1
                        || generation.value("persistent_result_prototype", -1) != 7
                        || generation.value("persistent_result_instruction", -1) != 63
                        || generation.value("persistent_result_getupval_occurrence", -1) != 15)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_SITE", "Deimos Control Area duration owner or persistent-result override site drifted from the verified instruction map");
                    duration_fields = {"duration_seconds"};
                    invariant = "Deimos Control Area body d9541341dfd466a3: root proto15/i56 owns pacing and proto7/i63 replaces the persisted 90-second result before stock derives halfway timing";
                }
                else if (replacement_template == "MISSION_CONTROL_AREA_NOKKO_TIMER_EXACT_REPLACEMENT")
                {
                    if (body_key != "e192d5cc2f37056e"
                        || module_path != "Lotus.Scripts.Venus.NokkoColony.Encounters.AreaDefense"
                        || ability_identifier != "CONTROL_AREA_NOKKO_TIMER_PATCH")
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_TARGET", "Venus/Nokko Control Area exact replacement is locked to its stock module and body key");
                    if (generation.value("stock_corpus_file", "") != "Lotus_Scripts_Venus_NokkoColony_Encounters_AreaDefense.lua_B"
                        || generation.value("stock_sha256", "") != "E5048C7A1F9AE04DA38BA5AAE18D749A946172A61E67F6D56853BC719246C3F5")
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_STOCK", "Venus/Nokko Control Area stock artifact drifted from the verified body");
                    if (generation.value("timer_argument_prototype", -1) != 5
                        || generation.value("timer_argument_instruction", -1) != 118
                        || generation.value("timer_argument_move_occurrence", -1) != 0
                        || generation.value("halfway_result_prototype", -1) != 6
                        || generation.value("halfway_result_instruction", -1) != 107
                        || generation.value("halfway_sub_occurrence", -1) != 0
                        || generation.value("two_thirds_result_prototype", -1) != 6
                        || generation.value("two_thirds_result_instruction", -1) != 112
                        || generation.value("two_thirds_sub_occurrence", -1) != 1)
                        add(diagnostics, Severity::error, "MISSION_REPLACEMENT_SITE", "Venus/Nokko Control Area timer or linked threshold site drifted from the verified instruction map");
                    duration_fields = {"duration_seconds"};
                    const auto duration = json_number(generation, "duration_seconds", diagnostics, "replacement_generation", true);
                    if (duration && std::floor(*duration) == *duration
                        && static_cast<int>(*duration) % 6 != 0)
                        add(diagnostics, Severity::error, "TIMER_LINKED_INTEGER", "Venus/Nokko duration must be divisible by 6 so its stock one-half and two-thirds thresholds remain exact LOADN values");
                    invariant = "Venus/Nokko body e192d5cc2f37056e: proto5/i118 supplies SetObjTimer while proto6/i107 and i112 own the linked halfway and two-thirds thresholds";
                }
                else
                {
                    add(diagnostics, Severity::error, "TEMPLATE_UNKNOWN", "Unsupported exact mission replacement template");
                }

                for (const char* name : duration_fields)
                {
                    const auto value = json_number(generation, name, diagnostics, "replacement_generation", true);
                    if (value && (!std::isfinite(*value) || *value < 1.0 || *value > 32767.0 || std::floor(*value) != *value))
                        add(diagnostics, Severity::error, "TIMER_INTEGER_RANGE", std::string(name) + " must be a whole number between 1 and 32767 seconds");
                }
                if (!project.contains("deployment") || !project.at("deployment").is_object()
                    || project.at("deployment").value("requires_addon", true)
                    || project.at("deployment").value("requires_card_extension", true)
                    || !project.at("deployment").value("requires_native_module", false))
                    add(diagnostics, Severity::error, "DEPLOYMENT", "Exact mission timer project requires one native replacement and no addon");
                if (!has_errors(diagnostics))
                    add(diagnostics, Severity::info, "MISSION_EXACT_REPLACEMENT_INVARIANT", invariant);
            }
            catch (const std::exception& exception)
            {
                add(diagnostics, Severity::error, "PROJECT_EXCEPTION", exception.what());
            }
            return diagnostics;
        }
        if (managed_mode == "MANAGED_LUA_CALL_ADDON" || managed_mode == "MANAGED_MISSION_ADDON")
        {
            try
            {
                const std::string project_id = json_string(project, "id", diagnostics, "project");
                if (!std::regex_match(project_id, std::regex("^[a-z0-9][a-z0-9._-]*$")))
                    add(diagnostics, Severity::error, "PROJECT_ID", "Project id has an invalid format");
                if (!project.contains("project_version") || project.at("project_version") != 1)
                    add(diagnostics, Severity::error, "PROJECT_VERSION", "Only project_version 1 is currently supported");
                if (!project.contains("target") || !project.at("target").is_object())
                    throw std::runtime_error("project.target must be an object");
                const Json& target = project.at("target");
                static_cast<void>(json_string(target, "warframe", diagnostics, "target"));
                static_cast<void>(json_string(target, "ability", diagnostics, "target"));
                const std::string ability_identifier = json_string(target, "ability_identifier", diagnostics, "target");
                const std::string body_key = json_string(target, "module_body_key", diagnostics, "target");
                const std::string module_path = json_string(target, "module_path", diagnostics, "target");
                static_cast<void>(json_string(target, "installed_build", diagnostics, "target"));
                if (!project.contains("effect") || !project.at("effect").is_object())
                    throw std::runtime_error("project.effect must be an object");
                const Json& effect = project.at("effect");
                static_cast<void>(json_string(effect, "summary", diagnostics, "effect"));
                static_cast<void>(json_string(effect, "lifetime", diagnostics, "effect"));
                static_cast<void>(json_string(effect, "cleanup", diagnostics, "effect"));
                if (!project.contains("stats") || !project.at("stats").is_array()
                    || !project.at("stats").empty())
                    add(diagnostics, Severity::error, "MISSION_ADDON_STATS", "Mission timer ownership is encoded in addon_generation; stats must be an empty array");
                if (!project.contains("addon_generation") || !project.at("addon_generation").is_object())
                    throw std::runtime_error("project.addon_generation must be an object");
                const Json& generation = project.at("addon_generation");
                const std::string addon_template = generation.value("template", "");
                const auto finite_number = [&](const char* name, const double minimum)
                {
                    const auto value = json_number(generation, name, diagnostics, "addon_generation", true);
                    if (value && (*value < minimum || *value > 86400.0))
                        add(diagnostics, Severity::error, "TIMER_RANGE", std::string(name) + " must be between " + format_number(minimum) + " and 86400");
                };
                std::string expected_hook;
                std::string invariant;
                if (addon_template == "MISSION_SURVIVAL_TIMERS_LUA_CALL")
                {
                    expected_hook = "renovice.target.lua_call";
                    invariant = "Survival body 1e3647332a578b78, prototype 64, captures 19/22/70";
                    if (body_key != "1e3647332a578b78"
                        || module_path != "Lotus.Scripts.Modes.SurvivalMission"
                        || ability_identifier != "SURVIVAL_TIMER_PATCH")
                        add(diagnostics, Severity::error, "MISSION_ADDON_TARGET", "Survival timer template is locked to its exact stock module and body key");
                    if (generation.value("prototype", -1) != 64
                        || generation.value("elapsed_reward_upvalue", -1) != 19
                        || generation.value("pickup_config_upvalue", -1) != 22
                        || generation.value("reward_config_upvalue", -1) != 70)
                        add(diagnostics, Severity::error, "MISSION_ADDON_CAPTURE", "Survival prototype/capture contract does not match the verified stock closure map");
                    finite_number("reward_interval_seconds", 1.0);
                    finite_number("life_support_per_pickup_seconds", 0.0);
                    finite_number("reward_progress_per_pickup_seconds", 0.0);
                }
                else if (addon_template == "MISSION_MOBILE_DEFENSE_TIMERS_TARGET")
                {
                    add(diagnostics, Severity::error, "TEMPLATE_RETIRED", "Mobile Defense Lua-entry timer addons are retired after live DefenseStage transition failure; use the exact stock LOADN replacement");
                }
                else if (addon_template == "MISSION_INTERCEPTION_SCORING_TARGET")
                {
                    expected_hook = "renovice.target.lua_call";
                    invariant = "Territory body a51e98a1833bd8c1, prototype 35, stock scoreRatePerSecond 1";
                    if (body_key != "a51e98a1833bd8c1"
                        || module_path != "Lotus.Scripts.Modes.TerritoryMission"
                        || ability_identifier != "INTERCEPTION_SCORING_PATCH")
                        add(diagnostics, Severity::error, "MISSION_ADDON_TARGET", "Interception scoring template is locked to its exact stock module and body key");
                    if (generation.value("prototype", -1) != 35
                        || generation.value("stock_score_rate", -1.0) != 1.0)
                        add(diagnostics, Severity::error, "MISSION_ADDON_CAPTURE", "Interception score-rate owner contract drifted");
                    const auto multiplier = json_number(generation, "scoring_speed_multiplier", diagnostics, "addon_generation", true);
                    if (multiplier && (*multiplier < 0.01 || *multiplier > 100.0))
                        add(diagnostics, Severity::error, "TIMER_RANGE", "scoring_speed_multiplier must be between 0.01 and 100");
                }
                else if (addon_template == "MISSION_CONTROL_AREA_PLAINS_TIMER_TARGET")
                {
                    expected_hook = "renovice.target.native_call";
                    invariant = "Plains Control Area body bf3c901cb4058c47, GetNetPersistentVar result at prototype 8 instruction 30";
                    if (body_key != "bf3c901cb4058c47"
                        || module_path != "Lotus.Scripts.Eidolon.Encounters.DynamicDefend"
                        || ability_identifier != "CONTROL_AREA_PLAINS_TIMER_PATCH")
                        add(diagnostics, Severity::error, "MISSION_ADDON_TARGET", "Plains Control Area timer template is locked to its exact stock module and body key");
                    if (generation.value("method", "") != "GetNetPersistentVar"
                        || generation.value("prototype", -1) != 8
                        || generation.value("instruction", -1) != 30)
                        add(diagnostics, Severity::error, "MISSION_ADDON_CALLSITE", "Plains Control Area duration-result callsite drifted");
                    finite_number("duration_seconds", 1.0);
                }
                else if (addon_template == "MISSION_CONTROL_AREA_DEIMOS_TIMER_TARGET")
                {
                    expected_hook = "renovice.target.native_call";
                    invariant = "Deimos Control Area body d9541341dfd466a3, GetNetPersistentVar result at prototype 7 instruction 62";
                    if (body_key != "d9541341dfd466a3"
                        || module_path != "Lotus.Scripts.InfestedMicroplanet.Encounters.DynamicAreaDefense"
                        || ability_identifier != "CONTROL_AREA_DEIMOS_TIMER_PATCH")
                        add(diagnostics, Severity::error, "MISSION_ADDON_TARGET", "Deimos Control Area timer template is locked to its exact stock module and body key");
                    if (generation.value("method", "") != "GetNetPersistentVar"
                        || generation.value("prototype", -1) != 7
                        || generation.value("instruction", -1) != 62)
                        add(diagnostics, Severity::error, "MISSION_ADDON_CALLSITE", "Deimos Control Area duration-result callsite drifted");
                    finite_number("duration_seconds", 1.0);
                }
                else
                {
                    add(diagnostics, Severity::error, "TEMPLATE_UNKNOWN", "Unsupported mission target-addon template");
                }
                if (managed_mode == "MANAGED_LUA_CALL_ADDON"
                    && addon_template != "MISSION_SURVIVAL_TIMERS_LUA_CALL")
                    add(diagnostics, Severity::error, "LEGACY_MODE_SCOPE", "MANAGED_LUA_CALL_ADDON remains the legacy Survival-only mode");
                if (effect.value("owner", "") != "ADDON"
                    || effect.value("hook", "") != expected_hook
                    || effect.value("authority", "") != "OWNER")
                    add(diagnostics, Severity::error, "MISSION_ADDON_EFFECT", "Mission target addon requires ADDON ownership, its exact registered hook, and OWNER authority");
                if (generation.value("hook_binding", "") != expected_hook)
                    add(diagnostics, Severity::error, "HOOK_MISMATCH", "Mission target-addon hook binding does not match its template");
                if (!project.contains("deployment") || !project.at("deployment").is_object()
                    || !project.at("deployment").value("requires_addon", false)
                    || project.at("deployment").value("requires_card_extension", true)
                    || project.at("deployment").value("requires_native_module", true))
                    add(diagnostics, Severity::error, "DEPLOYMENT", "Mission timer project requires an addon and no replacement module");
                if (!has_errors(diagnostics))
                    add(diagnostics, Severity::info, "MISSION_ADDON_INVARIANT", invariant);
            }
            catch (const std::exception& exception)
            {
                add(diagnostics, Severity::error, "PROJECT_EXCEPTION", exception.what());
            }
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
                    "Linked damage-to-Overguard generation requires MANAGED_ADDON_CARD_EXTENSION or the historical HYBRID_ADDON_CARD mode");
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
            if (generation.value("damage_argument", "") != "reportedDamage")
            {
                add(diagnostics, Severity::error, "EVENT_ARGUMENT", "The target-addon afterDamage contract exposes the engine-reported result as reportedDamage");
            }

            if (!generation.contains("native_argument_rewrites")
                || !generation.at("native_argument_rewrites").is_array())
            {
                add(diagnostics, Severity::error, "NATIVE_REWRITES", "addon_generation.native_argument_rewrites must be an array");
            }
            else if (generation.at("native_argument_rewrites").size() > 32)
            {
                add(diagnostics, Severity::error, "NATIVE_REWRITES", "The V49 host supports at most 32 declared native methods");
            }
            else
            {
                std::set<std::string> rewrite_sites;
                for (std::size_t index = 0; index < generation.at("native_argument_rewrites").size(); ++index)
                {
                    const Json& rewrite = generation.at("native_argument_rewrites").at(index);
                    const std::string path = "addon_generation.native_argument_rewrites[" + std::to_string(index) + "]";
                    if (!rewrite.is_object())
                    {
                        add(diagnostics, Severity::error, "NATIVE_REWRITE", path + " must be an object");
                        continue;
                    }
                    const std::string method = json_string(rewrite, "method", diagnostics, path);
                    if (!std::regex_match(method, std::regex("^[A-Za-z_][A-Za-z0-9_]{0,63}$")))
                    {
                        add(diagnostics, Severity::error, "NATIVE_METHOD", path + ".method is not a valid native method name");
                    }
                    const auto require_nonnegative_integer = [&](const char* field, const int minimum) -> std::optional<int> {
                        if (!rewrite.contains(field) || !rewrite.at(field).is_number_integer())
                        {
                            add(diagnostics, Severity::error, "NATIVE_SITE", path + "." + field + " must be an integer");
                            return std::nullopt;
                        }
                        const int value = rewrite.at(field).get<int>();
                        if (value < minimum)
                        {
                            add(diagnostics, Severity::error, "NATIVE_SITE", path + "." + field + " is below " + std::to_string(minimum));
                            return std::nullopt;
                        }
                        return value;
                    };
                    const std::optional<int> prototype = require_nonnegative_integer("prototype", 0);
                    const std::optional<int> instruction = require_nonnegative_integer("instruction", 0);
                    const std::optional<int> argument = require_nonnegative_integer("argument", 1);
                    const std::optional<double> expected = json_number(rewrite, "expected", diagnostics, path, true);
                    const std::optional<double> replacement = json_number(rewrite, "replacement", diagnostics, path, true);
                    static_cast<void>(expected);
                    static_cast<void>(replacement);
                    const std::string evidence = json_string(rewrite, "evidence_id", diagnostics, path);
                    if (evidence.empty())
                    {
                        add(diagnostics, Severity::error, "NATIVE_EVIDENCE", path + ".evidence_id must identify exact callsite evidence");
                    }
                    if (prototype && instruction && argument)
                    {
                        const std::string site = method + ":" + std::to_string(*prototype) + ":"
                            + std::to_string(*instruction) + ":" + std::to_string(*argument);
                        if (!rewrite_sites.emplace(site).second)
                        {
                            add(diagnostics, Severity::error, "NATIVE_REWRITE_DUPLICATE", "Duplicate native argument rewrite: " + site);
                        }
                    }
                }
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
                    add(diagnostics, Severity::error, "DEPLOYMENT", "Historical compatibility hybrid requires requires_native_module=true");
                }
                if (mode == "MANAGED_ADDON_CARD_EXTENSION"
                    && (!deployment.value("requires_card_extension", false)
                        || deployment.value("requires_native_module", true)))
                {
                    add(diagnostics, Severity::error, "DEPLOYMENT", "Universal target addon card attachment requires card_extension=true and native_module=false");
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

        if (project.value("authoring_mode", "") == "MANAGED_LUA_CALL_ADDON"
            || project.value("authoring_mode", "") == "MANAGED_MISSION_ADDON")
        {
            const Json& generation = project.at("addon_generation");
            const std::string addon_template = generation.at("template").get<std::string>();
            if (addon_template == "MISSION_MOBILE_DEFENSE_TIMERS_TARGET")
            {
                const std::string minimum_total = format_number(generation.at("minimum_total_seconds").get<double>());
                const std::string maximum_total = format_number(generation.at("maximum_total_seconds").get<double>());
                std::ostringstream output;
                output << "-- Generated by RENOVICE Ability Editor. Do not hand-edit generated sections.\n"
                       << "-- Exact target: Lotus.Scripts.MobileDefense / body 89329f85c8575b84\n"
                       << "-- Exact owner: DefenseStage prototype 22 before its CustomMissionTime query at instruction 139\n\n"
                       << "local MINIMUM_TOTAL_SECONDS = " << minimum_total << "\n"
                       << "local MAXIMUM_TOTAL_SECONDS = " << maximum_total << "\n\n"
                       << "local CUSTOM_MISSION_TIME = Symbol(\"CustomMissionTime\")\n\n"
                       << "local active = false\n"
                       << "local configured = false\n"
                       << "local ownerGameRules = nil\n"
                       << "local previousCustomMissionTime = nil\n"
                       << "local ownedCustomMissionTime = nil\n\n"
                       << "local function beforeDefenseStage(prototype, arguments, upvalues)\n"
                       << "    if not active or configured then return end\n"
                       << "    assert(prototype == 22, \"Mobile Defense hook received the wrong prototype\")\n"
                       << "    assert(type(arguments) == \"table\" and type(upvalues) == \"table\", \"Mobile Defense call tables are unavailable\")\n"
                       << "    local gameRules = gGameRules\n"
                       << "    assert(not IsNull(gameRules), \"Mobile Defense game rules receiver is unavailable\")\n"
                       << "    local mission = gameRules:GetMission()\n"
                       << "    assert(not IsNull(mission), \"Mobile Defense mission descriptor is unavailable\")\n"
                       << "    if mission.maxWaveNum > 0 then return end\n"
                       << "    local existing = gameRules:GetNetPersistentVar(CUSTOM_MISSION_TIME, 0)\n"
                       << "    if existing > 0 then return end\n"
                       << "    local total = Lerp(MINIMUM_TOTAL_SECONDS, MAXIMUM_TOTAL_SECONDS, mission.difficulty)\n"
                       << "    if isArchwingMission and _T.faction == Symbol(\"Grineer\") then total = total * 1.3 end\n"
                       << "    ownerGameRules = gameRules\n"
                       << "    previousCustomMissionTime = existing\n"
                       << "    ownedCustomMissionTime = total\n"
                       << "    gameRules:SetNetPersistentVar(CUSTOM_MISSION_TIME, total)\n"
                       << "    configured = true\n"
                       << "end\n\n"
                       << "local function cleanup()\n"
                       << "    active = false\n"
                       << "    if configured and gGameRules == ownerGameRules and not IsNull(ownerGameRules) then\n"
                       << "        local current = ownerGameRules:GetNetPersistentVar(CUSTOM_MISSION_TIME, 0)\n"
                       << "        if current == ownedCustomMissionTime then\n"
                       << "            ownerGameRules:SetNetPersistentVar(CUSTOM_MISSION_TIME, previousCustomMissionTime)\n"
                       << "        end\n"
                       << "    end\n"
                       << "    configured = false\n"
                       << "    ownerGameRules = nil\n"
                       << "    previousCustomMissionTime = nil\n"
                       << "    ownedCustomMissionTime = nil\n"
                       << "end\n\n"
                       << "return {\n"
                       << "    activate = function() active = true end,\n"
                       << "    cleanup = cleanup,\n"
                       << "    hooks = { luaCalls = { [22] = { before = beforeDefenseStage } } },\n"
                       << "}\n";
                return output.str();
            }
            if (addon_template == "MISSION_INTERCEPTION_SCORING_TARGET")
            {
                const std::string multiplier = format_number(generation.at("scoring_speed_multiplier").get<double>());
                std::ostringstream output;
                output << "-- Generated by RENOVICE Ability Editor. Do not hand-edit generated sections.\n"
                       << "-- Exact target: Lotus.Scripts.Modes.TerritoryMission / body a51e98a1833bd8c1\n"
                       << "-- Stock mission closure: prototype 35; stock scoreRatePerSecond=1\n\n"
                       << "local SCORING_SPEED_MULTIPLIER = " << multiplier << "\n"
                       << "local STOCK_SCORE_RATE = 1\n\n"
                       << "local active = false\n"
                       << "local configured = false\n"
                       << "local ownedScoreRate = nil\n\n"
                       << "local function beforeTerritoryMission(prototype, arguments, upvalues)\n"
                       << "    if not active or configured then return end\n"
                       << "    assert(prototype == 35, \"Interception hook received the wrong prototype\")\n"
                       << "    assert(type(arguments) == \"table\" and type(upvalues) == \"table\", \"Interception call tables are unavailable\")\n"
                       << "    assert(scoreRatePerSecond == STOCK_SCORE_RATE, \"Interception stock score rate drifted from 1\")\n"
                       << "    ownedScoreRate = STOCK_SCORE_RATE * SCORING_SPEED_MULTIPLIER\n"
                       << "    scoreRatePerSecond = ownedScoreRate\n"
                       << "    configured = true\n"
                       << "end\n\n"
                       << "local function cleanup()\n"
                       << "    active = false\n"
                       << "    if not configured then return end\n"
                       << "    if scoreRatePerSecond == ownedScoreRate then\n"
                       << "        scoreRatePerSecond = STOCK_SCORE_RATE\n"
                       << "    elseif scoreRatePerSecond == ownedScoreRate * 4 then\n"
                       << "        scoreRatePerSecond = STOCK_SCORE_RATE * 4\n"
                       << "    else\n"
                       << "        assert(false, \"Interception score rate changed before cleanup\")\n"
                       << "    end\n"
                       << "    configured = false\n"
                       << "    ownedScoreRate = nil\n"
                       << "end\n\n"
                       << "return {\n"
                       << "    activate = function() active = true end,\n"
                       << "    cleanup = cleanup,\n"
                       << "    hooks = { luaCalls = { [35] = { before = beforeTerritoryMission } } },\n"
                       << "}\n";
                return output.str();
            }
            if (addon_template == "MISSION_CONTROL_AREA_PLAINS_TIMER_TARGET")
            {
                const std::string duration = format_number(generation.at("duration_seconds").get<double>());
                std::ostringstream output;
                output << "-- Generated by RENOVICE Ability Editor. Do not hand-edit generated sections.\n"
                       << "-- Exact target: Lotus.Scripts.Eidolon.Encounters.DynamicDefend / body bf3c901cb4058c47\n"
                       << "-- Exact owners: proto8 upvalue 7; proto1 upvalues 5/6 (one-based)\n\n"
                       << "local CONTROL_AREA_SECONDS = " << duration << "\n"
                       << "local STOCK_CONTROL_AREA_SECONDS = 90\n\n"
                       << "local active = false\n"
                       << "local stateConfigured = false\n"
                       << "local pacingConfigured = false\n\n"
                       << "local function beforeStateUpdate(prototype, arguments, upvalues)\n"
                       << "    if not active or stateConfigured then return end\n"
                       << "    assert(prototype == 8, \"Plains Control Area state hook received the wrong prototype\")\n"
                       << "    assert(type(arguments) == \"table\" and type(upvalues) == \"table\", \"Plains Control Area call tables are unavailable\")\n"
                       << "    local duration = upvalues[7]\n"
                       << "    assert(type(duration) == \"number\", \"Plains Control Area duration capture is not numeric\")\n"
                       << "    assert(duration == STOCK_CONTROL_AREA_SECONDS or duration == CONTROL_AREA_SECONDS, \"Plains Control Area stock duration drifted from 90\")\n"
                       << "    upvalues[7] = CONTROL_AREA_SECONDS\n"
                       << "    stateConfigured = true\n"
                       << "end\n\n"
                       << "local function beforeReinforcementPacing(prototype, arguments, upvalues)\n"
                       << "    if not active or pacingConfigured then return end\n"
                       << "    assert(prototype == 1, \"Plains Control Area pacing hook received the wrong prototype\")\n"
                       << "    assert(type(arguments) == \"table\" and type(upvalues) == \"table\", \"Plains Control Area pacing tables are unavailable\")\n"
                       << "    local duration = upvalues[5]\n"
                       << "    local baseline = upvalues[6]\n"
                       << "    assert(type(duration) == \"number\" and type(baseline) == \"number\", \"Plains Control Area pacing captures are not numeric\")\n"
                       << "    assert(duration == STOCK_CONTROL_AREA_SECONDS or duration == CONTROL_AREA_SECONDS, \"Plains Control Area pacing duration drifted from its verified owner\")\n"
                       << "    assert(baseline == STOCK_CONTROL_AREA_SECONDS or baseline == CONTROL_AREA_SECONDS, \"Plains Control Area pacing baseline drifted from 90\")\n"
                       << "    upvalues[5] = CONTROL_AREA_SECONDS\n"
                       << "    upvalues[6] = CONTROL_AREA_SECONDS\n"
                       << "    pacingConfigured = true\n"
                       << "end\n\n"
                       << "return {\n"
                       << "    activate = function() active = true end,\n"
                       << "    cleanup = function() active = false end,\n"
                       << "    hooks = { luaCalls = {\n"
                       << "        [8] = { before = beforeStateUpdate },\n"
                       << "        [1] = { before = beforeReinforcementPacing },\n"
                       << "    } },\n"
                       << "}\n";
                return output.str();
            }
            if (addon_template == "MISSION_CONTROL_AREA_DEIMOS_TIMER_TARGET")
            {
                const std::string duration = format_number(generation.at("duration_seconds").get<double>());
                std::ostringstream output;
                output << "-- Generated by RENOVICE Ability Editor. Do not hand-edit generated sections.\n"
                       << "-- Exact target: Lotus.Scripts.InfestedMicroplanet.Encounters.DynamicAreaDefense / body d9541341dfd466a3\n"
                       << "-- Exact owners: proto7 upvalue 12; proto9 upvalue 14 (one-based)\n\n"
                       << "local CONTROL_AREA_SECONDS = " << duration << "\n"
                       << "local STOCK_CONTROL_AREA_SECONDS = 90\n"
                       << "local CONTROL_AREA_PACING_THRESHOLD = CONTROL_AREA_SECONDS * 2 / 3\n"
                       << "local STOCK_PACING_THRESHOLD = 60\n\n"
                       << "local active = false\n"
                       << "local stateConfigured = false\n"
                       << "local pacingConfigured = false\n\n"
                       << "local function beforeStateUpdate(prototype, arguments, upvalues)\n"
                       << "    if not active or stateConfigured then return end\n"
                       << "    assert(prototype == 7, \"Deimos Control Area state hook received the wrong prototype\")\n"
                       << "    assert(type(arguments) == \"table\" and type(upvalues) == \"table\", \"Deimos Control Area call tables are unavailable\")\n"
                       << "    local duration = upvalues[12]\n"
                       << "    assert(type(duration) == \"number\", \"Deimos Control Area duration capture is not numeric\")\n"
                       << "    assert(duration == STOCK_CONTROL_AREA_SECONDS or duration == CONTROL_AREA_SECONDS, \"Deimos Control Area stock duration drifted from 90\")\n"
                       << "    upvalues[12] = CONTROL_AREA_SECONDS\n"
                       << "    stateConfigured = true\n"
                       << "end\n\n"
                       << "local function beforeMissionLoop(prototype, arguments, upvalues)\n"
                       << "    if not active or pacingConfigured then return end\n"
                       << "    assert(prototype == 9, \"Deimos Control Area mission hook received the wrong prototype\")\n"
                       << "    assert(type(arguments) == \"table\" and type(upvalues) == \"table\", \"Deimos Control Area mission tables are unavailable\")\n"
                       << "    local threshold = upvalues[14]\n"
                       << "    assert(type(threshold) == \"number\", \"Deimos Control Area pacing threshold is not numeric\")\n"
                       << "    assert(threshold == STOCK_PACING_THRESHOLD or threshold == CONTROL_AREA_PACING_THRESHOLD, \"Deimos Control Area stock pacing threshold drifted from 60\")\n"
                       << "    upvalues[14] = CONTROL_AREA_PACING_THRESHOLD\n"
                       << "    pacingConfigured = true\n"
                       << "end\n\n"
                       << "return {\n"
                       << "    activate = function() active = true end,\n"
                       << "    cleanup = function() active = false end,\n"
                       << "    hooks = { luaCalls = {\n"
                       << "        [7] = { before = beforeStateUpdate },\n"
                       << "        [9] = { before = beforeMissionLoop },\n"
                       << "    } },\n"
                       << "}\n";
                return output.str();
            }
            const std::string reward_interval = format_number(generation.at("reward_interval_seconds").get<double>());
            const std::string pickup_life_support = format_number(generation.at("life_support_per_pickup_seconds").get<double>());
            const std::string pickup_reward_progress = format_number(generation.at("reward_progress_per_pickup_seconds").get<double>());
            std::ostringstream output;
            output << "-- Generated by RENOVICE Ability Editor. Do not hand-edit generated sections.\n"
                   << "-- Exact target: Lotus.Scripts.Modes.SurvivalMission / body 1e3647332a578b78\n"
                   << "-- Exact stock update closure: bytecode prototype 64\n"
                   << "-- One-based captures: 19=elapsed reward clock, 22=pickup config, 70=reward config\n\n"
                   << "local REWARD_INTERVAL_SECONDS = " << reward_interval << "\n"
                   << "local LIFE_SUPPORT_PER_PICKUP_SECONDS = " << pickup_life_support << "\n"
                   << "local REWARD_PROGRESS_PER_PICKUP_SECONDS = " << pickup_reward_progress << "\n\n"
                   << "local active = false\n"
                   << "local configured = false\n"
                   << "local pickupConfig = nil\n"
                   << "local rewardConfig = nil\n"
                   << "local originalPickupTimeAdded = nil\n"
                   << "local originalRewardInterval = nil\n"
                   << "local processedPickupCount = 0\n\n"
                   << "local function bindVerifiedOwners(upvalues)\n"
                   << "    local nextPickupConfig = upvalues[22]\n"
                   << "    local nextRewardConfig = upvalues[70]\n"
                   << "    assert(type(nextPickupConfig) == \"table\", \"Survival proto64 upvalue 22 is not the pickup config table\")\n"
                   << "    assert(type(nextRewardConfig) == \"table\", \"Survival proto64 upvalue 70 is not the reward config table\")\n"
                   << "    assert(type(nextPickupConfig.pickupTimeAdded) == \"number\", \"Survival pickupTimeAdded is not numeric\")\n"
                   << "    assert(type(nextRewardConfig.interval) == \"number\", \"Survival reward interval is not numeric\")\n"
                   << "    if not configured then\n"
                   << "        pickupConfig = nextPickupConfig\n"
                   << "        rewardConfig = nextRewardConfig\n"
                   << "        originalPickupTimeAdded = pickupConfig.pickupTimeAdded\n"
                   << "        originalRewardInterval = rewardConfig.interval\n"
                   << "        assert(originalPickupTimeAdded == 7, \"Survival stock pickupTimeAdded drifted from 7\")\n"
                   << "        assert(originalRewardInterval == 300, \"Survival stock reward interval drifted from 300\")\n"
                   << "        pickupConfig.pickupTimeAdded = LIFE_SUPPORT_PER_PICKUP_SECONDS\n"
                   << "        rewardConfig.interval = REWARD_INTERVAL_SECONDS\n"
                   << "        configured = true\n"
                   << "    else\n"
                   << "        assert(nextPickupConfig == pickupConfig, \"Survival pickup config owner changed\")\n"
                   << "        assert(nextRewardConfig == rewardConfig, \"Survival reward config owner changed\")\n"
                   << "        assert(pickupConfig.pickupTimeAdded == LIFE_SUPPORT_PER_PICKUP_SECONDS, \"Survival pickupTimeAdded was changed by another owner\")\n"
                   << "        assert(rewardConfig.interval == REWARD_INTERVAL_SECONDS, \"Survival reward interval was changed by another owner\")\n"
                   << "    end\n"
                   << "end\n\n"
                   << "local function beforeSurvivalUpdate(prototype, arguments, upvalues)\n"
                   << "    if not active then return end\n"
                   << "    assert(prototype == 64, \"Survival hook received the wrong prototype\")\n"
                   << "    assert(type(arguments) == \"table\", \"Survival arguments snapshot is unavailable\")\n"
                   << "    assert(type(upvalues) == \"table\", \"Survival upvalue view is unavailable\")\n"
                   << "    bindVerifiedOwners(upvalues)\n"
                   << "    local pickupCount = _T.PickupCollection\n"
                   << "    if type(pickupCount) ~= \"number\" or pickupCount <= 0 then processedPickupCount = 0 return end\n"
                   << "    local newPickups = pickupCount - processedPickupCount\n"
                   << "    if newPickups <= 0 then return end\n"
                   << "    local elapsedRewardTime = upvalues[19]\n"
                   << "    assert(type(elapsedRewardTime) == \"number\", \"Survival proto64 upvalue 19 is not elapsed reward time\")\n"
                   << "    upvalues[19] = elapsedRewardTime + newPickups * REWARD_PROGRESS_PER_PICKUP_SECONDS\n"
                   << "    processedPickupCount = pickupCount\n"
                   << "end\n\n"
                   << "return {\n"
                   << "    activate = function() active = true end,\n"
                   << "    cleanup = function()\n"
                   << "        active = false\n"
                   << "        processedPickupCount = 0\n"
                   << "        if configured then\n"
                   << "            assert(pickupConfig.pickupTimeAdded == LIFE_SUPPORT_PER_PICKUP_SECONDS, \"Survival pickupTimeAdded changed before cleanup\")\n"
                   << "            assert(rewardConfig.interval == REWARD_INTERVAL_SECONDS, \"Survival reward interval changed before cleanup\")\n"
                   << "            pickupConfig.pickupTimeAdded = originalPickupTimeAdded\n"
                   << "            rewardConfig.interval = originalRewardInterval\n"
                   << "            configured = false\n"
                   << "            pickupConfig = nil rewardConfig = nil originalPickupTimeAdded = nil originalRewardInterval = nil\n"
                   << "        end\n"
                   << "    end,\n"
                   << "    hooks = { luaCalls = { [64] = { before = beforeSurvivalUpdate } } },\n"
                   << "}\n";
            return output.str();
        }

        const Json& generation = project.at("addon_generation");
        const std::string localize_tag = generation.at("ability_localize_tag").get<std::string>();
        const std::string fraction_stat_id = generation.at("fraction_stat_id").get<std::string>();
        const std::string cap_stat_id = generation.at("cap_stat_id").get<std::string>();
        const Json& fraction_stat = find_stat(project, fraction_stat_id);
        const Json& cap_stat = find_stat(project, cap_stat_id);
        std::map<std::string, std::vector<const Json*>> native_rewrites;
        for (const Json& rewrite : generation.at("native_argument_rewrites"))
        {
            native_rewrites[rewrite.at("method").get<std::string>()].push_back(&rewrite);
        }

        std::ostringstream output;
        output << "-- Generated by RENOVICE Ability Editor. Do not hand-edit generated sections.\n"
               << "-- Canonical project: " << project.at("id").get<std::string>() << "\n\n"
               << "local AbilitiesLib = require(\"Lotus.Scripts.Libs.AbilitiesLib\")\n\n"
               << "local ABILITY_LOCALIZE_TAG = " << lua_quote(localize_tag) << "\n\n"
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

        for (const auto& [method, rewrites] : native_rewrites)
        {
            output << "local function beforeNative_" << lua_identifier(method)
                   << "(prototype, instruction, arguments)\n";
            for (const Json* rewrite : rewrites)
            {
                const int prototype = rewrite->at("prototype").get<int>();
                const int instruction = rewrite->at("instruction").get<int>();
                const int argument = rewrite->at("argument").get<int>();
                const double expected = rewrite->at("expected").get<double>();
                const double replacement = rewrite->at("replacement").get<double>();
                output << "    if prototype == " << prototype
                       << " and instruction == " << instruction
                       << " and arguments[" << argument << "] == " << format_number(expected) << " then\n"
                       << "        arguments[" << argument << "] = " << format_number(replacement) << "\n"
                       << "    end\n";
            }
            output << "end\n\n";
        }

        const std::string rate_getter = getter_name(fraction_stat);
        const std::string cap_getter = getter_name(cap_stat);
        output << "local function afterDamage(sourceAbility, reportedDamage)\n"
               << "    if IsNull(sourceAbility) or reportedDamage <= 0 then\n"
               << "        return\n"
               << "    end\n\n"
               << "    local caster = sourceAbility:GetAvatarOwner()\n"
               << "    if IsNull(caster) then\n"
               << "        return\n"
               << "    end\n"
               << "    local damageControl = caster:DamageControl()\n"
               << "    if IsNull(damageControl) then\n"
               << "        return\n"
               << "    end\n\n"
               << "    local cap = " << cap_getter << "(caster)\n"
               << "    local current = damageControl:GetOverguardAmount()\n"
               << "    if current >= cap then\n"
               << "        return\n"
               << "    end\n\n"
               << "    local fraction = " << rate_getter << "(caster)\n"
               << "    local grant = reportedDamage * fraction\n"
               << "    local newAmount = math.min(cap, current + grant)\n"
               << "    if current < newAmount then\n"
               << "        damageControl:SetOverguardAmount(newAmount)\n"
               << "        caster:NotifyOverguardGain(caster:GetPlayer(), newAmount - current)\n"
               << "        AbilitiesLib.NotifyGaveOverguard(caster, caster)\n"
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
               << "end\n\n"
               << "local function cleanup()\n"
               << "end\n\n"
               << "return {\n"
               << "    activate = activate,\n"
               << "    cleanup = cleanup,\n"
               << "    hooks = {\n"
               << "        matchesAbility = matchesAbility,\n"
               << "        afterAbilityCard = augmentAbilityCard,\n"
               << "        afterDamage = afterDamage,\n";
        if (!native_rewrites.empty())
        {
            output << "        nativeCalls = {\n";
            for (const auto& [method, rewrites] : native_rewrites)
            {
                static_cast<void>(rewrites);
                output << "            " << method << " = {\n"
                       << "                before = beforeNative_" << lua_identifier(method) << ",\n"
                       << "            },\n";
            }
            output << "        },\n";
        }
        output << "    },\n"
               << "}\n";
        return output.str();
    }

    BuildResult build_staged_addon(
        const Json& project,
        const fs::path& editor_root,
        const fs::path& staging_root,
        const bool run_external_gates)
    {
        if (project.contains("mission_profile")) return build_profile_mission(project, editor_root, staging_root, run_external_gates);
        BuildResult result;
        result.diagnostics = validate_project(project, editor_root);
        if (has_errors(result.diagnostics))
        {
            return result;
        }

        try
        {
            const std::string canonical_project = project.dump(2) + "\n";
            const std::string generated_source = generate_target_addon_source(project, editor_root);
            const fs::path hash_work = staging_root / ".hash-work";
            const std::string project_hash = sha256_text(
                hash_work,
                canonical_project + "\n-- GENERATED SOURCE --\n" + generated_source);
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

    BuildResult build_staged_exact_mission_replacement(
        const Json& project,
        const fs::path& editor_root,
        const fs::path& staging_root,
        const bool run_external_gates)
    {
        if (project.contains("mission_profile")) return build_profile_mission(project, editor_root, staging_root, run_external_gates);
        BuildResult result;
        result.diagnostics = validate_project(project, editor_root);
        if (has_errors(result.diagnostics))
            return result;

        try
        {
            const Json& generation = project.at("replacement_generation");
            const std::string canonical_project = project.dump(2) + "\n";
            const fs::path corpus_root = resolve_workspace_path(editor_root, "shared", "de_luau_corpus");
            const fs::path stock_bytecode = corpus_root / generation.at("stock_corpus_file").get<std::string>();
            const std::string expected_stock_hash = generation.at("stock_sha256").get<std::string>();
            const fs::path hash_work = staging_root / ".hash-work";
            const std::string build_hash = sha256_text(
                hash_work,
                canonical_project + "\n-- STOCK SHA256 --\n" + expected_stock_hash + "\n");
            if (fs::exists(hash_work) && fs::is_empty(hash_work))
                fs::remove(hash_work);

            const std::string project_id = project.at("id").get<std::string>();
            const std::string body_key = project.at("target").at("module_body_key").get<std::string>();
            const std::string stem = artifact_stem(project_id);
            result.generation_directory = staging_root / stem / build_hash.substr(0, 12);
            const fs::path source_directory = result.generation_directory / "source";
            const fs::path artifact_directory = result.generation_directory / "artifacts";
            fs::create_directories(source_directory);
            fs::create_directories(artifact_directory);

            result.project_snapshot = result.generation_directory / "ability_edit.json";
            result.generated_source = source_directory / (body_key + ".exact-byte-patch.json");
            result.generated_bytecode = artifact_directory / (body_key + " (" + stem + ").lua_B");
            result.manifest = result.generation_directory / "BUILD_MANIFEST.json";
            write_text(result.project_snapshot, canonical_project);

            struct ExactPatchSpec
            {
                std::string variant;
                std::string value_field;
                std::string gate_name;
                int prototype = 0;
                int instruction = 0;
                int expected_opcode = 0x12;
                int occurrence = 0;
                int replacement_opcode = 0x12;
                int register_a = 0;
                int stock_seconds = 0;
                int value_numerator = 1;
                int value_denominator = 1;
                std::size_t instruction_offset = 0;
                std::string expected_patch_location;
            };

            const std::string replacement_template = generation.at("template").get<std::string>();
            std::string evidence_id;
            int expected_prototype_count = 0;
            std::map<int, std::string> expected_structure_by_prototype;
            std::vector<ExactPatchSpec> patch_specs;
            if (replacement_template == "MISSION_MOBILE_DEFENSE_TIMERS_EXACT_REPLACEMENT")
            {
                evidence_id = "WF-MOBILE-DEFENSE-PROTO22-LERP-OPERANDS-2026-09-12";
                expected_prototype_count = 25;
                expected_structure_by_prototype = {
                    {22, "pidx=22 code_bytes=2692->2692 (+0) instructions=495->495 (+0)"},
                };
                patch_specs = {
                    {"minimum_total", "minimum_total_seconds", "patch-minimum-total-owner", 22, 120, 0x12, 9, 0x12, 17, 180, 1, 1, 21516, "proto[22] insn 120 @0x284"},
                    {"maximum_total", "maximum_total_seconds", "patch-maximum-total-owner", 22, 121, 0x12, 10, 0x12, 18, 240, 1, 1, 21520, "proto[22] insn 121 @0x288"},
                };
            }
            else if (replacement_template == "MISSION_EXCAVATION_TIMERS_EXACT_REPLACEMENT")
            {
                evidence_id = "WF-EXCAVATION-STOCK-DURATION-ASSIGNMENTS-2026-09-11";
                expected_prototype_count = 50;
                expected_structure_by_prototype = {
                    {32, "pidx=32 code_bytes=620->620 (+0) instructions=110->110 (+0)"},
                    {49, "pidx=49 code_bytes=2656->2656 (+0) instructions=581->581 (+0)"},
                };
                patch_specs = {
                    {"standard", "standard_dig_seconds", "patch-standard-owner", 49, 76, 0x12, 33, 0x12, 27, 100, 1, 1, 69944, "proto[49] insn 76 @0x188"},
                    {"old_world_salvage", "old_world_salvage_dig_seconds", "patch-old-world-salvage-owner", 32, 81, 0x12, 5, 0x12, 1, 60, 1, 1, 29105, "proto[32] insn 81 @0x1d0"},
                    {"elite_alert", "elite_alert_dig_seconds", "patch-elite-alert-owner", 32, 102, 0x12, 6, 0x12, 1, 140, 1, 1, 29229, "proto[32] insn 102 @0x24c"},
                };
            }
            else if (replacement_template == "MISSION_CONTROL_AREA_PLAINS_TIMER_EXACT_REPLACEMENT")
            {
                evidence_id = "WF-CONTROL-AREA-PLAINS-ROOT-DURATION-LOADN-2026-09-11";
                expected_prototype_count = 18;
                expected_structure_by_prototype = {
                    {8, "pidx=8 code_bytes=880->880 (+0) instructions=180->180 (+0)"},
                    {17, "pidx=17 code_bytes=892->892 (+0) instructions=202->202 (+0)"},
                };
                patch_specs = {
                    {"control_area_pacing", "duration_seconds", "patch-root-duration-owner", 17, 44, 0x12, 3, 0x12, 21, 90, 1, 1, 8701, "proto[17] insn 44 @0xdc"},
                    {"control_area_timer", "duration_seconds", "patch-set-obj-timer-argument", 8, 100, 0x14, 0, 0x12, 5, 90, 1, 1, 4061, "proto[8] insn 100 @0x1f4"},
                };
            }
            else if (replacement_template == "MISSION_CONTROL_AREA_DEIMOS_TIMER_EXACT_REPLACEMENT")
            {
                evidence_id = "WF-CONTROL-AREA-DEIMOS-ROOT-DURATION-LOADN-2026-09-11";
                expected_prototype_count = 16;
                expected_structure_by_prototype = {
                    {7, "pidx=7 code_bytes=992->992 (+0) instructions=203->203 (+0)"},
                    {15, "pidx=15 code_bytes=996->996 (+0) instructions=224->224 (+0)"},
                };
                patch_specs = {
                    {"control_area_pacing", "duration_seconds", "patch-root-duration-owner", 15, 56, 0x12, 1, 0x12, 23, 90, 1, 1, 10368, "proto[15] insn 56 @0x120"},
                    {"control_area_timer", "duration_seconds", "patch-persistent-duration-result", 7, 63, 0x13, 15, 0x12, 1, 90, 1, 1, 3308, "proto[7] insn 63 @0x140"},
                };
            }
            else if (replacement_template == "MISSION_CONTROL_AREA_NOKKO_TIMER_EXACT_REPLACEMENT")
            {
                evidence_id = "WF-CONTROL-AREA-NOKKO-TIMER-CONSUMER-AND-THRESHOLDS-2026-09-11";
                expected_prototype_count = 16;
                expected_structure_by_prototype = {
                    {5, "pidx=5 code_bytes=1044->1044 (+0) instructions=210->210 (+0)"},
                    {6, "pidx=6 code_bytes=1252->1252 (+0) instructions=232->232 (+0)"},
                };
                patch_specs = {
                    // Patch the second SUB first so replacing it does not renumber the first SUB occurrence.
                    {"two_thirds_threshold", "duration_seconds", "patch-two-thirds-threshold", 6, 112, 0x07, 1, 0x12, 3, 90, 2, 3, 5509, "proto[6] insn 112 @0x25c"},
                    {"halfway_threshold", "duration_seconds", "patch-halfway-threshold", 6, 107, 0x07, 0, 0x12, 3, 90, 1, 2, 5481, "proto[6] insn 107 @0x240"},
                    {"control_area_timer", "duration_seconds", "patch-set-obj-timer-argument", 5, 118, 0x14, 0, 0x12, 6, 90, 1, 1, 3974, "proto[5] insn 118 @0x25c"},
                };
            }
            else
            {
                throw std::runtime_error("Unsupported exact mission replacement template: " + replacement_template);
            }

            Json plan_patches = Json::array();
            const auto replacement_value = [&](const ExactPatchSpec& patch) {
                const int configured = generation.at(patch.value_field).get<int>();
                const long long scaled = static_cast<long long>(configured) * patch.value_numerator;
                if (patch.value_denominator <= 0 || scaled % patch.value_denominator != 0)
                    throw std::runtime_error("Configured duration cannot represent linked LOADN value for " + patch.variant);
                const long long value = scaled / patch.value_denominator;
                if (value < -32768 || value > 32767)
                    throw std::runtime_error("Linked LOADN value is outside the signed 16-bit range for " + patch.variant);
                return static_cast<int>(value);
            };
            for (const ExactPatchSpec& patch : patch_specs)
            {
                plan_patches.push_back({
                    {"variant", patch.variant},
                    {"prototype", patch.prototype},
                    {"instruction", patch.instruction},
                    {"expected_opcode", patch.expected_opcode},
                    {"replacement_opcode", patch.replacement_opcode},
                    {"occurrence", patch.occurrence},
                    {"stock_seconds", patch.stock_seconds},
                    {"replacement_value", replacement_value(patch)},
                    {"value_fraction", Json::array({patch.value_numerator, patch.value_denominator})},
                    {"absolute_instruction_offset", patch.instruction_offset},
                });
            }
            Json patch_plan{
                {"format", "RENOVICE_EXACT_BYTE_PATCH_V1"},
                {"template", replacement_template},
                {"target_body_key", body_key},
                {"stock_corpus_file", generation.at("stock_corpus_file")},
                {"stock_sha256", expected_stock_hash},
                {"evidence_id", evidence_id},
                {"patches", plan_patches},
            };
            if (replacement_template == "MISSION_EXCAVATION_TIMERS_EXACT_REPLACEMENT")
                patch_plan["preserved_fast_dig_seconds"] = 20;
            write_text(result.generated_source, patch_plan.dump(2) + "\n");

            bool gates_pass = true;
            Json gates = Json::array();
            const auto record_internal_gate = [&](const std::string& name, const bool pass, const std::string& detail)
            {
                result.gate_log += "===== " + name + " =====\n" + detail + "\n";
                gates.push_back({{"name", name}, {"exit_code", pass ? 0 : 1}, {"pass", pass}});
                if (!pass)
                {
                    gates_pass = false;
                    add(result.diagnostics, Severity::error, "EXTERNAL_GATE", name + " failed; inspect BUILD_GATES.log");
                }
            };
            const auto record_process_gate = [&](const std::string& name, const ProcessResult& process, const bool semantic_pass)
            {
                result.gate_log += "===== " + name + " =====\n" + process.output;
                if (result.gate_log.empty() || result.gate_log.back() != '\n')
                    result.gate_log.push_back('\n');
                const bool pass = process.exit_code == 0 && semantic_pass;
                gates.push_back({{"name", name}, {"exit_code", pass ? 0 : static_cast<int>(process.exit_code)}, {"pass", pass}});
                if (!pass)
                {
                    gates_pass = false;
                    add(result.diagnostics, Severity::error, "EXTERNAL_GATE", name + " failed; inspect BUILD_GATES.log");
                }
            };

            const bool stock_exists = fs::exists(stock_bytecode) && fs::is_regular_file(stock_bytecode);
            const std::string actual_stock_hash = stock_exists ? sha256_file(stock_bytecode) : std::string();
            record_internal_gate(
                "stock-hash",
                stock_exists && actual_stock_hash == expected_stock_hash,
                "stock=" + stock_bytecode.string() + "\nexpected=" + expected_stock_hash + "\nactual=" + (actual_stock_hash.empty() ? "MISSING" : actual_stock_hash));

            if (gates_pass)
            {
                const fs::path decompiler_root = resolve_workspace_path(editor_root, "repos", "de_luau_toolchain");
                const fs::path derecomp = decompiler_root / "bin" / "derecomp.exe";
                if (!fs::exists(derecomp))
                {
                    record_internal_gate("toolchain", false, "Missing " + derecomp.string());
                }
                else
                {
                    const auto loadn_bytes = [](const int value) {
                        return std::pair<int, int>{value & 0xff, (value >> 8) & 0xff};
                    };
                    std::vector<fs::path> temporary_patches;
                    fs::path current_input = stock_bytecode;
                    for (std::size_t index = 0; index < patch_specs.size(); ++index)
                    {
                        const ExactPatchSpec& patch = patch_specs[index];
                        const int replacement = replacement_value(patch);
                        const auto [operand_b, operand_c] = loadn_bytes(replacement);
                        const bool final_patch = index + 1 == patch_specs.size();
                        const fs::path output = final_patch
                            ? result.generated_bytecode
                            : artifact_directory / ("exact-mission-patch-" + std::to_string(index) + ".tmp.lua_B");
                        if (!final_patch)
                            temporary_patches.push_back(output);
                        const ProcessResult patch_process = run_process(
                             quote_process_argument(derecomp) + " de-patchop "
                                 + quote_process_argument(current_input) + " "
                                 + quote_process_argument(output) + " "
                                 + std::to_string(patch.prototype) + " " + std::to_string(patch.expected_opcode) + " "
                                 + std::to_string(patch.occurrence) + " " + std::to_string(patch.replacement_opcode) + " "
                                 + std::to_string(patch.register_a) + " "
                                 + std::to_string(operand_b) + " " + std::to_string(operand_c),
                            decompiler_root);
                        record_process_gate(
                            patch.gate_name,
                            patch_process,
                            contains_text(patch_process.output, patch.expected_patch_location));
                        if (patch_process.exit_code != 0 || !fs::exists(output))
                            break;
                        current_input = output;
                    }

                    if (fs::exists(result.generated_bytecode))
                    {
                        const std::string stock_bytes = read_text(stock_bytecode);
                        const std::string patched_bytes = read_text(result.generated_bytecode);
                        std::map<std::size_t, unsigned char> permitted;
                        std::set<int> expected_changed_prototypes;
                        for (const ExactPatchSpec& patch : patch_specs)
                        {
                            const auto [operand_b, operand_c] = loadn_bytes(replacement_value(patch));
                            const std::array<unsigned char, 4> replacement_word = {
                                static_cast<unsigned char>(patch.replacement_opcode),
                                static_cast<unsigned char>(patch.register_a),
                                static_cast<unsigned char>(operand_b),
                                static_cast<unsigned char>(operand_c),
                            };
                            bool changed = false;
                            for (std::size_t byte = 0; byte < replacement_word.size(); ++byte)
                            {
                                const std::size_t offset = patch.instruction_offset + byte;
                                permitted[offset] = replacement_word[byte];
                                changed = changed || (offset < stock_bytes.size()
                                    && static_cast<unsigned char>(stock_bytes[offset]) != replacement_word[byte]);
                            }
                            if (changed)
                                expected_changed_prototypes.insert(patch.prototype);
                        }
                        std::set<std::size_t> expected_differences;
                        for (const auto& [offset, value] : permitted)
                        {
                            if (offset < stock_bytes.size()
                                && static_cast<unsigned char>(stock_bytes[offset]) != value)
                                expected_differences.insert(offset);
                        }
                        std::set<std::size_t> actual_differences;
                        if (stock_bytes.size() == patched_bytes.size())
                        {
                            for (std::size_t index = 0; index < stock_bytes.size(); ++index)
                            {
                                if (stock_bytes[index] != patched_bytes[index])
                                    actual_differences.insert(index);
                            }
                        }
                        bool exact_diff = stock_bytes.size() == patched_bytes.size()
                            && actual_differences == expected_differences;
                        for (const auto& [offset, value] : permitted)
                        {
                            exact_diff = exact_diff && offset < patched_bytes.size()
                                && static_cast<unsigned char>(patched_bytes[offset]) == value;
                        }
                        std::ostringstream diff_detail;
                        diff_detail << "bytes=" << patched_bytes.size()
                                    << " changed=" << actual_differences.size()
                                    << " expected_changed=" << expected_differences.size() << " offsets=";
                        for (const std::size_t offset : actual_differences)
                            diff_detail << " 0x" << std::hex << std::uppercase << offset;
                        record_internal_gate("exact-byte-diff-contract", exact_diff, diff_detail.str());

                        if (run_external_gates)
                        {
                            const auto count_occurrences = [](const std::string& text, const std::string_view needle) {
                                std::size_t count = 0;
                                std::size_t position = 0;
                                while ((position = text.find(needle, position)) != std::string::npos)
                                {
                                    ++count;
                                    position += needle.size();
                                }
                                return count;
                            };
                            const ProcessResult roundtrip = run_process(
                                quote_process_argument(derecomp) + " de-roundtrip "
                                    + quote_process_argument(result.generated_bytecode),
                                decompiler_root);
                            record_process_gate(
                                "de-roundtrip",
                                roundtrip,
                                contains_text(roundtrip.output, "FULL BODY identical: True"));

                            const ProcessResult plan = run_process(
                                quote_process_argument(derecomp) + " plan-verify "
                                    + quote_process_argument(result.generated_bytecode),
                                decompiler_root);
                            record_process_gate(
                                "plan-verify",
                                plan,
                                contains_text(plan.output, "failures=0")
                                    && !contains_text(plan.output, "failures=1"));

                            const ProcessResult semantic_ir = run_process(
                                quote_process_argument(derecomp) + " semantic-ir-verify "
                                    + quote_process_argument(result.generated_bytecode),
                                decompiler_root);
                            record_process_gate(
                                "semantic-ir-verify",
                                semantic_ir,
                                count_occurrences(semantic_ir.output, " status=VERIFIED ") == static_cast<std::size_t>(expected_prototype_count)
                                    && count_occurrences(semantic_ir.output, "adapter_failures=0") == static_cast<std::size_t>(expected_prototype_count)
                                    && count_occurrences(semantic_ir.output, "verifier_failures=0") == static_cast<std::size_t>(expected_prototype_count));

                            const ProcessResult proto_diff = run_process(
                                quote_process_argument(derecomp) + " de-proto-diff "
                                    + quote_process_argument(stock_bytecode) + " "
                                    + quote_process_argument(result.generated_bytecode),
                                decompiler_root);
                            bool structure_pass = contains_text(
                                proto_diff.output,
                                "protos=" + std::to_string(expected_prototype_count)
                                    + "->" + std::to_string(expected_prototype_count)
                                    + " shared=" + std::to_string(expected_prototype_count));
                            if (expected_changed_prototypes.empty())
                            {
                                structure_pass = structure_pass
                                    && proto_diff.exit_code == 0
                                    && count_occurrences(proto_diff.output, "pidx=") == 0;
                            }
                            else
                            {
                                structure_pass = structure_pass
                                    && proto_diff.exit_code == 1
                                    && count_occurrences(proto_diff.output, "pidx=") == expected_changed_prototypes.size();
                                for (const int prototype : expected_changed_prototypes)
                                    structure_pass = structure_pass && contains_text(proto_diff.output, expected_structure_by_prototype.at(prototype));
                            }
                            result.gate_log += "===== de-proto-diff-expected-operands =====\n" + proto_diff.output;
                            if (result.gate_log.empty() || result.gate_log.back() != '\n')
                                result.gate_log.push_back('\n');
                            gates.push_back({
                                {"name", "de-proto-diff-expected-operands"},
                                {"exit_code", structure_pass ? 0 : static_cast<int>(proto_diff.exit_code)},
                                {"observed_tool_exit_code", static_cast<int>(proto_diff.exit_code)},
                                {"pass", structure_pass},
                            });
                            if (!structure_pass)
                            {
                                gates_pass = false;
                                add(result.diagnostics, Severity::error, "EXTERNAL_GATE", "de-proto-diff-expected-operands failed; inspect BUILD_GATES.log");
                            }
                        }
                        else
                        {
                            gates.push_back({{"name", "external-validation"}, {"exit_code", 0}, {"pass", false}, {"skipped", true}});
                            add(result.diagnostics, Severity::warning, "GATES_SKIPPED", "External roundtrip and structure gates were skipped");
                        }
                    }
                    for (const fs::path& temporary_patch : temporary_patches)
                    {
                        if (fs::exists(temporary_patch))
                            fs::remove(temporary_patch);
                    }
                }
            }

            write_text(result.generation_directory / "BUILD_GATES.log", result.gate_log);
            Json manifest{
                {"format", "RENOVICE_ABILITY_EDITOR_BUILD_V1"},
                {"package_type", "NATIVE_REPLACEMENT"},
                {"status", gates_pass ? "STAGED_PASS" : "STAGED_FAILED"},
                {"project_id", project_id},
                {"build_sha256", build_hash},
                {"source", {
                    {"path", fs::relative(result.generated_source, result.generation_directory).generic_string()},
                    {"sha256", sha256_file(result.generated_source)},
                    {"kind", "EXACT_BYTE_PATCH_PLAN"},
                }},
                {"stock_artifact", {
                    {"path", stock_bytecode.string()},
                    {"sha256", actual_stock_hash.empty() ? Json(nullptr) : Json(actual_stock_hash)},
                }},
                {"artifact", nullptr},
                {"intended_live_relative_path", "OpenWF/CustomScripts/" + result.generated_bytecode.filename().string()},
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

    std::vector<Diagnostic> validate_replacement_project(
        const Json& project,
        const fs::path& source_path)
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
            if (mode != "NATIVE_REPLACEMENT" && mode != "QUICK_NATIVE_PATCH")
            {
                add(
                    diagnostics,
                    Severity::error,
                    "REPLACEMENT_MODE",
                    "Replacement generation requires NATIVE_REPLACEMENT or QUICK_NATIVE_PATCH");
            }

            if (!project.contains("target") || !project.at("target").is_object())
            {
                add(diagnostics, Severity::error, "TARGET", "project.target must be an object");
                return diagnostics;
            }
            const Json& target = project.at("target");
            static_cast<void>(json_string(target, "warframe", diagnostics, "target"));
            static_cast<void>(json_string(target, "ability", diagnostics, "target"));
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
            }
            else if (project.at("effect").value("owner", "") != "NATIVE_MODULE")
            {
                add(diagnostics, Severity::error, "REPLACEMENT_OWNER", "A native replacement must use effect.owner=NATIVE_MODULE");
            }

            if (!project.contains("deployment") || !project.at("deployment").is_object())
            {
                add(diagnostics, Severity::error, "DEPLOYMENT", "project.deployment must be an object");
            }
            else
            {
                const Json& deployment = project.at("deployment");
                if (!deployment.value("requires_native_module", false))
                {
                    add(diagnostics, Severity::error, "DEPLOYMENT", "A native replacement requires requires_native_module=true");
                }
                if (deployment.value("requires_addon", false))
                {
                    add(diagnostics, Severity::error, "DEPLOYMENT", "A native replacement cannot declare requires_addon=true");
                }
            }

            if (!fs::exists(source_path) || !fs::is_regular_file(source_path))
            {
                add(diagnostics, Severity::error, "SOURCE_MISSING", "Replacement source does not exist: " + source_path.string());
            }
            else if (source_path.extension() != ".luau" && source_path.extension() != ".lua")
            {
                add(diagnostics, Severity::warning, "SOURCE_EXTENSION", "Replacement source should use .luau or .lua");
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
                "REPLACEMENT_STAGING_ONLY",
                "Replacement source is valid for gated staging; no live game file will be written");
        }
        return diagnostics;
    }

    BuildResult build_staged_replacement(
        const Json& project,
        const fs::path& source_path,
        const fs::path& editor_root,
        const fs::path& staging_root,
        const bool run_external_gates,
        const std::optional<fs::path>& api_baseline_source)
    {
        BuildResult result;
        result.diagnostics = validate_replacement_project(project, source_path);
        if (run_external_gates
            && (!api_baseline_source || !fs::exists(*api_baseline_source)
                || !fs::is_regular_file(*api_baseline_source)))
        {
            add(
                result.diagnostics,
                Severity::error,
                "API_BASELINE_MISSING",
                "A gated native replacement build requires its verified stock source baseline");
        }
        if (has_errors(result.diagnostics))
        {
            return result;
        }

        try
        {
            const std::string canonical_project = project.dump(2) + "\n";
            const std::string source = read_text(source_path);
            const std::string api_baseline = api_baseline_source
                ? read_text(*api_baseline_source)
                : std::string();
            const fs::path hash_work = staging_root / ".hash-work";
            const std::string build_hash = sha256_text(
                hash_work,
                canonical_project + "\n-- SOURCE --\n" + source
                    + "\n-- API BASELINE --\n" + api_baseline);
            if (fs::exists(hash_work) && fs::is_empty(hash_work))
            {
                fs::remove(hash_work);
            }

            const std::string project_id = project.at("id").get<std::string>();
            const std::string body_key = project.at("target").at("module_body_key").get<std::string>();
            const std::string stem = artifact_stem(project_id);
            result.generation_directory = staging_root / stem / build_hash.substr(0, 12);
            const fs::path source_directory = result.generation_directory / "source";
            const fs::path artifact_directory = result.generation_directory / "artifacts";
            fs::create_directories(source_directory);
            fs::create_directories(artifact_directory);

            result.project_snapshot = result.generation_directory / "ability_edit.json";
            result.generated_source = source_directory / (body_key + "." + stem + ".replacement.luau");
            result.generated_bytecode = artifact_directory / (body_key + " (" + stem + ").lua_B");
            result.manifest = result.generation_directory / "BUILD_MANIFEST.json";
            write_text(result.project_snapshot, canonical_project);
            write_text(result.generated_source, source);
            const fs::path staged_api_baseline = source_directory
                / (body_key + ".stock-api-baseline.luau");
            if (api_baseline_source)
                write_text(staged_api_baseline, api_baseline);

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
                const fs::path decompiler_root = resolve_workspace_path(editor_root, "repos", "de_luau_toolchain");
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
                            + result.generated_source.string() + "\" --baseline \""
                            + staged_api_baseline.string() + "\" --strict-unknown\"";
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
                {"package_type", "NATIVE_REPLACEMENT"},
                {"status", gates_pass ? "STAGED_PASS" : "STAGED_FAILED"},
                {"project_id", project_id},
                {"build_sha256", build_hash},
                {"source", {
                    {"path", fs::relative(result.generated_source, result.generation_directory).generic_string()},
                    {"sha256", sha256_file(result.generated_source)},
                }},
                {"api_baseline", api_baseline_source ? Json{
                    {"path", fs::relative(staged_api_baseline, result.generation_directory).generic_string()},
                    {"sha256", sha256_file(staged_api_baseline)},
                    {"policy", "STRICT_ON_CALL_SHAPES_INTRODUCED_BEYOND_STOCK_MULTISET"},
                } : Json(nullptr)},
                {"artifact", nullptr},
                {"intended_live_relative_path", "OpenWF/CustomScripts/" + result.generated_bytecode.filename().string()},
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

    DeploymentResult deploy_staged_build(
        const fs::path& build_manifest,
        const fs::path& game_root)
    {
        DeploymentResult result;
        try
        {
            if (!fs::exists(build_manifest) || !fs::is_regular_file(build_manifest))
            {
                add(result.diagnostics, Severity::error, "MANIFEST_MISSING", "Build manifest does not exist: " + build_manifest.string());
                return result;
            }
            if (!fs::exists(game_root) || !fs::is_directory(game_root))
            {
                add(result.diagnostics, Severity::error, "GAME_ROOT", "Selected game root does not exist: " + game_root.string());
                return result;
            }

            const Json manifest = load_project(build_manifest);
            if (manifest.value("status", "") != "STAGED_PASS")
            {
                add(result.diagnostics, Severity::error, "BUILD_STATUS", "Only a STAGED_PASS build may be deployed");
                return result;
            }
            if (!manifest.contains("artifact") || !manifest.at("artifact").is_object())
            {
                add(result.diagnostics, Severity::error, "ARTIFACT", "Build manifest has no compiled artifact");
                return result;
            }

            const fs::path generation_directory = fs::absolute(build_manifest).parent_path().lexically_normal();
            const fs::path artifact_relative = fs::path(manifest.at("artifact").at("path").get<std::string>());
            const fs::path live_relative = fs::path(manifest.at("intended_live_relative_path").get<std::string>());
            auto safe_relative = [](const fs::path& path) {
                if (path.empty() || path.is_absolute() || path.has_root_name() || path.has_root_directory()) return false;
                return std::none_of(path.begin(), path.end(), [](const fs::path& part) {
                    return part == ".." || part == ".";
                });
            };
            if (!safe_relative(artifact_relative) || !safe_relative(live_relative))
            {
                add(result.diagnostics, Severity::error, "UNSAFE_PATH", "Manifest contains an unsafe relative path");
                return result;
            }

            const fs::path artifact = (generation_directory / artifact_relative).lexically_normal();
            result.live_target = (fs::absolute(game_root).lexically_normal() / live_relative).lexically_normal();
            if (!fs::exists(artifact) || !fs::is_regular_file(artifact))
            {
                add(result.diagnostics, Severity::error, "ARTIFACT_MISSING", "Compiled artifact is missing: " + artifact.string());
                return result;
            }
            const std::string expected_hash = manifest.at("artifact").at("sha256").get<std::string>();
            const std::string artifact_hash = sha256_file(artifact);
            if (artifact_hash != expected_hash)
            {
                add(result.diagnostics, Severity::error, "ARTIFACT_HASH", "Compiled artifact hash no longer matches the build manifest");
                return result;
            }

            const auto timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()).count();
            const fs::path transaction_directory =
                generation_directory / "rollback" / ("deployment-" + std::to_string(timestamp));
            fs::create_directories(transaction_directory);
            const bool original_existed = fs::exists(result.live_target);
            const fs::path rollback_artifact = transaction_directory / "original.bin";
            std::optional<std::string> original_hash;
            if (original_existed)
            {
                if (!fs::is_regular_file(result.live_target))
                {
                    add(result.diagnostics, Severity::error, "LIVE_TARGET", "Live target exists but is not a regular file");
                    return result;
                }
                fs::copy_file(result.live_target, rollback_artifact, fs::copy_options::overwrite_existing);
                original_hash = sha256_file(rollback_artifact);
            }

            result.deployment_manifest = transaction_directory / "DEPLOYMENT_MANIFEST.json";
            Json deployment{
                {"format", "RENOVICE_ABILITY_DEPLOYMENT_V1"},
                {"status", "PREPARED"},
                {"build_manifest", fs::absolute(build_manifest).string()},
                {"game_root", fs::absolute(game_root).lexically_normal().string()},
                {"live_target", result.live_target.string()},
                {"deployed_sha256", artifact_hash},
                {"original_existed", original_existed},
                {"original_sha256", original_hash ? Json(*original_hash) : Json(nullptr)},
                {"rollback_artifact", original_existed ? Json(rollback_artifact.string()) : Json(nullptr)},
            };
            write_text(result.deployment_manifest, deployment.dump(2) + "\n");

            fs::create_directories(result.live_target.parent_path());
            fs::path temporary = result.live_target;
            temporary += ".renovice.tmp";
            fs::copy_file(artifact, temporary, fs::copy_options::overwrite_existing);
            if (sha256_file(temporary) != artifact_hash)
            {
                fs::remove(temporary);
                throw std::runtime_error("Temporary deployment copy failed hash verification");
            }
            if (!MoveFileExW(
                    temporary.wstring().c_str(),
                    result.live_target.wstring().c_str(),
                    MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH))
            {
                const DWORD error = GetLastError();
                fs::remove(temporary);
                throw std::runtime_error("Atomic deployment rename failed with Windows error " + std::to_string(error));
            }

            deployment["status"] = "DEPLOYED";
            deployment["deployed_at_unix_ms"] = timestamp;
            write_text(result.deployment_manifest, deployment.dump(2) + "\n");
            add(result.diagnostics, Severity::info, "DEPLOYED", "Artifact deployed atomically after rollback snapshot and hash verification");
            result.success = true;
        }
        catch (const std::exception& exception)
        {
            add(result.diagnostics, Severity::error, "DEPLOY_EXCEPTION", exception.what());
            result.success = false;
        }
        return result;
    }

    DeploymentResult rollback_deployment(const fs::path& deployment_manifest)
    {
        DeploymentResult result;
        result.deployment_manifest = fs::absolute(deployment_manifest);
        try
        {
            if (!fs::exists(result.deployment_manifest) || !fs::is_regular_file(result.deployment_manifest))
            {
                add(result.diagnostics, Severity::error, "MANIFEST_MISSING", "Deployment manifest does not exist");
                return result;
            }
            Json deployment = load_project(result.deployment_manifest);
            if (deployment.value("format", "") != "RENOVICE_ABILITY_DEPLOYMENT_V1")
            {
                add(result.diagnostics, Severity::error, "MANIFEST_FORMAT", "Unknown deployment manifest format");
                return result;
            }
            if (deployment.value("status", "") != "DEPLOYED")
            {
                add(result.diagnostics, Severity::error, "DEPLOYMENT_STATUS", "Only a DEPLOYED transaction can be rolled back");
                return result;
            }

            const fs::path game_root = fs::absolute(deployment.at("game_root").get<std::string>()).lexically_normal();
            result.live_target = fs::absolute(deployment.at("live_target").get<std::string>()).lexically_normal();
            const fs::path relative = result.live_target.lexically_relative(game_root);
            if (relative.empty() || relative.is_absolute()
                || std::any_of(relative.begin(), relative.end(), [](const fs::path& part) { return part == ".."; }))
            {
                add(result.diagnostics, Severity::error, "UNSAFE_PATH", "Rollback live target escapes the recorded game root");
                return result;
            }
            if (!fs::exists(result.live_target) || !fs::is_regular_file(result.live_target))
            {
                add(result.diagnostics, Severity::error, "LIVE_TARGET", "Deployed live target is missing; rollback stopped");
                return result;
            }
            const std::string deployed_hash = deployment.at("deployed_sha256").get<std::string>();
            if (sha256_file(result.live_target) != deployed_hash)
            {
                add(result.diagnostics, Severity::error, "LIVE_TARGET_CHANGED", "Live target changed after deployment; automatic rollback stopped to preserve external edits");
                return result;
            }

            const bool original_existed = deployment.at("original_existed").get<bool>();
            if (original_existed)
            {
                const fs::path rollback_artifact = deployment.at("rollback_artifact").get<std::string>();
                if (!fs::exists(rollback_artifact) || !fs::is_regular_file(rollback_artifact))
                {
                    add(result.diagnostics, Severity::error, "ROLLBACK_ARTIFACT", "Rollback snapshot is missing");
                    return result;
                }
                const std::string original_hash = deployment.at("original_sha256").get<std::string>();
                if (sha256_file(rollback_artifact) != original_hash)
                {
                    add(result.diagnostics, Severity::error, "ROLLBACK_HASH", "Rollback snapshot hash is invalid");
                    return result;
                }
                fs::path temporary = result.live_target;
                temporary += ".renovice.rollback.tmp";
                fs::copy_file(rollback_artifact, temporary, fs::copy_options::overwrite_existing);
                if (!MoveFileExW(
                        temporary.wstring().c_str(),
                        result.live_target.wstring().c_str(),
                        MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH))
                {
                    const DWORD error = GetLastError();
                    fs::remove(temporary);
                    throw std::runtime_error("Atomic rollback rename failed with Windows error " + std::to_string(error));
                }
                if (sha256_file(result.live_target) != original_hash)
                {
                    throw std::runtime_error("Restored target failed original hash verification");
                }
            }
            else
            {
                fs::remove(result.live_target);
            }

            deployment["status"] = "ROLLED_BACK";
            deployment["rolled_back_at_unix_ms"] = std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()).count();
            write_text(result.deployment_manifest, deployment.dump(2) + "\n");
            add(result.diagnostics, Severity::info, "ROLLED_BACK", "Previous live state restored and verified");
            result.success = true;
        }
        catch (const std::exception& exception)
        {
            add(result.diagnostics, Severity::error, "ROLLBACK_EXCEPTION", exception.what());
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
            check(contains_text(source, "afterDamage = afterDamage"), "universal afterDamage contract generated");
            check(contains_text(source, "nativeCalls = {"), "low-level nativeCalls contract generated");
            check(contains_text(source, "PushFloatArg = {"), "declared native method generated");
            check(contains_text(source, "prototype == 16 and instruction == 596 and arguments[2] == 1"), "exact native callsite guard generated");
            check(contains_text(source, "arguments[2] = 5"), "native argument replacement generated");
            check(contains_text(source, "GetUpgradeModifiedValue("), "stock operation-10 modifier generated");
            check(!contains_text(source, "RENOVICE_AFTER_MALLET_DAMAGE"), "legacy handler slot omitted");
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

            Json invalid_method = project;
            invalid_method["addon_generation"]["native_argument_rewrites"][0]["method"] = "PushFloatArg; injected";
            check(has_errors(validate_project(invalid_method, editor_root)), "unsafe native method rejected");

            Json invalid_site = project;
            invalid_site["addon_generation"]["native_argument_rewrites"][0]["instruction"] = -1;
            check(has_errors(validate_project(invalid_site, editor_root)), "invalid native instruction rejected");

            Json invalid_range = project;
            invalid_range["stats"][0]["maximum"] = 0.005;
            check(has_errors(validate_project(invalid_range, editor_root)), "base above cap rejected");

            Json wrong_unit = project;
            wrong_unit["stats"][0]["card"]["unit"] = nullptr;
            check(has_errors(validate_project(wrong_unit, editor_root)), "fraction without percent unit rejected");

            check(source == generate_target_addon_source(project, editor_root), "generation is deterministic");

            const Json survival_project{
                {"project_version", 1},
                {"id", "mission.survival.timers.addon"},
                {"status", "READY_TO_BUILD"},
                {"authoring_mode", "MANAGED_LUA_CALL_ADDON"},
                {"mode_selection", "AUTOMATIC_RECOMMENDATION"},
                {"mode_reason", "Exact stock timer ownership"},
                {"target", {
                    {"warframe", "Mission"},
                    {"ability", "Survival Timers"},
                    {"ability_identifier", "SURVIVAL_TIMER_PATCH"},
                    {"ability_localize_tag", nullptr},
                    {"module_path", "Lotus.Scripts.Modes.SurvivalMission"},
                    {"module_body_key", "1e3647332a578b78"},
                    {"installed_build", "exact-corpus-build"},
                    {"expected_source_sha256", nullptr},
                }},
                {"effect", {
                    {"summary", "Change stock Survival timer owners without replacing the mission module."},
                    {"owner", "ADDON"},
                    {"hook", "renovice.target.lua_call"},
                    {"hook_evidence_id", "WF-SURVIVAL-PROTO64-CAPTURES-2026-09-09"},
                    {"authority", "OWNER"},
                    {"lifetime", "Exact target-module generation."},
                    {"cleanup", "Restore table fields still owned by this generation."},
                    {"stacking", "Positive stock PickupCollection delta only."},
                }},
                {"stats", Json::array()},
                {"addon_generation", {
                    {"template", "MISSION_SURVIVAL_TIMERS_LUA_CALL"},
                    {"hook_binding", "renovice.target.lua_call"},
                    {"prototype", 64},
                    {"elapsed_reward_upvalue", 19},
                    {"pickup_config_upvalue", 22},
                    {"reward_config_upvalue", 70},
                    {"reward_interval_seconds", 150},
                    {"life_support_per_pickup_seconds", 7},
                    {"reward_progress_per_pickup_seconds", 5},
                }},
                {"description", {
                    {"enabled", false},
                    {"localization_key", nullptr},
                    {"text", nullptr},
                }},
                {"deployment", {
                    {"requires_addon", true},
                    {"requires_card_extension", false},
                    {"requires_native_module", false},
                    {"requires_description_override", false},
                    {"live_manifest", nullptr},
                }},
            };
            const std::vector<Diagnostic> survival_diagnostics =
                validate_project(survival_project, editor_root);
            check(!has_errors(survival_diagnostics), "valid Survival exact Lua-call addon project");
            check(
                std::any_of(survival_diagnostics.begin(), survival_diagnostics.end(), [](const Diagnostic& diagnostic) {
                    return diagnostic.code == "MISSION_ADDON_INVARIANT";
                }),
                "Survival exact prototype and capture invariant emitted");
            const std::string survival_source =
                generate_target_addon_source(survival_project, editor_root);
            check(
                contains_text(survival_source, "local REWARD_INTERVAL_SECONDS = 150")
                    && contains_text(survival_source, "local LIFE_SUPPORT_PER_PICKUP_SECONDS = 7")
                    && contains_text(survival_source, "local REWARD_PROGRESS_PER_PICKUP_SECONDS = 5"),
                "Survival configured values reach deterministic addon source");
            check(
                contains_text(survival_source, "upvalues[19] = elapsedRewardTime + newPickups * REWARD_PROGRESS_PER_PICKUP_SECONDS")
                    && contains_text(survival_source, "hooks = { luaCalls = { [64]")
                    && !contains_text(survival_source, "afterSurvivalUpdate")
                    && !contains_text(survival_source, "frame_76[116]"),
                "Survival addon updates the verified elapsed-time capture and omits the rejected replacement slot");
            check(
                survival_source == generate_target_addon_source(survival_project, editor_root),
                "Survival addon generation is deterministic");

            Json wrong_survival_capture = survival_project;
            wrong_survival_capture["addon_generation"]["elapsed_reward_upvalue"] = 20;
            check(
                has_errors(validate_project(wrong_survival_capture, editor_root)),
                "Survival addon rejects a drifted upvalue capture");
            Json wrong_survival_target = survival_project;
            wrong_survival_target["target"]["module_body_key"] = "1111111111111111";
            check(
                has_errors(validate_project(wrong_survival_target, editor_root)),
                "Survival addon rejects another module body");
            Json invalid_survival_range = survival_project;
            invalid_survival_range["addon_generation"]["reward_interval_seconds"] = 0;
            check(
                has_errors(validate_project(invalid_survival_range, editor_root)),
                "Survival addon rejects an invalid timer range");

            Json mobile_project = survival_project;
            mobile_project["id"] = "mission.mobile_defense.timers.exact-replacement";
            mobile_project["authoring_mode"] = "MANAGED_MISSION_EXACT_REPLACEMENT";
            mobile_project["target"]["ability"] = "Mobile Defense Timers";
            mobile_project["target"]["ability_identifier"] = "MOBILE_DEFENSE_TIMER_PATCH";
            mobile_project["target"]["module_path"] = "Lotus.Scripts.MobileDefense";
            mobile_project["target"]["module_body_key"] = "89329f85c8575b84";
            mobile_project["effect"]["owner"] = "NATIVE_MODULE";
            mobile_project["effect"]["hook"] = nullptr;
            mobile_project["effect"]["hook_evidence_id"] = "WF-MOBILE-DEFENSE-PROTO22-LERP-OPERANDS-2026-09-12";
            mobile_project["deployment"]["requires_addon"] = false;
            mobile_project["deployment"]["requires_native_module"] = true;
            mobile_project.erase("addon_generation");
            mobile_project["replacement_generation"] = {
                {"template", "MISSION_MOBILE_DEFENSE_TIMERS_EXACT_REPLACEMENT"},
                {"stock_corpus_file", "Lotus_Scripts_MobileDefense.lua_B"},
                {"stock_sha256", "E9CBBEF4B6BECA2AC61EC741F3F9A22BA45DF06878708C429176843222B47541"},
                {"stock_minimum_total_seconds", 180},
                {"stock_maximum_total_seconds", 240},
                {"minimum_prototype", 22},
                {"minimum_instruction", 120},
                {"minimum_loadn_occurrence", 9},
                {"maximum_prototype", 22},
                {"maximum_instruction", 121},
                {"maximum_loadn_occurrence", 10},
                {"minimum_total_seconds", 90},
                {"maximum_total_seconds", 120},
            };
            check(!has_errors(validate_project(mobile_project, editor_root)),
                "valid Mobile Defense exact stock-body replacement project");
            Json drifted_mobile_site = mobile_project;
            drifted_mobile_site["replacement_generation"]["minimum_instruction"] = 119;
            check(has_errors(validate_project(drifted_mobile_site, editor_root)),
                "Mobile Defense exact replacement rejects a drifted LOADN site");
            Json invalid_mobile_order = mobile_project;
            invalid_mobile_order["replacement_generation"]["minimum_total_seconds"] = 121;
            check(has_errors(validate_project(invalid_mobile_order, editor_root)),
                "Mobile Defense replacement rejects minimum greater than maximum");
            const fs::path mobile_build_fixture = fs::temp_directory_path()
                / ("renovice_mobile_defense_exact_selftest_" + std::to_string(GetCurrentProcessId()));
            fs::remove_all(mobile_build_fixture);
            const BuildResult mobile_build = build_staged_exact_mission_replacement(
                mobile_project,
                editor_root,
                mobile_build_fixture,
                true);
            check(mobile_build.success && fs::exists(mobile_build.generated_bytecode),
                "Mobile Defense exact replacement passes stock hash, surgical patch, roundtrip, plan, structure, and byte-diff gates");
            check(contains_text(mobile_build.gate_log, "changed=2 expected_changed=2")
                    && contains_text(mobile_build.gate_log, "pidx=22")
                    && !contains_text(mobile_build.gate_log, "pidx=13"),
                "Mobile Defense build changes only the two configured duration operand bytes in DefenseStage");
            fs::remove_all(mobile_build_fixture);

            Json interception_project = survival_project;
            interception_project["id"] = "mission.interception.timers.addon";
            interception_project["authoring_mode"] = "MANAGED_MISSION_ADDON";
            interception_project["target"]["ability"] = "Interception Timers";
            interception_project["target"]["ability_identifier"] = "INTERCEPTION_SCORING_PATCH";
            interception_project["target"]["module_path"] = "Lotus.Scripts.Modes.TerritoryMission";
            interception_project["target"]["module_body_key"] = "a51e98a1833bd8c1";
            interception_project["effect"]["hook"] = "renovice.target.lua_call";
            interception_project["effect"]["hook_evidence_id"] = "WF-TERRITORY-PROTO35-SCORE-RATE-2026-09-09";
            interception_project["addon_generation"] = {
                {"template", "MISSION_INTERCEPTION_SCORING_TARGET"},
                {"hook_binding", "renovice.target.lua_call"},
                {"prototype", 35},
                {"stock_score_rate", 1},
                {"scoring_speed_multiplier", 2},
            };
            check(!has_errors(validate_project(interception_project, editor_root)),
                "valid Interception exact scalar-owner addon project");
            const std::string interception_source = generate_target_addon_source(interception_project, editor_root);
            check(contains_text(interception_source, "scoreRatePerSecond = ownedScoreRate")
                    && contains_text(interception_source, "[35] = { before = beforeTerritoryMission }")
                    && contains_text(interception_source, "ownedScoreRate * 4")
                    && contains_text(interception_source, "scoreRatePerSecond == STOCK_SCORE_RATE")
                    && !contains_text(interception_source, "type(scoreRatePerSecond)"),
                "Interception addon uses the exact stock-value check without a borrowed-environment type guard");

            Json excavation_project = survival_project;
            excavation_project["id"] = "mission.excavation.timers.exact-replacement";
            excavation_project["authoring_mode"] = "MANAGED_MISSION_EXACT_REPLACEMENT";
            excavation_project["target"]["ability"] = "Excavation Timers";
            excavation_project["target"]["ability_identifier"] = "EXCAVATION_TIMER_PATCH";
            excavation_project["target"]["module_path"] = "Lotus.Scripts.Modes.ExcavationMission";
            excavation_project["target"]["module_body_key"] = "303f809a05c1fbaa";
            excavation_project["effect"]["owner"] = "NATIVE_MODULE";
            excavation_project["effect"]["hook"] = nullptr;
            excavation_project["effect"]["hook_evidence_id"] = "WF-EXCAVATION-STOCK-DURATION-ASSIGNMENTS-2026-09-11";
            excavation_project["deployment"]["requires_addon"] = false;
            excavation_project["deployment"]["requires_native_module"] = true;
            excavation_project.erase("addon_generation");
            excavation_project["replacement_generation"] = {
                {"template", "MISSION_EXCAVATION_TIMERS_EXACT_REPLACEMENT"},
                {"stock_corpus_file", "Lotus_Scripts_Modes_ExcavationMission.lua_B"},
                {"stock_sha256", "A2326FD92DDC2075E03CAB08300744BFA15ED8BDEC7C13FA98DD5071EEEC20C2"},
                {"stock_standard_seconds", 100},
                {"stock_old_world_salvage_seconds", 60},
                {"stock_elite_alert_seconds", 140},
                {"standard_prototype", 49},
                {"standard_instruction", 76},
                {"standard_loadn_occurrence", 33},
                {"old_world_salvage_prototype", 32},
                {"old_world_salvage_instruction", 81},
                {"old_world_salvage_loadn_occurrence", 5},
                {"elite_alert_prototype", 32},
                {"elite_alert_instruction", 102},
                {"elite_alert_loadn_occurrence", 6},
                {"standard_dig_seconds", 50},
                {"old_world_salvage_dig_seconds", 30},
                {"elite_alert_dig_seconds", 70},
            };
            check(!has_errors(validate_project(excavation_project, editor_root)),
                "valid Excavation exact stock-body replacement project");
            Json drifted_excavation_site = excavation_project;
            drifted_excavation_site["replacement_generation"]["standard_instruction"] = 77;
            check(has_errors(validate_project(drifted_excavation_site, editor_root)),
                "Excavation exact replacement rejects a drifted LOADN site");
            Json fractional_excavation_time = excavation_project;
            fractional_excavation_time["replacement_generation"]["standard_dig_seconds"] = 49.5;
            check(has_errors(validate_project(fractional_excavation_time, editor_root)),
                "Excavation exact replacement rejects a duration that LOADN cannot represent exactly");
            const fs::path excavation_build_fixture = fs::temp_directory_path()
                / ("renovice_excavation_exact_selftest_" + std::to_string(GetCurrentProcessId()));
            fs::remove_all(excavation_build_fixture);
            const BuildResult excavation_build = build_staged_exact_mission_replacement(
                excavation_project,
                editor_root,
                excavation_build_fixture,
                true);
            check(excavation_build.success && fs::exists(excavation_build.generated_bytecode),
                "Excavation exact replacement passes stock hash, surgical patch, roundtrip, plan, structure, and byte-diff gates");
            check(contains_text(excavation_build.gate_log, "changed=3 expected_changed=3")
                    && contains_text(excavation_build.gate_log, "pidx=32")
                    && contains_text(excavation_build.gate_log, "pidx=49"),
                "Excavation build changes only the three configured duration operand bytes");
            fs::remove_all(excavation_build_fixture);

            Json plains_control_project = survival_project;
            plains_control_project["id"] = "mission.control_area_plains.timers.exact-replacement";
            plains_control_project["authoring_mode"] = "MANAGED_MISSION_EXACT_REPLACEMENT";
            plains_control_project["target"]["ability"] = "Control Area (Plains) Timers";
            plains_control_project["target"]["ability_identifier"] = "CONTROL_AREA_PLAINS_TIMER_PATCH";
            plains_control_project["target"]["module_path"] = "Lotus.Scripts.Eidolon.Encounters.DynamicDefend";
            plains_control_project["target"]["module_body_key"] = "bf3c901cb4058c47";
            plains_control_project["effect"]["owner"] = "NATIVE_MODULE";
            plains_control_project["effect"]["hook"] = nullptr;
            plains_control_project["effect"]["hook_evidence_id"] = "WF-CONTROL-AREA-PLAINS-ROOT-DURATION-LOADN-2026-09-11";
            plains_control_project["deployment"]["requires_addon"] = false;
            plains_control_project["deployment"]["requires_native_module"] = true;
            plains_control_project.erase("addon_generation");
            plains_control_project["replacement_generation"] = {
                {"template", "MISSION_CONTROL_AREA_PLAINS_TIMER_EXACT_REPLACEMENT"},
                {"stock_corpus_file", "Lotus_Scripts_Eidolon_Encounters_DynamicDefend.lua_B"},
                {"stock_sha256", "ECC204753DB9BDED69F6A764C919DF5DD2240B5EE907E35C046E99C624D23386"},
                {"stock_duration_seconds", 90},
                {"duration_prototype", 17},
                {"duration_instruction", 44},
                {"duration_loadn_occurrence", 3},
                {"timer_argument_prototype", 8},
                {"timer_argument_instruction", 100},
                {"timer_argument_move_occurrence", 0},
                {"duration_seconds", 45},
            };
            check(!has_errors(validate_project(plains_control_project, editor_root)),
                "valid Plains Control Area exact stock-body replacement project");
            Json drifted_plains_site = plains_control_project;
            drifted_plains_site["replacement_generation"]["duration_instruction"] = 45;
            check(has_errors(validate_project(drifted_plains_site, editor_root)),
                "Plains Control Area exact replacement rejects a drifted root LOADN site");
            const fs::path plains_build_fixture = fs::temp_directory_path()
                / ("renovice_plains_control_exact_selftest_" + std::to_string(GetCurrentProcessId()));
            fs::remove_all(plains_build_fixture);
            const BuildResult plains_build = build_staged_exact_mission_replacement(
                plains_control_project,
                editor_root,
                plains_build_fixture,
                true);
            check(plains_build.success && fs::exists(plains_build.generated_bytecode),
                "Plains Control Area exact replacement passes stock hash, surgical patch, roundtrip, plan, semantic IR, structure, and byte-diff gates");
            check(contains_text(plains_build.gate_log, "changed=3 expected_changed=3")
                    && contains_text(plains_build.gate_log, "pidx=8")
                    && contains_text(plains_build.gate_log, "pidx=17")
                    && contains_text(plains_build.gate_log, "semantic-ir-verify"),
                "Plains Control Area build changes only the root duration operand and SetObjTimer argument instruction");
            fs::remove_all(plains_build_fixture);

            Json deimos_control_project = survival_project;
            deimos_control_project["id"] = "mission.control_area_deimos.timers.exact-replacement";
            deimos_control_project["authoring_mode"] = "MANAGED_MISSION_EXACT_REPLACEMENT";
            deimos_control_project["target"]["ability"] = "Control Area (Deimos) Timers";
            deimos_control_project["target"]["ability_identifier"] = "CONTROL_AREA_DEIMOS_TIMER_PATCH";
            deimos_control_project["target"]["module_path"] = "Lotus.Scripts.InfestedMicroplanet.Encounters.DynamicAreaDefense";
            deimos_control_project["target"]["module_body_key"] = "d9541341dfd466a3";
            deimos_control_project["effect"]["owner"] = "NATIVE_MODULE";
            deimos_control_project["effect"]["hook"] = nullptr;
            deimos_control_project["effect"]["hook_evidence_id"] = "WF-CONTROL-AREA-DEIMOS-ROOT-DURATION-LOADN-2026-09-11";
            deimos_control_project["deployment"]["requires_addon"] = false;
            deimos_control_project["deployment"]["requires_native_module"] = true;
            deimos_control_project.erase("addon_generation");
            deimos_control_project["replacement_generation"] = {
                {"template", "MISSION_CONTROL_AREA_DEIMOS_TIMER_EXACT_REPLACEMENT"},
                {"stock_corpus_file", "Lotus_Scripts_InfestedMicroplanet_Encounters_DynamicAreaDefense.lua_B"},
                {"stock_sha256", "ECBED12E85416CE5FBB25995D9252F4AD29042F1AE7DAA3C2E4C8A2F25AEDF49"},
                {"stock_duration_seconds", 90},
                {"duration_prototype", 15},
                {"duration_instruction", 56},
                {"duration_loadn_occurrence", 1},
                {"persistent_result_prototype", 7},
                {"persistent_result_instruction", 63},
                {"persistent_result_getupval_occurrence", 15},
                {"duration_seconds", 45},
            };
            check(!has_errors(validate_project(deimos_control_project, editor_root)),
                "valid Deimos Control Area exact stock-body replacement project");
            Json drifted_deimos_site = deimos_control_project;
            drifted_deimos_site["replacement_generation"]["duration_loadn_occurrence"] = 2;
            check(has_errors(validate_project(drifted_deimos_site, editor_root)),
                "Deimos Control Area exact replacement rejects a drifted root LOADN site");
            const fs::path deimos_build_fixture = fs::temp_directory_path()
                / ("renovice_deimos_control_exact_selftest_" + std::to_string(GetCurrentProcessId()));
            fs::remove_all(deimos_build_fixture);
            const BuildResult deimos_build = build_staged_exact_mission_replacement(
                deimos_control_project,
                editor_root,
                deimos_build_fixture,
                true);
            check(deimos_build.success && fs::exists(deimos_build.generated_bytecode),
                "Deimos Control Area exact replacement passes stock hash, surgical patch, roundtrip, plan, semantic IR, structure, and byte-diff gates");
            check(contains_text(deimos_build.gate_log, "changed=4 expected_changed=4")
                    && contains_text(deimos_build.gate_log, "pidx=7")
                    && contains_text(deimos_build.gate_log, "pidx=15")
                    && contains_text(deimos_build.gate_log, "semantic-ir-verify"),
                "Deimos Control Area build changes only the root duration operand and persisted duration result instruction");
            fs::remove_all(deimos_build_fixture);

            Json nokko_control_project = survival_project;
            nokko_control_project["id"] = "mission.control_area_nokko.timers.exact-replacement";
            nokko_control_project["authoring_mode"] = "MANAGED_MISSION_EXACT_REPLACEMENT";
            nokko_control_project["target"]["ability"] = "Control Area (Venus/Nokko) Timers";
            nokko_control_project["target"]["ability_identifier"] = "CONTROL_AREA_NOKKO_TIMER_PATCH";
            nokko_control_project["target"]["module_path"] = "Lotus.Scripts.Venus.NokkoColony.Encounters.AreaDefense";
            nokko_control_project["target"]["module_body_key"] = "e192d5cc2f37056e";
            nokko_control_project["effect"]["owner"] = "NATIVE_MODULE";
            nokko_control_project["effect"]["hook"] = nullptr;
            nokko_control_project["effect"]["hook_evidence_id"] = "WF-CONTROL-AREA-NOKKO-TIMER-CONSUMER-AND-THRESHOLDS-2026-09-11";
            nokko_control_project["deployment"]["requires_addon"] = false;
            nokko_control_project["deployment"]["requires_native_module"] = true;
            nokko_control_project.erase("addon_generation");
            nokko_control_project["replacement_generation"] = {
                {"template", "MISSION_CONTROL_AREA_NOKKO_TIMER_EXACT_REPLACEMENT"},
                {"stock_corpus_file", "Lotus_Scripts_Venus_NokkoColony_Encounters_AreaDefense.lua_B"},
                {"stock_sha256", "E5048C7A1F9AE04DA38BA5AAE18D749A946172A61E67F6D56853BC719246C3F5"},
                {"timer_argument_prototype", 5},
                {"timer_argument_instruction", 118},
                {"timer_argument_move_occurrence", 0},
                {"halfway_result_prototype", 6},
                {"halfway_result_instruction", 107},
                {"halfway_sub_occurrence", 0},
                {"two_thirds_result_prototype", 6},
                {"two_thirds_result_instruction", 112},
                {"two_thirds_sub_occurrence", 1},
                {"duration_seconds", 30},
            };
            check(!has_errors(validate_project(nokko_control_project, editor_root)),
                "valid Venus/Nokko Control Area exact timer-consumer replacement project");
            Json fractional_nokko_time = nokko_control_project;
            fractional_nokko_time["replacement_generation"]["duration_seconds"] = 25;
            check(has_errors(validate_project(fractional_nokko_time, editor_root)),
                "Venus/Nokko exact replacement rejects durations that cannot preserve both linked thresholds exactly");
            const fs::path nokko_build_fixture = fs::temp_directory_path()
                / ("renovice_nokko_control_exact_selftest_" + std::to_string(GetCurrentProcessId()));
            fs::remove_all(nokko_build_fixture);
            const BuildResult nokko_build = build_staged_exact_mission_replacement(
                nokko_control_project,
                editor_root,
                nokko_build_fixture,
                true);
            check(nokko_build.success && fs::exists(nokko_build.generated_bytecode),
                "Venus/Nokko Control Area exact replacement passes stock hash, timer-consumer, linked-threshold, roundtrip, semantic, structure, and byte-diff gates");
            check(contains_text(nokko_build.gate_log, "changed=8 expected_changed=8")
                    && contains_text(nokko_build.gate_log, "pidx=5")
                    && contains_text(nokko_build.gate_log, "pidx=6")
                    && contains_text(nokko_build.gate_log, "semantic-ir-verify"),
                "Venus/Nokko build changes only the SetObjTimer argument and two linked threshold result instructions");
            fs::remove_all(nokko_build_fixture);

            // Universal mission tunable registry for client 44.0.2 (2026.09.28.13.06) and the group-by-body-key generator.
            {
                const Json registry = load_mission_registry(editor_root);
                const MissionPaths mission_roots = mission_paths(registry, editor_root);
                const Json verification = verify_mission_registry(editor_root);
                check(verification.at("status") == "PASS" && verification.at("fail") == 0
                        && verification.at("pass") == registry.at("tunables").size(),
                    "every mission registry row verifies against its 44.0.2 stock evidence (SHA-256 + exact preimage)");
                check(registry.at("build") == "2026.09.28.13.06", "mission registry build label is 44.0.2 (2026.09.28.13.06)");
                const fs::path mission_fixture = fs::temp_directory_path()
                    / ("renovice_mission_registry_selftest_" + std::to_string(GetCurrentProcessId()));
                fs::remove_all(mission_fixture);
                const auto settings = [&](const Json& values) {
                    return Json{{"format", "RENOVICE_MISSION_SETTINGS_V1"}, {"build", registry.at("build")}, {"values", values}};
                };
                const auto site_of = [&](const std::string& id, const std::size_t index) -> const Json& {
                    return mission_tunable(registry, id).at("owner").at("sites").at(index);
                };
                const auto changed_bytes = [](const std::string& left, const std::string& right) {
                    std::size_t changed = left.size() == right.size() ? 0 : std::string::npos;
                    for (std::size_t n = 0; changed != std::string::npos && n < left.size(); ++n) changed += left[n] != right[n] ? 1 : 0;
                    return changed;
                };

                const MissionSetResult merged = build_mission_settings(
                    settings({{"excavation.dig_duration", 50}, {"excavation.dig_duration_elite_alert", 70}}), editor_root, mission_fixture, true);
                bool merged_ok = merged.success && merged.artifacts.size() == 1 && merged.artifacts.front().body_key == "f7444e3c621ff018"
                    && merged.artifacts.front().tunables.size() == 2 && merged.server_config_diff.empty();
                if (merged_ok)
                {
                    const auto stock = read_text(mission_roots.corpus / "Lotus_Scripts_Modes_ExcavationMission.lua_B");
                    const auto built = read_text(merged.artifacts.front().artifact);
                    const auto standard = site_of("excavation.dig_duration", 0).at("offset").get<std::size_t>();
                    const auto elite = site_of("excavation.dig_duration_elite_alert", 0).at("offset").get<std::size_t>();
                    merged_ok = changed_bytes(stock, built) == 2 && static_cast<unsigned char>(built[standard + 2]) == 50
                        && static_cast<unsigned char>(built[elite + 2]) == 70;
                }
                check(merged_ok, "two literal tunables in one module merge into exactly one exact-replacement artifact with only their operands changed");

                // Phase 2e: root-table rows of one body (carried-over preset row + Phase 2d row) are routed to ONE generic
                // target addon that writes each field; the preset keeps its literal form (literal_owner).
                const MissionSetResult cascade = build_mission_settings(
                    settings({{"void_cascade.pillar_duration", 45}, {"void_cascade.alert_reward_interval", 5}}), editor_root, mission_fixture, true);
                bool cascade_ok = cascade.success && cascade.artifacts.size() == 1 && cascade.artifacts.front().body_key == "32c344afa33be174"
                    && cascade.artifacts.front().backend == "TARGET_ADDON"
                    && mission_tunable(registry, "void_cascade.pillar_duration").contains("literal_owner");
                if (cascade_ok)
                {
                    const auto source = read_text(cascade.artifacts.front().source);
                    cascade_ok = contains_text(source, "owner[\"PILLAR_DURATION\"] = 45") && contains_text(source, "owner[\"PILLAR_DURATION_CIRCLE\"] = 45")
                        && contains_text(source, "owner[\"ALERT_REWARD_INTERVAL\"] = 5");
                }
                check(cascade_ok, "root-table rows of one body build one generic target addon that writes every owned field");

                const std::array<std::pair<const char*, std::size_t>, 6> conquest{{
                    {"archimedea.eta_survival_minutes", 46570}, {"archimedea.eta_defense_waves", 46582},
                    {"archimedea.eda_survival_minutes", 46726}, {"archimedea.eda_mirror_defense_waves", 46738},
                    {"archimedea.eda_alchemy", 46750}, {"archimedea.eda_disruption", 46762}}};
                bool conquest_ok = true;
                for (const auto& [id, previous_offset] : conquest)
                {
                    const std::string key = id;
                    const Json& row = mission_tunable(registry, key);
                    conquest_ok = conquest_ok && row.at("owner").at("body_key") == "076a7b443af7fdb8"
                        && row.at("owner").at("stock_sha256") == "73107506E80FF7853AE0C4E77D56682707492328BE9EEC80067C5EDB86529453"
                        && row.at("owner").at("sites").at(0).at("prototype") == 43
                        && row.at("owner").at("sites").at(0).at("offset").get<std::size_t>() == previous_offset + 61;
                }
                check(conquest_ok, "ConquestLib EDA/ETA rows are re-registered on body 076a7b443af7fdb8, prototype 43, offsets +61");
                const MissionSetResult conquest_build = build_mission_settings(
                    settings({{"archimedea.eta_survival_minutes", 5}, {"archimedea.eda_disruption", 4}}), editor_root, mission_fixture, true);
                check(conquest_build.success && conquest_build.artifacts.size() == 1
                        && static_cast<unsigned char>(read_text(conquest_build.artifacts.front().artifact)[46631 + 2]) == 5
                        && static_cast<unsigned char>(read_text(conquest_build.artifacts.front().artifact)[46823 + 2]) == 4,
                    "re-registered ConquestLib builds one replacement from the 44.0.2 stock body");

                const MissionSetResult mixed = build_mission_settings(settings({
                    {"netracell.enemy_power_fill", 2}, {"shrine.offering_generation_time", 15},
                    {"mobiledefense.total_time.minimum", 90}, {"survival.reward_interval", 150},
                    {"server.credit_boost_multiplier", 2}}), editor_root, mission_fixture, true);
                bool mixed_ok = mixed.success && mixed.artifacts.size() == 3 && fs::exists(mixed.server_config_diff);
                if (mixed_ok)
                {
                    std::set<std::string> backends;
                    for (const auto& item : mixed.artifacts) backends.insert(item.backend);
                    const auto metadata_text = read_text(std::find_if(mixed.artifacts.begin(), mixed.artifacts.end(),
                        [](const MissionArtifact& item) { return item.backend == "METADATA_PATCH"; })->artifact);
                    const Json diff = Json::parse(read_text(mixed.server_config_diff));
                    mixed_ok = backends == std::set<std::string>{"EXACT_LITERAL", "TARGET_ADDON", "METADATA_PATCH"}
                        && contains_text(metadata_text, "    q|Scripts.0.Script._enemyPowerFill|2\n")
                        && contains_text(metadata_text, "    q|Scripts.0.Script._offeringGenerationTime|15\n")
                        && diff.at("applied") == false && diff.at("config_patch").at("worldState").at("creditBoostMultiplier") == 2;
                }
                check(mixed_ok, "mixed settings produce one replacement, one target addon, one metadata file and one unapplied server diff");

                const MissionSetResult wrong_build = build_mission_settings(
                    Json{{"build", "2026.09.24.13.29"}, {"values", {{"excavation.dig_duration", 50}}}}, editor_root, mission_fixture, true);
                check(!wrong_build.success && !wrong_build.diagnostics.empty()
                        && contains_text(wrong_build.diagnostics.front().message, "Unsupported mission build profile"),
                    "mission settings for an unknown build fail closed");
                check(!build_mission_settings(settings({{"excavation.not_a_tunable", 5}}), editor_root, mission_fixture, true).success,
                    "unknown tunable ids fail closed");
                check(!build_mission_settings(settings({{"excavation.dig_duration", 0}}), editor_root, mission_fixture, true).success
                        && !build_mission_settings(settings({{"void_cascade.pillar_duration", 22.5}}), editor_root, mission_fixture, true).success,
                    "out-of-range and non-whole-number literal operands fail closed");

                const MissionNaming group_naming{"missions-selftest", "missions", "missions", "RENOVICE_Missions.txt", false, ""};
                Json hash_mismatch = registry;
                hash_mismatch["modules"]["f7444e3c621ff018"]["sha256"] = std::string(64, '0');
                const MissionSetResult rejected_hash = build_mission_set(hash_mismatch, Json{{"excavation.dig_duration", 50}},
                    group_naming, editor_root, mission_fixture, true, nullptr);
                check(!rejected_hash.success && contains_text(rejected_hash.diagnostics.front().message, "stock"),
                    "a stock SHA-256 mismatch disables the row and fails the build closed");
                Json preimage_mismatch = registry;
                for (auto& row : preimage_mismatch["tunables"])
                    if (row.at("tunable_id") == "excavation.dig_duration") row["owner"]["sites"][0]["expected"][2] = 99;
                const MissionSetResult rejected_preimage = build_mission_set(preimage_mismatch, Json{{"excavation.dig_duration", 50}},
                    group_naming, editor_root, mission_fixture, true, nullptr);
                check(!rejected_preimage.success && contains_text(rejected_preimage.diagnostics.front().message, "preimage"),
                    "an exact preimage mismatch fails closed");
                Json competing = registry;
                competing["modules"]["f7444e3c621ff018"]["addon"] = registry.at("modules").at("f10a043e7f825db2").at("addon");
                competing["modules"]["f7444e3c621ff018"]["addon"]["values"] = {{"reward_interval_seconds", "excavation.selftest_addon"}};
                Json fake = mission_tunable(registry, "survival.reward_interval");
                fake["owner"].erase("fields");  // template-only addon row: no generic or literal form on this body
                fake["owner"].erase("gate");
                fake["tunable_id"] = "excavation.selftest_addon";
                fake["owner"]["body_key"] = "f7444e3c621ff018";
                fake["owner"]["stock_sha256"] = registry.at("modules").at("f7444e3c621ff018").at("sha256");
                fake["owner"]["file"] = registry.at("modules").at("f7444e3c621ff018").at("file");
                competing["tunables"].push_back(fake);
                const MissionSetResult rejected_competing = build_mission_set(competing,
                    Json{{"excavation.dig_duration", 50}, {"excavation.selftest_addon", 150}}, group_naming, editor_root, mission_fixture, true, nullptr);
                check(!rejected_competing.success && contains_text(rejected_competing.diagnostics.front().message, "one body key may own only one artifact"),
                    "an exact replacement and a target addon for one body key are rejected as competing files");
                Json overlapping = registry;
                Json duplicate = mission_tunable(registry, "excavation.dig_duration");
                duplicate["tunable_id"] = "excavation.selftest_duplicate";
                overlapping["tunables"].push_back(duplicate);
                bool overlap_rejected = false;
                try { verify_mission_registry_structure(overlapping); }
                catch (const std::exception& e) { overlap_rejected = contains_text(e.what(), "competing owners"); }
                check(overlap_rejected, "two registry rows claiming one exact site are rejected");

                // Phase 2d: one tunable that owns several literal sites is patched atomically (all sites or nothing).
                {
                    const std::string multi = "disruption.default_round_count";
                    const Json& multi_row = mission_tunable(registry, multi);
                    const auto& multi_sites = multi_row.at("owner").at("sites");
                    const MissionSetResult rounds = build_mission_settings(settings({{multi, 6}}), editor_root, mission_fixture, true);
                    bool rounds_ok = multi_sites.size() == 7 && rounds.success && rounds.artifacts.size() == 1
                        && rounds.artifacts.front().body_key == multi_row.at("owner").at("body_key").get<std::string>();
                    if (rounds_ok)
                    {
                        const auto stock = read_text(mission_roots.corpus / multi_row.at("owner").at("file").get<std::string>());
                        const auto built = read_text(rounds.artifacts.front().artifact);
                        rounds_ok = changed_bytes(stock, built) == multi_sites.size();
                        for (const auto& site : multi_sites)
                            rounds_ok = rounds_ok && static_cast<unsigned char>(built[site.at("offset").get<std::size_t>() + 2]) == 6
                                && static_cast<unsigned char>(built[site.at("offset").get<std::size_t>() + 3]) == 0;
                    }
                    check(rounds_ok, "a multi-site literal tunable (Disruption default rounds, 7 sites) patches every site in one artifact");
                    Json partial = registry;
                    for (auto& row : partial["tunables"])
                        if (row.at("tunable_id") == multi) row["owner"]["sites"][6]["expected"][2] = 5;
                    const MissionSetResult rejected_partial = build_mission_set(partial, Json{{multi, 6}}, group_naming, editor_root,
                                                                                mission_fixture, true, nullptr);
                    check(!rejected_partial.success && rejected_partial.artifacts.empty()
                            && contains_text(rejected_partial.diagnostics.front().message, "preimage"),
                        "one drifted site of a multi-site tunable fails the whole row closed (no partial coverage)");
                }

                // Phase 2e item 2: one root-table row + one literal row in the same module -> ONE merged exact replacement.
                // lowDropMultiplier is a root-table field (addon lane) that keeps its single-use template f64 as literal_owner;
                // elite_alert_pickup_mult is a function literal (proto 67 constant) with no addon form.
                {
                    const std::string field = "survival.pickup_drop_low_high_mult.lowDropMultiplier";
                    const std::string literal_id = "survival.elite_alert_pickup_mult";
                    const Json& field_row = mission_tunable(registry, field);
                    const Json& site = field_row.at("literal_owner").at("sites").at(0);
                    const Json& literal_site = mission_tunable(registry, literal_id).at("owner").at("sites").at(0);
                    const MissionSetResult table = build_mission_settings(settings({{field, 2.25}, {literal_id, 1}}), editor_root, mission_fixture, true);
                    bool table_ok = field_row.at("backend") == "TARGET_ADDON" && site.at("kind") == "number_constant"
                        && site.at("gate").at("template_uses").size() == 1 && table.success && table.artifacts.size() == 1
                        && table.artifacts.front().backend == "EXACT_LITERAL" && table.artifacts.front().tunables.size() == 2;
                    if (table_ok)
                    {
                        const auto stock = read_text(mission_roots.corpus / field_row.at("owner").at("file").get<std::string>());
                        const auto built = read_text(table.artifacts.front().artifact);
                        const auto f64_at = [&](const std::size_t offset) {
                            std::uint64_t bits = 0;
                            for (std::size_t n = 0; n < 8; ++n) bits |= static_cast<std::uint64_t>(static_cast<unsigned char>(built[offset + n])) << (8 * n);
                            return std::bit_cast<double>(bits);
                        };
                        const auto offset = site.at("offset").get<std::size_t>();
                        const auto literal_offset = literal_site.at("offset").get<std::size_t>();
                        std::size_t outside = 0;
                        for (std::size_t n = 0; n < stock.size(); ++n)
                            outside += (stock[n] != built[n] && (n < offset || n >= offset + 8) && (n < literal_offset || n >= literal_offset + 8)) ? 1 : 0;
                        table_ok = f64_at(offset) == 2.25 && f64_at(literal_offset) == 1 && outside == 0 && stock.size() == built.size();
                    }
                    check(table_ok, "a root-table row and a literal row of one module build one merged replacement (only the two f64 constants change)");
                    const MissionSetResult conflict = build_mission_settings(settings({{"survival.alert_interval", 900}, {literal_id, 1}}),
                                                                             editor_root, mission_fixture, true);
                    check(!conflict.success && conflict.artifacts.empty()
                            && contains_text(conflict.diagnostics.front().message, "addon-only: survival.alert_interval")
                            && contains_text(conflict.diagnostics.front().message, "literal-only: survival.elite_alert_pickup_mult"),
                        "an addon-only root-table row (shared constant) and a literal-only row of one module fail closed and name both rows");
                    const auto rejects = [&](const std::function<void(Json&)>& mutate, const std::string& reason) {
                        Json tampered = registry;
                        for (auto& row : tampered["tunables"])
                            if (row.at("tunable_id") == field) mutate(row["literal_owner"]["sites"][0]);
                        const MissionSetResult result = build_mission_set(tampered, Json{{field, 2.25}}, group_naming, editor_root,
                                                                          mission_fixture, true, nullptr);
                        return !result.success && contains_text(result.diagnostics.front().message, reason);
                    };
                    check(rejects([](Json& s) { s["gate"]["template_uses"].push_back(s["gate"]["template_uses"][0]); }, "exactly one DUPTABLE")
                            && rejects([](Json& s) { s["gate"]["uses"].push_back(s["gate"]["uses"][0]); }, "shared")
                            && rejects([](Json& s) { s["gate"]["loop_free"] = false; }, "inside a loop")
                            && rejects([](Json& s) { s.erase("gate"); }, "no constant-exclusivity gate"),
                        "the single-use template gate rejects a second construction site, a shared value, a loop and missing evidence");
                }

                // Phase 2e item 1: fields that share one bytecode constant are independent addon controls. Survival interval
                // (300) and killPlayerTime (300) share their stock value; each build writes only its own field.
                {
                    const Json interval = mission_tunable(registry, "survival.reward_interval");
                    const Json kill = mission_tunable(registry, "survival.player_damage_at_zero_ls.killPlayerTime");
                    const auto source_of = [&](const Json& values) {
                        const MissionSetResult built = build_mission_settings(settings(values), editor_root, mission_fixture, true);
                        return built.success && built.artifacts.size() == 1 && built.artifacts.front().backend == "TARGET_ADDON"
                            ? read_text(built.artifacts.front().source) : std::string();
                    };
                    const auto interval_source = source_of(Json{{"survival.reward_interval", 150}});
                    const auto kill_source = source_of(Json{{"survival.player_damage_at_zero_ls.killPlayerTime", 200}});
                    check(interval.at("stock") == 300 && kill.at("stock") == 300 && kill.at("backend") == "TARGET_ADDON"
                            && contains_text(interval_source, "owner[\"interval\"] = 150") && !contains_text(interval_source, "killPlayerTime")
                            && !contains_text(interval_source, "alertInterval") && contains_text(interval_source, "[67] = { before = before67 }")
                            && contains_text(kill_source, "owner[\"killPlayerTime\"] = 200") && !contains_text(kill_source, "\"interval\""),
                        "shared-constant root-table fields build as independent addon controls (interval 150 leaves killPlayerTime unchanged)");
                    const auto rejects_addon = [&](const std::function<void(Json&)>& mutate, const std::string& reason) {
                        Json tampered = registry;
                        mutate(tampered);
                        const MissionSetResult result = build_mission_set(tampered, Json{{"survival.alert_interval", 900}}, group_naming,
                                                                          editor_root, mission_fixture, true, nullptr);
                        return !result.success && contains_text(result.diagnostics.front().message, reason);
                    };
                    const auto alert_field = [](Json& r) -> Json& {
                        for (auto& row : r["tunables"]) if (row.at("tunable_id") == "survival.alert_interval") return row["owner"]["fields"][0];
                        throw std::runtime_error("selftest row missing");
                    };
                    const auto alert_table = mission_tunable(registry, std::string("survival.alert_interval")).at("owner").at("fields").at(0).at("table_id").get<std::string>();
                    check(rejects_addon([&](Json& r) { alert_field(r)["expected"][7] = 0; }, "initialiser preimage changed")
                            && rejects_addon([&](Json& r) { r["modules"]["f10a043e7f825db2"]["root_tables"][alert_table]["hooks"] = Json::array(); }, "no hooked capturer")
                            && rejects_addon([&](Json& r) { r["modules"]["f10a043e7f825db2"]["root_tables"][alert_table].erase("gate"); }, "no gate evidence")
                            && rejects_addon([&](Json& r) { alert_field(r)["field_reads"] = 0; }, "no consumer read"),
                        "the root-table addon gate rejects a drifted initialiser, a table without hooks, missing gate evidence and an unread field");
                }

                // Phase 2e item 3: Void Flood fracture counts use their own lanes (root local and Duviri assignment: exact
                // literals; Shadowgrapher maxFractureActive and curses: root-table addon fields).
                {
                    const Json duviri = mission_tunable(registry, "void_flood.fractures_per_round.duviri");
                    const MissionSetResult duviri_build = build_mission_settings(settings({{"void_flood.fractures_per_round.duviri", 6}}),
                                                                                 editor_root, mission_fixture, true);
                    bool duviri_ok = duviri.at("backend") == "EXACT_LITERAL" && duviri.at("owner").at("sites").size() == 2
                        && mission_tunable(registry, "void_flood.fractures_per_round.normal").at("backend") == "EXACT_LITERAL"
                        && duviri_build.success && duviri_build.artifacts.size() == 1;
                    if (duviri_ok)
                    {
                        const auto stock = read_text(mission_roots.corpus / duviri.at("owner").at("file").get<std::string>());
                        const auto built = read_text(duviri_build.artifacts.front().artifact);
                        duviri_ok = changed_bytes(stock, built) == 2;
                        for (const auto& site : duviri.at("owner").at("sites"))
                            duviri_ok = duviri_ok && static_cast<unsigned char>(built[site.at("offset").get<std::size_t>() + 2]) == 6;
                    }
                    check(duviri_ok, "the Duviri fracture count (two assignment sites) builds as one exact replacement");
                    const MissionSetResult flood_addon = build_mission_settings(settings({{"void_flood.fractures_per_round.shadowgrapher", 4},
                        {"void_flood.curse_count.curseCountNormal", 3}}), editor_root, mission_fixture, true);
                    bool flood_ok = flood_addon.success && flood_addon.artifacts.size() == 1 && flood_addon.artifacts.front().backend == "TARGET_ADDON";
                    if (flood_ok)
                    {
                        const auto source = read_text(flood_addon.artifacts.front().source);
                        flood_ok = contains_text(source, "owner[\"maxFractureActive\"] = 4") && contains_text(source, "owner[\"curseCountNormal\"] = 3")
                            && !contains_text(source, "curseCountSteelPath");
                    }
                    check(flood_ok, "Shadowgrapher fractures per round and a curse count build as one root-table addon");
                    const MissionSetResult purgatory = build_mission_settings(settings({{"purgatory.difficulty2.ghost_level", 12}}), editor_root,
                                                                              mission_fixture, true);
                    check(purgatory.success && purgatory.artifacts.size() == 1
                            && contains_text(read_text(purgatory.artifacts.front().source), "container = container[2]")
                            && contains_text(read_text(purgatory.artifacts.front().source), "owner[\"ghostLevel\"] = 12"),
                        "a nested root table (Purgatory difficulty 2) is reached through its container path");
                }

                // Phase 2d: a metadata control carried by two Scripts entries (gameplay + HUD) is patched in both.
                {
                    const MissionSetResult health = build_mission_settings(settings({{"coh_excavation.base_health", 3000}}), editor_root,
                                                                           mission_fixture, true);
                    bool health_ok = health.success && health.artifacts.size() == 1;
                    if (health_ok)
                    {
                        const auto text = read_text(health.artifacts.front().artifact);
                        health_ok = contains_text(text, "    q|Scripts.0.Script._baseExcavatorHealth|3000\n")
                            && contains_text(text, "    q|Scripts.1.Script._baseExcavatorHealth|3000\n");
                    }
                    check(health_ok, "a multi-entry metadata control writes every runtime Scripts entry (Scripts.0 and Scripts.1)");
                }

                Json preset_project = make_linked_overguard_project(LinkedAddonForm{});
                preset_project["id"] = "mission.descendia_excavation.selftest";
                preset_project["authoring_mode"] = "MANAGED_MISSION_EXACT_REPLACEMENT";
                preset_project["target"]["module_body_key"] = registry.at("missions").at("descendia_excavation").at("body_key");
                preset_project["target"]["module_path"] = registry.at("missions").at("descendia_excavation").at("module_path");
                preset_project["mission_profile"] = {{"build", registry.at("build")}, {"id", "descendia_excavation"}, {"values", {{"dig_duration", 15}}}};
                const BuildResult preset_build = build_staged_exact_mission_replacement(preset_project, editor_root, mission_fixture, true);
                check(preset_build.success && preset_build.generated_bytecode.filename().string()
                        == "415a57536412719f (mission_descendia_excavation_timers_exact-replacement).lua_B"
                        && fs::exists(preset_build.manifest) && preset_build.manifest.filename() == "BUILD_MANIFEST.json",
                    "an existing preset builds through the registry path with its established artifact name and manifest");
                Json stale_preset = preset_project;
                stale_preset["mission_profile"]["build"] = "2026.09.24.13.29";
                check(has_errors(validate_project(stale_preset, editor_root)), "a preset for the superseded build label fails closed");
                fs::remove_all(mission_fixture);
            }

            check(load_project(editor_root / "SCHEMA" / "ability_edit.schema.json").is_object(), "schema parses");
            check(load_project(editor_root / "EXAMPLES" / "gyre_movement_speed_addon.json").is_object(), "existing example parses");

            const fs::path catalog_fixture = fs::temp_directory_path()
                / ("renovice_ability_catalog_selftest_" + std::to_string(GetCurrentProcessId()));
            fs::remove_all(catalog_fixture);
            const fs::path metadata_package = catalog_fixture / "metadata" / "package";
            const fs::path frame_file = metadata_package / "Lotus" / "Powersuits" / "Test" / "TestBaseSuit.json";
            const fs::path ability_file = metadata_package / "Lotus" / "Powersuits" / "Test" / "Abilities" / "TestPulseAbility.json";
            const fs::path corpus_file = catalog_fixture / "corpus" / "Lotus_Powersuits_Test_Abilities_TestPulse.lua_B";
            const fs::path names_file = catalog_fixture / "Names.en.json";
            const fs::path catalog_file = catalog_fixture / "ability-catalog.json";
            write_text(frame_file, Json{
                {"parent", "/Lotus/Types/Game/PowerSuits/PlayerPowerSuit"},
                {"data", {
                    {"LocalizeTag", "/Test/Frame"},
                    {"Icon", "/Icons/TestFrame.png"},
                    {"AbilityTypes", Json::array({"Abilities/TestPulseAbility"})},
                }},
            }.dump(2));
            write_text(ability_file, Json{
                {"parent", "/Lotus/Powersuits/PowersuitAbilities/PlayerPowerSuitAbility"},
                {"data", {
                    {"LocalizeTag", "/Test/Ability"},
                    {"LocalizeDescTag", "/Test/AbilityDesc"},
                    {"UniquePowerIdentifier", "TEST_PULSE"},
                    {"Script", {{"Script", "TestPulse.lua"}, {"Function", "ActivateAbility"}}},
                }},
            }.dump(2));
            write_text(corpus_file, "abc");
            write_text(names_file, Json{{"/Test/Frame", "Test Frame"}, {"/Test/Ability", "Test Pulse"}}.dump(2));
            const CatalogBuildResult catalog_result = build_ability_catalog(
                catalog_fixture / "metadata", catalog_fixture / "corpus", catalog_file, names_file);
            check(catalog_result.success, "fixture ability catalog builds");
            check(catalog_result.warframe_count == 1 && catalog_result.ability_count == 1,
                "catalog excludes non-player noise and preserves one ability slot");
            const Json fixture_catalog = load_project(catalog_file);
            check(fixture_catalog.at("warframes").at(0).at("name") == "Test Frame", "catalog uses installed localization map");
            check(fixture_catalog.at("warframes").at(0).at("abilities").at(0).at("name") == "Test Pulse",
                "catalog resolves localized ability name");
            check(fixture_catalog.at("warframes").at(0).at("abilities").at(0).at("module_body_key")
                    == "e16801510db89efd",
                "catalog uses deployed nonstandard FNV body key");
            fs::remove_all(catalog_fixture);

            const fs::path semantic_fixture = fs::temp_directory_path()
                / ("renovice_semantic_view_selftest_" + std::to_string(GetCurrentProcessId()));
            fs::remove_all(semantic_fixture);
            const fs::path semantic_fidelity = semantic_fixture / "fixture.fidelity.luau";
            const fs::path semantic_readable = semantic_fixture / "fixture.luau";
            const fs::path semantic_names = semantic_fixture / "fixture.names.tsv";
            const fs::path semantic_calls = semantic_fixture / "fixture.calls.tsv";
            const fs::path semantic_closures = semantic_fixture / "fixture.closures.tsv";
            const fs::path semantic_output = semantic_fixture / "fixture.semantic-view.json";
            const std::string fidelity_fixture_source =
                "-- RENOVICE_HASH_FIELD: Fixture\n"
                "-- RENOVICE_DEAD_ORPHAN_PROTOTYPE_OMITTED: 7\n"
                "local v1_0\n"
                "v1_0 = function(p0_0)\n"
                "    local v0_1\n"
                "    local v0_2\n"
                "    local v0_3\n"
                "    v0_1 = p0_0\n"
                "    v0_2 = \"v0_1\" -- v0_1 remains literal text\n"
                "    if p0_0 then\n"
                "        v0_3 = v0_1:IsKilled()\n"
                "    else\n"
                "        v0_3 = v0_1:IsKilled()\n"
                "    end\n"
                "    return v0_1\n"
                "end\n"
                "ActivateAbility = v1_0\n";
            const std::string readable_fixture_source =
                "-- RENOVICE_HASH_FIELD: Fixture\n"
                "-- RENOVICE_READABLE_VIEW_V1\n"
                "-- Identifier aliases are evidence-backed presentation only. Use the fidelity twin and TSV sidecar for exact provenance.\n"
                "-- RENOVICE_DEAD_ORPHAN_PROTOTYPE_OMITTED: 7\n"
                "local activateAbilityFunction\n"
                "activateAbilityFunction = function(avatar)\n"
                "    local result\n"
                "    local label\n"
                "    local isKilled\n"
                "    result = avatar\n"
                "    label = \"v0_1\" -- v0_1 remains literal text\n"
                "    if avatar then\n"
                "        isKilled = result:IsKilled()\n"
                "    else\n"
                "        isKilled = result:IsKilled()\n"
                "    end\n"
                "    return result\n"
                "end\n"
                "ActivateAbility = activateAbilityFunction\n";
            const std::string semantic_names_text =
                "prototype\tweb\tcanonical\treadable\tconfidence\tevidence\tsemantic_type\ttype_confidence\ttype_evidence\n"
                "1\t0\tv1_0\tactivateAbilityFunction\tEXACT_EXPORT\tglobal store ActivateAbility\tFunction\tEXACT_EXPORT\tglobal store ActivateAbility\n"
                "0\t0\tp0_0\tavatar\tSTRUCTURAL\tfunction parameter 0\t\t\t\n"
                "0\t1\tv0_1\tresult\tSTRUCTURAL\treturn value\t\t\t\n"
                "0\t2\tv0_2\tlabel\tSTRUCTURAL\tliteral holder\tstring\tSTRUCTURAL\tstring assignment\n"
                "0\t3\tv0_3\tisKilled\tAPI_RETURN\tlua:method:AvatarOrEntity:IsKilled result 0\tboolean\tAPI_CONTRACT\tlua:method:AvatarOrEntity:IsKilled return 0\n";
            const std::string semantic_closures_text =
                "parent_proto\tinstruction\top\tdestination_register\toperand_namespace\toperand_index\ttarget_proto\ttarget_params\ttarget_upvalues\ttarget_maxstack\tcapture_count\tcaptures\tstatus\n"
                "1\t1\tNEWCLOSURE\t0\tchild\t0\t0\t1\t0\t2\t0\t\tPASS\n";
            const auto replace_once = [](std::string value, const std::string& before, const std::string& after)
            {
                const std::size_t position = value.find(before);
                if (position == std::string::npos)
                    throw std::runtime_error("semantic self-test replacement anchor is missing");
                value.replace(position, before.size(), after);
                return value;
            };
            const auto span_fields = [](
                const std::string& source,
                const std::string& call,
                const std::size_t occurrence)
            {
                std::size_t offset = 0;
                for (std::size_t index = 0; index <= occurrence; ++index)
                {
                    offset = source.find(call, index == 0 ? 0 : offset + call.size());
                    if (offset == std::string::npos)
                        throw std::runtime_error("semantic self-test call anchor is missing");
                }
                if (offset == std::string::npos)
                    throw std::runtime_error("semantic self-test call anchor is missing");
                std::size_t line = 1;
                std::size_t column = 1;
                for (std::size_t index = 0; index < offset; ++index)
                {
                    if (source[index] == '\n')
                    {
                        ++line;
                        column = 1;
                    }
                    else ++column;
                }
                return std::to_string(offset) + "\t" + std::to_string(call.size()) + "\t"
                    + std::to_string(line) + "\t" + std::to_string(column);
            };
            const std::string semantic_calls_text =
                "schema_version\tprototype\tblock\tinstruction\tsource_occurrence\teffect_order\tkind\tname\tname_hash\tcallee_web\treceiver_web\treceiver_type\treceiver_type_confidence\treceiver_type_evidence\tdescriptor_join\targument_webs\texplicit_argument_count\topen_arguments\tresult_webs\tresult_count\topen_results\tdescriptor\tcontract_confidence\tcontract_status\tevidence\tparameters\treturns\tcontract_match\treadable_offset\treadable_length\treadable_line\treadable_column\tfidelity_offset\tfidelity_length\tfidelity_line\tfidelity_column\n"
                "2\t0\t0\t5\t0\t0\tmethod\tIsKilled\t\t-1\t1\tAvatarOrEntity\tSTOCK_BYTECODE\tself-test receiver evidence\tRECEIVER_TYPE\t\t0\tfalse\t3\t1\tfalse\tlua:method:AvatarOrEntity:IsKilled\tSTOCK_BYTECODE\tCONFIRMED\tself-test fixture\t\tboolean\tMATCH\t"
                + span_fields(readable_fixture_source, "result:IsKilled()", 0) + "\t"
                + span_fields(fidelity_fixture_source, "v0_1:IsKilled()", 0) + "\n"
                "2\t0\t0\t5\t1\t0\tmethod\tIsKilled\t\t-1\t1\tAvatarOrEntity\tSTOCK_BYTECODE\tself-test receiver evidence\tRECEIVER_TYPE\t\t0\tfalse\t3\t1\tfalse\tlua:method:AvatarOrEntity:IsKilled\tSTOCK_BYTECODE\tCONFIRMED\tself-test fixture\t\tboolean\tMATCH\t"
                + span_fields(readable_fixture_source, "result:IsKilled()", 1) + "\t"
                + span_fields(fidelity_fixture_source, "v0_1:IsKilled()", 1) + "\n";
            write_text(semantic_fidelity, fidelity_fixture_source);
            write_text(semantic_readable, readable_fixture_source);
            write_text(semantic_names, semantic_names_text);
            write_text(semantic_calls, semantic_calls_text);
            write_text(semantic_closures, semantic_closures_text);
            const SemanticViewBuildResult semantic_result = build_semantic_view(
                semantic_readable,
                semantic_fidelity,
                semantic_names,
                semantic_calls,
                semantic_closures,
                semantic_output);
            check(semantic_result.success, "identity-authorized semantic view builds");
            const Json semantic_document = load_project(semantic_output);
            check(
                semantic_document.at("status") == "VERIFIED_PRESENTATION_ONLY"
                    && semantic_document.at("verification").at("unauthorized_identifier_differences") == 0
                    && semantic_document.at("verification").at("non_identifier_differences") == 0,
                "semantic view records zero unauthorized transformations");
            check(
                semantic_result.api_callsite_count == 1
                    && semantic_result.api_call_expression_count == 2
                    && semantic_result.confirmed_api_callsite_count == 1
                    && semantic_document.at("callsites").size() == 2
                    && semantic_document.at("callsites").at(0).at("identity").at("source_occurrence") == 0
                    && semantic_document.at("callsites").at(1).at("identity").at("source_occurrence") == 1
                    && semantic_document.at("callsites").at(0).at("contract").at("match") == "MATCH",
                "semantic view counts one bytecode call and preserves both exact source projections");
            check(
                semantic_result.export_count == 1
                    && semantic_document.at("exports").at(0).at("exported_name") == "ActivateAbility",
                "semantic view retains exact export evidence");
            check(
                semantic_document.at("verification").at("authorized_fixed_comment_insertions") == 2,
                "semantic view permits only the exact fixed readable preamble");
            check(
                semantic_result.omitted_dead_orphan_prototype_count == 1
                    && semantic_document.at("verification").at("omitted_dead_orphan_prototype_count") == 1
                    && semantic_document.at("omitted_dead_orphan_prototypes").at(0) == 7,
                "semantic view records matched dead-orphan prototype evidence");
            const std::string first_semantic_document = read_text(semantic_output);
            const SemanticViewBuildResult repeated_semantic_result = build_semantic_view(
                semantic_readable,
                semantic_fidelity,
                semantic_names,
                semantic_calls,
                semantic_closures,
                semantic_output);
            check(
                repeated_semantic_result.success
                    && first_semantic_document == read_text(semantic_output),
                "semantic view is deterministic");

            write_text(
                semantic_readable,
                replace_once(
                    readable_fixture_source,
                    "RENOVICE_DEAD_ORPHAN_PROTOTYPE_OMITTED: 7",
                    "RENOVICE_DEAD_ORPHAN_PROTOTYPE_OMITTED: 8"));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects mismatched dead-orphan prototype evidence");

            write_text(
                semantic_readable,
                replace_once(readable_fixture_source, "return result", "return invented"));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects an unauthorized identifier");
            write_text(
                semantic_readable,
                replace_once(readable_fixture_source, "return result", "return (result)"));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects a non-identifier source transform");
            write_text(
                semantic_readable,
                replace_once(readable_fixture_source, "\"v0_1\"", "\"result\""));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects a string-literal change");
            write_text(
                semantic_readable,
                replace_once(readable_fixture_source, "RENOVICE_READABLE_VIEW_V1", "RENOVICE_READABLE_VIEW_V2"));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects an altered readable preamble");
            write_text(semantic_readable, readable_fixture_source);
            write_text(
                semantic_names,
                replace_once(semantic_names_text, "\tresult\tSTRUCTURAL", "\tend\tSTRUCTURAL"));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects a reserved-word alias");
            write_text(semantic_names, semantic_names_text);
            write_text(
                semantic_closures,
                replace_once(semantic_closures_text, "\tPASS\n", "\tFAIL\n"));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects unproven closure ownership");
            write_text(semantic_closures, semantic_closures_text);
            write_text(
                semantic_calls,
                replace_once(semantic_calls_text, "\tMATCH\t", "\tCONFIRMED_MISMATCH\t"));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects a confirmed API contract mismatch");
            write_text(
                semantic_calls,
                replace_once(
                    semantic_calls_text,
                    "2\t0\t0\t5\t1\t0\tmethod",
                    "2\t0\t0\t5\t2\t0\tmethod"));
            check(
                !build_semantic_view(
                    semantic_readable,
                    semantic_fidelity,
                    semantic_names,
                    semantic_calls,
                    semantic_closures,
                    semantic_output).success,
                "semantic view rejects non-contiguous callsite source occurrences");
            fs::remove_all(semantic_fixture);

            Json replacement = project;
            replacement["authoring_mode"] = "NATIVE_REPLACEMENT";
            replacement["effect"]["owner"] = "NATIVE_MODULE";
            replacement["deployment"]["requires_addon"] = false;
            replacement["deployment"]["requires_card_extension"] = false;
            replacement["deployment"]["requires_native_module"] = true;
            const fs::path replacement_fixture =
                fs::temp_directory_path() / "renovice_ability_editor_replacement_selftest.luau";
            write_text(replacement_fixture, "local answer = 42\nreturn answer\n");
            check(
                !has_errors(validate_replacement_project(replacement, replacement_fixture)),
                "valid native replacement project");

            Json wrong_replacement_owner = replacement;
            wrong_replacement_owner["effect"]["owner"] = "ADDON";
            check(
                has_errors(validate_replacement_project(wrong_replacement_owner, replacement_fixture)),
                "replacement rejects addon owner");
            check(
                has_errors(validate_replacement_project(replacement, replacement_fixture.string() + ".missing")),
                "replacement rejects missing source");
            fs::remove(replacement_fixture);

            const fs::path deployment_fixture = fs::temp_directory_path()
                / ("renovice_ability_editor_deploy_selftest_" + std::to_string(GetCurrentProcessId()));
            fs::remove_all(deployment_fixture);
            const fs::path generation = deployment_fixture / "generation";
            const fs::path artifact = generation / "artifacts" / "test.lua_B";
            const fs::path build_manifest = generation / "BUILD_MANIFEST.json";
            const fs::path game_root = deployment_fixture / "game";
            const fs::path live_target = game_root / "OpenWF" / "CustomScripts" / "test.lua_B";
            write_text(artifact, "new-bytecode");
            write_text(live_target, "old-bytecode");
            Json deployable{
                {"format", "RENOVICE_ABILITY_EDITOR_BUILD_V1"},
                {"status", "STAGED_PASS"},
                {"artifact", {
                    {"path", "artifacts/test.lua_B"},
                    {"sha256", sha256_file(artifact)},
                    {"size", fs::file_size(artifact)},
                }},
                {"intended_live_relative_path", "OpenWF/CustomScripts/test.lua_B"},
                {"live_write_performed", false},
            };
            write_text(build_manifest, deployable.dump(2) + "\n");
            const DeploymentResult deployed = deploy_staged_build(build_manifest, game_root);
            check(deployed.success, "sandbox deployment succeeds");
            check(read_text(live_target) == "new-bytecode", "sandbox deployment writes verified artifact");
            check(fs::exists(deployed.deployment_manifest), "deployment writes rollback manifest");
            const DeploymentResult rolled_back = rollback_deployment(deployed.deployment_manifest);
            check(rolled_back.success, "sandbox rollback succeeds");
            check(read_text(live_target) == "old-bytecode", "sandbox rollback restores exact previous file");

            const fs::path absent_generation = deployment_fixture / "absent-generation";
            const fs::path absent_artifact = absent_generation / "artifacts" / "new.lua_B";
            const fs::path absent_manifest = absent_generation / "BUILD_MANIFEST.json";
            const fs::path absent_target = game_root / "OpenWF" / "CustomScripts" / "new.lua_B";
            write_text(absent_artifact, "created-bytecode");
            deployable["artifact"]["path"] = "artifacts/new.lua_B";
            deployable["artifact"]["sha256"] = sha256_file(absent_artifact);
            deployable["artifact"]["size"] = fs::file_size(absent_artifact);
            deployable["intended_live_relative_path"] = "OpenWF/CustomScripts/new.lua_B";
            write_text(absent_manifest, deployable.dump(2) + "\n");
            const DeploymentResult created = deploy_staged_build(absent_manifest, game_root);
            check(created.success && fs::exists(absent_target), "deployment records originally absent target");
            const DeploymentResult removed = rollback_deployment(created.deployment_manifest);
            check(removed.success && !fs::exists(absent_target), "rollback removes newly introduced target");
            fs::remove_all(deployment_fixture);
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
