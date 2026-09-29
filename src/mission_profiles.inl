// Universal mission tunable registry (schema 2) and group-by-body-key generator.
//
// REGISTRIES/mission_build_u44.json is a per-client-build registry. Every row names one authoritative owner
// (exact literal site, target-addon capture owner, metadata parameter or server config key) plus the stock
// evidence it was verified against. The generator groups rows by module body key so one body never receives
// competing files, and reuses the existing gates: stock hash, exact preimage, allowed diff, metadata readback,
// addon compile/plan-verify/recompile-u44 and DE round-trip. Presets are views over registry rows.
//
// Phase 2e: root-table fields are routed through the target-addon lane (generic ROOT_TABLE_FIELD generator, gate
// ROOT_TABLE_UPVALUE_V1), so fields that share a bytecode constant are independent controls. Per body key: all rows
// addon-capable -> one addon; otherwise all rows literal-capable (root-table rows keep `literal_owner`) -> one merged
// exact replacement; otherwise fail closed naming the addon-only and literal-only rows.
//
// Phase 2g: a settings build emits every addon-lane body key into ONE multi-target addon
// (`Inject\Missions.targets.addon.lua_B`, one Scripts row) with per-instance root-table binding. Exact replacements stay
// separate files, one per body key. Presets keep their established single-key files.
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

constexpr const char* kConstantExclusivityGate = "K_CONSTANT_EXCLUSIVE_V1";

// The exact literal form of a row: the owner of an EXACT_LITERAL row, or the `literal_owner` a root-table row keeps
// for merged replacements. Null when the row has no literal form.
const Json* mission_literal_owner(const Json& row) {
    if (row.at("backend") == "EXACT_LITERAL") return &row.at("owner");
    return row.contains("literal_owner") ? &row.at("literal_owner") : nullptr;
}

// Operand domain of one literal site: a native f64 constant holds any finite number (the row limits bound it); a LOADN
// immediate must be a whole number in 1..32767.
void check_literal_operand(const Json& site, const double value, const std::string& id) {
    const double operand = mission_site_operand(site, value);
    if (site.at("kind") == "number_constant") {
        if (!std::isfinite(operand)) throw std::runtime_error("Mission value must resolve to a finite constant: " + id);
    } else if (!std::isfinite(operand) || operand < 1 || operand > 32767 || std::floor(operand) != operand) {
        throw std::runtime_error("Mission value must resolve to an exact positive whole-number operand: " + id);
    }
}

// A number constant is shared by every instruction and table-template entry that names it. Editing one therefore
// needs the registrar's K_CONSTANT_EXCLUSIVE_V1 proof (computed on the pinned stock bytes): the complete use set of the
// constant is the declared owner, and a table-template owner is consumed by exactly one DUPTABLE outside any loop whose
// initialiser is live. The SHA-256 pin makes the proof binding; this check rejects rows without it or with an
// inconsistent one.
void verify_constant_exclusivity(const Json& site) {
    if (!site.contains("gate") || !site.at("gate").is_object())
        throw std::runtime_error("number-constant site has no constant-exclusivity gate evidence");
    const Json& gate = site.at("gate");
    if (gate.value("gate", std::string()) != kConstantExclusivityGate)
        throw std::runtime_error("number-constant site gate is not " + std::string(kConstantExclusivityGate));
    if (gate.at("prototype") != site.at("prototype") || gate.at("constant") != site.at("constant"))
        throw std::runtime_error("constant-exclusivity gate names another prototype/constant");
    const Json& uses = gate.at("uses");
    if (!uses.is_array() || uses.empty()) throw std::runtime_error("constant-exclusivity gate lists no uses");
    std::size_t template_uses = 0;
    for (const auto& use : uses) {
        if (use.contains("template")) ++template_uses;
        else if (!use.contains("instruction")) throw std::runtime_error("constant-exclusivity use is neither an instruction nor a template entry");
    }
    if (template_uses == 0) return;
    // Single-use template gate: exactly one template entry and exactly one DUPTABLE construction site.
    if (template_uses != 1 || uses.size() != 1)
        throw std::runtime_error("template value constant is shared by several owners");
    const Json& constructions = gate.at("template_uses");
    if (!constructions.is_array() || constructions.size() != 1 || constructions.at(0).value("op", std::string()) != "DUPTABLE")
        throw std::runtime_error("table template is not consumed by exactly one DUPTABLE construction site");
    if (!gate.value("loop_free", false) || !gate.value("initialiser_live", false))
        throw std::runtime_error("table template construction is inside a loop or its initialiser is overwritten");
}

constexpr const char* kRootTableAddonTemplate = "ROOT_TABLE_FIELD";
constexpr const char* kRootTableGate = "ROOT_TABLE_UPVALUE_V1";

// Every mission target addon (generic ROOT_TABLE_FIELD and the established Survival/Interception/timer templates) acts
// only from hooks.luaCalls[P].before, i.e. hook binding renovice.target.lua_call. Its runtime status comes from
// REGISTRIES/hook_registry.tsv, the same authority validate_project uses for HOOK_UNPROVEN. The 44.0.2 live test
// (2026-09-29) proved the failure mode of an unproven binding: the addon attaches (TARGET ADDON PASS) but the runtime
// never dispatches a before-hook, so nothing is written. While the binding is not LIVE_CONFIRMED the automatic lane
// therefore uses the exact literal form of a row when it has one and reports NEEDS_BINDING for addon-only rows. Settings
// may name the binding in allow_unproven_hook_bindings to build the addon for a live acceptance run; the manifest records
// the binding status either way.
constexpr const char* kMissionAddonHookBinding = "renovice.target.lua_call";

struct MissionHookStatus {
    std::string status;
    bool live = false;    // LIVE_CONFIRMED in the hook registry
    bool opt_in = false;  // not live, explicitly allowed by the settings for an acceptance run
};

MissionHookStatus mission_addon_hook_status(const fs::path& editor_root, const std::vector<std::string>& allowed) {
    const auto rows = load_registry(editor_root / "REGISTRIES" / "hook_registry.tsv");
    const RegistryRow* hook = find_binding(rows, kMissionAddonHookBinding);
    if (hook == nullptr) throw std::runtime_error(std::string("Hook binding is not registered: ") + kMissionAddonHookBinding);
    MissionHookStatus result;
    result.status = hook->at("status");
    result.live = result.status == "LIVE_CONFIRMED";
    result.opt_in = !result.live && std::find(allowed.begin(), allowed.end(), kMissionAddonHookBinding) != allowed.end();
    return result;
}

Json mission_hook_record(const MissionHookStatus& hook) {
    return {{"binding", kMissionAddonHookBinding}, {"registry_status", hook.status}, {"live_confirmed", hook.live},
            {"built_by_explicit_opt_in", hook.opt_in}};
}

