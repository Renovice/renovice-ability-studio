# Missions SCRIPT SETTINGS R7: page tree, one row per value, defaults audit, Quick settings (2026-09-30)

Client 44.0.2 (`2026.09.28.13.06`). Branch `feat/mission-settings-r7-2026-09-30` (from `4511059`, R5). Contract:
`work/research/universal-mission-editor-2026-09-29/CONTRACT_PHASE1.md` Revision R7; runtime: bootstrapper
`feat/settings-r7-hierarchy-2026-09-30` (`RESEARCH/SETTINGS_R7_HIERARCHY_2026-09-30/README.md`). Offline only: no game or
server folder was written (installed files were only read); nothing pushed. The parallel R8 live-literal work
(`feat/live-literals-recipes-2026-09-30`) is not in this branch.

## User feedback addressed

The R5 Missions page was a long flat list of section buttons ("Control Area: 1 value" twice, "Disruption::",
"X: advanced" next to "X", Descendia modes scattered), tooltips listed nodes and MT codes, every value took two rows, and
defaults did not match what the player sees (Mobile Defense "80 s" is 60-80 s by node). Target: Missions → mission type →
category → value rows → value page; per-player sets; a Quick settings page; plain tooltips; defaults as experienced.

## Hypotheses

| # | Hypothesis | Result | Evidence |
|---|---|---|---|
| L1 | The broken titles are page-model cuts, not registry labels | **TRUE** | The group labels are clean ("Disruption: advanced"); the bootstrapper cut "<label>: N values - M custom" to 40 characters (bootstrapper record R7-1). R7 drops sections from the navigation. |
| L2 | A category/set tree can be expressed with one field (`path`) plus a row text, with no separate "set" field | **TRUE** | Sets are one more `path` level ("Max enemies at once" → Solo..Squad); named variants are a sub-page ("Hard nodes"). 112 pages for 293 values; the page model and the render gate walk them. |
| L3 | Every registry stock matches the 44.0.2 decompile | **TRUE (0 wrong of 294)** | Defaults audit (research agent over `work/research/universal-mission-editor-2026-09-29/decomp`, per value: code line, player sentence, verdict): 262 CONFIRMED single numbers, 32 RANGE/formula, 0 CHANGED, 0 UNCONFIRMED. `evidence/defaults_audit.json` in the staging folder. |
| L4 | Some single-number defaults mislead the player | **TRUE (19 labels, 21 notes)** | Masters that drive several rows (Defection, Shrine, Mirror Defense, Excavation, Faceoff kills) and the Mobile Defense timer have a range, not the first row's number (tables below). |
| L5 | `disruption.treasure_goblin.tier` is a strength a player can tune | **FALSE** | Audit: the game matches the value against the mission's enemy list (an id), so any other value switches treasure Demolysts off. Hidden (`ui.hidden`), never declared; the addon loses that one hook (63 → 62). |
| L6 | `faceoff.spawn_params.tier_up_interval` is seconds | **FALSE** | `tier = Clamp(floor(PvPvECurrentStep * tierUpInterval - 1), 0, maxTier)`: tiers per objective step. Unit removed, row "Tiers per objective step". |
| L7 | The Deepmines control area is Orb Vallis | **FALSE** | ExportRegions node `NokkoColony` = "Deepmines" (Venus, Free Roam, level 30-40), dict text "Location: The Deepmines below Fortuna, Venus". The "Fortuna mines" the user named is almost certainly the Deepmines (not live-verified). Its hold time has no stock in Lua (mission resource), so it is not declared. Orb Vallis bounties have no Control Area stage. |

## What changed

