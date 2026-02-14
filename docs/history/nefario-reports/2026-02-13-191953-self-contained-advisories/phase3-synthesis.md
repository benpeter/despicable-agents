## Delegation Plan

**Team name**: self-contained-advisories
**Description**: Make all nefario advisories self-contained and readable in isolation by updating the verdict format, reviewer prompts, and advisory rendering across all surfaces.

### Key Conflict Resolution: New Field vs. Better Instructions

**margo** argues the problem is content quality, not format structure -- fix
authoring instructions, keep the existing two-field format (CHANGE + WHY), add a
self-containment validation rule, and leave the 3-line cap untouched. No new
fields.

**ux-strategy-minion, software-docs-minion, lucy, and ai-modeling-minion** all
recommend adding a dedicated field (variously named SCOPE, SUBJECT, or ARTIFACT)
that explicitly names the concrete artifact or concept the advisory concerns.

**Resolution: Add one field (SCOPE), accept margo's content-quality constraints.**

Rationale:

1. The header line currently reads `[<domain>] Task N: <task title>`. The task
   title *can* serve as the artifact anchor -- but only when it is descriptive.
   Margo's position depends on task titles reliably naming artifacts, which they
   do in synthesis output but do NOT in the reviewer verdict format (where the
   reviewer writes `TASK: Task 3` with no title). The reviewer-to-gate pipeline
   loses the title because the reviewer prompt does not produce it.

2. Adding SCOPE to the reviewer verdict format is the minimum structural change
   that guarantees every advisory names its subject at the point of authoring.
   This is cheaper to enforce than relying on content-quality instructions alone,
   because it gives the model a labeled slot to fill. ai-modeling-minion's point
   about labeled slots producing better compliance than prose instructions is
   well-grounded in prompt engineering practice.

3. The 3-line cap on the execution plan gate presentation is preserved. SCOPE
   replaces the `Task N: <task title>` header -- it does not add a line. The
   reviewer verdict grows from 3 fields to 4 (SCOPE + CHANGE + WHY + TASK as
   routing metadata), but the reviewer verdict is not user-facing and is not
   subject to the 3-line gate cap.

4. Margo's content-quality constraints (self-containment test, no plan-internal
   references rule, one-sentence-per-field) are adopted wholesale as
   complementary enforcement. The SCOPE field provides structure; the content
   rules provide quality. Both are needed.

5. The RECOMMENDATION field is eliminated (merged into CHANGE), per
   software-docs-minion and lucy's recommendation. RECOMMENDATION and CHANGE are
   functionally identical -- "what should be different."

6. ai-modeling-minion's XML tag recommendation is declined per KISS. Plain-text
   field labels with examples are sufficient when the consumer is an LLM.
   ai-modeling-minion acknowledged this trade-off.

7. lucy's recommendation to include the original user request path in reviewer
   prompts is adopted -- it is a one-line addition with high value for intent
   alignment, and it does not change the advisory format itself.

