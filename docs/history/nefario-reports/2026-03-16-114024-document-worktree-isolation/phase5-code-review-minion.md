---
reviewer: code-review-minion
phase: 5
verdict: ADVISE
---

VERDICT: ADVISE

FINDINGS:

- [ADVISE] docs/orchestration.md:651 -- The note states `EnterWorktree`/`ExitWorktree` are "used by the Agent tool's `isolation: 'worktree'` parameter". This is partially accurate but imprecise: `EnterWorktree` is invoked by the platform internally when the agent tool uses `isolation: "worktree"`, but it is not a parameter of the Agent tool itself. The tool is `EnterWorktree` (standalone), not a parameter of `Task`/`Agent`. The sentence could mislead readers into looking for an `isolation` key on the `Agent` tool rather than in agent definitions. The changelog confirms `isolation: worktree` is declared in agent definitions, not passed as a runtime `Agent` tool parameter.
  FIX: Revise note to: "Mid-session worktree switching (`EnterWorktree`/`ExitWorktree`) is a separate capability used when agents are defined with `isolation: 'worktree'` for running subagents in isolated copies. The two mechanisms are unrelated."

- [NIT] docs/orchestration.md:634-638 -- The code block shows `claude --worktree auth-refactor` (Terminal 1) and `claude -w docs-overhaul` (Terminal 2). Both flags are verified correct. However, mixing `--worktree` and `-w` in adjacent examples without comment may confuse readers unfamiliar with the CLI. Since the section introduces the feature, using the long form consistently would aid discoverability.
  FIX: Use `claude --worktree docs-overhaul` in Terminal 2 for consistency, or add a comment `# -w is shorthand for --worktree`.

- [NIT] docs/orchestration.md:657 -- "Nefario creates `nefario/<slug>` in each worktree (Section 5)" is a forward cross-reference to Section 5 of the same document. Section 5 is above Section 6, so this is actually a backward reference. The parenthetical is accurate (commit-workflow.md also covers this in its Branching Strategy section), but the phrasing "Section 5" is ambiguous -- it could mean Section 5 of orchestration.md or Section 5 of commit-workflow.md (which also has a Section 5 on Commit Message Convention, not branching).
  FIX: Replace "(Section 5)" with "(see [Commit Points in Execution Flow](#5-commit-points-in-execution-flow))" for clarity.

- [NIT] docs/using-nefario.md:143 -- The tip says "each in its own worktree (`claude -w auth-refactor` in one terminal, `claude -w docs-overhaul` in another)". Using `-w` shorthand in user-facing tips is fine, but the anchor link `orchestration.md#6-parallel-orchestration-with-git-worktrees` correctly renders from the heading `## 6. Parallel Orchestration with Git Worktrees` -- no issue with the link itself. This is purely cosmetic: the inline code examples use the short flag while orchestration.md Section 6 code block uses both forms. No action required.

- [NIT] docs/commit-workflow.md:35 -- The forward-reference sentence ends without a period: "...following the same naming convention. See [Parallel Orchestration with Git Worktrees](orchestration.md#6-parallel-orchestration-with-git-worktrees)". The sentence is incomplete -- it trails off with no closing punctuation after the link.
  FIX: Add a period: "...following the same naming convention. See [Parallel Orchestration with Git Worktrees](orchestration.md#6-parallel-orchestration-with-git-worktrees)."
