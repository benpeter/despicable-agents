## Domain Plan Contribution: lucy

### Analysis: How Intent Drifted Through the Process

The cross-cutting checklist says Documentation is "ALWAYS include" (AGENT.md line 295). But this directive operates in planning phases (1-3) only. It governs which agents participate in planning -- it does not create a binding obligation for Phase 8 execution. The checklist itself says so explicitly: "This checklist governs agent inclusion in planning and execution phases (1-4). Phase 3.5 architecture review has its own triggering rules" (AGENT.md line 304). Phase 8 has a completely separate triggering mechanism: nefario self-generates a checklist from execution outcomes, and if that checklist is empty, Phase 8 is skipped (SKILL.md line 1964).

This creates a structural gap: **the planning mandate ("ALWAYS include docs agents") and the execution gate ("skip if checklist empty") are disconnected**. The planning phase can dutifully include software-docs-minion, but the execution phase can still self-assess that no documentation is needed and skip Phase 8 entirely. The "ALWAYS include" directive gives the illusion of coverage without enforcing it.

Here is how each failure pattern exploits this gap:

**(a) User-directed full skip ("Skipped per user directive")**: The post-exec gate (SKILL.md line 1660-1662) offers "Skip all post-exec" as an explicit option. When the user selects this, all of Phases 5-8 are skipped with no record of what documentation debt was deferred. The key-versioning report (line 85) shows "Phases 5-8: Skipped per user directive" -- no checklist was even generated to record what was skipped. The framework provides no mechanism to log the debt or carry it forward.

**(b) "Handled inline" self-assessment**: The staging-and-tos report (line 78-80) and cors-hsts-ratelimit report (line 92-94) both say "documentation handled inline during execution." This is nefario self-assessing that inline changes during Phase 4 were sufficient. No independent verification occurs. Phase 5's lucy review scope is "convention adherence, CLAUDE.md compliance, intent drift" (SKILL.md line 1826) -- not "did this PR update all derivative documentation." Phase 5 reviews the code that was written, not the documentation that was not written.

**(c) "Covered by Task N" subset coverage**: When Phase 8's outcome-action table (SKILL.md lines 1943-1955) triggers a checklist item, the agent is told to "inspect changed files for full scope" (SKILL.md line 1973). But if nefario's self-assessment already concluded that a task "covered" the docs impact, the checklist item is never generated. The coverage assessment happens before the checklist is built, and it is nefario -- not a docs specialist -- making that judgment.

**(d) Scope misjudgment**: The hashed-ip-logging report (line 55) says "Phase 8: Skipped (internal logging change, no user-facing docs needed)." But the outcome audit found that this PR should have updated: openapi.yaml (new error responses), README.md (new IP_HASH_SEED secret, new error patterns), and CONTRIBUTING.md (new .dev.vars variable). The outcome-action table in SKILL.md has "Config changed -> Config reference" and "Spec/config files modified -> Scan for derivative docs" -- both should have triggered. Nefario classified the change as "internal" and never evaluated against the table.

**(e) Cross-PR accumulation**: Nothing in the framework detects drift building across multiple orchestrations. Each Phase 8 evaluation is scoped to a single PR's execution outcomes. There is no "docs debt ledger" that persists across sessions. Even if each individual skip was defensible in isolation, the compound effect across 6 PRs was 13 OpenAPI discrepancies, a dangerously false README warning about key rotation, 3 missing secrets, and missing endpoint documentation.

### Why Phase 5 (Lucy) Did Not Catch Documentation Gaps

Lucy's Phase 5 review focus is explicitly scoped to: "convention adherence, CLAUDE.md compliance, intent drift" (SKILL.md line 1826). This scoping has two blind spots:

1. **Reviews what was written, not what is missing**: Lucy in Phase 5 reviews "the actual code files listed above" (SKILL.md line 1830). The file list comes from Phase 4's change ledger. If Phase 4 did not touch openapi.yaml, openapi.yaml is not in the review scope. Lucy cannot flag documentation drift in files that are not in the review set.

2. **CLAUDE.md compliance checks are narrow**: Lucy correctly flagged missing evolution log entries in the hashed-ip-logging review (phase5-lucy.md lines 43-48). But evolution log completeness is a CLAUDE.md-mandated artifact with a specific checklist. Derivative documentation (README, OpenAPI, CONTRIBUTING) has no equivalent CLAUDE.md mandate. Lucy checks what CLAUDE.md requires; CLAUDE.md does not require "all derivative docs updated on every PR."