// A root-table field owned through the target-addon lane (registrar gate ROOT_TABLE_UPVALUE_V1, pinned by the body
// SHA-256): the module root builds the table once, the table leaves the root only by closure capture, every capturing
// prototype is hooked (luaCalls[P].before) and one of them reads the field. The addon writes the live table field, so a
// shared bytecode constant does not matter. This check re-verifies the recorded evidence: the stock initialiser bytes
// at the recorded offset encode the registered stock value, and the table record names hooks with valid access paths.
void verify_root_table_fields(const Json& row, const Json& module, const std::string& bytes) {
    static const std::regex field_name("[A-Za-z_][A-Za-z0-9_]*");
    const Json& owner = row.at("owner");
    if (owner.value("gate", std::string()) != kRootTableGate) throw std::runtime_error("root-table addon row has no ROOT_TABLE_UPVALUE_V1 gate");
    if (!owner.at("fields").is_array() || owner.at("fields").empty()) throw std::runtime_error("root-table addon row owns no field");
    if (!row.at("stock").is_number()) throw std::runtime_error("root-table addon row has no numeric stock value");
    const auto key_ok = [&](const Json& key) {
        return (key.is_string() && std::regex_match(key.get<std::string>(), field_name)) || (key.is_number_integer() && key.get<long long>() >= 1);
    };
    for (const auto& field : owner.at("fields")) {
        const auto table_id = field.at("table_id").get<std::string>();
        if (!module.contains("root_tables") || !module.at("root_tables").contains(table_id))
            throw std::runtime_error("module record has no root table " + table_id);
        const Json& table = module.at("root_tables").at(table_id);
        if (table.value("gate", std::string()) != kRootTableGate) throw std::runtime_error("root table " + table_id + " has no gate evidence");
        if (!key_ok(field.at("field"))) throw std::runtime_error("invalid root-table field key in " + table_id);
        const Json& hooks = table.at("hooks");
        if (!hooks.is_array() || hooks.empty()) throw std::runtime_error("root table " + table_id + " has no hooked capturer");
        std::set<int> prototypes;
        for (const auto& hook : hooks) {
            if (hook.at("prototype").get<int>() < 0 || hook.at("upvalue").get<int>() < 1 || !prototypes.insert(hook.at("prototype").get<int>()).second)
                throw std::runtime_error("root table " + table_id + " has an invalid or duplicate hook");
            for (const auto& key : hook.at("path"))
                if (!key_ok(key)) throw std::runtime_error("root table " + table_id + " hook path is invalid");
        }
        if (field.value("field_reads", 0) < 1) throw std::runtime_error("no consumer read recorded for " + table_id);
        const auto offset = field.at("value_offset").get<std::size_t>();
        const auto expected = field.at("expected").get<std::vector<unsigned int>>();
        const bool constant = field.at("value_kind") == "number_constant";
        const std::size_t width = constant ? 8 : 4;
        if (expected.size() != width || offset > bytes.size() || width > bytes.size() - offset)
            throw std::runtime_error("invalid root-table initialiser extent");
        for (std::size_t n = 0; n < width; ++n)
            if (static_cast<unsigned char>(bytes[offset + n]) != expected[n])
                throw std::runtime_error("root-table initialiser preimage changed at offset " + std::to_string(offset));
        double stock = 0;
        if (constant) {
            if (offset == 0 || static_cast<unsigned char>(bytes[offset - 1]) != 2)
                throw std::runtime_error("expected native numeric constant tag before offset " + std::to_string(offset));
            std::uint64_t bits = 0;
            for (std::size_t n = 0; n < 8; ++n) bits |= static_cast<std::uint64_t>(expected[n]) << (8 * n);
            stock = std::bit_cast<double>(bits);
        } else {
            if (expected[0] != 0x08u) throw std::runtime_error("root-table initialiser is not a LOADN");
            stock = static_cast<double>(static_cast<std::int16_t>(expected[2] | (expected[3] << 8)));
        }
        if (stock != row.at("stock").get<double>())
            throw std::runtime_error("root-table initialiser at offset " + std::to_string(offset) + " disagrees with the registered stock value");
    }
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
    // Exact literal owner (the primary owner of an EXACT_LITERAL row, or the `literal_owner` of a root-table row).
    const auto verify_literal = [&](const Json& literal) {
        const auto bytes = stock_body(literal);
        if (literal.at("sites").empty()) throw std::runtime_error("literal row has no exact site");
        for (const auto& site : literal.at("sites")) {
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
            // A LOADN site must load the registered register. A non-LOADN preimage is allowed only for a carried-over,
            // separately verified linked-result site that the build rewrites into LOADN (flagged by the registrar).
            const bool loadn = !constant && expected[0] == 0x08u;
            if (constant) verify_constant_exclusivity(site);
            else if (loadn ? expected[1] != site.at("register").get<unsigned int>() : !site.value("rewrites_instruction", false))
                throw std::runtime_error("instruction site preimage is not a LOADN of the registered register");
            // The registered stock value must be exactly what the stock operand encodes at every site.
            if ((constant || loadn) && row.at("stock").is_number() && !site.value("inverse", false)) {
                double stock_operand = 0;
                if (constant) {
                    std::uint64_t bits = 0;
                    for (std::size_t n = 0; n < 8; ++n) bits |= static_cast<std::uint64_t>(expected[n]) << (8 * n);
                    stock_operand = std::bit_cast<double>(bits);
                } else {
                    stock_operand = static_cast<double>(static_cast<std::int16_t>(expected[2] | (expected[3] << 8)));
                }
                if (stock_operand != mission_site_operand(site, row.at("stock").get<double>()))
                    throw std::runtime_error("stock operand at offset " + std::to_string(offset) + " disagrees with the registered stock value");
            }
        }
    };
    if (row.contains("literal_owner")) verify_literal(row.at("literal_owner"));
    if (backend == "EXACT_LITERAL") {
        verify_literal(owner);
    } else if (backend == "TARGET_ADDON") {
        const auto bytes = stock_body(owner);
        const auto body = owner.at("body_key").get<std::string>();
        const Json& module = mission_module(registry, body);
        if (owner.at("template") != kRootTableAddonTemplate) {
            if (!module.contains("addon") || module.at("addon").at("template") != owner.at("template"))
                throw std::runtime_error("target-addon row has no matching module addon template");
            const Json& bindings = module.at("addon").at("values");
            const auto field = owner.at("generation_field").get<std::string>();
            if (!bindings.contains(field) || bindings.at(field) != row.at("tunable_id"))
                throw std::runtime_error("addon value binding disagrees with the registry row");
        }
        if (owner.contains("fields")) verify_root_table_fields(row, module, bytes);
        else if (owner.at("template") == kRootTableAddonTemplate) throw std::runtime_error("root-table addon row owns no field");
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
        // The primary field plus every `also` entry (the same parameter in another Scripts entry of the owner type,
        // for example a HUD instance) is one control: all must verify and are always patched together.
        std::vector<Json> entries{Json{{"field", field}, {"stock_text", owner.at("stock_text")}, {"preimage", owner.at("preimage")}}};
        if (owner.contains("also")) for (const auto& entry : owner.at("also")) entries.push_back(entry);
        std::set<std::string> seen_fields;
        for (const auto& entry : entries) {
            const auto path = entry.at("field").get<std::string>();
            if (!std::regex_match(path, field_pattern) || path.substr(path.rfind('.') + 1) != field.substr(field.rfind('.') + 1))
                throw std::runtime_error("metadata entry " + path + " is not the same parameter as " + field);
            if (!seen_fields.insert(path).second) throw std::runtime_error("duplicate metadata entry " + path);
            if (!record.at("fields").contains(path) || record.at("fields").at(path) != entry.at("stock_text"))
                throw std::runtime_error("metadata stock value changed for " + path);
            const auto preimage = entry.at("preimage").get<std::string>();
            if (preimage != path.substr(path.rfind('.') + 1) + "=" + entry.at("stock_text").get<std::string>())
                throw std::runtime_error("metadata preimage disagrees with the owner field");
            if (("\n" + record.at("text").get<std::string>() + "\n").find("\n" + preimage + "\n") == std::string::npos)
                throw std::runtime_error("metadata preimage line missing from the composed owner type");
        }
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

// Phase 2i: in-game settings editor fields (registrar tools/editor_fields.py; design
// work/research/universal-mission-editor-2026-09-29/INGAME_EDITOR_DESIGN.md sections 3.2, 3.3 and 4.6). Every registry row
// carries a `ui` object; package builds turn it into the `settings` declarations of package.json that the bootstrapper's
// ADDON_SETTINGS_V1 primitive validates. The composed row labels are budgeted here so the native GenericSettings rows never
// truncate: CHECKBOX "Custom <label>" <= 40 characters, TITLE (group label upper-cased) <= 48.
constexpr const char* kMissionUiFormat = "RENOVICE_MISSION_UI_FIELDS_V1";
constexpr const char* kSettingsDeclarationFormat = "RENOVICE_SETTINGS_DECL_V1";
constexpr const char* kScriptSettingsFormat = "RENOVICE_SCRIPT_SETTINGS_V1";
constexpr std::size_t kSettingsLabelBudget = 40;    // value rows, composed "Custom <label>"
constexpr std::size_t kSettingsTitleBudget = 48;    // TITLE rows
constexpr std::size_t kSettingsTextMaximum = 64;    // runtime bound for labels and aliases
constexpr std::size_t kSettingsScopeMaximum = 256;  // runtime bound for scope text
constexpr std::size_t kSettingsUnitMaximum = 16;
constexpr std::size_t kSettingsMaximumValues = 4096;
constexpr std::size_t kSettingsMaximumAliases = 1024;
constexpr const char* kSettingsCheckboxPrefix = "Custom ";

bool settings_printable(const std::string& text) {
    return std::all_of(text.begin(), text.end(), [](const char c) { return c >= 0x20 && c < 0x7f; });
}

std::string settings_upper(std::string text) {
    std::transform(text.begin(), text.end(), text.begin(), [](const unsigned char c) { return static_cast<char>(std::toupper(c)); });
    return text;
}

std::string settings_lane(const std::string& backend) {
    if (backend == "TARGET_ADDON") return "addon";
    if (backend == "EXACT_LITERAL") return "literal";
    if (backend == "METADATA_PATCH") return "metadata";
    if (backend == "SERVER_CONFIG") return "server";
    throw std::runtime_error("unknown mission backend " + backend);
}

// Apply timing is a property of the lane (design section 5): an addon write is seen at the game's next read of the field,
// an exact replacement at the next module load (next mission), a metadata patch at the next game start.
std::string settings_applies(const std::string& lane) {
    if (lane == "addon") return "live_next_read";
    if (lane == "literal") return "next_mission";
    if (lane == "metadata") return "restart";
    return "server_reload";
}

bool settings_whole(const Json& number) {
    return number.is_number_integer() || (number.is_number_float() && std::floor(number.get<double>()) == number.get<double>());
}

// Structural check of the registry `ui` fields; throws the first exact reason.
void verify_mission_ui(const Json& registry) {
    static const std::regex group_id("[a-z0-9_]{1,64}");
    if (registry.value("ui_format", std::string()) != kMissionUiFormat) throw std::runtime_error("registry has no RENOVICE_MISSION_UI_FIELDS_V1 ui fields");
    const Json& groups = registry.at("ui_groups");
    if (!groups.is_object() || groups.empty()) throw std::runtime_error("registry ui_groups is empty");
    std::set<long long> orders;
    for (const auto& [id, group] : groups.items()) {
        const auto label = group.at("label").get<std::string>();
        if (!std::regex_match(id, group_id)) throw std::runtime_error("invalid ui group id " + id);
        if (label.empty() || !settings_printable(label) || label.size() > kSettingsLabelBudget || settings_upper(label).size() > kSettingsTitleBudget)
            throw std::runtime_error("ui group " + id + " label is empty, not printable ASCII or over its budget");
        if (!group.at("order").is_number_integer() || !orders.insert(group.at("order").get<long long>()).second)
            throw std::runtime_error("ui group " + id + " order is not a unique integer");
        if (!group.at("aliases").is_array() || group.at("aliases").size() > kSettingsMaximumAliases)
            throw std::runtime_error("ui group " + id + " aliases are not a bounded array");
        for (const auto& alias : group.at("aliases"))
            if (!alias.is_string() || alias.get<std::string>().empty() || alias.get<std::string>().size() > kSettingsTextMaximum ||
                !settings_printable(alias.get<std::string>()))
                throw std::runtime_error("ui group " + id + " has an invalid alias");
    }
    std::set<std::string> labels;
    for (const auto& row : registry.at("tunables")) {
        const auto id = row.at("tunable_id").get<std::string>();
        if (!row.contains("ui") || !row.at("ui").is_object()) throw std::runtime_error(id + ": no ui fields");
        const Json& ui = row.at("ui");
        const auto group = ui.at("group").get<std::string>();
        if (!groups.contains(group) || id.substr(0, id.find('.')) != group) throw std::runtime_error(id + ": ui group is not its tunable_id family");
        const auto label = ui.at("short_label").get<std::string>();
        if (label.empty() || !settings_printable(label) || label.front() == ' ' || label.back() == ' ' ||
            std::string(kSettingsCheckboxPrefix).size() + label.size() > kSettingsLabelBudget)
            throw std::runtime_error(id + ": short_label is empty, not printable ASCII or over the " + std::to_string(kSettingsLabelBudget) +
                                     "-character row budget");
        std::string folded = label;
        std::transform(folded.begin(), folded.end(), folded.begin(), [](const unsigned char c) { return static_cast<char>(std::tolower(c)); });
        if (!labels.insert(group + "|" + folded).second) throw std::runtime_error(id + ": short_label is not unique in group " + group);
        const auto scope = ui.at("scope_text").get<std::string>();
        if (scope.empty() || scope.size() > kSettingsScopeMaximum || !settings_printable(scope))
            throw std::runtime_error(id + ": scope_text is empty, not printable ASCII or over " + std::to_string(kSettingsScopeMaximum) + " characters");
        const auto lane = settings_lane(row.at("backend").get<std::string>());
        if (ui.at("lane") != lane || ui.at("applies") != settings_applies(lane)) throw std::runtime_error(id + ": ui lane/applies disagree with the backend");
        const Json& limits = row.at("limits");
        if (ui.at("min") != limits.at("minimum") || ui.at("max") != limits.at("maximum")) throw std::runtime_error(id + ": ui min/max disagree with limits");
        const auto type = ui.at("type").get<std::string>();
        const auto editor = ui.at("editor").get<std::string>();
        const bool integer = limits.value("integer", false);
        if (type == "enum") {
            if (editor != "TOGGLE" || !ui.contains("options") || !ui.at("options").is_array() || ui.at("options").empty())
                throw std::runtime_error(id + ": enum value needs TOGGLE and options");
        } else if (type == "int") {
            if (!integer || editor != (limits.at("minimum").get<double>() >= 0 ? "INPUTCOUNT" : "INPUTBOX") || ui.contains("options"))
                throw std::runtime_error(id + ": int value editor/limits disagree");
            if ((row.at("stock").is_number() && !settings_whole(row.at("stock"))) || !settings_whole(limits.at("minimum")) || !settings_whole(limits.at("maximum")))
                throw std::runtime_error(id + ": int value has a fractional stock or limit");
        } else if (type == "float") {
            if (integer || editor != "INPUTBOX" || ui.contains("options")) throw std::runtime_error(id + ": float value editor/limits disagree");
        } else {
            throw std::runtime_error(id + ": unknown ui type " + type);
        }
        const auto unit = ui.at("unit").get<std::string>();
        if (unit.size() > kSettingsUnitMaximum || !settings_printable(unit)) throw std::runtime_error(id + ": ui unit is not a short printable text");
    }
}

// Declaration of one value (design section 3.2), copied from the registry row: stock is the registry stock.
Json mission_value_declaration(const Json& row) {
    const Json& ui = row.at("ui");
    Json declaration{{"group", ui.at("group")}, {"label", ui.at("short_label")}, {"unit", ui.at("unit")}, {"type", ui.at("type")},
                     {"stock", row.at("stock")}, {"min", ui.at("min")}, {"max", ui.at("max")}, {"scope", ui.at("scope_text")},
                     {"lane", ui.at("lane")}, {"applies", ui.at("applies")}};
    if (ui.contains("options")) declaration["options"] = ui.at("options");
    return declaration;
}

Json mission_group_declaration(const Json& registry, const std::string& id) {
    const Json& group = registry.at("ui_groups").at(id);
    return Json{{"id", id}, {"label", group.at("label")}, {"order", group.at("order")}, {"aliases", group.at("aliases")}};
}

// Strict schema check of package.json `settings` declarations (top level and per member), mirroring the design's runtime
// parser: exact field sets, types, bounds, value ranges, group references. Returns every problem found (empty = valid).
std::vector<std::string> validate_settings_declarations(const Json& package_json) {
    static const std::regex group_id("[a-z0-9_]{1,64}");
    static const std::regex value_id("[A-Za-z0-9_.]{1,128}");
    // "stock_check" is the optional R1 field (bootstrapper dd5414c): "live" (the default when absent) or "none", addon lane only.
    static const std::set<std::string> value_fields{"group", "label", "unit", "type", "stock", "min", "max", "scope", "lane", "applies", "options", "stock_check"};
    static const std::set<std::string> types{"int", "float", "enum"}, lanes{"addon", "literal", "metadata"},
        applies{"live_next_read", "next_instance", "next_mission", "restart"};
    std::vector<std::string> problems;
    const auto text_ok = [](const Json& value, const std::size_t maximum, const bool allow_empty) {
        return value.is_string() && (allow_empty || !value.get<std::string>().empty()) && value.get<std::string>().size() <= maximum &&
               settings_printable(value.get<std::string>());
    };
    if (!package_json.is_object() || !package_json.contains("settings") || !package_json.at("settings").is_object()) {
        problems.push_back("package.json has no settings object");
        return problems;
    }
    const Json& top = package_json.at("settings");
    for (const auto& [key, value] : top.items()) {
        static_cast<void>(value);
        if (key != "format" && key != "build" && key != "groups") problems.push_back("settings has unknown field " + key);
    }
    if (top.value("format", std::string()) != kSettingsDeclarationFormat) problems.push_back("settings.format is not RENOVICE_SETTINGS_DECL_V1");
    if (!top.contains("build") || !text_ok(top.at("build"), kSettingsTextMaximum, false)) problems.push_back("settings.build is not a build label");
    std::set<std::string> declared_groups, used_groups;
    if (!top.contains("groups") || !top.at("groups").is_array()) {
        problems.push_back("settings.groups is not an array");
    } else {
        for (const auto& group : top.at("groups")) {
            if (!group.is_object()) { problems.push_back("settings.groups entry is not an object"); continue; }
            for (const auto& [key, value] : group.items()) {
                static_cast<void>(value);
                if (key != "id" && key != "label" && key != "order" && key != "aliases") problems.push_back("group has unknown field " + key);
            }
            const std::string id = group.contains("id") && group.at("id").is_string() ? group.at("id").get<std::string>() : std::string();
            if (!std::regex_match(id, group_id)) problems.push_back("group id '" + id + "' is invalid");
            else if (!declared_groups.insert(id).second) problems.push_back("group " + id + " is declared twice");
            if (!group.contains("label") || !text_ok(group.at("label"), kSettingsTextMaximum, false)) problems.push_back("group " + id + " label is invalid");
            if (!group.contains("order") || !group.at("order").is_number_integer()) problems.push_back("group " + id + " order is not an integer");
            if (!group.contains("aliases") || !group.at("aliases").is_array() || group.at("aliases").size() > kSettingsMaximumAliases) {
                problems.push_back("group " + id + " aliases are not a bounded array");
            } else {
                for (const auto& alias : group.at("aliases"))
                    if (!text_ok(alias, kSettingsTextMaximum, false)) problems.push_back("group " + id + " has an invalid alias");
            }
        }
    }
    std::set<std::string> ids;
    if (!package_json.contains("members") || !package_json.at("members").is_object()) {
        problems.push_back("package.json has no members object");
        return problems;
    }
    for (const auto& [file, member] : package_json.at("members").items()) {
        if (!member.is_object() || !member.contains("settings")) continue;
        const Json& settings = member.at("settings");
        if (!settings.is_object() || settings.size() != 1 || !settings.contains("values") || !settings.at("values").is_object()) {
            problems.push_back(file + ": member settings must be exactly { \"values\": { ... } }");
            continue;
        }
        for (const auto& [id, value] : settings.at("values").items()) {
            const std::string where = file + ": " + id;
            if (!std::regex_match(id, value_id)) problems.push_back(where + ": invalid value id");
            if (!ids.insert(id).second) problems.push_back(where + ": value id declared twice in the package");
            if (!value.is_object()) { problems.push_back(where + ": declaration is not an object"); continue; }
            for (const auto& [key, field] : value.items()) {
                static_cast<void>(field);
                if (!value_fields.contains(key)) problems.push_back(where + ": unknown field " + key);
            }
            for (const char* key : {"group", "label", "unit", "type", "stock", "min", "max", "scope", "lane", "applies"})
                if (!value.contains(key)) problems.push_back(where + ": missing field " + key);
            if (value.contains("group") && value.at("group").is_string()) used_groups.insert(value.at("group").get<std::string>());
            if (value.contains("group") && (!value.at("group").is_string() || !declared_groups.contains(value.at("group").get<std::string>())))
                problems.push_back(where + ": group is not declared");
            if (value.contains("label") && !text_ok(value.at("label"), kSettingsTextMaximum, false)) problems.push_back(where + ": label is invalid");
            if (value.contains("unit") && !text_ok(value.at("unit"), kSettingsUnitMaximum, true)) problems.push_back(where + ": unit is invalid");
            if (value.contains("scope") && !text_ok(value.at("scope"), kSettingsScopeMaximum, false)) problems.push_back(where + ": scope is invalid");
            const std::string type = value.contains("type") && value.at("type").is_string() ? value.at("type").get<std::string>() : std::string();
            if (!types.contains(type)) problems.push_back(where + ": type is not int, float or enum");
            if (value.contains("lane") && (!value.at("lane").is_string() || !lanes.contains(value.at("lane").get<std::string>())))
                problems.push_back(where + ": lane is not addon, literal or metadata");
            if (value.contains("applies") && (!value.at("applies").is_string() || !applies.contains(value.at("applies").get<std::string>())))
                problems.push_back(where + ": applies is not a known apply class");
            if (value.contains("stock_check")) {
                const Json& check = value.at("stock_check");
                if (!check.is_string() || (check.get<std::string>() != "live" && check.get<std::string>() != "none"))
                    problems.push_back(where + ": stock_check is not live or none");
                else if (!value.contains("lane") || !value.at("lane").is_string() || value.at("lane").get<std::string>() != "addon")
                    problems.push_back(where + ": stock_check is allowed only on the addon lane");
            }
            bool numbers = true;
            for (const char* key : {"stock", "min", "max"})
                if (!value.contains(key) || !value.at(key).is_number() || !std::isfinite(value.at(key).get<double>())) numbers = false;
            if (!numbers) {
                problems.push_back(where + ": stock/min/max are not finite numbers");
            } else {
                const double stock = value.at("stock").get<double>(), low = value.at("min").get<double>(), high = value.at("max").get<double>();
                if (low > high || stock < low || stock > high) problems.push_back(where + ": stock is outside min..max");
                if (type == "int" && (!settings_whole(value.at("stock")) || !settings_whole(value.at("min")) || !settings_whole(value.at("max"))))
                    problems.push_back(where + ": int value has a fractional stock or bound");
            }
            if (type == "enum") {
                bool stock_listed = false;
                if (!value.contains("options") || !value.at("options").is_array() || value.at("options").empty()) {
                    problems.push_back(where + ": enum has no options");
                } else {
                    for (const auto& option : value.at("options")) {
                        if (!option.is_object() || option.size() != 2 || !option.contains("label") || !option.contains("value") ||
                            !text_ok(option.at("label"), kSettingsTextMaximum, false) || !option.at("value").is_number())
                            problems.push_back(where + ": enum option must be { \"label\", \"value\" }");
                        else if (numbers && option.at("value").get<double>() == value.at("stock").get<double>())
                            stock_listed = true;
                    }
                    if (!stock_listed) problems.push_back(where + ": enum stock is not one of its options");
                }
            } else if (value.contains("options")) {
                problems.push_back(where + ": options are allowed only for enums");
            }
        }
    }
    if (ids.size() > kSettingsMaximumValues) problems.push_back("more than 4096 values in one package");
    for (const auto& group : declared_groups)
        if (!used_groups.contains(group)) problems.push_back("group " + group + " is declared but no value uses it");
    return problems;
}

// Row-label budget of one declaration (design section 4.6 item 3).
std::vector<std::string> settings_label_budget_problems(const std::string& id, const Json& declaration, const Json& group) {
    std::vector<std::string> problems;
    const auto label = declaration.at("label").get<std::string>();
    if (std::string(kSettingsCheckboxPrefix).size() + label.size() > kSettingsLabelBudget)
        problems.push_back(id + ": row label \"Custom " + label + "\" is over " + std::to_string(kSettingsLabelBudget) + " characters");
    const auto title = settings_upper(group.at("label").get<std::string>());
    if (title.size() > kSettingsTitleBudget) problems.push_back(id + ": group title " + title + " is over " + std::to_string(kSettingsTitleBudget) + " characters");
    return problems;
}

// Compiled values of a generated multi-target addon source: `[id] = { value = V, stock = S },` per value.
std::map<std::string, std::pair<double, double>> multi_target_compiled_values(const std::string& source) {
    static const std::regex entry("\\[\"([A-Za-z0-9_.]+)\"\\] = \\{ value = ([^,]+), stock = ([^ ]+) \\},");
    std::map<std::string, std::pair<double, double>> values;
    for (auto it = std::sregex_iterator(source.begin(), source.end(), entry); it != std::sregex_iterator(); ++it)
        if (!values.emplace((*it)[1].str(), std::pair{std::stod((*it)[2].str()), std::stod((*it)[3].str())}).second)
            throw std::runtime_error("compiled value " + (*it)[1].str() + " appears twice");
    return values;
}

// A settings value as JSON: whole numbers of int/enum declarations are written as integers.
Json settings_number(const double value, const std::string& type) {
    if (type != "float" && std::floor(value) == value && std::abs(value) < 9.0e15) return Json(static_cast<long long>(value));
    return Json(value);
}

// Registry-wide invariants that do not depend on stock bytes.
void verify_mission_registry_structure(const Json& registry) {
    std::set<std::string> ids;
    std::map<std::string, std::vector<std::tuple<std::size_t, std::size_t, std::string>>> extents;
    std::map<std::string, std::string> metadata_owners, addon_owners;
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
        if (const Json* literal = mission_literal_owner(row))
            for (const auto& site : literal->at("sites")) {
                const auto offset = site.at("offset").get<std::size_t>();
                const std::size_t width = site.at("kind") == "number_constant" ? 8 : 4;
                auto& body = extents[literal->at("body_key").get<std::string>()];
                for (const auto& [start, size, other] : body)
                    if (offset < start + size && start < offset + width)
                        throw std::runtime_error("competing owners " + other + " and " + id + " overlap at offset " + std::to_string(offset));
                body.emplace_back(offset, width, id);
            }
        if (row.at("backend") == "TARGET_ADDON" && row.at("owner").contains("fields"))
            for (const auto& field : row.at("owner").at("fields")) {
                const auto key = row.at("owner").at("body_key").get<std::string>() + "|" + field.at("table_id").get<std::string>() + "|" + field.at("field").dump();
                if (const auto found = addon_owners.find(key); found != addon_owners.end() && found->second != id)
                    throw std::runtime_error("competing owners " + found->second + " and " + id + " for root-table field " + key);
                addon_owners.emplace(key, id);
            }
        if (row.at("backend") == "METADATA_PATCH") {
            const Json& owner = row.at("owner");
            std::vector<std::string> fields{owner.at("field").get<std::string>()};
            if (owner.contains("also")) for (const auto& entry : owner.at("also")) fields.push_back(entry.at("field").get<std::string>());
            for (const auto& field : fields) {
                const auto key = owner.at("type").get<std::string>() + "|" + field;
                if (const auto found = metadata_owners.find(key); found != metadata_owners.end())
                    throw std::runtime_error("competing owners " + found->second + " and " + id + " for metadata " + key);
                metadata_owners.emplace(key, id);
            }
        }
    }
    for (const auto& [id, preset] : registry.at("missions").items()) {
        const auto lane = preset.at("lane").get<std::string>();
        for (const auto& [name, parameter] : preset.at("parameters").items()) {
            const auto tunable_id = parameter.at("tunable_id").get<std::string>();
            const Json& row = mission_tunable(registry, tunable_id);
            // A preset keeps its established lane; a root-table row routed to the addon lane still serves an
            // EXACT_LITERAL preset through its exact literal form.
            if (row.at("backend") != lane && !(lane == "EXACT_LITERAL" && row.contains("literal_owner")))
                throw std::runtime_error("preset " + id + "." + name + " lane disagrees with its tunable backend");
            const Json& reference = row.at("backend") == "METADATA_PATCH" ? row.at("owner").at("consumer") : row.at("owner");
            if (reference.contains("body_key") && reference.at("body_key") != preset.at("body_key"))
                throw std::runtime_error("preset " + id + "." + name + " targets another body key");
        }
    }
    verify_mission_ui(registry);
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
            for (const auto& site : row.at("owner").at("sites")) check_literal_operand(site, number, id);
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
    std::string lane;  // a preset forces its established lane; empty = choose per body key
    std::vector<std::string> allow_unproven_hooks;  // settings.allow_unproven_hook_bindings (live acceptance runs only)
    // settings.output_layout == "package": also emit the Lua artifacts as ONE optional bootstrapper folder package,
    // Packages\Missions\ (bootstrapper feat/script-packages-2026-09-29). The default "loose" layout is unchanged.
    bool package_layout = false;
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

// Phase 2g: settings builds emit ONE multi-target addon, `Inject\Missions.targets.addon.lua_B`, for every body key on the
// addon lane (bootstrapper contract `RESEARCH/MULTI_TARGET_ADDON_AND_ROOT_BINDING_2026-09-29`, branch
// feat/multi-target-addon 67cd256): one Scripts row, one enable state, `return { targets = { ["<key>"] = entry } }`, no
// top-level hooks. Every lowercase 16-hex string constant in the compiled file is a declared target key, so the keys
// appear only as `targets` keys; the build re-reads the compiled string pool exactly as the loader does and fails closed
// on any other lowercase 16-hex text in the source or the pool. Presets keep their established single-key files.
constexpr const char* kMultiTargetAddonName = "Missions";
// Optional folder package layout (bootstrapper feat/script-packages-2026-09-29, `renovice/packages_core.hpp`): one
// `CustomScripts\Packages\Missions\` folder holds the multi-target addon, the exact replacements and a strict
// `package.json`; the Scripts menu shows ONE row `[PACKAGE] Missions`, policy `package:missions`. Limits mirror the
// loader: display name <= 64, member label <= 128, description <= 1024 printable characters, members are replacement
// (`<16-hex key> (...).lua_B`) or target-addon files only.
constexpr const char* kMissionPackageName = "Missions";
constexpr std::size_t kPackageLabelMaximum = 128;
constexpr std::size_t kPackageDescriptionMaximum = 1024;

std::string ascii_lower_text(std::string text) {
    std::transform(text.begin(), text.end(), text.begin(), [](const unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return text;
}

// Printable-ASCII and length rule shared with the loader's package.json parser (control characters are rejected).
std::string package_text(std::string text, const std::size_t maximum) {
    for (char& c : text)
        if (static_cast<unsigned char>(c) < 0x20 || static_cast<unsigned char>(c) >= 0x7f) c = ' ';
    if (text.size() > maximum) text = text.substr(0, maximum - 3) + "...";
    return text;
}

// Registry module paths are dotted module names (`Lotus.Scripts.Modes.SurvivalMission`): the label uses the last part.
std::string module_short_name(const std::string& module_path) {
    const auto separator = module_path.find_last_of("./\\");
    return separator == std::string::npos || separator + 1 == module_path.size() ? module_path : module_path.substr(separator + 1);
}
constexpr std::size_t kMultiTargetMaximumKeys = 1024;          // bootstrapper maximum_multi_target_keys
constexpr std::uintmax_t kMultiTargetMaximumBytes = 1024 * 1024;  // contract: smaller than 1 MiB

bool lowercase_hex_digit(const char c) { return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f'); }

// Declared target keys of a compiled DE container, read like the loader's discover_multi_target_keys
// (`09 03 | varint count | {varint length, bytes}...`; a declaration is a pool string of exactly 16 lowercase hex digits).
std::set<std::string> multi_target_declared_keys(const std::string& bytes) {
    const auto read_varint = [&](std::size_t& offset) {
        std::uint64_t value = 0;
        for (unsigned shift = 0; shift < 35; shift += 7) {
            if (offset >= bytes.size()) throw std::runtime_error("multi-target string pool is truncated");
            const auto byte = static_cast<unsigned char>(bytes[offset++]);
            value |= static_cast<std::uint64_t>(byte & 0x7fu) << shift;
            if ((byte & 0x80u) == 0) return value;
        }
        throw std::runtime_error("multi-target string pool varint is unterminated");
    };
    if (bytes.size() < 3 || static_cast<unsigned char>(bytes[0]) != 0x09 || static_cast<unsigned char>(bytes[1]) != 0x03)
        throw std::runtime_error("multi-target artifact is not a DE 09 03 container");
    std::size_t offset = 2;
    const std::uint64_t count = read_varint(offset);
    if (count > bytes.size()) throw std::runtime_error("multi-target string pool count is implausible");
    std::set<std::string> keys;
    for (std::uint64_t n = 0; n < count; ++n) {
        const std::uint64_t length = read_varint(offset);
        if (length > bytes.size() - offset) throw std::runtime_error("multi-target string pool entry is truncated");
        const std::string text = bytes.substr(offset, static_cast<std::size_t>(length));
        if (text.size() == 16 && std::all_of(text.begin(), text.end(), lowercase_hex_digit)) {
            if (text == std::string(16, '0')) throw std::runtime_error("multi-target file declares the zero key");
            keys.insert(text);
        }
        offset += static_cast<std::size_t>(length);
    }
    return keys;
}

// Source-level rule: every maximal run of 16 or more lowercase hex digits (string, comment or identifier) must be exactly
// one declared key, and each key occurs exactly once (its `targets` key). Returns the violations, empty when clean.
std::vector<std::string> multi_target_stray_hex(const std::string& source, const std::set<std::string>& keys) {
    std::vector<std::string> problems;
    std::map<std::string, int> seen;
    for (std::size_t n = 0; n < source.size();) {
        if (!lowercase_hex_digit(source[n])) { ++n; continue; }
        std::size_t end = n;
        while (end < source.size() && lowercase_hex_digit(source[end])) ++end;
        if (end - n >= 16) {
            const std::string run = source.substr(n, end - n);
            if (run.size() != 16 || !keys.contains(run)) problems.push_back("stray lowercase hex text '" + run + "'");
            else ++seen[run];
        }
        n = end;
    }
    for (const auto& key : keys)
        if (seen[key] != 1) problems.push_back("declared key occurs " + std::to_string(seen[key]) + " times (expected once)");
    return problems;
}

std::string lua_table_key(const Json& key) {
    return key.is_string() ? lua_quote(key.get<std::string>()) : std::to_string(key.get<long long>());
}

// Generic per-instance root-table entries (gate ROOT_TABLE_UPVALUE_V1). DE runs a module root once per instance and the
// runtime dispatches luaCalls[P].before for EVERY live instance (matched by exact prototype), so an entry never caches one
// owner: each hook resolves the table from that call's upvalues, and `ownedTable` keeps a weak-keyed record per live
// table. Per table: the stock values are checked once, the new values written once; a drifted table is left unchanged
// and reported once; cleanup restores every table it wrote whose field still holds the written value.
//
// Phase 2i (INGAME_EDITOR_DESIGN.md section 3.4, primitive ADDON_SETTINGS_V1): each entry keeps its compiled values in its
// `settings` table (`[id] = { value, stock }`, stock equal to the registry stock). `activate(context)` derives the effective
// settings of this generation: with `context.settings` (a generation-owned table `[id] = { enabled, value, stock }` built by
// the host from package.json declarations and CustomScripts\Settings\<package>.json) only enabled values whose declared
// stock equals the compiled stock are bound; a missing or disabled value keeps its field stock and is never written.
// Without `context.settings` (loose layout, an older runtime, or an addon without declarations) the compiled values apply
// exactly as before. The stock check runs only over the fields this generation writes.
std::string multi_target_addon_source(const Json& registry, const std::map<std::string, std::vector<const Json*>>& bodies,
                                      const std::map<std::string, double>& values) {
    std::ostringstream out;
    out << "-- Generated by RENOVICE Ability Editor from the mission registry. Do not hand-edit.\n"
        << "-- Build profile " << registry.at("build").get<std::string>() << ". Multi-target addon: one Scripts row, \"[ADDON] "
        << kMultiTargetAddonName << "\".\n"
        << "-- Target keys appear only as the keys of `targets` (every lowercase 16-hex string constant is a declared target).\n"
        << "-- Root-table fields (gate " << kRootTableGate << ") are bound per live table instance: stock checked once per\n"
        << "-- table, written once, restored in cleanup. No polling, no per-frame writes, no single-owner assumption.\n"
        << "-- Values: activate(context) reads context.settings (ADDON_SETTINGS_V1: [id] = { enabled, value, stock }); without\n"
        << "-- it the compiled values below apply. A value that is not enabled is never written.\n\n"
        << "local function effectiveSettings(compiled, context)\n"
        << "    local provided = nil\n"
        << "    if type(context) == \"table\" and type(context.settings) == \"table\" then provided = context.settings end\n"
        << "    local result = {}\n"
        << "    for id, entry in pairs(compiled) do\n"
        << "        if provided == nil then\n"
        << "            result[id] = { enabled = true, value = entry.value, stock = entry.stock }\n"
        << "        else\n"
        << "            local given = provided[id]\n"
        << "            local usable = type(given) == \"table\" and given.enabled == true and type(given.value) == \"number\"\n"
        << "                and given.value == given.value and given.stock == entry.stock\n"
        << "            if usable then\n"
        << "                result[id] = { enabled = true, value = given.value, stock = entry.stock }\n"
        << "            else\n"
        << "                result[id] = { enabled = false, value = entry.stock, stock = entry.stock }\n"
        << "            end\n"
        << "        end\n"
        << "    end\n"
        << "    return result\n"
        << "end\n\n"
        << "local function anyEnabled(current, fields)\n"
        << "    for i = 1, #fields do\n"
        << "        if current[fields[i].setting].enabled then return true end\n"
        << "    end\n"
        << "    return false\n"
        << "end\n\n"
        << "local function ownedTable(tag, settings, fields)\n"
        << "    local bound = setmetatable({}, { __mode = \"k\" }) -- live table -> written values, or false when drifted\n"
        << "    local function bind(owner, current)\n"
        << "        assert(type(owner) == \"table\", tag .. \" is not a table\")\n"
        << "        if bound[owner] ~= nil then return end\n"
        << "        for i = 1, #fields do\n"
        << "            local field = fields[i]\n"
        << "            if current[field.setting].enabled and owner[field.key] ~= settings[field.setting].stock then\n"
        << "                bound[owner] = false\n"
        << "                assert(false, tag .. \" stock values drifted; this instance is left unchanged\")\n"
        << "            end\n"
        << "        end\n"
        << "        local written = {}\n"
        << "        for i = 1, #fields do\n"
        << "            local field = fields[i]\n"
        << "            if current[field.setting].enabled then\n"
        << "                local value = current[field.setting].value\n"
        << "                owner[field.key] = value\n"
        << "                written[i] = value\n"
        << "            end\n"
        << "        end\n"
        << "        bound[owner] = written\n"
        << "    end\n"
        << "    local function restore()\n"
        << "        for owner, written in pairs(bound) do\n"
        << "            if written then\n"
        << "                for i = 1, #fields do\n"
        << "                    local field = fields[i]\n"
        << "                    local value = written[i]\n"
        << "                    if value ~= nil and owner[field.key] == value then owner[field.key] = settings[field.setting].stock end\n"
        << "                end\n"
        << "            end\n"
        << "            bound[owner] = nil\n"
        << "        end\n"
        << "    end\n"
        << "    return bind, restore\n"
        << "end\n";
    std::size_t target = 0;
    for (const auto& [body, rows] : bodies) {
        ++target;
        const Json& module = mission_module(registry, body);
        const auto module_path = module.at("module_path").get<std::string>();
        struct Owned { std::string key; std::string setting; };
        std::map<std::string, std::vector<Owned>> tables;
        std::map<std::string, const Json*> settings;
        for (const Json* row : rows) {
            const auto id = row->at("tunable_id").get<std::string>();
            settings.emplace(id, row);
            for (const auto& field : row->at("owner").at("fields"))
                tables[field.at("table_id").get<std::string>()].push_back({lua_table_key(field.at("field")), lua_quote(id)});
        }
        out << "\n-- Target " << target << ": " << module_path << "\n"
            << "local function target" << target << "()\n"
            << "    local settings = { -- compiled values (used without context.settings) and the registry stock\n";
        for (const auto& [id, row] : settings)
            out << "        [" << lua_quote(id) << "] = { value = " << format_number(values.at(id)) << ", stock = "
                << format_number(row->at("stock").get<double>()) << " },\n";
        out << "    }\n"
            << "    local current = nil -- effective settings of the active generation; nil while inactive\n";
        struct Bind { int upvalue; std::vector<std::string> steps; std::size_t slot; };
        std::map<int, std::vector<Bind>> hooks;  // prototype -> tables its captures reach
        std::size_t slot = 0;
        for (const auto& [table_id, fields] : tables) {
            ++slot;
            out << "    local fields" << slot << " = {\n";
            for (const auto& field : fields) out << "        { key = " << field.key << ", setting = " << field.setting << " },\n";
            out << "    }\n"
                << "    local bind" << slot << ", restore" << slot << " = ownedTable(" << lua_quote(module_path + " " + table_id)
                << ", settings, fields" << slot << ")\n"
                << "    local live" << slot << " = false\n";
            for (const auto& hook : module.at("root_tables").at(table_id).at("hooks")) {
                Bind bind{hook.at("upvalue").get<int>(), {}, slot};
                for (const auto& key : hook.at("path")) bind.steps.push_back("[" + lua_table_key(key) + "]");
                hooks[hook.at("prototype").get<int>()].push_back(std::move(bind));
            }
        }
        for (const auto& [prototype, binds] : hooks) {
            out << "    local function before" << prototype << "(prototype, arguments, upvalues)\n"
                << "        if current == nil then return end\n"
                << "        assert(prototype == " << prototype << ", " << lua_quote(module_path + " hook received the wrong prototype") << ")\n"
                << "        assert(type(upvalues) == \"table\", \"upvalue view is unavailable\")\n";
            for (const auto& bind : binds) {
                const std::string base = "upvalues[" + std::to_string(bind.upvalue) + "]";
                if (bind.steps.empty()) {
                    out << "        if live" << bind.slot << " then bind" << bind.slot << "(" << base << ", current) end\n";
                    continue;
                }
                // A nested table is reached through its root container(s) of this instance; every step must be a table.
                out << "        if live" << bind.slot << " then\n"
                    << "            local container = " << base << "\n";
                for (const auto& step : bind.steps)
                    out << "            assert(type(container) == \"table\", \"root-table container is not a table\")\n"
                        << "            container = container" << step << "\n";
                out << "            bind" << bind.slot << "(container, current)\n"
                    << "        end\n";
            }
            out << "    end\n";
        }
        out << "    return {\n"
            << "        label = " << lua_quote(module_path) << ", -- reserved for the settings editor; ignored by the runtime\n"
            << "        settings = settings, -- reserved for the settings editor; ignored by the runtime\n"
            << "        activate = function(context)\n"
            << "            current = effectiveSettings(settings, context)\n";
        for (std::size_t n = 1; n <= slot; ++n) out << "            live" << n << " = anyEnabled(current, fields" << n << ")\n";
        out << "        end,\n"
            << "        cleanup = function()\n"
            << "            current = nil\n";
        for (std::size_t n = 1; n <= slot; ++n) out << "            live" << n << " = false\n            restore" << n << "()\n";
        out << "        end,\n"
            << "        hooks = { luaCalls = {\n";
        for (const auto& [prototype, binds] : hooks) out << "            [" << prototype << "] = { before = before" << prototype << " },\n";
        out << "        } },\n"
            << "    }\n"
            << "end\n";
    }
    out << "\nreturn {\n"
        << "    label = " << lua_quote(kMultiTargetAddonName) << ", -- reserved for the settings editor; ignored by the runtime\n"
        << "    targets = {\n";
    target = 0;
    for (const auto& entry : bodies) out << "        [" << lua_quote(entry.first) << "] = target" << ++target << "(),\n";
    out << "    },\n"
        << "}\n";
    return out.str();
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

        // Lua rows are grouped per body key and each body gets exactly one artifact. A body whose rows can all be written
        // by the target addon uses the addon lane (root-table fields are independent controls there). A body that also
        // has literal-only rows is built as ONE merged exact replacement when every requested row has an exact literal
        // form; otherwise it fails closed and names the rows that have only one form. A preset keeps its established lane.
        // The addon lane is chosen automatically only while its hook binding is LIVE_CONFIRMED (or explicitly allowed by
        // the settings for an acceptance run); otherwise a row's exact literal form is used, and a body with addon-only
        // rows reports NEEDS_BINDING instead of staging an addon that the runtime would never call.
        const MissionHookStatus hook = mission_addon_hook_status(editor_root, naming.allow_unproven_hooks);
        const bool addon_lane_usable = hook.live || hook.opt_in;
        std::map<std::string, std::vector<const Json*>> lua_rows, literal, addon;
        std::vector<const Json*> metadata, server;
        for (const auto& [id, value] : values) {
            static_cast<void>(value);
            const Json& row = mission_tunable(registry, id);
            try { verify_mission_row(registry, row, paths); }
            catch (const std::exception& e) { throw std::runtime_error(id + ": " + e.what()); }
            const auto backend = row.at("backend").get<std::string>();
            if (backend == "EXACT_LITERAL" || backend == "TARGET_ADDON") lua_rows[row.at("owner").at("body_key").get<std::string>()].push_back(&row);
            else if (backend == "METADATA_PATCH") metadata.push_back(&row);
            else server.push_back(&row);
        }
        const auto id_list = [](const std::vector<const Json*>& rows) {
            std::string text;
            for (const Json* row : rows) text += (text.empty() ? "" : ", ") + row->at("tunable_id").get<std::string>();
            return text;
        };
        for (const auto& [body, rows] : lua_rows) {
            std::vector<const Json*> addon_only, literal_only;
            bool all_addon = true, all_literal = true;
            for (const Json* row : rows) {
                const bool can_addon = row->at("backend") == "TARGET_ADDON";
                const bool can_literal = mission_literal_owner(*row) != nullptr;
                all_addon = all_addon && can_addon;
                all_literal = all_literal && can_literal;
                if (can_addon && !can_literal) addon_only.push_back(row);
                if (can_literal && !can_addon) literal_only.push_back(row);
            }
            if (naming.lane.empty() && all_addon && !addon_lane_usable && !all_literal) {
                throw std::runtime_error("NEEDS_BINDING: body key " + body + ": " + id_list(addon_only) +
                                         " can be written only by a target addon (no exact literal form), and that addon acts only through hook "
                                         "binding " + kMissionAddonHookBinding + ", which is " + hook.status +
                                         " (not LIVE_CONFIRMED) in REGISTRIES/hook_registry.tsv. The 2026-09-29 44.0.2 live test showed the "
                                         "addon attaching without any luaCalls.before dispatch, so it would change nothing. To stage it for a "
                                         "live acceptance run only, add \"allow_unproven_hook_bindings\": [\"" + kMissionAddonHookBinding +
                                         "\"] to the mission settings");
            }
            if (naming.lane == "EXACT_LITERAL" ? all_literal : naming.lane == "TARGET_ADDON" ? all_addon : all_addon || all_literal) {
                if (naming.lane == "EXACT_LITERAL" || (naming.lane.empty() && (!all_addon || !addon_lane_usable))) literal[body] = rows;
                else addon[body] = rows;
            } else {
                throw std::runtime_error("Body key " + body + " would need both an exact replacement (literal-only: " + id_list(literal_only) +
                                         ") and a target addon (addon-only: " + id_list(addon_only) +
                                         "); one body key may own only one artifact");
            }
        }
        const auto registry_sha = sha256_file(editor_root / kMissionRegistryPath);
        Json normalized = {{"format", "RENOVICE_MISSION_SETTINGS_V1"}, {"build", registry.at("build")}, {"values", Json::object()}};
        for (const auto& [id, value] : values) normalized["values"][id] = value;
        if (!naming.allow_unproven_hooks.empty()) normalized["allow_unproven_hook_bindings"] = naming.allow_unproven_hooks;
        // Recorded only for the package layout, so every loose build keeps its exact settings bytes and build hash.
        if (naming.package_layout) normalized["output_layout"] = "package";
        const std::string package_live = std::string("OpenWF/CustomScripts/Packages/") + kMissionPackageName + "/";
        const auto lua_live_path = [&](const std::string& loose_directory, const fs::path& artifact) {
            return (naming.package_layout ? package_live : loose_directory) + artifact.filename().string();
        };
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
                                const fs::path& stock, const std::string& stock_sha, const std::string& live, const Json& gates,
                                const Json& extra) {
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
            Json manifest{{"format", "RENOVICE_ABILITY_EDITOR_BUILD_V1"}, {"package_type", package_type}, {"status", "STAGED_PASS"},
                                {"project_id", naming.label}, {"build_sha256", build_hash}, {"registry_build", registry.at("build")},
                                {"registry_sha256", registry_sha}, {"body_key", body}, {"tunables", item.tunables},
                                {"source", {{"path", relative(source)}, {"sha256", sha256_file(source)}}},
                                {"artifact", {{"path", relative(artifact)}, {"sha256", item.sha256}, {"size", item.size}}},
                                {"stock_artifact", {{"path", stock.string()}, {"sha256", stock_sha}}},
                                {"intended_live_relative_path", live}, {"live_write_performed", false}, {"gates", gates},
                                {"diagnostics", Json::array()}};
            Json entry{{"backend", backend}, {"body_key", body}, {"tunables", item.tunables}, {"path", relative(artifact)},
                       {"sha256", item.sha256}, {"size", item.size}, {"manifest", relative(item.manifest)},
                       {"intended_live_relative_path", live}};
            if (backend == "TARGET_ADDON") manifest["runtime_hook"] = entry["runtime_hook"] = mission_hook_record(hook);
            // A multi-target artifact names its declared keys and one stock record per target instead of one stock body.
            for (const auto& [name, value] : extra.items()) manifest[name] = entry[name] = value;
            if (extra.contains("target_keys")) {
                item.target_keys = extra.at("target_keys").get<std::vector<std::string>>();
                manifest.erase("stock_artifact");
            }
            write_text(item.manifest, manifest.dump(2) + "\n");
            set_artifacts.push_back(entry);
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
                for (const auto& site : mission_literal_owner(*row)->at("sites")) {
                    check_literal_operand(site, value, id);
                    const auto offset = site.at("offset").get<std::size_t>();
                    const auto expected = site.at("expected").get<std::vector<unsigned int>>();
                    const bool constant = site.at("kind") == "number_constant";
                    const std::size_t width = constant ? 8 : 4;
                    if (expected.size() != width || offset > bytes.size() || width > bytes.size() - offset) throw std::runtime_error("Invalid patch extent");
                    if (constant && (offset == 0 || static_cast<unsigned char>(bytes[offset - 1]) != 2)) throw std::runtime_error("Expected native numeric constant tag");
                    for (std::size_t n = 0; n < width; ++n)
                        if (static_cast<unsigned char>(bytes[offset + n]) != expected[n]) throw std::runtime_error("Verified instruction preimage changed");
                    const double exact = mission_site_operand(site, value);
                    const int operand = static_cast<int>(exact);
                    if (constant) {
                        const auto bits = std::bit_cast<std::uint64_t>(exact);
                        for (std::size_t n = 0; n < 8; ++n) bytes[offset + n] = static_cast<char>((bits >> (8 * n)) & 255);
                    } else {
                        bytes[offset] = static_cast<char>(0x08); // U44 LOADN, from the verified opcode profile.
                        bytes[offset + 1] = static_cast<char>(site.at("register").get<int>());
                        bytes[offset + 2] = static_cast<char>(operand & 255);
                        bytes[offset + 3] = static_cast<char>((operand >> 8) & 255);
                    }
                    for (std::size_t n = 0; n < width; ++n)
                        if (!permitted.insert(offset + n).second) throw std::runtime_error("Competing exact sites overlap at offset " + std::to_string(offset));
                    plan.push_back({{"tunable_id", id}, {"value", value}, {"site", site}, {"operand", constant ? Json(exact) : Json(operand)}});
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
                   lua_live_path("OpenWF/CustomScripts/", artifact), gates, Json::object());
        }

        // Compile gates shared by every addon artifact.
        const auto addon_gates = [&](Json& gates, const fs::path& source, const fs::path& canonical, const fs::path& artifact) {
            gates.push_back({{"name", "current-stock-hash"}, {"pass", true}, {"exit_code", 0}});
            gate(gates, "source-compile", "recompile " + quote_process_argument(source) + " " + quote_process_argument(canonical), "re-parses=yes");
            gate(gates, "source-plan", "plan-verify " + quote_process_argument(canonical), "failures=0");
            gate(gates, "u44-compile", "recompile-u44 " + quote_process_argument(source) + " " + quote_process_argument(artifact) + " " +
                 quote_process_argument(toolchain / "profiles/u44/name-map.tsv"), "re-parses=yes");
            gate(gates, "de-roundtrip", "de-roundtrip " + quote_process_argument(artifact), "FULL BODY identical: True");
        };
        if (naming.single_artifact) {
            // A preset keeps its established single-key file and bytes (`<key>.<suffix>.target.addon.lua_B`, template source).
            for (const auto& [body, rows] : addon) {
                const Json& module = mission_module(registry, body);
                const fs::path stock = paths.corpus / module.at("file").get<std::string>();
                bool template_rows = module.contains("addon");
                for (const Json* row : rows) {
                    bool bound = false;
                    if (template_rows)
                        for (const auto& [field, id] : module.at("addon").at("values").items()) bound = bound || id == row->at("tunable_id");
                    template_rows = template_rows && bound;
                }
                if (!template_rows) throw std::runtime_error("Preset body key " + body + " has no established addon template for " + id_list(rows));
                const Json scaffold = mission_addon_scaffold(registry, body, values);
                std::string source_text = generate_target_addon_source(scaffold, editor_root);
                for (const auto& rewrite : module.at("addon").at("source_rewrites"))
                    source_text = replace_all(source_text, rewrite.at(0).get<std::string>(), rewrite.at(1).get<std::string>());
                source_text = "-- Build profile " + registry.at("build").get<std::string>() + "; exact target " + body + "\n" + source_text;
                const fs::path source = result.directory / "source" / (body + ".luau");
                const fs::path artifact = result.directory / "artifacts" / (body + "." + naming.addon_suffix + ".target.addon.lua_B");
                write_text(source, source_text);
                Json gates = Json::array();
                addon_gates(gates, source, result.directory / "source" / (body + ".verification-u43.lua_B"), artifact);
                record("TARGET_ADDON", "TARGET_ADDON", body, rows, source, artifact, stock, module.at("sha256").get<std::string>(),
                       "OpenWF/CustomScripts/Inject/" + artifact.filename().string(), gates, Json::object());
            }
        } else if (!addon.empty()) {
            // Settings builds: ONE multi-target addon for every body key on the addon lane. Only the generic per-instance
            // root-table entries are emitted. The established Survival/Interception templates bind a single owner per
            // activation (the Survival template asserts "owner changed" on a second module instance), which the multi-target
            // instance contract forbids; their template-only rows fail closed and stay available through their preset.
            Json targets = Json::array(), target_keys = Json::array();
            std::vector<const Json*> all_rows;
            for (const auto& [body, rows] : addon) {
                const Json& module = mission_module(registry, body);
                std::vector<const Json*> template_only;
                for (const Json* row : rows)
                    if (!row->at("owner").contains("fields")) template_only.push_back(row);
                if (!template_only.empty()) {
                    std::string presets;
                    for (const auto& [id, preset] : registry.at("missions").items())
                        if (preset.at("body_key") == body) presets += (presets.empty() ? "" : ", ") + id;
                    throw std::runtime_error("Body key " + body + ": " + id_list(template_only) + " exist only in the established " +
                                             (module.contains("addon") ? module.at("addon").at("template").get<std::string>() : std::string("addon")) +
                                             " template, which binds one owner per activation and is not multi-instance safe, so it cannot be "
                                             "part of the multi-target " + kMultiTargetAddonName + " addon" +
                                             (presets.empty() ? std::string() : "; build it through the '" + presets + "' preset instead"));
                }
                Json tunables = Json::array();
                for (const Json* row : rows) {
                    tunables.push_back(row->at("tunable_id"));
                    all_rows.push_back(row);
                }
                target_keys.push_back(body);
                targets.push_back({{"body_key", body}, {"module_path", module.at("module_path")}, {"tunables", tunables},
                                   {"stock_artifact", {{"path", (paths.corpus / module.at("file").get<std::string>()).string()},
                                                       {"sha256", module.at("sha256")}}},
                                   {"supersedes", body + "." + naming.addon_suffix + ".target.addon.lua_B"}});
            }
            if (addon.size() > kMultiTargetMaximumKeys) throw std::runtime_error("Multi-target addon would declare more than 1024 targets");
            const std::string name = std::string(kMultiTargetAddonName) + ".targets.addon";
            const std::string source_text = multi_target_addon_source(registry, addon, values);
            const fs::path source = result.directory / "source" / (name + ".luau");
            const fs::path artifact = result.directory / "artifacts" / (name + ".lua_B");
            write_text(source, source_text);
            Json gates = Json::array();
            addon_gates(gates, source, result.directory / "source" / (std::string(kMultiTargetAddonName) + ".verification-u43.lua_B"), artifact);
            // Declaration gate: the compiled string pool declares exactly the addon body keys (loader discovery rules), the
            // source holds no other lowercase 16-hex text, and the file stays inside the loader limits.
            std::set<std::string> expected;
            for (const auto& key : target_keys) expected.insert(key.get<std::string>());
            const auto declared = multi_target_declared_keys(read_text(artifact));
            std::string problems;
            for (const auto& problem : multi_target_stray_hex(source_text, expected)) problems += (problems.empty() ? "" : "; ") + problem;
            if (declared != expected)
                problems += (problems.empty() ? "" : "; ") + std::string("compiled string pool declares ") + std::to_string(declared.size()) +
                            " keys, expected exactly the " + std::to_string(expected.size()) + " addon body keys";
            if (fs::file_size(artifact) >= kMultiTargetMaximumBytes)
                problems += (problems.empty() ? "" : "; ") + std::string("artifact is not smaller than 1 MiB");
            result.gate_log += "multi-target-declared-keys\n" + (problems.empty() ? std::string("PASS") : problems) + " declared=" +
                               std::to_string(declared.size()) + " expected=" + std::to_string(expected.size()) + "\n";
            gates.push_back({{"name", "multi-target-declared-keys"}, {"pass", problems.empty()}, {"exit_code", problems.empty() ? 0 : 1}});
            if (!problems.empty()) throw std::runtime_error("multi-target-declared-keys failed: " + problems);
            std::string policy = artifact.filename().string();
            std::transform(policy.begin(), policy.end(), policy.begin(), [](const unsigned char c) { return static_cast<char>(std::tolower(c)); });
            const Json scripts_menu = naming.package_layout
                ? Json{{"row", "[PACKAGE] " + std::string(kMissionPackageName)},
                       {"policy_id", "package:" + ascii_lower_text(kMissionPackageName)},
                       {"package", "Packages/" + std::string(kMissionPackageName)}}
                : Json{{"row", "[ADDON] " + std::string(kMultiTargetAddonName)}, {"policy_id", "target-addon:" + policy}};
            record("TARGET_ADDON", "TARGET_ADDON", "multi-target", all_rows, source, artifact, fs::path(), std::string(),
                   lua_live_path("OpenWF/CustomScripts/Inject/", artifact), gates,
                   Json{{"target_keys", target_keys}, {"targets", targets}, {"scripts_menu", scripts_menu}});
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
                    if (row->at("owner").contains("also"))
                        for (const auto& entry : row->at("owner").at("also"))
                            text += "    q|" + entry.at("field").get<std::string>() + "|" + format_number(values.at(id)) + "\n";
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
                   registry.at("metadata_snapshot").at("sha256").get<std::string>(), "OpenWF/Metadata Patches/" + naming.metadata_file, gates,
                   Json::object());
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
        // Optional folder package: the Lua artifacts (exact replacements + the multi-target addon) are copied byte for byte
        // into Packages\Missions\ with a strict package.json. Metadata patches and server diffs are separate systems and
        // stay outside the package. Gates mirror the loader's static package rules.
        Json package_record = nullptr;
        if (naming.package_layout) {
            if (naming.single_artifact) throw std::runtime_error("output_layout \"package\" applies to mission settings builds only");
            std::vector<const MissionArtifact*> members;
            for (const auto& item : result.artifacts)
                if (item.backend == "EXACT_LITERAL" || item.backend == "TARGET_ADDON") members.push_back(&item);
            if (members.empty()) {
                add(result.diagnostics, Severity::warning, "PACKAGE_EMPTY",
                    "output_layout \"package\" requested, but these settings produced no Lua artifact; no package folder was written");
            } else {
                const fs::path package_dir = result.directory / "Packages" / kMissionPackageName;
                fs::create_directories(package_dir);
                Json member_labels = Json::object();
                Json member_records = Json::array();
                std::set<std::string> replacement_keys, used_groups;
                for (const MissionArtifact* item : members) {
                    const std::string file = item->artifact.filename().string();
                    std::string label;
                    if (item->backend == "TARGET_ADDON") {
                        if (item->target_keys.empty()) throw std::runtime_error("Package member " + file + " is not the multi-target addon");
                        std::string modules;
                        for (const auto& key : item->target_keys)
                            modules += (modules.empty() ? "" : ", ") + module_short_name(mission_module(registry, key).at("module_path").get<std::string>());
                        label = "Mission tunables: " + modules;
                    } else {
                        if (!replacement_keys.insert(item->body_key).second) throw std::runtime_error("Two package members replace " + item->body_key);
                        std::string tunables;
                        for (const auto& id : item->tunables) tunables += (tunables.empty() ? "" : ", ") + id;
                        label = "Exact replacement: " + module_short_name(mission_module(registry, item->body_key).at("module_path").get<std::string>()) +
                                " (" + tunables + ")";
                    }
                    label = package_text(label, kPackageLabelMaximum);
                    fs::copy_file(item->artifact, package_dir / file, fs::copy_options::overwrite_existing);
                    // Phase 2i: one declaration per tunable the member carries (design section 3.2), from the registry row.
                    Json member_values = Json::object();
                    for (const auto& id : item->tunables) {
                        const Json& row = mission_tunable(registry, id);
                        member_values[id] = mission_value_declaration(row);
                        used_groups.insert(row.at("ui").at("group").get<std::string>());
                    }
                    member_labels[file] = Json{{"label", label}, {"settings", Json{{"values", member_values}}}};
                    member_records.push_back({{"file", file}, {"backend", item->backend}, {"label", label}, {"sha256", item->sha256},
                                              {"size", item->size}, {"intended_live_relative_path", item->intended_live_relative_path}});
                }
                const std::string description = package_text(
                    "RENOVICE universal mission editor output for client build " + registry.at("build").get<std::string>() +
                    ". One Scripts row for every generated Lua mission change. Every value is declared in settings; "
                    "CustomScripts/Settings/Missions.json selects which values apply.",
                    kPackageDescriptionMaximum);
                Json group_declarations = Json::array();
                std::vector<std::string> ordered_groups(used_groups.begin(), used_groups.end());
                std::sort(ordered_groups.begin(), ordered_groups.end(), [&](const std::string& a, const std::string& b) {
                    return registry.at("ui_groups").at(a).at("order").get<long long>() < registry.at("ui_groups").at(b).at("order").get<long long>();
                });
                for (const auto& group : ordered_groups) group_declarations.push_back(mission_group_declaration(registry, group));
                const Json package_json{{"schema", 1}, {"name", kMissionPackageName}, {"description", description},
                                        {"members", member_labels},
                                        {"settings", Json{{"format", kSettingsDeclarationFormat}, {"build", registry.at("build")},
                                                          {"groups", group_declarations}}}};
                write_text(package_dir / "package.json", package_json.dump(2) + "\n");

                // Package gates (loader rules, bootstrapper renovice/packages_core.hpp).
                std::set<std::string> on_disk, declared;
                for (const auto& entry : fs::directory_iterator(package_dir)) {
                    const std::string name = entry.path().filename().string();
                    if (name != "package.json") on_disk.insert(name);
                }
                for (const auto& [name, value] : member_labels.items()) {
                    static_cast<void>(value);
                    declared.insert(name);
                }
                std::string problems;
                if (on_disk != declared) problems += "on-disk members differ from package.json members; ";
                for (const MissionArtifact* item : members)
                    if (sha256_file(package_dir / item->artifact.filename()) != item->sha256)
                        problems += "member " + item->artifact.filename().string() + " is not byte-identical to its artifact; ";
                for (const auto& name : declared) {
                    const bool bytecode = name.size() > 6 && ascii_lower_text(name.substr(name.size() - 6)) == ".lua_b";
                    const bool multi = ascii_lower_text(name).find(".targets.addon") != std::string::npos;
                    const bool replacement = name.size() >= 16 && std::all_of(name.begin(), name.begin() + 16, lowercase_hex_digit)
                                             && ascii_lower_text(name).find(".addon") == std::string::npos;
                    if (!bytecode || (!multi && !replacement)) problems += "member " + name + " is not a replacement or multi-target addon file; ";
                }
                if (Json::parse(read_text(package_dir / "package.json")) != package_json) problems += "package.json readback mismatch; ";
                result.gate_log += "package-folder\n" + (problems.empty() ? std::string("PASS") : problems) + " members=" +
                                   std::to_string(declared.size()) + "\n";
                if (!problems.empty()) throw std::runtime_error("package-folder gate failed: " + problems);

                // Phase 2i gate settings-declarations: strict schema; exactly one declaration per member tunable and nothing
                // else; declaration == registry row; declared stock == registry stock == the addon's compiled stock constant;
                // row-label budget. A failure fails the package build closed.
                std::vector<std::string> settings_problems;
                for (const auto& problem : validate_settings_declarations(package_json)) settings_problems.push_back("schema: " + problem);
                std::size_t declared_values = 0;
                Json migration_values = Json::object(), migration_groups = Json::object();
                for (const MissionArtifact* item : members) {
                    const std::string file = item->artifact.filename().string();
                    const Json& declared_member = package_json.at("members").at(file).at("settings").at("values");
                    std::set<std::string> want(item->tunables.begin(), item->tunables.end()), have;
                    for (const auto& [id, declaration] : declared_member.items()) {
                        static_cast<void>(declaration);
                        have.insert(id);
                    }
                    if (want != have) settings_problems.push_back(file + ": declarations are not exactly the member tunables");
                    std::map<std::string, std::pair<double, double>> compiled;
                    if (item->backend == "TARGET_ADDON") {
                        compiled = multi_target_compiled_values(read_text(item->source));
                        std::set<std::string> compiled_ids;
                        for (const auto& [id, value] : compiled) compiled_ids.insert(id);
                        if (compiled_ids != want) settings_problems.push_back(file + ": compiled settings table is not exactly the declared values");
                    }
                    for (const auto& id : want) {
                        if (!declared_member.contains(id)) continue;
                        const Json& row = mission_tunable(registry, id);
                        const Json& declaration = declared_member.at(id);
                        ++declared_values;
                        if (declaration != mission_value_declaration(row)) settings_problems.push_back(id + ": declaration differs from its registry row");
                        const double stock = row.at("stock").get<double>();
                        if (!declaration.at("stock").is_number() || declaration.at("stock").get<double>() != stock)
                            settings_problems.push_back(id + ": declared stock differs from the registry stock");
                        if (declaration.at("lane") != (item->backend == "TARGET_ADDON" ? "addon" : "literal"))
                            settings_problems.push_back(id + ": declared lane differs from the member kind");
                        if (item->backend == "TARGET_ADDON") {
                            const auto found = compiled.find(id);
                            if (found == compiled.end() || found->second.second != stock)
                                settings_problems.push_back(id + ": compiled stock constant differs from the registry stock");
                            else if (found->second.first != values.at(id))
                                settings_problems.push_back(id + ": compiled value differs from the build value");
                        }
                        const auto group = declaration.at("group").get<std::string>();
                        for (const auto& problem : settings_label_budget_problems(id, declaration, registry.at("ui_groups").at(group)))
                            settings_problems.push_back(problem);
                        migration_groups[group] = true;
                        migration_values[id] = Json{{"enabled", true}, {"value", settings_number(values.at(id), declaration.at("type").get<std::string>())}};
                    }
                }
                std::string settings_text;
                for (const auto& problem : settings_problems) settings_text += (settings_text.empty() ? "" : "; ") + problem;
                result.gate_log += "settings-declarations\n" + (settings_text.empty() ? std::string("PASS") : settings_text) + " values=" +
                                   std::to_string(declared_values) + " groups=" + std::to_string(group_declarations.size()) + "\n";
                if (!settings_text.empty()) throw std::runtime_error("settings-declarations gate failed: " + settings_text);
                // Migration settings file (design section 3.3): the values this build applies, all enabled, so a runtime with
                // ADDON_SETTINGS_V1 reproduces the loose behaviour. It is installed outside the package folder
                // (CustomScripts/Settings/<package>.json) because the package folder is replaced on redeploy.
                const fs::path settings_file = result.directory / "Settings" / (std::string(kMissionPackageName) + ".json");
                fs::create_directories(settings_file.parent_path());
                const Json migration{{"format", kScriptSettingsFormat}, {"package", "package:" + ascii_lower_text(kMissionPackageName)},
                                     {"build", registry.at("build")}, {"use_stock", false}, {"groups", migration_groups},
                                     {"values", migration_values}};
                write_text(settings_file, migration.dump(2) + "\n");
                if (Json::parse(read_text(settings_file)) != migration) throw std::runtime_error("settings migration file readback mismatch");
                result.package_directory = package_dir;
                package_record = {{"path", relative(package_dir)}, {"name", kMissionPackageName},
                                  {"manifest", {{"path", relative(package_dir / "package.json")}, {"sha256", sha256_file(package_dir / "package.json")}}},
                                  {"members", member_records},
                                  {"scripts_menu", {{"row", "[PACKAGE] " + std::string(kMissionPackageName)},
                                                    {"policy_id", "package:" + ascii_lower_text(kMissionPackageName)}}},
                                  {"intended_live_relative_path", "OpenWF/CustomScripts/Packages/" + std::string(kMissionPackageName)},
                                  {"settings", {{"declarations", {{"format", kSettingsDeclarationFormat}, {"values", declared_values},
                                                                  {"groups", group_declarations.size()}}},
                                                {"migration", {{"path", relative(settings_file)}, {"sha256", sha256_file(settings_file)},
                                                               {"format", kScriptSettingsFormat},
                                                               {"intended_live_relative_path", "OpenWF/CustomScripts/Settings/" +
                                                                                                   std::string(kMissionPackageName) + ".json"}}}}},
                                  {"gates", Json::array({Json{{"name", "package-folder"}, {"pass", true}, {"exit_code", 0}},
                                                         Json{{"name", "settings-declarations"}, {"pass", true}, {"exit_code", 0}}})}};
            }
        }
        if (naming.single_artifact && (result.artifacts.size() != 1 || !server.empty()))
            throw std::runtime_error("A preset build must produce exactly one artifact");
        if (result.artifacts.empty() && server.empty()) throw std::runtime_error("Mission settings produced no artifact");

        // Reported only once the addon is actually staged (a failed build carries its error alone).
        if (!addon.empty() && !hook.live)
            add(result.diagnostics, Severity::warning, "HOOK_UNPROVEN",
                std::string("Target addon staged although hook binding ") + kMissionAddonHookBinding + " is " + hook.status +
                " (not LIVE_CONFIRMED): " + (hook.opt_in ? "explicit allow_unproven_hook_bindings opt-in" : "preset keeps its established lane") +
                ". No live luaCalls.before dispatch has been observed since runtime V107; treat the artifact as a live acceptance probe, not a working edit.");

        result.manifest = result.directory / "MISSION_SET_MANIFEST.json";
        Json set_manifest{{"format", "RENOVICE_MISSION_SET_BUILD_V1"}, {"status", "STAGED_PASS"}, {"label", naming.label},
                          {"registry_build", registry.at("build")}, {"registry_sha256", registry_sha},
                          {"settings_sha256", sha256_file(result.directory / "mission_settings.json")},
                          {"artifacts", set_artifacts}, {"server_config_diff", server_diff},
                          {"allow_unproven_hook_bindings", naming.allow_unproven_hooks},
                          {"live_write_performed", false},
                          {"evidence_boundary", "Offline gates only; in-game behaviour is not claimed."}};
        // Package-layout fields only; a loose build's manifest keeps its exact previous content.
        if (naming.package_layout) {
            set_manifest["output_layout"] = "package";
            set_manifest["package"] = package_record;
        }
        write_text(result.manifest, set_manifest.dump(2) + "\n");
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
        // Optional, for live acceptance runs only: hook bindings that may stage an addon although they are not
        // LIVE_CONFIRMED. Every name must be a registered binding; the manifest records the status.
        std::vector<std::string> allow_unproven;
        if (settings.contains("allow_unproven_hook_bindings")) {
            const Json& list = settings.at("allow_unproven_hook_bindings");
            if (!list.is_array()) throw std::runtime_error("allow_unproven_hook_bindings must be an array of hook binding ids");
            const auto hooks = load_registry(editor_root / "REGISTRIES" / "hook_registry.tsv");
            for (const auto& name : list) {
                if (!name.is_string() || find_binding(hooks, name.get<std::string>()) == nullptr)
                    throw std::runtime_error("allow_unproven_hook_bindings names an unregistered hook binding: " + name.dump());
                allow_unproven.push_back(name.get<std::string>());
            }
        }
        // Optional: "output_layout": "loose" (default, unchanged files) or "package" (also Packages\Missions\).
        bool package_layout = false;
        if (settings.contains("output_layout")) {
            const Json& layout = settings.at("output_layout");
            if (!layout.is_string() || (layout != "loose" && layout != "package"))
                throw std::runtime_error("output_layout must be \"loose\" or \"package\"");
            package_layout = layout == "package";
        }
        return build_mission_set(registry, settings.at("values"),
                                 MissionNaming{"missions", "missions", "missions", "RENOVICE_Missions.txt", false, "", allow_unproven,
                                               package_layout},
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
                                           MissionNaming{project.at("id").get<std::string>(), "mission_" + id + "_timers", "mission_" + id, id + ".txt", true,
                                                         preset.at("lane").get<std::string>(), {}},
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
