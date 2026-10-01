# Release plan

## 0.2.0-rc1 candidate — implemented

- End-to-end plan/preset/assignment/checklist/transfer workflow
- FEP2 atomic party protocol, maximum-record size test, and plain-text fallback
- Safe migration and import/export boundaries
- Optional TomTom/Auctionator capability detection
- Interface 16001 UI safeguards and native-default appearance
- Contextual camp-choice button with safe manual context, persistent default/position/visibility, and provider-driven zero-data UI
- Assignment-aware, explainable recommendations bounded to verified catalog records and current FEP2 plan data
- Deterministic Lua syntax, data, protocol, migration, conflict, restricted-API, and archive checks
- Installable ZIP and local `_classic_beta_` deployment

## Pre-release gate

The owner must smoke-test the candidate in the real client. Do not publish GitHub or CurseForge releases before that approval.

## Bounded blockers

Object selection and material computation await a redistributable official/public camp-object/Blueprint source. Exact checked sources and zero verified coverage are in `DATA_PROVENANCE.md`. No sample or inferred content may be promoted into production.

Automatic campfire sensing is also bounded: the Interface 16001 audit found no documented non-secret event/API that proves camp proximity or interaction. `manual-v1` is the production adapter until such an API is directly verified. No target/name/nameplate, combat-log, mouseover, or tooltip scanning is an acceptable substitute.

## Smoke-test checklist

1. `/reload`, `/fep`, close button, drag persistence, combat hide/refusal.
2. Switch Blizzard/Bronze appearances; inspect labels, buttons, and absence of red legacy textures.
3. Change 3/5/10 slots; save/load/delete presets.
4. Use Transfer export/import and try malformed/unknown-ID text.
5. Test Dungeon/Travel readiness checkboxes.
6. In a two-client group, share and verify atomic FEP2 receipt; copy Manual Summary.
7. Verify `/fep status` reports zero verified records and optional addon status accurately.
8. Run `/fep camp probe`, then `/fep camp`; verify the exact zero-data message, drag persistence after `/reload`, non-persistent manual context, visibility option, both appearances, and no placement/casting action.
9. With a provenance-valid test provider installed separately, verify effect/material rendering, default persistence, and explainable FEP2 assignment/effect-gap recommendations.
