# Cost Model - Planifest Website

> Compute, storage, egress, third-party cost estimates.

## Current Hosting Strategy

- Provider: GitHub Pages.
- Target tier: Free tier.

## Breakdown

- **Compute**: No dynamically running servers. GitHub Actions minutes consumed during builds are expected to remain well within normal allowances for standard repository owners. Egress data generated from normal traffic patterns falls within fair-use limits for static sites.
- **Storage**: Minor static assets (images, js binaries) which securely scale safely below repo size limits.
- **Database**: Zero.
- **Network Fees**: Handled transparently through GitHub CDN. Zero explicit fees incurred.

**Total Cost of Operation:** £0 / month.
