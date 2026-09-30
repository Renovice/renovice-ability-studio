#!/usr/bin/env python3
"""Offline gates for the Mallet integer-Overguard fix (2026-09-30).

Usage:
  python run_gates.py <installed_octavia_package_dir> <out_dir>

<installed_octavia_package_dir> is read only (the live
OpenWF/CustomScripts/Packages/Octavia folder). Everything is written to <out_dir>.
Exit code 0 only when every gate passes. Proves source, build, bytes and the
formula against recorded live beats; it does not prove gameplay.
"""
import csv
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
NOTE = HERE.parent
WORKSPACE = next(p for p in HERE.parents if (p / "WORKSPACE.json").is_file())
TOOLCHAIN = WORKSPACE / "repos" / "toolchains" / "de-luau-toolchain"
DERECOMP = TOOLCHAIN / "bin" / "derecomp.head.exe"
LUAU = TOOLCHAIN / "bin" / "luau.exe"
FILE = "ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B"
BASELINE_SOURCE = NOTE.parent / "SETTINGS_SECOND_CONSUMER_2026-09-30" / "src" / "mallet-threat-settings.u44.luau"
COMMITTED_PACKAGE = NOTE.parent / "SETTINGS_SECOND_CONSUMER_2026-09-30" / "package" / "Octavia" / FILE
SOURCE = NOTE / "src" / "mallet-overguard-integer-cap.u44.luau"
CONTRACT = HERE / "overguard_contract.luau"
BEATS = [NOTE / "evidence" / "live_beats_session_a.tsv", NOTE / "evidence" / "live_beats_session_b.tsv"]
EXPECTED = {
    "derecomp": "c1672d8d70e44bf7001a68f873f229714f5afdefb0b93c8558b6abb49e187c58",
    "installed": "1e3682a4bacf46ef4b15bcedb71ad402a2d9bd01540e410abe0a5419b418bb86",
}
AFTER_DAMAGE_PROTO = 8
PRELUDE = ('local NOTIFY = 0\n'
           'local require = function(name)\n'
           ' assert(name == "Lotus.Scripts.Libs.AbilitiesLib")\n'
           ' return { NotifyGaveOverguard = function() NOTIFY += 1 end }\nend\n'
           'IsNull = function(x) return x == nil end\n')


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(args):
    return subprocess.run([str(a) for a in args], capture_output=True, text=True)


def last_line(result):
    text = (result.stdout + result.stderr).strip()
    return text.splitlines()[-1] if text else ""


def beats_lua():
    rows = []
    for path in BEATS:
        with open(path, encoding="utf-8") as handle:
            for row in csv.DictReader(handle, delimiter="\t"):
                if row["class"] not in ("clean", "at-cap"):
                    continue
                damages = ",".join(x for x in row["grant_damages"].split(",") if x)
                rows.append("{%s,%s,%s,%s,{%s}}" % (row["strength"], row["og_before"], row["og_next"],
                                                   json.dumps(row["class"]), damages))
    return "local BEATS = {\n" + ",\n".join(rows) + "\n}\n", len(rows)


