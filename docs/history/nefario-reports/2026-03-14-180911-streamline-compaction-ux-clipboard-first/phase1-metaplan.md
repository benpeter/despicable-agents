# Meta-Plan: Streamline Compaction UX -- Clipboard-First

## Task Summary

Simplify the compaction flow in the nefario skill by removing the Skip/Compact
AskUserQuestion gate and replacing it with an always-generate pattern: always
copy the compaction prompt to the clipboard, tell the user to paste to compact or
type "continue" to skip, and clarify the post-compaction continuation instruction
(queue "continue" immediately, not "type when ready").

## Scope

- **In**: Compaction flow logic and user-facing messages in `skills/nefario/SKILL.md`
  -- specifically the two compaction checkpoints (after Phase 3, ~line 796; after
  Phase 3.5, ~line 1312) and the optional Phase 4 compaction note (~line 1751).
- **Out**: Compaction prompt content/quality, other nefario phases, Claude Code
  clipboard internals, AGENT.md files, the-plan.md.

## Affected File

Single file: `skills/nefario/SKILL.md`

There are exactly two compaction checkpoint blocks that need modification:
1. **Post-Phase 3 checkpoint** (lines 796-852): AskUserQuestion with Skip/Compact
   options, pbcopy on "Compact", print command, "Type `continue` when ready to resume."
2. **Post-Phase 3.5 checkpoint** (lines 1312-1355): Same pattern, different focus string.

Both follow an identical structure that must be refactored to the new
clipboard-first pattern.

## Planning Consultations

### Consultation 1: UX Flow Design

- **Agent**: ux-strategy-minion
- **Planning question**: The current compaction flow is a two-step interaction:
  (1) AskUserQuestion "Compact or Skip?", then (2) if Compact, show the command
  and wait. The proposed change collapses this to one step: always generate the
  prompt, copy to clipboard, and present a single message with two paths (paste
  to compact, or type "continue" to skip). Does removing the explicit choice
  gate reduce cognitive load, or does it risk confusing users who see an
  unsolicited clipboard change? Should the "paste to compact or continue to skip"
  message be presented via AskUserQuestion (with options) or as a plain text
  message that waits for freeform input? What is the clearest phrasing for
  "queue continue immediately" vs the current "type continue when ready"?
- **Context to provide**: The two compaction checkpoint blocks from SKILL.md
  (lines 796-852 and 1312-1355), the AskUserQuestion conventions (header
  max 12 chars, Run: $summary_full trailing line), and the fact that this
  runs in a terminal CLI context.
- **Why this agent**: UX strategy owns interaction flow design, cognitive load
  reduction, and user journey coherence. The core change is about simplifying
  an interaction pattern -- their expertise determines whether the proposed
  approach is actually simpler or just different.

### Consultation 2: Prompt Engineering for the Compaction Instruction

- **Agent**: ai-modeling-minion
- **Planning question**: The compaction checkpoints contain orchestration
  instructions that control nefario's behavior (when to copy to clipboard,
  what to print, what to wait for). The proposed change modifies the control
  flow from conditional (if user picks Compact) to unconditional (always copy,
  then branch on user response). What is the clearest way to encode the new
  flow in SKILL.md's instruction format so that nefario reliably: (a) always
  runs the pbcopy command, (b) always prints the user-facing message, (c)
  waits for either a paste-and-compact cycle or a "continue" response, and
  (d) does not re-prompt or get confused by the absence of an AskUserQuestion
  gate? Also: should the context-usage extraction (lines 805-816) still be
  included, and if so, where does it go in the new flow?
- **Context to provide**: The full compaction checkpoint blocks, the
  AskUserQuestion API conventions, the inline summary template, and the
  session output discipline rules from CLAUDE.md.
- **Why this agent**: ai-modeling-minion owns prompt engineering and
  multi-agent architecture. The change modifies orchestration instructions
  that control nefario's runtime behavior -- getting the instruction encoding
  right is critical for reliable execution.

## Cross-Cutting Checklist

- **Testing** (test-minion): Not needed for planning. The deliverable is a
  SKILL.md text change with no executable code. Testing coverage will be
  evaluated in execution -- the success criterion "no behavioral regression"
  requires manual verification by running the nefario flow, which cannot be
  automated. Phase 6 will check if any existing tests are affected.
- **Security** (security-minion): Not needed. The change modifies user-facing
  messages and clipboard behavior. No auth, secrets, user input processing,
  or attack surface changes.
- **Usability -- Strategy** (ux-strategy-minion): ALWAYS include. Consultation 1
  above covers this. Planning question: see Consultation 1.
- **Usability -- Design** (ux-design-minion, accessibility-minion): Not needed.
  No visual UI components are produced. This is a CLI text interaction pattern.
- **Documentation** (software-docs-minion): Not needed for planning. The change
  is self-contained within SKILL.md, which is its own documentation. No
  architecture docs, API docs, or user guides are affected. Phase 8 will
  evaluate if docs/orchestration.md needs a corresponding update.
- **Observability** (observability-minion, sitespeed-minion): Not needed. No
  runtime services, APIs, or web-facing components.

## Anticipated Approval Gates

**Zero gates expected.** This task involves:
- Modifying two text blocks in a single file (SKILL.md)
- The change is additive (simplifying an interaction) and easily reversible
  (revert the text blocks)
- No downstream tasks depend on the compaction flow design
- Low blast radius, easy to reverse = no gate needed per the gate
  classification matrix

The execution plan approval gate (standard nefario Phase 3.5 process) will
serve as the single review point.

## Rationale

This is a focused UX simplification in a single file. Two specialists are
needed for planning:

1. **ux-strategy-minion** because the core change is an interaction pattern
   redesign -- collapsing a two-step gate into a one-step clipboard-first flow.
   Their expertise determines whether the proposed approach genuinely reduces
   friction.

2. **ai-modeling-minion** because the compaction checkpoints are orchestration
   instructions that control nefario's runtime behavior. The control flow
   change (conditional to unconditional) must be encoded precisely in the
   SKILL.md instruction format to avoid execution-time confusion.

No other specialists are needed for planning. The change touches no code,
infrastructure, APIs, security boundaries, or observable systems. It is
entirely within the nefario skill's orchestration instructions.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent build/rebuild | Not relevant -- no agents being rebuilt |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant -- no status line changes |
| despicable-prompter | skills/despicable-prompter/ | LEAF | Task briefing | Not relevant -- task is already briefed |

### Precedence Decisions

No precedence conflicts. None of the discovered external skills overlap with the
task domain (compaction flow UX in nefario SKILL.md).
