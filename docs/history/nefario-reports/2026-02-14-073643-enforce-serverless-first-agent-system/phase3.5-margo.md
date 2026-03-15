# Margo Review: enforce-serverless-first

## Verdict: ADVISE

## Issues

### 1. Task 7 is redundant with Task 2

Task 2 hand-edits iac-minion's AGENT.md to match the 2.1 spec and bumps
`x-plan-version` to 2.1. Task 7 then runs `/despicable-lab --check` which, by
the plan's own admission, "should show iac-minion as current" because Task 2
already did the work. The plan even acknowledges this: "If the hand-edits in
Task 2 are already consistent with the spec, /despicable-lab may determine no
rebuild is necessary."

This is a verification step masquerading as a task. A single line in the
verification steps section (`/despicable-lab --check` shows iac-minion as
current -- already listed as verification step #10) covers this. Eliminate Task 7
as a delegated task and run the check inline during verification.

**Cost**: One additional opus agent invocation for a no-op confirmation.

### 2. Task 3 (margo AGENT.md) has 5 changes, not "three surgical modifications"

The prompt says "three surgical modifications -- no new sections." It then lists
five changes: (1) burden-of-proof paragraph, (2) framing rule #1 rewrite,
(3) framing rule #3 rewrite, (4) new checklist step with renumbering,
(5) frontmatter update. The framing is misleading but the scope itself is
reasonable. Just fix the description to match reality.

### 3. Task 2 + Task 7 ordering creates a write-then-verify-then-possibly-overwrite chain

Task 2 hand-edits AGENT.md. Task 7 regenerates from spec. If /despicable-lab
produces output that differs from the hand-edits (which is possible -- the
generator may format tables differently, wrap lines differently, etc.), Task 7
would overwrite Task 2's work. The plan does not address what happens if the
check fails or the rebuild differs from the hand-edits.

**Recommendation**: Either (a) drop Task 2 entirely and let Task 7 do the
rebuild from spec (simpler, one source of truth), or (b) drop Task 7 and trust
the hand-edits (which is what the plan actually expects to happen). Having both
is belt-and-suspenders complexity.

### 4. Seven tasks for what is essentially a find-and-replace preference change

The user request boils down to: change "topology-neutral" to "serverless-first"
across 6-7 files, add a decision log entry, and update a template. The 7-task
decomposition with 4 execution batches, an approval gate, and a deferred skill
invocation is disproportionate to the change.

A simpler decomposition:
- **Task A**: Update the-plan.md (approval gate) -- same as Task 1
- **Task B** (after gate): Update all agent files (iac-minion AGENT.md +
  RESEARCH.md, margo AGENT.md, lucy AGENT.md) -- merge Tasks 2, 3, 6
- **Task C** (parallel with A): Update docs (CLAUDE.md template, Decision 31)
  -- merge Tasks 4, 5

This is 3 tasks instead of 7, 2 batches instead of 4. Task 7 becomes a
verification step. The content of each change is identical -- just fewer
orchestration boundaries.

That said, the 7-task version is not *wrong*, just heavier than necessary. The
individual prompts are well-scoped and the changes themselves are correct. This
is an efficiency concern, not a correctness concern.

## What is fine

- The blocking concern list (5 items) is well-scoped. The decision to exclude
  "storage access patterns" is correct -- that is a data architecture decision.
- Edge-first as recommendation rather than mandatory gate is the right call.
- Decision 31 with explicit supersession is necessary and well-formatted.
- The approval gate on the-plan.md is required by project rules.
- The framing throughout is "strong default with escape hatches," not dogma.
  This preserves agent usability for non-serverless work.
- The Boring Technology Assessment is correctly left untouched.

## Summary

The plan achieves the goal correctly. The over-engineering is in the
orchestration (7 tasks / 4 batches for a preference change that touches 7
files), not in the substance. Recommend merging tasks to reduce to 3-4 tasks
and eliminating the redundant Task 7. Not blocking because the extra tasks
add latency and cost, not risk.
