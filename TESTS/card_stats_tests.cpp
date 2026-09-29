#include "renovice/core.hpp"
#include <iostream>
#include <stdexcept>
int main() {
    using renovice::Json;
    const std::string source=R"(
local v9_1
v9_1 = 300
rank = function()
    if rank == 1 then
        v9_1 = 1500
    else
        v9_1 = 3500
    end
end
card = function()
    row = { Label = "/HEALTH", Value = nil }
    copy = v9_1
    row.Value = copy
    row2 = { Label = "/DAMAGE", Value = nil }
    result = CalculateDamage(v9_1)
    row2.Value = result
    row3 = { Label = "/BRANCH", Value = nil }
    if changed then
        temp = v9_1
    end
    row3.Value = temp
end
)";
    auto report=renovice::discover_card_stats(source,Json{{"/HEALTH","Health"},{"/DAMAGE","Damage"}},"test");
    auto& rows=report["rows"];
    if(rows.size()!=3 || rows[0]["label"]!="Health" || rows[0]["inputs"].size()!=2
        || rows[1]["status"]!="CALCULATED_OR_UNRESOLVED" || !rows[2]["inputs"].empty())
        throw std::runtime_error("Card direct-copy/branch/function-call boundaries failed");
    for(const auto& input:rows[0]["inputs"]) {
        auto token=source.substr(input["offset"].get<std::size_t>(),input["length"].get<std::size_t>());
        if(std::stod(token)!=input["original"].get<double>()) throw std::runtime_error("Incorrect editable span");
    }
    const auto unrelated=renovice::discover_card_stats("v1 = 1\nv1 = 2\nv1 = 3\n",Json::object(),"test");
    if(!unrelated["rows"].empty()) throw std::runtime_error("Hidden constants leaked into card stats");
    const auto frame=renovice::discover_card_stats("frame_1[20] = { Label = \"/DAMAGE\", Value = nil }\nframe_1[20].Value = frame_1[19]\n",Json::object(),"test");
    if(frame["rows"].size()!=1 || !frame["rows"][0]["inputs"].empty())
        throw std::runtime_error("Frame-backed card label must remain visible without an invented base binding");
    auto shadowed=source;
    shadowed.insert(shadowed.find("    row ="),"    local v9_1\n    v9_1 = 99\n");
    if(!renovice::discover_card_stats(shadowed,Json::object(),"test")["rows"][0]["inputs"].empty())
        throw std::runtime_error("Shadowed local leaked into editable root inputs");
    const auto masked=renovice::discover_card_stats(
        "--[[\nfake = { Label = \"/FAKE\", Value = 123 }\n]]\n"
        "text = [=[\nfake = { Label = \"/FAKE\", Value = 123 }\n]=]\n"+source,
        Json::object(),"test");
    if(masked["rows"].size()!=3 || masked["rows"][0]["inputs"].size()!=2)
        throw std::runtime_error("Comments/strings were treated as executable card definitions");
    auto reassigned=source;
    reassigned.insert(reassigned.find("    row.Value"),"    copy = ExternalValue()\n");
    if(!renovice::discover_card_stats(reassigned,Json::object(),"test")["rows"][0]["inputs"].empty())
        throw std::runtime_error("Reassigned value retained a stale root binding");
    std::cout<<"PASS card labels, direct base links, rank input spans, computed/branch rejection, hidden constants excluded\n";
    const std::string linked=R"(
local v9_1
local lib
lib = require("Lotus.Scripts.Libs.AbilitiesLib")
v9_1 = 100
base = function(level)
    if level == 1 then
        v9_1 = 10
    else
        v9_1 = 20
    end
end
modified = function()
    local initial
    initial = v9_1
    return initial
end
card = function()
    local row
    row = { Label = "/DURATION", Value = v9_1 }
end
GetAbilityUpgradeLevelInfo = card
activate = function(ability, owner)
    local bag
    local amount
    amount = modified()
    bag = {}
    bag.duration = amount
    lib.SetAbilityStats(ability, owner, bag)
end
ActivateAbility = activate
tick = function(ability, owner, control)
    local stats
    local duration
    stats = lib.GetAbilityStats(ability, owner)
    duration = (stats).duration
    control:GiveTemporaryImmunity(duration, 0)
