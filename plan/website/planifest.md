# Planifest - website

## Initiative
- Problem: Create a landing page and informational website for the Planifest project. It needs to showcase the framework with a beautiful, slick design with dynamic animations and support light/dark themes.
- Adoption mode: greenfield

## Product Layer
- User stories confirmed: 6
- Acceptance criteria confirmed: 6
- Constraints: Must be hosted on GitHub Pages (static files only)
- Integrations: planifest-docs (read-only during build)

## Architecture Layer
- Latency target: LCP < 1.0s
- Availability target: 99.9%
- Scalability target: Static site, infinitely scalable via GitHub Pages CDN
- Security: Public data classification, no auth, no user data
- Cost boundary: Free tier (GitHub Pages)

## Engineering Layer
- Stack: HTML/JS/CSS / Vite / GitHub Actions / GitHub Pages
- Components: 
  - `web-app`: static site displaying the Planifest landing page
- Data ownership: none
- Deployment: GitHub Actions workflow deploying to `gh-pages` branch

## Scope
- In: Beautiful hero section, technical overview, light/dark mode, static site generation, GitHub Actions workflow, dynamic rendering of `planifest-docs` files directly during build, removal of metadata/IDs for cleaner reading, linking documentation pages automatically.
- Out: Backend APIs, databases, user authentication, multi-page routing, showing meta data/IDs from MD docs.
- Deferred: Interactive playground.

## Risks
- GitHub Pages build size limitations (low likelihood / low impact)
- Animation jank on lower-end devices (medium likelihood / medium impact)

## Dependencies
- Upstream: Planifest framework documentation (content)
- Downstream: none

## Confirmation
Human confirmed this Planifest before proceeding: yes / no
