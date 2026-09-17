#include "renovice/core.hpp"

#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <map>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string_view>

#include <windows.h>

namespace renovice
{
    namespace
    {
        constexpr std::uint64_t deployed_body_key_basis = 1469598103934665603ull;
        constexpr std::uint64_t body_key_prime = 1099511628211ull;

        void add_diagnostic(
            std::vector<Diagnostic>& diagnostics,
            const Severity severity,
            std::string code,
            std::string message)
        {
            diagnostics.push_back(Diagnostic{severity, std::move(code), std::move(message)});
        }

        [[nodiscard]] std::string read_binary(const fs::path& path)
        {
            std::ifstream input(path, std::ios::binary);
            if (!input) throw std::runtime_error("Unable to open " + path.string());
            return std::string(std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>());
        }

        void write_atomic(const fs::path& path, const std::string& text)
        {
            fs::create_directories(path.parent_path());
            const fs::path temporary = path.string() + ".tmp";
            {
                std::ofstream output(temporary, std::ios::binary | std::ios::trunc);
                if (!output) throw std::runtime_error("Unable to write " + temporary.string());
                output.write(text.data(), static_cast<std::streamsize>(text.size()));
                if (!output) throw std::runtime_error("Incomplete write to " + temporary.string());
            }
            std::error_code error;
            fs::rename(temporary, path, error);
            if (error)
            {
                fs::remove(path, error);
                error.clear();
                fs::rename(temporary, path, error);
            }
            if (error) throw std::runtime_error("Unable to activate " + path.string() + ": " + error.message());
        }

        [[nodiscard]] Json load_json(const fs::path& path)
        {
            return Json::parse(read_binary(path));
        }

        [[nodiscard]] fs::path semantic_sdk_symbols(const fs::path& toolchain_root)
        {
            fs::path cursor = fs::absolute(toolchain_root);
            while (!cursor.empty())
            {
                const fs::path manifest_path = cursor / "WORKSPACE.json";
                if (fs::is_regular_file(manifest_path))
                {
                    const Json manifest = load_json(manifest_path);
                    if (!manifest.contains("shared") || !manifest.at("shared").is_object()
                        || !manifest.at("shared").contains("semantic_sdk")
                        || !manifest.at("shared").at("semantic_sdk").is_string())
                    {
                        throw std::runtime_error(
                            "WORKSPACE.json is missing shared.semantic_sdk");
                    }
                    const fs::path symbols = fs::weakly_canonical(
                        cursor / manifest.at("shared").at("semantic_sdk").get<std::string>()
                        / "symbols.tsv");
                    const fs::path sdk_manifest = symbols.parent_path() / "manifest.json";
                    if (!fs::is_regular_file(symbols) || !fs::is_regular_file(sdk_manifest))
                    {
                        throw std::runtime_error(
                            "Published Semantic SDK symbols/manifest are missing: " + symbols.string()
                            + ". Run renovice-semantic build first.");
                    }
                    return symbols;
                }
                const fs::path parent = cursor.parent_path();
                if (parent == cursor) break;
                cursor = parent;
            }
            throw std::runtime_error(
                "Unable to locate WORKSPACE.json above the DE Luau toolchain");
        }

        [[nodiscard]] std::string string_field(const Json& object, const char* key)
        {
            if (!object.is_object() || !object.contains(key) || !object.at(key).is_string()) return {};
            return object.at(key).get<std::string>();
        }

        [[nodiscard]] fs::path package_root(const fs::path& snapshot)
        {
            if (fs::is_directory(snapshot / "Lotus")) return snapshot;
            std::vector<fs::path> candidates;
            for (const auto& entry : fs::directory_iterator(snapshot))
            {
                if (entry.is_directory() && fs::is_directory(entry.path() / "Lotus"))
                {
                    candidates.push_back(entry.path());
                }
            }
            std::sort(candidates.begin(), candidates.end());
            if (candidates.size() != 1)
            {
                throw std::runtime_error(
                    "Metadata snapshot must contain exactly one package root with a Lotus directory: "
                    + snapshot.string());
            }
            return candidates.front();
        }

