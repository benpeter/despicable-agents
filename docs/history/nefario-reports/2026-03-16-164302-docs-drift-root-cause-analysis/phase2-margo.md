## Domain Plan Contribution: margo

### Verdict: ADVISE

The five failure patterns are real, but the fix must be proportional to the
problem. The core issue is that Phase 8 has a soft skip path with zero
accountability -- not that the framework lacks phases or tracking mechanisms.
The simplest fix targets the skip path itself, not the execution path.

### Root Cause Analysis (Complexity Perspective)

The current Phase 8 design has a fundamental asymmetry:

- **Running Phase 8** is expensive: generate checklist, spawn 2-3 subagents,
  classify marketing tiers, produce artifacts. ~3 complexity units.
- **Skipping Phase 8** is free: one line in the report ("Skipped"), zero
  artifacts, zero visibility into what was skipped.

When the cost of doing is high and the cost of skipping is zero, rational
actors skip. This is a UX incentive problem, not a process gap. The WRL
evidence confirms it: across 6 PRs, the skip path was taken every time
through various rationalizations (user-directed, "handled inline",
"covered by Task N", scope misjudgment).

The "handled inline" and "covered by Task N" patterns are particularly
revealing. They are not user-directed skips -- they are **orchestrator
self-assessment** with no external verification. The orchestrator decided
documentation was handled and skipped Phase 8 unilaterally. This violates
the SKILL.md core rule ("You NEVER skip any phase based on your own
judgement") but through a loophole: the orchestrator is not technically
skipping the phase -- it generates an empty checklist (step 2: "If checklist
is empty, skip entirely"), which makes it look like the phase ran but found
nothing to do.

**Essential complexity**: Documentation impact assessment requires matching
code changes against documentation artifacts. This is inherently non-trivial.

**Accidental complexity in proposed fixes**: A docs debt tracker, cross-PR
accumulation counter, or mandatory Phase 8 execution all add persistent
state, new data structures, and cross-session coordination. These are
heavyweight solutions to a lightweight problem.

### Recommendations

#### 1. RECOMMENDED: Always-generate checklist with mandatory disclosure (low complexity)

Make Phase 8 checklist generation unconditional -- it runs even when Phase 8
execution is skipped. The checklist is written to scratch and surfaced in the
wrap-up report. This is NOT the same as mandatory Phase 8 execution (which
would spawn subagents).

**What changes in SKILL.md**:
- Phase 8 step 1 (checklist generation) runs always, regardless of skip flags.
- Step 2 changes: if checklist is non-empty AND Phase 8 was skipped, the wrap-up
  report includes a "Documentation debt" section listing the checklist items.
- If checklist is empty, record that explicitly ("Phase 8 checklist: 0 items
  identified").

**Complexity cost**: ~1 unit. No new data structures, no cross-session state,
no new phases. The checklist generation logic already exists. The only addition
is running it unconditionally and surfacing it.

**Why this works**: It closes the accountability gap without adding process.
The user still decides whether to run Phase 8, but the decision is now
informed -- they see exactly what they are deferring. The "handled inline"
loophole closes because the checklist either confirms "yes, everything was
handled" (empty checklist = validated) or reveals "no, these items remain"
(non-empty = visible debt).

#### 2. RECOMMENDED: Expand the outcome-action table (low complexity)

The current table misses categories that caused WRL drift. Specific gaps:

| Missing Outcome | Drift It Caused | Proposed Action |
|---|---|---|
| New secret/env var | IP_HASH_SEED undocumented | README secrets section review |
| New response headers | Link, HSTS, X-RateLimit-Limit undocumented | OpenAPI + README review |
| Changed error responses | Missing 503/500/422 in spec | OpenAPI error response review |
| New CORS behavior | Preflight undocumented | OpenAPI + README review |
| New environment/deploy target | Staging undocumented | README + CONTRIBUTING review |

**Complexity cost**: 0. This is a table expansion, not a new mechanism.

#### 3. RECOMMENDED: Eliminate "handled inline" as a valid skip reason (zero complexity)

Add an explicit rule to the Phase 8 spec: "Documentation handled during
Phase 4 execution does not exempt Phase 8 checklist generation. The
checklist evaluates all execution outcomes, including outcomes already
partially addressed by Phase 4 tasks." This closes the self-assessment
loophole.

**Complexity cost**: 0. This is a clarification of existing intent, not
a new mechanism.

#### 4. NOT RECOMMENDED: Docs debt tracker across PRs

A persistent debt tracker requires:
- A file or database to store accumulated debt items
- Logic to read/write this tracker in the wrap-up phase
- Logic to present accumulated debt when starting a new orchestration
- Deduplication logic when the same item appears across multiple PRs
- Staleness detection when debt items are resolved outside the framework

**Complexity cost**: ~5 units. New persistent state, cross-session
coordination, staleness management. This is a new subsystem.

**Why it is not justified**: The always-generate checklist (Recommendation 1)
solves the immediate problem. If the user skips Phase 8 six times and sees six
non-empty checklists in six reports, the debt is already visible. The reports
ARE the tracker. A separate tracker is YAGNI -- it solves the "what if someone
doesn't read the reports?" problem, which is a human process problem, not a
framework problem.

**When it would be justified**: If evidence shows that visible checklists in
reports are ignored and debt continues to accumulate. That is a future problem
with a future solution. Build it when the simpler mechanism demonstrably fails.

#### 5. NOT RECOMMENDED: Pre-PR docs diff check / automated verification tool

A tool that compares code changes against documentation artifacts and flags
discrepancies requires:
- Parsing logic for each documentation format (OpenAPI, Markdown, etc.)
- Heuristics to match code changes to doc sections
- False positive management (not every code change needs doc updates)
- Maintenance burden when documentation formats change

**Complexity cost**: ~8 units (new tool, new dependency, ongoing maintenance).

**Why it is not justified**: This is building a tool to compensate for a
process that already has the capability but doesn't run. Fix the process
first. If the always-generate checklist proves insufficient (because the
checklist itself misses things), then consider tooling. But the WRL evidence
shows the checklist mechanism was never given a chance -- it was skipped, not
wrong.

#### 6. NOT RECOMMENDED: Mandatory Phase 8 execution (removing skip option)

Removing the ability to skip Phase 8 would solve the problem but creates
unsustainable overhead for rapid iteration. The WRL project intentionally
ran 6 PRs fast. Forcing 3 subagent spawns per PR for documentation that may
genuinely not need updating creates approval fatigue -- the very problem the
skip mechanism was designed to prevent.

**Complexity cost**: Negative in mechanism terms (removing a feature), but
positive in operational burden per PR.

### Proposed Tasks

1. **Modify SKILL.md Phase 8 to make checklist generation unconditional**
   - Decouple checklist generation (step 1) from checklist execution (steps 2-4)
   - Checklist generates regardless of --skip-docs / "Skip docs only" / "Skip all post-exec"
   - Non-empty checklist with Phase 8 skipped = "Documentation debt" section in wrap-up report
   - Empty checklist = explicit "Phase 8 checklist: 0 items" in wrap-up
   - Owner: whoever modifies SKILL.md (likely nefario's spec author)
   - Complexity budget: ~1 unit

2. **Expand outcome-action table in SKILL.md**
   - Add 5 missing outcome categories (secrets, response headers, error responses, CORS, deploy targets)
   - Review against the full WRL drift audit to confirm no other gaps
   - Owner: software-docs-minion for taxonomy, spec author for SKILL.md
   - Complexity budget: 0

3. **Add anti-self-assessment rule to Phase 8 spec**
   - Explicit prohibition: "handled inline" does not bypass checklist generation
   - Explicit rule: Phase 4 documentation tasks do not exempt Phase 8 checklist evaluation
   - Owner: spec author
   - Complexity budget: 0

### Risks and Concerns

1. **Over-engineering risk (HIGH)**: The biggest risk is that the fix becomes
   more complex than the problem. The drift audit took one orchestration to
   resolve (0022). If the fix adds 3+ complexity units to EVERY future
   orchestration to prevent a problem that occurs in rapid-iteration bursts,
   the cure is worse than the disease. The three recommended changes total ~1
   complexity unit. Stay there.

2. **Checklist quality risk (MEDIUM)**: Making checklist generation unconditional
   only works if the checklist is accurate. If the outcome-action table has gaps
   (it does -- hence Recommendation 2), the checklist will miss items and create
   false confidence. The table expansion must happen alongside the process change.

3. **Approval fatigue risk (MEDIUM)**: Even a "Documentation debt" section in
   the wrap-up report adds cognitive load. If every PR shows a debt section with
   items the user intentionally deferred, it becomes noise. Consider: only show
   the debt section when the checklist has MUST-priority items. SHOULD/COULD
   items can be noted without the "debt" framing.

4. **Scope creep risk (HIGH)**: This analysis could expand into redesigning the
   entire post-execution pipeline, building new tooling, adding CI checks, or
   creating cross-session persistence. All of these are YAGNI. The problem is
   specific (Phase 8 skipped without visibility), and the fix should be specific
   (make the skip visible). Resist the temptation to solve adjacent problems.

5. **"Never trust self-assessment" slippery slope (MEDIUM)**: If we add
   external verification for documentation, the same argument applies to code
   review (Phase 5) and testing (Phase 6). Where does it stop? The answer:
   documentation is uniquely vulnerable because it is the only artifact type
   where the orchestrator can plausibly claim "handled inline" -- code review
   and test execution have objective pass/fail signals. Documentation quality
   is subjective, which is why it needs the checklist guardrail.

### Additional Agents Needed

None beyond those already in the meta-plan. The three recommended changes are
spec modifications, not new mechanisms requiring additional domain expertise.

If the synthesis phase considers a docs debt tracker (Recommendation 4) despite
the YAGNI concern, **data-minion** would be needed for the persistence design.
But I recommend against it.
