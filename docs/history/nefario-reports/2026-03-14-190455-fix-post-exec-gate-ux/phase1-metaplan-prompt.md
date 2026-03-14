MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
<github-issue>
Fix post-exec gate UX: replace inverted skip-only multiSelect with explicit 'Run all' single-select

**Outcome**: After approving a task gate, the user sees an explicit "Run all phases" option as the default choice, eliminating the current anti-pattern where the happy path (run everything) requires selecting nothing and triggering a Claude Code "you haven't answered all questions" warning. This makes the most common action visible and warning-free.

**Success criteria**:
- "Run all phases" is the first, explicitly listed option marked as recommended
- Confirming without changing selection runs all phases (no empty-selection semantics)
- No Claude Code "unanswered question" warning on the default path
- Freeform flag overrides (--skip-docs, --skip-tests, --skip-review, --skip-post) still work
- Existing skip combinations remain available as named options

**Scope**:
- In: SKILL.md post-exec AskUserQuestion block (lines ~1627-1636), option definitions, question text
- Out: Approval gate structure (Phase 4 gates themselves), other AskUserQuestion instances, nefario AGENT.md

**Constraints**:
- Must use AskUserQuestion with multiSelect: false (single-select) to avoid empty-selection UX issues
- Preserve freeform text override behavior for flag-style skips
</github-issue>

## Working Directory
/Users/ben/github/benpeter/despicable-agents

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

Discovered skills:
- despicable-lab: Nefario's Laboratory -- rebuild agents whose specs have changed (NOT relevant)
- despicable-statusline: Configure Claude Code status line (NOT relevant)

No external skills are relevant to this task.

## Instructions
1. Read relevant files to understand the codebase context
2. The external skill discovery is already done above -- no relevant skills found
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning). These are agents whose domain expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-JXtYwL/fix-post-exec-gate-ux/phase1-metaplan.md`
