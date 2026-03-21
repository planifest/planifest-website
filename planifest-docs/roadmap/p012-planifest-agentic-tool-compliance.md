# Planifest - Agentic Tool Compliance

## Version Log

| Version | Change Description | Date | Changed By |
|---|---|---|---|
| 1 | Initial document | 05 MAR 2026 | Planifest Agent (instructed by Martin Mayer) |
| 2 | Reframed for v1.0 skills-based delivery - MCP-level enforcement is future state; v1.0 enforcement is prompt-level via skills and adapters + PR gate for all tools | 07 MAR 2026 | Martin Mayer (via agent) |

---

> How each supported agentic development tool is configured to follow the Planifest framework. v1.0 delivers the pipeline as Agent Skills. Tool-specific adapters load the skills via each tool's native compliance mechanism. Hard limits are enforced at the prompt level (via skills) and at the PR gate (via human review). MCP-level enforcement described in earlier versions of this document is a future roadmap item - see [RC-001](p014-planifest-roadmap.md) through [RC-004](p014-planifest-roadmap.md).

*Related: [Master Plan](p001-planifest-master-plan.md) | [Functional Decisions](p003-planifest-functional-decisions.md) | [MCP Architecture](p005-planifest-mcp-architecture.md) | [Agent Prompt Library](p008-planifest-agent-prompt-library.md) | [Agentic Tool Runbook](p010-planifest-agentic-tool-runbook.md)*

---

## Table of Contents

