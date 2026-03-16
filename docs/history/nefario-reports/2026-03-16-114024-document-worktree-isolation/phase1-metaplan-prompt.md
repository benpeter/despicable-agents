MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
<github-issue>
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
</github-issue>

---
Additional context: all approvals given, proceed right through to PR creation autonomously

## Working Directory
/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/document-worktree-isolation

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
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Vb3HFr/document-worktree-isolation/phase1-metaplan.md`
