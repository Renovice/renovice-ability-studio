#include "renovice/core.hpp"

#include <algorithm>
#include <array>
#include <cctype>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <limits>
#include <map>
#include <optional>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string_view>
#include <tuple>
#include <unordered_map>
#include <utility>

#include <windows.h>
#include <bcrypt.h>

namespace renovice
{
    namespace
    {
        struct NameRow
        {
            std::size_t prototype = 0;
            std::size_t web = 0;
            std::string canonical;
            std::string readable;
            std::string confidence;
            std::string evidence;
            std::string semantic_type;
            std::string type_confidence;
            std::string type_evidence;
            Json occurrences = Json::array();
        };

        struct ClosureRow
        {
            std::size_t parent_proto = 0;
            std::size_t instruction = 0;
            std::string op;
            std::size_t destination_register = 0;
            std::string operand_namespace;
            std::size_t operand_index = 0;
            std::size_t target_proto = 0;
            std::size_t target_params = 0;
            std::size_t target_upvalues = 0;
            std::size_t target_maxstack = 0;
            std::size_t capture_count = 0;
            std::string captures;
            std::string status;
        };

        struct CallRow
        {
            std::size_t prototype = 0;
            std::size_t block = 0;
            std::size_t instruction = 0;
            std::size_t source_occurrence = 0;
            std::size_t effect_order = 0;
            std::string kind;
            std::string name;
            std::string name_hash;
            int callee_web = -1;
            int receiver_web = -1;
            std::string receiver_type;
            std::string receiver_type_confidence;
            std::string receiver_type_evidence;
            std::string descriptor_join;
            std::vector<int> argument_webs;
            int explicit_argument_count = 0;
            bool open_arguments = false;
            std::vector<int> result_webs;
            int result_count = 0;
            bool open_results = false;
            std::string descriptor;
            std::string contract_confidence;
            std::string contract_status;
            std::string evidence;
            std::string parameters;
            std::string returns;
            std::string contract_match;
            std::size_t readable_offset = 0;
            std::size_t readable_length = 0;
            std::size_t readable_line = 0;
            std::size_t readable_column = 0;
            std::size_t fidelity_offset = 0;
            std::size_t fidelity_length = 0;
            std::size_t fidelity_line = 0;
            std::size_t fidelity_column = 0;
        };

        [[nodiscard]] bool same_callsite_contract(
            const CallRow& left,
            const CallRow& right)
        {
            return left.prototype == right.prototype
                && left.block == right.block
                && left.instruction == right.instruction
                && left.effect_order == right.effect_order
                && left.kind == right.kind
                && left.name == right.name
                && left.name_hash == right.name_hash
                && left.callee_web == right.callee_web
                && left.receiver_web == right.receiver_web
                && left.receiver_type == right.receiver_type
                && left.receiver_type_confidence == right.receiver_type_confidence
                && left.receiver_type_evidence == right.receiver_type_evidence
                && left.descriptor_join == right.descriptor_join
                && left.argument_webs == right.argument_webs
                && left.explicit_argument_count == right.explicit_argument_count
                && left.open_arguments == right.open_arguments
                && left.result_webs == right.result_webs
                && left.result_count == right.result_count
                && left.open_results == right.open_results
                && left.descriptor == right.descriptor
                && left.contract_confidence == right.contract_confidence
                && left.contract_status == right.contract_status
                && left.evidence == right.evidence
                && left.parameters == right.parameters
                && left.returns == right.returns
                && left.contract_match == right.contract_match;
        }

        enum class TokenKind
        {
            identifier,
            atom,
        };

        struct Token
        {
            TokenKind kind = TokenKind::atom;
            std::string text;
            std::size_t offset = 0;
            std::size_t length = 0;
            std::size_t line = 0;
            std::size_t column = 0;
        };

        struct LongBracket
        {
            std::size_t content_start = 0;
            std::string closing;
        };

        [[nodiscard]] std::string read_text_file(const fs::path& path)
        {
            std::ifstream input(path, std::ios::binary);
            if (!input) throw std::runtime_error("Unable to read " + path.string());
            return std::string(
                std::istreambuf_iterator<char>(input),
                std::istreambuf_iterator<char>());
        }

        void write_text_file(const fs::path& path, const std::string& value)
        {
            if (!path.parent_path().empty()) fs::create_directories(path.parent_path());
            std::ofstream output(path, std::ios::binary | std::ios::trunc);
            if (!output) throw std::runtime_error("Unable to write " + path.string());
            output.write(value.data(), static_cast<std::streamsize>(value.size()));
            if (!output) throw std::runtime_error("Unable to finish writing " + path.string());
        }

        [[nodiscard]] std::string sha256_text(const std::string& value)
        {
            BCRYPT_ALG_HANDLE algorithm = nullptr;
            BCRYPT_HASH_HANDLE hash = nullptr;
            DWORD object_size = 0;
            DWORD hash_size = 0;
            DWORD returned = 0;

            const auto require_success = [](const NTSTATUS status, const char* operation)
            {
                if (status < 0)
                    throw std::runtime_error(std::string("BCrypt failure: ") + operation);
            };

            require_success(
                BCryptOpenAlgorithmProvider(&algorithm, BCRYPT_SHA256_ALGORITHM, nullptr, 0),
                "open SHA-256 provider");
            try
            {
                require_success(
                    BCryptGetProperty(
                        algorithm,
                        BCRYPT_OBJECT_LENGTH,
                        reinterpret_cast<PUCHAR>(&object_size),
                        sizeof(object_size),
                        &returned,
                        0),
                    "query object length");
                require_success(
                    BCryptGetProperty(
                        algorithm,
                        BCRYPT_HASH_LENGTH,
                        reinterpret_cast<PUCHAR>(&hash_size),
                        sizeof(hash_size),
                        &returned,
                        0),
                    "query hash length");
                std::vector<UCHAR> object(object_size);
                std::vector<UCHAR> digest(hash_size);
                require_success(
                    BCryptCreateHash(algorithm, &hash, object.data(), object_size, nullptr, 0, 0),
                    "create hash");

                std::size_t offset = 0;
                constexpr std::size_t maximum_chunk =
                    static_cast<std::size_t>((std::numeric_limits<ULONG>::max)());
                while (offset < value.size())
                {
                    const std::size_t count = (std::min)(maximum_chunk, value.size() - offset);
                    require_success(
                        BCryptHashData(
                            hash,
                            reinterpret_cast<PUCHAR>(
                                const_cast<char*>(value.data() + offset)),
                            static_cast<ULONG>(count),
                            0),
                        "hash data");
                    offset += count;
                }
                require_success(BCryptFinishHash(hash, digest.data(), hash_size, 0), "finish hash");

                std::ostringstream output;
                output << std::hex << std::uppercase << std::setfill('0');
                for (const UCHAR byte : digest)
                    output << std::setw(2) << static_cast<unsigned int>(byte);
                BCryptDestroyHash(hash);
                hash = nullptr;
                BCryptCloseAlgorithmProvider(algorithm, 0);
                algorithm = nullptr;
                return output.str();
            }
            catch (...)
            {
                if (hash != nullptr) BCryptDestroyHash(hash);
                if (algorithm != nullptr) BCryptCloseAlgorithmProvider(algorithm, 0);
                throw;
            }
        }

