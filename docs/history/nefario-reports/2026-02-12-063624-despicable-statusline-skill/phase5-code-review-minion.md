# Code Review: despicable-statusline SKILL.md

## VERDICT: APPROVE

The SKILL.md is well-structured, complete against the spec, and follows established skill patterns. All four config states are covered with appropriate branching logic. The shell commands are correct, and the skill includes proper safety measures (backup, validation, rollback).

## FINDINGS

### Correctness

**ADVISE**: Lines 44-46 -- Default command readability

The default command is a 300+ character single-line shell snippet. While functionally correct, it is difficult to audit for correctness in the SKILL.md file itself.

**FIX**: Consider adding a comment above the command explaining the flow:
```
# Flow: read input → extract dir/model/used%/sid → build result → append nefario status → echo
```

This does NOT need to block approval. The command is correct and matches the synthesis spec exactly. The fix is a readability improvement for future maintainers.

---

**NIT**: Line 45 -- Shell command could use more defensive quoting

The default command uses `$dir`, `$model`, `$used`, etc. without quoting. If any of these extracted values contain spaces or special chars, the result string could break.

**FIX**: Recommend adding quotes in future revisions:
```sh
result="\"$dir\" | \"$model\""
```

However, in practice these values come from Claude Code's JSON context (session_id, model.display_name, workspace.current_dir) which are sanitized, so this is a theoretical concern. Not blocking.

---

### Completeness Against Spec

- **State A (no statusLine)**: Covered (lines 40-48). Uses jq to set full default command.
- **State B (inline statusLine without nefario)**: Covered (lines 50-62). Appends snippet before `echo "$result"`.
- **State C (already has nefario)**: Covered via idempotency check (lines 28-34).
- **State D (non-standard format)**: Covered (lines 66-79). Provides manual instructions rather than modifying.

All four states from the synthesis plan are implemented correctly.

---

### Idempotency

**Line 30**: The idempotency check looks for `nefario-status-` substring in the `statusLine` `command` value. This is correct and matches the synthesis spec (line 69 of phase3-synthesis.md).

However, the instructions say "Check if the string `nefario-status-` appears anywhere in the `statusLine` `command` value" but do not explicitly instruct Claude Code on HOW to check.

**ADVISE**: Add implementation guidance:

```diff
- Check if the string `nefario-status-` appears anywhere in the `statusLine` `command` value. If it does, output and stop:
+ Check if the string `nefario-status-` appears anywhere in the `statusLine` `command` value (read via jq: `jq -r '.statusLine.command // ""' ~/.claude/settings.json`). If it does, output and stop:
```

This makes the skill more actionable for Claude Code. Not blocking, as Claude Code will likely infer the correct approach from context.

---

### Safety Measures

**Lines 82-89**: Excellent safety coverage. The workflow includes:
1. Pre-write JSON validation (`jq empty`)
2. Backup creation (`.backup-statusline`)
3. Post-write validation
4. Rollback on failure

This exceeds the synthesis spec's safety requirements and follows the vault-detection-then-act pattern from reference skills. No changes needed.

---

### jq Availability Check

**Lines 15-22**: The skill checks for `jq` availability at the start (via `command -v jq`) and provides a clear error with installation instructions if missing.

**ADVISE**: The check is good, but the timing is slightly off. The skill should check for jq BEFORE reading settings.json, since jq is required for all JSON manipulation (not just setting the command).

**FIX**: Move the check to step 0 (as it already is) and clarify that it gates all subsequent operations:

```diff
- Run `command -v jq` via Bash. If jq is not found, stop and output:
+ Run `command -v jq` via Bash. If jq is not found, STOP IMMEDIATELY and output:
```

The instruction already does this correctly (step 0 comes before step 1). The fix is just adding emphasis. Not blocking.

---

### Output Messages

**Lines 31-34** (no-op): Clear and concise. Matches synthesis spec line 70-72.

**Lines 94-101** (success): Good. Includes the visibility explanation ("The nefario status appears during /nefario orchestration sessions") which prevents post-action confusion.

**Lines 68-79** (manual fallback): Excellent. Provides specific snippet and explains prerequisites (`$sid` and `$result`). Matches synthesis spec lines 104-115.

All three outcome paths are well-covered.

---

### State B Implementation Concern

**Lines 50-62**: The skill instructs Claude Code to append the nefario snippet "just before the final `echo "$result"`" using jq string manipulation. However, the synthesis spec (lines 91-96) suggests using bash parameter expansion:

```sh
new_command="${current%echo \"\$result\"*}${snippet}echo \"\$result\""
```

