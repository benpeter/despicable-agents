# Phase 3: Synthesis -- Compaction Gate Context + Clipboard

## Delegation Plan

**Team name**: compaction-gate-context-clipboard
**Description**: Embed context usage percentage and pbcopy clipboard support into both compaction checkpoint gates in SKILL.md (#112, #110)

### Task 1: Implement context usage display and pbcopy in compaction gates

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |

    ## Task

    Edit `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` to add context usage
    display and pbcopy clipboard support to both compaction checkpoint gates. Also fix
    the `$summary` to `$summary_full` bug in both gates.

    Three changes per gate (two gates total = six changes), plus one HTML comment addition.

    ## Target Locations

    1. **Post-Phase 3 compaction gate** -- starts at line 798
    2. **Post-Phase 3.5 compaction gate** -- starts at line 1210

    ## Change 1: Add context extraction instructions (BEFORE each gate)

    At each compaction checkpoint, BEFORE the AskUserQuestion bullet list, add these
    context extraction instructions:

    ```markdown
    <!-- The <system_warning> token usage format ("Token usage: {used}/{total};
         {remaining} remaining") is empirically observed Claude Code behavior, not a
         stable API. If the format changes, the context line is silently omitted. -->

    Before presenting the AskUserQuestion, extract context usage from the most recent
    `<system_warning>` in the conversation:

    1. Scan backward for the most recent text matching:
       `Token usage: {used}/{total}; {remaining} remaining`
       (values may contain commas as thousand separators)
    2. If found: compute `$context_pct = floor(used / total * 100)` and
       `$context_remaining_k = floor(remaining / 1000)` (strip commas before arithmetic).
    3. If not found or format does not match: skip the context line (silent omission).
    ```

    IMPORTANT: The HTML comment should appear only ONCE, at the first compaction checkpoint
    (Post-Phase 3, ~line 798). The second checkpoint (Post-Phase 3.5) should have the
    extraction instructions but not a duplicate of the HTML comment.

    ## Change 2: Update the `question` field in each AskUserQuestion

    **Post-Phase 3 gate** -- replace the current `question` value:

    FROM:
    ```
    - `question`: "Phase 3 complete. Specialist details are now in the synthesis. Compact context before continuing?\n\nRun: $summary"
    ```

    TO:
    ```
    - `question`: "[Context: {$context_pct}% used -- {$context_remaining_k}k remaining]\n\nPhase 3 complete. Specialist details are now in the synthesis. Compact context before continuing?\n\nRun: $summary_full"
    ```

    **Post-Phase 3.5 gate** -- replace the current `question` value:

    FROM:
    ```
    - `question`: "Phase 3.5 complete. Review verdicts are folded into the plan. Compact context before execution?\n\nRun: $summary"
    ```

    TO:
    ```
    - `question`: "[Context: {$context_pct}% used -- {$context_remaining_k}k remaining]\n\nPhase 3.5 complete. Review verdicts are folded into the plan. Compact context before execution?\n\nRun: $summary_full"
    ```

    When context data is unavailable (step 3 above), the `[Context: ...]` prefix line
    and its trailing `\n\n` are omitted entirely -- the question falls back to the
    original text (with `$summary_full`).

    ## Change 3: Add pbcopy to the "Compact" response handling in each gate

    In each gate's **"Compact" response handling** section, add a silent pbcopy call
    BEFORE the existing "Copy and run:" print block. The pbcopy loads the `/compact`
    command onto the clipboard so the user can paste directly.

    **Post-Phase 3 "Compact" response handling** -- insert before "Copy and run:":

    ```markdown
    Silently copy the `/compact` command to the clipboard (Mac-only, no error surfacing):

    ```bash
    echo '/compact focus="Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, $summary, scratch directory path. Discard: individual specialist contributions from Phase 2."' | pbcopy 2>/dev/null
    ```

    The `$summary` and scratch directory path in the pbcopy command must be interpolated
    to their actual resolved values, matching the printed code block below.

    Then print:
    ```

    And change the "Copy and run:" line to "Copied to clipboard. Paste and run:" to
    reflect that the command is already on the clipboard. Keep the existing code block
    and "Type `continue`..." instruction unchanged.

    **Post-Phase 3.5 "Compact" response handling** -- same pattern with the Phase 3.5
    focus string:

    ```bash
    echo '/compact focus="Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, $summary, scratch directory path, skills-invoked. Discard: individual review verdicts, Phase 2 specialist contributions, raw synthesis input."' | pbcopy 2>/dev/null
    ```

    Same interpolation rule. Same "Copied to clipboard. Paste and run:" wording change.

    ## Precise Edit Locations

    **Post-Phase 3 gate** (current lines ~798-828):
    - INSERT context extraction instructions between line 799 ("using AskUserQuestion:")
      and line 801 ("- `header`: "P3 Compact"")
    - REPLACE line 802 (question field) with new question including context prefix and $summary_full
    - INSERT pbcopy block in "Compact" response handling (after line 811, before line 812)
    - CHANGE "Copy and run:" (line 814) to "Copied to clipboard. Paste and run:"

    **Post-Phase 3.5 gate** (current lines ~1208-1240):
    - INSERT context extraction instructions between line 1211 ("AskUserQuestion:")
      and line 1213 ("- `header`: "P3.5 Compact"")
    - REPLACE line 1214 (question field) with new question including context prefix and $summary_full
    - INSERT pbcopy block in "Compact" response handling (after line 1223, before line 1224)
    - CHANGE "Copy and run:" (line 1226) to "Copied to clipboard. Paste and run:"

    ## What NOT to Do

    - Do NOT modify any other AskUserQuestion gates (there are many in SKILL.md)
    - Do NOT add error handling or user-visible warnings for pbcopy failure
    - Do NOT add a proactive tool call to trigger a fresh `<system_warning>`
    - Do NOT modify the focus strings themselves (only add the pbcopy echo wrapper)
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

- **Deliverables**: Updated `skills/nefario/SKILL.md` with context usage display and pbcopy at both compaction checkpoints
- **Success criteria**:
  - Both compaction gate `question` fields include `[Context: {$context_pct}% used -- {$context_remaining_k}k remaining]` prefix
  - Both gate `question` fields end with `$summary_full` (not `$summary`)
  - Both "Compact" response handlers include silent `pbcopy 2>/dev/null` before the printed code block
  - Graceful degradation: context line omitted when `<system_warning>` data unavailable
  - One HTML comment documenting the empirical format
  - No other SKILL.md sections modified

### Cross-Cutting Coverage

- **Testing**: Not applicable. This is a spec-only change to a SKILL.md file -- no executable code, no testable runtime behavior. The changes are verified by visual inspection of the edited file.
- **Security**: Not applicable. pbcopy writes to the local clipboard only, no network activity, no secrets handling, no user input processing. The `2>/dev/null` suppresses errors without masking security issues.
- **Usability -- Strategy**: Covered by devx-minion in the task prompt. The context line placement (first line, before prose) follows information hierarchy principles -- decision-critical data first. The pbcopy timing (on "Compact" selection only) respects the user's clipboard as private workspace.
- **Usability -- Design**: Not applicable. No UI components -- this is terminal text in an AskUserQuestion prompt.
- **Documentation**: The change IS documentation (SKILL.md is the spec). The HTML comment documents the empirical `<system_warning>` format. No external docs needed.
- **Observability**: Not applicable. No runtime components. The observability-minion's contribution was about parsing an observability signal (token usage), which is incorporated into the task prompt's extraction instructions.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none -- this is a single-file spec edit with no UI components, no runtime code, no web-facing output, no multi-service coordination, and no end-user documentation changes.
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

**Context line remaining tokens format**: devx-minion recommended `{remaining_k}k remaining` (abbreviated). observability-minion recommended `{remaining} tokens remaining` (full token count from `<system_warning>`). **Resolution**: Use the abbreviated format `{remaining_k}k remaining`. Rationale: The gate renders in a terminal where horizontal space matters. `56k remaining` conveys the same information as `56,000 tokens remaining` in less than half the characters. The `k` suffix is universally understood by the developer audience. Dropping "tokens" (the unit is implied by context) follows the Helix Manifesto's "Lean and Mean" principle.

**pbcopy timing**: devx-minion initially considered "before gate" then revised to "on Compact selection only". observability-minion listed the sequence as pbcopy after selection. **Resolution**: No conflict -- both converged on pbcopy in the "Compact" response handling, not before the gate. This avoids overwriting the user's clipboard when they choose "Skip".

**$summary bug**: Both specialists independently identified the `$summary` to `$summary_full` bug. No conflict. Included as part of this change.

### Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| `<system_warning>` format changes silently | Medium | Silent degradation: omit context line, gate still works. HTML comment documents the format as empirical. |
| Claude Code stops injecting `<system_warning>` | Low | Same silent degradation path -- gate works without context line |
| AskUserQuestion question field length | Low | Additions are modest (~50 chars context line + ~80 chars summary_full upgrade). Well under any practical limit. |
| pbcopy unavailable (non-Mac, CI, container) | Low | `2>/dev/null` suppresses errors silently. Printed code block is always the fallback. |
| Clipboard overwrite on "Compact" | Negligible | User explicitly chose "Compact", signaling intent to run the command. Overwriting clipboard with the needed command is helpful. |

### Execution Order

Single task, no dependencies. One batch:

```
Batch 1: Task 1 (devx-minion, opus, bypassPermissions)
```

No approval gates. Changes are additive and fully reversible.

### Verification Steps

1. Read the modified SKILL.md and verify both compaction checkpoints contain:
   - Context extraction instructions before the AskUserQuestion
   - Updated `question` with `[Context: ...]` prefix and `$summary_full` suffix
   - pbcopy in "Compact" response handling
   - "Copied to clipboard. Paste and run:" wording
2. Verify no other sections of SKILL.md were modified (diff should show changes only in the two compaction checkpoint regions)
3. Verify the HTML comment appears exactly once
