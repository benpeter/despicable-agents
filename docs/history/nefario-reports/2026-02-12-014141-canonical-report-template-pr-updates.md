---
type: nefario-report
version: 3
date: "2026-02-12"
time: "01:41:41"
task: "Define canonical report template and keep PR descriptions current with post-execution updates"
source-issue: 37
mode: full
agents-involved: [software-docs-minion, devx-minion, ux-strategy-minion, security-minion, test-minion, lucy, margo, code-review-minion]
task-count: 3
gate-count: 1
outcome: completed
---

# Define canonical report template and keep PR descriptions current with post-execution updates

## Summary

Defined a canonical v3 report template in TEMPLATE.md with a complete markdown skeleton, conditional section rules, and collapsibility annotations. Added a Post-Nefario Updates mechanism to SKILL.md that detects existing PRs on the current branch and offers to append update sections to the PR body. Updated orchestration docs to reflect the v3 structure.

## Original Prompt

> **Outcome**: Every nefario execution report and PR description follows an identical section structure, and PR descriptions stay accurate when additional work lands on the same branch after the initial nefario run. Currently reports are inconsistent (no template exists — the LLM infers structure from hints), and PR bodies go stale when subsequent nefario runs or manual commits happen on the same branch.

## Key Design Decisions

#### Separate Template File Over Inline in SKILL.md

**Rationale**:
- SKILL.md is already ~1400 lines and loads into every nefario session
- Adding ~150 lines of template inline compounds context cost with no structural benefit
- SKILL.md references TEMPLATE.md the same way it references scratch files — a pattern agents already follow reliably

**Alternatives Rejected**:
- Inline template in SKILL.md: eliminates dual-source risk but adds ~150 lines of context per session. User explicitly chose the separate file approach during plan approval.

#### Detection-and-Nudge Over Auto-Append for PR Updates

**Rationale**:
- Branch identity is not a reliable proxy for "continuation of the same task"
- Auto-appending when a second nefario run addresses a different purpose would corrupt the report
- Two options (Append/Skip) are the minimum viable surface for the decision

**Alternatives Rejected**:
- Fully automatic append: corruption risk when same branch, different purpose
- Three options (Append/Skip/Replace): "Replace" duplicates `gh pr edit` functionality users already know. Dropped per simplicity review.

#### Issue's Prescribed Section Order Preserved

**Rationale**:
- The section order was a deliberate product decision in the issue spec
- PR reviewer scanning concern (Files Changed buried) addressed through collapsibility instead of reordering

**Alternatives Rejected**:
- Moving Files Changed to position 5: contradicts the issue's explicit order

### Conflict Resolutions

Three conflicts arose during planning:

1. **TEMPLATE.md disposition**: devx-minion recommended keeping TEMPLATE.md as external reference; software-docs-minion recommended deleting it and inlining in SKILL.md. Resolved by user decision: keep TEMPLATE.md as authoritative canonical template, SKILL.md references it.

2. **Section ordering**: ux-strategy-minion recommended moving Files Changed earlier and consolidating Key Design Decisions with gate Decisions. Resolved in favor of the issue's prescribed order; collapsibility mitigates the scanning concern.

3. **Post-Nefario Updates mechanism**: devx-minion recommended auto-detect + auto-append; ux-strategy-minion warned about corruption risk. Resolved as detection-and-nudge with 2 options.

## Phases

### Phase 1: Meta-Plan

Nefario identified three specialists for planning: devx-minion (template structure and LLM-followability), software-docs-minion (documentation architecture and TEMPLATE.md governance), and ux-strategy-minion (report audience analysis and section ordering). Testing, security, and observability were excluded from planning as this is a documentation-only task with no new attack surface or runtime components.

### Phase 2: Specialist Planning

Three specialists contributed in parallel. devx-minion recommended a literal fill-in-the-blank template with `{PLACEHOLDER}` tokens and auto-detection of existing PRs for the update mechanism. software-docs-minion recommended deleting TEMPLATE.md and inlining everything in SKILL.md, with plain-English conditional inclusion rules. ux-strategy-minion recommended moving Files Changed earlier in the section order, consolidating the two Decisions sections, and using an appended section (not inline annotations) for Post-Nefario Updates.

### Phase 3: Synthesis

Nefario resolved three conflicts between specialists and produced a 3-task plan: (1) write canonical template, (2) add Post-Nefario Updates mechanism, (3) delete TEMPLATE.md and update cross-references. One approval gate after Task 1.

### Phase 3.5: Architecture Review

Six mandatory reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo) reviewed the plan. Result: 3 APPROVE, 3 ADVISE, 0 BLOCK. Key advisories incorporated: margo's simplification of 3 options to 2 for the PR update mechanism, software-docs-minion's explicit conditional detection references, lucy's section hierarchy validation at gate.

### Phase 4: Execution

The user revised the plan before execution: chose the separate file approach (TEMPLATE.md stays, SKILL.md references it) instead of inlining. Task 1 rewrote TEMPLATE.md as v3 canonical template and updated SKILL.md references. Gate approved. Task 2 added PR detection and Post-Nefario Updates mechanism to SKILL.md wrap-up. Task 3 updated orchestration.md cross-references and verified build-index.sh compatibility.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo). 1 APPROVE, 2 ADVISE. code-review-minion identified a NIT in the manual update convention (missing frontmatter stripping) — auto-fixed. lucy noted the TEMPLATE.md disposition differs from the synthesis plan but acknowledged the user's explicit choice. margo noted minor content duplication in gate briefs across Execution and Decisions sections — accepted as intentional per issue spec.

### Phase 6: Test Execution

