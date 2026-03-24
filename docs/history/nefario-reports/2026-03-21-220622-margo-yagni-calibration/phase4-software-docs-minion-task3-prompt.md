You are adding a new decision entry to `docs/decisions.md` documenting the
two-tier YAGNI calibration change for margo.

## What to do

### Fix Decision 32 heading (advisory incorporation)

First, check the heading for Decision 32. It likely reads something like
"## Serverless Default (Decision 31)" -- this is an orphaned heading from
a copy-paste. Fix it to read "## Agent Attribution (Decision 32)" or
whatever accurately describes Decision 32's topic.

### Add Decision 33

Add Decision 33 to `docs/decisions.md`. Insert it after Decision 32 and
before the "---" separator that precedes the "Deferred" section.

Add a section heading:
```markdown
## YAGNI Calibration (Decision 33)
```

Then the decision entry. **Keep it concise** -- decision entries are reference
material, not persuasive essays. Trim the duration_ms narrative and velocity
argument to essentials.

```markdown
### Decision 33: Two-Tier YAGNI Calibration for Margo

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-03-19 |
| **Choice** | Replace margo's binary YAGNI justification test with a two-tier evaluation. Tier 1 (speculative): no concrete consumer on the active roadmap -- recommend exclusion. Tier 2 (roadmap-planned): concrete named consumer exists -- evaluate proportional complexity only. A consumer is concrete when it names a specific milestone/task/issue, is on the active roadmap, and the planned work will use the proposed addition. |
| **Alternatives rejected** | (1) Keep binary YAGNI -- creates false-positive deferrals for trivially non-breaking additions with known consumers. (2) Full roadmap exemption -- "it's on the roadmap" becomes a universal YAGNI bypass without a proportional cost filter. |
| **Rationale** | YAGNI protects against speculative complexity, not planned delivery. The two-tier evaluation preserves enforcement for speculative items while eliminating false positives on low-cost roadmap items. The proportional cost criterion prevents the exemption from justifying heavyweight additions. |
| **Consequences** | margo labels items SPECULATIVE or ROADMAP-PLANNED before issuing a verdict. Roadmap-planned items with trivially non-breaking cost are accepted; structurally complex items are flagged regardless. YAGNI Enforcement in `margo/AGENT.md` is the single source of truth. CLAUDE.local.md override removed. |
```

## Constraints

- Do NOT modify any existing decisions (except fixing the Decision 32 heading).
- Do NOT modify the "Deferred" section.
- Follow the exact table format used by existing decisions (| Field | Value | pattern).

## Files

- `docs/decisions.md` -- the only file you modify

## Deliverables

- Decision 33 entry in `docs/decisions.md`
- Fixed Decision 32 heading

When you finish, report back with:
- File path with change scope and line counts
- 1-2 sentence summary of what was produced
