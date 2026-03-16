## Delegation Plan

**Team name**: docs-drift-fix
**Description**: Fix structural weaknesses in Phase 8 that caused documentation drift across 6 WRL PRs. Three targeted spec changes: always-generate checklist, expand outcome-action table, eliminate self-assessment loophole.

### Conflict Resolutions

**Cross-session debt tracker**: ux-strategy-minion proposed a persistent debt ledger file committed to the repo (cross-session accumulation, escalation threshold at 3+ skips, `--docs-catchup` mode). margo explicitly rejected this as YAGNI (~5 complexity units, new persistent state, staleness management). lucy proposed a lighter version: `docs-debt` field in report frontmatter + Phase 1 scan of recent reports.

**Resolution**: Side with margo. The always-generate checklist makes debt visible in every execution report. The reports ARE the ledger. A separate debt file, escalation thresholds, and a `--docs-catchup` mode are speculative infrastructure for a problem that the simpler mechanism has not yet failed to solve. If visible checklists in reports prove insufficient, the debt tracker can be added later with real evidence of need. Lucy's `docs-debt` frontmatter field is adopted as a lightweight enhancement to the report template (zero new infrastructure, just a YAML field) -- it makes the debt machine-queryable without a separate file.

**Diff-based doc scan**: software-docs-minion proposed a complementary diff-based trigger (scan git diff for env vars, routes, headers, status codes). margo flagged this as premature: fix the process first (the checklist was skipped, not wrong). ai-modeling-minion proposed a similar "documentation baseline scan" for multi-PR sessions.

**Resolution**: Side with margo. The diff-based scan is heuristic, language-dependent, and adds fragile complexity. The root cause is not that the checklist missed items -- the checklist was never generated. Fix the generation problem first. The expanded outcome-action table (universally agreed) addresses the taxonomy gaps that caused misclassification. If the expanded table proves insufficient after several orchestrations, diff-based augmentation can be reconsidered with real data on what the table still misses.

**Delegating checklist generation to software-docs-minion**: lucy proposed moving checklist generation from nefario to software-docs-minion (a separate subagent call). margo's framing implies keeping it lightweight (nefario-local evaluation). ai-modeling-minion proposed "tool-verified" checklist with Read tool calls for evidence.

**Resolution**: Keep checklist generation in the calling session (nefario), but add an explicit verification requirement: for any item marked "already addressed in Phase 4," the calling session must cite the file path and confirm via Read tool call. Spawning a separate subagent for checklist generation adds latency and cost to every orchestration; the real fix is preventing the self-assessment loophole (ban "handled inline" as a skip reason, require evidence for coverage claims). The verification requirement from ai-modeling-minion is adopted in a lightweight form: cite file path + section, not full excerpts.

**Phase 5 lucy scope expansion**: lucy proposed expanding Phase 5 review to flag missing derivative documentation. margo did not address this.

**Resolution**: Defer. Phase 5 reviews what was written, which is the correct scope for code review. Adding documentation completeness checks to Phase 5 creates dual ownership with Phase 8 and expands an already-complex review prompt. The Phase 8 fixes (always-generate, expanded table, no self-skip) are the correct place to catch documentation gaps. If Phase 8 still misses items after these fixes, Phase 5 expansion can be reconsidered.

