#!/usr/bin/env python3
"""Deterministic offline gates for the Mallet threat callsite fix (2026-09-29).

Usage:
  python run_gates.py <stock_BardMusic.lua_B> <installed_addon.lua_B> <out_dir>

Inputs are read-only. The stock module is the 44.0.2 BardMusic.lua extracted from the
Steam cache (sha256 c713c4d6...299f); the installed addon is the currently deployed
ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B (sha256 0acbfea2...aae5).
Everything is written to <out_dir>. Exit code 0 only when every gate passes.
"""
import hashlib, json, re, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
FIX = HERE.parent
WORKSPACE = next(p for p in Path(__file__).resolve().parents if (p / "WORKSPACE.json").is_file())
TOOLCHAIN = WORKSPACE / "repos" / "toolchains" / "de-luau-toolchain"
DERECOMP = TOOLCHAIN / "bin" / "derecomp.exe"
LUAU = TOOLCHAIN / "bin" / "luau.exe"
SOURCE = FIX / "mallet-threat.u44.luau"
BASELINE_SOURCE = (WORKSPACE / "repos" / "runtime" / "bootstrapper-runtime" / "RESEARCH"
                   / "LOADOUT_NATIVE_HOOK_CONFLICT_2026-09-27" / "mallet-threat.u44.luau")

EXPECTED = {
    "stock_sha256": "c713c4d6bf32adb06f7b3ff71d03f00feb53ccd0b651bd2cdf2382106882299f",
    "installed_addon_sha256": "0acbfea23262dc6d1f0103e469cca1ff94cf5d4757cb567326d1b344013baae5",
    "derecomp_sha256": "c1672d8d70e44bf7001a68f873f229714f5afdefb0b93c8558b6abb49e187c58",
}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(args, **kw):
    return subprocess.run([str(a) for a in args], capture_output=True, text=True, **kw)


def logical_listing(ir_text, proto):
    """Return {index: (op, text)} for one prototype of a derecomp ir/ir-u44 listing."""
    out, inside = {}, False
    for line in ir_text.splitlines():
        if line.startswith("== proto["):
            inside = line.startswith(f"== proto[{proto}]")
            continue
        m = re.match(r"\s*\[\s*(\d+)\]\s+(\S+)\s*(.*)$", line) if inside else None
        if m:
            out[int(m.group(1))] = (m.group(2), m.group(3).strip())
    return out


