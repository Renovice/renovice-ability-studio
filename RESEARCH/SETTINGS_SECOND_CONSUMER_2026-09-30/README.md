# Second ADDON_SETTINGS_V1 consumer: Octavia Mallet threat and Frost Ice Wave bonus (2026-09-30)

**Offline only.** Nothing was deployed or pushed. Nothing was written to the game folder, the OpenWF server or the
bootstrapper repository; the bootstrapper was only read and exported with `git archive`.

- Client: Steam `2026.09.28.13.06` (44.0.2).
- Branch: `feat/settings-second-consumer-2026-09-30`, based on `fix/mallet-threat-callsite-2026-09-29` `d0d8c41`.
- Staged: `work/staging/settings-second-consumer/`.

Contract:

- `work/research/universal-mission-editor-2026-09-29/INGAME_EDITOR_DESIGN.md` §3.2–3.4;
- `CONTRACT_PHASE1.md` item 11;
- bootstrapper `feat/ingame-settings-editor-2026-09-30`: code `c6ceec4`, main DLL `d2f22650…`, HEAD `7028479` (whose
  `renovice/` is identical to `c6ceec4`);
- `OpenWF/CustomScripts/HOW_TO_ADD_SCRIPTS.md` "Script packages" and "Script settings".

## Why

Design §3.4 item 6 and the bootstrapper note (row U-1) require a second consumer of `context.settings` that is
unrelated to Missions before ADDON_SETTINGS_V1 may be called universal. The Mallet threat level (a native float
argument transform) and the Ice Wave cold-stack bonus (native `nativeCalls` damage rewrite) share no code or target
with the Missions `luaCalls` table writes.

## Hypotheses and results

| ID | Hypothesis | Result | Evidence |
|---|---|---|---|
| F-1 | The bootstrapper already supports settings for a single-key target addon inside a package, so no loose-declaration format is needed. | **TRUE** | `packages.cpp`: every non-replacement member that declares values gets `member_delivery`, and `TargetAddon` is not excluded. `injection.cpp` builds `context.settings` for any chunk with a delivery. The gate delivered `{ id = { enabled, value, stock } }` to both single-key members. |
| F-2 | The current installed DLL (`6f100ebc`, bootstrapper `3ca9564`) admits these packages and keeps today's behaviour. | **TRUE (offline)** | `verify_script_packages --admit` at `3ca9564` accepts both packages. Settings are reserved there, so `activate()` gets no context, and the contract tests prove compiled 5 and 50 in that case. |
| F-3 | A member that declares values receives `context.settings = {}` when no Settings file exists, so "absent" means stock and not the compiled value. | **TRUE** | Gate: `no Settings file -> delivery with 0 values`. This is why the example files are a migration: they re-enable today's values. |
| F-4 | An enabled loose copy of the same addon makes the package fail closed. | **TRUE** | Gate: `conflict kind=target key=<key> holder=loose:Inject/<file> resolution=later-sorted-source-fails-closed`. Disabling the loose row resolves it. |
| F-5 | The loose root replacement `ec368d4901690a15 (Octavia Mallet No Cover exact flags).lua_B` conflicts with the Octavia package. | **FALSE** | Replacement keys and target keys are separate claim sets (`resolve_conflicts`). Gate: both packages are accepted next to it. |
| F-6 | The Ice Wave source is a raw-hash U44 source. | **FALSE** | `recompile-u44` without a map rejects `Name__ff67e37d` (`unresolved source alias`). `recompile-u44-raw` emits `ff67e37d`, which appears in none of the 5,474 stock modules. The source is a U43-alias source: with `profiles/u44/name-map.tsv` (`ff67e37d → e6841eeb`, which is in 35 stock modules) it reproduces the installed `dcedc4a2…` byte for byte. |
| F-7 | The addon edits change nothing outside the edited functions and add no wrong native-name hash. | **TRUE** | const-identity against the installed addons shows only additions, and only in the edited prototypes; there are 0 class swaps. Every added hash is used by the installed addon (`type` `404f8a8c`, `math` `b6e30ca3`) or by the stock target module (`floor` `d4f2b58e`, in stock BardMusic). |
| F-8 | The NAMECALL callsite gate still passes. | **TRUE** | `callsite_audit.py addon` at `284263b`: Mallet p16/i596 `NAMECALL :PushFloatArg` is OK; Ice Wave p7/i42, i53 and i65 are OK. |

