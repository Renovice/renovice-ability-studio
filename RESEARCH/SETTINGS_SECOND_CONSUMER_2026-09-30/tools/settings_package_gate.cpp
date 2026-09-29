// Offline gate: the Octavia and Frost packages through the EXACT bootstrapper
// ADDON_SETTINGS_V1 code (renovice/packages.cpp + settings_core.hpp +
// settings_ui_core.hpp, compiled with RENOVICE_PACKAGES_OFFLINE_GATE and the
// same stub providers as RENOVICE_TOOLCHAIN/settings/verify_addon_settings.cpp).
// Nothing in the bootstrapper is modified; the sources are an export of a pinned
// revision. Runs on a temporary CustomScripts tree; never touches a game folder.
//
// Usage: settings_package_gate <work dir> <staged Packages dir> <settings example dir>
#include <algorithm>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <map>
#include <string>
#include <string_view>
#include <vector>

#include "renovice/config.hpp"
#include "renovice/packages.hpp"
#include "renovice/script_control.hpp"
#include "renovice/settings_core.hpp"
#include "renovice/settings_ui_core.hpp"

namespace gate
{
std::filesystem::path root;
std::filesystem::path inject;
std::vector<std::string> log_lines;
std::map<std::string, bool> policy;
}

namespace renovice::config
{
const std::filesystem::path& custom_scripts_directory() noexcept { return gate::root; }
const std::filesystem::path& injection_directory() noexcept { return gate::inject; }
void log(std::string_view message) noexcept
{
	try { gate::log_lines.emplace_back(message); } catch (...) {}
}
}

namespace renovice::script_control
{
bool candidate_enabled(std::string_view id)
{
	const auto found = gate::policy.find(std::string(id));
	return found == gate::policy.end() || found->second;
}
}

