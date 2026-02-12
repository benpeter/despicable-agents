# Delegation Plan: Rework Phase 3.5 Reviewer Composition

## Delegation Plan

**Team name**: phase35-reviewer-rework
**Description**: Rework Phase 3.5 Architecture Review to use 5 mandatory + 6 discretionary reviewers with a user approval gate, narrow software-docs-minion to documentation impact checklist, and wire Phase 8 to consume that checklist.

---

### Task 1: Update AGENT.md -- Architecture Review section and synthesis template

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: The Architecture Review section in AGENT.md defines the reviewer roster, triggering rules, and synthesis output format. All downstream tasks (SKILL.md, orchestration.md) depend on this definition being correct. Hard to reverse (propagates into all nefario instances).
- **Prompt**: |
    You are updating the nefario agent specification to implement a new Phase 3.5
    reviewer composition model: 5 mandatory ("ALWAYS") reviewers and 6 discretionary
    reviewers selected by nefario and approved by the user before spawning.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md`. Make these changes:

    ### A. Review Triggering Rules table (lines ~559-570)

    Replace the current 6-ALWAYS + 4-conditional table with:

    **Mandatory reviewers (ALWAYS):**

    | Reviewer | Trigger | Rationale |
    |----------|---------|-----------|
    | **security-minion** | ALWAYS | Security violations in a plan are invisible until exploited. Mandatory review is the only reliable mitigation. |
    | **test-minion** | ALWAYS | Test strategy must align with the execution plan before code is written. Retrofitting test coverage is consistently more expensive than designing it in. |
    | **software-docs-minion** | ALWAYS | Produces documentation impact checklist consumed by Phase 8. Role is scoped to impact assessment, not full documentation review. |
    | **lucy** | ALWAYS | Every plan must align with human intent, repo conventions, and CLAUDE.md compliance. Intent drift is the #1 failure mode in multi-phase orchestration. |
    | **margo** | ALWAYS | Every plan must pass YAGNI/KISS/simplicity enforcement. Can BLOCK on: unnecessary complexity, over-engineering, scope creep. |

    **Discretionary reviewers (selected by nefario, approved by user):**

    | Reviewer | Domain Signal | Rationale |
    |----------|--------------|-----------|
    | **ux-strategy-minion** | Plan includes user-facing workflow changes, journey modifications, or cognitive load implications | Journey coherence and simplification review |
    | **ux-design-minion** | Plan includes tasks producing UI components, visual layouts, or interaction patterns | Accessibility patterns and visual hierarchy review |
    | **accessibility-minion** | Plan includes tasks producing web-facing HTML/UI that end users interact with | WCAG compliance must be reviewed before UI code is written |
    | **sitespeed-minion** | Plan includes tasks producing web-facing runtime code (pages, APIs serving browsers, assets) | Performance budgets must be established before implementation |
    | **observability-minion** | Plan includes 2+ tasks producing runtime components that need coordinated logging/metrics/tracing | Coordinated observability strategy across services |
    | **user-docs-minion** | Plan includes tasks whose output changes what end users see, do, or need to learn | User-facing documentation impact needs early identification |

    Add a paragraph after the discretionary table:

    > During synthesis, nefario evaluates each discretionary reviewer against the
    > delegation plan using a forced yes/no enumeration with one-line rationale per
    > reviewer. The "Domain Signal" column provides heuristic anchors -- nefario
    > matches plan content against these signals rather than applying rigid
    > conditionals. Discretionary picks are presented to the user for approval
    > before reviewers are spawned (see SKILL.md Phase 3.5 for the approval gate
    > interaction).

    Keep the existing paragraph about model selection:
    "All reviewers run on **sonnet** except lucy and margo, which run on **opus**
    (governance judgment requires deep reasoning)."

    ### B. Synthesis output template -- Architecture Review Agents field (line ~511)

    Replace:
    ```
    ### Architecture Review Agents
    - **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
    - **Conditional**: <list conditional reviewers triggered and why, or state "none triggered">
    ```

    With:
    ```
    ### Architecture Review Agents
    - **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
    - **Discretionary picks**: <for each discretionary reviewer selected, list: reviewer name + one-line rationale grounded in specific plan content; reference task numbers>
    - **Not selected**: <remaining discretionary pool members not selected, comma-separated>
    ```

    ### C. Cross-cutting checklist clarification (after line ~272)

    After the existing note about lucy and margo, add:

    > _This checklist governs agent inclusion in planning and execution phases (1-4). Phase 3.5 architecture review has its own triggering rules (see Architecture Review section) which may differ -- an agent can be ALWAYS in the checklist but discretionary in Phase 3.5 review._

    ### D. Verdict Format -- software-docs-minion exception

    In the Verdict Format section (after the BLOCK format block, around line 612),
    add a note:

    > **software-docs-minion exception**: In Phase 3.5, software-docs-minion
    > produces a documentation impact checklist (written to scratch) instead of a
    > standard domain review. Its verdict reflects whether the plan has adequate
    > documentation coverage -- ADVISE for gaps, APPROVE when coverage is
    > sufficient. software-docs-minion should not BLOCK for documentation concerns;
    > gaps are addressed through the checklist in Phase 8.

    ## What NOT to Do

    - Do NOT modify the delegation table (lines 96-187)
    - Do NOT modify post-execution phases (lines 672-688)
    - Do NOT modify the cross-cutting checklist entries themselves -- only add the
      clarifying note after the existing note about lucy/margo
    - Do NOT change model selection defaults (the "use opus" is a session directive,
      not a permanent spec change)
    - Do NOT touch any other agent's AGENT.md files

    ## Context

    - This implements the ALWAYS/discretionary split from the GitHub issue
    - ux-strategy-minion moves from ALWAYS to discretionary (not a demotion of
      planning importance -- the cross-cutting checklist still says ALWAYS for
      planning inclusion; only Phase 3.5 review changes)
    - user-docs-minion is NEW to Phase 3.5 (added to discretionary pool; was not
      previously a Phase 3.5 reviewer at all)
    - software-docs-minion remains ALWAYS but its role narrows to documentation
      impact checklist (detailed prompt is in Task 2)

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md` with:
    1. New ALWAYS/discretionary reviewer tables
    2. Updated synthesis output template
    3. Cross-cutting checklist clarification sentence
    4. software-docs-minion verdict exception note

    ## Success Criteria

    - ALWAYS roster is exactly: security-minion, test-minion, software-docs-minion, lucy, margo
    - Discretionary pool is exactly: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion
    - Synthesis template uses "Mandatory" / "Discretionary picks" / "Not selected" terminology
    - Cross-cutting checklist has clarifying sentence separating it from Phase 3.5 triggering
    - No unrelated sections modified

