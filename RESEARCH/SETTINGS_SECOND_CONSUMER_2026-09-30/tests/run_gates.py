#!/usr/bin/env python3
"""Offline gates for the second ADDON_SETTINGS_V1 consumer (2026-09-30).

Usage:
  python run_gates.py <installed_inject_dir> <out_dir>

<installed_inject_dir> is read only. It must hold the currently installed loose
addons (identity-pinned below); they are the const-identity baselines.
Everything is written to <out_dir>:
  <out_dir>/Packages/Octavia/  and  <out_dir>/Packages/Frost/  (the staged packages)
  <out_dir>/gates.json and per-gate evidence files.
Exit code 0 only when every gate passes.
"""
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
NOTE = HERE.parent
WORKSPACE = next(p for p in HERE.parents if (p / "WORKSPACE.json").is_file())
TOOLCHAIN = WORKSPACE / "repos" / "toolchains" / "de-luau-toolchain"
# Committed U44 raw-hash toolchain build (de-luau-toolchain 0299da9), the same
# binary the Mallet threat fix and the NAMECALL audit used.
DERECOMP = TOOLCHAIN / "bin" / "derecomp.head.exe"
LUAU = TOOLCHAIN / "bin" / "luau.exe"
NAME_MAP = TOOLCHAIN / "profiles" / "u44" / "name-map.tsv"
STOCK_DIR = TOOLCHAIN / "work" / "u44-rawhash-2026-09-29" / "stock"
AUDIT_TOOL = (WORKSPACE / "work" / "temp" / "ability-editor-callsite-audit" / "RESEARCH"
              / "CALLSITE_NAMECALL_AUDIT_2026-09-29" / "tools" / "callsite_audit.py")

EXPECTED = {
    "derecomp": "c1672d8d70e44bf7001a68f873f229714f5afdefb0b93c8558b6abb49e187c58",
    "name_map": "d27c3a00d0693b7c86c97831de047f69115a17a1115f54556cdc3c8dcdde4f59",
}

ADDONS = [
    {
        "name": "mallet",
        "package": "Octavia",
        "file": "ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B",
        "installed_sha256": "22e0cb4972f81050175b982cbef7c4d09a5a1fb2a1268c38172d45e151bf422a",
        "stock": "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B",
        "stock_sha256": "c713c4d6bf32adb06f7b3ff71d03f00feb53ccd0b651bd2cdf2382106882299f",
        "baseline_source": NOTE.parent / "MALLET_THREAT_CALLSITE_FIX_2026-09-29" / "mallet-threat.u44.luau",
        "source": NOTE / "src" / "mallet-threat-settings.u44.luau",
        "alias_map": False,   # no opaque aliases: plain names hash with the U44 seed
        "contract": HERE / "mallet_settings_contract.luau",
        "prelude": ('local require = function(name)\n'
                    ' assert(name == "Lotus.Scripts.Libs.AbilitiesLib")\n return {}\nend\n'),
        # Protos whose constants may change: transformFloatArgument and activate.
        "changed_protos": {10, 11},
        "allowed_strings": {"enabled", "mallet.threat_level", "number", "settings", "stock", "table", "value"},
    },
    {
        "name": "icewave",
        "package": "Frost",
        "file": "8fba3a28f8fef624.IceWaveColdStackDamage.target.addon.lua_B",
        "installed_sha256": "dcedc4a2d11cd2d7f03361432eb02c64fd01f3dc6517b627e940ac8ad4228e31",
        "stock": "Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B",
        "stock_sha256": "f903720dee7828506f2a3e668204860f5300a27c27fc53f4e86781cab276f3c5",
        "baseline_source": NOTE.parent / "ICE_WAVE_BONUS_50_2026-09-27" / "ice-wave-bonus50.u44.luau",
        "source": NOTE / "src" / "ice-wave-settings.u44.luau",
        "alias_map": True,    # U43-alias source (Name__ff67e37d -> e6841eeb)
        "contract": HERE / "icewave_settings_contract.luau",
        "prelude": ('INERT = false\n'
                    'IsNull = function(x) if INERT then error("ICE_WAVE_TEST_INERT_VIOLATION") end return x == nil end\n'
                    'Engine = { UpgradedValue = function(x) return x end }\n'),
        # card v20 (p27), DamageDD.before v23 (p30), SetSource.before v24 (p31), activate v28 (p34)
        "changed_protos": {27, 30, 31, 34},
        "allowed_strings": {"enabled", "ice_wave.bonus_per_cold_stack", "number", "settings", "stock", "table",
                            "value", "bonusPerStack"},
    },
]


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(args, **kw):
    return subprocess.run([str(a) for a in args], capture_output=True, text=True, **kw)


def last_line(result):
    text = (result.stdout + result.stderr).strip()
    return text.splitlines()[-1] if text else ""


def compile_u44(addon, source, output):
    args = [DERECOMP, "recompile-u44", source, output]
    if addon["alias_map"]:
        args.append(NAME_MAP)
    return run(args)


