# Meta-Plan: Post-Execution Multi-Select Skip Interview (Revised)

## Task Summary

Change the post-execution skip interview (after Phase 4 approval gates) from
single-choice AskUserQuestion options to multi-select, so the user can toggle
exactly which post-execution phases (5, 6, 7, 8) to run in a single interaction.

## Scope

**In scope**:
- Redesign the post-execution AskUserQuestion from `multiSelect: false` (4
  single-choice options) to `multiSelect: true` (individual phase toggles)
- Update the downstream interpretation logic (Phase 5-8 skip determination)
- Update all files that describe this behavior:
  - `skills/nefario/SKILL.md` (primary -- the post-exec gate definition + skip logic)
  - `nefario/AGENT.md` (secondary -- brief mention of skip options)
- Preserve freeform flag compatibility (`--skip-docs`, `--skip-tests`,
  `--skip-review`, `--skip-post`)

**Out of scope**:
- `the-plan.md` -- does not describe the AskUserQuestion UI details
- Changing which phases exist or what they do
- Changing Phase 7 (deployment) triggering logic (already conditional on
  explicit user request at plan approval, not part of this skip interview)
- Changing any other AskUserQuestion gates in the workflow

## Critical Historical Context

A previous orchestration (2026-02-10, report at
`docs/history/nefario-reports/2026-02-10-171844-replace-skip-post-granular-flags.md`)
attempted a similar change. During that session, it was discovered that
`multiSelect: true` did **not work** in Claude Code's AskUserQuestion UI at the
time. The resolution was a flat 4-option single-select design (the current
implementation). That previous decision was confirmed by ux-strategy-minion,
margo, and the user.

This context is essential for all planning consultations. The issue is now
re-opened, which implies one of:
1. The Claude Code UI has been updated to support `multiSelect: true` since Feb 10
2. The user wants to try a different implementation approach
3. The user wants to re-verify whether it works now

Each planning consultation must account for this uncertainty.

## Files Affected

| File | Section | Change |
|------|---------|--------|
| `skills/nefario/SKILL.md` | Lines ~1550-1570 (post-exec AskUserQuestion) | Redesign options from single-select to multi-select |
| `skills/nefario/SKILL.md` | Lines ~1645-1662 (skip determination logic) | Update to handle multi-select response format |
| `nefario/AGENT.md` | Lines ~775-777 (skip options mention) | Update description to reflect multi-select |

## Planning Consultations

### Consultation 1: UX Strategy for Multi-Select Gate Design

- **Agent**: ux-strategy-minion
- **Planning question**: We are revisiting the post-execution skip interview to
  change it from single-select (4 options: "Run all", "Skip docs", "Skip tests",
  "Skip review") to multi-select. A previous attempt on 2026-02-10 found that
  `multiSelect: true` did not work in Claude Code's UI, leading to the current
  flat single-select design. Assuming `multiSelect: true` now works, design the
  option list for a multi-select interaction. Key decisions:
  (1) Should options represent phases to RUN (pre-checked, user unchecks to skip)
  or phases to SKIP (unchecked, user checks to skip)? The framing affects
  cognitive load -- positive framing ("run these") vs. negative framing ("skip
  these") vs. the current negative framing where options are skip actions.
  (2) What should default states be? All checked (run everything) is the safest
  default but requires user action to skip. All unchecked requires explicit
  opt-in to each phase.
  (3) Should "Run all" remain as a separate option alongside individual phase
  toggles, or does multi-select make it redundant (all-checked = run all)?
  (4) How does this interact with the constraint that AskUserQuestion headers
  are max 12 characters and the question field must end with
  `\n\nRun: $summary_full`?
  The freeform flag escape hatch (`--skip-docs`, `--skip-tests`, etc.) is
  handled separately by devx-minion -- focus on the structured multi-select UX.
- **Context to provide**: Current AskUserQuestion definition (SKILL.md lines
  1550-1570), the 3 relevant phases (5=code review, 6=tests, 8=docs -- Phase 7
  deploy is gated separately), the previous attempt's UX analysis (report at
  `docs/history/nefario-reports/2026-02-10-171844-replace-skip-post-granular-flags/phase2-ux-strategy-minion.md`).
- **Why this agent**: Multi-select UIs can increase cognitive load if poorly
  designed. The framing decision (run-these vs. skip-these) and default state
  selection are core UX strategy concerns. The previous attempt already produced
  a ux-strategy analysis that can be built upon rather than starting from scratch.

### Consultation 2: Developer Experience for Skip Flag Compatibility and Response Parsing

- **Agent**: devx-minion
- **Planning question**: The current system supports both structured selection
  (AskUserQuestion options) and freeform text flags (`--skip-docs`,
  `--skip-tests`, `--skip-review`, `--skip-post`). With multi-select, the
  structured path changes from returning a single selected label (e.g.,
  "Skip docs") to returning a list of selected labels. How should the
  downstream skip determination logic (SKILL.md lines 1645-1662) be updated to
  handle the multi-select response format? Specific questions:
  (1) What is the expected response format from a `multiSelect: true`
  AskUserQuestion? Is it an array of selected labels, a comma-separated string,
  or something else? The logic must handle this format correctly.
  (2) Should the freeform flag semantics change at all now that multi-select
  handles combinations natively? The previous design used freeform as the escape
  hatch for multi-phase skips -- that use case is now covered by multi-select.
  (3) Are there edge cases where multi-select and freeform could conflict or
  produce ambiguous results?
  (4) The CONDENSE status line (lines 1657-1662) lists which phases will run.
  Does the logic for generating this line need to change, or does it remain the
  same regardless of input mode?
  Note: ux-strategy-minion is handling the option framing (run-these vs.
  skip-these) and defaults. Focus on the technical interaction: response parsing,
  flag compatibility, and skip determination logic.
