# Ice Wave bonus +50 per Cold stack — 2026-09-27
User requested +10 -> +50 per stack. Source coefficient edited in gameplay, card and two diagnostic descriptions. Existing Strength scaling and per-target semantics retained: stockRaw*(1+coldStacks*50*abilityStrength).
U44 compilation/reparse, all37 canonical semantic plans and 37-prototype serialization roundtrip PASS. Binary output differs from the verified +10 artifact at exactly three bytes: two LOADN10->50 and one shared f64 constant10->50. All other bytes identical. No binary patching used; output compiled from source.
Deployed only Ice Wave addon; previous +10 bytes preserved in artifacts/rollback-bonus10.lua_B. Mallet supported-hook correction and runtime DLL untouched. Installed SHA256 DCEDC4A2D11CD2D7F03361432EB02C64FD01F3DC6517B627E940AC8AD4228E31.
At100% Strength: zero stacks1x, one stack51x, ten stacks501x stock damage. New coefficient gameplay/card acceptance pending fresh load. No new diagnostic settings enabled.
