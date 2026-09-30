local _, FEP = ...

-- Provenance is deliberately shipped even when verified record coverage is zero.
-- It prevents absence of evidence from silently becoming invented game data.
FEP.DataManifest = {
    schema = 1,
    verifiedOn = "2026-09-30",
    targetBuild = "1.60.1.70124 / Interface 16001",
    coverage = { verifiedRecords = 0, claimedComplete = false },
    sources = {
        {
            id = "blizzard-product-build",
            publisher = "Blizzard Entertainment",
            url = "https://us.version.battle.net/v1/products/wow_classic_beta/versions",
            build = "1.60.1.70124",
            license = "Public product metadata; names/descriptions remain Blizzard copyright",
            verifiedOn = "2026-09-30",
            result = "Build/interface verified; no public camp-object blueprint/material/buff table exposed.",
        },
        {
            id = "blizzard-community-api",
            publisher = "Blizzard Entertainment",
            url = "https://develop.battle.net/documentation/world-of-warcraft",
            build = "API documentation current 2026-09-30",
            license = "Blizzard Developer API Terms",
            verifiedOn = "2026-09-30",
            result = "No documented Forever camp-object endpoint or namespace.",
        },
        {
            id = "blizzard-ui-api",
            publisher = "Blizzard Entertainment",
            url = "https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated",
            build = "Public generated UI API source checked 2026-09-30",
            license = "Repository/public Blizzard UI source terms",
            verifiedOn = "2026-09-30",
            result = "No documented camp-object/blueprint API suitable for authoritative extraction.",
        },
    },
    blocker = "No redistributable official/public source currently identifies Forever camp objects, blueprint recipes, material quantities, or stacking semantics. Coverage is intentionally zero; records must not be inferred from names, screenshots, or unrelated WoW items.",
}

FEP:RegisterCampObjects("official-public-v1", {}, FEP.DataManifest)
