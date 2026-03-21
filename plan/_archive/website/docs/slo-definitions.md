# SLO Definitions - Planifest Website

> Details error budgets, SLIs/SLOs.

## Overview

The service objectives center completely around maintaining the default availability standards provided by GitHub infrastructure.

## Service Level Objectives (SLOs)

- **Platform Availability Objective:** Targeted at 99.9% availability, aligning with the expected uptime SLA capabilities implicitly provided for GitHub Pages hosting.
- **Service Level Indicator (SLI):** GitHub status page indicating green operation for its Pages feature.

## Error Budget

- Downtime incurred by external system failures (GitHub CDN caching, GitHub Actions runners) reduces the budget but isn't something the Planifest initiative takes remediating actions on, other than waiting for vendor resolution.
