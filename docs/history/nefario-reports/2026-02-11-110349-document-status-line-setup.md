---
task: "Document how to add nefario status to the Claude Code status line"
source-issue: 25
date: 2026-02-11
slug: document-status-line-setup
specialists-consulted:
  - user-docs-minion
  - ux-strategy-minion
reviewers:
  - security-minion (APPROVE)
  - test-minion (ADVISE)
  - ux-strategy-minion (ADVISE)
  - software-docs-minion (APPROVE)
  - lucy (ADVISE)
  - margo (APPROVE)
tasks: 1
gates: 0
verification: "skipped (documentation-only, no code produced)"
---

## Executive Summary

Added a Status Line section to `docs/using-nefario.md` documenting how users
can configure their Claude Code status bar to show live nefario orchestration
status. The guide includes a copyable `settings.json` snippet, expected output
examples, and a brief explanation of session-scoped isolation.

## Original Prompt

**Outcome**: Users have a short guide in docs/ explaining how to configure
their Claude Code status line to show nefario orchestration status, so they
can see what nefario is doing in their current session.

**Success criteria**:
- Step-by-step instructions a user can follow in under 2 minutes
- Covers the settings.json statusLine command and what it shows
- Explains the CLAUDE_SESSION_ID-based session isolation

**Scope**:
- In: Status line setup guide in docs/
- Out: Customization options, modifying the status line implementation, changes to nefario SKILL.md

## Decisions

### Placement: Section in existing file vs standalone doc

Added as a `## Status Line` section at the end of `docs/using-nefario.md`
rather than creating a standalone `docs/status-line-setup.md`. The content
is a single paste-able snippet with brief context -- insufficient for a
standalone page. The architecture index already categorizes `using-nefario.md`
as user-facing documentation.

### Information sequence: Snippet-first vs explanation-first

Adopted snippet-first ordering (Setup > What It Shows > How It Works).
Users navigating to this section want to paste the config and see the result.
Explanation follows for those who want to understand the mechanism. This
follows the satisficing principle from UX research.

### Session isolation: Feature highlight vs background context

Presented as a single sentence in the "How It Works" section rather than
a dedicated subsection. Most users run one nefario session at a time;
session isolation is supporting context, not a feature to highlight.

## Agent Contributions

### Planning Phase

| Agent | Recommendation | Key Finding |
|-------|---------------|-------------|
| user-docs-minion | Add to using-nefario.md; structure as What It Shows > Setup > How It Works | Sentinel filename mismatch (SKILL.md uses `${slug}`, settings.json uses `${CLAUDE_SESSION_ID}`) |
| ux-strategy-minion | Snippet-first ordering; session isolation as background; ~20 lines target | Same filename mismatch confirmed; recommended devx-minion to verify runtime behavior |

### Review Phase

| Reviewer | Verdict | Key Note |
|----------|---------|----------|
| security-minion | APPROVE | No attack surface changes |
| test-minion | ADVISE | Track SKILL.md fix separately |
| ux-strategy-minion | ADVISE | Merge guidance should precede code block; session isolation wording improvement |
| software-docs-minion | APPROVE | Placement and structure are correct |
| lucy | ADVISE | Plan aligns with user intent; no CLAUDE.md violations |
| margo | APPROVE | Proportional to the problem; no over-engineering |

## Execution

### Task 1: Write status line section in docs/using-nefario.md

- **Agent**: user-docs-minion (sonnet)
- **Status**: Completed
- **Deliverable**: Updated `docs/using-nefario.md` (+33 lines)
- **Outcome**: Section added with three subsections (Setup, What It Shows,
  How It Works). JSON snippet matches the actual working configuration.
  Merge guidance positioned before the code block per ux-strategy-minion
  advisory. Session isolation described in plain language.

## Verification

Skipped (documentation-only task, no code produced).

## Known Issues

### Sentinel filename mismatch (HIGH)

SKILL.md writes the status sentinel to `/tmp/nefario-status-${slug}` (lines
285-286, 1130) but the documented `settings.json` command reads from
`/tmp/nefario-status-${CLAUDE_SESSION_ID}`. The status line will not display
nefario status until SKILL.md is updated to use `${CLAUDE_SESSION_ID}`.
This is a 3-line fix that should be tracked as a separate issue.

The documentation describes the correct intended behavior. Once the SKILL.md
fix ships, the guide will work as documented.

## Files Changed

| File | Change |
|------|--------|
| `docs/using-nefario.md` | Added `## Status Line` section (+33 lines) |

## Working Files

Companion directory: `docs/history/nefario-reports/2026-02-11-110349-document-status-line-setup/`

| File | Description |
|------|-------------|
| `prompt.md` | Original task description |
| `phase1-metaplan.md` | Meta-plan: specialist selection |
| `phase2-user-docs-minion.md` | User docs specialist contribution |
| `phase2-ux-strategy-minion.md` | UX strategy specialist contribution |
| `phase3-synthesis.md` | Synthesized execution plan |
