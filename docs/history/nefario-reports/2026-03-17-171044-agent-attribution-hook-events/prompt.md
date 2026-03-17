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