        [[nodiscard]] std::string asset_path(const fs::path& package, const fs::path& json_path)
        {
            fs::path relative = fs::relative(json_path, package);
            relative.replace_extension();
            return "/" + relative.generic_string();
        }

        [[nodiscard]] fs::path resolve_asset_json(
            const fs::path& package,
            const fs::path& owner_json,
            const std::string& reference)
        {
            fs::path resolved;
            if (!reference.empty() && reference.front() == '/')
            {
                resolved = package / fs::path(reference.substr(1));
            }
            else
            {
                resolved = owner_json.parent_path() / fs::path(reference);
            }
            if (resolved.extension() != ".json") resolved += ".json";
            return resolved.lexically_normal();
        }

        [[nodiscard]] std::string body_key_hex(const std::string_view bytes)
        {
            std::uint64_t hash = deployed_body_key_basis;
            for (const unsigned char byte : bytes)
            {
                hash ^= byte;
                hash *= body_key_prime;
            }
            std::ostringstream output;
            output << std::hex << std::setfill('0') << std::setw(16) << hash;
            return output.str();
        }

        [[nodiscard]] std::string corpus_filename(std::string module_path)
        {
            if (!module_path.empty() && module_path.front() == '/') module_path.erase(module_path.begin());
            std::replace(module_path.begin(), module_path.end(), '/', '_');
            std::replace(module_path.begin(), module_path.end(), '\\', '_');
            return module_path + "_B";
        }

        [[nodiscard]] std::string trim_suffix(std::string value, const std::string_view suffix)
        {
            if (value.size() >= suffix.size()
                && value.compare(value.size() - suffix.size(), suffix.size(), suffix) == 0)
            {
                value.resize(value.size() - suffix.size());
            }
            return value;
        }

        [[nodiscard]] std::string localize(
            const std::map<std::string, std::string>& names,
            const std::string& tag)
        {
            const auto found = names.find(tag);
            return found == names.end() ? std::string{} : found->second;
        }

        [[nodiscard]] std::string icon_fallback(const Json& data, const fs::path& source)
        {
            const std::string icon = string_field(data, "Icon");
            if (!icon.empty())
            {
                const std::string stem = fs::path(icon).stem().string();
                if (!stem.empty()) return stem;
            }
            return trim_suffix(source.stem().string(), "BaseSuit");
        }

        [[nodiscard]] std::wstring quote_windows(const fs::path& value)
        {
            std::wstring text = value.wstring();
            std::wstring output = L"\"";
            std::size_t slashes = 0;
            for (const wchar_t character : text)
            {
                if (character == L'\\')
                {
                    ++slashes;
                    continue;
                }
                if (character == L'\"')
                {
                    output.append(slashes * 2 + 1, L'\\');
                    output.push_back(L'\"');
                    slashes = 0;
                    continue;
                }
                output.append(slashes, L'\\');
                slashes = 0;
                output.push_back(character);
            }
            output.append(slashes * 2, L'\\');
            output.push_back(L'\"');
            return output;
        }
    }