        [[nodiscard]] std::vector<std::string> split_preserving_empty(
            const std::string_view value,
            const char delimiter)
        {
            std::vector<std::string> parts;
            std::size_t start = 0;
            while (start <= value.size())
            {
                const std::size_t next = value.find(delimiter, start);
                const std::size_t end = next == std::string_view::npos ? value.size() : next;
                parts.emplace_back(value.substr(start, end - start));
                if (next == std::string_view::npos) break;
                start = next + 1;
            }
            return parts;
        }

        [[nodiscard]] std::vector<std::vector<std::string>> parse_tsv(
            const std::string& text,
            const std::vector<std::string>& required_header,
            const std::string& description)
        {
            std::vector<std::vector<std::string>> rows;
            std::size_t start = 0;
            std::size_t line_number = 0;
            while (start <= text.size())
            {
                const std::size_t newline = text.find('\n', start);
                const std::size_t end = newline == std::string::npos ? text.size() : newline;
                std::string_view line(text.data() + start, end - start);
                if (!line.empty() && line.back() == '\r') line.remove_suffix(1);
                ++line_number;
                if (!line.empty()) rows.push_back(split_preserving_empty(line, '\t'));
                if (newline == std::string::npos) break;
                start = newline + 1;
            }
            if (rows.empty()) throw std::runtime_error(description + " is empty");
            if (!rows.front().empty() && rows.front().front().starts_with("\xEF\xBB\xBF"))
                rows.front().front().erase(0, 3);
            if (rows.front() != required_header)
                throw std::runtime_error(description + " header does not match the required schema");
            for (std::size_t index = 1; index < rows.size(); ++index)
            {
                if (rows[index].size() != required_header.size())
                    throw std::runtime_error(
                        description + " row " + std::to_string(index + 1)
                        + " has " + std::to_string(rows[index].size())
                        + " columns; expected " + std::to_string(required_header.size()));
            }
            rows.erase(rows.begin());
            return rows;
        }

        [[nodiscard]] std::size_t parse_size(
            const std::string& value,
            const std::string& field,
            const std::size_t row)
        {
            if (value.empty())
                throw std::runtime_error(field + " is empty at row " + std::to_string(row));
            std::size_t consumed = 0;
            unsigned long long parsed = 0;
            try
            {
                parsed = std::stoull(value, &consumed, 10);
            }
            catch (const std::exception&)
            {
                throw std::runtime_error(field + " is not an unsigned integer at row "
                    + std::to_string(row));
            }
            if (consumed != value.size()
                || parsed > static_cast<unsigned long long>((std::numeric_limits<std::size_t>::max)()))
                throw std::runtime_error(field + " is invalid at row " + std::to_string(row));
            return static_cast<std::size_t>(parsed);
        }

        [[nodiscard]] int parse_int(
            const std::string& value,
            const std::string& field,
            const std::size_t row)
        {
            if (value.empty())
                throw std::runtime_error(field + " is empty at row " + std::to_string(row));
            std::size_t consumed = 0;
            long long parsed = 0;
            try
            {
                parsed = std::stoll(value, &consumed, 10);
            }
            catch (const std::exception&)
            {
                throw std::runtime_error(field + " is not an integer at row "
                    + std::to_string(row));
            }
            if (consumed != value.size()
                || parsed < static_cast<long long>((std::numeric_limits<int>::min)())
                || parsed > static_cast<long long>((std::numeric_limits<int>::max)()))
                throw std::runtime_error(field + " is invalid at row " + std::to_string(row));
            return static_cast<int>(parsed);
        }

        [[nodiscard]] bool parse_bool(
            const std::string& value,
            const std::string& field,
            const std::size_t row)
        {
            if (value == "true") return true;
            if (value == "false") return false;
            throw std::runtime_error(field + " is not canonical true/false at row "
                + std::to_string(row));
        }

        [[nodiscard]] std::vector<int> parse_web_list(
            const std::string& value,
            const std::string& field,
            const std::size_t row)
        {
            std::vector<int> result;
            if (value.empty()) return result;
            for (const std::string& item : split_preserving_empty(value, ';'))
            {
                const int web = parse_int(item, field, row);
                if (web < -1)
                    throw std::runtime_error(field + " contains an invalid web at row "
                        + std::to_string(row));
                result.push_back(web);
            }
            return result;
        }

        [[nodiscard]] bool is_safe_identifier(const std::string& value)
        {
            if (value.empty()) return false;
            const auto starts_identifier = [](const char character)
            {
                const unsigned char byte = static_cast<unsigned char>(character);
                return std::isalpha(byte) != 0 || character == '_';
            };
            const auto continues_identifier = [](const char character)
            {
                const unsigned char byte = static_cast<unsigned char>(character);
                return std::isalnum(byte) != 0 || character == '_';
            };
            if (!starts_identifier(value.front())
                || !std::all_of(value.begin() + 1, value.end(), continues_identifier))
                return false;
            constexpr std::array<std::string_view, 23> reserved{
                "and", "break", "continue", "do", "else", "elseif", "end", "false",
                "for", "function", "goto", "if", "in", "local", "nil", "not", "or",
                "repeat", "return", "then", "true", "until", "while",
            };
            return std::find(reserved.begin(), reserved.end(), value) == reserved.end();
        }

        [[nodiscard]] std::vector<NameRow> load_name_rows(const std::string& text)
        {
            const std::vector<std::string> header{
                "prototype", "web", "canonical", "readable", "confidence", "evidence",
                "semantic_type", "type_confidence", "type_evidence",
            };
            const auto raw_rows = parse_tsv(text, header, "semantic naming map");
            if (raw_rows.empty()) throw std::runtime_error("semantic naming map has no rows");
            std::vector<NameRow> rows;
            rows.reserve(raw_rows.size());
            std::set<std::pair<std::size_t, std::size_t>> identities;
            std::set<std::string> canonical_names;
            for (std::size_t index = 0; index < raw_rows.size(); ++index)
            {
                const auto& raw = raw_rows[index];
                const std::size_t source_row = index + 2;
                NameRow row;
                row.prototype = parse_size(raw[0], "prototype", source_row);
                row.web = parse_size(raw[1], "web", source_row);
                row.canonical = raw[2];
                row.readable = raw[3];
                row.confidence = raw[4];
                row.evidence = raw[5];
                row.semantic_type = raw[6];
                row.type_confidence = raw[7];
                row.type_evidence = raw[8];
                if (row.canonical.empty())
                    throw std::runtime_error(
                        "semantic naming map has an empty canonical identity at row "
                        + std::to_string(source_row));
                const bool has_readable_evidence = !row.readable.empty()
                    || !row.confidence.empty() || !row.evidence.empty();
                if (has_readable_evidence
                    && (row.readable.empty() || row.confidence.empty() || row.evidence.empty()))
                    throw std::runtime_error(
                        "semantic naming map has partial readable-name evidence at row "
                        + std::to_string(source_row));
                if (!has_readable_evidence
                    && (row.semantic_type.empty() || row.type_confidence.empty()
                        || row.type_evidence.empty()))
                    throw std::runtime_error(
                        "semantic naming map row has neither readable-name nor complete type evidence at row "
                        + std::to_string(source_row));
                const std::string local_prefix = "v" + std::to_string(row.prototype) + "_";
                const std::string parameter_prefix = "p" + std::to_string(row.prototype) + "_";
                if (!row.canonical.starts_with(local_prefix)
                    && !row.canonical.starts_with(parameter_prefix))
                    throw std::runtime_error(
                        "canonical identity " + row.canonical + " does not belong to prototype "
                        + std::to_string(row.prototype));
                if (!is_safe_identifier(row.canonical)
                    || (!row.readable.empty() && !is_safe_identifier(row.readable)))
                    throw std::runtime_error(
                        "semantic naming map contains an unsafe or reserved identifier at row "
                        + std::to_string(source_row));
                if (!identities.emplace(row.prototype, row.web).second)
                    throw std::runtime_error(
                        "duplicate (prototype, web) identity at naming-map row "
                        + std::to_string(source_row));
                if (!canonical_names.insert(row.canonical).second)
                    throw std::runtime_error(
                        "duplicate canonical identity " + row.canonical);
                rows.push_back(std::move(row));
            }
            return rows;
        }

