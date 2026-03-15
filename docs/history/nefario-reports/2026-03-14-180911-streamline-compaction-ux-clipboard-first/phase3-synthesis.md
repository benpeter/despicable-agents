## Delegation Plan

**Team name**: streamline-compaction-ux-clipboard-first
**Description**: Remove the AskUserQuestion gate from both compaction checkpoints in SKILL.md. Replace with an unconditional clipboard-copy-then-wait pattern that eliminates a redundant confirmation step.

### Conflict Resolution: "queue" vs "now"

Both specialists agree the user should type `continue` immediately without waiting for compaction to finish. The disagreement is wording:

- **ai-modeling-minion** prefers "queue `continue`" -- technically precise about Claude Code's message queuing behavior.
- **ux-strategy-minion** prefers "type `continue` now" -- avoids system jargon, uses cause-and-effect framing.

**Resolution**: Use ux-strategy-minion's phrasing. "Queue" is a system internals term that describes *how* the platform handles the input, not *what the user should do*. The user's mental model is "I type something, it happens." The phrase "type `continue` now -- it will run after compaction finishes" tells the user exactly what to do (type now) and what will happen (runs later), without requiring them to understand message queuing. This aligns with Nielsen H2 (match between system and real world).

The post-compaction line becomes: `Type \`continue\` now -- it will run after compaction finishes.`

The pre-compaction "skip" option becomes: `type \`continue\` to skip.`

### Task 1: Replace both compaction checkpoints in SKILL.md
- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are editing the nefario orchestration skill to streamline the compaction flow.

    ## File
    `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    ## What to change

    There are exactly two "Compaction Checkpoint" sections in SKILL.md that must be updated:

    1. **Post-Phase 3 checkpoint** (starts around line 796, `### Compaction Checkpoint` after synthesis)
    2. **Post-Phase 3.5 checkpoint** (starts around line 1312, `### Compaction Checkpoint` after review verdicts)

    For EACH checkpoint, replace the current AskUserQuestion-based conditional flow with an unconditional clipboard-first sequence. The transformation is identical for both checkpoints -- only the phase number, focus string, phase-completion sentence, and next-phase target differ.

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
    - The `Run: $summary_full` convention note at lines 507-513
    - The optional Phase 4 compaction note at lines 1751-1753
    - The Execution Plan Approval Gate or any other gates
    - Anything before or after the two checkpoint sections

    ## Style constraints

    - Follow the existing SKILL.md style: markdown with indented code blocks
    - The printed message template should use indented code block style (4-space indent), matching the current pattern
    - The numbered steps (1, 2, 3) provide reliable sequential execution for the model
    - "STOP. Wait for the user's next message before doing anything else." must appear as step 3, exactly as written -- this is the critical instruction that replaces the implicit turn boundary AskUserQuestion provided

- **Deliverables**: Updated `skills/nefario/SKILL.md` with both compaction checkpoints replaced
- **Success criteria**:
    - Both checkpoints use the unconditional clipboard-first pattern
    - No AskUserQuestion remains in either compaction checkpoint
    - Context usage extraction logic is preserved identically
    - pbcopy commands and focus strings are preserved identically
    - The printed message includes context usage, fait-accompli framing, both options, and `Run: $summary_full`
    - "STOP. Wait for the user's next message" appears as the final step in each checkpoint
    - Advisory Termination section is untouched
    - All other AskUserQuestion gates in the file are untouched

### Cross-Cutting Coverage

- **Testing**: Not included. This is a text-only change to a prompt file (SKILL.md). There are no executable tests for SKILL.md content. The success criteria verify correctness by inspection. The "no behavioral regression" criterion from the task is covered by the success criteria requiring all non-compaction sections remain untouched.
- **Security**: Not included. No auth, no user input processing, no secrets, no new attack surface. The clipboard operation is unchanged (existing pbcopy with stderr suppression).
- **Usability -- Strategy**: Covered. ux-strategy-minion contributed to Phase 2 planning and their recommendations (eliminate gate, use freeform wait, retain context display, "now" wording) are incorporated in the task prompt.
- **Usability -- Design**: Not included. No visual UI components. This is a CLI text interaction pattern.
- **Documentation**: Not included. SKILL.md is the documentation -- it is being updated directly. No separate docs needed for an internal workflow change.
- **Observability**: Not included. No runtime components, no logging, no metrics.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none -- the plan has a single task modifying one prompt file with no UI, no web output, no runtime components, and no user-facing documentation changes
- **Not selected**: ux-design-minion (no UI components), accessibility-minion (no web UI), sitespeed-minion (no web runtime), observability-minion (no runtime components), user-docs-minion (no end-user documentation impact)

### Conflict Resolutions

| Conflict | Resolution |
|----------|------------|
| "queue `continue`" (ai-modeling) vs "type `continue` now" (ux-strategy) | Adopted ux-strategy phrasing: "type `continue` now -- it will run after compaction finishes." "Queue" is system jargon; "now" with a cause-and-effect explanation achieves the same goal in user-facing language. |
| Whether to always print the command (ux-strategy req #1) vs clipboard-first with fallback (ai-modeling) | Both agree: always print. The printed command serves as clipboard fallback and gives the user confidence about what was copied. No actual conflict -- both contributions include this. |

### Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Model continues generating instead of stopping after print | Medium | Explicit "STOP. Wait for the user's next message before doing anything else." as numbered step 3. Claude 4.x reliably respects imperative stop instructions at the end of numbered sequences. |
| Clipboard overwrite destroys user's prior clipboard content | Low | The message announces the clipboard change explicitly (fait-accompli framing). The command is also printed as manual-copy fallback. Users are in an active CLI session at a natural pause point. |
| "continue" ambiguity (skip vs resume) | Low | Context disambiguates: before paste, "continue" means skip. After /compact runs, "continue" means resume. The message wording makes each meaning clear at each point. |
| pbcopy fails on non-macOS or SSH | Low | Existing `2>/dev/null` suppression. The printed command is the fallback. This is unchanged from today -- the only difference is it now runs every time, not only on the "Compact" branch. |

### Execution Order

```
Batch 1: Task 1 (ai-modeling-minion edits SKILL.md)
   |
   v
Phase 3.5: Architecture review (5 mandatory reviewers)
   |
   v
Approval gate
```

Single task, no parallelism needed, no approval gates within execution (the change is easy to reverse and has no downstream dependents within the plan).

### Verification Steps

1. Open `skills/nefario/SKILL.md` and locate both "### Compaction Checkpoint" sections
2. Verify neither section contains "AskUserQuestion", "Skip", or "Compact" option labels
3. Verify both sections contain the numbered 1-2-3 step pattern ending with "STOP. Wait"
4. Verify the printed message includes: context line, "Compaction prompt copied to clipboard", both "To compact:" and "To skip:" lines, the /compact command, and `Run: $summary_full`
5. Verify the pbcopy commands and focus strings are character-identical to the originals
6. Verify the context usage extraction logic (scanning, parsing, fallback) is unchanged
7. Verify the Advisory Termination section is untouched
8. Verify no other AskUserQuestion in the file was modified (search for "AskUserQuestion" -- should still appear in Phase 1, impasse, execution plan approval, and other gates)
