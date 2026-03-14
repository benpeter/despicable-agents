You are editing the nefario orchestration skill to streamline the compaction flow.

## File
`/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

## What to change

There are exactly two "Compaction Checkpoint" sections in SKILL.md that must be updated:

1. **Post-Phase 3 checkpoint** — the `### Compaction Checkpoint` subsection under `## Phase 3: Synthesis`
2. **Post-Phase 3.5 checkpoint** — the `### Compaction Checkpoint` subsection under `## Phase 3.5: Architecture Review`

For EACH checkpoint, replace the current AskUserQuestion-based conditional flow with an unconditional clipboard-first sequence. The transformation is identical for both checkpoints — only the phase number, focus string, phase-completion sentence, and next-phase target differ.

## Current pattern (to remove for each checkpoint)

Each checkpoint currently has:
- Context usage extraction logic (KEEP THIS UNCHANGED)
- An AskUserQuestion with header, question, and Skip/Compact options
- "Skip" response handling (print message, proceed)
- "Compact" response handling (pbcopy, print command, wait for continue)

## New pattern (to replace with)

Replace each checkpoint with this structure:

```
### Compaction Checkpoint

After [phase trigger], perform these steps in order:

[context usage extraction -- PRESERVE EXACTLY as-is, including the extraction
algorithm, the <system_warning> scanning, the fallback behavior, and the
HTML comment about token usage format]

1. Copy the compaction command to the clipboard (silently):

    [existing pbcopy command -- PRESERVE EXACTLY, including the focus string
    and 2>/dev/null]

2. Print the compaction message:

    ```
    [Context: {$context_pct}% used -- {$context_remaining_k}k remaining]

    Phase N complete. Compaction prompt copied to clipboard.

    To compact: paste the command below, then type `continue` now -- it will run after compaction finishes.
    To skip: type `continue`.

        /compact focus="[EXISTING FOCUS STRING -- PRESERVE EXACTLY]"

    Run: $summary_full
    ```

    When context data is unavailable (extraction returned nothing), omit the
    `[Context: ...]` line and its trailing blank line. The message then begins
    with "Phase N complete."

3. STOP. Wait for the user's next message before doing anything else.

When the user responds with "continue" (or synonyms: "go", "next", "ok",
"resume", "proceed"), proceed to [next phase].
```

## Specific values for each checkpoint

**Post-Phase 3 checkpoint:**
- Phase trigger: "writing the synthesis to the scratch file"
- Phase number in message: "Phase 3"
- Next phase: "Phase 3.5"
- Focus string: PRESERVE the existing focus string exactly as it is in the current pbcopy command
- The HTML comment about focus strings (`<!-- Focus strings are printed verbatim...-->`) should be preserved after the printed command block

**Post-Phase 3.5 checkpoint:**
- Phase trigger: "processing all review verdicts"
- Phase number in message: "Phase 3.5"
- Next phase: "the Execution Plan Approval Gate"
- Focus string: PRESERVE the existing focus string exactly as it is in the current pbcopy command
- The HTML comment about focus strings should be preserved

## What to preserve (do NOT change)

- The context usage extraction logic (scanning, parsing, fallback) -- keep every line
- The pbcopy commands and their focus strings -- keep exact content
- The `$summary` and scratch directory interpolation rules
- The HTML comments (`<!-- ... -->`) about token usage format and focus strings
- The interpolation instruction paragraphs about `$summary` and scratch directory path
- The "Advisory Termination" section that follows the post-Phase 3 checkpoint (it skips the checkpoint in advisory mode)
- The synonym list for "continue" detection
- The `Run: $summary_full` trailing line in the printed message

## What to remove

- The AskUserQuestion call (header, question, options)
- The "Skip" response handling block
- The "Compact" response handling block and its conditional structure
- The phrase "Copied to clipboard. Paste and run:" (replaced by the new message template)
- The phrase "Type `continue` when ready to resume." (replaced by the new phrasing)
- Any references to "AskUserQuestion" within the checkpoint sections

## What NOT to touch

- Any AskUserQuestion calls OUTSIDE these two checkpoints (Phase 1 gate, Phase 3 impasse, etc.)
- The optional Phase 4 compaction note
- The Execution Plan Approval Gate or any other gates
- Anything before or after the two checkpoint sections

## Style constraints

- Follow the existing SKILL.md style: markdown with indented code blocks
- The printed message template should use indented code block style (4-space indent), matching the current pattern
- The numbered steps (1, 2, 3) provide reliable sequential execution for the model
- "STOP. Wait for the user's next message before doing anything else." must appear as step 3, exactly as written -- this is the critical instruction that replaces the implicit turn boundary AskUserQuestion provided

## Verification advisory (from test-minion)

Before: AskUserQuestion appears 21 times in SKILL.md. After your edit, it should appear exactly 19 times. Count occurrences before and after to confirm only the two compaction checkpoints were changed.

## When done

Mark task #1 as completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