Skipped (documentation-only change, no tests to run).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (documentation was the primary deliverable).

## Agent Contributions

<details>
<summary>Agent Contributions (3 planning, 6 review, 3 code review)</summary>

### Planning

**devx-minion**: Recommended literal fill-in-the-blank template with `{PLACEHOLDER}` tokens and auto-detection of existing PRs.
- Adopted: placeholder token syntax, PR detection via `gh pr list`, v3 frontmatter schema
- Risks flagged: SKILL.md length growth, PR body relative links not resolving in GitHub PR view

**software-docs-minion**: Recommended deleting TEMPLATE.md and inlining template in SKILL.md with plain-English conditional rules.
- Adopted: INCLUDE WHEN/OMIT WHEN conditional rules, report writing checklist update
- Risks flagged: build-index.sh v2/v3 compatibility (verified compatible)

**ux-strategy-minion**: Recommended collapsibility strategy, appended section for Post-Nefario Updates, detection-and-nudge approach.
- Adopted: collapsibility annotations, appended section pattern, detection-and-nudge with user choice
- Risks flagged: auto-append corruption risk for unrelated tasks on same branch

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: APPROVE. Documentation-only change, manual validation appropriate.

**ux-strategy-minion**: APPROVE. Design decisions serve all three report audiences well.

**software-docs-minion**: ADVISE. Template subsection numbering could confuse executing agents; conditional section detection needs explicit session data references.

**lucy**: ADVISE. Section hierarchy interpretation (nested vs flat) ambiguous in issue spec; flagged for gate validation. Stale line number references mitigated by semantic anchors.

**margo**: ADVISE. Reduced Post-Nefario Updates from 3 options to 2 (dropped "Replace"). Minor prompt redundancy in Task 1.

### Code Review

**code-review-minion**: APPROVE. Internal consistency confirmed. One NIT: manual update convention missing frontmatter stripping — auto-fixed.

**lucy**: ADVISE. TEMPLATE.md kept as separate file contradicts synthesis plan but matches user's explicit choice.

**margo**: ADVISE. Minor content duplication in gate briefs between Execution and Decisions sections — intentional per issue spec.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Rewrite TEMPLATE.md as canonical v3 template + add SKILL.md reference | software-docs-minion | completed |
| 2 | Add Post-Nefario Updates mechanism to SKILL.md wrap-up | devx-minion | completed |
| 3 | Update cross-references and verify build-index.sh compatibility | software-docs-minion | completed |

### Files Changed

| File Path | Action | Description |
|-----------|--------|-------------|
| docs/history/nefario-reports/TEMPLATE.md | modified | Full rewrite as v3 canonical template (332 lines) |
| skills/nefario/SKILL.md | modified | Template reference, PR detection, Post-Nefario Updates mechanism |
| docs/orchestration.md | modified | Updated report section list to v3 |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Canonical v3 Report Template | software-docs-minion | HIGH | approved | 1 |

#### Canonical v3 Report Template

**Decision**: Adopt v3 report template as canonical structure for all future reports and PR bodies.
**Rationale**: Skeleton with placeholders prevents LLM drift (root cause of inconsistency). Separate file keeps SKILL.md focused. Conditional rules use INCLUDE WHEN/OMIT WHEN — no ambiguous "optional."
**Rejected**: Inline template (context bloat), keeping v2 format (no section standardization).

## Decisions

#### Canonical v3 Report Template

**Decision**: Adopt v3 report template with 12 top-level H2 sections in the issue's prescribed order, `{PLACEHOLDER}` skeleton, and explicit conditional inclusion rules.
**Rationale**: The root cause of report inconsistency was the absence of a deterministic template — the LLM inferred structure from prose hints in SKILL.md. A skeleton with placeholders is followed precisely; prose descriptions drift.
**Rejected**: Inline template in SKILL.md (adds ~150 lines of context per session), keeping v2 format (doesn't address section naming or ordering inconsistencies).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 1 APPROVE, 2 ADVISE — 1 NIT auto-fixed (frontmatter stripping) |
| Test Execution | Skipped (documentation-only change) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (documentation was the primary deliverable) |

## Working Files

<details>
<summary>Working files (15 files)</summary>

Companion directory: [2026-02-12-014141-canonical-report-template-pr-updates/](./2026-02-12-014141-canonical-report-template-pr-updates/)

- [Original Prompt](./2026-02-12-014141-canonical-report-template-pr-updates/prompt.md)
- [Phase 1: Meta-plan](./2026-02-12-014141-canonical-report-template-pr-updates/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-12-014141-canonical-report-template-pr-updates/phase2-devx-minion.md)
- [Phase 2: software-docs-minion](./2026-02-12-014141-canonical-report-template-pr-updates/phase2-software-docs-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-12-014141-canonical-report-template-pr-updates/phase2-ux-strategy-minion.md)
- [Phase 3: Synthesis](./2026-02-12-014141-canonical-report-template-pr-updates/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-12-014141-canonical-report-template-pr-updates/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-12-014141-canonical-report-template-pr-updates/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-12-014141-canonical-report-template-pr-updates/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-12-014141-canonical-report-template-pr-updates/phase3.5-software-docs-minion.md)
- [Phase 3.5: lucy](./2026-02-12-014141-canonical-report-template-pr-updates/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-12-014141-canonical-report-template-pr-updates/phase3.5-margo.md)
- [Phase 5: code-review-minion](./2026-02-12-014141-canonical-report-template-pr-updates/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-12-014141-canonical-report-template-pr-updates/phase5-lucy.md)
- [Phase 5: margo](./2026-02-12-014141-canonical-report-template-pr-updates/phase5-margo.md)

</details>
