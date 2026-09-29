#!/usr/bin/env python3
"""NAMECALL callsite audit and gate for RENOVICE target addons (2026-09-29).

Since bootstrapper V66 (2026-09-13) the runtime reports a native call at the
logical index of the NAMECALL that names the method
(`native_callsite_instruction_from_saved_pc`, injection_core.hpp): a CALL whose
previous instruction is NAMECALL is mapped back one instruction. A filter that
tests the CALL index (NAMECALL + 1) never matches.

This tool is read-only with respect to its inputs. It needs only derecomp
(`ir`/`ir-u44`, `decompile-mod`/`decompile-mod-u44`).

Subcommands
  check     one site:   --stock S --profile u43|u44 --prototype P --instruction I --method M
  addon     one addon:  <addon.lua_B> [--stock S --profile u43|u44]  (stock resolved by body key otherwise)
  scan      many:       --out DIR  <addon.lua_B | directory> ...   (dedupes by SHA-256)

Classification of one (prototype, instruction, method) site:
  OK              instruction is `NAMECALL :method` and the next instruction is CALL
  OFF-BY-ONE      instruction is the CALL directly after `NAMECALL :method` (NAMECALL + 1)
  OTHER-MISMATCH  anything else (wrong method, wrong prototype, index out of range)

Exit code of `check`/`addon`: 0 only when every site is OK.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

WORKSPACE = next(p for p in Path(__file__).resolve().parents if (p / "WORKSPACE.json").is_file())
TOOLCHAIN = WORKSPACE / "repos" / "toolchains" / "de-luau-toolchain"
# Committed U44 raw-hash toolchain (0299da9); the same binary the Mallet and
# Elite Sanctuary fixes used.
DERECOMP = TOOLCHAIN / "bin" / "derecomp.head.exe"
STOCK_DIRS = {
    "u44": [TOOLCHAIN / "work" / "u44-rawhash-2026-09-29" / "stock",          # 44.0.2, 5,474 modules
            WORKSPACE / "shared" / "corpus" / "de-luau-u44.0.2-authoring",
            WORKSPACE / "shared" / "corpus" / "de-luau-u44-authoring"],       # 44.0 mission subset
    "u43": [WORKSPACE / "shared" / "corpus" / "de-luau-stock"],              # U43, 5,386 modules
}
FNV_BASIS = 1469598103934665603   # replacements_core.hpp deployed_body_key_basis
FNV_PRIME = 1099511628211
# Hook shapes whose callback receives (prototype, instruction, ...) and whose
# native name is fixed by the hook itself.
FIXED_NATIVE = {"transformFloatArgument": "PushFloatArg"}


def sha256(path: Path) -> str:
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def body_key(data: bytes) -> str:
    h = FNV_BASIS
    for byte in data:
        h = ((h ^ byte) * FNV_PRIME) & 0xFFFFFFFFFFFFFFFF
    return f"{h:016x}"


def run(args):
    return subprocess.run([str(a) for a in args], capture_output=True, text=True,
                          encoding="utf-8", errors="replace")


# --------------------------------------------------------------------------- stock
_IR_CACHE: dict[tuple[str, str], dict[int, dict[int, tuple[str, str]]]] = {}


def ir_listing(stock: Path, profile: str) -> dict[int, dict[int, tuple[str, str]]]:
    """{prototype: {logical_index: (opcode, operand text)}} from derecomp ir/ir-u44."""
    key = (str(stock), profile)
    if key in _IR_CACHE:
        return _IR_CACHE[key]
    r = run([DERECOMP, "ir-u44" if profile == "u44" else "ir", stock])
    if r.returncode != 0:
        raise RuntimeError(f"derecomp ir failed for {stock}: {r.stderr.strip()[:300]}")
    protos: dict[int, dict[int, tuple[str, str]]] = {}
    current = None
    for line in r.stdout.splitlines():
        m = re.match(r"== proto\[(\d+)\]", line)
        if m:
            current = protos.setdefault(int(m.group(1)), {})
            continue
        m = re.match(r"\s*\[\s*(\d+)\]\s+(\S+)\s*(.*)$", line) if current is not None else None
        if m:
            current[int(m.group(1))] = (m.group(2), m.group(3).strip())
    _IR_CACHE[key] = protos
    return protos


def namecall_method(entry) -> str | None:
    if entry is None or entry[0] != "NAMECALL":
        return None
    m = re.search(r":(\S+)$", entry[1])
    return m.group(1) if m else None


def method_namecalls(ir, method: str):
    return [(p, i) for p, body in sorted(ir.items()) for i, e in sorted(body.items())
            if namecall_method(e) == method]


def classify_site(ir, prototype: int, instruction: int, method: str) -> dict:
    body = ir.get(prototype)
    sites = method_namecalls(ir, method)
    result = {"prototype": prototype, "instruction": instruction, "method": method,
              "method_namecalls": [f"p{p}/i{i}" for p, i in sites]}
    if body is None:
        return {**result, "class": "OTHER-MISMATCH", "reason": f"prototype {prototype} does not exist"}
    here = body.get(instruction)
    result["at"] = f"{here[0]} {here[1]}".strip() if here else None
    if namecall_method(here) == method:
        nxt = body.get(instruction + 1)
        if nxt and nxt[0] == "CALL":
            return {**result, "class": "OK", "reason": f"NAMECALL :{method} at {instruction}, CALL at {instruction + 1}"}
        return {**result, "class": "OTHER-MISMATCH",
                "reason": f"NAMECALL :{method} at {instruction} is not followed by CALL ({nxt})"}
    prev = body.get(instruction - 1)
    if here and here[0] == "CALL" and namecall_method(prev) == method:
        return {**result, "class": "OFF-BY-ONE", "expected_instruction": instruction - 1,
                "reason": f"{instruction} is the CALL; the runtime reports NAMECALL :{method} at {instruction - 1}"}
    return {**result, "class": "OTHER-MISMATCH",
            "reason": f"instruction {instruction} is {result['at']!r}, not NAMECALL :{method}"}


_KEYMAP: dict[str, tuple[str, Path]] | None = None


def keymap(cache: Path | None = None) -> dict[str, tuple[str, Path]]:
    """body key -> (profile, stock file) over every configured stock directory."""
    global _KEYMAP
    if _KEYMAP is not None:
        return _KEYMAP
    if cache and cache.is_file():
        raw = json.loads(cache.read_text(encoding="utf-8"))
        _KEYMAP = {k: (v[0], Path(v[1])) for k, v in raw.items()}
        return _KEYMAP
    out: dict[str, tuple[str, Path]] = {}
    for profile, dirs in STOCK_DIRS.items():
        for d in dirs:
            if not d.is_dir():
                continue
            for f in sorted(d.glob("*.lua_B")):
                out.setdefault(body_key(f.read_bytes()), (profile, f))
    _KEYMAP = out
    if cache:
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(json.dumps({k: [v[0], str(v[1])] for k, v in sorted(out.items())}, indent=0),
                         encoding="utf-8")
    return out


# --------------------------------------------------------------------------- addon extraction
def decompile(addon: Path, profile_hint: str | None):
    order = [profile_hint] if profile_hint else []
    order += [p for p in ("u44", "u43") if p not in order]
    last = ""
    for profile in order:
        r = run([DERECOMP, "decompile-mod-u44" if profile == "u44" else "decompile-mod", addon])
        if r.returncode == 0 and "function" in r.stdout:
            return profile, r.stdout
        last = (r.stdout + r.stderr)[-300:]
    raise RuntimeError(f"cannot decompile {addon}: {last}")


def _function_blocks(text: str):
    """Yield (name, def_line_index, params, body_lines) for every `X = function(...)` in
    derecomp module output (indentation-delimited)."""
    lines = text.splitlines()
    for idx, line in enumerate(lines):
        m = re.match(r"^(\s*)(?:local\s+)?(\w+) = function\(([^)]*)\)\s*$", line)
        if not m:
            continue
        indent = m.group(1)
        end = idx + 1
        while end < len(lines) and not re.match(rf"^{indent}end\b", lines[end]):
            end += 1
        params = [p.strip() for p in m.group(3).split(",") if p.strip()]
        yield m.group(2), idx, params, lines[idx + 1:end]


def _param_constant_tests(body_lines, param: str):
    """Ordered (line_no, constant) where `param` is compared against an integer constant."""
    tests = []
    const_of: dict[str, tuple[int, int]] = {}
    alias_of: dict[str, str] = {}
    for n, line in enumerate(body_lines):
        s = line.strip()
        m = re.match(r"^(?:local\s+)?(\w+) = (-?\d+)$", s)
        if m:
            const_of[m.group(1)] = (n, int(m.group(2)))
            alias_of.pop(m.group(1), None)
            continue
        m = re.match(r"^(?:local\s+)?(\w+) = (\w+)$", s)
        if m:
            alias_of[m.group(1)] = m.group(2)
            continue
        m = re.match(r"^if (\w+) (==|~=) (\w+) then$", s)
        if m:
            a, b = m.group(1), m.group(3)
            for x, y in ((a, b), (b, a)):
                if (x == param or alias_of.get(x) == param) and y in const_of:
                    tests.append((n, const_of[y][1]))
        m = re.search(rf"\b{re.escape(param)} (==|~=) (\d+)\b", s)       # readable source form
        if m:
            tests.append((n, int(m.group(2))))
    return tests


def _hook_bindings(text: str):
    """Resolve hooks.nativeCalls[Method].{before,after} and hooks.transformFloatArgument
    to function definition line indexes, following derecomp's register reuse."""
    lines = text.splitlines()
    fn_def: dict[str, int] = {}
    tables: dict[str, dict] = {}
    bindings = []
    for idx, line in enumerate(lines):
        s = line.strip()
        m = re.match(r"^(?:local\s+)?(\w+) = function\(", s)
        if m:
            fn_def[m.group(1)] = idx
            tables.pop(m.group(1), None)
            continue
        m = re.match(r"^(?:local\s+)?(\w+) = \{(.*)\}$", s)
        if m:
            tables[m.group(1)] = {"_fields": {}}
            fn_def.pop(m.group(1), None)
            continue
        m = re.match(r"^(\w+)\.(\w+) = (\w+)$", s)
        if not m:
            continue
        holder, field, value = m.groups()
        tbl = tables.setdefault(holder, {"_fields": {}})
        if value in fn_def:
            tbl["_fields"][field] = ("fn", fn_def[value])
        elif value in tables:
            tbl["_fields"][field] = ("tbl", tables[value])
        if field == "transformFloatArgument" and value in fn_def:
            bindings.append(("transformFloatArgument", "PushFloatArg", "call", fn_def[value]))
        if field == "nativeCalls" and value in tables:
            for method, (kind, spec) in tables[value]["_fields"].items():
                if kind != "tbl":
                    continue
                for phase, (k2, fn) in spec["_fields"].items():
                    if k2 == "fn":
                        bindings.append((f"nativeCalls.{method}.{phase}", method, phase, fn))
    return bindings


