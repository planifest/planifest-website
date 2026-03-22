# Planifest - Functional Decisions


---

Functional Decisions define what Planifest is and does. They are not ADRs - ADRs will capture architectural and implementation decisions separately when the build begins.

---

## FD-001 - Planifest is a specification framework for agentic development

**Decision:** Planifest is a specification framework for agentic development. It defines how requirements are captured, how decisions are recorded, and how agents are instructed and verified - across the full span of product, architecture, and engineering.

**Rationale:** The root cause of failed agentic development is not inadequate tooling - it is missing domain knowledge. Agents cannot acquire domain knowledge implicitly the way an experienced developer can. Planifest builds a structured domain for agents to reason within, and produces reporting outputs that let teams verify what was built without reading every line of generated code.

> Planifest gives agents the domain knowledge to build with purpose - and gives teams the visibility to trust what was built.

---

## FD-002 - Planifest covers three layers of every initiative

**Decision:** Every initiative is described across three distinct layers:

- **Product** - Functional Requirements. What the system must do. Derived from user stories, acceptance criteria, and problem statements. The *Why* and the *What*.
- **Architecture** - Non-functional Requirements. How the system must perform, scale, and operate. SLOs, latency budgets, availability targets, security constraints, cost boundaries. The *How it must behave*.
- **Engineering** - Technical Delivery Plan. How the system will be built. Component design, data contracts, interface contracts, infrastructure, deployment topology. The *How it will be built*.

Across all three layers, Scope, Risks, and Dependencies are first-class concerns. Nothing significant is left implicit.

**Rationale:** Collapsing product, architecture, and engineering into a single layer produces ambiguous specs and agents that conflate intent with implementation. Keeping them separate allows each to be reasoned about, verified, and updated independently.

---

## FD-003 - The Initiative Brief is the initiating input

**Decision:** A human authors one structured markdown document - the Initiative Brief - covering the problem statement, user stories, acceptance criteria, constraints, and known integrations. This is the seed that initiates the pipeline.

The orchestrator agent assesses the brief against what a complete Planifest specification requires, coaches the human through any gaps - one question at a time, in priority order - and produces the validated **Planifest**: the plan for what will be built and the manifest of what it builds against. The human confirms the Planifest before the pipeline proceeds. This is the hard gate.

Human intervention points are:
- **Initiative Brief** - initiating the pipeline
- **Planifest confirmation** - the human confirms the validated Planifest before development begins
- **PR review** - reviewing code and docs before merging
- **Schema changes and migrations** - approving any data contract changes
- **High/critical risk items** - human review required by default
- **Agent-raised improvements** - human decides whether they become a new Initiative Brief

**Rationale:** A single, well-defined initiating input makes the pipeline deterministic and every downstream artifact traceable to a human decision. The coaching conversation ensures the brief reaches the level of detail the framework requires without placing the burden of knowing the framework on the human. Autonomous execution between gates does not mean zero human involvement - it means human involvement is deliberate, bounded, and at the right moments.

---

## FD-004 - Specification must be complete before development begins

**Decision:** Agents do not begin development until the specification is complete. The orchestrator agent coaches the human through every gap in the Initiative Brief before the spec-agent produces artifacts. The spec-agent and adr-agent then surface any remaining ambiguity or unresolved decision before passing work to the codegen-agent. An incomplete specification is a hard gate - the pipeline does not proceed.

**Rationale:** The specification is not just the input to the pipeline - it is the standard against which all outputs are assessed. Code generated against an incomplete spec is incomplete, inconsistent, or incorrect by definition. Planifest insists on completeness first.

---

## FD-005 - The human gate is the PR

**Decision:** The pipeline is fully autonomous between the Initiative Brief and the pull request. The PR is the single human gate, reviewed before the feature enters the release process (UAT or Production, depending on SDLC). Humans review code and docs together - always. Neither is merged without the other.

**Rationale:** The PR is the natural, existing engineering checkpoint teams already understand and trust. Planifest delivers a complete, tested, documented, security-assessed artifact to that checkpoint. It does not replace governance - it delivers to it.

