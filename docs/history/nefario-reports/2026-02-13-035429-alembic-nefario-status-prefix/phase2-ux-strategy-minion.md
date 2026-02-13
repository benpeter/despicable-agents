# UX Strategy: Alembic Prefix Placement

## Planning Question

Should ALL user-facing nefario outputs get the alembic prefix, or only a subset? What is the right balance between "distinctive identity" and "visual noise" in a fast-scrolling terminal during multi-phase orchestrations?

## Recommendation: Apply to Orientation and Decision Layers Only

The alembic should prefix outputs at the **Orientation** and **Decision** visual weight levels. It should NOT appear on **Inline** or **Advisory** level outputs. The reasoning follows directly from the existing visual hierarchy in SKILL.md.

### The Existing Hierarchy Already Tells Us Where to Place It

SKILL.md defines four visual weights:

| Weight | Pattern | Alembic? | Rationale |
|--------|---------|----------|-----------|
| **Decision** | `ALL-CAPS LABEL:` headers | YES | These are nefario's highest-stakes moments. The alembic reinforces "this is an orchestrated decision point, not a regular prompt." |
| **Orientation** | `**--- Phase N: Name ---**` | YES | Phase markers are the spine of the orchestration. Prefixing them creates a scannable visual thread through the session. |
| **Advisory** | `>` blockquote, bold label | NO | Compaction checkpoints are optional nudges. Adding a symbol to something the user may skip adds noise without aiding recognition. |
| **Inline** | Plain text, no framing | NO | CONDENSE lines, heartbeats, and informational notes are designed to flow without interruption. A prefix on these contradicts their design intent. |

### Detailed Breakdown by Output Type

**YES -- Gets the alembic prefix:**

1. **Phase markers** (`**--- Phase N: Name ---**`)
   - Becomes: `**--- Phase 1: Meta-Plan ---**` with alembic prepended
   - These are the user's primary orientation anchors during a multi-phase session
   - A consistent symbol at every phase boundary creates a scannable "nefario thread" when scrolling back through terminal history
   - There are only 5 of these per orchestration (Phases 1, 2, 3, 3.5, 4) -- low repetition, high value

2. **AskUserQuestion headers** (P1 Team, P3.5 Review, P3.5 Plan, P4 Gate, P4 Calibrate, P5 Security, P5 Issue, PR, Post-exec, Existing PR, Confirm)
   - These are the Decision weight. The `header` field in AskUserQuestion is the most prominent element because it drives the interactive UI chrome
   - However: the `header` field has a documented 12-character limit ("AskUserQuestion `header` values must not exceed 12 characters"). Current longest headers are already at 11 characters ("P3.5 Review", "P4 Calibrate"). Adding a multi-byte prefix could exceed the limit depending on how the renderer counts
   - **Risk**: The alembic character may count as 1 character (code point), 2 bytes (UTF-8 for U+2697 without selector), or more with the variant selector. If the 12-char limit is byte-counted rather than character-counted, this will break existing headers
   - **Recommendation**: Test the limit empirically. If the limit accommodates the prefix, apply it to all AskUserQuestion headers. If it does not, apply it only to the `question` field or the gate brief text, not the `header`. This is the single highest-risk item in the implementation

3. **Gate briefs** (TEAM:, APPROVAL GATE:, EXECUTION PLAN:, SECURITY FINDING:, VERIFICATION ISSUE:)
   - These are multi-line Decision-weight blocks. The ALL-CAPS label is the first thing the user reads
   - Prefixing the label (e.g., the alembic followed by `TEAM:`) gives immediate identity without adding visual noise to the structured fields below
   - Apply the prefix to the top-level label only, NOT to sub-fields (DECISION, DELIVERABLE, RATIONALE, IMPACT, etc.)

4. **Escalation briefs** (security-severity BLOCKs, unresolvable verification issues)
   - These are rare, high-stakes, attention-demanding. The alembic reinforces that this is an orchestrated escalation, not a random error

**NO -- Does NOT get the alembic prefix:**

5. **CONDENSE lines** ("Planning: consulting ...", "Review: N APPROVE, N BLOCK", "Verifying: ...")
   - These are Inline weight by explicit design. They compress information into flowing text
   - Prefixing them would contradict their intent: to be glanced at and passed over
   - A typical orchestration produces 4-6 CONDENSE lines. Prefixing them would mean the alembic appears on ~10 different output lines per orchestration. That crosses from "identity signal" into "visual clutter"

