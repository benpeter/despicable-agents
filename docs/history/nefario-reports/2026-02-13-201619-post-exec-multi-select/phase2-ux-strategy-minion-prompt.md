You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
<github-issue>
The post-execution skip interview (after Phase 4) currently uses single-choice AskUserQuestion options like "Skip to Phase 8" or "Run Phase 5". Change this to a multi-select so the user can pick exactly which post-execution phases to run (e.g., run Phase 5 code review and Phase 8 docs but skip Phase 6 tests and Phase 7 deploy).
</github-issue>

## Your Planning Question
We are revisiting the post-execution skip interview to change it from single-select (4 options: "Run all", "Skip docs", "Skip tests", "Skip review") to multi-select. A previous attempt on 2026-02-10 found that `multiSelect: true` did not work in Claude Code's UI, leading to the current flat single-select design. Assuming `multiSelect: true` now works, design the option list for a multi-select interaction. Key decisions:

(1) Should options represent phases to RUN (pre-checked, user unchecks to skip) or phases to SKIP (unchecked, user checks to skip)? The framing affects cognitive load -- positive framing ("run these") vs. negative framing ("skip these") vs. the current negative framing where options are skip actions.
(2) What should default states be? All checked (run everything) is the safest default but requires user action to skip. All unchecked requires explicit opt-in to each phase.
(3) Should "Run all" remain as a separate option alongside individual phase toggles, or does multi-select make it redundant (all-checked = run all)?
(4) How does this interact with the constraint that AskUserQuestion headers are max 12 characters and the question field must end with `\n\nRun: $summary_full`?

The freeform flag escape hatch (--skip-docs, --skip-tests, etc.) is handled separately by devx-minion -- focus on the structured multi-select UX.

## Context

### Current Implementation (SKILL.md lines 1550-1570)
The current post-exec gate uses `multiSelect: false` with 4 options:
```
- header: "Post-exec"
- question: "Post-execution phases for Task N: <task title>?\n\nRun: $summary_full"
- options (4, multiSelect: false):
  1. label: "Run all", description: "Code review + tests + docs after execution completes." (recommended)
  2. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
  3. label: "Skip tests", description: "Skip test execution (Phase 6)."
  4. label: "Skip review", description: "Skip code review (Phase 5)."
```

### Three Relevant Phases
- Phase 5: Code review (code-review-minion, lucy, margo)
- Phase 6: Test execution (test discovery, baseline comparison, layered execution)
- Phase 8: Documentation (software-docs-minion, user-docs-minion, product-marketing-minion)
Note: Phase 7 (deploy) is gated separately at plan approval and is NOT part of this skip interview.

### Previous Attempt Context
Report: docs/history/nefario-reports/2026-02-10-171844-replace-skip-post-granular-flags.md
Key finding: `multiSelect: true` did not work in Claude Code's UI on 2026-02-10, leading to the flat 4-option single-select design with freeform flags as escape hatch.
The previous UX analysis is at: docs/history/nefario-reports/2026-02-10-171844-replace-skip-post-granular-flags/phase2-ux-strategy-minion.md

## Instructions
1. Read relevant files to understand the current state
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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase2-ux-strategy-minion.md