---

### Task 2: Update SKILL.md -- Phase 3.5 reviewer identification, approval gate, and software-docs-minion prompt

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: yes
- **Gate reason**: SKILL.md Phase 3.5 defines the operational behavior of the orchestration workflow. This is the most complex edit in the plan (reviewer identification, approval gate interaction, software-docs-minion prompt, response handling). High blast radius -- Phase 8 and all future orchestration sessions depend on it.
- **Prompt**: |
    You are updating the nefario SKILL.md to implement the new Phase 3.5 reviewer
    composition model with a user approval gate.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`.
    Make these changes to the Phase 3.5 section (starts at line ~601):

    ### A. Replace "Identify Reviewers" section (lines ~606-621)

    Replace the current section with:

    ```markdown
    ### Identify Reviewers

    From the delegation plan, determine which reviewers to include:

    **Mandatory** (always spawned, not user-adjustable):
    - security-minion
    - test-minion
    - software-docs-minion (documentation impact checklist role -- see prompt below)
    - lucy
    - margo

    **Discretionary** (selected by nefario, approved by user):

    Evaluate each discretionary reviewer against the delegation plan. For each,
    determine whether the plan produces artifacts in the reviewer's domain.

    | Reviewer | Domain Signal |
    |----------|--------------|
    | ux-strategy-minion | Plan includes user-facing workflow changes, journey modifications, or cognitive load implications |
    | ux-design-minion | Plan includes tasks producing UI components, visual layouts, or interaction patterns |
    | accessibility-minion | Plan includes tasks producing web-facing HTML/UI that end users interact with |
    | sitespeed-minion | Plan includes tasks producing web-facing runtime code (pages, APIs serving browsers, assets) |
    | observability-minion | Plan includes 2+ tasks producing runtime components that need coordinated logging/metrics/tracing |
    | user-docs-minion | Plan includes tasks whose output changes what end users see, do, or need to learn |

    For each discretionary reviewer, decide yes/no with a one-line rationale
    grounded in the specific plan content (reference task numbers or deliverables).
    ```

    ### B. Add "Reviewer Approval Gate" section (after Identify Reviewers, before Spawn Reviewers)

    Insert a new section:

    ```markdown
    ### Reviewer Approval Gate

    Present discretionary picks to the user for approval before spawning any
    reviewers. If no discretionary reviewers were selected, auto-approve with a
    CONDENSE note ("Reviewers: 5 mandatory, 0 discretionary") and skip the gate.

    **Presentation format** (target 6-10 lines):

    ~~~
    REVIEWERS: <1-sentence plan summary>
    Mandatory: security, test, software-docs, lucy, margo (always review)

      DISCRETIONARY (nefario recommends):
        <agent-name>       <rationale, max 60 chars, reference tasks>
        <agent-name>       <rationale, max 60 chars, reference tasks>

      NOT SELECTED from pool:
        <remaining pool members, comma-separated>

    Full plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md
    ~~~

    Format rules:
    - Mandatory line: flat comma-separated, one line, presented as fact not choice.
      Use short names (security, test, software-docs, lucy, margo).
    - DISCRETIONARY block: one agent per line with plan-grounded rationale. Rationale
      must reference specific plan content (task numbers, deliverables), not the
      reviewer's general capability. Max 60 characters per rationale.
    - NOT SELECTED: flat comma-separated list of remaining discretionary pool members.
    - No "ALSO AVAILABLE" block listing the full agent roster. The decision space is
      the 6-member discretionary pool only.

    **AskUserQuestion**:
    - `header`: "Review"
    - `question`: "<1-sentence plan summary>"
    - `options` (3, `multiSelect: false`):
      1. label: "Approve reviewers"
         description: "5 mandatory + N discretionary reviewers proceed to review."
         (recommended)
      2. label: "Adjust reviewers"
         description: "Add or remove discretionary reviewers before review begins."
      3. label: "Skip review"
         description: "Proceed to plan approval without architecture review."

    **Response handling**:

    **"Approve reviewers"**: Gate clears. Spawn mandatory + approved discretionary
    reviewers.

    **"Adjust reviewers"**: User provides freeform adjustment. Constrained to the
    6-member discretionary pool. If the user requests an agent outside the pool,
    note it is not a Phase 3.5 reviewer and offer the closest match from the pool.
    Cap at 2 adjustment rounds, same as the Team Approval Gate. After adjustment,
    spawn the final approved set.

    **"Skip review"**: Skip Phase 3.5 entirely. Proceed directly to the Execution
    Plan Approval Gate. No reviewers are spawned. The plan is presented as-is.
    The execution plan gate still occurs -- the user still has a checkpoint before
    code runs. Do NOT add friction or warnings to the skip path.
    ```

    ### C. Update "Spawn Reviewers" section (lines ~622-653)

    Update the opening to say:

    ```markdown
    ### Spawn Reviewers

    Spawn all approved reviewers in parallel (mandatory + user-approved discretionary).
    Use opus for lucy and margo (governance reviewers requiring deeper reasoning);
    use sonnet for all others:
    ```

    The rest of the spawn section stays the same, EXCEPT add a special prompt
    template for software-docs-minion. After the generic reviewer prompt template,
    add:

    ```markdown
    **software-docs-minion prompt** (replaces the generic reviewer prompt):

    ~~~
    Task:
      subagent_type: software-docs-minion
      description: "Nefario: software-docs-minion review"
      model: sonnet
      prompt: |
        You are reviewing a delegation plan before execution begins.
        Your role: produce a documentation impact checklist for Phase 8.

        ## Delegation Plan
        Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md

        ## Your Review Focus
        Identify all documentation that needs creating or updating as a result
        of this plan. Do NOT write the documentation. Produce a checklist of
        what needs to change.

        ## Checklist Format
        Write the checklist to: $SCRATCH_DIR/{slug}/phase3.5-docs-checklist.md

        Use this format:

        ```markdown
        # Documentation Impact Checklist

        Source: Phase 3.5 architecture review
        Plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md

        ## Items

        - [ ] **[software-docs]** <what to update>
          Scope: <what specifically changes, one line>
          Files: <exact file path(s) affected>
          Priority: MUST | SHOULD | COULD

        - [ ] **[user-docs]** <what to update>
          Scope: <what specifically changes, one line>
          Files: <exact file path(s) affected>
          Priority: MUST | SHOULD | COULD

        ## Not Applicable
        - <category>: <brief rationale why not applicable>
        ```

        Rules:
        - Owner tag: [software-docs] or [user-docs] to pre-route to Phase 8 agent
        - One line per item for the description
        - Scope: one line of intent, not a paragraph
        - Priority: MUST (required for correctness), SHOULD (improves completeness),
          COULD (nice to have)
        - Max 10 items. If you identify more than 10, the plan has documentation-heavy
          changes and the full analysis belongs in Phase 8.
        - Include "Not Applicable" section for standard categories that don't apply

        ## Verdict
        After writing the checklist, return your verdict:
        - APPROVE: Plan has adequate documentation coverage in its task prompts
        - ADVISE: Documentation gaps exist but are addressable in Phase 8
          (include the gaps as checklist items)
        - Do NOT use BLOCK for documentation concerns. Gaps are addressed through
          the checklist in Phase 8. Only BLOCK if the plan fundamentally cannot be
          documented (no clear deliverables, contradictory outputs, etc.) -- this
          should be extremely rare.

        Write your verdict to: $SCRATCH_DIR/{slug}/phase3.5-software-docs-minion.md

        Be concise. Focus on identifying WHAT needs documenting, not writing docs.
    ~~~
    ```

    ### D. No changes to Process Verdicts or Revision Loop sections

    These sections (lines ~655-728) remain unchanged. software-docs-minion's
    verdict file is still read by the same verdict processing loop. The checklist
    is a secondary artifact that only Phase 8 consumes.

    ## What NOT to Do

    - Do NOT modify Phase 4 (Execution) or any post-execution phase except Phase 8
      (that is Task 3)
    - Do NOT modify the compaction checkpoints
    - Do NOT modify the Execution Plan Approval Gate
    - Do NOT change the revision loop logic
    - Do NOT modify Phase 1, 2, or 3 sections

    ## Context

    - The Team Approval Gate from #48 (PR #51, already merged to main) establishes
      the pattern: AskUserQuestion with 3 options, freeform adjust constrained to
      a pool, 2-round adjustment cap. This gate reuses that pattern.
    - The compaction checkpoint after Phase 3 (lines 582-599) happens BEFORE this
      gate. The compaction checkpoint after Phase 3.5 (lines 729-746) happens AFTER
      this gate and after verdict processing. Both remain unchanged.
    - software-docs-minion produces TWO outputs: the checklist file (consumed by
      Phase 8) and the verdict file (consumed by the Phase 3.5 verdict loop).
      This is consistent -- the verdict loop reads the verdict file as it does
      for all reviewers; the checklist is an additional artifact.

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` with:
    1. New Identify Reviewers section (mandatory + discretionary)
    2. New Reviewer Approval Gate section with AskUserQuestion spec
    3. Updated Spawn Reviewers section
    4. New software-docs-minion prompt template producing documentation impact checklist

    ## Success Criteria

    - Mandatory reviewers list matches: security-minion, test-minion, software-docs-minion, lucy, margo
    - Discretionary pool matches: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion
    - Reviewer Approval Gate uses AskUserQuestion with header "Review" and 3 options
    - "Skip review" skips Phase 3.5 entirely (no reviewers spawned)
    - "Adjust reviewers" constrained to discretionary pool with 2-round cap
    - Auto-skip gate when 0 discretionary reviewers selected
    - software-docs-minion prompt produces checklist to phase3.5-docs-checklist.md
    - software-docs-minion verdict is APPROVE or ADVISE (BLOCK only in extreme cases)
    - Generic reviewer prompt template unchanged for all other reviewers

