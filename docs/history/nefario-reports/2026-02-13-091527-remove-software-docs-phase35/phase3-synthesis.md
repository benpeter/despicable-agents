# Phase 3: Synthesis -- Remove software-docs-minion from Phase 3.5 / Replace with ux-strategy-minion

## Conflict Resolution: ux-strategy-minion Promotion

Lucy flagged the ux-strategy-minion promotion as scope drift, reading the meta-plan scope as authoritative over the user's task description. However, the user's original task is unambiguous:

> "Remove software-docs-minion from mandatory Phase 3.5 Architecture Reviewers and **replace with ux-strategy-minion**."

And the success criteria explicitly states:

> "ALWAYS reviewers list is: security-minion, test-minion, **ux-strategy-minion**, lucy, margo"

The user's intent is clear: the mandatory count stays at 5, software-docs-minion is replaced by ux-strategy-minion. This is the authoritative specification. Lucy's concern about the meta-plan being more conservative is noted but overridden by the user's explicit task description.

**Resolution**: Mandatory reviewers become 5: security-minion, test-minion, ux-strategy-minion, lucy, margo. ux-strategy-minion moves from the discretionary pool to mandatory. The discretionary pool shrinks from 6 to 5 members.

## Delegation Plan

**Team name**: remove-software-docs-phase35
**Description**: Remove software-docs-minion from mandatory Phase 3.5 reviewers, replace with ux-strategy-minion, and simplify Phase 8 to self-derive its documentation checklist

