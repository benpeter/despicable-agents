#112 and #110 in one go please. use opus for all agents, all approvals given, work through this including the PR creation without asking back

## Issue #112: feat(nefario): embed context usage in compaction AskUserQuestion gates

Embed context usage percentage in compaction checkpoint gates by parsing system_warning token usage data, so users can see their context usage when the status line is occluded by AskUserQuestion.

## Issue #110: feat(nefario): add pbcopy clipboard support to compaction checkpoints

Add pbcopy clipboard copy to both compaction checkpoint gates so the /compact command is automatically on the clipboard when the gate fires. Mac-only is acceptable.
