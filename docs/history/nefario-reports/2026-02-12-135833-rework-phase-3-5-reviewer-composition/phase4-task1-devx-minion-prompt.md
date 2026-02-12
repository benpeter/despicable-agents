You are updating the nefario agent specification to implement a new Phase 3.5
reviewer composition model: 5 mandatory ("ALWAYS") reviewers and 6 discretionary
reviewers selected by nefario and approved by the user before spawning.

## What to Do

Edit `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md`. Make these changes:

### A. Review Triggering Rules table (lines ~559-570)

Replace the current 6-ALWAYS + 4-conditional table with:

**Mandatory reviewers (ALWAYS):**

| Reviewer | Trigger | Rationale |
|----------|---------|-----------|
| **security-minion** | ALWAYS | Security violations in a plan are invisible until exploited. Mandatory review is the only reliable mitigation. |
| **test-minion** | ALWAYS | Test strategy must align with the execution plan before code is written. Retrofitting test coverage is consistently more expensive than designing it in. |
| **software-docs-minion** | ALWAYS | Produces documentation impact checklist consumed by Phase 8. Role is scoped to impact assessment, not full documentation review. |
| **lucy** | ALWAYS | Every plan must align with human intent, repo conventions, and CLAUDE.md compliance. Intent drift is the #1 failure mode in multi-phase orchestration. |
| **margo** | ALWAYS | Every plan must pass YAGNI/KISS/simplicity enforcement. Can BLOCK on: unnecessary complexity, over-engineering, scope creep. |

**Discretionary reviewers (selected by nefario, approved by user):**

| Reviewer | Domain Signal | Rationale |
|----------|--------------|-----------|
| **ux-strategy-minion** | Plan includes user-facing workflow changes, journey modifications, or cognitive load implications | Journey coherence and simplification review |
| **ux-design-minion** | Plan includes tasks producing UI components, visual layouts, or interaction patterns | Accessibility patterns and visual hierarchy review |
| **accessibility-minion** | Plan includes tasks producing web-facing HTML/UI that end users interact with | WCAG compliance must be reviewed before UI code is written |
| **sitespeed-minion** | Plan includes tasks producing web-facing runtime code (pages, APIs serving browsers, assets) | Performance budgets must be established before implementation |
| **observability-minion** | Plan includes 2+ tasks producing runtime components that need coordinated logging/metrics/tracing | Coordinated observability strategy across services |
| **user-docs-minion** | Plan includes tasks whose output changes what end users see, do, or need to learn | User-facing documentation impact needs early identification |

Add a paragraph after the discretionary table:

> During synthesis, nefario evaluates each discretionary reviewer against the
> delegation plan using a forced yes/no enumeration with one-line rationale per
> reviewer. The "Domain Signal" column provides heuristic anchors -- nefario
> matches plan content against these signals rather than applying rigid
> conditionals. Discretionary picks are presented to the user for approval
> before reviewers are spawned (see SKILL.md Phase 3.5 for the approval gate
> interaction).

Keep the existing paragraph about model selection:
"All reviewers run on **sonnet** except lucy and margo, which run on **opus**
(governance judgment requires deep reasoning)."

### B. Synthesis output template -- Architecture Review Agents field (line ~511)

Replace:
```
### Architecture Review Agents
- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: <list conditional reviewers triggered and why, or state "none triggered">
```

With:
```
### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**: <for each discretionary reviewer selected, list: reviewer name + one-line rationale grounded in specific plan content; reference task numbers>
- **Not selected**: <remaining discretionary pool members not selected, comma-separated>
```

### C. Cross-cutting checklist clarification (after line ~272)

After the existing note about lucy and margo, add:

> _This checklist governs agent inclusion in planning and execution phases (1-4). Phase 3.5 architecture review has its own triggering rules (see Architecture Review section) which may differ -- an agent can be ALWAYS in the checklist but discretionary in Phase 3.5 review._

### D. Verdict Format -- software-docs-minion exception

In the Verdict Format section (after the BLOCK format block, around line 612),
add a note:

> **software-docs-minion exception**: In Phase 3.5, software-docs-minion
> produces a documentation impact checklist (written to scratch) instead of a
> standard domain review. Its verdict reflects whether the plan has adequate
> documentation coverage -- ADVISE for gaps, APPROVE when coverage is
> sufficient. software-docs-minion should not BLOCK for documentation concerns;
> gaps are addressed through the checklist in Phase 8.

### E. Advisory: Annotate "NEVER skipped" line (around line 552)

The existing line says "Phase 3.5 is NEVER skipped." This will contradict the
new "Skip review" gate option. Find this line and annotate it to clarify:

Change from something like:
"Phase 3.5 is NEVER skipped"
To:
"Phase 3.5 is never skipped autonomously by nefario. The user may skip Phase 3.5
via the Reviewer Approval Gate (see SKILL.md)."

### F. Advisory: Add phase3.5-docs-checklist.md to Scratch Directory Structure

Find the Scratch Directory Structure section (if it exists in AGENT.md). If it
lists scratch files, add `phase3.5-docs-checklist.md` to the listing as:
```
  phase3.5-docs-checklist.md          # documentation impact checklist (Phase 8 input)
```
Note: The Scratch Directory Structure may be in SKILL.md instead. If you cannot
find it in AGENT.md, skip this sub-task -- it will be handled in Task 2.

## What NOT to Do

- Do NOT modify the delegation table (lines 96-187)
- Do NOT modify post-execution phases (lines 672-688)
- Do NOT modify the cross-cutting checklist entries themselves -- only add the
  clarifying note after the existing note about lucy/margo
- Do NOT change model selection defaults (the "use opus" is a session directive,
  not a permanent spec change)
- Do NOT touch any other agent's AGENT.md files

## Context

- This implements the ALWAYS/discretionary split from GitHub issue #49
- ux-strategy-minion moves from ALWAYS to discretionary (not a demotion of
  planning importance -- the cross-cutting checklist still says ALWAYS for
  planning inclusion; only Phase 3.5 review changes)
- user-docs-minion is NEW to Phase 3.5 (added to discretionary pool; was not
  previously a Phase 3.5 reviewer at all)
- software-docs-minion remains ALWAYS but its role narrows to documentation
  impact checklist (detailed prompt is in Task 2)

## Deliverables

Updated `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md` with:
1. New ALWAYS/discretionary reviewer tables
2. Updated synthesis output template
3. Cross-cutting checklist clarification sentence
4. software-docs-minion verdict exception note
5. "NEVER skipped" annotation (advisory)
6. Scratch directory structure update (advisory, if applicable)

## Success Criteria

- ALWAYS roster is exactly: security-minion, test-minion, software-docs-minion, lucy, margo
- Discretionary pool is exactly: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion
- Synthesis template uses "Mandatory" / "Discretionary picks" / "Not selected" terminology
- Cross-cutting checklist has clarifying sentence separating it from Phase 3.5 triggering
- No unrelated sections modified

When you finish your task, mark it completed with TaskUpdate and send a message
to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