### Task 1: Update the-plan.md (GATED)
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: the-plan.md is the canonical source of truth. CLAUDE.md requires human owner approval for modifications. Only Phase 3.5 reviewer list and Phase 8 checklist derivation sections may be touched.
- **Prompt**: |
    You are updating the-plan.md to reflect two changes: (1) software-docs-minion
    is removed from mandatory Phase 3.5 reviewers and replaced by ux-strategy-minion,
    and (2) Phase 8 self-derives its documentation checklist from execution outcomes
    only (no Phase 3.5 checklist input).

    ## What to change

    The file is at: `/Users/ben/github/benpeter/2despicable/3/the-plan.md`

    ### Change 1: Phase 3.5 invocation model description (~line 178-186)

    Current text (lines 178-186):
    ```
    _Phase 3.5 -- Architecture Review_: Cross-cutting agents review the plan before
    execution. Mandatory reviewers (security-minion, test-minion, software-docs-minion,
    lucy, margo) always participate. Discretionary reviewers (ux-strategy-minion,
    ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion,
    user-docs-minion) are selected by nefario using domain signal heuristics and
    approved by the user via a Reviewer Approval Gate before spawning.
    software-docs-minion produces a documentation impact checklist for Phase 8 rather
    than a full review. Reviewers return APPROVE, ADVISE, or BLOCK verdicts. BLOCK
    triggers revision loop (capped at 2 rounds).
    ```

    Updated text:
    ```
    _Phase 3.5 -- Architecture Review_: Cross-cutting agents review the plan before
    execution. Mandatory reviewers (security-minion, test-minion, ux-strategy-minion,
    lucy, margo) always participate. Discretionary reviewers (ux-design-minion,
    accessibility-minion, sitespeed-minion, observability-minion,
    user-docs-minion) are selected by nefario using domain signal heuristics and
    approved by the user via a Reviewer Approval Gate before spawning.
    Reviewers return APPROVE, ADVISE, or BLOCK verdicts. BLOCK
    triggers revision loop (capped at 2 rounds).
    ```

    Changes: Replace software-docs-minion with ux-strategy-minion in mandatory list.
    Remove ux-strategy-minion from discretionary list. Delete the sentence about
    software-docs-minion producing a documentation impact checklist.

    ### Change 2: Mandatory reviewers table (~line 461-469)

    Current:
    ```
    | Reviewer | Trigger | Rationale |
    |----------|---------|-----------|
    | security-minion | ALWAYS | Security violations in a plan are invisible until exploited |
    | test-minion | ALWAYS | Retrofitting test coverage is consistently more expensive than designing it in |
    | software-docs-minion | ALWAYS | Produces documentation impact checklist for Phase 8 (impact assessment, not full review) |
    | lucy | ALWAYS | Every plan must align with human intent, repo conventions, and CLAUDE.md compliance |
    | margo | ALWAYS | Every plan must pass YAGNI/KISS/simplicity enforcement |
    ```

    Updated:
    ```
    | Reviewer | Trigger | Rationale |
    |----------|---------|-----------|
    | security-minion | ALWAYS | Security violations in a plan are invisible until exploited |
    | test-minion | ALWAYS | Retrofitting test coverage is consistently more expensive than designing it in |
    | ux-strategy-minion | ALWAYS | Every plan needs journey coherence review and simplification audit before execution |
    | lucy | ALWAYS | Every plan must align with human intent, repo conventions, and CLAUDE.md compliance |
    | margo | ALWAYS | Every plan must pass YAGNI/KISS/simplicity enforcement |
    ```

    ### Change 3: Discretionary reviewers table (~line 471-480)

    Remove the ux-strategy-minion row. The table should have 5 rows:
    ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion,
    user-docs-minion.

    Also update the reference "6-member pool" to "5-member pool" if it appears
    near line 484.

    ### Change 4: Phase 8 description (~line 247-249)

    Current:
    ```
    _Phase 8 -- Documentation (conditional)_: Runs when nefario's documentation
    checklist has items. Nefario generates the checklist at the Phase 7->8 boundary
    based on execution outcomes.
    ```

    This text already describes self-derivation from execution outcomes. No change
    needed to the Phase 8 description or outcome-action table itself. Verify that
    there is no remaining reference to "Phase 3.5 checklist" or "merge" in the
    Phase 8 section. If there is, remove it.

    ## What NOT to change

    - Do NOT modify any agent specs (everything below line ~503)
    - Do NOT modify the delegation table, cross-cutting checklist, working patterns,
      or any section outside Phase 3.5 and Phase 8
    - Do NOT add new rows to the outcome-action table (software-docs-minion suggested
      a "derivative documentation" row, but that adds scope -- the existing table and
      Phase 8 agent judgment are sufficient)
    - Do NOT modify the model selection section

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/3/the-plan.md` with exactly
    the changes above. The diff should be small and focused.

    ## Verification

    After making changes, search the-plan.md for "software-docs-minion" and verify
    that it does NOT appear in any Phase 3.5-related context. It should still appear
    in agent specs, the delegation table, Phase 8 sub-steps, and other non-Phase-3.5
    contexts. Also verify "6-member pool" does not appear (should be "5-member pool"
    if the phrase exists).
- **Deliverables**: Updated the-plan.md with Phase 3.5 and Phase 8 changes
- **Success criteria**: software-docs-minion not in mandatory Phase 3.5 reviewers; ux-strategy-minion is mandatory; discretionary pool is 5 members; no Phase 3.5 checklist references in Phase 8; diff is narrowly scoped

### Task 2: Update skills/nefario/SKILL.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating skills/nefario/SKILL.md to reflect the approved the-plan.md
    changes. software-docs-minion is removed from mandatory Phase 3.5 reviewers
    and replaced by ux-strategy-minion. Phase 8 no longer merges a Phase 3.5
    checklist -- it self-derives entirely from execution outcomes.

    The file is at: `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

    ## Changes to make

    ### A. Mandatory reviewer list (~line 743-747)

    Remove software-docs-minion from the mandatory list and add ux-strategy-minion.
    The updated list should be:
    ```
    - security-minion
    - test-minion
    - ux-strategy-minion (journey coherence, simplification audit -- see prompt below)
    - lucy
    - margo
    ```

    ### B. Discretionary reviewer table (~line 755-762)

    Remove the ux-strategy-minion row. The table should have 5 rows:
    ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion,
    user-docs-minion.

    ### C. Reviewer Approval Gate presentation (~line 786)

    Update the mandatory line from:
    ```
    Mandatory: security, test, software-docs, lucy, margo (always review)
    ```
    to:
    ```
    Mandatory: security, test, ux-strategy, lucy, margo (always review)
    ```

    ### D. Format rules (~line 799-800)

    Update:
    ```
    Use short names (security, test, software-docs, lucy, margo).
    ```
    to:
    ```
    Use short names (security, test, ux-strategy, lucy, margo).
    ```

    ### E. Discretionary pool references

    Search for all occurrences of "6-member" in the file and replace with
    "5-member". These appear around lines 806, 826-827, 833.

    ### F. Remove software-docs-minion custom prompt block (~lines 907-972)

    Delete the entire block from `**software-docs-minion prompt**` through the
    closing triple-backtick. This is the custom prompt that produces the Phase 3.5
    documentation impact checklist.

    ### G. Add ux-strategy-minion custom prompt block

    In place of the removed software-docs-minion prompt (or immediately after the
    generic reviewer prompt template), add:

    ```
    **ux-strategy-minion prompt** (replaces the generic reviewer prompt):

    ~~~
    Task:
      subagent_type: ux-strategy-minion
      description: "Nefario: ux-strategy-minion review"
      model: sonnet
      prompt: |
        You are reviewing a delegation plan before execution begins.
        Your role: evaluate journey coherence, cognitive load, and simplification
        opportunities across the plan.

        ## Delegation Plan
        Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md

        ## Your Review Focus
        1. Journey coherence: Do the planned deliverables form a coherent user
           experience? Are there gaps or contradictions in the user-facing flow?
        2. Cognitive load: Will the planned changes increase complexity for users?
           Are there simpler alternatives that achieve the same goal?
        3. Simplification: Can any planned deliverables be combined, removed, or
           simplified without losing value?
        4. User jobs-to-be-done: Does each user-facing task serve a real user need,
           or is it feature creep?

        ## Verdict
        Return exactly one of:
        - APPROVE: No concerns from your domain.
        - ADVISE: <list specific non-blocking warnings>
        - BLOCK: <describe the blocking issue and what must change>

        Write your verdict to: $SCRATCH_DIR/{slug}/phase3.5-ux-strategy-minion.md

        Be concise. Only flag issues within your domain expertise.
    ~~~
    ```

    Use triple-backtick for the outer fence (matching the existing pattern in the
    file). The ~~~ above is just to avoid nesting issues in this prompt -- use
    the same fencing pattern as the other custom prompts in the file.

    ### H. Scratch directory structure (~line 289)

    Remove:
    ```
      phase3.5-docs-checklist.md          # documentation impact checklist (Phase 8 input)
    ```

    ### I. Phase 8 section (~lines 1581-1623)

    Replace the current Phase 8 logic (steps 1a, 1b, 1c, and the merge) with
    simplified self-derivation. The new step 1 should be:

    ```
    1. **Generate documentation checklist** from execution outcomes:

       Evaluate execution outcomes against the outcome-action table:

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

       For each matching outcome, create a checklist item with:
       - Owner tag: [software-docs] or [user-docs] (from table Owner column)
       - Priority: MUST (gate-approved decisions, new projects, breaking changes),
         SHOULD (user-facing features, new APIs), COULD (config refs, derivative docs)
       - Scope: one-line description of what needs updating
       - Files: affected file path(s) if identifiable from execution outcomes

       Write the checklist to: `$SCRATCH_DIR/{slug}/phase8-checklist.md`
    ```

    Note: This adds the "derivative docs" row that software-docs-minion recommended
    (spec/config files modified -> scan for derivative docs). This closes the gap
    from removing Phase 3.5 pre-analysis without requiring a separate task.

    Remove step 1a (read Phase 3.5 checklist), step 1b (supplement with execution
    outcomes), and step 1c (flag divergence). They are replaced by the single
    step above.

    ### J. Phase 8 sub-step 8a prompt reference (~lines 1618-1623)

    Update the agent prompt reference to remove Phase 3.5 checklist mentions:

    Current (~line 1621):
    ```
       - Note: Items from Phase 3.5 are pre-analyzed with scope and file paths.
         Execution-derived items may need the agent to inspect changed files for
         full scope.
    ```

    Replace with:
    ```
       - Note: Checklist items are derived from execution outcomes. Agents should
         inspect changed files for full scope when file paths are not specified.
    ```

    ## What NOT to change

    - Do NOT modify any other phases (1-4, 5-7)
    - Do NOT modify the Execution Plan Approval Gate
    - Do NOT modify the Team Approval Gate
    - Do NOT change the Phase 8 sub-steps (8a spawn pattern, 8b marketing lens)
    - Do NOT modify the report template or any sections outside Phase 3.5 and Phase 8

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

    ## Verification

    After making changes:
    1. Search for "software-docs-minion" -- should NOT appear in Phase 3.5 reviewer
       context. Should still appear in Phase 8 outcome-action table and sub-step 8a.
    2. Search for "phase3.5-docs-checklist" -- should return zero results.
    3. Search for "6-member" -- should return zero results (all replaced with "5-member").
    4. Verify ux-strategy-minion appears in the mandatory list and has a custom prompt.
    5. Verify the discretionary table has exactly 5 rows (no ux-strategy-minion).
