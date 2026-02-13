MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

## Task

<github-issue>
## Problem

Advisory-only orchestrations (assembling a specialist team for evaluation and report, no code changes) are a frequent use case. Currently, the user must manually type directives like "do not change anything, just create a report" every time. This is repetitive friction that a flag would eliminate.

**This is not YAGNI.** The pattern is well-established through regular use. The user repeatedly crafts the same natural language guardrails to prevent execution and ensure a meaningful report is produced. A flag codifies proven behavior.

## Proposal

Add `--advisory` as a flag on `/nefario`. When present:

- Phases 1-2 run identically (meta-plan, specialist planning)
- Phase 3 produces a recommendation synthesis instead of an execution plan
- Phases 3.5-8 are skipped (no architecture review, no execution, no code review, no tests, no deployment, no docs)
- A report is generated with `mode: advisory` frontmatter
- No branch is created, no PR is opened
- Reports go to `docs/history/nefario-reports/` with the same naming convention

## Prior Analysis

This was evaluated in an advisory orchestration with devx-minion, ai-modeling-minion, margo, and lucy. Key findings:

- **Unanimous**: A separate skill is wrong (60-70% code duplication, fork maintenance)
- **devx-minion**: Same workflow with different terminal condition = flag, not new skill
- **ai-modeling-minion**: ~60-70 lines of additions at two locations in SKILL.md
- **lucy**: No identity drift; advisory is a subset of what nefario already does

Full analysis: `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`

## Acceptance Criteria

- [ ] `/nefario --advisory <task>` runs Phases 1-3 and produces an advisory report
- [ ] `/nefario --advisory #<issue>` works with issue mode
- [ ] Advisory reports use `mode: advisory` in frontmatter
- [ ] No branch creation, no commits, no PR for advisory runs
- [ ] Report template handles advisory sections (no execution, no verification, no files changed)
</github-issue>

## Working Directory
/Users/ben/github/benpeter/2despicable/2

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
   (not execution -- planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ITMTbi/advisory-flag-nefario/phase1-metaplan.md`
