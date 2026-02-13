# Meta-Plan: Fix Compaction Checkpoints

## Scope

**In scope**: Replace the two passive blockquote compaction checkpoints in
`skills/nefario/SKILL.md` (post-Phase 3, line ~811 and post-Phase 3.5, line ~1194)
with AskUserQuestion gates that pause execution and offer clipboard copy of the
`/compact` command.

**Out of scope**: Programmatic invocation of `/compact` (blocked by
anthropics/claude-code#19877, tracked in #88). Changes to any other file.
Changes to the compaction focus strings themselves. Changes to the optional
Phase 4-to-5 compaction mention (line ~1595).

## Planning Consultations

### Consultation 1: Compaction Gate Interaction Design

- **Agent**: ux-strategy-minion
- **Planning question**: The current compaction checkpoints are passive
  blockquotes that don't pause execution. We're replacing them with
  AskUserQuestion gates offering "Skip" (recommended) and "Compact" options.
  The "Compact" path copies a `/compact focus="..."` command to the clipboard
  via `pbcopy`, prints a note, then waits for the user to say "continue".

  Review this interaction flow for cognitive load and friction:
  1. Is "Skip" as the recommended default the right call? The user is mid-orchestration
     and compaction is optional but beneficial for long sessions.
  2. The "Compact" path has three steps: (a) clipboard copy, (b) user pastes and
     runs `/compact`, (c) user types "continue". Is this too many steps? Should
     the "continue" step be eliminated (e.g., auto-proceed after a delay, or
     detect that compaction completed)?
  3. The issue proposes "You can type `continue` and hit Return while compaction
     is running -- it will be queued." Is this interaction pattern intuitive, or
     will users wait for compaction to finish before typing continue?
  4. Should the gate use the existing `P<N> <Label>` header convention (e.g.,
     "P3 Compact") or the proposed bare "Compact" header? The existing convention
     provides phase context.

- **Context to provide**: SKILL.md lines 229-237 (visual hierarchy table),
  lines 501-517 (AskUserQuestion conventions), lines 811-825 (current post-Phase 3
  checkpoint), lines 1194-1206 (current post-Phase 3.5 checkpoint)
- **Why this agent**: UX strategy evaluates whether the interaction flow serves
  the user's job-to-be-done (managing context window pressure) without adding
  unnecessary friction to the orchestration flow.

### Consultation 2: Clipboard and Platform Considerations

- **Agent**: devx-minion
- **Planning question**: The "Compact" option needs to copy a `/compact focus="..."`
  command to the system clipboard. The issue specifies `pbcopy` on macOS with a
  "fallback note for other platforms."

  1. What's the right cross-platform clipboard strategy? `pbcopy` (macOS),
     `xclip`/`xsel` (Linux), `clip.exe` (WSL)? Or should we detect platform
     and use the appropriate tool?
  2. Should clipboard failure be silent (just print the command for manual copy)
     or should it warn?
  3. The `/compact focus="..."` string contains quotes and special characters.
     What's the safest way to pipe it to clipboard tools without shell escaping
     issues?
  4. Is there a simpler approach than clipboard -- e.g., just printing the command
     in a code block that's easy to select and copy?

- **Context to provide**: The current SKILL.md compaction checkpoint format,
  the fact that this runs in Claude Code CLI (terminal environment), the
  platform detection available in the env block.
- **Why this agent**: DevX specializes in CLI interaction patterns, error
  messages, and developer-facing UX in terminal environments. Clipboard handling
  is a classic CLI DX concern.

## Cross-Cutting Checklist

- **Testing**: Not needed for planning. This is a documentation/spec change to
  SKILL.md, not executable code. No test infrastructure exists for SKILL.md
  content. test-minion will participate in Phase 3.5 architecture review as
  mandatory reviewer.

- **Security**: Not needed for planning. The clipboard copy executes a shell
  command (`pbcopy`), but the content is a hardcoded `/compact` invocation, not
  user-supplied input. No new attack surface. security-minion will participate
  in Phase 3.5 as mandatory reviewer.

- **Usability -- Strategy**: INCLUDED as Consultation 1 above. The core question
  is whether the gate interaction flow is intuitive and low-friction.

- **Usability -- Design**: Not needed for planning. There are no visual UI
  components -- this is a CLI text interaction using the existing AskUserQuestion
  primitive. The design vocabulary (header, question, options) is already
  established.

- **Documentation**: Not needed for planning. The change is self-contained in
  SKILL.md, which IS the documentation. No separate docs need updating.
  software-docs-minion will verify consistency in Phase 3.5 if selected as
  discretionary reviewer.

- **Observability**: Not needed for planning. No runtime components, no logging,
  no metrics. This is an orchestration control flow change in a skill spec.

## Anticipated Approval Gates

**Zero execution gates expected.** This is a single-file, two-location change
in SKILL.md. The change follows an established pattern (AskUserQuestion) used
extensively throughout the same file. The blast radius is low (no downstream
tasks depend on the checkpoint format), and the change is easily reversible.

The Phase 3.5 architecture review (mandatory) serves as the quality gate.

## Rationale

This task is well-scoped: two locations in one file, replacing a known-broken
pattern (passive blockquote) with an established working pattern
(AskUserQuestion). Only two specialists add genuine planning value:

1. **ux-strategy-minion** -- The interaction flow design is the core design
   decision. The issue proposes a specific flow, but there are open UX questions
   about step count, defaults, and the "type continue while compaction runs"
   instruction.

2. **devx-minion** -- The clipboard copy mechanism is the only technical
   implementation question. Platform detection, escaping, and failure handling
   need a CLI/DX perspective.

Other agents are excluded from planning because:
- The file being changed (SKILL.md) is prose/spec, not code -- no code review,
  testing, or infrastructure concerns at planning time.
- Security surface is minimal (hardcoded clipboard content).
- The AskUserQuestion pattern is thoroughly documented in SKILL.md itself --
  no API design or spec questions.
- Mandatory Phase 3.5 reviewers (security-minion, test-minion, ux-strategy-minion,
  lucy, margo) will catch any issues before execution.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding from specs | Not relevant -- no agents are being rebuilt |
| despicable-prompter | .claude/skills/despicable-prompter/ | LEAF | Task briefing generation | Not relevant -- task is already briefed |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line configuration | Not relevant -- no status line changes |

### Precedence Decisions

No precedence conflicts. None of the discovered skills overlap with the task
domain (orchestration control flow in SKILL.md).
