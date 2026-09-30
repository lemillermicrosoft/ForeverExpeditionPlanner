# Existing-solutions preflight

Performed 2026-09-30 before implementation.

- A current web/GitHub search was attempted, but the configured search provider was unavailable in this build environment.
- Established WoW addon patterns considered: Ace3-style modular separation, Blizzard’s native Settings canvas, `C_ChatInfo` addon-message prefixes, SavedVariables defaults merging, and provider-owned static data.
- Decision: keep the addon self-contained. Ace3 is mature and permissively licensed, but vendoring it would add substantial code for an MVP that needs only a small event dispatcher and one options canvas. No runtime dependency is justified.
- Reused patterns, not copied code: namespace passed through `...`, TOC-ordered modules, recursive defaults merge, versioned message prefix, native Settings registration with legacy fallback, and data-provider registration.
- No third-party source code was copied into this repository.

Before beta, repeat the online search when a provider is available and compare maintained camp-planning addons or verified Forever data packs.
