# Existing-solutions preflight

Repeated 2026-09-30 for 0.2.0-rc1.

- Public web search was attempted; the configured search provider was unavailable, so direct public endpoints, GitHub search, Blizzard developer documentation, public generated UI API source, and the installed public beta build metadata were checked instead.
- No maintained Forever camp planner/data pack or documented official camp-object API was found. Exact authority/coverage findings are in `DATA_PROVENANCE.md`.
- Established WoW patterns retained: Blizzard Settings canvas, `C_ChatInfo`, SavedVariables migrations, provider-owned static data, optional-addon capability detection, and bounded addon messages.
- Ace3 remains unnecessary for this small self-contained addon; no runtime dependency or third-party source code was added.
- TomTom and Auctionator are detected only when installed and never required.

Repeat the data-source review whenever build metadata changes or Blizzard publishes a relevant API/data export.
