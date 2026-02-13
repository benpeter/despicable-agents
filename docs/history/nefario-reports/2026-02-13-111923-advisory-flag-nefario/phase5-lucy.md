VERDICT: ADVISE

## Requirements Traceability

| Requirement (from synthesis plan) | Plan Element | Status |
|---|---|---|
| Add `ADVISORY: true` directive to AGENT.md (orthogonal to MODE) | AGENT.md lines 46-54 | COVERED |
| Advisory report output format in AGENT.md | AGENT.md lines 559-611 | COVERED |
| MODE: PLAN + ADVISORY note in AGENT.md | AGENT.md lines 753-755 | COVERED |
| `--advisory` flag in SKILL.md frontmatter argument-hint | SKILL.md line 10 | COVERED |
| Flag Extraction section in SKILL.md | SKILL.md lines 32-47 | COVERED |
| Advisory exception in Core Rules | SKILL.md lines 24-26 | COVERED |
| Advisory context in Phase 2 specialist prompt | SKILL.md lines 677-684 | COVERED |
| ADV prefix in status lines | SKILL.md lines 399-402 | COVERED |
| Advisory Synthesis prompt in SKILL.md | SKILL.md lines 749-794 | COVERED |
| Advisory Termination in SKILL.md | SKILL.md lines 818-832 | COVERED |
| Advisory Wrap-up in SKILL.md | SKILL.md lines 834-893 | COVERED |
| SKILL.md description update | SKILL.md lines 3-9, 154-156 | COVERED |
| TEMPLATE.md `advisory` mode in frontmatter field table | TEMPLATE.md line 265 | COVERED |
| TEMPLATE.md Team Recommendation section in skeleton | TEMPLATE.md lines 127-155 | COVERED |
| TEMPLATE.md conditional section rules for advisory | TEMPLATE.md lines 275-283 | COVERED |
| TEMPLATE.md advisory formatting notes | TEMPLATE.md lines 305-311 | COVERED |
| TEMPLATE.md advisory checklist steps (10a, 10b) | TEMPLATE.md lines 393-394 | COVERED |
| TEMPLATE.md incremental writing advisory note | TEMPLATE.md lines 375-376 | COVERED |
| `the-plan.md` must NOT be modified | Verified: no `advisory`/`ADVISORY` matches | COMPLIANT |

All stated requirements have corresponding plan elements. No orphaned tasks. No unaddressed requirements.

## Findings

### [ADVISE] TEMPLATE.md skeleton frontmatter: mode field not updated

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`
- **Line**: 16
- **Description**: The skeleton's YAML frontmatter still shows `mode: {full | plan}` but does not include `advisory`. The Frontmatter Fields table (line 265) was correctly updated to include `advisory`, creating an inconsistency within the same template file. An LLM copy-pasting the skeleton will omit `advisory` as a valid value.
- AGENT: devx-minion / software-docs-minion (Task 4)
- FIX: Change line 16 from `mode: {full | plan}` to `mode: {full | plan | advisory}`

### [ADVISE] SKILL.md: standard post-synthesis block reads as fallthrough after advisory synthesis

- **File**: `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`
- **Lines**: 796-800
- **Description**: The advisory synthesis section ends at line 794. Line 796 immediately follows with "Nefario will return a structured delegation plan. ... Proceed to Phase 3.5 (Architecture Review)." The Advisory Termination section that overrides this behavior does not appear until line 818, after the Compaction Checkpoint section. An LLM processing this top-to-bottom may process the advisory synthesis, hit the standard post-synthesis instruction at 796 (which says "proceed to Phase 3.5"), and follow it before reaching the advisory termination directive at 818. The advisory termination section says to "skip the compaction checkpoint" but the compaction checkpoint sits between the standard fallthrough (796) and the advisory termination (818), creating a reading-order ambiguity. This is not a hard blocker because the advisory termination section explicitly says "Skip Phases 3.5 through 8 entirely", but the placement increases the risk of misinterpretation.
- AGENT: devx-minion (Task 3)
- FIX: Add a single sentence at line 795 (after "but the file location is consistent.") such as: `When advisory-mode is active, skip the standard post-synthesis steps below and proceed directly to Advisory Termination.` This creates a clear branch point before the standard path.

### [NIT] AGENT.md x-plan-version / x-build-date unchanged

- **File**: `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md`
- **Lines**: 11-12
- **Description**: AGENT.md was substantively modified (new Advisory Directive section, advisory output format, MODE: PLAN advisory note -- ~67 lines added) but `x-plan-version` remains "2.0" and `x-build-date` remains "2026-02-10". Per CLAUDE.md versioning rules, version divergence between `the-plan.md` spec and AGENT.md is tracked via these fields. Since `the-plan.md` was intentionally not updated (this is an operational extension to the skill, not a spec change), the version fields are technically correct -- both still say "2.0" because the spec is still "2.0". However, the `x-build-date` could reasonably be updated to reflect that the built artifact has changed. This is a nit, not a compliance issue.
- AGENT: devx-minion (Task 1)
- FIX: No action required. If the team adopts a convention for tracking operational (non-spec) AGENT.md changes, update `x-build-date` to today's date.

## CLAUDE.md Compliance

| Directive | Status |
|---|---|
| All artifacts in English | COMPLIANT -- all changes are in English |
| Do NOT modify `the-plan.md` | COMPLIANT -- verified via grep |
| No PII, no proprietary data | COMPLIANT -- no PII in changes |
| YAGNI / KISS / Lean and Mean | COMPLIANT -- advisory mode adds ~280 lines across 3 files; proportional to the feature scope (new orchestration mode) |
| Agent boundaries strict | COMPLIANT -- nefario AGENT.md defines the format; SKILL.md defines the workflow; TEMPLATE.md defines the report structure |

## Scope Assessment

No scope creep detected. The changes are tightly scoped to the three files identified in the plan. No new files were created. No unrelated sections were modified. The advisory feature maps directly to the original request ("add a flag to nefario to tell it to assemble a team for advisory only").

## Summary

Two advisory findings, one nit. The skeleton frontmatter inconsistency (TEMPLATE.md line 16) is a minor omission that should be fixed before merge. The SKILL.md reading-order ambiguity (lines 794-818) is a behavioral risk that could cause advisory runs to attempt Phase 3.5 before hitting the termination directive -- recommend adding a branch-point sentence. Neither finding is severe enough to block.
