---
task: "Extension mechanism for integrating external skills and domain knowledge"
source-issue: 29
date: 2026-02-11
branch: nefario/external-skill-integration
status: complete
agents-consulted: 5
agents-reviewed: 6
tasks-executed: 5
gates: 1
verification: code review passed (3 ADVISE, 0 BLOCK)
---

# External Skill Integration

## Executive Summary

Enabled nefario to discover, classify, and delegate to external project-local
skills without requiring external skills to adopt despicable-agents conventions.
All changes are prompt-level (AGENT.md, SKILL.md edits) and documentation --
no new code, infrastructure, or tooling.

## Original Prompt

Outcome: Users can combine despicable-agents orchestration with external domain
skills (e.g., AEM/EDS skills, gh-upskill packages) without forking or modifying
despicable-agents itself. The integration is loosely coupled -- external skills
keep their own patterns and conventions, despicable-agents discovers and
delegates to them rather than absorbing them.

## Key Design Decisions

1. **Filesystem is the registry** -- nefario scans `.claude/skills/` and `.skills/`
   during META-PLAN. No skill manifest, catalog, or registry.

2. **Content-signal classification** -- ORCHESTRATION vs LEAF determined by
   natural language heuristic (phases, ordering, sub-skill references), not
   formal algorithm or mandatory metadata.

3. **Three-tier precedence** -- CLAUDE.md explicit preferences > project-local >
   specificity. Cross-cutting reviews never yielded.

4. **Deferred macro-tasks** -- orchestration skills become single opaque tasks
   in the delegation plan, executed in main session context.

5. **`<external-skill>` content boundaries** -- same pattern as `<github-issue>`
   for prompt injection defense.

6. **Dropped `keywords:` metadata** -- `description` field is sufficient.
   Optional keywords create implied coupling.

## Agent Contributions

### Planning (Phase 2)

| Agent | Recommendation |
|-------|---------------|
| devx-minion | Prompt-level changes only; filesystem is registry; SKILL.md frontmatter is manifest |
| ai-modeling-minion | Content-signal classification; three-tier precedence; deferred macro-task pattern |
| software-docs-minion | Three doc artifacts; dual-perspective approach; three-tier integration contract |
| ux-strategy-minion | Auto-discovery mandatory; "(project skill)" suffix; simplification audit (6 things NOT to build) |
| security-minion | `<external-skill>` content boundaries; rely on Claude Code permissions; no custom permission layer |

### Architecture Review (Phase 3.5)

| Reviewer | Verdict | Key Point |
|----------|---------|-----------|
| security-minion | ADVISE | Add realpath validation and name collision handling |
| test-minion | ADVISE | Post-merge smoke test recommended |
| ux-strategy-minion | APPROVE | All UX criteria satisfied |
| software-docs-minion | APPROVE | All documentation criteria satisfied |
| lucy | ADVISE | Opus model justified by user instruction; Task 4 could parallelize |
| margo | ADVISE | Merge Tasks 4+5; reduce doc target to 200-300 lines |

### Code Review (Phase 5)

| Reviewer | Verdict | Key Finding |
|----------|---------|-------------|
| code-review-minion | ADVISE | `context: fork` signal in AGENT.md not mentioned in external-skills.md |
| lucy | ADVISE | SKILL.md Phase 1 discovery omits realpath sub-step; silent skip of missing frontmatter |
| margo | ADVISE | Precedence tier 3 is speculative; external-skills.md slightly over-documented |

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Design integration surface (AGENT.md) | ai-modeling-minion | Complete (GATED) |
| 2 | Update SKILL.md phases | ai-modeling-minion | Complete |
| 3 | Write docs/external-skills.md | software-docs-minion | Complete |
| 4 | Add user guide section | user-docs-minion | Complete |
| 5 | Update cross-references | software-docs-minion | Complete |

### Files Changed

| File | Change | Lines |
|------|--------|-------|
| `nefario/AGENT.md` | New External Skill Integration section | +82 |
| `skills/nefario/SKILL.md` | Discovery, synthesis, deferral, content boundary | +45 |
| `docs/external-skills.md` | New architecture reference | +157 |
| `docs/using-nefario.md` | Working with Project Skills section | +28 |
| `docs/architecture.md` | Composable bullet + sub-documents row | +2 |
| `docs/decisions.md` | Decision 28 | +14 |
| `README.md` | External skill mention | +2 |

### Gate Decisions

**Gate 1: External Skill Integration Surface Design**
- Decision: Add prompt-level discovery, classification, and deferral logic to AGENT.md
- Outcome: Approved
- Confidence: MEDIUM
- Rejected alternatives: skill registry/manifest (YAGNI), configurable precedence (one heuristic + override sufficient)

## Verification

- Code review: 3 ADVISE, 0 BLOCK (accepted as non-blocking)
- Tests: Skipped (no executable code produced)
- Documentation: Covered by execution tasks 3-5

## Conflicts Resolved

1. **Keywords metadata**: Dropped per ux-strategy + devx consensus over software-docs Tier 1 proposal
2. **Classification complexity**: Content signals as natural language guidance, not weighted scoring
3. **Documentation scope**: external-skills.md created but maintainer section capped at ~150 words

## Outstanding Items

- Post-merge smoke test: Run `/nefario` on a project with external skills to validate discovery path
- Code review ADVISE items (non-blocking): `context: fork` documentation gap, SKILL.md realpath sub-step

## Working Files

Companion directory: `docs/history/nefario-reports/2026-02-11-143008-external-skill-integration/`

Files:
- `prompt.md` -- original prompt
- `phase1-metaplan.md` -- meta-plan
- `phase2-*.md` -- specialist planning contributions (5 files)
- `phase3-synthesis.md` -- execution plan
- `phase3.5-*.md` -- architecture review verdicts (6 files)
- `phase5-*.md` -- code review verdicts (3 files)
