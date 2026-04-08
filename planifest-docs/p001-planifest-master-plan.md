# Planifest - Master Plan


---

> Planifest is a **specification framework for agentic development**. It defines how requirements are captured, how decisions are recorded, and how agents are instructed and verified - across the full span of product, architecture, and engineering. This document is the canonical architecture reference. All sub-documents are linked via standard markdown links and diagrams are rendered as Mermaid.

> **Planifest gives agents the domain knowledge to build with purpose - and gives teams the visibility to trust what was built.**

---

## Table of Contents

- [1. What Planifest Is](#1-what-planifest-is)
- [2. System Overview](#2-system-overview)
- [3. SDLC Documentation Architecture](#3-sdlc-documentation-architecture)
- [4. Human and Agent Responsibilities](#4-human-and-agent-responsibilities)
- [5. Pipeline Architecture - New Initiatives](#5-pipeline-architecture-new-initiatives)
- [6. Pipeline Architecture - Change & Maintenance](#6-pipeline-architecture-change-maintenance)
- [7. Agent Orchestration Layer](#7-agent-orchestration-layer)
- [8. Artifact Types](#8-artifact-types)
- [9. Adoption Modes](#9-adoption-modes)
- [10. Monorepo Structure](#10-monorepo-structure)
- [11. Documentation Sync](#11-documentation-sync)
- [Local Dev - Agentic Tool Execution Mode](p010-planifest-agentic-tool-runbook.md)
- [MCP Design - Tool Server Architecture](roadmap/p005-planifest-mcp-architecture.md) *(roadmap)*
- [Functional Decisions](p003-planifest-functional-decisions.md)
- [The Pathway to Agentic Development](p004-the-pathway-to-agentic-development.md)

---

## 1. What Planifest Is

Planifest is a specification framework for agentic development. It is not a code generator. It is not a CI/CD tool. It is the layer that gives agents the domain knowledge to build correctly - and gives teams the evidence to verify they did.

A **Planifest** is the plan and the manifest: the plan is what will be built, the manifest is what it builds against. For every initiative, the orchestrator agent produces a Planifest - a single document that records both. You cannot plan what to build without recording what you're building against.

**The root problem** Planifest solves is not the absence of good tooling - it is the absence of domain knowledge. Agents cannot acquire domain knowledge implicitly the way an experienced developer does. Without it, they generate code that is technically correct but architecturally wrong. They make decisions that have already been made. They create components that overlap with ones that already exist. They build quickly, and incorrectly, at scale.

Planifest builds a structured domain for agents to reason within: what the system does, what it is made of, what decisions have been made and why, how each component relates to the whole. When an agent is asked to build something, it works within that domain - not in isolation.

Planifest specifies three layers of every initiative:

- **Product** - Functional requirements. What the system must do. Derived from user stories, acceptance criteria, problem statements. The *Why* and the *What*.
- **Architecture** - Non-functional requirements. How the system must perform, scale, and operate. SLOs, latency budgets, availability targets, security constraints, cost boundaries. The *How it must behave*.
- **Engineering** - Technical delivery plan. Component design, data contracts, interface contracts, infrastructure, deployment topology. The *How it will be built*.

Across all three layers, Scope, Risks, and Dependencies are first-class concerns. Nothing significant is left implicit. See [Functional Decisions](p003-planifest-functional-decisions.md) for the full set of functional decisions.

---

## 2. System Overview

```mermaid
flowchart TD
    A([ðŸ‘¤ Initiative Brief]) --> ORCH[Orchestrator]
    Z([ðŸ‘¤ Adjustment / Bug Report]) --> ORCH

    ORCH --> PHASE0[Phase 0: Assess & Coach]
    PHASE0 -->|Planifest confirmed| LOOP
    
    subgraph LOOP["Agentic Iteration Loop (Phases 1-6)"]
        direction TB
        PHASE1[Phase 1: planifest-spec-agent]
        PHASE1 --> PHASE2[Phase 2: planifest-adr-agent]
        PHASE2 --> PHASE3[Phase 3: planifest-codegen-agent]
        PHASE3 --> PHASE4[Phase 4: planifest-validate-agent]
        PHASE4 --> PHASE5[Phase 5: planifest-security-agent]
        PHASE5 --> PHASE6[Phase 6: planifest-docs-agent]
    end
    
    PHASE6 --> HGATE([ðŸ‘¤ PR Review])

    style A fill:transparent,stroke:#28a745,stroke-width:2px
    style Z fill:transparent,stroke:#28a745,stroke-width:2px
    style HGATE fill:transparent,stroke:#28a745,stroke-width:2px
    style PHASE0 fill:transparent,stroke:#f0a500,stroke-width:2px
```

> Planifest runs in two modes: any **CI/CD platform** (GitHub Actions, GitLab CI, Bitbucket Pipelines, CircleCI, etc.) using an LLM API, and any **agentic coding tool** (Claude Code, Cursor, Codex, Antigravity, GitHub Copilot, etc.) locally on a dev machine. See [Agentic Tool Runbook](p010-planifest-agentic-tool-runbook.md).

---

## 3. SDLC Documentation Architecture

The overarching SDLC folder structure (consisting of the `plan/`, `manifest/`, and `docs/` folders) is the most critical concept in Planifest. It acts as a structured, versioned file tree that captures everything Planifest knows about a system - per initiative, per component, and system-wide. Agents query these files before building anything. It is the mechanism by which the domain is made available to agents that cannot acquire it implicitly.

```mermaid
flowchart LR
    subgraph DKS["SDLC Collaboration Folders"]
        Q["domain_query"]
        GC["get_component"]
        GDG["get_dependency_graph"]
        GR["get_risk"]
        GG["get_glossary"]
        GDC["get_data_contract"]
    end

    AG["Agents"] -->|read / write| DKS
    DKS --> STORE[(git docs/ folder)]

    style DKS fill:transparent,stroke:#ffc107,stroke-width:2px,stroke-dasharray: 5 5
    style STORE fill:transparent,stroke:#0066cc,stroke-width:2px
```

### Access path - v1.0

**Git `docs/` folder** - agents read and write documents directly via Agent Skills. Documents are colocated with code. No additional infrastructure required. Works locally and in CI.

A dedicated queryable Domain Knowledge Store MCP service is a roadmap item - see [RC-001](p014-planifest-roadmap.md).

### Agents query before generating

Before building any component, an agent must at minimum:
1. `get_component` - understand what already exists in the vicinity
2. `domain_query` - confirm no existing component has overlapping responsibility
3. `get_risk` - understand what risk has already been identified
4. `get_glossary` - confirm it is using the correct ubiquitous language

### Document versioning

Every document is versioned. Updates create new versions rather than overwriting. History is never destroyed - only superseded. Documents carry `author: "human" | "agent"` - agent-authored documents are always flagged distinctly.

See [MCP Design](roadmap/p005-planifest-mcp-architecture.md), [MCP Domain Service Spec](roadmap/p007-planifest-domain-knowledge-service-reference.md), and [MCP Interface Spec](roadmap/p006-planifest-domain-knowledge-service-interface.md) for the full MCP tool interface and conformance requirements *(roadmap - RC-001)*.

---

## 4. Human and Agent Responsibilities

Planifest is not zero human-in-the-loop. It is zero human-in-the-loop *for building*. Humans retain approval authority over anything that changes intent or carries irreversible consequences.

```mermaid
flowchart LR
    subgraph HUMAN["ðŸ‘¤ Humans"]
        H1["Author Initiative Briefs"]
        H2["Review & approve PRs\n(code + docs together)"]
        H3["Approve schema changes\n& migrations"]
        H4["Review high/critical\nrisk items"]
        H5["Decide on agent-raised\nimprovements"]
    end

    subgraph AGENT["ðŸ¤– Agents"]
        A1["Build, test, document\n& raise PRs"]
        A2["Self-heal bugs that\ndon't break requirements"]
        A3["Raise issues, quirks\n& tech debt"]
        A4["Propose migrations -\nnever apply unilaterally"]
    end

    style HUMAN fill:transparent,stroke:#28a745,stroke-width:2px
    style AGENT fill:#f0f4ff,stroke:#6c8ebf
```

### Default rules

Conservative by default. Autonomy is earned progressively. Hard limits cannot be overridden under any circumstance. Rules can be relaxed per initiative as confidence grows - except hard limits, which are non-negotiable.

See [FD-007 - Default rules](p003-planifest-functional-decisions.md#fd-007--default-rules-are-conservative-autonomy-is-earned-progressively) for the full default rules table.

### Three-Track Decision Tree (Scope-based Routing)

Every incoming request is triaged into one of three execution tracks based on the scope of the change:

| Track | Signal | Rigour |
|---|---|---|
| **Fast Path** | UI styling, copy/text changes, or isolated pure-function logic bugs. No schema changes. | **Low**: Bypass spec/ADR. Direct implementation + validation. |
| **Change Pipeline** | Targeted bug fix or modification to 1-2 existing components. | **Medium**: Phase 1 Context -> Phase 2 Change -> Phase 3 Validate. |
| **Initiative Pipeline** | New features, ≥ 3 user stories, or touches > 3 components. | **High**: Full Phase 0-6 Agentic Iteration Loop. |

See [Planifest Pipeline](p015-planifest-pipeline.md) for detailed criteria per track.

---

## 5. Pipeline Architecture - Initiative Pipeline

Triggered when a new Feature Brief is provided.

**The design is a hard gate.** The orchestrator coaches the human until a complete design (`plan/current/design.md`) is produced and **Planifest confirmed**. The pipeline then proceeds through specification, architecture, and generation.

```mermaid
flowchart TD
    BRIEF([ðŸ‘¤ Feature Brief]) --> P0[â‘ Phase 0: Assess & Coach]
    P0 -->|Planifest confirmed| LOOP
    
    subgraph LOOP["Agentic Iteration Loop"]
        direction TB
        P1[â‘  Phase 1: planifest-spec-agent]
        P1 --> P2[â‘¡ Phase 2: planifest-adr-agent]
        P2 --> P3[â‘¢ Phase 3: planifest-codegen-agent]
        P3 --> P4[â‘£ Phase 4: planifest-validate-agent]
        P4 --> P5[â‘¤ Phase 5: planifest-security-agent]
        P5 --> P6[â‘¥ Phase 6: planifest-docs-agent]
    end
    
    P6 --> HGATE([ðŸ‘¤ PR Review])

    style BRIEF fill:transparent,stroke:#28a745,stroke-width:2px
    style HGATE fill:transparent,stroke:#28a745,stroke-width:2px
    style P0 fill:transparent,stroke:#f0a500,stroke-width:2px
```

### Agent responsibilities

| Agent | Domain Knowledge Access (v1.0) | Output |
|---|---|---|
| planifest-spec-agent | Reads `docs/` and `plan/current/` directly | design-spec.md, openapi.yaml, scope.md, risk-register.md |
| planifest-adr-agent | Reads `docs/adr/` directly | docs/adr/*.md |
| planifest-codegen-agent | Reads component files; writes via filesystem | Full implementation + tests + IaC |
| planifest-validate-agent | Reads failure logs; writes via filesystem | Test results, self-correct logs |
| planifest-security-agent | Reads source files directly | security-report.md |
| planifest-docs-agent | Writes to `docs/` and `plan/current/` folders directly | SDLC folders updated |

---

## 6. Pipeline Architecture - Change & Maintenance

```mermaid
flowchart TD
    TRIGGER([ðŸ‘¤ Adjustment / Bug Report])

    subgraph PHASE1["â‘  Domain Context"]
        DKS["domain_query + get_component<br/>get_dependency_graph + get_risk"]
    end

    subgraph PHASE2["â‘¡ Targeted Change"]
        C["planifest-change-agent"]
    end

    subgraph PHASE3["â‘¢ Validate & Self-Correct"]
        V{"CI passes?"}
        FIX["Self-correct"]
        FAIL(["âŒ Halt"])
        RETRY(["Retries left?"])
    end

    subgraph PHASE4["â‘£ ADR & Migration Check"]
        ADR{"Contract changed?"}
        NEWADR["adr-agent"]
        SCHEMA{"Schema changed?"}
        MIG["propose_migration\nFlag for human review"]
    end

    subgraph PHASE5["â‘¤ Security"]
        SEC["security-agent"]
    end

    subgraph PHASE6["â‘¥ Ship & Update"]
        PR["pr-agent"]
        DOCS["docs-agent"]
        UPDK["Update plan/ and docs/"]
    end

    HGATE([ðŸ‘¤ PR Review])
    DONE([âœ… Merged Â· Domain updated])

    TRIGGER --> PHASE1
    PHASE1 --> PHASE2
    PHASE2 --> PHASE3
    V -->|Yes| PHASE4
    V -->|No| RETRY
    RETRY -->|Yes| FIX --> V
    RETRY -->|No| FAIL
    ADR -->|Yes| NEWADR --> PHASE5
    ADR -->|No| SCHEMA
    SCHEMA -->|Yes| MIG --> PHASE5
    SCHEMA -->|No| PHASE5
    PHASE5 --> PHASE6
    PR --> DOCS --> UPDK --> HGATE --> DONE

    style TRIGGER fill:#d4edda,stroke:#28a745,color:#000
    style HGATE fill:transparent,stroke:#28a745,stroke-width:2px
    style DONE fill:#d4edda,stroke:#28a745,color:#000
    style FAIL fill:#f8d7da,stroke:#dc3545,color:#000
    style PHASE1 fill:#fff8e1,stroke:#f0a500
    style PHASE4 fill:#f9f0ff,stroke:#9b59b6
```

---

## 7. Agent Orchestration Layer

In v1.0, the pipeline is executed by a human-triggered agent session following the orchestrator skill. The orchestrator skill sequences the phase skills, and each agent reads and writes files directly.

A fully automated orchestrator service (watching for Initiative Briefs, running the pipeline as a CI state machine) is a roadmap item - see [RC-002](p014-planifest-roadmap.md). A serial write queue to structurally eliminate concurrent merge conflicts is [RC-003](p014-planifest-roadmap.md).

Code and docs are always committed together in a single atomic operation. Neither is ever committed without the other - enforced by the pipeline skill instructions and reviewed at the PR gate.

### Agent interface

```typescript
type AgentContext = {
  runId: string
  goal: string
  initiativeId: string
  componentId?: string
}

type AgentResult = {
  status: "complete" | "blocked" | "failed"
  blockedReason?: string    // surfaces a spec gap if blocked
  outputPaths: string[]     // files written to disk
}
```

---

## 8. Artifact Types

Planifest defines distinct artifact types. No artifact bleeds into another. Each is maintained and versioned independently.

**Per Initiative:**

| Artifact | Purpose |
|---|---|
| Feature Brief | What needs to be built and why |
| Design Specification | Functional and non-functional requirements |
| OpenAPI Specification | Language-agnostic API contract - generated first |
| ADRs | Every significant decision with context and consequences |
| Risk Register | Technical, operational, security, compliance risks |
| Scope | In / out / deferred |
| Security Report | Threat model, dependency audit, auth/authz, network policy |
| Quirks | Known oddities, workarounds, acknowledged tech debt |
| Recommendations | Suggested improvements for future iterations |
| Operational Model | Runbook triggers, on-call expectations, alerting thresholds |
| SLO Definitions | Error budgets, SLIs/SLOs |
| Cost Model | Compute, storage, egress, third-party cost estimates |
| Domain Glossary | Ubiquitous language - agents must respect it |

**Per Component:**

| Artifact | Purpose |
|---|---|
| Component Purpose | What this component exists to do in the wider system |
| Interface Contract | Inputs, outputs, schema, consumers, breaking change policy |
| Dependencies | What it consumes / what depends on it |
| Data Contract | Schema, invariants, ownership - one owner per dataset |
| Migration History | Full history of schema changes - never destroyed |
| ADRs | Component-level decisions |
| Risk | Component-scoped risk items |
| Scope | Component-scoped in / out / deferred |
| Quirks | Component-scoped oddities |
| Test Coverage Summary | Coverage state at point of generation |
| Known Tech Debt | Explicitly acknowledged debt |

**System-wide:**

| Artifact | Purpose |
|---|---|
| Component Registry | Index of every component - what it is, what it does |
| Dependency Graph | How components relate to each other |

---

## 9. Adoption Modes

| Mode | `initiative_mode` | Entry point | Description |
|---|---|---|---|
| **Greenfield** | `greenfield` | Feature Brief | New system, no prior codebase. Pipeline runs spec to PR. |
| **Retrofit** | `retrofit` | Existing codebase | spec-agent performs codebase ingestion first - scans, infers architecture, generates ADRs from what exists. Surfaces drift and tech debt before any new code. |
| **Agent Interface Layer** | `agent-interface` | Interface spec | Large or complex component library. Interface layer specified first; agents develop against it, not the internals. |

---

## 10. Monorepo Structure

```
monorepo/
â”œâ”€â”€ planifest-framework/
â”‚   â”œâ”€â”€ skills/
â”‚   â”‚   â”œâ”€â”€ planifest-orchestrator/SKILL.md   # Entry point
â”‚   â”‚   â”œâ”€â”€ planifest-spec-agent/SKILL.md
â”‚   â”‚   â”œâ”€â”€ planifest-adr-agent/SKILL.md
â”‚   â”‚   â”œâ”€â”€ planifest-codegen-agent/SKILL.md
â”‚   â”‚   â”œâ”€â”€ planifest-validate-agent/SKILL.md
â”‚   â”‚   â”œâ”€â”€ planifest-security-agent/SKILL.md
â”‚   â”‚   â”œâ”€â”€ planifest-docs-agent/SKILL.md
â”‚   â”‚   â””â”€â”€ planifest-change-agent/SKILL.md
â”‚   â”œâ”€â”€ setup/                        # Tool setup scripts
â”‚   â”œâ”€â”€ templates/                      # Artifact templates
â”‚   â”‚   â”œâ”€â”€ feature-brief.template.md
â”‚   â”‚   â”œâ”€â”€ iteration-log.template.md
â”‚   â”‚   â””â”€â”€ ...
â”œâ”€â”€ plan/                           # Execution plans
â”‚   â”œâ”€â”€ current/
â”‚   â”‚   â”œâ”€â”€ design.md               # Confirmed build plan
â”‚   â”‚   â”œâ”€â”€ feature-brief.md
â”‚   â”‚   â”œâ”€â”€ iteration-log.md
â”‚   â”‚   â””â”€â”€ ...
â”‚   â”œâ”€â”€ archive/                     # Historical plans
â”‚   â””â”€â”€ changelog/                   # Audit log
â”œâ”€â”€ src/
â”‚   â””â”€â”€ {component-id}/
â”‚       â”œâ”€â”€ component.yml           # Component manifest (Single Source of Truth)
â”‚       â””â”€â”€ apps/ | packages/ | infra/   # Implementation
â”œâ”€â”€ docs/                           # Repo-wide state & artifact history
â”‚   â”œâ”€â”€ adr/                        # Component-specific ADRs (persisted)
â”‚   â”œâ”€â”€ migrations/                  # Component migration records
â”‚   â”œâ”€â”€ component-registry.md
â”‚   â””â”€â”€ dependency-graph.md
â””â”€â”€ README.md
```

---

## 11. Documentation Sync

Every agent output is a markdown document, written to `plan/current/` (initiative-level artifacts) or `src/{component-id}/docs/` (component-level artifacts), with repo-wide state in `docs/`. The git repository is the documentation system - markdown and Mermaid render natively on GitHub, GitLab, and Bitbucket. No additional sync infrastructure is required for v1.0.

Teams that want a richer documentation experience (Obsidian, Notion, Confluence) can integrate at the documentation provider level - see [RC-005 - Pluggable Documentation Provider](p014-planifest-roadmap.md) in the roadmap.

---

---

*This document is the living Planifest architecture reference. As the system evolves, agents update it.*

*Related: [Functional Decisions](p003-planifest-functional-decisions.md) | [The Pathway to Agentic Development](p004-the-pathway-to-agentic-development.md) | [Agentic Tool Runbook](p010-planifest-agentic-tool-runbook.md) | [Pilot App](p011-planifest-pilot-app.md) | [Backend Stack Evaluation](p013-planifest-backend-stack-evaluation.md) | [Roadmap](p014-planifest-roadmap.md) | [Frontend Stack Evaluation](p016-planifest-frontend-stack-evaluation.md) | [Strategic Intent vs Stochastic Execution](p017-research-report-strategic-intent-vs-stochastic-execution.md) | [Code Quality Standards](../planifest-framework/standards/code-quality-standards.md)*
