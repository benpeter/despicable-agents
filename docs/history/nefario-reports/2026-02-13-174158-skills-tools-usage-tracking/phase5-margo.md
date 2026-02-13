# Margo Review -- Session Resources Tracking

**Reviewer**: margo
**Files reviewed**: `docs/history/nefario-reports/TEMPLATE.md`, `skills/nefario/SKILL.md`

---

## VERDICT: ADVISE

The changes are proportional to the request. Replacing an always-omitted section
(External Skills) with a broader one (Session Resources) is sound -- it reuses
an empty slot rather than adding a new section. The `<details>` collapse is
appropriate for ancillary data. No new dependencies, no new technology, no code.

That said, there is measurable accidental complexity in the conditional rule
matrix and the formatting rules that could be trimmed.

---

## FINDINGS

- [ADVISE] `docs/history/nefario-reports/TEMPLATE.md`:310 -- The "Skills Invoked"
  subsection has a conditional rule row ("Always included / Never omitted") that
  is a no-op. A subsection that is always present in an always-present parent
  does not need its own conditional rule. This row adds noise to the rules table
  without adding information.
  AGENT: devx-minion
  FIX: Remove the `Session Resources: Skills Invoked subsection` row from the
  Conditional Section Rules table. Its behavior is already implied by the parent
  rule ("Always ... Never omitted entirely").

- [ADVISE] `docs/history/nefario-reports/TEMPLATE.md`:357-365 -- The Session
  Resources formatting rule is 9 lines covering 5 distinct conditions (collapse,
  `/nefario` first, zero-tool omission, compaction fallback, advisory omission).
  Compare to other formatting rules which are 1-2 lines each. The complexity
  budget here is disproportionate to the value of best-effort tool counts.
  Specifically, the distinction between "replace with fallback message when
  counts not available" vs. "omit entirely in advisory mode" is two different
  degradation paths for the same subsection. One path (omit gracefully) would
  suffice for both cases.
  AGENT: devx-minion
  FIX: Unify the degradation: "Omit the Tool Usage subsection when counts are
  not available OR mode is advisory." Remove the fallback message variant. This
  collapses two conditions into one and removes 3 lines of formatting rules.

- [NIT] `skills/nefario/SKILL.md`:2048-2049 -- The frontmatter schema reference
  says "10-11 fields" but with `skills-used` added there are now 10 always +
  2 conditional = 10-12 fields. Not blocking, but the reference is stale.
  AGENT: devx-minion
  FIX: Update to "10-12 fields" (or just "12 fields, 2 conditional").

- [NIT] `docs/history/nefario-reports/TEMPLATE.md`:209 -- The `<summary>` tag
  includes `({N} skills, {M} tool types)` which requires the report writer to
  compute two counts for a collapsed section most readers will never expand.
  A static summary like "Session resources" (no counts) would be simpler, matching
  the pattern used elsewhere. Low stakes since this is a template placeholder.
  AGENT: devx-minion
  FIX: Consider simplifying to `<summary>Session resources</summary>` without
  dynamic counts, or keep as-is if inline counts are valued for scanability.

---

## COMPLEXITY BUDGET ASSESSMENT

| Item | Cost | Justification |
|------|------|---------------|
| New section (Session Resources) | 0 | Replaces existing empty section, net zero |
| New frontmatter field (skills-used) | 0.5 | Conditional, rarely present |
| 3 conditional rules for subsections | 1 | One is a no-op (Skills Invoked always-present) |
| 9-line formatting rule | 1 | Two degradation paths where one suffices |
| SKILL.md data accumulation items | 0.5 | Two new bullet points, well-scoped |
| **Total** | 3 | Acceptable for the feature, reducible to ~2 with fixes above |

The changes stay within budget. The ADVISE items would reduce the rule surface
area without losing any functionality. None are blocking.