---

### Task 3: Update SKILL.md -- Phase 8 checklist merge logic

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: bypassPermissions
- **Blocked by**: Task 2
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario SKILL.md Phase 8 documentation section to consume
    the Phase 3.5 documentation impact checklist as input.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`.
    Make these changes to Phase 8 (starts at line ~1251):

    ### A. Replace step 1 "Generate checklist" with merge logic

    Replace the current step 1 (lines ~1253-1268) with:

    ```markdown
    1. **Merge documentation checklist** from Phase 3.5 and execution outcomes:

       a. **Read Phase 3.5 checklist**: If `$SCRATCH_DIR/{slug}/phase3.5-docs-checklist.md`
          exists, read it as the starting checklist. These items were identified
          from the plan before execution and have owner tags ([software-docs] or
          [user-docs]), scope, file paths, and priority already assigned.

       b. **Supplement with execution outcomes**: Evaluate execution outcomes
          against the outcome-action table below. For each outcome, check whether
          the Phase 3.5 checklist already covers it. If not, add a new item.

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

       c. **Flag divergence**: For items in the Phase 3.5 checklist that do not
          correspond to any execution outcome, mark them as: "Planned but not
          implemented -- verify if still needed."

       Write the merged checklist to: `$SCRATCH_DIR/{slug}/phase8-checklist.md`
    ```

    ### B. Update step 3 agent prompts (sub-step 8a, lines ~1272-1277)

    Update the text to reference the merged checklist with owner tags:

    ```markdown
    3. **Sub-step 8a** (parallel): spawn software-docs-minion + user-docs-minion
       with their respective checklist items and paths to execution artifacts.

       Each agent's prompt should reference:
       - Work order: `$SCRATCH_DIR/{slug}/phase8-checklist.md`
       - Items tagged with their owner ([software-docs] or [user-docs])
       - Note: Items from Phase 3.5 are pre-analyzed with scope and file paths.
         Execution-derived items may need the agent to inspect changed files for
         full scope.
    ```

    ### C. Keep everything else unchanged

    Steps 2, 4, 5, 6 remain unchanged. The outcome-action table is retained
    (moved into step 1b as supplementation source, not replaced). Sub-step 8b
    (product-marketing-minion) is unchanged.

    ## What NOT to Do

    - Do NOT remove the outcome-action table -- it becomes the supplementation
      source for execution-discovered items
    - Do NOT modify sub-step 8b (product-marketing-minion)
    - Do NOT modify Phase 5, 6, or 7
    - Do NOT modify any section outside Phase 8

    ## Context

    - The Phase 3.5 checklist is produced by software-docs-minion during
      architecture review (Task 2 of this plan)
    - The checklist is a prediction (based on the plan). Phase 8's execution-outcome
      table is ground truth. Phase 8 unions both.
    - If Phase 3.5 was skipped ("Skip review" at the reviewer gate), the
      phase3.5-docs-checklist.md file will not exist. The merge logic handles
      this: step 1a says "if exists" -- if it does not, Phase 8 falls back to
      generating the checklist entirely from execution outcomes (current behavior).

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`
    Phase 8 section with merge logic.

    ## Success Criteria

    - Phase 8 reads phase3.5-docs-checklist.md if it exists
    - Phase 8 supplements (not replaces) with execution-outcome items
    - Outcome-action table is preserved as supplementation source
    - Divergence flagging is present for planned-but-not-implemented items
    - Graceful fallback when phase3.5-docs-checklist.md does not exist

