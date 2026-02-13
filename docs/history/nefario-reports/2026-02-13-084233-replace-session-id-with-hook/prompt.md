**Outcome**: Nefario and the status line no longer rely on the shared `/tmp/claude-session-id` file to communicate the session ID. Instead, a `SessionStart` hook defined in the nefario skill frontmatter writes `CLAUDE_SESSION_ID` into `CLAUDE_ENV_FILE`, making it available as an environment variable in all subsequent Bash tool calls during the orchestration. This eliminates the last-writer-wins race condition when multiple Claude Code sessions run concurrently (the old file was global — whichever session's status line refreshed last would overwrite everyone else's session ID).

**Success criteria**:
- `CLAUDE_SESSION_ID` env var is available in Bash tool calls during `/nefario` orchestration and contains the correct session ID
- `/tmp/claude-session-id` file is no longer written or read by any component
- Nefario SKILL.md uses `$CLAUDE_SESSION_ID` instead of `$(cat /tmp/claude-session-id 2>/dev/null)` for all status file operations
- Status line command no longer writes `echo "$sid" > /tmp/claude-session-id`
- Despicable-statusline skill (SKILL.md) updated to not inject the session-id write
- Multiple concurrent Claude Code sessions each see their own nefario status (no cross-talk)
- `docs/using-nefario.md` updated if it references the old mechanism
- No new entries in `~/.claude/settings.json` — hook lives in skill frontmatter only

**Scope**:
- In: Nefario skill frontmatter (SessionStart hook), `skills/nefario/SKILL.md` SID sourcing, status line command, despicable-statusline skill, docs
- Out: Hook logic for commit-point-check (covered by #73), change ledger mechanism, defer/declined markers, nefario status file format, `install.sh` (no changes needed — skill frontmatter hooks deploy with the symlink)

**Constraints**:
- Hook must be defined in skill frontmatter, not user-level or project-level settings — nefario is deployed via symlink and must work in any repo
- `CLAUDE_ENV_FILE` is only available in SessionStart hooks (per Claude Code docs)
