# Lucy Review: Phase 8 Restructure + TEMPLATE.md docs-debt + AGENT.md Update

## VERDICT: ADVISE

Five findings. One substantive semantic conflict with the canonical spec, two
internal inconsistencies, two minor formatting items.

---

## Findings

### 1. [ADVISE] the-plan.md vs SKILL.md/AGENT.md: 8a/8b semantics diverge

**Files**: `the-plan.md:266-272`, `skills/nefario/SKILL.md:1942-2013`, `nefario/AGENT.md:830`

**The canonical spec (`the-plan.md`) defines:**
- 8a = parallel doc execution (software-docs-minion + user-docs-minion)
- 8b = sequential marketing review (product-marketing-minion)

**The changed files define:**
- 8a = documentation assessment (always runs, generates checklist)
- 8b = documentation execution (conditional, includes both doc agents + marketing)

These are fundamentally different semantics using the same labels. The SKILL.md
and AGENT.md have introduced an "always-run assessment" phase that does not exist
in `the-plan.md` at all. The canonical spec says Phase 8 is entirely conditional
("If no items match, Phase 8 is skipped entirely").

**Severity**: COMPLIANCE. `the-plan.md` is the canonical spec per CLAUDE.md
("source of truth, human-edited"). The deployed files redefine its terms without
updating it.

**Fix**: Either update `the-plan.md` to reflect the new 8a/8b semantics (requires
human owner approval per CLAUDE.md: "Do NOT modify the-plan.md unless you are the
human owner or the human owner approves"), or realign SKILL.md/AGENT.md to match
the canonical spec. If the assessment-always-runs behavior is intended, the spec
must be updated first.

---

### 2. [ADVISE] SKILL.md overview line 157: Phase 8 description contradicts 8a always-run

**File**: `skills/nefario/SKILL.md:157`

The overview list says:

> 8. **Documentation** -- Generate/update project documentation (conditional: checklist has items)

But the Phase 8 detail section at line 1942 says Phase 8a "always runs." The
parenthetical "(conditional: checklist has items)" describes only 8b behavior. A
reader scanning the overview gets the wrong mental model: that the entire phase is
conditional.

**Severity**: CONVENTION. Internal inconsistency within the same file.

**Fix**: Update the overview parenthetical to reflect the 8a/8b split, e.g.:
`(8a: always assesses; 8b: conditional on checklist items)`

---

### 3. [ADVISE] TEMPLATE.md docs-debt field description references Phase 8a/8b but schema section does not explain them

**File**: `docs/history/nefario-reports/TEMPLATE.md:299`

The `docs-debt` field description says:

> `none` (Phase 8a found 0 items or all items addressed in 8b), `deferred` (Phase 8a found items but Phase 8b was skipped)

This references Phase 8a and 8b as known concepts, but the template itself
provides no definition of these sub-phases. A report author encountering this
for the first time gets no context. The Phase 8 section in the skeleton (line 94-96)
still reads simply:

> ### Phase 8: Documentation
> {Documentation outcome or "Skipped ({reason})."}

This does not reflect the 8a/8b split either.

**Severity**: CONVENTION. The template's skeleton and its field descriptions are
internally misaligned on the Phase 8 model.

**Fix**: Update the Phase 8 skeleton section to acknowledge the 8a/8b structure
(e.g., separate narrative guidance for assessment vs execution outcomes). Or add a
brief inline definition of 8a/8b near the `docs-debt` field description.

---

### 4. [NIT] TEMPLATE.md Documentation Debt section: conditional inclusion phrasing

**File**: `docs/history/nefario-reports/TEMPLATE.md:213`

The conditional inclusion comment reads:

> {INCLUDE WHEN `docs-debt` = `deferred`. OMIT WHEN `docs-debt` = `none`.}

This matches the established pattern used elsewhere in the template (e.g., line 313
for Post-Nefario Updates). Consistent -- no issue. Noting for completeness that this
is well-formed.

---

### 5. [NIT] AGENT.md line 830: dense single-line description

**File**: `nefario/AGENT.md:830`

The Phase 8 bullet is significantly longer than its sibling bullets (lines 827-829).
The 8a/8b detail, debt tracking, and sub-step agent list are all packed into one
line. This is within the correct `@domain:post-execution-phases` section boundary
and factually accurate, but readability suffers compared to the compact style of
Phases 5-7.

**Severity**: NIT. Functional but could benefit from breaking into sub-bullets.

**Fix**: Optional. Consider splitting into a main bullet with sub-bullets for 8a
and 8b, matching the structural detail level of the SKILL.md treatment.

---

## Traceability

| Requirement | Plan Element | Status |
|-------------|-------------|--------|
| Resolve ALWAYS/Conditional contradiction from cross-cutting checklist | Phase 8a always-run assessment in SKILL.md + AGENT.md | PARTIAL -- contradiction shifted rather than resolved (see Finding 1) |
| SKILL.md pattern consistency | Phase 8 section uses established comment tags and formatting | OK |
| TEMPLATE.md v3 schema conventions | docs-debt field + Documentation Debt section added | OK with minor gap (Finding 3) |
| AGENT.md section boundaries | Change is within `@domain:post-execution-phases` markers | OK |

## Summary

The changes are internally coherent and well-structured. The Phase 8a/8b split
is a sound design that separates assessment (always) from execution (conditional),
which does resolve the operational contradiction of "Documentation is ALWAYS in the
checklist but Phase 8 is conditional."

However, this resolution was applied only to the deployed artifacts (SKILL.md,
AGENT.md, TEMPLATE.md) without updating the canonical spec (`the-plan.md`),
creating a spec-vs-implementation divergence. The cross-cutting checklist in
AGENT.md line 295 still says "ALWAYS include" for Documentation, which now makes
sense at the planning level (Phases 1-4) but the Phase 8 execution semantics have
drifted from the spec's definition. The overview line in SKILL.md still describes
Phase 8 as fully conditional, contradicting the 8a always-run behavior documented
50 lines later in the same file.

Recommendation: Land the changes as-is to unblock execution, but open a follow-up
to reconcile `the-plan.md` with the new 8a/8b semantics.
