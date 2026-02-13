# Polish approval gate presentation: backtick card framing + scratch file links

Synthesized from GitHub issues #82 and #85. All requirements from both issues are included.

## From #82: Link to scratch files that produced the decision

### Problem

When the user is presented with a gate or approval, they have no simple entry point to follow the conversation that led there. The current output mentions scratch file paths as plain text, which is:

1. **Not clickable** — file paths are not MD links, so there's no quick way to open them
2. **Messy** — raw temp paths like `/var/folders/3k/.../nefario-scratch-1ytDH0/replace-session-id-with-hook/` are noisy and hard to parse
3. **Incomplete** — advisories reference reviewer verdicts but don't link to the prompt/response pair that produced them
4. **Not visually distinct** — even the `Details:` line at the bottom blends into surrounding text; only hovering reveals it's a link (in terminals that support it)

### Requirements

1. **Advisory links (prompt + response)**: Each advisory in the ADVISORIES section should include MD links to both the prompt sent to the reviewer and the reviewer's response:
   ```
   ADVISORIES:
     [security] Task 1: Add SessionStart hook — [prompt](prompt-path) · [verdict](response-path)
       CHANGE: Add sanitization to session_id extraction
       WHY: Defense-in-depth against shell metacharacters
   ```

2. **Scratch dir reference**: The working dir / details line should link to the scratch directory but not display the full temp path:
   ```
   Working dir: [scratch/replace-session-id-with-hook/](full-path)
   ```

3. **Visual distinction for links**: Links must be visually distinct from surrounding text so the user knows they're clickable without hovering.

### Scope

- Applies to all gate types: team gate (P1), reviewer gate (P3.5), execution plan gate, mid-execution gates
- Each gate type has different relevant scratch files — the linked files should match what produced the decision being presented
- The CONDENSE line already preserves the scratch path; this is about surfacing it usefully at decision points

## From #85: Apply backtick card framing to all approval gates

### Context

PR #79 added backtick card framing (`` `───` `` borders + `` `LABEL:` `` highlighted fields) to the **mid-execution approval gate** template (SKILL.md). The intent was to apply this visual treatment to all gates and approval presentations, but only one was done.

### Remaining gates needing card framing

1. **Team Approval Gate** — Phase 1 team selection
2. **Reviewer Approval Gate** — Phase 3.5 discretionary reviewer selection
3. **Execution Plan Approval Gate** — Phase 3.5 plan presentation
4. **PR Gate** — Phase 8 PR creation offer

### Pattern to follow

From the mid-execution gate (already updated):
- Top/bottom borders: `` `────────────────────────────────────────────────────` ``
- Header line: ⚗️ `` `APPROVAL GATE: <title>` ``
- Field labels wrapped in backticks: `` `DECISION:` ``, `` `DELIVERABLE:` ``, `` `RATIONALE:` ``, etc.
- Maintains the Decision visual weight from the Visual Hierarchy table

### Scope

- **In**: All four gate templates listed above in SKILL.md
- **Out**: Phase announcements, compaction checkpoints, AskUserQuestion prompts, non-SKILL.md docs (these use different visual weights)

## Combined scope

Both changes apply to the same gate templates in `skills/nefario/SKILL.md`. The card framing (#85) and scratch file links (#82) should be applied together so each gate template gets both treatments in a single pass.
