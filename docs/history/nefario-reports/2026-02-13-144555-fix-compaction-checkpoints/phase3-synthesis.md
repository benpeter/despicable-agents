# Phase 3 Synthesis: Fix compaction checkpoints (#87)

## Delegation Plan

**Team name**: fix-compaction-checkpoints
**Description**: Replace blockquote compaction advisories with AskUserQuestion gates that pause execution, using printed code blocks instead of clipboard copy.

### Conflict Resolutions

**Clipboard vs. printed code block**: The issue proposes clipboard copy via `pbcopy`. devx-minion recommends printing the `/compact` command in a visible code block instead. **Resolution: adopt devx-minion's recommendation.** Rationale:

1. **Cross-platform fragmentation for zero gain.** Clipboard requires `pbcopy` (macOS), `xclip`/`xsel` (Linux X11), `wl-copy` (Wayland), `clip.exe` (WSL) -- platform detection, fallback chains, and silent failure modes. The SKILL.md spec would need 20+ lines of shell logic for a feature that saves one select-and-copy action.
2. **Invisible state is bad DX.** After clipboard copy, the user cannot verify what was copied without pasting. If copy fails silently or something overwrites the clipboard, the user pastes garbage.
3. **Transitional feature.** Issue #88 tracks programmatic `/compact` support. When that lands, the entire copy-paste dance becomes unnecessary. A printed code block is the simplest implementation with the least throwaway work.
4. **Terminal selection is muscle memory.** CLI users routinely select and copy text from terminals. A well-formatted indented code block is faster to recognize and verify than invisible clipboard state.
5. **ux-strategy-minion's analysis is compatible.** UX strategy recommended simplifying the instruction text and removing the queuing explanation. The printed code block approach achieves both: "Copy and run the command below. Type `continue` when ready." -- no queuing, no clipboard, no invisible state.

All three specialists agree on: P\<N\> header convention, update visual hierarchy table, "Skip" as recommended default, and keeping focus strings static.

**Queuing explanation**: ux-strategy-minion recommends removing the "while compaction is running" instruction. All specialists agree this adds unnecessary cognitive load. Adopted: the instruction simply says "Type `continue` when ready to resume." Works whether compaction is running or finished.

