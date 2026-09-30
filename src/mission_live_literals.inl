// LIVE_LITERALS_V1 recipe emission (2026-09-30, contract CONTRACT_PHASE1.md Revision R8).
//
// Instead of baking a literal value into an exact replacement at build time, a "literal_mode": "recipe" package ships
// `Packages/Missions/literals.json`: per value the exact sites and preimages of every driven row, the encoding rule and
// the scale, plus the module's stock size and SHA-256. The bootstrapper (LIVE_LITERALS_V1) synthesizes the module from
// its captured stock bytes at each apply, so the value is typeable in SCRIPT SETTINGS. The site rules (operand, domain,
// encoding, preimage verification, patch application) are the shared core include/renovice/live_literal_patch_core.hpp,
// byte-identical to the bootstrapper's renovice/live_literal_patch_core.hpp; the exact-replacement builder uses the same
// core, so a recipe and a baked replacement of the same values are the same bytes.
//
// Included by mission_profiles.inl (inside its anonymous namespace).

namespace patch = live_literal_patch;

constexpr const char* kLiveLiteralRecipeFormat = "RENOVICE_LIVE_LITERALS_V1";
constexpr const char* kLiveLiteralRecipeFile = "literals.json";
// Pinned SHA-256 of the shared core (gate `live-literal-core`); the bootstrapper pins the same value.
constexpr const char* kLiveLiteralCoreSha256 = "2fdda7b84c966250d3718da4391a1145981734d6774cb62cce02e7e099ba9be8";

// Registry literal site (EXACT_LITERAL owner or literal_owner) -> shared-core site.
patch::Site mission_patch_site(const Json& site) {
    patch::Site out;
    out.kind = site.at("kind") == "number_constant" ? patch::SiteKind::NumberConstant : patch::SiteKind::Loadn;
    out.offset = site.at("offset").get<std::size_t>();
    const auto expected = site.at("expected").get<std::vector<unsigned int>>();
    if (expected.size() != patch::width(out.kind)) throw std::runtime_error("invalid literal site extent");
    for (std::size_t n = 0; n < expected.size(); ++n) out.expected[n] = static_cast<unsigned char>(expected[n]);
    out.reg = static_cast<unsigned char>(site.value("register", 0));
    out.rewrites_instruction = site.value("rewrites_instruction", false);
    out.inverse = site.value("inverse", false);
    out.numerator = site.at("numerator").get<double>();
    out.denominator = site.contains("denominator") ? site.at("denominator").get<double>() : 1.0;
    out.value_offset = site.value("value_offset", 0.0);  // R11 coupled site (0 = plain site)
    return out;
}

