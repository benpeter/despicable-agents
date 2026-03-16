## Context

Claude Code has mature git worktree isolation support (`claude --worktree <name>` / `claude -w`). Users can already run multiple independent nefario orchestrations in parallel by starting each in its own worktree — no framework changes needed.

This is undocumented today. A short section in the orchestration docs would help users discover this capability.

## What to document

Add a section to `docs/orchestration.md` (or a linked sub-doc) covering:

- **How it works**: `claude -w auth-refactor` then `/nefario` in each terminal — each gets its own branch and working directory
- **When to use it**: Independent workstreams that don't touch the same files (e.g., auth refactor + API redesign)
- **Merge-back workflow**: Standard git PRs from each worktree branch
- **What NOT to expect**: No automatic merge, no cross-session coordination — each nefario session is fully independent

## What NOT to build

Per YAGNI / Helix Manifesto: no framework-level worktree orchestration. The infrastructure layer (Claude Code + git) handles this transparently. Nefario's value is sequential orchestration within a session, not cross-session parallelism.

## References

- Claude Code worktree docs: `claude --worktree`, `isolation: "worktree"` on Agent tool
- `EnterWorktree`/`ExitWorktree` tools for mid-session switching

---
Additional context: all approvals given, proceed right through to PR creation autonomously
