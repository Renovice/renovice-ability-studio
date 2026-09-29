#include "renovice/core.hpp"
#include <algorithm>
#include <cmath>
#include <map>
#include <regex>
#include <set>
#include <sstream>

namespace renovice {
namespace {
// A deliberately bounded analysis of the renderer's assignment form. It is
// not a Lua interpreter. Unknown expressions and conflicting reaching values
// have no provenance; they cannot produce editable controls.
std::string trim(std::string s) {
    auto a=s.find_first_not_of(" \r\n\t");
    return a==std::string::npos?"":s.substr(a,s.find_last_not_of(" \r\n\t")-a+1);
}
std::vector<std::string> split(const std::string& s,char delimiter) {
    std::vector<std::string> out;int depth=0;char quote=0;std::size_t start=0;
    for(std::size_t i=0;i<s.size();++i) {
        char c=s[i];
        if(quote) { if(c=='\\') ++i;else if(c==quote) quote=0;continue; }
        if(c=='"'||c=='\'') {quote=c;continue;}
        if(c=='('||c=='['||c=='{') ++depth;
        if(c==')'||c==']'||c=='}') --depth;
        if(depth==0 && c==delimiter) {out.push_back(trim(s.substr(start,i-start)));start=i+1;}
    }
    out.push_back(trim(s.substr(start)));return out;
}
std::string unparen(std::string s) {
    s=trim(s);
    while(s.size()>1 && s.front()=='(' && s.back()==')') {
        int depth=0;bool whole=true;
        for(std::size_t i=0;i<s.size();++i) {if(s[i]=='(')++depth;if(s[i]==')')--depth;if(depth==0 && i+1<s.size()){whole=false;break;}}
        if(!whole)break;
        s=trim(s.substr(1,s.size()-2));
    }
    return s;
}
struct Def {std::string expression;int result=0;int line=0;};
struct Fn {std::string name;std::set<std::string> locals;std::map<std::string,std::vector<Def>> defs;std::vector<std::pair<int,std::string>> lines;std::vector<std::vector<std::string>> returns;};
struct Value {
    std::string kind,name;
    bool operator==(const Value&) const = default;
};
const std::regex slot(R"(^[A-Za-z_][A-Za-z0-9_]*(?:\[[0-9]+\])?$)");
const std::regex numeric(R"(^-?(?:[0-9]+(?:\.[0-9]+)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?$)");
const std::regex field(R"(^(.+)\.([A-Za-z_][A-Za-z0-9_]*)$)");
// Finds the outer call, without mistaking parentheses around a receiver for
// argument parentheses. Quoted strings never become identifiers.
bool call(const std::string& text,std::string& callee,std::vector<std::string>& args) {
    auto s=unparen(text);if(s.empty()||s.back()!=')')return false;
    int depth=0;char quote=0;std::size_t opening=std::string::npos;
    for(std::size_t i=0;i<s.size();++i) {
        char c=s[i];if(quote){if(c=='\\')++i;else if(c==quote)quote=0;continue;}
        if(c=='"'||c=='\''){quote=c;continue;}
        if(c=='('){if(depth==0)opening=i;++depth;}
        if(c==')'){--depth;if(depth==0 && i+1==s.size() && opening>0 && opening!=std::string::npos){callee=trim(s.substr(0,opening));args=split(s.substr(opening+1,i-opening-1),',');if(args.size()==1 && args[0].empty())args.clear();return true;}}
    }
    return false;
}
struct Analysis {
    Fn global;
    std::map<std::string,Fn> functions;
    std::set<std::string> roots;
    std::map<std::string,std::string> stat_roots;
    std::map<std::string,std::set<std::string>> calls;
    bool valid=true;

