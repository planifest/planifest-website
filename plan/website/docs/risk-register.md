# Risk Register - Planifest Website

> Documents identified risks, their likelihood, impact, and mitigation strategies.

| Risk ID | Category | Description | Likelihood | Impact | Mitigation Strategy |
|---|---|---|---|---|---|
| R-01 | Technical | **GitHub Pages size limits**: Building multiple raw static artifacts may hit size limitations long term. | Low | Low | Only rendering specified markdown and stripping unnecessary data limits size. |
| R-02 | Operational | **Animation Jank**: Premium CSS animations and micro-animations may cause layout thrashing on lower-end devices. | Medium | Medium | Prefer CSS transform/opacity animations. Test early on throttling settings in DevTools. Provide prefers-reduced-motion fallbacks. |
| R-03 | Technical | **Markdown parsing edge cases**: `planifest-docs/` markdown might contain unusual structures (like the literal HTML or unclosed tags) that break the Vite parser. | Medium | Medium | Implement robust fallback parsing or specific regex validations during the build step. |
| R-04 | Technical | **Asset path resolution**: Inter-document linking might generate 404s if the Vite bundler does not automatically map the markdown links correctly to site paths. | Medium | High | Construct an explicit mapping and testing step in the Vite plugin or build script to verify link targets exist. |