6. **Heartbeat lines** ("Waiting for 3 agents...")
   - Pure status noise. Literally designed to be ignorable. A symbol prefix would promote their visual weight inappropriately

7. **Compaction checkpoints** ("> **COMPACT** -- Phase 3 complete...")
   - Advisory weight. Blockquote formatting already sets them apart. Adding the alembic inside a blockquote would be visually redundant (two framing devices competing)

8. **Informational one-liners** ("Continuing without compaction.", "Committed N files: ...", "Using existing PR #N.", "Updated PR #N with Post-Nefario Updates.")
   - These are byproducts. They confirm actions, not demand attention. No prefix.

9. **Status file writes** (`echo "P1 Meta-Plan | $summary" > /tmp/nefario-status-$SID`)
   - This is the status line context, consumed by the statusline script
   - The task specifies that the alembic DOES appear here (it is in scope), but it should use the text variant selector (U+2697 U+FE0E) per the constraint about monospace alignment
   - The prefix appears once in the status line, persistent throughout the session. This is the single most valuable placement: it is always visible, never scrolls away, and costs zero additional cognitive load because the status line is peripheral vision by design

### Cognitive Load Analysis

The "every prefix" approach would mean the alembic appears approximately 20-30 times per orchestration session across all output types. That is excessive. Users would habituate within the first 3 occurrences and stop noticing it -- the "banner blindness" effect. Worse, frequent repetition of a decorative element trains users to ignore ALL instances, including the ones on Decision-weight outputs where noticing it matters.

The recommended approach yields approximately 8-12 occurrences per orchestration:
- 5 phase markers
- 3-5 gate headers / briefs
- 0-2 escalation briefs (rare)
- 1 persistent status line entry

This is the right density: enough to establish identity, sparse enough that each occurrence registers.

### The Satisficing Principle Applies

Users scan terminal output; they do not read it. The alembic's job is to answer one question instantly: "Is nefario orchestrating right now?" The status line answers this persistently. Phase markers answer it at transitions. Gate briefs answer it at decision points. These three contexts are the only ones where the question is relevant. Adding the alembic elsewhere answers a question nobody is asking, which is the definition of extraneous cognitive load.

## Risks

1. **AskUserQuestion header character limit**: The 12-character max is the constraint most likely to force a design compromise. If the alembic + space pushes headers over the limit, the fallback is: apply the prefix to the `question` field instead, and rely on the gate brief label for the visual identity signal. Must be tested empirically before implementation.

2. **Double-width rendering**: Even with the text variant selector (U+FE0E), some terminal emulators may still render the alembic as double-width. If this happens in the status line, the alignment math for the `$result` string in the statusline command will be off. The implementation should test in macOS Terminal, VS Code terminal, and iTerm2 -- all three are in scope.

3. **Inconsistency between agent outputs and orchestrator outputs**: The alembic is for nefario only. But during orchestration, some gate brief content originates from subagents (the producing agent creates the deliverable, nefario wraps it in a gate). The alembic should be applied by the orchestrator layer (SKILL.md), not by individual agents. This is an implementation boundary, not a UX decision, but it affects where the prefix logic lives.

4. **Future symbol creep**: If nefario gets an alembic, lucy and margo will want symbols too. The task scope explicitly excludes other agents, but the precedent is set. From a UX perspective, symbol proliferation should be resisted. Nefario is the one agent that owns the entire user-facing output stream of an orchestration; others are invisible (their output is suppressed or condensed). Only the orchestrator needs a visual identity marker.

## Dependencies

- Must coordinate with whoever implements the status line changes (`despicable-statusline` skill) to ensure the text variant selector (U+FE0E) is correctly embedded in the shell command string
- Must coordinate with whoever modifies SKILL.md to ensure the prefix is applied only at Orientation and Decision weight levels, not globally

## Summary

Apply the alembic to the structural skeleton of the orchestration (phase markers, gate headers, gate briefs, escalations, status line) and leave the connective tissue untouched (CONDENSE lines, heartbeats, compaction prompts, informational one-liners). This respects the visual hierarchy already designed into SKILL.md and avoids the trap of turning a distinctive identity signal into background noise through overuse.