3. **Phase 3.5 lucy review is pre-execution**: Lucy's Phase 3.5 review (key-versioning phase3.5-lucy.md) correctly flagged that evolution log and backlog tasks were missing from the plan. But this is a plan review -- it can only flag omissions in the plan. It cannot flag documentation drift that only becomes visible after code is written. And Finding 4 was ADVISE severity with "assuming nefario wrap-up handles it" -- a deferral that assumes the very mechanism that failed.

### Recommendations

**R1: Decouple Phase 8 checklist generation from nefario self-assessment**

CHANGE: Phase 8's documentation checklist (SKILL.md line 1937) is currently generated by nefario, the same agent that decides whether to run Phase 8. This is the fox guarding the henhouse.

FIX: The checklist generation step should be performed by software-docs-minion (or a dedicated docs-triage subagent), not by nefario. The agent receives the list of files changed in Phase 4 and evaluates them against the outcome-action table. Nefario's role is to invoke the evaluation and act on its output, not to perform the evaluation itself. This prevents the "internal change, no docs needed" misjudgment because a docs specialist will recognize that a new secret in wrangler.toml triggers a CONTRIBUTING.md update.

SEVERITY: This is the highest-priority fix. It addresses failure patterns (b), (c), and (d) directly.

**R2: Make Phase 8 checklist generation non-skippable even when Phase 8 execution is skipped**

CHANGE: When the user selects "Skip docs only" or "Skip all post-exec" (SKILL.md line 1757-1765), Phase 8 is skipped entirely -- including checklist generation.

FIX: Always generate the Phase 8 checklist, even when the user skips execution. If the checklist is non-empty and execution is skipped, write the checklist to the scratch directory and include a "Documentation debt" section in the wrap-up report listing deferred items. This gives the user visibility into what they skipped and creates an artifact that can be referenced later.

SEVERITY: Addresses failure pattern (a). Low implementation cost -- the checklist generation is a single subagent call that takes seconds.

**R3: Add a "docs impact" field to the nefario execution report**

CHANGE: The nefario report template has no field for documentation debt. When Phase 8 is skipped, the report says "Skipped" with a parenthetical rationale, but this rationale is nefario's self-assessment and there is no structured data to query across reports.

FIX: Add a `docs-debt` field to the report YAML frontmatter. Values: `none` (Phase 8 ran and cleared all items), `deferred` (checklist generated but execution skipped, with item count), `not-evaluated` (Phase 8 skipped before checklist generation -- should become impossible after R2). Include the deferred item list in the report body if non-empty.

SEVERITY: Addresses failure pattern (e) partially. Enables cross-PR debt detection by making debt machine-readable in report frontmatter.

**R4: Add cross-PR documentation debt detection to Phase 1 (Meta-Plan)**

CHANGE: No mechanism in the framework detects documentation drift building across multiple orchestrations. Each session is stateless with respect to docs debt.

FIX: In Phase 1 (meta-plan), before specialist selection, nefario should scan recent nefario reports in the project's `docs/history/nefario-reports/` for reports with `docs-debt: deferred` or Phase 8 skipped. If found, the meta-plan should include a "Documentation debt context" section listing the deferred items and flag that the current task's Phase 8 should address accumulated debt, not just the current task's delta. This is a lightweight grep over YAML frontmatter, not a full audit.

SEVERITY: Addresses failure pattern (e). Requires R3 to be effective (needs machine-readable debt data).

**R5: Expand Phase 5 lucy review scope to include derivative documentation**

CHANGE: Phase 5 lucy reviews only files in the Phase 4 change ledger. Documentation files that should have been updated but were not are invisible.

FIX: Add a review instruction to lucy's Phase 5 prompt: "Check whether the changes in the file list have documentation implications beyond the files changed. Specifically: (1) Do new API endpoints, parameters, or response shapes require openapi.yaml updates? (2) Do new environment variables or secrets require README/CONTRIBUTING updates? (3) Do behavioral changes require user-facing docs updates? Flag missing documentation updates as ADVISE findings with FIX pointing to the specific doc file and section."

SEVERITY: Addresses failure patterns (b), (c), (d) at the Phase 5 level. This is a defense-in-depth measure -- it does not replace R1 (which prevents the Phase 8 skip) but catches cases where Phase 8 runs but misses items.