### Task 1: Restructure Phase 8 — always-generate checklist, ban self-skip

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This restructures Phase 8 control flow in SKILL.md. All downstream documentation behavior depends on getting this right. Hard to reverse (changes orchestration semantics), high blast radius (affects every future orchestration).
- **Prompt**: |
    You are modifying the Phase 8 documentation section of the nefario orchestration
    skill to fix a structural weakness: the checklist generation step was being skipped
    whenever Phase 8 execution was skipped, leaving documentation debt invisible.

    ## Target file
    `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    ## Current state (lines 1935-2030)

    Phase 8 is titled "Phase 8: Documentation (Conditional)" at line 1935.
    The current flow is:
    1. Generate checklist from outcome-action table (line 1937-1962)
    2. If checklist empty, skip entirely (line 1964)
    3. Sub-step 8a: spawn doc agents in parallel (line 1966-1977)
    4. Sub-step 8b: marketing lens (line 1979-2016)
    5. Non-blocking by default (line 2026)
    6. Write output (line 2028-2029)

    The post-exec gate (lines 1656-1672) offers "Skip docs only" and "Skip all
    post-exec" which skip Phase 8 entirely — including checklist generation.

    The skip handling (lines 1752-1773) routes "Skip docs only" to "Skip Phase 8"
    and "Skip all post-exec" to "Skip Phases 5, 6, 8."

    ## Changes required

    ### Change 1: Split Phase 8 into Assessment (always) and Execution (skippable)

    Restructure Phase 8 into two sub-phases:

    **Phase 8a: Documentation Assessment (ALWAYS runs)**
    - Runs regardless of --skip-docs, "Skip docs only", or "Skip all post-exec"
    - Evaluates execution outcomes against the outcome-action table
    - For each matching outcome, identifies target documentation files
    - For any item claimed as "already addressed in Phase 4": requires citing
      the specific file path and section that addresses it. Items without
      evidence stay on the checklist as UNVERIFIED.
    - Writes checklist to `$SCRATCH_DIR/{slug}/phase8-checklist.md`
    - If checklist is empty: records "Phase 8 assessment: 0 items identified"
    - If checklist is non-empty AND Phase 8 execution was skipped: records items
      as documentation debt (see Change 3)

    **Phase 8b: Documentation Execution (skippable)**
    - This is the current sub-step 8a (spawn doc agents) and sub-step 8b (marketing lens)
    - Skipped when user selects --skip-docs or equivalent
    - Skipped when Phase 8a checklist is empty (equivalent to current line 1964)
    - Renumber: current "Sub-step 8a" becomes "Phase 8b step 1", current
      "Sub-step 8b" becomes "Phase 8b step 2"

    ### Change 2: Ban "handled inline" as a skip justification

    Add an explicit rule after the Phase 8 header:

    "Documentation handled during Phase 4 execution does not exempt Phase 8a
    assessment. The assessment evaluates ALL execution outcomes, including those
    claimed as already addressed. Phase 4 documentation tasks are verified, not
    trusted — the checklist confirms coverage rather than assuming it."

    ### Change 3: Record documentation debt when skipped

    When Phase 8a produces a non-empty checklist but Phase 8b execution is skipped:
    - Print a CONDENSE line: "Doc debt: N items deferred (item1, item2, ...)"
    - Include the deferred items in the wrap-up verification summary
    - The execution report records these items (see the report template change
      in the other task)

    ### Change 4: Update skip handling section (lines 1752-1773)

    The skip handling section currently says Phase 8 is skipped entirely on
    --skip-docs. Update to clarify:
    - --skip-docs = skip Phase 8b (execution). Phase 8a (assessment) always runs.
    - "Skip docs only" = same as --skip-docs
    - "Skip all post-exec" = skip Phases 5, 6, and 8b. Phase 8a still runs.
    - Add a note: "Phase 8a (assessment) is non-skippable. It runs even when
      all post-execution phases are skipped, producing the documentation
      checklist for debt tracking."

    ### Change 5: Update the CONDENSE status line (lines 1768-1773)

    Currently the status line omits docs when skipped. Update:
    - When docs are skipped but assessment runs: `Verifying: code review, tests, doc assessment...`
    - When all are skipped: `Assessing: documentation...` (Phase 8a still runs)

    ## What NOT to change

    - Do NOT modify the outcome-action table content (that is a separate task)
    - Do NOT add diff-based scanning or baseline comparison
    - Do NOT add a persistent debt ledger file
    - Do NOT modify Phase 5 scope
    - Do NOT change the post-exec gate options (the options stay the same;
      what changes is what "Skip docs" means internally)
    - Do NOT modify the sub-step 8a/8b agent prompts or marketing tier logic
    - Preserve all existing SKILL.md comments (<!-- INFRASTRUCTURE: ... -->,
      <!-- DOMAIN-SPECIFIC: ... -->)

    ## Deliverables

    1. Modified Phase 8 section in SKILL.md (lines ~1935-2030)
    2. Modified skip handling section (lines ~1752-1773)
    3. Modified CONDENSE status line section (lines ~1768-1773)

    ## Success criteria

    - Phase 8a (assessment + checklist generation) runs on EVERY orchestration,
      even when the user selects "Skip all post-exec"
    - "Handled inline" claims require file path evidence
    - Non-empty checklist with skipped execution produces visible debt record
    - Existing Phase 8b behavior (agent spawning, marketing review) unchanged
    - No new phases, no new subagent calls, no persistent state files
- **Deliverables**: Modified SKILL.md with restructured Phase 8 (8a always-run assessment, 8b skippable execution), updated skip handling, updated status lines
- **Success criteria**: Phase 8a assessment is structurally non-skippable in the spec; "handled inline" banned as skip justification; debt visibility on skip

### Task 2: Expand outcome-action table with missing categories

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none (parallel with Task 1)
- **Approval gate**: no
- **Prompt**: |
    You are expanding the Phase 8 outcome-action table in the nefario orchestration
    skill to cover documentation drift categories that were missed in the WRL project.

    ## Target file
    `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    ## Current table (lines 1943-1955)

    ```
    | Outcome | Action | Owner |
    |---------|--------|-------|
    | New API endpoints | API reference, OpenAPI prose | software-docs-minion |
    | Architecture changed | C4 diagrams, component docs | software-docs-minion |
    | Gate-approved decision | ADR | software-docs-minion |
    | New user-facing feature | Getting-started / how-to | user-docs-minion |
    | New CLI command/flag | Usage docs | user-docs-minion |
    | User-visible bug fix | Release notes | user-docs-minion |
    | README not updated | README review | software-docs + product-marketing |
    | New project (git init) | Full README (blocking) | software-docs + product-marketing |
    | Breaking change | Migration guide | user-docs-minion |
    | Config changed | Config reference | software-docs-minion |
    | Spec/config files modified | Scan for derivative docs referencing changed sections | software-docs-minion |
    ```

    ## New rows to add

    Add these rows to the table, after the existing rows and before the priority
    assignment section:

    | Outcome | Action | Owner |
    |---------|--------|-------|
    | New secrets / environment variables | README secrets/env section, CONTRIBUTING .dev.vars template, deployment docs | software-docs-minion |
    | New response headers | API reference, OpenAPI response headers | software-docs-minion |
    | Error response shape changed | OpenAPI error response definitions | software-docs-minion |
    | Existing behavior changed (not a breaking change) | Scan docs referencing changed behavior for stale content | software-docs-minion |
    | New publicly accessible endpoint (incl. health, status) | README endpoint table, OpenAPI spec | software-docs-minion |
    | Developer setup dependencies changed | CONTRIBUTING setup section, getting-started | software-docs-minion |
    | CORS / security header changes | API reference, security docs | software-docs-minion |

    ## Update priority assignment (lines 1957-1960)

    Current:
    ```
    Priority assignment:
    - MUST: gate-approved decisions, new projects, breaking changes
    - SHOULD: user-facing features, new APIs
    - COULD: config refs, derivative docs
    ```

    Updated:
    ```
    Priority assignment:
    - MUST: gate-approved decisions, new projects, breaking changes,
      existing behavior contradicts docs (stale content)
    - SHOULD: user-facing features, new APIs, new secrets/env vars,
      new publicly accessible endpoints
    - COULD: config refs, derivative docs, new response headers,
      CORS/security headers, developer setup changes, error response changes
    ```

    Note: "Existing behavior changed" (stale content) is MUST priority because
    the WRL audit showed that wrong documentation (key rotation warning) is more
    damaging than missing documentation.

    ## Also add a catch-all row

    After the new rows, add one final catch-all:

    | Outcome | Action | Owner |
    |---------|--------|-------|
    | Any other file touched in Phase 4 that is referenced by existing documentation | Verify documentation references are still accurate | software-docs-minion |

    This converts the table from an exhaustive list to a minimum-plus-scan approach.

    ## What NOT to change

    - Do NOT modify any existing rows (only add new ones)
    - Do NOT modify the Phase 8 structure (that is Task 1)
    - Do NOT add diff-based scanning logic
    - Do NOT change priority levels of existing rows

    ## Deliverables

    1. Expanded outcome-action table in SKILL.md (lines ~1943-1960)

    ## Success criteria

    - All 7 new rows + 1 catch-all row present in the table
    - Priority assignment updated to include new categories
    - Existing rows unchanged
    - Table formatting consistent with current style
