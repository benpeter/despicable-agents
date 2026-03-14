You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Fix post-exec gate UX: replace inverted skip-only multiSelect with explicit 'Run all' single-select

**Outcome**: After approving a task gate, the user sees an explicit "Run all phases" option as the default choice, eliminating the current anti-pattern where the happy path (run everything) requires selecting nothing and triggering a Claude Code "you haven't answered all questions" warning. This makes the most common action visible and warning-free.

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
- User can always type "Other" for freeform input

## Your Planning Question

The current post-exec gate uses a multiSelect pattern where the happy path (run all phases) means selecting nothing, triggering a Claude Code "unanswered question" warning. We need to replace this with single-select (multiSelect: false) using explicit named options. What should the option list look like? Consider:

1. Which skip combinations are actually useful vs. combinatorial noise? (There are 7 possible combinations of 3 skip flags — we can only show 2-4 options total)
2. How to label "run all" as the obvious default?
3. Ordering by frequency of use
4. Keeping the list short enough to scan instantly
5. How should the downstream consumption logic (lines 1723-1736) be updated to match the new single-select pattern?

## Context: Current Implementation

### Current post-exec AskUserQuestion (SKILL.md lines 1627-1648):
```
- **"Approve"**: Present a FOLLOW-UP AskUserQuestion for post-execution options:
  - `header`: "Post-exec"
  - `question`: "Skip any post-execution phases for Task N: <task title>? (confirm with none selected to run all)\n\nRun: $summary_full"
  - `options` (3, `multiSelect: true`):
    1. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
    2. label: "Skip tests", description: "Skip test execution (Phase 6)."
    3. label: "Skip review", description: "Skip code review (Phase 5)."
  Options are ordered by ascending risk (docs = lowest, review = highest).
  If no options selected: run all post-execution phases (5-8).
  If one or more options selected: skip those phases, run the rest.
  Then auto-commit changes (see below) and continue to next batch.
  The user may also type freeform flags at the same prompt,
  using flags to skip multiple phases (e.g., "--skip-docs --skip-tests",
  or "--skip-post" to skip all). Interpret natural language skip intent as
  equivalent to the corresponding flags. Flag reference:
  - `--skip-docs` = skip Phase 8
  - `--skip-tests` = skip Phase 6
  - `--skip-review` = skip Phase 5
  - `--skip-post` = skip Phases 5, 6, 8 (all post-execution)
  Flags can be combined: `--skip-docs --skip-tests` skips both.
  If the user provides both structured selection and freeform text,
  freeform text overrides on conflict.
```

### Current downstream consumption logic (SKILL.md lines 1723-1736):
```
Determine which post-execution phases to run based on the user's
multi-select response and/or freeform text flags:
- Phase 5 (Code Review): Skip if the user's selection includes
  "Skip review", or freeform contains --skip-review or --skip-post.
  Also skip if Phase 4 produced only documentation-only files (see
  Phase 5 file classification table).
- Phase 6 (Test Execution): Skip if the user's selection includes
  "Skip tests", or freeform contains --skip-tests or --skip-post.
  Also skip if no tests exist.
- Phase 8 (Documentation): Skip if the user's selection includes
  "Skip docs", or freeform contains --skip-docs or --skip-post.
  Also skip if checklist has no items.
- If no options were selected and no freeform skip flags were typed,
  run all phases.
```

### Other single-select AskUserQuestion patterns in the same file (for consistency):
- P1 Team gate: 3 options (Approve team, Adjust team, Reject)
- P3.5 Reviewer gate: 3 options (Approve reviewers, Adjust reviewers, Skip review)
- P4 Gate: 4 options (Approve, Request changes, Reject, Skip)

## Instructions
1. Read the SKILL.md file to see the full context around these blocks
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ux-strategy-minion

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-JXtYwL/fix-post-exec-gate-ux/phase2-ux-strategy-minion.md`