def main():
    stock, installed, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
    out.mkdir(parents=True, exist_ok=True)
    gates, facts = {}, {}

    def gate(name, ok, detail=""):
        gates[name] = {"pass": bool(ok), "detail": detail}
        print(("PASS " if ok else "FAIL ") + name + (": " + detail if detail else ""))

    gate("input.stock-identity", sha(stock) == EXPECTED["stock_sha256"], sha(stock))
    gate("input.installed-addon-identity", sha(installed) == EXPECTED["installed_addon_sha256"], sha(installed))
    gate("tool.derecomp-identity", sha(DERECOMP) == EXPECTED["derecomp_sha256"], sha(DERECOMP))

    # 1. Callsite numbering as the runtime reports it (NAMECALL logical index).
    ir = run([DERECOMP, "ir-u44", stock]).stdout
    (out / "stock.ir-u44.txt").write_text(ir, encoding="utf-8")
    p16 = logical_listing(ir, 16)
    push = [i for i, (op, t) in p16.items() if op == "NAMECALL" and t.endswith(":PushFloatArg")]
    radial = [i for i, (op, t) in p16.items() if op == "NAMECALL" and t.endswith(":RadialDamage")]
    gate("stock.p16-single-PushFloatArg-namecall-596",
         push == [596] and p16.get(597, ("",))[0] == "CALL", f"namecalls={push} next={p16.get(597)}")
    # Live anchor: 44.0.2 session pid 23260 logged ENGINE_DAMAGE SourcePrototype=16
    # SourceInstruction=576 for RadialDamage through the same saved-PC mapper.
    gate("stock.p16-RadialDamage-namecall-576-matches-live-anchor", radial == [576], f"namecalls={radial}")
    threat_block = [p16.get(i) for i in range(578, 603)]
    gate("stock.threat-formula-and-secondary-script",
         p16.get(579) == ("LOADN", "R30 <- 5") and "DIVK" in p16.get(582, ("", ""))[0]
         and p16.get(601, ("", ""))[1].endswith(":ActivateSecondaryScript"),
         "Lerp(5,0,min(1,pool/1500)) -> floor -> PushFloatArg -> ActivateSecondaryScript")
    facts["p16_threat_block"] = [f"[{i}] {op} {t}" for i, (op, t) in
                                 ((i, p16[i]) for i in range(578, 603) if i in p16)]

    # 2. Real-source contract test under upstream Luau (require stub only).
    body = SOURCE.read_text(encoding="utf-8")
    harness = ("local require = function(name)\n"
               " assert(name == \"Lotus.Scripts.Libs.AbilitiesLib\")\n return {}\nend\n"
               "local addon = (function()\n" + body + "\nend)()\n"
               + (HERE / "contract_assertions.luau").read_text(encoding="utf-8"))
    (out / "contract_harness.luau").write_text(harness, encoding="utf-8")
    r = run([LUAU, out / "contract_harness.luau"])
    gate("source.contract-test", r.returncode == 0 and "PASS contract" in r.stdout,
         (r.stdout + r.stderr).strip())

    # 3. U44 compile, determinism, reparse and container roundtrip.
    cand, cand2, base = out / "candidate.lua_B", out / "candidate.2.lua_B", out / "baseline.rebuild.lua_B"
    r1 = run([DERECOMP, "recompile-u44", SOURCE, cand])
    r2 = run([DERECOMP, "recompile-u44", SOURCE, cand2])
    rb = run([DERECOMP, "recompile-u44", BASELINE_SOURCE, base])
    gate("build.recompile-u44", r1.returncode == 0 and "re-parses=yes" in (r1.stdout + r1.stderr),
         (r1.stdout + r1.stderr).strip().splitlines()[-1])
    gate("build.deterministic", cand.read_bytes() == cand2.read_bytes())
    gate("build.baseline-source-reproduces-installed-bytes",
         rb.returncode == 0 and base.read_bytes() == installed.read_bytes(), sha(base))
    rt = run([DERECOMP, "de-roundtrip", cand])
    gate("build.de-roundtrip", rt.returncode == 0, (rt.stdout + rt.stderr).strip().splitlines()[-1]
         if (rt.stdout + rt.stderr).strip() else "")

    # 4. CONST-ID against the live-loaded installed addon (names/strings/key uses).
    ci = run([DERECOMP, "const-identity", installed, cand, "--u44"])
    (out / "const-identity.txt").write_text(ci.stdout + ci.stderr, encoding="utf-8")
    gate("gate.const-identity-vs-installed", ci.returncode == 0,
         (ci.stdout + ci.stderr).strip().splitlines()[-1] if (ci.stdout + ci.stderr).strip() else "")

    # 5. The only semantic delta is the callsite operand 597 -> 596.
    ir_old = run([DERECOMP, "ir-u44", installed]).stdout
    ir_new = run([DERECOMP, "ir-u44", cand]).stdout
    (out / "installed.ir-u44.txt").write_text(ir_old, encoding="utf-8")
    (out / "candidate.ir-u44.txt").write_text(ir_new, encoding="utf-8")
    old_l, new_l = ir_old.splitlines(), ir_new.splitlines()
    diff = [(a, b) for a, b in zip(old_l, new_l) if a != b]
    only_operand = (len(old_l) == len(new_l) and len(diff) >= 1
                    and all("597" in a and "596" in b and a.replace("597", "596") == b for a, b in diff))
    gate("gate.ir-delta-only-597-to-596", only_operand,
         f"differing_lines={len(diff)} " + " | ".join(f"{a.strip()} => {b.strip()}" for a, b in diff))
    bytes_old, bytes_new = installed.read_bytes(), cand.read_bytes()
    byte_diff = [i for i in range(min(len(bytes_old), len(bytes_new))) if bytes_old[i] != bytes_new[i]]
    facts["byte_delta"] = {"installed_size": len(bytes_old), "candidate_size": len(bytes_new),
                           "differing_offsets": byte_diff}

    facts["candidate_sha256"] = sha(cand)
    facts["candidate_size"] = cand.stat().st_size
    facts["source_sha256"] = sha(SOURCE)
    result = {"gates": gates, "facts": facts, "all_pass": all(g["pass"] for g in gates.values())}
    (out / "gates.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print("ALL GATES PASS" if result["all_pass"] else "GATES FAILED")
    return 0 if result["all_pass"] else 1


if __name__ == "__main__":
    sys.exit(main())
