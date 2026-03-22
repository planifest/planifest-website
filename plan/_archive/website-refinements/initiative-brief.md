# Initiative Brief: Website Refinements

## Product Goal
Refine the Planifest documentation website's visual presentation and messaging to ensure high-quality consumption of the framework's literature. 

## Scope
1. **Domain Knowledge Terminology:** Strip out the deprecated concept of a "Domain Knowledge Store" as an active system component throughout the primary Planifest markdown documentation, replacing it with the formalized SDLC folders framework (`plan/`, `manifest/`, `docs/`). Move the Store into explicit roadmap context.
2. **Title Cleanup:** Modify the `build-docs.js` static builder to dynamically strip leading IDs from documentation headers in the live site (e.g., `p015-planifest-pipeline` becomes `Planifest Pipeline`).
3. **Dark Mode Contrast:** Correct Mermaid diagram CSS contrast issues to ensure legibility when dynamic native Dark Mode backgrounds are engaged, avoiding unreadable white-text-on-light-background conflicts.
4. **Version Log Purge:** Remove all instances of the deprecated "Version Log" table from every markdown file across `planifest-docs` and `planifest-framework` since file history relies solely on Git. Subsequently remove the obsolete `versionLogRegex` logic from the Vite `build-docs.js` pipeline.

## Out of Scope
- Rewriting core Planifest principles or framework methodology.
- Switching away from markdown-based static site generation.
