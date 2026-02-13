MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

Replace the shared `/tmp/claude-session-id` file mechanism with a `SessionStart` hook that writes `CLAUDE_SESSION_ID` into `CLAUDE_ENV_FILE`, making it available as an environment variable in all subsequent Bash tool calls during orchestration. This eliminates a last-writer-wins race condition when multiple Claude Code sessions run concurrently.

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
- Out: Hook logic for commit-point-check (covered by #73), change ledger mechanism, defer/declined markers, nefario status file format, `install.sh`

## Specialist Contributions

Read the following scratch file for the full specialist contribution:
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1ytDH0/replace-session-id-with-hook/phase2-devx-minion.md`

## Key consensus across specialists:

### devx-minion
- Use inline SessionStart hook in skill frontmatter YAML. Format: `hooks: > SessionStart: > - hooks: > - type: command, command: '...'`
- Do NOT use `once: true` — risk of env var loss after compaction/clear
- Do NOT use a matcher — match all SessionStart events for safety
- Extract session_id from stdin JSON via `jq -r '.session_id // empty'`
- Inline command (not script file) — symlink deployment makes path resolution fragile
- 9 locations in SKILL.md to replace `SID=$(cat /tmp/claude-session-id 2>/dev/null)` with direct `$CLAUDE_SESSION_ID`
- Remove `echo "$sid" > /tmp/claude-session-id` from despicable-statusline (3 states: A, B, D manual)
- Update docs/using-nefario.md "How It Works" section and manual config JSON example
- commit-point-check.sh already has `CLAUDE_SESSION_ID` fallback — no changes needed
- Risk: existing users need to re-run /despicable-statusline to remove dead write

## External Skills Context
Two project-local skills discovered:
- despicable-lab (ORCHESTRATION) — not relevant, no agents need rebuilding
- despicable-statusline (LEAF) — modification target (its SKILL.md needs editing), not invoked during execution

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. If external skills were discovered, include them in the execution plan:
   - ORCHESTRATION skills: create DEFERRED macro-tasks (see Core Knowledge)
   - LEAF skills: list in the Available Skills section of relevant task prompts
   - Apply precedence rules when skills overlap with internal specialists
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1ytDH0/replace-session-id-with-hook/phase3-synthesis.md`
