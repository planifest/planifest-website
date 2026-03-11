# Scope Document - Planifest Website

> Defines what is in scope, out of scope, and deferred for the Planifest Website initiative.

## 1. In Scope

- **Beautiful hero section** that captivates visitors with modern aesthetics.
- **Dynamic animations** that feel premium without degrading performance.
- **Technical overview** of the Planifest framework and the canonical 3-folder structure.
- **Rendering of Markdown pages** natively from the `planifest-docs/` subdirectory during build time.
- **Stripping of metadata** (document IDs, versions log tables) to ensure a cleaner visual layout for readers.
- **Linking documentation pages** so that relative references in the markdown resolve smoothly on the deployed site.
- **Light and dark theme toggling** that feels fast and reliable.
- **Static Site Generation** built directly into static assets via Vite.
- **GitHub Actions workflow** configured for seamless deployment to `gh-pages` branch.

## 2. Out of Scope

- **Backend APIs** (no dynamic server functionality).
- **Databases** of any kind.
- **User authentication** or login forms.
- **Multi-page routing mechanisms** that depend dynamically on server-side resolution.
- **Direct representation of raw metadata** from parsed `.md` documents visually.

## 3. Deferred

- **Interactive Playground**: Initially planned, but explicitly deferred.
    - *Note:* The playground module cannot be built until further requirement scoping establishes what specific capabilities the playground needs (e.g. backend container environment versus client-side mocking).
