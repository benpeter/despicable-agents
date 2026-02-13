# Lucy Review: Skills & Tool Usage Tracking

## Verdict: ADVISE

The changes align well with the original intent of issue #98. The TEMPLATE.md
and SKILL.md modifications are internally consistent with each other and
faithfully implement the synthesis plan. The naming inconsistency
(`skills-invoked` in SKILL.md body vs `skills-used` in frontmatter) is
intentional and documented in the synthesis with clear rationale. No goal drift
detected. However, there are two orphaned references and one stale count that
should be addressed.

---

## Requirements Traceability

| Requirement (from issue #98) | Plan Element | Status |
|------------------------------|-------------|--------|
| Report template includes a section for skills invoked | TEMPLATE.md `## Session Resources` > `### Skills Invoked` | Covered |
| Report template includes a section for tools used (with counts if feasible) | TEMPLATE.md `## Session Resources` > `### Tool Usage` | Covered |
| Skills tracking populated from conversation context | SKILL.md `At Wrap-up` > `skills-invoked` accumulation item | Covered |
| Tool counts are best-effort, omitted gracefully if not available | TEMPLATE.md formatting rules + SKILL.md wrap-up step 6 | Covered |
| Existing reports remain valid (additive) | No version bump, conditional inclusion, External Skills preserved as subsection | Covered |
| Scope: TEMPLATE.md and SKILL.md only | Only those two files changed | Covered |
| Out of scope: runtime hooks, shell instrumentation, backfilling | Not present | Confirmed absent |

No orphaned requirements. No scope creep beyond stated requirements.

---

## Findings

### 1. [ADVISE] `docs/orchestration.md`:531 -- Orphaned "External Skills" standalone reference

`docs/orchestration.md` line 531 still describes `External Skills` as a
standalone top-level report section:

```
- **External Skills**: Table of external skills discovered during meta-plan.
  Conditional: included only when skills were discovered.
```

This is now stale. External Skills is a subsection of Session Resources, not a
standalone H2 section. This file was not in the declared change scope, but it
describes the report structure and will mislead anyone reading the
orchestration docs.

AGENT: devx-minion (Task 1 and Task 2 both missed this downstream reference)
FIX: Replace the External Skills bullet in `docs/orchestration.md:531` with a
Session Resources bullet that describes the merged section (three subsections:
External Skills, Skills Invoked, Tool Usage; collapsed by default; always
present structurally).

### 2. [ADVISE] `nefario/AGENT.md`:536 -- Orphaned "External Skills" subsection header in execution plan skeleton

`nefario/AGENT.md` lines 536-544 contain a standalone `### External Skills`
subsection in the execution plan output skeleton, with the instruction "Omit
the External Skills subsection if no external skills are used in the plan."
This is the execution plan skeleton (Phase 3 output), not the report skeleton,
so it is a different context -- but the terminology overlap with the now-renamed
report section could cause confusion. The execution plan's External Skills
subsection is about skills discovered during planning and used in execution
tasks, which is distinct from the report's Session Resources section.

AGENT: devx-minion
FIX: No change needed to the execution plan skeleton itself (it serves a
different purpose). However, confirm this was intentionally left unchanged.
The synthesis plan explicitly scoped only TEMPLATE.md and SKILL.md. This is
acceptable if the distinction between "execution plan External Skills" and
"report Session Resources: External Skills" is clear to the orchestrator.
Downgrade to NIT if the team confirms this is intentional.

### 3. [ADVISE] `skills/nefario/SKILL.md`:2048 -- Stale frontmatter field count

Line 2048 says `v3 YAML frontmatter schema (10-11 fields)`. With the addition
of the conditional `skills-used` field, the frontmatter now has 12 fields
(10 always-present + 2 conditional: `source-issue` and `skills-used`). The
count should be updated to `10-12 fields` or `12 fields (10 required,
2 conditional)`.

AGENT: devx-minion (Task 2)
FIX: Update `skills/nefario/SKILL.md:2048` from `(10-11 fields)` to
`(10-12 fields)`.

### 4. [NIT] `skills/nefario/SKILL.md`:2049 -- Section count says 12 but skeleton has 13 H2 sections

Line 2049 says `Canonical section order (12 top-level H2 sections)`. Counting
the actual H2 sections in the TEMPLATE.md skeleton yields 13 (Summary, Original
Prompt, Key Design Decisions, Phases, Agent Contributions, Team Recommendation,
Execution, Decisions, Verification, Session Resources, Working Files, Test Plan,
Post-Nefario Updates). This appears to be a pre-existing discrepancy (Team
Recommendation was likely added after the count was set), not introduced by
this PR. The rename from External Skills to Session Resources did not change
the count. Flagging for awareness.

AGENT: pre-existing (not attributable to current execution)
FIX: Update to `(13 top-level H2 sections)` or clarify that the count
excludes conditional-only sections.

---

## CLAUDE.md Compliance

| Directive | Status |
|-----------|--------|
| All artifacts in English | PASS |
| No PII, no proprietary data | PASS |
| Do NOT modify `the-plan.md` | PASS (not touched) |
| YAGNI / KISS | PASS -- changes are additive, minimal, well-scoped |
| Version: no bump (additive) | PASS (version remains 3) |
| Never delete remote branches | N/A |

## Scope Assessment

The changes are proportional to the problem. Two files changed, both
documentation/template artifacts. No code, no runtime components, no new
dependencies. The synthesis decision to merge External Skills into Session
Resources rather than adding a parallel section is well-justified (External
Skills was never populated in any existing report).

## Naming Consistency Check

The naming split (`skills-invoked` in SKILL.md accumulation data vs
`skills-used` in YAML frontmatter) is intentional per the synthesis plan.
The rationale is documented: `skills-used` matches the verb pattern of
`agents-involved` in frontmatter, while `skills-invoked` is the internal
accumulation label. The report body section is `### Skills Invoked`. This
is consistent -- the frontmatter field name and the internal tracking label
serve different audiences (machine-parseable frontmatter vs. human-readable
accumulation instructions).
