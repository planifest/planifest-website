# ADR-001: Static Site Generation with Vite

## Status
Accepted

## Context
The Planifest framework requires a landing page to showcase its features and agentic development approach. The site needs to be fast (LCP < 1.0s), secure, and easy to maintain. Since the content is primarily informational and user-specific data is not stored, a dynamic server-side rendered (SSR) application or a traditional CMS would introduce unnecessary complexity, security surface area, and hosting costs. Vite offers a fast, modern build toolchain for static assets.

## Decision
We will build the website as a completely static site generated using Vite with vanilla HTML/JS/CSS, avoiding heavy reactive frameworks like React or Vue since the interactive requirements (animations, theme toggling) are minimal.

## Consequences
**Positive:**
- Lightning-fast page loads due to pre-compiled static assets.
- Zero server-side security vulnerabilities.
- Extremely low barrier to entry for contributors who know basic HTML/CSS.
- Very fast build times during CI/CD.

**Negative:**
- Any shared layout components (like a header or footer) must be handled either by a static site generator plugin within Vite or duplicated across HTML files, making multi-page scaling slightly more cumbersome without a framework.
- Adding complex interactive state in the future (like the deferred interactive playground) will require vanilla JS DOM manipulation rather than declarative framework state.
