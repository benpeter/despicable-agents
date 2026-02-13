# Delegation Plan

**Team name**: phase-context-status-gates
**Description**: Add phase and task context to nefario status line and AskUserQuestion gates, closing the orientation gap where users lose "where am I?" awareness during orchestration.

## Conflict Resolutions

### 1. Gate header format: `P<N> Label` (devx/ux-strategy) over `Phase N -- Label` (ux-design)

Resolved in favor of `P<N> Label`. The 12-character AskUserQuestion header limit is a hard UI constraint. `Phase N -- Label` overflows for nearly every header (e.g., "Phase 3.5 -- Review" = 20 chars). The compact `P<N>` notation fits within 12 chars for all headers when combined with devx-minion's Option A overflow handling. ux-design's concern about explicitness is addressed by the phase announcements in the conversation stream that already use the full "Phase N: Name" format -- the gate header is a compact callback to that established context.

### 2. Status file format: `P<N> <Name> | <summary>` (ux-strategy) over alternatives

Resolved in favor of ux-strategy's format. devx's `P<N>: <summary>` loses the semantic phase label (users would see "P3:" with no clue what phase 3 is). ux-design's `Phase N: Name -- <summary>` is too long (20+ chars for the prefix alone). The ux-strategy format `P4 Execution | Build MCP server...` provides both the phase number and a human-readable label in ~16 chars, leaving room for the task summary.

### 3. Dark kitchen status updates: out of scope (respecting issue boundary)

The issue explicitly excludes "changes to post-execution dark kitchen phases". While ux-design correctly notes that status file writes are infrastructure (not conversation output), the scope boundary should be respected. Dark kitchen status updates can be addressed in a follow-up issue. The current plan covers Phases 1-4 and wrap-up only.

### 4. Task summary length: 40 characters (compromise)

ux-strategy recommended 32 chars; current is 48. With the phase prefix adding ~16 chars, the total nefario status segment becomes ~59 chars (prefix + " | " + 40 + "..."). This fits comfortably in the status line alongside `dir | model | Context: N%` for typical terminal widths. 40 chars preserves enough task context to be recognizable while accommodating the phase prefix.

### 5. Follow-up gates: no phase prefix (devx) -- accepted

devx-minion's recommendation to skip the `P<N>` prefix on follow-up gates (Post-exec, Confirm, PR, Existing PR) is sound. These gates always immediately follow a primary gate in the same interaction turn, so the user already has phase context. Adding prefixes would be redundant and waste the tight character budget.

### 6. Mid-execution gate task title in question field (devx)

devx-minion recommends prepending `Task N: <title> -- ` to the Gate question field. This is valuable: during Phase 4 with multiple tasks, the user needs to know WHICH task they are approving, not just what phase they are in. The header provides phase context; the question provides task context. Accepted.

### 7. Status file update timing: BEFORE phase announcement (ux-design) -- accepted

ux-design's recommendation to write the status file before the phase announcement marker ensures no window where both orientation channels are stale. This is a sequencing detail within the same task.

---

