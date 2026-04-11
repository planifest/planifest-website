# Planifest

**Feature ID:** `website-nav-sitemap`
**Status:** `Completed`
**Lead Layer:** `Product / Engineering`

## 1. Executive Summary
Implementation of a responsive hamburger navigation menu and a static HTML sitemap for the confirmed design documentation site. This improves accessibility and discoverability of framework files without adding heavyweight UI components.

## 2. Component Inventory
The following components are impacted by this feature:
- `web-app` (frontend static site generator)

## 3. Product Specification
- **Navigation:** Mobile users will see a hamburger button that expands the primary links (`About`, `Structure`, `Master Plan`).
- **Sitemap Generator:** The `build-docs.js` script natively scans the `planifest-docs` directory and emits a `sitemap.html` containing a full link tree.
- **Footer Link:** The `index` and document template both feature a footer anchor linking directly to the new static sitemap.

## 4. Engineering Model
- Lightweight vanilla JS class toggling for responsive menus (`.show` class on `.nav-links`).
- `main.ts` now intercepts click requests and dynamically fetches the entire domain context (`sitemap-data.json`) to populate the unified `.nav-links` dropdown. This renders the hamburger icon completely persistent.
- Static Generation (`build-docs.js`) handles iterating markdown arrays into `<ol>/<ul>` structures specifically for the footer sitemap link.
- Vite powers the continuous build loop.

## 5. Risk Assessment
- **Risk:** The injected JS bundle might interfere with the static site functionality.
- **Mitigation:** Used vanilla DOM selectors wrapped in `DOMContentLoaded`. Keeps the bundle lightweight and robust. Minimum dependencies added.

