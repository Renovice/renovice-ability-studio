// Universal mission tunable registry (schema 2) and group-by-body-key generator.
//
// REGISTRIES/mission_build_u44.json is a per-client-build registry. Every row names one authoritative owner
// (exact literal site, target-addon capture owner, metadata parameter or server config key) plus the stock
// evidence it was verified against. The generator groups rows by module body key so one body never receives
// competing files, and reuses the existing gates: stock hash, exact preimage, allowed diff, metadata readback,
// addon compile/plan-verify/recompile-u44 and DE round-trip. Presets are views over registry rows.
namespace {
constexpr const char* kMissionRegistryPath = "REGISTRIES/mission_build_u44.json";

Json load_mission_registry(const fs::path& editor_root) {
    Json registry = Json::parse(read_text(editor_root / kMissionRegistryPath));
    if (registry.value("schema", 0) != 2 || registry.value("format", std::string()) != "RENOVICE_MISSION_TUNABLE_REGISTRY_V2")
        throw std::runtime_error("Mission registry is not a schema-2 universal tunable registry");
    if (!registry.contains("build") || !registry.at("build").is_string() || registry.at("build").get<std::string>().empty())
        throw std::runtime_error("Mission registry has no client build label");
    return registry;
}

// The accepted build label comes from the registry. Anything else fails closed.
void require_mission_build(const Json& registry, const Json& build) {
    const auto expected = registry.at("build").get<std::string>();
    if (!build.is_string() || build.get<std::string>() != expected)
        throw std::runtime_error("Unsupported mission build profile '" +
            (build.is_string() ? build.get<std::string>() : std::string("<missing>")) +
            "'; the mission registry is verified only for client build " + expected);
}

const Json& mission_tunable(const Json& registry, const std::string& id) {
    for (const auto& row : registry.at("tunables"))
        if (row.at("tunable_id").get<std::string>() == id) return row;
    throw std::runtime_error("Unknown mission tunable_id: " + id);
}

const Json& mission_module(const Json& registry, const std::string& body) {
    if (!registry.at("modules").contains(body)) throw std::runtime_error("Registry has no module record for body key " + body);
    return registry.at("modules").at(body);
}

std::uint32_t de_name_hash(const std::string& name, const std::uint32_t seed) {
    std::uint32_t x = seed;
    for (const unsigned char c : name) x = (x ^ c) * 0x01000193u;
    x = ~x;
    return (x << 17) | (x >> 15);
}

struct MissionPaths { fs::path workspace; fs::path corpus; fs::path server; };

MissionPaths mission_paths(const Json& registry, const fs::path& editor_root) {
    const fs::path workspace = locate_workspace_root(editor_root);
    return {workspace, workspace / registry.at("corpus").get<std::string>(),
            (workspace / registry.at("server_root").get<std::string>()).lexically_normal()};
}

double mission_site_operand(const Json& site, const double value) {
    const double numerator = site.at("numerator").get<double>();
    return site.value("inverse", false) ? numerator / value : value * numerator / site.at("denominator").get<double>();
}

// Verifies one row's exact owner against the stock evidence the registry names. Throws the exact reason.
void verify_mission_row(const Json& registry, const Json& row, const MissionPaths& paths) {
    const auto backend = row.at("backend").get<std::string>();
    const Json& owner = row.at("owner");
    const auto stock_body = [&](const Json& reference) {
        const auto body = reference.at("body_key").get<std::string>();
        const Json& module = mission_module(registry, body);
        if (module.at("sha256") != reference.at("stock_sha256") || module.at("file") != reference.at("file"))
            throw std::runtime_error("row stock identity disagrees with the module record for body " + body);
        const fs::path file = paths.corpus / module.at("file").get<std::string>();
        if (!fs::exists(file)) throw std::runtime_error("stock body missing from the build corpus: " + file.string());
        if (sha256_file(file) != module.at("sha256").get<std::string>())
            throw std::runtime_error("stock SHA-256 mismatch for body " + body);
        return read_text(file);
    };
    if (backend == "EXACT_LITERAL") {
        const auto bytes = stock_body(owner);
        if (owner.at("sites").empty()) throw std::runtime_error("literal row has no exact site");
        for (const auto& site : owner.at("sites")) {
            const auto kind = site.at("kind").get<std::string>();
            if (kind != "instruction" && kind != "number_constant") throw std::runtime_error("unknown literal site kind " + kind);
            const bool constant = kind == "number_constant";
            const auto offset = site.at("offset").get<std::size_t>();
            const auto expected = site.at("expected").get<std::vector<unsigned int>>();
            const std::size_t width = constant ? 8 : 4;
            if (expected.size() != width || offset > bytes.size() || width > bytes.size() - offset)
                throw std::runtime_error("invalid literal site extent");
            if (constant && (offset == 0 || static_cast<unsigned char>(bytes[offset - 1]) != 2))
                throw std::runtime_error("expected native numeric constant tag before offset " + std::to_string(offset));
            if (!site.value("inverse", false) && site.at("denominator").get<double>() == 0.0)
                throw std::runtime_error("literal site has a zero denominator");
            for (std::size_t n = 0; n < width; ++n)
                if (static_cast<unsigned char>(bytes[offset + n]) != expected[n])
                    throw std::runtime_error("exact preimage changed at offset " + std::to_string(offset));
        }
    } else if (backend == "TARGET_ADDON") {
        static_cast<void>(stock_body(owner));
        const auto body = owner.at("body_key").get<std::string>();
        const Json& module = mission_module(registry, body);
        if (!module.contains("addon") || module.at("addon").at("template") != owner.at("template"))
            throw std::runtime_error("target-addon row has no matching module addon template");
        const Json& bindings = module.at("addon").at("values");
        const auto field = owner.at("generation_field").get<std::string>();
        if (!bindings.contains(field) || bindings.at(field) != row.at("tunable_id"))
            throw std::runtime_error("addon value binding disagrees with the registry row");
    } else if (backend == "METADATA_PATCH") {
        static const std::regex type_pattern("/Lotus/[A-Za-z0-9_/]+");
        static const std::regex field_pattern("Scripts\\.[0-9]+\\.Script\\._[A-Za-z0-9_]+");
        const auto type = owner.at("type").get<std::string>();
        const auto field = owner.at("field").get<std::string>();
        if (!std::regex_match(type, type_pattern) || !std::regex_match(field, field_pattern))
            throw std::runtime_error("invalid metadata owner");
        const Json& consumer = owner.at("consumer");
        const auto consumer_bytes = stock_body(consumer);
        const auto global = consumer.at("global").get<std::string>();
        if ("_" + global != field.substr(field.rfind('.') + 1))
            throw std::runtime_error("consumer global does not match the metadata field");
        const auto seed = static_cast<std::uint32_t>(std::stoul(registry.at("name_hash_seed").get<std::string>(), nullptr, 16));
        const std::uint32_t hash = de_name_hash(global, seed);
        std::ostringstream hex;
        hex << std::hex << std::nouppercase << std::setw(8) << std::setfill('0') << hash;
        if (hex.str() != consumer.at("name_hash").get<std::string>())
            throw std::runtime_error("registered consumer name hash is wrong for " + global);
        std::string little_endian(4, '\0');
        for (std::size_t n = 0; n < 4; ++n) little_endian[n] = static_cast<char>((hash >> (8 * n)) & 255u);
        if (consumer_bytes.find(little_endian) == std::string::npos)
            throw std::runtime_error("consumer body does not reference hashed global " + global + " (unread parameter)");
        const fs::path snapshot_path = paths.corpus / registry.at("metadata_snapshot").at("file").get<std::string>();
        if (!fs::exists(snapshot_path) || sha256_file(snapshot_path) != registry.at("metadata_snapshot").at("sha256").get<std::string>())
            throw std::runtime_error("metadata snapshot missing or SHA-256 mismatch");
        const Json snapshot = Json::parse(read_text(snapshot_path));
        if (snapshot.at("packages_bin_sha256") != owner.at("packages_bin_sha256") || snapshot.at("build") != registry.at("build"))
            throw std::runtime_error("metadata snapshot belongs to another Packages.bin/build");
        if (!snapshot.at("types").contains(type)) throw std::runtime_error("metadata snapshot lacks owner type " + type);
        const Json& record = snapshot.at("types").at(type);
        if (!record.at("fields").contains(field) || record.at("fields").at(field) != owner.at("stock_text"))
            throw std::runtime_error("metadata stock value changed for " + field);
        const auto preimage = owner.at("preimage").get<std::string>();
        if (preimage != field.substr(field.rfind('.') + 1) + "=" + owner.at("stock_text").get<std::string>())
            throw std::runtime_error("metadata preimage disagrees with the owner field");
        if (("\n" + record.at("text").get<std::string>() + "\n").find("\n" + preimage + "\n") == std::string::npos)
            throw std::runtime_error("metadata preimage line missing from the composed owner type");
    } else if (backend == "SERVER_CONFIG") {
        static const std::regex key_pattern("[A-Za-z]+(\\.[A-Za-z]+)+");
        if (!std::regex_match(owner.at("config_key").get<std::string>(), key_pattern))
            throw std::runtime_error("invalid server config key");
        if (!fs::exists(paths.server)) throw std::runtime_error("server source unavailable for read-only verification: " + paths.server.string());
        for (const auto& [file_key, sha_key, preimage_key] : {std::tuple{"schema_file", "schema_sha256", "schema_preimage"},
                                                              std::tuple{"consumer_file", "consumer_sha256", "consumer_preimage"}}) {
            const fs::path file = paths.server / owner.at(file_key).get<std::string>();
            if (!fs::exists(file) || sha256_file(file) != owner.at(sha_key).get<std::string>())
                throw std::runtime_error("server source changed or missing: " + owner.at(file_key).get<std::string>());
            if (read_text(file).find(owner.at(preimage_key).get<std::string>()) == std::string::npos)
                throw std::runtime_error("server preimage missing: " + owner.at(preimage_key).get<std::string>());
        }
    } else {
        throw std::runtime_error("unknown mission backend " + backend);
    }
}

// Registry-wide invariants that do not depend on stock bytes.
void verify_mission_registry_structure(const Json& registry) {
    std::set<std::string> ids;
    std::map<std::string, std::vector<std::tuple<std::size_t, std::size_t, std::string>>> extents;
    for (const auto& row : registry.at("tunables")) {
        const auto id = row.at("tunable_id").get<std::string>();
        if (!ids.insert(id).second) throw std::runtime_error("duplicate tunable_id " + id);
        const Json& limits = row.at("limits");
        if (limits.at("minimum").get<double>() > limits.at("maximum").get<double>())
            throw std::runtime_error(id + ": minimum exceeds maximum");
        if (row.at("stock").is_number() && (row.at("stock").get<double>() < limits.at("minimum").get<double>() ||
                                            row.at("stock").get<double>() > limits.at("maximum").get<double>()))
            throw std::runtime_error(id + ": stock value outside its limits");
        static const std::set<std::string> applies{"restart", "next_mission", "F9", "immediate"};
        if (!applies.contains(row.at("applies").get<std::string>())) throw std::runtime_error(id + ": unknown applies value");
        if (row.at("backend") == "EXACT_LITERAL")
            for (const auto& site : row.at("owner").at("sites")) {
                const auto offset = site.at("offset").get<std::size_t>();
                const std::size_t width = site.at("kind") == "number_constant" ? 8 : 4;
                auto& body = extents[row.at("owner").at("body_key").get<std::string>()];
                for (const auto& [start, size, other] : body)
                    if (offset < start + size && start < offset + width)
                        throw std::runtime_error("competing owners " + other + " and " + id + " overlap at offset " + std::to_string(offset));
                body.emplace_back(offset, width, id);
            }
    }
    for (const auto& [id, preset] : registry.at("missions").items()) {
        const auto lane = preset.at("lane").get<std::string>();
        for (const auto& [name, parameter] : preset.at("parameters").items()) {
            const auto tunable_id = parameter.at("tunable_id").get<std::string>();
            const Json& row = mission_tunable(registry, tunable_id);
            if (row.at("backend") != lane) throw std::runtime_error("preset " + id + "." + name + " lane disagrees with its tunable backend");
            const Json& reference = row.at("backend") == "METADATA_PATCH" ? row.at("owner").at("consumer") : row.at("owner");
            if (reference.contains("body_key") && reference.at("body_key") != preset.at("body_key"))
                throw std::runtime_error("preset " + id + "." + name + " targets another body key");
        }
    }
}

std::map<std::string, double> validate_mission_values(const Json& registry, const Json& values) {
    if (!values.is_object() || values.empty()) throw std::runtime_error("Mission settings must name at least one tunable_id");
    std::map<std::string, double> result;
    for (const auto& [id, value] : values.items()) {
        const Json& row = mission_tunable(registry, id);
        if (!value.is_number()) throw std::runtime_error("Mission value must be a number: " + id);
        const double number = value.get<double>();
        const Json& limits = row.at("limits");
        if (!std::isfinite(number) || number < limits.at("minimum").get<double>() || number > limits.at("maximum").get<double>())
            throw std::runtime_error("Out-of-range mission value: " + id);
        if (limits.value("integer", false) && std::floor(number) != number)
            throw std::runtime_error("Mission value must be a whole number: " + id);
        if (row.at("backend") == "EXACT_LITERAL")
            for (const auto& site : row.at("owner").at("sites")) {
                const double operand = mission_site_operand(site, number);
                if (!std::isfinite(operand) || operand < 1 || operand > 32767 || std::floor(operand) != operand)
                    throw std::runtime_error("Mission value must resolve to an exact positive whole-number operand: " + id);
            }
        result.emplace(id, number);
    }
    return result;
}

// Preset parameters (UI contract) -> registry tunable values.
Json preset_mission_values(const Json& registry, const Json& preset, const Json& values) {
    Json settings = Json::object();
    if (!values.is_object() || values.size() != preset.at("parameters").size())
        throw std::runtime_error("Unexpected mission parameter count");
    for (const auto& [name, parameter] : preset.at("parameters").items()) {
        if (!values.contains(name) || !values.at(name).is_number()) throw std::runtime_error("Missing mission parameter: " + name);
        const double value = values.at(name).get<double>();
        if (!std::isfinite(value) || value < parameter.at("minimum").get<double>() || value > parameter.at("maximum").get<double>())
            throw std::runtime_error("Out-of-range mission parameter: " + name);
        double tunable = value;
        if (parameter.contains("transform")) {
            if (parameter.at("transform").at("kind") != "inverse") throw std::runtime_error("Unknown preset transform for " + name);
            tunable = parameter.at("transform").at("numerator").get<double>() / value;
        }
        const auto id = parameter.at("tunable_id").get<std::string>();
        static_cast<void>(mission_tunable(registry, id));
        settings[id] = tunable;
    }
    return settings;
}

std::string mission_expected_mode(const Json& registry, const Json& preset) {
    const auto lane = preset.at("lane").get<std::string>();
    if (lane == "METADATA_PATCH") return "MANAGED_MISSION_METADATA_PATCH";
    if (lane == "EXACT_LITERAL") return "MANAGED_MISSION_EXACT_REPLACEMENT";
    if (lane == "TARGET_ADDON")
        return mission_module(registry, preset.at("body_key").get<std::string>()).at("addon").at("authoring_mode").get<std::string>();
    throw std::runtime_error("Unknown preset lane " + lane);
}

Json mission_profile_record(const Json& project, const Json& registry) {
    require_mission_build(registry, project.at("mission_profile").at("build"));
    const auto id = project.at("mission_profile").at("id").get<std::string>();
    if (!registry.at("missions").contains(id)) throw std::runtime_error("Unknown mission preset: " + id);
    return registry.at("missions").at(id);
}

std::vector<Diagnostic> validate_profile_mission(const Json& project, const fs::path& editor_root) {
    std::vector<Diagnostic> errors;
    try {
        const Json registry = load_mission_registry(editor_root);
        const Json rec = mission_profile_record(project, registry);
        if (project.at("target").at("module_body_key") != rec.at("body_key") ||
            project.at("target").at("module_path") != rec.at("module_path"))
            throw std::runtime_error("Mission target does not match the verified build profile");
        const Json& values = project.at("mission_profile").at("values");
        const Json settings = preset_mission_values(registry, rec, values);
        if (values.contains("minimum_total_time") && values.at("minimum_total_time").get<double>() > values.at("maximum_total_time").get<double>())
            throw std::runtime_error("Minimum total time exceeds maximum");
        static_cast<void>(validate_mission_values(registry, settings));
        if (project.value("authoring_mode", "") != mission_expected_mode(registry, rec))
            throw std::runtime_error("Mission artifact lane disagrees with the verified profile");
    } catch (const std::exception& e) { add(errors, Severity::error, "MISSION_BUILD_PROFILE", e.what()); }
    return errors;
}

struct MissionNaming {
    std::string label;
    std::string replacement_suffix;
    std::string addon_suffix;
    std::string metadata_file;
    bool single_artifact = false;
};

std::string replace_all(std::string text, const std::string& from, const std::string& to) {
    for (std::size_t pos = 0; (pos = text.find(from, pos)) != std::string::npos; pos += to.size()) text.replace(pos, from.size(), to);
    return text;
}

// Scaffold for the existing verified target-addon templates; every field comes from the registry module record.
Json mission_addon_scaffold(const Json& registry, const std::string& body, const std::map<std::string, double>& values) {
    const Json& module = mission_module(registry, body);
    const Json& spec = module.at("addon");
    Json generation = spec.at("generation");
    generation["template"] = spec.at("template");
    generation["hook_binding"] = spec.at("hook_binding");
    for (const auto& [field, id] : spec.at("values").items()) {
        const auto tunable = id.get<std::string>();
        const auto found = values.find(tunable);
        generation[field] = found != values.end() ? found->second : mission_tunable(registry, tunable).at("stock").get<double>();
    }
    return Json{
        {"project_version", 1},
        {"id", "mission." + body + ".registry-addon"},
        {"status", "READY_TO_BUILD"},
        {"authoring_mode", spec.at("authoring_mode")},
        {"target", {{"warframe", "Mission"}, {"ability", module.at("module_path")}, {"ability_identifier", spec.at("ability_identifier")},
                    {"module_body_key", spec.at("legacy_body_key")}, {"module_path", module.at("module_path")},
                    {"installed_build", registry.at("build")}}},
        {"effect", {{"summary", "Registry-generated mission target addon for body " + body},
                    {"owner", "ADDON"}, {"hook", spec.at("hook_binding")}, {"hook_evidence_id", spec.at("hook_evidence_id")},
                    {"authority", "OWNER"},
                    {"lifetime", "Exact body-keyed target-module generation; reapplied on the next natural module load or F9 refresh."},
                    {"cleanup", "Restores the owned stock values while this generation still owns them."},
                    {"stacking", "One owner write per generation; no polling or repeated setters."}}},
        {"stats", Json::array()},
        {"addon_generation", generation},
        {"deployment", {{"requires_addon", true}, {"requires_card_extension", false}, {"requires_native_module", false}}}};
}

MissionSetResult build_mission_set(const Json& registry, const Json& values_json, const MissionNaming& naming,
                                   const fs::path& editor_root, const fs::path& staging_root, bool run_external_gates,
                                   const Json& project_snapshot) {
    MissionSetResult result;
    try {
        if (!run_external_gates) throw std::runtime_error("Current-build mission export requires all verification gates");
        verify_mission_registry_structure(registry);
        const auto values = validate_mission_values(registry, values_json);
        const MissionPaths paths = mission_paths(registry, editor_root);

        std::map<std::string, std::vector<const Json*>> literal, addon;
        std::vector<const Json*> metadata, server;
        for (const auto& [id, value] : values) {
            static_cast<void>(value);
            const Json& row = mission_tunable(registry, id);
            try { verify_mission_row(registry, row, paths); }
            catch (const std::exception& e) { throw std::runtime_error(id + ": " + e.what()); }
            const auto backend = row.at("backend").get<std::string>();
            if (backend == "EXACT_LITERAL") literal[row.at("owner").at("body_key").get<std::string>()].push_back(&row);
            else if (backend == "TARGET_ADDON") addon[row.at("owner").at("body_key").get<std::string>()].push_back(&row);
            else if (backend == "METADATA_PATCH") metadata.push_back(&row);
            else server.push_back(&row);
        }
        const auto id_list = [](const std::vector<const Json*>& rows) {
            std::string text;
            for (const Json* row : rows) text += (text.empty() ? "" : ", ") + row->at("tunable_id").get<std::string>();
            return text;
        };
        for (const auto& [body, rows] : literal)
            if (addon.contains(body))
                throw std::runtime_error("Body key " + body + " would receive both an exact replacement (" + id_list(rows) +
                                         ") and a target addon (" + id_list(addon.at(body)) + "); one body key may own only one artifact");

        const auto registry_sha = sha256_file(editor_root / kMissionRegistryPath);
        Json normalized = {{"format", "RENOVICE_MISSION_SETTINGS_V1"}, {"build", registry.at("build")}, {"values", Json::object()}};
        for (const auto& [id, value] : values) normalized["values"][id] = value;
        const auto build_hash = sha256_text(staging_root / ".hash-work", naming.label + "\n" + normalized.dump() + "\n" + registry_sha);
        result.directory = staging_root / artifact_stem(naming.label) / build_hash.substr(0, 12);
        fs::create_directories(result.directory / "artifacts");
        fs::create_directories(result.directory / "source");
        write_text(result.directory / "mission_settings.json", normalized.dump(2) + "\n");
        if (!project_snapshot.is_null()) write_text(result.directory / "ability_edit.json", project_snapshot.dump(2) + "\n");

        const auto toolchain = resolve_workspace_path(editor_root, "repos", "de_luau_toolchain");
        const auto compiler = toolchain / "bin/derecomp.exe";
        const auto gate = [&](Json& gates, const std::string& name, const std::string& arguments, const std::string& marker) {
            const auto process = run_process(quote_process_argument(compiler) + " " + arguments, toolchain);
            const bool pass = process.exit_code == 0 && contains_text(process.output, marker);
            result.gate_log += name + "\n" + process.output + "\n";
            gates.push_back({{"name", name}, {"pass", pass}, {"exit_code", process.exit_code}});
            if (!pass) throw std::runtime_error(name + " failed: " + process.output);
        };
        const auto relative = [&](const fs::path& path) { return fs::relative(path, result.directory).generic_string(); };
        Json set_artifacts = Json::array();
        const auto record = [&](const std::string& package_type, const std::string& backend, const std::string& body,
                                const std::vector<const Json*>& rows, const fs::path& source, const fs::path& artifact,
                                const fs::path& stock, const std::string& stock_sha, const std::string& live, const Json& gates) {
            MissionArtifact item;
            item.backend = backend;
            item.body_key = body;
            for (const Json* row : rows) item.tunables.push_back(row->at("tunable_id").get<std::string>());
            item.source = source;
            item.artifact = artifact;
            item.sha256 = sha256_file(artifact);
            item.size = fs::file_size(artifact);
            item.intended_live_relative_path = live;
            item.manifest = result.directory / (naming.single_artifact ? std::string("BUILD_MANIFEST.json")
                                                                        : "BUILD_MANIFEST." + artifact_stem(backend + "." + body) + ".json");
            const Json manifest{{"format", "RENOVICE_ABILITY_EDITOR_BUILD_V1"}, {"package_type", package_type}, {"status", "STAGED_PASS"},
                                {"project_id", naming.label}, {"build_sha256", build_hash}, {"registry_build", registry.at("build")},
                                {"registry_sha256", registry_sha}, {"body_key", body}, {"tunables", item.tunables},
                                {"source", {{"path", relative(source)}, {"sha256", sha256_file(source)}}},
                                {"artifact", {{"path", relative(artifact)}, {"sha256", item.sha256}, {"size", item.size}}},
                                {"stock_artifact", {{"path", stock.string()}, {"sha256", stock_sha}}},
                                {"intended_live_relative_path", live}, {"live_write_performed", false}, {"gates", gates},
                                {"diagnostics", Json::array()}};
            write_text(item.manifest, manifest.dump(2) + "\n");
            set_artifacts.push_back({{"backend", backend}, {"body_key", body}, {"tunables", item.tunables}, {"path", relative(artifact)},
                                     {"sha256", item.sha256}, {"size", item.size}, {"manifest", relative(item.manifest)},
                                     {"intended_live_relative_path", live}});
            result.artifacts.push_back(std::move(item));
        };

        for (const auto& [body, rows] : literal) {
            const Json& module = mission_module(registry, body);
            const fs::path stock = paths.corpus / module.at("file").get<std::string>();
            if (sha256_file(stock) != module.at("sha256").get<std::string>()) throw std::runtime_error("Current mission stock hash mismatch: " + body);
            auto bytes = read_text(stock);
            const auto original = bytes;
            std::set<std::size_t> permitted;
            Json plan = Json::array();
            for (const Json* row : rows) {
                const auto id = row->at("tunable_id").get<std::string>();
                const double value = values.at(id);
                for (const auto& site : row->at("owner").at("sites")) {
                    const auto offset = site.at("offset").get<std::size_t>();
                    const auto expected = site.at("expected").get<std::vector<unsigned int>>();
                    const bool constant = site.at("kind") == "number_constant";
                    const std::size_t width = constant ? 8 : 4;
                    if (expected.size() != width || offset > bytes.size() || width > bytes.size() - offset) throw std::runtime_error("Invalid patch extent");
                    if (constant && (offset == 0 || static_cast<unsigned char>(bytes[offset - 1]) != 2)) throw std::runtime_error("Expected native numeric constant tag");
                    for (std::size_t n = 0; n < width; ++n)
                        if (static_cast<unsigned char>(bytes[offset + n]) != expected[n]) throw std::runtime_error("Verified instruction preimage changed");
                    const int operand = static_cast<int>(mission_site_operand(site, value));
                    if (constant) {
                        const auto bits = std::bit_cast<std::uint64_t>(static_cast<double>(operand));
                        for (std::size_t n = 0; n < 8; ++n) bytes[offset + n] = static_cast<char>((bits >> (8 * n)) & 255);
                    } else {
                        bytes[offset] = static_cast<char>(0x08); // U44 LOADN, from the verified opcode profile.
                        bytes[offset + 1] = static_cast<char>(site.at("register").get<int>());
                        bytes[offset + 2] = static_cast<char>(operand & 255);
                        bytes[offset + 3] = static_cast<char>((operand >> 8) & 255);
                    }
                    for (std::size_t n = 0; n < width; ++n)
                        if (!permitted.insert(offset + n).second) throw std::runtime_error("Competing exact sites overlap at offset " + std::to_string(offset));
                    plan.push_back({{"tunable_id", id}, {"value", value}, {"site", site}, {"operand", operand}});
                }
            }
            for (std::size_t n = 0; n < bytes.size(); ++n)
                if (original[n] != bytes[n] && !permitted.contains(n)) throw std::runtime_error("Unexpected bytecode change");
            const fs::path source = result.directory / "source" / (body + ".plan.json");
            const fs::path artifact = result.directory / "artifacts" / (body + " (" + naming.replacement_suffix + "_exact-replacement).lua_B");
            write_text(source, Json{{"body_key", body}, {"module", module}, {"edits", plan}}.dump(2) + "\n");
            write_text(artifact, bytes);
            Json gates = Json::array();
            gates.push_back({{"name", "current-stock-hash"}, {"pass", true}, {"exit_code", 0}});
            gates.push_back({{"name", "exact-instruction-preimages-and-allowed-diff"}, {"pass", true}, {"exit_code", 0}});
            gate(gates, "de-roundtrip", "de-roundtrip " + quote_process_argument(artifact), "FULL BODY identical: True");
            record("NATIVE_REPLACEMENT", "EXACT_LITERAL", body, rows, source, artifact, stock, module.at("sha256").get<std::string>(),
                   "OpenWF/CustomScripts/" + artifact.filename().string(), gates);
        }

        for (const auto& [body, rows] : addon) {
            const Json& module = mission_module(registry, body);
            const fs::path stock = paths.corpus / module.at("file").get<std::string>();
            const Json scaffold = mission_addon_scaffold(registry, body, values);
            auto source_text = generate_target_addon_source(scaffold, editor_root);
            for (const auto& rewrite : module.at("addon").at("source_rewrites"))
                source_text = replace_all(source_text, rewrite.at(0).get<std::string>(), rewrite.at(1).get<std::string>());
            source_text = "-- Build profile " + registry.at("build").get<std::string>() + "; exact target " + body + "\n" + source_text;
            const fs::path source = result.directory / "source" / (body + ".luau");
            const fs::path artifact = result.directory / "artifacts" / (body + "." + naming.addon_suffix + ".target.addon.lua_B");
            write_text(source, source_text);
            const auto canonical = result.directory / "source" / (body + ".verification-u43.lua_B");
            Json gates = Json::array();
            gates.push_back({{"name", "current-stock-hash"}, {"pass", true}, {"exit_code", 0}});
            gate(gates, "source-compile", "recompile " + quote_process_argument(source) + " " + quote_process_argument(canonical), "re-parses=yes");
            gate(gates, "source-plan", "plan-verify " + quote_process_argument(canonical), "failures=0");
            gate(gates, "u44-compile", "recompile-u44 " + quote_process_argument(source) + " " + quote_process_argument(artifact) + " " +
                 quote_process_argument(toolchain / "profiles/u44/name-map.tsv"), "re-parses=yes");
            gate(gates, "de-roundtrip", "de-roundtrip " + quote_process_argument(artifact), "FULL BODY identical: True");
            record("TARGET_ADDON", "TARGET_ADDON", body, rows, source, artifact, stock, module.at("sha256").get<std::string>(),
                   "OpenWF/CustomScripts/Inject/" + artifact.filename().string(), gates);
        }

        if (!metadata.empty()) {
            std::map<std::string, std::vector<const Json*>> by_type;
            for (const Json* row : metadata) by_type[row->at("owner").at("type").get<std::string>()].push_back(row);
            std::string text;
            Json plan = Json::array();
            for (const auto& [type, rows] : by_type) {
                text += type + "\n";
                for (const Json* row : rows) {
                    const auto id = row->at("tunable_id").get<std::string>();
                    text += "    q|" + row->at("owner").at("field").get<std::string>() + "|" + format_number(values.at(id)) + "\n";
                    plan.push_back({{"tunable_id", id}, {"value", values.at(id)}, {"owner", row->at("owner")}});
                }
            }
            const fs::path source = result.directory / "source" / "metadata.plan.json";
            const fs::path artifact = result.directory / "artifacts" / naming.metadata_file;
            write_text(source, plan.dump(2) + "\n");
            write_text(artifact, text);
            if (read_text(artifact) != text) throw std::runtime_error("Metadata artifact readback mismatch");
            Json gates = Json::array();
            gates.push_back({{"name", "current-stock-hash"}, {"pass", true}, {"exit_code", 0}});
            gates.push_back({{"name", "verified-metadata-binding-and-output-readback"}, {"pass", true}, {"exit_code", 0}});
            const fs::path snapshot = paths.corpus / registry.at("metadata_snapshot").at("file").get<std::string>();
            record("METADATA_PATCH", "METADATA_PATCH", "metadata", metadata, source, artifact, snapshot,
                   registry.at("metadata_snapshot").at("sha256").get<std::string>(), "OpenWF/Metadata Patches/" + naming.metadata_file, gates);
        }

        Json server_diff = nullptr;
        if (!server.empty()) {
            Json changes = Json::array(), patch = Json::object();
            for (const Json* row : server) {
                const auto id = row->at("tunable_id").get<std::string>();
                const auto key = row->at("owner").at("config_key").get<std::string>();
                changes.push_back({{"tunable_id", id}, {"config_key", key}, {"stock", row->at("stock")}, {"value", values.at(id)},
                                   {"applies", row->at("applies")}, {"schema_sha256", row->at("owner").at("schema_sha256")}});
                Json* cursor = &patch;
                std::size_t start = 0;
                for (std::size_t dot; (dot = key.find('.', start)) != std::string::npos; start = dot + 1) cursor = &(*cursor)[key.substr(start, dot - start)];
                (*cursor)[key.substr(start)] = values.at(id);
            }
            result.server_config_diff = result.directory / "artifacts" / "server-config-diff.json";
            write_text(result.server_config_diff, Json{{"format", "RENOVICE_SERVER_CONFIG_DIFF_V1"}, {"build", registry.at("build")},
                                                       {"server_root", registry.at("server_root")}, {"applied", false},
                                                       {"note", "Review and apply manually (config.json or /custom/setConfig); the generator never writes the server."},
                                                       {"changes", changes}, {"config_patch", patch}}.dump(2) + "\n");
            server_diff = {{"path", relative(result.server_config_diff)}, {"sha256", sha256_file(result.server_config_diff)}, {"applied", false}};
        }
        if (naming.single_artifact && (result.artifacts.size() != 1 || !server.empty()))
            throw std::runtime_error("A preset build must produce exactly one artifact");
        if (result.artifacts.empty() && server.empty()) throw std::runtime_error("Mission settings produced no artifact");

        result.manifest = result.directory / "MISSION_SET_MANIFEST.json";
        write_text(result.manifest, Json{{"format", "RENOVICE_MISSION_SET_BUILD_V1"}, {"status", "STAGED_PASS"}, {"label", naming.label},
                                         {"registry_build", registry.at("build")}, {"registry_sha256", registry_sha},
                                         {"settings_sha256", sha256_file(result.directory / "mission_settings.json")},
                                         {"artifacts", set_artifacts}, {"server_config_diff", server_diff},
                                         {"live_write_performed", false},
                                         {"evidence_boundary", "Offline gates only; in-game behaviour is not claimed."}}.dump(2) + "\n");
        write_text(result.directory / "BUILD_GATES.log", result.gate_log);
        result.success = true;
    } catch (const std::exception& e) {
        add(result.diagnostics, Severity::error, "MISSION_BUILD_PROFILE", e.what());
        if (!result.directory.empty()) write_text(result.directory / "BUILD_GATES.log", result.gate_log + e.what());
    }
    return result;
}
}

