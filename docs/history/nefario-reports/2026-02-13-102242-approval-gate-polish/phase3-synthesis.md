## Delegation Plan

**Team name**: approval-gate-polish
**Description**: Apply consistent backtick card framing and markdown scratch-file links to all 5 approval gates in SKILL.md

### Conflict Resolutions

**Display text convention: role-labels vs filenames**

ux-strategy-minion recommends role-based display labels (`[meta-plan]`, `[plan]`, `[verdict]`).
devx-minion recommends filename-only display text (`[phase1-metaplan.md]`, `[phase3-synthesis.md]`).

**Resolved in favor of: role-labels (ux-strategy-minion).**

Rationale: The user at a gate is thinking "What produced this decision?" not "What phase number is this file?" Role labels communicate intent; filenames communicate implementation. The gate audience is the human user making an approve/reject decision, not a developer navigating the filesystem. Additionally, role labels are shorter, producing less visual noise in the compact gate format.

The full vocabulary is:

| Role label | Maps to | Used in |
|------------|---------|---------|
| `meta-plan` | `phase1-metaplan.md` | Team gate |
| `plan` | `phase3-synthesis.md` | Reviewer, Exec Plan gates |
| `prompt` | `phase3.5-{reviewer}-prompt.md` | Complex advisories |
| `verdict` | `phase3.5-{reviewer}.md` | Complex advisories |
| `task-prompt` | `phase4-{agent}-prompt.md` | Mid-execution gate |

**Link visual distinction: backtick-wrapped links vs label-value separation**

ux-strategy-minion recommends backtick-wrapping the entire link (`` `[meta-plan](path)` ``).
devx-minion warns this may prevent link rendering and recommends backtick-wrapping the label only, with the link in plain text.

**Resolved in favor of: label-value separation (devx-minion).**

Rationale: Backtick-wrapping a markdown link may cause it to render as literal text in some contexts. The safer approach is: backtick the label (`` `Details:` ``), leave the link as plain markdown (`[meta-plan](path)`). The label-value separation already creates visual distinction -- the backticked label is the structural element, the link is the value. This matches the existing mid-execution gate pattern where field labels are backticked but field values are not.

**PR gate links: include or omit**

