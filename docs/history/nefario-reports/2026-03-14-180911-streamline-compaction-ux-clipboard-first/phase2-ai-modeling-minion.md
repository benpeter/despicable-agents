# Phase 2: AI Modeling Minion -- Compaction Flow Prompt Engineering

## Planning Question

> How to encode the unconditional-copy flow in SKILL.md so nefario reliably:
> (a) always runs pbcopy, (b) always prints the message, (c) waits for paste-and-compact
> or "continue", (d) does not get confused by the absence of an AskUserQuestion gate?
> Should context-usage extraction still be included?

## Analysis

### Current control flow (both checkpoints)

```
AskUserQuestion gate
  |
  +-- "Skip" --> print "Continuing..." --> proceed
  +-- "Compact" --> pbcopy --> print command --> wait for "continue" --> proceed
```

The AskUserQuestion gate creates an explicit branch point that the model is
fine-tuned to handle. Removing it changes the interaction from a structured
tool-mediated choice to a freeform wait-for-user-input pattern. This is the
key prompt engineering concern: Claude models are highly reliable at following
structured tool calls (AskUserQuestion produces a guaranteed user response in a
known format), but freeform "wait for user to say X or do Y" patterns require
more careful prompt design to avoid the model continuing without waiting or
misinterpreting the user's response.

### Proposed control flow

```
Always: pbcopy --> print message --> wait
  |
  User pastes /compact --> compaction runs --> user types "continue" --> proceed
  User types "continue" directly --> proceed (skip compaction)
```

### Key prompt engineering risks

1. **Model may not actually wait.** Without AskUserQuestion forcing a turn
   boundary, the model must be instructed to stop generating and yield control.
   The strongest signal for this is an explicit instruction to STOP and wait
   for user input, placed as the final directive in the block. Claude 4.x
   models respect "stop here and wait for the user's next message" when it is
   unambiguous and positioned at the end of an instruction block.

2. **Ambiguous response classification.** The model must distinguish between:
   - User pasted the /compact command (compaction will run externally)
   - User typed "continue" (skip compaction)
   - User typed something else (clarify)

   In the current flow, AskUserQuestion resolves this cleanly. Without it,
   the model sees raw user text. However, this is actually simpler than it
   sounds: if the user pastes /compact, Claude Code intercepts it as a slash
   command -- the model never sees the paste as a message. The user's next
   typed message after compaction finishes is "continue". So the model only
   ever sees "continue" (or synonyms) as the resume signal, regardless of
   whether compaction happened.

3. **Post-compaction context loss.** After /compact runs, the conversation
   context is rewritten. The compaction focus string preserves the phase state
   and next step, so the model should know to resume. The existing focus
   strings already handle this. The instruction to proceed should be
   phrased so it works both pre- and post-compaction (the model may or
   may not remember the exact instruction text after compaction).

### Recommended prompt structure

Replace each checkpoint block with a three-part unconditional sequence:

**Part 1: Context extraction (keep it).** The context-usage extraction should
be retained. It provides valuable information to the user for deciding whether
to compact. The `[Context: ...]` prefix in the printed message helps the user
make an informed decision without adding any model complexity. If the data is
unavailable, the silent-omission fallback already handles it gracefully.

**Part 2: Unconditional action block.** Structure as a numbered sequence, not
conditional branches. This is the critical change. Numbered steps are the most
reliable instruction format for Claude -- the model follows them sequentially
without skipping. The block should read:

```
### Compaction Checkpoint

After [phase trigger], perform these steps in order:

1. Extract context usage [same extraction logic as today]
2. Copy the /compact command to the clipboard:
   [pbcopy command]
3. Print the compaction message:
   [message template]
4. STOP. Wait for the user's next message before doing anything else.
```

The "STOP. Wait for the user's next message" is the critical instruction.
It replaces the implicit turn boundary that AskUserQuestion provided. On
Claude 4.x, an explicit stop-and-wait instruction at the end of a numbered
sequence is highly reliable. Do NOT soften this with "you may want to wait"
or "pause here" -- use imperative "STOP" and "Wait".

**Part 3: Resume handling.** After the stop, specify what to do when the user
responds:

```
When the user responds with "continue" (or synonyms: "go", "next", "ok",
"resume", "proceed"), proceed to [next phase].
```