    CatalogBuildResult build_ability_catalog(
        const fs::path& metadata_snapshot,
        const fs::path& stock_corpus,
        const fs::path& output_path,
        const std::optional<fs::path>& localized_names)
    {
        CatalogBuildResult result;
        result.catalog_path = output_path;
        try
        {
            if (!fs::is_directory(metadata_snapshot))
            {
                throw std::runtime_error("Metadata snapshot directory is missing: " + metadata_snapshot.string());
            }
            if (!fs::is_directory(stock_corpus))
            {
                throw std::runtime_error("Stock corpus directory is missing: " + stock_corpus.string());
            }

            std::map<std::string, std::string> names;
            if (localized_names)
            {
                if (!fs::is_regular_file(*localized_names))
                {
                    throw std::runtime_error("Localized names file is missing: " + localized_names->string());
                }
                const Json names_json = load_json(*localized_names);
                if (!names_json.is_object()) throw std::runtime_error("Localized names JSON must be an object");
                for (const auto& [tag, value] : names_json.items())
                {
                    if (value.is_string()) names.emplace(tag, value.get<std::string>());
                }
            }

            const fs::path package = package_root(metadata_snapshot);
            const fs::path powersuits = package / "Lotus" / "Powersuits";
            std::vector<fs::path> metadata_files;
            for (const auto& entry : fs::recursive_directory_iterator(powersuits))
            {
                if (entry.is_regular_file() && entry.path().extension() == ".json")
                {
                    metadata_files.push_back(entry.path());
                }
            }
            std::sort(metadata_files.begin(), metadata_files.end());

            Json warframes = Json::array();
            std::size_t unreadable_metadata = 0;
            std::size_t unresolved_modules = 0;
            std::set<std::string> seen_frame_assets;

            for (const fs::path& frame_file : metadata_files)
            {
                Json frame;
                try { frame = load_json(frame_file); }
                catch (...) { ++unreadable_metadata; continue; }
                if (!frame.contains("data") || !frame.at("data").is_object()) continue;
                const Json& frame_data = frame.at("data");
                if (string_field(frame, "parent") != "/Lotus/Types/Game/PowerSuits/PlayerPowerSuit"
                    || !frame_file.stem().string().ends_with("BaseSuit"))
                {
                    continue;
                }
                if (!frame_data.contains("AbilityTypes") || !frame_data.at("AbilityTypes").is_array()
                    || frame_data.at("AbilityTypes").empty())
                {
                    continue;
                }

                const std::string frame_asset = asset_path(package, frame_file);
                if (!seen_frame_assets.insert(frame_asset).second) continue;
                const std::string frame_tag = string_field(frame_data, "LocalizeTag");
                const std::string localized_frame = localize(names, frame_tag);
                const std::string frame_name = localized_frame.empty()
                    ? icon_fallback(frame_data, frame_file)
                    : localized_frame;

                Json abilities = Json::array();
                std::size_t slot = 0;
                for (const Json& reference_json : frame_data.at("AbilityTypes"))
                {
                    ++slot;
                    if (!reference_json.is_string()) continue;
                    const std::string reference = reference_json.get<std::string>();
                    const fs::path ability_file = resolve_asset_json(package, frame_file, reference);
                    Json ability;
                    try { ability = load_json(ability_file); }
                    catch (...)
                    {
                        abilities.push_back({
                            {"slot", slot},
                            {"ability_asset_path", reference},
                            {"resolution_status", "ABILITY_METADATA_MISSING"},
                        });
                        continue;
                    }
                    const Json& data = ability.contains("data") && ability.at("data").is_object()
                        ? ability.at("data") : Json::object();
                    const std::string ability_tag = string_field(data, "LocalizeTag");
                    const std::string localized_ability = localize(names, ability_tag);
                    const std::string ability_asset = asset_path(package, ability_file);
                    const std::string fallback_name = trim_suffix(ability_file.stem().string(), "Ability");
                    const std::string ability_name = localized_ability.empty() ? fallback_name : localized_ability;
                    const std::string identifier = string_field(data, "UniquePowerIdentifier");

                    std::string script;
                    std::string function;
                    if (data.contains("Script") && data.at("Script").is_object())
                    {
                        script = string_field(data.at("Script"), "Script");
                        function = string_field(data.at("Script"), "Function");
                    }

                    std::string module_path;
                    fs::path bytecode_path;
                    std::string body_key;
                    std::string resolution = "SCRIPT_REFERENCE_MISSING";
                    if (!script.empty())
                    {
                        if (script.front() == '/') module_path = script.substr(1);
                        else
                        {
                            const fs::path relative_parent = fs::relative(ability_file.parent_path(), package);
                            module_path = (relative_parent / fs::path(script)).generic_string();
                        }
                        bytecode_path = stock_corpus / corpus_filename(module_path);
                        if (fs::is_regular_file(bytecode_path))
                        {
                            body_key = body_key_hex(read_binary(bytecode_path));
                            resolution = "RESOLVED";
                            ++result.resolved_body_key_count;
                        }
                        else
                        {
                            resolution = "STOCK_BYTECODE_MISSING";
                            ++unresolved_modules;
                        }
                    }

                    abilities.push_back({
                        {"slot", slot},
                        {"name", ability_name},
                        {"name_source", localized_ability.empty() ? "INTERNAL_ASSET_FALLBACK" : "LOCALIZED_NAMES"},
                        {"ability_asset_path", ability_asset},
                        {"ability_localize_tag", ability_tag},
                        {"ability_description_tag", string_field(data, "LocalizeDescTag")},
                        {"ability_identifier", identifier},
                        {"module_path", module_path},
                        {"entry_function", function},
                        {"module_body_key", body_key},
                        {"stock_bytecode_path", bytecode_path.empty() ? "" : bytecode_path.string()},
                        {"resolution_status", resolution},
                    });
                    ++result.ability_count;
                }

                warframes.push_back({
                    {"name", frame_name},
                    {"name_source", localized_frame.empty() ? "ICON_OR_ASSET_FALLBACK" : "LOCALIZED_NAMES"},
                    {"warframe_asset_path", frame_asset},
                    {"warframe_localize_tag", frame_tag},
                    {"abilities", std::move(abilities)},
                });
                ++result.warframe_count;
            }

            std::sort(warframes.begin(), warframes.end(), [](const Json& left, const Json& right) {
                return left.at("name").get<std::string>() < right.at("name").get<std::string>();
            });

            Json catalog{
                {"format", "RENOVICE_ABILITY_CATALOG_V1"},
                {"metadata_snapshot", metadata_snapshot.filename().string()},
                {"metadata_package_root", package.string()},
                {"stock_corpus", stock_corpus.string()},
                {"localized_names", localized_names ? localized_names->string() : ""},
                {"counts", {
                    {"warframes", result.warframe_count},
                    {"abilities", result.ability_count},
                    {"resolved_body_keys", result.resolved_body_key_count},
                    {"unresolved_modules", unresolved_modules},
                    {"unreadable_metadata_files", unreadable_metadata},
                }},
                {"warframes", std::move(warframes)},
            };
            write_atomic(output_path, catalog.dump(2) + "\n");

            if (unreadable_metadata != 0)
            {
                add_diagnostic(result.diagnostics, Severity::warning, "CATALOG_METADATA_SKIPPED",
                    std::to_string(unreadable_metadata) + " metadata files could not be parsed");
            }
            if (unresolved_modules != 0)
            {
                add_diagnostic(result.diagnostics, Severity::warning, "CATALOG_MODULES_UNRESOLVED",
                    std::to_string(unresolved_modules) + " referenced modules were absent from the stock corpus");
            }
            add_diagnostic(result.diagnostics, Severity::info, "CATALOG_BUILT",
                "Cataloged " + std::to_string(result.warframe_count) + " Warframe definitions and "
                + std::to_string(result.ability_count) + " ability slots; "
                + std::to_string(result.resolved_body_key_count) + " body keys resolved from exact stock bytes");
            result.success = result.warframe_count != 0 && result.ability_count != 0;
        }
        catch (const std::exception& exception)
        {
            add_diagnostic(result.diagnostics, Severity::error, "CATALOG_BUILD", exception.what());
        }
        return result;
    }

