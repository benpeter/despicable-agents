## Delegation Plan

**Team name**: gate-transparency
**Description**: Surface decision rationale at all four nefario gate types (Team, Reviewer, Execution Plan, Mid-execution)

### Task 1: Enrich AGENT.md upstream data formats
- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are modifying `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md` to enrich four upstream data formats that feed gate rendering in SKILL.md. These are additive changes to output templates -- no existing behavior is removed.

    Make exactly these four edits:

    ---

    **Edit 1: Add Notable Exclusions to meta-plan output template**

    In the meta-plan output template (MODE: META-PLAN section), find this text:

    ```
    <!-- @domain:meta-plan-checklist END -->

    ### Anticipated Approval Gates
    ```

    Replace with:

    ```
    <!-- @domain:meta-plan-checklist END -->

    ### Notable Exclusions
    <2-3 agents whose exclusion from planning is most likely to surprise the user,
    with a one-line reason each. Choose agents whose domain is adjacent to the task
    but who were excluded for a specific reason. Skip agents with no plausible
    connection to the task. Maximum 3 entries.>

    - <agent-name>: <one-line exclusion reason>
    - <agent-name>: <one-line exclusion reason>

    ### Anticipated Approval Gates
    ```

    This provides the SKILL.md Team gate with a machine-excerptable list of notable exclusions. The cross-cutting checklist remains the authoritative source; Notable Exclusions is a curated derivative.

    ---

    **Edit 2: Rename Conflict Resolutions to Decisions with structured format**

    In the synthesis output template (MODE: SYNTHESIS section), find this text:

    ```
    ### Conflict Resolutions
    <any disagreements between specialists and how you resolved them>
    ```

    Replace with:

    ```
    ### Decisions
    <non-trivial choices made during synthesis: conflicts between specialists,
    trade-offs between approaches, scope decisions. Use Chosen/Over/Why format.
    Include only decisions where a real alternative was considered and rejected.
    Do not fabricate alternatives -- if a decision was uncontested, it does not
    belong here. Maximum 5 entries.>

    - **<topic>**
      Chosen: <the approach selected>
      Over: <the rejected alternative(s), with attribution when clear>
      Why: <rationale for this choice over the alternative>
    ```

    ---

    **Edit 3: Add Gate rationale field to synthesis task template**

    In the synthesis task template (MODE: SYNTHESIS section), find this text:

    ```
    - **Gate reason**: <why this deliverable needs user review before proceeding>
    - **Prompt**: |
    ```

    Replace with:

    ```
    - **Gate reason**: <why this deliverable needs user review before proceeding>
    - **Gate rationale** (gated tasks only): |
        Chosen: <the approach this task will implement>
        Over: <1-2 alternatives considered during synthesis>
        Why: <why this approach was selected>
    - **Prompt**: |
    ```

    The Gate rationale field provides pre-execution rationale as a fallback when agents do not report execution-time reasoning. It uses the same Chosen/Over/Why micro-format as the Decisions section. The "(gated tasks only)" annotation means it is omitted entirely for non-gated tasks.

    ---

    **Edit 4: Enrich Architecture Review Agents section**

    In the synthesis output template, find this text:

    ```
    ### Architecture Review Agents
    <!-- @domain:synthesis-review-agents BEGIN -->
    - **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
    - **Discretionary picks**: <for each discretionary reviewer selected, list: reviewer name + one-line rationale grounded in specific plan content; reference task numbers>
    - **Not selected**: <remaining discretionary pool members not selected, comma-separated>
    <!-- @domain:synthesis-review-agents END -->
    ```

    Replace with:

    ```
    ### Architecture Review Agents
    <!-- @domain:synthesis-review-agents BEGIN -->
    - **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
    - **Discretionary picks**:
      - <reviewer-name>: <selection rationale referencing task numbers>
        Review focus: <what specifically this reviewer will examine>
      - ...
    - **Not selected**:
      - <reviewer-name>: <exclusion rationale referencing specific plan content>
      - ...
    <!-- @domain:synthesis-review-agents END -->
    ```

    Discretionary picks become a bullet list with a Review focus sub-line per entry. Not selected becomes a bullet list with per-member exclusion rationale (the discretionary pool is only 5 agents, so showing all with rationale is feasible).

    ---

    **Edit 5: Add decision transparency anchor to Decision Brief Format section**

    Find the line that reads:

    ```
    Target 12-18 lines for mid-execution gates (soft ceiling; clarity wins over brevity).

    Field definitions:
    ```

    Replace with:

    ```
    Target 12-18 lines for mid-execution gates (soft ceiling; clarity wins over brevity).

    All four gate types (Team, Reviewer, Execution Plan, Mid-execution) follow this
    progressive-disclosure pattern, at density proportional to each gate's decision
    scope. SKILL.md defines per-gate formats. The principle is consistent: every gate
    surfaces what was decided, what was rejected, and why.

    Field definitions:
    ```

    ---

    **What NOT to do:**
    - Do not modify any other sections of AGENT.md
    - Do not change compaction focus strings (analysis confirmed they do not need changes)
    - Do not rename or restructure existing sections beyond what is specified above
    - Do not modify the Decision Brief Format template itself (the code block with APPROVAL GATE)
    - Do not touch the advisory output format