- **Deliverables**: Expanded outcome-action table with 8 new rows covering all WRL drift categories, updated priority assignments
- **Success criteria**: Every WRL drift pattern has a matching row in the table; priority assignments include new categories; catch-all row present

### Task 3: Add docs-debt field to report template and update AGENT.md post-execution description

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are adding documentation debt tracking to the nefario execution report
    template and updating the AGENT.md post-execution phase description to reflect
    the Phase 8 restructuring.

    ## Target files

    1. `/Users/ben/github/benpeter/despicable-agents/docs/history/nefario-reports/TEMPLATE.md`
    2. `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md`

    ## Change 1: Add `docs-debt` to report template frontmatter

    In TEMPLATE.md, the frontmatter skeleton (lines 9-22) currently has these fields:
    ```yaml
    type: nefario-report
    version: 3
    date: "{YYYY-MM-DD}"
    time: "{HH:MM:SS}"
    task: "{one-line task description}"
    source-issue: {N}
    mode: {full | plan | advisory}
    agents-involved: [{agent1}, {agent2}, ...]
    skills-used: [{skill1}, {skill2}]
    task-count: {N}
    gate-count: {N}
    outcome: {completed | partial | aborted}
    ```

    Add a new field after `outcome`:
    ```yaml
    docs-debt: {none | deferred | not-evaluated}
    ```

    ## Change 2: Add docs-debt to the Frontmatter Fields table

    In TEMPLATE.md, the Frontmatter Fields table (lines 276-289) needs a new row:

    | Field | Required | Description |
    |-------|----------|-------------|
    | `docs-debt` | always | Documentation debt status: `none` (Phase 8a found 0 items or all items addressed), `deferred` (Phase 8a found items but Phase 8b was skipped), `not-evaluated` (Phase 8a did not run — should not occur after this fix) |

    ## Change 3: Add Documentation Debt section to report skeleton

    In the report skeleton, after the Verification section (after line 208) and
    before Session Resources, add:

    ```markdown
    ## Documentation Debt

    {INCLUDE WHEN `docs-debt` = `deferred`. OMIT WHEN `docs-debt` = `none`.}

    | Item | Priority | Target Files | Status |
    |------|----------|-------------|--------|
    | {checklist item description} | {MUST/SHOULD/COULD} | {file paths} | deferred |
    ```

    ## Change 4: Add conditional section rule for Documentation Debt

    In the Conditional Section Rules table (lines 293-305), add:

    | Section | INCLUDE WHEN | OMIT WHEN |
    |---------|-------------|-----------|
    | Documentation Debt | `docs-debt` = `deferred` | `docs-debt` = `none` or `not-evaluated` |

    ## Change 5: Update AGENT.md post-execution phases description

    In `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md`, find the
    Post-Execution Phases section (between `<!-- @domain:post-execution-phases BEGIN -->`
    and `<!-- @domain:post-execution-phases END -->`). The Phase 8 bullet currently reads:

    ```
    - **Phase 8: Documentation** -- Conditional: runs when documentation checklist has items.
      Sub-step 8a: software-docs-minion + user-docs-minion in parallel.
      Sub-step 8b: product-marketing-minion reviews (conditional on README/user-facing docs).
    ```

    Update to:

    ```
    - **Phase 8: Documentation** -- Phase 8a (assessment) always runs: generates
      documentation checklist from execution outcomes, verifies coverage claims.
      Phase 8b (execution) is conditional: runs when checklist has items and user
      did not skip docs. When 8b is skipped with a non-empty checklist, items are
      recorded as documentation debt in the execution report.
    ```

    ## Change 6: Add docs-debt to the report writing checklist

    In TEMPLATE.md, the Report Writing Checklist (lines 407-432), add after step 13
    ("Write Verification table"):

    ```
    13a. Write Documentation Debt section (if docs-debt = deferred; include
         Phase 8a checklist items with priority and target files)
    ```

    ## What NOT to change

    - Do NOT bump the template version (the owner decides versioning)
    - Do NOT modify the Phase 8 section of SKILL.md (that is Task 1)
    - Do NOT add cross-session debt tracking or ledger files
    - Do NOT modify any other AGENT.md sections

    ## Deliverables

    1. Modified TEMPLATE.md with docs-debt frontmatter field, Documentation Debt
       section, conditional rule, and checklist step
    2. Modified AGENT.md with updated Phase 8 description

    ## Success criteria

    - `docs-debt` field present in frontmatter skeleton and fields table
    - Documentation Debt section has conditional inclusion rule
    - Report writing checklist includes the debt section step
    - AGENT.md accurately describes the 8a/8b split
