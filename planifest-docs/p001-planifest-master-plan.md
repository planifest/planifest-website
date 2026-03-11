# Planifest - Master Plan

## Version Log

| Version | Change Description | Date | Changed By |
|---|---|---|---|
| 1 | Initial document | 02 MAR 2026 | Martin Mayer |
| 2 | Added MCP architecture, dual-runtime model, CI platform agnosticism | 02 MAR 2026 | Martin Mayer |
| 3 | Reframed as specification framework; added Domain Knowledge Store, adoption modes, human gates, data contracts, artifact types, default rules | 05 MAR 2026 | Martin Mayer |
| 4 | Added Roadmap (p014) to related links | 07 MAR 2026 | Martin Mayer |
| 5 | Deduplicated default rules table - now references canonical table in p003 FD-007 | 07 MAR 2026 | Martin Mayer (via agent) |
| 6 | Added Planifest name etymology; replaced monorepo structure with v1.0 skills-based layout; replaced docs sync with v1.0 git-native framing | 07 MAR 2026 | Martin Mayer (via agent) |
| 7 | Added Strategic Intent vs Stochastic Execution (p017) to related links | 11 MAR 2026 | Martin Mayer |

---

> Planifest is a **specification framework for agentic development**. It defines how requirements are captured, how decisions are recorded, and how agents are instructed and verified - across the full span of product, architecture, and engineering. This document is the canonical architecture reference. All sub-documents are linked via standard markdown links and diagrams are rendered as Mermaid.

> **Planifest gives agents the domain knowledge to build with purpose - and gives teams the visibility to trust what was built.**

---

## Table of Contents