        void validate_capture_list(
            const std::string& captures,
            const std::size_t expected_count,
            const std::size_t source_row)
        {
            if (expected_count == 0)
            {
                if (!captures.empty())
                    throw std::runtime_error(
                        "zero-capture closure has capture text at row "
                        + std::to_string(source_row));
                return;
            }
            const auto parts = split_preserving_empty(captures, ';');
            if (parts.size() != expected_count)
                throw std::runtime_error(
                    "closure capture_count does not match captures at row "
                    + std::to_string(source_row));
            for (std::size_t index = 0; index < parts.size(); ++index)
            {
                const std::string expected_prefix = std::to_string(index) + "=";
                const std::string& capture = parts[index];
                if (!capture.starts_with(expected_prefix))
                    throw std::runtime_error(
                        "closure capture indexes are not contiguous at row "
                        + std::to_string(source_row));
                const std::size_t kind_end = capture.find(':', expected_prefix.size());
                if (kind_end == std::string::npos || kind_end + 2 >= capture.size())
                    throw std::runtime_error(
                        "closure capture syntax is invalid at row "
                        + std::to_string(source_row));
                const std::string kind = capture.substr(
                    expected_prefix.size(), kind_end - expected_prefix.size());
                if (kind != "VAL" && kind != "REF" && kind != "UPVAL")
                    throw std::runtime_error(
                        "closure capture kind is invalid at row "
                        + std::to_string(source_row));
                const char storage = capture[kind_end + 1];
                const char expected_storage = kind == "UPVAL" ? 'U' : 'R';
                if (storage != expected_storage)
                    throw std::runtime_error(
                        "closure capture storage is invalid at row "
                        + std::to_string(source_row));
                (void)parse_size(
                    capture.substr(kind_end + 2),
                    "closure capture index",
                    source_row);
            }
        }

        [[nodiscard]] std::vector<ClosureRow> load_closure_rows(const std::string& text)
        {
            const std::vector<std::string> header{
                "parent_proto", "instruction", "op", "destination_register",
                "operand_namespace", "operand_index", "target_proto", "target_params",
                "target_upvalues", "target_maxstack", "capture_count", "captures", "status",
            };
            const auto raw_rows = parse_tsv(text, header, "closure ownership map");
            std::vector<ClosureRow> rows;
            rows.reserve(raw_rows.size());
            std::set<std::pair<std::size_t, std::size_t>> sites;
            for (std::size_t index = 0; index < raw_rows.size(); ++index)
            {
                const auto& raw = raw_rows[index];
                const std::size_t source_row = index + 2;
                ClosureRow row;
                row.parent_proto = parse_size(raw[0], "parent_proto", source_row);
                row.instruction = parse_size(raw[1], "instruction", source_row);
                row.op = raw[2];
                row.destination_register = parse_size(raw[3], "destination_register", source_row);
                row.operand_namespace = raw[4];
                row.operand_index = parse_size(raw[5], "operand_index", source_row);
                row.target_proto = parse_size(raw[6], "target_proto", source_row);
                row.target_params = parse_size(raw[7], "target_params", source_row);
                row.target_upvalues = parse_size(raw[8], "target_upvalues", source_row);
                row.target_maxstack = parse_size(raw[9], "target_maxstack", source_row);
                row.capture_count = parse_size(raw[10], "capture_count", source_row);
                row.captures = raw[11];
                row.status = raw[12];
                if (row.status != "PASS")
                    throw std::runtime_error(
                        "closure ownership is not proven PASS at row "
                        + std::to_string(source_row));
                if (row.op != "NEWCLOSURE" && row.op != "DUPCLOSURE")
                    throw std::runtime_error(
                        "unsupported closure opcode at row " + std::to_string(source_row));
                if (row.operand_namespace != "child" && row.operand_namespace != "const")
                    throw std::runtime_error(
                        "unsupported closure operand namespace at row "
                        + std::to_string(source_row));
                if (!sites.emplace(row.parent_proto, row.instruction).second)
                    throw std::runtime_error(
                        "duplicate closure site at row " + std::to_string(source_row));
                validate_capture_list(row.captures, row.capture_count, source_row);
                rows.push_back(std::move(row));
            }
            return rows;
        }

