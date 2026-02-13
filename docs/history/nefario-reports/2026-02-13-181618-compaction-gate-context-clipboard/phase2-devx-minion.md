# DevX Planning Contribution: Compaction Gate Context + Clipboard

## Planning Question

> What is the best placement and formatting of the context percentage within the AskUserQuestion question text? Should it go before the existing question, after it, or replace part of it? Should the pbcopy be a silent Bash call before the AskUserQuestion, or should its success/failure be surfaced?

## Analysis

### Current Gate Structure

Both compaction gates follow the same pattern:

```
- header: "P3 Compact" / "P3.5 Compact"
- question: "<phase status>. <what was preserved>. Compact context before <next phase>?\n\nRun: $summary"
- options: Skip (recommended) / Compact
```

The question text is a single string rendered by AskUserQuestion. When the gate fires, it **replaces the visible terminal area** -- the user sees only the header, question, and options. The status line (which normally shows context percentage) is occluded.

The question field has a required trailing convention: `\n\nRun: $summary_full` (note: the current gates incorrectly use `$summary` instead of `$summary_full` -- this should be fixed as part of this change).

### Constraint Inventory

1. **Header**: max 12 chars. Current values ("P3 Compact", "P3.5 Compact") are 10 and 12 chars respectively. No room to embed context info here.
2. **Question**: free-form text, but must end with `\n\nRun: $summary_full`.
3. **Options**: label + description pairs. Not suitable for dynamic data.
4. **AskUserQuestion rendering**: the question text is the primary readable area. It must be scannable -- the user needs to make a quick decision (skip or compact).

## Recommendations

### 1. Context Line Placement: BEFORE the existing question text, as first line

**Recommendation**: Place the context usage line as the **first line** of the question, separated by a blank line from the rest.

**Rationale (information hierarchy for decision-making)**:

The context percentage is the **primary input to the user's decision**. The user sees the gate and needs to answer: "Should I compact?" The answer depends almost entirely on how much context is consumed. The phase status ("Phase 3 complete") is confirming information they already know. Therefore the context info must be the first thing they read.

Placing it after the question text buries the decision-critical signal below the prompt. Placing it inline within the question sentence makes the sentence harder to parse. Placing it as a leading line gives it visual prominence and keeps it separate from the prose.

**Proposed question format (Phase 3)**:

```
"[Context: 72% used -- 56k remaining]\n\nPhase 3 complete. Specialist details are now in the synthesis. Compact context before continuing?\n\nRun: $summary_full"
```

**Proposed question format (Phase 3.5)**:

```
"[Context: 72% used -- 56k remaining]\n\nPhase 3.5 complete. Review verdicts are folded into the plan. Compact context before execution?\n\nRun: $summary_full"
```

### 2. Context Line Formatting

**Recommendation**: `[Context: {pct}% used -- {remaining_k}k remaining]`

**Design choices**:

- **Square brackets**: visually distinct from prose. Signal that this is a status indicator, not a sentence. Consistent with how status/metadata lines appear in terminal UIs.
- **Percentage first**: the most actionable number. "72% used" immediately tells the user whether they are in danger territory. The absolute remaining tokens are secondary context.
- **Abbreviated remaining tokens**: `56k remaining` not `56,000 tokens remaining`. Terminal output should be compact. The unit "k" is universally understood by developers. Drop the word "tokens" -- it adds length without adding clarity.
- **Em dash separator**: `--` (double hyphen, rendered as em dash in the spec) between percentage and remaining. Visually separates the two data points.
- **No color/emoji**: AskUserQuestion question text is rendered by Claude Code's prompt UI, not by the agent's terminal output. The agent cannot control formatting within the question field. Keep it plain text.

**Graceful degradation**: If the `<system_warning>` token usage data is unavailable or unparseable, omit the context line entirely. Do not show `[Context: unknown]` or similar. The gate should still function -- the user can always decide based on their own judgment. The SKILL.md spec should say: "If token usage cannot be determined, omit the context line and present the gate without it."

### 3. pbcopy: Silent Bash Call BEFORE the AskUserQuestion

**Recommendation**: Execute `pbcopy` as a silent Bash call **before** the AskUserQuestion fires. Do not surface success or failure.

**Rationale**:

