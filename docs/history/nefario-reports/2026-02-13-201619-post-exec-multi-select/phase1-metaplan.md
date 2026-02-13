# Meta-Plan: Post-Execution Multi-Select Skip Interview

## Task Summary

Change the post-execution skip interview (after Phase 4 approval gates) from
single-choice AskUserQuestion options to multi-select, so the user can toggle
exactly which post-execution phases (5, 6, 7, 8) to run in a single interaction.

## Scope

**In scope**:
- Redesign the post-execution AskUserQuestion from `multiSelect: false` (4
  single-choice options) to `multiSelect: true` (individual phase toggles)
- Update the downstream interpretation logic (Phase 5-8 skip determination)
- Update all three files that describe this behavior:
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

## Files Affected

| File | Section | Change |
|------|---------|--------|
| `skills/nefario/SKILL.md` | Lines ~1550-1570 (post-exec AskUserQuestion) | Redesign options from single-select to multi-select |
| `skills/nefario/SKILL.md` | Lines ~1645-1662 (skip determination logic) | Update to handle multi-select response format |
| `nefario/AGENT.md` | Lines ~775-777 (skip options mention) | Update description to reflect multi-select |

## Planning Consultations

### Consultation 1: UX Strategy for Multi-Select Gate Design

- **Agent**: ux-strategy-minion
- **Planning question**: The current post-execution skip interview presents 4
  mutually exclusive options ("Run all", "Skip docs", "Skip tests", "Skip
  review"). We want to change this to multi-select so users can pick any
  combination. Design the option list, default states (pre-selected or not),
  labeling, and interaction flow. Key constraints: (1) AskUserQuestion headers
  are max 12 characters, (2) the question field must end with
  `\n\nRun: $summary_full`, (3) most users want "Run all" most of the time so
  the default should be friction-free, (4) Phase 7 (deploy) is already gated
  separately at plan approval and should NOT appear here. What is the simplest
  multi-select UX that reduces cognitive load compared to the current
  single-select approach?
- **Context to provide**: Current AskUserQuestion definition (SKILL.md lines
  1550-1570), the 4 phases (5=code review, 6=tests, 7=deploy, 8=docs), the
  freeform flag fallback (`--skip-*`).
- **Why this agent**: Multi-select UIs can easily increase cognitive load if
  poorly designed. ux-strategy-minion ensures the new interaction is simpler
  than the old one, not more complex. Default state selection (all-on vs
  all-off) is a critical UX decision.

### Consultation 2: Developer Experience for Skip Flag Compatibility

- **Agent**: devx-minion
- **Planning question**: The current system supports both structured selection
  (AskUserQuestion options) and freeform text flags (`--skip-docs`,
  `--skip-tests`, `--skip-review`, `--skip-post`). With multi-select, the
  structured path becomes the primary interaction, but freeform flags must
  remain as an escape hatch. Are there any edge cases in how multi-select
  responses interact with the existing flag parsing? Should the flag names or
  semantics change now that multi-select is available? Is there a risk of
  confusing the two input modes?
- **Context to provide**: Current flag definitions (SKILL.md lines 1562-1570),
  the AskUserQuestion options structure, the skip determination logic (SKILL.md
  lines 1645-1662).
- **Why this agent**: devx-minion ensures the developer-facing interaction
  (flags, option labels, response interpretation) remains consistent and
  intuitive across both input modes.

## Cross-Cutting Checklist

- **Testing**: Not needed for planning. This is a spec/documentation change to
  three markdown files -- no executable code. Phase 6 (test execution) is not
  applicable. However, the change should be verified manually by running a
  nefario orchestration that reaches the post-exec gate.
- **Security**: Not needed. No attack surface, authentication, user input
  processing, or secrets involved. This changes markdown specification files only.
- **Usability -- Strategy**: INCLUDED as Consultation 1. The multi-select
  redesign is fundamentally a UX decision -- default states, option ordering,
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

## Rationale

This is a focused UX improvement to a single interaction point in the nefario
workflow. Only two specialist perspectives add genuine planning value:

1. **ux-strategy-minion** -- The core question is "what should the multi-select
   look like?" Default states, option ordering, and cognitive load reduction are
   UX strategy concerns. This is the primary planning consultation.

2. **devx-minion** -- The secondary question is "does multi-select break or
   confuse the freeform flag escape hatch?" Flag compatibility and dual-mode
   input consistency are developer experience concerns.

Other agents were considered and excluded:
- **software-docs-minion**: The deliverables ARE documentation. No separate
  documentation planning needed.
- **ai-modeling-minion**: No LLM prompt design or multi-agent coordination involved.
- **frontend-minion**: No web UI components. AskUserQuestion is a CLI construct.
- **margo**: Will review in Phase 3.5 (mandatory). No planning input needed --
  the task is inherently a simplification (replacing 4 mutually exclusive options
  with a more flexible multi-select).

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