def main():
    package, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    gates = {}

    def gate(name, ok, detail=""):
        gates[name] = {"pass": bool(ok), "detail": detail}
        print(("PASS " if ok else "FAIL ") + name + (": " + detail if detail else ""))

    installed = package / FILE
    gate("tool.derecomp-identity", sha(DERECOMP) == EXPECTED["derecomp"], sha(DERECOMP))
    gate("input.installed-identity", sha(installed) == EXPECTED["installed"], sha(installed))
    gate("input.committed-package-equals-installed",
         COMMITTED_PACKAGE.read_bytes() == installed.read_bytes(), sha(COMMITTED_PACKAGE))

    base = out / "baseline.rebuild.lua_B"
    rb = run([DERECOMP, "recompile-u44", BASELINE_SOURCE, base])
    gate("build.baseline-source-reproduces-installed",
         rb.returncode == 0 and base.read_bytes() == installed.read_bytes(), sha(base) if base.exists() else "")

    cand, cand2 = out / FILE, out / (FILE + ".2")
    r1, r2 = run([DERECOMP, "recompile-u44", SOURCE, cand]), run([DERECOMP, "recompile-u44", SOURCE, cand2])
    gate("build.recompile-u44", r1.returncode == 0 and "re-parses=yes" in (r1.stdout + r1.stderr), last_line(r1))
    gate("build.deterministic", r2.returncode == 0 and cand.read_bytes() == cand2.read_bytes(), sha(cand))
    cand2.unlink()
    rt = run([DERECOMP, "de-roundtrip", cand])
    gate("build.de-roundtrip", rt.returncode == 0 and "FULL BODY identical: True" in rt.stdout, last_line(rt))

    ci = run([DERECOMP, "const-identity", installed, cand, "--u44"])
    text = ci.stdout + ci.stderr
    (out / "const-identity.txt").write_text(text, encoding="utf-8")
    problems = []
    installed_bytes = installed.read_bytes()
    for m in re.finditer(r"^proto (\d+) (HASH|STRING|KEYUSE) only-stock=\[(.*?)\] only-candidate=\[(.*)\]$",
                         text, re.M):
        proto, kind, removed, added = int(m.group(1)), m.group(2), m.group(3).strip(), m.group(4).strip()
        if proto != AFTER_DAMAGE_PROTO:
            problems.append(f"delta outside afterDamage: proto {proto} {kind}")
        if removed:
            problems.append(f"proto {proto} {kind} removed {removed}")
        for item in [x.strip() for x in added.split(",") if x.strip()]:
            hx = re.search(r"([0-9a-fA-F]{8})$", item)
            if kind != "STRING" and not (hx and int(hx.group(1), 16).to_bytes(4, "little") in installed_bytes):
                problems.append(f"proto {proto} {kind} added {item} not already used by the installed addon")
    swaps = re.search(r"^CLASS_SWAPS (.*)$", text, re.M)
    if not swaps or "hash_string_class_swaps=0" not in swaps.group(1):
        problems.append("hash/string class swap")
    # const-identity exits non-zero on any delta; the gate is the delta itself.
    gate("gate.const-identity-delta-only-afterDamage", bool(swaps) and not problems,
         "; ".join(problems) or (re.search(r"^CONST_IDENTITY (.*)$", text, re.M) or [None, ""])[1])

    beats, count = beats_lua()
    for label, source, flags in (("candidate", SOURCE, "BASELINE = false\nEXPECT_NO_CAP_WRITES = true\n"),
                                 ("baseline", BASELINE_SOURCE, "BASELINE = true\nEXPECT_NO_CAP_WRITES = false\n")):
        harness = (PRELUDE + flags + beats + "local addon = (function()\n" + source.read_text(encoding="utf-8")
                   + "\nend)()\n" + CONTRACT.read_text(encoding="utf-8"))
        path = out / f"contract_{label}.luau"
        path.write_text(harness, encoding="utf-8")
        lr = run([LUAU, path])
        (out / f"contract_{label}.txt").write_text(lr.stdout + lr.stderr, encoding="utf-8")
        replay = re.search(r"REPLAY .*", lr.stdout)
        gate(f"source.{label}.contract-and-live-replay", lr.returncode == 0 and "PASS overguard contract" in lr.stdout,
             (replay.group(0) if replay else last_line(lr)) + f" rows={count}")

    result = {"gates": gates, "all_pass": all(g["pass"] for g in gates.values()),
              "facts": {"candidate_sha256": sha(cand), "candidate_size": cand.stat().st_size,
                        "source_sha256": sha(SOURCE), "installed_sha256": sha(installed)}}
    (out / "gates.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print("ALL GATES PASS" if result["all_pass"] else "GATES FAILED")
    return 0 if result["all_pass"] else 1


if __name__ == "__main__":
    sys.exit(main())
