#include "renovice/core.hpp"
#include <algorithm>
#include <fstream>
#include <map>
#include <regex>
#include <set>
#include <sstream>

namespace renovice {
namespace {
struct CardLine { std::string text; std::size_t offset; };
// Keep byte positions while excluding comments and long-string payloads from
// source analysis. Quoted labels remain literal strings, never executable text.
std::string mask_noncode(std::string s) {
    const auto blank=[&](std::size_t begin,std::size_t end) {
        for(auto j=begin;j<end;++j) if(s[j]!='\n' && s[j]!='\r') s[j]=' ';
    };
    for(std::size_t i=0;i<s.size();) {
        const bool comment=s.compare(i,2,"--")==0;
        auto start=i+(comment?2:0), q=start;
        if(q<s.size() && s[q]=='[') {
            ++q;while(q<s.size() && s[q]=='=') ++q;
            if(q<s.size() && s[q]=='[') {
                const auto close="]"+std::string(q-start-1,'=')+"]";
                auto end=s.find(close,q+1);end=end==std::string::npos?s.size():end+close.size();
                blank(i,end);i=end;continue;
            }
        }
        if(comment) {
            auto end=s.find('\n',i);if(end==std::string::npos) end=s.size();
            blank(i,end);i=end;continue;
        }
        if(s[i]=='"' || s[i]=='\'') {
            const auto quote=s[i];auto end=i+1;bool multiline=false;
            while(end<s.size()) {
                if(s[end]=='\n') multiline=true;
                if(s[end]=='\\' && end+1<s.size()) { if(s[end+1]=='\n') multiline=true;end+=2;continue; }
                if(s[end++]==quote) break;
            }
            if(multiline) blank(i,end);
            i=end;continue;
        }
        ++i;
    }
    return s;
}
std::string strip(std::string s) {
    const auto first=s.find_first_not_of(" \t\r\n");
    if(first==std::string::npos) return {};
    return s.substr(first,s.find_last_not_of(" \t\r\n")-first+1);
}
std::string unparen(std::string s) {
    s=strip(s);
    while(s.size()>1 && s.front()=='(' && s.back()==')') s=strip(s.substr(1,s.size()-2));
    return s;
}
bool boundary(const std::string& s) {
    return s=="end" || s=="else" || s.starts_with("elseif ") || s.starts_with("if ")
        || s.starts_with("while ") || s.starts_with("for ") || s=="repeat" || s.starts_with("until ");
}
const std::regex identifier(R"(^[A-Za-z_][A-Za-z0-9_]*(?:\[[0-9]+\])?$)");
const std::regex assign(R"(^\s*([A-Za-z_][A-Za-z0-9_]*(?:\[[0-9]+\])?)\s*=\s*(.*?)\s*$)");
const std::regex number(R"(^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(-?(?:[0-9]+(?:\.[0-9]+)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?)\s*$)");
const std::regex label(R"rx(^\s*([A-Za-z_][A-Za-z0-9_]*(?:\[[0-9]+\])?)\s*=\s*\{\s*Label\s*=\s*"([^"\\]+)"\s*,\s*Value\s*=\s*([^,}]+)[,}])rx");
const std::regex value(R"(^\s*([A-Za-z_][A-Za-z0-9_]*(?:\[[0-9]+\])?)\.Value\s*=\s*(.*?)\s*$)");
const std::regex declaration(R"(^local ([A-Za-z_][A-Za-z0-9_]*)$)");

// Deliberately restricted to direct copy chains inside one straight-line region.
// Function calls, arithmetic, branch joins and reused non-root temporaries reject.
std::string root_for(std::string expression, std::size_t before,
    const std::vector<CardLine>& lines, const std::set<std::string>& roots,
    std::set<std::string> seen={}) {
    expression=unparen(expression);
    // A displayed percentage or converted unit may be a single base value
    // multiplied/divided by a literal. Scaling the base preserves that native
    // presentation conversion; do not infer a new absolute gameplay unit.
    std::smatch conversion;
    static const std::regex literal_conversion(R"(^(.+)\s+([*/])\s+(-?(?:[0-9]+(?:\.[0-9]+)?|\.[0-9]+))$)");
    if(std::regex_match(expression,conversion,literal_conversion)) {
        if(std::stod(conversion[3])==0)return {};
        return root_for(conversion[1],before,lines,roots,std::move(seen));
    }
    if(!std::regex_match(expression,identifier) || !seen.insert(expression).second) return {};
    if(roots.contains(expression)) return expression;
    for(auto i=before;i>0;) {
        const auto& text=lines[--i].text;
        const auto t=strip(text);
        if(boundary(t) || t.find(" = function(")!=std::string::npos) return {};
        std::smatch m;
        if(std::regex_match(text,m,assign) && m[1].str()==expression)
            return root_for(m[2],i,lines,roots,std::move(seen));
    }
    return {};
}
}

Json discover_card_stats(const std::string& source, const Json& names, const std::string& body_key) {
    const auto code=mask_noncode(source);
    std::vector<CardLine> lines;
    std::size_t offset=0;
    while(offset<source.size()) {
        auto end=source.find('\n',offset); if(end==std::string::npos) end=source.size();
        lines.push_back({code.substr(offset,end-offset),offset}); offset=end+1;
    }
    std::set<std::string> roots;
    std::map<std::string,std::vector<Json>> constants;
    std::size_t first_function=lines.size();
    for(std::size_t i=0;i<lines.size();++i) {
        if(lines[i].text.find(" = function(")!=std::string::npos) { first_function=i;break; }
        std::smatch m;
        if(std::regex_match(lines[i].text,m,declaration)) roots.insert(m[1]);
    }
    // Only renderer-unique root variables qualify; friendly aliases can be shadowed.
    const std::regex unique_root(R"(^v[0-9]+_[0-9]+$)");
    for(auto it=roots.begin();it!=roots.end();) {
        if(!std::regex_match(*it,unique_root)) it=roots.erase(it); else ++it;
    }
    // Edited source may shadow even renderer-generated names. Refuse those
    // bindings instead of accidentally editing another closure's local values.
    for(auto it=roots.begin();it!=roots.end();) {
        const std::regex local_shadow("\\blocal\\s+[^=\\n]*\\b"+*it+"\\b");
        const std::regex parameter_shadow("\\bfunction\\s*\\([^)]*\\b"+*it+"\\b");
        bool shadow=false;
        for(auto i=first_function;i<lines.size() && !shadow;++i)
            shadow=std::regex_search(lines[i].text,local_shadow) || std::regex_search(lines[i].text,parameter_shadow);
        if(shadow) it=roots.erase(it);else ++it;
    }
    for(std::size_t i=0;i<lines.size();++i) {
        std::smatch m;
        if(std::regex_match(lines[i].text,m,number) && roots.contains(m[1])) {
            constants[m[1]].push_back({{"offset",lines[i].offset+static_cast<std::size_t>(m.position(2))},
                {"length",m.length(2)},{"line",i+1},{"variable",m[1].str()},
                {"original",std::stod(m[2])},{"initial",i<first_function}});
        }
    }
    Json rows=Json::array();
    for(std::size_t i=0;i<lines.size();++i) {
        std::smatch m;
        if(!std::regex_search(lines[i].text,m,label)) continue;
        const auto table=m[1].str(),tag=m[2].str();
        auto expression=strip(m[3]);
        std::size_t value_line=i;
        if(expression=="nil") {
            expression.clear();
            for(auto j=i+1;j<lines.size() && j<i+80;++j) {
                const auto t=strip(lines[j].text);
                if(boundary(t) || t.find(" = function(")!=std::string::npos) break;
                std::smatch v;
                if(std::regex_match(lines[j].text,v,value) && v[1].str()==table) {
                    expression=v[2];value_line=j;break;
                }
                if(std::regex_match(lines[j].text,v,assign) && v[1].str()==table) break;
            }
        }
        auto root=root_for(expression,value_line,lines,roots);
        const auto display=names.contains(tag) && names[tag].is_string() ? names[tag].get<std::string>() : tag;
        Json inputs=Json::array();
        if(!root.empty() && constants.contains(root)) {
            const auto& candidates=constants.at(root);
            const bool has_rank=std::any_of(candidates.begin(),candidates.end(),[](const Json& c){return !c.at("initial").get<bool>();});
            for(const auto& c:candidates) if(!has_rank || !c.at("initial").get<bool>()) inputs.push_back(c);
        }
        rows.push_back({{"label",display},{"label_tag",tag},{"card_line",i+1},
            {"value_line",value_line+1},{"expression",expression},{"variable",root},
            {"status",inputs.empty()?"CALCULATED_OR_UNRESOLVED":"DIRECT_CARD_BASE_INPUT"},
            {"evidence",inputs.empty()?"Native card label found; base input is not resolved by the direct-copy analyser."
                :"Native card Value traces to this root variable through copies or literal unit conversion. Inputs retain separate source branches; rank/PvP labels are not inferred."},
            {"inputs",inputs},{"all_inputs",root.empty() || !constants.contains(root) ? Json::array() : Json(constants.at(root))}});
    }
    return {{"format","RENOVICE_CARD_STATS_V1"},{"body_key",body_key},{"rows",rows}};
}

Json discover_card_stats_file(const fs::path& source_path,const fs::path& names_path,const std::string& body_key) {
    std::ifstream source(source_path,std::ios::binary);
    if(!source) throw std::runtime_error("Cannot open card source");
    std::ostringstream content;content<<source.rdbuf();
    Json names=Json::object();
    if(!names_path.empty()) { std::ifstream input(names_path);if(!input) throw std::runtime_error("Cannot open localized names");input>>names; }
    return discover_card_stats(content.str(),names,body_key);
}
}
