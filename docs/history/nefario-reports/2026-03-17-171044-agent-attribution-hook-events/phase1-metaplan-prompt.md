MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

#125 Leverage agent_id/agent_type in hook events for commit attribution

## Context

Claude Code 2.1.69 added `agent_id` (for subagents) and `agent_type` (for subagents and `--agent`) fields to hook events. This provides structured metadata about which agent triggered a hook.

## Current State

The commit workflow's PostToolUse hook tracks file changes via a change ledger. Attribution of which agent produced a change currently relies on heuristics within the orchestration flow. The hook itself doesn't know which agent is running.

## Proposed Change

Update the PostToolUse hook (`commit-workflow.md` / hook scripts) to use `agent_id` and `agent_type` from hook event data for richer commit attribution. This could enable:

- Per-agent commit messages (e.g., "frontend-minion: implement header component")
- More accurate change tracking in the ledger
- Better debugging when reviewing execution reports

Evaluate whether the additional metadata is sufficient to replace or simplify existing attribution logic.

## Source

Claude Code changelog: 2.1.69 — "Added `agent_id` (for subagents) and `agent_type` (for subagents and `--agent`) to hook events"

## Working Directory
/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/agent-attribution

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan (see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning)
5. For each specialist, write a specific planning question that draws on their unique expertise
6. Return the meta-plan in the structured format
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-KeX6EC/agent-attribution-hook-events/phase1-metaplan.md