- **Deliverables**: Updated report template with docs-debt field and Documentation Debt section; updated AGENT.md post-execution description
- **Success criteria**: docs-debt is a first-class report field; deferred items are structured and machine-queryable; AGENT.md reflects 8a/8b split

### Cross-Cutting Coverage

- **Testing** (test-minion): Excluded. This task produces spec changes (markdown edits to SKILL.md, AGENT.md, TEMPLATE.md), not executable code. There is nothing to unit test. Verification is via Phase 3.5 review and manual inspection.
- **Security** (security-minion): Excluded. No attack surface, auth, user input, secrets handling, or dependencies introduced. The changes are orchestration process rules.
- **Usability -- Strategy** (ux-strategy-minion): Covered by Phase 2 planning contribution. ux-strategy-minion's key insight (make skip cost visible at decision point, respect the skip as a legitimate job) is incorporated: the always-generate checklist with CONDENSE debt line implements their "show what WOULD be done" recommendation. The debt ledger and escalation threshold were not adopted (resolved in favor of margo's YAGNI position).
- **Usability -- Design** (ux-design-minion, accessibility-minion): Excluded. No user-facing interfaces produced. The changes affect text-based orchestration prompts.
- **Documentation** (software-docs-minion): Covered by Phase 2 planning contribution. software-docs-minion's outcome-action table expansion is adopted as Task 2. Their diff-based scan proposal was not adopted (resolved in favor of fixing the process first).
- **Observability** (observability-minion): Excluded. No runtime components, APIs, or background processes created.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - software-docs-minion: The outcome-action table expansion (Task 2) directly affects software-docs-minion's work orders in every future Phase 8. The agent should validate that the new rows are actionable and that priority assignments are correct.
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Risks and Mitigations