- **`tools/player_layout.py` (new, called by `player_text.py` and `register_registry.py`).** For all 291 player-text rows and
  28 masters: `ui.path` (with category), `ui.row`, `ui.quick` (8 headline values), `ui.default_label` (19), `ui.unit` fix
  (1), `ui.hidden` (1), `ui.group` from the category (Advanced → `<family>_advanced`, everything else → `<family>`),
  `ui.rank` (display order), `ui_groups[*].order` renumbered so mission types sort alphabetically (merged families right
  after their host), and the R7 description (`ui.scope_text`; the R5 sentence kept as `ui.r5_scope_text`). Gates: every
  shown value placed once, path/row/quick/label budgets, "<row>: <default> (default)" within 40, no "::", descriptions (one
  or two sentences, <= 200, <= 3 commas, no "stock", no MT_/id/camelCase), (page, row) unique, no row named like a page.
  Registry meta `ui_layout` (`RENOVICE_MISSION_LAYOUT_V1`). Rows without an entry get [type, (sub,) "Advanced"].
- **Generator (`src/mission_profiles.inl`).** Declarations carry `path`, `row`, `quick`, `default_label`; a package build
  collapses a category level whose parent would hold that one category only (`r7_collapse_paths`); a literal value is
  declared as `type: "enum"` with the default and the built value as its two options; strict pre-check knows the R7 fields;
  `verify_mission_ui` checks the R7 fields and description rules when `ui_layout` is present; new package gate
  `settings-layout` (path and row on every value, one row per (page, text), no row named like a sibling page, unique quick
  labels, no "::", description rules); the label-budget gate checks the R7 value row.
- **Self-test (`src/core.cpp`):** the R5 player-text case also checks the R7 fields and rejects (no sentence end, three
  sentences, "stock", MT code, node list, 201 characters, missing path, "::" in a path, a 34-character row, a quick label
  ending in ":"); the package case compares the declaration with its registry row except the collapsed path.

## Navigation (staged package, `evidence/navigation_tree.txt`)

```
Missions
  Quick settings: 2 on
  Capture | Colonist Door Defense | Control Area | Defection | Defense | Descendia | Disruption | Entrati Swarm | Excavation
  Exterminate | Faceoff | Five Fates | Infested Salvage | Lantern | Mirror Defense | Mobile Defense | Orphix Venom
  Purgatory | Purge | Survival | Void Cascade | Void Flood
  Reset all to defaults
Survival
  Timers: Time between rewards: 150 s | Alert mission length: 600 s (default) | Life support (7 rows)
  Rewards / drops (9 rows, "Pickup drops when low: 1.5x (default)" ...)
  Advanced: Damage at 0%: 0.05 (default) | Enemy level (9 rows)
Mobile Defense
  Timers: Time per terminal: 60-80 s (default)            (choices "60-80 s (default)" / "20 s" on its value page)
  Enemies: Sentient Anomaly: max enemies: Solo: 6 (default) ... Squad: 12 (default)
Descendia
  Destroy Targets: Targets to destroy: Solo: 15 (default) ... Squad: 60 (default)
  Shrine Defense
    Timers: Offering stage time: 420 s (default)
    Enemies
      Max enemies at once: Solo: 7-20 (default) ... Squad: 19-35 (default)
        Offering stage | Boss stage | Steel Path offering | Steel Path boss (8 rows each: Most at once / Refill below)
      Time between waves: Solo: 9-15 s (default) ... Squad: 7-12 s (default)
        Offering stage | Boss stage | Steel Path offering | Steel Path boss (Solo..Squad)
```

Survival has no Enemies category: no Lua owner for Survival enemy counts exists (R5 matrix: native or level data). The
render gate therefore walks Mirror Defense → Enemies → Max enemies at once → Squad for the brief's example.

## Defaults audit: displayed defaults changed (19 labels)