        [[nodiscard]] std::vector<CallRow> load_call_rows(const std::string& text)
        {
            const std::vector<std::string> header{
                "schema_version", "prototype", "block", "instruction", "source_occurrence", "effect_order",
                "kind", "name", "name_hash", "callee_web", "receiver_web",
                "receiver_type", "receiver_type_confidence", "receiver_type_evidence", "descriptor_join",
                "argument_webs", "explicit_argument_count", "open_arguments",
                "result_webs", "result_count", "open_results", "descriptor",
                "contract_confidence", "contract_status", "evidence", "parameters",
                "returns", "contract_match", "readable_offset", "readable_length",
                "readable_line", "readable_column", "fidelity_offset", "fidelity_length",
                "fidelity_line", "fidelity_column",
            };
            const auto raw_rows = parse_tsv(text, header, "API callsite map");
            std::vector<CallRow> rows;
            rows.reserve(raw_rows.size());
            std::set<std::tuple<std::size_t, std::size_t, std::size_t>> identities;
            std::map<std::pair<std::size_t, std::size_t>, std::size_t> next_occurrences;
            std::map<std::pair<std::size_t, std::size_t>, CallRow> first_occurrences;
            for (std::size_t index = 0; index < raw_rows.size(); ++index)
            {
                const auto& raw = raw_rows[index];
                const std::size_t source_row = index + 2;
                if (raw[0] != "2")
                    throw std::runtime_error("API callsite schema is unsupported at row "
                        + std::to_string(source_row));
                CallRow row;
                row.prototype = parse_size(raw[1], "prototype", source_row);
                row.block = parse_size(raw[2], "block", source_row);
                row.instruction = parse_size(raw[3], "instruction", source_row);
                row.source_occurrence = parse_size(raw[4], "source_occurrence", source_row);
                row.effect_order = parse_size(raw[5], "effect_order", source_row);
                row.kind = raw[6];
                row.name = raw[7];
                row.name_hash = raw[8];
                row.callee_web = parse_int(raw[9], "callee_web", source_row);
                row.receiver_web = parse_int(raw[10], "receiver_web", source_row);
                row.receiver_type = raw[11];
                row.receiver_type_confidence = raw[12];
                row.receiver_type_evidence = raw[13];
                row.descriptor_join = raw[14];
                row.argument_webs = parse_web_list(raw[15], "argument_webs", source_row);
                row.explicit_argument_count = parse_int(raw[16], "explicit_argument_count", source_row);
                row.open_arguments = parse_bool(raw[17], "open_arguments", source_row);
                row.result_webs = parse_web_list(raw[18], "result_webs", source_row);
                row.result_count = parse_int(raw[19], "result_count", source_row);
                row.open_results = parse_bool(raw[20], "open_results", source_row);
                row.descriptor = raw[21];
                row.contract_confidence = raw[22];
                row.contract_status = raw[23];
                row.evidence = raw[24];
                row.parameters = raw[25];
                row.returns = raw[26];
                row.contract_match = raw[27];
                row.readable_offset = parse_size(raw[28], "readable_offset", source_row);
                row.readable_length = parse_size(raw[29], "readable_length", source_row);
                row.readable_line = parse_size(raw[30], "readable_line", source_row);
                row.readable_column = parse_size(raw[31], "readable_column", source_row);
                row.fidelity_offset = parse_size(raw[32], "fidelity_offset", source_row);
                row.fidelity_length = parse_size(raw[33], "fidelity_length", source_row);
                row.fidelity_line = parse_size(raw[34], "fidelity_line", source_row);
                row.fidelity_column = parse_size(raw[35], "fidelity_column", source_row);
                if (!identities.emplace(row.prototype, row.instruction, row.source_occurrence).second)
                    throw std::runtime_error("duplicate API callsite identity at row "
                        + std::to_string(source_row));
                const std::pair<std::size_t, std::size_t> bytecode_identity{
                    row.prototype, row.instruction};
                std::size_t& next_occurrence = next_occurrences[bytecode_identity];
                if (row.source_occurrence != next_occurrence)
                    throw std::runtime_error(
                        "API callsite source occurrences are not contiguous from zero at row "
                        + std::to_string(source_row));
                ++next_occurrence;
                if (row.kind != "method" && row.kind != "global_function"
                    && row.kind != "dynamic_function")
                    throw std::runtime_error("unsupported API callsite kind at row "
                        + std::to_string(source_row));
                if ((row.kind == "method" || row.kind == "global_function") && row.name.empty())
                    throw std::runtime_error("named API callsite has no name at row "
                        + std::to_string(source_row));
                if (row.callee_web < -1 || row.receiver_web < -1
                    || row.explicit_argument_count < -1 || row.result_count < -1)
                    throw std::runtime_error("API callsite contains an invalid signed count at row "
                        + std::to_string(source_row));
                const std::set<std::string> allowed_joins{
                    "NONE", "STATIC_NAME", "UNIQUE_METHOD_NAME", "RECEIVER_TYPE",
                    "RECEIVER_TYPE_CONFLICT", "AMBIGUOUS",
                };
                if (!allowed_joins.count(row.descriptor_join))
                    throw std::runtime_error("API callsite descriptor join is invalid at row "
                        + std::to_string(source_row));
                if (row.receiver_type.empty()
                    != (row.receiver_type_confidence.empty()
                        && row.receiver_type_evidence.empty()))
                    throw std::runtime_error("API callsite receiver type provenance is incomplete at row "
                        + std::to_string(source_row));
                if ((row.descriptor_join == "RECEIVER_TYPE"
                        || row.descriptor_join == "RECEIVER_TYPE_CONFLICT")
                    && row.receiver_type.empty())
                    throw std::runtime_error("API callsite receiver-based join lacks a receiver type at row "
                        + std::to_string(source_row));
                if (row.open_arguments != (row.explicit_argument_count == -1)
                    || row.open_results != (row.result_count == -1))
                    throw std::runtime_error("API callsite open-width flags disagree at row "
                        + std::to_string(source_row));
                if (!row.open_arguments
                    && row.argument_webs.size()
                        != static_cast<std::size_t>(row.explicit_argument_count))
                    throw std::runtime_error("API callsite argument web count disagrees at row "
                        + std::to_string(source_row));
                if (!row.open_results
                    && row.result_webs.size() != static_cast<std::size_t>(row.result_count))
                    throw std::runtime_error("API callsite result web count disagrees at row "
                        + std::to_string(source_row));
                const std::set<std::string> allowed_matches{
                    "MATCH", "OPEN_ARGUMENTS", "UNSPECIFIED", "UNREGISTERED",
                    "AMBIGUOUS", "OBSERVED_MISMATCH", "CONFIRMED_MISMATCH",
                };
                if (!allowed_matches.count(row.contract_match))
                    throw std::runtime_error("API callsite contract match is invalid at row "
                        + std::to_string(source_row));
                if (row.contract_match == "CONFIRMED_MISMATCH")
                    throw std::runtime_error("confirmed API contract arity mismatch at row "
                        + std::to_string(source_row));
                if (row.descriptor.empty())
                {
                    if (!row.contract_confidence.empty() || !row.contract_status.empty()
                        || !row.evidence.empty() || !row.parameters.empty()
                        || !row.returns.empty())
                        throw std::runtime_error("unbound API callsite carries contract claims at row "
                            + std::to_string(source_row));
                }
                else if (row.contract_confidence.empty() || row.contract_status.empty())
                    throw std::runtime_error("bound API callsite lacks confidence/status at row "
                        + std::to_string(source_row));
                if (row.readable_length == 0 || row.fidelity_length == 0
                    || row.readable_line == 0 || row.readable_column == 0
                    || row.fidelity_line == 0 || row.fidelity_column == 0)
                    throw std::runtime_error("API callsite has an empty source span at row "
                        + std::to_string(source_row));
                const auto first = first_occurrences.find(bytecode_identity);
                if (first == first_occurrences.end())
                    first_occurrences.emplace(bytecode_identity, row);
                else if (!same_callsite_contract(first->second, row))
                    throw std::runtime_error(
                        "API callsite source occurrences disagree on bytecode or contract facts at row "
                        + std::to_string(source_row));
                rows.push_back(std::move(row));
            }
            return rows;
        }

        struct SourceLocation
        {
            std::size_t line = 1;
            std::size_t column = 1;
        };

        [[nodiscard]] SourceLocation source_location_at(
            const std::string& source,
            const std::size_t offset)
        {
            if (offset > source.size())
                throw std::runtime_error("source span offset is outside its source");
            SourceLocation location;
            std::size_t cursor = 0;
            while (cursor < offset)
            {
                if (source[cursor] == '\r')
                {
                    if (cursor + 1 < offset && source[cursor + 1] == '\n') cursor += 2;
                    else ++cursor;
                    ++location.line;
                    location.column = 1;
                }
                else if (source[cursor] == '\n')
                {
                    ++cursor;
                    ++location.line;
                    location.column = 1;
                }
                else
                {
                    ++cursor;
                    ++location.column;
                }
            }
            return location;
        }

        [[nodiscard]] bool contains_identifier(
            const std::string_view source,
            const std::string_view identifier)
        {
            if (identifier.empty()) return false;
            const auto continues_identifier = [](const char value)
            {
                const unsigned char byte = static_cast<unsigned char>(value);
                return std::isalnum(byte) != 0 || value == '_';
            };
            std::size_t position = 0;
            while ((position = source.find(identifier, position)) != std::string_view::npos)
            {
                const bool start_boundary = position == 0
                    || !continues_identifier(source[position - 1]);
                const std::size_t end = position + identifier.size();
                const bool end_boundary = end == source.size()
                    || !continues_identifier(source[end]);
                if (start_boundary && end_boundary) return true;
                ++position;
            }
            return false;
        }

