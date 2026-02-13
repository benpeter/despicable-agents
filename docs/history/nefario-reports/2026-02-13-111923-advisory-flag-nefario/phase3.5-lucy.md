# Lucy Review: advisory-flag

**Verdict**: ADVISE

## Intent Alignment

The plan aligns with the original intent. The user's prompt.md asks for `--advisory` flag support on `/nefario` that runs Phases 1-3, produces a report, and skips execution. The plan delivers exactly this across 5 tasks modifying 3 files (AGENT.md, SKILL.md, TEMPLATE.md). No scope creep beyond the stated requirements.

### Requirements Traceability

| Acceptance Criterion | Plan Element | Status |
|---|---|---|
| `/nefario --advisory <task>` runs Phases 1-3, produces advisory report | Tasks 1-3, 5 | COVERED |
| `/nefario --advisory #<issue>` works with issue mode | Task 2 (flag extraction before issue parsing) | COVERED |
| Advisory reports use `mode: advisory` in frontmatter | Task 3 (wrap-up step 3), Task 4 (TEMPLATE.md) | COVERED |
| No branch creation, no commits, no PR | Task 3 (Advisory Termination + Wrap-up) | SEE FINDING 1 |
| Report template handles advisory sections | Task 4 | COVERED |

## Findings

### 1. [ADVISE] Commit in advisory wrap-up contradicts acceptance criterion

**Acceptance criterion #4** (prompt.md line 34): "No branch creation, no commits, no PR for advisory runs."

**Plan** (Task 3, Advisory Wrap-up step 4): "auto-commit with message: `docs: add nefario advisory report for <slug>`"

The plan commits the report to the current branch. The acceptance criterion says "no commits." This is likely an intent ambiguity rather than a true violation -- the user probably meant "no code commits" since the report needs to persist somewhere, and the existing exemplar advisory report (`docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`) was committed to the repo. The proposal section (prompt.md line 14) says only "No branch is created, no PR is opened" without mentioning commits.

**Recommendation**: Clarify with the user whether "no commits" means (a) no commits at all (report is written but not committed) or (b) no feature-branch commits / no code commits (report auto-commit on current branch is acceptable). The plan's behavior (auto-commit report) matches the exemplar pattern and is likely correct intent.

### 2. [ADVISE] the-plan.md is not modified -- version tracking gap

The plan modifies `nefario/AGENT.md` directly (Task 1) without going through the standard build pipeline. Per CLAUDE.md: "Each agent spec in `the-plan.md` has a `spec-version`. Each built `AGENT.md` has `x-plan-version` in its frontmatter. When they diverge, use `/despicable-lab` to regenerate."

The advisory directive is being added directly to AGENT.md without a corresponding `the-plan.md` spec update or version bump. This is arguably correct -- the advisory capability is a SKILL.md-level feature, and the AGENT.md changes are about documenting a directive format, not changing nefario's core remit. But it creates a situation where AGENT.md content is not traceable to `the-plan.md`.

**Recommendation**: Non-blocking. The AGENT.md changes are synthesis-format documentation, not remit changes. If the user wants traceability, a `the-plan.md` note under nefario's invocation model section would be appropriate, but the plan correctly avoids modifying `the-plan.md` per CLAUDE.md's "Do NOT modify" rule.

## CLAUDE.md Compliance

- **"Do NOT modify `the-plan.md`"**: All 5 tasks explicitly include "Do not modify `the-plan.md`" in their negative constraints. COMPLIANT.
- **"Never delete remote branches"**: Not applicable (advisory mode creates no branches). COMPLIANT.
- **"All artifacts in English"**: All plan content is in English. COMPLIANT.
- **"No PII, no proprietary data"**: No PII introduced. COMPLIANT.
- **Engineering Philosophy (YAGNI/KISS)**: The plan is proportionate. 5 tasks for 3 files is reasonable given the serial dependency chain (AGENT.md defines format -> SKILL.md references it -> SKILL.md synthesis -> SKILL.md termination -> SKILL.md description). Task 4 (TEMPLATE.md) runs in parallel. No over-engineering detected -- this is my domain boundary; margo handles the complexity assessment.
- **Session Output Discipline**: Not directly applicable to plan review, but task prompts do not contradict these conventions.

## Convention Adherence

- **File naming**: All modifications target existing files. No new files created. COMPLIANT.
- **Report location**: Advisory reports go to `docs/history/nefario-reports/` with the same naming convention. Matches existing pattern. COMPLIANT.
- **Frontmatter conventions**: `mode: advisory` extends the existing `mode` field vocabulary (`full`, `plan`). Consistent extension. COMPLIANT.
- **Agent assignments**: devx-minion handles CLI/skill changes, software-docs-minion handles template changes. Matches delegation table. COMPLIANT.

## Scope Assessment

No scope creep detected. The plan delivers exactly the 5 acceptance criteria from the prompt. The advisory-to-execution boundary ("start a new orchestration") is a reasonable guard rail, not scope expansion -- it prevents undefined behavior.

The plan is well-contained. Each task has clear "What NOT to Do" constraints. Cross-cutting coverage exclusions are justified. The single approval gate (Task 3) is correctly placed at the core behavioral specification.