---

## FD-006 - Humans and agents have distinct, defined responsibilities

**Decision:** The division of responsibility is explicit and non-negotiable by default.

**Humans:**
- Author Initiative Briefs
- Submit adjustments (small changes) and bug reports
- Review and approve PRs - code and docs together, always
- Approve schema changes and migrations
- Decide whether an agent-raised improvement becomes an Initiative Brief

**Agents:**
- Build, test, document, and raise PRs
- Self-heal bugs that do not break requirements - no PR required by default
- Raise issues, quirks, tech debt, and improvement ideas
- Propose migrations - never apply them unilaterally

**Rationale:** Ambiguity about who does what leads to either uncontrolled autonomy or supervised micro-management. Neither is viable at scale. Clear boundaries make the pipeline trustworthy and auditable.

---

## FD-007 - Default rules are conservative; autonomy is earned progressively

**Decision:** The pipeline ships with conservative defaults. Rules can be relaxed per initiative as confidence in the pipeline grows. Rules marked as hard limits cannot be overridden under any circumstance.

| Rule | Default | Overridable? |
|---|---|---|
| Changes require human approval | Yes - via PR | Yes |
| Bugs that don't break requirements | Self-heal autonomously | Yes |
| Improvements require human review | Yes - always | Yes |
| Issues and improvements raised by agents | Yes | Yes |
| High/critical risk items require human review | Yes | Yes |
| Domain glossary must be respected | Yes | Yes |
| Docs submitted with code | Required - both or nothing | Yes |
| Schema changes require human approval | Yes - always | Yes |
| Migrations proposed before schema changes | Required | No - hard limit |
| Destructive schema operations require human approval | Yes - always | No - hard limit |
| Data contract owned by one component | Required | No - hard limit |

**Rationale:** A team new to Planifest gets maximum oversight. As confidence grows, rules can be relaxed - progressively increasing agent autonomy within boundaries the team controls. Hard limits exist because the consequences of getting them wrong are irreversible.

---

## FD-008 - Planifest encodes discipline, not tools

**Decision:** Planifest encodes functional and non-functional requirements, SDLC procedure, technical strategy, component purpose, domain knowledge, and standards. Implementation details - languages, frameworks, validation libraries - are below Planifest's concern. They are the codegen agent's domain, guided by stack configuration artifacts.

**Rationale:** Planifest's value is the discipline and repeatability it enforces, not the specific tools used to implement any given initiative. Coupling Planifest to implementation choices would limit its applicability and longevity.

---

## FD-009 - SDLC documentation folders are first-class components

**Decision:** The domain Planifest builds is written to a structured, versioned document store as the system is built. Every component produces documentation as a first-class output, not an afterthought. Documents are granular, standard, and machine-readable. History is never destroyed - only superseded.

Agents query before generating. Before building any component, an agent must at minimum:
1. Understand what already exists in the vicinity
2. Confirm there is no existing component with overlapping responsibility
3. Understand what risk has already been identified for this domain
4. Confirm it is using the correct ubiquitous language from the domain glossary

**Rationale:** Without a queryable domain, agents work in isolation - producing output that is technically correct but architecturally wrong. The structured SDLC documentation is what separates purposeful generation from plausible generation.

---

## FD-010 - Domain context is accessed via the git `docs/`, `plan/`, and `manifest/` folders

**Decision:** Agents access domain context by reading and writing the `docs/`, `plan/`, and `manifest/` folders directly via Agent Skills. Documents are colocated with the code they describe. No additional infrastructure is required - the documentation works locally and in CI.

A dedicated queryable Domain Knowledge Store MCP service is a roadmap item (see [RC-001](p014-planifest-roadmap.md)). It will provide tighter agent context and structured query responses suited to larger teams or complex domains.

