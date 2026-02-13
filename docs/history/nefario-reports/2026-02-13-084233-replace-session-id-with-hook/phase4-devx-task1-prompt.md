You are modifying the nefario orchestration skill to replace the `/tmp/claude-session-id` shared file mechanism with a `SessionStart` hook that writes `CLAUDE_SESSION_ID` into `CLAUDE_ENV_FILE`.

## Part A: Add the SessionStart hook to frontmatter

Edit `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`.

The current frontmatter (lines 1-10) is:
```yaml
---
name: nefario
description: >
  Orchestrate a team of specialist agents for complex, multi-domain tasks.
  Uses a nine-phase process: nefario creates a meta-plan, specialists
  contribute domain expertise, nefario synthesizes, cross-cutting agents
  review the plan, you execute, then post-execution phases verify code
  quality, run tests, optionally deploy, and update documentation.
argument-hint: "#<issue> | <task description>"
---
```

Replace with:
```yaml
---
name: nefario
description: >
  Orchestrate a team of specialist agents for complex, multi-domain tasks.
  Uses a nine-phase process: nefario creates a meta-plan, specialists
  contribute domain expertise, nefario synthesizes, cross-cutting agents
  review the plan, you execute, then post-execution phases verify code
  quality, run tests, optionally deploy, and update documentation.
argument-hint: "#<issue> | <task description>"
hooks:
  SessionStart:
    - hooks:
        - type: command
          command: 'INPUT=$(cat); SID=$(echo "$INPUT" | jq -r ".session_id // empty" | tr -dc "[:alnum:]-_"); [ -n "$SID" ] && [ -n "$CLAUDE_ENV_FILE" ] && echo "CLAUDE_SESSION_ID=$SID" >> "$CLAUDE_ENV_FILE"'
---
```

IMPORTANT format details:
- Do NOT use `once: true` -- the hook must fire on every SessionStart event to survive compaction
- Do NOT add a `matcher:` field -- omitting it matches all SessionStart events
- The `tr -dc '[:alnum:]-_'` sanitizes the session_id (defense-in-depth per security advisory)
- Use bare `CLAUDE_SESSION_ID=$SID` (no `export` prefix) -- CLAUDE_ENV_FILE uses KEY=VALUE format
- Use `>>` to append (not clobber other hooks' env vars)

## Part B: Replace all SID references in SKILL.md body

In the same file, find and replace ALL occurrences of the two-line pattern:
```sh
SID=$(cat /tmp/claude-session-id 2>/dev/null)
echo "..." > /tmp/nefario-status-$SID
```
With the single-line pattern:
```sh
echo "..." > /tmp/nefario-status-$CLAUDE_SESSION_ID
```

For the `chmod` line that follows the first occurrence:
```sh
chmod 600 /tmp/nefario-status-$SID
```
Change to:
```sh
chmod 600 /tmp/nefario-status-$CLAUDE_SESSION_ID
```

For cleanup patterns:
```sh
SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/nefario-status-$SID
```
Change to:
```sh
rm -f /tmp/nefario-status-$CLAUDE_SESSION_ID
```

There are 9 locations total. Search for `claude-session-id` or `$SID` to find them all.

## What NOT to do
- Do NOT modify any other files
- Do NOT change the status file path pattern (`/tmp/nefario-status-*`)
- Do NOT add `once: true` to the hook
- Do NOT use `export` prefix in the CLAUDE_ENV_FILE write
- Do NOT touch `commit-point-check.sh`
- Do NOT modify files under `docs/history/`

When done, mark task #1 completed with TaskUpdate and send a message to the team lead with file paths, change scope, and line counts.