- **Deliverables**: Updated SKILL.md with Phase 3.5 reviewer swap, removed software-docs custom prompt, added ux-strategy custom prompt, simplified Phase 8, updated discretionary pool size
- **Success criteria**: All 10 changes (A-J) applied; verification queries pass

### Task 3: Update nefario/AGENT.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating nefario/AGENT.md to reflect the approved the-plan.md changes.
    software-docs-minion is removed from mandatory Phase 3.5 reviewers and replaced
    by ux-strategy-minion.

    The file is at: `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`

    ## Changes to make

    ### A. Architecture Review Agents synthesis template (~line 513)

    Change:
    ```
    - **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
    ```
    to:
    ```
    - **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
    ```

    ### B. Mandatory reviewer table (~lines 562-570)

    Replace the software-docs-minion row:
    ```
    | **software-docs-minion** | ALWAYS | Produces documentation impact checklist consumed by Phase 8. Role is scoped to impact assessment, not full documentation review. |
    ```
    with:
    ```
    | **ux-strategy-minion** | ALWAYS | Every plan needs journey coherence review and simplification audit before execution. |
    ```

    ### C. Discretionary reviewer table (~lines 572-581)

    Remove the ux-strategy-minion row from the discretionary table. The table
    should have 5 rows: ux-design-minion, accessibility-minion, sitespeed-minion,
    observability-minion, user-docs-minion.

    ### D. software-docs-minion exception paragraph (~lines 633-638)

    Delete the entire paragraph:
    ```
    **software-docs-minion exception**: In Phase 3.5, software-docs-minion
    produces a documentation impact checklist (written to scratch) instead of a
    standard domain review. Its verdict reflects whether the plan has adequate
    documentation coverage -- ADVISE for gaps, APPROVE when coverage is
    sufficient. software-docs-minion should not BLOCK for documentation concerns;
    gaps are addressed through the checklist in Phase 8.
    ```

    ## What NOT to change

    - Do NOT modify any other sections of AGENT.md
    - Do NOT change the YAML frontmatter
    - The mandatory count stays at 5 (composition changes, count does not)
    - Do NOT add a ux-strategy-minion exception paragraph (it uses the standard
      reviewer prompt pattern, unlike the old software-docs-minion)

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`

    ## Verification

    After making changes:
    1. Search for "software-docs-minion" in Phase 3.5 context -- should not appear
    2. Verify ux-strategy-minion appears in mandatory table and synthesis template
    3. Verify discretionary table has 5 rows (no ux-strategy-minion)
    4. Verify the exception paragraph is deleted
- **Deliverables**: Updated AGENT.md with Phase 3.5 reviewer swap and exception paragraph removal
- **Success criteria**: Mandatory list shows ux-strategy-minion; no software-docs in Phase 3.5 context; exception paragraph removed; discretionary pool is 5 members

### Task 4: Update docs/orchestration.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating docs/orchestration.md to reflect the approved the-plan.md
    changes. software-docs-minion is removed from mandatory Phase 3.5 reviewers
    and replaced by ux-strategy-minion. Phase 8 no longer merges a Phase 3.5
    checklist.

    The file is at: `/Users/ben/github/benpeter/2despicable/3/docs/orchestration.md`

    ## Changes to make

    ### A. Mandatory reviewer table (~lines 59-65)

    Replace the software-docs-minion row:
    ```
    | software-docs-minion | ALWAYS | Produces documentation impact checklist for Phase 8 (impact assessment, not full review) |
    ```
    with:
    ```
    | ux-strategy-minion | ALWAYS | Every plan needs journey coherence review and simplification audit before execution |
    ```

    ### B. Discretionary reviewer table (~lines 69-76)

    Remove the ux-strategy-minion row. The table should have 5 rows.

    ### C. Discretionary pool size reference (~line 78)

    If the text references "6-member pool" or similar, update to "5-member pool".

    ### D. software-docs-minion exception paragraph (~line 90)

    Delete the paragraph about software-docs-minion producing a documentation
    impact checklist rather than a standard review.

    ### E. Phase 8 description (~line 162)

    Current:
    ```
    Runs when nefario's documentation checklist has items. The checklist is generated
    by merging the Phase 3.5 documentation impact checklist (produced by
    software-docs-minion during architecture review, if available) with
    execution-outcome items identified at the Phase 7-to-8 boundary. If Phase 3.5
    was skipped, the checklist is generated entirely from execution outcomes (e.g.,
    new API endpoints trigger API reference docs, architecture changes trigger C4
    diagram updates, user-facing features trigger how-to guides).
    ```

    Replace with:
    ```
    Runs when nefario's documentation checklist has items. The checklist is generated
    at the Phase 7-to-8 boundary by evaluating execution outcomes against the
    outcome-action table (e.g., new API endpoints trigger API reference docs,
    architecture changes trigger C4 diagram updates, user-facing features trigger
    how-to guides). Owner tags and priority are assigned by the orchestrator based
    on the outcome-action table.
    ```

    ## What NOT to change

    - Do NOT modify the mermaid sequence diagram (it shows "Reviewers" generically,
      not individual reviewer names)
    - Do NOT modify Phase 4-7 descriptions
    - Do NOT modify Phase 8 sub-step descriptions (8a, 8b)

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/3/docs/orchestration.md`

    ## Verification

    After making changes:
    1. Search for "software-docs-minion" -- should not appear in Phase 3.5 context.
       May still appear in Phase 8 sub-step descriptions.
    2. Search for "Phase 3.5 checklist" or "merge" in Phase 8 context -- should not appear.
    3. Verify ux-strategy-minion is in mandatory table.
    4. Verify discretionary table has 5 rows.
