# Website Refinements

**Date:** 2026-03-22
**Feature:** website-refinements

## Changes Applied
- Replaced functional references to a theoretical "Domain Knowledge Store" across foundational documentation with concrete references to Planifest's SDLC document architecture (the `plan/`, `docs/`, and `manifest/` folders) per User constraints.
- Modifed the JSON sitemap builder (`src/web-app/scripts/build-docs.js`) to restore the raw JSON generation path and introduced a stripping regex to cleanly remove artifact ID prefixes (e.g. `p015`) during JSON processing to increase header legibility.
- Removed custom `fill` styles from numerous `planifest-docs` Mermaid diagrams to resolve poor contrast rendering in dark-mode clients and force dynamic background passthrough with explicit stroke-dasharray styling.
- Executed a global regex wipe of all legacy "Version Log" blocks across the entire repository to shift solely to Git accountability, and safely eliminated the downstream `build-docs.js` log extraction layer since it's no longer necessary.

## Component Affected
- `web-app` (Manifest scope and updated pipeline documentation reference path).
- `planifest-docs/*` (Strategy context content)