## Task 1: Update nefario SKILL.md -- phase-prefixed status file and gate headers

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating `skills/nefario/SKILL.md` to add phase context to the
    status line and AskUserQuestion gate headers. This closes an orientation
    gap where users lose "where am I?" awareness during nefario orchestration.

    ## Context

    The nefario orchestration skill has a status file mechanism
    (`/tmp/nefario-status-$SID`) that shows task context in the Claude Code
    status line. Currently the file is written ONCE at orchestration start
    (Phase 1, lines 362-368) and never updated. AskUserQuestion gates use
    generic single-word headers ("Team", "Gate", "Plan") with no phase context.

    The status line is hidden during AskUserQuestion prompts, and the gate
    headers have no phase info -- so users lose orientation in both UI states.

    ## Changes Required

    ### A. Phase-prefixed status file writes at every phase boundary

    **Format**: `P<N> <Name> | <summary>`

    Phase-to-label mapping:
    - P1 Meta-Plan
    - P2 Planning
    - P3 Synthesis
    - P3.5 Review
    - P4 Execution

    Examples:
    - `P1 Meta-Plan | Build MCP server with OAuth support...`
    - `P2 Planning | Build MCP server with OAuth support...`
    - `P4 Execution | Build MCP server with OAuth support...`

    **Summary length**: Change the truncation from 48 characters to 40
    characters. Update the character budget math at line 363:
    - Old: "Truncate to 48 characters; if truncated, append '...' (so 'Nefario: ' 9-char prefix + 48 + 3 = 60 chars max)"
    - New: "Truncate to 40 characters; if truncated, append '...' (prefix ~16 chars + ' | ' 3 chars + 40 + 3 = ~62 chars max)"

    **Where to add writes**: At each phase boundary, BEFORE the phase
    announcement marker (the `**--- Phase N: Name ---**` line). The sequence
    at every phase boundary must be:
    1. Write status file (silent shell command)
    2. Print phase announcement marker

    Specific locations in SKILL.md:
    1. **Phase 1** (lines 362-368): Refactor existing write to use the new
       format. The status write should use `P1 Meta-Plan | $summary`.
    2. **Phase 2 start**: Add a status write instruction before the Phase 2
       announcement marker. Use `P2 Planning | $summary`.
    3. **Phase 3 start**: Add a status write instruction. Use
       `P3 Synthesis | $summary`.
    4. **Phase 3.5 start**: Add a status write instruction. Use
       `P3.5 Review | $summary`.
    5. **Phase 4 start**: Add a status write instruction. Use
       `P4 Execution | $summary`.

    The write pattern at each boundary is:
    ```sh
    SID=$(cat /tmp/claude-session-id 2>/dev/null)
    echo "P<N> <Name> | $summary" > /tmp/nefario-status-$SID
    ```
    Do NOT extract this into a helper function -- inline it at each boundary.
    The SID lookup is cheap and keeping it inline makes each instruction
    self-contained and readable.

    **Mid-execution gate status update**: When presenting a Phase 4 approval
    gate, update the status file to reflect the gate state:
    ```
    P4 Gate | <gate task title, max 40 chars>
    ```
    After the gate is resolved (approved/rejected/skipped), revert to:
    ```
    P4 Execution | $summary
    ```
    Only primary gates trigger status updates -- follow-up gates (Post-exec,
    Confirm) do NOT update the status file.

    ### B. Phase-prefixed AskUserQuestion headers

    Update the `header` field of the 8 PRIMARY gates to use `P<N> <Label>` format.
    The 4 FOLLOW-UP gates keep their existing headers unchanged.

    Header mapping (all must be <= 12 characters):

    | Current Header | Proposed Header | Chars | Phase | Type |
    |---|---|---|---|---|
    | `"Team"` | `"P1 Team"` | 8 | 1 | Primary |
    | `"Review"` | `"P3.5 Review"` | 12 | 3.5 | Primary |
    | `"Impasse"` | `"P3 Impasse"` | 11 | 3.5 | Primary |
    | `"Plan"` | `"P3.5 Plan"` | 10 | 3.5 | Primary |
    | `"Gate"` | `"P4 Gate"` | 7 | 4 | Primary |
    | `"Calibrate"` | `"P4 Calibrate"` | 12 | 4 | Primary |
    | `"Security"` | `"P5 Security"` | 11 | 5 | Primary |
    | `"Issue"` | `"P5 Issue"` | 8 | 5 | Primary |
    | `"Post-exec"` | `"Post-exec"` | 9 | 4 | Follow-up (unchanged) |
    | `"Confirm"` | `"Confirm"` | 7 | 4 | Follow-up (unchanged) |
    | `"PR"` | `"PR"` | 2 | wrap-up | Follow-up (unchanged) |
    | `"Existing PR"` | `"Existing PR"` | 11 | wrap-up | Follow-up (unchanged) |

    Notes:
    - `"P3 Impasse"` drops the `.5` because "Impasse" only occurs in Phase 3.5
      -- the label is unambiguous. This saves 2 chars.
    - `"P3.5 Plan"` uses `P3.5` because the Plan gate sits at the Phase 3.5 /
      Phase 4 boundary after architecture review completes. Even though the plan
      was synthesized in Phase 3, the gate is presented after Phase 3.5 review.

    ### C. Task title in Phase 4 Gate question field

    For the mid-execution approval gate (header: "P4 Gate"), modify the
    `question` field specification. Currently (line 1285):
    ```
    question: the DECISION line from the brief
    ```
    Change to:
    ```
    question: "Task N: <task title>" followed by " -- " and the DECISION line
    ```
    Example: `Task 2: Add OAuth token refresh -- Accept token rotation strategy using refresh_token grant`

    This applies ONLY to the "P4 Gate" AskUserQuestion. Other gates keep
    their existing question format.

    ### D. Add a character limit note

    After the header mapping changes, add a brief inline comment or note
    near the first gate definition (Team Approval Gate section) documenting
    the constraint:
    ```
    Note: AskUserQuestion `header` values must not exceed 12 characters.
    The `P<N> <Label>` convention reserves 3-5 chars for the phase prefix.
    ```

    ## Files to modify

    - `skills/nefario/SKILL.md` -- all changes are in this single file

    ## What NOT to do

    - Do NOT modify despicable-statusline SKILL.md -- it reads the status
      file as-is and needs no changes
    - Do NOT add status writes for Phases 5-8 (dark kitchen) -- that is
      out of scope for this task
    - Do NOT change the phase announcement markers themselves (`**--- Phase N: Name ---**`)
    - Do NOT change the Visual Hierarchy section
    - Do NOT extract status writes into a shell helper function
    - Do NOT modify the wrap-up cleanup logic (line 1720 `rm -f /tmp/nefario-status-$SID`)
    - Do NOT change question text for any gate other than "P4 Gate"

    ## Verification

    After making changes:
    1. Confirm all 8 primary gate headers are <= 12 characters
    2. Confirm status file write instructions exist at Phases 1, 2, 3, 3.5, and 4 boundaries
    3. Confirm each status write comes BEFORE its corresponding phase announcement marker
    4. Confirm the Phase 4 Gate question format includes "Task N: <title> -- "
    5. Confirm the 4 follow-up gates (Post-exec, Confirm, PR, Existing PR) are unchanged
    6. Confirm the summary truncation is updated from 48 to 40 characters

