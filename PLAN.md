# Release plan

## 0.2.0-rc1 candidate — implemented

- End-to-end plan/preset/assignment/checklist/transfer workflow
- FEP2 atomic party protocol, maximum-record size test, and plain-text fallback
- Safe migration and import/export boundaries
- Optional TomTom/Auctionator capability detection
- Interface 16001 UI safeguards and native-default appearance
- Deterministic Lua syntax, data, protocol, migration, conflict, restricted-API, and archive checks
- Installable ZIP and local `_classic_beta_` deployment

## Pre-release gate

The owner must smoke-test the candidate in the real client. Do not publish GitHub or CurseForge releases before that approval.

## Bounded blocker

Object selection and material computation await a redistributable official/public camp-object/Blueprint source. Exact checked sources and zero verified coverage are in `DATA_PROVENANCE.md`. No sample or inferred content may be promoted into production.

## Smoke-test checklist

1. `/reload`, `/fep`, close button, drag persistence, combat hide/refusal.
2. Switch Blizzard/Bronze appearances; inspect labels, buttons, and absence of red legacy textures.
3. Change 3/5/10 slots; save/load/delete presets.
4. Use Transfer export/import and try malformed/unknown-ID text.
5. Test Dungeon/Travel readiness checkboxes.
6. In a two-client group, share and verify atomic FEP2 receipt; copy Manual Summary.
7. Verify `/fep status` reports zero verified records and optional addon status accurately.
