#!/usr/bin/env python3
"""Deterministic offline gates for the NAMECALL callsite audit (2026-09-29).

Usage:
  python run_gates.py <out_dir> [--editor-build DIR]

Read-only for every input (stock corpora, installed CustomScripts, staged artifacts).
Everything is written to <out_dir>. Exit code 0 only when every gate passes.
"""
import argparse
import csv
import hashlib
import json
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "tools"))
import callsite_audit as ca  # noqa: E402

W = ca.WORKSPACE
U44 = W / "repos/toolchains/de-luau-toolchain/work/u44-rawhash-2026-09-29/stock"
U43 = W / "shared/corpus/de-luau-stock"
INSTALLED = Path(r"C:\Program Files (x86)\Steam\steamapps\common\Warframe\OpenWF\CustomScripts")

STOCK = {  # file -> sha256 (44.0.2 = u44, pinned U43 corpus = u43)
    ("u44", "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B"): "c713c4d6bf32adb06f7b3ff71d03f00feb53ccd0b651bd2cdf2382106882299f",
    ("u44", "Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B"): "f903720dee7828506f2a3e668204860f5300a27c27fc53f4e86781cab276f3c5",
    ("u44", "Lotus_Interface_MissionRequirementUtilities.lua_B"): "6801f711c598efbce3b57ca50f15e45b50abaf803abe1c72694f3b962e431d25",
    ("u44", "Lotus_Scripts_Eidolon_Encounters_DynamicDefend.lua_B"): "f2a27591489413891650d0948414cde30dc7b7ca7ec0922ca3003b55773c150e",
    ("u44", "Lotus_Scripts_InfestedMicroplanet_Encounters_DynamicAreaDefense.lua_B"): "322d5e174ac81d86dfdff92fced2cde6a2748d9929698409381c13de936153f2",
    ("u43", "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B"): "c0cf04fc388092533c3084e459ba4ae9050571934c82e3473385823f8e2a6390",
    ("u43", "Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B"): "5c657567b9471a46e78603d4da2f8d2c792a5ba18c4dacb4609d59d423a6fc69",
    ("u43", "Lotus_Interface_MissionRequirementUtilities.lua_B"): "4ad63fd5d545b70bd424d1e63d5390b37a573d66078f195e747d91f7a61d7e5e",
    ("u43", "Lotus_Scripts_MobileDefense.lua_B"): "e9cbbef4b6beca2ac61ec741f3f9a22ba45df06878708c429176843222b47541",
    ("u43", "Lotus_Scripts_Eidolon_Encounters_DynamicDefend.lua_B"): "ecc204753db9bded69f6a764c919df5dd2240b5ee907e35c046e99c624d23386",
    ("u43", "Lotus_Scripts_InfestedMicroplanet_Encounters_DynamicAreaDefense.lua_B"): "ecbed12e85416ce5fbb25995d9252f4ad29042f1ae7daa3c2e4c8a2f25aedf49",
}

