---
task: "docs: add /despicable-prompter reference to using-nefario guide"
date: 2026-02-11
branch: nefario/despicable-prompter-ref-using-nefario
slug: despicable-prompter-ref-using-nefario
status: completed
---

# Execution Report: Add /despicable-prompter Reference to using-nefario Documentation

## Executive Summary

Added a one-sentence cross-reference to `/despicable-prompter` in `docs/using-nefario.md`, placed immediately after the "less helpful examples" section. Users who write vague `/nefario` prompts now discover the briefing coach tool as a natural next step.

## Original Prompt

Add /despicable-prompter reference to using-nefario documentation

**Outcome**: Users who write vague /nefario prompts discover /despicable-prompter as a tool to improve them, so that the "less helpful examples" section becomes a learning opportunity instead of a dead end.

**Success criteria**:
- docs/using-nefario.md references /despicable-prompter near the "less helpful examples" section
- The reference explains what /despicable-prompter does in one sentence
- Users understand they can paste their vague idea and get a structured briefing back

**Scope**:
- In: docs/using-nefario.md
- Out: despicable-prompter skill itself, other documentation files, README

## Agent Contributions

### Planning Phase

| Agent | Recommendation |
|-------|---------------|
| user-docs-minion | Place a plain paragraph after the "less helpful examples" code block, before the next heading. Imperative mood, normalizing tone. |

### Architecture Review

| Agent | Verdict |
|-------|---------|
| security-minion | APPROVE |
| test-minion | APPROVE |
| ux-strategy-minion | APPROVE |
| software-docs-minion | APPROVE |
| lucy | APPROVE |
| margo | APPROVE |

### Code Review (Phase 5)

| Agent | Verdict | Notes |
|-------|---------|-------|
| code-review-minion | ADVISE | Minor wording deviation from synthesis plan; merge-ready as-is |
| lucy | APPROVE | All three success criteria met |
| margo | APPROVE | Exactly proportional to task scope |

## Decisions

No approval gates were required. Single-task plan with zero downstream dependents.

## Execution

### Task 1: Insert /despicable-prompter reference paragraph

- **Agent**: user-docs-minion
- **Status**: Completed
- **Deliverable**: `docs/using-nefario.md` (line 58)

Inserted text:
> If you have a rough idea but aren't sure how to structure it, run `/despicable-prompter` first — it transforms vague descriptions into structured `/nefario` briefings with clear outcomes, success criteria, and scope.

## Files Changed

| File | Change |
|------|--------|
| `docs/using-nefario.md` | Added 1 paragraph (2 inserted lines) after "less helpful examples" section |

## Verification

Code review passed (2 APPROVE, 1 ADVISE). Tests skipped (user-requested). Docs skipped (no checklist items).

## Working Files

Companion directory: `docs/history/nefario-reports/2026-02-11-103849-despicable-prompter-ref-using-nefario/`

Files:
- `prompt.md` — Original task description
- `phase1-metaplan.md` — Meta-plan (specialist selection)
- `phase2-user-docs-minion.md` — User docs specialist planning contribution
- `phase3-synthesis.md` — Synthesized execution plan
- `phase3.5-*.md` — Architecture review verdicts (6 reviewers)
- `phase5-*.md` — Code review verdicts (3 reviewers)
