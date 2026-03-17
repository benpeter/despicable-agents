## Meta-Plan

### Planning Consultations

#### Consultation 1: Adapter Interface Design

- **Agent**: api-design-minion
- **Planning question**: The `DelegationRequest` and `DelegationResult` types define the contract between the nefario orchestrator and external coding tool adapters (Codex CLI, Aider, future tools). Given the fields listed in the roadmap (agent name, task prompt, instruction file path, working directory, model tier, required tools list for request; exit code, changed files, stdout summary, stderr, raw diff reference for result), what is the minimal, well-structured interface? Specifically: (a) Should model tier be an enum or a string? (b) Should changed files be a list of paths or include richer metadata (e.g., added/modified/deleted)? (c) Should exit code distinguish between adapter failure vs. task failure? (d) Are there any fields needed to support both Codex (structured JSON output) and Aider (git-diff-based collection) that the roadmap spec might be missing?
- **Context to provide**: `docs/external-harness-integration.md` (gap analysis, current delegation model, tool inventory), `docs/external-harness-roadmap.md` (Issue 1.1 scope, Issues 2.1-2.2 and 3.1-3.3 for downstream consumer context), the fact that the codebase is pure Markdown + shell (no JS/TS/Python)
- **Why this agent**: API design is the core competency needed here. The types define a contract that multiple adapters will implement and the orchestrator will consume. Getting field semantics, optionality, and extensibility right is the primary planning challenge.

#### Consultation 2: Format and Language Decision

- **Agent**: devx-minion
- **Planning question**: The despicable-agents codebase is entirely Markdown and shell scripts -- no programming language code exists. The roadmap says "Language/format matches the surrounding codebase (document the decision; do not assume)." What is the right format for defining `DelegationRequest` and `DelegationResult` types in a Markdown-native project? Options include: (a) pure Markdown specification with field tables, (b) YAML schema definition (like JSON Schema in YAML), (c) TypeScript type definitions as a reference spec even though no TS exists in the project, (d) shell-level conventions (env vars, exit codes, file paths). Consider that downstream consumers (Issue 1.2 config loading, Issues 2.1/3.2 adapter wrappers) will need to implement against this contract. What format gives the clearest contract while respecting the codebase's character?
- **Context to provide**: `install.sh` and `assemble.sh` as representative code, CLAUDE.md (technology preferences: lightweight, vanilla), the YAGNI constraint in the roadmap ("do not assume"), the "What NOT to Build" section (no TypeScript orchestrator)
- **Why this agent**: DevX specializes in developer-facing contracts, configuration formats, and the intersection of documentation and implementation. The format decision is foundational -- it determines whether the types are a specification document, a machine-readable schema, or executable code.

#### Consultation 3: Downstream Consumer Analysis

- **Agent**: ai-modeling-minion
- **Planning question**: The `DelegationRequest` and `DelegationResult` types will be consumed by: (1) the nefario orchestrator during Phase 4 execution routing, (2) the Codex CLI adapter (Issue 2.1), (3) the Aider adapter (Issue 3.2), (4) the result summarization service (Issue 3.1), and (5) the routing config loader (Issue 1.2). From the orchestrator and multi-agent architecture perspective: (a) What fields does the orchestrator actually need from `DelegationResult` to make routing and gating decisions? (b) Does the orchestrator need to distinguish between "task completed with wrong output" vs "adapter crashed"? (c) Should the prompt in `DelegationRequest` be the raw specialist prompt or should it include metadata about which phase/gate the task belongs to? (d) Is there any information the orchestrator currently extracts from TaskUpdate/SendMessage that would be lost if not captured in these types?
- **Context to provide**: `nefario/AGENT.md` (Phase 4 execution patterns, TaskList polling, SendMessage result collection), `docs/external-harness-integration.md` (current delegation model table, gap analysis), `skills/nefario/SKILL.md` (Phase 4 execution workflow)
- **Why this agent**: ai-modeling-minion owns multi-agent architecture and prompt engineering. The types define the contract between the orchestrator and its delegation targets -- this agent understands what information flows are critical for the orchestrator to function correctly.

### Cross-Cutting Checklist

