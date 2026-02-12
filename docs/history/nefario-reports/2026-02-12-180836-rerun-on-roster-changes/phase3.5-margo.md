# Phase 3.5 Review: margo (Simplicity / YAGNI / KISS)

## Verdict: ADVISE

The plan is well-scoped to the problem and the conflict resolutions are sound.
The 4-task breakdown is justified (shared definition, two independent gate
modifications, documentation). No speculative functionality detected. The
invisible classification and lack of override keywords are the right call --
they avoid adding user-facing complexity for a system-level optimization.

### Non-blocking concerns

**1. Re-run cap is redundant with the adjustment cap (low risk)**

The plan introduces a "1 re-run cap per gate" on top of the existing "2
adjustment round cap." The re-run cap adds a rule that, combined with the
adjustment cap, creates a 2x2 matrix of states (adjustment round 1 or 2,
re-run used or not) at each gate. In practice, the adjustment cap alone already
bounds the worst case: at most 2 substantial adjustments = at most 2 re-runs.
The separate re-run cap handles the edge case where a user makes 2 substantial
adjustments in 2 rounds, and the system needs to re-run twice -- which is
already bounded by the adjustment cap.

The only scenario the re-run cap prevents that the adjustment cap does not: a
single adjustment round somehow triggering multiple re-runs. But the design
already ensures one classification per adjustment, so this cannot happen.

**Recommendation**: Consider dropping the per-gate re-run cap. The adjustment
cap (2 rounds) is sufficient. If the team wants to keep it as a defense-in-depth
measure, that is acceptable -- it is one sentence in the spec, not a code
abstraction. Just be aware it is a belt-and-suspenders rule, not a necessary
constraint. Non-blocking because the cost is one sentence of spec text, not
structural complexity.

**2. Context-aware re-run prompt is detailed but justified**

Task 2's constraint directive for the re-run prompt (7 bullet points) is on the
edge of over-specification. However, since a re-spawned nefario in META-PLAN
mode is a powerful agent that could easily drift scope, the constraints are
justified as essential guardrails. No change needed.

**3. Separate output file (phase1-metaplan-rerun.md) vs. overwrite**

The plan chose a separate file to avoid stale in-context references. This is
the right call. The alternative (overwrite) would be simpler but riskier. The
one-file-per-run approach is a minor complexity cost for a real safety benefit.
Acceptable.

### What looks good

- The adjustment classification definition is shared between both gates (DRY).
- The reviewer gate re-evaluation is correctly scoped as in-session (no
  subagent spawn) -- proportional to the lighter-weight nature of reviewer
  selection vs. full meta-planning.
- No new dependencies, no new technologies, no new gate types.
- The "invisible to user" design avoids adding cognitive load.
- Task count (4) is proportional to the problem: 1 shared definition + 2
  independent gate modifications + 1 documentation update. Consolidating
  further would create unnecessarily large diffs.