Json verify_mission_registry(const fs::path& editor_root) {
    const Json registry = load_mission_registry(editor_root);
    Json report{{"format", "RENOVICE_MISSION_REGISTRY_VERIFICATION_V1"}, {"build", registry.at("build")},
                {"registry_sha256", sha256_file(editor_root / kMissionRegistryPath)}, {"rows", registry.at("tunables").size()},
                {"excluded", registry.at("excluded").size()}, {"presets", registry.at("missions").size()},
                {"by_backend", Json::object()}, {"failures", Json::array()}};
    std::size_t pass = 0;
    try { verify_mission_registry_structure(registry); report["structure"] = "PASS"; }
    catch (const std::exception& e) { report["structure"] = std::string("FAIL: ") + e.what(); }
    const MissionPaths paths = mission_paths(registry, editor_root);
    for (const auto& row : registry.at("tunables")) {
        const auto backend = row.at("backend").get<std::string>();
        auto& bucket = report["by_backend"][backend];
        if (bucket.is_null()) bucket = {{"pass", 0}, {"fail", 0}};
        try {
            verify_mission_row(registry, row, paths);
            bucket["pass"] = bucket["pass"].get<int>() + 1;
            ++pass;
        } catch (const std::exception& e) {
            bucket["fail"] = bucket["fail"].get<int>() + 1;
            report["failures"].push_back({{"tunable_id", row.at("tunable_id")}, {"reason", e.what()}});
        }
    }
    report["pass"] = pass;
    report["fail"] = registry.at("tunables").size() - pass;
    report["status"] = report["structure"] == "PASS" && report["fail"] == 0 ? "PASS" : "FAIL";
    return report;
}

