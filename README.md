# Planifest Website

This repository contains the landing page, documentation viewer, and informational website for the **Planifest** framework. It uses the Planifest organizational framework internally to manage its own development.

## Repository Structure

Following the Planifest standard, this repository is organized into four main directories:

- `plan/` - Contains the active initiative specs (in `current/`), historical change logs, and decision trees detailing *what* we're building and *why*.
- `src/` - The actual system implementation. Contains the `web-app` UI component.
- `docs/` - Cross-cutting repository state including component registries and dependencies.
- `planifest-framework/` - The core Planifest templates, tools, and agent skills defining the governance model.

## Development

The website is a static site built with Vite and vanilla CSS. It dynamically renders Markdown files during the build process to produce HTML content.

To run the web app locally:

```bash
cd src/web-app
npm install
npm run dev
```

This will run `predev` scripts that build documentation into static outputs, and then start the local Vite development server.

## Deployment

Continuous deployment is handled automatically via GitHub Actions. Merging to the `main` branch will trigger a build and publish the static contents directly to GitHub Pages.