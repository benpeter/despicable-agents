# Architecture Review: Margo (Simplicity / YAGNI / KISS)

**Verdict: ADVISE**

The plan is well-scoped overall. The conflict resolutions demonstrate good YAGNI
discipline (no first-run README, deferred init-hooks, deferred context reading,
no NEFARIO_SCRATCH_DIR override). The task count (6) is proportional to the
problem. The deferral decisions are correct. However, there are specific areas
where accidental complexity is creeping in.

---

## Concerns (non-blocking)

### 1. Report path detection is one layer too many

The four-step detection order (env var > `docs/nefario-reports/` > `docs/history/nefario-reports/` > create default) has three concerns:

**a) NEFARIO_REPORTS_DIR env var is YAGNI.** The Scratch Path Resolution section
explicitly says "No `NEFARIO_SCRATCH_DIR` override -- YAGNI." The same logic
applies to reports. No user has asked for an env var override. No use case
justifies it today. The conflict resolution for scratch paths got this right;
the report path resolution contradicts it. Remove the env var. If needed later,
it is a one-line addition.

**b) Two detection paths plus a creation default is mildly over-engineered for
an LLM consumer.** The SKILL.md is read by an LLM, not a parser. Every
conditional branch is cognitive load for the model. Consider simplifying to:
detect existing `docs/nefario-reports/` or `docs/history/nefario-reports/`
(first found wins), otherwise create `docs/history/nefario-reports/`. That is
two conditions, not three.

**Simpler alternative:** Remove env var (step 1). Keep steps 2-4. This reduces
the detection from 4 steps to 3 and is consistent with the scratch path
YAGNI reasoning.

**Complexity cost:** Low (1 point), but it sets a precedent. If env var overrides
are added to reports, they will be requested for scratch too, then for branch
naming, then for slug patterns. Keep the precedent clean.

### 2. Task 6 smoke tests partially duplicate Task 1 and test LLM-consumed prose

Task 6 (portability smoke tests) tests filesystem operations that the SKILL.md
*describes* but does not *execute* as code. The SKILL.md is natural language
instructions consumed by an LLM. Testing "does mkdir -p work in three directory
scenarios" does not validate that the LLM will follow the instructions correctly.
It validates that bash and mkdir work, which is not in question.

The plan itself acknowledges this in Risk 5: "Tests can verify structural
properties but not LLM interpretation."

The useful tests from Task 6 are:
- Report directory detection priority (verifies the convention is unambiguous)
- Environment variable override (if kept; see concern 1)

The scenario tests (self-repo, external project, greenfield) are essentially
testing `mkdir -p` and `[ -d ... ]`, which is testing bash, not the toolkit.

**Simpler alternative:** Merge the detection-priority test into Task 1's
`test-no-hardcoded-paths.sh` as a second section. Drop the three scenario tests.
This eliminates Task 6 entirely and reduces the task count from 6 to 5. The
remaining tests (hardcoded path grep + install portability) cover the actual
risk: self-referential paths in deployable artifacts.

If the team feels strongly about keeping scenario tests, scope Task 6 down to
ONLY the detection priority test (which actually validates a design decision)
and drop the mkdir-based scenarios.

### 3. Task 2 prompt is extremely long and prescriptive

The Task 2 prompt is ~90 lines with a 13-item location checklist for find-and-replace.
This is micro-managing a competent agent. The test from Task 1
(`test-no-hardcoded-paths.sh`) already provides the verification mechanism. The
agent needs to know: (a) the new path convention, (b) the file to modify, (c)
the test to run afterward.

The risk is not that the agent misses a reference -- the grep test catches that.
The risk is that the prompt is so long that the agent gets confused by the
volume of instructions and makes errors. Shorter prompts with clear success
criteria produce better agent output.

**Simpler alternative:** Cut the Task 2 prompt to: new path convention (the Path
Resolution section content), what to change (5 bullet summary, not 13 sub-items),
what NOT to change, and verification (run the test). Let the agent figure out the
mechanical find-and-replace. It has grep.

This is advisory, not blocking -- the current prompt will likely work, it just
carries unnecessary cognitive load.

### 4. Minor: commit-workflow.md reference handling

Task 2 item 5 says to change `docs/commit-workflow.md` references to "See the
commit workflow documentation in the despicable-agents repository for the full
protocol." This creates a dangling informational reference. If the SKILL.md is
running on a different project, "the despicable-agents repository" is not
actionable.

**Simpler alternative:** Either inline the essential commit workflow rules (if
they are short enough -- check the file) or simply remove the reference. The
commit workflow is a project convention, not a toolkit dependency.

---

## What the plan gets right

- **Deferral decisions are excellent.** init-hooks, context reading, first-run
  README, and NEFARIO_SCRATCH_DIR are all correctly deferred. This is textbook
  YAGNI.
- **Scratch to $TMPDIR is the right call.** Ephemeral session state does not
  belong in the project tree. Simple, correct.
- **One approval gate is appropriate.** The SKILL.md refactor is the only
  high-risk change. Gate budget is well within bounds.
- **Test-before-change ordering (Task 1 before Task 2) is correct.** Regression
  safety net before the risky change.
- **Scope is tight.** No adjacent features, no gold plating, no technology
  additions. The task count (6) is proportional to the problem size.

---

## Summary

| Item | Severity | Recommendation |
|------|----------|----------------|
| NEFARIO_REPORTS_DIR env var | Medium | Remove. Apply same YAGNI reasoning as scratch path. |
| Task 6 scenario tests | Low-Medium | Eliminate or reduce to detection-priority-only test. |
| Task 2 prompt length | Low | Shorten. Trust the agent + test. |
| commit-workflow.md reference | Low | Inline or remove rather than dangling cross-repo reference. |

None of these are blocking. The plan is fundamentally sound and well-scoped.
The above items would reduce accidental complexity by roughly 15-20% if adopted.
