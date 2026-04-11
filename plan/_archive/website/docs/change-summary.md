# Change Summary

Change request: Remove MCP from v1.0 documentation - MCP is not part of v1.0 (which uses agentskills.io only). MCP references should only appear in roadmap sections.
Interpretation: Any reference to MCP as a current v1.0 capability is removed or clearly labelled as a future roadmap item. Where the current architecture is described, agentskills.io / direct file access replaces MCP. The roadmap document (p014) and roadmap/ subfolder are untouched - they already correctly frame MCP as future state.
Components affected: planifest-docs/p001, planifest-docs/p002, planifest-docs/p003, planifest-docs/p004, planifest-docs/p010
Contract changed: no
Schema changed: no
Migration proposed: no
Consumers affected: none
Blast radius: documentation content only - no code affected

## Files changed

### p001-planifest-master-plan.md
- §1: Removed "MCP is the nervous system" paragraph
- §2 System Overview: Removed MCP Servers subgraph and tool call arrows from diagram
- §3 DKS: Updated diagram to show direct file reads; updated "Two access paths" to v1.0 single path (git docs/) with MCP noted as roadmap
- §5 Agent responsibilities table: Updated column to "Domain Knowledge Access (v1.0)" with direct file access descriptions
- §7: Removed "MCP write model" subsection; updated AgentResult type; labelled orchestrator service section as roadmap
- §12 Build Sequence: Removed (described future MCP-first build plan, not v1.0)

### p002-planifest-product-concept.md
- §What This Could Become: Replaced "MCP servers" with "Agent Skills" in wedge description

### p003-planifest-functional-decisions.md
- FD-010: Updated to describe v1.0 as git docs/ folder only; MCP service noted as roadmap (RC-001)
- FD-011: Reframed as roadmap/future-state; v1.0 agents write directly via Agent Skills
- FD-012: Updated to focus on v1.0 non-MCP path; MCP path noted as roadmap
- FD-020: Reframed from "MCP is the nervous system" to "agentskills.io is the delivery mechanism for v1.0"

### p004-the-pathway-to-agentic-development.md
- §Domain Knowledge Store: Removed "the MCP service follows the same principle"
- §Accessing the Domain: Updated to v1.0 single path (git docs/); MCP service noted as roadmap

### p010-planifest-agentic-tool-runbook.md
- §8 Context Limit Strategy diagram: Removed "via filesystem MCP" from write-to-disk node

---

# Change Summary - 2026-03-18

Change request: Repository hygiene cleanup - exclude tool-specific AI agent config directories from version control.
Interpretation: Added `.gitignore` to the repository root excluding `.claude/`, `.gemini/`, `.agent/`, `.cursor/`, `.windsurf/`, and `.copilot/`. Untracked 436 previously committed files from `.claude/`, `.gemini/`, and `.agent/`. Generic, tool-agnostic configuration continues to live in `planifest-framework/`.
Components affected: none (repository infrastructure only)
Contract changed: no
Schema changed: no
Migration proposed: no
Consumers affected: none
Blast radius: repository structure only - no product code, contracts, or schemas affected

## Files changed

### .gitignore (new)
- Added exclusions for `.claude/`, `.gemini/`, `.agent/`, `.cursor/`, `.windsurf/`, `.copilot/`

### Untracked from index
- 436 files removed from git tracking across `.claude/skills/`, `.gemini/skills/`, and `.agent/workflows/`
- Files remain on disk; `.gitignore` prevents re-commitment

