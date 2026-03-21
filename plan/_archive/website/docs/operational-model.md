# Operational Model - Planifest Website

> Explains the runbook triggers, on-call expectations, and alerting thresholds.

## Overview

The website operates on simple static serving principles provided natively by GitHub Pages.

## Deployments
- Pushes to the `main` or related protected branches automatically trigger the continuous deployment (GitHub Actions), generating static assets and replacing the existing site on the `gh-pages` branch.
- No specific rollback actions exist other than generic Git branch reversions.

## Incident Triggers and Alerting
- There is no custom threshold set for metrics like 500-level errors or high latency natively via GitHub.
- Health status for GitHub Pages functions as the upstream dependency.

## On-Call Expectations
- Because the service represents a non-mission-critical public website managed securely within the GitHub source-of-truth, there are zero on-call rotations required. Maintenance occurs only when explicit content changes or styling updates are necessary.
