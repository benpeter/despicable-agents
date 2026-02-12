---
task: "Create /despicable-statusline skill to add nefario phase to status line"
source-issue: 34
date: 2026-02-12
slug: despicable-statusline-skill
branch: nefario/despicable-statusline-skill
status: complete
agents-consulted:
  planning: [devx-minion, ux-strategy-minion]
  review: [security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo]
  execution: [devx-minion]
  code-review: [code-review-minion, lucy, margo]
---

# Execution Report: Create /despicable-statusline Skill

## Executive Summary

Created a `/despicable-statusline` Claude Code skill that configures the user's
status line to display nefario orchestration phase. The skill reads existing
`~/.claude/settings.json` config, preserves it, and appends a nefario status
snippet. Idempotent and safe -- uses atomic writes with backup/validation/rollback.

## Original Prompt

Create a `/despicable-statusline` skill that configures the user's Claude Code
status line to include nefario orchestration phase as the last element. The skill
reads the user's existing status line config, preserves everything as-is, and
appends the nefario status snippet that reads from `/tmp/nefario-status-$sid`.

Source: GitHub issue #34

## Deliverables

| File | Location | Lines | Description |
|------|----------|-------|-------------|
| SKILL.md | `~/github/benpeter/claude-skills/despicable-statusline/SKILL.md` | 111 | Skill definition |
| Symlink | `~/.claude/skills/despicable-statusline` | - | Points to skills repo |

## Decisions

No approval gates were needed. The deliverable is a single prompt file that is
easily reversible (delete file + symlink), has zero downstream dependents, and
follows an established pattern.

**User feedback incorporated**: The user flagged that jq absence should produce
a clear error rather than failing silently. A step 0 was added to check jq
availability and print install instructions if missing.

## Agent Contributions

### Planning Phase

**devx-minion**: Recommended treating the statusLine command as an opaque blob,
using jq for safe JSON manipulation, idempotency via `nefario-status-` substring
check, and atomic write with backup/validation/rollback. Proposed the 4-state
branching logic (no config, inline, already present, non-standard).

**ux-strategy-minion**: Recommended no confirmation gate (invocation = consent),
default statusLine with 4 elements (dir, model, context%, nefario status), two
minimal outcome messages (success with visibility explanation, no-op single line),
and manual instructions for script-file configs.

### Architecture Review

| Reviewer | Verdict | Notes |
|----------|---------|-------|
| security-minion | ADVISE | jq validation, backup file permissions |
| test-minion | ADVISE | Expand verification to all 4 states |
| ux-strategy-minion | APPROVE | - |
| software-docs-minion | APPROVE | SKILL.md is self-documenting |
| lucy | APPROVE | Full requirements traceability, convention compliance |
| margo | APPROVE | Proportionate to problem, no over-engineering |

### Code Review

| Reviewer | Verdict | Notes |
|----------|---------|-------|
| code-review-minion | APPROVE | Production-ready, all 4 states covered |
| lucy | APPROVE | No drift, full CLAUDE.md compliance |
| margo | APPROVE | Proportional, zero new dependencies |

## Verification

Verification: code review passed. Skipped: tests (no executable code), docs (SKILL.md is self-documenting).

## Risks Accepted

1. **Session ID dependency**: If a user's existing command doesn't extract
   `session_id`, the nefario snippet fails safely (guards short-circuit).
2. **Non-standard formats**: Detected and handled via manual instructions
   (State D) rather than attempting potentially broken modification.

## Working Files

Companion directory: `docs/history/nefario-reports/2026-02-12-063624-despicable-statusline-skill/`

Files:
- prompt.md
- phase1-metaplan.md
- phase2-devx-minion.md
- phase2-ux-strategy-minion.md
- phase3-synthesis.md
- phase3.5-security-minion.md
- phase3.5-test-minion.md
- phase3.5-ux-strategy-minion.md
- phase3.5-software-docs-minion.md
- phase3.5-lucy.md
- phase3.5-margo.md
- phase5-code-review-minion.md
- phase5-lucy.md
- phase5-margo.md
