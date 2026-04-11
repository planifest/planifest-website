# Feature Brief - framework-link

## Business Goal

Provide direct access to the confirmed design Framework source code from the main documentation website, enabling users to easily find, review, and contribute to the framework repository.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| GitHub Link Integration | As a user, I want to see a link to the GitHub repository in the navigation bar and footer so that I can easily find the source code. | must-have | 1 |

---

## Phases

| Phase | Features Included | Ships When |
|-------|-------------------|------------|
| 1 | GitHub Link Integration | Links are present in the nav and footer, pointing to the correct URL and opening in a new tab. |

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| web-app | web website | existing | Display the landing page with links to docs and the framework repo |

---

## Stack

| Concern | Decision |
|---------|----------|
| Frontend | Vanilla HTML/CSS/JS |

---

## Scope Boundaries

### In Scope
- Adding GitHub repository link to header navigation
- Adding GitHub repository link to the footer

### Out of Scope
- Adding OAuth or GitHub login
- Pulling dynamic data from GitHub (e.g., stars, forks)

---

## Acceptance Criteria

- [ ] The top navigation bar includes a "GitHub" link pointing to `https://github.com/planifest/planifest-framework`.
- [ ] The footer includes a "GitHub" link pointing to `https://github.com/planifest/planifest-framework`.
- [ ] Links open in a new tab (`target="_blank"`) and use `rel="noopener noreferrer"` for security.

