# Phase 1: Meta-Plan -- Card Framing for Approval Gates

## Task Summary

Update the approval gate template in `skills/nefario/SKILL.md` to use inline
code spans (backticks) on structural lines, creating visually distinct card-like
separation in Claude Code terminal output. The Visual Hierarchy table must also
be updated to reflect the new Decision weight pattern.

The branch already has partial work: `---` border lines were added to the gate
template, and the Visual Hierarchy table's Decision row was updated to mention
the `---` card frame. The remaining work is wrapping structural elements in
backticks per the issue's success criteria.

## Scope

- **In**: SKILL.md approval gate template (lines ~1286-1306), Visual Hierarchy
  table (lines ~207-212)
- **Out**: Phase announcement formatting, compaction checkpoint formatting,
  AskUserQuestion prompts, non-SKILL.md documentation (including AGENT.md)

## Planning Consultations

### Consultation 1: UX Design -- Terminal Card Rendering

- **Agent**: ux-design-minion
- **Planning question**: Given that Claude Code renders inline code spans
  (`backticks`) with a distinct highlight color against the terminal background,
  what is the optimal way to apply backtick wrapping to create a card-like
  visual effect? Specifically: (a) Should the `---` border lines be wrapped as
  a single backtick span or should the dashes be broken into segments? (b) For
  field labels like `DECISION:`, should just the label be wrapped or the label
  plus its value? (c) Does wrapping the header line
  `⚗️ APPROVAL GATE: <Task title>` in backticks risk readability issues with
  the emoji rendering inside a code span in terminal environments? Provide
  a concrete template showing the recommended backtick placement.
- **Context to provide**: Current SKILL.md gate template (lines 1286-1306),
  Visual Hierarchy table (lines 207-212), the issue's success criteria, the
  constraint that only inline code spans and box-drawing characters are allowed.
- **Why this agent**: ux-design-minion has expertise in visual hierarchy,
  interaction design, and how formatting renders in terminal UIs. The core
  question is a visual design question about code span placement.

## Cross-Cutting Checklist

- **Testing**: Not included for planning. The deliverable is a documentation/template
  change with no executable output. No tests to write or run.
- **Security**: Not included for planning. No attack surface, auth, user input,
  or infrastructure changes.
- **Usability -- Strategy**: Not included for planning. This is a micro-level
  visual formatting change to an existing template. The user journey and
  cognitive load model are unchanged -- gates remain gates, with the same
  content and interaction flow. The strategic question (should gates exist, what
  should they contain) was already settled. Only the visual rendering changes.
  ux-design-minion covers the visual design question directly.
- **Usability -- Design**: Included as Consultation 1 (ux-design-minion). The
  task is purely a visual design question about code span placement in terminal
  rendering. accessibility-minion is not needed -- terminal code spans have no
  WCAG implications beyond what's already handled by the terminal emulator.
- **Documentation**: Not included for separate planning consultation. The task
  IS the documentation change (updating SKILL.md). software-docs-minion and
  user-docs-minion will participate in post-execution Phase 8 per user request.
  product-marketing-minion will also participate in Phase 8 per user request.
  There is no separate documentation artifact to plan.
- **Observability**: Not included for planning. No runtime components, services,
  or performance implications.

## Anticipated Approval Gates

None. This is a single-file change (SKILL.md) with low blast radius (zero
downstream dependents) and easy reversibility (additive formatting change). Per
the gate classification matrix, this is a NO GATE scenario.

Given the user's instruction to "work all through to PR creation without
interactions" and "consider all approvals given," all gates are pre-approved.

## Rationale

Only one specialist is consulted: ux-design-minion. The task is a narrow visual
formatting question about how to apply backtick wrapping to create card-like
appearance in terminal output. This is squarely in the UX design domain.

Other specialists were considered and excluded:
- **devx-minion**: Could advise on CLI visual patterns, but the question is
  specifically about code span rendering, not CLI interaction design.
- **ux-strategy-minion**: The strategic decision (gates need visual distinction)
  is already made. Only the implementation of that distinction remains.
- **frontend-minion**: No web rendering involved; this is terminal output.

The user requested software-docs-minion, user-docs-minion, and
product-marketing-minion in the roster. These will be included in post-execution
Phase 8 documentation, not in planning (there is nothing for them to plan -- the
task IS the documentation change).

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding | Not relevant to this task |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant to this task |

### Precedence Decisions

No conflicts. Neither discovered skill overlaps with the task domain.
