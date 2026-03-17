---
type: nefario-report
version: 3
date: "2026-03-17"
time: "09:55:22"
task: "Research feasibility of delegating specialist work to external LLM coding harnesses"
source-issue: 134
mode: full
agents-involved: [ai-modeling-minion, gru, devx-minion, mcp-minion, software-docs-minion, lucy, margo, security-minion, test-minion, ux-strategy-minion, code-review-minion]
task-count: 2
gate-count: 1
outcome: completed
docs-debt: none
---

# Research feasibility of delegating specialist work to external LLM coding harnesses

## Summary

Produced a feasibility study assessing whether the nefario orchestrator can delegate execution tasks to external LLM coding tools (Codex CLI, Aider, Gemini CLI, etc.) alongside Claude Code subagents. The research inventoried 12 tools, mapped AGENT.md knowledge to foreign instruction formats, and concluded that delegation is feasible now for Codex CLI and Aider, feasible with constraints for three more tools, and not yet feasible for six others. The report is published at [docs/external-harness-integration.md](../../external-harness-integration.md) with cross-links from three existing architecture docs.

## Original Prompt

> **Outcome**: The team has a thorough research report on whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents — so that the framework is not locked to a single harness and can route specialist work to the best available tool.
>
> **Success criteria**:
> - Inventory of LLM coding tools and their context-injection mechanisms
> - Analysis of how AGENT.md knowledge maps to each tool's instruction format
> - Feasibility assessment: can a delegation wrapper start an external tool, inject agent knowledge, and collect results
> - Gap analysis: what the current Agent tool provides vs. what a wrapper can replicate
> - Clear recommendation: feasible now / feasible with constraints / not yet feasible
> - Research written to a new doc under `docs/`

## Key Design Decisions

#### Single-Author Report

**Rationale**:
- One agent (ai-modeling-minion on opus) writes the entire report to avoid merge conflicts and maintain consistent voice
- All six specialist contributions provided as evidence in the prompt

**Alternatives Rejected**:
- Multi-agent section authoring: creates merge conflicts, inconsistent voice, coordination overhead for a single-file deliverable

#### Research Framing Over Design

**Rationale**:
- Lucy identified that specialist contributions leaned toward "how to build it" rather than "is it feasible"
- Explicit scope guards added to every task prompt
- Report describes what a wrapper would need to do, not how to structure it

**Alternatives Rejected**:
- Design document: out of scope per the issue; would commit to implementation decisions prematurely

#### Three-Layer Protocol Model

**Rationale**:
- mcp-minion's analysis that MCP is wrong for delegation (L3) but right for context sharing (L2) was adopted
- Avoids MCP advocacy while acknowledging its value at the right layer

**Alternatives Rejected**:
- MCP as the delegation layer: MCP is designed for short tool calls, not multi-minute coding tasks
- A2A as the delegation protocol: architecturally closest but zero adoption in coding tools

### Conflict Resolutions

