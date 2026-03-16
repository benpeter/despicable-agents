ADVISE

- [testing]: Anchor slug validity is declared as a verification step but no execution mechanism is specified — it will be skipped or eyeballed unless explicitly assigned.
  SCOPE: Verification Step 5 — all three cross-reference links (`orchestration.md#6-parallel-orchestration-with-git-worktrees`)
  CHANGE: Assign anchor validation to the executing agent (software-docs-minion) as a final step in Task 2 or Task 3: after edits are complete, confirm the heading slug produced by `## 6. Parallel Orchestration with Git Worktrees` matches the fragment used in both link targets. This can be done by inspecting the heading text — GitHub strips punctuation (the period after `6` is dropped) and lowercases, yielding `6-parallel-orchestration-with-git-worktrees`. Explicitly note this in the Task 2 and Task 3 prompts so the agent verifies before finishing.
  WHY: Broken anchors silently degrade to top-of-page links in most Markdown renderers. The plan identifies anchor validation as a risk but leaves it unowned; without an explicit instruction to the executing agent, it falls through.
  TASK: Tasks 2 and 3 (both insert links to the same anchor)
