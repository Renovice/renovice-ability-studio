#!/usr/bin/env python3
"""Deterministic offline gates for the Elite Sanctuary Onslaught no-rank addon (2026-09-29).

Usage:
  python run_gates.py <stock_MissionRequirementUtilities.lua_B> <installed_addon.lua_B> <out_dir>
                      [--derecomp <derecomp.exe>]

Inputs are read-only:
  * stock /Lotus/Interface/MissionRequirementUtilities.lua from the 44.0.2 cache
    (sha256 6801f711...1d25, live body key 64d11e6973afa4b1, 28 prototypes);
  * the installed 64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.lua_B
    (sha256 86eacb89...2ed1), which is also the rollback;
  * the 2026-09-13 baseline source in the bootstrapper deployment record (read only).
The default compiler is the committed U44 raw-hash toolchain build (derecomp.head.exe,
sha256 c1672d8d...7c58; it needs luau-compile.exe beside it). Everything is written to
<out_dir>. Exit code 0 only when every gate passes.
"""
import hashlib, json, re, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
FIX = HERE.parent
WORKSPACE = next(p for p in Path(__file__).resolve().parents if (p / "WORKSPACE.json").is_file())
TOOLCHAIN = WORKSPACE / "repos" / "toolchains" / "de-luau-toolchain"
LUAU = TOOLCHAIN / "bin" / "luau.exe"
SOURCE = FIX / "64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.luau"
BASELINE_SOURCE = (WORKSPACE / "repos" / "runtime" / "bootstrapper-runtime" / "RENOVICE_DEPLOYMENTS"
                   / "ELITE_SANCTUARY_NO_RANK_CALLSITE_FIX_2026-09-13" / "source"
                   / "9dfe563d26eb6527.EliteSanctuaryNoRank.target.addon.luau")

EXPECTED = {
    "stock_sha256": "6801f711c598efbce3b57ca50f15e45b50abaf803abe1c72694f3b962e431d25",
    "installed_addon_sha256": "86eacb891078aeb40b054ae2041ea29a23c3f55bc636612af35bd133d9672ed1",
    "derecomp_sha256": "c1672d8d70e44bf7001a68f873f229714f5afdefb0b93c8558b6abb49e187c58",
    "luau_sha256": "a0f4edd1e80ef7d7afd223c061e1f3b753398152cb732abf57328a93b375053e",
}
# U44 native-name hashes (FNV-1a, NOT, rotl17, seed 0x768e5ed0).
H_TOSTRING = "cb160055"


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(args, **kw):
    return subprocess.run([str(a) for a in args], capture_output=True, text=True, **kw)


def last_line(r):
    text = (r.stdout + r.stderr).strip()
    return text.splitlines()[-1] if text else ""


def listing(ir_text):
    """{proto: {"k": [const text], "i": {index: (op, text)}}} from a derecomp ir-u44 listing."""
    protos, cur = {}, None
    for line in ir_text.splitlines():
        m = re.match(r"== proto\[(\d+)\]", line)
        if m:
            cur = protos.setdefault(int(m.group(1)), {"k": [], "i": {}})
            continue
        if cur is None:
            continue
        m = re.match(r"\s*k\[\d+\]\s+(.*)$", line)
        if m:
            cur["k"].append(m.group(1).strip())
            continue
        m = re.match(r"\s*\[\s*(\d+)\]\s+(\S+)\s*(.*)$", line)
        if m:
            cur["i"][int(m.group(1))] = (m.group(2), m.group(3).strip())
    return protos


def namecalls(protos, method):
    return sorted((p, i) for p, d in protos.items() for i, (op, t) in d["i"].items()
                  if op == "NAMECALL" and t.endswith(":" + method))


def classed_constants(protos):
    """Module-level constant classes from an ir-u44 listing.

    const-identity compares prototypes by index and stops at the smaller prototype count,
    so a source that adds helper prototypes shifts every later index. This set view is
    index-free: quoted k[] entries are tag-3 strings, bare identifiers are tag-1 native-name
    hashes (the listing resolves them through the U44 namebase)."""
    strings, hashes = set(), set()
    for d in protos.values():
        for k in d["k"]:
            if k.startswith('"'):
                strings.add(k)
            elif re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", k) and k not in ("nil", "true", "false"):
                hashes.add(k)
    return strings, hashes


