MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

<github-issue>
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
</github-issue>

## Working Directory
/Users/ben/github/benpeter/despicable-agents

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution — planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1ytDH0/replace-session-id-with-hook/phase1-metaplan.md`
