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

## License

[Apache License Version 2.0](LICENSE.txt)

### Why we chose the Apache 2.0 License

We want the Planifest community to build with total confidence. While we considered the MIT license for its simplicity, we chose Apache 2.0 because it offers superior long-term protection for our users and contributors:

- **Explicit Patent Rights:** Unlike other permissive licenses, Apache 2.0 grants you an explicit license to any patents covered by the software. This means you can use, modify, and distribute Planifest without worrying about "hidden" patent claims.

- **Contributor Protection:** It ensures that every contribution made to the framework comes with the same patent grants. This prevents "patent trolling" within the ecosystem and keeps the code free for everyone, forever.

- **Community Safety (The "Retaliation" Clause):** The license includes a defense mechanism: if anyone sues a Planifest user over patent infringement related to this software, they automatically lose their own license to use it. This keeps the community collaborative and legally "polite."

- **Commercial Friendly:** It remains a permissive, open-source license. You are free to use Planifest for commercial projects, ship it in proprietary products, and build your business on it with zero royalties.

**TL;DR:** We chose Apache 2.0 so you can focus on building great things, knowing the legal foundation of your framework is rock-solid and community-first.
