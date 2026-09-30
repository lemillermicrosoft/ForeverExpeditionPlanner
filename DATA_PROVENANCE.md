# Data provenance

Verified: 2026-09-30. Target: WoW Classic Beta/Forever 1.60.1.70124, Interface 16001.

| Dataset/source | URL | License/redistribution basis | Result |
|---|---|---|---|
| Blizzard product version metadata | https://us.version.battle.net/v1/products/wow_classic_beta/versions | Public product metadata; underlying names remain Blizzard copyright | Confirms target build only; no camp records |
| Blizzard WoW Developer API docs | https://develop.battle.net/documentation/world-of-warcraft | Blizzard Developer API Terms | No documented Forever camp-object endpoint |
| Public generated Blizzard UI API source | https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated | Public repository/Blizzard UI source terms | No documented camp-object/Blueprint API suitable for extraction |

The machine's installed beta build and public web/GitHub searches were also inspected for discoverable documented APIs. Local caches, private account data, NDA sources, datamined guesses, and third-party prose were not treated as redistributable authority.

## Coverage

- Camp objects: 0 verified
- Blueprint recipes: 0 verified
- Materials/quantities: 0 verified
- Buff/conflict semantics: 0 verified
- Icons/item IDs: 0 verified

This is a bounded source-availability blocker, not an assertion that the game has no such content.

## Acceptance rule

A future record needs a stable ID, localized name, category, description, source URL, source/build, license basis, verification date/status, and direct evidence for every material, quantity, buff, conflict, item ID, and icon. Missing facts stay absent and are marked incomplete. Tests reject records without provenance.