std::string lower_hex_text(std::string text) {
    std::transform(text.begin(), text.end(), text.begin(), [](const unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return text;
}

std::string patch_hex(const std::array<unsigned char, 8>& bytes, const std::size_t count) {
    static constexpr char digits[] = "0123456789abcdef";
    std::string text;
    for (std::size_t n = 0; n < count; ++n) {
        text.push_back(digits[bytes[n] >> 4]);
        text.push_back(digits[bytes[n] & 15u]);
    }
    return text;
}

// One recipe value: a registry row declared directly, or a literal master knob (R5-3) with its driven rows.
struct LiveLiteralValue {
    std::string id;
    bool master = false;
    std::string body;
    std::vector<std::pair<const Json*, double>> drives;  // registry row, scale (1 for a direct row)
    Json declaration;
    double stock = 0;
};

LiveLiteralValue live_literal_value(const Json& registry, const std::string& id) {
    LiveLiteralValue value;
    value.id = id;
    if (const Json* master = mission_master(registry, id)) {
        if (master->at("lane") != "literal") throw std::runtime_error("live literal " + id + " is not a literal master knob");
        value.master = true;
        value.body = master->at("body_key").get<std::string>();
        for (const auto& drive : master->at("drives"))
            value.drives.emplace_back(&mission_tunable(registry, drive.at("tunable_id").get<std::string>()), drive.at("scale").get<double>());
        value.declaration = mission_master_declaration(*master);
        value.stock = master->at("stock").get<double>();
    } else {
        const Json& row = mission_tunable(registry, id);
        if (row.at("backend") != "EXACT_LITERAL") throw std::runtime_error("live literal " + id + " is not an EXACT_LITERAL row");
        if (row.at("ui").contains("hidden")) throw std::runtime_error(id + " is hidden from packages: " + row.at("ui").at("hidden").get<std::string>());
        value.body = row.at("owner").at("body_key").get<std::string>();
        value.drives.emplace_back(&row, 1.0);
        value.declaration = mission_value_declaration(row);
        value.stock = row.at("stock").get<double>();
    }
    if (value.declaration.at("lane") != "literal" || value.declaration.at("applies") != "next_mission")
        throw std::runtime_error("live literal " + id + " is not declared on the literal lane (next_mission)");
    for (const auto& [row, scale] : value.drives) {
        static_cast<void>(scale);
        if (row->at("owner").at("body_key") != value.body) throw std::runtime_error("live literal " + id + " drives rows of several modules");
    }
    return value;
}

// Host resolution (bootstrapper live_literals_core.hpp resolve_plans), used by the generator's own gates: a row's own
// value, when it is on, wins (at its stock it stays stock); otherwise an applied master (on and not at its stock) gives
// master x scale; otherwise the row stays stock. Returns the resolved patches of one module, sorted by offset.
std::vector<patch::Patch> resolve_live_literal_module(const std::vector<LiveLiteralValue>& values, const std::string& body,
                                                      const std::map<std::string, double>& on) {
    struct Choice { bool direct = false; double direct_value = 0; bool master = false; double master_value = 0; double scale = 1;
                    const Json* row = nullptr; };
    std::map<std::string, Choice> rows;
    for (const auto& value : values) {
        if (value.body != body) continue;
        const auto chosen = on.find(value.id);
        if (chosen == on.end()) continue;
        for (const auto& [row, scale] : value.drives) {
            auto& choice = rows[row->at("tunable_id").get<std::string>()];
            choice.row = row;
            if (!value.master) {
                choice.direct = true;
                choice.direct_value = chosen->second;
            } else if (chosen->second != value.stock) {
                choice.master = true;
                choice.master_value = chosen->second;
                choice.scale = scale;
            }
        }
    }
    std::vector<patch::Patch> patches;
    for (const auto& [id, choice] : rows) {
        double row_value = 0;
        if (choice.direct) {
            if (choice.direct_value == choice.row->at("stock").get<double>()) continue;
            row_value = choice.direct_value;
        } else if (choice.master) {
            row_value = patch::row_value(choice.master_value, choice.scale, choice.row->at("limits").value("integer", false));
        } else {
            continue;
        }
        for (const auto& site : mission_literal_owner(*choice.row)->at("sites")) {
            patch::Patch item;
            item.site = mission_patch_site(site);
            if (const auto error = patch::encode(item.site, row_value, item.bytes); error != patch::Error::None)
                throw std::runtime_error("live literal row " + id + ": " + patch::error_text(error));
            patches.push_back(item);
        }
    }
    std::sort(patches.begin(), patches.end(), [](const patch::Patch& a, const patch::Patch& b) { return a.site.offset < b.site.offset; });
    return patches;
}

std::string synthesize_live_literal_module(const std::string& stock, const std::vector<patch::Patch>& patches, const std::string& body) {
    std::vector<unsigned char> out;
    std::size_t failed = 0;
    const auto* bytes = reinterpret_cast<const unsigned char*>(stock.data());
    if (const auto error = patch::apply(bytes, stock.size(), patches, out, failed); error != patch::Error::None)
        throw std::runtime_error("live literal synthesis of " + body + " failed: " + patch::error_text(error));
    return std::string(out.begin(), out.end());
}

// Builds the recipe JSON (ordered) for `ids`. `insert_before(id)` names the package.json value the recipe value is
// displayed before (empty: after every package.json value of its section). Recipe-only groups are returned in `groups`.
nlohmann::ordered_json live_literal_recipe(const Json& registry, const MissionPaths& paths, const std::vector<LiveLiteralValue>& values,
                                           const std::function<std::string(const std::string&)>& insert_before,
                                           const std::vector<std::string>& recipe_groups) {
    nlohmann::ordered_json recipe = nlohmann::ordered_json::object();
    recipe["format"] = kLiveLiteralRecipeFormat;
    recipe["package"] = "package:" + ascii_lower_text(kMissionPackageName);
    recipe["build"] = registry.at("build").get<std::string>();
    nlohmann::ordered_json modules = nlohmann::ordered_json::object();
    std::set<std::string> bodies;
    for (const auto& value : values) bodies.insert(value.body);
    for (const auto& body : bodies) {
        const Json& module = mission_module(registry, body);
        const fs::path stock = paths.corpus / module.at("file").get<std::string>();
        if (!fs::exists(stock) || sha256_file(stock) != module.at("sha256").get<std::string>())
            throw std::runtime_error("live literal stock body missing or changed: " + body);
        modules[body] = nlohmann::ordered_json{{"file", module.at("file").get<std::string>()},
                                               {"stock_size", static_cast<std::uint64_t>(fs::file_size(stock))},
                                               {"stock_sha256", lower_hex_text(module.at("sha256").get<std::string>())}};
    }
    recipe["modules"] = modules;
    if (!recipe_groups.empty()) {
        nlohmann::ordered_json groups = nlohmann::ordered_json::array();
        for (const auto& group : recipe_groups)
            groups.push_back(nlohmann::ordered_json::parse(mission_group_declaration(registry, group).dump()));
        recipe["groups"] = groups;
    }
    nlohmann::ordered_json entries = nlohmann::ordered_json::object();
    for (const auto& value : values) {
        nlohmann::ordered_json entry = nlohmann::ordered_json::object();
        nlohmann::ordered_json declaration = nlohmann::ordered_json::object();
        for (const char* key : {"group", "label", "unit", "type", "stock", "min", "max", "scope", "lane", "applies"})
            declaration[key] = nlohmann::ordered_json::parse(value.declaration.at(key).dump());
        // R7 layout fields (merged R7 + R8, contract R9): page path (collapsed with the package values), row, quick label and
        // the display text of a range default. `default` is addon-lane only: a live literal's default is its stock.
        for (const char* key : {"path", "row", "quick", "default_label"})
            if (value.declaration.contains(key)) declaration[key] = nlohmann::ordered_json::parse(value.declaration.at(key).dump());
        entry["declaration"] = declaration;
        entry["module"] = value.body;
        if (const auto before = insert_before(value.id); !before.empty()) entry["insert_before"] = before;
        nlohmann::ordered_json drives = nlohmann::ordered_json::array();
        for (const auto& [row, scale] : value.drives) {
            const Json* owner = mission_literal_owner(*row);
            if (owner == nullptr) throw std::runtime_error("live literal row " + row->at("tunable_id").get<std::string>() + " has no literal form");
            nlohmann::ordered_json sites = nlohmann::ordered_json::array();
            for (const auto& site : owner->at("sites")) {
                const patch::Site core = mission_patch_site(site);
                nlohmann::ordered_json item = nlohmann::ordered_json::object();
                const bool constant = core.kind == patch::SiteKind::NumberConstant;
                item["kind"] = constant ? "number_constant" : "loadn";
                item["offset"] = core.offset;
                item["expected"] = patch_hex(core.expected, patch::width(core.kind));
                if (!constant) {
                    item["register"] = core.reg;
                    if (core.rewrites_instruction) item["rewrites_instruction"] = true;
                } else {
                    // Shared-constant safety: emitted only with the registrar's exclusivity proof (checked here again).
                    verify_constant_exclusivity(site);
                    item["constant_gate"] = kConstantExclusivityGate;
                }
                item["numerator"] = nlohmann::ordered_json::parse(site.at("numerator").dump());
                item["denominator"] = site.contains("denominator") ? nlohmann::ordered_json::parse(site.at("denominator").dump())
                                                                   : nlohmann::ordered_json(1);
                if (core.inverse) item["inverse"] = true;
                // R11 coupled site: emitted only when set, so every plain site keeps its R8 recipe form.
                if (core.value_offset != 0.0) item["value_offset"] = nlohmann::ordered_json::parse(site.at("value_offset").dump());
                sites.push_back(item);
            }
            drives.push_back(nlohmann::ordered_json{{"row", row->at("tunable_id").get<std::string>()},
                                                    {"scale", nlohmann::ordered_json::parse(settings_number(scale, "int").dump())},
                                                    {"integer", row->at("limits").value("integer", false)},
                                                    {"stock", nlohmann::ordered_json::parse(row->at("stock").dump())},
                                                    {"sites", sites}});
        }
        entry["drives"] = drives;
        entries[value.id] = entry;
    }
    recipe["values"] = entries;
    return recipe;
}

struct LiveLiteralOutput {
    Json settings_values = Json::object();  // values-file entries of the recipe values
    std::vector<std::string> groups;        // groups the recipe values use
    Json record = nullptr;                  // MISSION_SET_MANIFEST package.live_literals
};

using MissionOrderKey = std::tuple<long long, long long, std::string>;

// The values a recipe build declares in literals.json: named literal rows and literal masters, plus the headline list.
std::set<std::string> live_literal_declared_ids(const Json& registry, const std::map<std::string, double>& row_values,
                                                const std::map<std::string, double>& master_values, const MissionNaming& naming) {
    std::set<std::string> ids;
    for (const auto& [id, value] : row_values) {
        static_cast<void>(value);
        if (mission_tunable(registry, id).at("backend") == "EXACT_LITERAL") ids.insert(id);
    }
    for (const auto& [id, value] : master_values) {
        static_cast<void>(value);
        if (mission_master(registry, id)->at("lane") == "literal") ids.insert(id);
    }
    if (naming.literal_headline) {
        if (!registry.contains("ui_player_text") || !registry.at("ui_player_text").contains("live_literal_headline"))
            throw std::runtime_error("literal_scope \"headline\": the registry has no ui_player_text.live_literal_headline list");
        for (const auto& id : registry.at("ui_player_text").at("live_literal_headline")) ids.insert(id.get<std::string>());
    }
    return ids;
}

// Emits Packages/Missions/literals.json for a "literal_mode": "recipe" build and runs its gates:
//   live-literal-core      the shared core is the pinned, byte-identical copy;
//   live-literal-recipe    every value is a literal row or master of one module, declared with player text, unique in its
//                          mission section, schema-valid; every site verified against the pinned stock bytes (constant
//                          sites only with the exclusivity proof); each value alone at its min and its max synthesizes;
//                          the shipped values synthesize and pass the DE container round trip.
LiveLiteralOutput emit_live_literal_recipe(const Json& registry, const MissionPaths& paths, const fs::path& editor_root,
                                           const std::map<std::string, double>& row_values, const std::map<std::string, double>& master_values,
                                           const MissionNaming& naming, const fs::path& package_dir, const std::set<std::string>& package_groups,
                                           const std::vector<std::string>& package_value_ids,
                                           const std::function<MissionOrderKey(const std::string&)>& order,
                                           const std::map<std::string, std::vector<std::string>>& layout_paths,
                                           const std::function<void(const fs::path&)>& roundtrip, MissionSetResult& result) {
    LiveLiteralOutput output;
    const fs::path core_path = editor_root / "include/renovice/live_literal_patch_core.hpp";
    if (lower_hex_text(sha256_file(core_path)) != kLiveLiteralCoreSha256)
        throw std::runtime_error("live-literal-core gate failed: include/renovice/live_literal_patch_core.hpp is not the pinned shared core");
    // The declared set: named literal rows and literal masters, plus the headline list.
    const std::set<std::string> ids = live_literal_declared_ids(registry, row_values, master_values, naming);
    std::vector<std::string> ordered(ids.begin(), ids.end());
    std::sort(ordered.begin(), ordered.end(), [&](const std::string& a, const std::string& b) { return order(a) < order(b); });
    std::vector<LiveLiteralValue> values;
    const std::set<std::string> package_ids(package_value_ids.begin(), package_value_ids.end());
    std::set<std::string> groups;
    for (const auto& id : ordered) {
        if (package_ids.contains(id)) throw std::runtime_error("live literal " + id + " is also declared in package.json");
        values.push_back(live_literal_value(registry, id));
        // R7: the page path collapsed over the whole declared set (package.json and recipe values together).
        if (const auto found = layout_paths.find(id); found != layout_paths.end()) values.back().declaration["path"] = found->second;
        for (const auto& [row, scale] : values.back().drives) {
            static_cast<void>(scale);
            try { verify_mission_row(registry, *row, paths); }
            catch (const std::exception& e) { throw std::runtime_error(row->at("tunable_id").get<std::string>() + ": " + e.what()); }
        }
        groups.insert(values.back().declaration.at("group").get<std::string>());
    }
    if (values.empty()) throw std::runtime_error("literal_mode \"recipe\" declares no literal value");
    std::vector<std::string> recipe_groups;
    for (const auto& group : groups)
        if (!package_groups.contains(group)) recipe_groups.push_back(group);
    std::sort(recipe_groups.begin(), recipe_groups.end(), [&](const std::string& a, const std::string& b) {
        return registry.at("ui_groups").at(a).at("order").get<long long>() < registry.at("ui_groups").at(b).at("order").get<long long>();
    });
    const auto insert_before = [&](const std::string& id) {
        const auto key = order(id);
        const auto group = std::get<0>(key);
        for (const auto& other : package_value_ids) {
            const auto other_key = order(other);
            if (std::get<0>(other_key) == group && key < other_key) return other;
        }
        return std::string();
    };
    const auto recipe = live_literal_recipe(registry, paths, values, insert_before, recipe_groups);
    const fs::path recipe_path = package_dir / kLiveLiteralRecipeFile;
    write_text(recipe_path, recipe.dump(2) + "\n");
    if (nlohmann::ordered_json::parse(read_text(recipe_path)) != recipe) throw std::runtime_error("literals.json readback mismatch");

    // Declarations: schema (as a synthetic member), player text, per-section label uniqueness with package.json values.
    std::vector<std::string> problems;
    Json synthetic{{"settings", {{"format", kSettingsDeclarationFormat}, {"build", registry.at("build")}, {"groups", Json::array()}}},
                   {"members", {{kLiveLiteralRecipeFile, {{"settings", {{"values", Json::object()}}}}}}}};
    for (const auto& group : groups) synthetic["settings"]["groups"].push_back(mission_group_declaration(registry, group));
    for (const auto& value : values) synthetic["members"][kLiveLiteralRecipeFile]["settings"]["values"][value.id] = value.declaration;
    for (const auto& problem : validate_settings_declarations(synthetic)) problems.push_back("schema: " + problem);
    std::map<std::string, std::string> labels;
    for (const auto& id : package_value_ids) {
        const Json* master = mission_master(registry, id);
        const Json& ui = master != nullptr ? *master : mission_tunable(registry, id).at("ui");
        labels.emplace(section_family(ui.at("group").get<std::string>()) + "|" + ascii_lower_text(ui.at("short_label").get<std::string>()), id);
    }
    for (const auto& value : values) {
        const Json& d = value.declaration;
        const auto label = d.at("label").get<std::string>();
        const Json* master = mission_master(registry, value.id);
        const Json& ui = master != nullptr ? *master : mission_tunable(registry, value.id).at("ui");
        if (ui.value("label_source", std::string()) != "player_text") problems.push_back(value.id + ": declared without player text");
        for (const auto& problem : player_text_problems(value.id, label, d.at("unit").get<std::string>(), value.stock, d.at("min").get<double>(),
                                                        d.at("max").get<double>(), d.at("scope").get<std::string>(), "literal",
                                                        registry.contains("ui_layout")))  // R7 description rules
            problems.push_back(problem);
        for (const auto& problem : settings_label_budget_problems(value.id, d, registry.at("ui_groups").at(d.at("group").get<std::string>())))
            problems.push_back(problem);
        const auto [it, inserted] = labels.emplace(section_family(d.at("group").get<std::string>()) + "|" + ascii_lower_text(label), value.id);
        if (!inserted) problems.push_back(value.id + ": label '" + label + "' is not unique in its mission section (also " + it->second + ")");
    }
    if (!problems.empty()) {
        std::string text;
        for (const auto& problem : problems) text += (text.empty() ? "" : "; ") + problem;
        throw std::runtime_error("live-literal-recipe gate failed: " + text);
    }

    // Synthesis: each value alone at its min and its max, then the shipped values per module.
    std::map<std::string, std::string> stock_of;
    for (const auto& value : values) {
        if (stock_of.contains(value.body)) continue;
        const Json& module = mission_module(registry, value.body);
        stock_of[value.body] = read_text(paths.corpus / module.at("file").get<std::string>());
    }
    std::size_t extreme_syntheses = 0;
    for (const auto& value : values) {
        for (const double end : {value.declaration.at("min").get<double>(), value.declaration.at("max").get<double>()}) {
            const auto patches = resolve_live_literal_module(values, value.body, {{value.id, end}});
            static_cast<void>(synthesize_live_literal_module(stock_of.at(value.body), patches, value.body));
            ++extreme_syntheses;
        }
    }
    std::map<std::string, double> shipped;
    for (const auto& value : values) {
        const bool named = value.master ? master_values.contains(value.id) : row_values.contains(value.id);
        const double chosen = named ? (value.master ? master_values.at(value.id) : row_values.at(value.id)) : value.stock;
        const bool on = named && !naming.disabled_values.contains(value.id);
        if (named) shipped[value.id] = chosen;
        output.settings_values[value.id] = Json{{"enabled", on}, {"value", settings_number(chosen, value.declaration.at("type").get<std::string>())}};
    }
    Json synthesis_records = Json::array();
    const fs::path synthesis_dir = result.directory / "live-literals";
    for (const auto& [body, stock] : stock_of) {
        const auto patches = resolve_live_literal_module(values, body, shipped);
        if (patches.empty()) continue;
        const auto bytes = synthesize_live_literal_module(stock, patches, body);
        fs::create_directories(synthesis_dir);
        const fs::path file = synthesis_dir / (body + ".synthesized.lua_B");
        write_text(file, bytes);
        roundtrip(file);
        synthesis_records.push_back({{"body_key", body}, {"patches", patches.size()}, {"sha256", sha256_file(file)}, {"size", bytes.size()},
                                     {"path", fs::relative(file, result.directory).generic_string()}});
    }
    std::size_t masters = 0;
    for (const auto& value : values) masters += value.master ? 1 : 0;
    output.groups.assign(groups.begin(), groups.end());
    output.record = {{"path", fs::relative(recipe_path, result.directory).generic_string()}, {"sha256", sha256_file(recipe_path)},
                     {"size", fs::file_size(recipe_path)}, {"format", kLiveLiteralRecipeFormat}, {"values", values.size()},
                     {"masters", masters}, {"modules", stock_of.size()}, {"recipe_only_groups", recipe_groups},
                     {"core_sha256", kLiveLiteralCoreSha256}, {"shipped_synthesis", synthesis_records},
                     {"intended_live_relative_path", "OpenWF/CustomScripts/Packages/" + std::string(kMissionPackageName) + "/" + kLiveLiteralRecipeFile},
                     {"requires", "bootstrapper LIVE_LITERALS_V1; older DLLs ignore the file (those values stay stock)"}};
    result.gate_log += "live-literal-core\nPASS sha256=" + std::string(kLiveLiteralCoreSha256) + "\n";
    result.gate_log += "live-literal-recipe\nPASS values=" + std::to_string(values.size()) + " masters=" + std::to_string(masters) +
                       " modules=" + std::to_string(stock_of.size()) + " extreme_syntheses=" + std::to_string(extreme_syntheses) +
                       " shipped_modules=" + std::to_string(synthesis_records.size()) + " recipe_groups=" + std::to_string(recipe_groups.size()) + "\n";
    return output;
}
