> How to run the Planifest pipeline using each supported agentic development tool. v1.0 delivers the pipeline as Agent Skills - the orchestrator skill (`planifest-framework/skills/planifest-orchestrator/SKILL.md`) is the entry point. Tool-specific adapters in `planifest-framework/adapters/` load the skills via each tool's native compliance mechanism. MCP server infrastructure described in earlier versions of this document is a future roadmap item.

*Related: [Master Plan](p001-planifest-master-plan.md) | [Pipeline](p015-planifest-pipeline.md)*

---

## Table of Contents

- [1. The Orchestrator Skill - the shared source of truth](#1-the-orchestrator-skill---the-shared-source-of-truth)
- [2. Tool Comparison](#2-tool-comparison)
- [3. Claude Code](#3-claude-code)
- [4. Cursor](#4-cursor)
- [5. Antigravity](#5-antigravity)
- [6. GitHub Copilot](#6-github-copilot)
- [7. Hard Limits - all tools](#7-hard-limits--all-tools)
- [8. Context Limit Strategy](#8-context-limit-strategy)
- [9. Reconciling a Local Run with your VCS](#9-reconciling-a-local-run-with-your-vcs)

---

## 1. The Orchestrator Skill - the shared source of truth

`planifest-framework/skills/planifest-orchestrator/SKILL.md` is the entry point for all Planifest work, regardless of which agentic tool is used. It defines the coaching conversation, the pipeline phases (0-6), their sequencing, and the hard limits. Every tool loads this skill (or its tool-specific adapter) and follows it. The runtime differs; the steps do not.

The orchestrator skill:
- **Phase 0 (Assess and Coach)**: Assesses the brief and coaches the human to reach a **Design confirmed** state, producing the **confirmed design** at `plan/current/design.md`.
- **Sequences the phase skills**: spec-agent (Phase 1) -> adr-agent (Phase 2) -> codegen-agent (Phase 3) -> validate-agent (Phase 4) -> security-agent (Phase 5) -> docs-agent (Phase 6).
- **Handles Change Requests**: Invokes the change-agent skill for targeted modifications.

---

## 2. Tool Comparison

| Concern | Claude Code | Cursor | Antigravity | GitHub Copilot |
|---|---|---|---|---|
| MCP support | Native - stdio | Via MCP extension | Native | Limited / via extensions |
| Authentication | Claude Code session | API key or Cursor account | Antigravity account | GitHub account |
| Runs full pipeline | Yes - loads orchestrator skill, executes phases | Yes - with adapter + skills | Yes - pipeline-native | Partial - prompt-driven per phase |
| Domain Knowledge | Reads `plan/` and `docs/` directly | Reads `plan/` and `docs/` directly | Reads `plan/` and `docs/` directly | Reads `docs/` folder via workspace indexing |
| PR creation | Manual push + pipeline-run.md | Manual push + pipeline-run.md | Native | Via CLI or extension |
| Rules file | `planifest-framework/adapters/claude-code/CLAUDE.md` | `planifest-framework/adapters/cursor/.cursorrules` | Antigravity config | `planifest-framework/adapters/copilot/copilot-instructions.md` |
| Context management | Manual chunking per session | Per-file context, references by path | Managed by Antigravity | Limited - per-file or workspace |
| Hard limits enforced | Prompt-level + PR gate | Prompt-level + PR gate | Prompt-level + PR gate | Prompt-level + PR gate |

---

## 3. Claude Code

Claude Code is one of the supported local runtimes. It loads the orchestrator skill via `planifest-framework/adapters/claude-code/CLAUDE.md`, which points it at the skill set.

### Setup

The adapter file is loaded automatically when Claude Code opens the project root. For complex codebases, we recommend using the **Context-Mode MCP server** with the `--context-mode-mcp` setup flag. This installs enforcement hooks that prevent the agent from flooding its context window.

### Running the feature pipeline

```
Load the Planifest orchestrator skill at planifest-framework/skills/planifest-orchestrator/SKILL.md and execute the Feature Pipeline.

Feature brief: plan/current/feature-brief.md
Feature ID: {{feature_id}}
Adoption mode: greenfield | retrofit | agent-interface
```

The orchestrator will start Phase 0, coach gaps, produce the confirmed design (`design.md`), and then sequence through the phase skills once **Design confirmed**.

### Running the change pipeline

```
Load the Planifest orchestrator skill at planifest-framework/skills/planifest-orchestrator/SKILL.md and execute the Change Pipeline.

Feature ID: {{feature_id}}
Component ID: {{component_id}}
Change request: {{description}}
```

---

## 4. Cursor

Cursor discovers skills in `.cursor/skills/`. The setup script copies the Planifest skills there.

### Setup

Run the setup script:
```bash
# Windows
.\planifest-framework\setup.ps1 cursor
```

### Prompting

Cursor is prompt-driven. You must explicitly tell it to use the skill:

```
@planifest-orchestrator execute the Feature Pipeline.
Feature brief: plan/current/feature-brief.md
```

---

## 5. Antigravity

Antigravity natively understands the `GEMINI.md` and `planifest-framework/` structure.

### Setup

Antigravity is configured automatically when it discovers the `planifest-framework/` directory.

### Running the pipeline

```
Execute the Planifest Feature Pipeline.
Feature brief: plan/current/feature-brief.md
```

---

## 6. GitHub Copilot

Copilot uses `.github/copilot-instructions.md` (the boot file) to understand the framework.

### Setup

```bash
# Windows
.\planifest-framework\setup.ps1 copilot
```

---

## 7. Hard Limits - all tools

Regardless of the tool, the following hard limits are enforced by the skill set and reviewed at the PR:

1. **Design confirmed status required** to proceed past Phase 0.
2. **Requirements complete** before code generation begins.
3. No direct schema modification - **migration proposals only**.
4. **Destructive schema operations** require human approval.
5. **Data is owned by exactly one component**.
6. **Code and documentation** are written together.
7. **Credentials** are never in context.

---

## 8. Context Limit Strategy

Large features can exceed the context window of local tools. Planifest handles this via **Context-Mode**.

- **Context-Mode MCP (Primary)**: Uses a sandboxed search engine to query large outputs instead of reading them into context. Essential for large codebases. Activated via `--context-mode-mcp`.
- **Enforcement Hooks**: Physically blocks context-flooding native tools (`Grep`, `Bash` web calls) in Claude Code to ensure the agent uses the sandbox.
- **Selective context**: For the Change Pipeline, only load the required component manifests and contracts.
- **Phase-based isolation**: Complete each phase, commit the artifacts, and start the next phase in a fresh session if context is tight.
- **Component granularity**: Keep components focused. Small components have small contracts and fit easily in context.

---

## 9. Reconciling a Local Run with your VCS

Agents working locally commit to your local git repository.

1. Review the generated components and documentation.
2. Run your local tests.
3. `git push` to your remote.
4. Open the Pull Request on GitHub/GitLab.

The `pipeline-run.md` (written to the feature root) provides the summary for your PR description.