- **Context to provide**: Current skip determination logic (SKILL.md lines
  1645-1662), current freeform flag definitions (SKILL.md lines 1562-1570),
  the previous devx-minion analysis (report at
  `docs/history/nefario-reports/2026-02-10-171844-replace-skip-post-granular-flags/phase2-devx-minion.md`).
- **Why this agent**: devx-minion ensures the developer-facing interaction
  (flags, option labels, response interpretation) remains consistent across
  both input modes. The response format parsing for multi-select is a technical
  design question that directly affects correctness.

### Consultation 3: AskUserQuestion Multi-Select Behavior Verification

- **Agent**: ai-modeling-minion
- **Planning question**: The AskUserQuestion tool in Claude Code supports a
  `multiSelect` parameter. As of 2026-02-10, `multiSelect: true` was reported
  as non-functional in Claude Code's UI. This task assumes it now works. Based
  on your knowledge of the Anthropic API and Claude Code tool system:
  (1) What is the expected behavior of `multiSelect: true` in AskUserQuestion?
  How does the response differ from `multiSelect: false`?
  (2) When `multiSelect: true` is used, what does the response look like when
  the user selects zero options, one option, or multiple options? Is the
  response format an array, a comma-separated string, or something else?
  (3) Are there any known constraints on `multiSelect: true` -- e.g., minimum
  number of selections required, maximum options supported, how "(Recommended)"
  labels interact with multi-select?
  (4) Is there a way to set default-checked options in a `multiSelect: true`
  AskUserQuestion, or are all options unchecked by default?
  This information is critical because the entire task depends on `multiSelect:
  true` actually working. If it still does not work, the task scope changes
  fundamentally. The other two consultants (ux-strategy-minion for UX design,
  devx-minion for response parsing) both need this answer to produce valid
  recommendations.
- **Context to provide**: The AskUserQuestion tool specification (as available
  in Claude Code documentation), the current SKILL.md usage patterns (all 14
  instances use `multiSelect: false`), the previous session's finding that it
  did not work.
- **Why this agent**: ai-modeling-minion covers Anthropic API integration and
  Claude Code tool behavior. Understanding whether and how `multiSelect: true`
  actually works in AskUserQuestion is a prerequisite for the entire task. The
  other two agents design the UX and the parsing logic -- but both designs are
  speculative if the underlying tool capability is uncertain.

## Cross-Cutting Checklist

- **Testing**: Not needed for planning. This is a spec/documentation change to
  markdown files -- no executable code. However, the change should be verified
  manually by running a nefario orchestration that reaches the post-exec gate.
  Critical: the first verification step should confirm `multiSelect: true`
  actually renders correctly in the Claude Code UI.
- **Security**: Not needed. No attack surface, authentication, user input
  processing, or secrets involved. This changes markdown specification files only.
- **Usability -- Strategy**: INCLUDED as Consultation 1. The multi-select
  redesign is fundamentally a UX decision -- option framing, default states,
  and cognitive load are the core concerns.
- **Usability -- Design**: Not needed for planning. There is no visual UI
  component -- AskUserQuestion is a CLI text prompt with structured options.
  The visual presentation is handled by Claude Code's built-in rendering.
- **Documentation**: Not needed as a separate planning consultation.
  The change IS documentation -- SKILL.md and AGENT.md are the documentation.
  software-docs-minion and user-docs-minion have no additional perspective to
  add beyond what ux-strategy-minion and devx-minion provide.
- **Observability**: Not needed. No runtime components, logging, or metrics involved.

## Anticipated Approval Gates

None. This task modifies two specification files (SKILL.md and AGENT.md). The
changes are additive (refining an existing interaction), easy to reverse (revert
the text), and have no downstream task dependencies within the execution plan.
The gate classification matrix (easy to reverse + low blast radius) yields NO GATE.

**However**: If ai-modeling-minion's consultation reveals that `multiSelect: true`
still does not work, the task scope changes fundamentally and a re-scoping
decision would be needed before proceeding to synthesis.

## Rationale

Three specialist perspectives add genuine planning value for this task:

1. **ux-strategy-minion** -- The core question is "what should the multi-select
   look like?" Option framing (run-these vs. skip-these), default states, and
   cognitive load reduction are UX strategy concerns. This agent produced a
   prior analysis on this exact topic that can be refined.

2. **devx-minion** -- The secondary question is "how does the response parsing
   and flag compatibility work with multi-select?" The skip determination logic
   must correctly handle the multi-select response format, and the freeform flag
   escape hatch must remain consistent.

3. **ai-modeling-minion** (added) -- The foundational question is "does
   `multiSelect: true` actually work in AskUserQuestion, and if so, what is
   the response format?" The previous attempt discovered it did not work. This
   consultation validates the technical prerequisite before the other two agents
   design against it. Without this answer, both UX design and parsing logic are
   speculative.

Other agents were considered and excluded:
- **software-docs-minion**: The deliverables ARE documentation. No separate
  documentation planning needed.
- **frontend-minion**: No web UI components. AskUserQuestion is a CLI construct.
- **margo**: Will review in Phase 3.5 (mandatory). No planning input needed --
  the task is inherently a simplification if multi-select works (replacing
  single-select + freeform workaround with native multi-select).

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding | Not relevant -- task does not involve agent regeneration |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant -- task does not change status line behavior |

Note: despicable-prompter is a symlinked global skill (`skills/despicable-prompter/`),
not a project-local skill in `.claude/skills/`. It is not relevant to this task.

### Precedence Decisions

No precedence conflicts. No discovered skills overlap with the specialists
selected for this task.
