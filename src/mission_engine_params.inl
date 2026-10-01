// ENGINE_PARAM_OVERRIDE recipe emission (2026-10-01, contract CONTRACT_PHASE1.md Revision R16).
//
// A SCRIPT_PARAM_GLOBAL_AT_ENTRY row writes a level/encounter parameter into the called instance's environment once, at
// the entry (R10). The engine's own parameter writer (44.0.2 apply_param 0x181CAE0) writes the level value into that
// environment again on later engine paths (R15), so readers that run after a yield of the same instance can see the
// level value instead. Rows the registrar admitted as EXPOSED (owner.engine_override, gate ENGINE_PARAM_OVERRIDE_V1) are
// also emitted as declarations in `Packages/Missions/engine_params.json`: the bootstrapper's native hook on that writer
// adjusts the value on every engine write (stock x value, stock / value, value, or the R11 count rule).
//
// Compatibility: the addon keeps its R10 entry write for these rows. A bootstrapper with the native lane installed
// withholds the row values from the addon's context.settings (the native lane owns them, no double application); an older
// DLL ignores engine_params.json and the addon keeps the value (the R10 fallback).
//
// Included by mission_profiles.inl (inside its anonymous namespace), after mission_live_literals.inl.

constexpr const char* kEngineParamsFormat = "RENOVICE_ENGINE_PARAMS_V1";
constexpr const char* kEngineParamsFile = "engine_params.json";
constexpr const char* kEngineOverrideGate = "ENGINE_PARAM_OVERRIDE_V1";

struct EngineParamsOutput {
    Json record = nullptr;   // MISSION_SET_MANIFEST package.engine_params (nullptr: no override row in this build)
};

// Emits engine_params.json for every value of the addon member whose registry row carries an engine_override, and runs
// the gate `engine-param-overrides`:
//   * the row is a TARGET_ADDON SCRIPT_PARAM_GLOBAL_AT_ENTRY row whose owner re-verifies against the pinned stock bytes
//     (verify_mission_row), admitted with gate ENGINE_PARAM_OVERRIDE_V1;
//   * every parameter global of the row is declared (no partial override), each hash is the U44 name hash of its name;
//   * the mode is the row's own mode (the same arithmetic as the addon's R10/R11 write);
//   * no master knob drives the row (a master would keep driving the addon write the bootstrapper withholds);
//   * the value is declared by this member (type int or float).
EngineParamsOutput emit_engine_param_recipe(const Json& registry, const MissionPaths& paths, const fs::path& package_dir,
                                            const std::string& member_file, const std::vector<std::string>& member_ids,
                                            const Json& member_values, MissionSetResult& result) {
    EngineParamsOutput output;
    const auto seed = static_cast<std::uint32_t>(std::stoul(registry.at("name_hash_seed").get<std::string>(), nullptr, 16));
    static const std::set<std::string> modes{"scale", "scale_inverse", "absolute", "scale_count"};
    std::set<std::string> driven;
    if (registry.contains("ui_masters"))
        for (const auto& [master_id, master] : registry.at("ui_masters").items()) {
            static_cast<void>(master_id);
            if (master.contains("drives"))
                for (const auto& drive : master.at("drives")) driven.insert(drive.at("tunable_id").get<std::string>());
        }
    nlohmann::ordered_json overrides = nlohmann::ordered_json::array();
    std::set<std::string> modules;
    std::vector<std::string> rows;
    for (const auto& id : member_ids) {
        if (mission_master(registry, id) != nullptr) continue;
        const Json& row = mission_tunable(registry, id);
        const Json& owner = row.at("owner");
        if (!owner.is_object() || !owner.contains("engine_override")) continue;
        const Json& engine = owner.at("engine_override");
        const auto where = id + ": ";
        if (row.at("backend") != "TARGET_ADDON" || owner.value("template", std::string()) != kScriptParamTemplate)
            throw std::runtime_error("engine-param-overrides gate failed: " + where + "not a SCRIPT_PARAM_GLOBAL_AT_ENTRY row");
        if (engine.value("gate", std::string()) != kEngineOverrideGate || engine.value("exposure", std::string()).rfind("EXPOSED", 0) != 0)
            throw std::runtime_error("engine-param-overrides gate failed: " + where + "no ENGINE_PARAM_OVERRIDE_V1 admission");
        try { verify_mission_row(registry, row, paths); }
        catch (const std::exception& e) { throw std::runtime_error("engine-param-overrides gate failed: " + where + e.what()); }
        const auto mode = owner.at("mode").get<std::string>();
        if (!modes.contains(mode) || engine.value("mode", std::string()) != mode)
            throw std::runtime_error("engine-param-overrides gate failed: " + where + "mode differs from the row's own mode");
        if (driven.contains(id))
            throw std::runtime_error("engine-param-overrides gate failed: " + where + "a master knob drives this row");
        if (!member_values.contains(id) || (member_values.at(id).value("type", std::string()) != "float" &&
                                            member_values.at(id).value("type", std::string()) != "int"))
            throw std::runtime_error("engine-param-overrides gate failed: " + where + "not an int/float value of " + member_file);
        const Json& globals = owner.at("globals");
        const Json& parameters = engine.at("parameters");
        if (!globals.is_array() || globals.empty() || parameters != globals)
            throw std::runtime_error("engine-param-overrides gate failed: " + where + "the override does not cover every parameter global");
        for (const auto& global : globals) {
            const auto name = global.at("name").get<std::string>();
            std::ostringstream hex;
            hex << std::hex << std::nouppercase << std::setw(8) << std::setfill('0') << de_name_hash(name, seed);
            if (hex.str() != global.at("hash").get<std::string>())
                throw std::runtime_error("engine-param-overrides gate failed: " + where + "hash of " + name + " is not its U44 name hash");
            nlohmann::ordered_json item = nlohmann::ordered_json::object();
            item["value"] = id;
            item["module"] = owner.at("body_key");
            item["parameter"] = name;
            item["hash"] = hex.str();
            item["mode"] = mode;
            overrides.push_back(item);
        }
        modules.insert(owner.at("body_key").get<std::string>());
        rows.push_back(id);
    }
    if (rows.empty()) return output;
    nlohmann::ordered_json recipe = nlohmann::ordered_json::object();
    recipe["format"] = kEngineParamsFormat;
    recipe["package"] = "package:" + ascii_lower_text(kMissionPackageName);
    recipe["build"] = registry.at("build");
    recipe["member"] = member_file;
    recipe["overrides"] = overrides;
    const fs::path recipe_path = package_dir / kEngineParamsFile;
    write_text(recipe_path, recipe.dump(2) + "\n");
    if (nlohmann::ordered_json::parse(read_text(recipe_path)) != recipe) throw std::runtime_error("engine_params.json readback mismatch");
    result.gate_log += "engine-param-overrides\nPASS rows=" + std::to_string(rows.size()) + " overrides=" +
                       std::to_string(overrides.size()) + " modules=" + std::to_string(modules.size()) + " member=" + member_file + "\n";
    output.record = {{"path", fs::relative(recipe_path, result.directory).generic_string()}, {"sha256", sha256_file(recipe_path)}, {"format", kEngineParamsFormat},
                     {"rows", rows}, {"overrides", overrides.size()}, {"modules", modules.size()},
                     {"note", "Needs the R16 ENGINE_PARAM_OVERRIDE bootstrapper; older DLLs ignore it and the addon keeps the value."}};
    return output;
}
