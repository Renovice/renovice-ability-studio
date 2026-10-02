#!/usr/bin/env python3
"""Read-only scan of a Warframe executable for encoded-field accessor constants.

Usage: python scan_field_codec.py <Warframe.x64.exe>

Counts the accessor shape used by the ENGINE_DAMAGE observer
(renovice/engine_damage.cpp integer_getter / decode_float):
  add rcx,imm32; mov eax,[rcx]; rol eax,ROT; sar rcx,3; xor eax,ecx; xor eax,KEY; ...
and reports every (ROT, KEY) pair, the byte that follows (C3 = integer return,
66 0F 6E C0 = movd xmm0,eax float return), and whether the U43 keys still occur.
"""
import collections
import hashlib
import re
import sys

data = open(sys.argv[1], "rb").read()
print("sha256", hashlib.sha256(data).hexdigest())
shape = re.compile(rb"\xc1\xc0(.)\x48\xc1\xf9\x03\x33\xc1\x35(.{4})(.{4})", re.S)
pairs = collections.Counter()
for m in shape.finditer(data):
    rot, key, tail = m.group(1)[0], int.from_bytes(m.group(2), "little"), m.group(3)
    kind = "float" if tail.startswith(b"\x66\x0f\x6e\xc0") else ("int" if tail[:1] == b"\xc3" else "other")
    pairs[(rot, hex(key), kind)] += 1
for (rot, key, kind), n in sorted(pairs.items(), key=lambda x: -x[1]):
    print(f"rol={rot} key={key} return={kind} count={n}")
for name, key in (("u43-int 0xc55198a3", 0xC55198A3), ("u43-float 0x635bf253", 0x635BF253)):
    print(name, "occurrences", data.count(key.to_bytes(4, "little")))
