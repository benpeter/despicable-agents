# Lucy Review: Remove Overlay Mechanism (Issue #32)

## Original Request

Issue #32: Remove the overlay mechanism from the despicable-agents project. The mechanism (~2,900 lines) served only nefario and violated YAGNI/KISS/Lean-and-Mean principles. Mark nefario as hand-maintained, delete overlay artifacts, update documentation.

## Requirements Extracted

| # | Requirement | Source |
|---|-------------|--------|
| R1 | Remove `x-fine-tuned: true` from nefario frontmatter | Issue #32 |
| R2 | Remove overlay branching from `/despicable-lab` build pipeline | Issue #32 |
| R3 | Add nefario skip to `/despicable-lab` | Issue #32 |
| R4 | Remove overlay section from agent-anatomy docs | Issue #32 |
| R5 | Remove Merge Step from build-pipeline docs | Issue #32 |
| R6 | Record Decision 27, update superseded D9/D16 | Issue #32 |
| R7 | Update architecture.md table (remove overlay reference) | Issue #32 |
| R8 | Simplify deployment.md | Issue #32 |
| R9 | Remove `x-fine-tuned` comment from `the-plan.md` frontmatter pattern | Issue #32 |

## Traceability

| Requirement | Plan Element | Status |
|-------------|-------------|--------|
| R1 | `nefario/AGENT.md` -- `x-fine-tuned: true` removed from frontmatter | COVERED |
| R2 | `.claude/skills/despicable-lab/SKILL.md` -- overlay branching removed | COVERED |
| R3 | `.claude/skills/despicable-lab/SKILL.md` -- nefario skip added | COVERED |
| R4 | `docs/agent-anatomy.md` -- overlay section removed, retitled | COVERED |
| R5 | `docs/build-pipeline.md` -- Merge Step removed, simplified | COVERED |
| R6 | `docs/decisions.md` -- D27 added, D9/D16 marked superseded | COVERED |
| R7 | `docs/architecture.md` -- table row updated | COVERED |
| R8 | `docs/deployment.md` -- simplified | COVERED |
| R9 | `the-plan.md` -- x-fine-tuned comment removed | COVERED |

All requirements are addressed. No orphaned tasks (nothing beyond scope). No unaddressed requirements.

## Findings

### [ADVISE] CONVENTION `docs/decisions.md`:191 -- Stale AGENT.overrides.md reference in Decision 15

Decision 15 Consequences field still reads: "Constraint encoded in AGENT.overrides.md and AGENT.md." Since AGENT.overrides.md no longer exists (removed by this work), this reference is stale. D15 was not marked as superseded (it is still active -- the constraint itself still holds, just not in overrides), but the consequences text should be updated.

**Fix**: Change "Constraint encoded in AGENT.overrides.md and AGENT.md." to "Constraint encoded in AGENT.md (hand-maintained)." in Decision 15 Consequences.

### [NIT] CONVENTION `docs/decisions.md`:195 -- Section header "Overlay System (Decision 16)" is orphaned-looking

The section header "Overlay System (Decision 16)" now introduces a superseded decision. This is not wrong -- the decision log preserves history -- but the section title does not signal that D16 is superseded. The reader has to reach the Status field to learn that. This is consistent with how D9 is handled (its section header also does not signal supersession), so this is a style nit only, not an inconsistency.

**Fix**: No action required. Consistent with D9 treatment. Optionally, consider adding "(Superseded)" to section headers of superseded decisions in a future cleanup pass.

### [NIT] CONVENTION `docs/history/` -- Historical overlay docs remain

Three historical files in `docs/history/` reference overlays extensively:
- `docs/history/nefario-reports/2026-02-09-003-overlay-drift-detection.md`
- `docs/history/overlay-implementation-summary.md`
- `docs/history/overlay-decision-guide.md`

These are historical records and should NOT be modified (they document what happened at a point in time). Noting for completeness -- no action needed.

## CLAUDE.md Compliance

| Directive | Status |
|-----------|--------|
| All artifacts in English | PASS -- all changed files are in English |
| Do NOT modify `the-plan.md` unless human-approved | PASS -- the-plan.md change removes a comment per issue scope; issue was filed by the human owner |
| No PII, no proprietary data | PASS |
| Agent boundaries respected | PASS -- this is documentation/infrastructure work, not specialist domain work |
| Helix Manifesto (YAGNI, KISS, Lean and Mean) | PASS -- the entire change IS an application of these principles |

## Scope Assessment

**Scope creep**: None detected. Every changed file traces to a stated requirement.

**Gold-plating**: None detected. Changes are minimal and proportional.

**Proportionality**: The problem (remove ~2,900 lines of unused infrastructure) has a proportional solution (update 8 files to remove references and document the decision).

## Verdict

**VERDICT: ADVISE**

One stale reference in Decision 15 Consequences should be updated to remove the now-nonexistent `AGENT.overrides.md` mention. This is non-blocking -- a minor documentation inconsistency that does not affect functionality or create confusion beyond the decisions.md file itself. All other changes are clean, well-scoped, and aligned with the original intent.

### Summary

- 1 ADVISE finding (stale D15 reference)
- 1 NIT (superseded section headers -- consistent with existing pattern)
- 1 NIT (historical docs retained correctly)
- 0 BLOCK findings
- 0 DRIFT findings
- 0 SCOPE findings
- Full CLAUDE.md compliance
- Full requirements coverage