        void validate_call_span(
            const CallRow& row,
            const std::string& source,
            const bool readable,
            const std::size_t source_row)
        {
            const std::size_t offset = readable ? row.readable_offset : row.fidelity_offset;
            const std::size_t length = readable ? row.readable_length : row.fidelity_length;
            const std::size_t line = readable ? row.readable_line : row.fidelity_line;
            const std::size_t column = readable ? row.readable_column : row.fidelity_column;
            const std::string label = readable ? "readable" : "fidelity";
            if (offset > source.size() || length > source.size() - offset)
                throw std::runtime_error(label + " API callsite span is outside its source at row "
                    + std::to_string(source_row));
            const SourceLocation actual = source_location_at(source, offset);
            if (actual.line != line || actual.column != column)
                throw std::runtime_error(label + " API callsite line/column disagrees with its byte offset at row "
                    + std::to_string(source_row));
            const std::string_view slice(source.data() + offset, length);
            if (slice.find('(') == std::string_view::npos)
                throw std::runtime_error(label + " API callsite span is not a call expression at row "
                    + std::to_string(source_row));
            if (row.kind == "method"
                && !contains_identifier(slice, row.name))
                throw std::runtime_error(label + " API callsite span does not contain its exact call name at row "
                    + std::to_string(source_row));
        }

        void validate_non_crossing_call_spans(
            const std::vector<CallRow>& rows,
            const bool readable)
        {
            struct Interval
            {
                std::size_t start = 0;
                std::size_t end = 0;
                std::size_t row = 0;
            };
            std::vector<Interval> intervals;
            intervals.reserve(rows.size());
            for (std::size_t index = 0; index < rows.size(); ++index)
            {
                const std::size_t start = readable
                    ? rows[index].readable_offset : rows[index].fidelity_offset;
                const std::size_t length = readable
                    ? rows[index].readable_length : rows[index].fidelity_length;
                intervals.push_back(Interval{start, start + length, index + 2});
            }
            std::sort(intervals.begin(), intervals.end(), [](const Interval& left, const Interval& right)
            {
                if (left.start != right.start) return left.start < right.start;
                return left.end > right.end;
            });
            std::vector<Interval> parents;
            for (const Interval& interval : intervals)
            {
                while (!parents.empty() && interval.start >= parents.back().end)
                    parents.pop_back();
                if (!parents.empty() && interval.end > parents.back().end)
                    throw std::runtime_error(
                        std::string(readable ? "readable" : "fidelity")
                        + " API callsite spans cross between rows "
                        + std::to_string(parents.back().row) + " and "
                        + std::to_string(interval.row));
                parents.push_back(interval);
            }
        }

        [[nodiscard]] Json nullable_web(const int value)
        {
            return value < 0 ? Json(nullptr) : Json(value);
        }

        [[nodiscard]] Json web_list_json(const std::vector<int>& values)
        {
            Json result = Json::array();
            for (const int value : values) result.push_back(nullable_web(value));
            return result;
        }

        [[nodiscard]] Json nullable_text(const std::string& value)
        {
            return value.empty() ? Json(nullptr) : Json(value);
        }

        [[nodiscard]] Json call_span_json(
            const std::size_t offset,
            const std::size_t length,
            const std::size_t line,
            const std::size_t column)
        {
            return Json{
                {"offset", offset},
                {"length", length},
                {"line", line},
                {"column", column},
            };
        }

        [[nodiscard]] bool is_identifier_start(const char value)
        {
            const unsigned char byte = static_cast<unsigned char>(value);
            return std::isalpha(byte) != 0 || value == '_';
        }

        [[nodiscard]] bool is_identifier_continue(const char value)
        {
            const unsigned char byte = static_cast<unsigned char>(value);
            return std::isalnum(byte) != 0 || value == '_';
        }

        [[nodiscard]] std::optional<LongBracket> long_bracket_at(
            const std::string& source,
            const std::size_t position)
        {
            if (position >= source.size() || source[position] != '[') return std::nullopt;
            std::size_t cursor = position + 1;
            while (cursor < source.size() && source[cursor] == '=') ++cursor;
            if (cursor >= source.size() || source[cursor] != '[') return std::nullopt;
            const std::size_t equals_count = cursor - position - 1;
            return LongBracket{
                cursor + 1,
                "]" + std::string(equals_count, '=') + "]",
            };
        }

        [[nodiscard]] std::vector<Token> tokenize_luau(const std::string& source)
        {
            std::vector<Token> tokens;
            std::size_t position = 0;
            std::size_t line = 1;
            std::size_t column = 1;

            auto advance_to = [&](const std::size_t end)
            {
                while (position < end)
                {
                    if (source[position] == '\r')
                    {
                        if (position + 1 < end && source[position + 1] == '\n') position += 2;
                        else ++position;
                        ++line;
                        column = 1;
                    }
                    else if (source[position] == '\n')
                    {
                        ++position;
                        ++line;
                        column = 1;
                    }
                    else
                    {
                        ++position;
                        ++column;
                    }
                }
            };

            while (position < source.size())
            {
                const unsigned char byte = static_cast<unsigned char>(source[position]);
                if (std::isspace(byte) != 0)
                {
                    std::size_t end = position + 1;
                    while (end < source.size()
                        && std::isspace(static_cast<unsigned char>(source[end])) != 0) ++end;
                    advance_to(end);
                    continue;
                }

                const std::size_t token_offset = position;
                const std::size_t token_line = line;
                const std::size_t token_column = column;
                std::size_t end = position + 1;
                TokenKind kind = TokenKind::atom;

                if (source[position] == '-' && position + 1 < source.size()
                    && source[position + 1] == '-')
                {
                    const auto bracket = long_bracket_at(source, position + 2);
                    if (bracket)
                    {
                        const std::size_t close = source.find(bracket->closing, bracket->content_start);
                        if (close == std::string::npos)
                            throw std::runtime_error("unterminated long comment in generated source");
                        end = close + bracket->closing.size();
                    }
                    else
                    {
                        end = position + 2;
                        while (end < source.size() && source[end] != '\r' && source[end] != '\n') ++end;
                    }
                }
                else if (source[position] == '\'' || source[position] == '"')
                {
                    const char quote = source[position];
                    end = position + 1;
                    bool closed = false;
                    while (end < source.size())
                    {
                        if (source[end] == '\\')
                        {
                            end += (end + 1 < source.size()) ? 2 : 1;
                            continue;
                        }
                        if (source[end] == quote)
                        {
                            ++end;
                            closed = true;
                            break;
                        }
                        ++end;
                    }
                    if (!closed) throw std::runtime_error("unterminated quoted string in generated source");
                }
                else if (const auto bracket = long_bracket_at(source, position))
                {
                    const std::size_t close = source.find(bracket->closing, bracket->content_start);
                    if (close == std::string::npos)
                        throw std::runtime_error("unterminated long string in generated source");
                    end = close + bracket->closing.size();
                }
                else if (is_identifier_start(source[position]))
                {
                    kind = TokenKind::identifier;
                    end = position + 1;
                    while (end < source.size() && is_identifier_continue(source[end])) ++end;
                }
                else if (std::isdigit(byte) != 0
                    || (source[position] == '.' && position + 1 < source.size()
                        && std::isdigit(static_cast<unsigned char>(source[position + 1])) != 0))
                {
                    end = position + 1;
                    char previous = source[position];
                    while (end < source.size())
                    {
                        const char current = source[end];
                        const unsigned char current_byte = static_cast<unsigned char>(current);
                        if (std::isalnum(current_byte) != 0 || current == '.' || current == '_')
                        {
                            previous = current;
                            ++end;
                            continue;
                        }
                        if ((current == '+' || current == '-')
                            && (previous == 'e' || previous == 'E'
                                || previous == 'p' || previous == 'P'))
                        {
                            previous = current;
                            ++end;
                            continue;
                        }
                        break;
                    }
                }

                tokens.push_back(Token{
                    kind,
                    source.substr(token_offset, end - token_offset),
                    token_offset,
                    end - token_offset,
                    token_line,
                    token_column,
                });
                advance_to(end);
            }
            return tokens;
        }

