MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

Issue #87: Fix compaction checkpoints: add AskUserQuestion pause + clipboard copy

## Bug

Compaction checkpoints (after Phase 3 and Phase 3.5) print a blockquote advisory suggesting the user run `/compact`, but the orchestration proceeds immediately without pausing. The user sees the suggestion flash by and has no opportunity to act on it.

## Root cause

The checkpoint template (SKILL.md lines ~716-728 and ~1051-1061) prints a `>` blockquote with the `/compact` command, then says "if the user runs /compact, wait for continue." But there's no mechanism that actually **pauses execution**. Unlike approval gates which use `AskUserQuestion`, the compaction checkpoint is just output text.

## Why not just invoke /compact programmatically?

Claude Code's `/compact` is a built-in user-only command. Agents cannot invoke it — not via the Skill tool, not via prose output, not via hooks. This is a known limitation tracked as anthropics/claude-code#19877. See #88 for a follow-up that will simplify this once that's resolved.

## Proposed fix

Replace the blockquote advisory with an `AskUserQuestion` gate:

- `header`: "Compact"
- `question`: "Phase N complete. Compact context before continuing?"
- `options`:
  1. label: "Skip", description: "Continue without compaction. Auto-compaction may interrupt later phases." (recommended)
  2. label: "Compact", description: "Compact now. The /compact command will be copied to your clipboard."

**If user selects "Compact":**
1. Copy the full `/compact focus="Preserve: ..."` command to the system clipboard (via `pbcopy` on macOS, with fallback note for other platforms)
2. Print a short note: "Paste and run the command from your clipboard. You can type `continue` and hit Return while compaction is running — it will be queued and executed once compaction completes."
3. Wait for user to say "continue" before proceeding

**If user selects "Skip":**
Proceed immediately with a one-line note: "Continuing without compaction."

## Affected locations

- `skills/nefario/SKILL.md` line ~811 (post-Phase 3 checkpoint)
- `skills/nefario/SKILL.md` line ~1194 (post-Phase 3.5 checkpoint)

## References

- anthropics/claude-code#19877 — feature request for Claude-invocable /compact
- anthropics/claude-code#24606 — feature request for SDK compact() method
- #88 — follow-up: simplify once programmatic compaction is available

---
Additional context: use opus for all agents

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

Project-local skills found in .claude/skills/:
- despicable-lab
- despicable-prompter
- despicable-statusline

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
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-PKILQw/fix-compaction-checkpoints/phase1-metaplan.md`
