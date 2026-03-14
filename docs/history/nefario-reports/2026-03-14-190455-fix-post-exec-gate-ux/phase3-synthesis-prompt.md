MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

Fix post-exec gate UX: replace inverted skip-only multiSelect with explicit 'Run all' single-select

**Outcome**: After approving a task gate, the user sees an explicit "Run all phases" option as the default choice, eliminating the current anti-pattern where the happy path (run everything) requires selecting nothing and triggering a Claude Code "you haven't answered all questions" warning.

**Success criteria**:
- "Run all phases" is the first, explicitly listed option marked as recommended
- Confirming without changing selection runs all phases (no empty-selection semantics)
- No Claude Code "unanswered question" warning on the default path
- Freeform flag overrides (--skip-docs, --skip-tests, --skip-review, --skip-post) still work
- Existing skip combinations remain available as named options

**Scope**:
- In: SKILL.md post-exec AskUserQuestion block (lines ~1627-1648), option definitions, question text, and downstream consumption logic (lines ~1723-1736)
- Out: Approval gate structure (Phase 4 gates themselves), other AskUserQuestion instances, nefario AGENT.md

**Constraints**:
- Must use AskUserQuestion with multiSelect: false (single-select) to avoid empty-selection UX issues
- AskUserQuestion supports 2-4 options max
- Preserve freeform text override behavior for flag-style skips

## Specialist Contributions

Read the following scratch file for the full specialist contribution:
/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-JXtYwL/fix-post-exec-gate-ux/phase2-ux-strategy-minion.md

## Key consensus across specialists:

## Summary: ux-strategy-minion
Phase: planning
Recommendation: Replace multiSelect with 3-option single-select: "Run all" (recommended), "Skip docs only" (most common skip), "Skip all post-exec" (power-user fast path). Remaining combos live behind freeform flags.
Tasks: 1 -- Update SKILL.md post-exec AskUserQuestion block and downstream consumption logic
Risks: none critical
Conflicts: none

## External Skills Context
No external skills detected.

## Instructions
1. Review the specialist contribution
2. Create the final execution plan in structured format
3. This is a single-file change to SKILL.md. One task is sufficient.
4. Ensure the task has a complete, self-contained prompt with the exact text changes needed
5. The task agent should be devx-minion (CLI/prompt interaction expertise) or a general-purpose agent
6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-JXtYwL/fix-post-exec-gate-ux/phase3-synthesis.md`