### Task 1: Replace blockquote checkpoints with AskUserQuestion gates

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This is the only file changed and has high blast radius (every future orchestration session). Hard to verify without reviewing the exact spec text. Multiple valid phrasings exist for the gate text.
- **Prompt**: |

    ## Task

    Replace both compaction checkpoint blockquote sections in `skills/nefario/SKILL.md`
    with AskUserQuestion gates that actually pause execution.

    ## Context

    Issue #87: The current compaction checkpoints (after Phase 3 and Phase 3.5)
    print blockquote advisories but the orchestration proceeds immediately without
    pausing. Users see the suggestion flash by with no opportunity to act.

    The fix replaces these with AskUserQuestion gates (same mechanism used by
    other gates like P1 Team, P3 Impasse, P3.5 Review, etc.).

    ## What to change

    **File**: `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

    ### Change 1: Post-Phase 3 compaction checkpoint (lines ~811-825)

    Replace the current blockquote + response handling:

    ```
    ### Compaction Checkpoint

    After writing the synthesis to the scratch file, present a compaction prompt:

    > **COMPACT** -- Phase 3 complete. Specialist details are now in the synthesis.
    >
    > Run: `/compact focus="Preserve: ..."`
    >
    > After compaction, type `continue` to resume at Phase 3.5 (Architecture Review).
    > Skipping is fine if context is short. Risk: auto-compaction in later phases may lose orchestration state.

    If the user runs `/compact`, wait for them to say "continue" then proceed.
    If the user types anything else (or says "skip"/"continue"), print:
    `Continuing without compaction. Auto-compaction may interrupt later phases.`
    Then proceed to Phase 3.5. Do NOT re-prompt at subsequent boundaries.
    ```

    With an AskUserQuestion gate:

    ```
    ### Compaction Checkpoint

    After writing the synthesis to the scratch file, present a compaction checkpoint
    using AskUserQuestion:

    - `header`: "P3 Compact"
    - `question`: "Phase 3 complete. Specialist details are now in the synthesis. Compact context before continuing?\n\nRun: $summary"
    - `options` (2, `multiSelect: false`):
      1. label: "Skip", description: "Continue without compaction. Auto-compaction may interrupt later phases." (recommended)
      2. label: "Compact", description: "Pause to compact context before Phase 3.5."

    **"Skip" response handling**:
    Print: `Continuing without compaction.`
    Record that compaction was skipped (used to suppress the Phase 3.5 checkpoint).
    Proceed to Phase 3.5.

    **"Compact" response handling**:
    Print the `/compact` command for the user to copy and run:

        Copy and run:

            /compact focus="Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, $summary, scratch directory path. Discard: individual specialist contributions from Phase 2."

        Type `continue` when ready to resume.

    <!-- Focus strings are printed verbatim in terminal output.
         Avoid backticks, single quotes, and backslashes in focus string values. -->

    The `$summary` and scratch directory path references in the focus string must be
    interpolated to their actual resolved values before display. Do not show template
    variables in user-facing output (per the Path display rule).

    Wait for the user to say "continue" (or synonyms: "go", "next", "ok", "resume",
    "proceed"). Then proceed to Phase 3.5. Do NOT re-prompt at subsequent boundaries.
    ```

    ### Change 2: Post-Phase 3.5 compaction checkpoint (lines ~1194-1206)

    Replace the current blockquote + response handling:

    ```
    ### Compaction Checkpoint

    After processing all review verdicts, present a compaction prompt:

    > **COMPACT** -- Phase 3.5 complete. Review verdicts are folded into the plan.
    >
    > Run: `/compact focus="Preserve: ..."`
    >
    > After compaction, type `continue` to resume at Phase 4 (Execution).
    > Skipping is fine if context is short. Risk: auto-compaction during execution may lose task/agent tracking.

    Same response handling: if user runs `/compact`, wait for "continue". If
    anything else, print the continuation message and proceed. Do NOT re-prompt.
    ```

    With an AskUserQuestion gate:

    ```
    ### Compaction Checkpoint

    After processing all review verdicts, present a compaction checkpoint.

    **Skip-cascade rule**: If the user selected "Skip" at the P3 Compact checkpoint,
    suppress this gate entirely. Print: `Compaction skipped (per earlier choice).`
    and proceed to the Execution Plan Approval Gate.

    If the P3 Compact checkpoint was not skipped (i.e., the user selected "Compact"
    earlier), present using AskUserQuestion:

    - `header`: "P3.5 Compact"
    - `question`: "Phase 3.5 complete. Review verdicts are folded into the plan. Compact context before execution?\n\nRun: $summary"
    - `options` (2, `multiSelect: false`):
      1. label: "Skip", description: "Continue without compaction. Auto-compaction may interrupt execution." (recommended)
      2. label: "Compact", description: "Pause to compact context before Phase 4."

    **"Skip" response handling**:
    Print: `Continuing without compaction.`
    Proceed to the Execution Plan Approval Gate.

    **"Compact" response handling**:
    Print the `/compact` command for the user to copy and run:

        Copy and run:

            /compact focus="Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, $summary, scratch directory path. Discard: individual review verdicts, Phase 2 specialist contributions, raw synthesis input."

        Type `continue` when ready to resume.

    <!-- Focus strings are printed verbatim in terminal output.
         Avoid backticks, single quotes, and backslashes in focus string values. -->

    The `$summary` and scratch directory path references in the focus string must be
    interpolated to their actual resolved values before display. Do not show template
    variables in user-facing output (per the Path display rule).

    Wait for the user to say "continue" (or synonyms: "go", "next", "ok", "resume",
    "proceed"). Then proceed to the Execution Plan Approval Gate.
    ```

    ### Change 3: Visual hierarchy table (line ~237)

    Update the visual hierarchy table row for Advisory weight. The current row:

    ```
    | **Advisory** | `>` blockquote with bold label | Compaction checkpoints -- optional user action |
    ```

    Since compaction checkpoints are now AskUserQuestion gates (Decision weight),
    remove the Advisory row entirely if no other advisories remain. Check whether
    any other feature uses the Advisory weight class. If nothing else uses it,
    remove the row. If something else uses it, update the Use column to remove
    the compaction checkpoint reference.

    ### Change 4: Visual hierarchy description text (lines ~240-243)

    The paragraph after the table currently reads:

    ```
    Decision blocks are the heaviest: multi-line with structured fields. Orientation
    is a single bold line. Advisory uses blockquote indentation. Inline flows without
    interruption. This hierarchy maps to attention demands: the heavier the visual
    signal, the more attention needed.
    ```

    If the Advisory row was removed, update this paragraph to remove the Advisory
    reference. If the Advisory row was kept (with different examples), keep the
    paragraph as-is.

    ## What NOT to do

    - Do NOT use clipboard (`pbcopy`, `xclip`, etc.). Print the command as visible text.
    - Do NOT add platform detection logic.
    - Do NOT dynamically compose focus strings. They are static templates with variable interpolation.
    - Do NOT add a conditional context-pressure check to skip the gate automatically.
    - Do NOT change the focus string content itself (the Preserve/Discard lists).
    - Do NOT change any other gates or sections of SKILL.md.
    - Do NOT modify the Advisory Termination section (it already correctly skips the compaction checkpoint).

    ## Deliverables

    Updated `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` with:
    1. Post-Phase 3 AskUserQuestion compaction gate replacing blockquote
    2. Post-Phase 3.5 AskUserQuestion compaction gate replacing blockquote (with skip-cascade)
    3. Updated visual hierarchy table
    4. Authoring guard comments near focus strings

    ## Success criteria

    - Both compaction checkpoints use AskUserQuestion (execution pauses until user responds)
    - Headers follow P\<N\> convention: "P3 Compact" and "P3.5 Compact"
    - Skip is option 1 (recommended), Compact is option 2
    - "Compact" option prints the command as visible text (no clipboard)
    - Focus strings contain interpolation note (resolve $summary and paths before display)
    - Skip-cascade: P3.5 gate suppressed if P3 was skipped
    - Visual hierarchy table is accurate
    - Question fields end with `\n\nRun: $summary`
    - No other sections of SKILL.md are modified

- **Deliverables**: Updated `skills/nefario/SKILL.md` with both AskUserQuestion gates, updated visual hierarchy table, and authoring guard comments
- **Success criteria**: Both checkpoints pause execution via AskUserQuestion; headers follow P\<N\> convention; Skip is recommended default; command is printed as visible text (no clipboard); skip-cascade suppresses P3.5 if P3 was skipped; visual hierarchy table is accurate

### Cross-Cutting Coverage

- **Testing**: Not applicable -- this changes a markdown spec file (SKILL.md), not executable code. No tests exist for SKILL.md content. Phase 6 (test execution) will find no tests to run, which is correct.
- **Security**: Not applicable -- no attack surface, authentication, user input processing, secrets, or dependencies are introduced. The change modifies orchestration instructions in a markdown file. Removing clipboard (`pbcopy`) actually reduces the attack surface compared to the issue's original proposal.
- **Usability -- Strategy**: Covered. ux-strategy-minion contributed to planning. Key recommendations incorporated: Skip as recommended default, P\<N\> headers, simplified instruction text (no queuing explanation), skip-cascade to reduce gate fatigue.
- **Usability -- Design**: Not applicable -- no user-facing UI components, visual layouts, or interaction patterns are produced. The AskUserQuestion gate is a pre-existing UI component being reused.
- **Documentation**: Covered within the task itself. The change IS documentation (SKILL.md is the orchestration spec). The visual hierarchy table update ensures the spec remains self-consistent. No external documentation (user guides, architecture docs) is affected because SKILL.md is an internal tool spec, not user-facing documentation.
- **Observability**: Not applicable -- no runtime components, APIs, or background processes are created.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none
  - ux-design-minion: NO -- no UI components produced; AskUserQuestion is a pre-existing pattern being reused
  - accessibility-minion: NO -- no web-facing HTML/UI; this is a CLI spec change
  - sitespeed-minion: NO -- no web-facing runtime code
  - observability-minion: NO -- no runtime components
  - user-docs-minion: NO -- SKILL.md is an internal orchestration spec, not user-facing documentation
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Risks and Mitigations

1. **Gate fatigue** (Low): Adding two AskUserQuestion gates increases total gate count. **Mitigation**: Skip-cascade reduces this to at most one compaction gate in practice (if user skips at P3, P3.5 is suppressed). Skip-as-default means one keypress to dismiss. Overhead is ~2 seconds per checkpoint.

2. **Template variable interpolation** (Medium): Focus strings contain `$summary` and scratch directory path references. If the orchestrator prints these literally instead of resolving to actual values, the `/compact` command will contain unexpanded variables. **Mitigation**: Explicit interpolation note in the spec ("must be interpolated to their actual resolved values before display") aligned with the existing Path display rule.

3. **Terminal line wrapping** (Low): The `/compact focus="..."` command is a single long line (~200 chars). In narrow terminals, it may wrap and be harder to select. **Mitigation**: Keep command on a single line (no line breaks). CLI users handle long lines routinely. The indented code block format helps visual distinction.

4. **Transitional feature** (Informational): Issue #88 tracks programmatic `/compact`. When that lands, the copy-paste interaction becomes unnecessary. **Mitigation**: The printed-code-block approach is the simplest possible implementation -- easy to replace with a programmatic call later.

### Execution Order

```
Batch 1: Task 1 (single task, single file)
  |
  v
Approval Gate (Task 1 deliverable)
```

One task, one file, one gate. Execution is sequential by necessity.

### Verification Steps

1. Read the updated SKILL.md and verify both compaction checkpoints use AskUserQuestion format
2. Verify headers are "P3 Compact" and "P3.5 Compact"
3. Verify Skip is option 1 (recommended) in both gates
4. Verify "Compact" option prints the command as visible text (no `pbcopy` or clipboard references)
5. Verify skip-cascade logic: P3.5 gate suppressed when P3 was skipped
6. Verify visual hierarchy table no longer lists compaction as Advisory weight
7. Verify question fields end with `\n\nRun: $summary`
8. Verify authoring guard comments are present near focus strings
9. Verify no other sections of SKILL.md were modified
