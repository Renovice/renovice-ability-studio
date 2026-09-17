# Helminth identity registry — 2026-08-28
## H1 — installed client metadata alone identifies every subsumable ability

**Result: FALSE.** Client metadata proves powersuit ownership and exact ability
asset paths, but the Helminth/subsumable policy is curated game data rather
than a reliable property on every installed ability record.

## H2 — the official Wiki module can provide exact join keys

**Result: TRUE.** `Module:Ability/data` contains curated entries with
`Subsumable=true` and an `InternalName`. The refresh tool uses the Wiki API,
parses balanced Lua tables, and retains only rows that have both values. The
`InternalName` is joined to Ability Studio's exact installed asset path; display
name alone is never used as identity.

The generated registry currently contains 79 rows. Example:

```text
Resonator  Octavia  /Lotus/Powersuits/Bard/Abilities/BardCharmAbility
```

## Refresh and validation

Run:

```powershell
.\RESEARCH\tools\refresh-helminth-registry.ps1
```

The tool sends an explicit user agent, records retrieval time and source URL,
rejects duplicate asset paths, and refuses to replace the registry if fewer
than 40 valid rows are recovered. The committed TSV is therefore a reviewable
snapshot; Ability Studio does not scrape continuously during ordinary use.

## UI behavior

Catalog entries whose exact ability asset path is in the registry display a
`[HELMINTH]` marker and show the curated subsumed ability identity in the target
panel. Missing rows remain unmarked rather than guessed.