        [[nodiscard]] std::size_t remove_fixed_readable_preamble(
            std::vector<Token>& readable_tokens,
            const std::vector<Token>& fidelity_tokens)
        {
            constexpr std::string_view marker = "-- RENOVICE_READABLE_VIEW_V1";
            constexpr std::string_view explanation =
                "-- Identifier aliases are evidence-backed presentation only. Use the fidelity twin and TSV sidecar for exact provenance.";
            const auto contains_fixed_comment = [&](const std::vector<Token>& tokens)
            {
                return std::any_of(tokens.begin(), tokens.end(), [](const Token& token)
                {
                    return token.text == marker || token.text == explanation;
                });
            };
            if (contains_fixed_comment(fidelity_tokens))
                throw std::runtime_error("fixed readable-view preamble appeared in fidelity source");

            std::size_t insertion = 0;
            while (insertion < readable_tokens.size()
                && readable_tokens[insertion].text.starts_with("-- RENOVICE_HASH_"))
                ++insertion;
            const bool marker_at_boundary = insertion < readable_tokens.size()
                && readable_tokens[insertion].text == marker;
            const bool explanation_at_boundary = insertion + 1 < readable_tokens.size()
                && readable_tokens[insertion + 1].text == explanation;
            if (marker_at_boundary != explanation_at_boundary)
                throw std::runtime_error("fixed readable-view preamble is partial or reordered");
            if (!marker_at_boundary)
            {
                if (contains_fixed_comment(readable_tokens))
                    throw std::runtime_error("fixed readable-view preamble is outside its required boundary");
                return 0;
            }

            readable_tokens.erase(
                readable_tokens.begin() + static_cast<std::ptrdiff_t>(insertion),
                readable_tokens.begin() + static_cast<std::ptrdiff_t>(insertion + 2));
            if (contains_fixed_comment(readable_tokens))
                throw std::runtime_error("fixed readable-view preamble occurs more than once");
            return 2;
        }

        [[nodiscard]] std::set<std::size_t> load_omitted_dead_orphan_prototypes(
            const std::vector<Token>& tokens,
            const std::string_view source_label)
        {
            constexpr std::string_view shape =
                "-- RENOVICE_DEAD_ORPHAN_PROTOTYPE_OMITTED";
            constexpr std::string_view prefix =
                "-- RENOVICE_DEAD_ORPHAN_PROTOTYPE_OMITTED: ";
            std::set<std::size_t> prototypes;
            for (const Token& token : tokens)
            {
                if (!token.text.starts_with(shape)) continue;
                if (!token.text.starts_with(prefix))
                    throw std::runtime_error(
                        std::string(source_label) + " has a malformed dead-orphan marker at line "
                        + std::to_string(token.line));
                const std::string_view digits(token.text.data() + prefix.size(),
                                              token.text.size() - prefix.size());
                if (digits.empty() || (digits.size() > 1 && digits.front() == '0'))
                    throw std::runtime_error(
                        std::string(source_label) + " has a non-canonical dead-orphan prototype id at line "
                        + std::to_string(token.line));
                std::size_t prototype = 0;
                for (const char digit : digits)
                {
                    if (digit < '0' || digit > '9')
                        throw std::runtime_error(
                            std::string(source_label) + " has a malformed dead-orphan prototype id at line "
                            + std::to_string(token.line));
                    const std::size_t value = static_cast<std::size_t>(digit - '0');
                    if (prototype > ((std::numeric_limits<std::size_t>::max)() - value) / 10)
                        throw std::runtime_error(
                            std::string(source_label) + " has an overflowing dead-orphan prototype id at line "
                            + std::to_string(token.line));
                    prototype = prototype * 10 + value;
                }
                if (!prototypes.insert(prototype).second)
                    throw std::runtime_error(
                        std::string(source_label) + " repeats dead-orphan prototype "
                        + std::to_string(prototype));
            }
            return prototypes;
        }

        [[nodiscard]] Json token_span(const Token& token)
        {
            return Json{
                {"offset", token.offset},
                {"length", token.length},
                {"line", token.line},
                {"column", token.column},
            };
        }

        [[nodiscard]] std::string logical_filename(const fs::path& path)
        {
            std::string name = path.filename().string();
            if (name.ends_with(".tmp")) name.erase(name.size() - 4);
            return name;
        }

        [[nodiscard]] Json file_identity(const fs::path& path, const std::string& text)
        {
            return Json{
                {"file", logical_filename(path)},
                {"bytes", text.size()},
                {"sha256", sha256_text(text)},
            };
        }

        void add_result_diagnostic(
            SemanticViewBuildResult& result,
            const Severity severity,
            std::string code,
            std::string message)
        {
            result.diagnostics.push_back(Diagnostic{
                severity,
                std::move(code),
                std::move(message),
            });
        }
    }

