# Phase 3: Synthesis -- Card Framing for Approval Gates

## Delegation Plan

**Team name**: card-framing-gates
**Description**: Add backtick-wrapped box-drawing card framing to the APPROVAL GATE template in SKILL.md and update the Visual Hierarchy table.

### Task 1: Update APPROVAL GATE template and Visual Hierarchy table in SKILL.md
- **Agent**: ux-design-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario orchestration skill file to add card-style visual
    framing to the APPROVAL GATE decision brief template. This leverages Claude
    Code's built-in inline code highlight color to create card-like separation.

    ## File to edit

    `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

    ## Change 1: APPROVAL GATE template (around lines 1286-1306)

    Replace the current template block:

    ```
    ---
    ⚗️ APPROVAL GATE: <Task title>
    Agent: <who produced this> | Blocked tasks: <what's waiting>

    DECISION: <one-sentence summary of the deliverable/decision>

    DELIVERABLE:
      <file path 1> (<change scope>, +N/-M lines)
      <file path 2> (<change scope>, +N/-M lines)
      Summary: <1-2 sentences describing what was produced>

    RATIONALE:
    - <key point 1>
    - <key point 2>
    - Rejected: <alternative and why>

    IMPACT: <what approving/rejecting means for the project>
    Confidence: HIGH | MEDIUM | LOW
    ---
    ```

    With this new template that uses backtick-wrapped box-drawing borders and
    backtick-wrapped field labels:

    ```
    `────────────────────────────────────────────────────`
    ⚗️ `APPROVAL GATE: <Task title>`
    `Agent:` <who produced this> | `Blocked tasks:` <what's waiting>

    `DECISION:` <one-sentence summary of the deliverable/decision>

    `DELIVERABLE:`
      <file path 1> (<change scope>, +N/-M lines)
      <file path 2> (<change scope>, +N/-M lines)
      `Summary:` <1-2 sentences describing what was produced>

    `RATIONALE:`
    - <key point 1>
    - <key point 2>
    - Rejected: <alternative and why>

    `IMPACT:` <what approving/rejecting means for the project>
    `Confidence:` HIGH | MEDIUM | LOW
    `────────────────────────────────────────────────────`
    ```

    Design rules to follow precisely:
    - The border lines are exactly 52 box-drawing dash characters (U+2500, ─) wrapped in backticks
    - Top and bottom borders are identical
    - The header line has the emoji OUTSIDE the backtick span: ⚗️ `APPROVAL GATE: <Task title>`
    - Only field LABELS are backtick-wrapped, not their values (e.g., `DECISION:` not `DECISION: <value>`)
    - `Summary:` inside DELIVERABLE also gets backtick-wrapped as a sub-label
    - `Agent:` and `Blocked tasks:` get label-only backtick wrapping
    - List content under RATIONALE: and DELIVERABLE: remains unhighlighted
    - The backtick border lines replace the `---` borders entirely

    ## Change 2: Visual Hierarchy table (around line 209)

    In the Visual Hierarchy table, replace the current Decision row:

    ```
    | **Decision** | `---` card frame + `ALL-CAPS LABEL:` header + structured content | Approval gates, escalations -- requires user action |
    ```

    With:

    ```
    | **Decision** | `` `─── ···` `` border + `` `LABEL:` `` highlighted fields + structured content | Approval gates, escalations -- requires user action |
    ```

    This shows the new pattern: code-span-wrapped box-drawing border, highlighted
    field labels, and structured content within.

    ## What NOT to do

    - Do NOT modify any other templates (TEAM gate, REVIEWERS gate, EXECUTION PLAN gate, etc.) -- those are out of scope for this issue
    - Do NOT change the AskUserQuestion parameters or status file update sections that follow the template
    - Do NOT modify the "Maximum 5 files" or "Target 12-18 lines" guidance paragraphs that follow the template
    - Do NOT change any phase announcement formatting
    - Do NOT add any new sections or commentary -- just the two targeted edits

    ## Verification

    After editing, read back lines 1284-1310 and lines 207-212 to confirm the
    changes rendered correctly. Ensure the box-drawing characters (─) are present
    and that backtick wrapping is correct on all field labels.

- **Deliverables**: Updated SKILL.md with card-framed APPROVAL GATE template and updated Visual Hierarchy table
- **Success criteria**:
  - Gate header line uses backtick-wrapped text with box-drawing dash border
  - All field labels (DECISION:, DELIVERABLE:, RATIONALE:, IMPACT:, Confidence:, Agent:, Blocked tasks:, Summary:) are backtick-wrapped
  - Opening and closing border lines use backtick-wrapped 52-character box-drawing dashes
  - Visual Hierarchy table Decision row reflects the new pattern
  - No other sections of SKILL.md are modified

### Cross-Cutting Coverage
- **Testing**: Not applicable -- this is a documentation/template change with no executable output. No test-minion needed.
- **Security**: Not applicable -- no attack surface, auth, user input, or infrastructure changes. No security-minion needed.
- **Usability -- Strategy**: Covered by the ux-design-minion's planning contribution. The card framing pattern serves the user job-to-be-done of quickly parsing approval gate structure. No separate ux-strategy-minion task needed since this is a visual formatting change within an established interaction pattern.
- **Usability -- Design**: ux-design-minion is the executing agent (Task 1). Their design rationale is fully incorporated into the task prompt.
- **Documentation**: This IS the documentation change. Phase 8 post-execution with software-docs-minion, user-docs-minion, and product-marketing-minion will review as directed.
- **Observability**: Not applicable -- no runtime components. No observability-minion needed.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**: None -- this is a single-file template formatting change with no UI components, no runtime code, no user-facing workflow changes, and no web-facing output.
- **Not selected**: ux-strategy-minion, ux-design-minion (already the executor), accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions
No conflicts -- single specialist contribution with clear, well-reasoned recommendations.

### Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Terminal width wrapping at <55 columns | Low | 52 chars is conservative for 80+ column terminals. Can tune down to 40 if needed later. |
| Box-drawing char (U+2500) rendering | Very low | Part of basic Unicode box-drawing block; renders correctly in all modern terminals. |
| Backtick in task title/values | Very low | Rare in practice. Can escape or use double-backtick spans if encountered. |
| Visual inconsistency with other Decision-weight gates | Low | Acceptable as transitional state. Visual Hierarchy table documents the target pattern; follow-up issue will align remaining gates. |

### Execution Order

Single task, no batching needed:

1. **Task 1**: ux-design-minion updates SKILL.md (APPROVAL GATE template + Visual Hierarchy table)

No approval gates. Straight through to post-execution.

### Verification Steps
1. Read the updated APPROVAL GATE template section and confirm box-drawing borders and backtick-wrapped labels
2. Read the Visual Hierarchy table and confirm the Decision row reflects the new pattern
3. Verify no other sections of SKILL.md were modified (git diff should show changes only in the two targeted areas)