**Rationale:** The git `docs/` folder provides sufficient queryability for single-agent, single-initiative work. The standardised file paths and artifact structure mean agents can navigate the store efficiently. The MCP service becomes valuable when the domain grows large enough that file-based navigation creates context bloat, or when multiple agents need concurrent access.

---

## FD-011 - Code and docs are always committed atomically

**Decision:** Code and documentation are always committed together in a single atomic operation. Neither is ever committed without the other. In v1.0, this discipline is enforced by the pipeline skill instructions and reviewed at the PR gate.

A serial write queue where the domain-knowledge-server is the sole writer to the git repository - structurally eliminating merge conflicts from concurrent agents - is a roadmap item (see [RC-003](p014-planifest-roadmap.md)).

**Rationale:** Atomic commits ensure the repository is never in a state where code exists without documentation or vice versa. The serial write queue model becomes important when multiple agents operate concurrently; v1.0 runs one agent session at a time.

---

## FD-012 - Credentials are never present in agent context

**Decision:** Agents are never given credentials directly. The agent is given a capability - it can commit to git - not a credential. In v1.0, credentials are managed by the OS (macOS Keychain, Windows Credential Manager, Linux git credential store) or injected as masked environment variables in CI. Agents interact with the filesystem and git via Agent Skills, never via credentials in their context window.

**Rationale:** An agent that holds credentials can leak them. An agent that holds a capability cannot. This is a security boundary, not a convenience.

---

## FD-013 - The artifacts are the product; the destination is pluggable

**Decision:** Planifest produces structured markdown artifacts. Where they are stored and rendered is an integration concern. The artifacts are the source of truth.

In v1.0, the git repository is the default - artifacts land alongside the code via Agent Skills, no additional integration required. A git repo is already in scope for every initiative.

Teams that want a richer documentation experience (Obsidian, Notion, Confluence) can integrate at the documentation provider level - see [RC-005 - Pluggable Documentation Provider](p014-planifest-roadmap.md).

**Rationale:** Tying Planifest to a specific document store constrains adoption. The artifacts themselves are the source of truth - the destination is a delivery detail.

---

## FD-014 - OpenAPI is the canonical contract

**Decision:** The OpenAPI specification is the language-agnostic contract for every initiative. It is generated first, from functional requirements, and everything downstream implements against it. JSON Schema, embedded within OpenAPI, serves as the schema layer. No separate schema artifact is required.

**Rationale:** OpenAPI is the lingua franca for API contracts, understood across languages and tooling ecosystems. Generating it first ensures the contract is stable before any implementation begins.

---

## FD-015 - Stack is a requirement, not a default

**Decision:** Stack is specified explicitly - never assumed or defaulted by Planifest. It is declared at system level and may be overridden at component level. Any component-level deviation must be justified by an ADR. Some initiatives may deliberately leave stack unspecified, allowing agents to reason from requirements alone.

Stack decisions are always traceable. Every choice has an ADR. Every override has a justification. Nothing is implicit.

When coaching a human through stack selection, the orchestrator should draw attention to the research in [Backend Stack Evaluation](p013-planifest-backend-stack-evaluation.md). Not all stacks are equal for agent-generated code - the evaluation scores 13 backend frameworks against agent-specific criteria: compile-time error detection, error feedback clarity, concurrency safety, first-pass success rate, and self-correction iteration cost. The human decides, but they should decide with this evidence.

The same principle applies to frontend stack selection. The [Frontend Stack Evaluation](p016-planifest-frontend-stack-evaluation.md) scores 10 frontend frameworks against agent-specific criteria including LLM training corpus coverage, component model clarity, styling integration, and visual acceptability. React 19 + Vite + TypeScript achieves the highest first-pass success rate (70-80% functional, 55-65% visual). The evaluation also recommends specifying the component library (shadcn/ui), state management (TanStack Query + Zustand), and form handling (React Hook Form + Zod) to constrain agent output and reduce iteration.

