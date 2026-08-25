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
            << "  build PROJECT.json --staging PATH [--no-gates] [--editor-root PATH]\n";
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
            const renovice::BuildResult result = renovice::build_staged_addon(
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

        usage();
        return 2;
    }
    catch (const std::exception& exception)
    {
        std::cerr << "ERROR: " << exception.what() << '\n';
        return 1;
    }
}
