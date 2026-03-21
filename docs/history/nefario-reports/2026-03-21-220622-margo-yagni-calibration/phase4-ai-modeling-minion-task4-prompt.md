You are removing the interim YAGNI override from `CLAUDE.local.md` now that
the calibration is encoded directly in `margo/AGENT.md`.

## What to do

In `/Users/ben/github/benpeter/despicable-agents/CLAUDE.local.md` (use this
absolute path -- the file exists in the project root, not in the worktree),
remove the entire "## YAGNI Scope: Roadmap-Aware, Not Myopic" section.

This section was a stopgap override that is now superseded by the two-tier
YAGNI evaluation in `margo/AGENT.md`.

Remove the section header and all content through the blank line after
"do we know we'll need it?"

## Constraints

- Do NOT modify any other section of CLAUDE.local.md (Technology Bias,
  CRITICAL: Keep Agents Publishable, External Harness Integration).
- CLAUDE.local.md is a local file not checked into git. This is intentional.
- Use the ABSOLUTE path: /Users/ben/github/benpeter/despicable-agents/CLAUDE.local.md

## Files

- `/Users/ben/github/benpeter/despicable-agents/CLAUDE.local.md` -- the only file you modify

## Context

The YAGNI override was added as an interim fix after the `duration_ms`
incident. With Task 1 encoding the two-tier evaluation directly in margo's
AGENT.md, having both creates a dual-source-of-truth problem. The AGENT.md
is now the single source of truth for YAGNI evaluation logic.

## Deliverables

- CLAUDE.local.md with the YAGNI override section removed

When you finish, report back with:
- File path with change scope and line counts
- 1-2 sentence summary of what was produced