def _readable_bindings(text: str):
    """Fallback for readable sources: `Method = { before = fnName, after = fnName }` and
    `transformFloatArgument = fnName`."""
    names = {}
    for m in re.finditer(r"local function (\w+)\(", text):
        names[m.group(1)] = text[:m.start()].count("\n")
    out = []
    nc = re.search(r"nativeCalls\s*=\s*\{(.*?)\n\s*\},?\s*\n", text, re.S)
    if nc:
        for mm in re.finditer(r"(\w+)\s*=\s*\{([^{}]*)\}", nc.group(1)):
            for ph in re.finditer(r"(before|after)\s*=\s*(\w+)", mm.group(2)):
                if ph.group(2) in names:
                    out.append((f"nativeCalls.{mm.group(1)}.{ph.group(1)}", mm.group(1), ph.group(1), names[ph.group(2)]))
    t = re.search(r"transformFloatArgument\s*=\s*(\w+)", text)
    if t and t.group(1) in names:
        out.append(("transformFloatArgument", "PushFloatArg", "call", names[t.group(1)]))
    return out


def extract_filters(text: str):
    """[(hook, method, [(prototype, instruction)])] for every instruction-addressed hook."""
    blocks = {idx: (name, params, body) for name, idx, params, body in _function_blocks(text)}
    for m in re.finditer(r"local function (\w+)\(([^)]*)\)", text):     # readable sources
        idx = text[:m.start()].count("\n")
        if idx in blocks:
            continue
        rest = text[m.end():].splitlines()
        body = []
        for line in rest[1:]:
            if re.match(r"^end\b", line):
                break
            body.append(line)
        blocks[idx] = (m.group(1), [p.strip() for p in m.group(2).split(",")], body)
    bindings = _hook_bindings(text) or _readable_bindings(text)
    defs_by_name: dict[str, list[int]] = {}
    for idx, (name, _, _) in sorted(blocks.items()):
        defs_by_name.setdefault(name, []).append(idx)

    def site_pairs(fn_idx: int, depth: int = 0):
        """(prototype tests, instruction tests) of one callback, following one delegation
        such as `if not isOnslaughtBuild(prototype, instruction, arguments)` (depth <= 2)."""
        _, params, body = blocks[fn_idx]
        if len(params) < 2:
            return [], []
        protos = _param_constant_tests(body, params[0])
        instrs = _param_constant_tests(body, params[1])
        if depth < 2:
            alias = {params[0]: params[0], params[1]: params[1]}
            callee_of: dict[str, str] = {}
            for n, line in enumerate(body):
                s = line.strip()
                m = re.match(r"^(?:local\s+)?(\w+) = (\w+)$", s)
                if m and m.group(2) in alias:
                    alias[m.group(1)] = alias[m.group(2)]
                elif m and m.group(2) in defs_by_name:
                    callee_of[m.group(1)] = m.group(2)
                for c in re.finditer(r"(\w+)\(\s*(\w+)\s*,\s*(\w+)", s):
                    fn, a0, a1 = c.groups()
                    fn = callee_of.get(fn, fn)
                    if (alias.get(a0) == params[0] and alias.get(a1) == params[1]
                            and fn in defs_by_name):
                        before = [d for d in defs_by_name[fn] if d < fn_idx] or defs_by_name[fn]
                        p2, i2 = site_pairs(before[-1], depth + 1)
                        # The callee keeps its own line order; a band offset keeps its
                        # prototype/instruction pairing separate from the caller's.
                        band = 1_000_000 * (depth + 1)
                        protos.extend((band + ln, v) for ln, v in p2)
                        instrs.extend((band + ln, v) for ln, v in i2)
        return protos, instrs

    result = []
    for hook, method, phase, fn_idx in bindings:
        if fn_idx not in blocks:
            continue
        protos, instrs = site_pairs(fn_idx)
        pairs = []
        for n, instr in instrs:
            band = n // 1_000_000
            owner = [p for (pn, p) in protos if pn <= n and pn // 1_000_000 == band]
            pairs.append((owner[-1] if owner else None, instr))
        result.append({"hook": hook, "method": method, "phase": phase, "sites": pairs,
                       "prototype_only": sorted({p for _, p in protos}) if not pairs else []})
    return result


def audit_addon(addon: Path, stock: Path | None = None, profile: str | None = None,
                keys: dict | None = None) -> dict:
    name = addon.name
    key = name[:16].lower() if re.match(r"^[0-9a-fA-F]{16}", name) else None
    if stock is None and key and keys is not None and key in keys:
        profile, stock = keys[key]
        if ".u44." in name.lower() and profile != "u44":
            # A U44 port that kept its U43 key in the file name: the key names the
            # wrong stock module, so the site cannot be resolved by name.
            profile, stock = None, None
    if addon.suffix.lower() == ".luau":
        # Sources are compiled with the target's profile and then read through the same
        # decompiler as deployed bytecode, so one extractor serves both.
        import tempfile
        with tempfile.TemporaryDirectory() as tmp:
            built = Path(tmp) / "addon.lua_B"
            r = run([DERECOMP, "recompile-u44" if (profile or "u44") == "u44" else "recompile", addon, built])
            if r.returncode != 0 or not built.is_file():
                raise RuntimeError(f"cannot compile {addon}: {(r.stdout + r.stderr)[-300:]}")
            dprofile, text = decompile(built, profile or "u44")
    else:
        dprofile, text = decompile(addon, profile)
    filters = extract_filters(text)
    out = {"addon": str(addon), "sha256": sha256(addon), "body_key": key,
           "stock": str(stock) if stock else None, "stock_profile": profile,
           "stock_sha256": sha256(stock) if stock else None,
           "decompile_profile": dprofile, "hooks": []}
    ir = ir_listing(stock, profile) if stock else None
    for f in filters:
        rows = []
        for proto, instr in f["sites"]:
            if ir is None or proto is None:
                rows.append({"prototype": proto, "instruction": instr, "method": f["method"],
                             "class": "UNRESOLVED", "reason": "no stock module for this body key" if ir is None
                             else "instruction test without a prototype test"})
            else:
                rows.append(classify_site(ir, proto, instr, f["method"]))
        out["hooks"].append({**f, "sites": rows})
    classes = [r["class"] for h in out["hooks"] for r in h["sites"]]
    out["verdict"] = ("NO-INSTRUCTION-FILTER" if not classes else
                      "OK" if all(c == "OK" for c in classes) else
                      "OFF-BY-ONE" if "OFF-BY-ONE" in classes else
                      "OTHER-MISMATCH" if "OTHER-MISMATCH" in classes else "UNRESOLVED")
    return out


# --------------------------------------------------------------------------- CLI
def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("check")
    c.add_argument("--stock", required=True, type=Path)
    c.add_argument("--profile", required=True, choices=["u43", "u44"])
    c.add_argument("--prototype", required=True, type=int)
    c.add_argument("--instruction", required=True, type=int)
    c.add_argument("--method", required=True)
    a = sub.add_parser("addon")
    a.add_argument("addon", type=Path)
    a.add_argument("--stock", type=Path)
    a.add_argument("--profile", choices=["u43", "u44"])
    a.add_argument("--keymap", type=Path)
    s = sub.add_parser("scan")
    s.add_argument("--out", required=True, type=Path)
    s.add_argument("--keymap", type=Path)
    s.add_argument("--list", type=Path, help="text file with one addon path per line")
    s.add_argument("paths", nargs="*", type=Path)
    ns = ap.parse_args(argv)

    if ns.cmd == "check":
        row = classify_site(ir_listing(ns.stock, ns.profile), ns.prototype, ns.instruction, ns.method)
        print(json.dumps(row, indent=2))
        return 0 if row["class"] == "OK" else 1
    if ns.cmd == "addon":
        keys = None if ns.stock else keymap(ns.keymap)
        res = audit_addon(ns.addon, ns.stock, ns.profile, keys)
        print(json.dumps(res, indent=2))
        return 0 if res["verdict"] in ("OK", "NO-INSTRUCTION-FILTER") else 1
    # scan
    keys = keymap(ns.keymap)
    files = []
    if ns.list:
        files += [p if p.is_absolute() else WORKSPACE / p
                  for p in (Path(x.strip()) for x in ns.list.read_text(encoding="utf-8").splitlines() if x.strip())]
    for p in ns.paths:
        files += sorted(p.rglob("*.lua_B")) if p.is_dir() else [p]
    seen, results = {}, []
    for f in files:
        if not f.is_file():   # transient test trees can disappear between listing and scan
            results.append({"addon": str(f), "sha256": None, "verdict": "MISSING", "hooks": [], "copies": [str(f)]})
            continue
        h = sha256(f)
        if h in seen:
            seen[h]["copies"].append(str(f))
            continue
        try:
            res = audit_addon(f, keys=keys)
        except Exception as exc:  # recorded, never hidden
            res = {"addon": str(f), "sha256": h, "verdict": "ERROR", "error": str(exc)[:400], "hooks": []}
        res["copies"] = [str(f)]
        seen[h] = res
        results.append(res)
    ns.out.mkdir(parents=True, exist_ok=True)
    (ns.out / "scan.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    summary = {}
    for r in results:
        summary[r["verdict"]] = summary.get(r["verdict"], 0) + 1
    print(json.dumps({"unique_addons": len(results), "files": len(files), "verdicts": summary}, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
