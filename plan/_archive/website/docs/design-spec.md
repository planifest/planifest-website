# Design Specification - Planifest Website

> This document defines the functional and non-functional requirements for the Planifest Website.

---

## 1. Functional Requirements

| ID | Origin | Requirement | Acceptance Criteria |
|---|---|---|---|
| FR-01 | User Story 1 (landing-page) | Display a hero section with the main value proposition | Renders correctly; visible immediately on load; communicates "Agentic Framework" |
| FR-02 | User Story 1 (landing-page) | Display an explanation of the canonical 3-folder structure | Shows `planifest-framework/`, `plan/`, `src/` descriptions clearly |
| FR-03 | User Story 2 (doc-renderer) | Render markdown files from `planifest-docs` | Loads correctly formatted HTML generated from MD files during build |
| FR-04 | User Story 2 (doc-renderer) | Strip metadata (IDs, version logs) from rendered docs | Output HTML contains no Markdown frontmatter or literal version log tables |
| FR-05 | User Story 3 (page-linking) | Automatically convert inter-document markdown references | Links to other `.md` files should navigate correctly to generated pages in the site |
| FR-06 | User Story 4 (theme-toggle) | Switch seamlessly between light and dark themes | Theme toggle button changes colors/styles instantly and persists |

## 2. Non-Functional Requirements

### 2.1 Performance
- **Latency**: Largest Contentful Paint (LCP) must be under 1.0s.

### 2.2 Scalability
- **Mechanism**: The website is fully static, deployed to GitHub Pages and served via CDN, enabling near-infinite read scalability without infrastructure management.

### 2.3 Availability
- **Target**: 99.9% availability, inheriting the uptime of GitHub Pages.

### 2.4 Security
- **Authentication**: None required.
- **Authorisation**: Open access, public read-only content.
- **Data Classification**: Public. No PII, financials, or restricted data.

### 2.5 Operational & Cost
- **Cost**: The hosting infrastructure utilizes GitHub Pages free tier. Egress and compute costs are null.
- **Deployment**: Handled automatically via GitHub Actions CI/CD to the `gh-pages` branch.

---

## 3. Component Details & Context

- **web-app**: A static Single-Page Application (or multi-page generated site) built using Vite and vanilla web technologies. Connects to `planifest-docs/` during the build step. No backend required.
