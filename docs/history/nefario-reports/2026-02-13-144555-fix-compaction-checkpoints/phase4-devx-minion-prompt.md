## Task

Replace both compaction checkpoint blockquote sections in `skills/nefario/SKILL.md`
with AskUserQuestion gates that actually pause execution.

## Context

Issue #87: The current compaction checkpoints (after Phase 3 and Phase 3.5)
print blockquote advisories but the orchestration proceeds immediately without
pausing. Users see the suggestion flash by with no opportunity to act.

The fix replaces these with AskUserQuestion gates (same mechanism used by
other gates like P1 Team, P3 Impasse, P3.5 Review, etc.).

## What to change

**File**: `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

### Change 1: Post-Phase 3 compaction checkpoint (lines ~811-825)

Replace the current blockquote + response handling with an AskUserQuestion gate:

- `header`: "P3 Compact"
- `question`: "Phase 3 complete. Specialist details are now in the synthesis. Compact context before continuing?\n\nRun: $summary"
- `options` (2, `multiSelect: false`):
  1. label: "Skip", description: "Continue without compaction. Auto-compaction may interrupt later phases." (recommended)
  2. label: "Compact", description: "Pause to compact context before Phase 3.5."

**"Skip" response handling**:
Print: `Continuing without compaction.`
Record that compaction was skipped (used to suppress the Phase 3.5 checkpoint).
Proceed to Phase 3.5.

**"Compact" response handling**:
Print the `/compact` command for the user to copy and run:

    Copy and run:

        /compact focus="Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, $summary, scratch directory path. Discard: individual specialist contributions from Phase 2."

    Type `continue` when ready to resume.

<!-- Focus strings are printed verbatim in terminal output.
     Avoid backticks, single quotes, and backslashes in focus string values. -->

The `$summary` and scratch directory path references in the focus string must be
interpolated to their actual resolved values before display. Do not show template
variables in user-facing output (per the Path display rule).

Wait for the user to say "continue" (or synonyms: "go", "next", "ok", "resume",
"proceed"). Then proceed to Phase 3.5. Do NOT re-prompt at subsequent boundaries.

### Change 2: Post-Phase 3.5 compaction checkpoint (lines ~1194-1206)

Replace the current blockquote + response handling with an AskUserQuestion gate
that includes skip-cascade logic:

**Skip-cascade rule**: If the user selected "Skip" at the P3 Compact checkpoint,
suppress this gate entirely. Print: `Compaction skipped (per earlier choice).`
and proceed to the Execution Plan Approval Gate.

If the P3 Compact checkpoint was not skipped (i.e., the user selected "Compact"
earlier), present using AskUserQuestion:

- `header`: "P3.5 Compact"
- `question`: "Phase 3.5 complete. Review verdicts are folded into the plan. Compact context before execution?\n\nRun: $summary"
- `options` (2, `multiSelect: false`):
  1. label: "Skip", description: "Continue without compaction. Auto-compaction may interrupt execution." (recommended)
  2. label: "Compact", description: "Pause to compact context before Phase 4."

**"Skip" response handling**:
Print: `Continuing without compaction.`
Proceed to the Execution Plan Approval Gate.

**"Compact" response handling**:
Print the `/compact` command for the user to copy and run:

    Copy and run:

        /compact focus="Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, $summary, scratch directory path. Discard: individual review verdicts, Phase 2 specialist contributions, raw synthesis input."

    Type `continue` when ready to resume.

<!-- Focus strings are printed verbatim in terminal output.
     Avoid backticks, single quotes, and backslashes in focus string values. -->

The `$summary` and scratch directory path references in the focus string must be
interpolated to their actual resolved values before display. Do not show template
variables in user-facing output (per the Path display rule).

Wait for the user to say "continue" (or synonyms: "go", "next", "ok", "resume",
"proceed"). Then proceed to the Execution Plan Approval Gate.

### Change 3: Visual hierarchy table (line ~237)

Update the visual hierarchy table. The current row:

```
| **Advisory** | `>` blockquote with bold label | Compaction checkpoints -- optional user action |
```

Check whether any other feature in SKILL.md uses the Advisory weight class besides
compaction checkpoints. If nothing else uses it, remove the row entirely. If
something else uses it, update the Use column to remove the compaction checkpoint
reference.

Also update the paragraph after the table if the Advisory row was removed -- remove
the Advisory reference from: "Decision blocks are the heaviest: multi-line with
structured fields. Orientation is a single bold line. Advisory uses blockquote
indentation. Inline flows without interruption."

### Change 4: Advisory Termination section

The Advisory Termination section (line ~831) already mentions skipping the
compaction checkpoint. Verify it still works correctly with the new AskUserQuestion
format. The line says "Skip the compaction checkpoint" -- this should still be
correct since we're skipping the AskUserQuestion gate entirely in advisory mode.

## ADVISE notes from architecture review

- [governance/lucy]: Skip-cascade is a net-new stateful inter-gate dependency pattern with no existing precedent in SKILL.md. Implement carefully and document the state tracking clearly.
- [governance/lucy]: Verify Advisory row removal from visual hierarchy table is safe before removing.
- [simplicity/margo]: Authoring guard HTML comments are mild YAGNI but near-zero cost -- acceptable.

## What NOT to do

- Do NOT use clipboard (`pbcopy`, `xclip`, etc.). Print the command as visible text.
- Do NOT add platform detection logic.
- Do NOT dynamically compose focus strings. They are static templates with variable interpolation.
- Do NOT add a conditional context-pressure check to skip the gate automatically.
- Do NOT change the focus string content itself (the Preserve/Discard lists).
- Do NOT change any other gates or sections of SKILL.md beyond the four changes above.
- Do NOT modify the Advisory Termination section content (just verify it still works).

## Deliverables

Updated `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` with:
1. Post-Phase 3 AskUserQuestion compaction gate replacing blockquote
2. Post-Phase 3.5 AskUserQuestion compaction gate replacing blockquote (with skip-cascade)
3. Updated visual hierarchy table
4. Authoring guard comments near focus strings

## Success criteria

- Both compaction checkpoints use AskUserQuestion (execution pauses until user responds)
- Headers follow P<N> convention: "P3 Compact" and "P3.5 Compact"
- Skip is option 1 (recommended), Compact is option 2
- "Compact" option prints the command as visible text (no clipboard)
- Focus strings contain interpolation note (resolve $summary and paths before display)
- Skip-cascade: P3.5 gate suppressed if P3 was skipped
- Visual hierarchy table is accurate
- Question fields end with `\n\nRun: $summary`
- No other sections of SKILL.md are modified

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