- **Deliverables**: Modified `nefario/AGENT.md` with 5 targeted edits
- **Success criteria**: All five edits applied cleanly; no other sections modified; the Notable Exclusions subsection appears between Cross-Cutting Checklist and Anticipated Approval Gates; the Decisions section uses Chosen/Over/Why format; the Gate rationale field appears between Gate reason and Prompt; the Architecture Review Agents section uses bullet lists with Review focus and exclusion rationale; the decision transparency anchor appears after the line budget guidance

### Task 2: Enrich SKILL.md gate rendering formats
- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are modifying `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md` to enrich gate rendering at all four gate types, consuming the enriched upstream data formats from AGENT.md.

    Make exactly these edits:

    ---

    **Edit 1: Add Decision Transparency preamble before Team Approval Gate**

    Find the line:

    ```
    ### Team Approval Gate
    ```

    Insert BEFORE it (so the new section appears immediately before the Team gate):

    ```
    ### Decision Transparency at Gates

    Every gate must pass the self-containment test: a user who reads ONLY the gate
    output -- never clicks Details -- can make a well-informed approve/adjust/reject
    decision.

    To achieve this, gates surface decision rationale using a consistent
    micro-format. For synthesis decisions and mid-execution approaches:

        <Decision title>
          Chosen: <what was selected>
          Over: <what was rejected>
          Why: <rationale>

    For team and reviewer exclusions, a one-liner suffices:

        <agent-name>         <exclusion rationale>

    Density scales with decision scope: the Team gate is lighter than the Execution
    Plan gate. Each gate section below defines its own format and line budget.
    Attribution in "Over" lines is best-effort -- include when the synthesis clearly
    records the source; omit when uncertain; never fabricate.

    ```

    ---

    **Edit 2: Enrich Team gate with NOT SELECTED (notable) block**

    In the Team Approval Gate section, find the presentation format example:

    ```
      `ALSO AVAILABLE (not selected):`
        ai-modeling-minion, margo, software-docs-minion, security-minion, ...
    ```

    Replace with:

    ```
      `NOT SELECTED (notable):`
        margo                Will review in Phase 3.5 (mandatory reviewer)
        security-minion      No new attack surface; gate changes are prompt-only
        test-minion          No executable output; will review in Phase 3.5

      Also available: ai-modeling-minion, software-docs-minion, ...
    ```

    Then find the format rules block that contains:

    ```
    - ALSO AVAILABLE: flat comma-separated list. Users scan it for surprises,
      not read each entry. Include all 27-roster agents not in SELECTED.
    - Full meta-plan link for deep-dive (planning questions, cross-cutting
      checklist, exclusion rationale).
    - Total output: 8-12 lines. Must be visibly lighter than the Execution
      Plan Approval Gate (which targets 25-40 lines).
    ```

    Replace with:

    ```
    - NOT SELECTED (notable): up to 3 agents whose exclusion might surprise the
      user (governance agents for governance-adjacent tasks, security-minion for
      security-adjacent tasks, etc.). One line per agent with exclusion rationale,
      same alignment as SELECTED entries. Sourced from the meta-plan's Notable
      Exclusions subsection.
    - "Also available" remainder: flat comma list of all remaining roster agents.
      Lowercase "Also" distinguishes it from labeled blocks.
    - If no exclusions are notable (task is clearly single-domain), omit the
      NOT SELECTED (notable) block entirely. Keep only "Also available."
    - Full meta-plan link for deep-dive (planning questions, cross-cutting
      checklist, exclusion rationale).
    - Total output: 10-16 lines. Must be visibly lighter than the Execution
      Plan Approval Gate (which targets 35-55 lines).
    ```

    ---

    **Edit 3: Enrich Reviewer gate with per-member rationale**

    In the Reviewer Approval Gate section, find the presentation format example:

    ```
      `NOT SELECTED from pool:`
        <remaining pool members, comma-separated>
    ```

    Replace with:

    ```
      `NOT SELECTED:`
        <reviewer-name>      <exclusion rationale, max 60 chars>
        <reviewer-name>      <exclusion rationale, max 60 chars>
        <reviewer-name>      <exclusion rationale, max 60 chars>
    ```

    Also find the DISCRETIONARY block line in the same example:

    ```
      `DISCRETIONARY (nefario recommends):`
        <agent-name>       <rationale, max 60 chars, reference tasks>
        <agent-name>       <rationale, max 60 chars, reference tasks>
    ```

    Replace with:

    ```
      `DISCRETIONARY (nefario recommends):`
        <agent-name>       <rationale, max 60 chars, reference tasks>
          Review focus: <what specifically this reviewer will examine>
        <agent-name>       <rationale, max 60 chars, reference tasks>
          Review focus: <what specifically this reviewer will examine>
    ```

    Then find the format rules:

    ```
    - NOT SELECTED: flat comma-separated list of remaining discretionary pool members.
    - No "ALSO AVAILABLE" block listing the full agent roster. The decision space is
      the 5-member discretionary pool only.
    ```

    Replace with:

    ```
    - NOT SELECTED: per-member exclusion rationale for each unselected pool member.
      One line per agent with rationale, same alignment as DISCRETIONARY entries.
      The discretionary pool is only 5 agents, so showing all with rationale is
      feasible and eliminates "why wasn't X included?" questions.
    - DISCRETIONARY entries include a "Review focus:" sub-line stating what
      specifically the reviewer will examine (derived from plan content, not the
      reviewer's generic capability).
    - No "ALSO AVAILABLE" block listing the full agent roster. The decision space is
      the 5-member discretionary pool only.
    ```

    Also find the line budget:

    ```
    **Presentation format** (target 6-10 lines):
    ```

    Replace with:

    ```
    **Presentation format** (target 7-13 lines):
    ```

    ---

    **Edit 4: Rename CONFLICTS RESOLVED to DECISIONS in Execution Plan gate**

    In the Execution Plan Approval Gate section, find:

    ```
    `CONFLICTS RESOLVED:`
      - <what was contested>: Resolved in favor of <approach> because <rationale>
    ```

    Replace with:

    ```
    `DECISIONS:`
      <Decision title>
        Chosen: <what was selected>
        Over: <what was rejected> (<agent attribution, best-effort>)
        Why: <one sentence of rationale>

      <Decision title>
        Chosen: ...
        Over: ...
        Why: ...

      ... and N more in [plan]($SCRATCH_DIR/{slug}/phase3-synthesis.md)
    ```

    After the `Omit if no conflicts.` line that follows the old CONFLICTS RESOLVED block, find:

    ```
    Omit if no conflicts. If no risks, note: "No risks identified by specialists."
    ```

    Replace with:

    ```
    DECISIONS format rules:
    - Maximum 5 decisions shown inline. If more than 5 synthesis decisions exist,
      show the 5 with highest user impact (scope changes, security trade-offs,
      architecture choices over implementation details).
    - Beyond 5: add overflow line "... and N more in [plan](link)".
      Do not summarize overflowed decisions -- the link is the escape hatch.
    - If 0 decisions exist (no conflicts, no trade-offs), omit the DECISIONS block
      entirely. Do not show an empty block or "No decisions."
    - Attribution in "Over" lines is best-effort. Include when the synthesis clearly
      records which agent proposed the rejected alternative. Omit when uncertain.
      Never fabricate attribution.
    - One blank line between decision entries for scannability.
    Omit DECISIONS block if no decisions. If no risks, note: "No risks identified by specialists."
    ```

    Also update the line budget. Find:

    ```
    **Line budget guidance**: Target 25-40 lines for the complete gate output
    ```

    Replace with:

    ```
    **Line budget guidance**: Target 35-55 lines for the complete gate output
    ```

    ---

    **Edit 5: Add good/bad RATIONALE examples and enrich completion instruction for mid-execution gates**

    In Phase 4 section 5 ("At approval gates"), after the line:

    ```
    Target 12-18 lines for mid-execution gates (soft ceiling; clarity wins over brevity).
    ```

    Insert the following example block:

    ```

    Good RATIONALE (exposes reasoning and rejected alternatives):
    - PKCE chosen for public client security (no client secret storage needed)
    - Token refresh uses sliding window -- minimizes re-auth without unbounded sessions
    - Rejected: Implicit grant flow -- deprecated in OAuth 2.1, no refresh token support
    - Rejected: Client credentials grant -- requires secret storage, unsuitable for CLI

    Bad RATIONALE -- restates the decision (no new information):
    - Implemented the OAuth flow
    - Used best practices for token management
    - Followed the task requirements

    Bad RATIONALE -- appeals to convention (no task-specific reasoning):
    - Used the standard approach for this type of problem
    - Followed the pattern from the existing codebase
    - Applied the recommended security configuration

    When populating the RATIONALE section at a mid-execution gate: if the agent
    reported execution-time rationale (approach chosen and alternatives rejected),
    use that as the primary RATIONALE. If the agent did NOT report rationale, fall
    back to the Gate rationale field from the synthesis (pre-execution reasoning).
    The gate should show substantive reasoning, never be empty.

    ```

    Then find the agent completion instruction in Phase 4 section 3 ("Spawn teammates"):

    ```
       > When you finish your task, mark it completed with TaskUpdate and
       > send a message to the team lead with:
       > - File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
       > - 1-2 sentence summary of what was produced
       > This information populates the gate's DELIVERABLE section.
    ```

    Replace with:

    ```
       > When you finish your task, mark it completed with TaskUpdate and
       > send a message to the team lead with:
       > - File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
       > - 1-2 sentence summary of what was produced
       > - If this task has an approval gate: the approach you chose, what
       >   alternative(s) you considered but rejected, and a brief reason
       >   for each rejection
       > This information populates the gate's DELIVERABLE and RATIONALE sections.
    ```

    ---

    **What NOT to do:**
    - Do not modify compaction focus strings (analysis confirmed they survive without changes)
    - Do not restructure the mid-execution gate template itself (the APPROVAL GATE code block)
    - Do not modify advisory format (advisories use CHANGE/WHY, not Chosen/Over/Why)
    - Do not modify AskUserQuestion structures
    - Do not change any Phase 4 execution logic beyond what is specified