---

### Task 4: Update docs/orchestration.md

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: bypassPermissions
- **Blocked by**: Task 1, Task 2, Task 3
- **Approval gate**: no
- **Prompt**: |
    You are updating the orchestration architecture documentation to reflect the
    new Phase 3.5 reviewer composition model.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md`.

    ### A. Update Phase 3.5 section (lines ~53-84)

    Replace the "Review triggering rules" table with two tables: mandatory and
    discretionary. Use the exact rosters:

    **Mandatory reviewers (ALWAYS):**

    | Reviewer | Trigger | Rationale |
    |----------|---------|-----------|
    | security-minion | ALWAYS | Security violations in a plan are invisible until exploited |
    | test-minion | ALWAYS | Retrofitting test coverage is consistently more expensive than designing it in |
    | software-docs-minion | ALWAYS | Produces documentation impact checklist for Phase 8 (impact assessment, not full review) |
    | lucy | ALWAYS | Every plan must align with human intent, repo conventions, and CLAUDE.md compliance |
    | margo | ALWAYS | Every plan must pass YAGNI/KISS/simplicity enforcement |

    **Discretionary reviewers (selected by nefario, approved by user):**

    | Reviewer | Domain Signal |
    |----------|--------------|
    | ux-strategy-minion | Plan includes user-facing workflow or journey changes |
    | ux-design-minion | 1+ tasks produce user-facing interfaces |
    | accessibility-minion | 1+ tasks produce web-facing UI |
    | sitespeed-minion | 1+ tasks produce web-facing runtime components |
    | observability-minion | 2+ tasks produce runtime components needing coordinated observability |
    | user-docs-minion | Plan output changes what end users see, do, or need to learn |

    Add a paragraph after the discretionary table explaining the approval gate:

    > Before spawning reviewers, nefario presents its discretionary picks to the
    > user via a Reviewer Approval Gate. The user can approve the reviewer set,
    > adjust discretionary picks (constrained to the 6-member pool, 2-round
    > adjustment cap), or skip architecture review entirely to proceed directly
    > to the Execution Plan Approval Gate.

    Update the model selection line to keep current language:
    "All reviewers run on **sonnet** except lucy and margo, which run on **opus**
    (governance judgment requires deep reasoning)."

    Update the software-docs-minion description in the verdict format paragraph
    to note that software-docs-minion produces a documentation impact checklist
    rather than a standard domain review, and should not BLOCK for documentation
    concerns.

    ### B. Update Phase 8 section (lines ~150-159)

    Update the first paragraph to mention the Phase 3.5 checklist handoff:

    > Runs when nefario's documentation checklist has items. The checklist is
    > generated by merging the Phase 3.5 documentation impact checklist (produced
    > by software-docs-minion during architecture review, if available) with
    > execution-outcome items identified at the Phase 7-to-8 boundary. If Phase
    > 3.5 was skipped, the checklist is generated entirely from execution outcomes.

    ### C. Update Mermaid sequence diagram (lines ~163-285)

    In the Phase 3.5 section of the diagram, add the Reviewer Approval Gate
    between "Determine reviewers" and "Parallel Review":

    ```
    Note over Main,Rev: Phase 3.5: Architecture Review
    Main->>Main: Determine mandatory + discretionary reviewers

    Note over User,Main: Reviewer Approval Gate
    Main->>User: Discretionary picks with rationale
    User->>Main: Approve / Adjust / Skip review

    alt Skip review
        Main->>Main: Skip to Execution Plan Approval Gate
    else Proceed with review
        par Parallel Review
            Main->>Rev: Task(review synthesized plan)
            Rev->>Main: Verdict (APPROVE / ADVISE / BLOCK)
        end
    ```

    Keep the existing BLOCK resolution loop and compaction checkpoint unchanged.

    ### D. Do NOT modify these sections

    - Phase 1 (Meta-Plan) -- already mentions Team Approval Gate, no changes needed
    - Phase 2 (Specialist Planning) -- unchanged
    - Phase 3 (Synthesis) -- unchanged
    - Phase 4 (Execution) -- unchanged
    - Phase 5-7 -- unchanged
    - Section 2 (Delegation Model) -- unchanged
    - Section 3 (Approval Gates) -- unchanged (the Reviewer Approval Gate follows
      the same pattern as the Team Approval Gate already documented there)

    ## Context

    - Read the final state of AGENT.md and SKILL.md (modified by Tasks 1-3) to
      ensure documentation matches implementation
    - The Mermaid diagram needs to show the new gate as a distinct step
    - software-docs-minion's role change from "full review" to "documentation
      impact checklist" should be reflected throughout

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` with:
    1. New ALWAYS/discretionary reviewer tables in Phase 3.5
    2. Reviewer Approval Gate description
    3. Updated Phase 8 checklist source description
    4. Updated Mermaid sequence diagram

    ## Success Criteria

    - Reviewer tables match the AGENT.md roster exactly
    - Reviewer Approval Gate is documented between reviewer identification and
      reviewer spawning
    - Phase 8 description mentions Phase 3.5 checklist handoff
    - Mermaid diagram shows the new gate
    - software-docs-minion described as documentation impact checklist, not full review
    - No unrelated sections modified

