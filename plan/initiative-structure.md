# Planifest - Repository Structure

> The canonical layout for a Planifest-managed repository. Four top-level folders, four concerns.

---

## The Four Folders

```
repo/
├── planifest-framework/        ← The framework (skills, templates, schemas, standards)
│                                 Drop this in. Don't modify it per-project.
│
├── plan/                       ← Initiatives and their specifications
│                                 One subfolder per initiative. Plans, briefs, ADRs,
│                                 design specs, user stories, scope, risk.
│                                 Everything that describes WHAT to build and WHY.
│
├── src/                        ← Component implementations
│                                 One subfolder per component. Code, tests, config,
│                                 manifests, and component-level docs.
│
└── docs/                       ← Repo-wide state and cross-initiative documentation
                                  Component registry, dependency graph, system
                                  context documents. The overall picture.
```

---

## `planifest-framework/` - The Framework

This folder is the Planifest framework itself. It is the same across every project. You do not modify it per-initiative - you update it when the framework evolves.

```
planifest-framework/
├── skills/           ← Agent instructions (orchestrator + phase skills)
├── templates/        ← File format templates for every artifact
├── schemas/          ← JSON Schema validation definitions
├── standards/        ← Code quality standards
└── workflows/        ← Pipeline and workflow definitions
```

---

## `plan/` - Initiatives and Specifications

Organized by initiative. Each initiative gets a subfolder. This is where humans write briefs and agents write specs. No code lives here.

```
plan/
├── current/                         ← The active initiative
│   ├── initiative-brief.md          ← Human input (start here)
│   ├── planifest.md                 ← Validated plan (orchestrator output)
│   ├── pipeline-run.md              ← Audit trail (per run)
│   │
│   └── docs/
│       ├── design-spec.md           ← Functional & non-functional requirements
│       ├── openapi-spec.yaml        ← API contract
│       ├── scope.md                 ← In / Out / Deferred
│       ├── risk-register.md         ← Risk items with likelihood & impact
│       ├── domain-glossary.md       ← Ubiquitous language
│       ├── security-report.md       ← Security review findings
│       ├── operational-model.md     ← Runbook triggers, alerting thresholds
│       ├── slo-definitions.md       ← Error budgets, SLIs/SLOs
│       ├── cost-model.md            ← Compute, storage, egress cost estimates
│       ├── recommendations.md       ← Improvement suggestions
│       ├── quirks.md                ← Initiative-level quirks and workarounds
│       ├── change-summary.md        ← Written by the change-agent per run
│       │
│       └── adr/
│           ├── ADR-001-{title}.md   ← Architecture decision records
│           ├── ADR-002-{title}.md
│           └── ...
│
├── _archive/
│   ├── {initiative-id}/             ← Historical initiatives (moved here upon completion)
│   │   └── ...                      ← Same structure as current/
│
└── changelog/                       ← Log of all changes
    └── [initiative-id]-[date].md    ← A single change record

```

### Path Rules - plan/

1. **Initiative ID** is kebab-case, human-chosen, and stable.
2. **One level of subfolders** - all spec docs and supporting files live flat in `docs/`. ADRs get their own `docs/adr/` subfolder.
3. **No code** - nothing executable lives in `plan/`. If it runs, it belongs in `src/`.
4. **Phased initiatives** append the phase number: `docs/design-spec-phase-2.md`, `pipeline-run-phase-2.md`. The `planifest.md` is updated per phase, not duplicated.
5. **ADRs** are numbered sequentially. Never renumber. Superseded ADRs stay with `status: superseded`.

---

## `src/` - Component Implementations

Organized by component. Each component is a subfolder at the top level of `src/`. The component manifest lives with the code.