    explicit Analysis(const std::string& source,const Json& report) {
        global.name="<module>";
        for(const auto& row:report.at("rows")) if(!row.at("variable").get<std::string>().empty()) roots.insert(row.at("variable"));
        std::istringstream input(source);std::string line;Fn* fn=&global;int n=0;
        const std::regex begin(R"(^([A-Za-z_][A-Za-z0-9_]*) = function\(([^)]*)\)\r?$)");
        const std::regex assignment(R"(^\s*(?:local\s+)?(.+?)\s+=\s+(.+?)\s*$)");
        const std::regex long_string(R"(\[=*\[)");
        while(std::getline(input,line)) {
            ++n;auto t=trim(line);std::smatch m;
            if(std::regex_search(t,long_string)) {valid=false;continue;}
            if(t.starts_with("--")||t.empty())continue;
            char quote=0;
            for(std::size_t i=0;i<line.size();++i) {
                if(quote){if(line[i]=='\\')++i;else if(line[i]==quote)quote=0;}
                else if(line[i]=='"'||line[i]=='\'')quote=line[i];
                else if(line.compare(i,2,"--")==0){line.resize(i);break;}
            }
            if(quote){valid=false;continue;}
            t=trim(line);
            if(std::regex_match(line,m,begin)) {
                if(fn!=&global || functions.contains(m[1])){valid=false;continue;}
                auto name=m[1].str();functions[name].name=name;fn=&functions[name];
                for(const auto& parameter:split(m[2],','))if(!parameter.empty())fn->locals.insert(parameter);
                continue;
            }
            if((line=="end"||line=="end\r") && fn!=&global){fn=&global;continue;}
            if(t.find("function(")!=std::string::npos || t.find("function (")!=std::string::npos){valid=false;continue;}
            fn->lines.emplace_back(n,t);
            if(t.starts_with("local "))for(auto local:split(t.substr(6,t.find('=')==std::string::npos?std::string::npos:t.find('=')-6),','))fn->locals.insert(trim(local));
            if(t=="return"||t.starts_with("return ")) {fn->returns.push_back(split(t.size()>6?t.substr(7):"",','));continue;}
            if(std::regex_match(line,m,assignment)) {
                auto left=split(m[1],','),right=split(m[2],',');
                for(std::size_t i=0;i<left.size();++i) {
                    if(!std::regex_match(left[i],slot) && !std::regex_match(left[i],field))continue;
                    if(right.size()==1) fn->defs[left[i]].push_back({right[0],static_cast<int>(i),n});
                    else if(i<right.size()) fn->defs[left[i]].push_back({right[i],0,n});
                }
            }
        }
        if(fn!=&global)valid=false;
    }