1. **Assessment-always adds latency to every orchestration** (ai-modeling-minion, margo). The Phase 8a assessment reads the outcome-action table and evaluates execution outcomes — no subagent spawning, no file reads beyond what the calling session already has. Estimated cost: ~$0.004 per orchestration (ai-modeling-minion's estimate), negligible vs. Phase 4. Mitigation: Phase 8a runs in the dark kitchen (no interactive latency).

2. **Checklist quality depends on table completeness** (margo, software-docs-minion). The expanded table covers all observed WRL drift patterns, plus a catch-all row. But new outcome types will emerge. Mitigation: the catch-all row ("any file touched that is referenced by existing docs") provides a safety net. The table can be incrementally expanded when new gaps are discovered.

3. **"Handled inline" evidence requirement could be gamed** (ai-modeling-minion). The calling session could produce plausible-looking file path citations without actually verifying. Mitigation: the requirement to cite specific file paths and sections creates an auditable trail in scratch files. This is the strongest enforcement available in a prompt-only system. If gaming occurs, it will be visible in execution reports.

4. **Over-engineering risk** (margo). The fix is 3 tasks modifying 3 files. Total complexity: ~2 units (margo's scale). The rejected proposals (debt ledger, diff-based scan, Phase 5 expansion, `--docs-catchup` mode) would have added ~15 complexity units. The adopted scope is proportional to the problem.

5. **ALWAYS/Conditional contradiction** (lucy). The cross-cutting checklist says Documentation is "ALWAYS include" but Phase 8 was "Conditional." After Task 1, Phase 8a (assessment) is unconditional, resolving the contradiction. Phase 8b (execution) remains conditional, which is correct: the user should be able to skip documentation writing, but not documentation assessment.

### Execution Order

```
Batch 1 (parallel):
  Task 1: Restructure Phase 8 in SKILL.md (GATE)
  Task 2: Expand outcome-action table in SKILL.md

  [APPROVAL GATE after Task 1]

Batch 2 (sequential, after gate approval):
  Task 3: Update report template + AGENT.md (depends on Task 1's 8a/8b naming)
```

### Verification Steps

1. Read the modified Phase 8 section and confirm Phase 8a is structurally non-skippable
2. Trace the skip paths ("Skip docs only", "Skip all post-exec", "--skip-docs", "--skip-post") and confirm Phase 8a runs in all cases
3. Verify the outcome-action table has 19 rows (11 original + 7 new + 1 catch-all)
4. Verify the priority assignment includes all new categories
5. Verify TEMPLATE.md has `docs-debt` field and Documentation Debt section
6. Verify AGENT.md describes the 8a/8b split accurately
7. Confirm no rejected proposals leaked into the spec (no debt ledger, no diff scan, no Phase 5 expansion, no `--docs-catchup`)
