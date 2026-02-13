## Delegation Plan

**Team name**: gates-include-orchestration-title
**Description**: Add `$summary` run identifier to all AskUserQuestion gates in the nefario SKILL.md so users can identify which orchestration run a gate belongs to, especially in parallel terminal sessions.

### Conflict Resolution: Suffix wins over prefix

The three specialists proposed different placement conventions:
- **devx-minion**: Suffix -- append `\n\nRun: $summary` as a trailing line
- **ux-strategy-minion**: Prefix -- `$summary -- <gate-specific content>`
- **ai-modeling-minion**: Bracket prefix -- `[$summary] <question>`

**Resolution: Suffix (`\n\nRun: $summary` trailing line).** Rationale:

1. **Zero existing content changes.** The suffix appends to every gate identically without rewriting any question strings. Prefix approaches require restructuring each gate's question text, creating 12 different editing judgments (where to truncate, how to abbreviate, whether the existing content already contains run context).

2. **Consistent visual anchor.** Every gate gets the same footer shape. The user learns one pattern: glance at the bottom line. In multi-gate sessions, the prefix approach front-loads 40 identical characters on every prompt, pushing the actual decision content rightward. The suffix keeps decision content at the top where it belongs.

3. **Combines with centralized rule.** The ai-modeling-minion's DRY insight is correct -- state the rule once near the existing `header` constraint. A suffix convention is trivial to state as a universal rule: "every `question` field ends with `\n\nRun: $summary`". A prefix convention requires more complex instructions about how to restructure each gate's content.

4. **`header` + structured card already provide top-of-prompt context.** The ux-strategy-minion's "orientation first" argument assumes the user has no other context at the top. In practice, every gate has: (a) a structured card above the prompt (TEAM:, APPROVAL GATE:, SECURITY FINDING:, etc.) and (b) a `header` field (P4 Gate, P5 Security, etc.). The run identifier is not the only orientation signal -- it supplements what already exists.

5. **AskUserQuestion supports multiline.** The P4 Gate reject-confirmation question already uses multiline formatting (dependent task list), confirming `\n\n` renders correctly.

### Conflict Resolution: Hybrid approach for gate-level edits

- **ai-modeling-minion**: Centralized rule only, update 2-3 gates explicitly.
- **devx-minion**: Update all 12 gates explicitly in the spec.

**Resolution: Centralized rule + explicit updates for gates with literal strings or missing context.** The centralized rule handles the majority. Explicit edits are needed only for gates whose `question` specs use full literal strings that the LLM would reproduce verbatim (post-exec, calibrate, PR, existing PR, confirm) or that lack context entirely (post-exec).

