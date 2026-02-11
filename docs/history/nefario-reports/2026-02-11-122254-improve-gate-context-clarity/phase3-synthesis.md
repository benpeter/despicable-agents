# Delegation Plan

**Team name**: improve-gate-context
**Description**: Enhance gate output formatting across nefario orchestration to include inline context summaries, structured artifact references, and structured escalation formats so users can make informed decisions without opening scratch files.

## Synthesis Notes

### Specialist Consensus

All three specialists agree on the core diagnosis: the mid-execution decision brief (Gate 2) is the highest-impact gap because DELIVERABLE shows only a file path, forcing blind approvals. They also agree that:
- SKILL.md is the operational source of truth; all changes flow from it
- The artifact summary pattern (file paths + line deltas + plain-language summary) is the right intervention
- Post-execution escalation formats (security BLOCK, code review BLOCK, impasse) need structured definitions
- Update order must be: SKILL.md -> AGENT.overrides.md -> AGENT.md -> docs/orchestration.md

### Scope Decisions

The ux-strategy-minion identified 9 distinct gates. I am consolidating these into 3 execution tasks based on file ownership and dependency:

1. **SKILL.md update** (all gate formats live here): Covers Gates 1-9 from the ux-strategy analysis. This is one file with one agent -- splitting it across agents would violate file ownership.
2. **AGENT.overrides.md + AGENT.md sync** (nefario agent knowledge): Only the Decision Brief Format and Approval Gates sections need updating. These are subsets of the SKILL.md changes.
3. **docs/orchestration.md update** (architecture documentation): Section 3 needs to reflect the enhanced formats.

### What I Am NOT Including

- **Report template (TEMPLATE.md)**: software-docs-minion noted this may be a no-op. The gate brief format in reports is a summarized version (outcome + confidence + rationale). The enhancements add context fields that are useful at decision time but not for historical record. The existing report format already captures Decision, Rationale, and Rejected alternatives. No changes needed.
- **Post-execution phase selection contextualization (Gate 3)**: ux-strategy-minion proposed contextualizing options per deliverable type. This changes runtime behavior (suppressing non-applicable options, adding time estimates), which is gate logic, not gate formatting. Out of scope per the issue: "No change to the number or purpose of gates."
- **Calibration check data (Gate 5)**: ux-strategy-minion suggested summarizing what was gated. Low severity, and the current format is adequate. Omitting to stay minimal.
- **Agent completion message restructuring**: devx-minion proposed structured artifact summaries in agent completion messages. This is a good idea but changes agent behavior, not gate formatting. The gate format enhancement can reference "file paths and summary from the producing agent's completion message" without mandating a new message schema. The producing agent already includes file paths -- the gate format just needs to specify that this information goes into the DELIVERABLE section.

### Conflict Resolutions

No real conflicts between specialists. Minor alignment needed:
- **DELIVERABLE position**: devx-minion recommends moving DELIVERABLE above RATIONALE. ux-strategy-minion keeps it below IMPACT. I am adopting devx-minion's recommendation -- the user thinks "What is the decision?" then "What did it produce?" then "Why?" This is a better cognitive flow. DELIVERABLE moves to after DECISION, before RATIONALE.
- **Line budget**: devx-minion proposes 12-18 lines for mid-exec gates. ux-strategy-minion suggests 15-25. I am using devx-minion's 12-18 as the target (with the existing soft ceiling principle). The enhanced format with artifact summary naturally fits in ~15-20 lines.
- **Security escalation format**: ux-strategy-minion proposes a full structured format with AskUserQuestion options. The SKILL.md currently says "max 5-line escalation brief" but has no structured format. I am adopting ux-strategy's structured format but keeping it within the 5-line content constraint, with the AskUserQuestion providing the options structure.

---