```
src/
└── {component-id}/
    ├── component.json               ← Component manifest (mandatory)
    ├── package.json                 ← (or equivalent for the stack)
    │
    ├── src/                         ← Implementation (structure varies by stack)
    │   └── ...
    │
    ├── tests/                       ← Tests
    │   └── ...
    │
    └── docs/                        ← Component-level documentation
        ├── data-contract.md         ← Schema ownership & invariants
        ├── interface-contract.md    ← Inputs, outputs, breaking change policy
        ├── dependencies.md          ← What it consumes / what depends on it
        ├── risk.md                  ← Component-scoped risk items
        ├── scope.md                 ← Component-scoped in / out / deferred
        ├── quirks.md                ← Component-scoped oddities and workarounds
        ├── tech-debt.md             ← Explicitly acknowledged debt
        ├── test-coverage.md         ← Coverage state at point of generation
        └── migrations/
            └── proposed-{desc}.md   ← Migration proposals (written before any schema change)
```

### Path Rules - src/

1. **Component ID** is kebab-case, matches the `id` in `component.json`.
2. **`component.json` is mandatory** - every component has one. Read it before any work; update it after every build.
3. **Component-specific docs** live with the component at `src/{component-id}/docs/`. These describe the component's data contract, interface, dependencies, risk, and technical specifics.
4. **Initiative-level docs** live in `plan/_archive/{initiative-id}/docs/`. The component's `component.json` references the initiative via the `initiative` field and points to its domain knowledge via `pipeline.domainKnowledgePath`.
5. **Existing components** that predate Planifest are retrofitted by adding a `component.json` at their root.

---

## `docs/` - Repo-Wide State

Cross-initiative documentation and the overall system picture. This is the living state of the whole repository - not tied to any single initiative.

```
docs/
├── component-registry.md        ← Index of every component - ID, type, one-liner, status
└── dependency-graph.md          ← Mermaid diagram showing how components relate
```

The docs-agent writes to this folder at the end of each pipeline run. It accumulates over time as initiatives ship components.

### Path Rules - docs/

1. **Cross-initiative only** - nothing in `docs/` belongs to a specific initiative. Initiative-scoped docs go in `plan/_archive/{initiative-id}/docs/`.
2. **Written by the docs-agent** - humans may annotate, but agents own the component registry and dependency graph.
3. **Always current** - the docs-agent updates these files at the end of every pipeline run, not just on initial creation.

---

## How the Folders Connect

```
plan/_archive/{initiative-id}/planifest.md
    └── lists component IDs -> src/{component-id}/component.json
                                    └── references initiative -> plan/_archive/{initiative-id}/
                                    └── domainKnowledgePath  -> plan/_archive/{initiative-id}/docs/

plan/_archive/{initiative-id}/docs/design-spec.md
    └── functional requirements -> implemented in -> src/{component-id}/src/

plan/_archive/{initiative-id}/docs/adr/ADR-001-*.md
    └── decisions -> followed by -> src/{component-id}/src/

plan/_archive/{initiative-id}/docs/openapi-spec.yaml
    └── API contract -> implemented in -> src/{component-id}/src/

src/{component-id}/docs/data-contract.md
    └── schema ownership -> enforced across -> all components

docs/component-registry.md
    └── indexes -> all src/{component-id}/ manifests

docs/dependency-graph.md
    └── maps relationships between -> all src/{component-id}/
```

The relationship is bidirectional:
- `planifest.md` lists all component IDs
- Each `component.json` references its initiative ID
- The plan describes WHAT; the code IS the WHAT; the docs folder holds the cross-cutting view

---

## Retrofit - Adding Planifest to an Existing Repo

If the repo already has code:

1. Drop `planifest-framework/` into the repo root
2. Create `plan/`, `docs/` directories
3. Move existing components under `src/` (or leave them if they're already there)
4. Add a `component.json` to each existing component
5. Tell the orchestrator to use **retrofit** adoption mode - it will read the codebase and infer the existing architecture

---

*Templates for each file are in [planifest-framework/templates/](../planifest-framework/templates/). Skills reference these paths.*