This is unchanged from today and works the same whether the user compacted
or skipped. The /compact command is handled by Claude Code, not the model,
so the model's next input is always the user's "continue" message.

### Message template design

The printed message should be a single block that presents both options
clearly. Proposed template (P3 version):

```
[Context: {$context_pct}% used -- {$context_remaining_k}k remaining]

Phase 3 complete. Compaction prompt copied to clipboard.

To compact: paste and run the command below, then queue `continue`.
To skip: type `continue`.

    /compact focus="Preserve: current phase (3.5 review next), ..."

Run: $summary_full
```

Key design choices:
- "Compaction prompt copied to clipboard" -- states the fait accompli
- "paste and run the command below, then queue `continue`" -- the word "queue"
  signals that the user types it immediately (it executes after compaction
  finishes), addressing the "type continue once you are ready" misleading
  phrasing from the success criteria
- "To skip: type `continue`" -- clear alternative on its own line
- The /compact command is still printed as a fallback (clipboard may fail)
- `Run: $summary_full` trailing line preserved per AskUserQuestion convention
  (even though this is no longer an AskUserQuestion, the identification
  purpose remains valid)

### Post-compaction "queue" wording

The success criteria specifically call out changing "type continue once you are
ready" to "queue continue." The word "queue" is precise: in Claude Code, if the
user types "continue" while compaction is running, the message is queued and
delivered once compaction completes. The instruction "then queue `continue`"
tells the user they can type it immediately without waiting for compaction to
finish. This is a meaningful UX improvement.

### Should the `\n\nRun: $summary_full` convention be preserved?

Yes. The SKILL.md has a global convention (lines 507-513) that every gate's
question field ends with `\n\nRun: $summary_full`. Even though this is no
longer an AskUserQuestion, the identification purpose applies to any user-facing
checkpoint message. The user needs to know which orchestration run a checkpoint
belongs to, and the status line may be hidden by terminal output. Keep the
trailing `Run:` line.

## Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Model continues generating instead of stopping after print | Medium | Explicit "STOP. Wait for the user's next message" as final step. Numbered-step format ensures sequential execution. |
| pbcopy fails silently (SSH session, non-macOS) | Low | Command already uses `2>/dev/null`. Printed fallback ensures user can still copy manually. No change needed. |
| Model misinterprets user's "continue" after compaction as something else | Low | Synonym list is already established and works today. No change. |
| Post-compaction model forgets to proceed | Low | Focus string already includes "current phase (X next)". The compacted context explicitly tells the model what to do next. No change needed. |
| Other AskUserQuestion gates in SKILL.md are affected | None | Change is scoped to the two compaction checkpoint blocks only. All other gates keep AskUserQuestion. |

## Requirements for Implementation

1. **Replace both compaction checkpoint blocks** (post-Phase 3, ~lines 796-852;
   post-Phase 3.5, ~lines 1312-1355) with the unconditional sequence pattern.

2. **Preserve context-usage extraction logic** -- the extraction algorithm
   (scan backward, parse token usage, compute percentages, silent omission
   fallback) is unchanged.

3. **Preserve the pbcopy commands exactly** -- the focus strings and
   interpolation rules are unchanged.

4. **Update the printed message** to the new template (fait accompli framing,
   two clear options, "queue" wording).

5. **Add explicit STOP instruction** after the print step.

6. **Update resume handling** to remove the AskUserQuestion response-specific
   framing ("Skip" / "Compact" response handling) and replace with a single
   "When the user responds" block.

7. **Preserve the advisory-mode skip** for the post-Phase 3 checkpoint
   (lines 854-868 are unaffected -- advisory mode skips the checkpoint entirely).

8. **No changes to the optional Phase 4 compaction note** (lines 1751-1753) --
   that is already a separate, informal checkpoint.

## Dependencies

- No dependencies on other specialists. This is a self-contained SKILL.md text change.
- The pbcopy behavior, /compact slash command handling, and Claude Code message
  queuing are all existing platform behaviors that do not change.

## Specialist Sufficiency

No additional specialists needed beyond what is already planned. This is a
prompt engineering change to a single file with well-understood control flow
patterns.

## Estimated Scope

Two parallel edits to the same file (SKILL.md), each replacing ~55 lines of
conditional AskUserQuestion logic with ~35 lines of unconditional sequence
logic. Net reduction of ~40 lines. Both edits follow the identical pattern,
differing only in phase number, focus string content, and next-phase target.