# Every audited filter: (label, profile, stock file, method, prototype, instruction, expected class)
SITES = [
    ("Ice Wave installed SetBaseAmount", "u44", "Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B", "SetBaseAmount", 7, 42, "OK"),
    ("Ice Wave installed SetSource", "u44", "Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B", "SetSource", 7, 53, "OK"),
    ("Ice Wave installed DamageDD", "u44", "Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B", "DamageDD", 7, 65, "OK"),
    ("Mallet installed (fixed) transformFloatArgument", "u44", "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B", "PushFloatArg", 16, 596, "OK"),
    ("Mallet pre-fix (U44_AUTHORING / LOADOUT 2026-09-27)", "u44", "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B", "PushFloatArg", 16, 597, "OFF-BY-ONE"),
    ("Elite installed p25", "u44", "Lotus_Interface_MissionRequirementUtilities.lua_B", "BuildMissionForLocation", 25, 10, "OFF-BY-ONE"),
    ("Elite staged fix p25", "u44", "Lotus_Interface_MissionRequirementUtilities.lua_B", "BuildMissionForLocation", 25, 9, "OK"),
    ("Elite staged fix p21", "u44", "Lotus_Interface_MissionRequirementUtilities.lua_B", "BuildMissionForLocation", 21, 324, "OK"),
    ("Editor Plains Control Area lock (was 30)", "u44", "Lotus_Scripts_Eidolon_Encounters_DynamicDefend.lua_B", "GetNetPersistentVar", 8, 29, "OK"),
    ("Editor Deimos Control Area lock (was 62)", "u44", "Lotus_Scripts_InfestedMicroplanet_Encounters_DynamicAreaDefense.lua_B", "GetNetPersistentVar", 7, 61, "OK"),
    ("Editor Plains lock before fix", "u43", "Lotus_Scripts_Eidolon_Encounters_DynamicDefend.lua_B", "GetNetPersistentVar", 8, 30, "OFF-BY-ONE"),
    ("Editor Deimos lock before fix", "u43", "Lotus_Scripts_InfestedMicroplanet_Encounters_DynamicAreaDefense.lua_B", "GetNetPersistentVar", 7, 62, "OFF-BY-ONE"),
    ("Editor example / form default before fix (U43 target)", "u43", "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B", "PushFloatArg", 16, 596, "OFF-BY-ONE"),
    ("Editor example / form default after fix (U43 target)", "u43", "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B", "PushFloatArg", 16, 595, "OK"),
    ("Mallet cover-bypass addon 2026-09-09 (U43)", "u43", "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B", "RadialDamage", 16, 576, "OFF-BY-ONE"),
    ("Mobile Defense nativeCalls addon (retired template)", "u43", "Lotus_Scripts_MobileDefense.lua_B", "GetNetPersistentVar", 22, 139, "OFF-BY-ONE"),
    ("Elite 2026-09-12/13 package and V72 fixture (U43)", "u43", "Lotus_Interface_MissionRequirementUtilities.lua_B", "BuildMissionForLocation", 25, 10, "OFF-BY-ONE"),
    ("Ice Wave U43 package (V66-V99)", "u43", "Lotus_Powersuits_Frost_Abilities_IceSpike.lua_B", "DamageDD", 7, 64, "OK"),
]

