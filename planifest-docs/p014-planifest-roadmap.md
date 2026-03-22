# Planifest - Roadmap


---

> A parking lot for ideas that are worth tracking but not yet committed to. Items move between states as they are evaluated, explored, or set aside. This is not a backlog - it carries no implied commitment or priority. Items that graduate to committed work become Initiative Briefs.

---

## States

| State | Meaning |
|---|---|
| **Candidate** | Parked concept. Enough context to pick up later. No evaluation yet. |
| **Under Consideration** | Actively being explored or discussed. May become a functional decision, open question, or Initiative Brief. |
| **Deferred** | Evaluated and set aside with a reason. Not forgotten - revisit when conditions change. |

## Estimate Scale

| Size | Meaning |
|---|---|
| **S** | A few days of focused work. Single component or document change. |
| **M** | A week or two. Multiple components, moderate complexity. |
| **L** | Several weeks. Cross-cutting concern, new infrastructure, or significant design work. |
| **XL** | A month or more. Major new capability, external dependencies, or ecosystem-level change. |

---

## Deferred

### RD-001 - Cross-Repository Component Discovery via Specification Matching

**Size:** XL

**Summary:** Enable Planifest agents to search for existing components - both internal and external (open-source) - by matching the current initiative's specification against structured metadata published by other Planifest-adopting teams or repositories. Instead of keyword search, this is specification-to-specification matching: the agent's requirements are compared structurally against published component metadata (Interface Contracts, OpenAPI specs, DomainDocument envelopes) to find candidates that satisfy the spec.

**What it would require:**

- A **Component Discovery Service** - a queryable registry that indexes published component metadata across repositories, enabling spec-to-spec matching
- **GitHub / registry search integration** - agents would need to search package registries (npm, crates.io, PyPI) and source repositories (GitHub, GitLab) for components publishing Planifest-compatible metadata
- An **adopt / adapt / author decision framework** - structured criteria for deciding whether to use an existing component as-is, wrap or extend it, or author from scratch
- **Evaluation criteria** - licensing, maintenance health, security posture, compatibility with the declared stack, match quality and gap analysis
- A **well-known manifest convention** - e.g. a standard file path or registry entry that external repositories use to publish their component metadata in a Planifest-compatible format

**Why it matters:** Most coding agents generate code from scratch using training data - a lossy, stale, unattributable version of what already exists in open-source. The Planifest artifact set already carries the structured metadata needed for matching (Component Registry, Interface Contracts, OpenAPI specs). This idea extends that metadata from an internal concern to an ecosystem-level capability.

**Why deferred:** The infrastructure required is substantial - a discovery service, search integration, and an ecosystem of adopters publishing metadata. The core Planifest pipeline must be built and proven first. This becomes viable once the specification framework is in use and the metadata format is stable. Revisit once the pilot is complete and adoption patterns are established.

**Origin:** Discussion during p014 creation, 07 MAR 2026.

---

## Under Consideration

### RC-001 - Domain Knowledge MCP Server

**Size:** L

**Summary:** A queryable MCP service wrapping the Domain Knowledge Store. Agents call tools (`domain_query`, `get_component`, `get_risk`, `get_glossary`, etc.) and receive scoped, structured responses rather than reading raw markdown files from `docs/`.

**What it would add:** Tighter agent context (agents receive only what they asked for, not entire files), structured query responses with confidence levels and source references, enforcement of hard limits at the tool level (the server refuses non-compliant writes).

**Why not now:** v1.0 operates with the agent reading the `docs/` folder directly. The standardised file paths and artifact structure provide sufficient queryability for single-agent, single-initiative work. The MCP service becomes valuable when the domain grows large enough that file-based navigation creates context bloat, or when multiple agents need concurrent access.

**Trigger to revisit:** When the pilot initiative's `docs/` folder exceeds what an agent can navigate efficiently in a single session, or when a second concurrent initiative is started.

**Existing design work:** [p005 - MCP Architecture](roadmap/p005-planifest-mcp-architecture.md), [p006 - Domain Knowledge Service Interface](roadmap/p006-planifest-domain-knowledge-service-interface.md), [p007 - Domain Knowledge Service Reference](roadmap/p007-planifest-domain-knowledge-service-reference.md).