## Form chosen

Two optional packages, `Packages/Octavia/` and `Packages/Frost/`, each with one single-key target-addon member and
`package.json` declarations. The existing format needs no bootstrapper change and no loose-declaration spec (F-1).

Rejected alternatives:

- **One `Packages/Abilities/`.** It would join two unrelated abilities into one all-or-nothing unit and one SCRIPTS
  row, so an Ice Wave failure would also drop Mallet. Two packages keep today's two independent rows and
  package-local failure.
- **Loose-file declarations.** They are not needed. They would also duplicate the package manifest and its
  all-or-nothing validation.

## Settings exposed

| Package | Value id | Row labels (from the gate's page model) | Type | Stock | Min–max | Unticked or absent | Compiled (no `context.settings`) |
|---|---|---|---|---|---|---|---|
| Octavia | `mallet.threat_level` | `Custom Forced threat level`, INPUTCOUNT `Forced threat level (stock 5)` | int | 5 | 0–5 | the game's dynamic level: `floor(Lerp(5, 0, min(1, pool/1500)))` | forced 5 |
| Frost | `ice_wave.bonus_per_cold_stack` | `Custom Bonus per Cold stack`, INPUTBOX `Bonus per Cold stack (stock 0x)` | float | 0 | 0–100 | no bonus; the addon is inert (no capture, no `SetBaseAmount`, no card row) | 50 |

Mallet stock:

- The threat level has no single stock number, so the declared stock is 5, the level at an empty damage pool. The
  tooltip says: "Unticked: the game's dynamic level (5 while the Mallet's damage pool is empty, down to 0 at 1500).
  Ticked: always this level".
- "Forced" in the label says that ticking overrides the level and unticking keeps it dynamic.

Addon rule (the same as the Missions generator, CONTRACT_PHASE1 item 11). A value applies only when all of these hold:

- `enabled == true`;
- `stock` equals the compiled stock;
- `value` is a number, not NaN, and inside min–max (whole for int).

Otherwise the addon uses stock. Each `activate` call recomputes.

Source changes:

- `src/mallet-threat-settings.u44.luau`: one upvalue `forcedThreatLevel`; `activate(context)` resolves it;
  `transformFloatArgument` returns it at p16/i596 when it is not nil.
- `src/ice-wave-settings.u44.luau`: one upvalue `bonusPerStack` replaces the four literal 50s (gameplay, card, two
  diagnostic fields); `activate(context)` resolves it and arms the hooks only when it is not 0; the card hook returns
  the stock array unchanged when it is 0.

No new prototype, hook, polling or runtime primitive was added.

## Gates (all PASS)

`python tests/run_gates.py "<Warframe>\OpenWF\CustomScripts\Inject" <out>`: **29/29** (`evidence/run_gates.txt`,
`evidence/gates.json`).

- Tool identities: `derecomp.head.exe` `c1672d8d…7c58` (de-luau-toolchain `0299da9`, the committed U44 raw-hash
  build), name map `d27c3a00…4f59`, audit tool at `284263b`. Input identities: installed addons `22e0cb49…`,
  `dcedc4a2…`; stock BardMusic `c713c4d6…`, IceSpike `f903720d…`.
- U44 path: the unmodified previous sources rebuild to the installed bytes (Mallet `recompile-u44`; Ice Wave
  `recompile-u44` + name map).
- The candidates re-parse, two builds are byte-identical, and `de-roundtrip` reproduces the full body. `derecomp.exe`
  `b4221c48…` gives the same bytes.
- const-identity delta against the installed addons (F-7).
  - The tool verdict is FAIL by construction, because constants were added.
  - The gate accepts only additions in the edited prototypes, with allowed strings and proven hashes.
  - Mallet: 13/14 prototypes equal, delta only in p11 (activate). Ice Wave: 36/37 equal for hashes and strings,
    delta only in p30 (a `SETFIELD S:bonusPerStack`) and p34 (activate).
  - cfg-identity is informative only: the differences are only in the edited prototypes and the main chunk (Mallet
    p10, p11, p13; Ice Wave p27, p30, p31, p34, p36).
- IR check: `.settings`, `.enabled`, `.stock` and `.value` are string-keyed `GETFIELD`s, and the value id is a string
  constant.
- NAMECALL gate (F-8).
- Real-source contract under upstream Luau, with the declaration injected from `package.json`:
  - Mallet, 25 cases: compiled, stock, each of 0–5, and every rejection. The 8 unrelated PushFloatArg sites stay
    unchanged.
  - Ice Wave, 16 cases, through the stock p7 hook order (SetBaseAmount i42 → SetSource i53 → DamageDD i65
    before/after): `installed = 100·(1 + min(stacks,10)·bonus·strength)`, the amount is restored after DamageDD, the
    inert mode never calls `IsNull`, and the card rows are checked.
- Package: exactly `package.json` + one `.lua_B` member, and the committed bytes equal the rebuild.

`tools/run_bootstrapper_gates.ps1` (bootstrapper `7028479` and `3ca9564`, exported with `git archive`; the checkers are
built from those exact revisions with MSVC `/W4 /WX`, 0 warnings): **7/7** (`evidence/bootstrapper/*.txt`; the runner writes `.log`, renamed here because `*.log` is gitignored).

- `verify_addon_settings.ps1` at `7028479`: ADDON SETTINGS GATES PASS, 130 PASS lines, 0 FAIL. It is fixed to the
  phase2i fixtures, so it is a regression of the primitive.
- `verify_script_packages.ps1 -AdmitPackage` for Octavia and Frost, at `7028479` (settings) and `3ca9564` (installed
  DLL): all PASS.
  - Both packages are accepted, each as one `target-addon` member with the expected key.
  - At `7028479`, the no-file summary is `file=absent … effective=0 … members_staged=1/1`.
- `tools/settings_package_gate.cpp` (the exact `packages.cpp` + `settings_core.hpp` + `settings_ui_core.hpp`):
  SETTINGS PACKAGE GATE PASS.
  - Declarations are accepted by the strict parser.
  - Delivery for no file, the example file, `use_stock`, `enabled=false`, group off, out of range, recorded stock
    differs and a malformed file. Each fallback changes the delivery identity, which forces cleanup and activate.
  - The loose-copy conflict and its resolution.
  - Coexistence with the loose Mallet root replacement.
  - The SCRIPT SETTINGS page model: labels, INPUTCOUNT/INPUTBOX, bounds, and tooltips within budget and not cut.

## Artifacts

| File | Bytes | SHA-256 |
|---|---|---|
| `package/Octavia/ec368d4901690a15.MalletOverguardAndCard.target.addon.lua_B` | 3,798 | `1e3682a4bacf46ef4b15bcedb71ad402a2d9bd01540e410abe0a5419b418bb86` |
| `package/Octavia/package.json` (R1; pre-R1 was 1,138 B `c2416088…aed0a`) | 1,173 | `35b4d5efa19e091ec14bc3ed226e321fe1be966a27b89e7a3314b8bd879ecaae` |
| `package/Frost/8fba3a28f8fef624.IceWaveColdStackDamage.target.addon.lua_B` | 14,118 | `f3ddb4336b13e321d236a5f543ce1e5122783b9f3b5e619604073f2db8ea5e71` |
| `package/Frost/package.json` (R1; pre-R1 was 1,128 B `f1185838…d917c`) | 1,163 | `10e96fb6f449ad7a6544e8d30e4f724e9bedcb98b41a92ec3e28acde8bafda0d` |
| `settings-example/Octavia.json` (threat 5 enabled) | 253 | `485fa61205c716cf2a06a9979783c56e421bc678401cad84d74350afc42263cb` |
| `settings-example/Frost.json` (bonus 50 enabled) | 264 | `bf6b810e9f242b1aade8277bdcc0d8bd8c1da3bdae850a2c233299c9950ed82e` |

Install, rollback and live-test steps: `work/staging/settings-second-consumer/README.md`.

## Limitations and follow-ups (exact)

- **Offline only.** U-1 stays UNRESOLVED until the live steps in the staging README pass on both targets under DLL
  `ed2a996d` (R1; `d2f22650` before R1). Script load does not prove callback execution, and a card row does not prove damage.
- **Migration is required under ADDON_SETTINGS_V1.** Without `Settings/Octavia.json` and `Settings/Frost.json`,
  an ADDON_SETTINGS_V1 DLL delivers an empty table and both addons go to stock (F-3). The example files reproduce today's values.
- **Tooltip wording: resolved by R1** (section below). Superseded text, kept as history: `value_tooltip` always
  appended "Custom value applies only where the live value equals stock", which is false for these two addons.
- **`verify_addon_settings -Package`: resolved by R1** (bootstrapper `dd5414c`). The item below is kept as history.
- **`verify_addon_settings` takes no external package.** It runs only the phase2i fixtures. This note's
  `settings_package_gate.cpp` fills the gap for these packages. Spec for the owner: `verify_addon_settings.ps1
  -Package <folder> -Values <file>`, which runs parse → evaluate → delivery → page model and prints rows.
- **Stock gate scripts hit MAX_PATH** when the repository sits deeper than today. Nested `CustomScripts` trees under
  `RENOVICE_TOOLCHAIN/bin/...` exceed 260 characters, and `std::filesystem::copy` and `cl.exe` fail. The runner
  therefore uses a short `-Out` (`%LOCALAPPDATA%\Temp\scg`).
- Mallet threat 5 remains a preference, not a lock (see `MALLET_THREAT_CALLSITE_FIX_2026-09-29`). The threat value is
  used only when the stock integer changes (stock push cadence), so a new forced level shows at the next stock push
  after F9.

## Hypothesis report

- **Hypothesis:** ADDON_SETTINGS_V1 can drive two unrelated existing addons (a native float transform and a native
  damage rewrite) through `package.json` declarations only, with no bootstrapper change, while the addons keep today's
  behaviour when `context.settings` is absent.
- **Finding:** True (offline); live: Unconfirmed.
- **Reason:**
  - The exact loader and settings code accepts both packages, delivers the declared values and builds the native
    rows.
  - The real addon sources pass the contract under Luau.
  - The bytes pass the U44 identity, determinism and NAMECALL gates.
  - The installed-DLL revision admits the packages with compiled defaults.
- **Next step:** the user installs `ed2a996d` (editor-phase2-3, R1; the R1 manifests need it), then these packages with their `Settings` files, and
  runs the staging README live steps 1–8.

## Revision R1: `"stock_check": "none"` (2026-09-30)

Contract: `work/research/universal-mission-editor-2026-09-29/CONTRACT_PHASE1.md` "Revision R1" (bootstrapper
`feat/ingame-settings-editor-2026-09-30` `dd5414c`, DLL `ed2a996d…`). Optional per value `"stock_check": "live" |
"none"`, addon lane only, absent = `live`; display only (the SCRIPT SETTINGS tooltip sentence).

- Hypothesis: adding `"stock_check": "none"` to `mallet.threat_level` and `ice_wave.bonus_per_cold_stack` removes the
  false live-stock sentence from both tooltips and changes nothing else (addon bytes, deliveries, log lines).
  Result: **TRUE (offline)**.
- Change: the hand-written manifests `package/Octavia/package.json` and `package/Frost/package.json` (the source of
  record; `tests/run_gates.py` copies them into the staged folders) carry `"stock_check": "none"` directly after
  `"applies"`. The sources, the addon bytes and the settings examples are unchanged.
- `tests/run_gates.py`: 29/29 (`evidence/run_gates.txt`, `evidence/gates.json`, now the R1 run). Addon SHA-256s are
  unchanged (`1e3682a4…`, `f3ddb433…`); only `manifest_sha256` differs.
- `verify_addon_settings.ps1 -Package <dir> -Settings <file>` at bootstrapper `dd5414c`
  (`evidence/bootstrapper/verify_addon_settings_R1_{Octavia,Frost,Missions}.txt`): each exit 0, 150 PASS, 0 FAIL,
  ADDON SETTINGS GATES PASS.
  - Octavia and Frost: `DECL … stock_check=none`; the value tooltip ends at "Applies: live, at the next read."; delivery
    identities `fee07438…` and `6f4414d1…`, the same as without the field.
  - Missions phase2i (no field): `stock_check=live(default)`, and the addon tooltips keep the sentence.
- **Compatibility.** These manifests need DLL `ed2a996d…` or later for their settings. A pre-R1 settings DLL
  (`d2f22650`) rejects them as `unknown-field=stock_check`, which disables only these packages' settings (compiled
  5 and 50 apply). The installed `6f100ebc` (`3ca9564`) skips member `settings` as reserved; the R1 manifests were not
  re-gated at that revision.