**R6: Replace the "handled inline" self-assessment with a verification step**

CHANGE: When nefario reports "documentation handled inline during execution" (staging-and-tos, cors-hsts-ratelimit reports), there is no verification that the inline handling was complete.

FIX: If Phase 4 tasks include documentation changes (detected from the change ledger), Phase 8 should still generate the checklist and verify that the inline changes addressed all checklist items. If they did, Phase 8 reports "All items pre-addressed in execution" with the checklist as evidence. If gaps exist, Phase 8 spawns agents for the remaining items. "Handled inline" should never be a reason to skip checklist generation -- it should be the expected outcome of a checklist that finds everything already done.

SEVERITY: Directly addresses failure pattern (b). Makes "handled inline" a verified conclusion rather than an unverified assertion.

### Proposed Tasks

| # | Task | Traces to | Agents Needed |
|---|------|-----------|---------------|
| T1 | Move Phase 8 checklist generation from nefario to software-docs-minion subagent | R1 | software-docs-minion (prompt design), nefario skill author |
| T2 | Make checklist generation always run; log debt when execution skipped | R2, R3 | nefario skill author |
| T3 | Add `docs-debt` field to report template and update report generation | R3 | nefario skill author |
| T4 | Add cross-PR debt scan to Phase 1 meta-plan | R4 | nefario skill author |
| T5 | Expand lucy Phase 5 review prompt to include derivative doc checks | R5 | lucy spec author |
| T6 | Replace "handled inline" with checklist verification | R6 | nefario skill author |

### Risks and Concerns

1. **Overhead proportionality**: R1 adds a subagent call (software-docs-minion) to every orchestration's Phase 8, even for genuinely trivial changes. The cross-cutting checklist already says Documentation is "ALWAYS include" so this is consistent with the stated philosophy. But it adds latency and cost. Mitigation: the checklist generation step is a fast evaluation (read file list, match against table), not a full docs rewrite. The cost is one sonnet subagent call per orchestration.

2. **R4 (cross-PR scan) could become stale**: If reports accumulate `docs-debt: deferred` entries that are resolved outside the orchestration framework (e.g., manual edits), the scan produces false positives. Mitigation: the scan should check whether the deferred files have been modified since the report date. If they have, assume debt resolved.

3. **User friction with R2**: Users who skip docs for speed will now see a "Documentation debt" section in their report. This is the point -- making the cost visible -- but it could feel nagging. The framework should present this as information, not as a blocker. The user already made the skip decision; the report just records the consequence.

4. **Lucy's expanded Phase 5 scope (R5) overlaps with Phase 8**: If both R1 and R5 are implemented, there are two checkpoints for documentation completeness. This is defense-in-depth, not redundancy -- Phase 5 catches issues before Phase 8 runs, and Phase 8 handles the actual work. But the findings should not duplicate. Phase 5 lucy should flag documentation implications as ADVISE, and Phase 8 should be the resolution mechanism.

5. **"ALWAYS include" vs "Conditional"**: The fundamental tension is between the cross-cutting checklist (line 295: Documentation is ALWAYS include) and the Phase 8 header (line 1935: "Conditional"). These two directives contradict each other. If documentation is truly ALWAYS, then Phase 8 should always at least evaluate, never be skippable by nefario's own judgment. Only the user should be able to skip it (and with a debt record). This contradiction in the spec is the root cause of the drift. Resolving it -- by making "ALWAYS include" mean "always evaluate, never self-skip" -- is the single most important change.

### Additional Agents Needed

- **margo**: Should review the proposed tasks for complexity proportionality. Six tasks to fix one process gap could be over-engineering. Margo should assess whether R1 + R2 + R3 alone (the minimum viable fix) are sufficient, or whether R4/R5/R6 are genuinely load-bearing.
- **software-docs-minion**: Needed to validate that the proposed Phase 8 checklist delegation (R1) is feasible from the docs agent's perspective -- can software-docs-minion reliably evaluate the outcome-action table given only a file change list?
- **nefario** (as a planning consultant, not executor): The proposed changes modify nefario's SKILL.md and AGENT.md. Nefario should validate that the proposed Phase 1 debt scan (R4) and Phase 8 changes (R1, R2, R6) integrate coherently with the existing phase flow.