def const_identity_delta(text):
    """Parse `const-identity` per-prototype delta lines."""
    delta = []
    for line in text.splitlines():
        m = re.match(r"proto (\d+) (HASH|STRING|KEYUSE) only-stock=\[(.*?)\] only-candidate=\[(.*)\]$", line)
        if m:
            split = lambda s: [x.strip() for x in s.split(",") if x.strip()]
            delta.append((int(m.group(1)), m.group(2), split(m.group(3)), split(m.group(4))))
    summary = {}
    for key in ("CLASS_SWAPS", "CODE_DIFF", "CONST_IDENTITY"):
        m = re.search(rf"^{key} (.*)$", text, re.M)
        summary[key] = m.group(1) if m else ""
    return delta, summary


def main():
    inject, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    gates, facts = {}, {"tools": {}, "addons": {}}

    def gate(name, ok, detail=""):
        gates[name] = {"pass": bool(ok), "detail": detail}
        print(("PASS " if ok else "FAIL ") + name + (": " + detail if detail else ""))

    gate("tool.derecomp-identity", sha(DERECOMP) == EXPECTED["derecomp"], sha(DERECOMP))
    gate("tool.u44-alias-map-identity", sha(NAME_MAP) == EXPECTED["name_map"], sha(NAME_MAP))
    facts["tools"]["luau"] = sha(LUAU)
    facts["tools"]["callsite_audit"] = sha(AUDIT_TOOL)
    audit_head = run(["git", "-C", AUDIT_TOOL.parent, "rev-parse", "HEAD"]).stdout.strip()
    gate("tool.callsite-audit-revision", audit_head.startswith("284263b"), audit_head)

    for addon in ADDONS:
        n = addon["name"]
        work = out / "work" / n
        work.mkdir(parents=True, exist_ok=True)
        installed = inject / addon["file"]
        stock = STOCK_DIR / addon["stock"]
        manifest_path = NOTE / "package" / addon["package"] / "package.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        member = manifest["members"][addon["file"]]
        (value_id, decl), = member["settings"]["values"].items()

        gate(f"{n}.input.installed-identity", sha(installed) == addon["installed_sha256"], sha(installed))
        gate(f"{n}.input.stock-identity", sha(stock) == addon["stock_sha256"], sha(stock))

        # 1. The previous source reproduces the installed bytes through the same path.
        base = work / "baseline.rebuild.lua_B"
        rb = compile_u44(addon, addon["baseline_source"], base)
        gate(f"{n}.build.baseline-source-reproduces-installed",
             rb.returncode == 0 and base.read_bytes() == installed.read_bytes(), sha(base))

        # 2. Candidate: U44 path, reparse, determinism, container round trip.
        cand, cand2 = work / "candidate.lua_B", work / "candidate.2.lua_B"
        r1, r2 = compile_u44(addon, addon["source"], cand), compile_u44(addon, addon["source"], cand2)
        gate(f"{n}.build.recompile-u44", r1.returncode == 0 and "re-parses=yes" in (r1.stdout + r1.stderr),
             last_line(r1))
        gate(f"{n}.build.deterministic", r2.returncode == 0 and cand.read_bytes() == cand2.read_bytes(), sha(cand))
        rt = run([DERECOMP, "de-roundtrip", cand])
        gate(f"{n}.build.de-roundtrip", rt.returncode == 0 and "FULL BODY identical: True" in rt.stdout,
             last_line(rt))

        # 3. const-identity against the installed (live-loaded) addon.
        ci = run([DERECOMP, "const-identity", installed, cand, "--u44"])
        (work / "const-identity.txt").write_text(ci.stdout + ci.stderr, encoding="utf-8")
        delta, summary = const_identity_delta(ci.stdout + ci.stderr)
        protos = re.search(r"protos_stock=(\d+) protos_candidate=(\d+)", summary["CONST_IDENTITY"])
        installed_bytes, stock_bytes = installed.read_bytes(), stock.read_bytes()
        problems = []
        if not protos or protos.group(1) != protos.group(2):
            problems.append("prototype count changed")
        if "hash_string_class_swaps=0" not in summary["CLASS_SWAPS"]:
            problems.append("hash/string class swap")
        for proto, kind, removed, added in delta:
            if proto not in addon["changed_protos"]:
                problems.append(f"unexpected delta in proto {proto} {kind}")
            if removed:
                problems.append(f"proto {proto} {kind} removed {removed}")
            for item in added:
                if kind == "STRING":
                    ok = item.strip('"') in addon["allowed_strings"]
                elif kind == "HASH":
                    raw = int(item, 16).to_bytes(4, "little")
                    ok = raw in installed_bytes or raw in stock_bytes
                else:  # KEYUSE
                    m = re.match(r"(FIELD|GLOBAL|SETFIELD|NAMECALL) ([HS]):(.+)$", item)
                    if not m:
                        ok = False
                    elif m.group(2) == "S":
                        ok = m.group(3) in addon["allowed_strings"]
                    else:
                        raw = int(m.group(3), 16).to_bytes(4, "little")
                        ok = raw in installed_bytes or raw in stock_bytes
                if not ok:
                    problems.append(f"proto {proto} {kind} added {item} not allowed/proven")
        gate(f"{n}.gate.const-identity-delta-vs-installed", not problems,
             "; ".join(problems) if problems else
             f"{summary['CONST_IDENTITY']} | {summary['CLASS_SWAPS']} | deltas only in protos "
             f"{sorted({d[0] for d in delta})}, additions only, every added hash already used by the installed "
             f"addon or the stock target")

        # IR evidence: the new settings reads are plain string-keyed table reads.
        ir = run([DERECOMP, "ir-u44", cand]).stdout
        (work / "candidate.ir-u44.txt").write_text(ir, encoding="utf-8")
        (work / "installed.ir-u44.txt").write_text(run([DERECOMP, "ir-u44", installed]).stdout, encoding="utf-8")
        string_keys = all(re.search(rf"GETFIELD\s+\S+\s+<-\s+\S+\.{k}\s*$", ir, re.M)
                          for k in ("settings", "enabled", "stock", "value"))
        gate(f"{n}.ir.settings-read-as-string-keys", string_keys and f'"{value_id}"' in ir,
             "GETFIELD .settings/.enabled/.stock/.value with string constants; id constant present")

        # 4. NAMECALL callsite gate (ability-editor fix/callsite-namecall-audit 284263b).
        named = work / "named" / addon["file"]
        named.parent.mkdir(exist_ok=True)
        shutil.copyfile(cand, named)
        au = run([sys.executable, AUDIT_TOOL, "addon", named])
        (work / "callsite-audit.json").write_text(au.stdout + au.stderr, encoding="utf-8")
        verdict = json.loads(au.stdout).get("verdict") if au.returncode == 0 else "exit %d" % au.returncode
        gate(f"{n}.gate.native-callsite-namecall", au.returncode == 0 and verdict == "OK", f"verdict={verdict}")

        # 5. Real-source contract under upstream Luau, declaration injected.
        decl_lua = ("local DECL = { id = %s, type = %s, stock = %r, min = %r, max = %r }\n"
                    % (json.dumps(value_id), json.dumps(decl["type"]), decl["stock"], decl["min"], decl["max"]))
        harness = (addon["prelude"] + decl_lua + "local addon = (function()\n"
                   + addon["source"].read_text(encoding="utf-8") + "\nend)()\n"
                   + addon["contract"].read_text(encoding="utf-8"))
        (work / "contract_harness.luau").write_text(harness, encoding="utf-8")
        lr = run([LUAU, work / "contract_harness.luau"])
        gate(f"{n}.source.settings-contract", lr.returncode == 0 and "PASS " in lr.stdout, last_line(lr))

        # 6. Declaration <-> source: the addon reads exactly the declared id, and
        #    the declared stock/min/max are the constants the contract proved.
        text = addon["source"].read_text(encoding="utf-8")
        gate(f"{n}.decl.id-and-lane", text.count(f'settings["{value_id}"]') == 1 and decl["lane"] == "addon",
             f"{value_id} {decl['type']} stock={decl['stock']} min={decl['min']} max={decl['max']}")

        # 7. Stage the package folder: package.json + the candidate bytes only.
        package_dir = out / "Packages" / addon["package"]
        if package_dir.exists():
            shutil.rmtree(package_dir)
        package_dir.mkdir(parents=True)
        shutil.copyfile(manifest_path, package_dir / "package.json")
        shutil.copyfile(cand, package_dir / addon["file"])
        listed = sorted(p.name for p in package_dir.iterdir())
        gate(f"{n}.package.members-match-manifest",
             sorted(manifest["members"]) == [f for f in listed if f.endswith(".lua_B")]
             and listed == sorted(["package.json", addon["file"]]), ", ".join(listed))

        committed = manifest_path.parent / addon["file"]
        gate(f"{n}.package.committed-bytes-equal-rebuild",
             committed.is_file() and committed.read_bytes() == cand.read_bytes(),
             sha(committed) if committed.is_file() else "missing")

        facts["addons"][n] = {
            "candidate_sha256": sha(cand), "candidate_size": cand.stat().st_size,
            "source_sha256": sha(addon["source"]), "manifest_sha256": sha(manifest_path),
            "installed_sha256": sha(installed), "stock_sha256": sha(stock),
        }

    result = {"gates": gates, "facts": facts, "all_pass": all(g["pass"] for g in gates.values())}
    (out / "gates.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print("ALL GATES PASS" if result["all_pass"] else "GATES FAILED")
    return 0 if result["all_pass"] else 1


if __name__ == "__main__":
    sys.exit(main())