- **Deliverables**: Modified `skills/nefario/SKILL.md` with 5 targeted edits
- **Success criteria**: Decision Transparency preamble appears before Team gate; Team gate uses NOT SELECTED (notable) with Also available remainder; Reviewer gate has per-member exclusion rationale and Review focus sub-lines; Execution Plan gate uses DECISIONS with Chosen/Over/Why; Mid-execution gate has good/bad examples and fallback logic; completion instruction includes rationale reporting for gated tasks

### Task 3: Update TEMPLATE.md gate capture
- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 2
- **Approval gate**: no
- **Prompt**: |
    You are modifying `/Users/ben/github/benpeter/despicable-agents/docs/history/nefario-reports/TEMPLATE.md` to align the report template with the enriched gate formats.

    Make exactly these edits:

    ---

    **Edit 1: Rename Conflict Resolutions to Decisions in Key Design Decisions section**

    Find this text in the skeleton:

    ```
    ### Conflict Resolutions

    {Description of conflicts between specialist recommendations and how they were resolved. "None." if no conflicts arose.}
    ```

    Replace with:

    ```
    ### Decisions

    {Non-trivial choices made during synthesis. Use Chosen/Over/Why format for
    each entry. Include only decisions where a real alternative was considered
    and rejected. "None." if no contested decisions arose.}

    - **{topic}**
      Chosen: {the approach selected}
      Over: {the rejected alternative(s), with attribution when clear}
      Why: {rationale for this choice over the alternative}
    ```

    ---

    **Edit 2: Broaden Approval Gates table to capture all gate types**

    Find the Approval Gates section in the Execution section of the skeleton:

    ```
    ### Approval Gates

    | Gate Title | Agent | Confidence | Outcome | Rounds |
    |------------|-------|------------|---------|--------|
    | {gate title} | {agent} | {HIGH/MEDIUM/LOW} | {approved/rejected} | {N} |

    #### {Gate Title}

    **Decision**: {What was decided.}
    **Rationale**: {Why this decision was made.}
    **Rejected**: {Alternatives considered and why rejected.}
    ```

    Replace with:

    ```
    ### Approval Gates

    | Gate | Type | Outcome | Notes |
    |------|------|---------|-------|
    | {gate title} | {Team/Reviewer/Plan/Mid-execution} | {approved/adjusted/skipped} | {one-line summary or "routine"} |

    For adjusted or contested gates, add an H4 brief:

    #### {Gate Title}

    **Decision**: {What was decided.}
    **Rationale**: {Why this decision was made.}
    **Rejected**: {Alternatives considered and why rejected.}

    Routine approvals (approve as-is, no changes) get a table row only -- no H4
    brief. Only gates where the user adjusted, requested changes, or rejected
    warrant the full brief.
    ```

    ---

    **Edit 3: Update Formatting Rules for Conflict Resolutions reference**

    Find this line in the Formatting Rules section:

    ```
    - **Conflict Resolutions**: Always present as H3 under Key Design Decisions.
      Write "None." if no conflicts arose.
    ```

    Replace with:

    ```
    - **Decisions**: Always present as H3 under Key Design Decisions. Use
      Chosen/Over/Why format. Write "None." if no contested decisions arose.
    ```

    ---

    **Edit 4: Update Report Writing Checklist step 8**

    Find this line in the Report Writing Checklist:

    ```
    8. Write Key Design Decisions (H4 per decision, with Conflict Resolutions H3 subsection)
    ```

    Replace with:

    ```
    8. Write Key Design Decisions (H4 per decision, with Decisions H3 subsection using Chosen/Over/Why format)
    ```

    ---

    **Edit 5: Update Report Writing Checklist step 11**

    Find this line in the Report Writing Checklist:

    ```
    11. Write Execution (Tasks table + Files Changed table + Approval Gates table with per-gate H4 briefs)
    ```

    Replace with:

    ```
    11. Write Execution (Tasks table + Files Changed table + Approval Gates table; H4 briefs only for adjusted/contested gates)
    ```

    ---

    **What NOT to do:**
    - Do not bump the template version number (the changes are additive, not breaking)
    - Do not modify conditional section rules
    - Do not change the Decisions section under ## Decisions (that section captures mid-execution gate decisions, separate from the Key Design Decisions section)
    - Do not modify frontmatter field definitions
    - Do not change the collapsibility rules
