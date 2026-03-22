# Planifest - Website Refinements

**Initiative:** website-refinements
**Status:** Completed
**Date:** 2026-03-22
**Component Target:** `web-app`
**Component Mode:** Refinement (Existing)

## Architecture Overview

1. **Information Architecture Update:** The strategy documents across `planifest-docs/*` are systematically refactored to align the terminology regarding "SDLC Folders" vs "Domain Knowledge Store".
2. **Regex Parsing:** A regex injection inside `src/web-app/scripts/build-docs.js` is leveraged to capture and trim document prefixes when producing the frontend JSON sitemap array.
3. **Design System (Diagraming):** Direct `style` background fills in `.md` mermaid charts are reverted to `transparent` paired with semantic dashed strokes to permit dark-mode container flexibility.

## Affected Components
- `c:\d\planifest-docs\planifest-docs\*`
- `c:\d\planifest-docs\src\web-app\scripts\build-docs.js`
- `c:\d\planifest-docs\src\web-app\component.json`