The SKILL.md does not specify HOW to do the string manipulation. It says "Use jq to read the current command, replace the final `echo "$result"` with the snippet followed by `echo "$result"`, and write back atomically."

**ADVISE**: Be more specific about the jq approach or recommend bash:

**FIX Option 1 (jq)**: Add explicit jq command example:
```sh
jq --arg snippet '<snippet>' '.statusLine.command |= (sub("echo \"\\$result\"$"; $snippet + "echo \"\\$result\""))' ~/.claude/settings.json
```

**FIX Option 2 (bash)**: Recommend bash parameter expansion (as synthesis spec suggests):
```sh
current=$(jq -r '.statusLine.command' ~/.claude/settings.json)
snippet='f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"; '
new_command="${current%echo \"\$result\"*}${snippet}echo \"\$result\""
jq --arg cmd "$new_command" '.statusLine.command = $cmd' ~/.claude/settings.json > /tmp/settings.tmp && mv /tmp/settings.tmp ~/.claude/settings.json
```

The bash approach is cleaner for shell command string manipulation. The current instruction is underspecified but likely workable (Claude Code will infer a solution). Recommend clarifying in a future revision. **Not blocking** as the fallback to State D handles edge cases.

---

### Security

**Lines 105-110**: The skill prohibits modification of non-statusLine keys ("Do NOT modify any settings.json keys other than `statusLine`"). This is correct defensive design.

**No hardcoded secrets**: The nefario snippet reads from `/tmp/nefario-status-$sid`, which is written by nefario orchestration. No credentials, API keys, or sensitive data in the skill.

**No injection vectors**: The skill uses jq for JSON manipulation (safe) and instructs Claude Code to use Bash (with user consent, no remote input). The status line command itself reads from Claude Code's JSON context, which is controlled input. No injection risk.

**File operations**: Modifies user-owned config file (`~/.claude/settings.json`). Backup and validation provide rollback. Atomic write (temp + mv) prevents corruption. Security posture is sound.

---

### Complexity

**Cognitive Complexity**: Low. The workflow is linear with clear branching (4 states). Each state has a single responsibility. No deep nesting. The jq availability check and idempotency check are guard clauses that short-circuit early.

**Cyclomatic Complexity**: 5 decision points (jq check, idempotency check, State A/B/D branches, validation failure). Well within acceptable range (< 10).

The SKILL.md is easy to follow and reason about. No refactoring needed.

---

### DRY

The skill does not repeat logic. The nefario snippet appears twice (default command and manual instructions) but this is intentional -- one is embedded in the default, one is shown to the user for manual integration. No inappropriate duplication.

---

### Cross-Agent Integration

**Handoff points**: None. This skill is standalone. It modifies a local config file and does not interact with other agents or services.

**Dependency on nefario**: The skill configures the status line to read from `/tmp/nefario-status-$sid`. This file is written by nefario orchestration (see `skills/nefario/SKILL.md`). The dependency is implicit and safe -- if nefario never writes the file, the snippet fails gracefully (all guards short-circuit) and the status line shows only the non-nefario elements.

No cross-agent coordination issues.

---

### SKILL.md-Specific Considerations

**System prompt clarity**: The instructions are directive and actionable. Uses numbered steps, clear branching, and imperative mood ("Run...", "Use...", "If..., stop and output..."). Follows established skill patterns (session-review, obsidian-tasks, despicable-prompter).

**YAML frontmatter**: Valid. Name and description are clear and concise.

**"Act immediately on invocation" pattern**: Line 11 states "You act immediately on invocation -- no questions, no confirmation." This matches the despicable-prompter pattern and aligns with synthesis spec line 134 ("Do NOT ask for confirmation before modifying. Invocation is consent.").

**Tool usage instructions**: The skill explicitly tells Claude Code which tools to use:
- Read tool (line 26)
- Write tool (line 26)
- Bash with jq (lines 17, 44, 60, 85)

This is correct for SKILL.md files. The skill does not execute shell scripts -- it instructs Claude Code to use its tools.

---

## Summary

The SKILL.md is complete, correct, and safe. All four config states are covered. Idempotency and safety measures (backup, validation, rollback) are solid. Output messages are clear and prevent post-action confusion.

Two minor advisories:
1. State B string manipulation could be more explicit (recommend bash parameter expansion).
2. Idempotency check could include a jq command example for clarity.

Both are implementation details that Claude Code will likely infer correctly. The fallback to State D (manual instructions) handles edge cases. The skill is production-ready.

**Recommendation**: APPROVE and merge. Consider the advisories in a future refinement pass if users report issues.