- **Deliverables**: Modified `docs/history/nefario-reports/TEMPLATE.md` with 5 targeted edits
- **Success criteria**: Conflict Resolutions renamed to Decisions with Chosen/Over/Why format in skeleton; Approval Gates table broadened with Type column; formatting rules and checklist references updated

### Task 4: Update docs/orchestration.md gate documentation
- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 2
- **Approval gate**: no
- **Prompt**: |
    You are modifying `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md` to document the enriched gate formats. This is developer documentation that describes the orchestration architecture.

    Make exactly these edits:

    ---

    **Edit 1: Elevate Reviewer gate and add gate philosophy preamble**

    Find the opening of Section 3:

    ```
    ## 3. Approval Gates

    Approval gates pause execution to get user input before downstream work proceeds. The mechanism is designed to gate high-impact decisions without creating approval fatigue.

    Three types of gates exist with distinct semantics:
    ```

    Replace with:

    ```
    ## 3. Approval Gates

    Approval gates pause execution to get user input before downstream work proceeds. The mechanism is designed to gate high-impact decisions without creating approval fatigue.

    **Decision transparency principle**: Every gate surfaces what was decided, what was rejected, and why -- at density proportional to the gate's decision scope. Gates use a consistent Chosen/Over/Why micro-format for synthesis decisions and mid-execution approaches, and one-liner rationales for team and reviewer composition. The goal is self-containment: a user who reads only the gate output can make a well-informed approve/adjust/reject decision without opening scratch files.

    Four types of gates exist with distinct semantics:
    ```

    ---

    **Edit 2: Update Team Approval Gate format description**

    Find the Team gate format description:

    ```
    **Format**: Compact presentation targeting 8-12 lines:

    - **SELECTED block** -- Each selected agent on its own line with a one-line rationale explaining why it was chosen (not the planning question). Left-aligned for scannability.
    - **ALSO AVAILABLE list** -- Flat comma-separated list of all roster agents not selected. Users scan for surprises, not read each entry.
    - **Meta-plan link** -- Path to the full meta-plan scratch file for deep-dive into planning questions, cross-cutting checklist, and exclusion rationale.

    The total output must be visibly lighter than the Execution Plan Approval Gate (which targets 25-40 lines).
    ```

    Replace with:

    ```
    **Format**: Compact presentation targeting 10-16 lines:

    - **SELECTED block** -- Each selected agent on its own line with a one-line rationale explaining why it was chosen (not the planning question). Left-aligned for scannability.
    - **NOT SELECTED (notable) block** -- Up to 3 agents whose exclusion might surprise the user, with one-line exclusion rationale. Sourced from the meta-plan's Notable Exclusions subsection. Omitted when no exclusions are notable.
    - **Also available remainder** -- Flat comma-separated list of all remaining roster agents not in SELECTED or NOT SELECTED (notable).
    - **Meta-plan link** -- Path to the full meta-plan scratch file for deep-dive into planning questions, cross-cutting checklist, and full exclusion rationale.

    The total output must be visibly lighter than the Execution Plan Approval Gate (which targets 35-55 lines).
    ```

    ---

    **Edit 3: Add Reviewer Approval Gate subsection**

    Find the line:

    ```
    ### Execution Plan Approval Gate
    ```

    Insert BEFORE it:

    ```
    ### Reviewer Approval Gate

    The reviewer approval gate occurs after nefario identifies architecture reviewers and before those reviewers are spawned. It gives the user visibility into which discretionary reviewers were selected (and why others were not).

    **When it occurs**: After Phase 3 (Synthesis) / start of Phase 3.5 (Architecture Review), before reviewers are spawned.

    **Format**: Compact presentation targeting 7-13 lines:

    - **Mandatory line** -- Flat comma-separated list of the 5 mandatory reviewers, presented as fact not choice.
    - **DISCRETIONARY block** -- Each selected discretionary reviewer with plan-grounded rationale and a "Review focus" sub-line stating what specifically they will examine.
    - **NOT SELECTED block** -- Per-member exclusion rationale for each unselected discretionary pool member. The pool is only 5 agents, so showing all with rationale is feasible.
    - **Plan link** -- Path to the synthesis scratch file.

    **Response options**: Three choices:

    1. **Approve reviewers** (recommended) -- Spawn mandatory + approved discretionary reviewers.
    2. **Adjust reviewers** -- Add or remove discretionary reviewers. Constrained to the 5-member pool. Capped at 2 adjustment rounds.
    3. **Skip review** -- Skip architecture review entirely. The Execution Plan Approval Gate still applies.

    Auto-approved (gate skipped) when no discretionary reviewers are selected.

    ```

    ---

    **Edit 4: Update Execution Plan gate format description**

    Find this line in the Execution Plan Approval Gate section:

    ```
    - **Risks and conflict resolutions** -- Identified risks with mitigations, contested decisions with rationales (omitted if none)
    ```

    Replace with:

    ```
    - **Decisions** -- Non-trivial synthesis choices using Chosen/Over/Why format (what was selected, what was rejected with attribution, why). Maximum 5 inline; overflow linked to scratch file. Omitted if no contested decisions.
    - **Risks** -- Identified risks with mitigations (omitted if none)
    ```

    Also find:

    ```
    **Line budget**: Target 25-40 lines for the complete gate output. Soft guidance -- clarity wins over brevity.
    ```

    Replace with:

    ```
    **Line budget**: Target 35-55 lines for the complete gate output. Soft guidance -- clarity wins over brevity.
    ```

    ---

    **Edit 5: Add decision transparency to mid-execution gate documentation**

    Find this text in the Decision Brief Format subsection:

    ```
    **Layer 2 (30-second read)**: Rationale with rejected alternatives explicitly prefixed.
    ```

    Replace with:

    ```
    **Layer 2 (30-second read)**: Rationale with rejected alternatives explicitly prefixed. Populated from agent-reported execution-time reasoning when available, falling back to the synthesis Gate rationale field when not.
    ```

    ---

    **What NOT to do:**
    - Do not modify Section 1 (nine-phase architecture) except the Reviewer gate mention
    - Do not modify Section 2 (delegation model)
    - Do not modify Sections 4-6 (reports, commits, worktrees)
    - Do not change the mermaid diagram
    - Do not modify response handling or cascading gates logic
