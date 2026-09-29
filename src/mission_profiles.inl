// Build-specific mission bindings share the existing staging/export contract.
namespace {
Json mission_profile_record(const Json& project, const fs::path& editor_root) {
    if (project.at("mission_profile").at("build") != "2026.09.24.13.29")
        throw std::runtime_error("Unsupported mission build profile");
    const auto profile = Json::parse(read_text(editor_root / "REGISTRIES/mission_build_u44.json"));
    return profile.at("missions").at(project.at("mission_profile").at("id").get<std::string>());
}
std::vector<Diagnostic> validate_profile_mission(const Json& project, const fs::path& editor_root) {
    std::vector<Diagnostic> errors;
    try {
        const auto rec = mission_profile_record(project, editor_root);
        if (project.at("target").at("module_body_key") != rec.at("body_key") ||
            project.at("target").at("module_path") != rec.at("module_path"))
            throw std::runtime_error("Mission target does not match the verified build profile");
        const auto& values = project.at("mission_profile").at("values");
        if (values.size() != rec.at("parameters").size()) throw std::runtime_error("Unexpected mission parameter count");
        for (const auto& [name, limits] : rec.at("parameters").items()) {
            const double value = values.at(name).get<double>();
            if (!std::isfinite(value) || value < limits.at("minimum").get<double>() || value > limits.at("maximum").get<double>())
                throw std::runtime_error("Out-of-range mission parameter: " + name);
        }
        if (values.contains("minimum_total_time") && values.at("minimum_total_time").get<double>() > values.at("maximum_total_time").get<double>())
            throw std::runtime_error("Minimum total time exceeds maximum");
        for (const auto& p : rec.at("patches")) {
            const double v = values.at(p.at("value").get<std::string>()).get<double>();
            const double operand = p.value("inverse", false) ? p.at("numerator").get<double>() / v : v * p.at("numerator").get<double>() / p.at("denominator").get<double>();
            if (operand < 1 || operand > 32767 || std::floor(operand) != operand)
                throw std::runtime_error("Mission parameter must resolve to an exact positive whole-number operand: " + p.at("value").get<std::string>());
        }
        const bool replacement = !rec.at("patches").empty();
        if (rec.contains("metadata")) {
            const auto& metadata = rec.at("metadata");
            if (!values.contains(metadata.at("value").get<std::string>()) ||
                !std::regex_match(metadata.at("owner").get<std::string>(), std::regex("/Lotus/[A-Za-z0-9_/]+")) ||
                !std::regex_match(metadata.at("field").get<std::string>(), std::regex("Scripts\\.0\\.Script\\._[A-Za-z0-9_]+")))
                throw std::runtime_error("Invalid verified metadata binding");
        }
        const auto expected_mode = rec.contains("metadata") ? "MANAGED_MISSION_METADATA_PATCH" : replacement ? "MANAGED_MISSION_EXACT_REPLACEMENT" : project.at("mission_profile").at("id") == "survival" ? "MANAGED_LUA_CALL_ADDON" : "MANAGED_MISSION_ADDON";
        if (project.value("authoring_mode", "") != expected_mode)
            throw std::runtime_error("Mission artifact lane disagrees with the verified profile");
    } catch (const std::exception& e) { add(errors, Severity::error, "MISSION_BUILD_PROFILE", e.what()); }
    return errors;
}
}