---

### Cross-Cutting Coverage

- **Testing**: Excluded. This task produces only documentation and specification changes (AGENT.md, SKILL.md, orchestration.md). No executable code, no configuration, no infrastructure. Phase 6 will find no new test targets.
- **Security**: Excluded. No attack surface changes, no auth changes, no user input handling, no new dependencies. The changes are to orchestration workflow documentation.
- **Usability -- Strategy**: Addressed in the plan design itself. The specialist contributions from ux-strategy-minion shaped the gate presentation format, "Skip review" semantics, visual weight hierarchy, and rationale grounding rules. These UX strategy decisions are embedded in the Task 2 prompt (the SKILL.md gate specification). No separate execution task needed.
- **Usability -- Design**: Excluded. No user-facing interfaces are produced. The "interfaces" here are text-based approval gates in a CLI, which are covered by ux-strategy-minion's contribution to the gate design.
- **Documentation**: Task 4 (software-docs-minion updates orchestration.md). Phase 8 documentation will also run post-execution if the documentation checklist has items.
- **Observability**: Excluded. No runtime components, no services, no APIs. Pure specification changes.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**:
    - ux-strategy-minion: Plan changes user-facing approval flow in Phase 3.5 (Task 2)
    - devx-minion contributed to planning but is not a Phase 3.5 reviewer
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