Five conflicts resolved during synthesis: report filename (adopted software-docs-minion's `external-harness-integration.md`), scope framing (research not design per lucy), MCP role (context sharing only per mcp-minion), task granularity (2 tasks from 3-5 proposed), tool coverage depth (focus on 6 feasible-today tools).

## Phases

### Phase 1: Meta-Plan

Nefario identified 7 specialists for planning consultation. The user adjusted the team: removed security-minion and ux-strategy-minion, added lucy. Phase 1 was re-run with the revised 6-agent team (ai-modeling-minion, gru, devx-minion, mcp-minion, software-docs-minion, lucy). Four discovered project-local skills were assessed as not relevant to the research task.

### Phase 2: Specialist Planning

Six specialists contributed in parallel. Key findings: gru inventoried 12 tools with 6 feasible today; ai-modeling-minion identified 5 interface points in the current delegation contract; mcp-minion concluded MCP is wrong for delegation but right for context sharing; devx-minion outlined wrapper DX requirements; software-docs-minion proposed the report structure; lucy flagged two traceability gaps and four scope drift risks. No specialists recommended additional agents.

### Phase 3: Synthesis

Nefario consolidated six contributions into a 2-task execution plan with 1 approval gate. Five conflicts were resolved. Lucy's scope drift warnings were incorporated as explicit scope guards in all task prompts. The plan adopted mcp-minion's three-layer protocol model and gru's technology radar rings for delegation readiness assessment.

### Phase 3.5: Architecture Review

Six reviewers (5 mandatory + 1 discretionary software-docs-minion). Results: 2 APPROVE (security-minion, test-minion), 4 ADVISE (ux-strategy-minion, lucy, margo, software-docs-minion). Zero BLOCKs. Advisories incorporated: executive summary added (ux-strategy), sections merged and word floor dropped (margo), Mermaid made optional and radar ring clarification added (lucy), cross-link table precision improved (software-docs).

### Phase 4: Execution

Task 1 (ai-modeling-minion, opus): Wrote the complete feasibility study at `docs/external-harness-integration.md` (273 lines). Approved at gate. Task 2 (software-docs-minion, sonnet): Added cross-links to `docs/architecture.md`, `docs/external-skills.md`, and `docs/orchestration.md`. Both tasks completed successfully.

### Phase 5: Code Review

Three reviewers in parallel. code-review-minion: ADVISE (date qualifiers on benchmark scores, Claude Code baseline distinction in executive summary). lucy: ADVISE (Mermaid diagrams absent — noted as optional per Phase 3.5 advisory). margo: ADVISE (protocol section could be trimmer). Zero BLOCKs. All findings are non-blocking polish items.

### Phase 6: Test Execution

Skipped (docs-only changes, no executable output).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Phase 8a: 0 items identified. The deliverable IS documentation, and cross-links were included in execution. Phase 8b: Skipped (empty checklist).

<details>
<summary>Agent Contributions (6 planning, 6 architecture review, 3 code review)</summary>

### Planning

**ai-modeling-minion**: Analyzed current delegation contract (5 interface points), identified 3 coordination patterns (CLI wrapper, MCP, A2A), mapped instruction format translation complexity.
- Adopted: Five interface points framework, instruction format translation analysis, constraint identification
- Risks flagged: Result collection fidelity gap, frontmatter fields have no cross-tool equivalent

**gru**: Inventoried 12 LLM coding tools with technology radar rings for delegation readiness. Identified three convergence patterns (invocation, instruction format, auto-approve).
- Adopted: Full tool inventory with capability profiles, ring classifications, convergence patterns, AGENTS.md emergence
- Risks flagged: Tool landscape volatility, no public production signals for cross-harness orchestration

**devx-minion**: Outlined wrapper DX requirements: transparent facade, config-driven routing, two instruction channels per tool, error taxonomy.
- Adopted: DX dimensions for report coverage, YAGNI tension analysis, error experience considerations
- Risks flagged: Interactive-only tools breaking batch execution, configuration complexity creep

**mcp-minion**: Concluded MCP is wrong for delegation (L3) but valuable for context sharing (L2). Proposed three-layer protocol model.
- Adopted: Three-layer model (Process Invocation / Context Sharing / Orchestration Protocol), MCP positioning at L2 only
- Risks flagged: MCP advocacy bias, A2A zero adoption

**software-docs-minion**: Proposed report structure, filename, placement in docs/ hierarchy, and cross-linking strategy.
- Adopted: Full report structure, docs/external-harness-integration.md location, three cross-links, "Out of Scope" section approach
- Risks flagged: Report could become design doc without scope discipline

**lucy**: Identified two traceability gaps (feasibility recommendation ownership, gap analysis table requirement) and four scope drift risks.
- Adopted: Explicit ownership of recommendation by ai-modeling-minion, structured gap analysis table requirement, scope guards in all prompts
- Risks flagged: Planning questions lean design not research, security/UX sections without specialist depth

### Architecture Review

**security-minion**: APPROVE. No concerns — plan has no secrets, no command execution, publishability guard in place.

**test-minion**: APPROVE. Testing exclusion appropriate for docs-only deliverable. Nine verification steps sufficient.

**ux-strategy-minion**: ADVISE. SCOPE: Report information architecture. CHANGE: Add executive summary with verdicts before technical sections. WHY: Developers satisfice; placing conclusions after dense sections causes premature dropout.

**lucy**: ADVISE.
- SCOPE: Mermaid diagram constraint. CHANGE: Make adapter conceptual diagram optional. WHY: Mandatory adapter diagram risks crossing scope guard into design territory.
- SCOPE: Radar ring framing. CHANGE: Co-locate "delegation readiness, not tool quality" clarification with report structure. WHY: Currently only in Risks table, not in the prompt the agent sees.
- SCOPE: Task 2 scope guard. CHANGE: Replace copy-pasted research scope guard with cross-linking-appropriate guard. WHY: Task 2 is cross-linking, not research.

**margo**: ADVISE.
- SCOPE: Report section count. CHANGE: Merge Instruction Format + Protocol sections; drop 1500 word floor. WHY: 9 sections is heavy; word floor incentivizes padding.
- SCOPE: Mermaid diagrams. CHANGE: Make optional. WHY: Risk of crossing scope guard.

**software-docs-minion**: ADVISE.
- SCOPE: architecture.md cross-link. CHANGE: Target "Contributor / Architecture" sub-table specifically. WHY: architecture.md has two sub-tables; wrong placement breaks hierarchy.
- SCOPE: Row description format. CHANGE: Use terse noun-phrase matching existing pattern. WHY: Consistency with existing rows.

### Code Review

**code-review-minion**: ADVISE.
- SCOPE: Executive summary table. CHANGE: Distinguish Claude Code as baseline vs. new candidate. WHY: Conflates native target with delegation candidates.
- SCOPE: Tool inventory maturity cells. CHANGE: Add date qualifiers to SWE-bench scores. WHY: Benchmark scores are point-in-time; rest of doc uses date framing.

**lucy**: ADVISE. SCOPE: Mermaid diagrams. CHANGE: Note absence. WHY: Synthesis required two diagrams. Non-blocking because Phase 3.5 advisory made them optional.

**margo**: ADVISE. SCOPE: Protocol Landscape section (lines 94-158). CHANGE: Could be trimmed to ~10 lines. WHY: Longest section, drifts toward architecture analysis. Non-blocking — feasibility question already answered by Tool Inventory + Gap Analysis.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Write research report | ai-modeling-minion | completed |
| 2 | Add cross-links to existing docs | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [docs/external-harness-integration.md](../../external-harness-integration.md) | created | Feasibility study: 12 tools inventoried, gap analysis table, per-tool verdicts, sequencing recommendation |
| [docs/architecture.md](../../architecture.md) | modified | Added row to Contributor/Architecture sub-documents table |
| [docs/external-skills.md](../../external-skills.md) | modified | Added See Also section distinguishing skills from harnesses |
| [docs/orchestration.md](../../orchestration.md) | modified | Added blockquote cross-link after Phase 4 description |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Write research report | ai-modeling-minion | HIGH | approved | 1 |

## Decisions

#### Write research report

**Decision**: Accept the feasibility study as the primary deliverable. Per-tool verdicts: Codex CLI and Aider feasible now, Gemini CLI/Cline CLI/Copilot CLI feasible with constraints, 6 others not yet feasible, Windsurf not feasible.
**Rationale**: All six success criteria addressed. Gap analysis is a structured table. Radar rings represent delegation readiness. Executive summary provides upfront verdicts. Vendor-neutral and date-stamped.
**Rejected**: Narrower scope (fewer tools): would not satisfy the inventory success criterion. Design document: out of scope per the issue.
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE, 0 BLOCK (date qualifiers, protocol section length, Mermaid absence — all non-blocking) |
| Test Execution | Skipped (docs-only changes) |
| Deployment | Skipped (not requested) |
| Documentation | Phase 8a: 0 items. Phase 8b: skipped (empty checklist) |

<details>
<summary>Session resources (1 skill)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 2 events

</details>

## Working Files

<details>
<summary>Working files (39 files)</summary>

Companion directory: [2026-03-17-095522-use-outside-harnesses/](./2026-03-17-095522-use-outside-harnesses/)

- [Original Prompt](./2026-03-17-095522-use-outside-harnesses/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-03-17-095522-use-outside-harnesses/phase1-metaplan.md)
- [Phase 1: Meta-plan re-run](./2026-03-17-095522-use-outside-harnesses/phase1-metaplan-rerun.md)
- [Phase 2: ai-modeling-minion](./2026-03-17-095522-use-outside-harnesses/phase2-ai-modeling-minion.md)
- [Phase 2: gru](./2026-03-17-095522-use-outside-harnesses/phase2-gru.md)
- [Phase 2: devx-minion](./2026-03-17-095522-use-outside-harnesses/phase2-devx-minion.md)
- [Phase 2: mcp-minion](./2026-03-17-095522-use-outside-harnesses/phase2-mcp-minion.md)
- [Phase 2: software-docs-minion](./2026-03-17-095522-use-outside-harnesses/phase2-software-docs-minion.md)
- [Phase 2: lucy](./2026-03-17-095522-use-outside-harnesses/phase2-lucy.md)
- [Phase 3: Synthesis](./2026-03-17-095522-use-outside-harnesses/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-03-17-095522-use-outside-harnesses/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-03-17-095522-use-outside-harnesses/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-03-17-095522-use-outside-harnesses/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-03-17-095522-use-outside-harnesses/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-03-17-095522-use-outside-harnesses/phase3.5-margo.md)
- [Phase 3.5: software-docs-minion](./2026-03-17-095522-use-outside-harnesses/phase3.5-software-docs-minion.md)
- [Phase 5: code-review-minion](./2026-03-17-095522-use-outside-harnesses/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-03-17-095522-use-outside-harnesses/phase5-lucy.md)
- [Phase 5: margo](./2026-03-17-095522-use-outside-harnesses/phase5-margo.md)
- [Phase 8: Checklist](./2026-03-17-095522-use-outside-harnesses/phase8-checklist.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-03-17-095522-use-outside-harnesses/phase1-metaplan-prompt.md)
- [Phase 1: Meta-plan re-run prompt](./2026-03-17-095522-use-outside-harnesses/phase1-metaplan-rerun-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: gru prompt](./2026-03-17-095522-use-outside-harnesses/phase2-gru-prompt.md)
- [Phase 2: devx-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase2-devx-minion-prompt.md)
- [Phase 2: mcp-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase2-mcp-minion-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase2-software-docs-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-03-17-095522-use-outside-harnesses/phase2-lucy-prompt.md)
- [Phase 3: Synthesis prompt](./2026-03-17-095522-use-outside-harnesses/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-03-17-095522-use-outside-harnesses/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-03-17-095522-use-outside-harnesses/phase3.5-margo-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase3.5-software-docs-minion-prompt.md)
- [Phase 4: ai-modeling-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase4-ai-modeling-minion-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-03-17-095522-use-outside-harnesses/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-03-17-095522-use-outside-harnesses/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-03-17-095522-use-outside-harnesses/phase5-margo-prompt.md)

</details>