- **Deliverables**: Modified `docs/orchestration.md` with 5 targeted edits
- **Success criteria**: Gate philosophy preamble in Section 3 opening; "Four types" instead of "Three types"; Team gate format updated with NOT SELECTED (notable); Reviewer gate added as new subsection; Execution Plan gate uses Decisions; Mid-execution gate references Gate rationale fallback

### Cross-Cutting Coverage
<!-- @domain:synthesis-cross-cutting BEGIN -->
- **Testing**: Excluded -- no executable output; all changes are prompt/doc artifacts. Phase 3.5 test-minion review covers test strategy alignment.
- **Security**: Excluded -- no new attack surface; all changes are prompt text and documentation. Phase 3.5 security-minion review covers prompt injection risks.
- **Usability -- Strategy**: Covered by ux-strategy-minion specialist contribution (Phase 2). Self-containment test, density scaling, and line budget guidance incorporated into all four task prompts.
- **Usability -- Design**: Excluded -- no UI components produced. All changes are CLI text formatting and documentation.
- **Documentation**: Covered by Tasks 3 (TEMPLATE.md) and 4 (docs/orchestration.md). TEMPLATE.md captures the new gate formats for reporting; orchestration.md documents them for developers.
- **Observability**: Excluded -- no runtime components. All changes are prompt/doc artifacts.
<!-- @domain:synthesis-cross-cutting END -->