**Origin:** v1.0 complexity review, 07 MAR 2026.

---

### RC-002 - Orchestrator Service

**Size:** L

**Summary:** A service that watches for new Initiative Briefs, runs the pipeline as a state machine (Discovery -> Spec -> ADR -> Codegen -> Validate -> Security -> PR -> Docs), persists state between steps, and handles retries with full error context. The implementation language is a stack decision.

**What it would add:** Fully automated pipeline execution without human-triggered sessions. Idempotent re-runs. State persistence across failures. The pipeline runs in CI without anyone opening an agent tool.

**Why not now:** v1.0 pipeline execution is the agent following `pipeline.md` in a human-triggered session. The human starts the tool, the agent reads the pipeline document, executes the phases. This is sufficient to prove the framework and iterate on the specification. The orchestrator automates what the human currently triggers - valuable once the pipeline is proven and the team wants hands-off execution.

**Trigger to revisit:** When the pipeline has been run successfully multiple times and the team wants CI-triggered execution rather than human-triggered sessions.

**Existing design work:** [p001 §7 - Agent Orchestration Layer](p001-planifest-master-plan.md#7-agent-orchestration-layer), [p009 - Pipeline Template Reference](roadmap/p009-planifest-pipeline-template-reference.md).

**Origin:** v1.0 complexity review, 07 MAR 2026.

---

### RC-003 - Serial Write Queue and Listener

**Size:** M

**Summary:** A queue-and-listener pattern where all agent writes are posted to a serial queue, processed one at a time, and committed atomically (code + docs together). The MCP domain-knowledge-server is the sole writer to git.

**What it would add:** Structural prevention of merge conflicts. Guaranteed atomic commits. Enforcement of the code-and-docs-together rule at the infrastructure level.

**Why not now:** v1.0 runs one agent at a time on one branch. Merge conflicts don't arise because there's a single writer. The agent commits directly. The code-and-docs-together discipline is enforced by the pipeline document and reviewed at the PR gate.

**Trigger to revisit:** When multiple agents operate concurrently on the same repository, or when the team wants structural enforcement of atomic commits rather than process enforcement.

**Existing design work:** [p007 §Git Write Model](roadmap/p007-planifest-domain-knowledge-service-reference.md#git-write-model), [p005 §7 - Write Model & Security](roadmap/p005-planifest-mcp-architecture.md#7-write-model--security).

**Origin:** v1.0 complexity review, 07 MAR 2026.

---

### RC-004 - MCP Server Suite (filesystem, ci, vcs, docs, nx)

**Size:** XL

**Summary:** A set of MCP servers providing structured tool access for file operations (scoped to component boundaries), CI execution (structured output rather than shell parsing), VCS operations (platform-agnostic PR creation), documentation sync (pluggable provider), and Nx project graph queries.

**What it would add:** Agents interact via typed tool calls rather than shell commands. Path scoping prevents agents from accidentally modifying other components. CI output is structured (parsed errors, not raw terminal output). VCS operations are platform-agnostic.

**Why not now:** v1.0 agents have direct access to the filesystem and can run shell commands. The pipeline document constrains their scope. The overhead of building, testing, and maintaining five MCP servers is disproportionate to the value they add when there's a single agent operating in a human-supervised session.

**Trigger to revisit:** When agent scope violations become a recurring problem at the PR gate, or when the team needs platform-agnostic VCS operations (switching from GitHub to GitLab, for example).

**Existing design work:** [p005 §3 - MCP Servers in This Pipeline](roadmap/p005-planifest-mcp-architecture.md#3-mcp-servers-in-this-pipeline).

**Origin:** v1.0 complexity review, 07 MAR 2026.

---

### RC-005 - Pluggable Documentation Provider

**Size:** M

**Summary:** A docs-server MCP that syncs Planifest artifacts to a configurable documentation target: Obsidian vault (with wikilinks), Notion database, Confluence space, or plain markdown / GitHub wiki.

**What it would add:** Teams choose where their documentation lives without changing the Planifest artifact structure. Cross-references are generated in the provider's native format.

**Why not now:** v1.0 docs are markdown in git. GitHub renders markdown and Mermaid natively. No sync step is needed - the docs are already where the code is. Teams that want Obsidian can point a vault at the `docs/` folder.

**Trigger to revisit:** When a team adopting Planifest has a hard requirement for Notion or Confluence as their primary documentation system.

**Existing design work:** [p001 §11 - Documentation Sync](p001-planifest-master-plan.md#11-documentation-sync), [p005 §3 - docs-server](roadmap/p005-planifest-mcp-architecture.md#3-mcp-servers-in-this-pipeline).

**Origin:** v1.0 complexity review, 07 MAR 2026.

---

### RC-006 - CI Pipeline Template Stamping

**Size:** M

**Summary:** Infrastructure to automatically generate CI pipeline configuration (GitHub Actions, GitLab CI, etc.) for each initiative, stamp `{{component_id}}` placeholders, manage template versions across components, and run migration scripts when templates are updated.

**What it would add:** Standardised CI config generated automatically for every initiative. Template versioning so pipeline improvements propagate to existing components.

**Why not now:** v1.0 teams write their own CI config (or the agent helps them write it). The pipeline phases are the same regardless of CI platform - what changes is the YAML syntax. Generating that YAML is straightforward; building and maintaining a template stamping and migration system is not.

**Trigger to revisit:** When more than a handful of initiatives exist and maintaining CI config manually across them becomes a burden.

**Existing design work:** [p009 §6 - Template Stamping](roadmap/p009-planifest-pipeline-template-reference.md#6-template-stamping).

**Origin:** v1.0 complexity review, 07 MAR 2026.

---

### RC-007 - Agent Prompt Library as API System Prompts

**Size:** S

**Summary:** The agent prompts in [p008](roadmap/p008-planifest-agent-prompt-library.md) are submitted to an LLM API as `system` messages when the orchestrator service runs the pipeline. Each prompt is parameterised with `{{placeholder}}` values filled by the orchestrator before the API call.

**What it would add:** Machine-executed pipeline - each agent phase is an API call, not a human-triggered session. Prompts are stable, versioned artifacts that can be tested and tuned independently.

**Why not now:** v1.0 agents read the pipeline document directly - they internalise the instructions rather than receiving them as API system prompts. The prompts in p008 are still useful as reference material for how each agent should behave, but submitting them as API calls requires the orchestrator service (RC-002).

**Trigger to revisit:** When RC-002 (Orchestrator Service) is built.

**Existing design work:** [p008 - Agent Prompt Library](roadmap/p008-planifest-agent-prompt-library.md).

**Origin:** v1.0 complexity review, 07 MAR 2026.

---

## Candidate

### RC-009 - Observability Store for Pipeline Quality Metrics

**Size:** L

**Summary:** Track retry counts per agent, self-correct patterns, spec gap frequency, brief quality metrics, and which components fail most. This data becomes a product analytics layer for engineering quality - showing which briefs are consistently underspecified, which agents need prompt tuning, and where the framework creates the most friction.

**Origin:** Mentioned in [p002 - Product Concept](p002-planifest-product-concept.md) and [p008 §10 - Tuning Notes](roadmap/p008-planifest-agent-prompt-library.md#10-tuning-notes). Not yet evaluated as a standalone capability.

---

### RC-010 - Planifest as SaaS (Component Registry as a Service)

**Size:** XL

**Summary:** The Component Registry becomes a hosted service. Teams connect their repos, component metadata is indexed, and agents across any tool can query the registry to understand the codebase before acting. Value compounds as more components are registered and more change history accumulates.

**Origin:** [p002 - Product Concept § What This Could Become](p002-planifest-product-concept.md). The long-term commercial vision. Depends on the open-source framework being adopted and the metadata format being stable.

---

*Related: [Master Plan](p001-planifest-master-plan.md) | [Product Concept](p002-planifest-product-concept.md) | [Functional Decisions](p003-planifest-functional-decisions.md)*
