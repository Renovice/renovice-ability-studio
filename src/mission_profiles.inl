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

// LIVE_LITERALS_V1: operand, domain, encoding and preimage rules live in the shared core
// include/renovice/live_literal_patch_core.hpp (byte-identical in the bootstrapper, which synthesizes recipes at run time).
live_literal_patch::Site mission_operand_site(const Json& site) {
    live_literal_patch::Site core;
    core.kind = site.at("kind") == "number_constant" ? live_literal_patch::SiteKind::NumberConstant : live_literal_patch::SiteKind::Loadn;
    core.inverse = site.value("inverse", false);
    core.numerator = site.at("numerator").get<double>();
    core.denominator = core.inverse ? 1.0 : site.at("denominator").get<double>();
    core.value_offset = site.value("value_offset", 0.0);  // R11 coupled site (0 = plain site)
    return core;
}

double mission_site_operand(const Json& site, const double value) {
    return live_literal_patch::operand(mission_operand_site(site), value);
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
    const auto error = live_literal_patch::operand_error(mission_operand_site(site), value);
    if (error == live_literal_patch::Error::OperandNotFinite) throw std::runtime_error("Mission value must resolve to a finite constant: " + id);
    if (error != live_literal_patch::Error::None)
        throw std::runtime_error("Mission value must resolve to an exact positive whole-number operand: " + id);
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
// Phase 2k: minimal luaCalls hook set per root table (registrar tools/hook_plan.py). Every prototype that can read, write
// or leak an owned field runs either as a hooked prototype or only inside the dynamic extent of a call to one (nesting
// rule; valid at the first bind and after every re-activation). The full ROOT_TABLE_UPVALUE_V1 capturer list stays the
// owner evidence; the generator emits only `minimal_hooks.prototypes`.
constexpr const char* kMinimalHooksGate = "ROOT_TABLE_MINIMAL_HOOKS_V1";
// Contract R10 (2026-09-30): target-addon rows written once at a module entry (registrar tools/mission_owner_specs.py,
// gate CAPTURE_GRAPH_ENTRY_V1). Every entry prototype is a direct child of the module root (so the hook may retire, R3)
// and every recorded reader of the value runs only inside a call that starts at an entry (capture-graph proof).
//  - MISSION_INFO_FIELD_AT_ENTRY: host only; writes one MissionInfo field through the game's own setter
//    (m = gGameRules:GetMission(); m.<field> = N; gGameRules:SetMission(m)), only on normal nodes (the field is 0 and
//    the mission is no alert, invasion, syndicate, goal, sortie or nightmare mission), once per mission.
//  - SCRIPT_PARAM_GLOBAL_AT_ENTRY: a level/encounter script parameter. It is a global of the CALLED instance's
//    environment, which the runtime passes as the fifth luaCalls.before argument (bootstrapper contract R10); the name
//    is compiled as a hashed field (`-- RENOVICE_HASH_FIELD:` directive), the key the stock GETGLOBAL reads.
constexpr const char* kEntryGate = "CAPTURE_GRAPH_ENTRY_V1";
constexpr const char* kMissionInfoTemplate = "MISSION_INFO_FIELD_AT_ENTRY";
constexpr const char* kScriptParamTemplate = "SCRIPT_PARAM_GLOBAL_AT_ENTRY";

bool entry_template_row(const Json& row) {
    if (row.at("backend") != "TARGET_ADDON") return false;
    const auto name = row.at("owner").value("template", std::string());
    return name == kMissionInfoTemplate || name == kScriptParamTemplate;
}

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
// Contract R14 (2026-10-01): an optional owner `mode` makes the row a multiplier over its fields. `scale`: every field gets
// (its own registered stock) x (row value); `scale_count`: the same, rounded half up and at least 1 (the R11 count rule).
// Such a row has stock 1, a minimum >= 0 and a fractional value; each field carries its own `stock`, which its initialiser
// bytes must encode. Without `mode` (every row before R14) the row value is written as is and a field carries no stock.
constexpr const char* kRootFieldScale = "scale";
constexpr const char* kRootFieldScaleCount = "scale_count";

std::string root_field_mode(const Json& row) {
    const Json& owner = row.at("owner");
    if (!owner.contains("mode")) return std::string();
    if (!owner.at("mode").is_string()) throw std::runtime_error(row.at("tunable_id").get<std::string>() + ": root-table mode is not a string");
    const auto mode = owner.at("mode").get<std::string>();
    if (mode != kRootFieldScale && mode != kRootFieldScaleCount)
        throw std::runtime_error(row.at("tunable_id").get<std::string>() + ": unknown root-table field mode " + mode);
    return mode;
}

void verify_root_table_fields(const Json& row, const Json& module, const std::string& bytes) {
    static const std::regex field_name("[A-Za-z_][A-Za-z0-9_]*");
    const Json& owner = row.at("owner");
    if (owner.value("gate", std::string()) != kRootTableGate) throw std::runtime_error("root-table addon row has no ROOT_TABLE_UPVALUE_V1 gate");
    if (!owner.at("fields").is_array() || owner.at("fields").empty()) throw std::runtime_error("root-table addon row owns no field");
    if (!row.at("stock").is_number()) throw std::runtime_error("root-table addon row has no numeric stock value");
    const auto mode = root_field_mode(row);
    if (!mode.empty() && (row.at("stock").get<double>() != 1 || row.at("limits").at("minimum").get<double>() < 0 ||
                          row.at("limits").value("integer", false)))
        throw std::runtime_error("a scaled root-table row needs stock 1, a minimum >= 0 and a fractional value");
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
        // Phase 2k: the generator hooks only the proven minimal subset (registrar tools/hook_plan.py, gate
        // ROOT_TABLE_MINIMAL_HOOKS_V1). It must be a non-empty subset of the capturer hooks above.
        if (!table.contains("minimal_hooks") || table.at("minimal_hooks").value("gate", std::string()) != kMinimalHooksGate)
            throw std::runtime_error("root table " + table_id + " has no " + std::string(kMinimalHooksGate) + " hook plan");
        const Json& minimal = table.at("minimal_hooks").at("prototypes");
        std::set<int> chosen;
        if (!minimal.is_array() || minimal.empty()) throw std::runtime_error("root table " + table_id + " hook plan is empty");
        for (const auto& prototype : minimal)
            if (!prototype.is_number_integer() || !prototypes.contains(prototype.get<int>()) || !chosen.insert(prototype.get<int>()).second)
                throw std::runtime_error("root table " + table_id + " hook plan names a prototype that is not a unique capturer hook");
        // Contract R3: retire evidence. `retire_safe` is a boolean; `root_children` names only planned prototypes.
        const Json& plan = table.at("minimal_hooks");
        if (!plan.contains("retire_safe") || !plan.at("retire_safe").is_boolean() || !plan.contains("root_children") ||
            !plan.at("root_children").is_array())
            throw std::runtime_error("root table " + table_id + " hook plan has no R3 retire evidence");
        for (const auto& prototype : plan.at("root_children"))
            if (!prototype.is_number_integer() || !chosen.contains(prototype.get<int>()))
                throw std::runtime_error("root table " + table_id + " hook plan names a root child outside its prototypes");
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
        // R14: a scaled row's field keeps its own stock; an unscaled row's field holds the row stock and carries none.
        if (mode.empty() == field.contains("stock"))
            throw std::runtime_error(mode.empty() ? "a field stock is allowed only on a scaled root-table row"
                                                  : "a field of a scaled root-table row has no stock");
        const double registered = mode.empty() ? row.at("stock").get<double>() : field.at("stock").get<double>();
        if (stock != registered)
            throw std::runtime_error("root-table initialiser at offset " + std::to_string(offset) + " disagrees with the registered stock value");
        if (mode == kRootFieldScaleCount && (stock < 1 || std::floor(stock) != stock))
            throw std::runtime_error("a scale_count field must hold a whole number >= 1");
    }
}

