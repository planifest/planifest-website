# ADR-002: Build-Time Markdown Rendering

## Status
Accepted

## Context
A key feature of the website is presenting the existing Planifest documentation directly to readers. Since the documentation is authored as Markdown within the `planifest-docs` folder of the same repository, fetching the raw markdown via an API at runtime (e.g., using `fetch`) introduces an unnecessary network hop and client-side processing overhead (parsing markdown to HTML within the browser).

## Decision
We will parse and render the Markdown documents from `planifest-docs` into HTML during the Vite build process. A plugin or build script will automatically execute the necessary transformations—such as stripping internal IDs or author metadata from the Version Log tables—and inject the clean HTML into static templates for the site generator.

## Consequences
**Positive:**
- Zero performance penalty on the client device for parsing markdown content.
- Improves SEO indexing since content is immediately present in the delivered HTML payload.
- Removes runtime dependencies on markdown-to-HTML libraries like `marked` or MDI.

**Negative:**
- Increases compilation time in the CI environment as the documentation repository grows.
- Hard-couples the build process to custom logic for stripping internal Planifest metadata formatting.
- Any change to documentation files requires a complete redeployment of the website via actions, whereas runtime fetching could ostensibly retrieve unbuilt changes if hosted statically elsewhere.