- **Before, not after the option selection**: The clipboard should be loaded when the gate appears, not after the user picks "Compact". Why? Because the user reads the gate, decides "yes, I need to compact", selects "Compact", and then the instruction says "Copy and run: `/compact ...`". If the command is already on the clipboard when they see this instruction, they just paste. Zero friction. If we pbcopy after option selection, there is a timing issue -- the printed code block and the paste action happen in the same breath, which is fine, but loading the clipboard earlier means the command is ready the instant the user needs it.
- **Silent (no output surfaced)**: `pbcopy` either works or it doesn't. If it fails (non-Mac, pbcopy not in PATH, etc.), the printed code block is the fallback. There is nothing actionable the user can do about a clipboard failure -- telling them "clipboard copy failed" just adds noise. The printed code block is always there.
- **Implementation**: `echo '/compact focus="..."' | pbcopy 2>/dev/null` -- redirect stderr to suppress any error output. No need to check exit code.

**When to pbcopy**: The pbcopy should fire **unconditionally** before the AskUserQuestion, not only after the user selects "Compact". Reason: the user might read the gate, realize they want to compact, and hit Ctrl+C to manually run the command rather than selecting the option. Having it on the clipboard already covers this path.

Actually, on reconsideration: the pbcopy should happen **only when the "Compact" option is selected**, not before the gate. Here is why:

- The `/compact` command includes a long `focus=` string that varies by phase. Loading it onto the clipboard preemptively overwrites whatever the user had on their clipboard, even if they choose "Skip". That is a violation of the principle of least surprise -- the user's clipboard is their private workspace, and we should not modify it without a clear signal that they want the clipboard action.
- The "Compact" selection is that signal. After "Compact" is selected, the printed code block appears. At that point, also execute `pbcopy` silently. The user pastes immediately.

**Final recommendation**: pbcopy fires in the **"Compact" response handling** section, right before (or alongside) the printed code block. Not before the AskUserQuestion gate.

### 4. Pre-Gate Sequence

The full pre-gate sequence becomes:

1. **Parse `<system_warning>` token usage** (or make a lightweight tool call to trigger one, per observability-minion's recommendation). Extract `used`, `total`, `remaining`. Compute `pct = round(used / total * 100)` and `remaining_k = round(remaining / 1000)`.
2. **Construct AskUserQuestion** with context line if available, without if not.
3. **Fire AskUserQuestion**.
4. **On "Compact" selection**: execute `echo '<compact command>' | pbcopy 2>/dev/null`, then print the code block with "Copy and run:" instructions.
5. **On "Skip" selection**: proceed without clipboard modification.

### 5. Pre-existing Bug: `$summary` vs `$summary_full`

Both compaction gates currently end their question with `\n\nRun: $summary` (40-char). The AskUserQuestion convention at line 507-513 specifies `\n\nRun: $summary_full` (120-char). This should be corrected as part of this change. The `$summary_full` gives the user enough context to identify which orchestration run the gate belongs to, which matters when AskUserQuestion occludes the status line.

## Risks and Dependencies

### Risks

1. **AskUserQuestion question field length**: Adding a context line and switching to `$summary_full` makes the question longer. Risk: if AskUserQuestion has an undocumented length limit, the text could be truncated. **Mitigation**: the additions are modest (~50 chars for context line, ~80 chars for summary_full upgrade). Total question length stays well under 500 chars. No known length limit in Claude Code's AskUserQuestion.

2. **Clipboard overwrite on "Compact"**: Even when scoped to the "Compact" response, pbcopy still overwrites the clipboard. **Mitigation**: the user explicitly chose "Compact", signaling intent to run the command. Overwriting the clipboard with the command they need is helpful, not surprising.

3. **pbcopy unavailability**: On non-Mac systems or in environments where pbcopy is not available. **Mitigation**: `2>/dev/null` suppresses errors. Printed code block is always the fallback. No user-visible failure.

### Dependencies

1. **Observability-minion consultation**: The context percentage extraction depends on how the spec instructs the agent to obtain `<system_warning>` data (look backward vs. trigger fresh). This planning contribution assumes the data is available by the time the gate fires. The observability-minion should define the parsing instructions and graceful degradation rules.

2. **No code dependencies**: Both changes are spec-only (SKILL.md text). No runtime dependencies, no new tools, no new libraries.

## Requirements Summary

| Requirement | Detail |
|------------|--------|
| Context line format | `[Context: {pct}% used -- {remaining_k}k remaining]` |
| Context line placement | First line of question, separated by `\n\n` from rest |
| Context line fallback | Omit entirely if token data unavailable |
| pbcopy timing | On "Compact" selection, before printing code block |
| pbcopy implementation | `echo '...' \| pbcopy 2>/dev/null` (silent, no exit code check) |
| pbcopy fallback | Printed code block always present |
| Summary fix | Change `$summary` to `$summary_full` in both gates |
| Locations | Post-Phase 3 (~line 802) and Post-Phase 3.5 (~line 1214) |