// Contract R10: re-verifies an entry-template owner (MISSION_INFO_FIELD_AT_ENTRY / SCRIPT_PARAM_GLOBAL_AT_ENTRY) against
// the stock bytes: every entry is a recorded root child, a MissionInfo field is a string key present in the module, a
// parameter global's hash is the U44 name hash of its name and is referenced by the module.
void verify_entry_owner(const Json& registry, const Json& row, const std::string& bytes) {
    static const std::regex identifier("[A-Za-z_][A-Za-z0-9_]*");
    const Json& owner = row.at("owner");
    const auto name = owner.at("template").get<std::string>();
    if (owner.value("gate", std::string()) != kEntryGate) throw std::runtime_error("entry row has no CAPTURE_GRAPH_ENTRY_V1 gate");
    if (!row.at("stock").is_number()) throw std::runtime_error("entry row has no numeric stock value");
    const Json& entries = owner.at("entries");
    if (!entries.is_array() || entries.empty()) throw std::runtime_error("entry row names no entry prototype");
    std::set<int> prototypes;
    for (const auto& entry : entries) {
        const int prototype = entry.at("prototype").get<int>();
        if (prototype < 0 || !prototypes.insert(prototype).second) throw std::runtime_error("entry row has an invalid or duplicate entry prototype");
        if (!entry.value("root_child", false) || entry.value("created_by", std::string()) != "root")
            throw std::runtime_error("entry prototype " + std::to_string(prototype) + " is not a recorded direct child of the module root");
    }
    if (!owner.at("readers").is_array() || owner.at("readers").empty()) throw std::runtime_error("entry row records no reader");
    if (name == kMissionInfoTemplate) {
        const auto field = owner.at("field").get<std::string>();
        if (!std::regex_match(field, identifier)) throw std::runtime_error("invalid MissionInfo field name");
        if (!owner.value("host_only", false)) throw std::runtime_error("a MissionInfo write must be host only");
        if (row.at("stock").get<double>() != 0) throw std::runtime_error("a MissionInfo count row must have stock 0 (the normal-node default)");
        if (bytes.find(field) == std::string::npos) throw std::runtime_error("module does not name the MissionInfo field " + field);
        for (const auto& reader : owner.at("readers"))
            if (reader.at("key") != field) throw std::runtime_error("a MissionInfo reader names another field");
        return;
    }
    static const std::set<std::string> modes{"scale", "scale_inverse", "absolute", "scale_count"};  // R11: scale_count
    const auto mode = owner.at("mode").get<std::string>();
    if (!modes.contains(mode)) throw std::runtime_error("unknown script-parameter mode " + mode);
    if (mode != "absolute" && (row.at("stock").get<double>() != 1 || row.at("limits").at("minimum").get<double>() <= 0))
        throw std::runtime_error("a scaled script parameter needs stock 1 and a positive minimum");
    const auto seed = static_cast<std::uint32_t>(std::stoul(registry.at("name_hash_seed").get<std::string>(), nullptr, 16));
    std::set<std::string> names;
    if (!owner.at("globals").is_array() || owner.at("globals").empty()) throw std::runtime_error("script-parameter row names no global");
    for (const auto& global : owner.at("globals")) {
        const auto parameter = global.at("name").get<std::string>();
        if (!std::regex_match(parameter, identifier) || !names.insert(parameter).second) throw std::runtime_error("invalid or duplicate parameter global");
        const std::uint32_t hash = de_name_hash(parameter, seed);
        std::ostringstream hex;
        hex << std::hex << std::nouppercase << std::setw(8) << std::setfill('0') << hash;
        if (hex.str() != global.at("hash").get<std::string>()) throw std::runtime_error("registered hash is wrong for parameter " + parameter);
        std::string little_endian(4, '\0');
        for (std::size_t n = 0; n < 4; ++n) little_endian[n] = static_cast<char>((hash >> (8 * n)) & 255u);
        if (bytes.find(little_endian) == std::string::npos) throw std::runtime_error("module does not read the hashed parameter " + parameter);
    }
    for (const auto& reader : owner.at("readers"))
        if (!names.contains(reader.at("key").get<std::string>())) throw std::runtime_error("a reader names a global outside the row");
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
                live_literal_patch::Site core = mission_operand_site(site);
                for (std::size_t n = 0; n < width; ++n) core.expected[n] = static_cast<unsigned char>(expected[n]);
                if (live_literal_patch::stock_error(core, row.at("stock").get<double>()) != live_literal_patch::Error::None)
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
        if (entry_template_row(row)) {
            verify_entry_owner(registry, row, bytes);
            return;
        }
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
        // R10: also a named script struct of the owner type (`OnFirstTouchedScript._duration`, `PickUpScript._x`).
        static const std::regex field_pattern("(Scripts\\.[0-9]+\\.Script|[A-Za-z]+Script)\\._[A-Za-z0-9_]+");
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

// Contract R5 (CONTRACT_PHASE1.md, 2026-09-30): player-facing text, sections and master knobs.
//  - Rows curated by RESEARCH/.../tools/player_text.py carry ui.label_source "player_text"; they and every master knob pass
//    the player-text gates below (a mirror of the tool's gates): label <= 33 characters (the CHECKBOX row "Custom <label>"
//    fits 40) and "<label>: <stock>" <= 40 (the value BUTTON row), no unexplained abbreviation or code identifier, a
//    description that states the stock value followed by its unit, and a rendered tooltip (bootstrapper value_tooltip plus
//    the CHECKBOX prefix) of at most 300 characters, so nothing is cut.
//  - A section is a mission family (first dotted part of the id); its Advanced subsection is the ui group
//    "<family>_advanced", ordered right after the family. Labels are unique within a section (the section TITLE names the
//    mission; the stock search box is off since bootstrapper R4).
//  - A master knob (registry `ui_masters`) is one declared value that drives several rows of ONE module: every driven row
//    gets master x scale unless the row itself is enabled (the row wins). Addon lane: resolved by the generated addon in
//    activate(context). Literal lane: the replacement is built with master x scale in every driven row's sites, and the
//    member declares only the master (one literal value per member, design section 5).
//  - A row with ui.hidden (a reason) is never declared in a package (for example a value no stock code reads).
constexpr const char* kAdvancedGroupSuffix = "_advanced";
constexpr const char* kPlayerTextFormat = "RENOVICE_MISSION_PLAYER_TEXT_V1";
constexpr std::size_t kPlayerLabelMaximum = 33;
constexpr std::size_t kSettingsTooltipMaximum = 300;  // bootstrapper settings_ui_core.hpp maximum_tooltip
const std::vector<std::string>& player_text_banned_words() {
    static const std::vector<std::string> words{"LS", "MD", "SP", "AI", "HP", "DoT", "sim", "Sim", "mult", "Mult", "pct", "dist",
                                                "num", "Num", "lvl", "req", "thr", "cfg", "max.", "min.", "sim.", "mult.", "1P",
                                                "2P", "3P", "4P", "P1", "P2", "P3", "P4", "p1", "p2", "p3", "p4", "Lerp", "proto",
                                                "upvalue", "frame_", "cap_", "Name__", "maxWaveNum", "NpcHardCap", "fixedLength"};
    return words;
}

std::string mission_family(const std::string& id) { return id.substr(0, id.find('.')); }

std::string section_family(const std::string& group) {
    const std::string suffix = kAdvancedGroupSuffix;
    return group.size() > suffix.size() && group.compare(group.size() - suffix.size(), suffix.size(), suffix) == 0
               ? group.substr(0, group.size() - suffix.size()) : group;
}

// Display numbers exactly as the bootstrapper (whole numbers without a decimal point, otherwise %.6g).
std::string settings_display_number(const double value) {
    if (std::floor(value) == value && std::fabs(value) < 1.0e15) return std::to_string(static_cast<long long>(value));
    char buffer[48]{};
    std::snprintf(buffer, sizeof(buffer), "%.6g", value);
    return buffer;
}

std::string settings_with_unit(const double value, const std::string& unit) {
    return settings_display_number(value) + (unit.empty() ? std::string() : unit == "x" ? unit : " " + unit);
}

// Longest tooltip the bootstrapper renders for a value (CHECKBOX row: "Off: ..." + value_tooltip).
std::string settings_rendered_tooltip(const double stock, const std::string& unit, const double low, const double high,
                                      const std::string& scope, const std::string& lane) {
    std::string text = "Off: the stock value is used. Stock " + settings_with_unit(stock, unit) + ".";
    text += " Range " + settings_display_number(low) + " to " + settings_display_number(high) + ".";
    text += " " + scope + ".";
    if (lane == "literal") text += " Edited in Ability Studio; this switch applies the edited script at the next mission.";
    else text += " Applies: live, at the next read. Custom value applies only where the live value equals stock.";
    return text;
}

bool player_text_word_char(const char c) { return std::isalnum(static_cast<unsigned char>(c)) || c == '_'; }

std::vector<std::string> r7_description_problems(const std::string& where, const std::string& text);

// R7 (`layout_r7`): the description is the short player sentence of the page tree (r7_description_problems) instead of
// the R5 sentence that ends with the stock value; every other rule is unchanged.
std::vector<std::string> player_text_problems(const std::string& where, const std::string& label, const std::string& unit,
                                              const double stock, const double low, const double high,
                                              const std::string& description, const std::string& lane,
                                              const bool layout_r7 = false) {
    std::vector<std::string> problems;
    const auto token_problems = [&](const std::string& text, const std::string& what) {
        for (const auto& word : player_text_banned_words())
            for (std::size_t at = text.find(word); at != std::string::npos; at = text.find(word, at + 1)) {
                const bool before = at == 0 || !player_text_word_char(text[at - 1]);
                const bool after = !player_text_word_char(word.back()) || at + word.size() == text.size() ||
                                   !player_text_word_char(text[at + word.size()]);
                if (before && after) {
                    problems.push_back(where + ": " + what + " has the unexplained abbreviation or code token '" + word + "'");
                    break;
                }
            }
        for (std::size_t at = 0; at < text.size();) {
            if (!player_text_word_char(text[at])) { ++at; continue; }
            std::size_t end = at;
            while (end < text.size() && player_text_word_char(text[end])) ++end;
            const std::string token = text.substr(at, end - at);
            static const std::regex camel("[a-z]+[A-Z][A-Za-z]*");
            if (std::regex_match(token, camel)) problems.push_back(where + ": " + what + " has the code identifier '" + token + "'");
            at = end;
        }
    };
    if (label.empty() || label.size() > kPlayerLabelMaximum || !settings_printable(label) || label.front() == ' ' || label.back() == ' ')
        problems.push_back(where + ": label '" + label + "' is empty, padded, not printable ASCII or over " +
                           std::to_string(kPlayerLabelMaximum) + " characters");
    if ((label + ": " + settings_with_unit(stock, unit)).size() > kSettingsLabelBudget)
        problems.push_back(where + ": value row '" + label + ": " + settings_with_unit(stock, unit) + "' is over 40 characters");
    token_problems(label, "label");
    if (description.empty() || description.size() > kSettingsScopeMaximum || !settings_printable(description))
        problems.push_back(where + ": description is empty, not printable ASCII or over 256 characters");
    token_problems(description, "description");
    if (layout_r7) {
        for (const auto& problem : r7_description_problems(where, description)) problems.push_back(problem);
        return problems;
    }
    const std::string head = "stock " + settings_display_number(stock);
    const auto at = description.find(head);
    if (at == std::string::npos) {
        problems.push_back(where + ": description does not state the stock value ('" + head + "')");
    } else {
        const std::string tail = description.substr(at + head.size());
        static const std::map<std::string, std::string> words{{"s", " s"}, {"x", "x"}, {"m", " m"}, {"HP", " health"},
                                                              {"XP", " XP"}, {"min", " min"}};
        if (const auto found = words.find(unit); found != words.end()) {
            if (tail.rfind(found->second, 0) != 0) problems.push_back(where + ": the stock value is not followed by its unit");
        } else if (!(tail.size() >= 2 && ((tail[0] == ' ' && (std::isalpha(static_cast<unsigned char>(tail[1])) || tail[1] == '(')) ||
                                          tail[0] == '%'))) {
            problems.push_back(where + ": the stock value of a unitless value is not followed by what it counts");
        }
    }
    const auto tooltip = settings_rendered_tooltip(stock, unit, low, high, description, lane);
    if (tooltip.size() > kSettingsTooltipMaximum)
        problems.push_back(where + ": rendered tooltip is " + std::to_string(tooltip.size()) + " characters (over 300)");
    return problems;
}

const Json* mission_master(const Json& registry, const std::string& id) {
    if (!registry.contains("ui_masters") || !registry.at("ui_masters").contains(id)) return nullptr;
    return &registry.at("ui_masters").at(id);
}

// Contract R7 (CONTRACT_PHASE1.md, 2026-09-30): the SCRIPT SETTINGS page tree. Every declared value carries `path` (the
// pages below the package page: mission type, optional location or mode, category, optional set) and `row` (its row
// text on the last page); headline values carry `quick` (their Quick settings label) and range defaults
// `default_label`. The registry holds the full path (RESEARCH/.../tools/player_layout.py); a package build drops a
// category level whose parent page would hold that one category only (r7_collapse_paths). Descriptions (`scope`) are
// one or two short plain sentences: no stock number (the row shows the default), no node lists, codes or ids.
constexpr const char* kLayoutFormat = "RENOVICE_MISSION_LAYOUT_V1";
constexpr std::size_t kPathDepthMaximum = 6;       // bootstrapper settings_core.hpp maximum_path_depth
constexpr std::size_t kPathTextMaximum = 40;       // maximum_path_text
constexpr std::size_t kRowTextMaximum = 33;        // maximum_row_text
constexpr std::size_t kQuickLabelMaximum = 40;     // maximum_quick_label
constexpr std::size_t kDefaultLabelMaximum = 20;   // maximum_default_label
constexpr std::size_t kDescriptionMaximumR7 = 200;
const std::vector<std::string>& r7_categories() {
    static const std::vector<std::string> names{"Timers", "Objectives", "Enemies", "Rewards / drops", "Advanced"};
    return names;
}
bool r7_category(const std::string& name) {
    const auto& names = r7_categories();
    return std::find(names.begin(), names.end(), name) != names.end();
}

// Layout text as the bootstrapper parses it (printable, not padded), plus the R7 producer rules: no "::" and no
// dangling colon (the live R5 defects "Disruption::" and "Control Area: 1 value" came from cut labels).
bool r7_text(const std::string& text, const std::size_t maximum) {
    return !text.empty() && text.size() <= maximum && settings_printable(text) && text.front() != ' ' && text.back() != ' ' &&
           text.find("::") == std::string::npos && text.back() != ':';
}

std::vector<std::string> r7_description_problems(const std::string& where, const std::string& text) {
    std::vector<std::string> problems;
    if (text.empty() || text.size() > kDescriptionMaximumR7 || !settings_printable(text))
        problems.push_back(where + ": description is empty, not printable ASCII or over 200 characters");
    std::size_t sentences = 0;
    for (std::size_t at = 0; at < text.size(); ++at)
        if ((text[at] == '.' || text[at] == '!' || text[at] == '?') && (at + 1 == text.size() || text[at + 1] == ' ')) ++sentences;
    if (sentences == 0 || sentences > 2) problems.push_back(where + ": description is not one or two sentences");
    static const std::regex internal("MT_[A-Z_]+|\\b[A-Z][A-Z0-9]*_[A-Z0-9_]+\\b|\\b[a-z0-9_]+\\.[a-z0-9_]+\\b|SolNode|frame_|proto");
    static const std::regex camel("\\b[a-z]+[A-Z][A-Za-z]*\\b");
    if (std::regex_search(text, internal) || std::regex_search(text, camel))
        problems.push_back(where + ": description carries an internal id, code token or MT code");
    if (std::count(text.begin(), text.end(), ',') > 3) problems.push_back(where + ": description reads like a list (more than 3 commas)");
    std::string lower = text;
    std::transform(lower.begin(), lower.end(), lower.begin(), [](const unsigned char c) { return static_cast<char>(std::tolower(c)); });
    if (lower.find("stock") != std::string::npos) problems.push_back(where + ": description says \"stock\" (the menu says Default)");
    return problems;
}

// Drops a category level whose parent page would hold that one category only (and no other page). Deterministic over
// the declared set; the bootstrapper renders whatever paths it receives.
std::map<std::string, std::vector<std::string>> r7_collapse_paths(std::map<std::string, std::vector<std::string>> paths) {
    for (;;) {
        std::map<std::vector<std::string>, std::set<std::string>> children;
        for (const auto& [id, path] : paths)
            for (std::size_t depth = 0; depth < path.size(); ++depth)
                children[std::vector<std::string>(path.begin(), path.begin() + static_cast<std::ptrdiff_t>(depth))].insert(path[depth]);
        // The shallowest page whose only child is one category page (never the package page: mission types stay).
        const std::vector<std::string>* parent = nullptr;
        for (const auto& [prefix, names] : children)
            if (!prefix.empty() && names.size() == 1 && r7_category(*names.begin()) && (parent == nullptr || prefix.size() < parent->size()))
                parent = &prefix;
        if (parent == nullptr) return paths;
        const auto cut = *parent;
        for (auto& [id, path] : paths)
            if (path.size() > cut.size() && std::equal(cut.begin(), cut.end(), path.begin()))
                path.erase(path.begin() + static_cast<std::ptrdiff_t>(cut.size()));
    }
}

std::vector<std::string> r7_layout_ui_problems(const std::string& where, const Json& ui) {
    std::vector<std::string> problems;
    if (!ui.contains("path") || !ui.at("path").is_array() || ui.at("path").empty() || ui.at("path").size() > kPathDepthMaximum) {
        problems.push_back(where + ": ui path is missing or not 1 to 6 pages");
    } else {
        for (const auto& element : ui.at("path"))
            if (!element.is_string() || !r7_text(element.get<std::string>(), kPathTextMaximum) ||
                (element.get<std::string>().find('/') != std::string::npos && element.get<std::string>() != "Rewards / drops"))
                problems.push_back(where + ": ui path element is empty, padded, over 40 characters, has \"::\", a slash or a trailing colon");
    }
    if (!ui.contains("row") || !ui.at("row").is_string() || !r7_text(ui.at("row").get<std::string>(), kRowTextMaximum))
        problems.push_back(where + ": ui row is missing, padded, over 33 characters or has \"::\"");
    if (ui.contains("quick") && (!ui.at("quick").is_string() || !r7_text(ui.at("quick").get<std::string>(), kQuickLabelMaximum)))
        problems.push_back(where + ": ui quick label is invalid");
    if (ui.contains("default_label") &&
        (!ui.at("default_label").is_string() || !r7_text(ui.at("default_label").get<std::string>(), kDefaultLabelMaximum)))
        problems.push_back(where + ": ui default_label is invalid");
    // R17: an "All <type> missions" master: a quick value on its mission-type page.
    if (ui.contains("quick_on_page") &&
        (!ui.at("quick_on_page").is_boolean() || !ui.contains("quick") || !ui.contains("path") || !ui.at("path").is_array() ||
         ui.at("path").size() != 1))
        problems.push_back(where + ": ui quick_on_page needs a quick label and the mission-type page as its path");
    return problems;
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
    for (const auto& [id, group] : groups.items()) {
        // R5: an Advanced subsection names its family and sorts right after it.
        if (!group.contains("advanced_of")) continue;
        const auto family = group.at("advanced_of").get<std::string>();
        if (id != family + kAdvancedGroupSuffix || !groups.contains(family) || groups.at(family).contains("advanced_of") ||
            group.at("order").get<long long>() <= groups.at(family).at("order").get<long long>())
            throw std::runtime_error("ui group " + id + " is not the Advanced subsection of an existing family ordered after it");
    }
    std::map<std::string, std::string> labels;  // (section family + folded label) -> id
    const auto unique_label = [&](const std::string& id, const std::string& group, const std::string& label) {
        std::string folded = label;
        std::transform(folded.begin(), folded.end(), folded.begin(), [](const unsigned char c) { return static_cast<char>(std::tolower(c)); });
        // R5: unique within the mission section (family and its Advanced subsection). The section TITLE names the mission and
        // the stock search box is off (bootstrapper R4), so "Max enemies at once (solo)" may appear in several sections.
        if (const auto [it, inserted] = labels.emplace(section_family(group) + "|" + folded, id); !inserted)
            throw std::runtime_error(id + ": short_label is not unique in its mission section " + section_family(group) + " (also " +
                                     it->second + ")");
    };
    const bool player_text = registry.contains("ui_player_text");
    const bool layout_r7 = registry.contains("ui_layout");
    if (layout_r7 && registry.at("ui_layout").value("format", std::string()) != kLayoutFormat)
        throw std::runtime_error("registry ui_layout is not RENOVICE_MISSION_LAYOUT_V1");
    if (player_text) {
        const Json& meta = registry.at("ui_player_text");
        if (meta.value("format", std::string()) != kPlayerTextFormat || meta.at("banned_abbreviations") != Json(player_text_banned_words()))
            throw std::runtime_error("registry ui_player_text is not RENOVICE_MISSION_PLAYER_TEXT_V1 with the generator's banned-abbreviation list");
    }
    for (const auto& row : registry.at("tunables")) {
        const auto id = row.at("tunable_id").get<std::string>();
        if (!row.contains("ui") || !row.at("ui").is_object()) throw std::runtime_error(id + ": no ui fields");
        const Json& ui = row.at("ui");
        const auto group = ui.at("group").get<std::string>();
        if (!groups.contains(group) || mission_family(id) != section_family(group)) throw std::runtime_error(id + ": ui group is not its tunable_id family");
        const auto label = ui.at("short_label").get<std::string>();
        if (label.empty() || !settings_printable(label) || label.front() == ' ' || label.back() == ' ' ||
            std::string(kSettingsCheckboxPrefix).size() + label.size() > kSettingsLabelBudget)
            throw std::runtime_error(id + ": short_label is empty, not printable ASCII or over the " + std::to_string(kSettingsLabelBudget) +
                                     "-character row budget");
        unique_label(id, group, label);
        const auto scope = ui.at("scope_text").get<std::string>();
        if (scope.empty() || scope.size() > kSettingsScopeMaximum || !settings_printable(scope))
            throw std::runtime_error(id + ": scope_text is empty, not printable ASCII or over " + std::to_string(kSettingsScopeMaximum) + " characters");
        if (ui.contains("rank") && !ui.at("rank").is_number_integer()) throw std::runtime_error(id + ": ui rank is not an integer");
        if (ui.contains("hidden") && (!ui.at("hidden").is_string() || ui.at("hidden").get<std::string>().empty()))
            throw std::runtime_error(id + ": ui hidden must be a non-empty reason");
        if (ui.value("label_source", std::string()) == "player_text") {
            if (!player_text) throw std::runtime_error(id + ": player_text row without registry ui_player_text");
            if (row.at("stock").is_number())
                for (const auto& problem : player_text_problems(id, label, ui.at("unit").get<std::string>(), row.at("stock").get<double>(),
                                                                ui.at("min").get<double>(), ui.at("max").get<double>(), scope,
                                                                ui.at("lane").get<std::string>(), layout_r7))
                    throw std::runtime_error(problem);
        }
        if (layout_r7)
            for (const auto& problem : r7_layout_ui_problems(id, ui)) throw std::runtime_error(problem);
        const auto lane = settings_lane(row.at("backend").get<std::string>());
        // R10: an entry-template addon row is written at the mission's entry, so it applies at the next mission.
        const auto applies = entry_template_row(row) ? std::string("next_mission") : settings_applies(lane);
        if (ui.at("lane") != lane || ui.at("applies") != applies) throw std::runtime_error(id + ": ui lane/applies disagree with the backend");
        if (ui.contains("stock_check") && (lane != "addon" || (ui.at("stock_check") != "live" && ui.at("stock_check") != "none")))
            throw std::runtime_error(id + ": ui stock_check must be live or none on the addon lane");
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
    // R5 master knobs: one module, one lane, every driven row driven once, stock = first row stock / its scale, limits inside
    // every driven row's limits after scaling, whole scales for int masters, the player-text gates. R17: a mission-type
    // master may drive rows of several modules; it then lists them in `body_keys` (first driven row's module first) and its
    // group may be the main section of its first driven row's family. Its `applies` is that of every driven row.
    if (!registry.contains("ui_masters")) return;
    static const std::regex master_id("[A-Za-z0-9_.]{1,128}");
    std::map<std::string, std::string> driven_by;
    for (const auto& [id, master] : registry.at("ui_masters").items()) {
        if (!std::regex_match(id, master_id)) throw std::runtime_error("ui master " + id + ": invalid value id");
        for (const auto& row : registry.at("tunables"))
            if (row.at("tunable_id") == id) throw std::runtime_error("ui master " + id + ": id collides with a tunable_id");
        const auto group = master.at("group").get<std::string>();
        const auto first_row = master.at("drives").is_array() && !master.at("drives").empty()
                                   ? master.at("drives").at(0).at("tunable_id").get<std::string>() : std::string();
        if (!groups.contains(group) || (group != mission_family(id) && group != mission_family(first_row)) ||
            groups.at(group).contains("advanced_of"))
            throw std::runtime_error("ui master " + id + ": group is not its family's main section");
        const auto lane = master.at("lane").get<std::string>();
        const auto master_applies = master.at("applies").get<std::string>();
        if ((lane != "addon" && lane != "literal") ||
            (master_applies != settings_applies(lane) && !(lane == "addon" && master_applies == "next_mission")))
            throw std::runtime_error("ui master " + id + ": lane/applies must be addon/live_next_read, addon/next_mission or literal/next_mission");
        const auto type = master.at("type").get<std::string>();
        const double stock = master.at("stock").get<double>(), low = master.at("min").get<double>(), high = master.at("max").get<double>();
        if ((type != "int" && type != "float") || low > high || stock < low || stock > high ||
            (type == "int" && (!settings_whole(master.at("stock")) || !settings_whole(master.at("min")) || !settings_whole(master.at("max")))))
            throw std::runtime_error("ui master " + id + ": type, stock or limits are inconsistent");
        const auto editor = master.at("editor").get<std::string>();
        if (editor != (type == "int" && low >= 0 ? "INPUTCOUNT" : "INPUTBOX")) throw std::runtime_error("ui master " + id + ": editor/limits disagree");
        if (!master.at("drives").is_array() || master.at("drives").empty()) throw std::runtime_error("ui master " + id + ": drives no row");
        const auto body = master.at("body_key").get<std::string>();
        std::set<std::string> bodies{body}, drive_bodies;
        if (master.contains("body_keys")) {
            const auto listed = master.at("body_keys").get<std::vector<std::string>>();
            if (listed.size() < 2 || listed.front() != body) throw std::runtime_error("ui master " + id + ": body_keys must list several modules, body_key first");
            bodies.insert(listed.begin(), listed.end());
            if (bodies.size() != listed.size()) throw std::runtime_error("ui master " + id + ": body_keys lists a module twice");
        }
        bool first = true;
        for (const auto& drive : master.at("drives")) {
            const auto row_id = drive.at("tunable_id").get<std::string>();
            const Json& row = mission_tunable(registry, row_id);
            const double scale = drive.at("scale").get<double>();
            if (!(scale > 0) || (type == "int" && std::floor(scale) != scale))
                throw std::runtime_error("ui master " + id + ": scale of " + row_id + " must be positive (whole for an int master)");
            if (!bodies.contains(row.at("owner").at("body_key").get<std::string>()) || row.at("ui").at("lane") != lane)
                throw std::runtime_error("ui master " + id + ": " + row_id + " is not a " + lane + " row of module " + body);
            if (row.at("ui").at("applies") != master_applies)
                throw std::runtime_error("ui master " + id + ": " + row_id + " applies " + row.at("ui").at("applies").get<std::string>() +
                                         ", the master " + master_applies);
            drive_bodies.insert(row.at("owner").at("body_key").get<std::string>());
            if (!row.at("stock").is_number()) throw std::runtime_error("ui master " + id + ": " + row_id + " has no stock");
            if (first && std::fabs(row.at("stock").get<double>() / scale - stock) > 1e-9)
                throw std::runtime_error("ui master " + id + ": stock is not the first driven row's stock divided by its scale");
            if (low * scale < row.at("limits").at("minimum").get<double>() - 1e-9 || high * scale > row.at("limits").at("maximum").get<double>() + 1e-9)
                throw std::runtime_error("ui master " + id + ": limits exceed " + row_id + " after scaling");
            if (const auto [it, inserted] = driven_by.emplace(row_id, id); !inserted)
                throw std::runtime_error("ui master " + id + ": " + row_id + " is already driven by " + it->second);
            first = false;
        }
        if (drive_bodies != bodies) throw std::runtime_error("ui master " + id + ": body_keys are not exactly the modules of its driven rows");
        const auto label = master.at("short_label").get<std::string>();
        unique_label(id, group, label);
        for (const auto& problem : player_text_problems(id, label, master.at("unit").get<std::string>(), stock, low, high,
                                                        master.at("scope_text").get<std::string>(), lane, layout_r7))
            throw std::runtime_error(problem);
        if (layout_r7)
            for (const auto& problem : r7_layout_ui_problems(id, master)) throw std::runtime_error(problem);
    }
}

// Declaration of one master knob (R5): the same fields as a row declaration.
// R7 layout fields of a declaration (the registry path; a package build collapses single-category levels).
void add_layout_fields(Json& declaration, const Json& ui) {
    for (const char* key : {"path", "row", "quick", "default_label"})
        if (ui.contains(key)) declaration[key] = ui.at(key);
    // R17: the "All <type> missions" master shows its Quick settings pair on its own page.
    if (ui.value("quick_on_page", false)) declaration["quick_on_page"] = true;
}

// R17: the BUTTON text of a quick_on_page pair: the Quick settings label after its colon, first letter upper case
// (bootstrapper settings_ui_core.hpp quick_pair_label).
std::string quick_pair_label(const std::string& quick) {
    const auto colon = quick.find(':');
    std::string what = colon == std::string::npos ? quick : quick.substr(colon + 1);
    const auto start = what.find_first_not_of(' ');
    what = start == std::string::npos ? std::string() : what.substr(start);
    if (!what.empty()) what[0] = static_cast<char>(std::toupper(static_cast<unsigned char>(what[0])));
    return what;
}

Json mission_master_declaration(const Json& master) {
    Json declaration{{"group", master.at("group")}, {"label", master.at("short_label")}, {"unit", master.at("unit")}, {"type", master.at("type")},
                     {"stock", master.at("stock")}, {"min", master.at("min")}, {"max", master.at("max")}, {"scope", master.at("scope_text")},
                     {"lane", master.at("lane")}, {"applies", master.at("applies")}};
    add_layout_fields(declaration, master);
    return declaration;
}

// Declaration of one value (design section 3.2), copied from the registry row: stock is the registry stock.
Json mission_value_declaration(const Json& row) {
    const Json& ui = row.at("ui");
    Json declaration{{"group", ui.at("group")}, {"label", ui.at("short_label")}, {"unit", ui.at("unit")}, {"type", ui.at("type")},
                     {"stock", row.at("stock")}, {"min", ui.at("min")}, {"max", ui.at("max")}, {"scope", ui.at("scope_text")},
                     {"lane", ui.at("lane")}, {"applies", ui.at("applies")}};
    if (ui.contains("options")) declaration["options"] = ui.at("options");
    // R1 field, emitted since R10 for values the addon writes whatever the live value is (script-parameter scales).
    if (ui.contains("stock_check")) declaration["stock_check"] = ui.at("stock_check");
    add_layout_fields(declaration, ui);
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
    // R7 (bootstrapper feat/settings-r7-hierarchy-2026-09-30): "path", "row", "quick", "default_label" and "default".
    // R17 (bootstrapper feat/r17-type-masters-2026-10-01): "quick_on_page" (bool; needs "quick").
    static const std::set<std::string> value_fields{"group", "label", "unit", "type", "stock", "min", "max", "scope", "lane", "applies", "options", "stock_check",
                                                    "path", "row", "quick", "default_label", "default", "quick_on_page"};
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
            if (value.contains("path")) {
                const Json& path = value.at("path");
                if (!path.is_array() || path.empty() || path.size() > kPathDepthMaximum) problems.push_back(where + ": path is not 1 to 6 pages");
                else
                    for (const auto& element : path)
                        if (!element.is_string() || !r7_text(element.get<std::string>(), kPathTextMaximum) ||
                            (element.get<std::string>().find('/') != std::string::npos && element.get<std::string>() != "Rewards / drops"))
                            problems.push_back(where + ": path element is invalid");
            }
            if (value.contains("row") && (!value.at("row").is_string() || !r7_text(value.at("row").get<std::string>(), kRowTextMaximum)))
                problems.push_back(where + ": row is invalid");
            if (value.contains("quick") && (!value.at("quick").is_string() || !r7_text(value.at("quick").get<std::string>(), kQuickLabelMaximum)))
                problems.push_back(where + ": quick is invalid");
            if (value.contains("default_label") &&
                (!value.at("default_label").is_string() || !r7_text(value.at("default_label").get<std::string>(), kDefaultLabelMaximum)))
                problems.push_back(where + ": default_label is invalid");
            if (value.contains("quick_on_page") && (!value.at("quick_on_page").is_boolean() || !value.contains("quick")))
                problems.push_back(where + ": quick_on_page must be a boolean of a value with a quick label");
            if (value.contains("default")) {
                if (!value.at("default").is_number() || value.value("lane", std::string("addon")) != "addon")
                    problems.push_back(where + ": default must be a number on the addon lane");
                else if (value.contains("min") && value.contains("max") && value.at("min").is_number() && value.at("max").is_number() &&
                         (value.at("default").get<double>() < value.at("min").get<double>() ||
                          value.at("default").get<double>() > value.at("max").get<double>()))
                    problems.push_back(where + ": default is outside min..max");
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
    // R7: the value row "<row>: <default> (default)" (bootstrapper value_row_label) fits the 40-character row.
    if (declaration.contains("row")) {
        const std::string shown = declaration.contains("default_label") ? declaration.at("default_label").get<std::string>()
                                  : declaration.at("type") == "enum"
                                      ? [&]() {
                                            for (const auto& option : declaration.at("options"))
                                                if (option.at("value") == declaration.at("stock")) return option.at("label").get<std::string>();
                                            return std::string();
                                        }()
                                      : settings_with_unit(declaration.at("stock").get<double>(), declaration.at("unit").get<std::string>());
        const std::string row = declaration.at("row").get<std::string>() + ": " + shown + " (default)";
        // R17: a quick_on_page value shows CHECKBOX "<row>" and BUTTON "<quick label after its colon>: <kept value>" there.
        if (declaration.value("quick_on_page", false) && declaration.contains("quick")) {
            const std::string pair = quick_pair_label(declaration.at("quick").get<std::string>()) + ": " + shown + " (default)";
            if (pair.size() > kSettingsLabelBudget) problems.push_back(id + ": page pair \"" + pair + "\" is over 40 characters");
        } else if (row.size() > kSettingsLabelBudget) {
            problems.push_back(id + ": value row \"" + row + "\" is over 40 characters");
        }
        if (declaration.contains("quick")) {  // the Quick settings BUTTON "<quick label before its colon>: <kept value>"
            const auto quick = declaration.at("quick").get<std::string>();
            const std::string owner = quick.substr(0, quick.find(':')) + ": " + shown + " (default)";
            if (owner.size() > kSettingsLabelBudget) problems.push_back(id + ": Quick settings row \"" + owner + "\" is over 40 characters");
        }
    }
    const auto title = settings_upper(group.at("label").get<std::string>());
    if (title.size() > kSettingsTitleBudget) problems.push_back(id + ": group title " + title + " is over " + std::to_string(kSettingsTitleBudget) + " characters");
    return problems;
}

// Compiled values of a generated multi-target addon source: `[id] = { value = V, stock = S, enabled = B },` per value.
struct CompiledMissionValue { double value = 0; double stock = 0; bool enabled = false; };
std::map<std::string, CompiledMissionValue> multi_target_compiled_values(const std::string& source) {
    static const std::regex entry("\\[\"([A-Za-z0-9_.]+)\"\\] = \\{ value = ([^,]+), stock = ([^,]+), enabled = (true|false) \\},");
    std::map<std::string, CompiledMissionValue> values;
    for (auto it = std::sregex_iterator(source.begin(), source.end(), entry); it != std::sregex_iterator(); ++it) {
        const CompiledMissionValue value{std::stod((*it)[2].str()), std::stod((*it)[3].str()), (*it)[4].str() == "true"};
        const auto [slot, inserted] = values.emplace((*it)[1].str(), value);
        // R17: a cross-module master knob is compiled into every target that holds one of its rows, identically.
        if (!inserted && (slot->second.value != value.value || slot->second.stock != value.stock || slot->second.enabled != value.enabled))
            throw std::runtime_error("compiled value " + (*it)[1].str() + " appears twice with different entries");
    }
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

std::map<std::string, double> validate_mission_values(const Json& registry, const Json& values, const bool allow_empty = false) {
    // A package that declares every addon value may enable none of them (everything stock, nothing hooked).
    if (!values.is_object() || (values.empty() && !allow_empty)) throw std::runtime_error("Mission settings must name at least one tunable_id");
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
    // Phase 2k, settings.package_scope == "all_addon_values" (package layout only): the Missions addon member declares
    // EVERY multi-instance-safe TARGET_ADDON row of the registry so SCRIPT SETTINGS can edit any mission value. Rows named
    // in `values` are enabled with that value; every other declared row is compiled as stock and disabled. luaCalls hooks
    // are emitted only for root tables that hold at least one enabled value (a target without one declares no hook).
    bool declare_all_addon_values = false;
    // R5, settings.disabled_values (package_scope all_addon_values only): ids named in `values` that are built with that
    // value but shipped switched off (compiled enabled = false; the Settings file entry enabled = false). A replacement
    // member whose declared values are all off is not staged until the player ticks one (bootstrapper literal gate).
    std::set<std::string> disabled_values{};
    // LIVE_LITERALS_V1 (contract R8), settings.literal_mode == "recipe" (package layout, all_addon_values): literal values
    // are emitted as a declarative recipe (Packages/Missions/literals.json) the bootstrapper synthesizes at each apply, so
    // they are typeable in game; no baked exact replacement is built. settings.literal_scope == "headline" also declares
    // every registry headline literal value (ui_player_text.live_literal_headline) at stock/off.
    bool literal_recipes = false;
    bool literal_headline = false;
};

// R5 master knobs of one build: value per declared master (build value or stock) and whether it ships enabled.
struct MasterBuild { double value = 0; bool enabled = false; };

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
constexpr std::uintmax_t kPackageManifestMaximumBytes = 512u * 1024u;  // bootstrapper packages_core.hpp maximum_manifest_bytes

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

// The in-game SCRIPT SETTINGS editor shows a member label on one CHECKBOX row of 40 characters (bootstrapper
// renovice/settings_ui_core.hpp maximum_row_label); a longer label is cut there ("Mission tunables: Purgatory,", live
// 2026-09-30). The label is therefore short and human-readable, built from the member's section labels; the technical
// detail (modules, tunable ids) is kept as `detail` in the build manifest member record, and the runtime tooltip lists
// the file and the declared values per section. The loader's own limit stays kPackageLabelMaximum.
constexpr std::size_t kPackageMemberRowLabelBudget = 40;

// Section (ui group) labels of the member's tunables, in registry group order.
std::vector<std::string> member_section_labels(const Json& registry, const std::vector<std::string>& tunables) {
    std::map<long long, std::string> ordered;
    for (const auto& id : tunables) {
        // R5: an Advanced subsection counts as its mission section.
        const auto group = section_family(mission_tunable(registry, id).at("ui").at("group").get<std::string>());
        const Json& record = registry.at("ui_groups").at(group);
        ordered[record.at("order").get<long long>()] = record.at("label").get<std::string>();
    }
    std::vector<std::string> labels;
    for (const auto& [order, label] : ordered) {
        static_cast<void>(order);
        labels.push_back(label);
    }
    return labels;
}

// First candidate that fits the row budget and is unique (case-insensitive) among the package's member labels.
std::string package_member_label(const Json& registry, const std::string& backend, const std::vector<std::string>& tunables,
                                 const std::string& body_key, const std::set<std::string>& used_lower) {
    const auto sections = member_section_labels(registry, tunables);
    std::string list;
    for (const auto& label : sections) list += (list.empty() ? "" : ", ") + label;
    const std::string count = std::to_string(sections.size()) + (sections.size() == 1 ? " section" : " sections");
    std::vector<std::string> candidates;
    if (backend == "TARGET_ADDON") {
        if (!list.empty()) candidates = {"Mission values: " + list, "Values: " + list};
        candidates.push_back("Mission values: " + count);
    } else {
        if (!list.empty()) candidates = {list + " (script replacement)", list + " replacement"};
        candidates.push_back("Script replacement: " + count);
        candidates.push_back("Script replacement " + body_key.substr(0, std::min<std::size_t>(8, body_key.size())));
    }
    for (const auto& candidate : candidates)
        if (candidate.size() <= kPackageMemberRowLabelBudget && settings_printable(candidate) &&
            !used_lower.count(ascii_lower_text(candidate)))
            return candidate;
    throw std::runtime_error("no package member label within " + std::to_string(kPackageMemberRowLabelBudget) +
                             " characters is unique for the " + backend + " member " + body_key);
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
// `settings` table (`[id] = { value, stock, enabled }`, stock equal to the registry stock). `activate(context)` derives the
// effective settings of this generation: with `context.settings` (a generation-owned table `[id] = { enabled, value, stock }`
// built by the host from package.json declarations and CustomScripts\Settings\<package>.json) only enabled values whose
// declared stock equals the compiled stock are bound; a missing or disabled value keeps its field stock and is never
// written. Without `context.settings` (loose layout, an older runtime, or rejected declarations) the compiled values apply
// where their compiled `enabled` flag is true. The stock check runs only over the fields this generation writes.
//
// Phase 2k (performance + in-game editing): EVERY root table that holds a declared value is hooked, at its proven minimal
// prototypes only (registry `minimal_hooks.prototypes`, gate ROOT_TABLE_MINIMAL_HOOKS_V1), so any value can be ticked in
// SCRIPT SETTINGS without a rebuild. A hook whose tables hold no enabled value in the active generation returns the R3
// retire sentinel before it touches anything (one dispatch per prototype per module instance); a hook with an enabled
// value binds, writes and then retires. SCRIPT SETTINGS apply and F9 commit a new generation, which re-arms every hook
// (contract R3), so a newly ticked value is written at the next call of its hook.
// R3 RETIRE POINT. Contract Revision R3 (CONTRACT_PHASE1.md; bootstrapper feat/lua-call-retire-2026-09-30 f3a3303): a
// luaCalls[P].before callback that returns the exact string "RENOVICE_RETIRE" retires prototype P for the module instance
// it saw; the runtime re-arms it at the next root entry (new instance), at every F9 commit and on rebind/enable/disable.
// Pre-R3 DLLs ignore the return value. Two retire paths per hook, both only when P is a direct child of the module root
// (registry minimal_hooks.root_children; a nested prototype's signal would be ignored, so the build fails instead):
//  - IDLE: right after the activation guard, when none of the hook's tables holds an enabled value in this generation.
//    Nothing is written, so retiring is safe for any table (the next generation re-arms the hook).
//  - SETTLED: as the LAST statement, after every bind of the hook returned (bound and written, already bound, or drifted and
//    reported by an error on its first call), and only when every bound table is retire-safe (registry
//    minimal_hooks.retire_safe: the table cannot be replaced by another table during the instance).
// R4 RETIRE-ALL POINT. Contract Revision R4 / S5 (CONTRACT_PHASE1.md; bootstrapper feat/lua-call-retire-r4-2026-09-30
// e935739): a callback returning "RENOVICE_RETIRE", "RENOVICE_RETIRE_ALL" retires this hook and every other retirable hook
// the addon declares for the same target key, for the current module instance (hooks not called yet included). The
// two-value form is a plain R3 retire on R3 DLLs (one result read) and ignored by pre-R3 DLLs. The generator emits it as
// the FIRST statement after the activation guard, only when NO declared value of the target is enabled in the active
// generation (`liveTarget`, the OR of every table flag of the target, set in activate), so no hook of the target can
// have work for this instance (R4 obligation 1). Otherwise the R3 idle path and the settled path run unchanged
// (obligations 2 and 3). It is emitted only from hooks that carry the settled R3 retire, i.e. root children whose bound
// tables are all retire-safe (obligation 4).
constexpr const char* kLuaCallRetireSentinel = "RENOVICE_RETIRE";
constexpr const char* kLuaCallRetireAllSentinel = "RENOVICE_RETIRE_ALL";
constexpr const char* kTargetLiveFlag = "liveTarget";
std::string hook_retire_statement() {
    return std::string("return \"") + kLuaCallRetireSentinel + "\" -- R3: this hook's tables are settled for this instance";
}
std::string hook_idle_retire_statement(const std::string& condition) {
    return "if not (" + condition + ") then return \"" + kLuaCallRetireSentinel +
           "\" end -- R3: no enabled value for this hook's tables";
}
std::string hook_retire_all_statement() {
    return std::string("if not ") + kTargetLiveFlag + " then return \"" + kLuaCallRetireSentinel + "\", \"" +
           kLuaCallRetireAllSentinel + "\" end -- R4: no enabled value of this target";
}
std::string target_live_assignment(const std::vector<std::size_t>& slots) {
    std::string condition;
    for (const auto n : slots) condition += (condition.empty() ? "live" : " or live") + std::to_string(n);
    return std::string(kTargetLiveFlag) + " = " + (condition.empty() ? std::string("false") : condition);
}

// R5 master knobs, generated source form (read back by multi_target_compiled_values like every settings entry):
//   local masters = { ["<id>"] = { value = V, stock = S, enabled = B }, }   -- compiled value, declared stock, build choice
//   local drives = { ["<row>"] = { master = "<id>", scale = N }, }          -- the master that drives a row
// effectiveSettings(settings, context, masters, drives): a row that is itself usable (enabled, number, declared stock equal
// to the compiled stock) keeps its own value; otherwise a usable master gives master x scale; otherwise the row stays stock
// and is never written. Without context.settings the compiled flags decide in the same order. A build without masters
// emits the Phase 2i function unchanged (byte-identical sources).
constexpr const char* kMasterEffectiveCall = "effectiveSettings(settings, context, masters, drives)";
constexpr const char* kHashedFieldDirective = "-- RENOVICE_HASH_FIELD: ";

// Contract R10 entry templates, generated Lua (file-level helpers, emitted only when a template is used):
//  - missionInfo_<field>(tag, value): host only (gRegion:IsMaster()); on a normal node (field 0; no alert, invasion,
//    syndicate, goal, sortie or nightmare mission) writes the field through the game's own setter and prints one line;
//    skips when the field already holds the value, so repeated entries and several entry prototypes write once.
//  - scriptParameter(tag, mode, read, write): per called environment (weak keys) the first entry records the observed
//    number and writes observed x value (scale), observed / value (scale_inverse) or value (absolute); later entries skip
//    while the written number is there, write again when the observed number is back, and leave any other number alone
//    (another writer: fail closed, one line). restore() puts the observed number back where the written one is still
//    there (cleanup: F9 or SCRIPT SETTINGS apply, script disable). No environment (runtime before R10): nothing written.
std::string mission_info_helper(const std::string& field) {
    return "local function missionInfo_" + field + "(tag, value)\n"
           "    local region = gRegion\n"
           "    if region == nil or not region:IsMaster() then return end\n"
           "    local rules = gGameRules\n"
           "    if rules == nil then return end\n"
           "    local mission = rules:GetMission()\n"
           "    if mission == nil then return end\n"
           "    local now = mission." + field + "\n"
           "    if now == value then return end\n"
           "    if now ~= 0 or mission.alertId ~= \"\" or mission.invasionId ~= \"\" or mission.goalId ~= \"\" or mission.sortieId ~= \"\"\n"
           "        or mission.nightmare then return end\n"
           "    local syndicate = mission.syndicateTag\n"
           "    if syndicate ~= nil and syndicate:IsValid() then return end\n"
           "    mission." + field + " = value\n"
           "    rules:SetMission(mission)\n"
           "    print(\"RENOVICE Missions: \" .. tag .. \" " + field + " 0 -> \" .. tostring(value))\n"
           "end\n";
}

constexpr const char* kScriptParameterHelper =
    "local function scriptParameter(tag, mode, read, write)\n"
    "    local records = setmetatable({}, { __mode = \"k\" }) -- environment -> { observed, written }, or false\n"
    "    local function enter(environment, value)\n"
    "        if type(environment) ~= \"table\" then return end\n"
    "        local record = records[environment]\n"
    "        local current = read(environment)\n"
    "        if record == nil then\n"
    "            if type(current) ~= \"number\" then\n"
    "                records[environment] = false\n"
    "                print(\"RENOVICE Missions: \" .. tag .. \" is not a number in this instance; left unchanged\")\n"
    "                return\n"
    "            end\n"
    "            local written = value\n"
    "            if mode == \"scale\" then written = current * value elseif mode == \"scale_inverse\" then written = current / value end\n"
    "            write(environment, written)\n"
    "            records[environment] = { observed = current, written = written }\n"
    "            print(\"RENOVICE Missions: \" .. tag .. \" \" .. tostring(current) .. \" -> \" .. tostring(written))\n"
    "            return\n"
    "        end\n"
    "        if record == false or current == record.written then return end\n"
    "        if current == record.observed then\n"
    "            write(environment, record.written)\n"
    "            return\n"
    "        end\n"
    "        records[environment] = false\n"
    "        print(\"RENOVICE Missions: \" .. tag .. \" was changed by another writer; left unchanged\")\n"
    "    end\n"
    "    local function restore()\n"
    "        for environment, record in pairs(records) do\n"
    "            if record and read(environment) == record.written then write(environment, record.observed) end\n"
    "            records[environment] = nil\n"
    "        end\n"
    "    end\n"
    "    return enter, restore\n"
    "end\n";

// Contract R11 (2026-09-30): scriptCountParameter(tag, read, write) is the scale_count form of scriptParameter, emitted only
// when a row uses it. The parameter is a whole-number count or a plain list of counts (a level/encounter table such as the
// Railjack kill goals {20,35,55,85,110}): every number n >= 1 becomes round(n x value), at least 1 (a number below 1 is
// kept); a list is written as a NEW list, so the level's own table is never mutated and cleanup puts the original table
// back. Anything else (nil, a string, a list with a non-number value or a non-list key) is left unchanged with one line.
// Record, skip, rewrite, drift and restore rules are the scriptParameter rules (a list compares by identity).
constexpr const char* kScriptCountParameterHelper =
    "local function countText(v)\n"
    "    if type(v) ~= \"table\" then return tostring(v) end\n"
    "    local text = \"\"\n"
    "    for i = 1, #v do text = text .. (i > 1 and \"/\" or \"\") .. tostring(v[i]) end\n"
    "    return \"{\" .. text .. \"}\"\n"
    "end\n"
    "local function scaledCount(current, value)\n"
    "    local function one(n)\n"
    "        if n < 1 then return n end\n"
    "        local r = n * value + 0.5\n"
    "        r = r - r % 1\n"
    "        if r < 1 then r = 1 end\n"
    "        return r\n"
    "    end\n"
    "    if type(current) == \"number\" then return one(current) end\n"
    "    if type(current) ~= \"table\" then return nil end\n"
    "    local size, count = #current, 0\n"
    "    for key, n in pairs(current) do\n"
    "        if type(key) ~= \"number\" or type(n) ~= \"number\" then return nil end\n"
    "        count = count + 1\n"
    "    end\n"
    "    if size == 0 or count ~= size then return nil end\n"
    "    local copy = {}\n"
    "    for i = 1, size do copy[i] = one(current[i]) end\n"
    "    return copy\n"
    "end\n"
    "local function scriptCountParameter(tag, read, write)\n"
    "    local records = setmetatable({}, { __mode = \"k\" }) -- environment -> { observed, written }, or false\n"
    "    local function enter(environment, value)\n"
    "        if type(environment) ~= \"table\" then return end\n"
    "        local record = records[environment]\n"
    "        local current = read(environment)\n"
    "        if record == nil then\n"
    "            local written = scaledCount(current, value)\n"
    "            if written == nil then\n"
    "                records[environment] = false\n"
    "                print(\"RENOVICE Missions: \" .. tag .. \" is not a count or a list of counts in this instance; left unchanged\")\n"
    "                return\n"
    "            end\n"
    "            write(environment, written)\n"
    "            records[environment] = { observed = current, written = written }\n"
    "            print(\"RENOVICE Missions: \" .. tag .. \" \" .. countText(current) .. \" -> \" .. countText(written))\n"
    "            return\n"
    "        end\n"
    "        if record == false or current == record.written then return end\n"
    "        if current == record.observed then\n"
    "            write(environment, record.written)\n"
    "            return\n"
    "        end\n"
    "        records[environment] = false\n"
    "        print(\"RENOVICE Missions: \" .. tag .. \" was changed by another writer; left unchanged\")\n"
    "    end\n"
    "    local function restore()\n"
    "        for environment, record in pairs(records) do\n"
    "            if record and read(environment) == record.written then write(environment, record.observed) end\n"
    "            records[environment] = nil\n"
    "        end\n"
    "    end\n"
    "    return enter, restore\n"
    "end\n";

// Contract R14 (2026-10-01): ownedTable with scaled root-table fields, emitted instead of the plain form only when a build
// declares a scaled row (packages without one keep the earlier text byte for byte). A field entry of a scaled row carries
// its own `stock` and `scale` ("scale" or "scale_count"): the stock check compares the live field with that stock, the
// write is stock x value (scale_count: rounded half up, at least 1, the R11 count rule) computed from the REGISTERED
// stock, never from the live number, so a value is never compounded; restore puts that stock back where the written number
// is still there. Plain fields keep the Phase 2i rules (the setting's stock, the value as is). Arrays are bound per live
// instance like any other root table (the array is the owner reached through its container path) and mutated in place:
// each mission instance builds its own arrays in the module root.
constexpr const char* kScaledOwnedTableHelper =
    "local function fieldStock(settings, field)\n"
    "    if field.scale ~= nil then return field.stock end\n"
    "    return settings[field.setting].stock\n"
    "end\n"
    "local function fieldValue(current, field)\n"
    "    local value = current[field.setting].value\n"
    "    if field.scale == nil then return value end\n"
    "    local written = field.stock * value\n"
    "    if field.scale == \"scale_count\" then\n"
    "        written = written + 0.5\n"
    "        written = written - written % 1\n"
    "        if written < 1 then written = 1 end\n"
    "    end\n"
    "    return written\n"
    "end\n"
    "local function ownedTable(tag, settings, fields)\n"
    "    local bound = setmetatable({}, { __mode = \"k\" }) -- live table -> written values, or false when drifted\n"
    "    local function bind(owner, current)\n"
    "        assert(type(owner) == \"table\", tag .. \" is not a table\")\n"
    "        if bound[owner] ~= nil then return true end\n"
    "        for i = 1, #fields do\n"
    "            local field = fields[i]\n"
    "            if current[field.setting].enabled and owner[field.key] ~= fieldStock(settings, field) then\n"
    "                bound[owner] = false\n"
    "                assert(false, tag .. \" stock values drifted; this instance is left unchanged\")\n"
    "            end\n"
    "        end\n"
    "        local written = {}\n"
    "        for i = 1, #fields do\n"
    "            local field = fields[i]\n"
    "            if current[field.setting].enabled then\n"
    "                local value = fieldValue(current, field)\n"
    "                owner[field.key] = value\n"
    "                written[i] = value\n"
    "            end\n"
    "        end\n"
    "        bound[owner] = written\n"
    "        return true\n"
    "    end\n"
    "    local function restore()\n"
    "        for owner, written in pairs(bound) do\n"
    "            if written then\n"
    "                for i = 1, #fields do\n"
    "                    local field = fields[i]\n"
    "                    local value = written[i]\n"
    "                    if value ~= nil and owner[field.key] == value then owner[field.key] = fieldStock(settings, field) end\n"
    "                end\n"
    "            end\n"
    "            bound[owner] = nil\n"
    "        end\n"
    "    end\n"
    "    return bind, restore\n"
    "end\n";

// R17: `native_rows` are rows the engine writer owns (engine_params.json, contract R16) whose master is resolved there; the
// addon never applies a master to them (no double application when the bootstrapper withholds the row itself).
std::string multi_target_addon_source(const Json& registry, const std::map<std::string, std::vector<const Json*>>& bodies,
                                      const std::map<std::string, double>& values, const std::set<std::string>& enabled,
                                      const std::map<std::string, MasterBuild>& masters = {},
                                      const std::set<std::string>& native_rows = {}) {
    std::ostringstream out;
    const std::string retire = hook_retire_statement();
    // R10: script-parameter globals of the called instance are read and written as hashed fields of its environment
    // table. The directive hashes EVERY field access with that name in this file, so the build gate
    // `entry-parameter-keys` checks that the names occur only in the generated accessors.
    std::set<std::string> parameter_names, info_fields;
    bool count_parameters = false;  // R11: a scale_count row needs scriptCountParameter
    bool scaled_fields = false;     // R14: a scaled root-table row needs the per-field stock form of ownedTable
    for (const auto& [body, rows] : bodies)
        for (const Json* row : rows) {
            if (!entry_template_row(*row) && row->at("owner").contains("fields") && !root_field_mode(*row).empty()) scaled_fields = true;
            if (!entry_template_row(*row)) continue;
            if (row->at("owner").at("template") == kScriptParamTemplate) {
                for (const auto& global : row->at("owner").at("globals")) parameter_names.insert(global.at("name").get<std::string>());
                if (row->at("owner").at("mode") == "scale_count") count_parameters = true;
            } else
                info_fields.insert(row->at("owner").at("field").get<std::string>());
        }
    for (const auto& name : parameter_names) out << kHashedFieldDirective << name << "\n";
    out << "-- Generated by RENOVICE Ability Editor from the mission registry. Do not hand-edit.\n"
        << "-- Build profile " << registry.at("build").get<std::string>() << ". Multi-target addon: one Scripts row, \"[ADDON] "
        << kMultiTargetAddonName << "\".\n"
        << "-- Target keys appear only as the keys of `targets` (every lowercase 16-hex string constant is a declared target).\n"
        << "-- Root-table fields (gate " << kRootTableGate << ") are bound per live table instance: stock checked once per\n"
        << "-- table, written once, restored in cleanup. No polling, no per-frame writes, no single-owner assumption.\n"
        << "-- Hooks (gate " << kMinimalHooksGate << "): every table with a declared value is hooked at its proven minimal\n"
        << "-- prototypes. A hook with no enabled value retires at once (R3); one with a value binds, writes, then retires.\n"
        << "-- A target with no enabled value at all retires every hook of the target at its first hooked call (R4 retire-all).\n"
        << "-- Values: activate(context) reads context.settings (ADDON_SETTINGS_V1: [id] = { enabled, value, stock }); without\n"
        << "-- it the compiled values below apply where enabled. A value that is not enabled is never written.\n";
    if (masters.empty()) {
        out << "\n"
            << "local function effectiveSettings(compiled, context)\n"
            << "    local provided = nil\n"
            << "    if type(context) == \"table\" and type(context.settings) == \"table\" then provided = context.settings end\n"
            << "    local result = {}\n"
            << "    for id, entry in pairs(compiled) do\n"
            << "        if provided == nil then\n"
            << "            result[id] = { enabled = entry.enabled, value = entry.value, stock = entry.stock }\n"
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
            << "end\n\n";
    } else {
        out << "-- Master knobs (contract R5): a master value drives several rows of one target (row = master x scale); a row that\n"
            << "-- is itself enabled wins over its master.\n\n"
            << "local function effectiveSettings(compiled, context, masters, drives)\n"
            << "    local provided = nil\n"
            << "    if type(context) == \"table\" and type(context.settings) == \"table\" then provided = context.settings end\n"
            << "    local function pick(id, entry)\n"
            << "        if provided == nil then\n"
            << "            if entry.enabled then return entry.value end\n"
            << "            return nil\n"
            << "        end\n"
            << "        local given = provided[id]\n"
            << "        if type(given) == \"table\" and given.enabled == true and type(given.value) == \"number\"\n"
            << "            and given.value == given.value and given.stock == entry.stock then\n"
            << "            return given.value\n"
            << "        end\n"
            << "        return nil\n"
            << "    end\n"
            << "    local chosen = {}\n"
            << "    if masters ~= nil then\n"
            << "        for id, entry in pairs(masters) do chosen[id] = pick(id, entry) end\n"
            << "    end\n"
            << "    local result = {}\n"
            << "    for id, entry in pairs(compiled) do\n"
            << "        local value = pick(id, entry)\n"
            << "        if value == nil and drives ~= nil then\n"
            << "            local drive = drives[id]\n"
            << "            if drive ~= nil and chosen[drive.master] ~= nil then value = chosen[drive.master] * drive.scale end\n"
            << "        end\n"
            << "        if value ~= nil then\n"
            << "            result[id] = { enabled = true, value = value, stock = entry.stock }\n"
            << "        else\n"
            << "            result[id] = { enabled = false, value = entry.stock, stock = entry.stock }\n"
            << "        end\n"
            << "    end\n"
            << "    return result\n"
            << "end\n\n";
    }
    out
        << "local function anyEnabled(current, fields)\n"
        << "    for i = 1, #fields do\n"
        << "        if current[fields[i].setting].enabled then return true end\n"
        << "    end\n"
        << "    return false\n"
        << "end\n\n";
    if (scaled_fields)
        out << kScaledOwnedTableHelper;
    else
        out << "local function ownedTable(tag, settings, fields)\n"
        << "    local bound = setmetatable({}, { __mode = \"k\" }) -- live table -> written values, or false when drifted\n"
        << "    local function bind(owner, current)\n"
        << "        assert(type(owner) == \"table\", tag .. \" is not a table\")\n"
        << "        if bound[owner] ~= nil then return true end\n"
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
        << "        return true\n"
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
    for (const auto& field : info_fields) out << "\n" << mission_info_helper(field);
    if (!parameter_names.empty()) out << "\n" << kScriptParameterHelper;
    if (count_parameters) out << "\n" << kScriptCountParameterHelper;
    std::size_t target = 0;
    for (const auto& [body, rows] : bodies) {
        ++target;
        const Json& module = mission_module(registry, body);
        const auto module_path = module.at("module_path").get<std::string>();
        // R14: `scaled` is ", stock = S, scale = \"mode\"" for a field of a scaled row (empty otherwise).
        struct Owned { std::string key; std::string setting; bool enabled; std::string scaled; };
        std::map<std::string, std::vector<Owned>> tables;
        std::map<std::string, const Json*> settings;
        std::vector<const Json*> entry_rows;  // R10 entry templates
        for (const Json* row : rows) {
            const auto id = row->at("tunable_id").get<std::string>();
            settings.emplace(id, row);
            if (entry_template_row(*row)) {
                entry_rows.push_back(row);
                continue;
            }
            const auto mode = root_field_mode(*row);
            for (const auto& field : row->at("owner").at("fields"))
                tables[field.at("table_id").get<std::string>()].push_back(
                    {lua_table_key(field.at("field")), lua_quote(id), enabled.contains(id),
                     mode.empty() ? std::string()
                                  : ", stock = " + format_number(field.at("stock").get<double>()) + ", scale = " + lua_quote(mode)});
        }
        out << "\n-- Target " << target << ": " << module_path << "\n"
            << "local function target" << target << "()\n"
            << "    local settings = { -- compiled values (used without context.settings), the registry stock and the build's choice\n";
        for (const auto& [id, row] : settings)
            out << "        [" << lua_quote(id) << "] = { value = " << format_number(values.at(id)) << ", stock = "
                << format_number(row->at("stock").get<double>()) << ", enabled = " << (enabled.contains(id) ? "true" : "false") << " },\n";
        out << "    }\n";
        // R5 master knobs whose driven rows belong to this target (every driven row of the target's module is a declared row
        // of the target). R17: a cross-module master appears in every target that holds one of its rows, with only that
        // target's drives; a row the engine writer owns gets the master there, not here.
        std::vector<std::string> target_masters;
        std::map<std::string, std::vector<std::pair<std::string, double>>> target_drives;
        for (const auto& [id, build] : masters) {
            static_cast<void>(build);
            const Json* master = mission_master(registry, id);
            if (master == nullptr) throw std::runtime_error("unknown master knob " + id);
            std::vector<std::pair<std::string, double>> own;
            for (const auto& drive : master->at("drives")) {
                const auto row_id = drive.at("tunable_id").get<std::string>();
                if (mission_tunable(registry, row_id).at("owner").at("body_key") != body) continue;
                if (!settings.contains(row_id))
                    throw std::runtime_error("master knob " + id + " drives " + row_id + ", which is not a declared row of its target");
                if (native_rows.contains(row_id)) continue;
                own.emplace_back(row_id, drive.at("scale").get<double>());
            }
            // R19: a master every drive of which the engine writer owns (Railjack kill goals since R19) drives nothing here,
            // but it is still a value of this member (engine_params.json names it, the bootstrapper delivers it): it stays
            // compiled, with no drives, in the target of its own module, so the settings-declarations gate keeps holding
            // (declared == compiled) and the addon never applies it.
            if (own.empty()) {
                bool every_drive_native = !master->at("drives").empty();
                for (const auto& drive : master->at("drives"))
                    if (!native_rows.contains(drive.at("tunable_id").get<std::string>())) every_drive_native = false;
                if (!every_drive_native || master->at("body_key") != body) continue;
            }
            target_drives[id] = own;
            target_masters.push_back(id);
        }
        if (!target_masters.empty()) {
            out << "    local masters = { -- master knobs (R5): compiled value, declared stock and the build's choice\n";
            for (const auto& id : target_masters)
                out << "        [" << lua_quote(id) << "] = { value = " << format_number(masters.at(id).value) << ", stock = "
                    << format_number(mission_master(registry, id)->at("stock").get<double>()) << ", enabled = "
                    << (masters.at(id).enabled ? "true" : "false") << " },\n";
            out << "    }\n"
                << "    local drives = { -- row -> master knob that drives it (row value = master value x scale)\n";
            std::map<std::string, std::string> drive_lines;
            for (const auto& id : target_masters)
                for (const auto& [row_id, scale] : target_drives.at(id))
                    drive_lines[row_id] = "        [" + lua_quote(row_id) + "] = { master = " + lua_quote(id) +
                                          ", scale = " + format_number(scale) + " },\n";
            for (const auto& [row_id, line] : drive_lines) out << line;
            out << "    }\n";
        }
        out
            << "    local current = nil -- effective settings of the active generation; nil while inactive\n"
            << "    local " << kTargetLiveFlag << " = false -- any enabled value of this target in the active generation (R4)\n";
        struct Bind { int upvalue; std::vector<std::string> steps; std::size_t slot; bool retire_safe; bool root_child; };
        std::map<int, std::vector<Bind>> hooks;  // prototype -> hooked tables it binds
        std::vector<std::size_t> hooked_slots;
        std::size_t slot = 0;
        for (const auto& [table_id, fields] : tables) {
            ++slot;
            out << "    local fields" << slot << " = {\n";
            for (const auto& field : fields)
                out << "        { key = " << field.key << ", setting = " << field.setting << field.scaled << " },\n";
            out << "    }\n";
            const std::string tag = module_path + " " + table_id;
            hooked_slots.push_back(slot);
            out << "    local bind" << slot << ", restore" << slot << " = ownedTable(" << lua_quote(tag) << ", settings, fields" << slot << ")\n"
                << "    local live" << slot << " = false\n";
            const Json& table = module.at("root_tables").at(table_id);
            std::set<int> minimal, root_children;
            for (const auto& prototype : table.at("minimal_hooks").at("prototypes")) minimal.insert(prototype.get<int>());
            for (const auto& prototype : table.at("minimal_hooks").value("root_children", Json::array())) root_children.insert(prototype.get<int>());
            const bool table_retire_safe = table.at("minimal_hooks").value("retire_safe", false);
            std::size_t emitted = 0;
            for (const auto& hook : table.at("hooks")) {
                if (!minimal.contains(hook.at("prototype").get<int>())) continue;
                const bool root_child = root_children.contains(hook.at("prototype").get<int>());
                Bind bind{hook.at("upvalue").get<int>(), {}, slot, table_retire_safe && root_child, root_child};
                for (const auto& key : hook.at("path")) bind.steps.push_back("[" + lua_table_key(key) + "]");
                hooks[hook.at("prototype").get<int>()].push_back(std::move(bind));
                ++emitted;
            }
            if (emitted != minimal.size()) throw std::runtime_error("hook plan of " + tag + " names a prototype without a capturer hook");
        }
        // R10 entry rows: one live flag per row; the hook of every entry prototype applies it.
        struct EntryUse { std::size_t slot; bool environment; };
        std::map<int, std::vector<EntryUse>> entry_hooks;  // prototype -> entry rows it applies
        std::map<std::size_t, std::string> activation, restores;  // slot -> activate expression / cleanup statements
        for (const Json* row : entry_rows) {
            ++slot;
            const auto id = row->at("tunable_id").get<std::string>();
            const Json& owner = row->at("owner");
            const bool parameter = owner.at("template") == kScriptParamTemplate;
            hooked_slots.push_back(slot);
            activation[slot] = "current[" + lua_quote(id) + "].enabled";
            out << "    local live" << slot << " = false\n";
            if (parameter) {
                const auto mode = owner.at("mode").get<std::string>();
                std::size_t k = 0;
                for (const auto& global : owner.at("globals")) {
                    ++k;
                    const auto name = global.at("name").get<std::string>();
                    out << "    local enter" << slot << "_" << k << ", restore" << slot << "_" << k
                        << (mode == "scale_count" ? " = scriptCountParameter(" : " = scriptParameter(")
                        << lua_quote(id + " " + name) << (mode == "scale_count" ? std::string() : ", " + lua_quote(mode)) << ",\n"
                        << "        function(environment) return environment." << name << " end,\n"
                        << "        function(environment, value) environment." << name << " = value end)\n";
                    restores[slot] += "            restore" + std::to_string(slot) + "_" + std::to_string(k) + "()\n";
                }
                out << "    local function apply" << slot << "(environment) -- " << kScriptParamTemplate << " " << mode << "\n"
                    << "        local value = current[" << lua_quote(id) << "].value\n";
                for (std::size_t n = 1; n <= k; ++n) out << "        enter" << slot << "_" << n << "(environment, value)\n";
                out << "    end\n";
            } else {
                const auto field = owner.at("field").get<std::string>();
                out << "    local function apply" << slot << "() -- " << kMissionInfoTemplate << " " << field << "\n"
                    << "        missionInfo_" << field << "(" << lua_quote(id) << ", current[" << lua_quote(id) << "].value)\n"
                    << "    end\n";
            }
            for (const auto& entry : owner.at("entries")) {
                if (!entry.value("root_child", false))
                    throw std::runtime_error(module_path + " entry " + std::to_string(entry.at("prototype").get<int>()) + " of " + id +
                                             " is not a root child: it would have no R3 retire path");
                entry_hooks[entry.at("prototype").get<int>()].push_back({slot, parameter});
            }
        }
        std::set<int> hooked_prototypes;
        for (const auto& [prototype, binds] : hooks) hooked_prototypes.insert(prototype);
        for (const auto& [prototype, uses] : entry_hooks) hooked_prototypes.insert(prototype);
        for (const int prototype : hooked_prototypes) {
            const std::vector<Bind> binds = hooks.contains(prototype) ? hooks.at(prototype) : std::vector<Bind>{};
            const std::vector<EntryUse> uses = entry_hooks.contains(prototype) ? entry_hooks.at(prototype) : std::vector<EntryUse>{};
            if (!std::all_of(binds.begin(), binds.end(), [](const Bind& bind) { return bind.root_child; }))
                throw std::runtime_error(module_path + " hook " + std::to_string(prototype) +
                                         " is not a root child: it would have no R3 retire path");
            std::set<std::size_t> slots;
            for (const auto& bind : binds) slots.insert(bind.slot);
            for (const auto& use : uses) slots.insert(use.slot);
            std::string condition;
            for (const auto n : slots) condition += (condition.empty() ? "live" : " or live") + std::to_string(n);
            // R3 obligations 1 and 2 hold for this hook exactly when it carries the settled retire (below); R4 obligation 4
            // admits the retire-all statement only there. An entry is a root child whose work is done for the instance once
            // it ran (the write is once per instance), so entries never block the settled retire.
            const bool retire_here = !retire.empty() &&
                std::all_of(binds.begin(), binds.end(), [](const Bind& bind) { return bind.retire_safe; });
            const bool environment = std::any_of(uses.begin(), uses.end(), [](const EntryUse& use) { return use.environment; });
            out << "    local function before" << prototype
                << (environment ? "(prototype, arguments, upvalues, trace, environment)\n" : "(prototype, arguments, upvalues)\n")
                << "        if current == nil then return end\n";
            if (retire_here) out << "        " << hook_retire_all_statement() << "\n";
            out << "        " << hook_idle_retire_statement(condition) << "\n"
                << "        assert(prototype == " << prototype << ", " << lua_quote(module_path + " hook received the wrong prototype") << ")\n";
            if (!binds.empty()) out << "        assert(type(upvalues) == \"table\", \"upvalue view is unavailable\")\n";
            for (const auto& bind : binds) {
                const std::string base = "upvalues[" + std::to_string(bind.upvalue) + "]";
                if (bind.steps.empty()) {
                    out << "        if live" << bind.slot << " then bind" << bind.slot << "(" << base << ", current) end\n";
                    continue;
                }
                // A nested table is reached through its root container(s) of this instance (outermost key first); every
                // step must be a table.
                out << "        if live" << bind.slot << " then\n"
                    << "            local container = " << base << "\n";
                for (const auto& step : bind.steps)
                    out << "            assert(type(container) == \"table\", \"root-table container is not a table\")\n"
                        << "            container = container" << step << "\n";
                out << "            bind" << bind.slot << "(container, current)\n"
                    << "        end\n";
            }
            for (const auto& use : uses)
                out << "        if live" << use.slot << " then apply" << use.slot << (use.environment ? "(environment)" : "()") << " end\n";
            // Every bind above returned or raised and every entry ran: each table and entry of this hook is settled.
            if (retire_here) out << "        " << retire << "\n";
            out << "    end\n";
        }
        out << "    return {\n"
            << "        label = " << lua_quote(module_path) << ", -- reserved for the settings editor; ignored by the runtime\n"
            << "        settings = settings, -- reserved for the settings editor; ignored by the runtime\n"
            << "        activate = function(context)\n"
            << "            local effective = " << (target_masters.empty() ? "effectiveSettings(settings, context)" : kMasterEffectiveCall) << "\n";
        out << "            current = effective\n";
        for (const auto n : hooked_slots)
            out << "            live" << n << " = "
                << (activation.contains(n) ? activation.at(n) : "anyEnabled(current, fields" + std::to_string(n) + ")") << "\n";
        out << "            " << target_live_assignment(hooked_slots) << "\n"
            << "        end,\n"
            << "        cleanup = function()\n"
            << "            current = nil\n"
            << "            " << kTargetLiveFlag << " = false\n";
        for (const auto n : hooked_slots) {
            out << "            live" << n << " = false\n";
            if (!activation.contains(n)) out << "            restore" << n << "()\n";
            else if (restores.contains(n)) out << restores.at(n);
        }
        out << "        end,\n";
        if (!hooked_prototypes.empty()) {
            out << "        hooks = { luaCalls = {\n";
            for (const int prototype : hooked_prototypes) out << "            [" << prototype << "] = { before = before" << prototype << " },\n";
            out << "        } },\n";
        }
        out << "    }\n"
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

// Phase 2k gate `hook-retire` (contract R3), read back from the generated source per target section:
//  - `idle`: hooks whose first statement after the activation guard is the idle retire over EXACTLY the live flags the
//    hook binds (every table of the hook without an enabled value -> retire before touching anything);
//  - `settled`: hooks whose LAST statement returns the sentinel (after every bind);
//  - `retire_all` (contract R4 / S5): hooks whose FIRST statement after the activation guard is the retire-all statement
//    over the target-wide flag, in a target whose activate sets that flag to the OR of EVERY table flag of the target
//    (so retire-all is returned only when no hook of the target has work for this instance).
// Any other occurrence of either sentinel is an error.
struct SourceRetirePaths { std::set<int> idle; std::set<int> settled; std::set<int> retire_all; };
std::map<std::string, SourceRetirePaths> multi_target_source_retire_paths(const std::string& source) {
    static const std::regex section("\n-- Target [0-9]+: ([^\n]+)\n");
    static const std::regex function("\n    local function before([0-9]+)\\(prototype, arguments, upvalues(?:, trace, environment)?\\)\n([\\s\\S]*?)\n    end(?=\n)");
    static const std::regex live_use("\n        if (live[0-9]+) then");  // table binds and R10 entry applies
    // Lookahead: two declarations on consecutive lines (a table flag, then an R10 entry flag) must both match.
    static const std::regex live_declaration("\n    local live([0-9]+) = false(?=\n)");
    std::map<std::string, SourceRetirePaths> result;
    std::vector<std::pair<std::size_t, std::string>> starts;
    for (auto it = std::sregex_iterator(source.begin(), source.end(), section); it != std::sregex_iterator(); ++it)
        starts.emplace_back(static_cast<std::size_t>(it->position()), (*it)[1].str());
    const std::size_t tail = source.rfind("\nreturn {\n");
    const std::string sentinel = std::string("return \"") + kLuaCallRetireSentinel + "\"";
    const std::string all_sentinel = std::string("\"") + kLuaCallRetireAllSentinel + "\"";
    const std::string guard = "        if current == nil then return end\n";
    const std::string retire_all = guard + "        " + hook_retire_all_statement() + "\n";
    for (std::size_t n = 0; n < starts.size(); ++n) {
        const std::size_t end = n + 1 < starts.size() ? starts[n + 1].first : tail;
        const std::string text = source.substr(starts[n].first, end - starts[n].first);
        auto& paths = result[starts[n].second];
        // Target-wide flag: declared once, set in activate to the OR of every table flag of the section, cleared in cleanup.
        std::vector<std::size_t> slots;
        for (auto it = std::sregex_iterator(text.begin(), text.end(), live_declaration); it != std::sregex_iterator(); ++it)
            slots.push_back(std::stoul((*it)[1].str()));
        const bool flag_ok = contains_text(text, std::string("\n    local ") + kTargetLiveFlag + " = false ")
            && contains_text(text, "\n            " + target_live_assignment(slots) + "\n        end,\n        cleanup = function()\n")
            && contains_text(text, std::string("\n            current = nil\n            ") + kTargetLiveFlag + " = false\n");
        for (auto it = std::sregex_iterator(text.begin(), text.end(), function); it != std::sregex_iterator(); ++it) {
            const int prototype = std::stoi((*it)[1].str());
            std::string body = (*it)[2].str();
            // Retire-all path: the first statement after the guard, and only over a well-formed target-wide flag.
            if (body.rfind(retire_all, 0) == 0) {
                if (!flag_ok)
                    throw std::runtime_error("before" + (*it)[1].str() + " returns retire-all but the target flag " + kTargetLiveFlag +
                                             " is not the OR of every table flag of " + starts[n].second);
                paths.retire_all.insert(prototype);
                body = guard + body.substr(retire_all.size());
            }
            if (body.find(all_sentinel) != std::string::npos)
                throw std::runtime_error("before" + (*it)[1].str() + " returns retire-all outside its first statement");
            // Idle path: guard, then the idle line naming exactly the live flags used by the binds below it.
            std::set<std::string> flags;
            const std::string scan = "\n" + body;
            for (auto use = std::sregex_iterator(scan.begin(), scan.end(), live_use); use != std::sregex_iterator(); ++use)
                flags.insert((*use)[1].str());
            std::string condition;
            std::vector<std::string> ordered(flags.begin(), flags.end());
            std::sort(ordered.begin(), ordered.end(), [](const std::string& x, const std::string& y) {
                return std::stoul(x.substr(4)) < std::stoul(y.substr(4));
            });
            for (const auto& flag : ordered) condition += (condition.empty() ? "" : " or ") + flag;
            const std::string idle = guard + "        " + hook_idle_retire_statement(condition) + "\n";
            if (!flags.empty() && body.rfind(idle, 0) == 0) {
                paths.idle.insert(prototype);
                body = guard + body.substr(idle.size());
            }
            const auto at = body.find(sentinel);
            if (at == std::string::npos) continue;
            // The settled sentinel must be the last statement (after every bind of the hook) and appear once.
            if (body.find(sentinel, at + 1) != std::string::npos || body.find('\n', at) != std::string::npos)
                throw std::runtime_error("before" + (*it)[1].str() + " returns the retire sentinel before its last statement");
            paths.settled.insert(prototype);
        }
    }
    return result;
}

std::map<std::string, std::set<int>> multi_target_source_retiring_hooks(const std::string& source) {
    std::map<std::string, std::set<int>> result;
    for (const auto& [module, paths] : multi_target_source_retire_paths(source)) result[module] = paths.settled;
    return result;
}

// Phase 2k gate `hook-plan`: the luaCalls prototypes the GENERATED SOURCE declares per target (read back from the
// `hooks = { luaCalls = { [P] = ... } }` block of each `-- Target N: <module>` section). A target without the block maps
// to an empty set.
std::map<std::string, std::set<int>> multi_target_source_hooks(const std::string& source) {
    static const std::regex section("\n-- Target [0-9]+: ([^\n]+)\n");
    static const std::regex entry("\n            \\[([0-9]+)\\] = \\{ before = before([0-9]+) \\},");
    std::map<std::string, std::set<int>> result;
    std::vector<std::pair<std::size_t, std::string>> starts;
    for (auto it = std::sregex_iterator(source.begin(), source.end(), section); it != std::sregex_iterator(); ++it)
        starts.emplace_back(static_cast<std::size_t>(it->position()), (*it)[1].str());
    const std::size_t tail = source.rfind("\nreturn {\n");
    for (std::size_t n = 0; n < starts.size(); ++n) {
        const std::size_t end = n + 1 < starts.size() ? starts[n + 1].first : tail;
        const std::string text = source.substr(starts[n].first, end - starts[n].first);
        auto& set = result[starts[n].second];
        for (auto it = std::sregex_iterator(text.begin(), text.end(), entry); it != std::sregex_iterator(); ++it) {
            if ((*it)[1].str() != (*it)[2].str()) throw std::runtime_error("hook entry names another prototype's function");
            set.insert(std::stoi((*it)[1].str()));
        }
    }
    return result;
}

#include "mission_live_literals.inl"
#include "mission_engine_params.inl"

MissionSetResult build_mission_set(const Json& registry, const Json& values_json, const MissionNaming& naming,
                                   const fs::path& editor_root, const fs::path& staging_root, bool run_external_gates,
                                   const Json& project_snapshot) {
    MissionSetResult result;
    try {
        if (!run_external_gates) throw std::runtime_error("Current-build mission export requires all verification gates");
        verify_mission_registry_structure(registry);
        // R5: master knobs named in `values` are split from row values. A literal master is expanded into its driven rows
        // (each built with master x scale); an addon master is compiled into its target (declared below).
        Json row_values = Json::object();
        std::map<std::string, double> master_values;
        std::map<std::string, std::string> literal_master_of_body;  // body key -> the literal master its member declares
        std::set<std::string> expanded_rows;
        for (const auto& [id, value] : values_json.items()) {
            const Json* master = mission_master(registry, id);
            if (master == nullptr) {
                const Json& row = mission_tunable(registry, id);
                if (row.at("ui").contains("hidden"))
                    throw std::runtime_error(id + " is hidden from packages: " + row.at("ui").at("hidden").get<std::string>());
                row_values[id] = value;
                continue;
            }
            if (!naming.declare_all_addon_values)
                throw std::runtime_error("master knob " + id + " needs \"package_scope\": \"all_addon_values\"");
            if (!value.is_number() || !std::isfinite(value.get<double>()) || value.get<double>() < master->at("min").get<double>() ||
                value.get<double>() > master->at("max").get<double>() ||
                (master->at("type") == "int" && std::floor(value.get<double>()) != value.get<double>()))
                throw std::runtime_error("Out-of-range or non-whole value for master knob " + id);
            master_values[id] = value.get<double>();
        }
        for (const auto& id : naming.disabled_values)
            if (!values_json.contains(id)) throw std::runtime_error("disabled_values names " + id + ", which values does not name");
        // R18: a literal master whose drives span several modules (contract R17 cross-module drive) reaches the other modules
        // only through a recipe (literals.json names a module per drive). A baked build gives each module its own exact
        // replacement member with its own switch, which would split the master's one switch and displace the addon values of
        // that module, so a baked build expands such a master in its own module only and records the rows it leaves stock.
        std::vector<std::pair<std::string, std::string>> baked_cross_module;  // (driven row, master)
        for (const auto& [id, number] : master_values) {
            const Json& master = *mission_master(registry, id);
            if (master.at("lane") != "literal" || naming.literal_recipes) continue;  // R8: a recipe declares the master itself
            const auto master_body = master.at("body_key").get<std::string>();
            for (const auto& drive : master.at("drives")) {
                const auto row = drive.at("tunable_id").get<std::string>();
                if (mission_tunable(registry, row).at("owner").at("body_key") != master_body) {
                    baked_cross_module.emplace_back(row, id);
                    continue;
                }
                if (row_values.contains(row)) throw std::runtime_error(row + " is named both directly and through master knob " + id);
                const double scaled = number * drive.at("scale").get<double>();
                row_values[row] = mission_tunable(registry, row).at("limits").value("integer", false) ? Json(static_cast<long long>(std::llround(scaled)))
                                                                                                       : Json(scaled);
                expanded_rows.insert(row);
            }
            const auto body = master.at("body_key").get<std::string>();
            if (!literal_master_of_body.emplace(body, id).second)
                throw std::runtime_error("two literal master knobs name body key " + body);
        }
        const auto values = validate_mission_values(registry, row_values, naming.declare_all_addon_values);
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
            if (naming.literal_recipes && backend == "EXACT_LITERAL") continue;  // R8: declared in the recipe below
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
        // Compiled addon values and the build's enabled set. Without package_scope every built addon row is enabled with its
        // requested value (the Phase 2g-2j behaviour). With package_scope "all_addon_values" every other multi-instance-safe
        // TARGET_ADDON row is declared too, compiled as its stock and disabled; rows that cannot join are listed with the
        // exact reason.
        std::map<std::string, double> compiled_values;
        std::set<std::string> enabled_ids;
        for (const auto& [body, rows] : addon)
            for (const Json* row : rows) {
                const auto id = row->at("tunable_id").get<std::string>();
                compiled_values[id] = values.at(id);
                if (!naming.disabled_values.contains(id)) enabled_ids.insert(id);  // R5: built but shipped off
            }
        Json excluded_values = Json::array();
        for (const auto& [row, master] : baked_cross_module)  // R18
            excluded_values.push_back({{"tunable_id", row}, {"reason", "driven by literal master " + master + " from another module; "
                "a baked build (no \"literal_mode\": \"recipe\") builds a master in its own module only, so this row stays stock"}});
        if (naming.declare_all_addon_values) {
            if (!naming.package_layout) throw std::runtime_error("package_scope \"all_addon_values\" needs \"output_layout\": \"package\"");
            if (!addon_lane_usable)
                throw std::runtime_error(std::string("NEEDS_BINDING: package_scope \"all_addon_values\" declares target-addon values, whose hook binding ") +
                                         kMissionAddonHookBinding + " is " + hook.status + "; add \"allow_unproven_hook_bindings\": [\"" +
                                         kMissionAddonHookBinding + "\"] for a live acceptance build");
            for (const auto& row : registry.at("tunables")) {
                if (row.at("backend") != "TARGET_ADDON") continue;
                const auto id = row.at("tunable_id").get<std::string>();
                if (values.contains(id)) continue;
                const auto body = row.at("owner").at("body_key").get<std::string>();
                if (row.at("ui").contains("hidden")) {  // R5: never declared (for example: no stock code reads it)
                    excluded_values.push_back({{"tunable_id", id}, {"reason", "hidden: " + row.at("ui").at("hidden").get<std::string>()}});
                    continue;
                }
                if (!row.at("owner").contains("fields") && !entry_template_row(row)) {
                    std::string presets;
                    for (const auto& [preset_id, preset] : registry.at("missions").items())
                        if (preset.at("body_key") == body) presets += (presets.empty() ? "" : ", ") + preset_id;
                    excluded_values.push_back({{"tunable_id", id}, {"reason", "template-only row: its established " +
                        row.at("owner").at("template").get<std::string>() + " template binds one owner per activation and is not "
                        "multi-instance safe; available through the '" + presets + "' preset"}});
                    continue;
                }
                if (literal.contains(body)) {
                    excluded_values.push_back({{"tunable_id", id}, {"reason", "body key " + body + " is built as an exact replacement (" +
                        id_list(literal.at(body)) + ") and one body key may own only one artifact; disable that replacement value and "
                        "rebuild to declare this value"}});
                    continue;
                }
                try { verify_mission_row(registry, row, paths); }
                catch (const std::exception& e) { throw std::runtime_error(id + ": " + e.what()); }
                addon[body].push_back(&row);
                compiled_values[id] = row.at("stock").get<double>();
            }
            // Design section 5: a literal value is toggled through its member, so a replacement member may declare exactly one.
            // R5: a member built from a literal master knob declares only the master, and every row of it must be driven by
            // that master (one switch, one value).
            for (const auto& [body, rows] : literal) {
                if (const auto master = literal_master_of_body.find(body); master != literal_master_of_body.end()) {
                    for (const Json* row : rows)
                        if (!expanded_rows.contains(row->at("tunable_id").get<std::string>()))
                            throw std::runtime_error("package_scope \"all_addon_values\": " + row->at("tunable_id").get<std::string>() +
                                                     " shares body key " + body + " with master knob " + master->second +
                                                     "; a master member may carry only the rows its master drives");
                    continue;
                }
                if (rows.size() != 1)
                    throw std::runtime_error("package_scope \"all_addon_values\": the exact replacement of body key " + body + " carries " +
                                             std::to_string(rows.size()) + " literal values (" + id_list(rows) + "); a live-list literal value "
                                             "must be the only value of its replacement member");
            }
        }
        // R5 addon master knobs: declared when every driven row is a declared addon row of this build (package_scope
        // all_addon_values); compiled with the build value when named (shipped on unless in disabled_values), else stock/off.
        std::map<std::string, MasterBuild> addon_masters;
        if (naming.declare_all_addon_values && registry.contains("ui_masters")) {
            for (const auto& [id, master] : registry.at("ui_masters").items()) {
                if (master.at("lane") != "addon") continue;
                std::string missing;
                for (const auto& drive : master.at("drives")) {
                    const auto row = drive.at("tunable_id").get<std::string>();
                    // R17: each driven row in its own module's target (a cross-module master spans several targets).
                    const auto body = mission_tunable(registry, row).at("owner").at("body_key").get<std::string>();
                    bool present = false;
                    if (addon.contains(body))
                        for (const Json* declared : addon.at(body)) present = present || declared->at("tunable_id") == row;
                    if (!present) missing += (missing.empty() ? "" : ", ") + row;
                }
                if (!missing.empty()) {
                    if (master_values.contains(id))
                        throw std::runtime_error("master knob " + id + " is named, but its driven rows " + missing + " are not declared addon rows");
                    excluded_values.push_back({{"tunable_id", id}, {"reason", "master knob: driven rows " + missing +
                                                                              " are not declared addon rows in this build"}});
                    continue;
                }
                const bool named = master_values.contains(id);
                addon_masters[id] = MasterBuild{named ? master_values.at(id) : master.at("stock").get<double>(),
                                                named && !naming.disabled_values.contains(id)};
            }
        }
        for (const auto& [id, value] : master_values) {
            static_cast<void>(value);
            if (mission_master(registry, id)->at("lane") == "addon" && !addon_masters.contains(id))
                throw std::runtime_error("master knob " + id + " is not part of this build");
        }
        const auto registry_sha = sha256_file(editor_root / kMissionRegistryPath);
        Json normalized = {{"format", "RENOVICE_MISSION_SETTINGS_V1"}, {"build", registry.at("build")}, {"values", Json::object()}};
        for (const auto& [id, value] : values)
            if (!expanded_rows.contains(id)) normalized["values"][id] = value;
        for (const auto& [id, value] : master_values) normalized["values"][id] = value;  // R5: masters as named
        if (!naming.allow_unproven_hooks.empty()) normalized["allow_unproven_hook_bindings"] = naming.allow_unproven_hooks;
        if (naming.declare_all_addon_values) normalized["package_scope"] = "all_addon_values";
        if (!naming.disabled_values.empty()) normalized["disabled_values"] = naming.disabled_values;
        if (naming.literal_recipes) normalized["literal_mode"] = "recipe";
        if (naming.literal_headline) normalized["literal_scope"] = "headline";
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
            if (extra.contains("masters")) item.masters = extra.at("masters").get<std::vector<std::string>>();  // R5
            write_text(item.manifest, manifest.dump(2) + "\n");
            set_artifacts.push_back(entry);
            result.artifacts.push_back(std::move(item));
        };

        for (const auto& [body, rows] : literal) {
            const Json& module = mission_module(registry, body);
            const fs::path stock = paths.corpus / module.at("file").get<std::string>();
            if (sha256_file(stock) != module.at("sha256").get<std::string>()) throw std::runtime_error("Current mission stock hash mismatch: " + body);
            const auto original = read_text(stock);
            std::set<std::size_t> permitted;
            std::vector<patch::Patch> patches;
            Json plan = Json::array();
            for (const Json* row : rows) {
                const auto id = row->at("tunable_id").get<std::string>();
                const double value = values.at(id);
                for (const auto& site : mission_literal_owner(*row)->at("sites")) {
                    check_literal_operand(site, value, id);
                    const auto offset = site.at("offset").get<std::size_t>();
                    const bool constant = site.at("kind") == "number_constant";
                    const std::size_t width = constant ? 8 : 4;
                    if (site.at("expected").size() != width) throw std::runtime_error("Invalid patch extent");
                    // Shared core (LIVE_LITERALS_V1): extent, constant tag and preimage against the stock bytes, then the
                    // U44 LOADN / native f64 encoding. The bootstrapper synthesizes recipes with the same code.
                    patch::Patch item;
                    item.site = mission_patch_site(site);
                    switch (patch::verify(item.site, reinterpret_cast<const unsigned char*>(original.data()), original.size())) {
                    case patch::Error::None: break;
                    case patch::Error::Extent: throw std::runtime_error("Invalid patch extent");
                    case patch::Error::ConstantTag: throw std::runtime_error("Expected native numeric constant tag");
                    case patch::Error::PreimageChanged: throw std::runtime_error("Verified instruction preimage changed");
                    default: throw std::runtime_error("Literal site shape rejected at offset " + std::to_string(offset));
                    }
                    if (patch::encode(item.site, value, item.bytes) != patch::Error::None)
                        throw std::runtime_error("Mission value must resolve to an exact positive whole-number operand: " + id);
                    for (std::size_t n = 0; n < width; ++n)
                        if (!permitted.insert(offset + n).second) throw std::runtime_error("Competing exact sites overlap at offset " + std::to_string(offset));
                    patches.push_back(item);
                    const double exact = mission_site_operand(site, value);
                    plan.push_back({{"tunable_id", id}, {"value", value}, {"site", site},
                                    {"operand", constant ? Json(exact) : Json(static_cast<int>(exact))}});
                }
            }
            std::sort(patches.begin(), patches.end(), [](const patch::Patch& a, const patch::Patch& b) { return a.site.offset < b.site.offset; });
            const std::string bytes = synthesize_live_literal_module(original, patches, body);
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
                   lua_live_path("OpenWF/CustomScripts/", artifact), gates,
                   literal_master_of_body.contains(body) ? Json{{"masters", Json::array({literal_master_of_body.at(body)})}} : Json::object());
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
                    if (!row->at("owner").contains("fields") && !entry_template_row(*row)) template_only.push_back(row);
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
            // R17: rows owned at the engine writer whose master the package's engine_params.json resolves (package layout).
            std::set<std::string> native_master_rows;
            if (naming.package_layout)
                for (const auto& [id, build] : addon_masters) {
                    static_cast<void>(build);
                    for (const auto& drive : mission_master(registry, id)->at("drives")) {
                        const auto row_id = drive.at("tunable_id").get<std::string>();
                        if (mission_tunable(registry, row_id).at("owner").contains("engine_override")) native_master_rows.insert(row_id);
                    }
                }
            const std::string source_text = multi_target_addon_source(registry, addon, compiled_values, enabled_ids, addon_masters,
                                                                      native_master_rows);
            const fs::path source = result.directory / "source" / (name + ".luau");
            const fs::path artifact = result.directory / "artifacts" / (name + ".lua_B");
            write_text(source, source_text);
            Json gates = Json::array();
            const std::size_t compile_log_start = result.gate_log.size();
            addon_gates(gates, source, result.directory / "source" / (std::string(kMultiTargetAddonName) + ".verification-u43.lua_B"), artifact);
            // Contract R10 gate `entry-parameter-keys`: every script-parameter name is compiled as exactly one hashed field
            // name (the compiler reports hashed-fields=<names>), it occurs in the source only in its generated accessor pair
            // (`environment.<name>` read and write), and never as a string key. A name also used as a string field
            // anywhere else in the file would be hashed there too, so the build fails instead.
            {
                std::set<std::string> names;
                std::map<std::string, std::size_t> accessors;
                for (const auto& [body, rows] : addon)
                    for (const Json* row : rows)
                        if (entry_template_row(*row) && row->at("owner").at("template") == kScriptParamTemplate)
                            for (const auto& global : row->at("owner").at("globals")) {
                                names.insert(global.at("name").get<std::string>());
                                ++accessors[global.at("name").get<std::string>()];
                            }
                std::string problems;
                const std::string compile_log = result.gate_log.substr(compile_log_start);
                static const std::regex reported("hashed-fields=([0-9]+)");
                std::size_t reports = 0;
                for (auto it = std::sregex_iterator(compile_log.begin(), compile_log.end(), reported); it != std::sregex_iterator(); ++it) {
                    ++reports;
                    if (std::stoul((*it)[1].str()) != names.size())
                        problems += "compiler reports " + (*it)[1].str() + " hashed field names, expected " + std::to_string(names.size()) + "; ";
                }
                if (reports == 0) problems += "compiler output has no hashed-fields count; ";
                for (const auto& name : names) {
                    std::size_t uses = 0;
                    for (std::size_t at = source_text.find("." + name); at != std::string::npos; at = source_text.find("." + name, at + 1)) {
                        const std::size_t end = at + 1 + name.size();
                        if (end < source_text.size() && (std::isalnum(static_cast<unsigned char>(source_text[end])) || source_text[end] == '_')) continue;
                        ++uses;
                    }
                    if (uses != 2 * accessors.at(name))
                        problems += name + " is used as a field " + std::to_string(uses) + " times, expected only its " +
                                    std::to_string(2 * accessors.at(name)) + " accessor uses; ";
                    if (source_text.find("\"" + name + "\"") != std::string::npos || source_text.find("[\"" + name + "\"]") != std::string::npos)
                        problems += name + " also appears as a string key; ";
                    if (!contains_text(source_text, kHashedFieldDirective + name + "\n")) problems += name + " has no hashed-field directive; ";
                }
                result.gate_log += "entry-parameter-keys\n" + (problems.empty() ? std::string("PASS") : problems) + " names=" +
                                   std::to_string(names.size()) + "\n";
                gates.push_back({{"name", "entry-parameter-keys"}, {"pass", problems.empty()}, {"exit_code", problems.empty() ? 0 : 1}});
                if (!problems.empty()) throw std::runtime_error("entry-parameter-keys failed: " + problems);
            }
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
            // Phase 2k gate hook-plan: the luaCalls prototypes the generated source declares per target equal the union of
            // the registry minimal hook sets (ROOT_TABLE_MINIMAL_HOOKS_V1) of every table that holds a declared value.
            const auto source_hooks = multi_target_source_hooks(source_text);
            // Contract R3 gate hook-retire: a hook returns "RENOVICE_RETIRE" exactly when its prototype is a root child and
            // every table it binds is retire-safe (registry minimal_hooks), and only as its last statement. Contract R4: the
            // same hooks, and only they, open with retire-all over the target-wide flag.
            std::map<std::string, SourceRetirePaths> source_retiring;
            try { source_retiring = multi_target_source_retire_paths(source_text); }
            catch (const std::exception& e) { problems += std::string(e.what()) + "; "; }
            std::size_t hooked_targets = 0, hook_count = 0, hooked_tables = 0, table_count = 0, full_hooks = 0, retiring_hooks = 0,
                        idle_hooks = 0, enabled_tables = 0, retire_all_hooks = 0, entry_rows_total = 0;
            Json hook_plan = Json::array();
            for (const auto& [body, rows] : addon) {
                const Json& module = mission_module(registry, body);
                const auto module_path = module.at("module_path").get<std::string>();
                std::map<std::string, bool> tables;
                std::set<int> entry_prototypes;  // R10 entry templates (registry entries, every one a root child)
                for (const Json* row : rows) {
                    if (entry_template_row(*row)) {
                        ++entry_rows_total;
                        for (const auto& entry : row->at("owner").at("entries")) entry_prototypes.insert(entry.at("prototype").get<int>());
                        continue;
                    }
                    for (const auto& field : row->at("owner").at("fields"))
                        tables[field.at("table_id").get<std::string>()] |= enabled_ids.contains(row->at("tunable_id").get<std::string>());
                }
                std::set<int> want, full, not_retirable;
                for (const int prototype : entry_prototypes) want.insert(prototype);
                Json hooked = Json::array();
                for (const auto& [table_id, on] : tables) {
                    const Json& table = module.at("root_tables").at(table_id);
                    for (const auto& hook_entry : table.at("hooks")) full.insert(hook_entry.at("prototype").get<int>());
                    ++table_count;
                    // Phase 2k: every table with a declared value is hooked (idle hooks retire at once, R3).
                    enabled_tables += on ? 1 : 0;
                    ++hooked_tables;
                    hooked.push_back(table_id);
                    const Json& plan = table.at("minimal_hooks");
                    std::set<int> root_children;
                    for (const auto& prototype : plan.value("root_children", Json::array())) root_children.insert(prototype.get<int>());
                    for (const auto& prototype : plan.at("prototypes")) {
                        want.insert(prototype.get<int>());
                        if (!plan.value("retire_safe", false) || !root_children.contains(prototype.get<int>())) not_retirable.insert(prototype.get<int>());
                    }
                }
                std::set<int> want_retiring;
                for (const int prototype : want)
                    if (!not_retirable.contains(prototype)) want_retiring.insert(prototype);
                const auto retiring = source_retiring.find(module_path);
                const std::set<int> have_retiring = retiring == source_retiring.end() ? std::set<int>{} : retiring->second.settled;
                const std::set<int> have_idle = retiring == source_retiring.end() ? std::set<int>{} : retiring->second.idle;
                const std::set<int> have_retire_all = retiring == source_retiring.end() ? std::set<int>{} : retiring->second.retire_all;
                if (have_retiring != want_retiring)
                    problems += "target " + module_path + " returns the retire sentinel from hooks other than its retire-safe root-child hooks; ";
                retiring_hooks += have_retiring.size();
                const auto found = source_hooks.find(module_path);
                const std::set<int> have = found == source_hooks.end() ? std::set<int>{} : found->second;
                if (found == source_hooks.end()) problems += "target " + module_path + " is missing from the generated source; ";
                else if (have != want) problems += "target " + module_path + " declares hooks that are not the minimal hook plan of its tables; ";
                // Every emitted hook has the idle retire path (no enabled value -> retire without writing).
                if (have_idle != have)
                    problems += "target " + module_path + " has a hook without an idle R3 retire path; ";
                idle_hooks += have_idle.size();
                // Contract R4 / S5: exactly the hooks that satisfy R3 obligations 1 and 2 (the settled-retire hooks) open with
                // retire-all over the target-wide flag (the read-back checks the flag is the OR of every table flag).
                if (have_retire_all != want_retiring)
                    problems += "target " + module_path + " returns retire-all from hooks other than its retire-safe root-child hooks; ";
                retire_all_hooks += have_retire_all.size();
                if (!have.empty()) ++hooked_targets;
                hook_count += have.size();
                full_hooks += full.size();
                hook_plan.push_back({{"body_key", body}, {"module_path", module_path}, {"hooked_tables", hooked},
                                     {"tables", tables.size()}, {"prototypes", std::vector<int>(have.begin(), have.end())},
                                     {"retiring_prototypes", std::vector<int>(have_retiring.begin(), have_retiring.end())},
                                     {"idle_retire_prototypes", std::vector<int>(have_idle.begin(), have_idle.end())},
                                     {"retire_all_prototypes", std::vector<int>(have_retire_all.begin(), have_retire_all.end())},
                                     {"full_capturer_prototypes", full.size()}});
            }
            if (source_hooks.size() != addon.size()) problems += "generated source target count differs from the addon targets; ";
            result.gate_log += "hook-plan\n" + (problems.empty() ? std::string("PASS") : problems) + " targets=" + std::to_string(addon.size()) +
                               " hooked_targets=" + std::to_string(hooked_targets) + " hooks=" + std::to_string(hook_count) +
                               " full_capturer_hooks=" + std::to_string(full_hooks) + " tables=" + std::to_string(table_count) +
                               " hooked_tables=" + std::to_string(hooked_tables) + " enabled_tables=" + std::to_string(enabled_tables) + " values=" + std::to_string(compiled_values.size()) +
                               " enabled=" + std::to_string(enabled_ids.size()) + " retiring_hooks=" + std::to_string(retiring_hooks) + " idle_retire_hooks=" + std::to_string(idle_hooks) +
                               " retire_all_hooks=" + std::to_string(retire_all_hooks) + " entry_rows=" + std::to_string(entry_rows_total) + "\n";
            gates.push_back({{"name", "hook-plan"}, {"pass", problems.empty()}, {"exit_code", problems.empty() ? 0 : 1}});
            gates.push_back({{"name", "hook-retire"}, {"pass", problems.empty()}, {"exit_code", problems.empty() ? 0 : 1}});
            if (!problems.empty()) throw std::runtime_error("hook-plan failed: " + problems);
            std::string policy = artifact.filename().string();
            std::transform(policy.begin(), policy.end(), policy.begin(), [](const unsigned char c) { return static_cast<char>(std::tolower(c)); });
            const Json scripts_menu = naming.package_layout
                ? Json{{"row", "[PACKAGE] " + std::string(kMissionPackageName)},
                       {"policy_id", "package:" + ascii_lower_text(kMissionPackageName)},
                       {"package", "Packages/" + std::string(kMissionPackageName)}}
                : Json{{"row", "[ADDON] " + std::string(kMultiTargetAddonName)}, {"policy_id", "target-addon:" + policy}};
            Json addon_extra{{"target_keys", target_keys}, {"targets", targets}, {"scripts_menu", scripts_menu},
                             {"hook_plan", {{"gate", kMinimalHooksGate}, {"targets", hook_plan}, {"hooked_targets", hooked_targets},
                                            {"hooks", hook_count}, {"full_capturer_hooks", full_hooks}, {"values", compiled_values.size()},
                                            {"enabled", enabled_ids.size()}, {"retiring_hooks", retiring_hooks}, {"idle_retire_hooks", idle_hooks},
                                            {"retire_all_hooks", retire_all_hooks}, {"retire_sentinel", kLuaCallRetireSentinel},
                                            {"retire_all_sentinel", kLuaCallRetireAllSentinel}}}};
            // R5: recorded only when the build declares master knobs (older builds keep their manifest shape).
            for (const auto& [id, build] : addon_masters) {
                static_cast<void>(build);
                addon_extra["masters"].push_back(id);
            }
            record("TARGET_ADDON", "TARGET_ADDON", "multi-target", all_rows, source, artifact, fs::path(), std::string(),
                   lua_live_path("OpenWF/CustomScripts/Inject/", artifact), gates, addon_extra);
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
        LiveLiteralOutput live_literal_output;  // R8 recipe (literal_mode "recipe" only)
        EngineParamsOutput engine_params_output;  // R16 engine_params.json (rows with an engine_override only)
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
                // R5 declaration helpers: the declared ids of a member, the declaration of a row or master, and its order key.
                const auto member_declared_ids = [&](const MissionArtifact& item) {
                    if (item.backend == "EXACT_LITERAL" && !item.masters.empty()) return item.masters;
                    std::vector<std::string> ids = item.tunables;
                    ids.insert(ids.end(), item.masters.begin(), item.masters.end());
                    return ids;
                };
                // R7: collapsed page paths of every declared value (a category level whose parent would hold that one
                // category only is dropped), computed over the whole declared set before any declaration is written.
                std::map<std::string, std::vector<std::string>> r7_paths;
                for (const MissionArtifact* item : members)
                    for (const auto& id : member_declared_ids(*item)) {
                        const Json* master = mission_master(registry, id);
                        const Json& ui = master != nullptr ? *master : mission_tunable(registry, id).at("ui");
                        if (ui.contains("path")) r7_paths[id] = ui.at("path").get<std::vector<std::string>>();
                    }
                // Merged R7 + R8: recipe values share the pages, so they take part in the collapse.
                if (naming.literal_recipes)
                    for (const auto& id : live_literal_declared_ids(registry, values, master_values, naming)) {
                        const Json* master = mission_master(registry, id);
                        const Json& ui = master != nullptr ? *master : mission_tunable(registry, id).at("ui");
                        if (ui.contains("path")) r7_paths[id] = ui.at("path").get<std::vector<std::string>>();
                    }
                r7_paths = r7_collapse_paths(std::move(r7_paths));
                const auto mission_declaration = [&](const std::string& id) -> Json {
                    const Json* master = mission_master(registry, id);
                    Json declaration = master != nullptr ? mission_master_declaration(*master)
                                                         : mission_value_declaration(mission_tunable(registry, id));
                    if (const auto found = r7_paths.find(id); found != r7_paths.end()) declaration["path"] = found->second;
                    // R7: a literal value is a choice between the game default and the value the replacement was built
                    // with (the menu offers exactly what the built script can do); the member applies when the built
                    // value is chosen (enabled = value != default).
                    if (declaration.at("lane") == "literal" && declaration.at("type") != "enum" &&
                        (master_values.contains(id) || values.contains(id))) {
                        const double stock = declaration.at("stock").get<double>();
                        const double built = master_values.contains(id) ? master_values.at(id) : values.at(id);
                        const auto unit = declaration.at("unit").get<std::string>();
                        Json options = Json::array();
                        options.push_back({{"label", declaration.contains("default_label") ? declaration.at("default_label").get<std::string>()
                                                                                          : settings_with_unit(stock, unit)},
                                           {"value", settings_number(stock, "int")}});
                        if (built != stock) options.push_back({{"label", settings_with_unit(built, unit)}, {"value", settings_number(built, "int")}});
                        declaration["type"] = "enum";
                        declaration["options"] = options;
                    }
                    return declaration;
                };
                const auto declaration_order = [&](const std::string& id) {
                    const Json* master = mission_master(registry, id);
                    const Json& ui = master != nullptr ? *master : mission_tunable(registry, id).at("ui");
                    return std::tuple<long long, long long, std::string>{
                        registry.at("ui_groups").at(ui.at("group").get<std::string>()).at("order").get<long long>(),
                        ui.contains("rank") ? ui.at("rank").get<long long>() : 1000000000LL, id};
                };
                Json member_labels = Json::object();
                Json member_records = Json::array();
                std::set<std::string> replacement_keys, used_groups, used_labels;
                for (const MissionArtifact* item : members) {
                    const std::string file = item->artifact.filename().string();
                    std::string detail;
                    if (item->backend == "TARGET_ADDON") {
                        if (item->target_keys.empty()) throw std::runtime_error("Package member " + file + " is not the multi-target addon");
                        std::string modules;
                        for (const auto& key : item->target_keys)
                            modules += (modules.empty() ? "" : ", ") + module_short_name(mission_module(registry, key).at("module_path").get<std::string>());
                        detail = "Mission tunables: " + modules;
                    } else {
                        if (!replacement_keys.insert(item->body_key).second) throw std::runtime_error("Two package members replace " + item->body_key);
                        std::string tunables;
                        for (const auto& id : item->tunables) tunables += (tunables.empty() ? "" : ", ") + id;
                        detail = "Exact replacement: " + module_short_name(mission_module(registry, item->body_key).at("module_path").get<std::string>()) +
                                 " (" + tunables + ")";
                    }
                    const std::string label = package_member_label(registry, item->backend, item->tunables,
                                                                   item->backend == "TARGET_ADDON" ? file : item->body_key, used_labels);
                    used_labels.insert(ascii_lower_text(label));
                    fs::copy_file(item->artifact, package_dir / file, fs::copy_options::overwrite_existing);
                    // Phase 2i: one declaration per value the member carries (design section 3.2), from the registry row. R5: plus
                    // its master knobs; a literal master member declares only its master.
                    Json member_values = Json::object();
                    for (const auto& id : member_declared_ids(*item)) {
                        const Json declaration = mission_declaration(id);
                        member_values[id] = declaration;
                        used_groups.insert(declaration.at("group").get<std::string>());
                    }
                    member_labels[file] = Json{{"label", label}, {"settings", Json{{"values", member_values}}}};
                    member_records.push_back({{"file", file}, {"backend", item->backend}, {"label", label}, {"detail", detail},
                                              {"sha256", item->sha256},
                                              {"size", item->size}, {"intended_live_relative_path", item->intended_live_relative_path}});
                }
                const std::string description = package_text(
                    naming.literal_recipes
                        ? "RENOVICE mission editor output for client build " + registry.at("build").get<std::string>() +
                              ". Script-literal values (literals.json) need the LIVE_LITERALS_V1 bootstrapper; older DLLs ignore "
                              "that file and keep those values stock. CustomScripts/Settings/Missions.json holds the chosen values."
                        : "RENOVICE universal mission editor output for client build " + registry.at("build").get<std::string>() +
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
                // R5: the bootstrapper lists a section's values in declaration order, so each member's values are written in
                // (section order, rank, id) order: headline values first, per-player-count variants together. Every other key
                // keeps the sorted order of earlier builds.
                nlohmann::ordered_json ordered_package = nlohmann::ordered_json::parse(package_json.dump());
                for (auto& [file, member] : ordered_package.at("members").items()) {
                    if (!member.contains("settings")) continue;
                    const Json& values_of = package_json.at("members").at(file).at("settings").at("values");
                    std::vector<std::string> ids;
                    for (const auto& [id, declaration] : values_of.items()) {
                        static_cast<void>(declaration);
                        ids.push_back(id);
                    }
                    std::sort(ids.begin(), ids.end(), [&](const std::string& a, const std::string& b) {
                        return declaration_order(a) < declaration_order(b);
                    });
                    nlohmann::ordered_json values_ordered = nlohmann::ordered_json::object();
                    for (const auto& id : ids) values_ordered[id] = nlohmann::ordered_json::parse(values_of.at(id).dump());
                    member["settings"]["values"] = values_ordered;
                }
                write_text(package_dir / "package.json", ordered_package.dump(2) + "\n");
                if (naming.literal_recipes) {
                    std::vector<std::string> package_value_ids;
                    for (const auto& [file, member] : ordered_package.at("members").items())
                        for (const auto& [id, declaration] : member.at("settings").at("values").items()) {
                            static_cast<void>(declaration);
                            package_value_ids.push_back(id);
                        }
                    live_literal_output = emit_live_literal_recipe(
                        registry, paths, editor_root, values, master_values, naming, package_dir, used_groups, package_value_ids,
                        declaration_order, r7_paths,
                        [&](const fs::path& file) {
                            Json roundtrip_gates = Json::array();
                            gate(roundtrip_gates, "live-literal-roundtrip", "de-roundtrip " + quote_process_argument(file),
                                 "FULL BODY identical: True");
                        },
                        result);
                }

                // R16: native ENGINE_PARAM_OVERRIDE declarations for the addon member's EXPOSED script-parameter rows.
                for (const MissionArtifact* item : members) {
                    if (item->backend != "TARGET_ADDON") continue;
                    const std::string file = item->artifact.filename().string();
                    engine_params_output = emit_engine_param_recipe(registry, paths, package_dir, file, member_declared_ids(*item),
                                                                    package_json.at("members").at(file).at("settings").at("values"),
                                                                    result);
                }

                // Package gates (loader rules, bootstrapper renovice/packages_core.hpp).
                std::set<std::string> on_disk, declared;
                for (const auto& entry : fs::directory_iterator(package_dir)) {
                    const std::string name = entry.path().filename().string();
                    if (name != "package.json" && name != kLiveLiteralRecipeFile && name != kEngineParamsFile) on_disk.insert(name);
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
                // Loader bound (bootstrapper renovice/packages_core.hpp maximum_manifest_bytes, 512 KiB since the settings editor).
                const auto manifest_bytes = fs::file_size(package_dir / "package.json");
                if (manifest_bytes > kPackageManifestMaximumBytes)
                    problems += "package.json is " + std::to_string(manifest_bytes) + " bytes, over the loader bound of " +
                                std::to_string(kPackageManifestMaximumBytes) + "; ";
                // Member-label gate (SCRIPT SETTINGS row): <= 40 printable characters, unique, no dangling list punctuation.
                std::set<std::string> label_keys;
                for (const auto& [name, member] : member_labels.items()) {
                    const auto label = member.at("label").get<std::string>();
                    if (label.empty() || label.size() > kPackageMemberRowLabelBudget || !settings_printable(label) ||
                        std::string(" ,;:(-/").find(label.back()) != std::string::npos || label.front() == ' ')
                        problems += "member " + name + " label is empty, over " + std::to_string(kPackageMemberRowLabelBudget) +
                                    " characters or ends in list punctuation; ";
                    if (!label_keys.insert(ascii_lower_text(label)).second) problems += "member " + name + " label is not unique; ";
                }
                result.gate_log += "package-folder\n" + (problems.empty() ? std::string("PASS") : problems) + " members=" +
                                   std::to_string(declared.size()) + " package_json_bytes=" + std::to_string(manifest_bytes) + "\n";
                if (!problems.empty()) throw std::runtime_error("package-folder gate failed: " + problems);

                // Phase 2i gate settings-declarations: strict schema; exactly one declaration per member tunable and nothing
                // else; declaration == registry row; declared stock == registry stock == the addon's compiled stock constant;
                // row-label budget. A failure fails the package build closed.
                std::vector<std::string> settings_problems;
                for (const auto& problem : validate_settings_declarations(package_json)) settings_problems.push_back("schema: " + problem);
                std::size_t declared_values = 0;
                Json migration_values = Json::object(), migration_groups = Json::object();
                std::map<std::string, std::string> value_labels;  // section + folded label -> id (R5: unique per mission section)
                std::size_t declared_masters = 0;
                for (const MissionArtifact* item : members) {
                    const std::string file = item->artifact.filename().string();
                    const Json& declared_member = package_json.at("members").at(file).at("settings").at("values");
                    const auto declared_ids = member_declared_ids(*item);
                    std::set<std::string> want(declared_ids.begin(), declared_ids.end()), have;
                    for (const auto& [id, declaration] : declared_member.items()) {
                        static_cast<void>(declaration);
                        have.insert(id);
                    }
                    if (want != have) settings_problems.push_back(file + ": declarations are not exactly the member values");
                    std::map<std::string, CompiledMissionValue> compiled;
                    if (item->backend == "TARGET_ADDON") {
                        compiled = multi_target_compiled_values(read_text(item->source));
                        std::set<std::string> compiled_ids;
                        for (const auto& [id, value] : compiled) compiled_ids.insert(id);
                        if (compiled_ids != want) settings_problems.push_back(file + ": compiled settings table is not exactly the declared values");
                    }
                    for (const auto& id : want) {
                        if (!declared_member.contains(id)) continue;
                        const Json* master = mission_master(registry, id);
                        const Json& ui = master != nullptr ? *master : mission_tunable(registry, id).at("ui");
                        const Json& declaration = declared_member.at(id);
                        ++declared_values;
                        declared_masters += master != nullptr ? 1 : 0;
                        if (declaration != mission_declaration(id)) settings_problems.push_back(id + ": declaration differs from its registry row");
                        const double stock = master != nullptr ? master->at("stock").get<double>() : mission_tunable(registry, id).at("stock").get<double>();
                        if (!declaration.at("stock").is_number() || declaration.at("stock").get<double>() != stock)
                            settings_problems.push_back(id + ": declared stock differs from the registry stock");
                        if (declaration.at("lane") != (item->backend == "TARGET_ADDON" ? "addon" : "literal"))
                            settings_problems.push_back(id + ": declared lane differs from the member kind");
                        // The build's choice for this value: an addon value is enabled when the build names it (otherwise it
                        // is declared at stock, package_scope "all_addon_values"); a replacement member exists only for values
                        // the build names. R5: disabled_values ships a named value switched off (the value is still built);
                        // a master is on/off as a whole.
                        const bool named = master != nullptr ? master_values.contains(id) : values.contains(id);
                        const bool on = item->backend == "TARGET_ADDON"
                                            ? (master != nullptr ? addon_masters.at(id).enabled : enabled_ids.contains(id))
                                            : named && !naming.disabled_values.contains(id);
                        const double chosen = named ? (master != nullptr ? master_values.at(id) : values.at(id)) : stock;
                        if (item->backend == "TARGET_ADDON") {
                            const auto found = compiled.find(id);
                            if (found == compiled.end() || found->second.stock != stock)
                                settings_problems.push_back(id + ": compiled stock constant differs from the registry stock");
                            else if (found->second.value != chosen)
                                settings_problems.push_back(id + ": compiled value differs from the build value");
                            else if (found->second.enabled != on)
                                settings_problems.push_back(id + ": compiled enabled flag differs from the build's choice");
                        }
                        const auto group = declaration.at("group").get<std::string>();
                        for (const auto& problem : settings_label_budget_problems(id, declaration, registry.at("ui_groups").at(group)))
                            settings_problems.push_back(problem);
                        // Phase 2k: value labels end in no list punctuation. R5: unique within the mission section (the section
                        // TITLE names the mission; the search box is off since bootstrapper R4).
                        const auto label = declaration.at("label").get<std::string>();
                        if (label.empty() || std::string(" ,;:(-/").find(label.back()) != std::string::npos || label.front() == ' ')
                            settings_problems.push_back(id + ": label is empty or starts/ends with a space or list punctuation");
                        if (const auto [it, inserted] = value_labels.emplace(section_family(group) + "|" + ascii_lower_text(label), id); !inserted)
                            settings_problems.push_back(id + ": label \"" + label + "\" is not unique in its mission section (also " + it->second + ")");
                        // R5 player-text gates (label <= 33, value row <= 40, no unexplained abbreviation or code identifier, stock
                        // and unit stated, tooltip <= 300). A full package (all_addon_values) must declare player text only.
                        if (ui.value("label_source", std::string()) == "player_text") {
                            for (const auto& problem : player_text_problems(id, label, declaration.at("unit").get<std::string>(), stock,
                                                                            declaration.at("min").get<double>(), declaration.at("max").get<double>(),
                                                                            declaration.at("scope").get<std::string>(),
                                                                            declaration.at("lane").get<std::string>(),
                                                                            registry.contains("ui_layout")))
                                settings_problems.push_back(problem);
                        } else if (naming.declare_all_addon_values) {
                            settings_problems.push_back(id + ": declared without player text (label_source " +
                                                        ui.value("label_source", std::string("?")) + ")");
                        }
                        migration_groups[group] = true;
                        migration_values[id] = Json{{"enabled", on}, {"value", settings_number(chosen, declaration.at("type").get<std::string>())}};
                    }
                }
                // R7 layout gate: every value has a page path and a row; one row per (page, text); no row named like a
                // page next to it; unique quick labels; no "::" or dangling colon anywhere; short plain descriptions
                // without node lists, MT codes or internal ids.
                std::size_t layout_pages = 0, layout_quick = 0;
                if (registry.contains("ui_layout")) {
                    std::map<std::pair<std::vector<std::string>, std::string>, std::string> rows_seen;
                    std::set<std::vector<std::string>> pages;
                    std::set<std::string> quick_seen;
                    std::vector<std::tuple<std::vector<std::string>, std::string, std::string>> row_list;
                    // Merged R7 + R8: the recipe values (literals.json) are rows of the same pages.
                    Json layout_members = package_json.at("members");
                    if (naming.literal_recipes && fs::exists(package_dir / kLiveLiteralRecipeFile)) {
                        Json recipe_values = Json::object();
                        const Json recipe_file = Json::parse(read_text(package_dir / kLiveLiteralRecipeFile));
                        for (const auto& [id, entry] : recipe_file.at("values").items()) recipe_values[id] = entry.at("declaration");
                        layout_members[kLiveLiteralRecipeFile] = Json{{"settings", Json{{"values", recipe_values}}}};
                    }
                    for (const auto& [file, member] : layout_members.items()) {
                        static_cast<void>(file);
                        for (const auto& [id, declaration] : member.at("settings").at("values").items()) {
                            if (!declaration.contains("path") || !declaration.contains("row")) {
                                settings_problems.push_back(id + ": declared without an R7 page path and row");
                                continue;
                            }
                            for (const auto& problem : r7_layout_ui_problems(id, declaration)) settings_problems.push_back(problem);
                            const auto path = declaration.at("path").get<std::vector<std::string>>();
                            for (std::size_t depth = 1; depth <= path.size(); ++depth)
                                pages.insert(std::vector<std::string>(path.begin(), path.begin() + static_cast<std::ptrdiff_t>(depth)));
                            const auto row = declaration.at("row").get<std::string>();
                            row_list.emplace_back(path, row, id);
                            if (const auto [it, inserted] = rows_seen.emplace(std::make_pair(path, ascii_lower_text(row)), id); !inserted)
                                settings_problems.push_back(id + ": row \"" + row + "\" appears twice on its page (also " + it->second + ")");
                            const auto label = declaration.at("label").get<std::string>();
                            if (label.find("::") != std::string::npos) settings_problems.push_back(id + ": label has \"::\"");
                            if (declaration.contains("quick") && !quick_seen.insert(ascii_lower_text(declaration.at("quick").get<std::string>())).second)
                                settings_problems.push_back(id + ": quick label is not unique");
                            const Json* master = mission_master(registry, id);
                            const Json& ui = master != nullptr ? *master : mission_tunable(registry, id).at("ui");
                            if (ui.value("label_source", std::string()) == "player_text")
                                for (const auto& problem : r7_description_problems(id, declaration.at("scope").get<std::string>()))
                                    settings_problems.push_back(problem);
                        }
                    }
                    for (const auto& [path, row, id] : row_list) {
                        auto page = path;
                        page.push_back(row);
                        if (pages.contains(page)) settings_problems.push_back(id + ": row has the same name as a page next to it");
                    }
                    layout_pages = pages.size();
                    layout_quick = quick_seen.size();
                    const std::size_t recipe_rows = layout_members.contains(kLiveLiteralRecipeFile)
                        ? layout_members.at(kLiveLiteralRecipeFile).at("settings").at("values").size() : 0;
                    result.gate_log += "settings-layout\n" + std::string(settings_problems.empty() ? "PASS" : "FAIL") + " values=" +
                                       std::to_string(declared_values) +
                                       (recipe_rows != 0 ? " live_literals=" + std::to_string(recipe_rows) : std::string()) +
                                       " pages=" + std::to_string(layout_pages) + " quick=" + std::to_string(layout_quick) + "\n";
                }
                std::string settings_text;
                for (const auto& problem : settings_problems) settings_text += (settings_text.empty() ? "" : "; ") + problem;
                // R5 declaration order, read back from the written file: inside every member, values of one section follow
                // their rank (headline values first, per-player-count variants together).
                {
                    const auto written = nlohmann::ordered_json::parse(read_text(package_dir / "package.json"));
                    for (const auto& [file, member] : written.at("members").items()) {

                        std::tuple<long long, long long, std::string> previous{-1, -1, std::string()};
                        for (const auto& [id, declaration] : member.at("settings").at("values").items()) {
                            static_cast<void>(declaration);
                            const auto key = declaration_order(id);
                            if (key < previous) settings_problems.push_back(file + ": " + id + " is declared out of section/rank order");
                            previous = key;
                        }
                    }
                }
                if (!settings_problems.empty()) settings_text.clear();
                for (const auto& problem : settings_problems) settings_text += (settings_text.empty() ? "" : "; ") + problem;
                result.gate_log += "settings-declarations\n" + (settings_text.empty() ? std::string("PASS") : settings_text) + " values=" +
                                   std::to_string(declared_values) + " groups=" + std::to_string(group_declarations.size()) +
                                   (declared_masters != 0 ? " masters=" + std::to_string(declared_masters) : std::string()) + "\n";
                if (!settings_text.empty()) throw std::runtime_error("settings-declarations gate failed: " + settings_text);
                // Migration settings file (design section 3.3): the values this build applies, enabled, so a runtime with
                // ADDON_SETTINGS_V1 reproduces the loose behaviour; with package_scope "all_addon_values" every other declared
                // value is listed disabled at its stock (the shipped defaults). It is installed outside the package folder
                // (CustomScripts/Settings/<package>.json) because the package folder is replaced on redeploy.
                const fs::path settings_file = result.directory / "Settings" / (std::string(kMissionPackageName) + ".json");
                fs::create_directories(settings_file.parent_path());
                for (const auto& [id, entry] : live_literal_output.settings_values.items()) migration_values[id] = entry;  // R8
                for (const auto& group : live_literal_output.groups) migration_groups[group] = true;
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
                                                                  {"groups", group_declarations.size()},
                                                                  {"scope", naming.declare_all_addon_values ? "all_addon_values" : "built_values"},
                                                                  {"enabled_addon_values", enabled_ids.size()},
                                                                  {"masters", declared_masters},
                                                                  {"excluded_values", excluded_values}}},
                                                {"migration", {{"path", relative(settings_file)}, {"sha256", sha256_file(settings_file)},
                                                               {"format", kScriptSettingsFormat},
                                                               {"intended_live_relative_path", "OpenWF/CustomScripts/Settings/" +
                                                                                                   std::string(kMissionPackageName) + ".json"}}}}},
                                  {"gates", Json::array({Json{{"name", "package-folder"}, {"pass", true}, {"exit_code", 0}},
                                                         Json{{"name", "settings-declarations"}, {"pass", true}, {"exit_code", 0}}})}};
                if (naming.literal_recipes) {
                    package_record["live_literals"] = live_literal_output.record;
                    package_record["gates"].push_back({{"name", "live-literal-recipe"}, {"pass", true}, {"exit_code", 0}});
                }
                if (!engine_params_output.record.is_null()) {
                    package_record["engine_params"] = engine_params_output.record;
                    package_record["gates"].push_back({{"name", "engine-param-overrides"}, {"pass", true}, {"exit_code", 0}});
                }
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
        // Optional (Phase 2k): "package_scope": "built_values" (default: the package declares the values it builds) or
        // "all_addon_values" (declare every multi-instance-safe addon value; `values` names the enabled ones).
        bool declare_all = false;
        if (settings.contains("package_scope")) {
            const Json& scope = settings.at("package_scope");
            if (!scope.is_string() || (scope != "built_values" && scope != "all_addon_values"))
                throw std::runtime_error("package_scope must be \"built_values\" or \"all_addon_values\"");
            declare_all = scope == "all_addon_values";
        }
        // Optional (R5): "disabled_values": [ids] named in `values` that are built but shipped switched off
        // (package_scope "all_addon_values" only).
        std::set<std::string> disabled;
        if (settings.contains("disabled_values")) {
            const Json& list = settings.at("disabled_values");
            if (!list.is_array() || !declare_all || !package_layout)
                throw std::runtime_error("disabled_values must be an array of ids and needs package_scope \"all_addon_values\"");
            for (const auto& id : list) {
                if (!id.is_string() || !disabled.insert(id.get<std::string>()).second)
                    throw std::runtime_error("disabled_values holds a non-string or repeated id: " + id.dump());
            }
        }
        MissionNaming naming{"missions", "missions", "missions", "RENOVICE_Missions.txt", false, "", allow_unproven, package_layout, declare_all};
        naming.disabled_values = std::move(disabled);
        // Optional (R8): "literal_mode": "baked" (default: exact replacements) or "recipe" (LIVE_LITERALS_V1 literals.json,
        // typeable in game; package layout with package_scope "all_addon_values"), and "literal_scope": "built_values"
        // (default) or "headline" (recipe mode: also declare every registry headline literal value at stock, off).
        if (settings.contains("literal_mode")) {
            const Json& mode = settings.at("literal_mode");
            if (!mode.is_string() || (mode != "baked" && mode != "recipe")) throw std::runtime_error("literal_mode must be \"baked\" or \"recipe\"");
            naming.literal_recipes = mode == "recipe";
            if (naming.literal_recipes && (!package_layout || !declare_all))
                throw std::runtime_error("literal_mode \"recipe\" needs output_layout \"package\" and package_scope \"all_addon_values\"");
        }
        if (settings.contains("literal_scope")) {
            const Json& scope = settings.at("literal_scope");
            if (!scope.is_string() || (scope != "built_values" && scope != "headline"))
                throw std::runtime_error("literal_scope must be \"built_values\" or \"headline\"");
            naming.literal_headline = scope == "headline";
            if (naming.literal_headline && !naming.literal_recipes) throw std::runtime_error("literal_scope \"headline\" needs literal_mode \"recipe\"");
        }
        return build_mission_set(registry, settings.at("values"), naming, editor_root, staging_root, run_external_gates, nullptr);
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