    SourceRenderResult render_stock_module_source(
        const fs::path& toolchain_root,
        const fs::path& stock_bytecode,
        const fs::path& output_source)
    {
        SourceRenderResult result;
        result.source_path = output_source;
        result.fidelity_source_path = output_source;
        result.fidelity_source_path.replace_extension(".fidelity.luau");
        result.naming_map_path = output_source;
        result.naming_map_path.replace_extension(".names.tsv");
        result.call_map_path = output_source;
        result.call_map_path.replace_extension(".calls.tsv");
        result.closure_map_path = output_source;
        result.closure_map_path.replace_extension(".closures.tsv");
        result.semantic_view_path = output_source;
        result.semantic_view_path.replace_extension(".semantic-view.json");
        try
        {
            const fs::path executable = toolchain_root / "bin" / "derecomp.exe";
            if (!fs::is_regular_file(executable)) throw std::runtime_error("Missing decompiler: " + executable.string());
            if (!fs::is_regular_file(stock_bytecode)) throw std::runtime_error("Missing stock bytecode: " + stock_bytecode.string());
            const fs::path semantic_sdk = semantic_sdk_symbols(toolchain_root);
            fs::create_directories(output_source.parent_path());
            const std::array<fs::path, 6> targets{
                result.fidelity_source_path,
                result.source_path,
                result.naming_map_path,
                result.call_map_path,
                result.closure_map_path,
                result.semantic_view_path,
            };
            const std::array<fs::path, 6> temporary{
                targets[0].string() + ".tmp",
                targets[1].string() + ".tmp",
                targets[2].string() + ".tmp",
                targets[3].string() + ".tmp",
                targets[4].string() + ".tmp",
                targets[5].string() + ".tmp",
            };
            const std::array<fs::path, 2> verification_bytecode{
                targets[1].string() + ".rv.lua_B.tmp",
                targets[0].string() + ".fv.lua_B.tmp",
            };
            for (const fs::path& path : temporary) fs::remove(path);
            for (const fs::path& path : verification_bytecode) fs::remove(path);

            const auto discard_temporary = [&temporary, &verification_bytecode]()
            {
                std::error_code error;
                for (const fs::path& path : temporary) fs::remove(path, error);
                for (const fs::path& path : verification_bytecode) fs::remove(path, error);
            };
            const auto run_derecomp = [&](std::wstring command, const std::string& operation)
            {
                STARTUPINFOW startup{};
                startup.cb = sizeof(startup);
                PROCESS_INFORMATION process{};
                if (!CreateProcessW(nullptr, command.data(), nullptr, nullptr, FALSE, CREATE_NO_WINDOW,
                    nullptr, toolchain_root.c_str(), &startup, &process))
                {
                    const DWORD error = GetLastError();
                    discard_temporary();
                    throw std::runtime_error(
                        "CreateProcessW failed for " + operation + " with Windows error "
                        + std::to_string(error));
                }
                const DWORD wait = WaitForSingleObject(process.hProcess, INFINITE);
                DWORD exit_code = 1;
                const BOOL exit_read = GetExitCodeProcess(process.hProcess, &exit_code);
                CloseHandle(process.hThread);
                CloseHandle(process.hProcess);
                if (wait != WAIT_OBJECT_0 || exit_read == FALSE)
                {
                    discard_temporary();
                    throw std::runtime_error("Unable to collect " + operation + " process result");
                }
                return exit_code;
            };

            std::wstring command = quote_windows(executable)
                + L" semantic-ir-render-module-readable "
                + quote_windows(stock_bytecode) + L" "
                + quote_windows(temporary[0]) + L" "
                + quote_windows(temporary[1]) + L" "
                + quote_windows(temporary[2]) + L" --semantic-sdk "
                + quote_windows(semantic_sdk) + L" --call-map "
                + quote_windows(temporary[3]);
            const DWORD exit_code = run_derecomp(std::move(command), "readable Semantic IR render");
            bool outputs_valid = exit_code == 0;
            for (std::size_t index = 0; index != 4; ++index)
                outputs_valid = outputs_valid && fs::is_regular_file(temporary[index])
                    && fs::file_size(temporary[index]) != 0;
            if (!outputs_valid)
            {
                discard_temporary();
                throw std::runtime_error(
                    "semantic-ir-render-module-readable failed with exit code "
                    + std::to_string(exit_code));
            }

            std::wstring closure_command = quote_windows(executable)
                + L" closure-map " + quote_windows(stock_bytecode) + L" "
                + quote_windows(temporary[4]);
            const DWORD closure_exit = run_derecomp(std::move(closure_command), "closure ownership map");
            if (closure_exit != 0 || !fs::is_regular_file(temporary[4])
                || fs::file_size(temporary[4]) == 0)
            {
                discard_temporary();
                throw std::runtime_error(
                    "closure-map failed with exit code " + std::to_string(closure_exit));
            }

            const SemanticViewBuildResult semantic_view = build_semantic_view(
                temporary[1],
                temporary[0],
                temporary[2],
                temporary[3],
                temporary[4],
                temporary[5]);
            result.diagnostics.insert(
                result.diagnostics.end(),
                semantic_view.diagnostics.begin(),
                semantic_view.diagnostics.end());
            if (!semantic_view.success || !fs::is_regular_file(temporary[5])
                || fs::file_size(temporary[5]) == 0)
            {
                discard_temporary();
                throw std::runtime_error(
                    "semantic source proof rejected the coordinated render");
            }

            const std::array<std::pair<fs::path, std::string>, 2> source_views{
                std::pair{temporary[1], std::string("readable")},
                std::pair{temporary[0], std::string("fidelity")},
            };
            for (std::size_t index = 0; index < source_views.size(); ++index)
            {
                const fs::path& source = source_views[index].first;
                const std::string& label = source_views[index].second;
                std::wstring recompile_command = quote_windows(executable)
                    + L" recompile " + quote_windows(source) + L" "
                    + quote_windows(verification_bytecode[index]);
                const DWORD recompile_exit = run_derecomp(
                    std::move(recompile_command), label + " source recompile/reparse gate");
                if (recompile_exit != 0
                    || !fs::is_regular_file(verification_bytecode[index])
                    || fs::file_size(verification_bytecode[index]) == 0)
                {
                    discard_temporary();
                    throw std::runtime_error(
                        label + " source failed recompile/reparse with exit code "
                        + std::to_string(recompile_exit));
                }

                std::wstring roundtrip_command = quote_windows(executable)
                    + L" de-roundtrip " + quote_windows(verification_bytecode[index]);
                const DWORD roundtrip_exit = run_derecomp(
                    std::move(roundtrip_command), label + " DE container round-trip gate");
                if (roundtrip_exit != 0)
                {
                    discard_temporary();
                    throw std::runtime_error(
                        label + " recompiled container failed exact DE round-trip with exit code "
                        + std::to_string(roundtrip_exit));
                }

                std::wstring plan_command = quote_windows(executable)
                    + L" plan-verify " + quote_windows(verification_bytecode[index]);
                const DWORD plan_exit = run_derecomp(
                    std::move(plan_command), label + " semantic plan gate");
                if (plan_exit != 0)
                {
                    discard_temporary();
                    throw std::runtime_error(
                        label + " recompiled container failed semantic plan verification with exit code "
                        + std::to_string(plan_exit));
                }
            }
            for (const fs::path& path : verification_bytecode) fs::remove(path);

            // Activate the six coordinated files as one recoverable
            // transaction.  Windows has no multi-file atomic rename, so every
            // prior target is preserved and restored if any activation fails.
            std::array<fs::path, 6> backups;
            std::array<bool, 6> had_target{false, false, false, false, false, false};
            std::array<bool, 6> activated{false, false, false, false, false, false};
            std::error_code error;
            for (std::size_t index = 0; index < targets.size(); ++index)
            {
                backups[index] = targets[index].string() + ".readability.bak";
                fs::remove(backups[index], error);
                error.clear();
                had_target[index] = fs::is_regular_file(targets[index]);
                if (had_target[index])
                {
                    fs::rename(targets[index], backups[index], error);
                    if (error) break;
                }
                fs::rename(temporary[index], targets[index], error);
                if (error) break;
                activated[index] = true;
            }
            if (error)
            {
                const std::string activation_error = error.message();
                for (std::size_t index = 0; index < targets.size(); ++index)
                {
                    std::error_code rollback_error;
                    if (activated[index]) fs::remove(targets[index], rollback_error);
                    if (had_target[index] && fs::is_regular_file(backups[index]))
                    {
                        rollback_error.clear();
                        fs::rename(backups[index], targets[index], rollback_error);
                    }
                    fs::remove(temporary[index], rollback_error);
                }
                throw std::runtime_error(
                    "Unable to activate readable source transaction: "
                    + activation_error);
            }
            for (const fs::path& backup : backups) fs::remove(backup, error);
            add_diagnostic(result.diagnostics, Severity::info, "SOURCE_RENDERED",
                "Rendered readable Semantic IR source with fidelity twin and "
                "identity/API-call/closure maps plus a fail-closed semantic proof from "
                + stock_bytecode.filename().string());
            add_diagnostic(result.diagnostics, Severity::info, "SOURCE_VIEWS_GATED",
                "Readable and fidelity sources both recompiled/reparsed, exact-round-tripped, "
                "and passed semantic plan verification before activation");
            result.success = true;
        }
        catch (const std::exception& exception)
        {
            add_diagnostic(result.diagnostics, Severity::error, "SOURCE_RENDER", exception.what());
        }
        return result;
    }
}
