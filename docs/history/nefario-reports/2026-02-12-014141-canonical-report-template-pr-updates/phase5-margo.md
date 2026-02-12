# Phase 5: Margo Code Review

## Verdict: ADVISE

## Findings

### 1. [ADVISE] TEMPLATE.md — Duplicated gate decision content between Execution and Decisions sections

**File**: `docs/history/nefario-reports/TEMPLATE.md`, lines 149-165

The template has gate decision briefs appearing in two places: once under
"Execution > Approval Gates" (lines 149-153) and again under the standalone
"Decisions" section (lines 155-165). The Decisions section repeats the same
fields (Decision, Rationale, Rejected) with slightly more detail (adding
Confidence and Outcome fields). This creates structural duplication in every
report that has gates.

**Simpler alternative**: Merge the two into one location. Either the Execution
section's gate table links to the Decisions section for detail (current approach
seems to intend this but the template shows both with overlapping content), or
the Decisions section is removed and the Execution section's per-gate H4 blocks
carry the full rationale. The conditional-section rule already says "INCLUDE
WHEN gate-count > 0" for Decisions, so when there are no gates both are omitted
-- but when gates exist, the reader sees the same information twice with minor
variation.

**Impact**: Low. This is a template cosmetic issue, not a mechanism problem.
Reports will be slightly longer than necessary when gates are present.

---

### 2. [ADVISE] SKILL.md — Post-Nefario Updates mechanism: reasonable but has one unnecessary step

**File**: `skills/nefario/SKILL.md`, lines 1428-1470

The Post-Nefario Updates mechanism (step 8 in wrap-up) is well-scoped:

- Triggers only when `existing-pr` is set (detected earlier via `gh pr list`)
- Asks the user before modifying the PR body (not automatic)
- Appends rather than overwrites
- Handles the "already has updates section" case (no duplicate H2)
- Has a clean "Separate report only" escape hatch

This is proportional to the problem. Running multiple nefario sessions on the
same branch is a real workflow (iterative development on a feature branch), and
silently writing a second report without updating the PR body would leave the PR
description stale. The mechanism is straightforward: fetch body, append section,
update body. No new dependencies, no new abstractions.

One minor concern: the mechanism generates a mini "Files changed" table inside
the update section (lines 1447-1450). This duplicates content that already
exists in the new report file which is linked from the same update block
(`**Report**: [{report-slug}](./{report-filename})`). The reader can click
through to the full report for file details. Consider whether the embedded
table is worth the template complexity or whether the link alone suffices.

---

### 3. [ADVISE] TEMPLATE.md — Template is 332 lines for a documentation skeleton

The template file is 332 lines. Of those, roughly 130 lines are the actual
skeleton (the markdown between the code fences), and 200 lines are template
notes (frontmatter field descriptions, conditional rules, collapsibility rules,
formatting rules, naming conventions, index file docs, incremental writing,
report writing checklist). These notes are valuable reference material, but the
file serves two roles: (1) a fillable skeleton for report generation, and (2)
a comprehensive reference manual for the template format.

This is not a blocking concern because the notes are genuinely useful and having
them co-located with the skeleton means there is one canonical source of truth.
The alternative (splitting into TEMPLATE.md + TEMPLATE-GUIDE.md) would add a
file and create a synchronization burden. Keeping it in one file is the simpler
choice. Noting this only because 332 lines for a template is on the heavy side
-- if it grows further, consider whether the notes could be trimmed.

---

### 4. [NIT] docs/orchestration.md — Minimal change, well-integrated

The orchestration.md change (line 486-488) adds Post-Nefario Updates to the
report section list with correct conditional-inclusion annotation and adds
a one-line reference to TEMPLATE.md. Clean, no excess.

---

## Summary

The Post-Nefario Updates mechanism in SKILL.md is proportional to the problem
it solves. It reuses existing infrastructure (`existing-pr` detection, `gh pr`
commands), adds no new dependencies, and gives the user control via an
explicit prompt. The template is comprehensive and well-structured. The only
complexity concerns are minor: duplicated gate content between two report
sections, and an embedded files-changed table in the update section that may
not justify its template weight.

No blocking issues. Complexity budget impact: approximately 0 points (no new
technology, no new service, no new abstraction layer, no new dependency).
