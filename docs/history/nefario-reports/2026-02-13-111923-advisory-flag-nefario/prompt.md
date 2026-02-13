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
