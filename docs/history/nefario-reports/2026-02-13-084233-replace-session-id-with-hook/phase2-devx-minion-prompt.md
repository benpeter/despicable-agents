You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

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

**Constraints**:
- Hook must be defined in skill frontmatter, not user-level or project-level settings — nefario is deployed via symlink and must work in any repo
- `CLAUDE_ENV_FILE` is only available in SessionStart hooks (per Claude Code docs)

## Your Planning Question

What is the correct YAML format for defining a `SessionStart` hook in a skill's YAML frontmatter? The hook needs to write `CLAUDE_SESSION_ID` to `CLAUDE_ENV_FILE`. Specifically:
1. Should the hook use a `once: true` flag since the session ID only needs to be set once per session?
2. Should we use a matcher (e.g., `startup`) or match all session start events (`startup`, `resume`, `clear`, `compact`) since `CLAUDE_ENV_FILE` contents may not persist across compaction/clear?
3. The hook script receives session_id in stdin JSON — should it extract from stdin or is it already available as an env var?
4. What is the exact inline command vs. script file tradeoff given this is deployed via symlink?

## Context

Key files to examine:
- `skills/nefario/SKILL.md` — current frontmatter (lines 1-9) and all `SID=$(cat /tmp/claude-session-id 2>/dev/null)` occurrences
- `.claude/skills/despicable-statusline/SKILL.md` — status line command templates with `echo "$sid" > /tmp/claude-session-id`
- `docs/using-nefario.md` — documentation referencing the old mechanism
- Claude Code hooks documentation (web search for latest format)

## Instructions
1. Read relevant files to understand the current state
2. Research Claude Code hook system — especially SessionStart hooks, CLAUDE_ENV_FILE, skill frontmatter hook format
3. Apply your domain expertise to the planning question
4. Identify risks, dependencies, and requirements from your perspective
5. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
6. Return your contribution in this format:

## Domain Plan Contribution: devx-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

7. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1ytDH0/replace-session-id-with-hook/phase2-devx-minion.md`