- **Deliverables**: Updated docs/orchestration.md with Phase 3.5 and Phase 8 changes
- **Success criteria**: Consistent with the-plan.md changes; no Phase 3.5 checklist references in Phase 8; ux-strategy-minion is mandatory

### Cross-Cutting Coverage
- **Testing**: Not applicable -- this task modifies documentation/configuration files only, producing no executable code. No tests to write or run.
- **Security**: Not applicable -- no attack surface, auth, user input, secrets, or dependencies introduced.
- **Usability -- Strategy**: Not applicable at execution level. The change itself promotes ux-strategy-minion to mandatory reviewer status, which improves UX coverage in future orchestrations.
- **Usability -- Design**: Not applicable -- no UI produced.
- **Documentation**: Covered by Tasks 1-4 themselves (this IS a documentation change). All four target files are documentation/configuration artifacts.
- **Observability**: Not applicable -- no runtime components produced.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo

  Note: This plan changes the mandatory list itself. For THIS review, the current
  mandatory list (pre-change) applies: security-minion, test-minion,
  software-docs-minion, lucy, margo.

- **Discretionary picks**: none -- all tasks are text edits to configuration/documentation files. No user-facing interfaces, web components, runtime services, or end-user documentation changes.
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

**lucy vs. user task: ux-strategy-minion promotion**

