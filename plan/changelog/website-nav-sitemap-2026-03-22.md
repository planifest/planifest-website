# Change Log: Website Navigation & Sitemap (website-nav-sitemap)
Date: 2026-03-22

## Executive Summary
Added responsive mobile navigation via a hamburger menu and built a statically-generated site map page to improve discoverability across the documentation site.

## What Changed
- **`src/web-app/src/style.css`**: Added responsive styling for the `.nav-links` container and `.hamburger-btn`. The hamburger menu toggles a dropdown natively.
- **`src/web-app/src/main.ts`**: Introduced vanilla JS listener to toggle the `.show` class on `.nav-links` when the hamburger button is clicked.
- **`src/web-app/index.html`**: Modified the navigation structure to include a `nav-actions` container, embedding the `<button class="hamburger-btn">`. Added an anchored footer link pointing to the new static sitemap.
- **`src/web-app/scripts/build-docs.js`**: Replicated the `nav-actions` and `hamburger-btn` footprint in the inline `template`. Added automatic metadata extraction to dump an aggregate `sitemap.html` in the build process. Added footer link to all docs pages.

## Why it Changed
Following user guidance, navigation elements needed strengthening. The modal-based approach was avoided in favor of a clean, responsive CSS dropdown navigation approach (mobile hamburger). A traditional static `sitemap.html` ensures all markdown file outputs remain easily indexed and navigable without heavyweight SPAs or JS side effects.

## Artifacts Produced
- `sitemap.html` (Static Output)
- `initiative-brief.md`
- `planifest.md`
