# UX Strategy Review: Enforce Serverless-First Across Agent System

**Verdict: ADVISE**

## Journey Coherence

The plan forms a coherent experience. The framing shift flows logically: the-plan.md establishes the spec (Task 1), AGENT.md files encode the behavior (Tasks 2, 3, 6), the CLAUDE.md template sets developer expectations (Task 4), and Decision 31 provides the audit trail (Task 5). Task 7 verifies consistency. No gaps in the chain.

One concern: the journey for a developer who encounters this system *after* these changes has two competing mental models present in the codebase. The margo Boring Technology Assessment section retains a "Topology-Neutral" heading (the plan explicitly preserves this). A developer reading margo's complexity budget ("default to managed/serverless column") and then hitting "Topology-Neutral Boring Technology Assessment" will experience a framing contradiction. The plan acknowledges this is intentional (boring tech assessment is orthogonal), but the *heading* creates a cognitive snag. This is not blocking -- the content beneath the heading clarifies the distinction -- but it is a rough seam in the journey.

## Cognitive Load

The blocking concern list (5 items) is the right size. It is enumerable, memorable, and avoids the "10-dimension evaluation matrix" anti-pattern that the original Step 0 had. This is a net reduction in cognitive load for the primary path (serverless) and a slight increase for the deviation path (must document blocking concern). This tradeoff is correct -- the deviation path *should* require more effort.

However, the same 5-item blocking concern list is repeated verbatim in at least 7 locations across the plan: iac-minion identity, iac-minion Step 0, iac-minion RESEARCH.md, margo complexity budget, margo review checklist, lucy compliance check, CLAUDE.md template, and Decision 31. This creates a maintenance burden: if the list ever changes, 7+ files need updating. The plan does not establish a single canonical location for the list. This is acceptable for a v1 (the list is unlikely to change frequently), but worth noting for future governance.

## Simplification Opportunities

**Task 7 (despicable-lab check) may be unnecessary.** Task 2 already hand-edits AGENT.md and bumps x-plan-version to 2.1. The plan itself acknowledges that "/despicable-lab --check should show iac-minion as current" after Task 2. If the hand-edits are correct, Task 7 is a no-op verification. This is low cost but worth flagging: it is a verification step, not a deliverable. If it runs and finds a mismatch, it will *overwrite Task 2's hand-edits*, which could cause rework. Ensure Task 7 runs in check-only mode first.

**Tasks 4 and 5 could theoretically be one task** (both assigned to lucy, both unblocked, both modifying docs/). But they touch different files with different purposes, so keeping them separate is defensible for clarity.

No other simplification opportunities identified. The task count (7) is appropriate for the scope.

## Jobs-to-Be-Done

Each task serves the original request:

| Task | Job | Justified? |
|------|-----|-----------|
| 1 | Establish spec authority for the shift | Yes -- the-plan.md is source of truth |
| 2 | Encode serverless-first in the primary infrastructure agent | Yes -- core deliverable |
| 3 | Arm the simplicity guardian to enforce the default | Yes -- without this, margo cannot flag deviations |
| 4 | Set developer expectations at the entry point | Yes -- CLAUDE.md is how developers interact with the system |
| 5 | Provide governance audit trail | Yes -- supersession of PR #123 needs documentation |
| 6 | Enable compliance enforcement in plan review | Yes -- lucy is the enforcement mechanism |
| 7 | Verify spec/agent consistency | Marginal -- see simplification note above |

No feature creep detected. The scope matches the original request precisely.

## Summary

The plan is well-structured, reduces cognitive load on the primary path, and serves the user's stated goals. The only advisory items are:

1. The "Topology-Neutral" heading in margo's Boring Technology Assessment creates a minor framing contradiction with the new serverless-first stance. Consider renaming in a follow-up (not in this task -- the plan correctly avoids scope creep here).
2. The 5-item blocking concern list is repeated in 7+ locations with no canonical source. Acceptable now, maintenance risk later.
3. Task 7 should run check-only first to avoid overwriting Task 2's hand-edits.

None of these rise to BLOCK level.