namespace
{
using namespace renovice;
bool pass = true;

void check(bool result, const std::string& name)
{
	std::cout << (result ? "PASS" : "FAIL") << '\t' << name << '\n';
	pass &= result;
}

std::string read_text(const std::filesystem::path& path)
{
	std::ifstream input(path, std::ios::binary);
	return std::string((std::istreambuf_iterator<char>(input)), std::istreambuf_iterator<char>());
}

void write_text(const std::filesystem::path& path, std::string_view text)
{
	std::filesystem::create_directories(path.parent_path());
	std::ofstream output(path, std::ios::binary | std::ios::trunc);
	output.write(text.data(), static_cast<std::streamsize>(text.size()));
}

std::string replace_once(std::string text, std::string_view from, std::string_view to)
{
	const auto at = text.find(from);
	if (at == std::string::npos) return "<replace-failed>";
	text.replace(at, from.size(), to);
	return text;
}

bool logged(std::string_view needle)
{
	return std::any_of(gate::log_lines.begin(), gate::log_lines.end(),
		[&](const std::string& line) { return line.find(needle) != std::string::npos; });
}

struct Fixture
{
	std::string folder;       // Packages/<folder>
	std::string member;       // the single target-addon member
	std::string key;          // its target key
	std::string id;           // the declared value id
	std::string group;        // its group
	double example_value;     // value in the example Settings/<folder>.json
	double stock;             // declared stock
	double above_max;         // an out-of-range value
};

std::filesystem::path packages_source;
std::filesystem::path examples;
std::filesystem::path work_root;

// Fresh CustomScripts tree holding the named packages and, optionally, their
// Settings files; then one startup scan.
const packages::Package* scan(const std::vector<std::string>& folders,
	const std::map<std::string, std::string>& settings, std::shared_ptr<const packages::Snapshot>& keep)
{
	std::error_code ec;
	std::filesystem::remove_all(work_root, ec);
	gate::root = work_root / "CustomScripts";
	gate::inject = gate::root / "Inject";
	std::filesystem::create_directories(gate::inject);
	for (const auto& folder : folders)
	{
		std::filesystem::create_directories(gate::root / "Packages" / folder);
		std::filesystem::copy(packages_source / folder, gate::root / "Packages" / folder,
			std::filesystem::copy_options::recursive, ec);
	}
	for (const auto& [folder, text] : settings)
		write_text(gate::root / "Settings" / settings::values_file_name(folder), text);
	gate::log_lines.clear();
	if (!packages::initialise()) return nullptr;
	keep = packages::candidate();
	for (const auto& package : keep->packages)
		if (package.folder == folders.front()) return &package;
	return nullptr;
}

const packages::Member* only_member(const packages::Package* package)
{
	return package != nullptr && package->members.size() == 1 ? &package->members.front() : nullptr;
}

void print_log(std::string_view label)
{
	for (const auto& line : gate::log_lines) std::cout << "LOG\t" << label << '\t' << line << '\n';
}

void package_cases(const Fixture& f)
{
	const auto example = read_text(examples / (f.folder + ".json"));
	check(!example.empty(), f.folder + ": example Settings file present");
	std::shared_ptr<const packages::Snapshot> keep;

	// 1. No Settings file: package accepted, declarations valid, delivery empty
	//    (context.settings = {} -> the addon runs stock).
	auto* package = scan({f.folder}, {}, keep);
	auto* member = only_member(package);
	print_log(f.folder + "/absent");
	check(package != nullptr && package->structurally_valid && package->accepted && package->reason.empty(),
		f.folder + ": package accepted by the loader rules");
	check(package != nullptr && package->id == "package:" + script_control::ascii_lower(f.folder),
		f.folder + ": state id package:" + script_control::ascii_lower(f.folder));
	check(package != nullptr && package->declarations != nullptr && package->settings_reason.empty()
		&& package->declarations->values.size() == 1 && package->declarations->groups.size() == 1
		&& package->declarations->values.front().id == f.id
		&& package->declarations->values.front().group == f.group
		&& package->declarations->values.front().stock == f.stock,
		f.folder + ": declarations accepted by the strict parser (1 value, 1 group, stock "
			+ settings_ui::display_number(f.stock) + ")");
	check(member != nullptr && member->filename == f.member && member->kind == packages::MemberKind::TargetAddon
		&& packages::key_text(member->key) == f.key && member->staged,
		f.folder + ": single-key target-addon member staged (" + f.key + ")");
	check(member != nullptr && member->delivery != nullptr && member->delivery->values.empty(),
		f.folder + ": no Settings file -> delivery with 0 values (context.settings = {}, stock)");
	check(logged("RENOVICE SETTINGS PACKAGE trigger=startup package=" + f.folder
			+ " declarations=1 groups=1 file=absent use_stock=0 effective=0 rejected=0 unknown_entries=0 members_staged=1/1"),
		f.folder + ": exact summary line, file absent");

	// 2. The example file: exactly the one value is delivered.
	package = scan({f.folder}, {{f.folder, example}}, keep);
	member = only_member(package);
	print_log(f.folder + "/example");
	check(member != nullptr && member->delivery != nullptr && member->delivery->values.size() == 1
		&& member->delivery->values[0].id == f.id
		&& member->delivery->values[0].value == static_cast<float>(f.example_value)
		&& member->delivery->values[0].stock == static_cast<float>(f.stock)
		&& member->delivery->identity.rfind("settings-v1:", 0) == 0,
		f.folder + ": example file delivers { " + f.id + " = { enabled = true, value = "
			+ settings_ui::display_number(f.example_value) + ", stock = " + settings_ui::display_number(f.stock) + " } }");
	const std::string example_identity = member != nullptr && member->delivery ? member->delivery->identity : "";
	check(logged("file=valid use_stock=0 effective=1 rejected=0"), f.folder + ": summary effective=1");

	// 3. Everything that must fall back to stock (delivery without the value).
	const std::vector<std::pair<std::string, std::string>> stock_cases{
		{"use_stock=true", replace_once(example, "\"use_stock\": false", "\"use_stock\": true")},
		{"enabled=false", replace_once(example, "\"enabled\": true", "\"enabled\": false")},
		{"group off", replace_once(example, "\"" + f.group + "\": true", "\"" + f.group + "\": false")},
		{"value above max", replace_once(example, "\"value\": " + settings_ui::display_number(f.example_value),
			"\"value\": " + settings_ui::display_number(f.above_max))},
		{"recorded stock differs", replace_once(example, "\"stock\": " + settings_ui::display_number(f.stock),
			"\"stock\": 7")},
		{"malformed file", example.substr(0, example.size() / 2)},
	};
	for (const auto& [label, text] : stock_cases)
	{
		package = scan({f.folder}, {{f.folder, text}}, keep);
		member = only_member(package);
		check(text != "<replace-failed>" && package != nullptr && package->accepted && member != nullptr
			&& member->staged && member->delivery != nullptr && member->delivery->values.empty()
			&& member->delivery->identity != example_identity,
			f.folder + ": " + label + " -> stock, package still loads, identity changes (forces cleanup+activate)");
	}
	check(logged("RENOVICE SETTINGS FILE REJECT trigger=startup package=" + f.folder),
		f.folder + ": malformed file logs FILE REJECT (package-local)");

	// 4. Install rule: an enabled loose copy of the same addon conflicts; the
	//    package (sorted after loose files) fails closed. Disabling the loose row
	//    (or removing the file) resolves it.
	std::error_code ec;
	package = scan({f.folder}, {{f.folder, example}}, keep);
	std::filesystem::copy_file(packages_source / f.folder / f.member, gate::inject / f.member, ec);
	gate::log_lines.clear();
	packages::initialise();
	keep = packages::candidate();
	package = nullptr;
	for (const auto& candidate : keep->packages) if (candidate.folder == f.folder) package = &candidate;
	check(package != nullptr && !package->accepted && package->reason.find(
			"conflict kind=target key=" + f.key + " holder=loose:Inject/" + f.member) != std::string::npos,
		f.folder + ": with the loose copy still enabled the package fails closed (" + (package ? package->reason : "") + ")");
	gate::policy["target-addon:" + script_control::ascii_lower(f.member)] = false;
	gate::log_lines.clear();
	packages::initialise();
	keep = packages::candidate();
	package = nullptr;
	for (const auto& candidate : keep->packages) if (candidate.folder == f.folder) package = &candidate;
	check(package != nullptr && package->accepted, f.folder + ": loose copy disabled in ScriptStates -> package accepted");
	gate::policy.clear();
}

void both_and_ui(const Fixture& octavia, const Fixture& frost)
{
	std::shared_ptr<const packages::Snapshot> keep;
	const auto octavia_text = read_text(examples / "Octavia.json");
	const auto frost_text = read_text(examples / "Frost.json");
	// The installed loose root replacement for the same BardMusic key claims a
	// REPLACEMENT key, not a target key: no conflict with the Octavia package.
	scan({octavia.folder, frost.folder}, {{octavia.folder, octavia_text}, {frost.folder, frost_text}}, keep);
	write_text(gate::root / (octavia.key + " (Octavia Mallet No Cover exact flags).lua_B"), "\x09\x03 replacement stub");
	gate::log_lines.clear();
	packages::initialise();
	keep = packages::candidate();
	std::size_t accepted = 0;
	for (const auto& candidate : keep->packages) accepted += candidate.accepted ? 1 : 0;
	print_log("both");
	check(accepted == 2, "both packages accepted together, next to the loose Mallet root replacement (same key, other lane)");

	// SCRIPT SETTINGS page model for both packages (flat default layout).
	using namespace settings_ui;
	std::vector<PackageView> views;
	for (const auto* fixture : {&octavia, &frost})
	{
		const packages::Package* found = nullptr;
		for (const auto& candidate : keep->packages) if (candidate.folder == fixture->folder) found = &candidate;
		PackageView view;
		view.folder = fixture->folder;
		view.display = found ? found->display : fixture->folder;
		view.declarations = found ? found->declarations.get() : nullptr;
		view.members.push_back(MemberView{fixture->member, "", "member:" + script_control::ascii_lower(fixture->folder)
			+ "/" + script_control::ascii_lower(fixture->member), true, false});
		const auto error = settings::parse_values_file(read_text(examples / (fixture->folder + ".json")),
			"package:" + script_control::ascii_lower(fixture->folder), view.state);
		check(error.empty(), fixture->folder + ": example file parses (" + error + ")");
		views.push_back(std::move(view));
	}
	const auto page = build_flat_page(views);
	auto row = [&](std::string_view setting) -> const Row*
	{
		for (const auto& candidate : page.rows) if (candidate.setting == setting) return &candidate;
		return nullptr;
	};
	for (const auto& r : page.rows)
	{
		std::cout << "ROW\t" << row_kind_name(r.kind) << "\t" << r.label << "\t" << r.setting
			<< "\ttooltip(" << r.tooltip.size() << ")=" << r.tooltip << '\n';
	}
	bool budget = true;
	for (const auto& r : page.rows)
	{
		budget &= r.label.size() <= (r.kind == RowKind::Title ? maximum_title_label : maximum_row_label);
		budget &= r.tooltip.size() <= maximum_tooltip;
	}
	check(budget, "every label and tooltip within the UI budget");
	const auto* mallet_custom = row("custom:octavia/" + octavia.id);
	const auto* mallet_value = row("value:octavia/" + octavia.id);
	const auto* ice_custom = row("custom:frost/" + frost.id);
	const auto* ice_value = row("value:frost/" + frost.id);
	check(mallet_custom && mallet_custom->kind == RowKind::Checkbox && mallet_custom->label == "Custom Forced threat level"
		&& mallet_custom->value, "Mallet: CHECKBOX \"Custom Forced threat level\" ticked by the example");
	check(mallet_value && mallet_value->kind == RowKind::InputCount && mallet_value->label == "Forced threat level (stock 5)"
		&& mallet_value->count == 5.0 && mallet_value->minimum == 0.0 && mallet_value->maximum == 5.0 && !mallet_value->locked,
		"Mallet: INPUTCOUNT \"Forced threat level (stock 5)\" 0..5, value 5");
	check(mallet_value && mallet_value->tooltip.find("Unticked: the game's dynamic level") != std::string::npos
		&& mallet_value->tooltip.find("Ticked: always this level.") != std::string::npos,
		"Mallet: tooltip carries the full dynamic-stock explanation (not cut)");
	check(ice_custom && ice_custom->kind == RowKind::Checkbox && ice_custom->label == "Custom Bonus per Cold stack"
		&& ice_custom->value, "Ice Wave: CHECKBOX \"Custom Bonus per Cold stack\" ticked by the example");
	check(ice_value && ice_value->kind == RowKind::InputBox && ice_value->label == "Bonus per Cold stack (stock 0x)"
		&& ice_value->content == "50" && ice_value->minimum == 0.0 && ice_value->maximum == 100.0 && ice_value->validate,
		"Ice Wave: validated INPUTBOX \"Bonus per Cold stack (stock 0x)\" 0..100, value 50");
	check(ice_value && ice_value->tooltip.find("the addon changes nothing.") != std::string::npos,
		"Ice Wave: tooltip carries the full scope (not cut)");
	check(row("group:octavia/mallet") && row("group:frost/ice_wave") && row("package:octavia") && row("package:frost")
		&& row("stock:octavia") && row("stock:frost") && !row("member:octavia/" + script_control::ascii_lower(octavia.member)),
		"package, Use stock values and section switches present; no member row for a one-member package");
}
}

int main(int argc, char** argv)
{
	if (argc != 4)
	{
		std::cerr << "usage: settings_package_gate <work dir> <staged Packages dir> <settings example dir>\n";
		return 2;
	}
	work_root = argv[1];
	packages_source = argv[2];
	examples = argv[3];
	const Fixture octavia{"Octavia", "ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B",
		"ec368d4901690a15", "mallet.threat_level", "mallet", 5.0, 5.0, 6.0};
	const Fixture frost{"Frost", "8fba3a28f8fef624.IceWaveColdStackDamage.target.addon.lua_B",
		"8fba3a28f8fef624", "ice_wave.bonus_per_cold_stack", "ice_wave", 50.0, 0.0, 101.0};
	package_cases(octavia);
	package_cases(frost);
	both_and_ui(octavia, frost);
	std::cout << (pass ? "SETTINGS PACKAGE GATE PASS" : "SETTINGS PACKAGE GATE FAIL") << '\n';
	return pass ? 0 : 1;
}
