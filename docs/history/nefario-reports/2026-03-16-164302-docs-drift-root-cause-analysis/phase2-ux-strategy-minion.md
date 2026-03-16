## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### 1. The core problem: skipping is invisible and stateless

The current post-execution gate (lines 1656-1672 of SKILL.md) presents three options — "Run all", "Skip docs only", "Skip all post-exec" — as if each decision exists in isolation. There is no mechanism that remembers what was skipped across PRs, no accumulation signal, and no cost visibility. Each skip decision is a clean slate.

This is a textbook case of **missing system status visibility** (Nielsen heuristic 1). The user has no idea what the cumulative effect of their choices is. After 6 PRs with Phase 8 skipped, the framework's internal state and the user's mental model have diverged completely: the user thinks "I'll catch up on docs later" while the system has forgotten every skip the moment the session ended.

The WRL docs drift audit (0022) catalogued the result: 13 OpenAPI discrepancies, a dangerously false README section, 3 missing secrets in docs, missing endpoint documentation. This is the precise cost of 6 invisible skips.

#### 2. Respect the skip — it exists for a legitimate job

The user's JTBD when skipping: "When I'm doing rapid iteration across related PRs, I want to defer documentation overhead, so I can maintain creative momentum and ship functional changes faster."

This is a real and valid job. Forcing full Phase 8 on every PR during a burst of related work would violate the user's autonomy and create legitimate fatigue. The skip option is not a design error — the **invisibility of accumulated skips** is the design error.

#### 3. Make the skip cost visible at the decision point (not after)

The post-execution gate should show a running tally of recent doc skips. This is the minimum viable intervention: one line of context added to the existing gate, zero additional interaction steps.

**Current gate question** (line 1658):
```
Post-execution phases for Task N: <task title>
```

**Proposed gate question when skip history exists**:
```
Post-execution phases for Task N: <task title>
Doc skips this session: 2 (PR #53, #54). Total recent: 4 since Mar 10.
```

**When no skip history exists**, the gate is unchanged — no clutter for users who always run docs.

This follows the calm technology principle: inform without demanding focus. The tally is peripheral awareness, not an obstacle. The user sees it, registers the accumulation, and makes an informed choice. No extra clicks, no extra gates, no fatigue.

#### 4. Lightweight "dry run" checklist — show what WOULD be done, not what WAS skipped

