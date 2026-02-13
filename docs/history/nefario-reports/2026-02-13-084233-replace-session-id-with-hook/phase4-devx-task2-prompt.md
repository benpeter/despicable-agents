You are updating the despicable-statusline skill to remove the `/tmp/claude-session-id` write that is no longer needed.

## Context

The nefario skill now uses a SessionStart hook to set `CLAUDE_SESSION_ID` as an env var instead of reading from `/tmp/claude-session-id`. The status line command no longer needs to write the session ID to that file. However, the status line command still needs to extract `$sid` from the stdin JSON for its own use (reading `/tmp/nefario-status-$sid`).

## File to edit

`/Users/ben/github/benpeter/despicable-agents/.claude/skills/despicable-statusline/SKILL.md`

## Changes

Remove the fragment `[ -n "$sid" ] && echo "$sid" > /tmp/claude-session-id;` from the State A full default command (around line 45). This is the only location that writes to `/tmp/claude-session-id`.

States B and D contain only the nefario status reading snippet which does NOT write to `/tmp/claude-session-id` -- verify they don't need changes.

The `sid` variable extraction (`sid=$(echo "$input" | jq -r '.session_id // ""')`) MUST remain because it is used later in the nefario status file read (`f="/tmp/nefario-status-$sid"`).

## What NOT to do
- Do NOT remove the `sid` extraction -- it is still needed
- Do NOT remove the nefario status file reading logic
- Do NOT modify any other files

When done, mark task #2 completed with TaskUpdate and send a message to the team lead with file paths, change scope, and line counts.