### Architecture Review Agents
<!-- @domain:synthesis-review-agents BEGIN -->
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - user-docs-minion: Gate changes affect what users see at approval points (Tasks 1-4)
    Review focus: gate presentation wording clarity and user-facing terminology
- **Not selected**:
  - ux-design-minion: No UI components produced (all prompt/doc changes)
  - accessibility-minion: No web-facing HTML in plan
  - sitespeed-minion: No browser-facing runtime code
  - observability-minion: No runtime components; all changes are prompt/doc artifacts
<!-- @domain:synthesis-review-agents END -->

### Decisions

- **NOT SELECTED label consistency**
  Chosen: "NOT SELECTED (notable)" for Team gate, matching Reviewer gate's "NOT SELECTED"
  Over: "NOT CONSULTED (rationale)" (ai-modeling-minion)
  Why: consistency across gates matters; "notable" signals curated subset without introducing a new label

- **Planning questions excluded from Team gate**
  Chosen: exclude planning questions from gate presentation
  Over: show planning questions as sub-lines per agent (ai-modeling-minion)
  Why: planning questions are implementation detail; the user's decision is team composition, not prompts; showing them grows Team gate from 10-16 to 25-30 lines

- **Mid-execution gate: examples over redesign**
  Chosen: add good/bad RATIONALE examples + agent instructions + Gate rationale fallback
  Over: structural APPROACH block replacing RATIONALE (ux-strategy-minion)
  Why: the existing format is untested; redesigning before first production use is premature; examples address the quality problem without structural risk