- **Testing**: Exclude from planning. This issue produces types and contracts only, no executable code. test-minion will be included in Phase 3.5 architecture review to validate testability of the interface, but has nothing to contribute to planning a type definition.
- **Security**: Exclude from planning. The types define data shapes, not auth flows or input handling. No attack surface is created by a type definition. security-minion will review in Phase 3.5 for any concerns about field contents (e.g., should stderr be sanitized before logging).
- **Usability -- Strategy**: Include. Planning question for ux-strategy-minion: "The adapter interface is consumed by developers building new adapters (primary user) and by the nefario orchestrator (primary consumer). From a usability perspective: (a) Is the field naming self-explanatory to someone reading the spec without context? (b) Is the boundary between DelegationRequest (what the orchestrator provides) and DelegationResult (what the adapter returns) intuitive? (c) Are there any fields where the name suggests one thing but the roadmap description implies another?" Context: roadmap Issue 1.1, feasibility study gap analysis.
- **Usability -- Design**: Exclude. No user-facing interface is produced. This is a developer-facing type contract.
- **Documentation**: Include. Planning question for software-docs-minion: "The types will need to be documented so adapter authors can implement against them. Should the type definition document itself be the documentation (self-documenting format), or should there be a separate adapter authoring guide? Consider that only two adapters (Codex, Aider) exist in the roadmap -- a full guide is premature, but the type definitions need field-level documentation including semantics, optionality, and examples." Context: existing docs structure (`docs/` directory, `docs/external-harness-integration.md` as precedent for this work).
- **Observability**: Exclude. No runtime components are produced. The types may eventually carry fields relevant to observability (e.g., stderr, exit code), but that is a type design question handled by api-design-minion, not an observability architecture question.

### Notable Exclusions

- **mcp-minion**: The roadmap explicitly rules out MCP and A2A for this work ("CLI subprocess is the pragmatic choice for L3"). The adapter interface uses process invocation, not protocol integration.
- **data-minion**: No data persistence, no database modeling. The types are in-memory / in-document contracts, not stored entities.
- **iac-minion**: No infrastructure, CI/CD, or deployment concerns in a type definition issue. The adapters will invoke CLI tools as subprocesses but that is implementation (Issues 2.1, 3.2), not this issue.

### Anticipated Approval Gates

1. **Format decision gate** (MUST): The choice of how to express the types (Markdown spec vs. YAML schema vs. TypeScript reference types) is hard to reverse once downstream issues build on it, and has 2+ dependents (Issues 1.2, 1.3, 2.1, 3.2 all implement against this contract). This is the primary gate for this issue.

2. **Type definition gate** (MUST): The actual field definitions for `DelegationRequest` and `DelegationResult` lock in the contract that all adapters implement. Multiple valid designs exist (e.g., flat vs. nested exit status, string vs. enum model tier). High blast radius (every adapter depends on it), hard to reverse without cascading changes.

### Rationale

This issue is fundamentally an API design problem wrapped in a codebase format question. The three planning consultations cover:

- **api-design-minion**: The core domain -- what fields, what semantics, what optionality. This is the primary planning contribution.
- **devx-minion**: The format decision that the roadmap explicitly calls out ("document the decision; do not assume"). This is secondary but foundational -- it determines the deliverable format.
- **ai-modeling-minion**: The consumer perspective -- what the orchestrator needs from these types. This ensures the interface serves its actual consumers, not just its conceptual elegance.

The cross-cutting inclusions (ux-strategy, software-docs) provide lightweight review of naming clarity and documentation approach without adding full planning consultations.

### Scope

**What this achieves**: Defines the `DelegationRequest` and `DelegationResult` types as a documented contract that adapter authors (Issues 2.1, 3.2) implement and the orchestrator (Issue 4.1) consumes. Includes a documented decision on the expression format.

**In scope**:
- Field definitions for both types (name, semantics, optionality, examples)
- Format decision (how the types are expressed in the codebase)
- Field-level documentation
- Coverage for both Codex (structured JSON) and Aider (git-diff) use cases

**Out of scope**:
- Implementation of any adapter, config loader, or routing logic
- Routing configuration schema (Issue 1.2)
- Instruction translation logic (Issue 1.3)
- Any executable code, runtime behavior, or tooling
- Harness-specific fields (the types must remain harness-agnostic)

### External Skill Integration

No external skills detected relevant to this task. The project-local skills (`despicable-lab`, `despicable-statusline`) are for agent management and status display, not adapter interface design.