### Task 1: Update SKILL.md with run-title convention and gate edits

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This is the sole deliverable of the plan. It modifies the nefario orchestration specification, which governs all future orchestration sessions. The change is easy to reverse (single file, additive text) but has high blast radius (affects every future gate interaction). MUST gate per the classification matrix.
- **Prompt**: |
    ## Task: Add run-title convention and update gate specifications in SKILL.md

    **File**: `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

    You are editing the nefario orchestration skill specification. The goal is
    to ensure every AskUserQuestion gate includes the orchestration run title
    (`$summary`) so the user can identify which run they are deciding on --
    critical for parallel nefario sessions in different terminals.

    ### What to do

    **Step 1: Add centralized convention note** (after existing line 503-504)

    Add a new convention note immediately after the existing AskUserQuestion
    `header` constraint. The current text at line 503-504 is:

    ```
    > Note: AskUserQuestion `header` values must not exceed 12 characters.
    > The `P<N> <Label>` convention reserves 3-5 chars for the phase prefix.
    ```

    Add this new note immediately after:

    ```
    > **Run-title convention**: Every AskUserQuestion `question` field must end
    > with `\n\nRun: $summary` on a dedicated trailing line. This ensures the
    > user can identify which orchestration run a gate belongs to, even when the
    > status line is hidden by the AskUserQuestion prompt. The `$summary` value
    > is established in Phase 1 and capped at 40 characters.
    ```

    **Step 2: Update gates with literal-string questions**

    The centralized convention handles most gates. But gates whose `question`
    spec uses a full literal string need explicit updates so the LLM does not
    reproduce the literal verbatim without the trailing line.

    Update these gates:

    1. **Post-exec gate** (line ~1477): The worst offender -- zero context.
       Change from:
       ```
       - `question`: "Post-execution phases for this task?"
       ```
       To:
       ```
       - `question`: "Post-execution phases for Task N: <task title>?\n\nRun: $summary"
       ```
       This adds BOTH task-level context (which task's post-execution) AND
       run-level context. The task title comes from the P4 Gate that was just
       approved -- the executing agent knows which task.

    2. **P4 Calibrate gate** (line ~1541): Currently a full literal.
       Change from:
       ```
       - `question`: "5 consecutive approvals without changes. Gates well-calibrated?"
       ```
       To:
       ```
       - `question`: "5 consecutive approvals without changes. Gates well-calibrated?\n\nRun: $summary"
       ```

    3. **PR gate** (line ~1869): Currently a full literal with slug.
       Change from:
       ```
       - `question`: "Create PR for nefario/<slug>?"
       ```
       To:
       ```
       - `question`: "Create PR for nefario/<slug>?\n\nRun: $summary"
       ```

    4. **Existing PR gate** (line ~2061): Currently a full literal.
       Change from:
       ```
       - `question`: "PR #<existing-pr> exists on this branch. Update its description with this run's changes?"
       ```
       To:
       ```
       - `question`: "PR #<existing-pr> exists on this branch. Update its description with this run's changes?\n\nRun: $summary"
       ```

    5. **Confirm (reject) gate** (line ~1501): This gate has a multi-line
       formatted question string. Add the `Run:` line at the very end of the
       formatted block. The current spec shows a fenced code block for the
       question format. Add `\n\nRun: $summary` as the last line inside that
       format, after the "Alternative:" line. The result should look like:

       ```
       Reject <task title>?

       Dependent tasks that will also be dropped:
         Task N: <title> -- <1-sentence deliverable description>
         Task M: <title> -- <1-sentence deliverable description>

       Alternative: Select "Cancel" then choose "Request changes" for a less drastic revision.

       Run: $summary
       ```

    **Step 3: Add `$summary` to compaction checkpoint focus strings**

    This ensures `$summary` survives context compaction so the convention
    can be applied in later phases.

    1. **Phase 3 compaction** (line ~811): The current focus string is:
       ```
       Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, scratch directory path.
       ```
       Add `$summary` to the preserve list. Insert it after "branch name":
       ```
       Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, $summary, scratch directory path.
       ```

    2. **Phase 3.5 compaction** (line ~1194): The current focus string is:
       ```
       Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, scratch directory path.
       ```
       Add `$summary` to the preserve list. Insert it after "branch name":
       ```
       Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, $summary, scratch directory path.
       ```

    ### What NOT to do

    - Do NOT modify `header` fields. They stay as-is (12-char cap, phase identity).
    - Do NOT rewrite question content for gates that use template-style specs
      (e.g., `<1-sentence task summary>`, `the one-sentence finding description`).
      The centralized convention handles these -- the LLM will apply the rule.
    - Do NOT add a template variable like `$run_line`. SKILL.md is not a template
      engine. The convention is an instruction, not a variable substitution.
    - Do NOT modify any AskUserQuestion `options` -- only `question` fields change.
    - Do NOT change anything outside the AskUserQuestion specifications and
      compaction focus strings.

    ### Context

    The AskUserQuestion `question` field renders as a terminal prompt. Multiline
    is supported (confirmed by the P4 reject-confirmation gate which already uses
    multiline formatting). The `\n\n` creates a blank line separating the gate
    decision content from the run identifier footer.

    The `$summary` variable is established in Phase 1 (max 40 characters,
    natural language). It is the same identifier shown in the status line.
    Using it in gates creates consistency across all user-facing run identity.

    ### Deliverables

    - Updated `skills/nefario/SKILL.md` with:
      1. Centralized run-title convention note (after line 503-504)
      2. Five gate `question` field updates (post-exec, calibrate, PR, existing PR, confirm)
      3. Two compaction focus string updates (Phase 3, Phase 3.5)

    ### Success criteria

    - The convention note appears immediately after the existing `header`
      constraint note.
    - All 5 literal-string gates show `\n\nRun: $summary` in their question spec.
    - The post-exec gate question additionally includes `Task N: <task title>`.
    - Both compaction focus strings include `$summary`.
    - No other content in SKILL.md is changed.
    - The file is valid markdown after all edits.

- **Deliverables**: Updated `skills/nefario/SKILL.md` with convention note, 5 gate updates, and 2 compaction updates.
- **Success criteria**: All 12 gates will produce a `Run: $summary` trailing line (5 via explicit spec, 7 via centralized convention). Both compaction focus strings preserve `$summary`.

### Cross-Cutting Coverage

- **Testing** (test-minion): Not included. This is a specification-only change (editing a markdown file). No executable code, no configuration, no infrastructure. Testing is covered by the Phase 5/6 post-execution pipeline which will verify the edits are syntactically correct and consistent.
- **Security** (security-minion): Not included. No attack surface, no auth, no user input handling, no secrets, no new dependencies. The change adds display text to terminal prompts.
- **Usability -- Strategy** (ux-strategy-minion): Covered. The ux-strategy-minion participated in Phase 2 planning. Their core recommendation ($summary as identifier, orientation-first) is adopted. The suffix vs. prefix conflict was resolved in favor of suffix with documented rationale.
- **Usability -- Design** (ux-design-minion, accessibility-minion): Not included. No user-facing interfaces are produced. The change modifies a specification that governs terminal text prompts, not visual UI.
- **Documentation** (software-docs-minion / user-docs-minion): Not included for execution. The SKILL.md IS the documentation -- the task directly updates it. No separate documentation artifact is needed. Phase 8 post-execution will evaluate whether the user guide needs a note about the run-title convention.
- **Observability** (observability-minion, sitespeed-minion): Not included. No runtime components, no services, no APIs. Pure specification change.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none -- the plan produces no UI components (no ux-design-minion), no web-facing HTML (no accessibility-minion), no web runtime code (no sitespeed-minion), fewer than 2 runtime components (no observability-minion), no end-user-visible changes (no user-docs-minion).
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

1. **Suffix vs. prefix placement**: devx-minion (suffix) vs. ux-strategy-minion (prefix) vs. ai-modeling-minion (bracket prefix). Resolved in favor of suffix. See detailed rationale above. The ux-strategy-minion's orientation-first argument is valid but outweighed by: (a) existing top-of-prompt context from headers and structured cards, (b) suffix's zero-rewrite simplicity, (c) visual noise reduction in multi-gate sessions.

2. **Centralized-only vs. explicit-all-12**: ai-modeling-minion (centralized + 2-3 explicit) vs. devx-minion (all 12 explicit). Resolved as hybrid: centralized convention + 5 explicit updates for literal-string gates. The ai-modeling-minion is right that a centralized rule is DRYer and more maintainable. The devx-minion is right that literal-string gates need explicit updates because the LLM may reproduce them verbatim. The compromise updates the 5 gates with full literal strings and relies on the convention for the 7 gates with template-style specs.

3. **Gate count (11 vs. 12)**: devx-minion identified 12 gates (including the Confirm reject-confirmation gate). The original task said 11. The Confirm gate IS a separate AskUserQuestion call and DOES need run context. Resolved: 12 gates total.

4. **ux-strategy-minion's truncation rule**: The ux-strategy-minion proposed an 80-char soft limit with truncation of gate content. This is not adopted because: (a) the suffix approach puts the run identifier on its own line, so combined length is not an issue, (b) truncation of gate content could lose decision-critical information, (c) `$summary` is already capped at 40 chars. No truncation rule is needed with the suffix convention.

5. **ux-strategy-minion's P1/P3.5 simplification**: The ux-strategy-minion proposed replacing the P1 Team and P3.5 Review question content entirely with just `$summary`. Not adopted -- the existing question content serves a different function (gate-specific decision context) even when it overlaps with `$summary`. The centralized convention simply appends the `Run:` line, preserving all existing content unchanged.

### Risks and Mitigations

1. **LLM drift in late phases** (from ai-modeling-minion): The LLM may forget the centralized convention after context compaction. Mitigation: `$summary` added to compaction focus strings (Step 3 of the task). Additionally, the status file writes throughout execution repeatedly reference `$summary`, providing natural reinforcement.

2. **Near-duplication in early gates** (from devx-minion): P1 Team's question is `<1-sentence task summary>` which may closely match `$summary`. The `Run:` trailing line could feel redundant. Mitigation: This is acceptable -- the label "Run:" provides certainty about what the text represents, and consistency across all 12 gates matters more than eliminating cosmetic overlap in 2-3 of them. Single-session users learn to ignore it; multi-session users depend on it.

3. **No runtime enforcement** (from ai-modeling-minion): AskUserQuestion has no server-side validation that `question` ends with the run line. If the LLM omits it, the gate renders without context. Mitigation: This is inherent to SKILL.md as a prompt-based spec. The centralized convention + compaction preservation + status file reinforcement are the available mitigations. Acceptance criterion: convention followed in >90% of gates across sessions.

4. **$summary immutability** (from ux-strategy-minion): If `$summary` could change mid-session, gates would show inconsistent identifiers. Mitigation: `$summary` is established in Phase 1 and the spec does not provide a mechanism to change it. This is already enforced by convention.

### Execution Order

```
Batch 1 (single task):
  Task 1: devx-minion -- Update SKILL.md (convention + gates + compaction)
    -> APPROVAL GATE after completion

Post-execution: Phase 5 (code review), Phase 6 (tests -- likely skipped, no executable code), Phase 8 (docs evaluation)
```

### Verification Steps

1. Count AskUserQuestion occurrences in SKILL.md -- should be unchanged (no new gates added).
2. Verify the convention note appears after line 503-504's header constraint.
3. Verify all 5 literal-string gate questions end with `\n\nRun: $summary`.
4. Verify the post-exec gate question includes `Task N: <task title>`.
5. Verify both compaction focus strings include `$summary`.
6. Verify no other SKILL.md content was changed (diff should show only the expected additions).
