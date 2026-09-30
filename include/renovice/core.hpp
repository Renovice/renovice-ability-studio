#pragma once

#include <cstdint>
#include <filesystem>
#include <optional>
#include <string>
#include <vector>

#include <nlohmann/json.hpp>

namespace renovice
{
    namespace fs = std::filesystem;
    using Json = nlohmann::json;

    [[nodiscard]] Json discover_card_stats(const std::string& source, const Json& names, const std::string& body_key);
    [[nodiscard]] Json discover_card_stats_file(const fs::path& source, const fs::path& names, const std::string& body_key);
    [[nodiscard]] Json discover_linked_card_stats_file(const fs::path& source, const fs::path& names, const std::string& body_key, const fs::path& editor_root);
    [[nodiscard]] Json discover_automatic_card_links(const std::string& source, const Json& card_report);

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

    struct MissionArtifact
    {
        std::string backend;
        std::string body_key;
        std::vector<std::string> tunables;
        fs::path source;
        fs::path artifact;
        fs::path manifest;
        std::string sha256;
        std::uintmax_t size = 0;
        std::string intended_live_relative_path;
        std::vector<std::string> target_keys;  // multi-target addon only: declared module body keys
        std::vector<std::string> masters;      // contract R5: master knobs this member declares
    };

    struct MissionSetResult
    {
        bool success = false;
        fs::path directory;
        fs::path manifest;
        fs::path server_config_diff;
        fs::path package_directory;  // settings output_layout "package": Packages/Missions (install-ready)
        std::vector<MissionArtifact> artifacts;
        std::vector<Diagnostic> diagnostics;
        std::string gate_log;
    };

    struct DeploymentResult
    {
        bool success = false;
        fs::path deployment_manifest;
        fs::path live_target;
        std::vector<Diagnostic> diagnostics;
    };

    struct CatalogBuildResult
    {
        bool success = false;
        fs::path catalog_path;
        std::size_t warframe_count = 0;
        std::size_t ability_count = 0;
        std::size_t resolved_body_key_count = 0;
        std::vector<Diagnostic> diagnostics;
    };

    struct SourceRenderResult
    {
        bool success = false;
        fs::path source_path;
        fs::path fidelity_source_path;
        fs::path naming_map_path;
        fs::path call_map_path;
        fs::path closure_map_path;
        fs::path semantic_view_path;
        std::vector<Diagnostic> diagnostics;
    };

    struct SemanticViewBuildResult
    {
        bool success = false;
        fs::path output_path;
        std::size_t token_count = 0;
        std::size_t naming_row_count = 0;
        std::size_t mapped_occurrence_count = 0;
        std::size_t alias_occurrence_count = 0;
        std::size_t canonical_retained_count = 0;
        std::size_t sidecar_only_count = 0;
        std::size_t closure_site_count = 0;
        std::size_t closure_capture_count = 0;
        std::size_t export_count = 0;
        std::size_t omitted_dead_orphan_prototype_count = 0;
        std::size_t api_callsite_count = 0;
        std::size_t api_call_expression_count = 0;
        std::size_t registered_api_callsite_count = 0;
        std::size_t confirmed_api_callsite_count = 0;
        std::size_t unresolved_api_callsite_count = 0;
        std::size_t unregistered_api_callsite_count = 0;
        std::size_t ambiguous_api_callsite_count = 0;
        std::size_t observed_mismatch_api_callsite_count = 0;
        std::vector<Diagnostic> diagnostics;
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
        std::string installed_build = "private-live-2026-09-07";
        std::string hook_binding = "renovice.mallet.damage_dispatch";
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
        std::string native_method = "PushFloatArg";
        int native_prototype = 16;
        int native_instruction = 596;
        int native_argument = 2;
        double native_expected_value = 1.0;
        double native_replacement_value = 5.0;
        std::string native_evidence = "WF-V49-MALLET-PUSHFLOATARG-P16-I596";
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
    [[nodiscard]] BuildResult build_staged_exact_mission_replacement(
        const Json& project,
        const fs::path& editor_root,
        const fs::path& staging_root,
        bool run_external_gates = true);
    // Universal mission tunable registry (REGISTRIES/mission_build_u44.json, schema 2).
    // Verifies every registered row against the stock evidence it names; never writes files.
    [[nodiscard]] Json verify_mission_registry(const fs::path& editor_root);
    // Builds a mission_settings.json ({"build", "values": {tunable_id: number}}) into at most one artifact per
    // module body key, one metadata patch file and one server-config diff (written, never applied).
    [[nodiscard]] MissionSetResult build_mission_settings(
        const Json& settings,
        const fs::path& editor_root,
        const fs::path& staging_root,
        bool run_external_gates = true);
    [[nodiscard]] std::vector<Diagnostic> validate_replacement_project(
        const Json& project,
        const fs::path& source_path);
    [[nodiscard]] BuildResult build_staged_replacement(
        const Json& project,
        const fs::path& source_path,
        const fs::path& editor_root,
        const fs::path& staging_root,
        bool run_external_gates = true,
        const std::optional<fs::path>& api_baseline_source = std::nullopt);
    [[nodiscard]] DeploymentResult deploy_staged_build(
        const fs::path& build_manifest,
        const fs::path& game_root);
    [[nodiscard]] DeploymentResult rollback_deployment(
        const fs::path& deployment_manifest);
    [[nodiscard]] CatalogBuildResult build_ability_catalog(
        const fs::path& metadata_snapshot,
        const fs::path& stock_corpus,
        const fs::path& output_path,
        const std::optional<fs::path>& localized_names = std::nullopt);
    [[nodiscard]] SourceRenderResult render_stock_module_source(
        const fs::path& toolchain_root,
        const fs::path& stock_bytecode,
        const fs::path& output_source);
    [[nodiscard]] SemanticViewBuildResult build_semantic_view(
        const fs::path& readable_source,
        const fs::path& fidelity_source,
        const fs::path& naming_map,
        const fs::path& call_map,
        const fs::path& closure_map,
        const fs::path& output_path);
    [[nodiscard]] bool run_self_tests(const fs::path& editor_root, std::string& report);
    [[nodiscard]] std::string diagnostics_text(const std::vector<Diagnostic>& diagnostics);
    [[nodiscard]] std::string severity_name(Severity severity);
}