_Note: This plan modifies the Phase 3.5 reviewer roster itself. The Phase 3.5 review of THIS plan should use the CURRENT (pre-change) roster, not the proposed new roster. After this plan executes, future orchestrations will use the new roster._

### Conflict Resolutions

**1. Option 3 label: "Skip review" vs "Skip discretionary"**

devx-minion and ai-modeling-minion proposed "Skip discretionary" (run mandatory reviewers only). ux-strategy-minion proposed "Skip review" (skip Phase 3.5 entirely). Lucy did not weigh in on this specific choice.

**Resolution: "Skip review"** (ux-strategy-minion's recommendation). Rationale: "Skip discretionary" creates a half-measure -- mandatory reviewers still run, consuming compute and time, while the user's intent is likely "I want to move fast." If the user wants to skip, they should get the full benefit of skipping. The Execution Plan Approval Gate still provides a checkpoint. Additionally, "Skip review" correctly maps the control to the effect (Norman's mapping principle), while "Skip discretionary" requires the user to understand the mandatory/discretionary distinction to predict the outcome.

**2. software-docs-minion verdict capability: BLOCK allowed vs. never BLOCK**

devx-minion recommended software-docs-minion retain full APPROVE/ADVISE/BLOCK verdict capability. ux-strategy-minion recommended software-docs-minion should NOT use BLOCK for documentation concerns (only ADVISE). ai-modeling-minion aligned with ux-strategy-minion.

**Resolution: ADVISE as ceiling, BLOCK only in extreme cases.** The prompt instructs software-docs-minion to not BLOCK for documentation concerns -- gaps are addressed through the checklist in Phase 8. However, BLOCK is retained for the rare case where the plan fundamentally cannot be documented (contradictory outputs, no clear deliverables). This preserves safety while eliminating the common case of documentation-triggered revision loops.

**3. Gate header: "Review" vs "Reviewers"**

ux-strategy-minion proposed "Review" (different from Phase 2's "Team"). devx-minion and ai-modeling-minion proposed "Reviewers".

**Resolution: "Review"** (ux-strategy-minion's recommendation). The single-word shift "Team" -> "Review" signals different context without explanatory text. "Reviewers" is descriptive but feels like a subset of "Team" rather than a distinct gate type.

**4. Discretionary selection method: heuristic domain signals vs. hardcoded conditionals**

ai-modeling-minion recommended heuristic analysis with domain signal table. devx-minion recommended reusing the same trigger rule approach but lighter. ux-strategy-minion did not prescribe a specific method.

**Resolution: Domain signal table** (ai-modeling-minion's recommendation). The domain signal table provides heuristic anchors without rigid pattern matching. Nefario already performs this kind of contextual reasoning in Phase 1 (meta-plan). The forced yes/no enumeration with rationale prevents over-inclusion while being more robust than text pattern matching against task descriptions.

### Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Gate echo: two team-composition gates (Phase 2, Phase 3.5) train rubber-stamping | MEDIUM | Visual weight hierarchy (Phase 2: 8-12 lines, Phase 3.5: 6-10 lines, Execution: 25-40 lines). Different headers ("Team" vs "Review"). Compaction checkpoint between them creates temporal separation. Phase 3.5 gate auto-skips when 0 discretionary selected. |
| Checklist staleness: Phase 3.5 checklist diverges from execution reality | MEDIUM | Phase 8 merge logic unions 3.5 checklist with execution outcomes. Divergence flagging marks planned-but-not-implemented items. Outcome-action table preserved as supplementation source. |
| ux-strategy-minion demotion misses journey issues on backend plans | LOW | Accepted tradeoff per issue scope. Domain signal is broad: "user-facing workflow changes, journey modifications, or cognitive load implications." Most plans that affect user experience will trigger this. Pure infrastructure plans that genuinely have no UX impact do not need journey review. |
| user-docs-minion is new to Phase 3.5 (not a reclassification) | LOW | Flagged as new capability. Domain signal is clear: "output changes what end users see, do, or need to learn." Phase 8 already spawns user-docs-minion regardless of Phase 3.5 participation. |
| Fourth gate type risks approval fatigue (lucy) | MEDIUM | Gate is lightest in the sequence (6-10 lines). Auto-skip when 0 discretionary. "Skip review" provides one-click escape. Gate budget monitoring: if 3+ consecutive sessions have 0 "Adjust" interactions, consider converting to notification. |
| Referenced analysis file does not exist (lucy) | LOW | Plan does not depend on it. All decisions traceable to issue body and source files. |
| Two output files from software-docs-minion (devx-minion) | LOW | Verdict file follows standard pattern (verdict loop reads it normally). Checklist is secondary artifact consumed only by Phase 8. No verdict loop changes needed. |

### Execution Order

```
Batch 1: Task 1 (AGENT.md updates)
  [APPROVAL GATE]
Batch 2: Task 2 (SKILL.md Phase 3.5)
  [APPROVAL GATE]
Batch 3: Task 3 (SKILL.md Phase 8)
Batch 4: Task 4 (orchestration.md)
```

Task 1 gates because it defines the roster that all subsequent tasks depend on.
Task 2 gates because it defines the operational behavior (gate interaction, prompts) that Task 3 and Task 4 depend on.
Tasks 3 and 4 do not gate (easy to reverse, documentation-scope changes).

### Verification Steps

After all tasks complete:

1. **Roster consistency**: Verify the ALWAYS roster in AGENT.md, SKILL.md, and orchestration.md all list exactly: security-minion, test-minion, software-docs-minion, lucy, margo
2. **Discretionary pool consistency**: Verify all three files list exactly: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion
3. **Gate specification**: Verify SKILL.md has the Reviewer Approval Gate with AskUserQuestion (header: "Review", 3 options: Approve reviewers / Adjust reviewers / Skip review)
4. **software-docs-minion prompt**: Verify SKILL.md has the narrowed prompt producing phase3.5-docs-checklist.md
5. **Phase 8 merge**: Verify SKILL.md Phase 8 reads phase3.5-docs-checklist.md and supplements (not replaces) with execution outcomes
6. **Cross-cutting clarification**: Verify AGENT.md has the sentence distinguishing cross-cutting checklist from Phase 3.5 roster
7. **Mermaid diagram**: Verify orchestration.md diagram shows the Reviewer Approval Gate between reviewer identification and reviewer spawning
8. **No scope creep**: Verify no changes to the-plan.md, individual agent AGENT.md files, Phase 5/6 logic, or Phase 2 gate
