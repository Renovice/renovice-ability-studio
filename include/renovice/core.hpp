#pragma once

#include <filesystem>
#include <optional>
#include <string>
#include <vector>

#include <nlohmann/json.hpp>

namespace renovice
{
    namespace fs = std::filesystem;
    using Json = nlohmann::json;

    enum class Severity
    {
        info,
        warning,
        error,
    };

    struct Diagnostic
    {
        Severity severity;
        std::string code;
        std::string message;
    };

    struct BuildResult
    {
        bool success = false;
        fs::path generation_directory;
        fs::path project_snapshot;
        fs::path generated_source;
        fs::path generated_bytecode;
        fs::path manifest;
        std::vector<Diagnostic> diagnostics;
        std::string gate_log;
    };

    struct LinkedAddonForm
    {
        std::string project_id = "octavia.mallet.overguard";
        std::string warframe = "Octavia";
        std::string ability = "Mallet";
        std::string ability_identifier = "BARD_MUSIC";
        std::string ability_localize_tag = "/Lotus/Language/Suits/BardMusicAbilityName";
        std::string module_path = "Lotus/Powersuits/Bard/Abilities/BardMusic.lua";
        std::string module_body_key = "08faf07b504d058f";
        std::string installed_build = "private-live-2026-08-25";
        std::string hook_binding = "renovice.mallet.damage_dispatch";
        std::string handler_slot = "RENOVICE_AFTER_MALLET_DAMAGE";
        std::string rate_id = "damage_to_overguard";
        std::string rate_label = "Overguard From Damage";
        double base_percent = 1.0;
        double maximum_percent = 5.0;
        std::string modifier_family = "STRENGTH";
        std::string modifier_binding = "mallet.strength.channel_10";
        std::string modifier_evidence = "WF-STOCK-BARD-BOXLOOP;WF-LIVE-MALLET-2026-08-23";
        std::string cap_id = "overguard_cap";
        std::string cap_label = "Overguard Cap";
        double cap_value = 15000.0;
        std::string trace_prefix = "mallet.addon";
    };

    [[nodiscard]] fs::path locate_editor_root(const fs::path& executable_path);
    [[nodiscard]] Json load_project(const fs::path& path);
    void save_project(const fs::path& path, const Json& project);
    [[nodiscard]] Json make_linked_overguard_project(const LinkedAddonForm& form);
    [[nodiscard]] std::vector<Diagnostic> validate_project(
        const Json& project,
        const fs::path& editor_root);
    [[nodiscard]] std::string generate_target_addon_source(
        const Json& project,
        const fs::path& editor_root);
    [[nodiscard]] BuildResult build_staged_addon(
        const Json& project,
        const fs::path& editor_root,
        const fs::path& staging_root,
        bool run_external_gates = true);
    [[nodiscard]] bool run_self_tests(const fs::path& editor_root, std::string& report);
    [[nodiscard]] std::string diagnostics_text(const std::vector<Diagnostic>& diagnostics);
    [[nodiscard]] std::string severity_name(Severity severity);
}
