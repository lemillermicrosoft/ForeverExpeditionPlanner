# Forever Expedition Planner

Forever Expedition Planner is a self-contained, Forever-native World of Warcraft addon for planning camp loadouts before combat. This repository contains an **installable alpha** targeting the modern restricted Classic branch (`Interface: 16001`).

## Alpha features

- Searchable, provider-based camp-object data model
- 3, 5, or 10-slot camp loadouts
- Named saved presets
- Party “who brings what” assignments through versioned addon messages
- Readable manual summary for players without the addon
- Aggregated materials and dungeon-readiness checklists
- Data-driven duplicate/non-stacking warning architecture
- Bronze, dependency-free native UI
- Esc → Options → AddOns configuration and `/fep` commands
- Account-wide SavedVariables, including the planner window position

## Data integrity

No authoritative Forever camp-object dataset was available during this alpha build. Production therefore displays **“Verified camp data pack pending”** and does not invent content. Three conspicuously named sample fixtures can be enabled under **Options → AddOns → Forever Expedition Planner → Developer Mode**. They exist only to exercise UI and planner behavior.

A future verified data pack can register records at load time:

```lua
FEP:RegisterCampObjects("Verified Provider Name", {
  {
    id = "stable-provider-id",
    name = "Localized display name",
    category = "Category",
    description = "Description",
    tags = { "searchable", "terms" },
    materials = { { name = "Material", count = 2 } },
    buffs = { "verified-stacking-group" },
  },
})
```

`buffs` and `conflicts` are provider-supplied keys. The addon does not infer stacking behavior.

## Install

Copy the packaged `ForeverExpeditionPlanner` folder into:

`World of Warcraft/_classic_/Interface/AddOns/`

The folder must directly contain `ForeverExpeditionPlanner.toc`. Enable **Load out of date AddOns** only if the Forever client’s reported interface number differs from 16001.

Commands:

- `/fep` — toggle planner
- `/fep options` — open AddOns options
- `/fep share` — share assignments with group addon users
- `/fep help` — command reminder

The window closes when combat begins and will not open during combat. Its center-relative position persists across sessions and can be restored with **Reset window position** in AddOns options.

## Development

No external libraries, generated runtime dependencies, combat-log parsing, protected calls, or secret-value assumptions are used. Run static validation with:

```powershell
node scripts/validate.mjs
```

Build the installable folder with:

```powershell
./scripts/package.ps1
```

Outputs:

- `dist/ForeverExpeditionPlanner/` — clean install folder
- `dist/ForeverExpeditionPlanner-0.1.0-alpha.zip` — distributable archive whose root is the addon folder

## Compatibility note

The options panel prefers the modern `Settings` canvas API and retains a legacy `InterfaceOptions_AddCategory` fallback. Addon messaging similarly prefers `C_ChatInfo` with a legacy fallback. Real client smoke testing is still required on the target Forever build.

## License

Copyright © 2026 Forever Expedition Planner Contributors. All rights reserved. See [LICENSE](LICENSE).