MissionSetResult build_mission_settings(const Json& settings, const fs::path& editor_root, const fs::path& staging_root, bool run_external_gates) {
    try {
        const Json registry = load_mission_registry(editor_root);
        if (!settings.is_object() || settings.value("format", std::string("RENOVICE_MISSION_SETTINGS_V1")) != "RENOVICE_MISSION_SETTINGS_V1")
            throw std::runtime_error("Mission settings must be a RENOVICE_MISSION_SETTINGS_V1 object");
        require_mission_build(registry, settings.contains("build") ? settings.at("build") : Json());
        if (!settings.contains("values")) throw std::runtime_error("Mission settings have no values object");
        return build_mission_set(registry, settings.at("values"), MissionNaming{"missions", "missions", "missions", "RENOVICE_Missions.txt", false},
                                 editor_root, staging_root, run_external_gates, nullptr);
    } catch (const std::exception& e) {
        MissionSetResult result;
        add(result.diagnostics, Severity::error, "MISSION_BUILD_PROFILE", e.what());
        return result;
    }
}

BuildResult build_profile_mission(const Json& project, const fs::path& editor_root, const fs::path& staging_root, bool run_external_gates) {
    BuildResult result;
    result.diagnostics = validate_profile_mission(project, editor_root);
    if (has_errors(result.diagnostics)) return result;
    try {
        const Json registry = load_mission_registry(editor_root);
        const Json preset = mission_profile_record(project, registry);
        const auto id = project.at("mission_profile").at("id").get<std::string>();
        const Json values = preset_mission_values(registry, preset, project.at("mission_profile").at("values"));
        const auto set = build_mission_set(registry, values,
                                           MissionNaming{project.at("id").get<std::string>(), "mission_" + id + "_timers", "mission_" + id, id + ".txt", true},
                                           editor_root, staging_root, run_external_gates, project);
        result.diagnostics.insert(result.diagnostics.end(), set.diagnostics.begin(), set.diagnostics.end());
        result.gate_log = set.gate_log;
        result.generation_directory = set.directory;
        if (!set.success) return result;
        const MissionArtifact& artifact = set.artifacts.front();
        if (artifact.body_key != "metadata" && artifact.body_key != preset.at("body_key").get<std::string>())
            throw std::runtime_error("Preset artifact targets an unexpected body key");
        result.project_snapshot = set.directory / "ability_edit.json";
        result.generated_source = artifact.source;
        result.generated_bytecode = artifact.artifact;
        result.manifest = artifact.manifest;
        result.success = true;
    } catch (const std::exception& e) {
        add(result.diagnostics, Severity::error, "MISSION_BUILD_PROFILE", e.what());
    }
    return result;
}