    Value resolve(Fn& fn,std::string expression,int result=0,std::set<std::string> seen={}) {
        expression=unparen(expression);
        if(result>0) {std::string target;std::vector<std::string> arguments;if(!call(expression,target,arguments))return {};}
        const auto key=fn.name+":"+expression+":"+std::to_string(result);
        if(seen.size()>100 || !seen.insert(key).second)return {};
        if(roots.contains(expression) && (&fn==&global || !fn.locals.contains(expression)))return {"root",expression};
        if(functions.contains(expression) && (&fn==&global || !fn.locals.contains(expression)) && !fn.defs.contains(expression))return {"function",expression};
        if(expression=="require" && !fn.locals.contains(expression) && !global.defs.contains(expression))return {"builtin","require"};
        if(expression=="Engine.UpgradedValue")return {"builtin","upgraded"};
        if(std::regex_match(expression,slot)) {
            auto* owner=&fn;
            if(!fn.defs.contains(expression)) {if(fn.locals.contains(expression))return {};owner=&global;}
            if(!owner->defs.contains(expression))return {};
            Value value;bool first=true;
            for(const auto& d:owner->defs.at(expression)) {
                auto next=resolve(*owner,d.expression,d.result,seen);
                if(next.kind.empty() || (!first && !(next==value)))return {};
                value=next;first=false;
            }
            return value;
        }
        std::string callee;std::vector<std::string> args;
        if(call(expression,callee,args)) {
            // Known value-preserving engine wrappers; arbitrary calls are not
            // assumed to return, or even use, their arguments.
            auto colon=callee.rfind(':');
            if(colon!=std::string::npos) {
                const auto method=callee.substr(colon+1);
                if((method=="GetModifiedValue"||method=="GetBaseValue") && args.empty())return resolve(fn,callee.substr(0,colon),0,seen);
                if(method=="GetUpgradeModifiedValue" && args.size()==4)return resolve(fn,args[0],0,seen);
                return {};
            }
            const auto target=resolve(fn,callee,0,seen);
            if(target==Value{"builtin","require"} && args.size()==1 && args[0]=="\"Lotus.Scripts.Libs.AbilitiesLib\"")return {"module","AbilitiesLib"};
            if(target==Value{"builtin","upgraded"} && args.size()==1)return resolve(fn,args[0],0,seen);
            if(target==Value{"api","GetAbilityStats"} && args.size()==2)return {"stats","AbilitiesLib"};
            if(target.kind=="function") {
                calls[fn.name].insert(target.name);
                auto& body=functions.at(target.name);Value value;bool first=true;
                for(const auto& returns:body.returns) {
                    if(result<0 || static_cast<std::size_t>(result)>=returns.size())return {};
                    auto next=resolve(body,returns[result],0,seen);
                    if(next.kind.empty() || (!first && !(next==value)))return {};
                    value=next;first=false;
                }
                return value;
            }
            return {};
        }
        std::smatch m;
        if(std::regex_match(expression,m,field)) {
            auto receiver=resolve(fn,m[1],0,seen);auto member=m[2].str();
            if(receiver==Value{"module","AbilitiesLib"} && (member=="SetAbilityStats"||member=="GetAbilityStats"))return {"api",member};
            if(receiver.kind=="stats")return stat_roots.contains(member)?Value{"root",stat_roots.at(member)}:Value{"stat",member};
        }
        // Simple arithmetic is accepted only when every nonnumeric operand
        // derives from the same root. External/other-stat operands reject.
        for(char op:std::string("+-*/")) {
            auto parts=split(expression,op);if(parts.size()<2)continue;
            Value value;int variables=0;
            for(std::size_t i=0;i<parts.size();++i) {
                auto part=parts[i];
                if(std::regex_match(part,numeric)) {
                    if((op=='*'||op=='/') && std::stod(part)==0)return {};
                    continue;
                }
                auto next=resolve(fn,part,0,seen);
                if(next.kind!="root" || ++variables>1 || (op=='/' && i!=0))return {};
                value=next;
            }
            return value;
        }
        return {};
    }
    // Only direct local/table aliases qualify for a published stat bag. Fields
    // must be written in the same straight-line region before SetAbilityStats.
    std::string table_slot(Fn& fn,std::string s,std::set<std::string> seen={}) {
        s=unparen(s);if(!std::regex_match(s,slot)||!seen.insert(s).second)return {};
        if(!fn.defs.contains(s))return {};
        const auto& ds=fn.defs.at(s);
        if(ds.size()==1 && std::regex_match(unparen(ds[0].expression),slot))return table_slot(fn,ds[0].expression,seen);
        return s;
    }
    bool straight(Fn& fn,int from,int to) {
        for(const auto& [line,t]:fn.lines)if(line>from && line<to) {
            if(t=="end"||t=="else"||t.starts_with("if ")||t.starts_with("elseif ")||t.starts_with("while ")||t.starts_with("for ")||t.starts_with("return")||t.starts_with("cfg_"))return false;
            auto rhs=t;auto assignment=rhs.find(" = ");if(assignment!=std::string::npos)rhs=rhs.substr(assignment+3);
            std::string callee;std::vector<std::string> args;if(call(rhs,callee,args))return false;
        }
        return true;
    }
};
}

Json discover_automatic_card_links(const std::string& source,const Json& report) {
    Analysis a(source,report);Json controls=Json::array(),rejections=Json::array();
    if(!a.valid)return {{"controls",controls},{"rejections",Json::array({"Unsupported source structure"})}};
    const auto export_function=[&](const std::string& name) {return a.resolve(a.global,name);};
    const auto activation=export_function("ActivateAbility");
    const auto card=export_function("GetAbilityUpgradeLevelInfo");
    if(activation.kind!="function" || card.kind!="function")return {{"controls",controls},{"rejections",Json::array({"Missing native card/activation export"})}};
    struct Publish {std::string function,root,field;int line;};
    std::vector<Publish> published;
    // Include calls used in assignments in the call graph, not only standalone
    // calls; otherwise card-only helper reads could be mistaken for gameplay.
    for(auto& [name,fn]:a.functions)for(const auto& [left,defs]:fn.defs)for(const auto& d:defs) {
        (void)left;std::string callee;std::vector<std::string> args;
        if(call(d.expression,callee,args)){auto target=a.resolve(fn,callee);if(target.kind=="function")a.calls[name].insert(target.name);}
    }
    // Summaries only certify a shared root, never assign meaning from a value.
    for(auto& [name,fn]:a.functions) {
        for(const auto& [line,text]:fn.lines) {
            auto t=text;if(t.starts_with("do ") && t.ends_with(" end"))t=t.substr(3,t.size()-7);
            std::string callee;std::vector<std::string> args;
            if(!call(t,callee,args))continue;
            auto target=a.resolve(fn,callee);
            if(target.kind=="function")a.calls[name].insert(target.name);
            if(target!=Value{"api","SetAbilityStats"} || args.size()!=3)continue;
            auto table=a.table_slot(fn,args[2]);if(table.empty())continue;
            for(auto& [left,defs]:fn.defs) {
                if(!left.starts_with(table+"."))continue;
                // Duplicate field writes would require a reaching-definition
                // proof. Do not choose whichever happens to be last in text.
                if(defs.size()!=1 || defs[0].line>=line || !a.straight(fn,defs[0].line,line)) {
                    published.push_back({name,"",left.substr(table.size()+1),line});continue;
                }
                if(std::any_of(fn.defs.at(table).begin(),fn.defs.at(table).end(),[&](const Def& d){return d.line>defs[0].line && d.line<line;})) {
                    published.push_back({name,"",left.substr(table.size()+1),line});continue;
                }
                auto value=a.resolve(fn,defs[0].expression);
                published.push_back({name,value.kind=="root"?value.name:"",left.substr(table.size()+1),line});
            }
        }
    }
    const auto reachable=[&](const std::string& start) {
        std::set<std::string> reached;std::vector<std::string> pending{start};
        while(!pending.empty()){auto n=pending.back();pending.pop_back();if(!reached.insert(n).second)continue;for(const auto& child:a.calls[n])pending.push_back(child);}
        return reached;
    };
    auto gameplay=reachable(activation.name);
    auto card_functions=reachable(card.name);
    const auto augment=a.resolve(a.global,"GetAugmentDescriptionInfo");
    if(augment.kind=="function") {auto extra=reachable(augment.name);card_functions.insert(extra.begin(),extra.end());}
    std::set<std::string> gameplay_readers=gameplay;
    for(const auto& [name,defs]:a.global.defs) {
        (void)defs;if(a.global.locals.contains(name))continue;
        auto exported=a.resolve(a.global,name);
        if(exported.kind=="function" && !card_functions.contains(exported.name)){auto extra=reachable(exported.name);gameplay_readers.insert(extra.begin(),extra.end());}
    }
    std::map<std::string,std::set<std::string>> owners;
    for(const auto& p:published)if(gameplay.contains(p.function))owners[p.field].insert(p.root);
    for(const auto& [field,roots]:owners)if(roots.size()==1 && !roots.contains(""))a.stat_roots[field]=*roots.begin();
    struct Effect {std::string root,operation;int line;};
    std::vector<Effect> effects;
    // These are game operations, not arbitrary functions whose arguments might
    // be ignored. Damage-packet edits require a matching application in the
    // same exported gameplay function; a populated but unused packet rejects.
    for(auto& [name,fn]:a.functions)if(gameplay_readers.contains(name) && !card_functions.contains(name)) {
        std::set<std::string> applied_packets;
        std::map<std::string,int> application_lines;
        std::map<std::string,int> setter_counts;
        const auto method_call=[](std::string t,std::string& receiver,std::string& method,std::vector<std::string>& args) {
            if(t.starts_with("do ") && t.ends_with(" end"))t=t.substr(3,t.size()-7);
            std::string callee;if(!call(t,callee,args))return false;
            auto colon=callee.rfind(':');if(colon==std::string::npos)return false;
            receiver=unparen(callee.substr(0,colon));method=callee.substr(colon+1);return true;
        };
        for(const auto& [line,t]:fn.lines) {
            (void)line;std::string receiver,method;std::vector<std::string> args;
            if(!method_call(t,receiver,method,args))continue;
            auto receiver_slot=a.table_slot(fn,receiver);
            setter_counts[(receiver_slot.empty()?receiver:receiver_slot)+":"+method]++;
            if(method=="RadialDamage" && args.size()==1) {
                auto packet=a.table_slot(fn,args[0]);
                if(!packet.empty() && fn.defs.at(packet).size()==1) {
                    applied_packets.insert(packet);
                    if(!application_lines.contains(packet))application_lines[packet]=line;
                }
            }
        }
        applied_packets.erase("");
        for(const auto& [line,t]:fn.lines) {
            std::string receiver,method;std::vector<std::string> args;
            if(!method_call(t,receiver,method,args)||args.empty())continue;
            const auto receiver_slot=a.table_slot(fn,receiver);
            if(setter_counts[(receiver_slot.empty()?receiver:receiver_slot)+":"+method]!=1)continue;
            bool sink=(method=="GiveTemporaryImmunity" && args.size()==2)
                || ((method=="SetDamageRadius"||method=="SetExplosiveDamage") && args.size()==1)
                || (method=="SetBaseAmount" && args.size()==1 && applied_packets.contains(receiver_slot) && line<application_lines.at(receiver_slot));
            if(!sink)continue;
            auto v=a.resolve(fn,args[0]);if(v.kind=="root")effects.push_back({v.name,method,line});
        }
        for(const auto& packet:applied_packets) {
            auto property=fn.defs.find(packet+".radius");
            if(property==fn.defs.end() || property->second.size()!=1)continue;
            const auto& d=property->second.front();if(d.line>=application_lines.at(packet))continue;
            auto v=a.resolve(fn,d.expression);
            if(v.kind=="root")effects.push_back({v.name,"applied radial-damage radius",d.line});
        }
    }
    std::set<std::string> emitted;
    for(const auto& row:report.at("rows")) {
        const auto root=row.at("variable").get<std::string>();
        if(root.empty() || emitted.contains(root))continue;
        bool native_card=false;
        for(const auto& [name,fn]:a.functions)if(card_functions.contains(name))
            for(const auto& [line,text]:fn.lines){(void)text;if(line==row.at("card_line").get<int>())native_card=true;}
        if(!native_card)continue;
        auto found=std::find_if(published.begin(),published.end(),[&](const Publish& p){return p.root==root && gameplay.contains(p.function) && a.stat_roots.contains(p.field);});
        const auto effect=std::find_if(effects.begin(),effects.end(),[&](const Effect& e){return e.root==root;});
        if(effect==effects.end()){rejections.push_back({{"variable",root},{"reason","No proven gameplay operation consumes this base"}});continue;}
        // The getter must read this exact published key outside the card path.
        bool read=found==published.end();
        for(auto& [name,fn]:a.functions)if(gameplay_readers.contains(name) && !card_functions.contains(name))
            for(auto& [left,defs]:fn.defs)for(const auto& def:defs) {
                (void)left;std::smatch m;auto rhs=unparen(def.expression);
                if(found!=published.end() && std::regex_match(rhs,m,field) && m[2]==found->field && a.resolve(fn,m[1]).kind=="stats")read=true;
            }
        bool writes_valid=true;
        if(a.global.defs.contains(root))for(const auto& d:a.global.defs.at(root))
            if(!std::regex_match(d.expression,numeric))writes_valid=false;
        for(auto& [name,fn]:a.functions)if(fn.defs.contains(root))for(const auto& d:fn.defs.at(root)) {
            (void)name;if(std::regex_match(d.expression,numeric))continue;
            if(a.resolve(fn,d.expression,d.result)!=Value{"root",root})writes_valid=false;
        }
        if(!read || !writes_valid){rejections.push_back({{"variable",root},{"reason",!read?"No matching gameplay stat read":"Unresolved overwrite of base variable"}});continue;}
        auto inputs=row.value("all_inputs",row.at("inputs"));
        if(inputs.empty())continue;
        std::string labels;Json tags=Json::array();
        for(const auto& sibling:report.at("rows"))if(sibling.at("variable")==root){if(!labels.empty())labels+=" / ";labels+=sibling.at("label").get<std::string>();tags.push_back(sibling.at("label_tag"));}
        controls.push_back({{"id","auto."+root},{"label",labels+" · Base scale"},{"unit","× base"},{"variable",root},{"label_tag",row.at("label_tag")},{"label_tags",tags},
            {"operation","scale"},{"original",1},{"minimum",0.01},{"maximum",10000},{"inputs",inputs},
            {"assignments",Json::array({{{"role","card"},{"line",row.at("value_line")}},{{"role","gameplay"},{"line",effect->line}}})},
            {"evidence","Automatically traced shared base to gameplay operation "+effect->operation+" at line "+std::to_string(effect->line)+". Scales every literal base assignment, including all ranks, defaults and PvP/variant branches; native modifier calculations remain unchanged."},
            {"proof","GAMEPLAY_OPERATION_DATAFLOW"}});
        emitted.insert(root);
    }
    return {{"controls",controls},{"rejections",rejections}};
}
}