When the user selects "Skip docs only" or "Skip all post-exec", nefario should still generate the Phase 8 checklist (it's a lightweight evaluation of execution outcomes against the outcome-action table) and write it to the scratch file. Then show a single condensed line:

```
Skipping: 3 doc items (OpenAPI update, README new endpoint, config reference)
```

This is not a full dry run — it is the checklist generation step (Phase 8 step 1) running unconditionally, with the results surfaced as a CONDENSE line rather than triggering agent spawning. The cost is minimal (checklist generation is nefario-local, no subagent calls) and the benefit is high: the user sees exactly what they are deferring, not an abstract "docs skipped."

This converts the skip from "I'm skipping something vague" to "I'm skipping these 3 specific items." Specificity makes cost real without creating friction.

#### 5. Persistent skip ledger in scratch/report — not just session memory

The skip tally needs to survive across sessions. Two mechanisms, layered:

**5a. Report-level tracking (already partially exists)**: The verification summary already notes "Skipped: docs." Extend the report frontmatter with a structured field:

```yaml
doc-debt:
  - "OpenAPI: new OPTIONS endpoint undocumented"
  - "README: key rotation section stale"
  - "Config: CORS_ORIGINS secret undocumented"
```

This is the checklist items that Phase 8 WOULD have processed. It turns the execution report into a debt receipt.

**5b. Cross-session accumulation file**: A simple file at a known location (e.g., `docs/nefario-doc-debt.md` or a well-known path in the report directory) that nefario appends to on each skip and reads at each post-exec gate. Format:

```markdown
# Documentation Debt Ledger

| Date | Branch/PR | Skipped Items | Status |
|------|-----------|---------------|--------|
| 2026-03-10 | nefario/key-rotation | OpenAPI OPTIONS, README key rotation | open |
| 2026-03-10 | nefario/cors-headers | Config CORS_ORIGINS secret | open |
```

When Phase 8 runs and clears items, mark them resolved. The file is the single source of truth for accumulated debt. It lives in the repo (committed), so it persists across sessions and is visible in PRs.

#### 6. Escalation threshold — not a hard block, a louder signal

After N consecutive doc skips (recommend N=3), the gate presentation changes. Not from single-select to a blocker, but from peripheral awareness to foregrounded concern:

**Normal skip tally** (skips 1-2):
```
Doc skips this session: 1 (PR #53).
```

**Elevated tally** (skip 3+):
```
Doc debt: 3 PRs, 8 items deferred. Oldest: Mar 10 (6 days ago).
Consider: Run docs on this PR to clear backlog, or batch in a dedicated docs PR.
```

The "Consider" line is advisory, not blocking. It uses the language of options ("Run docs on this PR" or "batch in a dedicated docs PR") rather than the language of obligation ("You should..."). This respects autonomy while making the cost unmistakable.

Critically, this does NOT add a new gate or a new AskUserQuestion interaction. It modifies the content of the existing gate's question field. Same number of clicks, more information.

#### 7. "Batch docs" as a first-class nefario task type

After a burst of skipped-docs PRs, the most natural resolution is a dedicated documentation PR. The framework should make this easy: `nefario --docs-catchup` or similar, which reads the debt ledger, generates the checklist from accumulated items, and runs Phase 8 as a standalone task.

This transforms deferred docs from "invisible debt I feel guilty about" to "a planned task I can schedule when I'm ready." The JTBD shifts from avoidance to intentional batching.

#### 8. Anti-fatigue interaction with existing gate budget

The 3-5 approval gate budget (line 1714) constrains Phase 4 mid-execution gates. The post-exec gate is separate — it fires once per orchestration, after execution completes. These are different interaction categories:

- Mid-execution gates: decision points about design choices (high cognitive cost, benefits from budgeting)
- Post-exec gate: operational choice about verification scope (low cognitive cost, routine)

The post-exec gate should NOT count toward the 3-5 gate budget. It is a different class of interaction. However, the recommendations above are designed to avoid adding new gates entirely — they modify the content of the existing post-exec gate, not the number of interactions.

The calibration check (5 consecutive approvals, line 1720) is also orthogonal — it measures rubber-stamping of mid-execution gates, not post-exec skips. The skip tally is the post-exec equivalent of the calibration check: a self-awareness mechanism that surfaces when habitual behavior may be accumulating cost.

### Proposed Tasks

1. **Add skip tally to post-exec gate question**: Modify the post-exec AskUserQuestion question field to include a running count of recent doc skips when the count is > 0. Requires reading the debt ledger at gate presentation time. Low complexity, high impact.

2. **Generate Phase 8 checklist unconditionally**: Decouple checklist generation (Phase 8 step 1) from checklist execution (steps 2-4). Always run step 1 after Phase 4. When docs are skipped, write the checklist to scratch and show a CONDENSE line summarizing skipped items. When docs run, proceed as today.

3. **Add `doc-debt` field to report frontmatter**: When Phase 8 is skipped but the checklist was generated (per task 2), include the checklist items in the report's YAML frontmatter as `doc-debt`. Update the report template accordingly.

4. **Create cross-session debt ledger**: Define the debt ledger file format and location. Nefario appends on skip, reads at gate, marks resolved when Phase 8 clears items. Simple markdown table, committed to repo.

5. **Add escalation threshold to gate question**: When debt ledger has 3+ open items, modify gate question text to include the elevated tally with advisory language. No new gate, no new interaction step.

6. **Define `--docs-catchup` task type** (lower priority): A standalone nefario mode that reads the debt ledger and runs Phase 8 as a dedicated orchestration. Clears accumulated debt in a single focused PR.

### Risks and Concerns

**Risk: Tally becomes noise that users learn to ignore.** Mitigation: Keep the tally minimal (one line) and only show it when there IS accumulated debt. Users who never skip docs never see it. The specificity of the checklist items (task 2) is the key — "3 items" is ignorable, "OpenAPI update, README new endpoint, config reference" is concrete enough to register.

**Risk: Debt ledger becomes stale or conflicts across branches.** Mitigation: The ledger should be append-only and keyed by branch/PR. Merge conflicts are unlikely (each entry is a new row) but if they occur, both sides are valid — accept both. Staleness is addressed by the "mark resolved" mechanism when Phase 8 runs.

**Risk: Unconditional checklist generation adds latency.** Mitigation: Checklist generation is a local evaluation step (nefario reads the outcome-action table and matches it against execution outcomes). No subagent spawning, no file reading beyond what nefario already has in context. Estimated cost: negligible.

**Risk: Escalation threshold feels paternalistic.** Mitigation: Advisory language only, never blocking. The user chose to skip and the framework should respect that. The elevated tally is "here is what you've deferred" not "you should not have deferred this." The `--docs-catchup` escape hatch turns deferred docs into a planned activity rather than a guilt trip.

**Concern: This analysis assumes the skip pattern is the user's conscious choice.** If the user is skipping because Phase 8 produces low-quality documentation that requires more cleanup than writing from scratch, the fix is different (improve Phase 8 output quality, not make skipping more visible). The debt visibility mechanism would surface this pattern — if the user consistently skips even after seeing the tally, that is signal that Phase 8 value proposition needs examination.

### Additional Agents Needed

- **devx-minion**: For the implementation mechanics of the debt ledger file, the `--docs-catchup` mode, and the unconditional checklist generation. The workflow integration details (where in SKILL.md the logic changes, how the debt ledger file is read/written, how `--docs-catchup` maps to nefario's phase structure) are developer experience questions.

- **software-docs-minion**: The debt ledger is itself a documentation artifact. Its format, location, and relationship to the report index should be reviewed for consistency with existing documentation conventions.
