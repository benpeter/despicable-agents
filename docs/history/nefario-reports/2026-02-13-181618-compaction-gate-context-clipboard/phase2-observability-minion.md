# Phase 2: observability-minion Contribution

## Planning Question

How should the SKILL.md spec instruct the agent to parse `<system_warning>` token usage data for embedding context percentage in compaction AskUserQuestion gates? Should it look backward in context or trigger a fresh warning? What graceful degradation applies?

## Analysis

### The Signal Source: `<system_warning>` Token Usage

The `<system_warning>` attachment is injected by Claude Code after tool calls. Format:
```
Token usage: {used}/{total}; {remaining} remaining
```

This is analogous to a metrics scrape endpoint in observability: a single source of truth that must be read at the right moment to get a meaningful snapshot. The key question is freshness vs. cost.

### Recommendation: Look Backward, Do Not Trigger a Proactive Tool Call

**Use the most recent `<system_warning>` already in context.** Do not make a lightweight tool call solely to trigger a fresh warning.

Rationale:

1. **Staleness is negligible.** The compaction checkpoints fire after Phase 3 synthesis and Phase 3.5 review -- both phases involve heavy tool call activity (writing scratch files, spawning subagents, reading files). The most recent `<system_warning>` will be from the tool call that immediately precedes the gate presentation. The delta between "last tool call" and "gate display" is a few hundred tokens of orchestrator reasoning at most -- well under 1% of a 200k context window. This is fresh enough for a human decision.

2. **A proactive tool call adds cost with no value.** Any tool call (even a no-op Bash like `true`) consumes tokens, adds latency, and grows the context -- exactly the resource the user is trying to conserve. It is counterproductive to burn context tokens to measure context tokens.

3. **Reliability.** Every tool call can fail. A no-op Bash call is unlikely to fail, but any failure would require error handling logic in the spec. Looking backward at already-available data has zero failure modes.

4. **Spec simplicity.** "Parse the most recent `<system_warning>`" is a single instruction. "Make a tool call, then parse" is two instructions with an error branch. Simpler specs produce more reliable agent behavior.

### Parsing Specification

The spec should instruct the agent to:

1. **Locate**: Scan backward in the current conversation context for the most recent text matching the pattern `Token usage: {used}/{total}; {remaining} remaining`.

2. **Extract**: Parse `{used}` and `{total}` as integers. Compute percentage: `floor(used / total * 100)`.

3. **Format**: Embed as a single line at the top of the AskUserQuestion `question` field:
   ```
   [Context: {pct}% used -- {remaining} tokens remaining]
   ```
   Use `--` (double dash) rather than em-dash for terminal compatibility. Use the `{remaining}` value directly from the warning (already human-readable with unit).

4. **Variable naming**: Introduce `$context_pct` and `$context_remaining` as session-scoped derived values, computed once per compaction gate. This avoids re-parsing if the same values are needed in the `/compact` focus string or elsewhere.

### Graceful Degradation

Three degradation scenarios, ordered by likelihood:

| Scenario | Detection | Degradation |
|----------|-----------|-------------|
| **Warning present, format matches** | Regex matches `Token usage: (\d[\d,]*)/(\d[\d,]*);\s*(\d[\d,]*)\s*remaining` | Normal: embed context line |
| **Warning absent** (no tool calls preceded the gate, or Claude Code stopped injecting them) | No match found scanning backward | Omit the `[Context: ...]` line entirely. Present the gate without it. Do not warn or error -- the gate is still useful without the percentage. |
| **Warning present, format changed** | Text contains "Token usage" but does not match the expected regex | Same as absent: omit the `[Context: ...]` line. Do not attempt partial parsing. |

The key principle: **the context percentage is informational, not functional.** The compaction gate works without it -- users managed fine before this feature. Degradation should be silent omission, not an error or warning that interrupts the workflow.

The regex should account for comma-formatted numbers (e.g., `123,456`) since token counts can exceed 100k. Pattern: `Token usage: ([\d,]+)/([\d,]+); ([\d,]+) remaining`.

### Risk: Format Volatility

The `<system_warning>` format is not a documented API. It is an internal Claude Code mechanism subject to change without notice. This is the primary risk.

Mitigations:
- **Silent degradation** (above) means format changes never break the workflow.
- **The regex is simple** -- easy to update if the format evolves.
- **The spec should document the expected format** with a comment noting it is empirically observed, not contractually guaranteed. This sets expectations for future maintainers.

### Interaction with pbcopy (Issue #110)

The two features compose cleanly. The sequence at each compaction gate becomes:

1. Parse `<system_warning>` (backward scan, compute `$context_pct` and `$context_remaining`)
2. Present AskUserQuestion with context line embedded in `question`
3. On "Compact" selection: run `pbcopy` with the `/compact` command, then print the command as visible fallback

No ordering conflict. The `pbcopy` call itself will trigger a new `<system_warning>`, but this is irrelevant -- the percentage was already computed and displayed.

### Observation: Compaction Gates Use `$summary` Not `$summary_full`

The two compaction gate `question` fields currently use `$summary` (40-char) in their `Run:` line, while all other AskUserQuestion gates use `$summary_full` (120-char). This is likely an oversight from the original implementation. The spec author should consider normalizing to `$summary_full` for consistency, per the convention established in the SKILL.md AskUserQuestion note (line 507-513). This is tangential to the current issues but worth flagging since these lines are being modified anyway.

## Requirements

1. **No proactive tool calls for measurement.** Parse backward from existing context only.
2. **Silent degradation.** Missing or changed format omits the context line; never errors.
3. **Regex must handle comma-separated numbers** (token counts above 999).
4. **Context line placement**: First line of the `question` field, before the existing text, separated by a blank line.
5. **Compute once per gate.** Do not re-parse for each field that references context data.
6. **Document the format as empirical.** Include an HTML comment in SKILL.md noting the `<system_warning>` format is observed behavior, not a stable API.

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| `<system_warning>` format changes silently | Medium | Silent degradation: omit context line, gate still works |
| Claude Code stops injecting `<system_warning>` entirely | Low | Same silent degradation path |
| Agent misparses and shows wrong percentage | Low | Simple regex with integer arithmetic; floor rounding avoids floating-point edge cases |
| Percentage display creates false precision expectations | Low | Floor rounding + showing remaining tokens gives users two independent signals |

## Dependencies

- No external dependencies. Both features modify only `skills/nefario/SKILL.md`.
- The `<system_warning>` injection is a Claude Code platform behavior, not something this project controls. Changes to Claude Code could affect this feature.
- `pbcopy` (issue #110) is Mac-only, per issue owner's explicit override of cross-platform concerns.

## Suggested Spec Language

For the SKILL.md compaction checkpoint sections, the parsing instruction could read:

```markdown
<!-- The <system_warning> token usage format is empirically observed Claude Code
     behavior, not a stable API. If the format changes, the context line is
     silently omitted. -->

Before presenting the compaction AskUserQuestion, extract context usage:

1. Scan backward in conversation context for the most recent text matching:
   `Token usage: {used}/{total}; {remaining} remaining`
   (where values may contain commas as thousand separators)
2. If found: compute `$context_pct = floor(used / total * 100)`,
   retain `$context_remaining` from the matched `{remaining}` value.
3. If not found or format does not match: skip the context line (silent omission).

When context data is available, prepend to the `question` field:
`[Context: {$context_pct}% used -- {$context_remaining} tokens remaining]\n\n`
```
