# Forever Expedition Planner plan

## Alpha — implemented

- Modular core, storage, static-data registry, planner, party transport, checklists, conflict evaluator, native UI, and options
- Empty production catalog with opt-in developer fixtures
- Versioned `FEP1` addon-message prefix and plain-text fallback
- Static package validation and deterministic local packaging

## Beta — blocked on verified inputs

1. Obtain an authoritative camp-object source with stable IDs, names, categories, materials, icons, and stacking/conflict semantics.
2. Confirm Forever client API behavior for Interface 16001 on a real client.
3. Add localization boundaries and a verified data-provider manifest.
4. Add import/export schema versioning only if the game’s restricted branch safely supports the chosen encoding.
5. Run multiplayer interoperability tests for party, raid, and instance groups.

## Release readiness

- In-client smoke test: open/close, combat boundary, reload persistence, options registration
- Verify 3/5/10 slot truncation behavior is acceptable to product owner
- Verify addon-message size against the largest real identifiers
- Accessibility/readability pass at multiple UI scales
- Package metadata, screenshots, changelog, and release notes
- CurseForge project ID and approved release channel

## Explicit non-goals

- No combat automation or combat-log analysis
- No protected action execution
- No guessed camp data or stacking rules
- No external runtime frameworks
- No release/publish workflow in this repository alpha