BuildResult build_profile_mission(const Json& project, const fs::path& editor_root, const fs::path& staging_root, bool run_external_gates) {
    BuildResult result;
    result.diagnostics = validate_profile_mission(project, editor_root);
    if (has_errors(result.diagnostics)) return result;
    try {
        if (!run_external_gates) throw std::runtime_error("Current-build mission export requires all verification gates");
        const auto profile = Json::parse(read_text(editor_root / "REGISTRIES/mission_build_u44.json"));
        const auto rec = mission_profile_record(project, editor_root);
        const auto id = project.at("mission_profile").at("id").get<std::string>();
        const auto& values = project.at("mission_profile").at("values");
        const auto body = rec.at("body_key").get<std::string>();
        const auto workspace = editor_root.parent_path().parent_path().parent_path();
        const auto stock = workspace / profile.at("corpus").get<std::string>() / rec.at("file").get<std::string>();
        if (sha256_file(stock) != rec.at("sha256").get<std::string>()) throw std::runtime_error("Current mission stock hash mismatch");
        const auto toolchain = resolve_workspace_path(editor_root, "repos", "de_luau_toolchain");
        const auto compiler = toolchain / "bin/derecomp.exe";
        const bool replacement = !rec.at("patches").empty();
        const bool metadata = rec.contains("metadata");
        const auto hash_work = staging_root / ".hash-work";
        const auto build_hash = sha256_text(hash_work, project.dump() + rec.dump());
        result.generation_directory = staging_root / artifact_stem(project.at("id").get<std::string>()) / build_hash.substr(0,12);
        fs::create_directories(result.generation_directory / "artifacts");
        fs::create_directories(result.generation_directory / "source");
        result.project_snapshot = result.generation_directory / "ability_edit.json";
        write_text(result.project_snapshot, project.dump(2) + "\n");
        result.generated_source = result.generation_directory / "source" / (id + (replacement ? ".plan.json" : ".luau"));
        result.generated_bytecode = result.generation_directory / "artifacts" / (body + (replacement ? " (mission_" + id + "_timers_exact-replacement).lua_B" : ".mission_" + id + ".target.addon.lua_B"));
        result.manifest = result.generation_directory / "BUILD_MANIFEST.json";
        if (metadata) {
            result.generated_source = result.generation_directory / "source" / (id + ".plan.json");
            result.generated_bytecode = result.generation_directory / "artifacts" / (id + ".txt");
        }
        Json gates = Json::array();
        const auto gate = [&](const std::string& name, const std::string& arguments, const std::string& marker) {
            const auto process = run_process(quote_process_argument(compiler) + " " + arguments, toolchain);
            const bool pass = process.exit_code == 0 && contains_text(process.output, marker);
            result.gate_log += name + "\n" + process.output + "\n";
            gates.push_back({{"name",name},{"pass",pass},{"exit_code",process.exit_code}});
            if (!pass) throw std::runtime_error(name + " failed: " + process.output);
        };
        gates.push_back({{"name","current-stock-hash"},{"pass",true},{"exit_code",0}});
        if (metadata) {
            const auto& binding = rec.at("metadata");
            const auto number = values.at(binding.at("value").get<std::string>()).dump();
            const auto text = binding.at("owner").get<std::string>() + "\n    q|" +
                binding.at("field").get<std::string>() + "|" + number + "\n";
            write_text(result.generated_source, Json{{"binding",rec},{"values",values}}.dump(2));
            write_text(result.generated_bytecode, text);
            if (read_text(result.generated_bytecode) != text) throw std::runtime_error("Metadata artifact readback mismatch");
            gates.push_back({{"name","verified-metadata-binding-and-output-readback"},{"pass",true},{"exit_code",0}});
        } else if (replacement) {
            auto bytes = read_text(stock);
            const auto original = bytes;
            std::set<std::size_t> permitted;
            for (const auto& patch : rec.at("patches")) {
                const auto offset = patch.at("offset").get<std::size_t>();
                const auto expected = patch.at("expected").get<std::vector<unsigned int>>();
                const bool number_constant = patch.value("kind", "instruction") == "number_constant";
                const std::size_t width = number_constant ? 8 : 4;
                if (expected.size()!=width || offset>bytes.size() || width>bytes.size()-offset) throw std::runtime_error("Invalid patch extent");
                if (number_constant && (offset==0 || static_cast<unsigned char>(bytes[offset-1])!=2)) throw std::runtime_error("Expected native numeric constant tag");
                for (std::size_t n=0;n<width;++n)
                    if (static_cast<unsigned char>(bytes[offset+n]) != expected[n]) throw std::runtime_error("Verified instruction preimage changed");
                const auto value=values.at(patch.at("value").get<std::string>()).get<double>();
                const int operand=static_cast<int>(patch.value("inverse",false) ? patch.at("numerator").get<double>()/value : value*patch.at("numerator").get<double>()/patch.at("denominator").get<double>());
                if (number_constant) {
                    const auto bits=std::bit_cast<std::uint64_t>(static_cast<double>(operand));
                    for (std::size_t n=0;n<8;++n) bytes[offset+n]=static_cast<char>((bits>>(8*n))&255);
                } else {
                bytes[offset]=static_cast<char>(0x08); // U44 LOADN, from the verified opcode profile.
                bytes[offset+1]=static_cast<char>(patch.at("register").get<int>());
                bytes[offset+2]=static_cast<char>(operand&255);
                bytes[offset+3]=static_cast<char>((operand>>8)&255);
                }
                for (std::size_t n=0;n<width;++n) permitted.insert(offset+n);
            }
            for (std::size_t n=0;n<bytes.size();++n)
                if (original[n]!=bytes[n] && !permitted.contains(n)) throw std::runtime_error("Unexpected bytecode change");
            write_text(result.generated_source, Json{{"binding",rec},{"values",values}}.dump(2));
            write_text(result.generated_bytecode,bytes);
            gates.push_back({{"name","exact-instruction-preimages-and-allowed-diff"},{"pass",true},{"exit_code",0}});
        } else {
            // Reuse the existing verified addon generator and its capture contracts.
            Json legacy=project;
            legacy.erase("mission_profile");
            legacy["target"]["module_body_key"]=rec.at("legacy_body_key");
            if (id=="survival") {
                legacy["addon_generation"]["reward_interval_seconds"]=values.at("reward_interval");
                legacy["addon_generation"]["life_support_per_pickup_seconds"]=values.at("pickup_life_support");
                legacy["addon_generation"]["reward_progress_per_pickup_seconds"]=values.at("pickup_reward_progress");
            } else {
                legacy["addon_generation"]["scoring_speed_multiplier"]=values.at("scoring_speed_multiplier");
            }
            auto source=generate_target_addon_source(legacy,editor_root);
            if (id=="survival") {
                for (const auto& pair : std::vector<std::pair<std::string,std::string>>{{"prototype == 64","prototype == 67"},{"[64] =","[67] ="},{"proto64","proto67"},{"prototype 64","prototype 67"}}) {
                    std::size_t pos=0;
                    while ((pos=source.find(pair.first,pos))!=std::string::npos) { source.replace(pos,pair.first.size(),pair.second);pos+=pair.second.size(); }
                }
            }
            source="-- Build profile 2026.09.24.13.29; exact target " + body + "\n"+source;
            write_text(result.generated_source,source);
            const auto canonical=result.generation_directory/"source/verification-u43.lua_B";
            gate("source-compile", "recompile "+quote_process_argument(result.generated_source)+" "+quote_process_argument(canonical),"re-parses=yes");
            gate("source-plan", "plan-verify "+quote_process_argument(canonical),"failures=0");
            gate("u44-compile", "recompile-u44 "+quote_process_argument(result.generated_source)+" "+quote_process_argument(result.generated_bytecode)+" "+quote_process_argument(toolchain/"profiles/u44/name-map.tsv"),"re-parses=yes");
        }
        if (!metadata) gate("de-roundtrip","de-roundtrip "+quote_process_argument(result.generated_bytecode),"FULL BODY identical: True");
        write_text(result.generation_directory/"BUILD_GATES.log",result.gate_log);
        const Json manifest{{"format","RENOVICE_ABILITY_EDITOR_BUILD_V1"},{"package_type",metadata?"METADATA_PATCH":replacement?"NATIVE_REPLACEMENT":"TARGET_ADDON"},{"status","STAGED_PASS"},{"project_id",project.at("id")},{"build_sha256",build_hash},{"source",{{"path",fs::relative(result.generated_source,result.generation_directory).generic_string()},{"sha256",sha256_file(result.generated_source)}}},{"artifact",{{"path",fs::relative(result.generated_bytecode,result.generation_directory).generic_string()},{"sha256",sha256_file(result.generated_bytecode)},{"size",fs::file_size(result.generated_bytecode)}}},{"stock_artifact",{{"path",stock.string()},{"sha256",rec.at("sha256")}}},{"intended_live_relative_path",(metadata?std::string("OpenWF/Metadata Patches/"):std::string("OpenWF/CustomScripts/")+(replacement?"":"Inject/"))+result.generated_bytecode.filename().string()},{"live_write_performed",false},{"gates",gates},{"diagnostics",Json::array()}};
        write_text(result.manifest,manifest.dump(2)+"\n");
        result.success=true;
    } catch(const std::exception& e) {
        add(result.diagnostics,Severity::error,"MISSION_BUILD_PROFILE",e.what());
        if (!result.generation_directory.empty()) write_text(result.generation_directory/"BUILD_GATES.log",result.gate_log+e.what());
    }
    return result;
}
