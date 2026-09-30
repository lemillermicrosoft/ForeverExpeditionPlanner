# Forever Expedition Planner

A privacy-first planning addon for World of Warcraft: Forever (`Interface 16001`). **0.2.0-rc1 is a smoke-test candidate, not a published release.**

## What works

- Searchable, provenance-enforced catalog registry with safe item tooltips/icons when verified item IDs exist
- 3/5/10-slot plans, named presets, material aggregation, and verified data-driven non-stacking warnings
- Party assignments and atomic protocol-v2 sync; every message is bounded to 240 bytes
- Copyable plain-text fallback summary for players without the addon
- Dungeon and travel readiness templates
- `FEPX1` plan import/export with bounded parsing, unknown-ID rejection, and schema migrations
- Optional TomTom/Auctionator detection without hard dependencies
- Blizzard/native default plus optional Bronze appearance
- No combat-log processing, protected actions, external telemetry, or secret-value assumptions

## Catalog status (bounded blocker)

The bundled verified catalog contains **zero records**. As of 2026-09-30, no redistributable official/public source found by this project exposes Forever camp-object IDs, Blueprint recipes, material quantities, buffs, or stacking semantics. We will not relabel unrelated WoW items, scrape private/NDA material, or infer facts from screenshots. The planner remains usable for structure, assignments, readiness, transfers, and future verified providers, but object selection and material aggregation are blocked until such a source exists.

See [DATA_PROVENANCE.md](DATA_PROVENANCE.md) for exact sources, build, license basis, date, results, and acceptance rules. Unknown fields remain absent rather than guessed.

## Install and test

Copy the `ForeverExpeditionPlanner` folder into `_classic_beta_/Interface/AddOns/`, then enable it at character selection. Commands:

- `/fep` — toggle
- `/fep options` — options
- `/fep share` — explicit party sync
- `/fep export` — print transfer string
- `/fep status` — dataset/integration status

The planner hides on combat entry and refuses to open during combat.

## Development

```powershell
node scripts/validate.mjs
node scripts/test.mjs
./scripts/package.ps1
```

Packaging creates `dist/ForeverExpeditionPlanner-0.2.0-rc1.zip` with the addon folder as its root. No release is created by this workflow.

## Provider contract

`FEP:RegisterCampObjects(provider, records, manifest)` accepts only records with `id`, `name`, `category`, `description`, plus a `verification` table containing `source`, `url`, `build`, `license`, `verifiedOn`, and `status`. Materials require positive quantities. Buff/conflict keys must be explicitly sourced. Malformed and duplicate records are rejected.

## License

Copyright 2026 Forever Expedition Planner Contributors. All rights reserved. Blizzard names and game data remain Blizzard Entertainment property; source references do not grant relicensing rights.
