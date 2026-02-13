## Task

Edit `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` to add context usage
display and pbcopy clipboard support to both compaction checkpoint gates. Also fix
the `$summary` to `$summary_full` bug in both gates.

Three changes per gate (two gates total = six changes), plus one HTML comment addition.

## Target Locations

1. **Post-Phase 3 compaction gate** -- search for `### Compaction Checkpoint` after the line about "Advisory Termination"
2. **Post-Phase 3.5 compaction gate** -- search for the second `### Compaction Checkpoint`

## Change 1: Add context extraction instructions (BEFORE each gate)

At each compaction checkpoint, BEFORE the AskUserQuestion bullet list, add context
extraction instructions.

At the FIRST checkpoint only, include an HTML comment explaining the empirical format.
At the second checkpoint, include only the extraction instructions (no duplicate HTML comment).

## Change 2: Update the `question` field in each AskUserQuestion

Add `[Context: {$context_pct}% used -- {$context_remaining_k}k remaining]` as the first line,
and fix `$summary` to `$summary_full` in the Run: line.

When context data is unavailable, the `[Context: ...]` prefix and its trailing `\n\n` are
omitted entirely.

## Change 3: Add pbcopy to the "Compact" response handling

In each gate's "Compact" response handling section, add a silent pbcopy call BEFORE
the existing print block. Change "Copy and run:" to "Copied to clipboard. Paste and run:".

The pbcopy echo command must include the SAME focus string as the printed code block below it.
The `$summary` and scratch directory path in the pbcopy command must be interpolated
to their actual resolved values, matching the printed code block.

## What NOT to Do

- Do NOT modify any other AskUserQuestion gates
- Do NOT add error handling or user-visible warnings for pbcopy failure
- Do NOT add a proactive tool call to trigger a fresh `<system_warning>`
- Do NOT modify the focus strings themselves
- Do NOT change the gate options, headers, or response handling flow
- Do NOT duplicate the HTML comment at the second checkpoint
- Do NOT add any frameworks, dependencies, or new files

## Verification

After editing, confirm:
1. Both compaction gates have context extraction instructions before the AskUserQuestion
2. Both `question` fields start with `[Context: ...]` and end with `$summary_full`
3. Both "Compact" response handlers have pbcopy before the printed code block
4. Both printed code blocks say "Copied to clipboard. Paste and run:"
5. The HTML comment about empirical format appears once (at Post-Phase 3 only)
6. No other sections of SKILL.md were modified

Report back with file paths, change scope, and line counts.
