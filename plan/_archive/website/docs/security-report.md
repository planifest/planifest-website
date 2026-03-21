# Security Report - Planifest Website

> Documents the threat model, dependency audit, authentication, authorisation, and network policy for the Planifest Website.

## 1. Threat Model

- **Attack Surface**: Minimal. The application is a static site containing public informational content. No user inputs are processed by backend systems.
- **Data Sensitivity**: Public domain knowledge. No PII, credentials, or proprietary intellectual property requiring restriction.
- **Primary Threats**:
  - *Supply Chain Attack*: Malicious code introduced via `npm` dependencies during the build process resulting in cross-site scripting (XSS) via modified final JavaScript bundles.
  - *Defacement*: Unauthorised commits to the `main` branch or `gh-pages` branch leading to altered public messaging.

## 2. Dependency Audit

- The solution relies heavily on the Vite build chain (`vite`, `typescript`) and the `marked` library for static Markdown conversion.
- Execution of `npm install` yielded 0 known vulnerabilities.
- Mitigation: GitHub Dependabot is (or should be) configured to automatically manage automated pull requests for critical JS ecosystem updates.

## 3. Authentication & Authorisation

- **Authentication**: None. Publicly accessible application.
- **Authorisation**: Static HTTP serving via GitHub Pages uses inherent platform access controls. Only collaborators with commit access to the upstream repo can alter content.

## 4. Network Policy

- Hosted securely behind GitHub CDN with default TLS encryption (HTTPS).
- Automatically inherits DDoS mitigation strategies and edge caching capabilities from GitHub's infrastructure.

## 5. Security Findings

| Finding | Severity | Description | Remediation |
|---|---|---|---|
| None identified | Low | Static build configuration inherently mitigates standard interactive web vulnerabilities. Ensure branch protections remain active. | Ensure GitHub branch protection on `main` requires peer review to prevent malicious code changes. |
