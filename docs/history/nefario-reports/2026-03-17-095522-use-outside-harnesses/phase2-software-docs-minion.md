## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. Location and Naming

The report should live at `docs/external-harness-integration.md`. This name signals what the document is about (integrating external coding harnesses) without implying a conclusion (not "migration" or "replacement"). It sits alongside `docs/external-skills.md` as a natural sibling -- external skills covers how the framework discovers Claude Code skills; external harness integration covers how the framework could delegate to non-Claude-Code execution environments.

Add a row to the "Contributor / Architecture" table in `docs/architecture.md`:

| Document | Covers |
|----------|--------|
| [External Harness Integration](external-harness-integration.md) | Feasibility study: delegating execution to Cursor, Aider, Codex CLI, and other LLM coding tools alongside Claude Code subagents |

This anchors the document in the existing hub-and-spoke structure. Cross-link from `docs/external-skills.md` (related concept: external skills are Claude Code native, external harnesses are non-Claude-Code tools) and from `docs/orchestration.md` (Phase 4 execution currently assumes Claude Code subagents -- this doc explores relaxing that assumption).

#### 2. Document Structure

The report should follow a feasibility study structure with these sections:

```
# External Harness Integration

[< Back to Architecture Overview](architecture.md)

## Problem Statement
  - What limitation does single-harness lock-in create?
  - What would multi-harness delegation enable?

## Current Delegation Model
  - How nefario delegates today (subagent spawning, Task tool, scratch files)
  - What contracts exist between nefario and execution agents
  - Which parts are Claude-Code-specific vs. harness-agnostic

## Tool Inventory
  - Per-tool profile for each candidate (Cursor, Aider, Codex CLI, plus any others discovered during research)
  - For each: CLI interface, input/output format, automation support, context model, strengths/limitations

## Integration Surface Analysis
  - What nefario needs from an execution harness (input contract, output contract, status signaling, error handling)
  - How each tool maps (or fails to map) to those needs
  - Gap analysis: what is missing per tool

## Comparison Matrix
  - Summary matrix comparing all tools across the integration dimensions
  - Quick-reference format for decision-making

## Feasibility Assessment
  - What is achievable today vs. requires tool evolution
  - Effort estimates (ballpark, not sprint-level)
  - Which tools are closest to viable

## Recommendations
  - Recommended approach (adapter pattern, direct integration, hybrid, or "wait")
  - Sequencing if multiple tools are feasible
  - What would need to change in nefario's delegation model

## Out of Scope
  - Dimensions intentionally not covered in depth

## Open Questions
  - Unresolved items that need further investigation or user input
```

#### 3. Rationale for This Structure

**Problem Statement first, not tool inventory first.** The document should lead with "why are we investigating this?" before cataloging tools. This follows the project's existing pattern (see `compaction-strategy.md` which opens with "Problem: Context Overflow" before describing the solution). Readers need the problem framed before tool details are useful.

**Separate "Tool Inventory" and "Integration Surface Analysis."** The inventory is descriptive (what does each tool do?). The analysis is evaluative (how well does each tool fit our needs?). Mixing them makes both harder to read. The inventory can be read standalone by someone who just wants to know what tools exist. The analysis requires understanding nefario's delegation model first.

**Matrix AND per-tool sections.** The matrix provides quick comparison for decision-making. The per-tool sections in the inventory provide the depth needed to understand why a tool scores the way it does. This is not redundant -- they serve different reading modes (scanning vs. studying). The project's `agent-catalog.md` uses a similar pattern: summary table at top, per-agent detail below.

**"Out of Scope" section instead of inline disclaimers.** A dedicated section cleanly acknowledges what the research intentionally does not cover (security implications of executing code via third-party tools, UX implications of multi-harness workflows, cost analysis, licensing). This is better than scattering "this is out of scope" notes throughout the document, which interrupt flow. The section should briefly state why each dimension is excluded (e.g., "Security: deferred because the threat model depends on which integration pattern is chosen, which this report informs but does not decide") so readers understand the exclusion is intentional, not an oversight.

#### 4. Conventions to Follow

Based on the existing docs, the report should:

- **Open with a back-link**: `[< Back to Architecture Overview](architecture.md)` (every sub-document does this)
- **Use horizontal rules (`---`)** between major sections (consistent across `external-skills.md`, `compaction-strategy.md`, `orchestration.md`)
- **Include Mermaid diagrams** where they clarify flow -- specifically, a diagram showing the current delegation flow (nefario -> Task tool -> subagent) and a proposed flow showing where an external harness adapter would sit
- **Use tables for structured comparisons** (the project uses tables extensively in `decisions.md`, `orchestration.md`, `domain-adaptation.md`)
- **Maintain a decision-record tone**: state what was considered, what was assessed, and what the findings are -- not just conclusions. The reader should be able to evaluate the reasoning, not just trust the recommendation.

