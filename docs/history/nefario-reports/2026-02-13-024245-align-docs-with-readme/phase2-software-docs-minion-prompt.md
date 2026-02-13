You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Align docs/ files with new progressive-disclosure README. Fix 4 MUST findings and evaluate 2 SHOULD findings across decisions.md, orchestration.md, and architecture.md. All findings relate to stale reviewer counts ("6 ALWAYS reviewers" is now 5 after ux-strategy-minion moved to discretionary pool).

## Your Planning Question

Four decisions.md entries reference "6 ALWAYS reviewers" (now 5). Decisions 10, 12, 20 are historical ADR entries (need addendum notes, not rewrites). Decision 15 describes current behavior (needs direct update). What addendum format respects ADR immutability while correcting stale counts? Should addenda go inside the table or below it? How should they cross-reference the rework decision?

Key context:
- Decision 10 (line ~128): "Six ALWAYS reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo)"
- Decision 12 Consequences (line ~153): "6 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5)"
- Decision 15 Consequences (line ~191): "Every /nefario run incurs review cost (6 ALWAYS + 0-4 conditional reviewers)" — current behavior description, factually wrong
- Decision 20 Consequences (line ~262): "Phase 3.5 minimum review cost increases (6 ALWAYS reviewers)"
- The issue suggests addendum format: `> **Update ({date})**: The ALWAYS reviewer count was reduced from 6 to 5 when ux-strategy-minion was moved to the discretionary pool. See Decision N.`

The most recent relevant decision is the Phase 3.5 reviewer composition rework. There is no explicit "Decision 30" yet for this — the rework was done in nefario report 2026-02-12-135833-rework-phase-3-5-reviewer-composition.

## Context

Read docs/decisions.md for the full ADR log. The issue references a recent nefario report about the rework.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: software-docs-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-T1yIjX/align-docs-with-readme/phase2-software-docs-minion.md`