### Task 1: Update verdict format definition in nefario/AGENT.md

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This is the canonical format definition that all other files reference. Getting this wrong propagates errors to every downstream task. Hard to reverse (all other tasks build on it) and has 3 dependents.
- **Prompt**: |
    You are updating the advisory verdict format definition in nefario's agent
    specification. This is the canonical definition that other files will
    reference.

    ## What to Change

    File: `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md`

    ### 1. Update the ADVISE verdict format (around line 664-672)

    Replace the current ADVISE format block:
    ```
    VERDICT: ADVISE
    WARNINGS:
    - [domain]: <description of concern>
      TASK: <task number affected, e.g., "Task 3">
      CHANGE: <what specifically changed in the task prompt or deliverables>
      RECOMMENDATION: <suggested change>
    ```

    With the new format:
    ```
    VERDICT: ADVISE
    WARNINGS:
    - [domain]: <description of concern>
      SCOPE: <file, component, or concept affected -- e.g., "nefario/AGENT.md verdict format", "OAuth token refresh flow", "install.sh symlink targets">
      CHANGE: <what is proposed, in domain terms -- not by referencing plan-internal numbering>
      WHY: <risk or rationale, using only information present in this advisory>
      TASK: <task number> (routing metadata for orchestrator -- not shown in user-facing output)
    ```

    ### 2. Update the explanatory paragraph after the ADVISE format (around line 674-676)

    Replace:
    ```
    The TASK and CHANGE fields enable the calling session to populate the execution
    plan approval gate with structured advisory data, showing which tasks were
    modified and what changed.
    ```

    With:
    ```
    Each advisory is self-contained: a reader seeing only the advisory block can
    answer "what part of the system does this affect" (SCOPE), "what is suggested"
    (CHANGE), and "why" (WHY) without opening any other document. The TASK field
    is routing metadata that enables the orchestrator to inject advisories into the
    correct task prompts -- it is not shown in user-facing output.

    Content rules for all advisory fields:
    - SCOPE names a concrete artifact (file path, config key, endpoint) or concept
      (flow, pattern, format). Not "step 1" or "the approach."
    - CHANGE states the proposed modification in domain terms. Not "updated the
      task prompt" or "added to step 2."
    - WHY explains the risk or rationale using facts present in this advisory.
      Not "see the synthesis" or "as discussed."
    - One sentence per field. If more detail is needed, the Details link mechanism
      provides progressive disclosure.
    ```

    ### 3. Add SCOPE to the BLOCK verdict format (around line 688-693)

    Replace:
    ```
    Block format:
    ```
    VERDICT: BLOCK
    ISSUE: <description of the blocking concern>
    RISK: <what happens if this is not addressed>
    SUGGESTION: <how the plan could be revised to resolve this>
    ```
    ```

    With:
    ```
    Block format:
    ```
    VERDICT: BLOCK
    SCOPE: <file, component, or concept affected>
    ISSUE: <description of the blocking concern>
    RISK: <what happens if this is not addressed>
    SUGGESTION: <how the plan could be revised to resolve this>
    ```

    SCOPE, ISSUE, RISK, and SUGGESTION must each be self-contained -- readable
    without access to the plan, other verdicts, or the originating conversation.
    ```

    ### 4. Make AGENT.md reference SKILL.md as the canonical location for reviewer output format

    After the updated ADVISE format block and its explanatory paragraph, add a
    one-line note:

    ```
    Reviewers receive the advisory output format via the reviewer prompt template
    in SKILL.md. The format above defines the schema; the reviewer prompt provides
    examples and enforcement instructions.
    ```

    ## What NOT to Do

    - Do not change anything outside the Verdict Format section (lines ~656-693)
    - Do not change the APPROVE verdict -- it has no format body
    - Do not change the Resolution process (lines 680-685) or the revision loop mechanics
    - Do not modify the ARCHITECTURE.md section that follows
    - Do not restructure other sections of AGENT.md

    ## Deliverables

    Updated `nefario/AGENT.md` with:
    - ADVISE verdict format using SCOPE/CHANGE/WHY/TASK fields
    - Explanatory paragraph documenting self-containment rules
    - BLOCK verdict format with SCOPE field added
    - Reference note pointing to SKILL.md for reviewer prompt details

    ## Success Criteria

    - The ADVISE format has exactly 4 labeled fields: SCOPE, CHANGE, WHY, TASK
    - The BLOCK format has exactly 4 labeled fields: SCOPE, ISSUE, RISK, SUGGESTION
    - RECOMMENDATION field is gone (merged into CHANGE)
    - Content rules are documented inline
    - No other sections of AGENT.md are modified

- **Deliverables**: Updated verdict format section in `nefario/AGENT.md`
- **Success criteria**: ADVISE uses SCOPE/CHANGE/WHY/TASK; BLOCK uses SCOPE/ISSUE/RISK/SUGGESTION; content rules documented; RECOMMENDATION eliminated