def main():
    args = sys.argv[1:]
    derecomp = TOOLCHAIN / "bin" / "derecomp.head.exe"
    if "--derecomp" in args:
        i = args.index("--derecomp"); derecomp = Path(args[i + 1]); del args[i:i + 2]
    stock, installed, out = Path(args[0]), Path(args[1]), Path(args[2])
    out.mkdir(parents=True, exist_ok=True)
    gates, facts = {}, {}

    def gate(name, ok, detail=""):
        gates[name] = {"pass": bool(ok), "detail": detail}
        print(("PASS " if ok else "FAIL ") + name + (": " + detail if detail else ""))

    gate("input.stock-identity", sha(stock) == EXPECTED["stock_sha256"], sha(stock))
    gate("input.installed-addon-identity", sha(installed) == EXPECTED["installed_addon_sha256"], sha(installed))
    gate("tool.derecomp-identity", sha(derecomp) == EXPECTED["derecomp_sha256"], sha(derecomp))
    gate("tool.luau-identity", sha(LUAU) == EXPECTED["luau_sha256"], sha(LUAU))

    # 1. Stock ownership and callsite numbering as the runtime reports it (NAMECALL index).
    ir = run([derecomp, "ir-u44", stock]).stdout
    (out / "stock.ir-u44.txt").write_text(ir, encoding="utf-8")
    sp = listing(ir)
    gate("stock.prototype-count-28", len(sp) == 28, f"protos={len(sp)} (live module.graph nodes=28)")
    calls = namecalls(sp, "BuildMissionForLocation")
    gate("stock.BuildMissionForLocation-namecalls", calls == [(21, 324), (25, 9), (26, 3)], str(calls))
    p25, p21 = sp[25]["i"], sp[21]["i"]
    gate("stock.p25-TryLaunchOnslaught-9-then-CALL-10",
         p25.get(10, ("",))[0] == "CALL"
         and p25.get(3, ("", ""))[1].endswith("SANCTUARY_ONSLAUGHT_CHALLENGE_NODE")
         and p25.get(4, ("", ""))[1].endswith("SANCTUARY_ONSLAUGHT_NODE"),
         "Ternary(isElite, SolNode802, SolNode801) -> NAMECALL 9 -> CALL 10 -> checker")
    gate("stock.p21-fallback-324-Symbol-argument",
         p21.get(325, ("",))[0] == "CALL" and p21.get(321, ("", ""))[1].endswith("<- Symbol"),
         f"321={p21.get(321)} 325={p21.get(325)}")
    k21 = sp[21]["k"]
    gate("stock.p21-owns-MissionMaxSuitRequired",
         '"/Lotus/Language/Menu/MissionMaxSuitRequired"' in k21
         and any(op == "GETFIELD" and t.endswith(".maxSuitReq") for op, t in p21.values()),
         "p21 reads mission.maxSuitReq and returns the dialog key")
    facts["stock_callsites"] = calls
    facts["live_anchor"] = ("renovice_source.log pid 11584: native.call.before BuildMissionForLocation "
                            "prototype=25 instruction=9 and prototype=21 instruction=324 for key 64d11e6973afa4b1")

    # 2. Baseline: the 2026-09-13 source is the installed file and filters on CALL 10.
    base = out / "baseline.rebuild.lua_B"
    rb = run([derecomp, "recompile-u44", BASELINE_SOURCE, base])
    gate("baseline.source-reproduces-installed-bytes",
         rb.returncode == 0 and base.read_bytes() == installed.read_bytes(), sha(base) if base.exists() else "")
    ir_inst = run([derecomp, "ir-u44", installed]).stdout
    (out / "installed.ir-u44.txt").write_text(ir_inst, encoding="utf-8")
    ip = listing(ir_inst)
    inst_loadk = [t for d in ip.values() for op, t in d["i"].values() if op == "LOADK"]
    gate("baseline.installed-filters-p25-i10-only",
         any(t.endswith("<- 25") for t in inst_loadk) and any(t.endswith("<- 10") for t in inst_loadk)
         and not any(t.endswith("<- 9") or t.endswith("<- 324") for t in inst_loadk),
         "installed addon returns early unless instruction == 10; the runtime reports 9")

    # 3. Real-source contract test under upstream Luau (IsNull stubbed; Symbol modelled by __tostring).
    harness = ("IsNull = function(v) return v == nil end\n"
               "local addon = (function()\n" + SOURCE.read_text(encoding="utf-8") + "\nend)()\n"
               + (HERE / "contract_assertions.luau").read_text(encoding="utf-8"))
    (out / "contract_harness.luau").write_text(harness, encoding="utf-8")
    r = run([LUAU, out / "contract_harness.luau"])
    gate("source.contract-test", r.returncode == 0 and "PASS contract" in r.stdout, (r.stdout + r.stderr).strip())
    # Negative control: the same assertions must reject the installed (baseline) source.
    neg = harness.replace(SOURCE.read_text(encoding="utf-8"), BASELINE_SOURCE.read_text(encoding="utf-8"))
    (out / "contract_harness.baseline.luau").write_text(neg, encoding="utf-8")
    rn = run([LUAU, out / "contract_harness.baseline.luau"])
    gate("source.contract-test-rejects-baseline",
         rn.returncode != 0 and "elite onslaught p25 i9 must clear" in (rn.stdout + rn.stderr),
         "baseline fails at the p25/i9 assertion")

    # 4. U44 raw-hash compile, determinism, reparse and DE container roundtrip.
    cand, cand2 = out / "candidate.lua_B", out / "candidate.2.lua_B"
    r1 = run([derecomp, "recompile-u44", SOURCE, cand])
    r2 = run([derecomp, "recompile-u44", SOURCE, cand2])
    gate("build.recompile-u44", r1.returncode == 0 and r2.returncode == 0
         and "re-parses=yes" in (r1.stdout + r1.stderr), last_line(r1))
    gate("build.deterministic", cand.read_bytes() == cand2.read_bytes(), sha(cand))
    rt = run([derecomp, "de-roundtrip", cand])
    gate("build.de-roundtrip", rt.returncode == 0 and "FULL BODY identical: True" in rt.stdout, last_line(rt))

    # 5. Compiler-closed stability: decompile-mod-u44 -> recompile-u44 keeps every constant class.
    dec, cand3, dec2, cand4 = (out / "candidate.dec.luau", out / "candidate.pass2.lua_B",
                               out / "candidate.pass2.dec.luau", out / "candidate.pass3.lua_B")
    run([derecomp, "decompile-mod-u44", cand, dec]); run([derecomp, "recompile-u44", dec, cand3])
    run([derecomp, "decompile-mod-u44", cand3, dec2]); run([derecomp, "recompile-u44", dec2, cand4])
    ci_rt = run([derecomp, "const-identity", cand, cand3, "--u44"])
    (out / "const-identity.roundtrip.txt").write_text(ci_rt.stdout + ci_rt.stderr, encoding="utf-8")
    gate("gate.const-identity-roundtrip", ci_rt.returncode == 0 and "verdict=PASS" in ci_rt.stdout, last_line(ci_rt))
    gate("gate.compiler-closed-fixed-point", cand3.exists() and cand4.exists()
         and cand3.read_bytes() == cand4.read_bytes(), f"pass2={sha(cand3)} pass3={sha(cand4)}")

    # 6. CONST-ID against the live-loaded installed addon: no hash/string class swap, and the
    #    module-level delta is exactly the new node test (tostring hash + two node strings).
    ci = run([derecomp, "const-identity", installed, cand, "--u44"])
    (out / "const-identity.vs-installed.txt").write_text(ci.stdout + ci.stderr, encoding="utf-8")
    swaps = re.search(r"hash_string_class_swaps=(\d+)", ci.stdout)
    gate("gate.const-identity-vs-installed-no-class-swap", swaps is not None and swaps.group(1) == "0",
         swaps.group(0) if swaps else "no CLASS_SWAPS line")
    ir_cand = run([derecomp, "ir-u44", cand]).stdout
    (out / "candidate.ir-u44.txt").write_text(ir_cand, encoding="utf-8")
    cp = listing(ir_cand)
    (cs, ch), (is_, ih) = classed_constants(cp), classed_constants(ip)
    delta = {"strings_added": sorted(cs - is_), "strings_removed": sorted(is_ - cs),
             "hashes_added": sorted(ch - ih), "hashes_removed": sorted(ih - ch),
             "string_hash_overlap": sorted({s.strip('"') for s in cs} & ch)}
    gate("gate.constant-class-delta-vs-installed",
         delta == {"strings_added": ['"SolNode801"', '"SolNode802"'], "strings_removed": [],
                   "hashes_added": ["tostring"], "hashes_removed": [], "string_hash_overlap": []},
         json.dumps(delta))
    facts["tostring_hash_u44"] = H_TOSTRING  # stock MRU uses the same hashed tostring (FASTCALL 63)

    # 7. Every opcode the candidate uses is already used by the stock module or the live-loaded addon.
    ops = lambda ps: {op for d in ps.values() for op, _ in d["i"].values()}
    missing = ops(cp) - ops(sp) - ops(ip)
    gate("gate.opcode-coverage", not missing, f"candidate_ops={len(ops(cp))} missing={sorted(missing)}")
    fast = sorted({t for d in cp.values() for op, t in d["i"].values() if op == "FASTCALL1"})
    facts["candidate_fastcalls"] = fast  # A=40 type, A=63 tostring (both used by U44 stock)

    facts.update({"candidate_sha256": sha(cand), "candidate_size": cand.stat().st_size,
                  "source_sha256": sha(SOURCE), "derecomp": str(derecomp)})
    result = {"gates": gates, "facts": facts, "all_pass": all(g["pass"] for g in gates.values())}
    (out / "gates.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print("ALL GATES PASS" if result["all_pass"] else "GATES FAILED")
    return 0 if result["all_pass"] else 1


if __name__ == "__main__":
    sys.exit(main())
