# Phase 2 Contribution: software-docs-minion

## Planning Question Addressed

Two documentation deliverables need structure advice: (1) report iteration structure, (2) roadmap document format and location.

---

## Deliverable 1: Report Iteration Structure

### Current Document Anatomy

The report has a clean seven-section structure: Problem Statement, Executive Summary, Current Delegation Model, Tool Inventory, Instruction and Protocol Landscape, Gap Analysis, Feasibility Assessment, Recommendations, Out of Scope, Open Questions. Total: ~273 lines. This is a well-proportioned feasibility study.

### Impact of the Five Changes

| Feedback Item | Type of Change | Affected Sections |
|---------------|---------------|-------------------|
| 1. Configuration gap / routing DX | **Additive** -- new section needed | None existing; needs new section between Recommendations and Out of Scope |
| 2. Model specification mapping | **Additive** -- new content | Could extend Instruction and Protocol Landscape OR create subsection under new routing config section |
| 3. Worktree isolation | **Rewrite** -- resolve Open Question 2 | Move answer into Gap Analysis (concurrency row) or Current Delegation Model; remove from Open Questions |
| 4. Quality parity (user's responsibility) | **Rewrite** -- resolve Open Question 3 | Short statement in Recommendations; remove from Open Questions |
| 5. Aider result collection | **Rewrite** -- resolve Open Question 5 | State answer in Feasibility Assessment (Aider subsection) and Gap Analysis (result collection row); remove from Open Questions |

### Restructuring Recommendations

**No major restructuring needed.** The changes are either additive (items 1-2) or resolution-in-place (items 3-5). The existing section flow remains sound.

**One new section is required**: A "Routing and Configuration" section (or "Delegation Configuration") should be added between "Recommendations" and "Out of Scope." This is the right location because:
- It follows the feasibility analysis (reader now knows what tools are viable)
- It follows the recommendations (reader knows the sequencing)
- It precedes Out of Scope (configuration DX design details that go beyond this doc can be explicitly scoped out)
- It is clearly a forward-looking "how would this work" section, not a retrospective assessment

This section should cover:
1. Configuration surface -- where routing rules live, what format, what granularity
2. Model specification -- how `model:` frontmatter maps to external tool model flags
3. Defaults -- Claude Code for everything unless overridden (zero-config baseline)

**Model specification** should live within this new section, not in the existing Instruction and Protocol Landscape. Rationale: model specification is part of the routing/configuration concern, not the instruction format concern. The Instruction Format Translation table already notes that `model` frontmatter has "No equivalent" in other formats -- the new section explains how the adapter resolves this gap.

### Open Questions Section

**Rename to "Open Questions" and restructure.** Three of five items get resolved:

| Current Item | Resolution | New State |
|-------------|-----------|-----------|
| 1. Instruction isolation | Unresolved | Stays as open question |
| 2. Parallel delegation / worktree | Resolved by user feedback (item 3) | Move answer to Gap Analysis or new Routing section; remove from Open Questions |
| 3. Model quality parity | Resolved by user feedback (item 4) | One-line resolution in Recommendations; remove from Open Questions |
| 4. AGENTS.md spec stability | Unresolved | Stays as open question |
| 5. Aider result collection | Resolved by user feedback (item 5) | Move answer to Feasibility Assessment; remove from Open Questions |

After resolution, two questions remain (instruction isolation, AGENTS.md stability). This is fine -- keep the section named "Open Questions" with just two items. Two remaining questions is appropriate for a feasibility study; it signals the document is nearing completion without claiming false certainty. Do not rename the section.

### Line Budget

The report is currently ~273 lines. The new Routing and Configuration section should target 40-60 lines. Resolved open questions shrink by ~15 lines but their content moves inline (net neutral). Expected final size: ~320-330 lines. This is acceptable for the document's scope.

### Execution Guidance

When integrating changes, preserve the existing horizontal rule (`---`) section delimiter pattern. Each major section is separated by `---`. The new Routing and Configuration section should follow this convention.

Do not touch the Executive Summary table or the Technology Radar table for these changes -- they remain accurate. The Executive Summary's "Key reason not to build it yet" paragraph also remains valid; the routing configuration section describes the *design* of configuration, not a commitment to build it.

---

## Deliverable 2: Roadmap Document Structure

### Format Recommendation: Milestone/Issue Hierarchy

**Use a two-level structure: Milestones containing Issues.** Not a flat list, not a deep epic/story/subtask tree.

Rationale:
- **Flat list with dependency annotations** becomes unreadable past 8-10 issues. Dependencies expressed as "depends on #3, #7" require mental graph traversal.
- **Epic/story/subtask** is over-structured for a roadmap that will be consumed by a single orchestration team, not a project management tool.
- **Milestones with issues** maps directly to GitHub's native milestone+issue model, making future issue creation mechanical (create milestone, then create issues tagged to it). It also provides natural sequencing: milestones are ordered, issues within a milestone can be parallelized.

### Proposed Structure

```
# External Harness Integration Roadmap

## How to Use This Document
[Brief description of milestone/issue structure, how to create GitHub issues from it]

## Milestone 1: Adapter Foundation
### Issue 1.1: [title]
### Issue 1.2: [title]
...

## Milestone 2: Codex CLI Adapter
### Issue 2.1: [title]
### Issue 2.2: [title]
...

## Milestone N: ...

## Future Milestones (Aider, Gemini CLI)
[Brief placeholder descriptions, not full issues -- extensibility without premature detail]
```

### Issue Format

Each issue should follow this template within the roadmap document:

```markdown
### Issue N.M: [Short Title]

**Goal**: One sentence stating what this issue delivers.

**Scope**:
- Bullet list of concrete deliverables (files, schemas, tests)

**Depends on**: Issue N.X (or "None")

**Acceptance criteria**:
- Bullet list of verifiable outcomes

**Notes**: Optional context, constraints, or design hints
```

This format translates directly to a GitHub issue body. The title becomes the issue title. The content becomes the issue description. The milestone tag comes from the parent heading. Dependencies become issue references once created.

**Do not include estimated effort, story points, or assignees.** These are planning artifacts that belong in the issue tracker, not a roadmap document. The document defines *what* and *sequence*, not *who* and *when*.

### Extensibility for Future Tools

The milestone/issue structure naturally extends:

- **Codex-specific milestones** (Milestones 1-N) ship first and establish the adapter pattern
- **A "Future Milestones" section** at the end sketches Aider and Gemini CLI milestones at headline level (milestone title + 2-3 sentence scope) without full issue decomposition
- When it is time to build the Aider adapter, a new section with full issues gets added below the existing Codex milestones -- the document grows downward without restructuring existing content
- **Milestone 1 (Adapter Foundation)** should explicitly contain the cross-tool abstractions (adapter interface, configuration schema, result normalization) so that subsequent tool-specific milestones only need to implement against an established interface

This mirrors how the existing docs/ directory works: architecture.md is a hub that grows by adding sub-document links, not by restructuring existing content.

### File Location

**Recommended: `docs/external-harness-roadmap.md`**

Rationale:
- Lives alongside its companion document `docs/external-harness-integration.md` (the feasibility study)
- The `external-harness-` prefix creates a natural grouping when scanning the docs/ directory
- No subdirectory needed -- a single roadmap document does not warrant `docs/roadmaps/`
- If the roadmap later needs to be split (unlikely for a single integration path), it can become `docs/roadmaps/` at that point

**Do not use**: `docs/roadmaps/codex-integration.md` -- this over-scopes the directory structure (creating `roadmaps/` for one file) and under-scopes the document (naming it "codex" when it covers the full multi-tool path, Codex-first).

**Add to architecture.md**: The new document should be linked in the "Contributor / Architecture" sub-documents table in architecture.md, next to the existing external-harness-integration.md entry:

```markdown
| [External Harness Roadmap](external-harness-roadmap.md) | Implementation roadmap: Codex CLI adapter, cross-tool abstractions, future tool milestones |
```

### Cross-Reference Between Documents

The roadmap document should open with a back-link to the feasibility study:

```markdown
[< Back to Architecture Overview](architecture.md) | [Feasibility Study](external-harness-integration.md)
```

The feasibility study (external-harness-integration.md) should add a forward reference in its Recommendations section:

```markdown
For implementation sequencing, see [External Harness Roadmap](external-harness-roadmap.md).
```

This creates a bidirectional link without duplicating content.

---

## Risks and Dependencies

### Risks

1. **Report bloat from configuration section**: The new Routing and Configuration section could expand beyond 60 lines if it tries to specify the configuration format in detail. The section should describe the *design space* and *recommended approach*, not a full schema definition. Schema details belong in the roadmap (as a specific issue deliverable).

2. **Roadmap document staleness**: Roadmaps decay faster than reference documentation. Once GitHub issues are created from the roadmap, the document becomes a historical record, not a living plan. The document should state this in its "How to Use" preamble -- "This document defines the initial roadmap. Once issues are created, track progress in the GitHub milestone."

3. **Premature detail in future tool milestones**: The extensibility section for Aider and Gemini CLI should be deliberately thin. Full issue decomposition for tools the team has not committed to building creates maintenance burden and false confidence. Two to three sentences per future milestone is sufficient.

### Dependencies

- The roadmap's milestone structure depends on inputs from other planning consultations:
  - **ai-modeling-minion** defines the model mapping approach, which determines whether there is a dedicated "model routing" issue or whether it is folded into configuration
  - **devx-minion** defines the configuration format, which determines the scope of the configuration-related issues
  - **mcp-minion** defines the adapter interface contract, which determines how Milestone 1 (Adapter Foundation) is decomposed
- The report iteration has no dependencies on other consultations -- all five feedback items have clear user directives that can be executed independently

### Requirements for Execution

- The executing agent must read the current docs/external-harness-integration.md in full before editing (Write tool requirement)
- The roadmap document is a new file -- use Write tool, not Edit
- After creating the roadmap, update docs/architecture.md to add the new document to the sub-documents table
- Both documents need `*Last assessed: 2026-03-17*` date stamps