Lucy flagged the ux-strategy-minion promotion to mandatory as scope drift, noting the meta-plan described a 4-member mandatory list (security-minion, test-minion, lucy, margo). However, the user's task description explicitly says "replace with ux-strategy-minion" and the success criteria lists ux-strategy-minion as mandatory. The user's task is authoritative.

**Resolution**: Follow the user's explicit task description. Mandatory reviewers: 5 (security-minion, test-minion, ux-strategy-minion, lucy, margo). Discretionary pool: 5 members (was 6).

**software-docs-minion: derivative documentation row**

software-docs-minion recommended adding a "derivative documentation" row to the outcome-action table to close the gap from removing Phase 3.5 pre-analysis. Lucy recommended against adding scope. The derivative-docs row is a lightweight mitigation (one table row) that addresses a real gap (spec files modified but dependent docs not flagged). Including it in the SKILL.md Phase 8 outcome-action table is proportionate.

**Resolution**: Add the derivative-docs row to the SKILL.md Phase 8 outcome-action table only (not to the-plan.md, which has a constraint limiting changes to Phase 3.5 and Phase 8 sections -- and the outcome-action table in the-plan.md is in Phase 8 but adding a row may be seen as exceeding "checklist derivation sections"). The SKILL.md table is the operational one consumed by the orchestrator at runtime.

