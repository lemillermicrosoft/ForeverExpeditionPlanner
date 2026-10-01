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
- Small draggable camp-choice button with manual camp context, persistent personal default, verified effects/materials, and assignment-aware recommendations
- No combat-log processing, protected actions, external telemetry, or secret-value assumptions

## Catalog status (bounded blocker)

The bundled verified catalog contains **zero records**. As of 2026-09-30, no redistributable official/public source found by this project exposes Forever camp-object IDs, Blueprint recipes, material quantities, buffs, or stacking semantics. We will not relabel unrelated WoW items, scrape private/NDA material, or infer facts from screenshots. The planner remains usable for structure, assignments, readiness, transfers, and future verified providers, but object selection and material aggregation are blocked until such a source exists.

The contextual panel is provider-driven: verified records registered later through `FEP:RegisterCampObjects` appear automatically. With zero records it explicitly says that there are no verified options instead of showing fixtures. Recommendations use only the saved personal default and the current bounded FEP2 plan's verified objects, buff keys, and assignments. They do not inspect live auras or infer unknown buffs/stacking.

See [DATA_PROVENANCE.md](DATA_PROVENANCE.md) for exact sources, build, license basis, date, results, and acceptance rules. Unknown fields remain absent rather than guessed.

## Camp context feasibility and safe fallback

An Interface 16001 audit found no documented, non-secret API/event that reliably identifies proximity to or interaction with a Forever campfire. Automatic sensing is therefore disabled. FEP does not inspect targets, names/nameplates, combat logs, mouseover units, or tooltips; it does not create secure actions or place/cast anything.

At a camp, run `/fep camp` to enable the manual context and reveal the small draggable button. Click it to review verified choices; click a choice to save the personal default. Run `/fep camp` again when leaving. Visibility and position persist safely, while context itself intentionally does not persist across login.

## Install and test

Copy the `ForeverExpeditionPlanner` folder into `_classic_beta_/Interface/AddOns/`, then enable it at character selection. Commands:

- `/fep` — toggle planner
- `/fep options` — options
- `/fep share` — explicit party sync
- `/fep export` — print transfer string
- `/fep status` — dataset, integration, and camp-detection status
- `/fep camp` — toggle manual camp context
- `/fep camp status` — explain detection and the current recommendation
- `/fep camp probe` — print the bounded client-side feasibility probe
- `/fep camp show|hide` — enable or hide the feature
- `/fep camp default <verified-id>` — save a verified personal default

The planner hides on combat entry and refuses to open during combat. The camp control is planning-only and has no placement or casting action.

### Exact client probe and smoke test

1. On Forever build `1.60.1.70124` / Interface `16001`, log in and run `/fep camp probe`. Confirm it reports `adapter manual-v1; automatic=false` and performs no target, nameplate, combat-log, mouseover, or tooltip inspection.
2. Run `/fep camp`. Confirm the small `CAMP` button appears, can be dragged, opens on click, and states that no verified additions are available with the bundled zero-record catalog.
3. Run `/reload`. Confirm the button position and visibility persist, but the button stays hidden until `/fep camp` explicitly activates context again.
4. Switch Blizzard/native and Bronze/custom appearances; repeat the panel and tooltip checks.
5. With a provenance-valid provider installed, confirm every option shows only its verified effect/material fields, clicking one persists the personal default, and `/fep camp status` explains whether the recommendation came from the FEP2 assignment, a verified effect absent from the current plan, the personal default, or deterministic catalog order.
6. In a two-client group, sync a bounded FEP2 plan with an assignment to the current character and confirm the assigned verified option is recommended. Enter combat and confirm the control never places, casts, targets, or performs a protected action.

## Development

```powershell
node scripts/validate.mjs
node scripts/test.mjs
./scripts/package.ps1
```

Packaging creates `dist/ForeverExpeditionPlanner-0.2.0-rc1.zip` with the addon folder as its root. No release is created by this workflow.

## Provider contract

`FEP:RegisterCampObjects(provider, records, manifest)` accepts only records with `id`, `name`, `category`, `description`, plus a `verification` table containing `source`, `url`, `build`, `license`, `verifiedOn`, and `status`. Materials require positive quantities. Buff/conflict keys must be explicitly sourced. Malformed and duplicate records are rejected. The camp UI consumes this registry directly, so future verified records require no production UI changes.

## License

Copyright 2026 Forever Expedition Planner Contributors. All rights reserved. Blizzard names and game data remain Blizzard Entertainment property; source references do not grant relicensing rights.
