# Planifest Pilot App

---

> The first feature built and maintained by Planifest, using Planifest. Purpose TBC - this document covers the confirmed technical decisions and will be updated when the product scope is defined.

*Related: [Master Plan](p001-planifest-master-plan.md) | [Product Concept](p002-planifest-product-concept.md) | [Roadmap](p014-planifest-roadmap.md)*

---

## Table of Contents

- [1. Status](#1-status)
- [2. Confirmed Technical Decisions](#2-confirmed-technical-decisions)
- [3. GCP Architecture](#3-gcp-architecture)
- [4. Monorepo Structure](#4-monorepo-structure)
- [5. CI/CD Pipeline](#5-cicd-pipeline)
- [6. What Happens When Purpose is Confirmed](#6-what-happens-when-purpose-is-confirmed)

---

## 1. Status

| Decision | Status |
|---|---|
| Application purpose | ⏳ TBC |
| Frontend stack | ✅ React 19 + TypeScript + shadcn/ui |
| Backend stack | ✅ Node.js + TypeScript |
| CI/CD platform | ✅ GitHub Actions |
| Source control | ✅ GitHub |
| Cloud provider | ✅ GCP |
| Compute | ✅ Cloud Run |
| Database | ✅ Cloud SQL (PostgreSQL) |
| Queue | ✅ Cloud Tasks |
| Container registry | ✅ Artifact Registry |
| Secrets | ✅ Secret Manager |
| IaC | ✅ Pulumi (TypeScript) |

---

## 2. Confirmed Technical Decisions

### Frontend
React 19 with TypeScript, Vite, Tailwind CSS, and shadcn/ui. Served as a containerised static build via Cloud Run - no CDN required at pilot scale, but the container approach makes it straightforward to add one later.

This is a pilot decision, not a Planifest default. The [Frontend Stack Evaluation](p016-planifest-frontend-stack-evaluation.md) assessed 10 frontend frameworks for agent-generated code and found React 19 + Vite + TypeScript the clear leader - 70-80% first-pass functional success rate, the deepest agent skills ecosystem, and the broadest component library coverage. The evaluation recommends specifying shadcn/ui as the component library, TanStack Query + Zustand for state management, and React Hook Form + Zod for form handling - these constrain the codegen-agent's output and reduce visual inconsistency.

### Backend
Node.js with Fastify and TypeScript. Fastify's native JSON Schema validation pairs cleanly with the OpenAPI-first approach Planifest uses - the spec defines the contract, Fastify validates against it at runtime. Shared types via Zod schemas in a `packages/shared` workspace.

This is a pilot decision, not a Planifest default. The [Backend Stack Evaluation](p013-planifest-backend-stack-evaluation.md) assessed 13 frameworks for agent-generated code and found Node.js/TypeScript + Fastify defensible for single-language simplicity, SDK coverage (~95%), and LLM fluency - but noted trade-offs in error handling discipline and type system soundness. For future features, especially those with security-critical or high-performance components, the evaluation recommends considering Go (highest first-pass success rate) or Rust (strongest compile-time guarantees).

### Database
PostgreSQL via Cloud SQL. Drizzle ORM for type-safe queries - no raw SQL, schema migrations tracked in the repo.

### Source Control & CI
GitHub monorepo. GitHub Actions for CI/CD - the reference implementation Planifest is built and validated against first.

### Cloud
GCP throughout. See [3. GCP Architecture](#3-gcp-architecture) for the service map.

### IaC
Pulumi with TypeScript. Consistent with the rest of the stack - one language for application code and infrastructure. The Pulumi stack will be parameterised for environment (dev / staging / prod) from day one.

---

## 3. GCP Architecture

```mermaid
flowchart TD
    subgraph INTERNET["Public"]
        USER["👤 User"]
    end

    subgraph GCP["GCP Project"]
        subgraph CR["Cloud Run Services"]
            WEB["web\nReact frontend\n(containerised)"]
            API["api\nFastify backend"]
            REG["registry\nPlanifest registry"]
            ORCH["orchestrator\nPlanifest pipeline"]
        end

        subgraph DATA["Data"]
            DB["Cloud SQL\nPostgreSQL"]
            Q["Cloud Tasks\nAsync job queue"]
            SEC["Secret Manager\nApp secrets"]
        end

        subgraph REGISTRY["Artifact Registry"]
            IMGS["Container images\nweb / api / registry /\norchestrator"]
        end

        LB["Cloud Load Balancer\n+ Cloud Armor"]
    end

    USER --> LB
    LB --> WEB
    LB --> API
    API --> DB
    API --> Q
    API --> SEC
    REG --> DB
    ORCH --> Q
    ORCH --> API
    CR --> IMGS

    style GCP fill:#f0f4ff,stroke:#6c8ebf
    style CR fill:#fff8e1,stroke:#f0a500
    style DATA fill:#f9f0ff,stroke:#9b59b6
    style INTERNET fill:#d4edda,stroke:#28a745
```

### Service decisions

**Cloud Run** is the right choice for this pilot for three reasons: no cluster management (no GKE overhead at this stage), scales to zero when idle (cost-efficient while usage is low), and the containerised deployment model is portable - if the pilot outgrows Cloud Run, migrating to GKE is a container re-target, not a rewrite.

**Cloud SQL** over a managed serverless option (Firestore, Spanner) because the stack is PostgreSQL + Drizzle throughout Planifest's architecture. Consistency matters more than marginal operational savings at pilot scale.

**Cloud Tasks** for async work - background jobs, long-running pipeline steps, webhook processing. Keeps the API response times predictable.

**Cloud Armor** on the load balancer from day one - lightweight WAF rules, not complex security theatre. Easier to have it in place than to retrofit.

### Environments

| Environment | Cloud Run config | Cloud SQL | Notes |
|---|---|---|---|
| dev | Min instances: 0, scale to 1 | Shared dev instance | Deployed on every push to `main` |
| staging | Min instances: 1 | Dedicated instance | Deployed on release tag |
| prod | Min instances: 1, scale to N | Dedicated instance, HA | Manual promotion from staging |

---

## 4. Monorepo Structure

The pilot app lives inside the Planifest monorepo as its first feature - eating our own cooking from day one.

```
monorepo/
├── planifest-framework/
│   ├── skills/                # Agent Skills - the confirmed design pipeline
│   │   ├── planifest-orchestrator/SKILL.md
│   │   ├── planifest-spec-agent/SKILL.md
│   │   ├── planifest-adr-agent/SKILL.md
│   │   ├── planifest-codegen-agent/SKILL.md
│   │   ├── planifest-validate-agent/SKILL.md
│   │   ├── planifest-security-agent/SKILL.md
│   │   ├── planifest-docs-agent/SKILL.md
│   │   ├── planifest-change-agent/SKILL.md
│   │   └── shared/
│   │       └── default-rules.md
│   ├── setup/                        # Tool setup scripts
│   ├── templates/                      # Artifact templates
│
├── plan/
│   └── pilot/                 # ← The pilot feature lives here
│       ├── design.md          # Confirmed design and build plan
│       ├── feature-brief.md
│       ├── iteration-log.md   # Latest pipeline run log
│       └── docs/              # Full artifact set per FD-019
│           ├── design-requirements.md
│           ├── openapi-spec.yaml
│           ├── domain-glossary.md
│           ├── risk-register.md
│           ├── scope.md
│           ├── operational-model.md
│           ├── slo-definitions.md
│           ├── cost-model.md
│           ├── security-report.md
│           ├── recommendations.md
│           └── adr/
│
├── src/
│   └── pilot/                 # ← The pilot implementation lives here
│       ├── component.yml      # Component manifest
│       ├── apps/
│       │   ├── web/           # React + TypeScript + Vite + TailwindCSS
│       │   └── api/           # Fastify + TypeScript
│       ├── packages/
│       │   └── shared/        # Zod schemas, types, API contracts
│       ├── infra/             # Pulumi - Cloud Run, Cloud SQL, Cloud Tasks
│       └── docs/              # Component-level artifacts
│           ├── purpose.md
│           ├── interface-contract.md
│           ├── data-contract.md
│           ├── quirks.md
│           └── migrations/
│
├── docs/                      # Repo-wide state
│   ├── component-registry.md
│   └── dependency-graph.md
│
├── infra/
│   └── platform/
│       └── gcp/               # Shared Pulumi modules - Cloud Run, Cloud SQL, Artifact Registry
└── README.md
```

---

## 5. CI/CD Pipeline

The pilot uses GitHub Actions as the CI/CD platform - Planifest's reference implementation. Both the feature pipeline (used once to bootstrap the pilot) and the change pipeline (used for every subsequent change) are stamped from Planifest's core templates.

```mermaid
flowchart LR
    subgraph TRIGGER["Triggers"]
        T1["feature-brief.md\ncommitted"]
        T2["Issue / change\nbrief raised"]
        T3["Local Claude Code\nsession"]
    end

    subgraph PIPELINE["Planifest Pipeline"]
        P1["Feature pipeline\n(GitHub Actions)\nBootstraps pilot app"]
        P2["Change pipeline\n(GitHub Actions)\nMaintains pilot app"]
        P3["Local pipeline\n(Claude Code)\nDev iteration"]
    end

    subgraph GCP2["GCP Deployment"]
        D1["Artifact Registry\nContainer images"]
        D2["Cloud Run\nDeploy on merge"]
    end

    T1 --> P1
    T2 --> P2
    T3 --> P3
    P1 --> D1
    P2 --> D1
    D1 --> D2

    style TRIGGER fill:#d4edda,stroke:#28a745
    style PIPELINE fill:#f0f4ff,stroke:#6c8ebf
    style GCP2 fill:#fff8e1,stroke:#f0a500
```

---

## 6. What Happens When Purpose is Confirmed

When the pilot's product scope is defined, a **Feature Brief** will be written and committed to the repo. Planifest will process it through the full feature pipeline. The orchestrator begins **Phase 0 - Assess and Coach**. Development does not begin until the **confirmed design** (`plan/current/design.md`) is complete and **Design confirmed**. Humans retain approval at the PR, for any schema changes, and for any high/critical risk items.

1. **Phase 0** coaches for every answer needed - surfaces gaps before proceeding. Derives the **confirmed design** (`design.md`).
2. **spec-agent (Phase 1)** derives the detailed requirements set, OpenAPI definition, scope, risk register, and domain glossary.
3. **adr-agent (Phase 2)** generates ADRs for every significant decision.
4. **codegen-agent (Phase 3)** scaffolds the full implementation inside `src/pilot/`.
5. **validate loop (Phase 4)** runs CI and self-corrects.
6. **security-agent (Phase 5)** produces the security report.
7. **docs-agent (Phase 6)** opens the PR and syncs all artifacts.

### Targeted Modifications

Once the pilot components exist, future modifications (bugs, adjustments) that don't change intent will follow the **Change Pipeline**, bypassing the full Agentic Iteration Loop while still maintaining artifact consistency. Trivial UI or logic fixes follow the **Fast Path**.

---

*This document will be updated when the pilot purpose is confirmed.*

*[← All Components](vault-index.md) | [← Architecture](p001-planifest-master-plan.md) | [← Concept](p002-planifest-product-concept.md)*
