## Delegation Plan

**Team name**: team-gate-phase2
**Description**: Add user approval gate between Phase 1 (meta-plan) and Phase 2 (specialist dispatch) in the nefario orchestration workflow

### Conflict Resolutions

Three points of specialist disagreement were resolved:

**1. CONDENSE line timing (ux-strategy vs devx)**

ux-strategy-minion recommends moving the CONDENSE line to AFTER gate approval, arguing that compressing information then expanding it for the gate creates a jarring sequence. devx-minion recommends keeping the CONDENSE line BEFORE the gate, arguing its role shifts from "here's what we'll do" to "here's what we found."

**Resolution**: Keep CONDENSE line BEFORE the gate (devx-minion's position). Rationale: The CONDENSE line serves the Communication Protocol's context management function -- it fires when a phase completes, not when the user approves. Moving it after the gate would break the pattern established for all other CONDENSE lines (meta-plan result, review verdicts, post-execution start). The gate adds new information (the approval interaction) on top of the condensed summary. Append `(pending approval)` to distinguish from an approved state: `"Planning: consulting devx-minion, security-minion, ... (pending approval) | Skills: N discovered | Scratch: <path>"`

**2. Number of response options (ux-strategy: 3 vs devx: 4)**

ux-strategy-minion recommends 3 options (Approve / Adjust team / Reject). devx-minion recommends 4 (Approve / Modify team / Skip planning / Abandon).

**Resolution**: Use 3 options (ux-strategy-minion's position). Rationale: "Skip planning" (jump to MODE: PLAN behavior) is a mode switch, not a team selection response. Users who want MODE: PLAN should invoke `/nefario` with that mode explicitly. Embedding a mode escape hatch in the gate adds cognitive load to every invocation for a rare power-user scenario. Hick's Law applies: 3 options vs 4 meaningfully affects decision speed at a glance-and-confirm checkpoint.

**3. MODE: PLAN behavior (ux-strategy vs lucy)**

ux-strategy-minion says the team gate should still appear in MODE: PLAN (so users can upgrade to full mode). lucy says the gate is inapplicable in MODE: PLAN because there is no team selection.

**Resolution**: Skip the gate in MODE: PLAN (lucy's position). Rationale: MODE: PLAN explicitly bypasses specialist consultation. Showing a "here's who we would consult" gate and then not consulting them is confusing. If the user wants to see the team, they use META-PLAN mode. The gate exists to control specialist compute; MODE: PLAN already controls that by design.

### Task 1: Add Team Selection Gate to SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This is the core deliverable. The gate format, response handling, and CONDENSE timing define the user experience for all future orchestrations. Hard to reverse once established as a workflow pattern. All other tasks depend on it.
- **Prompt**: |
    You are implementing a team selection approval gate in the nefario
    orchestration skill.

    ## Task
    Modify `skills/nefario/SKILL.md` to add a user approval gate between
    Phase 1 (Meta-Plan) and Phase 2 (Specialist Planning). This gate lets
    the user see which specialists nefario selected, approve the team,
    adjust it, or reject the orchestration.

    ## What to Change

    ### Change 1: Replace the "no formal approval" text (around line 372-374)

    The current text reads:
    ```
    Nefario will return a meta-plan listing which specialists to consult
    and what to ask each one. Review it briefly -- if it looks reasonable,
    proceed to Phase 2. No need for formal user approval at this stage.
    ```

    Replace this entire paragraph with a new "Team Approval Gate" subsection.
    The gate must follow this specification:

    **Presentation format** (5-12 lines, compact):
    ```
    TEAM: <1-sentence task summary>
    Specialists: N selected | N considered, not selected

      SELECTED:
        devx-minion          Workflow integration, SKILL.md structure
        ux-strategy-minion   Approval gate interaction design
        lucy                 Governance alignment for new gate

      ALSO AVAILABLE (not selected):
        ai-modeling-minion, margo, software-docs-minion, security-minion, ...

    Full meta-plan: $SCRATCH_DIR/{slug}/phase1-metaplan.md
    ```

    Design notes for the format:
    - SELECTED block uses agent name + one-line rationale (why they were
      chosen, NOT the planning question). One line per agent.
    - ALSO AVAILABLE is a flat comma-separated list (not a table). Users
      scan it for surprises, not read each entry.
    - Full meta-plan link for deep-dive (planning questions, cross-cutting
      checklist, exclusion rationale).
    - Total output: 8-12 lines. Must be visibly lighter than the Execution
      Plan Approval Gate (which targets 25-40 lines).

    **Decision options** via AskUserQuestion:
    - `header`: "Team"
    - `question`: "<1-sentence task summary>"
    - `options` (3, `multiSelect: false`):
      1. label: "Approve team", description: "Consult these N specialists and proceed to planning." (recommended)
      2. label: "Adjust team", description: "Add or remove specialists before planning begins."
      3. label: "Reject", description: "Abandon this orchestration."

    **"Adjust team" response handling**:
    When the user selects "Adjust team":
    1. Present a freeform prompt: "Which specialists should be added or removed? Refer to agents by name or domain (e.g., 'add security-minion' or 'drop lucy'). Full agent roster: $SCRATCH_DIR/{slug}/phase1-metaplan.md"
    2. Nefario interprets the natural language request against the 27-agent roster.
    3. For added agents, nefario generates planning questions (lightweight inference, not a full re-plan).
    4. Re-present the gate with the updated team for confirmation.
    5. Cap at 2 adjustment rounds to prevent analysis paralysis.

    DO NOT use a multi-select UI for 27 agents. Natural language modification
    is the correct pattern here.

    **"Reject" response handling**:
    Abandon the orchestration. Clean up scratch directory. Print:
    "Orchestration abandoned. Scratch files removed."

    **MODE: PLAN exemption**:
    Add an explicit note that this gate does NOT apply in MODE: PLAN.
    MODE: PLAN bypasses specialist consultation entirely, so there is no
    team to approve. The gate applies only in META-PLAN mode (the default).

    **Second-round specialists exemption**:
    If Phase 2 specialists recommend additional agents (the "second round"
    at SKILL.md lines 440-442), those agents are spawned without re-gating.
    The user already approved the task scope and initial team; specialist-
    recommended additions are refinements within that scope.

    ### Change 2: Update the CONDENSE line (around line 158)

    The existing CONDENSE line:
    ```
    "Planning: consulting devx-minion, security-minion, ... | Skills: N discovered | Scratch: <actual resolved path>"
    ```

    Update to append `(pending approval)`:
    ```
    "Planning: consulting devx-minion, security-minion, ... (pending approval) | Skills: N discovered | Scratch: <actual resolved path>"
    ```

    Add a note that after gate approval, this CONDENSE line is already in
    context, so no second CONDENSE line is needed. The gate response itself
    serves as the confirmation marker.

    ### Change 3: Add to Communication Protocol SHOW list (around line 137)

    Add "Team approval gate (specialist list with rationale)" to the SHOW
    list, after the existing "Execution plan approval gate" entry.

    ## What NOT to Change

    - Phase 3.5 Architecture Review -- completely unaffected
    - Execution Plan Approval Gate -- format, options, and behavior unchanged
    - Phase 2 specialist spawning logic -- only a gate is added before it
    - The meta-plan prompt or output format -- the gate consumes existing output
    - nefario/AGENT.md -- out of scope per task statement
    - Any other AGENT.md files

    ## Context

    Read these files to understand the current structure:
    - `skills/nefario/SKILL.md` -- the file you are modifying
    - `$SCRATCH_DIR/{slug}/phase2-ux-strategy-minion.md` -- UX design for the gate
    - `$SCRATCH_DIR/{slug}/phase2-devx-minion.md` -- workflow integration analysis
    - `$SCRATCH_DIR/{slug}/phase2-lucy.md` -- governance alignment analysis

    ## Key Constraints

    - Gate output MUST be 5-12 lines (categorically lighter than the execution plan gate)
    - "Approve team" MUST be the recommended default
    - "Adjust team" uses freeform follow-up, NOT structured multi-select
    - Cap adjustment rounds at 2
    - Gate is mandatory by default, user-skippable (consistent with all other gates)
    - Do NOT add a "Skip planning" option (MODE: PLAN is the explicit path for that)
    - CONDENSE line fires BEFORE the gate with `(pending approval)` marker

    ## Deliverables
    - Updated `skills/nefario/SKILL.md` with all three changes above

    ## Success Criteria
    - The gate section is self-contained and follows the same structural patterns as the Execution Plan Approval Gate section
    - Reading the SKILL.md top-to-bottom, the flow is: Phase 1 returns -> CONDENSE -> Team Approval Gate -> Phase 2 begins
    - MODE: PLAN exemption is explicitly stated
    - Communication Protocol SHOW list includes the new gate

    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead with:
    - File paths with change scope and line counts (e.g., "skills/nefario/SKILL.md (new team gate section, +N lines)")
    - 1-2 sentence summary of what was produced
    This information populates the gate's DELIVERABLE section.
- **Deliverables**: Updated `skills/nefario/SKILL.md` with team approval gate section, CONDENSE line update, and Communication Protocol SHOW list addition
- **Success criteria**: Gate section follows existing patterns; flow reads naturally top-to-bottom; MODE: PLAN exemption stated; SHOW list updated

### Task 2: Update docs/orchestration.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating the orchestration architecture documentation to reflect
    a new team approval gate added between Phase 1 and Phase 2.

    ## Task
    Update `docs/orchestration.md` to document the new Team Approval Gate.

    ## What to Change

    ### Change 1: Update Phase 1 description (Section 1, around line 24)

    The current text reads:
    ```
    The meta-plan is informational. No user approval is required before proceeding to Phase 2.
    ```

    Replace with text describing that the meta-plan output is presented to
    the user via a Team Approval Gate before Phase 2 proceeds. The user sees
    the selected specialists with rationale and can approve, adjust the team,
    or reject the orchestration.

    ### Change 2: Add Team Approval Gate subsection (Section 3, before "Execution Plan Approval Gate")

    Add a new subsection "### Team Approval Gate" between the intro paragraph
    of Section 3 (around line 336) and the "### Execution Plan Approval Gate"
    subsection (around line 344). The section types now become:

    1. Team Approval Gate -- occurs once, after Phase 1, before Phase 2
    2. Execution Plan Approval Gate -- occurs once, after Phase 3.5, before Phase 4
    3. Mid-execution gates -- occur during Phase 4

    Update the intro paragraph to reflect three gate types (currently says "two types").

    The Team Approval Gate subsection should document:
    - **When it occurs**: After Phase 1 (Meta-Plan), before Phase 2 (Specialist Planning)
    - **Purpose**: Visibility into team selection; prevents wasted compute on irrelevant specialists
    - **Format**: Compact presentation (5-12 lines) with SELECTED agents (name + rationale), ALSO AVAILABLE list, and meta-plan link
    - **Response options**: Approve team (recommended) / Adjust team / Reject
    - **Adjust team workflow**: Freeform natural language, capped at 2 rounds
    - **MODE: PLAN exemption**: Gate does not apply in MODE: PLAN (no specialists selected)
    - **Anti-fatigue**: Gate is categorically lighter than execution plan gate; does not count toward calibration counter

    ### Change 3: Update Mermaid diagram (around line 164)

    Add a Team Approval Gate interaction between Phase 1 and Phase 2:
    ```mermaid
        Note over Main,User: Team Approval Gate
        Main->>User: Team composition (specialists + rationale)
        User->>Main: Approve / Adjust / Reject
    ```

    Insert this after the Phase 1 meta-plan return and before the Phase 2
    parallel consultation block.

    ## What NOT to Change

    - Phase 3.5 Architecture Review section
    - Execution Plan Approval Gate section (format, options, behavior unchanged)
    - Mid-execution gates section
    - Any other section of the document

    ## Context

    Read these files:
    - `docs/orchestration.md` -- the file you are modifying
    - `skills/nefario/SKILL.md` -- read the new Team Approval Gate section
      (added by Task 1) to ensure documentation accurately reflects the implementation

    ## Deliverables
    - Updated `docs/orchestration.md` with Phase 1 description change, new Team Approval Gate subsection, and Mermaid diagram update

    ## Success Criteria
    - The three gate types (team, plan, mid-execution) are clearly distinguished
    - The Mermaid diagram shows the user interaction between Phase 1 and Phase 2
    - Documentation matches the SKILL.md implementation

    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead with:
    - File paths with change scope and line counts
    - 1-2 sentence summary of what was produced

### Task 3: Update docs/using-nefario.md
- **Agent**: user-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating the user-facing guide for nefario to reflect a new
    team approval gate.

    ## Task
    Update `docs/using-nefario.md` to describe the new team confirmation
    step in the user's journey.

    ## What to Change

    ### Change 1: Update Phase 1 description (around line 102)

    The current text reads:
    ```
    **Phase 1 -- Meta-Planning.** Nefario reads your codebase and figures out
    which specialists to consult. You see the list of specialists and what
    each will be asked. No action needed from you -- this is informational.
    ```

    Replace with text that describes the new user interaction:
    After nefario identifies the specialists, you see the team with a brief
    rationale for each selection. You approve the team, adjust it (add or
    remove specialists), or reject the orchestration. This is a quick
    confirmation -- typically a one-click approve.

    ### Change 2: Update Phase 2 description (around line 104)

    The current text starts with "Specialists are consulted in parallel..."
    Add a note that the specialists were confirmed by the user in the
    preceding step.

    ## What NOT to Change

    - Any other phase descriptions
    - The "Tips for Success" section
    - The "Working with Project Skills" section
    - Anything else in the document

    ## Tone and Style

    This is a user-facing guide. Write for a developer who has never used
    nefario before. Keep it conversational and practical. Do not use
    internal terminology like "AskUserQuestion" or "CONDENSE line."

    ## Context

    Read these files:
    - `docs/using-nefario.md` -- the file you are modifying
    - `skills/nefario/SKILL.md` -- read the new Team Approval Gate section
      to understand what the user actually experiences

    ## Deliverables
    - Updated `docs/using-nefario.md` with revised Phase 1 and Phase 2 descriptions

    ## Success Criteria
    - A new user reading the guide understands they will be asked to confirm
      the team before specialist planning begins
    - The description makes it clear this is a quick interaction, not a detailed review

    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead with:
    - File paths with change scope and line counts
    - 1-2 sentence summary of what was produced

### Cross-Cutting Coverage

| Dimension | Coverage | Justification |
|-----------|----------|---------------|
| Testing | Not included | No executable code produced. Changes are to markdown documentation files (SKILL.md, orchestration.md, using-nefario.md). No tests to write or run. |
| Security | Not included | No attack surface created. No auth, user input processing, secrets, or infrastructure changes. The gate is a prompt-level workflow checkpoint. |
| Usability -- Strategy | Covered | ux-strategy-minion contributed to planning (Phase 2). Gate design incorporates their recommendations on cognitive weight, progressive disclosure, and anti-fatigue. |
| Usability -- Design | Not included | No user-facing interface produced. The gate is a text-based CLI interaction using existing AskUserQuestion patterns. |
| Documentation | Covered | Tasks 2 and 3 update orchestration.md and using-nefario.md respectively. |
| Observability | Not included | No runtime components produced. This is a workflow documentation change. |

### Architecture Review Agents
- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no user-facing UI, no web-facing components)

### Risks and Mitigations

1. **Approval fatigue from two pre-execution gates** (raised by all three specialists). The user now has: Team gate -> Plan gate -> Mid-execution gates. Risk of rubber-stamping.
   - Mitigation: Team gate is categorically lighter (5-12 lines vs 25-40). Three options vs four. Default is "Approve team" (one click). Does NOT increment the calibration counter. Target: under 10 seconds for the common approve path.

2. **Adjust team generating planning questions for new agents** (raised by ux-strategy-minion). When the user adds a specialist, nefario must generate a planning question. If this requires spawning nefario again, the adjustment flow feels sluggish.
   - Mitigation: Nefario generates questions locally from task context and agent domain knowledge. No subagent spawn for a single planning question.

3. **AGENT.md scope boundary** (raised by lucy). If the meta-plan output format needs changes to support the gate, nefario/AGENT.md may need updates, but the task scope excludes AGENT.md changes.
   - Mitigation: The gate consumes the existing meta-plan output format without changes. The SKILL.md calling session extracts agent names and planning questions from the current format. No AGENT.md modifications needed.

4. **Communication Protocol gap** (raised by ux-strategy-minion). The gate must be in the SHOW list, or the orchestrator might suppress it following "never show phase transition announcements."
   - Mitigation: Task 1 explicitly adds the gate to the SHOW list in the Communication Protocol.

### Execution Order

```
Batch 1 (parallel: none, sequential):
  Task 1: SKILL.md team approval gate [devx-minion, sonnet]
  >>> APPROVAL GATE: Task 1 deliverable <<<

Batch 2 (parallel):
  Task 2: orchestration.md update [software-docs-minion, sonnet]
  Task 3: using-nefario.md update [user-docs-minion, sonnet]
```

### Verification Steps

1. Read the complete `skills/nefario/SKILL.md` after Task 1 and verify:
   - Flow reads: Phase 1 -> CONDENSE with `(pending approval)` -> Team Approval Gate -> Phase 2
   - Team gate section uses AskUserQuestion with 3 options
   - MODE: PLAN exemption is explicitly stated
   - SHOW list includes the team gate
   - Phase 3.5 is completely unchanged

2. Read `docs/orchestration.md` after Task 2 and verify:
   - Section 3 now describes three gate types (team, plan, mid-execution)
   - New Team Approval Gate subsection is present with correct content
   - Mermaid diagram includes user interaction between Phase 1 and Phase 2
   - Phase 3.5 section is unchanged

3. Read `docs/using-nefario.md` after Task 3 and verify:
   - Phase 1 description mentions team confirmation
   - Phase 2 description notes specialists were user-confirmed
   - Tone remains user-friendly and conversational