end
Tick = tick
return
)";
    const auto links=[](const std::string& text) {
        return renovice::discover_automatic_card_links(text,renovice::discover_card_stats(text,Json::object(),"never-registered-body"));
    };
    const auto replace=[](std::string text,const std::string& before,const std::string& after) {
        auto pos=text.find(before);if(pos==std::string::npos)throw std::runtime_error("Missing mutation fixture");
        text.replace(pos,before.size(),after);return text;
    };
    auto automatic=links(linked);
    if(automatic["controls"].size()!=1 || automatic["controls"][0]["inputs"].size()!=3 || automatic["controls"][0]["operation"]!="scale")
        throw std::runtime_error("Generic card/shared-helper/stat-publication/getter/gameplay trace failed: "+automatic.dump());
    const auto reject=[&](const std::string& mutated,const char* description) {
        if(!links(mutated)["controls"].empty())throw std::runtime_error(description);
    };
    reject(replace(linked,"control:GiveTemporaryImmunity(duration, 0)","Print(duration)"),"Unused/display-only stat read was accepted as gameplay");
    reject(replace(linked,"bag.duration = amount","bag.duration = 20"),"Equal numbers were used as evidence of a shared source");
    reject(replace(linked,"bag.duration = amount","bag.duration = amount\n    bag = {}"),"Reset table retained a stale field link");
    reject(replace(linked,"bag.duration = amount","bag.duration = amount\n    Mutate(bag)"),"Unknown intervening call retained a field link");
    reject(replace(linked,"lib.SetAbilityStats(ability, owner, bag)","lib.SetAbilityStats(ability, owner, bag)\n    local other\n    other = {}\n    other.duration = ExternalValue()\n    lib.SetAbilityStats(ability, owner, other)"),"Unknown competing publication retained a field link");
    reject(replace(linked,"v9_1 = 10\n","v9_1 = ExternalValue()\n"),"Unknown base overwrite was accepted");
    reject(replace(linked,"initial = v9_1","initial = v9_1\n    initial = 20"),"Reassigned helper temporary retained old provenance");
    reject(replace(linked,"local amount","local amount\n    local modified"),"Shadowed helper resolved to a global function");
    reject(replace(linked,"Lotus.Scripts.Libs.AbilitiesLib","Other.Library"),"Unrelated same-named methods were treated as AbilitiesLib");
    reject(replace(linked,"Tick = tick","-- Tick is not exported"),"Unreachable getter/action proved a gameplay link");
    reject(replace(linked,"initial = v9_1","initial = (v9_1 * 0)"),"Zeroed expression was claimed dependent on base");
    reject(replace(linked,"initial = v9_1","initial = (v9_1 - v9_1)"),"Cancelled expression was claimed dependent on base");
    reject("--[=[\n"+linked+"\n]=]", "Long comment text was analysed as executable code");
    reject(replace(linked,"local duration","local duration\n    local v9_1"),"Shadowed stat was accepted");
    auto duplicated=replace(linked,"local row","local row\n    if level == 1 then\n        v9_1 = 10\n    else\n        v9_1 = 20\n    end");
    if(links(duplicated)["controls"][0]["inputs"].size()!=5)throw std::runtime_error("Duplicated rank assignments did not join the scale control");
    auto converted=replace(linked,"Value = v9_1","Value = (v9_1 * 100)");
    if(links(converted)["controls"].size()!=1)throw std::runtime_error("Literal card unit conversion lost its gameplay link");
    auto direct=replace(linked,"control:GiveTemporaryImmunity(duration, 0)","control:SetDamageRadius(v9_1)");
    direct=replace(direct,"bag.duration = amount","bag.duration = 20");
    if(links(direct)["controls"].size()!=1)throw std::runtime_error("Direct native setter should not require a stat-bag roundtrip");
    const auto packet=replace(linked,"control:GiveTemporaryImmunity(duration, 0)",
        "local packet\n    packet = Engine.RadialDamageData()\n    packet:SetBaseAmount(duration)\n    region:RadialDamage(packet)");
    if(links(packet)["controls"].size()!=1)throw std::runtime_error("Applied damage packet lost base provenance");
    reject(replace(packet,"region:RadialDamage(packet)","-- not applied"),"Unused damage packet claimed practical damage");
    reject(replace(packet,"region:RadialDamage(packet)","packet:SetBaseAmount(0)\n    region:RadialDamage(packet)"),"Overwritten packet amount retained stale link");
    std::cout<<"PASS automatic shared/duplicate base links, direct effects, applied packets, unit conversion and 16 counterexamples\n";
}
