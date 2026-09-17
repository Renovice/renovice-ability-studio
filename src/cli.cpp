#include "renovice/core.hpp"

#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include <windows.h>

namespace
{
    [[nodiscard]] std::filesystem::path executable_path()
    {
        std::wstring buffer(32768, L'\0');
        const DWORD length = GetModuleFileNameW(nullptr, buffer.data(), static_cast<DWORD>(buffer.size()));
        if (length == 0 || length >= buffer.size())
        {
            throw std::runtime_error("GetModuleFileNameW failed");
        }
        buffer.resize(length);
        return std::filesystem::path(buffer);
    }

    void usage()
    {
        std::cout
            << "RENOVICE Ability Editor CLI\n\n"
            << "Commands:\n"
            << "  self-test [--editor-root PATH]\n"
            << "  init-mallet PROJECT.json [--editor-root PATH]\n"
            << "  validate PROJECT.json [--editor-root PATH]\n"
            << "  build PROJECT.json --staging PATH [--no-gates] [--editor-root PATH]\n"
            << "  validate-replacement PROJECT.json --source FILE.luau [--editor-root PATH]\n"
            << "  build-replacement PROJECT.json --source FILE.luau --staging PATH [--baseline STOCK.luau] [--no-gates] [--editor-root PATH]\n"
            << "  deploy BUILD_MANIFEST.json --game-root PATH\n"
            << "  rollback DEPLOYMENT_MANIFEST.json\n"
            << "  build-catalog --metadata PATH --corpus PATH --output catalog.json [--names Names.en.json]\n"
            << "  render-source --toolchain PATH --bytecode FILE.lua_B --output FILE.luau\n";
    }

    [[nodiscard]] std::optional<std::string> option_value(
        const std::vector<std::string>& arguments,
        const std::string& option)
    {
        for (std::size_t index = 0; index + 1 < arguments.size(); ++index)
        {
            if (arguments[index] == option)
            {
                return arguments[index + 1];
            }
        }
        return std::nullopt;
    }

    [[nodiscard]] bool has_option(const std::vector<std::string>& arguments, const std::string& option)
    {
        return std::find(arguments.begin(), arguments.end(), option) != arguments.end();
    }
}

