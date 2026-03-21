# Initiative Brief - Planifest Website

> Written by a human. This is the input document that kicks off the Planifest pipeline. The orchestrator reads this and coaches you through any gaps before passing it to the spec-agent.

---

## Business Goal

Create a landing page and informational website for the Planifest project. The website needs to showcase the framework with a beautiful, slick design including dynamic animations, and must support both light and dark themes. It serves as the public face of the project, hosted freely on GitHub Pages.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| landing-page | View the hero section, see value proposition, understand the 3-folder structure | must-have | 1 |
| doc-renderer | Render markdown files from `planifest-docs`, stripping metadata (IDs, version logs) | must-have | 1 |
| page-linking | Parse doc references and link pages sensibly together | should-have | 1 |
| theme-toggle | Switch between light and dark themes seamlessly | must-have | 1 |
| github-pages | Build and export static files for GH Pages hosting | must-have | 1 |

---

## Phases

| Phase | Features Included | Ships When |
|-------|-------------------|------------|
| 1 | landing-page, doc-renderer, page-linking, theme-toggle, animations, github-pages | The site is live on GitHub pages with a beautiful light/dark UI and navigable docs |

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| web-app | static-site | new | Displaying the Planifest landing page |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| none | none | none |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| planifest-docs | none | Read-only during build |

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | HTML/JS/CSS (Vanilla or Static Generator) |
| Runtime | Node (for build) |
| Framework | Vite (Static Site) |
| Frontend | Vanilla Web / Built for fast loading |
| Database | none |
| ORM | none |
| Testing | none |
| IaC | none |
| Cloud | GitHub Pages |
| Compute | static |
| CI | GitHub Actions |

---

## Scope Boundaries

### In Scope
- Beautiful hero section.
- Technical overview of the framework.
- Render pages from `planifest-docs/` automatically during build.
- Strip document IDs, version logs, and metadata for a cleaner reading experience.
- Link documentation pages together based on references.
- Light and dark theme toggle.
- Static site generation via Vite.
- GitHub Actions workflow for deployment to GitHub Pages.

### Out of Scope
- Backend APIs or databases.
- User authentication.
- Showing metadata/doc IDs from the markdown documents.

### Deferred
- Interactive playground.

---

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Latency | LCP < 1.0s | Lighthouse Audit |
| Availability | 99.9% | GitHub Pages Uptime |
| Accessibility | 100% | Lighthouse Audit |

---

## Constraints and Assumptions

### Constraints
- Must be hosted on GitHub Pages (static files only).

### Assumptions
- The design should feel premium, adopting modern UI trends (glassmorphism, tailored color palettes).

---

## Acceptance Criteria

- [ ] A static site is generated that clearly explains Planifest.
- [ ] Users can toggle between light and dark mode.
- [ ] The site feels modern, animated, and slick.
- [ ] A GitHub Actions workflow exists to deploy to `gh-pages` branch.
