---
name: despicable-statusline
description: >
  Configure the Claude Code status line to show nefario orchestration phase.
  Reads existing statusLine config, preserves it, and appends the nefario
  status snippet. Idempotent -- safe to run multiple times.
---

# Despicable Statusline

You configure the Claude Code status line to display nefario orchestration status. You act immediately on invocation -- no questions, no confirmation.

## Workflow

### 0. Check jq Availability

Run `command -v jq` via Bash. If jq is not found, stop and output:

```
jq is required but not installed.
Install: brew install jq (macOS) or apt install jq (Linux)
```

### 1. Read Settings

Use the Read tool to read `~/.claude/settings.json`. If the file does not exist, create it with `{}` as content first using the Write tool.

### 2. Idempotency Check

Check if the string `nefario-status-` appears anywhere in the `statusLine` `command` value. If it does, output and stop:

```
Status line already includes nefario status. No changes made.
```

### 3. Determine Config State and Apply

Examine the current `statusLine` configuration and branch:

**State A -- No statusLine configured** (`.statusLine` is absent or null):

Set `.statusLine.command` to the full default command via jq:

```sh
input=$(cat); dir=$(echo "$input" | jq -r '.workspace.current_dir // "?"'); model=$(echo "$input" | jq -r '.model.display_name // "?"'); used=$(echo "$input" | jq -r '.context_window.used_percentage // ""'); sid=$(echo "$input" | jq -r '.session_id // ""'); [ -n "$sid" ] && echo "$sid" > /tmp/claude-session-id; result="$dir | $model"; if [ -n "$used" ]; then result="$result | Context: $(printf '%.0f' "$used")%"; fi; f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"; echo "$result"
```

Use jq via Bash to set `.statusLine.command` to this value. Write via atomic pattern: write to a temp file, then `mv` over the original.

**State B -- Inline statusLine without nefario snippet**:

The existing `.statusLine.command` is a shell string that does NOT contain `nefario-status-` and ends with `echo "$result"`. Append the nefario snippet just before the final `echo "$result"` using jq string manipulation:

The nefario snippet to insert:

```sh
f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns";
```

Use jq to read the current command, replace the final `echo "$result"` with the snippet followed by `echo "$result"`, and write back atomically.

If the command does NOT end with `echo "$result"`, fall through to State D.

**State C -- Already has nefario snippet**: Handled by step 2 (no-op).

**State D -- Non-standard or script-file statusLine**:

If the command value looks like a script file path (no semicolons, references a .sh file) or does not contain `echo "$result"`, do NOT modify it. Output:

```
Your status line uses a custom format that cannot be auto-modified.

To add nefario status manually, add this before your final output:

  f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"

This requires $sid (session ID from .session_id) and $result (your output
string) to be defined earlier in your command.
```

### 4. Safety Measures

Before modifying `~/.claude/settings.json`:

1. Validate the file is valid JSON: run `jq empty ~/.claude/settings.json` via Bash
2. Create a backup: copy to `~/.claude/settings.json.backup-statusline`
3. After writing the new file, validate the result is valid JSON: run `jq empty ~/.claude/settings.json` via Bash
4. If post-write validation fails, restore from backup and report the error

### 5. Success Message

For State A and State B, output:

```
Status line updated.
  Added: nefario orchestration status
  Config: ~/.claude/settings.json

The nefario status appears during /nefario orchestration sessions.
Outside orchestration, it is hidden.
```

## Known Limitations

**Parallel session status bleed**: The status line identifies the active
nefario session via a shared `/tmp/claude-session-id` file. If two Claude
Code sessions run simultaneously, the status line may briefly show the
orchestration phase from the other session. This is rare in practice —
it only occurs when both sessions are actively running `/nefario` at the
same time — but it can be confusing when it happens.

The root cause is tracked in [#74](https://github.com/benpeter/despicable-agents/issues/74).
A proper fix (e.g., per-session env vars via `SessionStart` hooks) would
be worthwhile, but all known approaches add meaningful complexity to the
skill and its deployment. For now, the shared-file approach stays as the
simplest thing that works for the common single-session case.

## Important Notes

- Do NOT ask for confirmation before modifying. Invocation is consent.
- Do NOT show the user the shell command that was written.
- Do NOT modify any settings.json keys other than `statusLine`.
- Do NOT reorder, rename, or remove existing statusLine elements.
- Do NOT add elements beyond the nefario snippet (no git branch, no cost tracking, no session ID display).
- Do NOT use Claude Code's Edit tool for JSON manipulation of the command string -- use `jq` via Bash for all JSON read/write operations.