#### 5. Relationship to Existing Decision Records

If the research leads to a recommendation that the team adopts, that adoption should be recorded as a new entry in `docs/decisions.md` (following the existing numbered format). The research report itself is the backing analysis; the decision entry is the compact record of what was chosen and why. This mirrors how `RESEARCH.md` backs `AGENT.md` -- the research is comprehensive, the decision is dense and actionable.

The research report should NOT be structured as a decision record itself. It is a feasibility study that informs a future decision, not a decision. Conflating the two would force premature commitment or create an awkward "proposed" decision that is really just research.

### Proposed Tasks

#### Task 1: Define the integration surface contract

**What**: Before evaluating tools, formally document what nefario requires from an execution harness. Extract this from the current Claude Code subagent integration (Task tool invocation, prompt format, output parsing, error handling, scratch file interaction). This becomes the "Integration Surface Analysis" section's evaluation framework.

**Deliverables**: A checklist of capabilities nefario needs from any execution harness (input format, output format, status reporting, error signaling, file system access, context passing, result collection).

**Dependencies**: Requires reading `skills/nefario/SKILL.md` and `docs/orchestration.md` for the current delegation contract. The researcher (likely devx-minion or the primary researcher) needs to extract this, but software-docs-minion should validate the contract is documented clearly enough for tool-by-tool evaluation.

#### Task 2: Write the research report

**What**: Produce `docs/external-harness-integration.md` following the structure above. Research each candidate tool's CLI capabilities, automation support, and integration feasibility against the contract from Task 1.

**Deliverables**: Complete research report at `docs/external-harness-integration.md`.

**Dependencies**: Task 1 (integration surface contract). Web research for current tool capabilities.

#### Task 3: Add architecture.md entry and cross-links

**What**: Add the new document to the Sub-Documents table in `docs/architecture.md`. Add cross-references from `docs/external-skills.md` (in "Known Limitations" or a new "Related" section) and from `docs/orchestration.md` (in the Phase 4 section, noting the assumption of Claude Code subagents and linking to this feasibility study).

**Deliverables**: Updated `docs/architecture.md`, `docs/external-skills.md`, `docs/orchestration.md` with cross-links.

**Dependencies**: Task 2 (report must exist before linking to it).

#### Task 4: Review report structure and clarity

**What**: software-docs-minion reviews the completed report for structural coherence, progressive disclosure, appropriate depth, and consistency with project documentation conventions.

**Deliverables**: Review verdict (APPROVE/ADVISE/BLOCK) with specific findings.

**Dependencies**: Task 2 (report must be written before review).

### Risks and Concerns

1. **Scope creep into design document.** The deliverable is a feasibility study, not an implementation design. The report should stop at "here is what is feasible and what we recommend investigating further." If the researcher starts designing adapter interfaces or protocol bridges, the document will be premature and will age poorly as tool capabilities change. The "Recommendations" section should be directional, not prescriptive.

2. **Tool landscape volatility.** LLM coding tools are evolving rapidly. A tool inventory written today may be partially obsolete in weeks. The report should clearly state the research date and tool versions evaluated. Avoid assertions about permanent limitations -- frame gaps as "as of [date], tool X does not support Y" rather than "tool X cannot do Y."

3. **Comparison matrix becoming the only thing people read.** Matrices are convenient but lossy. If the matrix oversimplifies, readers may draw wrong conclusions. Mitigation: each matrix cell should be traceable to a specific finding in the per-tool section (row labels should match section headers). The matrix should include a footnote stating it is a summary, not a substitute for the per-tool analysis.

4. **Missing the "why not" dimension.** The research should explicitly address reasons NOT to support external harnesses (added complexity, maintenance burden, testing surface, consistency guarantees that Claude Code subagents provide). A feasibility study that only asks "can we?" without asking "should we?" is incomplete. This belongs in the Feasibility Assessment section.

5. **Cross-link staleness.** Adding cross-references from `orchestration.md` and `external-skills.md` creates maintenance coupling. If the research report is later superseded or substantially restructured, those links need updating. This is a minor risk but worth noting -- the project does not currently have automated link checking.

### Additional Agents Needed

None beyond what is likely already planned. The primary research is a devx-minion or gru-level task (tool landscape evaluation). software-docs-minion's role is structural guidance (this contribution) and post-write review (Task 4). The existing cross-cutting reviewers (lucy for intent alignment, margo for simplicity) will catch issues like scope creep or unnecessary complexity in the proposed integration patterns.

One consideration: if the research discovers that external harness integration would require changes to nefario's communication protocol or phase architecture, the **security-minion** should review the feasibility assessment section. Executing code through third-party CLI tools introduces a different trust boundary than Claude Code subagents. This does not need a full security review of the research report, but the "Feasibility Assessment" and "Recommendations" sections should be flagged for security-minion attention if they propose concrete integration patterns. This can be decided after the report is drafted rather than planned upfront.