### Risks and Mitigations

1. **LOW: First few orchestrations may produce slightly less precise doc checklists** (from software-docs-minion). Phase 8 agents still run with full specialist judgment -- they just start without a pre-analyzed checklist. The derivative-docs row in the outcome-action table partially mitigates this.

2. **LOW: Inconsistent mandatory count across artifacts** (from lucy). Mitigated by the explicit location checklist in lucy's contribution. All four files are updated in the execution plan with specific line references. The verification steps in each task prompt ensure consistency.

3. **LOW: Loss of the divergence signal** (from software-docs-minion). The "planned but not implemented" flagging disappears. Mitigated by the simplification itself: single-source checklist means no divergence to detect. The orchestrator can compare planned vs. actual deliverables from the synthesis plan if needed, without a separate mechanism.

### Execution Order

```
Batch 1: Task 1 (the-plan.md) -- GATED
  |
  v  [user approval]
  |
Batch 2: Task 2 (SKILL.md) + Task 3 (AGENT.md) + Task 4 (orchestration.md) -- parallel
```

### Verification Steps

After all tasks complete:
1. `grep -c "software-docs-minion" the-plan.md` in Phase 3.5 context -- should be 0
2. `grep -c "phase3.5-docs-checklist"` across all 4 files -- should be 0
3. `grep -c "6-member"` across all 4 files -- should be 0
4. Mandatory list in all 4 files is: security-minion, test-minion, ux-strategy-minion, lucy, margo
5. Discretionary pool in all files has 5 members (no ux-strategy-minion)
6. Phase 8 in SKILL.md uses single-source derivation (no merge, no step 1a/1c)
7. ux-strategy-minion has a custom prompt in SKILL.md
8. software-docs-minion custom prompt block is removed from SKILL.md