    SemanticViewBuildResult build_semantic_view(
        const fs::path& readable_source,
        const fs::path& fidelity_source,
        const fs::path& naming_map,
        const fs::path& call_map,
        const fs::path& closure_map,
        const fs::path& output_path)
    {
        SemanticViewBuildResult result;
        result.output_path = output_path;
        try
        {
            const std::string readable_text = read_text_file(readable_source);
            const std::string fidelity_text = read_text_file(fidelity_source);
            const std::string naming_text = read_text_file(naming_map);
            const std::string call_text = read_text_file(call_map);
            const std::string closure_text = read_text_file(closure_map);
            if (readable_text.empty() || fidelity_text.empty())
                throw std::runtime_error("readable and fidelity sources must both be non-empty");

            std::vector<NameRow> names = load_name_rows(naming_text);
            const std::vector<CallRow> calls = load_call_rows(call_text);
            const std::vector<ClosureRow> closures = load_closure_rows(closure_text);
            for (std::size_t index = 0; index < calls.size(); ++index)
            {
                validate_call_span(calls[index], readable_text, true, index + 2);
                validate_call_span(calls[index], fidelity_text, false, index + 2);
            }
            validate_non_crossing_call_spans(calls, true);
            validate_non_crossing_call_spans(calls, false);
            std::vector<Token> readable_tokens = tokenize_luau(readable_text);
            const std::vector<Token> fidelity_tokens = tokenize_luau(fidelity_text);
            const std::set<std::size_t> readable_omitted_orphans =
                load_omitted_dead_orphan_prototypes(readable_tokens, "readable source");
            const std::set<std::size_t> fidelity_omitted_orphans =
                load_omitted_dead_orphan_prototypes(fidelity_tokens, "fidelity source");
            if (readable_omitted_orphans != fidelity_omitted_orphans)
                throw std::runtime_error(
                    "readable and fidelity sources disagree on omitted dead-orphan prototypes");
            const std::size_t authorized_comment_insertions = remove_fixed_readable_preamble(
                readable_tokens, fidelity_tokens);

            std::unordered_map<std::string, std::size_t> name_by_canonical;
            name_by_canonical.reserve(names.size());
            for (std::size_t index = 0; index < names.size(); ++index)
                name_by_canonical.emplace(names[index].canonical, index);

            if (readable_tokens.size() != fidelity_tokens.size())
            {
                std::size_t divergence = 0;
                const std::size_t shared_count = (std::min)(
                    readable_tokens.size(), fidelity_tokens.size());
                for (; divergence < shared_count; ++divergence)
                {
                    const Token& fidelity = fidelity_tokens[divergence];
                    const Token& readable = readable_tokens[divergence];
                    if (fidelity.kind == readable.kind && fidelity.text == readable.text) continue;
                    const auto mapped = fidelity.kind == TokenKind::identifier
                        ? name_by_canonical.find(fidelity.text)
                        : name_by_canonical.end();
                    if (mapped != name_by_canonical.end()
                        && readable.kind == TokenKind::identifier
                        && !names[mapped->second].readable.empty()
                        && readable.text == names[mapped->second].readable) continue;
                    break;
                }
                std::string location;
                if (divergence < shared_count)
                {
                    const Token& fidelity = fidelity_tokens[divergence];
                    const Token& readable = readable_tokens[divergence];
                    location = "; first non-alias divergence at token "
                        + std::to_string(divergence) + ": fidelity '" + fidelity.text
                        + "' line " + std::to_string(fidelity.line) + ", readable '"
                        + readable.text + "' line " + std::to_string(readable.line);
                }
                throw std::runtime_error(
                    "token alignment failed: readable has "
                    + std::to_string(readable_tokens.size()) + " tokens while fidelity has "
                    + std::to_string(fidelity_tokens.size()) + location);
            }

            std::size_t alias_occurrences = 0;
            std::size_t retained_occurrences = 0;
            for (std::size_t index = 0; index < fidelity_tokens.size(); ++index)
            {
                const Token& fidelity = fidelity_tokens[index];
                const Token& readable = readable_tokens[index];
                const auto mapped = fidelity.kind == TokenKind::identifier
                    ? name_by_canonical.find(fidelity.text)
                    : name_by_canonical.end();

                if (fidelity.text != readable.text)
                {
                    if (fidelity.kind != TokenKind::identifier
                        || readable.kind != TokenKind::identifier)
                        throw std::runtime_error(
                            "non-identifier token changed at token " + std::to_string(index)
                            + " (fidelity line " + std::to_string(fidelity.line) + ")");
                    if (mapped == name_by_canonical.end())
                        throw std::runtime_error(
                            "identifier change is not authorized by a canonical identity at token "
                            + std::to_string(index) + ": " + fidelity.text + " -> " + readable.text);
                    NameRow& row = names[mapped->second];
                    if (row.readable.empty())
                        throw std::runtime_error(
                            "identifier change has no authorized readable alias at token "
                            + std::to_string(index) + ": " + fidelity.text + " -> " + readable.text);
                    if (readable.text != row.readable)
                        throw std::runtime_error(
                            "identifier change disagrees with (prototype, web) alias at token "
                            + std::to_string(index) + ": expected " + row.readable
                            + ", found " + readable.text);
                    row.occurrences.push_back(Json{
                        {"token", index},
                        {"rendering", "ALIAS_APPLIED"},
                        {"fidelity", token_span(fidelity)},
                        {"readable", token_span(readable)},
                    });
                    ++alias_occurrences;
                    continue;
                }

                if (fidelity.kind != readable.kind)
                    throw std::runtime_error(
                        "token kind changed without text change at token " + std::to_string(index));
                if (mapped != name_by_canonical.end())
                {
                    NameRow& row = names[mapped->second];
                    row.occurrences.push_back(Json{
                        {"token", index},
                        {"rendering", "CANONICAL_RETAINED"},
                        {"fidelity", token_span(fidelity)},
                        {"readable", token_span(readable)},
                    });
                    ++retained_occurrences;
                }
            }

            Json value_rows = Json::array();
            Json exports = Json::array();
            std::size_t sidecar_only = 0;
            for (const NameRow& row : names)
            {
                if (row.occurrences.empty()) ++sidecar_only;
                const std::string display_name = row.readable.empty()
                    ? row.canonical
                    : row.readable;
                value_rows.push_back(Json{
                    {"identity", {
                        {"prototype", row.prototype},
                        {"web", row.web},
                        {"canonical", row.canonical},
                    }},
                    {"readable", display_name},
                    {"readable_alias", row.readable.empty() ? Json(nullptr) : Json(row.readable)},
                    {"alias_status", row.readable.empty()
                        ? "UNKNOWN_CANONICAL_PRESERVED"
                        : "EVIDENCE_BACKED_ALIAS"},
                    {"confidence", row.confidence.empty() ? Json(nullptr) : Json(row.confidence)},
                    {"evidence", row.evidence.empty() ? Json(nullptr) : Json(row.evidence)},
                    {"semantic_type", row.semantic_type.empty() ? Json(nullptr) : Json(row.semantic_type)},
                    {"type_confidence", row.type_confidence.empty() ? Json(nullptr) : Json(row.type_confidence)},
                    {"type_evidence", row.type_evidence.empty() ? Json(nullptr) : Json(row.type_evidence)},
                    {"source_state", row.occurrences.empty() ? "SIDECAR_ONLY" : "SOURCE_MAPPED"},
                    {"occurrences", row.occurrences},
                });
                constexpr std::string_view export_prefix = "global store ";
                if (row.confidence == "EXACT_EXPORT" && row.evidence.starts_with(export_prefix))
                {
                    exports.push_back(Json{
                        {"exported_name", row.evidence.substr(export_prefix.size())},
                        {"identity", {
                            {"prototype", row.prototype},
                            {"web", row.web},
                            {"canonical", row.canonical},
                        }},
                        {"readable", row.readable},
                        {"confidence", row.confidence},
                        {"evidence", row.evidence},
                        {"source_occurrence_count", row.occurrences.size()},
                    });
                }
            }

            Json closure_rows = Json::array();
            std::size_t capture_count = 0;
            for (const ClosureRow& row : closures)
            {
                capture_count += row.capture_count;
                closure_rows.push_back(Json{
                    {"parent_prototype", row.parent_proto},
                    {"instruction", row.instruction},
                    {"opcode", row.op},
                    {"destination_register", row.destination_register},
                    {"operand_namespace", row.operand_namespace},
                    {"operand_index", row.operand_index},
                    {"target_prototype", row.target_proto},
                    {"target_params", row.target_params},
                    {"target_upvalues", row.target_upvalues},
                    {"target_maxstack", row.target_maxstack},
                    {"capture_count", row.capture_count},
                    {"captures", row.captures},
                    {"status", row.status},
                });
            }

            Json callsite_rows = Json::array();
            std::size_t registered_callsites = 0;
            std::size_t confirmed_callsites = 0;
            std::size_t unresolved_callsites = 0;
            std::size_t unregistered_callsites = 0;
            std::size_t ambiguous_callsites = 0;
            std::size_t observed_mismatch_callsites = 0;
            for (const CallRow& row : calls)
            {
                if (row.source_occurrence == 0)
                {
                    if (row.descriptor.empty()) ++unregistered_callsites;
                    else ++registered_callsites;
                    if (row.contract_status == "CONFIRMED") ++confirmed_callsites;
                    if (row.contract_status == "UNRESOLVED") ++unresolved_callsites;
                    if (row.contract_match == "AMBIGUOUS") ++ambiguous_callsites;
                    if (row.contract_match == "OBSERVED_MISMATCH") ++observed_mismatch_callsites;
                }
                callsite_rows.push_back(Json{
                    {"identity", {
                        {"prototype", row.prototype},
                        {"block", row.block},
                        {"instruction", row.instruction},
                        {"source_occurrence", row.source_occurrence},
                        {"effect_order", row.effect_order},
                    }},
                    {"kind", row.kind},
                    {"name", nullable_text(row.name)},
                    {"name_hash", nullable_text(row.name_hash)},
                    {"value_webs", {
                        {"callee", nullable_web(row.callee_web)},
                        {"receiver", nullable_web(row.receiver_web)},
                        {"arguments", web_list_json(row.argument_webs)},
                        {"results", web_list_json(row.result_webs)},
                    }},
                    {"receiver_semantics", {
                        {"type", nullable_text(row.receiver_type)},
                        {"confidence", nullable_text(row.receiver_type_confidence)},
                        {"evidence", nullable_text(row.receiver_type_evidence)},
                    }},
                    {"arity", {
                        {"explicit_arguments", nullable_web(row.explicit_argument_count)},
                        {"open_arguments", row.open_arguments},
                        {"results", nullable_web(row.result_count)},
                        {"open_results", row.open_results},
                    }},
                    {"contract", {
                        {"descriptor", nullable_text(row.descriptor)},
                        {"confidence", nullable_text(row.contract_confidence)},
                        {"status", nullable_text(row.contract_status)},
                        {"evidence", nullable_text(row.evidence)},
                        {"parameters", nullable_text(row.parameters)},
                        {"returns", nullable_text(row.returns)},
                        {"match", row.contract_match},
                        {"join_basis", row.descriptor_join},
                    }},
                    {"spans", {
                        {"readable", call_span_json(
                            row.readable_offset, row.readable_length,
                            row.readable_line, row.readable_column)},
                        {"fidelity", call_span_json(
                            row.fidelity_offset, row.fidelity_length,
                            row.fidelity_line, row.fidelity_column)},
                    }},
                });
            }

            result.token_count = fidelity_tokens.size();
            result.naming_row_count = names.size();
            result.alias_occurrence_count = alias_occurrences;
            result.canonical_retained_count = retained_occurrences;
            result.mapped_occurrence_count = alias_occurrences + retained_occurrences;
            result.sidecar_only_count = sidecar_only;
            result.closure_site_count = closures.size();
            result.closure_capture_count = capture_count;
            result.export_count = exports.size();
            result.omitted_dead_orphan_prototype_count = fidelity_omitted_orphans.size();
            result.api_callsite_count = registered_callsites + unregistered_callsites;
            result.api_call_expression_count = calls.size();
            result.registered_api_callsite_count = registered_callsites;
            result.confirmed_api_callsite_count = confirmed_callsites;
            result.unresolved_api_callsite_count = unresolved_callsites;
            result.unregistered_api_callsite_count = unregistered_callsites;
            result.ambiguous_api_callsite_count = ambiguous_callsites;
            result.observed_mismatch_api_callsite_count = observed_mismatch_callsites;

            Json omitted_dead_orphan_prototypes = Json::array();
            for (const std::size_t prototype : fidelity_omitted_orphans)
                omitted_dead_orphan_prototypes.push_back(prototype);

            const Json document{
                {"schema_version", 3},
                {"format", "RENOVICE_SEMANTIC_VIEW_V3"},
                {"status", "VERIFIED_PRESENTATION_ONLY"},
                {"span_encoding", "UTF8_BYTE_OFFSET_WITH_ONE_BASED_LINE_COLUMN"},
                {"policy", {
                    {"baseline_compiler_mutated", false},
                    {"readable_changes_permitted", "FIXED_PREAMBLE_AND_IDENTIFIER_ALIAS_ONLY"},
                    {"identity_authority", "PROTOTYPE_VALUE_WEB"},
                    {"unknown_policy", "PRESERVE_CANONICAL_OR_SIDECAR_ONLY"},
                    {"unreachable_prototype_policy", "OMIT_WITH_MATCHED_EXPLICIT_PROTOTYPE_IDS"},
                }},
                {"inputs", {
                    {"readable_source", file_identity(readable_source, readable_text)},
                    {"fidelity_source", file_identity(fidelity_source, fidelity_text)},
                    {"naming_map", file_identity(naming_map, naming_text)},
                    {"call_map", file_identity(call_map, call_text)},
                    {"closure_map", file_identity(closure_map, closure_text)},
                }},
                {"verification", {
                    {"token_stream_aligned", true},
                    {"token_count", result.token_count},
                    {"authorized_fixed_comment_insertions", authorized_comment_insertions},
                    {"authorized_identifier_differences", result.alias_occurrence_count},
                    {"unauthorized_identifier_differences", 0},
                    {"non_identifier_differences", 0},
                    {"mapped_occurrences", result.mapped_occurrence_count},
                    {"canonical_retained_occurrences", result.canonical_retained_count},
                    {"sidecar_only_rows", result.sidecar_only_count},
                    {"naming_rows", result.naming_row_count},
                    {"closure_sites", result.closure_site_count},
                    {"closure_captures", result.closure_capture_count},
                    {"exact_exports", result.export_count},
                    {"omitted_dead_orphan_prototype_count", result.omitted_dead_orphan_prototype_count},
                    {"api_callsites", result.api_callsite_count},
                    {"api_call_expressions", result.api_call_expression_count},
                    {"registered_api_callsites", result.registered_api_callsite_count},
                    {"confirmed_api_callsites", result.confirmed_api_callsite_count},
                    {"unresolved_api_callsites", result.unresolved_api_callsite_count},
                    {"unregistered_api_callsites", result.unregistered_api_callsite_count},
                    {"ambiguous_api_callsites", result.ambiguous_api_callsite_count},
                    {"observed_contract_mismatches", result.observed_mismatch_api_callsite_count},
                    {"confirmed_contract_violations", 0},
                }},
                {"omitted_dead_orphan_prototypes", std::move(omitted_dead_orphan_prototypes)},
                {"values", std::move(value_rows)},
                {"exports", std::move(exports)},
                {"closures", std::move(closure_rows)},
                {"callsites", std::move(callsite_rows)},
            };
            write_text_file(output_path, document.dump(2) + "\n");
            result.success = true;
            add_result_diagnostic(
                result,
                Severity::info,
                "SEMANTIC_VIEW_VERIFIED",
                "Verified " + std::to_string(result.token_count)
                    + " aligned tokens; " + std::to_string(result.alias_occurrence_count)
                    + " identifier aliases authorized by exact (prototype, value-web) identities; "
                    "zero unauthorized or non-identifier differences; "
                    + std::to_string(result.api_callsite_count)
                    + " instruction-addressed API callsites projected as "
                    + std::to_string(result.api_call_expression_count)
                    + " source expressions with validated readable/fidelity spans; "
                    + std::to_string(result.confirmed_api_callsite_count)
                    + " confirmed contract matches and zero confirmed contract violations");
        }
        catch (const std::exception& exception)
        {
            std::error_code error;
            fs::remove(output_path, error);
            add_result_diagnostic(
                result,
                Severity::error,
                "SEMANTIC_VIEW_REJECTED",
                exception.what());
        }
        return result;
    }
}