Key findings from the evaluation:
- **Agent iteration speed varies dramatically by language.** Go achieves 70-80% first-pass compilation; Rust achieves 45%. Both produce correct code - but at very different iteration costs.
- **A polyglot architecture is legitimate.** Different components have different requirements. An integration-heavy service benefits from Node.js/TypeScript SDK coverage. A security-critical service benefits from Rust's compile-time guarantees. A data pipeline benefits from Python's ecosystem. The stack can vary by component - each choice requires an ADR.
- **The pilot stack (Node.js/TypeScript + Fastify) is a defensible choice** for single-language simplicity, SDK coverage, and LLM fluency - but it is a pilot decision, not a Planifest default.

**Rationale:** Defaulting a stack is the same as defaulting requirements - it is presumptuous and undermines the spec-driven principle. Stack is a decision that belongs to the initiative or system, not to the pipeline. Agents generate code in whatever stack is declared - the quality of that code depends on the match between the stack and the initiative's requirements.

---

## FD-016 - Data is treated differently to code

**Decision:** A component can be rebuilt freely within its boundary - the data it owns cannot. Every component that owns data has a Data Contract: the canonical schema definition, the invariants the data must always satisfy, and the full migration history. Data ownership is singular - no two components own the same data. This is a hard limit.

Schema changes follow a strict path regardless of other configuration:
1. Agent proposes a migration - never applies it directly
2. Migration plan is written to the doc store and flagged for human review
3. Human approves before any schema change is applied
4. Destructive operations (drop column, drop table, rename) require human approval with no override

**Rationale:** Data is irreversible in a way code is not. A bad deployment can be rolled back. A destructive migration applied to production data cannot always be undone. The strictness here is proportionate to the risk.

---

## FD-017 - Component granularity is a design decision, not a framework constraint

**Decision:** Planifest supports three component types:

- **Microservice** - single deployable unit, single domain responsibility
- **Microfrontend** - single UI domain, independently deployable
- **Component pack** - a focused group of related logic with one reason to change, shipped together

The guiding principle: **one reason to change, easy to rebuild rather than modify**.

**Rationale:** Current model strengths favour generating a focused component from a clear spec over making surgical edits to existing code. Keeping components small and purposeful plays to that strength and keeps the agent's blast radius small and predictable. As model capabilities evolve, this guidance may too.

---

## FD-018 - Planifest supports three adoption modes

**Decision:** Where a team enters the Planifest pipeline depends on the state of their system and the complexity of their domain.

- **Greenfield** (`initiative_mode: greenfield`) - new system, no prior codebase. The Initiative Brief is the sole input. The pipeline runs from spec to PR.
- **Retrofit** (`initiative_mode: retrofit`) - existing production system with no prior spec. The `spec-agent` performs codebase ingestion first: scanning the repo, inferring existing architecture, and generating ADRs from what already exists. Conflicts, drift, and tech debt are surfaced before any new code is written.
- **Agent Interface Layer** (`initiative_mode: agent-interface`) - large or complex component library where a full codebase spec creates more noise than signal. A well-defined interface layer is specified first; agents develop against the interface, not the internals.

**Rationale:** A single entry point would make Planifest impractical for the most common real-world scenario - an existing production system. Adoption mode is a first-class concern, not an edge case.

---

## FD-019 - Artifact types are distinct and independently versioned

**Decision:** Planifest defines the following artifact types, each with a distinct scope and purpose. No artifact bleeds into another. Each is maintained and versioned independently. Each is a discrete input the agents consume.

**Per Initiative:**

| Artifact | Purpose |
|---|---|
| Initiative Brief | What needs to be built and why |
| Design Specification | Functional and non-functional requirements |
| OpenAPI Specification | Language-agnostic API contract |
| ADRs | Every significant decision with context and consequences |
| Risk Register | Technical, operational, security, and compliance risks |
| Scope | In / out / deferred |
| Security Report | Threat model, dependency audit, auth/authz, network policy |
| Quirks | Known oddities, workarounds, technical debt |
| Recommendations | Suggested improvements for future iterations |
| Operational Model | Runbook triggers, on-call expectations, alerting thresholds |
| SLO Definitions | Error budgets, SLIs/SLOs |
| Cost Model | Compute, storage, egress, third-party cost estimates |
| Domain Glossary | Ubiquitous language for the initiative |

