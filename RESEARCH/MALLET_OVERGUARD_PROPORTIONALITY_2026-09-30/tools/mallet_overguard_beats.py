#!/usr/bin/env python3
"""Pair Mallet damage with Octavia Overguard per beat from renovice_source.log.

Read only. Needs DiagnosticsMode=trace (dispatch.results carries the per-hit
reportedDamage the addon saw) and DiagnosticsCasterStats=true (CASTER_STATS at
the stock SetSource boundary carries Octavia's Overguard and strength).

Usage:
  python mallet_overguard_beats.py <log> [<log> ...] --tsv <out.tsv>

Model checked per beat k (SetSource snapshot k -> snapshot k+1):
  cap = 15000 * strength, r = min(0.05, 0.01 * strength)
  for each 'grant' hit in order: og = min(cap, og + dmg * r), engine truncates.
A beat is "clean" when the next snapshot is 500 ms later, Octavia took no
native-observed damage (no TennoAvatar ENGINE_DAMAGE record in the beat),
strength did not change, both snapshots are below the cap, and no
dispatch trace was rate-limited (Mallet correlation numbers are contiguous).
"""
import argparse
import json
import math
import re
import sys

KEY = "key=0xec368d4901690a15"
RESULT = re.compile(r'result(\d)_tag=\d+=("([^"]*)"|[^ ]+)')


def parse(paths):
    beats, cur = [], None
    for path in paths:
        with open(path, encoding="utf-8", errors="replace") as handle:
            for line in handle:
                if "event=CASTER_STATS " in line and "BardMusic" in line:
                    data = json.loads(line[line.find("json=") + 5:])
                    live = data["Live"]
                    snap = {
                        "tick": int(re.search(r"tick_ms=(\d+)", line).group(1)),
                        "og": live["overguard"]["value"],
                        "strength": live["strength"]["value"],
                    }
                    if data["Method"] == "SetSource":
                        cur = {"stats": snap, "hits": [], "tenno": 0}
                        beats.append(cur)
                    continue
                if cur is None:
                    continue
                if "ENGINE_DAMAGE" in line and '"Phase":"end"' in line and '"HandlerSlot":0' in line:
                    cur["tenno"] += '"TargetType":"TennoAvatar"' in line
                    continue
                if KEY not in line or "event=dispatch.results" not in line:
                    continue
                res = {}
                for m in RESULT.finditer(line):
                    res[int(m.group(1))] = m.group(3) if m.group(3) is not None else m.group(2)
                cur["hits"].append({"label": res[0], "corr": int(float(res[1])),
                                    "dmg": float(res[3]), "hp": float(res[7])})
    return beats


def simulate(og, strength, hits):
    cap, rate = 15000 * strength, min(0.05, max(0.0, 0.01 * strength))
    for hit in hits:
        if hit["label"] != "mallet.c9v57.grant" or og >= cap:
            continue
        og = math.floor(min(cap, og + hit["dmg"] * rate))
    return og


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("logs", nargs="+")
    parser.add_argument("--tsv")
    args = parser.parse_args()
    beats = parse(args.logs)
    rows = []
    for k in range(len(beats) - 1):
        b, nb = beats[k], beats[k + 1]
        s, og0, og1 = b["stats"]["strength"], b["stats"]["og"], nb["stats"]["og"]
        grants = [h for h in b["hits"] if h["label"] == "mallet.c9v57.grant"]
        missing = 0
        if b["hits"] and nb["hits"]:
            missing = nb["hits"][0]["corr"] - b["hits"][-1]["corr"] - 1
        cap_int = math.floor(15000 * s)
        klass = "other"
        if og0 >= cap_int:
            klass = "at-cap"
        elif (nb["stats"]["tick"] - b["stats"]["tick"] <= 600 and b["tenno"] == 0
              and nb["stats"]["strength"] == s and og1 < cap_int and missing == 0):
            klass = "clean"
        pred = simulate(og0, s, b["hits"])
        rows.append((k, b["stats"]["tick"], s, og0, og1, len(grants),
                     len(b["hits"]) - len(grants), missing, b["tenno"], pred, klass,
                     ",".join("%g" % h["dmg"] for h in grants)))
    clean = [r for r in rows if r[10] == "clean"]
    exact = sum(1 for r in clean if r[4] == r[9])
    print("beats=%d clean=%d exact=%d at-cap=%d rate-limited=%d"
          % (len(rows), len(clean), exact, sum(1 for r in rows if r[10] == "at-cap"),
             sum(1 for r in rows if r[7] > 0)))
    if args.tsv:
        with open(args.tsv, "w", encoding="utf-8", newline="\n") as out:
            out.write("beat\ttick_ms\tstrength\tog_before\tog_next\tgrant_hits\tkill_skips\t"
                      "rate_limited_traces\toctavia_hit_records\tmodel_og_next\tclass\tgrant_damages\n")
            for r in rows:
                out.write("\t".join(str(x) for x in r) + "\n")
    return 0 if exact == len(clean) else 1


if __name__ == "__main__":
    sys.exit(main())