- **Deliverables**: Updated `skills/nefario/SKILL.md` with phase-prefixed status file writes at all phase boundaries, phase-prefixed gate headers, task title in P4 Gate question, and character limit documentation note.
- **Success criteria**: All 8 primary gate headers use `P<N> Label` format and fit within 12 chars. Status file is updated at each phase boundary (1, 2, 3, 3.5, 4) with `P<N> <Name> | <summary>` format. Mid-execution gates update the status file. Phase 4 Gate question includes task title.

---

## Task 2: Update user-facing documentation in using-nefario.md

- **Agent**: user-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating `docs/using-nefario.md` to reflect that the nefario
    status line and approval gates now show the current orchestration phase.
    This is a documentation-only task -- the implementation changes are already
    done in SKILL.md (Task 1).

    ## Changes Required

    Three targeted edits to `docs/using-nefario.md`. All are small -- roughly
    5 changed lines total.

    ### A. Update "What Happens" introduction (line 100)

    Current text:
    ```
    Nefario follows a structured process: plan with specialists, review the plan, execute, then verify the results. Here is what you experience at each phase.
    ```

    Add one sentence about phase awareness:
    ```
    Nefario follows a structured process: plan with specialists, review the plan, execute, then verify the results. Here is what you experience at each phase. The status line and all approval prompts include the current phase, so you always know where you are in the process.
    ```

    ### B. Update "What It Shows" subsection (lines 188-193)

    Current text says the status bar appends "the task summary." Update to
    say it shows "the current phase and task summary" and that it "updates
    at each phase transition."

    Update the example from:
    ```
    ~/my-project | Claude Opus 4 | Context: 12% | Build MCP server with OAuth...
    ```
    To:
    ```
    ~/my-project | Claude Opus 4 | Context: 12% | P4 Execution | Build MCP server with OAuth...
    ```

    ### C. Update "How It Works" subsection (lines 195-197)

    Current text says nefario "writes a one-line task summary to
    `/tmp/nefario-status-<session-id>`." Change to say it writes "the current
    phase and a one-line task summary" and note the file "is updated at each
    phase transition" (not just written once at start).

    ## Writing guidelines

    - Document the EXPERIENCE, not the mechanism. Users need to know they
      will always see their current phase -- not the exact header format or
      status file content format.
    - Do NOT list specific gate header values (e.g., "P4 Gate") in the
      user guide. That is SKILL.md implementation detail.
    - Do NOT document the status file format (`P<N> <Name> | <summary>`)
      in the user guide. Users see the rendered status line, not the raw file.
    - Keep changes minimal. One sentence added, two subsections lightly revised.
    - Use representative but not overly specific examples so they do not
      become stale if the format evolves.

    ## Files to modify

    - `docs/using-nefario.md` -- single file, three small edits

    ## What NOT to do

    - Do NOT rewrite the Status Line section structure
    - Do NOT modify the manual configuration example (lines 199-217)
    - Do NOT modify the despicable-statusline SKILL.md
    - Do NOT add per-phase documentation of gate header formats
    - Do NOT document the technical status file format

    ## Verification

    After making changes, confirm:
    1. The "What Happens" intro mentions phase awareness in one added sentence
    2. The "What It Shows" example includes a phase prefix
    3. The "How It Works" text mentions phase transitions, not just initial write
    4. The manual configuration example is untouched
    5. No gate header format details appear in the user guide