- **Compaction focus strings unchanged**
  Chosen: no modifications to compaction checkpoints
  Over: add "key design decisions" to focus string (advisory recommendation)
  Why: enriched data lives inside the synthesis output, which is already preserved as a unit by "synthesized execution plan"; over-specifying risks treating unlisted subsections as less important

### Risks and Mitigations

- **Line budget growth at Execution Plan gate**: Gate grows from ~30 to ~45 lines. Mitigation: DECISIONS block caps at 5 inline entries with link overflow; the Chosen/Over/Why format has strong visual rhythm for scanning.
- **Agent compliance with rationale reporting**: Enriched completion instruction asks agents to report approach and alternatives. Compliance is not guaranteed. Mitigation: Gate rationale field provides a pre-execution fallback; the gate always shows substantive reasoning.
- **Notable Exclusions quality**: Nefario must make a judgment call about which exclusions are "most likely to surprise." Mitigation: max 3 cap limits variability; cross-cutting checklist remains authoritative.

### Execution Order

```
Batch 1: Task 1 (AGENT.md)
Batch 2: Task 2 (SKILL.md) -- depends on Task 1
Batch 3: Task 3 (TEMPLATE.md) + Task 4 (orchestration.md) -- parallel, both depend on Task 2
```

No mid-execution gates. All changes are additive and easily reversible.

### Verification Steps

1. Verify AGENT.md contains: Notable Exclusions subsection, Decisions section with Chosen/Over/Why, Gate rationale field, enriched Architecture Review Agents, decision transparency anchor
2. Verify SKILL.md contains: Decision Transparency preamble, NOT SELECTED (notable) in Team gate, per-member rationale in Reviewer gate, DECISIONS block in Execution Plan gate, good/bad RATIONALE examples in mid-execution gate, enriched completion instruction
3. Verify TEMPLATE.md contains: Decisions (renamed from Conflict Resolutions) with Chosen/Over/Why, broadened Approval Gates table with Type column, updated formatting rules and checklist
4. Verify orchestration.md contains: gate philosophy preamble, "Four types" opener, Team gate NOT SELECTED (notable), Reviewer gate as new subsection, DECISIONS in Execution Plan gate, Gate rationale fallback in mid-execution gate
5. Cross-reference line budgets are consistent: Team 10-16, Reviewer 7-13, Execution Plan 35-55, Mid-execution 12-18