## Task 1: Update gate formats in SKILL.md

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: SKILL.md is the operational source of truth for all gate formats. All downstream files derive from it. Changes here propagate to AGENT.md and docs. Hard to reverse (format changes affect all future orchestrations) with 2 downstream dependents (Tasks 2 and 3).
- **Prompt**: |
    You are updating gate output formats in the nefario orchestration skill file.
    Your goal: add enough inline context to every gate that users can make informed
    decisions without opening scratch files or deliverable files.

    ## File to Edit
    `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    Read the full file first. Then make the following targeted edits:

    ### Edit 1: Execution Plan Approval Gate (around line 594-667)

    Add two lines to the "Instant orientation" section:
    - A `REQUEST:` line echoing the truncated original prompt (max 80 chars, with "...")
    - A `WORKING DIR:` line showing the scratch directory path

    The updated format should be:
    ```
    EXECUTION PLAN: <1-sentence goal summary>
    REQUEST: "<truncated original prompt, max 80 chars>..."
    Tasks: N | Gates: N | Advisories incorporated: N
    Working dir: $SCRATCH_DIR/{slug}/
    ```

    Also add a description label to the FULL PLAN reference line:
    ```
    FULL PLAN: $SCRATCH_DIR/{slug}/phase3-synthesis.md (task prompts, agent assignments, dependencies)
    ```

    ### Edit 2: Mid-Execution Decision Brief (around line 781-797)

    This is the highest-impact change. Replace the current decision brief format with:
    ```
    APPROVAL GATE: <Task title>
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
    ```

    Key changes from current format:
    - DELIVERABLE moves UP, between DECISION and RATIONALE (user flow: what is it? -> what did it produce? -> why?)
    - DELIVERABLE expands from bare path to artifact summary block (file list with change scope descriptions, line deltas, and a 1-2 sentence Summary line)
    - RATIONALE uses `Rejected:` prefix on the alternative bullet for visual distinction
    - Maximum 5 files listed in DELIVERABLE; if more, show top 4 + "and N more files"
    - If a gate depends on a prior approved gate, the DECISION line must restate the dependency: "Builds on <prior decision description> approved in Task N."

    Also update the field definitions below the format to explain the enhanced DELIVERABLE section.

    Add a line budget note: "Target 12-18 lines for mid-execution gates (soft ceiling; clarity wins over brevity)."

    ### Edit 3: Agent Completion Message (around line 757-761)

    Update the instruction that agents receive at the end of their prompts. Change:
    ```
    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead summarizing what you produced and
    where the deliverables are. Include file paths.
    ```
    To:
    ```
    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead with:
    - File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
    - 1-2 sentence summary of what was produced
    This information populates the gate's DELIVERABLE section.
    ```

    ### Edit 4: Security BLOCK Escalation (around line 946-947)

    The current text says "SHOW: max 5-line escalation brief" with no structured format.
    Replace with a structured format that fits within 5 content lines plus AskUserQuestion:

    ```
    SECURITY FINDING: <title>
    Severity: CRITICAL | HIGH | MEDIUM | File: <path>:<line-range>
    Finding: <one-sentence description>
    Proposed fix: <one-sentence description of what auto-fix will do>
    Risk if unfixed: <one-sentence consequence>
    ```

    Then present using AskUserQuestion:
    - `header`: "Security"
    - `question`: the one-sentence finding description
    - `options` (4, `multiSelect: false`):
      1. label: "Proceed with auto-fix", description: "Apply the proposed fix automatically." (recommended)
      2. label: "Review first", description: "Show the affected code before deciding."
      3. label: "Fix manually", description: "Pause orchestration. You fix the code, then resume."
      4. label: "Accept risk", description: "Proceed without fixing. Document as known risk."

    ### Edit 5: Code Review BLOCK Escalation (around line 948-963)

    Expand the VERIFICATION ISSUE format to include code context and fix history:

    ```
    VERIFICATION ISSUE: <title>
    Phase: Code Review | Agent: <reviewer> | Severity: HIGH | MEDIUM | LOW
    Finding: <one-sentence description>
    Producing agent: <who wrote the code> | File: <path>:<line-range>

    CODE CONTEXT (max 5 lines):
      <relevant code lines with the issue>

    FIX HISTORY:
      Round 1: <what was attempted, why it didn't resolve>
      Round 2: <what was attempted, why it didn't resolve>

    Risk if accepted: <one-sentence consequence>
    ```

    Add a secret scanning rule: "Before including code in an escalation brief, scan
    for credential patterns (sk-, AKIA, ghp_, token:, password:, BEGIN.*PRIVATE KEY).
    If matched, replace snippet with: 'Code omitted (potential secret). Review: <path>:<lines>'"

    Also rename "Skip verification" option to "Skip remaining checks" and update its
    description to: "Skip all remaining code review and test phases."

    ### Edit 6: BLOCK Impasse Escalation (after the revision loop, around line 563-565)

    The current text says "Present the impasse to the user with all reviewer positions
    and let the user decide how to proceed." Replace with a structured format:

    ```
    PLAN IMPASSE: <one-sentence description of the disagreement>
    Revision rounds: 2 of 2 exhausted

    POSITIONS:
      [<reviewer-1>] BLOCK: <one-sentence position>
        Concern: <what they believe will go wrong>
      [<reviewer-2>] BLOCK: <one-sentence position>
        Concern: <what they believe will go wrong>
      [other reviewers]: <summary of APPROVE/ADVISE verdicts>

    CONFLICT ANALYSIS: <nefario's synthesis of why positions are incompatible>

    Full context: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md
    ```

    Then present using AskUserQuestion:
    - `header`: "Impasse"
    - `question`: the one-sentence disagreement description
    - `options` (4, `multiSelect: false`):
      1. label: "Override blockers", description: "Accept the plan despite unresolved concerns."
      2. label: "Provide direction", description: "Give your own guidance to resolve the conflict."
      3. label: "Restart planning", description: "Re-run synthesis with additional constraints."
      4. label: "Abandon", description: "Cancel this orchestration."

    ### Edit 7: PR Creation Prompt (around line 1098-1127)

    Enhance the PR creation prompt to include change summary context. Update the
    AskUserQuestion section to show:

    ```
    PR: Create PR for nefario/<slug>?
    Branch: nefario/<slug>
    Commits: N | Files changed: N | Lines: +N/-M
      <file path 1> (+N/-M)
      <file path 2> (+N/-M)
      ... (max 5 files, then "and N more")
    ```

    Add instructions: Before presenting the PR gate, run `git diff --stat` (or
    `git diff --stat origin/<default-branch>...HEAD` if on a feature branch) and
    `git rev-list --count origin/<default-branch>..HEAD` to populate commit count,
    file count, and line deltas. If verification had accepted-as-is findings, append
    a line: "Note: N verification findings accepted as-is (see report)."

    ### Edit 8: Reject Confirmation (around line 833-841)

    Expand the reject confirmation to include:
    - Dependent task descriptions (not just titles)
    - A reminder that "Request changes" is available as an alternative

    Update the format to:
    ```
    Reject <task title>?

    Dependent tasks that will also be dropped:
      Task N: <title> -- <1-sentence deliverable description>
      Task M: <title> -- <1-sentence deliverable description>

    Alternative: Select "Cancel" then choose "Request changes" for a less drastic revision.
    ```

    ## What NOT to Do
    - Do not change gate logic, add new gates, or remove existing gates
    - Do not modify AskUserQuestion option labels or the number of options (except where explicitly specified above for security escalation, impasse, and existing option renames)
    - Do not change the Communication Protocol SHOW/NEVER SHOW/CONDENSE lists
    - Do not modify Phase structure, ordering, or skip conditions
    - Do not change the scratch directory structure or file naming
    - Do not restructure sections or move content between sections (only edit within existing sections)
    - Keep all existing content that is not explicitly being modified

    ## Deliverables
    Updated `skills/nefario/SKILL.md` with all 8 gate format enhancements.

    ## Success Criteria
    - Every gate format includes inline context sufficient to make decisions without opening files
    - Existing gate logic (APPROVE/ADVISE/BLOCK) is unchanged
    - AskUserQuestion parameters are unchanged except where explicitly modified
    - Security and code review escalations have structured formats with code context
    - Impasse escalation has a structured format with decision options
    - PR creation includes change summary stats
    - Line budgets are documented for all gate types

- **Deliverables**: Updated `skills/nefario/SKILL.md`
- **Success criteria**: All 8 edits applied; gate logic unchanged; formats include inline context

---

## Task 2: Sync AGENT.overrides.md and rebuild AGENT.md

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are synchronizing the nefario agent knowledge base with updated gate formats.

    ## Context
    The gate format templates in `skills/nefario/SKILL.md` have been updated (Task 1).
    Two nefario files contain copies of the Decision Brief Format that must match:
    - `nefario/AGENT.overrides.md` (the override layer -- this is what you edit)
    - `nefario/AGENT.md` (the deployed agent -- also needs manual sync)

    ## Files to Edit
    1. `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.overrides.md`
    2. `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md`

    ## Reference File (source of truth -- read this first)
    `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    ## Instructions

    ### Step 1: Read the updated SKILL.md

    Read the updated `skills/nefario/SKILL.md` to understand the new gate formats:
    - The enhanced mid-execution Decision Brief (DELIVERABLE moved up, artifact summary block)
    - The line budget (12-18 lines target for mid-exec gates)

    ### Step 2: Update AGENT.overrides.md

    Edit the `## Approval Gates` section in `nefario/AGENT.overrides.md`.
    Specifically, update the `### Decision Brief Format` subsection:

    - Replace the current Decision Brief Format code block with the enhanced format
      from SKILL.md (DELIVERABLE between DECISION and RATIONALE, artifact summary
      block with file paths + change scope + line deltas + Summary line, Rejected:
      prefix on alternative bullets)
    - Update the field definitions below the format to match SKILL.md's updated definitions
    - Add the DELIVERABLE expanded definition: "File paths with change scope, line
      deltas, and a 1-2 sentence summary. Maximum 5 files listed. Answers: what am
      I agreeing went into the codebase?"
    - Remove the old `Reply: approve / request changes / reject / skip` line from
      the format block (this is handled by AskUserQuestion in SKILL.md)

    Do NOT change:
    - Gate Classification section (unchanged)
    - Response Handling section (unchanged)
    - Anti-Fatigue Rules section (unchanged)
    - Cascading Gates section (unchanged)
    - Gate vs. Notification section (unchanged)
    - Any section outside `## Approval Gates`

    ### Step 3: Update AGENT.md

    Read `nefario/AGENT.md` and find the identical `### Decision Brief Format`
    subsection (around line 251-287). Apply the exact same changes as Step 2.

    The AGENT.md has a nearly identical copy of the Approval Gates section.
    Ensure the Decision Brief Format in AGENT.md matches the one you wrote
    in AGENT.overrides.md exactly.

    ## What NOT to Do
    - Do not rewrite entire sections -- make targeted edits to the Decision Brief Format only
    - Do not modify gate logic, response handling, or anti-fatigue rules
    - Do not touch sections outside Approval Gates
    - Do not change YAML frontmatter in AGENT.md
    - Do not modify AGENT.generated.md (it is a build output)

    ## Deliverables
    Updated `nefario/AGENT.overrides.md` and `nefario/AGENT.md` with the enhanced
    Decision Brief Format matching SKILL.md.

    ## Success Criteria
    - The Decision Brief Format code block in both files matches the SKILL.md format
    - The field definitions are updated to include the DELIVERABLE expansion
    - No other sections are modified
    - The `Reply:` line is removed from the format block (replaced by AskUserQuestion)

