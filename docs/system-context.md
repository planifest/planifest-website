# System Context

This repository (`planifest-docs`) serves as the official landing page and documentation site for the **Planifest framework**. 

It uses the very framework it documents to structure its own development.

## Core System

The core of this repository is a static site workflow. There are no backend services, databases, or runtime dependencies beyond the browser.

### The Build Process
The `web-app` component (found in `src/web-app/`) is a static site built with Vite. During the `predev` and `prebuild` phases, markdown files (both local descriptions and framework templates) are parsed via Node.js scripts, stripped of agent-specific metadata/frontmatter, and converted into HTML that the frontend consumes. 

Inter-document markdown links are automatically rewritten to ensure smooth web navigation between pages.

### Deployment Architecture
The result of the Vite build is a static asset directory (`dist/`). A GitHub Actions workflow triggers on merges to the `main` branch, executes the build scripts, and publishes the static site directly to **GitHub Pages**. This ensures near-infinite uptime and zero server maintenance costs.
