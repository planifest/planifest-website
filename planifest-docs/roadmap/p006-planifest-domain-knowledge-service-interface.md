# Planifest - Domain Knowledge Service Interface

## Version Log

| Version | Change Description | Date | Changed By |
|---|---|---|---|
| 1 | Initial Document | 05 MAR 2026 | Martin Mayer |
| 2 | Deduplicated default rules table - now references canonical table in p003 FD-007 | 07 MAR 2026 | Martin Mayer (via agent) |
| 3 | Added future-state status marker - v1.0 operates with git docs/ path; this interface specification applies when RC-001 is implemented | 07 MAR 2026 | Martin Mayer (via agent) |

---

> **Status: Future architecture.** This document defines the interface for the Domain Knowledge Service MCP server (roadmap item [RC-001](p014-planifest-roadmap.md)). v1.0 operates with the git `docs/` path - agents read and write artifacts directly as markdown files. The interface defined here becomes relevant when the Domain Knowledge Store is implemented as a queryable service.

> The public interface specification for the Planifest Domain Knowledge Service. This document defines the contracts a conforming implementation must honour. Implementation details - storage backend, queue mechanism, git provider, branching strategy - are left to the implementer.

---

## Overview

Planifest is a specification framework for agentic development. The Domain Knowledge Service is the component of that framework responsible for storing, versioning, and serving the domain knowledge agents require to build with purpose and humans require to verify what was built.

This specification defines the interface any conforming implementation must expose. The [Planifest reference implementation](p007-planifest-domain-knowledge-service-reference.md) is one implementation - opinionated, git-backed, and built for the Planifest stack. Teams may implement the interface differently against their own infrastructure: different storage backends, queue systems, git providers, or document stores.

---

## Conformance Requirements

A conforming implementation must:

- Expose all tools defined in this specification with the exact request and response schemas described
- Support all document types defined in the Document Envelope
- Implement the Default Rules model - all rules must be supported and overridable per initiative, except hard limits which must not be overridable
- Persist documents with versioning - updates create new versions, history is never destroyed
- Flag agent-authored documents distinctly from human-authored documents
- Ensure code and docs are always written atomically - never one without the other
- Provide a non-MCP path where agents interact with the underlying store directly using locally-held credentials that are never exposed to the agent

---

## Document Envelope

Every document in a conforming store must support this envelope. Content varies by document type; the envelope is always the same.

```typescript
interface DomainDocument {
  id: string                    // e.g. "initiative:auth-service:design-spec"
  type: DocumentType
  scope: DocumentScope
  initiative: string
  component?: string
  version: string               // semver
  createdAt: string             // ISO 8601
  updatedAt: string             // ISO 8601
  author: "human" | "agent"
  status: "draft" | "active" | "superseded" | "archived"
  content: DocumentContent
  risk: RiskSummary
  scope_boundaries: ScopeBoundaries
  quirks: Quirk[]
}

type DocumentScope = "initiative" | "component" | "system"

type DocumentType =
  | "initiative-brief"
  | "design-spec"
  | "openapi-spec"
  | "adr"
  | "security-report"
  | "risk-register"
  | "scope"
  | "quirks"
  | "recommendations"
  | "operational-model"
  | "slo-definitions"
  | "cost-model"
  | "domain-glossary"
  | "component-purpose"
  | "interface-contract"
  | "dependency-map"
  | "test-coverage"
  | "tech-debt"
  | "data-contract"
  | "migration"
  | "component-registry"
  | "dependency-graph"
```

### Cross-cutting Types

```typescript
interface RiskSummary {
  level: "low" | "medium" | "high" | "critical"
  items: RiskItem[]
}

interface RiskItem {
  id: string
  category: "technical" | "operational" | "security" | "compliance"
  description: string
  likelihood: "low" | "medium" | "high"
  impact: "low" | "medium" | "high"
  mitigation?: string
  status: "open" | "mitigated" | "accepted"
}

interface ScopeBoundaries {
  in: string[]
  out: string[]
  deferred: string[]
}

interface Quirk {
  id: string
  description: string
  workaround?: string
  raisedBy: "human" | "agent"
  raisedAt: string
  status: "open" | "resolved" | "accepted"
}
```

---

## Required Tools

### Query Tools

#### `domain_query`
```typescript
interface DomainQueryRequest {
  question: string
  scope?: {
    initiative?: string
    component?: string
    documentTypes?: DocumentType[]
  }
  maxResults?: number           // default: 5
}

interface DomainQueryResponse {
  answer: string
  confidence: "high" | "medium" | "low"
  sources: DocumentReference[]
  relatedQuestions?: string[]
}

interface DocumentReference {
  id: string
  type: DocumentType
  excerpt: string
  path: string
}
```

#### `get_component`
```typescript
interface GetComponentRequest {
  componentId: string
  initiative: string
  include?: DocumentType[]
}

interface GetComponentResponse {
  component: ComponentRegistryEntry
  purpose: ComponentPurpose
  contract: InterfaceContract
  risk: RiskSummary
  scope: ScopeBoundaries
  quirks: Quirk[]
  adrs: ADRContent[]
  techDebt: string[]
}
```

#### `get_dependency_graph`
```typescript
interface GetDependencyGraphRequest {
  initiative: string
  rootComponent?: string
  depth?: number                // default: 2
}

interface GetDependencyGraphResponse {
  nodes: ComponentRegistryEntry[]
  edges: DependencyEdge[]
}

interface DependencyEdge {
  from: string
  to: string
  type: "consumes" | "produces" | "publishes" | "subscribes"
  contract: string
}
```