- The `7028479`/`3ca9564` bootstrapper evidence above (`tools/run_bootstrapper_gates.ps1`) is the pre-R1 run with
  the pre-R1 manifests and was not repeated.
- Staged: `work/staging/settings-second-consumer/` (R1; the previous manifests are in `older/Packages/`).

## Revision R7: author's defaults (2026-09-30)

Live feedback: the Ice Wave card showed the bonus only after "Custom" was ticked in SCRIPT SETTINGS, and "Restore stock
values" turned the bonus off (stock 0x) instead of returning to the addon's 50x. Contract `CONTRACT_PHASE1.md` Revision R7
(bootstrapper `feat/settings-r7-hierarchy-2026-09-30`) adds the optional declaration field `default` (addon lane only).

| Hypothesis | Result | Evidence |
|---|---|---|
| With `context.settings` present and no entry, the Frost addon applies 0 (inert), not its compiled 50 | **TRUE** | `src/ice-wave-settings.u44.luau` L1238-1251: `bonus = 0` as soon as `context.settings` is a table; only an enabled entry with `stock == 0` sets another bonus. The Mallet addon keeps the game's dynamic level in the same case (L245-255). |
| Declaring `default` makes the host deliver the author's default without a file entry, so no addon byte changes | **TRUE (offline)** | Bootstrapper R7 `member_delivery`: a declared default is delivered as `{ enabled = true, value = default, stock }`; gate `verify_addon_settings.ps1` ("declared default: delivered at 50 with no file or a disabled entry ...") and `-Package` on these manifests (`DELIVER ... ice_wave.bonus_per_cold_stack ... value = 50, stock = 0`). |

Changes (manifests only; the addon `.lua_B` bytes and the example `Settings` files are unchanged):

- `package/Frost/package.json`: `"default": 50`; scope "Ice Wave damage grows with each Cold stack on the target (up to 10)
  and with Ability Strength. 0 turns the bonus off." SCRIPT SETTINGS shows "Bonus per Cold stack: 50x (default)".
- `package/Octavia/package.json`: `"default": 5` (forced threat 5, as the addon does today); scope "The Mallet always draws
  enemy attention at this threat level (0 to 5). Turn the Octavia script off in SCRIPTS for the game's own changing level."
- Neither package has `path` (older layout): SCRIPT SETTINGS lists the value directly on the package page; the render gate
  covers both (`verify_script_settings_render.ps1` section 1c).

Compatibility: a DLL before R7 rejects the field (`unknown-field=default`, settings capability only); the members then get
`context.settings = nil` and run their compiled values, which are the same 50 and 5. The pinned-revision gate of this note
(`tools/run_bootstrapper_gates.ps1`, R1-R5 bootstrappers) therefore reports the settings capability as rejected for these
manifests; that is the documented older-DLL behaviour, not a regression. Staged in `work/staging/settings-second-consumer/`
(R1 manifests moved to `older/r1/`).