- **Deliverables**: Updated `nefario/AGENT.overrides.md` and `nefario/AGENT.md`
- **Success criteria**: Decision Brief Format matches SKILL.md in both files; no other sections changed

---

## Task 3: Update docs/orchestration.md gate documentation

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating the architecture documentation to reflect enhanced gate formats.

    ## Context
    The gate format templates in `skills/nefario/SKILL.md` have been updated (Task 1).
    The architecture documentation in `docs/orchestration.md` describes these formats
    for human readers and must be synchronized.

    ## File to Edit
    `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md`

    ## Reference File (source of truth -- read this first)
    `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    ## Instructions

    Read the updated `skills/nefario/SKILL.md` to understand the new gate formats.
    Then read `docs/orchestration.md` Section 3 (starts around line 334).

    Update the following subsections:

    ### Update 1: "Execution Plan Approval Gate" (around line 344-368)

    Add the `REQUEST:` and `Working dir:` lines to the format description.
    In the bullet list under "Key sections:", add:
    - **Original request echo** -- One-line truncated echo of the user's original prompt for alignment verification
    - **Working directory** -- Path to scratch directory for browsing all planning artifacts

    Update the FULL PLAN reference description to include the parenthetical label.

    ### Update 2: "Decision Brief Format (Mid-Execution)" (around line 384-410)

    This is the main update. Replace the CLI format example with the enhanced version:
    - DELIVERABLE between DECISION and RATIONALE
    - Artifact summary block (file paths + change scope + line deltas + Summary)
    - Rejected: prefix on alternative bullets

    Update the Layer descriptions:
    - Layer 1 (5-second scan): One-sentence decision description -- unchanged
    - Layer 1.5 (10-second scan): Deliverable summary with files changed, scope, and line deltas -- NEW
    - Layer 2 (30-second read): Rationale with rejected alternatives -- unchanged
    - Layer 3 (deep dive): Full deliverable at file path -- unchanged

    Add the line budget: "Target 12-18 lines for mid-execution gates (soft ceiling)."

    ### Update 3: "Response Handling (Mid-Execution)" (around line 412-421)

    Update the **Reject** bullet to mention that the confirmation prompt includes
    dependent task descriptions (not just titles) and a "Request changes" alternative reminder.

    No other changes to response handling.

    ## What NOT to Do
    - Do not restructure Section 3 or change its subsection organization
    - Do not add new subsections for security escalation, code review escalation, or impasse formats (these are Phase 5 operational details, not architecture documentation -- they belong in SKILL.md only)
    - Do not modify Sections 1, 2, 4, or 5
    - Do not change cross-references to SKILL.md
    - Keep the document's voice and style consistent with existing prose

    ## Deliverables
    Updated `docs/orchestration.md` Section 3 reflecting the enhanced gate formats.

    ## Success Criteria
    - Execution Plan Approval Gate description includes REQUEST and Working dir
    - Decision Brief Format example matches the enhanced SKILL.md format
    - Layer descriptions include the new Layer 1.5
    - Line budget is documented
    - Reject confirmation description is updated
    - No changes outside Section 3

- **Deliverables**: Updated `docs/orchestration.md`
- **Success criteria**: Section 3 reflects enhanced formats; no changes outside Section 3

---

## Cross-Cutting Coverage

| Dimension | Coverage | Justification |
|-----------|----------|---------------|
| **Testing** | Not applicable | All changes are markdown specification files. No executable code produced. Phase 6 would find no test infrastructure. |
| **Security** | Addressed inline | Edit 5 in Task 1 adds a secret scanning rule for code snippets in escalation briefs. No new attack surface created (spec files only). |
| **Usability -- Strategy** | ux-strategy-minion contributed to planning | Gate context was the ux-strategy-minion's primary planning domain. All recommendations incorporated in Task 1. |
| **Usability -- Design** | Not applicable | No user-facing interfaces produced. These are internal specification documents consumed by an LLM orchestrator. |
| **Documentation** | Task 3 | docs/orchestration.md is updated as the final task. software-docs-minion contributed to planning and owns Tasks 2-3. |
| **Observability** | Not applicable | No runtime components produced. |

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no UI, no web-facing output)

## Conflict Resolutions

| Conflict | Resolution | Rationale |
|----------|-----------|-----------|
| DELIVERABLE position (devx: before RATIONALE vs ux-strategy: after IMPACT) | Adopted devx-minion's position: DELIVERABLE after DECISION, before RATIONALE | Better cognitive flow: "What? -> What did it produce? -> Why?" matches user's mental model when evaluating a gate |
| Line budget for mid-exec gates (devx: 12-18 vs ux-strategy: 15-25) | Adopted devx-minion's 12-18 as target | The enhanced format naturally fits ~15-18 lines. 25-line ceiling is too generous -- it approaches the plan approval gate's budget and risks approval fatigue |
| Post-execution phase selection contextualization (ux-strategy: contextualize options per deliverable) | Excluded from scope | Changes runtime behavior (option suppression, time estimates). The issue says "No change to the number or purpose of gates -- only the information presented at each one." Option suppression changes gate purpose. |

## Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Three-way sync drift (SKILL.md, AGENT.overrides.md, AGENT.md) | Medium | Task 2 explicitly syncs both files. Verification step confirms Decision Brief Format is identical across all three. |
| Artifact summaries increase agent message size | Low | Structured format is simple (path + parenthetical + delta). Agents already produce this info; change makes it structured. Graceful degradation: if agent omits summary, gate falls back to bare file paths. |
| Code snippets in escalation briefs may expose secrets | Medium | Secret scanning rule added in Task 1 Edit 5. Matches are replaced with safe placeholder text. |
| Line deltas require git state that may not exist | Low | New files use `wc -l`. Modified files use `git diff --stat`. If unavailable, omit delta. Format degrades gracefully to current behavior. |
| Enhanced format increases gate output length | Low | Line budgets documented (12-18 for mid-exec, 25-40 for plan approval). The enhancement adds ~5-8 lines to mid-exec gates (from ~10-12 to ~15-18). Within budget. |

## Execution Order

```
Batch 1: Task 1 (SKILL.md - all gate formats) [GATE]
  |
  v -- user approves gate --
  |
Batch 2: Task 2 (AGENT.overrides.md + AGENT.md sync) + Task 3 (docs/orchestration.md)
         [parallel, no gates]
```

## Verification Steps

After all tasks complete:
1. Confirm the mid-execution Decision Brief Format code block is identical in SKILL.md, AGENT.overrides.md, and AGENT.md
2. Confirm docs/orchestration.md Section 3 reflects the enhanced formats (REQUEST line, Layer 1.5, DELIVERABLE position)
3. Confirm no gate logic has changed (same AskUserQuestion options, same response handling, same skip conditions) except for the 3 newly structured escalation formats
4. Confirm no changes outside the targeted sections in each file