#### `list_adrs`
```typescript
interface ListADRsRequest {
  initiative: string
  component?: string
  status?: ADRContent["status"][]
}

interface ListADRsResponse {
  adrs: Array<{
    id: string
    title: string
    status: ADRContent["status"]
    decision: string
    path: string
  }>
}
```

#### `get_risk`
```typescript
interface GetRiskRequest {
  initiative: string
  component?: string
  level?: RiskItem["level"][]
  status?: RiskItem["status"][]
}

interface GetRiskResponse {
  summary: RiskSummary
  items: RiskItem[]
}
```

#### `get_quirks`
```typescript
interface GetQuirksRequest {
  initiative: string
  component?: string
  status?: Quirk["status"][]
}

interface GetQuirksResponse {
  quirks: Quirk[]
}
```

#### `get_glossary`
```typescript
interface GetGlossaryRequest {
  initiative: string
  term?: string
}

interface GetGlossaryResponse {
  terms: GlossaryEntry[]
}

interface GlossaryEntry {
  term: string
  definition: string
  aliases?: string[]
  usedIn: string[]
}
```

#### `get_data_contract`
```typescript
interface GetDataContractRequest {
  componentId: string
  initiative: string
}

interface GetDataContractResponse {
  componentId: string
  owner: string
  schema: DataSchema
  invariants: string[]
  migrations: MigrationSummary[]
}
```

#### `get_migration_history`
```typescript
interface GetMigrationHistoryRequest {
  componentId: string
  initiative: string
  status?: MigrationSummary["status"][]
}

interface GetMigrationHistoryResponse {
  componentId: string
  migrations: MigrationSummary[]
  currentSchemaVersion: string
}
```

---

### Write Tools

#### `create_document`
```typescript
interface CreateDocumentRequest {
  type: DocumentType
  scope: DocumentScope
  initiative: string
  component?: string
  content: DocumentContent
  changeSummary: string
}

interface CreateDocumentResponse {
  id: string
  version: string
  path: string
  requiresHumanReview: boolean
}
```

#### `update_document`
```typescript
interface UpdateDocumentRequest {
  id: string
  content: Partial<DocumentContent>
  changeSummary: string
}

interface UpdateDocumentResponse {
  id: string
  previousVersion: string
  newVersion: string
  path: string
  requiresHumanReview: boolean
}
```

#### `supersede_adr`
```typescript
interface SupersedeADRRequest {
  supersededId: string
  newAdr: ADRContent
  rationale: string
  initiative: string
  component?: string
}

interface SupersedeADRResponse {
  supersededId: string
  newId: string
  path: string
  requiresHumanReview: boolean  // always true
}
```

#### `raise_issue`
```typescript
interface RaiseIssueRequest {
  initiative: string
  component?: string
  type: "quirk" | "risk" | "tech-debt"
  description: string
  severity?: "low" | "medium" | "high"
  suggestedMitigation?: string
}

interface RaiseIssueResponse {
  id: string
  status: "logged"
  path: string
  requiresHumanReview: boolean
}
```

#### `raise_improvement`
```typescript
interface RaiseImprovementRequest {
  initiative: string
  component?: string
  title: string
  description: string
  rationale: string
  effort: "low" | "medium" | "high"
  impact: "low" | "medium" | "high"
  suggestedApproach?: string
  relatedDocuments?: string[]
}

interface RaiseImprovementResponse {
  id: string
  status: "logged"
  path: string
  requiresHumanReview: true     // always by default
}
```

#### `propose_migration`
```typescript
interface ProposeMigrationRequest {
  componentId: string
  initiative: string
  description: string
  changes: SchemaChange[]
  rationale: string
  rollbackPlan: string
}

interface SchemaChange {
  type: "add-column" | "add-table" | "add-index"
       | "modify-column" | "rename-column" | "rename-table"
       | "drop-column" | "drop-table"
  target: string
  detail: string
  destructive: boolean
}

interface ProposeMigrationResponse {
  id: string
  status: "proposed"
  path: string
  requiresHumanReview: true     // always
  hardLimit: boolean            // true if destructive operations present
}
```

---

## Default Rules

A conforming implementation must support all default rules defined in [FD-007](p003-planifest-functional-decisions.md#fd-007--default-rules-are-conservative-autonomy-is-earned-progressively) as configurable behaviour per initiative. Rules marked **hard limit** in FD-007 must not be overridable.

---

## Non-MCP Path

A conforming implementation must also support a non-MCP path where agents interact with the underlying store directly - writing code and docs without the service intermediary. This path suits smaller teams, single initiatives, or environments where running an additional service is not desirable.

Both paths must produce the same document structure and honour the same default rules. The choice is operational, not architectural.

In this mode:
- The agent writes directly using locally-held credentials
- Credentials are managed natively by the OS (macOS Keychain, Windows Credential Manager, Linux git credential store) or injected as masked environment variables in CI
- Credentials are never present in the agent's context - the agent is given a capability, not a credential
- The same atomicity requirement applies - code and docs are always written together

---

*Related: [Master Plan](p001-planifest-master-plan.md) | [Domain Knowledge Service Reference](p007-planifest-domain-knowledge-service-reference.md) | [The Pathway to Agentic Development](p004-the-pathway-to-agentic-development.md) | [Roadmap](p014-planifest-roadmap.md)*