int main(int argc, char** argv)
{
    try
    {
        std::vector<std::string> arguments;
        for (int index = 1; index < argc; ++index)
        {
            arguments.emplace_back(argv[index]);
        }
        if (arguments.empty())
        {
            usage();
            return 2;
        }

        const std::filesystem::path editor_root = option_value(arguments, "--editor-root")
            ? std::filesystem::absolute(*option_value(arguments, "--editor-root"))
            : renovice::locate_editor_root(executable_path());
        const std::string& command = arguments.front();

        if (command == "self-test")
        {
            std::string report;
            const bool pass = renovice::run_self_tests(editor_root, report);
            std::cout << report;
            return pass ? 0 : 1;
        }

        if (command == "init-mallet")
        {
            if (arguments.size() < 2)
            {
                usage();
                return 2;
            }
            const renovice::Json project = renovice::make_linked_overguard_project(renovice::LinkedAddonForm{});
            renovice::save_project(arguments[1], project);
            std::cout << "Created " << std::filesystem::absolute(arguments[1]).string() << '\n';
            return 0;
        }

        if (command == "validate")
        {
            if (arguments.size() < 2)
            {
                usage();
                return 2;
            }
            const renovice::Json project = renovice::load_project(arguments[1]);
            const std::vector<renovice::Diagnostic> diagnostics = renovice::validate_project(project, editor_root);
            std::cout << renovice::diagnostics_text(diagnostics);
            const bool failed = std::any_of(
                diagnostics.begin(), diagnostics.end(), [](const renovice::Diagnostic& diagnostic) {
                    return diagnostic.severity == renovice::Severity::error;
                });
            return failed ? 1 : 0;
        }

        if (command == "build")
        {
            if (arguments.size() < 2)
            {
                usage();
                return 2;
            }
            const std::optional<std::string> staging = option_value(arguments, "--staging");
            if (!staging)
            {
                throw std::runtime_error("build requires --staging PATH");
            }
            const renovice::Json project = renovice::load_project(arguments[1]);
            const bool exact_mission_replacement =
                project.value("authoring_mode", "") == "MANAGED_MISSION_EXACT_REPLACEMENT";
            const renovice::BuildResult result = exact_mission_replacement
                ? renovice::build_staged_exact_mission_replacement(
                    project,
                    editor_root,
                    std::filesystem::absolute(*staging),
                    !has_option(arguments, "--no-gates"))
                : renovice::build_staged_addon(
                    project,
                    editor_root,
                    std::filesystem::absolute(*staging),
                    !has_option(arguments, "--no-gates"));
            std::cout << renovice::diagnostics_text(result.diagnostics);
            if (!result.generation_directory.empty())
            {
                std::cout << "Generation: " << result.generation_directory.string() << '\n';
                std::cout << "Source: " << result.generated_source.string() << '\n';
                std::cout << "Bytecode: " << result.generated_bytecode.string() << '\n';
                std::cout << "Manifest: " << result.manifest.string() << '\n';
            }
            return result.success ? 0 : 1;
        }

        if (command == "validate-replacement")
        {
            if (arguments.size() < 2)
            {
                usage();
                return 2;
            }
            const std::optional<std::string> source = option_value(arguments, "--source");
            if (!source)
            {
                throw std::runtime_error("validate-replacement requires --source FILE.luau");
            }
            const renovice::Json project = renovice::load_project(arguments[1]);
            const std::vector<renovice::Diagnostic> diagnostics =
                renovice::validate_replacement_project(project, std::filesystem::absolute(*source));
            std::cout << renovice::diagnostics_text(diagnostics);
            const bool failed = std::any_of(
                diagnostics.begin(), diagnostics.end(), [](const renovice::Diagnostic& diagnostic) {
                    return diagnostic.severity == renovice::Severity::error;
                });
            return failed ? 1 : 0;
        }

        if (command == "build-replacement")
        {
            if (arguments.size() < 2)
            {
                usage();
                return 2;
            }
            const std::optional<std::string> source = option_value(arguments, "--source");
            const std::optional<std::string> staging = option_value(arguments, "--staging");
            const std::optional<std::string> baseline = option_value(arguments, "--baseline");
            if (!source || !staging)
            {
                throw std::runtime_error("build-replacement requires --source FILE.luau and --staging PATH");
            }
            const renovice::Json project = renovice::load_project(arguments[1]);
            const renovice::BuildResult result = renovice::build_staged_replacement(
                project,
                std::filesystem::absolute(*source),
                editor_root,
                std::filesystem::absolute(*staging),
                !has_option(arguments, "--no-gates"),
                baseline
                    ? std::optional<std::filesystem::path>(std::filesystem::absolute(*baseline))
                    : std::nullopt);
            std::cout << renovice::diagnostics_text(result.diagnostics);
            if (!result.generation_directory.empty())
            {
                std::cout << "Generation: " << result.generation_directory.string() << '\n';
                std::cout << "Source: " << result.generated_source.string() << '\n';
                std::cout << "Bytecode: " << result.generated_bytecode.string() << '\n';
                std::cout << "Manifest: " << result.manifest.string() << '\n';
            }
            return result.success ? 0 : 1;
        }

        if (command == "deploy")
        {
            if (arguments.size() < 2)
            {
                usage();
                return 2;
            }
            const std::optional<std::string> game_root = option_value(arguments, "--game-root");
            if (!game_root)
            {
                throw std::runtime_error("deploy requires --game-root PATH");
            }
            const renovice::DeploymentResult result = renovice::deploy_staged_build(
                std::filesystem::absolute(arguments[1]),
                std::filesystem::absolute(*game_root));
            std::cout << renovice::diagnostics_text(result.diagnostics);
            if (!result.deployment_manifest.empty())
            {
                std::cout << "Deployment manifest: " << result.deployment_manifest.string() << '\n';
                std::cout << "Live target: " << result.live_target.string() << '\n';
            }
            return result.success ? 0 : 1;
        }

        if (command == "rollback")
        {
            if (arguments.size() < 2)
            {
                usage();
                return 2;
            }
            const renovice::DeploymentResult result =
                renovice::rollback_deployment(std::filesystem::absolute(arguments[1]));
            std::cout << renovice::diagnostics_text(result.diagnostics);
            if (!result.deployment_manifest.empty())
            {
                std::cout << "Deployment manifest: " << result.deployment_manifest.string() << '\n';
                std::cout << "Live target: " << result.live_target.string() << '\n';
            }
            return result.success ? 0 : 1;
        }

        if (command == "build-catalog")
        {
            const auto metadata = option_value(arguments, "--metadata");
            const auto corpus = option_value(arguments, "--corpus");
            const auto output = option_value(arguments, "--output");
            if (!metadata || !corpus || !output)
            {
                throw std::runtime_error("build-catalog requires --metadata PATH, --corpus PATH, and --output FILE");
            }
            const auto names = option_value(arguments, "--names");
            const renovice::CatalogBuildResult result = renovice::build_ability_catalog(
                std::filesystem::absolute(*metadata),
                std::filesystem::absolute(*corpus),
                std::filesystem::absolute(*output),
                names ? std::optional<std::filesystem::path>(std::filesystem::absolute(*names)) : std::nullopt);
            std::cout << renovice::diagnostics_text(result.diagnostics);
            std::cout << "Catalog: " << result.catalog_path.string() << '\n'
                      << "Warframes: " << result.warframe_count << '\n'
                      << "Abilities: " << result.ability_count << '\n'
                      << "Resolved body keys: " << result.resolved_body_key_count << '\n';
            return result.success ? 0 : 1;
        }

        if (command == "render-source")
        {
            const auto toolchain = option_value(arguments, "--toolchain");
            const auto bytecode = option_value(arguments, "--bytecode");
            const auto output = option_value(arguments, "--output");
            if (!toolchain || !bytecode || !output)
            {
                throw std::runtime_error("render-source requires --toolchain PATH, --bytecode FILE, and --output FILE");
            }
            const renovice::SourceRenderResult result = renovice::render_stock_module_source(
                std::filesystem::absolute(*toolchain),
                std::filesystem::absolute(*bytecode),
                std::filesystem::absolute(*output));
            std::cout << renovice::diagnostics_text(result.diagnostics);
            if (!result.source_path.empty()) std::cout << "Source: " << result.source_path.string() << '\n';
            if (!result.fidelity_source_path.empty())
                std::cout << "Fidelity source: " << result.fidelity_source_path.string() << '\n';
            if (!result.naming_map_path.empty())
                std::cout << "Name evidence: " << result.naming_map_path.string() << '\n';
            if (!result.call_map_path.empty())
                std::cout << "API callsites: " << result.call_map_path.string() << '\n';
            if (!result.closure_map_path.empty())
                std::cout << "Closure ownership: " << result.closure_map_path.string() << '\n';
            if (!result.semantic_view_path.empty())
                std::cout << "Semantic proof: " << result.semantic_view_path.string() << '\n';
            return result.success ? 0 : 1;
        }

        usage();
        return 2;
    }
    catch (const std::exception& exception)
    {
        std::cerr << "ERROR: " << exception.what() << '\n';
        return 1;
    }
}
