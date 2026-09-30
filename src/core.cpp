#include "renovice/core.hpp"
#include "renovice/live_literal_patch_core.hpp"

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
                // Target addons act only through hook binding renovice.target.lua_call. While it is not LIVE_CONFIRMED the
                // automatic lane refuses addon-only rows (NEEDS_BINDING); the addon generator itself is exercised through
                // the explicit live-acceptance opt-in.
                const auto probe_settings = [&](const Json& values) {
                    Json value = settings(values);
                    value["allow_unproven_hook_bindings"] = Json::array({"renovice.target.lua_call"});
                    return value;
                };
                const auto site_of = [&](const std::string& id, const std::size_t index) -> const Json& {
                    return mission_tunable(registry, id).at("owner").at("sites").at(index);
                };
                const auto changed_bytes = [](const std::string& left, const std::string& right) {
                    std::size_t changed = left.size() == right.size() ? 0 : std::string::npos;
                    for (std::size_t n = 0; changed != std::string::npos && n < left.size(); ++n) changed += left[n] != right[n] ? 1 : 0;
                    return changed;
                };
                // Phase 2g multi-target source: the value lives once in the entry's settings table and the field names it.
                const auto writes_field = [](const std::string& source, const std::string& id, const std::string& key, const std::string& value) {
                    return contains_text(source, "[\"" + id + "\"] = { value = " + value + ",")
                        && contains_text(source, "{ key = \"" + key + "\", setting = \"" + id + "\" }");
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
                const MissionSetResult cascade_default = build_mission_settings(
                    settings({{"void_cascade.pillar_duration", 45}, {"void_cascade.alert_reward_interval", 5}}), editor_root, mission_fixture, true);
                check(cascade_default.success && cascade_default.artifacts.size() == 1 && cascade_default.artifacts.front().backend == "EXACT_LITERAL"
                        && cascade_default.artifacts.front().tunables.size() == 2,
                    "while renovice.target.lua_call is not LIVE_CONFIRMED, rows with an exact literal form build as one exact replacement");
                const MissionSetResult cascade = build_mission_settings(
                    probe_settings({{"void_cascade.pillar_duration", 45}, {"void_cascade.alert_reward_interval", 5}}), editor_root, mission_fixture, true);
                bool cascade_ok = cascade.success && cascade.artifacts.size() == 1 && cascade.artifacts.front().target_keys == std::vector<std::string>{"32c344afa33be174"}
                    && cascade.artifacts.front().backend == "TARGET_ADDON"
                    && mission_tunable(registry, "void_cascade.pillar_duration").contains("literal_owner");
                if (cascade_ok)
                {
                    const auto source = read_text(cascade.artifacts.front().source);
                    cascade_ok = writes_field(source, "void_cascade.pillar_duration", "PILLAR_DURATION", "45")
                        && writes_field(source, "void_cascade.pillar_duration", "PILLAR_DURATION_CIRCLE", "45")
                        && writes_field(source, "void_cascade.alert_reward_interval", "ALERT_REWARD_INTERVAL", "5");
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

                const MissionSetResult mixed = build_mission_settings(probe_settings({
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

                const MissionNaming group_naming{"missions-selftest", "missions", "missions", "RENOVICE_Missions.txt", false, "", {}};
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
                fake["ui"]["group"] = "excavation";  // Phase 2i: a row's ui group is its tunable_id family, labels unique per group
                fake["ui"]["short_label"] = "Self-test addon row";
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
                        const MissionSetResult built = build_mission_settings(probe_settings(values), editor_root, mission_fixture, true);
                        return built.success && built.artifacts.size() == 1 && built.artifacts.front().backend == "TARGET_ADDON"
                            ? read_text(built.artifacts.front().source) : std::string();
                    };
                    const auto interval_source = source_of(Json{{"survival.reward_interval", 150}});
                    const auto kill_source = source_of(Json{{"survival.player_damage_at_zero_ls.killPlayerTime", 200}});
                    check(interval.at("stock") == 300 && kill.at("stock") == 300 && kill.at("backend") == "TARGET_ADDON"
                            && writes_field(interval_source, "survival.reward_interval", "interval", "150") && !contains_text(interval_source, "killPlayerTime")
                            && !contains_text(interval_source, "alertInterval") && contains_text(interval_source, "[67] = { before = before67 }")
                            && writes_field(kill_source, "survival.player_damage_at_zero_ls.killPlayerTime", "killPlayerTime", "200")
                            && !contains_text(kill_source, "\"interval\""),
                        "shared-constant root-table fields build as independent addon controls (interval 150 leaves killPlayerTime unchanged)");
                    // 2026-09-29 live failure: the addon attached but no before-hook ran. Default settings must not stage it.
                    const MissionSetResult unproven = build_mission_settings(settings(Json{{"survival.reward_interval", 150}}), editor_root,
                                                                             mission_fixture, true);
                    check(!unproven.success && unproven.artifacts.empty() && !unproven.diagnostics.empty()
                            && contains_text(unproven.diagnostics.front().message, "NEEDS_BINDING")
                            && contains_text(unproven.diagnostics.front().message, "survival.reward_interval")
                            && contains_text(unproven.diagnostics.front().message, "renovice.target.lua_call")
                            && contains_text(unproven.diagnostics.front().message, "OFFLINE_VERIFIED"),
                        "an addon-only row fails closed with NEEDS_BINDING while renovice.target.lua_call is not LIVE_CONFIRMED");
                    const MissionSetResult probe = build_mission_settings(probe_settings(Json{{"survival.reward_interval", 150}}), editor_root,
                                                                          mission_fixture, true);
                    bool probe_ok = probe.success && probe.artifacts.size() == 1 && probe.artifacts.front().backend == "TARGET_ADDON"
                        && std::any_of(probe.diagnostics.begin(), probe.diagnostics.end(),
                                       [](const Diagnostic& d) { return d.severity == Severity::warning && d.code == "HOOK_UNPROVEN"; });
                    if (probe_ok)
                    {
                        const Json manifest = Json::parse(read_text(probe.artifacts.front().manifest));
                        const Json set = Json::parse(read_text(probe.manifest));
                        probe_ok = manifest.at("runtime_hook").at("binding") == "renovice.target.lua_call"
                            && manifest.at("runtime_hook").at("registry_status") == "OFFLINE_VERIFIED"
                            && manifest.at("runtime_hook").at("live_confirmed") == false
                            && manifest.at("runtime_hook").at("built_by_explicit_opt_in") == true
                            && set.at("artifacts").at(0).at("runtime_hook") == manifest.at("runtime_hook")
                            && set.at("allow_unproven_hook_bindings") == Json::array({"renovice.target.lua_call"});
                    }
                    check(probe_ok, "the explicit live-acceptance opt-in stages the addon, warns HOOK_UNPROVEN and records the binding status");
                    Json unknown_binding = settings(Json{{"survival.reward_interval", 150}});
                    unknown_binding["allow_unproven_hook_bindings"] = Json::array({"renovice.target.not_a_binding"});
                    const MissionSetResult rejected_binding = build_mission_settings(unknown_binding, editor_root, mission_fixture, true);
                    check(!rejected_binding.success && !rejected_binding.diagnostics.empty()
                            && contains_text(rejected_binding.diagnostics.front().message, "unregistered hook binding"),
                        "an opt-in that names an unregistered hook binding fails closed");
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
                    const MissionSetResult flood_addon = build_mission_settings(probe_settings({{"void_flood.fractures_per_round.shadowgrapher", 4},
                        {"void_flood.curse_count.curseCountNormal", 3}}), editor_root, mission_fixture, true);
                    bool flood_ok = flood_addon.success && flood_addon.artifacts.size() == 1 && flood_addon.artifacts.front().backend == "TARGET_ADDON";
                    if (flood_ok)
                    {
                        const auto source = read_text(flood_addon.artifacts.front().source);
                        flood_ok = writes_field(source, "void_flood.fractures_per_round.shadowgrapher", "maxFractureActive", "4")
                            && writes_field(source, "void_flood.curse_count.curseCountNormal", "curseCountNormal", "3")
                            && !contains_text(source, "curseCountSteelPath");
                    }
                    check(flood_ok, "Shadowgrapher fractures per round and a curse count build as one root-table addon");
                    const MissionSetResult purgatory = build_mission_settings(probe_settings({{"purgatory.difficulty2.ghost_level", 12}}), editor_root,
                                                                              mission_fixture, true);
                    check(purgatory.success && purgatory.artifacts.size() == 1
                            && contains_text(read_text(purgatory.artifacts.front().source), "container = container[2]")
                            && writes_field(read_text(purgatory.artifacts.front().source), "purgatory.difficulty2.ghost_level", "ghostLevel", "12"),
                        "a nested root table (Purgatory difficulty 2) is reached through its container path");
                }

                // Phase 2i: registry ui fields (row budget, unique labels per group, lane-derived apply timing, editor rule).
                {
                    const auto rejects_ui = [&](const std::function<void(Json&)>& mutate, const std::string& needle) {
                        Json bad = registry;
                        mutate(bad);
                        try { verify_mission_registry_structure(bad); } catch (const std::exception& e) { return contains_text(e.what(), needle); }
                        return false;
                    };
                    const auto ui_of = [](Json& r, const std::string& id) -> Json& {
                        for (auto& row : r["tunables"]) if (row["tunable_id"] == id) return row["ui"];
                        throw std::runtime_error("no row " + id);
                    };
                    bool ui_ok = true;
                    try { verify_mission_registry_structure(registry); } catch (const std::exception&) { ui_ok = false; }
                    check(ui_ok
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["short_label"] = std::string(34, 'A'); }, "row budget")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["short_label"] =
                                                             ui_of(r, "survival.pickup_time_added")["short_label"]; }, "not unique in its mission section")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["short_label"] =
                                                             ui_of(r, "survival.capsule_interval")["short_label"]; }, "not unique in its mission section")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["applies"] = "next_mission"; }, "lane/applies")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["editor"] = "INPUTCOUNT"; }, "float value editor")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["max"] = 1; }, "min/max")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["group"] = "defense"; }, "family")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["scope_text"] = std::string(257, 'a'); }, "scope_text")
                            && rejects_ui([&](Json& r) { r["ui_groups"]["survival"]["label"] = std::string(41, 'A'); }, "over its budget"),
                          "registry ui fields: every row fits the 40-character row budget with a label unique in its mission section, "
                          "and the apply timing, editor and min/max agree with the lane and limits");
                    // Contract R5: player-text gates (labels, abbreviations, code identifiers, stock + unit in the description,
                    // rendered tooltip <= 300), Advanced subsections and master knobs.
                    const auto master_of = [](Json& r, const std::string& id) -> Json& { return r["ui_masters"][id]; };
                    bool ui_r5 = registry.contains("ui_masters") && registry.contains("ui_player_text")
                        && registry.at("ui_groups").contains("survival_advanced")
                        && registry.at("ui_groups").at("survival_advanced").at("advanced_of") == "survival"
                        && mission_tunable(registry, "survival.alert_ls_drop_mult").at("ui").at("group") == "survival_advanced"
                        && mission_tunable(registry, "survival.alert_ls_drop_mult").at("ui").at("short_label") == "Alert missions: pickup drop rate"
                        && mission_tunable(registry, "fivefates.state_times_sp.state1").at("ui").contains("hidden");
                    check(ui_r5
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["short_label"] = "LS reward time"; }, "abbreviation")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["short_label"] = "Max sim. enemies"; }, "abbreviation")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["short_label"] = "Reward mult"; }, "abbreviation")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["short_label"] = "Reward interval (1P)"; }, "abbreviation")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["short_label"] = "rewardInterval"; }, "code identifier")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["scope_text"] = "Seconds per reward rotation"; }, "stock value")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["scope_text"] = "Seconds per reward; stock 300 minutes"; },
                                          "followed by its unit")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["scope_text"] = std::string(140, 'a') + "; stock 300 s"; },
                                          "rendered tooltip")
                            && rejects_ui([&](Json& r) { ui_of(r, "survival.reward_interval")["group"] = "defense_advanced"; }, "family")
                            && rejects_ui([&](Json& r) { r["ui_groups"]["survival_advanced"]["order"] = 1; }, "Advanced subsection")
                            && rejects_ui([&](Json& r) { master_of(r, "loopdefend.max_enemies.p1")["drives"][0]["scale"] = 1.5; }, "whole")
                            && rejects_ui([&](Json& r) { master_of(r, "loopdefend.max_enemies.p1")["stock"] = 17; }, "first driven row")
                            && rejects_ui([&](Json& r) { master_of(r, "loopdefend.max_enemies.p1")["drives"].push_back(
                                                             {{"tunable_id", "survival.reward_interval"}, {"scale", 1}}); }, "is not a addon row of module")
                            && rejects_ui([&](Json& r) { master_of(r, "loopdefend.max_enemies.p2")["drives"].push_back(
                                                             {{"tunable_id", "loopdefend.enemy_counts.maxNum.p1"}, {"scale", 1}}); }, "already driven")
                            && rejects_ui([&](Json& r) { r["ui_masters"]["survival.reward_interval"] = master_of(r, "orphix.spawn_interval"); }, "collides")
                            && rejects_ui([&](Json& r) { r["ui_player_text"]["banned_abbreviations"] = Json::array({"LS"}); }, "banned-abbreviation"),
                          "R5 player text: labels <= 33 without unexplained abbreviations or code identifiers, descriptions that state "
                          "stock and unit, tooltips <= 300, Advanced subsections after their section, and master knobs (whole scales for "
                          "int, stock from the first row, one module and lane, each row driven once, ids distinct from rows)");
                }

                // Phase 2g: a settings build emits ONE multi-target addon (Inject\Missions.targets.addon.lua_B) for every
                // addon-lane body key; exact replacements stay separate files. Gate: exact declared keys in the compiled string
                // pool, no stray lowercase 16-hex text, no top-level hooks, and per-instance binding executed under luau.exe.
                {
                    const Json values{{"survival.reward_interval", 150}, {"purgatory.difficulty1.warrior_level", 15},
                                      {"lantern.tier_up_interval", 60}, {"void_flood.fractures_per_round.normal", 4}};
                    const std::set<std::string> expected_keys{"6fa60841c9e0f207", "caec63d8e739b693", "f10a043e7f825db2"};
                    const MissionSetResult unified = build_mission_settings(probe_settings(values), editor_root, mission_fixture, true);
                    const MissionArtifact* multi = nullptr;
                    std::size_t addon_count = 0, replacement_count = 0;
                    for (const auto& item : unified.artifacts)
                    {
                        if (item.backend == "TARGET_ADDON") { ++addon_count; multi = &item; }
                        if (item.backend == "EXACT_LITERAL") ++replacement_count;
                    }
                    bool unified_ok = unified.success && addon_count == 1 && replacement_count == 1 && multi != nullptr
                        && multi->artifact.filename() == "Missions.targets.addon.lua_B" && multi->body_key == "multi-target"
                        && std::set<std::string>(multi->target_keys.begin(), multi->target_keys.end()) == expected_keys
                        && multi->intended_live_relative_path == "OpenWF/CustomScripts/Inject/Missions.targets.addon.lua_B";
                    std::string unified_source;
                    if (unified_ok)
                    {
                        unified_source = read_text(multi->source);
                        const Json manifest = Json::parse(read_text(multi->manifest));
                        std::set<std::string> superseded;
                        for (const auto& target : manifest.at("targets")) superseded.insert(target.at("supersedes").get<std::string>());
                        const auto tail = unified_source.substr(unified_source.rfind("\nreturn {\n"));
                        unified_ok = multi_target_declared_keys(read_text(multi->artifact)) == expected_keys
                            && multi_target_stray_hex(unified_source, expected_keys).empty()
                            && contains_text(tail, "    targets = {\n") && !contains_text(tail, "hooks")
                            && !contains_text(unified_source, "owner changed")
                            && contains_text(unified_source, "setmetatable({}, { __mode = \"k\" })")
                            && manifest.at("scripts_menu").at("policy_id") == "target-addon:missions.targets.addon.lua_b"
                            && manifest.at("runtime_hook").at("built_by_explicit_opt_in") == true
                            && !manifest.contains("stock_artifact") && manifest.at("targets").size() == 3
                            && superseded == std::set<std::string>{"6fa60841c9e0f207.missions.target.addon.lua_B",
                                                                   "caec63d8e739b693.missions.target.addon.lua_B",
                                                                   "f10a043e7f825db2.missions.target.addon.lua_B"}
                            && contains_text(unified.gate_log, "multi-target-declared-keys\nPASS declared=3 expected=3");
                    }
                    check(unified_ok, "addon rows of three modules build ONE Missions.targets.addon.lua_B (compiled pool declares exactly their "
                                      "keys, no top-level hooks, no owner-changed assert); the Void Flood replacement stays separate");

                    // Optional folder package layout (bootstrapper feat/script-packages-2026-09-29): the same Lua artifacts,
                    // byte for byte, in Packages\Missions\ with a strict package.json; one [PACKAGE] Missions row.
                    {
                        Json packaged_settings = probe_settings(values);
                        packaged_settings["output_layout"] = "package";
                        const MissionSetResult packaged = build_mission_settings(packaged_settings, editor_root, mission_fixture, true);
                        bool package_ok = packaged.success && unified.success && !packaged.package_directory.empty()
                            && packaged.package_directory.filename() == "Missions"
                            && packaged.package_directory.parent_path().filename() == "Packages"
                            && packaged.directory != unified.directory;
                        std::set<std::string> files;
                        if (package_ok)
                            for (const auto& entry : fs::directory_iterator(packaged.package_directory)) files.insert(entry.path().filename().string());
                        package_ok = package_ok
                            && files == std::set<std::string>{"package.json", "Missions.targets.addon.lua_B",
                                                              "fc711ff621a75552 (missions_exact-replacement).lua_B"};
                        if (package_ok)
                        {
                            const Json package_json = Json::parse(read_text(packaged.package_directory / "package.json"));
                            const Json set_manifest = Json::parse(read_text(packaged.manifest));
                            std::map<std::string, std::string> loose_hashes;
                            for (const auto& item : unified.artifacts) loose_hashes[item.artifact.filename().string()] = item.sha256;
                            const Json& addon_values = package_json.at("members").at("Missions.targets.addon.lua_B").at("settings").at("values");
                            const Json& flood_values = package_json.at("members").at("fc711ff621a75552 (missions_exact-replacement).lua_B")
                                                           .at("settings").at("values");
                            std::set<std::string> group_ids;
                            for (const auto& group : package_json.at("settings").at("groups")) group_ids.insert(group.at("id").get<std::string>());
                            const fs::path migration_path = packaged.directory / "Settings" / "Missions.json";
                            const Json migration = fs::exists(migration_path) ? Json::parse(read_text(migration_path)) : Json();
                            package_ok = package_json.at("schema") == 1 && package_json.at("name") == "Missions"
                                && package_json.at("settings").at("format") == "RENOVICE_SETTINGS_DECL_V1"
                                && package_json.at("settings").at("build") == registry.at("build")
                                && group_ids == std::set<std::string>{"lantern", "purgatory_advanced", "survival", "void_flood"}
                                && validate_settings_declarations(package_json).empty()
                                && addon_values.size() == 3 && flood_values.size() == 1
                                && addon_values.at("survival.reward_interval") == mission_value_declaration(mission_tunable(registry, "survival.reward_interval"))
                                && addon_values.at("survival.reward_interval").at("stock") == 300
                                && addon_values.at("survival.reward_interval").at("lane") == "addon"
                                && addon_values.at("survival.reward_interval").at("applies") == "live_next_read"
                                && flood_values.at("void_flood.fractures_per_round.normal").at("lane") == "literal"
                                && flood_values.at("void_flood.fractures_per_round.normal").at("applies") == "next_mission"
                                && flood_values.at("void_flood.fractures_per_round.normal").at("stock") == 3
                                && migration.is_object() && migration.at("format") == "RENOVICE_SCRIPT_SETTINGS_V1"
                                && migration.at("package") == "package:missions" && migration.at("use_stock") == false
                                && migration.at("values").size() == 4
                                && migration.at("values").at("survival.reward_interval") == Json{{"enabled", true}, {"value", 150}}
                                && migration.at("values").at("purgatory.difficulty1.warrior_level") == Json{{"enabled", true}, {"value", 15}}
                                && set_manifest.at("package").at("settings").at("migration").at("intended_live_relative_path")
                                       == "OpenWF/CustomScripts/Settings/Missions.json"
                                && contains_text(packaged.gate_log, "settings-declarations\nPASS values=4 groups=4")
                                && package_json.at("members").size() == 2
                                && package_json.at("members").contains("Missions.targets.addon.lua_B")
                                && package_json.at("members").at("Missions.targets.addon.lua_B").at("label")
                                       == "Values: Lantern, Purgatory, Survival"
                                && package_json.at("members").at("fc711ff621a75552 (missions_exact-replacement).lua_B").at("label")
                                       == "Void Flood (script replacement)"
                                && [&]() {
                                       // The technical detail moved from the 40-character row label to the manifest record.
                                       std::set<std::string> details;
                                       for (const auto& member : set_manifest.at("package").at("members"))
                                           details.insert(member.value("detail", std::string()));
                                       return details == std::set<std::string>{
                                                  "Mission tunables: Purgatory, HalloweenLanternEndless, SurvivalMission",
                                                  "Exact replacement: ZarimanCorruptionMission (void_flood.fractures_per_round.normal)"};
                                   }()
                                && set_manifest.at("output_layout") == "package"
                                && set_manifest.at("package").at("scripts_menu").at("policy_id") == "package:missions"
                                && set_manifest.at("package").at("scripts_menu").at("row") == "[PACKAGE] Missions"
                                && !Json::parse(read_text(unified.manifest)).contains("package")
                                && contains_text(packaged.gate_log, "package-folder\nPASS members=2");
                            for (const auto& item : packaged.artifacts)
                            {
                                if (item.backend != "TARGET_ADDON" && item.backend != "EXACT_LITERAL") continue;
                                const auto file = item.artifact.filename().string();
                                package_ok = package_ok
                                    && sha256_file(packaged.package_directory / file) == item.sha256
                                    && loose_hashes[file] == item.sha256
                                    && item.intended_live_relative_path == "OpenWF/CustomScripts/Packages/Missions/" + file;
                            }
                        }
                        check(package_ok, "output_layout \"package\" emits Packages\\Missions\\ (package.json + the byte-identical addon and "
                                          "replacement, one [PACKAGE] Missions row, policy package:missions) with one RENOVICE_SETTINGS_DECL_V1 "
                                          "declaration per member tunable, the Settings\\Missions.json migration file and a PASS "
                                          "settings-declarations gate; the loose build is unchanged");
                        {
                            // Member row labels (SCRIPT SETTINGS, 40 characters): many sections fall back to a count; a
                            // replacement label is unique; every candidate is within the row budget.
                            std::vector<std::string> many, one_group;
                            std::set<std::string> seen_groups;
                            for (const auto& row : registry.at("tunables")) {
                                const auto group = section_family(row.at("ui").at("group").get<std::string>());
                                if (row.at("backend") == "TARGET_ADDON" && seen_groups.insert(group).second)
                                    many.push_back(row.at("tunable_id").get<std::string>());
                            }
                            one_group.push_back("void_flood.fractures_per_round.normal");
                            const auto wide = package_member_label(registry, "TARGET_ADDON", many, "Missions.targets.addon.lua_B", {});
                            const auto first = package_member_label(registry, "EXACT_LITERAL", one_group, "fc711ff621a75552", {});
                            const auto second = package_member_label(registry, "EXACT_LITERAL", one_group, "0123456789abcdef",
                                                                     {ascii_lower_text(first)});
                            check(many.size() > 3 && wide == "Mission values: " + std::to_string(many.size()) + " sections"
                                      && first == "Void Flood (script replacement)" && second == "Void Flood replacement"
                                      && wide.size() <= 40 && second.size() <= 40,
                                  "package member labels fit the 40-character SCRIPT SETTINGS row: section list, count fallback, "
                                  "unique replacement label");
                        }

                        // Phase 2i: the declaration schema check rejects every malformed shape the runtime parser must reject.
                        if (package_ok)
                        {
                            const Json good = Json::parse(read_text(packaged.package_directory / "package.json"));
                            const std::string addon_file = "Missions.targets.addon.lua_B";
                            const auto rejects = [&](const std::function<void(Json&)>& mutate, const std::string& needle) {
                                Json bad = good;
                                mutate(bad);
                                const auto problems = validate_settings_declarations(bad);
                                std::string joined;
                                for (const auto& problem : problems) joined += problem + "; ";
                                return !problems.empty() && contains_text(joined, needle);
                            };
                            const auto value = [&](Json& j) -> Json& {
                                return j["members"][addon_file]["settings"]["values"]["survival.reward_interval"];
                            };
                            check(validate_settings_declarations(good).empty()
                                    && rejects([&](Json& j) { value(j)["step"] = 1; }, "unknown field step")
                                    && rejects([&](Json& j) { value(j).erase("scope"); }, "missing field scope")
                                    && rejects([&](Json& j) { value(j)["label"] = std::string(65, 'a'); }, "label is invalid")
                                    && rejects([&](Json& j) { value(j)["scope"] = std::string(257, 'a'); }, "scope is invalid")
                                    && rejects([&](Json& j) { value(j)["stock"] = 5000000; }, "stock is outside min..max")
                                    && rejects([&](Json& j) { value(j)["group"] = "defense"; }, "group is not declared")
                                    && rejects([&](Json& j) { value(j)["type"] = "int"; value(j)["stock"] = 2.5; }, "fractional")
                                    && rejects([&](Json& j) { value(j)["type"] = "enum"; }, "enum has no options")
                                    && rejects([&](Json& j) { value(j)["lane"] = "server"; }, "lane is not")
                                    && rejects([&](Json& j) { value(j)["applies"] = "F9"; }, "applies is not")
                                    && rejects([&](Json& j) { j["settings"]["format"] = "V0"; }, "settings.format")
                                    && rejects([&](Json& j) { j["settings"]["values"] = Json::object(); }, "settings has unknown field values")
                                    && rejects([&](Json& j) { j["settings"]["groups"].push_back({{"id", "spy"}, {"label", "Spy"}, {"order", 1},
                                                                                                 {"aliases", Json::array()}}); },
                                               "group spy is declared but no value uses it")
                                    && rejects([&](Json& j) { j["members"][addon_file]["settings"]["enabled"] = true; }, "exactly")
                                    && rejects([&](Json& j) { j["members"]["fc711ff621a75552 (missions_exact-replacement).lua_B"]["settings"]["values"]
                                                                   ["survival.reward_interval"] = value(j); }, "declared twice"),
                                "the settings declaration schema check rejects unknown/missing fields, over-long text, out-of-range stock, "
                                "undeclared or unused groups, fractional ints, enums without options, unknown lanes/apply classes and "
                                "duplicate value ids");

                            // Revision R1 (bootstrapper dd5414c): optional stock_check "live" | "none", addon lane only, absent = live.
                            const auto accepts = [&](const std::function<void(Json&)>& mutate) {
                                Json changed = good;
                                mutate(changed);
                                return validate_settings_declarations(changed).empty();
                            };
                            const auto flood = [&](Json& j) -> Json& {
                                return j["members"]["fc711ff621a75552 (missions_exact-replacement).lua_B"]["settings"]["values"]
                                        ["void_flood.fractures_per_round.normal"];
                            };
                            bool generator_omits = true;
                            for (const auto& [member_file, member] : good.at("members").items())
                                if (member.contains("settings"))
                                    for (const auto& [value_id, declaration] : member.at("settings").at("values").items())
                                        if (declaration.contains("stock_check")) generator_omits = false;
                            check(generator_omits
                                    && accepts([&](Json& j) { value(j)["stock_check"] = "live"; })
                                    && accepts([&](Json& j) { value(j)["stock_check"] = "none"; })
                                    && rejects([&](Json& j) { value(j)["stock_check"] = "always"; }, "stock_check is not live or none")
                                    && rejects([&](Json& j) { value(j)["stock_check"] = true; }, "stock_check is not live or none")
                                    && rejects([&](Json& j) { flood(j)["stock_check"] = "live"; }, "stock_check is allowed only on the addon lane"),
                                "stock_check (R1) is accepted as live or none on addon values, rejected on other values or lanes, and the "
                                "generator leaves it absent (absent = live)");
                        }
                        Json bad_layout = probe_settings(values);
                        bad_layout["output_layout"] = "zip";
                        check(!build_mission_settings(bad_layout, editor_root, mission_fixture, true).success,
                              "an unknown output_layout is rejected");
                    }

                    // Per-instance binding, executed by the reference Luau VM on the generated source. Phase 2k: one case per
                    // (target, emitted hook prototype); the upvalue view holds every live table that prototype binds (its
                    // minimal-hook tables with an enabled value), including nested container paths (outermost key first).
                    const auto run_harness = [&](const std::string& source, const Json& manifest, const Json& build_values,
                                                 const std::string& name) -> std::pair<bool, std::string> {
                        std::set<std::string> enabled;
                        for (const auto& [id, value] : build_values.items()) enabled.insert(id);
                        std::ostringstream harness, idle;
                        std::size_t case_count = 0, hookless = 0, idle_count = 0, all_count = 0, other_count = 0;
                        harness << "local function chunk()\n" << source << "end\n\n"
                                << "local EXPECTED_TARGETS = " << manifest.at("target_keys").size() << "\nlocal cases = {\n";
                        for (const auto& target : manifest.at("targets")) {
                            const auto body = target.at("body_key").get<std::string>();
                            const Json& module = registry.at("modules").at(body);
                            std::map<std::string, std::string> fields;  // hooked table -> enabled fields
                            for (const auto& id_json : target.at("tunables")) {
                                const auto id = id_json.get<std::string>();
                                const Json& row = mission_tunable(registry, id);
                                for (const auto& field : row.at("owner").at("fields")) {
                                    const auto table_id = field.at("table_id").get<std::string>();
                                    if (enabled.contains(id))
                                        fields[table_id] += "{ id = " + lua_quote(id) + ", key = " + lua_table_key(field.at("field")) +
                                                            ", stock = " + format_number(row.at("stock").get<double>()) + ", value = " +
                                                            format_number(build_values.at(id).get<double>()) + " }, ";
                                }
                            }
                            std::map<int, std::string> prototypes;
                            std::map<int, bool> retire;  // contract R3: root child and every bound table retire-safe
                            for (const auto& [table_id, list] : fields) {
                                const Json& table = module.at("root_tables").at(table_id);
                                std::set<int> minimal, root_children;
                                for (const auto& prototype : table.at("minimal_hooks").at("prototypes")) minimal.insert(prototype.get<int>());
                                for (const auto& prototype : table.at("minimal_hooks").at("root_children")) root_children.insert(prototype.get<int>());
                                for (const auto& hook : table.at("hooks")) {
                                    if (!minimal.contains(hook.at("prototype").get<int>())) continue;
                                    const int proto = hook.at("prototype").get<int>();
                                    const bool safe = table.at("minimal_hooks").at("retire_safe").get<bool>() && root_children.contains(proto);
                                    retire[proto] = (retire.contains(proto) ? retire[proto] : true) && safe;
                                    std::string path;
                                    for (const auto& key : hook.at("path")) path += lua_table_key(key) + ", ";
                                    prototypes[hook.at("prototype").get<int>()] += "{ upvalue = " + std::to_string(hook.at("upvalue").get<int>()) +
                                                                                   ", path = { " + path + "}, fields = { " + list + "} }, ";
                                }
                            }
                            // Phase 2k: every emitted hook of the target (manifest hook plan) gets an idle-retire case.
                            // Contract R4: `all` = the hook opens with retire-all (manifest retire_all_prototypes); `other` =
                            // a declared value of the same target none of whose tables this hook binds (enabling it must
                            // turn retire-all into the plain R3 idle retire).
                            for (const auto& plan : manifest.at("hook_plan").at("targets")) {
                                if (plan.at("body_key") != body) continue;
                                if (plan.at("prototypes").empty()) ++hookless;
                                std::set<int> retire_all;
                                for (const auto& prototype : plan.value("retire_all_prototypes", Json::array())) retire_all.insert(prototype.get<int>());
                                for (const auto& prototype : plan.at("prototypes")) {
                                    const int proto = prototype.get<int>();
                                    std::string other = "nil";
                                    for (const auto& id_json : target.at("tunables")) {
                                        const auto other_id = id_json.get<std::string>();
                                        const Json& row = mission_tunable(registry, other_id);
                                        bool bound_here = false;
                                        for (const auto& field : row.at("owner").at("fields"))
                                            for (const auto& hooked : module.at("root_tables").at(field.at("table_id").get<std::string>())
                                                                          .at("minimal_hooks").at("prototypes"))
                                                bound_here = bound_here || hooked.get<int>() == proto;
                                        if (bound_here) continue;
                                        other = "{ id = " + lua_quote(other_id) + ", stock = " +
                                                format_number(row.at("stock").get<double>()) + " }";
                                        ++other_count;
                                        break;
                                    }
                                    idle << "    { key = " << lua_quote(body) << ", prototype = " << proto << ", all = "
                                         << (retire_all.contains(proto) ? "true" : "false") << ", other = " << other << " },\n";
                                    ++idle_count;
                                    all_count += retire_all.contains(proto) ? 1 : 0;
                                }
                            }
                            for (const auto& [prototype, tables] : prototypes) {
                                harness << "    { key = " << lua_quote(body) << ", prototype = " << prototype << ", retire = "
                                        << (retire[prototype] ? "true" : "false") << ", tables = { " << tables << "} },\n";
                                ++case_count;
                            }
                        }
                        harness << "}\nlocal idle = {\n" << idle.str() << "}\nlocal EXPECTED_HOOKLESS = " << hookless << "\n" << R"LUA(
local function check(condition, message)
    if not condition then error("MULTI-TARGET HARNESS FAIL: " .. message, 0) end
end
local function instance(case, offset)
    local upvalues, owners = {}, {}
    for t, tab in ipairs(case.tables) do
        local owner = {}
        for _, field in ipairs(tab.fields) do owner[field.key] = field.stock + offset end
        owners[t] = owner
        if #tab.path == 0 then
            upvalues[tab.upvalue] = owner
        else
            local node = upvalues[tab.upvalue] or {}
            upvalues[tab.upvalue] = node
            for i = 1, #tab.path - 1 do
                local k = tab.path[i]
                node[k] = node[k] or {}
                node = node[k]
            end
            local leaf = tab.path[#tab.path]
            if node[leaf] ~= nil then for k, v in pairs(node[leaf]) do owner[k] = v end end
            node[leaf] = owner
        end
    end
    return owners, upvalues
end
local function holds(owners, case, name)
    for t, tab in ipairs(case.tables) do
        for _, field in ipairs(tab.fields) do
            if owners[t][field.key] ~= field[name] then return false end
        end
    end
    return true
end

local container = chunk()
check(type(container) == "table" and container.hooks == nil and type(container.targets) == "table", "container has targets and no top-level hooks")
local count, hookless = 0, 0
for key, entry in pairs(container.targets) do
    count = count + 1
    check(type(entry) == "table" and type(entry.activate) == "function" and type(entry.cleanup) == "function"
        and (entry.hooks == nil or (type(entry.hooks) == "table" and type(entry.hooks.luaCalls) == "table")), key .. " entry shape")
    if entry.hooks == nil then hookless = hookless + 1 end
end
check(count == EXPECTED_TARGETS, "declared target count")
check(hookless == EXPECTED_HOOKLESS, "every target with a declared table declares hooks")
for _, case in ipairs(cases) do
    local entry = container.targets[case.key]
    local before = entry.hooks.luaCalls[case.prototype].before
    local tag = case.key .. "/" .. case.prototype
    local first = case.tables[1].fields[1]
    local expected = case.retire and "RENOVICE_RETIRE" or nil
    local a, ua = instance(case, 0)
    check(before(case.prototype, {}, ua) == nil, tag .. " an inactive hook stays armed (returns nothing)")
    check(holds(a, case, "stock"), tag .. " inert before activate")
    entry.activate()
    entry.activate()
    -- Contract R3: once every table of this hook is settled for the instance it returns the retire sentinel (only
    -- from a retire-safe root-child hook), on the first and on every later call.
    -- Contract R4: a value of this target is enabled, so the hook never returns retire-all (exactly one value, or none).
    local settled = table.pack(before(case.prototype, {}, ua))
    check(settled[1] == expected and settled.n == (expected and 1 or 0), tag .. " the hook returns the R3 retire sentinel after its write (no retire-all)")
    local b, ub = instance(case, 0)
    before(case.prototype, {}, ub)
    before(case.prototype, {}, ub)
    check(holds(a, case, "value") and holds(b, case, "value"), tag .. " two live instances are both written")
    a[1][first.key] = first.value + 1000
    before(case.prototype, {}, ua)
    check(a[1][first.key] == first.value + 1000, tag .. " each instance is written once")
    local d, ud = instance(case, 1)
    local ok, err = pcall(before, case.prototype, {}, ud)
    check(not ok and string.find(tostring(err), "drifted", 1, true) ~= nil, tag .. " a drifted instance reports an error")
    check(d[1][first.key] == first.stock + 1, tag .. " a drifted instance is left unchanged")
    for _ = 2, #case.tables do pcall(before, case.prototype, {}, ud) end
    local result
    ok, result = pcall(before, case.prototype, {}, ud)
    check(ok and d[1][first.key] == first.stock + 1, tag .. " a drifted instance is reported once per table and never written")
    check(result == expected, tag .. " a settled drifted instance retires the hook without an error")
    entry.cleanup()
    entry.cleanup()
    check(holds(b, case, "stock"), tag .. " cleanup restores every written instance")
    check(a[1][first.key] == first.value + 1000, tag .. " cleanup keeps a value another owner changed")
    local c, uc = instance(case, 0)
    before(case.prototype, {}, uc)
    check(holds(c, case, "stock"), tag .. " inert after cleanup")
    entry.activate()
    before(case.prototype, {}, ub)
    check(holds(b, case, "value"), tag .. " re-activation binds a restored instance again")
    entry.cleanup()
    check(holds(b, case, "stock"), tag .. " the second cleanup restores it")
    print("PASS " .. tag)
end
-- Phase 2i: values delivered by the host as context.settings (ADDON_SETTINGS_V1); no context keeps the compiled values (above).
for _, case in ipairs(cases) do
    local tag = case.key .. "/" .. case.prototype .. " settings"
    local first = case.tables[1].fields[1]
    local function run(settings, offset)
        local fresh = chunk()
        local entry = fresh.targets[case.key]
        local owners, up = instance(case, offset or 0)
        entry.activate({ settings = settings })
        local ok = pcall(entry.hooks.luaCalls[case.prototype].before, case.prototype, {}, up)
        return owners, entry, ok
    end
    local function given(enabled, delta, stockDelta)
        local result = {}
        for _, tab in ipairs(case.tables) do
            for _, field in ipairs(tab.fields) do
                result[field.id] = { enabled = enabled, value = field.value + delta, stock = field.stock + stockDelta }
            end
        end
        return result
    end
    local empty = run({})
    check(holds(empty, case, "stock"), tag .. ": an empty settings table (no settings file) writes nothing")
    local custom, entry = run(given(true, 1, 0))
    check(custom[1][first.key] == first.value + 1, tag .. ": an enabled value from context.settings is written")
    entry.cleanup()
    check(holds(custom, case, "stock"), tag .. ": cleanup restores a value delivered by context.settings")
    check(holds((run(given(false, 1, 0))), case, "stock"), tag .. ": a disabled value is never written")
    check(holds((run(given(true, 1, 1))), case, "stock"), tag .. ": a value whose declared stock differs from the compiled stock is not written")
    local drifted, _, ok = run(given(false, 1, 0), 1)
    check(ok and drifted[1][first.key] == first.stock + 1, tag .. ": a disabled value ignores a drifted table")
    print("PASS " .. tag)
end
-- Phase 2k + R3: every emitted hook has an idle retire path. With no enabled value for its tables it returns the sentinel
-- on its first call without touching the upvalue view; before activation it stays armed (returns nothing).
-- Contract R4 / S5: with an empty context.settings no value of the target is enabled, so a retire-all hook returns
-- "RENOVICE_RETIRE", "RENOVICE_RETIRE_ALL" (both values) as its first statement; with an enabled value in another table of
-- the same target it returns only the plain R3 retire (another hook of the target still has work for this instance).
local all_count, other_count = 0, 0
for _, h in ipairs(idle) do
    local tag = h.key .. "/" .. h.prototype
    local entry = chunk().targets[h.key]
    local before = entry.hooks.luaCalls[h.prototype].before
    check(select("#", before(h.prototype, {}, {})) == 0, tag .. " idle hook stays armed before activate")
    entry.activate({ settings = {} })
    local r = table.pack(before(h.prototype, {}, nil))
    if h.all then
        check(r.n == 2 and r[1] == "RENOVICE_RETIRE" and r[2] == "RENOVICE_RETIRE_ALL",
            tag .. " R4: empty context.settings returns both retire values, writing nothing")
        all_count = all_count + 1
    else
        check(r.n == 1 and r[1] == "RENOVICE_RETIRE", tag .. " idle hook retires on its first call, writing nothing")
    end
    entry.cleanup()
    check(select("#", before(h.prototype, {}, {})) == 0, tag .. " idle hook stays armed after cleanup")
    if h.other then
        entry.activate({ settings = { [h.other.id] = { enabled = true, value = h.other.stock, stock = h.other.stock } } })
        r = table.pack(before(h.prototype, {}, nil))
        check(r.n == 1 and r[1] == "RENOVICE_RETIRE",
            tag .. " R4: an enabled value in another table of the target (" .. h.other.id .. ") returns only the plain retire")
        entry.cleanup()
        other_count = other_count + 1
    end
end
local other = chunk()
check(#cases == 0 or other.targets[cases[1].key] ~= container.targets[cases[1].key], "each binding runs its own chunk state")
print("MULTI-TARGET HARNESS PASS cases=" .. #cases .. " idle=" .. #idle .. " retire_all=" .. all_count .. " other=" .. other_count)
)LUA";
                        const fs::path harness_path = mission_fixture / (name + "_harness.luau");
                        write_text(harness_path, harness.str());
                        const fs::path luau = resolve_workspace_path(editor_root, "repos", "de_luau_toolchain") / "bin/luau.exe";
                        const ProcessResult run = run_process(quote_process_argument(luau) + " " + quote_process_argument(harness_path), mission_fixture);
                        const bool ok = run.exit_code == 0 && contains_text(run.output, "MULTI-TARGET HARNESS PASS cases=" + std::to_string(case_count) +
                                                                                            " idle=" + std::to_string(idle_count) +
                                                                                            " retire_all=" + std::to_string(all_count) +
                                                                                            " other=" + std::to_string(other_count));
                        const auto summary = run.output.find("MULTI-TARGET HARNESS PASS");
                        return {ok, ok ? " [" + name + ": " + run.output.substr(summary, run.output.find_first_of("\r\n", summary) - summary) + "]"
                                       : run.output};
                    };
                    bool harness_ok = false;
                    std::string harness_output;
                    if (unified_ok)
                    {
                        const Json addon_values{{"survival.reward_interval", 150}, {"purgatory.difficulty1.warrior_level", 15},
                                                {"lantern.tier_up_interval", 60}};
                        std::tie(harness_ok, harness_output) = run_harness(unified_source, Json::parse(read_text(multi->manifest)), addon_values, "multi_target");
                    }
                    check(harness_ok, "the generated entries bind every live instance once (weak-keyed), skip a drifted instance with one error, "
                                      "restore every written instance in cleanup, and take enabled values from context.settings while "
                                      "disabled, missing or stock-mismatched values stay stock (luau.exe, 3 modules)" + harness_output);

                    // Phase 2i: the compiled settings table is read back exactly (value = build value, stock = registry stock).
                    {
                        const auto compiled = unified_ok ? multi_target_compiled_values(unified_source) : std::map<std::string, CompiledMissionValue>{};
                        bool compiled_ok = compiled.size() == 3;
                        for (const auto& [id, entry] : compiled)
                            compiled_ok = compiled_ok && entry.value == values.at(id).get<double>() && entry.enabled
                                && entry.stock == mission_tunable(registry, id).at("stock").get<double>();
                        check(compiled_ok && contains_text(unified_source, "activate = function(context)")
                                && contains_text(unified_source, "effectiveSettings(settings, context)"),
                              "the multi-target addon compiles its build values with the registry stock and reads context.settings in activate");
                    }

                    // Phase 2k: minimal hooks. Survival reward interval (root:i19:R9) is hooked only at its proven minimal
                    // prototypes; the full capturer list (10 prototypes, incl. the hot tick 68) is not emitted.
                    {
                        const auto hooks = unified_ok ? multi_target_source_hooks(unified_source) : std::map<std::string, std::set<int>>{};
                        const Json& plan = registry.at("modules").at("f10a043e7f825db2").at("root_tables").at("root:i19:R9").at("minimal_hooks");
                        std::set<int> minimal;
                        for (const auto& prototype : plan.at("prototypes")) minimal.insert(prototype.get<int>());
                        check(unified_ok && hooks.contains("Lotus.Scripts.Modes.SurvivalMission")
                                && hooks.at("Lotus.Scripts.Modes.SurvivalMission") == minimal
                                && minimal == std::set<int>{31, 61, 67, 69} && !minimal.contains(68)
                                && plan.at("gate") == "ROOT_TABLE_MINIMAL_HOOKS_V1"
                                && contains_text(unified.gate_log, "hook-plan\nPASS targets=3 hooked_targets=3"),
                              "the Survival reward-interval table is hooked only at its ROOT_TABLE_MINIMAL_HOOKS_V1 prototypes 31/61/67/69 "
                              "(hot tick 68 and the other capturers are not hooked); the hook-plan gate passes");
                        // The gate reads the generated source back: a tampered hook block is detected.
                        std::string tampered = unified_source;
                        const std::string needle = "            [67] = { before = before67 },";
                        const auto at = tampered.find(needle);
                        if (at != std::string::npos) tampered.replace(at, needle.size(), "            [68] = { before = before67 },");
                        bool tamper_detected = at == std::string::npos;
                        try { tamper_detected = multi_target_source_hooks(tampered).at("Lotus.Scripts.Modes.SurvivalMission") != minimal; }
                        catch (const std::exception&) { tamper_detected = true; }
                        check(at != std::string::npos && tamper_detected, "the hook-plan read-back detects a hook entry that differs from the plan");
                        // Contract R3: every Survival hook here is a retire-safe root child, so each returns the sentinel as its
                        // last statement; a sentinel placed before a bind is rejected by the read-back.
                        std::map<std::string, std::set<int>> retiring;
                        try { if (unified_ok) retiring = multi_target_source_retiring_hooks(unified_source); } catch (const std::exception&) {}
                        const std::string bind_line = "        if live1 then bind1(upvalues[70], current) end\n";
                        const std::string retire_line = "        return \"RENOVICE_RETIRE\" -- R3: this hook's tables are settled for this instance\n";
                        std::string early = unified_source;
                        const auto bind_at = early.find(bind_line);
                        bool early_rejected = false;
                        if (bind_at != std::string::npos) {
                            early.insert(bind_at, retire_line);
                            try { static_cast<void>(multi_target_source_retiring_hooks(early)); } catch (const std::exception& e) {
                                early_rejected = contains_text(e.what(), "before its last statement");
                            }
                        }
                        // Idle retire path (no enabled value -> retire at once): present on every hook; a hook without it is found.
                        std::map<std::string, SourceRetirePaths> paths;
                        try { if (unified_ok) paths = multi_target_source_retire_paths(unified_source); } catch (const std::exception&) {}
                        const std::string idle_line = "        if not (live1) then return \"RENOVICE_RETIRE\" end -- R3: no enabled value for this hook's tables\n";
                        std::string no_idle = unified_source;
                        const auto idle_at = no_idle.find("    local function before67(");
                        const auto idle_line_at = idle_at == std::string::npos ? std::string::npos : no_idle.find(idle_line, idle_at);
                        if (idle_line_at != std::string::npos) no_idle.erase(idle_line_at, idle_line.size());
                        std::map<std::string, SourceRetirePaths> no_idle_paths;
                        try { no_idle_paths = multi_target_source_retire_paths(no_idle); } catch (const std::exception&) {}
                        check(paths.contains("Lotus.Scripts.Modes.SurvivalMission")
                                && paths.at("Lotus.Scripts.Modes.SurvivalMission").idle == minimal
                                && idle_line_at != std::string::npos
                                && no_idle_paths.contains("Lotus.Scripts.Modes.SurvivalMission")
                                && !no_idle_paths.at("Lotus.Scripts.Modes.SurvivalMission").idle.contains(67)
                                && contains_text(unified.gate_log, " idle_retire_hooks="),
                              "R3 idle path: every emitted hook retires at once when its tables hold no enabled value; a hook without the "
                              "idle path is detected by the hook-retire read-back");
                        // Contract R4 / S5: every retire-safe root-child hook opens with retire-all over the target-wide flag;
                        // the read-back rejects a flag that is not the OR of every table flag of the target, a retire-all
                        // statement anywhere but first, and misses a hook whose retire-all statement was removed.
                        const std::string all_line = "        if not liveTarget then return \"RENOVICE_RETIRE\", \"RENOVICE_RETIRE_ALL\" end -- R4: no enabled value of this target\n";
                        const auto section_at = unified_source.find("\n-- Target ");
                        const auto survival_at = unified_source.find(": Lotus.Scripts.Modes.SurvivalMission\n");
                        const auto flag_at = survival_at == std::string::npos ? std::string::npos : unified_source.find("            liveTarget = live", survival_at);
                        const auto flag_end = flag_at == std::string::npos ? std::string::npos : unified_source.find('\n', flag_at);
                        bool narrowed_rejected = false;
                        if (flag_end != std::string::npos) {
                            std::string narrowed = unified_source;
                            narrowed.replace(flag_at, flag_end - flag_at, "            liveTarget = false");
                            try { static_cast<void>(multi_target_source_retire_paths(narrowed)); }
                            catch (const std::exception& e) { narrowed_rejected = contains_text(e.what(), "is not the OR of every table flag"); }
                        }
                        const auto before67_at = unified_source.find("    local function before67(");
                        const auto all_at = before67_at == std::string::npos ? std::string::npos : unified_source.find(all_line, before67_at);
                        std::string no_all = unified_source, late_all = unified_source;
                        std::map<std::string, SourceRetirePaths> no_all_paths;
                        bool late_rejected = false;
                        if (all_at != std::string::npos) {
                            no_all.erase(all_at, all_line.size());
                            try { no_all_paths = multi_target_source_retire_paths(no_all); } catch (const std::exception&) {}
                            const auto bind67 = late_all.find("        if live", all_at + all_line.size());
                            late_all.erase(all_at, all_line.size());
                            if (bind67 != std::string::npos) late_all.insert(bind67 - all_line.size(), all_line);
                            try { static_cast<void>(multi_target_source_retire_paths(late_all)); }
                            catch (const std::exception& e) { late_rejected = contains_text(e.what(), "retire-all outside its first statement"); }
                        }
                        check(section_at != std::string::npos && paths.contains("Lotus.Scripts.Modes.SurvivalMission")
                                && paths.at("Lotus.Scripts.Modes.SurvivalMission").retire_all == minimal
                                && narrowed_rejected && all_at != std::string::npos && late_rejected
                                && no_all_paths.contains("Lotus.Scripts.Modes.SurvivalMission")
                                && !no_all_paths.at("Lotus.Scripts.Modes.SurvivalMission").retire_all.contains(67)
                                && contains_text(unified.gate_log, " retire_all_hooks="),
                              "R4 retire-all: every retire-safe root-child hook returns \"RENOVICE_RETIRE\", \"RENOVICE_RETIRE_ALL\" as its first "
                              "statement when no value of its target is enabled; a target flag narrower than every table flag, a late "
                              "retire-all and a missing one are detected by the hook-retire read-back");
                        check(retiring.contains("Lotus.Scripts.Modes.SurvivalMission")
                                && retiring.at("Lotus.Scripts.Modes.SurvivalMission") == minimal
                                && contains_text(unified.gate_log, " retiring_hooks=") && bind_at != std::string::npos && early_rejected,
                              "R3: the retire-safe root-child hooks return \"RENOVICE_RETIRE\" as their last statement; an early sentinel is "
                              "rejected by the hook-retire read-back");
                        // Registry structure: a minimal hook outside the capturer list fails verify.
                        Json bad = registry;
                        bad["modules"]["f10a043e7f825db2"]["root_tables"]["root:i19:R9"]["minimal_hooks"]["prototypes"] = Json::array({68, 200});
                        bool rejected = false;
                        try { verify_root_table_fields(mission_tunable(bad, "survival.reward_interval"), bad.at("modules").at("f10a043e7f825db2"),
                                                       read_text(mission_roots.corpus / bad.at("modules").at("f10a043e7f825db2").at("file").get<std::string>())); }
                        catch (const std::exception& e) { rejected = contains_text(e.what(), "hook plan names a prototype"); }
                        check(rejected, "a minimal hook plan naming a prototype that is not a capturer hook is rejected by verify-missions");
                    }

                    // Phase 2k: the FULL package (package_scope all_addon_values). Every multi-instance-safe addon value is
                    // declared; only the build's values are enabled; only their tables are hooked; the rest of the targets
                    // declare no hooks; Void Flood addon rows give way to the enabled Void Flood replacement member.
                    {
                        Json full_settings = probe_settings(Json{{"survival.reward_interval", 150}, {"void_flood.fractures_per_round.normal", 4}});
                        full_settings["output_layout"] = "package";
                        full_settings["package_scope"] = "all_addon_values";
                        const MissionSetResult full = build_mission_settings(full_settings, editor_root, mission_fixture, true);
                        bool full_ok = full.success && !full.package_directory.empty();
                        std::string full_detail;
                        if (!full_ok && !full.diagnostics.empty()) full_detail = " " + full.diagnostics.front().message;
                        std::size_t addon_rows = 0, flood_rows = 0, hidden_rows = 0, addon_masters = 0;
                        for (const auto& row : registry.at("tunables"))
                            if (row.at("backend") == "TARGET_ADDON" && row.at("owner").contains("fields")) {
                                ++addon_rows;
                                if (row.at("owner").at("body_key") == "fc711ff621a75552") ++flood_rows;
                                else if (row.at("ui").contains("hidden")) ++hidden_rows;
                            }
                        for (const auto& [id, master] : registry.at("ui_masters").items())
                            if (master.at("lane") == "addon" && master.at("body_key") != "fc711ff621a75552") ++addon_masters;
                        const std::size_t declared_addon = addon_rows - flood_rows - hidden_rows + addon_masters;
                        if (full_ok) {
                            const Json package_json = Json::parse(read_text(full.package_directory / "package.json"));
                            const Json& addon_member = package_json.at("members").at("Missions.targets.addon.lua_B").at("settings").at("values");
                            const Json migration = Json::parse(read_text(full.directory / "Settings" / "Missions.json"));
                            const Json set_manifest = Json::parse(read_text(full.manifest));
                            const MissionArtifact* full_addon = nullptr;
                            for (const auto& item : full.artifacts) if (item.backend == "TARGET_ADDON") full_addon = &item;
                            const Json addon_manifest = full_addon ? Json::parse(read_text(full_addon->manifest)) : Json();
                            std::size_t enabled_entries = 0;
                            for (const auto& [id, entry] : migration.at("values").items()) enabled_entries += entry.at("enabled") == true ? 1 : 0;
                            const auto source_hooks = full_addon ? multi_target_source_hooks(read_text(full_addon->source)) : std::map<std::string, std::set<int>>{};
                            std::size_t hooked_targets = 0;
                            for (const auto& [module_path, set] : source_hooks) hooked_targets += set.empty() ? 0 : 1;
                            const auto& excluded = set_manifest.at("package").at("settings").at("declarations").at("excluded_values");
                            full_ok = full_addon != nullptr && validate_settings_declarations(package_json).empty()
                                && addon_member.size() == declared_addon && hidden_rows > 0 && addon_masters > 0
                                && excluded.size() == flood_rows + 2 + hidden_rows
                                && migration.at("values").size() == declared_addon + 1 && enabled_entries == 2
                                && migration.at("values").at("survival.reward_interval") == Json{{"enabled", true}, {"value", 150}}
                                && migration.at("values").at("void_flood.fractures_per_round.normal") == Json{{"enabled", true}, {"value", 4}}
                                && migration.at("values").at("survival.pickup_time_added") == Json{{"enabled", false}, {"value", 7}}
                                && hooked_targets == addon_manifest.at("target_keys").size()
                                && source_hooks.at("Lotus.Scripts.Modes.SurvivalMission") == std::set<int>{23, 31, 34, 59, 61, 67, 69, 72}
                                && fs::file_size(full.package_directory / "package.json") <= 512u * 1024u
                                && addon_manifest.at("hook_plan").at("hooked_targets") == addon_manifest.at("target_keys").size()
                                && addon_manifest.at("hook_plan").at("idle_retire_hooks") == addon_manifest.at("hook_plan").at("hooks")
                                && addon_manifest.at("hook_plan").at("retire_all_hooks") == addon_manifest.at("hook_plan").at("hooks")
                                && addon_manifest.at("hook_plan").at("retire_all_sentinel") == "RENOVICE_RETIRE_ALL"
                                && contains_text(full.gate_log, "hook-plan\nPASS targets=" + std::to_string(addon_manifest.at("target_keys").size()) + " hooked_targets=" + std::to_string(addon_manifest.at("target_keys").size()) + " ")
                                && contains_text(full.gate_log, "settings-declarations\nPASS values=" + std::to_string(declared_addon + 1) + " ")
                                && contains_text(full.gate_log, " masters=" + std::to_string(addon_masters) + "\n")
                                && contains_text(read_text(full_addon->source), kMasterEffectiveCall);
                            if (full_ok) {
                                // Two-instance harness over the full file plus a second build with nested (1- and 2-step
                                // container) and shared-hook tables enabled.
                                const auto [ok1, out1] = run_harness(read_text(full_addon->source), addon_manifest, Json{{"survival.reward_interval", 150}}, "full_package");
                                Json wide_values{{"survival.reward_interval", 150}, {"survival.capsule_interval", 60},
                                                 {"purgatory.difficulty2.ghost_level", 12},
                                                 {"shrine.respawn_delay.normal.offering.p2", 9}, {"shrine.stage_time.offering", 300},
                                                 {"loopdefend.enemy_counts.maxNum.p1", 9}};
                                Json wide_settings = probe_settings(wide_values);
                                wide_settings["output_layout"] = "package";
                                wide_settings["package_scope"] = "all_addon_values";
                                const MissionSetResult wide = build_mission_settings(wide_settings, editor_root, mission_fixture, true);
                                const MissionArtifact* wide_addon = nullptr;
                                for (const auto& item : wide.artifacts) if (item.backend == "TARGET_ADDON") wide_addon = &item;
                                bool ok2 = wide.success && wide_addon != nullptr;
                                std::string out2 = ok2 ? std::string() : (wide.diagnostics.empty() ? std::string(" wide build failed") : " " + wide.diagnostics.front().message);
                                if (ok2) std::tie(ok2, out2) = run_harness(read_text(wide_addon->source), Json::parse(read_text(wide_addon->manifest)), wide_values, "wide_package");
                                // R4: the full package must exercise the "enabled value in another table" case.
                                full_ok = ok1 && ok2 && !contains_text(out1, " other=0]");
                                full_detail = out1 + out2;
                            }
                        }
                        check(full_ok, "package_scope all_addon_values declares every multi-instance-safe addon value (Void Flood addon rows "
                                       "and the 2 template-only rows excluded with reasons), ships them disabled except the build's values, hooks "
                                       "every declared table at its minimal prototypes (every target hooked, every hook with an idle R3 retire path "
                                       "and an R4 retire-all path), "
                                       "stays under 512 KiB, and passes "
                                       "the two-instance harness incl. nested and shared-hook tables" + full_detail);

                        // Contract R5: master knobs of the full package, executed by the reference Luau VM. One case per (master,
                        // hooked prototype): a usable master writes master x scale into every driven row it binds; a driven row
                        // that is itself enabled wins; a master whose declared stock differs writes nothing; cleanup restores.
                        {
                            const MissionArtifact* master_addon = nullptr;
                            for (const auto& item : full.artifacts) if (item.backend == "TARGET_ADDON") master_addon = &item;
                            bool masters_ok = full.success && master_addon != nullptr && !master_addon->masters.empty();
                            std::string masters_detail;
                            std::size_t master_cases = 0;
                            if (masters_ok) {
                                std::ostringstream harness;
                                harness << "local function chunk()\n" << read_text(master_addon->source) << "end\n\nlocal cases = {\n";
                                for (const auto& id : master_addon->masters) {
                                    const Json& master = registry.at("ui_masters").at(id);
                                    const auto body = master.at("body_key").get<std::string>();
                                    const Json& module = registry.at("modules").at(body);
                                    const double value = master.at("stock").get<double>() + 1;
                                    // prototype -> table -> (upvalue/path, fields)
                                    std::map<int, std::map<std::string, std::pair<std::string, std::string>>> by_proto;
                                    for (const auto& drive : master.at("drives")) {
                                        const std::string row_id = drive.at("tunable_id").get<std::string>();
                                        const Json& row = mission_tunable(registry, row_id);
                                        for (const auto& field : row.at("owner").at("fields")) {
                                            const auto table_id = field.at("table_id").get<std::string>();
                                            const Json& table = module.at("root_tables").at(table_id);
                                            std::set<int> minimal;
                                            for (const auto& prototype : table.at("minimal_hooks").at("prototypes")) minimal.insert(prototype.get<int>());
                                            for (const auto& hook : table.at("hooks")) {
                                                const int proto = hook.at("prototype").get<int>();
                                                if (!minimal.contains(proto)) continue;
                                                std::string path;
                                                for (const auto& key : hook.at("path")) path += lua_table_key(key) + ", ";
                                                auto& slot = by_proto[proto][table_id];
                                                slot.first = "upvalue = " + std::to_string(hook.at("upvalue").get<int>()) + ", path = { " + path + "}";
                                                slot.second += "{ id = " + lua_quote(row.at("tunable_id").get<std::string>()) + ", key = " +
                                                               lua_table_key(field.at("field")) + ", stock = " +
                                                               format_number(row.at("stock").get<double>()) + ", scale = " +
                                                               format_number(drive.at("scale").get<double>()) + " }, ";
                                            }
                                        }
                                    }
                                    for (const auto& [proto, tables] : by_proto) {
                                        harness << "    { key = " << lua_quote(body) << ", prototype = " << proto << ", master = " << lua_quote(id)
                                                << ", mstock = " << format_number(master.at("stock").get<double>()) << ", value = "
                                                << format_number(value) << ", tables = { ";
                                        for (const auto& [table_id, slot] : tables)
                                            harness << "{ " << slot.first << ", fields = { " << slot.second << "} }, ";
                                        harness << "} },\n";
                                        ++master_cases;
                                    }
                                }
                                harness << "}\n" << R"LUA(
local function check(condition, message)
    if not condition then error("MASTER HARNESS FAIL: " .. message, 0) end
end
local function instance(case)
    local upvalues, owners = {}, {}
    for t, tab in ipairs(case.tables) do
        local owner = {}
        for _, field in ipairs(tab.fields) do owner[field.key] = field.stock end
        owners[t] = owner
        if #tab.path == 0 then
            upvalues[tab.upvalue] = owner
        else
            local node = upvalues[tab.upvalue] or {}
            upvalues[tab.upvalue] = node
            for i = 1, #tab.path - 1 do
                local k = tab.path[i]
                node[k] = node[k] or {}
                node = node[k]
            end
            node[tab.path[#tab.path]] = owner
        end
    end
    return owners, upvalues
end
local function run(case, settings)
    local entry = chunk().targets[case.key]
    local owners, upvalues = instance(case)
    entry.activate({ settings = settings })
    local ok, err = pcall(entry.hooks.luaCalls[case.prototype].before, case.prototype, {}, upvalues)
    check(ok, case.master .. "/" .. case.prototype .. " hook raised: " .. tostring(err))
    return owners, entry
end
for _, case in ipairs(cases) do
    local tag = case.master .. "/" .. case.prototype
    local owners, entry = run(case, { [case.master] = { enabled = true, value = case.value, stock = case.mstock } })
    for t, tab in ipairs(case.tables) do
        for _, field in ipairs(tab.fields) do
            check(owners[t][field.key] == case.value * field.scale, tag .. " master writes value x scale into " .. field.id)
        end
    end
    entry.cleanup()
    for t, tab in ipairs(case.tables) do
        for _, field in ipairs(tab.fields) do check(owners[t][field.key] == field.stock, tag .. " cleanup restores " .. field.id) end
    end
    local first = case.tables[1].fields[1]
    local settings = { [case.master] = { enabled = true, value = case.value, stock = case.mstock },
                       [first.id] = { enabled = true, value = first.stock + 2, stock = first.stock } }
    owners = run(case, settings)
    for t, tab in ipairs(case.tables) do
        for _, field in ipairs(tab.fields) do
            local want = field.id == first.id and first.stock + 2 or case.value * field.scale
            check(owners[t][field.key] == want, tag .. " an enabled driven row wins over its master (" .. field.id .. ")")
        end
    end
    owners = run(case, { [case.master] = { enabled = true, value = case.value, stock = case.mstock + 1 } })
    owners = owners
    for t, tab in ipairs(case.tables) do
        for _, field in ipairs(tab.fields) do check(owners[t][field.key] == field.stock, tag .. " a master with another stock writes nothing") end
    end
    owners = run(case, { [case.master] = { enabled = false, value = case.value, stock = case.mstock } })
    for t, tab in ipairs(case.tables) do
        for _, field in ipairs(tab.fields) do check(owners[t][field.key] == field.stock, tag .. " a disabled master writes nothing") end
    end
    local plain = chunk().targets[case.key]
    local compiled_owners, compiled_up = instance(case)
    plain.activate()
    pcall(plain.hooks.luaCalls[case.prototype].before, case.prototype, {}, compiled_up)
    for t, tab in ipairs(case.tables) do
        for _, field in ipairs(tab.fields) do
            check(compiled_owners[t][field.key] == field.stock, tag .. " without context.settings a stock-compiled master writes nothing")
        end
    end
end
print("MASTER HARNESS PASS cases=" .. #cases)
)LUA";
                                const fs::path harness_path = mission_fixture / "master_harness.luau";
                                write_text(harness_path, harness.str());
                                const fs::path luau = resolve_workspace_path(editor_root, "repos", "de_luau_toolchain") / "bin/luau.exe";
                                const ProcessResult run = run_process(quote_process_argument(luau) + " " + quote_process_argument(harness_path), mission_fixture);
                                masters_ok = master_cases > 0 && run.exit_code == 0 &&
                                             contains_text(run.output, "MASTER HARNESS PASS cases=" + std::to_string(master_cases));
                                masters_detail = masters_ok ? " [cases=" + std::to_string(master_cases) + "]" : " " + run.output.substr(0, 600);
                            }
                            check(masters_ok, "R5 master knobs (luau.exe, full package): a master writes master x scale into every driven row, "
                                              "an enabled driven row wins, a master with another declared stock or disabled writes nothing, "
                                              "cleanup restores, and a stock-compiled master is inert without context.settings" + masters_detail);
                        }

                        // Contract R5: literal master knobs and disabled_values. Mobile Defense "Time per terminal" drives both
                        // total-time literals (x3) into ONE replacement member that declares only the master; the Mobile Defense
                        // addon rows and addon masters give way with reasons; a disabled value is built but shipped off.
                        {
                            Json literal_settings = probe_settings(Json{{"mobiledefense.time_per_terminal", 20}, {"excavation.dig_time", 50}});
                            literal_settings["output_layout"] = "package";
                            literal_settings["package_scope"] = "all_addon_values";
                            literal_settings["disabled_values"] = Json::array({"excavation.dig_time"});
                            const MissionSetResult literal = build_mission_settings(literal_settings, editor_root, mission_fixture, true);
                            bool literal_ok = literal.success && !literal.package_directory.empty();
                            std::string literal_detail = literal_ok || literal.diagnostics.empty() ? std::string() : " " + literal.diagnostics.front().message;
                            if (literal_ok) {
                                const Json package_json = Json::parse(read_text(literal.package_directory / "package.json"));
                                const Json migration = Json::parse(read_text(literal.directory / "Settings" / "Missions.json"));
                                const Json plan = Json::parse(read_text(literal.directory / "source" / "a807aae359ffc1eb.plan.json"));
                                const Json normalized = Json::parse(read_text(literal.directory / "mission_settings.json"));
                                const Json set_manifest = Json::parse(read_text(literal.manifest));
                                std::set<std::string> excluded_ids;
                                for (const auto& entry : set_manifest.at("package").at("settings").at("declarations").at("excluded_values"))
                                    excluded_ids.insert(entry.at("tunable_id").get<std::string>());
                                std::set<int> operands;
                                for (const auto& edit : plan.at("edits")) operands.insert(edit.at("operand").get<int>());
                                const Json& md = package_json.at("members").at("a807aae359ffc1eb (missions_exact-replacement).lua_B").at("settings").at("values");
                                const Json& dig = package_json.at("members").at("f7444e3c621ff018 (missions_exact-replacement).lua_B").at("settings").at("values");
                                literal_ok = md.size() == 1 && md.contains("mobiledefense.time_per_terminal")
                                    && md.at("mobiledefense.time_per_terminal").at("lane") == "literal" && dig.size() == 1 && dig.contains("excavation.dig_time")
                                    && plan.at("edits").size() == 2 && operands == std::set<int>{60}
                                    && migration.at("values").at("mobiledefense.time_per_terminal") == Json{{"enabled", true}, {"value", 20}}
                                    && migration.at("values").at("excavation.dig_time") == Json{{"enabled", false}, {"value", 50}}
                                    && excluded_ids.contains("mobiledefense.enemy_counts.max.p1") && excluded_ids.contains("mobiledefense.max_enemies.p1")
                                    && normalized.at("values").contains("mobiledefense.time_per_terminal")
                                    && !normalized.at("values").contains("mobiledefense.total_time.minimum")
                                    && normalized.at("disabled_values") == Json::array({"excavation.dig_time"})
                                    && contains_text(literal.gate_log, "settings-declarations\nPASS");
                            }
                            const auto rejected = [&](Json settings_json, const std::string& needle) {
                                const MissionSetResult bad = build_mission_settings(settings_json, editor_root, mission_fixture, true);
                                return !bad.success && !bad.diagnostics.empty() && contains_text(bad.diagnostics.front().message, needle);
                            };
                            const auto full_input = [&](const Json& values_json) {
                                Json value = probe_settings(values_json);
                                value["output_layout"] = "package";
                                value["package_scope"] = "all_addon_values";
                                return value;
                            };
                            Json unnamed_disabled = full_input(Json{{"survival.reward_interval", 150}});
                            unnamed_disabled["disabled_values"] = Json::array({"excavation.dig_time"});
                            check(literal_ok
                                    && rejected(probe_settings(Json{{"mobiledefense.time_per_terminal", 20}}), "needs \"package_scope\"")
                                    && rejected(full_input(Json{{"mobiledefense.time_per_terminal", 0}}), "master knob mobiledefense.time_per_terminal")
                                    && rejected(full_input(Json{{"mobiledefense.time_per_terminal", 20}, {"mobiledefense.total_time.minimum", 60}}), "named both")
                                    && rejected(full_input(Json{{"mobiledefense.time_per_terminal", 20}, {"mobiledefense.console_count", 2}}),
                                                "only the rows its master drives")
                                    && rejected(unnamed_disabled, "which values does not name")
                                    && rejected(full_input(Json{{"fivefates.state_times_sp.state1", 200}}), "hidden"),
                                  "R5 literal master: Mobile Defense time per terminal builds both total-time operands (20 x 3 = 60) into one "
                                  "replacement member that declares only the master, displaces the Mobile Defense addon rows and masters with "
                                  "reasons, ships a disabled value off, and rejects masters outside all_addon_values, out-of-range values, a row "
                                  "named twice, a foreign row in a master member, unnamed disabled ids and hidden rows" + literal_detail);
                        }
                        Json loose_scope = probe_settings(Json{{"survival.reward_interval", 150}});
                        loose_scope["package_scope"] = "all_addon_values";
                        Json bad_scope = loose_scope;
                        bad_scope["output_layout"] = "package";
                        bad_scope["package_scope"] = "everything";
                        check(!build_mission_settings(loose_scope, editor_root, mission_fixture, true).success
                                && !build_mission_settings(bad_scope, editor_root, mission_fixture, true).success,
                              "package_scope all_addon_values needs the package layout, and an unknown package_scope is rejected");
                    }

                    // No-stray-hex rule: the source check and the loader-equivalent pool reader.
                    std::string pool{'\x09', '\x03', '\x03', '\x10'};
                    pool += "0123456789abcdef";
                    pool += '\x10';
                    pool += "0123456789ABCDEF";
                    pool += '\x03';
                    pool += "abc";
                    bool zero_rejected = false;
                    try { static_cast<void>(multi_target_declared_keys(std::string{'\x09', '\x03', '\x01', '\x10'} + std::string(16, '0'))); }
                    catch (const std::exception&) { zero_rejected = true; }
                    check(unified_ok && !multi_target_stray_hex(unified_source + "-- 0123456789abcdef\n", expected_keys).empty()
                            && !multi_target_stray_hex(unified_source + "-- f10a043e7f825db2\n", expected_keys).empty()
                            && !multi_target_stray_hex(unified_source + "-- 0123456789abcdef0\n", expected_keys).empty()
                            && multi_target_stray_hex(unified_source + "-- F10A043E7F825DB2\n", expected_keys).empty()
                            && multi_target_declared_keys(pool) == std::set<std::string>{"0123456789abcdef"} && zero_rejected,
                        "stray or repeated lowercase 16-hex text is rejected, uppercase is ignored, and the pool reader matches the loader rules");
                    Json stray_registry = registry;
                    stray_registry["modules"]["6fa60841c9e0f207"]["module_path"] = "Lotus.Scripts.Modes.Purgatory0123456789abcdef";
                    const MissionSetResult stray = build_mission_set(stray_registry, values,
                        MissionNaming{"missions-selftest", "missions", "missions", "RENOVICE_Missions.txt", false, "", {"renovice.target.lua_call"}},
                        editor_root, mission_fixture, true, nullptr);
                    check(!stray.success && !stray.diagnostics.empty()
                            && contains_text(stray.diagnostics.front().message, "multi-target-declared-keys failed")
                            && contains_text(stray.diagnostics.front().message, "stray lowercase hex text '0123456789abcdef'"),
                        "a generated string that would become an extra declared key fails the multi-target build closed");

                    // Template-only rows bind one owner per activation (not multi-instance safe) and stay with their preset.
                    const MissionSetResult template_row = build_mission_settings(probe_settings({{"survival.pickup_reward_progress", 5}}),
                                                                                 editor_root, mission_fixture, true);
                    check(!template_row.success && template_row.artifacts.empty() && !template_row.diagnostics.empty()
                            && contains_text(template_row.diagnostics.front().message, "not multi-instance safe")
                            && contains_text(template_row.diagnostics.front().message, "'survival' preset"),
                        "a template-only addon row fails closed in the multi-target file and names its preset");
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