INSTALLED_EXPECT = {  # installed file -> (sha256, expected verdict)
    r"Inject\8fba3a28f8fef624.IceWaveColdStackDamage.target.addon.lua_B": ("dcedc4a2d11cd2d7f03361432eb02c64fd01f3dc6517b627e940ac8ad4228e31", "OK"),
    r"Inject\ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B": ("22e0cb4972f81050175b982cbef7c4d09a5a1fb2a1268c38172d45e151bf422a", "OK"),
    r"Inject\64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.lua_B": ("86eacb891078aeb40b054ae2041ea29a23c3f55bc636612af35bd133d9672ed1", "OFF-BY-ONE"),
    r"Packages\Missions\Missions.targets.addon.lua_B": ("00da193d03d43472d4df98806e7a532a82f449e17fa82e07624cc2f9816a773e", "NO-INSTRUCTION-FILTER"),
}
STAGED_EXPECT = {
    "work/staging/elite-sanctuary-fix/64d11e6973afa4b1.EliteSanctuaryNoRank.target.addon.lua_B": ("4e6d5b7133017e6001c61d0f1e1f1b7d6878f6a9085ca570008fede6815b90e3", "OK"),
    "work/staging/mallet-threat-fix/ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B": ("22e0cb4972f81050175b982cbef7c4d09a5a1fb2a1268c38172d45e151bf422a", "OK"),
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--editor-build", type=Path)
    ns = ap.parse_args()
    out = ns.out
    out.mkdir(parents=True, exist_ok=True)
    gates, facts = {}, {}

    def gate(name, ok, detail=""):
        gates[name] = {"pass": bool(ok), "detail": detail}
        print(("PASS " if ok else "FAIL ") + name + (": " + detail if detail else ""))

    gate("tool.derecomp-identity", ca.sha256(ca.DERECOMP) == "c1672d8d70e44bf7001a68f873f229714f5afdefb0b93c8558b6abb49e187c58",
         ca.sha256(ca.DERECOMP))
    for (profile, name), expected in STOCK.items():
        path = (U44 if profile == "u44" else U43) / name
        gate(f"stock.{profile}.{name}", ca.sha256(path) == expected, expected[:16])

    # 1. Every audited site against the stock IR.
    excerpt = []
    rows = []
    for label, profile, name, method, proto, instr, expect in SITES:
        path = (U44 if profile == "u44" else U43) / name
        ir = ca.ir_listing(path, profile)
        row = ca.classify_site(ir, proto, instr, method)
        rows.append({"label": label, "profile": profile, "stock": name, **row})
        gate(f"site.{label}", row["class"] == expect, f"{method} p{proto}/i{instr} -> {row['class']}: {row['reason']}")
        body = ir.get(proto, {})
        excerpt.append(f"## {label}  ({profile} {name})")
        for i in range(instr - 1, instr + 2):
            if i in body:
                excerpt.append(f"  p{proto} [{i:4d}] {body[i][0]:<10} {body[i][1]}")
    (out / "stock-sites.ir.txt").write_text("\n".join(excerpt) + "\n", encoding="utf-8")
    facts["sites"] = rows

    # 2. Installed (read-only) and staged addons through the generic extractor.
    keys = ca.keymap()
    for rel, (sha, expect) in INSTALLED_EXPECT.items():
        path = INSTALLED / rel
        if not path.is_file():
            gate(f"installed.{rel}", False, "missing")
            continue
        res = ca.audit_addon(path, keys=keys)
        gate(f"installed.{rel}", res["sha256"] == sha and res["verdict"] == expect,
             f"{res['sha256'][:16]} {res['verdict']} " + "; ".join(
                 f"{h['hook']} p{s['prototype']}/i{s['instruction']}={s['class']}" for h in res["hooks"] for s in h["sites"]))
    for rel, (sha, expect) in STAGED_EXPECT.items():
        res = ca.audit_addon(W / rel, keys=keys)
        gate(f"staged.{rel}", res["sha256"] == sha and res["verdict"] == expect, f"{res['sha256'][:16]} {res['verdict']}")

    # 3. Provenance: the derecomp API call map numbers a method call by its CALL
    #    (NAMECALL + 1), which is how the CALL indices entered addons.
    calls = W / "work/ability-behavior/current/modules/08faf07b504d058f/calls.tsv"
    ir43 = ca.ir_listing(U43 / "Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B", "u43")
    with calls.open(encoding="utf-8", newline="") as fh:
        method_rows = [r for r in csv.DictReader(fh, delimiter="\t") if r["kind"] == "method"]
    shifted = sum(1 for r in method_rows
                  if ca.namecall_method(ir43[int(r["prototype"])].get(int(r["instruction"]) - 1)) == r["name"])
    gate("provenance.call-map-numbers-method-calls-by-CALL", shifted == len(method_rows) and len(method_rows) > 0,
         f"{shifted}/{len(method_rows)} method rows sit at NAMECALL+1 (calls.tsv {ca.sha256(calls)[:16]})")
    facts["call_map_method_rows"] = len(method_rows)

    # 4. Ability Editor generator gate (C++ self-test), when a build is given.
    if ns.editor_build:
        cli = ns.editor_build / "bin" / "renovice_ability_editor_cli.exe"
        r = subprocess.run([str(cli), "self-test", "--editor-root", str(HERE.parents[2])],
                           capture_output=True, text=True)
        (out / "editor-self-test.txt").write_text(r.stdout + r.stderr, encoding="utf-8")
        summary = [l for l in r.stdout.splitlines() if l.startswith("SUMMARY")]
        gate("editor.self-test", r.returncode == 0 and "failed=0" in (summary[-1] if summary else ""),
             summary[-1] if summary else "no summary")
        for needle in ("gate rejects the CALL index (NAMECALL+1)", "44.0.2 gate:",
                       "rejected nativeCalls.PushFloatArg form not generated"):
            gate(f"editor.{needle}", any(l.startswith("PASS " + needle) for l in r.stdout.splitlines()))

    result = {"gates": gates, "facts": facts, "all_pass": all(g["pass"] for g in gates.values())}
    (out / "gates.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print("ALL GATES PASS" if result["all_pass"] else "GATES FAILED")
    return 0 if result["all_pass"] else 1


if __name__ == "__main__":
    sys.exit(main())