ux-strategy-minion recommends no links (dead-link risk, decision doesn't benefit from scratch context).
devx-minion suggests a report or synthesis link.

**Resolved in favor of: no links (ux-strategy-minion).**

Rationale: The PR gate asks "push or don't push?" The git diff stats ARE the reference material. Scratch files may be cleaned up after this gate. Adding links creates false affordance with dead-link risk.

### Task 1: Apply card framing and links to all gates in SKILL.md

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |

    ## Task: Apply backtick card framing and markdown links to all 5 approval gates

    Edit `skills/nefario/SKILL.md` to bring all approval gates into visual
    consistency with the mid-execution gate (already card-framed) and add
    markdown links to scratch files.

    ### Context

    The mid-execution gate (SKILL.md line ~1249-1269) already has the target
    pattern: backtick borders, backtick-wrapped field labels, structured content.
    Four other gates need the same treatment, and all five gates need markdown
    links to their relevant scratch files.

    This is a single-file edit to `skills/nefario/SKILL.md`.

    ### What to do

    **Sub-task A: Amend the path display rule (line 224-227)**

    The existing rule says "never abbreviate." Add one sentence at the end:
    "Markdown links with role-label display text (e.g., `[meta-plan](full-path)`)
    are permitted; the full resolved path must be the link target."

    This amendment permits the new link convention without contradicting the
    existing rule. It must be in the same change as the gate updates.

    **Sub-task B: Team Approval Gate (line ~441-454)**

    Apply card framing and add footer link. Transform from:

    ```
    ⚗️ TEAM: <1-sentence task summary>
    Specialists: N selected | N considered, not selected

      SELECTED:
        devx-minion          Workflow integration, SKILL.md structure
        ux-strategy-minion   Approval gate interaction design
        lucy                 Governance alignment for new gate

      ALSO AVAILABLE (not selected):
        ai-modeling-minion, margo, software-docs-minion, security-minion, ...

    Details: $SCRATCH_DIR/{slug}/phase1-metaplan.md  (planning questions, cross-cutting checklist)
    ```

    To:

    ```
    `────────────────────────────────────────────────────`
    ⚗️ `TEAM:` <1-sentence task summary>
    `Specialists:` N selected | N considered, not selected

      `SELECTED:`
        devx-minion          Workflow integration, SKILL.md structure
        ux-strategy-minion   Approval gate interaction design
        lucy                 Governance alignment for new gate

      `ALSO AVAILABLE (not selected):`
        ai-modeling-minion, margo, software-docs-minion, security-minion, ...

    `Details:` [meta-plan]($SCRATCH_DIR/{slug}/phase1-metaplan.md)
    `────────────────────────────────────────────────────`
    ```

    Changes:
    - Add top/bottom `────` borders (48 em-dash chars in backticks)
    - Backtick-wrap field labels: `TEAM:`, `Specialists:`, `SELECTED:`,
      `ALSO AVAILABLE (not selected):`, `Details:`
    - Convert Details line to MD link with role-label display text `[meta-plan]`
    - Remove the parenthetical description after the link (the role label
      replaces that function)

    **Sub-task C: Reviewer Approval Gate (line ~782-794)**

    Apply card framing and add footer link. Transform to:

    ```
    `────────────────────────────────────────────────────`
    ⚗️ `REVIEWERS:` <1-sentence plan summary>
    `Mandatory:` security, test, ux-strategy, lucy, margo (always review)

      `DISCRETIONARY (nefario recommends):`
        <agent-name>       <rationale, max 60 chars, reference tasks>
        <agent-name>       <rationale, max 60 chars, reference tasks>

      `NOT SELECTED from pool:`
        <remaining pool members, comma-separated>

    `Details:` [plan]($SCRATCH_DIR/{slug}/phase3-synthesis.md)
    `────────────────────────────────────────────────────`
    ```

    Changes:
    - Add top/bottom borders
    - Backtick-wrap field labels: `REVIEWERS:`, `Mandatory:`,
      `DISCRETIONARY (nefario recommends):`, `NOT SELECTED from pool:`, `Details:`
    - Convert Details line to MD link with role-label `[plan]`
    - Remove parenthetical description

    **Sub-task D: Execution Plan Approval Gate (line ~1038-1114)**

    Apply card framing to the orientation block, convert paths to links,
    and update advisory link format.

    Orientation block becomes:

    ```
    `────────────────────────────────────────────────────`
    ⚗️ `EXECUTION PLAN:` <1-sentence goal summary>
    `REQUEST:` "<truncated original prompt, max 80 chars>..."
    `Tasks:` N | `Gates:` N | `Advisories incorporated:` N
    `Working dir:` [{slug}/]($SCRATCH_DIR/{slug}/)
    ```

    Note: The Working dir line uses the slug as display text (it IS meaningful
    as a session identifier) with full path as link target.

    Task list section -- backtick-wrap the `TASKS:` label:

    ```
    `TASKS:`
      1. <Task title>                                    [agent-name, model]
         Produces: <deliverable summary>
    ```

    Advisories section -- backtick-wrap `ADVISORIES:` label. For the complex
    advisory links (line ~1083-1090), transform from:

    ```
      Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md  (reviewer analysis and recommendations)
      Prompt: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}-prompt.md
    ```

    To:

    ```
      `Details:` [verdict]($SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md)
      `Prompt:` [prompt]($SCRATCH_DIR/{slug}/phase3.5-{reviewer}-prompt.md)
    ```

    Changes: backtick-wrap labels, convert to MD links with role-labels
    (`[verdict]`, `[prompt]`), remove parenthetical descriptions.

    Risks section -- backtick-wrap `RISKS:` and `CONFLICTS RESOLVED:` labels.

    Review summary -- backtick-wrap `REVIEW:` label.

    Footer becomes:

    ```
    `Details:` [plan]($SCRATCH_DIR/{slug}/phase3-synthesis.md)
    `────────────────────────────────────────────────────`
    ```

    The closing border goes after the Details footer. Backtick-wrap `Details:`
    label, convert to MD link with `[plan]` role label, remove parenthetical.

    IMPORTANT: The Execution Plan gate has multiple separate code blocks in the
    template (orientation, task list, advisories, risks, review, details). The
    card borders wrap the ENTIRE gate -- opening border at the top of orientation,
    closing border after the Details footer. The separate code blocks in the
    SKILL.md template are an authoring convenience showing different sections;
    the calling session emits one continuous output. Make sure the borders are
    in the first and last code blocks respectively.

    **Sub-task E: Mid-execution Approval Gate (line ~1249-1269)**

    Already has card framing. Add a footer link before the closing border:

    Transform the area around the closing border from:

    ```
    `Confidence:` HIGH | MEDIUM | LOW
    `────────────────────────────────────────────────────`
    ```

    To:

    ```
    `Confidence:` HIGH | MEDIUM | LOW
    `Details:` [task-prompt]($SCRATCH_DIR/{slug}/phase4-{agent}-prompt.md)
    `────────────────────────────────────────────────────`
    ```

    One new line added. The task-prompt link gives the user "what was asked"
    context for the deliverable they are approving.

    **Sub-task F: PR Gate (line ~1676-1683)**

    Apply card framing only (no links). Transform from:

    ```
    PR: Create PR for nefario/<slug>?
    Branch: nefario/<slug>
    Commits: N | Files changed: N | Lines: +N/-M
      <file path 1> (+N/-M)
      <file path 2> (+N/-M)
      ... (max 5 files, then "and N more")
    ```

    To:

    ```
    `────────────────────────────────────────────────────`
    ⚗️ `PR:` Create PR for nefario/<slug>?
    `Branch:` nefario/<slug>
    `Commits:` N | `Files changed:` N | `Lines:` +N/-M
      <file path 1> (+N/-M)
      <file path 2> (+N/-M)
      ... (max 5 files, then "and N more")
    `────────────────────────────────────────────────────`
    ```

    Changes:
    - Add top/bottom borders
    - Add ⚗️ emoji prefix to header line (consistency with other gates)
    - Backtick-wrap field labels: `PR:`, `Branch:`, `Commits:`, `Files changed:`, `Lines:`
    - NO links (the git diff stats are the reference material; scratch files
      may be cleaned up)

    **Sub-task G: Visual Hierarchy table (line ~207-212)**

    Verify the Decision weight description still accurately describes the
    updated pattern. The current description is:
    `` `─── ···` `` border + `` `LABEL:` `` highlighted fields + structured content

    If the only addition is MD links (which are "structured content"), no update
    is needed. If you determine the description should mention links, update it
    minimally.

    ### What NOT to do

    - Do NOT change any AskUserQuestion fields (header, question, options, description)
    - Do NOT add links inside AskUserQuestion prompts
    - Do NOT modify the advisory principles or format rules prose -- only the
      code block templates
    - Do NOT change the line budget guidance numbers
    - Do NOT add links to the PR gate
    - Do NOT backtick-wrap link display text (backtick the label, leave the link plain)
    - Do NOT add more than one footer link per gate
    - Do NOT change any non-gate sections of SKILL.md
    - Do NOT reformat or restructure the SKILL.md file beyond the specific
      template code blocks and the path display rule amendment

    ### Consistency rules (apply to all 5 gates)

    1. Every gate (except PR) gets a `Details:` footer link as the last content
       line before the closing border
    2. All gates use identical 48-em-dash borders in backticks
    3. All gates use ⚗️ prefix on the header line
    4. Field labels are backtick-wrapped; field values (including links) are not
    5. Link display text uses role labels (meta-plan, plan, verdict, prompt,
       task-prompt), not filenames
    6. Slug-only display text for the Working dir line (`[{slug}/]`)
    7. Complex advisory links use label-prefixed format (`` `Details:` [verdict](path) ``)
    8. Simple advisories (CHANGE + WHY only) have no links

    ### Deliverables

    - Updated `skills/nefario/SKILL.md` with all changes applied

    ### Success criteria

    - All 5 gate templates have backtick card framing (borders + labels)
    - 4 gates (Team, Reviewer, Exec Plan, Mid-execution) have footer MD links
    - PR gate has framing but no links
    - Path display rule amended to permit MD links
    - Advisory section has prompt+verdict links for complex advisories
    - Working dir shows slug-only display text
    - Visual Hierarchy table is accurate
    - No changes outside the specified sections

- **Deliverables**: Updated `skills/nefario/SKILL.md`
- **Success criteria**: All 5 gates card-framed, 4 gates have footer links, advisory links converted, path display rule amended, no changes outside specified sections

### Cross-Cutting Coverage

- **Testing**: Not applicable. This is a documentation/template change with no executable output. No test-minion execution task needed. (Phase 3.5 test-minion will review the plan for test strategy alignment.)
- **Security**: Not applicable. No attack surface, auth, user input, secrets, or dependencies. (Phase 3.5 security-minion will review the plan.)
- **Usability -- Strategy**: Covered. ux-strategy-minion provided planning input (Phase 2) that directly shaped link placement, display conventions, and minimum viable link set. Their recommendations are incorporated into the task prompt.
- **Usability -- Design**: Not applicable. No UI components or visual layouts are being produced. The changes are to instructional templates in a markdown file.
- **Documentation**: The change IS documentation. The deliverable is an updated SKILL.md. No separate documentation task needed.
- **Observability**: Not applicable. No runtime components, services, or APIs.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none
  - ux-design-minion: No -- no UI components or visual layouts produced
  - accessibility-minion: No -- no web-facing HTML/UI
  - sitespeed-minion: No -- no web-facing runtime code
  - observability-minion: No -- no runtime components
  - user-docs-minion: No -- changes are to internal orchestration templates, not end-user-facing documentation
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Risks and Mitigations

1. **Path display rule contradiction** (from ux-strategy-minion) -- If the path display rule (line 224-227) is not amended in the same change, the new link convention contradicts "never abbreviate." Mitigation: Sub-task A amends the rule as the first edit. The task prompt explicitly sequences this.

2. **Execution Plan gate line budget** (from devx-minion) -- The Execution Plan gate targets 25-40 lines. Adding borders (+2 lines) and converting existing lines to links (net zero) keeps the impact minimal. Complex advisory links only appear on advisories that already have Details lines (net zero). Risk is low.

3. **Terminal rendering variance** (from devx-minion) -- Backtick borders and em-dash characters render differently across terminal emulators. Mitigation: The mid-execution gate already uses this pattern (accepted risk). Extending it to all gates is consistent, not additive risk.

4. **Template readability for maintainers** (from devx-minion) -- MD link syntax inside code block templates increases visual complexity. Mitigation: The link pattern is well-known, consistent across all gates, and documented by the role-label vocabulary table in this synthesis.

### Execution Order

```
Batch 1: Task 1 (devx-minion, single task, no dependencies)
```

Single-task plan. No gates, no batching complexity.

### Verification Steps

1. Verify all 5 gate template code blocks have top/bottom backtick borders
2. Verify all field labels in gate templates are backtick-wrapped
3. Verify Team, Reviewer, Exec Plan, Mid-execution gates have `Details:` footer links with role-label display text
4. Verify PR gate has borders but no links
5. Verify advisory section has `[verdict]` and `[prompt]` links for complex advisories
6. Verify Working dir uses `[{slug}/]` display text
7. Verify path display rule (line 224-227) has the amendment sentence
8. Verify no changes outside the specified sections (gates + path display rule)
9. Verify Visual Hierarchy table is still accurate
