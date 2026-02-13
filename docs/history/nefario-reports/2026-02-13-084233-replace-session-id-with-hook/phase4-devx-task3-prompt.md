You are updating the nefario user documentation to reflect the new session ID mechanism.

## File to edit

`/Users/ben/github/benpeter/despicable-agents/docs/using-nefario.md`

## Changes

### 1. Update the "How It Works" section (around line 197)

Current text:
```
The status line command extracts `session_id` from the JSON that Claude Code pipes to it, and writes it to `/tmp/claude-session-id` so the nefario skill can discover it. When nefario starts orchestrating, it reads the session ID from that file and writes the current phase and task summary to `/tmp/nefario-status-<session-id>`. The file is updated at each phase transition so the status line always reflects the current phase. The status line command checks for this file and appends its contents. When orchestration finishes, nefario removes the file.
```

Replace with:
```
The nefario skill registers a `SessionStart` hook that captures the session ID and makes it available as the `CLAUDE_SESSION_ID` environment variable. When nefario starts orchestrating, it writes the current phase and task summary to `/tmp/nefario-status-<session-id>`. The file is updated at each phase transition. The status line command extracts `session_id` from the JSON that Claude Code pipes to it, checks for the nefario status file, and appends its contents. When orchestration finishes, nefario removes the file. Each session has its own status file, so concurrent sessions do not interfere.
```

### 2. Update the manual configuration JSON example (around lines 204-211)

In the JSON command string, remove the fragment `[ -n \\\"$sid\\\" ] && echo \\\"$sid\\\" > /tmp/claude-session-id;` (the escaped version within the JSON string). Keep the `sid` extraction and the nefario status file reading.

The resulting command should still extract `sid` from stdin JSON (for reading `/tmp/nefario-status-$sid`) but no longer write to `/tmp/claude-session-id`.

## What NOT to do
- Do NOT modify any other documentation files
- Do NOT change the "What It Shows" section -- it is still accurate
- Do NOT modify files under `docs/history/`
- Do NOT remove the manual configuration section -- just update it

When done, mark task #3 completed with TaskUpdate and send a message to the team lead with file paths, change scope, and line counts.
