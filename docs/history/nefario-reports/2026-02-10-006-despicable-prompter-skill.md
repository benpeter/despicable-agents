---
type: nefario-report
version: 1
date: "2026-02-10"
sequence: 006
task: "Create despicable-prompter intake skill for nefario briefings"
mode: full
agents-involved: [nefario, ai-modeling-minion, devx-minion, ux-strategy-minion, security-minion, test-minion, software-docs-minion, lucy, margo]
task-count: 1
gate-count: 0
outcome: completed
---

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Create despicable-prompter intake skill |
| Duration | ~8m |
| Outcome | completed |
| Planning Agents | 3 agents consulted |
| Review Agents | 6 reviewers |
| Execution Agents | 1 agent spawned |
| Gates Presented | 0 |
| Files Changed | 1 created |
| Outstanding Items | 1 item |

## Executive Summary

Created `/despicable-prompter`, a project-local Claude Code skill that coaches users into articulating clean, intent-focused task briefings for `/nefario`. The skill uses a single-pass transformation pattern: it always produces a ready-to-paste `/nefario` command on the first response, classifying input as well-formed, vague, or implementation-heavy and applying the appropriate transformation. User-stated technology preferences are preserved as constraints without endorsement or expansion.

## Decisions

#### Output Template: 4 Sections, Not 5

**Rationale**:
- Motivation folds naturally into Outcome ("X so that Y")
- Separate Motivation section would require fabrication when user doesn't articulate one
- Fewer sections = less friction for nefario to parse

**Alternatives Rejected**:
- 5-section template with separate Motivation (ai-modeling-minion) -- adds dimension users rarely articulate
- Free-form prose (devx-minion) -- loses structural enforcement against implementation leakage

#### Constraint Handling: Preserve Without Meta-Tags

**Rationale**:
- The Constraints header itself signals "user-stated"
- Nefario's specialists evaluate each constraint regardless of tagging
- Tags add visual noise without helping downstream consumers

**Alternatives Rejected**:
- `[user-stated]` annotation tags (ai-modeling-minion) -- noise without value

#### Single-Pass Pattern

**Rationale**:
- All three specialists independently converged on this
- Voice-input users are mid-flow; every additional turn is friction
- Nefario's meta-plan phase fills gaps; the skill doesn't need to be exhaustive

**Alternatives Rejected**:
- Multi-turn interview (no specialist recommended this)

## Conflict Resolutions

None. All three specialists converged on the same core design (single-pass, 4 dimensions, preserve-over-filter). Minor differences in output format and section naming were resolved in synthesis without controversy.

## Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | ai-modeling-minion, devx-minion, ux-strategy-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo |
| Execution | devx-minion |
| Code Review | (skipped -- no executable code) |
| Test Execution | (skipped -- no tests) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- self-documenting skill) |

## Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| `.claude/skills/despicable-prompter/SKILL.md` | created | Briefing coach skill with YAML frontmatter, input classification, output template, 3 examples, edge cases |

## Approval Gates

None. Single text file, easy to reverse, zero downstream dependents.

## Verification

| Phase | Result |
|-------|--------|
| Code Review | (skipped -- no executable code) |
| Test Execution | (skipped -- no tests) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- self-documenting skill) |

## Outstanding Items

- [ ] Add `/despicable-prompter` entry to CLAUDE.md Structure section (deferred: out of explicit scope per user's boundary, but follows `/lab` precedent)

## Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~2m (parallel) |
| Synthesis | ~2m |
| Architecture Review | ~1m (parallel) |
| Execution | ~1m |
| Post-execution | (skipped) |
| **Total** | **~8m** |