**Per Component:**

| Artifact | Purpose |
|---|---|
| Component Purpose | What this component exists to do in the wider system |
| Interface Contract | Inputs, outputs, schema, consumers, breaking change policy |
| Dependencies | What it consumes / what depends on it |
| Data Contract | Schema, invariants, ownership |
| Migration History | Full history of schema changes |
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

**Rationale:** Clean separation of artifacts keeps each concern focused, makes the pipeline predictable, and allows any artifact to be updated without invalidating others.

---

## FD-020 - agentskills.io is the delivery mechanism; Planifest is the brain

**Decision:** In v1.0, Agent Skills (delivered via agentskills.io) are the execution mechanism. Planifest provides the knowledge, requirements, standards, and procedure that give those capabilities purpose and direction. They are complementary, not overlapping.

MCP will eventually provide the infrastructure layer - typed tool calls, credential isolation, structured query responses - see [RC-001](p014-planifest-roadmap.md) through [RC-004](p014-planifest-roadmap.md).

**Rationale:** Without Planifest, an agent is capable but undirected. Without a delivery mechanism, Planifest has no means of execution. The specification and the execution layer must be understood and maintained separately.

---

## FD-021 - A Planifest is the plan and the manifest

**Decision:** For every initiative, the orchestrator agent produces a **Planifest** - the plan is what will be built, the manifest is what it builds against. The human confirms the Planifest before the pipeline proceeds. It is written to `plan/current/planifest.md`.

The Planifest records: the problem, the adoption mode, the confirmed product layer (user stories, acceptance criteria, constraints), the architecture layer (NFRs, security, cost), the engineering layer (stack, components, data ownership, deployment), the scope boundaries (in, out, deferred), and the risks and dependencies.

**Rationale:** You cannot plan what to build without recording what you're building against. The Planifest is the contract between human and agent - the hard gate before development begins. See [Strategic Intent vs Stochastic Execution](p017-research-report-strategic-intent-vs-stochastic-execution.md) for the technical evaluation of this sequential intent-mapping logic.

---

## FD-022 - Planifest is delivered as Agent Skills

**Decision:** The Planifest pipeline is delivered as a set of Agent Skills - one `SKILL.md` file per pipeline phase, each independently installable. The orchestrator skill is the entry point; phase skills (spec-agent, adr-agent, codegen-agent, validate-agent, security-agent, docs-agent, change-agent) are invoked in sequence. Tool-specific adapters (`.claude/CLAUDE.md`, `.cursorrules`, `copilot-instructions.md`) load the skills via each tool's native compliance mechanism.

This resolves FQ-007.

**Rationale:** Planifest v1.0 is documentation that instructs agents. Agent Skills are structured documents that agents read and follow. The delivery mechanism and the product are the same thing. Skills are composable - a team that only wants the specification discipline installs the orchestrator and spec-agent. A team that wants the full pipeline installs the set.

---

## Open Questions

| Ref | Question |
|---|---|
| FQ-001 | Trigger mechanism: webhook, file watcher, or queue? Should be pluggable per deployment. |
| FQ-002 | Initiative Brief structure: what are the defined fields, and how is stack referenced within it? |
| FQ-003 | System and Component Configuration format: what does a stack declaration artifact look like, and how granular can it be? |
| FQ-004 | Codebase ingestion for large monorepos: how does ingestion handle component boundaries, existing data contracts, and shared tables that predate Planifest? |
| FQ-005 | Agent Interface Layer boundaries: when is it warranted, and can Planifest propose one from ingestion or does a human always define it? |
| FQ-006 | Rollback strategy: what is the recovery path when a migration is applied and something goes wrong post-deploy? |
| ~~FQ-007~~ | ~~Should Planifest pipeline agents be packaged as Agent Skills?~~ **Resolved - see FD-022.** |