- **Deliverables**: Updated `docs/using-nefario.md` with three targeted edits reflecting phase-aware status line and gate headers.
- **Success criteria**: User guide accurately describes the improved phase awareness experience without exposing implementation details. Manual configuration example is unchanged. Changes are ~5 lines total.

---

## Cross-Cutting Coverage

- **Testing**: No executable code produced. All changes are to SKILL.md (orchestration instructions) and using-nefario.md (documentation). No tests applicable. Phase 6 will verify no existing tests are broken by the branch.
- **Security**: No attack surface created. Changes are to documentation/specification files. No secrets, auth, or user input handling. Excluded.
- **Usability -- Strategy**: Covered. ux-strategy-minion's contributions are incorporated into the conflict resolutions (status file format, dual-channel orientation model, no task title in gate headers).
- **Usability -- Design**: Covered. ux-design-minion's contributions are incorporated (status write timing before announcement, mid-gate status updates). The `P<N> Label` format was chosen over ux-design's `Phase N -- Label` due to the 12-char hard constraint -- see Conflict Resolution #1.
- **Documentation**: Task 2 handles user-facing documentation (using-nefario.md). software-docs-minion coverage deferred to Phase 8 documentation checklist (no architectural changes -- this is a spec/docs-only change).
- **Observability**: No runtime components produced. Excluded.

## Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**:
  - ux-strategy-minion: Task 1 changes the status file format and gate header convention that define the user's orientation experience during orchestration. Journey coherence review needed.
- **Not selected**: ux-design-minion (already incorporated via conflict resolutions; no UI components produced), accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion (Task 2 covers docs directly)

## Risks and Mitigations

### Risk 1: Header character overflow (from devx-minion)
The 12-character limit on AskUserQuestion headers is a hard UI constraint. All proposed headers have been validated against this limit. Future gate types must maintain discipline. **Mitigation**: A character limit note is added to SKILL.md (Task 1, section D).

### Risk 2: Task summary shortened from 48 to 40 characters (from ux-strategy-minion)
8 fewer characters may truncate some task titles to be less recognizable. **Mitigation**: Tested against real task titles: "Build MCP server with OAuth support..." (38 chars), "Add phase context to status and gates..." (39 chars), "Restore phase announcements and improve..." (41 chars -- truncates to 40 + "..."). 40 chars is sufficient for recognizability. The phase prefix adds more orientation value than 8 extra summary chars.

### Risk 3: Phase 3.5 numbering is unusual (from devx-minion)
"P3.5" as a prefix is unconventional. **Mitigation**: Acceptable because the phase announcements already use this numbering. Users see `**--- Phase 3.5: Architecture Review ---**` before encountering the gate header. The full and abbreviated forms are a natural pair.

### Risk 4: User guide example becomes stale if format changes (from user-docs-minion)
The status line example in using-nefario.md shows a specific format. **Mitigation**: Task 2 instructions emphasize documenting the experience rather than the mechanism, and using representative examples. The example is illustrative, not normative.

### Risk 5: P3.5 Plan header may cause confusion about which phase (synthesis)
The Plan gate is presented after Phase 3.5 architecture review, but the plan was synthesized in Phase 3. Using `P3.5 Plan` (rather than `P3 Plan`) correctly indicates WHEN the gate appears in the user's timeline, which is what matters for orientation. Documented in Task 1 notes.

## Execution Order

```
Batch 1: Task 1 (SKILL.md changes -- no gate)
Batch 2: Task 2 (using-nefario.md docs -- depends on Task 1, no gate)
```

No approval gates. Both tasks are additive documentation/spec changes that are easy to reverse. Low blast radius (no downstream dependents beyond each other). Gate budget: 0 of 3-5.

## External Skills

No external skills used in the plan. The despicable-statusline skill was evaluated and confirmed to need no changes -- it reads the status file content verbatim and passes it through. The format change flows through automatically.

## Verification Steps

After all tasks complete:
1. Read `skills/nefario/SKILL.md` and verify all 8 primary gate headers match the mapping table and are <= 12 chars
2. Verify status file write instructions exist at Phases 1, 2, 3, 3.5, 4 with correct format
3. Verify Phase 4 Gate question includes task title prefix
4. Read `docs/using-nefario.md` and verify the three targeted edits are present
5. Verify the manual configuration example in using-nefario.md is unchanged
6. Verify despicable-statusline SKILL.md is unmodified