| Value(s) | R5 showed | R7 shows | Why |
|---|---|---|---|
| `mobiledefense.time_per_terminal` | 80 s | **60-80 s** | Total `Lerp(180, 240, difficulty)` split over 3 terminals; the player sees 60 s on the easiest to 80 s on the hardest nodes (78-104 s on Archwing against Grineer). |
| `excavation.dig_time` | 100 s | **60-140 s** | 100 s normal, 140 s Elite Alert, 60 s Old World Salvage (the master sets all three). |
| `defection.max_enemies.p1..p4` | 10, 16, 22, 28 | **7-10, 12-16, 17-22, 22-28** | Blended between the easy and hard node values by node difficulty. |
| `shrine.max_enemies.p1..p4` | 10, 15, 20, 25 | **7-20, 9-25, 14-30, 19-35** | Offering, boss and Steel Path stages differ. |
| `shrine.respawn_delay.p1..p4` | 15, 14, 13, 12 s | **9-15 s, 9-14 s, 8-13 s, 7-12 s** | Same. |
| `loopdefend.max_enemies.p1..p4` | 18, 22, 28, 33 | **8-18, 15-25, 25-30, 30-35** | Regular and Infested, lower and upper counts. |
| `faceoff.exterminate_kills` | 160 | **130-160** | The goal is a random number in that range. |

Tooltip notes added (the number shown is right, the context was missing): Duviri Defense caps (fewer below level 30; Steel
Path uses the squad value), Faceoff max enemies p1-p3 (Steel Path uses the squad value), Mirror Defense masters (Steel Path
uses the squad value), Orphix spawn interval (90 s in the event), Survival alert length (used only when the mission sets no
length), Survival capsule interval and pickup time (Duviri likely uses its own value), Void Flood fractures (Duviri uses 5),
Void Cascade exolizer time (The Circuit uses its own timer), Purgatory reward tiers (solo earns at 1-3, each player moves
up one), Control Area Plains/Cambion (which bounties), Disruption boss health (Double Trouble only).

**Not confirmable here (reported, unchanged):** the Mirror Defense enemy counts are multiplied by a global the decompile
cannot name (`Name__1fd804e9`) before use; if it is not 1 on some nodes the on-screen count differs from the table. Meaning
(not the number) remains unconfirmed and says so in the tooltip for: Colonist Door bridge triggers, Lantern lamp fade
constants, Mirror Defense pickup/damage fields and tunnel interval, Survival capsule warning time, Orphix score per round.

## Gates

| Gate | Result |
|---|---|
| Build (`-Werror`) | 0 warnings, 0 errors |
| `python player_text.py` (R5 + R7 layout gates) | PASS: 291 rows, 28 masters, 5 hidden (+1 hidden by the layout) |
| `verify-missions` | 594/594 PASS, structure PASS |
| Self-test / ctest | 148/148 / 2/2 |
| `test_presets_and_sample.py` | 12 presets byte-identical, 36 rejections, 2b/2d/2e/2f/2g/2h/2i as recorded; full package identical to the staged set (293 values, 62 hooks) |
| `test_phase2k_hook_plan.py` / `test_phase2e_gates.py` / `test_phase2d_gates.py` | 6 / 7 / 7 PASS |
| Package build gates | de-roundtrip, declared keys 21, hook plan 62 (all idle/settled/retire-all), package-folder, `settings-layout PASS values=293 pages=112 quick=8`, `settings-declarations PASS values=293 groups=34 masters=24` |
| Bootstrapper R7 `verify_addon_settings -Package` (staged Missions + Frost + Octavia) | 209/209 with the installed values files, the staged ones and none; 415 pages; no switch row; every value one row |
| Bootstrapper R7 `verify_script_packages -AdmitPackage` | PACKAGE ACCEPT members=6 replacements=5 target_addons=1 target_keys=21 |

## Package inventory (R5 `6730755f` → R7 `4cb290f7`)

- 294 → 293 declared values (−1 hidden treasure Demolyst tier); 37 → 34 sections declared (Advanced sections without values
  are no longer declared: values moved to their category's section).
- Five replacement files byte-identical; addon changed only by the removed hook; package.json carries the R7 fields.
- Shipped choices unchanged (Survival 150 s on, Void Flood 4 on; Mobile Defense 20 s, Excavation 50 s, Control Area 30 s
  built and off). The user's installed values file stays valid (ids unchanged).

## Live test (not done here)

See `work/staging/editor-phase2-3/README.md` and `work/staging/missions-full-package/README.md`.