- [1. What Planifest Is](#1-what-planifest-is)
- [2. System Overview](#2-system-overview)
- [3. The Domain Knowledge Store](#3-the-domain-knowledge-store)
- [4. Human and Agent Responsibilities](#4-human-and-agent-responsibilities)
- [5. Pipeline Architecture - New Initiatives](#5-pipeline-architecture-new-initiatives)
- [6. Pipeline Architecture - Change & Maintenance](#6-pipeline-architecture-change-maintenance)
- [7. Agent Orchestration Layer](#7-agent-orchestration-layer)
- [8. Artifact Types](#8-artifact-types)
- [9. Adoption Modes](#9-adoption-modes)
- [10. Monorepo Structure](#10-monorepo-structure)
- [11. Documentation Sync](#11-documentation-sync)
- [12. Build Sequence](#12-build-sequence)
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

**MCP is the nervous system. Planifest is the brain.** MCP provides agent capabilities and connections. Planifest provides the knowledge, requirements, standards, and procedure that give those capabilities purpose and direction. They are complementary, not overlapping.

---

## 2. System Overview

```mermaid
flowchart TD
    A([👤 Initiative Brief]) --> ORCH[Orchestrator]
    Z([👤 Adjustment / Bug Report]) --> ORCH

    ORCH --> SA[spec-agent]
    SA -->|spec complete?| GATE1{Hard gate}
    GATE1 -->|No - surface gaps| SA
    GATE1 -->|Yes| AA[adr-agent]
    AA --> CA[codegen-agent]
    CA --> VA[validate-loop]
    VA --> SEC[security-agent]
    SEC --> PRA[pr-agent]
    PRA --> HGATE([👤 PR Review])
    HGATE --> DA[docs-agent]
    DA --> DKS[(Domain Knowledge Store)]

    subgraph MCP["MCP Servers"]
        M1["domain-knowledge-server"]
        M2["filesystem-server"]
        M3["ci-server"]
        M4["vcs-server"]
        M5["docs-server"]
    end

    SA <-->|tool calls| MCP
    AA <-->|tool calls| MCP
    CA <-->|tool calls| MCP
    VA <-->|tool calls| MCP
    SEC <-->|tool calls| MCP
    PRA <-->|tool calls| MCP
    DA <-->|tool calls| MCP

    style A fill:#d4edda,stroke:#28a745,color:#000
    style Z fill:#d4edda,stroke:#28a745,color:#000
    style HGATE fill:#d4edda,stroke:#28a745,color:#000
    style GATE1 fill:#fff8e1,stroke:#f0a500
    style MCP fill:#fff3cd,stroke:#ffc107
    style DKS fill:#cce5ff,stroke:#0066cc
```

> Planifest runs in two modes: any **CI/CD platform** (GitHub Actions, GitLab CI, Bitbucket Pipelines, CircleCI, etc.) using an LLM API, and any **agentic coding tool** (Claude Code, Cursor, Codex, Antigravity, GitHub Copilot, etc.) locally on a dev machine. See [Agentic Tool Runbook](p010-planifest-agentic-tool-runbook.md).

---

## 3. The Domain Knowledge Store

The Domain Knowledge Store is the most critical component in Planifest. It is a structured, versioned document store that captures everything Planifest knows about a system - per initiative, per component, and system-wide. Agents query it before building anything. It is the mechanism by which the domain is made available to agents that cannot acquire it implicitly.

```mermaid
flowchart LR
    subgraph DKS["Domain Knowledge Store"]
        Q["domain_query"]
        GC["get_component"]
        GDG["get_dependency_graph"]
        GR["get_risk"]
        GG["get_glossary"]
        GDC["get_data_contract"]
    end

    AG["Agents"] -->|MCP tool calls| DKS
    DKS --> STORE[(git docs/ or MCP service)]

    style DKS fill:#fff3cd,stroke:#ffc107
    style STORE fill:#cce5ff,stroke:#0066cc
```

### Two access paths

**MCP-enabled service** - agents call tools and receive scoped, purposeful responses. Keeps agent context tight. Better suited to larger teams, multiple initiatives, or complex domains.

**Git `docs/` folder** - documents colocated with code. No additional infrastructure. Better suited to smaller teams, single initiatives, or local development.

Both paths produce and consume the same document structure and honour the same default rules. The choice is operational, not architectural.

### Agents query before generating

Before building any component, an agent must at minimum:
1. `get_component` - understand what already exists in the vicinity
2. `domain_query` - confirm no existing component has overlapping responsibility
3. `get_risk` - understand what risk has already been identified
4. `get_glossary` - confirm it is using the correct ubiquitous language

### Document versioning

Every document is versioned. Updates create new versions rather than overwriting. History is never destroyed - only superseded. Documents carry `author: "human" | "agent"` - agent-authored documents are always flagged distinctly.

See [MCP Design](roadmap/p005-planifest-mcp-architecture.md), [MCP Domain Service Spec](roadmap/p007-planifest-domain-knowledge-service-reference.md), and [MCP Interface Spec](roadmap/p006-planifest-domain-knowledge-service-interface.md) for the full tool interface and conformance requirements *(roadmap)*.

---

## 4. Human and Agent Responsibilities

Planifest is not zero human-in-the-loop. It is zero human-in-the-loop *for building*. Humans retain approval authority over anything that changes intent or carries irreversible consequences.

```mermaid
flowchart LR
    subgraph HUMAN["👤 Humans"]
        H1["Author Initiative Briefs"]
        H2["Review & approve PRs\n(code + docs together)"]
        H3["Approve schema changes\n& migrations"]
        H4["Review high/critical\nrisk items"]
        H5["Decide on agent-raised\nimprovements"]
    end

    subgraph AGENT["🤖 Agents"]
        A1["Build, test, document\n& raise PRs"]
        A2["Self-heal bugs that\ndon't break requirements"]
        A3["Raise issues, quirks\n& tech debt"]
        A4["Propose migrations -\nnever apply unilaterally"]
    end

    style HUMAN fill:#d4edda,stroke:#28a745
    style AGENT fill:#f0f4ff,stroke:#6c8ebf
```

### Default rules

Conservative by default. Autonomy is earned progressively. Hard limits cannot be overridden under any circumstance. Rules can be relaxed per initiative as confidence grows - except hard limits, which are non-negotiable.

See [FD-007 - Default rules](p003-planifest-functional-decisions.md#fd-007--default-rules-are-conservative-autonomy-is-earned-progressively) for the full default rules table.

---

## 5. Pipeline Architecture - New Initiatives

Triggered when a new Initiative Brief is committed to the document store or vault.

**Specification is a hard gate.** The spec-agent and adr-agent surface every gap, ambiguity, or unresolved decision before passing work to the codegen-agent. The pipeline does not proceed until the specification is complete.

```mermaid
flowchart TD
    BRIEF([👤 Initiative Brief])

    subgraph PHASE1["① Specification - hard gate"]
        S["spec-agent"]
        SG{"Spec complete?"}
        S --> SG
        SG -->|No - surface gaps| S
    end

    subgraph PHASE2["② Architecture Decisions"]
        A["adr-agent"]
    end

    subgraph PHASE3["③ Code Generation"]
        C["codegen-agent"]
    end

    subgraph PHASE4["④ Validate & Self-Correct"]
        V{"CI passes?"}
        FIX["Self-correct"]
        FAIL(["❌ Halt"])
        RETRY(["Retries left?"])
    end

    subgraph PHASE5["⑤ Security"]
        SEC["security-agent"]
    end

    subgraph PHASE6["⑥ Ship & Document"]
        PR["pr-agent"]
        DOCS["docs-agent"]
        DKS["Update Domain Knowledge Store"]
    end

    HGATE([👤 PR Review])
    DONE([✅ Merged · Domain updated])

    BRIEF --> PHASE1
    SG -->|Yes| PHASE2
    PHASE2 --> PHASE3
    PHASE3 --> PHASE4
    V -->|Yes| PHASE5
    V -->|No| RETRY
    RETRY -->|Yes| FIX --> V
    RETRY -->|No| FAIL
    PHASE5 --> PHASE6
    PR --> DOCS --> DKS --> HGATE --> DONE

    style BRIEF fill:#d4edda,stroke:#28a745,color:#000
    style HGATE fill:#d4edda,stroke:#28a745,color:#000
    style DONE fill:#d4edda,stroke:#28a745,color:#000
    style FAIL fill:#f8d7da,stroke:#dc3545,color:#000
    style PHASE1 fill:#fff8e1,stroke:#f0a500
    style PHASE2 fill:#f0f4ff,stroke:#6c8ebf
    style PHASE3 fill:#f0f4ff,stroke:#6c8ebf
    style PHASE4 fill:#fff8e1,stroke:#f0a500
    style PHASE5 fill:#f0f4ff,stroke:#6c8ebf
    style PHASE6 fill:#f0f4ff,stroke:#6c8ebf
```

### Agent responsibilities

| Agent | Domain Knowledge Tools | Output |
|---|---|---|
| spec-agent | `domain_query`, `get_component`, `get_glossary`, `get_risk` | design-spec.md, openapi.yaml, scope.md, risk-register.md |
| adr-agent | `list_adrs`, `domain_query` | docs/adr/*.md |
| codegen-agent | `get_component`, `get_data_contract`, `filesystem.read_file`, `filesystem.write_file` | Full implementation + tests + IaC |
| security-agent | `get_risk`, `filesystem.read_file`, `ci.run_sast` | security-report.md |
| pr-agent | `vcs.create_pr` | PR with full description |
| docs-agent | `create_document`, `update_document`, `docs.sync` | Domain Knowledge Store updated + docs synced |

---

## 6. Pipeline Architecture - Change & Maintenance

```mermaid
flowchart TD
    TRIGGER([👤 Adjustment / Bug Report])

    subgraph PHASE1["① Domain Context"]
        DKS["domain_query + get_component<br/>get_dependency_graph + get_risk"]
    end

    subgraph PHASE2["② Targeted Change"]
        C["change-codegen-agent"]
    end

    subgraph PHASE3["③ Validate & Self-Correct"]
        V{"CI passes?"}
        FIX["Self-correct"]
        FAIL(["❌ Halt"])
        RETRY(["Retries left?"])
    end

    subgraph PHASE4["④ ADR & Migration Check"]
        ADR{"Contract changed?"}
        NEWADR["adr-agent"]
        SCHEMA{"Schema changed?"}
        MIG["propose_migration\nFlag for human review"]
    end

    subgraph PHASE5["⑤ Security"]
        SEC["security-agent"]
    end

    subgraph PHASE6["⑥ Ship & Update"]
        PR["pr-agent"]
        DOCS["docs-agent"]
        UPDK["Update Domain Knowledge Store"]
    end

    HGATE([👤 PR Review])
    DONE([✅ Merged · Domain updated])

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
    style HGATE fill:#d4edda,stroke:#28a745,color:#000
    style DONE fill:#d4edda,stroke:#28a745,color:#000
    style FAIL fill:#f8d7da,stroke:#dc3545,color:#000
    style PHASE1 fill:#fff8e1,stroke:#f0a500
    style PHASE4 fill:#f9f0ff,stroke:#9b59b6
```

---

## 7. Agent Orchestration Layer

A single containerised orchestrator service (TypeScript, Fastify) that:
- Watches for new Initiative Briefs via webhook, file watcher, or queue trigger
- Runs the pipeline as a **state machine**: Discovery -> Spec -> ADR -> Codegen -> Validate -> Security -> PR -> Docs
- Persists state between steps so retries have full error context
- Is **idempotent** - re-running with the same Initiative Brief produces the same output

### MCP write model

The domain-knowledge-server is the **sole writer** to the document store and git repository. Agents never write directly. All writes are posted to the MCP service and queued for serial processing - one write at a time, in order. This eliminates merge conflicts by design.

```mermaid
flowchart LR
    AG["Agent"] -->|propose write| Q["Write queue\n(serial)"]
    Q --> L["Listener"]
    L -->|atomic commit\ncode + docs together| GIT["Git repo"]

    style Q fill:#fff8e1,stroke:#f0a500
    style GIT fill:#f0f4ff,stroke:#6c8ebf
```

Code and docs are always committed together in a single atomic operation. Neither is ever committed without the other.

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
  outputPaths: string[]     // files written via MCP
}
```

---

## 8. Artifact Types

Planifest defines distinct artifact types. No artifact bleeds into another. Each is maintained and versioned independently.

**Per Initiative:**

| Artifact | Purpose |
|---|---|
| Initiative Brief | What needs to be built and why |
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
| **Greenfield** | `greenfield` | Initiative Brief | New system, no prior codebase. Pipeline runs spec to PR. |
| **Retrofit** | `retrofit` | Existing codebase | spec-agent performs codebase ingestion first - scans, infers architecture, generates ADRs from what exists. Surfaces drift and tech debt before any new code. |
| **Agent Interface Layer** | `agent-interface` | Interface spec | Large or complex component library. Interface layer specified first; agents develop against it, not the internals. |

---

## 10. Monorepo Structure

```
monorepo/
├── planifest/
│   ├── skills/
│   │   ├── orchestrator/SKILL.md   # Entry point - coaching + sequencing
│   │   ├── spec-agent/SKILL.md     # Produce specification artifacts
│   │   ├── adr-agent/SKILL.md      # Produce ADRs
│   │   ├── codegen-agent/SKILL.md  # Implement against spec
│   │   ├── validate-agent/SKILL.md # Run checks, self-correct
│   │   ├── security-agent/SKILL.md # Security assessment
│   │   ├── docs-agent/SKILL.md     # Complete documentation
│   │   ├── change-agent/SKILL.md   # Change pipeline
│   │   └── shared/
│   │       └── default-rules.md    # Referenced by orchestrator
│   ├── adapters/
│   │   ├── claude-code/CLAUDE.md
│   │   ├── cursor/.cursorrules
│   │   ├── copilot/copilot-instructions.md
│   │   └── antigravity/planifest.yaml
│   └── templates/                  # Artifact templates
│       ├── initiative-brief.md
│       ├── design-spec.md
│       ├── adr.md
│       ├── component-purpose.md
│       ├── interface-contract.md
│       ├── data-contract.md
│       ├── security-report.md
│       ├── risk-register.md
│       └── scope.md
├── initiatives/
│   └── {initiative-id}/
│       ├── planifest.md            # The Planifest - plan for what will be built, manifest of what it builds against
│       ├── initiative-brief.md
│       ├── apps/
│       │   ├── web/
│       │   └── api/
│       ├── packages/shared/
│       ├── infra/
│       ├── docs/                   # Initiative and component artifacts
│       │   ├── design-spec.md
│       │   ├── openapi-spec.yaml
│       │   ├── domain-glossary.md
│       │   ├── risk-register.md
│       │   ├── scope.md
│       │   ├── operational-model.md
│       │   ├── slo-definitions.md
│       │   ├── cost-model.md
│       │   ├── adr/
│       │   ├── components/
│       │   │   └── {component-id}/
│       │   │       ├── purpose.md
│       │   │       ├── interface-contract.md
│       │   │       ├── data-contract.md
│       │   │       ├── migrations/
│       │   │       ├── risk.md
│       │   │       ├── scope.md
│       │   │       └── quirks.md
│       │   └── system/
│       │       ├── component-registry.md
│       │       └── dependency-graph.md
│       └── pipeline-run.md         # Audit trail for the latest run
└── README.md
```

---

## 11. Documentation Sync

Every agent output is a markdown document, written to `initiatives/{initiative-id}/docs/`. The git repository is the documentation system - markdown and Mermaid render natively on GitHub, GitLab, and Bitbucket. No additional sync infrastructure is required for v1.0.

Teams that want a richer documentation experience (Obsidian, Notion, Confluence) can integrate at the documentation provider level - see [RC-005 - Pluggable Documentation Provider](p014-planifest-roadmap.md) in the roadmap.

---

## 12. Build Sequence

```mermaid
flowchart LR
    subgraph M1["Milestone 1"]
        A1["Domain Knowledge\nMCP server"]
    end
    subgraph M2["Milestone 2"]
        A2["Orchestrator\nskeleton"]
    end
    subgraph M3["Milestone 3"]
        A3["CI templates\nVCS-MCP\nPulumi modules"]
    end
    subgraph M4["Milestone 4"]
        B1["spec-agent\nadr-agent"]
    end
    subgraph M5["Milestone 5"]
        B2["codegen-agent\nvalidate loop"]
    end
    subgraph M6["Milestone 6"]
        B3["security-agent\npr-agent\ndocs-agent"]
    end
    subgraph M7["Milestone 7+"]
        C1["First initiative\nend-to-end"]
        C2["Prompt tuning"]
    end

    M1 --> M2 --> M3 --> M4 --> M5 --> M6 --> M7
    C1 --> C2

    style M1 fill:#f0f4ff,stroke:#6c8ebf
    style M2 fill:#f0f4ff,stroke:#6c8ebf
    style M3 fill:#f0f4ff,stroke:#6c8ebf
    style M4 fill:#fff8e1,stroke:#f0a500
    style M5 fill:#fff8e1,stroke:#f0a500
    style M6 fill:#fff8e1,stroke:#f0a500
    style M7 fill:#d4edda,stroke:#28a745
```

**Milestone 1 - Domain Knowledge MCP server.** The new foundation. Build `apps/domain-knowledge-mcp` first: document schema, all query and write tools, the serial write queue. Everything downstream reads from and writes to this service.

**Milestone 2 - Orchestrator skeleton.** State machine with stubbed agents. Prove pipeline wiring, state persistence, retry logic, and idempotency.

**Milestone 3 - Templates.** CI pipeline templates, VCS-MCP, Pulumi modules. Prove a manual scaffold works end-to-end.

**Milestone 4 - spec-agent and adr-agent.** Highest leverage. Implement the hard gate: spec must be complete before proceeding.

**Milestone 5 - codegen-agent and validate loop.** Hardest to tune. Incremental write-to-disk. Self-correct retry loop.

**Milestone 6 - security-agent, pr-agent, docs-agent.** Close the loop.

**Milestone 7 - First real initiative.** The first run surfaces gaps that no upfront planning reveals.

---

*This document is the living Planifest architecture reference. As the system evolves, agents update it.*

*Related: [Functional Decisions](p003-planifest-functional-decisions.md) | [The Pathway to Agentic Development](p004-the-pathway-to-agentic-development.md) | [Agentic Tool Runbook](p010-planifest-agentic-tool-runbook.md) | [Pilot App](p011-planifest-pilot-app.md) | [Backend Stack Evaluation](p013-planifest-backend-stack-evaluation.md) | [Roadmap](p014-planifest-roadmap.md) | [Frontend Stack Evaluation](p016-planifest-frontend-stack-evaluation.md) | [Strategic Intent vs Stochastic Execution](p017-research-report-strategic-intent-vs-stochastic-execution.md) | [Code Quality Standards](../planifest-framework/standards/code-quality-standards.md)*
