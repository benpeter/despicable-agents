You are writing a research report: `docs/external-harness-integration.md`

**SCOPE GUARD: This is a research task. Document what exists and assess
feasibility. Do not produce implementation designs, architecture proposals,
or code. Where the research identifies that "an abstraction would be needed,"
describe what it would need to do, not how it should be structured.**

**PUBLISHABILITY GUARD: This report is published under Apache 2.0. It must
be vendor-neutral. Do not reflect any local technology biases. Do not
mention any specific company's internal usage. Tool names (Cursor, Aider,
Codex CLI) are fine -- they are public products.**

## What to produce

A feasibility study at `docs/external-harness-integration.md` that answers:
"Can the despicable-agents orchestrating session delegate tasks to external
LLM coding tools the same way it delegates to Claude Code subagents?"

The report must satisfy six success criteria:

1. **Inventory of LLM coding tools and their context-injection mechanisms**
2. **Analysis of how AGENT.md knowledge maps to each tool's instruction format**
3. **Feasibility assessment: can a delegation wrapper start an external tool, inject agent knowledge, and collect results**
4. **Gap analysis: what the current Agent tool provides vs. what a wrapper can replicate** -- this MUST be a structured comparison table, not narrative
5. **Clear recommendation: feasible now / feasible with constraints / not yet feasible** -- this is the core deliverable. Apply the verdict per-tool or per-tool-category. You own this recommendation explicitly.
6. **Research written to a new doc under docs/**

## Report structure

Follow this structure. Open with back-link to architecture.md. Use `---`
between major sections. Use tables over narrative wherever possible.
Mermaid diagrams are OPTIONAL -- include only where they genuinely clarify
flow that a table cannot.

ADVISORY INCORPORATED: Add an executive summary immediately after the
problem statement, before technical sections. The executive summary should
state per-tool or per-category verdicts upfront so the rest of the document
becomes optional depth rather than required reading.

ADVISORY INCORPORATED: Merge "Instruction Format Landscape" and "Protocol
Landscape" into adjacent or combined sections to reduce section count.
9 standalone sections is heavy for a feasibility study.

ADVISORY INCORPORATED: No word floor. Cap at 2500 words of prose + tables.
Let density handle itself. Prefer tables.

ADVISORY INCORPORATED: Technology radar rings in the report represent
delegation readiness (can this tool serve as a delegation target?), NOT
general tool quality or recommendation. Make this distinction explicit in
the report.

```
# External Harness Integration

[< Back to Architecture Overview](architecture.md)

## Problem Statement
What limitation does single-harness lock-in create?
What would multi-harness delegation enable?

## Executive Summary
Per-tool or per-category feasibility verdicts upfront.
The reader's core question answered in 3-5 sentences + a summary table.

## Current Delegation Model
How nefario delegates today (subagent spawning, Task tool, scratch files).
The five interface points of the current contract:
(a) prompt delivery, (b) context injection, (c) file access,
(d) result collection, (e) error handling.
Which parts are Claude-Code-specific vs. harness-agnostic.

## Tool Inventory
Per-tool profiles. For each tool: CLI headless interface, instruction
injection mechanism, result collection format, auto-approve flag,
maturity assessment. Focus depth on 6 feasible-today tools. Brief
coverage for watch/hold tools.

## Instruction and Protocol Landscape
How AGENT.md five-section template maps to each tool's instruction
format (AGENTS.md, .cursorrules/.mdc, CONVENTIONS.md, etc.).
Include a translation table: AGENT.md section x target format.
Document known lossy translations.
Three-layer protocol model: Process Invocation / Context Sharing /
Orchestration Protocol. Include protocol comparison table.

## Gap Analysis
STRUCTURED TABLE comparing what the current Claude Code Task tool
provides vs. what each candidate tool can replicate vs. what is
lost. Dimensions: prompt delivery, context injection, file access,
result collection, error handling, progress monitoring, model
routing, cost tracking, tool parity.

## Feasibility Assessment
Per-tool or per-category verdict using three tiers:
- Feasible now (build adapters with current tool capabilities)
- Feasible with constraints (what limitations exist)
- Not yet feasible (what would need to change)
Include "why not" dimension: reasons not to support external
harnesses (complexity, maintenance, consistency).

## Recommendations
Directional, not prescriptive. Sequencing if multiple tools are
feasible. What would need to change in nefario's delegation model
(at the concept level). Technology radar rings per tool as
DELEGATION TARGETS (not general tool quality).

## Out of Scope
Security threat model for external tool execution.
UX design for multi-harness workflows.
Cost comparison across providers.
Implementation of any wrapper or adapter.

## Open Questions
Unresolved items needing further investigation.
```

## Evidence from specialist planning

Use the following specialist evidence to inform your research. These are
planning-phase contributions, not execution outputs. Synthesize their
findings into the report structure above.

### From gru (technology radar)

Tool landscape with 12 tools assessed. Key findings:
- 6 tools feasible today: Claude Code (adopt), Codex CLI (trial), Aider
  (trial), Gemini CLI (trial), Copilot CLI (trial), Cline CLI (trial)
- 4 tools assess-ring: Continue, Goose, Kilo, Amp, Cursor CLI
- 1 tool hold: Windsurf (no headless CLI)
- Three convergence patterns: invocation (-p flag), instruction format
  (AGENTS.md under Linux Foundation), auto-approve flags
- Instruction format landscape table (9 formats, which tools read which)
- ACP protocol (Assess ring) -- agent-editor protocol, not orchestrator-agent
- Hype filter: individual tools mature, multi-tool orchestration is frontier
  (no public production signals)

Use gru's full tool capability table as the basis for the Tool Inventory
section. The table is in the scratch file at:
/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-gru.md

### From ai-modeling-minion (delegation model analysis)

Current subagent contract has five interface points: prompt delivery,
context injection, file access, result collection, error handling.
Three coordination patterns for external tools: CLI wrapper (Pattern A),
MCP tool use (Pattern B), A2A protocol (Pattern C). Instruction format
translation is the core complexity (AGENT.md -> AGENTS.md / .mdc / .aider).
Key constraints: shared filesystem assumption, no context window sharing
(favorable), tool subset differences, model routing translation, active
monitoring (CLI wait is actually simpler than current polling).

Full analysis at:
/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-ai-modeling-minion.md

### From mcp-minion (protocol analysis)

MCP is wrong for delegation layer (short tool calls, not multi-minute
coding tasks). MCP Tasks primitive is experimental, solves duration but
not delegation semantics. A2A is architecturally closer but zero adoption
in coding tools. Three-layer model:
- Layer 3: Orchestration Protocol (delegation, lifecycle, results)
- Layer 2: Context Sharing Protocol (MCP well-suited here)
- Layer 1: Process Invocation (subprocess, transport)
Result collection requirements: structured deliverable metadata,
completion signal, error propagation, progress streaming, git state handback.

Full analysis at:
/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-mcp-minion.md

### From devx-minion (developer experience)

Wrapper should be invisible to nefario (facade pattern). Config-driven
routing. Two instruction channels per tool: persistent (conventions file) +
per-task (message flag). Key DX dimensions to cover in report: invocation
ergonomics, configuration discoverability, first-run experience, error
experience, translation fidelity. YAGNI tension: zero-cost for users who
do not use external harnesses.

Full analysis at:
/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-devx-minion.md

### From lucy (governance review)

Two traceability gaps corrected: (1) feasibility recommendation must have
explicit owner (you own it), (2) gap analysis must be structured table.
Scope drift warnings: frame as research not design. Report must be
vendor-neutral and publishable. Convention requirements: back-link,
English, tables over narrative, date-stamp tool assessments.

### From software-docs-minion (document structure)

Report structure (used above). Location: docs/external-harness-integration.md.
Lead with problem not tools. Separate inventory (descriptive) from analysis
(evaluative). Matrix AND per-tool sections. Dedicated "Out of Scope" section.
Decision-record tone: show what was considered and assessed.

## Constraints

- The report must include a "Last assessed: 2026-03-17" note
- Frame tool limitations as "as of [date], tool X does not support Y"
  rather than permanent assertions
- Mermaid diagrams are OPTIONAL -- only if they clarify flow that tables cannot
- Cap at 2500 words of prose + tables. Prefer tables. No word floor.
- Do not produce: implementation designs, API contracts, code,
  configuration schemas, error message templates, or architecture
  proposals. Describe what would be needed, not how to build it.
- Do NOT modify any file other than docs/external-harness-integration.md

## Files to read for context

- docs/orchestration.md -- current delegation model (especially Phase 4)
- docs/external-skills.md -- related concept (external skills vs. external harnesses)
- docs/architecture.md -- where this doc fits in the hub-and-spoke structure
- docs/agent-anatomy.md -- AGENT.md structure
- nefario/AGENT.md -- the orchestrator agent (delegation table)
- The four scratch files referenced above for specialist evidence

When you finish, mark the task completed with TaskUpdate and send a message
to the team lead with file paths, change scope, and line counts.