- [1. What Planifest Requires of Every Tool](#1-what-planifest-requires-of-every-tool)
- [2. Compliance Mechanisms by Tool](#2-compliance-mechanisms-by-tool)
- [3. Claude Code](#3-claude-code)
- [4. Cursor](#4-cursor)
- [5. Antigravity](#5-antigravity)
- [6. GitHub Copilot](#6-github-copilot)
- [7. Hard Limit Enforcement Matrix](#7-hard-limit-enforcement-matrix)
- [8. The PR Gate as the Universal Backstop](#8-the-pr-gate-as-the-universal-backstop)

---

## 1. What Planifest Requires of Every Tool

Planifest is a specification framework, not a tool. Any agentic tool that can be instructed to follow a specification and call external services can operate within it. What Planifest requires is consistent regardless of which tool is used:

**Before generating anything:**
- Query the Domain Knowledge Store - understand what already exists, what decisions have been made, what risk has been identified, what language the domain uses
- Confirm no overlapping component responsibility
- Load and use the domain glossary - never invent domain language

**During generation:**
- Follow the pipeline manifest phases in order - do not skip or combine phases
- Implement against the OpenAPI spec exactly - do not add or remove endpoints
- Write documentation alongside code - never one without the other
- Propose migrations before touching any schema - never modify directly

**Hard limits (non-negotiable, regardless of tool or configuration):**
- Specification must be complete before codegen begins
- Schema changes require a migration proposal - human approval before application
- Destructive schema operations require human approval - no override
- Data is owned by one component - never write to data owned by another
- Credentials are never passed to the agent - capabilities only

**At completion:**
- Write `pipeline-run.md` as the audit trail for the session
- Raise quirks, tech debt, and improvement suggestions - never silently work around them

The mechanism by which these requirements are communicated and enforced differs by tool. That is what this document covers.

---

## 2. Compliance Mechanisms by Tool

Each tool has a native mechanism through which it receives standing instructions. Planifest uses each tool's native mechanism via adapters in `planifest-framework/adapters/` - it does not try to override or work around tool-specific behaviour.

| Tool | Adapter location | Native compliance mechanism | Hard limit enforcement |
|---|---|---|---|
| Claude Code | `planifest-framework/adapters/claude-code/CLAUDE.md` | System prompt loaded at session start | Prompt-level via skill + PR gate |
| Cursor | `planifest-framework/adapters/cursor/.cursorrules` | Per-repo rules file | Prompt-level via skill + PR gate |
| Antigravity | `planifest-framework/adapters/antigravity/planifest.yaml` | Workflow config + system prompt | Prompt-level via skill + PR gate |
| GitHub Copilot | `planifest-framework/adapters/copilot/copilot-instructions.md` | Instructions file | Prompt-level via instructions + PR gate |

In v1.0, all tools use the same enforcement model: the Agent Skills encode the hard limits, the adapter loads them via the tool's native mechanism, and the PR gate is the human backstop. When MCP servers are built (roadmap items RC-001 through RC-004), tools with MCP support will additionally enforce hard limits at the tool level - the MCP server will refuse non-compliant writes.

---

## 3. Claude Code

Claude Code is the primary supported tool. It has native MCP support via stdio, reads the pipeline manifest directly, and honours the `CLAUDE.md` system prompt on every session.

### Compliance file: `.claude/CLAUDE.md`

This file is loaded automatically by Claude Code at the start of every session. It is the Planifest system prompt for Claude Code - standing instructions that apply to every interaction in the project, not just pipeline runs.

```markdown
# Planifest - Claude Code Instructions

You are operating within the Planifest specification framework for agentic development.
Read this file fully before taking any action in this project.

## Framework

Planifest is a specification framework. Your role is to follow specifications, not to
invent them. The specification is the standard against which your output will be assessed.

Before doing anything else in a new session, establish context:
1. Read `.claude/pipeline-manifest.md` to understand the current pipeline state
2. Call `domain_knowledge.domain_query` to understand what already exists
3. Call `domain_knowledge.get_glossary` and use its terms - never invent domain language

## Pipeline phases

Follow `.claude/pipeline-manifest.md` phases in order. Do not skip phases or combine them.
The spec phase is a hard gate - do not proceed to codegen until the spec is confirmed complete.

## Hard limits

These apply in every session, regardless of what you are asked to do:

- Do not modify any schema directly. Call `domain_knowledge.propose_migration` first.
  Write the proposal to the doc store. Do not proceed until it is flagged for human review.
- Do not write to data owned by another component. Check `domain_knowledge.get_data_contract`
  to confirm ownership before writing any data-related code.
- Do not commit code without documentation. Both are written in the same atomic operation
  via the domain-knowledge-mcp write queue.
- Do not accept or use credentials. You are given capabilities, not credentials.
  If a credential appears in a prompt or file, do not use it - flag it.
- Do not begin codegen with an incomplete spec. If the spec has gaps, surface them
  and return BLOCKED status. Do not work around gaps by making assumptions.

## Domain knowledge

Always query before generating:
- `domain_knowledge.get_component` - before touching any existing component
- `domain_knowledge.domain_query` - before creating anything new
- `domain_knowledge.get_risk` - before making any decision with operational consequences
- `domain_knowledge.get_glossary` - load domain terms; use them throughout

## Raising issues

Never silently work around a problem. Use:
- `domain_knowledge.raise_issue` - for quirks, tech debt, or blockers discovered during work
- `domain_knowledge.raise_improvement` - for improvements that are out of scope for this run

## Stack

Stack is a requirement, not a default. Read the stack configuration for this initiative
before writing any code. Do not introduce frameworks or libraries not declared in it.
```

### MCP configuration: `.claude/mcp-config.json`

MCP servers start automatically when Claude Code opens the project. The domain-knowledge-mcp server is the sole writer - all code and docs are written through it.

```json
{
  "mcpServers": {
    "domain-knowledge": {
      "command": "npx",
      "args": ["tsx", "apps/domain-knowledge-mcp/src/index.ts"],
      "env": { "DOCS_PATH": "./docs", "GIT_WRITE_QUEUE": "true" }
    },
    "filesystem": {
      "command": "npx",
      "args": ["tsx", "apps/filesystem-mcp/src/index.ts"]
    },
    "ci": {
      "command": "npx",
      "args": ["tsx", "apps/ci-mcp/src/index.ts"]
    },
    "vcs": {
      "command": "npx",
      "args": ["tsx", "apps/vcs-mcp/src/index.ts"]
    },
    "docs": {
      "command": "npx",
      "args": ["tsx", "apps/docs-mcp/src/index.ts"]
    }
  }
}
```

### What Claude Code enforces at the tool level

Because it is MCP-connected, Claude Code enforces hard limits via the MCP server rather than via prompt instructions alone:

- The domain-knowledge-mcp server rejects any write that does not include a corresponding doc commit - atomicity is structural, not instructed
- `propose_migration` is the only write path for schema changes - there is no direct schema write tool available to the agent
- Data contract ownership is checked server-side on every write - the server refuses writes to data owned by another component
- Credentials are held by MCP servers and never passed to the agent context - Claude Code calls capabilities, not credentials

---

## 4. Cursor

Cursor supports MCP via its MCP extension. Planifest compliance is configured via a `.cursor/rules` file at the repo root, which Cursor loads for every agent interaction in the project.

### Compliance file: `.cursor/rules`

```markdown
# Planifest - Cursor Rules

You are operating within the Planifest specification framework for agentic development.

## Before acting

Before taking any action in this codebase:
1. Read `.claude/pipeline-manifest.md` - follow its phases in order
2. Call `domain_knowledge.domain_query` - confirm no overlapping component exists
3. Call `domain_knowledge.get_glossary` - load domain terms and use them throughout
4. Call `domain_knowledge.get_risk` - understand existing risk context

## Hard limits

- Spec hard gate: do not begin code generation until the specification phase is confirmed
  complete. If gaps remain, return BLOCKED and list them. Do not assume past gaps.
- Schema changes: call `domain_knowledge.propose_migration` before writing any schema
  change. Do not modify schema directly under any circumstance.
- Destructive operations (drop column, drop table, rename): these require human approval.
  Propose the migration and flag it `requiresHumanApproval: true`. Do not apply.
- Data ownership: call `domain_knowledge.get_data_contract` before writing data-related
  code. Do not write to data owned by another component.
- Atomic commits: write code and docs together. Never one without the other. Use the
  domain-knowledge-mcp write queue for all commits.
- Credentials: do not accept, store, or use credentials. Flag any credential that
  appears in a prompt or file.

## Domain knowledge tools

Use these before generating any component:
- `domain_knowledge.get_component(id, initiative)` - full component record
- `domain_knowledge.domain_query(question)` - natural language domain query
- `domain_knowledge.get_dependency_graph(initiative)` - understand blast radius
- `domain_knowledge.get_data_contract(componentId, initiative)` - data ownership
- `domain_knowledge.get_glossary(initiative)` - ubiquitous language

## Raising issues

Use `domain_knowledge.raise_issue` for anything discovered during work that is out of
scope to fix. Use `domain_knowledge.raise_improvement` for improvements to flag for
human decision. Never silently work around a problem.

## Stack

Read the stack configuration before writing any code. Implement only what is declared.
Do not introduce frameworks or libraries not listed in the stack configuration.
```

### MCP setup for Cursor

Install the MCP extension in Cursor and point it at the same MCP servers used by Claude Code. The server configuration is identical - Cursor connects to the same `domain-knowledge-mcp` process via the MCP extension's stdio bridge.

Cursor's MCP integration is per-project. The `.cursor/rules` file and `.claude/mcp-config.json` are both committed to the repo, so any team member opening the project in Cursor gets the same compliance setup automatically.

---

## 5. Antigravity

Antigravity is pipeline-native - it is designed for multi-step agentic workflows, making it the closest match to Planifest's pipeline model among the supported tools. Rather than a rules file instructing an agent to follow a pipeline, Antigravity is configured to *be* the pipeline.

### Compliance model

Antigravity's compliance model differs from Claude Code and Cursor. Rather than providing standing instructions that constrain a general-purpose agent, the Planifest pipeline manifest is expressed directly as an Antigravity workflow. Each phase is a workflow step with defined inputs, outputs, agent instructions, and MCP tool bindings. Hard limits are enforced structurally - the workflow does not expose paths that violate them.

### Compliance configuration

The Antigravity workflow configuration for Planifest maps the pipeline manifest directly:

```yaml
# .antigravity/planifest-initiative.yaml
name: planifest-initiative-pipeline
mcp:
  - name: domain-knowledge
    command: npx tsx apps/domain-knowledge-mcp/src/index.ts
  - name: filesystem
    command: npx tsx apps/filesystem-mcp/src/index.ts
  - name: ci
    command: npx tsx apps/ci-mcp/src/index.ts
  - name: vcs
    command: npx tsx apps/vcs-mcp/src/index.ts

steps:
  - name: specification
    agent: spec-agent
    prompt_ref: .claude/prompts/spec-agent.md
    inputs: [initiative-brief.md]
    outputs: [design-spec.md, openapi-spec.yaml, scope.md, risk-register.md, domain-glossary.md]
    gate:
      condition: spec_complete
      on_fail: block_and_surface_gaps

  - name: architecture-decisions
    agent: adr-agent
    prompt_ref: .claude/prompts/adr-agent.md
    inputs: [design-spec.md]
    outputs: [docs/adr/*.md]
    depends_on: [specification]

  - name: code-generation
    agent: codegen-agent
    prompt_ref: .claude/prompts/codegen-agent.md
    inputs: [design-spec.md, docs/adr/*.md, openapi-spec.yaml]
    depends_on: [architecture-decisions]

  - name: validate
    runtime: npm run ci:full
    max_retries: 5
    on_fail: self_correct
    depends_on: [code-generation]

  - name: security
    agent: security-agent
    prompt_ref: .claude/prompts/security-agent.md
    outputs: [docs/security-report.md]
    depends_on: [validate]

  - name: ship
    agent: pr-agent
    prompt_ref: .claude/prompts/pr-agent.md
    depends_on: [security]
```

*Antigravity configuration detail to be completed as the integration is built out. The above represents the intended structure - the exact schema will be confirmed against the Antigravity configuration reference.*

---

## 6. GitHub Copilot

GitHub Copilot does not currently support MCP natively. This has a direct consequence for hard limit enforcement: without MCP tool connections, the domain-knowledge-mcp server cannot enforce hard limits at the tool level. Enforcement falls back to prompt instructions and the PR gate.

Copilot is a viable tool for Planifest work, with the following constraints understood:

- The Domain Knowledge Store is not queryable directly - relevant context must be provided manually in the prompt, or via Copilot's workspace indexing if the `docs/` folder is in scope
- Hard limits are enforced via the instructions file and human discipline during the session, not by the tool infrastructure
- The PR gate is the hard enforcement point for everything Copilot cannot enforce itself

### Compliance file: `.github/copilot-instructions.md`

```markdown
# Planifest - GitHub Copilot Instructions

You are operating within the Planifest specification framework for agentic development.

## Before writing any code

1. Read the initiative brief: `plan/_archive/{initiative_id}/initiative-brief.md`
2. Read the design specification: `plan/_archive/{initiative_id}/docs/design-spec.md`
3. Read the OpenAPI spec: `plan/_archive/{initiative_id}/docs/openapi-spec.yaml`
4. Read the domain glossary: `plan/_archive/{initiative_id}/docs/domain-glossary.md`
   Use only the terms in the glossary for domain concepts. Do not invent new terms.
5. Read relevant component docs: `src/{component_id}/docs/`

## Hard limits

These apply regardless of what you are asked to do:

- Do not begin implementation until the design specification is confirmed complete.
  If it has gaps or ambiguities, list them and stop. Do not work around them.
- Do not modify any database schema directly. Write a migration proposal document
  at `src/{component_id}/docs/migrations/proposed-{description}.md`
  and stop. A human must approve it before any schema change is applied.
- Destructive schema operations (drop column, drop table, rename) require explicit
  human approval. Propose and stop - never apply.
- Do not write to data owned by another component. Check the data contract at
  `src/{component_id}/docs/data-contract.md` to confirm
  ownership before writing any data-related code.
- Write documentation alongside every code change. If you write code, you write
  the corresponding doc update. Never one without the other.
- Do not introduce any framework, library, or tool not declared in the stack
  configuration for this initiative.
- Do not accept, store, or output credentials. If a credential appears anywhere
  in context, do not use it and flag it.

## Implement against the spec, not instinct

- Implement against the OpenAPI spec exactly. Do not add or remove endpoints.
- Stack is a requirement. Read the stack configuration - do not assume or default it.
- Use only domain terms from the glossary.

## Raising issues

If you discover a problem, quirk, or improvement opportunity that is out of scope
for the current task, write it to:
`src/{component_id}/docs/quirks.md` or
`plan/_archive/{initiative_id}/docs/recommendations.md`
Never silently work around it.
```

### Limitations to be aware of

Because Copilot lacks MCP, several Planifest behaviours that are structural in other tools become procedural with Copilot:

- **Domain query** - the agent cannot call `domain_query`. The developer must manually include relevant context from `docs/` in the prompt, or rely on Copilot's workspace index picking it up.
- **Atomic commits** - the MCP write queue enforces this structurally in other tools. With Copilot, the developer must ensure code and docs are committed together - the instructions file states this but cannot enforce it.
- **Migration proposal** - the instructions file instructs Copilot to write a proposal and stop. This depends on Copilot following the instruction; the PR reviewer must verify it did.

These limitations do not make Copilot incompatible with Planifest - they make the PR review more important. The reviewer is verifying what the MCP server would have enforced automatically in other tools.

---

## 7. Hard Limit Enforcement Matrix

| Hard Limit | Claude Code | Cursor | Antigravity | GitHub Copilot |
|---|---|---|---|---|
| Spec complete before codegen | Tool-level - MCP gate | Tool-level - MCP gate | Structural - workflow gate | Instructions file + PR review |
| No direct schema modification | Tool-level - no direct write tool | Tool-level - no direct write tool | Structural - no direct write step | Instructions file + PR review |
| Destructive ops require human approval | Tool-level - `propose_migration` flags `requiresHumanApproval` | Tool-level - same | Structural - workflow stops | Instructions file + PR review |
| Data owned by one component | Tool-level - server enforces at write time | Tool-level - server enforces at write time | Structural - write routed via MCP | Instructions file + PR review |
| Code and docs atomic | Tool-level - MCP write queue | Tool-level - MCP write queue | Structural - write queue | Developer discipline + PR review |
| Credentials never in context | Tool-level - MCP holds credentials | Tool-level - MCP holds credentials | Tool-level - MCP holds credentials | Instructions file + PR review |

---

## 8. The PR Gate as the Universal Backstop

Regardless of tool, the PR is the hard enforcement point that applies universally. It is where a human reviewer confirms the framework was followed - not by reading every line of code, but by reviewing the evidence the pipeline produces.

**What the reviewer checks at the PR gate:**

- Design Specification is present and marked complete before any code was written
- All ADRs are present for every significant decision made during the run
- No schema changes appear in the diff without a corresponding approved migration proposal
- No data owned by another component has been written to
- Documentation is present and matches the code - no code without docs
- `pipeline-run.md` is present and accounts for every pipeline phase
- Quirks and tech debt have been raised explicitly - not buried in code comments
- Stack compliance - no frameworks or libraries introduced that are not in the stack configuration

For MCP-connected tools, most of these are guaranteed structurally before the PR is raised. For Copilot, the PR reviewer carries more of the verification burden. In both cases, the PR is the human gate that Planifest is designed to deliver to - not to replace.