### Task 2: Update all advisory surfaces in SKILL.md

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: yes
- **Gate reason**: SKILL.md is the operational heart of the orchestration system. Changes here affect every future orchestration. Multiple sections are modified (reviewer prompts, gate format, inline summary, Phase 5 instructions). Hard to reverse with 1 dependent (Task 4).
- **Prompt**: |
    You are updating all advisory-related format definitions and instructions
    in the nefario orchestration skill. Task 1 defined the canonical format in
    nefario/AGENT.md. This task aligns all SKILL.md surfaces with that definition.

    File: `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

    Read Task 1's deliverable first:
    `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md` (Verdict Format
    section, around line 656-693) to see the canonical format.

    ## Changes to Make

    ### A. Update the generic reviewer prompt template (around line 1089-1096)

    Replace the current verdict instructions:
    ```
    ## Instructions
    Return exactly one verdict:
    - APPROVE: No concerns from your domain.
    - ADVISE: <list specific non-blocking warnings>
    - BLOCK: <describe the blocking issue and what must change>

    Be concise. Only flag issues within your domain expertise.
    ```

    With:
    ```
    ## Original User Request
    Read the original user request from: $SCRATCH_DIR/{slug}/prompt.md

    ## Instructions
    Return exactly one verdict:

    - APPROVE: No concerns from your domain.

    - ADVISE: Return warnings using this format for each concern:
      - [your-domain]: <one-sentence description>
        SCOPE: <file, component, or concept affected>
        CHANGE: <what should change, in domain terms>
        WHY: <risk or rationale, self-contained>
        TASK: <task number affected>

      Example (good -- self-contained):
      - [security]: Open redirect risk in callback handler
        SCOPE: OAuth callback endpoint in auth/callback.ts
        CHANGE: Validate redirect_uri against allowlist before issuing redirect
        WHY: Unvalidated redirect_uri allows attackers to redirect users to malicious sites after authentication
        TASK: Task 3

      Example (bad -- references invisible context):
      - [security]: Issue with the approach
        SCOPE: step 1
        CHANGE: Add validation as discussed
        WHY: See the analysis above
        TASK: Task 3

      Each advisory must be understandable by a reader who has not seen the plan
      or this review session. SCOPE names the artifact, not a plan step number.
      CHANGE and WHY use domain terms, not plan-internal references.

    - BLOCK: Return using this format:
      SCOPE: <file, component, or concept affected>
      ISSUE: <description of the blocking concern>
      RISK: <what happens if this is not addressed>
      SUGGESTION: <how the plan could be revised>

    Be concise. Only flag issues within your domain expertise.
    ```

    ### B. Update the ux-strategy-minion prompt (around line 1123-1131)

    Replace the Instructions section of the ux-strategy-minion prompt with the
    same verdict format as above (section A), but keep the existing
    ux-strategy-specific "Your Review Focus" section unchanged. The Instructions
    section should be identical to the generic reviewer prompt's Instructions
    section. Also add the "Original User Request" line before Instructions, same
    as in the generic prompt.

    ### C. Update the execution plan gate ADVISORIES format (around line 1283-1309)

    Replace the current advisory format:
    ```
    Format:
    ```
    `ADVISORIES:`
      [<domain>] Task N: <task title>
        CHANGE: <one sentence describing the concrete change to the task>
        WHY: <one sentence explaining the concern that motivated it>

      [<domain>] Task M: <task title>
        CHANGE: ...
        WHY: ...
    ```
    ```

    With:
    ```
    Format:
    ```
    `ADVISORIES:`
      [<domain>] <artifact or concept> (Task N)
        CHANGE: <one sentence, in domain terms>
        WHY: <one sentence, self-contained rationale>

      [<domain>] <artifact or concept> (Task M)
        CHANGE: ...
        WHY: ...
    ```
    ```

    The header line now leads with the SCOPE value (artifact or concept) and puts
    the task reference in parentheses as secondary context. This makes the
    advisory scannable by what it concerns, not by plan-internal task numbering.

    Replace the advisory principles paragraph:
    ```
    Advisory principles:
    - Two-field format (CHANGE, WHY) makes each advisory self-contained
    ```

    With:
    ```
    Advisory principles:
    - Self-containment test: a reader seeing only this advisory block can answer
      "what part of the system does this affect, what is suggested, and why"
    - CHANGE and WHY must use domain terms -- no plan-internal references ("step 2",
      "the approach", "as discussed in the review")
    ```

    Keep the rest of the advisory principles (3-line max, Details link mechanism,
    5-advisory cap, 7-advisory rework threshold, informational note format)
    exactly as they are.

    ### D. Update the inline summary template (around line 348)

    Replace:
    ```
    Verdict: {APPROVE | ADVISE(details) | BLOCK(details)} (Phase 3.5 reviewers only)
    ```

    With:
    ```
    Verdict: {APPROVE | ADVISE -- SCOPE: <artifact>; CHANGE: <what>; WHY: <reason> | BLOCK(details)} (Phase 3.5 reviewers only)
    ```

    For multiple advisories, use semicolons between them. If the line exceeds
    200 characters, truncate to the first advisory and append "(+N more)".

    ### E. Add self-containment rule to Phase 5 code review instructions (around line 1665-1671)

    After the existing findings format block:
    ```
    FINDINGS:
    - [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
      AGENT: <producing-agent>
      FIX: <specific fix>
    ```

    Add:
    ```
    Each finding must be self-contained. Do not reference other findings by
    number, plan steps, or context not present in this finding. The <description>
    names the specific issue in domain terms.
    ```

    Phase 5 findings are already artifact-grounded via the <file>:<line-range>
    anchor. This addition prevents the description field from referencing
    invisible context. Do NOT restructure the Phase 5 format itself -- it is a
    different abstraction level (line-level vs. component-level) and its current
    structure is correct.

    ## What NOT to Do

    - Do not change verdict routing mechanics (Process Verdicts section, revision loop)
    - Do not change phase sequencing or execution flow
    - Do not change the Phase 4 execution logic
    - Do not add XML tags to the format
    - Do not change the 3-line cap for gate advisories
    - Do not modify the Phase 5 findings format structure (only add the self-containment instruction)
    - Do not modify report template (TEMPLATE.md) -- that is a separate task

    ## Deliverables

    Updated `skills/nefario/SKILL.md` with:
    - Reviewer prompt template with structured ADVISE/BLOCK format and examples
    - ux-strategy-minion prompt with matching verdict instructions
    - Original user request path added to reviewer prompts
    - Execution plan gate ADVISORIES format using SCOPE-first header
    - Updated advisory principles with self-containment test
    - Inline summary template with SCOPE/CHANGE/WHY structure
    - Phase 5 self-containment instruction

    ## Success Criteria

    - Generic reviewer prompt includes structured ADVISE format with good/bad examples
    - ux-strategy-minion prompt has matching verdict instructions
    - Both reviewer prompts include original user request path
    - Gate ADVISORIES format leads with artifact/concept, task number in parentheses
    - Advisory principles include self-containment test
    - Phase 5 findings have self-containment instruction
    - 3-line cap preserved for gate advisories
    - No changes to verdict routing, phase sequencing, or execution flow

- **Deliverables**: Updated SKILL.md across 5 sections (reviewer prompts, gate format, inline summary, advisory principles, Phase 5 instructions)
- **Success criteria**: All advisory surfaces use consistent SCOPE-anchored format; reviewer prompts include examples; self-containment rules documented

### Task 3: Update lucy and margo AGENT.md output standards

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating the output standards in lucy's and margo's agent
    specifications to include the self-contained advisory requirement.

    These two agents are the only reviewers with persistent AGENT.md files
    that contain verdict format instructions. Other reviewers receive the
    format exclusively via the reviewer prompt template in SKILL.md.

    ## What to Change

    ### File 1: `/Users/ben/github/benpeter/2despicable/2/lucy/AGENT.md`

    In the Output Standards section (around line 206-216), after the existing
    bullet "Specific citations":
    ```
    - **Specific citations**: Always cite the exact plan element, CLAUDE.md directive, or requirement being referenced. No vague findings.
    ```

    Add a new bullet immediately after it:
    ```
    - **Self-contained findings**: Each finding must be readable in isolation. Name the file, component, or concept it concerns -- not "Task 3" or "the approach." CHANGE descriptions state what is proposed in domain terms. WHY descriptions explain the rationale using information present in the finding itself.
    ```

    ### File 2: `/Users/ben/github/benpeter/2despicable/2/margo/AGENT.md`

    Find the Output Standards section. Add a similar self-containment bullet.
    Read the file first to find the exact location and match the existing style.

    The bullet for margo should read:
    ```
    - **Self-contained findings**: Each finding names the specific file, config, or concept it concerns. Proposed changes use domain terms, not plan-internal references. Rationale uses facts present in the finding.
    ```

    ## What NOT to Do

    - Do not change any other section of either AGENT.md
    - Do not restructure the Output Standards sections
    - Do not add examples (these agents receive examples via the reviewer prompt)
    - Do not change verdict type definitions (APPROVE/ADVISE/BLOCK)

    ## Deliverables

    - Updated `lucy/AGENT.md` Output Standards with self-contained findings bullet
    - Updated `margo/AGENT.md` Output Standards with self-contained findings bullet

    ## Success Criteria

    - Both files have a "Self-contained findings" bullet in Output Standards
    - The bullets match each agent's voice and existing style
    - No other sections modified

- **Deliverables**: Updated output standards in `lucy/AGENT.md` and `margo/AGENT.md`
- **Success criteria**: Self-containment directive added to both; no other changes

### Task 4: Update execution report template

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating the execution report template to use the new
    self-contained advisory format in the Agent Contributions section.

    File: `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`

    Read Task 1's deliverable first:
    `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md` (Verdict Format
    section) to see the canonical format.

    ## What to Change

    In the Agent Contributions section, under "Architecture Review" (around
    line 113-117), update the ADVISE template line:

    Replace:
    ```
    **{agent-name}**: ADVISE. {Concern and recommendation.}
    ```

    With:
    ```
    **{agent-name}**: ADVISE. SCOPE: {artifact or concept}. CHANGE: {what was proposed}. WHY: {rationale}.
    ```

    This aligns the report template with the canonical three-field advisory
    format. The structured fields ensure report readers can evaluate advisories
    without opening the reviewer's scratch file.

    For multi-advisory verdicts (reviewer produced multiple warnings), each
    advisory gets its own line:
    ```
    **{agent-name}**: ADVISE.
    - SCOPE: {artifact 1}. CHANGE: {proposal}. WHY: {reason}.
    - SCOPE: {artifact 2}. CHANGE: {proposal}. WHY: {reason}.
    ```

    ## What NOT to Do

    - Do not change the Phases narrative section (it uses prose, not structured blocks)
    - Do not retroactively update existing reports in docs/history/nefario-reports/
    - Do not change the skeleton structure or frontmatter
    - Do not change the APPROVE or BLOCK template lines
    - Do not change the Planning subsection format

    ## Deliverables

    Updated `TEMPLATE.md` with structured ADVISE line format in Agent
    Contributions section.

    ## Success Criteria

    - ADVISE template line uses SCOPE/CHANGE/WHY fields
    - Multi-advisory format documented
    - APPROVE and BLOCK lines unchanged
    - No changes outside Agent Contributions section

- **Deliverables**: Updated ADVISE line format in `docs/history/nefario-reports/TEMPLATE.md`
- **Success criteria**: ADVISE template uses SCOPE/CHANGE/WHY structure

### Cross-Cutting Coverage

- **Testing**: Not applicable. All changes are to prompt text and documentation templates, not executable code. No tests exist for these files. Phase 6 will confirm no regressions in orchestration flow by attempting a dry run if the user requests it.
- **Security**: Not applicable. No authentication, user input processing, or attack surface changes. The advisory format is consumed by LLMs and human readers.
- **Usability -- Strategy**: Covered. ux-strategy-minion contributed the core recognition-vs-recall analysis and the Krug three-question test that shaped the format design. The SCOPE field and content rules directly implement their recommendations.
- **Usability -- Design**: Not applicable. No user-facing UI components are produced. The advisory format is text in terminal output.
- **Documentation**: Covered by all four tasks. The entire scope of this plan is documentation/prompt text changes. software-docs-minion is the primary agent for all tasks.
- **Observability**: Not applicable. No runtime components, APIs, or background processes are created or modified.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - ai-modeling-minion: The revised reviewer prompt includes positive/negative examples and structured field labels. ai-modeling-minion should verify the prompt engineering is sound for reliable structured output compliance from reviewer agents (directly relevant to Tasks 1-2).
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

1. **New field (SCOPE) vs. instructions-only (margo) -- Resolved: add SCOPE.**
   Margo's content-quality constraints are adopted in full (self-containment test, no plan-internal references, one-sentence-per-field). But the structural gap -- reviewers write `TASK: Task 3` with no artifact name -- cannot be closed by content instructions alone because the reviewer verdict format does not have a slot for the artifact name. Adding SCOPE provides that slot. The gate presentation preserves the 3-line cap by putting SCOPE in the header line where `Task N: <task title>` currently sits. Net structural change: one new field in the reviewer verdict; zero additional lines in user-facing output.

2. **SCOPE vs. SUBJECT vs. ARTIFACT (naming) -- Resolved: SCOPE.**
   software-docs-minion and ux-strategy-minion proposed SCOPE. lucy and ai-modeling-minion proposed SUBJECT. SCOPE is preferred because it aligns with documentation terminology ("scope of impact") and is less generic than SUBJECT. ai-modeling-minion noted the field name matters less than the labeled-slot principle; software-docs-minion's naming analysis considered and rejected TARGET, ARTIFACT, SUBJECT, and AFFECTS.

3. **XML tags vs. plain-text labels (ai-modeling-minion) -- Resolved: plain-text.**
   ai-modeling-minion recommended XML tags for strongest format enforcement, then acknowledged plain-text labels with examples are sufficient when the consumer is an LLM. Per the project's KISS preference and margo's complexity-aversion stance, plain-text field labels win. XML can be revisited if compliance proves insufficient.

4. **3-line cap (margo) vs. 4-line cap (lucy) -- Resolved: 3-line cap preserved for user-facing gate output.**
   Lucy noted SCOPE adds a line, making the minimum 4. However, SCOPE replaces the task-title header line (not added below it), so the gate format stays at 3 content lines: header (SCOPE + task ref), CHANGE, WHY. The reviewer verdict has 4 labeled fields but is not subject to the gate cap.

5. **Where to define the format -- AGENT.md vs. SKILL.md (ai-modeling-minion) -- Resolved: both, with clear hierarchy.**
   ai-modeling-minion argued for single-source in SKILL.md reviewer prompt. However, nefario/AGENT.md must define the schema (it is the specification), and SKILL.md must provide it inline in the reviewer prompt (it is the operational delivery). AGENT.md is the definition; SKILL.md is the delivery with examples. AGENT.md includes a cross-reference to SKILL.md for the reviewer prompt details.

### Risks and Mitigations

1. **Reviewers may still produce plan-internal references despite instructions.** The positive/negative examples in the reviewer prompt are the primary mitigation. ai-modeling-minion confirmed that one good example and one bad example are the most cost-effective format enforcement mechanism (~120 tokens per reviewer, <$0.005 per orchestration).

2. **SCOPE values may be too vague ("the authentication flow" instead of "auth/callback.ts").** Mitigated by the examples in the reviewer prompt showing both file-path and concept-name SCOPEs. The content rule "name a concrete artifact or concept" further constrains vagueness.

3. **Dual-definition drift between AGENT.md and SKILL.md.** Mitigated by the cross-reference note in AGENT.md and Task 2's instruction to read Task 1's deliverable first. Phase 5 code review (automatic) will also catch inconsistencies.

4. **Backward compatibility of existing reports.** Historical reports in `docs/history/nefario-reports/` use the old format. They are historical records and will not be retroactively updated. The TEMPLATE.md change applies only to future reports.

5. **Phase 5 format divergence is intentional.** Phase 5 code review findings use `<file>:<line-range>` which is already artifact-grounded at a finer granularity. The self-containment instruction (Task 2, section E) prevents description-field references to invisible context without restructuring the Phase 5 format.

### Execution Order

```
Task 1: nefario/AGENT.md verdict format   [software-docs-minion, opus]
  GATE -- canonical format definition, 3 dependents

  |
  +-- Task 2: SKILL.md advisory surfaces   [software-docs-minion, opus]
  |     GATE -- operational format delivery
  |
  +-- Task 3: lucy + margo AGENT.md        [software-docs-minion, opus]
  |     (parallel with Task 2, different files)
  |
  +-- Task 4: TEMPLATE.md                  [software-docs-minion, opus]
        (parallel with Task 2, different files)
```

Batch 1: Task 1 (gated)
Batch 2: Tasks 2, 3, 4 in parallel (Task 2 gated)

### Verification Steps

After all tasks complete:

1. Read the updated verdict format in `nefario/AGENT.md` and confirm ADVISE uses SCOPE/CHANGE/WHY/TASK, BLOCK uses SCOPE/ISSUE/RISK/SUGGESTION.
2. Read the reviewer prompt template in `skills/nefario/SKILL.md` and confirm it includes the structured format with good/bad examples and the original user request path.
3. Read the gate ADVISORIES format in SKILL.md and confirm it leads with artifact/concept and puts task number in parentheses.
4. Read the inline summary template and confirm it uses SCOPE/CHANGE/WHY structure.
5. Read Phase 5 findings instructions and confirm the self-containment rule is present.
6. Read `lucy/AGENT.md` and `margo/AGENT.md` output standards and confirm self-containment bullets exist.
7. Read `TEMPLATE.md` and confirm the ADVISE line uses SCOPE/CHANGE/WHY fields.
8. Apply the self-containment test to each surface: "Can a reader seeing only this block answer what, what change, and why?"
