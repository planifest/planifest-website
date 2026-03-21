---
name: initiative-pipeline
description: Execute the full Planifest pipeline - from initiative brief to production-ready PR. Use this when starting a new initiative.
---

# Initiative Pipeline

Execute the full Planifest pipeline for a new initiative.

## Prerequisites

- An initiative brief at `plan/current/initiative-brief.md`
- Use the [initiative brief template](../templates/initiative-brief.template.md) if you don't have one yet

## Steps

1. **Load the orchestrator skill** - it drives the entire pipeline
2. **Phase 0 - Assess and Coach**
   - Read the initiative brief
   - Assess against the three layers: Product, Architecture, Engineering
   - Coach the human through gaps - one question at a time, in priority order
   - Produce the validated Planifest at `plan/current/planifest.md`
   - **Gate:** Human confirms the Planifest before proceeding
3. **Phase 1 - Specification** (invoke spec-agent)
   - Produce: design spec, OpenAPI spec, scope, risk register, domain glossary, operational model, SLO definitions, cost model
   - Write to `plan/`
   - **Gate:** All artifacts produced, OpenAPI spec covers every endpoint
4. **Phase 2 - Architecture Decisions** (invoke adr-agent)
   - Produce ADRs for every significant decision
   - Write to `plan/current/adr/`
   - **Gate:** ADR exists for every significant decision
5. **Phase 3 - Code Generation** (invoke codegen-agent)
   - Check for relevant capability skills for the declared stack
   - Produce full implementation at `src/{component-id}/`
   - **Gate:** Implementation exists and matches the spec
6. **Phase 4 - Validate** (invoke validate-agent)
   - Run CI checks: lint, typecheck, test, build
   - Self-correct up to 5 times
   - **Gate:** CI passes
7. **Phase 5 - Security** (invoke security-agent)
   - Produce security report
   - **Gate:** Report produced, critical/high findings flagged
8. **Phase 6 - Documentation and Ship** (invoke docs-agent)
   - Produce living per-component docs, registry, and dependency graph at `docs/`
   - Produce a change log entry (`plan/changelog/{initiative-id}-<YYYY-MM-DD>.md`)
   - **Gate:** All living artifacts produced, ready for human review
9. **Phase 7 - Human Review and Filing** (Post-Review Action)
   - The human reviews the changes and the active plan.
   - Upon acceptance, the active plan (brief, spec, ADRs) is moved from `plan/current/` to `plan/_archive/{initiative-id}/` for historical tracking.
