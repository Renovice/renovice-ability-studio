# Test references of the mission harnesses (2026-10-09)

Kept in the repository so a cleanup of `work/` or a client update cannot remove what the harnesses compare against.

- `inputs/` — the sample settings of client 2026.09.28.13.06, copied byte for byte from the dated
  `work/research/universal-mission-editor-2026-09-29/phase2{b,d,e}-sample/mission_settings.json` and
  `phase2i-sample/CustomScripts/Settings/Missions.json` (ee4fa704). `test_presets_and_sample.py` relabels them for
  the current registry build; a value id the registry no longer has fails the test.
- `<client build>/samples.json` — SHA-256 of every sample build on that client build, bound to the registry
  SHA-256. The first run on a build records it; every later run must be byte-identical. After an R step changes the
  registry on purpose: `python tools/test_presets_and_sample.py --record`.

The package files of the pinned harness input are pinned separately in `../test-results/package_pins.json`
(`harness_input.py --repin`, also run by `renovice_update.py --adopt`).

Historical (proven on client 2026.09.28.13.06, not re-run on another build): the byte comparisons with the dated
`phase2*-sample` folders, with the staged full package `work/staging/missions-full-package` (R7) and with the R14
Defense addon `work/staging/combined-r14`. Those folders are dated evidence; the harnesses record them as historical.
