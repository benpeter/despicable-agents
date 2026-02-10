# Phase 3: Synthesis -- Replace --skip-post with Granular Skip Flags

## Delegation Plan

**Team name**: granular-skip-flags
**Description**: Replace the coarse `--skip-post` flag with granular per-phase skip controls in the nefario SKILL.md and satellite files.

---

### Conflict Resolution: Flat 4-Option Single-Select

**The conflict**: devx-minion recommends a flat 5-option single-select; ux-strategy-minion recommends a two-tier progressive disclosure pattern with `multiSelect: true`.

**Resolution**: Use a **flat 4-option single-select** (margo's simplification, user-approved).

Rationale:

1. **AskUserQuestion constraint**: The tool supports 2-4 options. devx-minion's 5-option design exceeds this. Dropping "Skip all post-execution" to a freeform-only option (`--skip-post`) brings it to 4.

2. **`multiSelect: true` doesn't work in practice**: The Claude Code UI does not support multi-select in AskUserQuestion prompts. A two-tier approach with `multiSelect: false` in tier 2 can only skip one phase per structured selection -- no better than flat 4-option, but with an extra click.

3. **Flat is simpler**: Eliminates the "Customize" intermediary concept, inter-tier precedence rules, and one entire interaction layer. Same capability with fewer moving parts.

4. **The 4 options**: "Run all" (recommended), "Skip docs" (Phase 8), "Skip tests" (Phase 6), "Skip review" (Phase 5). Risk-gradient ordered (lowest risk first). Skip-all and multi-skip via freeform text (`--skip-post`, `--skip-docs --skip-tests`).

**What this preserves from each specialist**:
- From devx-minion: risk-gradient ordering, `--skip-post` as first-class shorthand, flag names (`--skip-review`, `--skip-tests`, `--skip-docs`), dual-channel gating logic, granular verification summary, freeform text as parallel channel.
- From ux-strategy-minion: run-all as one-click fast path, text escape hatch for power users, no confirmation dialogs, no risk warning labels.
- From margo: minimal complexity, no unnecessary interaction layers.

---

### Task 1: Replace Post-Exec Follow-Up in SKILL.md

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are making a targeted edit to the nefario orchestration SKILL.md file.

    ## What to Do

    Replace the post-execution follow-up AskUserQuestion block in
    `skills/nefario/SKILL.md` (lines 493-501). The current code is a 2-option
    binary follow-up ("Run all" / "Skip post-execution"). Replace it with a
    flat 4-option single-select with granular per-phase skip options.

    ### Current Code (lines 493-501)

    ```
    - **"Approve"**: Present a FOLLOW-UP AskUserQuestion for post-execution options:
      - `header`: "Post-exec"
      - `question`: "Post-execution phases for this task?"
      - `options` (2, `multiSelect: false`):
        1. label: "Run all", description: "Code review + tests + docs after execution completes." (recommended)
        2. label: "Skip post-execution", description: "Skip Phases 5, 6, 8. Commit and continue."
      Then auto-commit changes (see below) and continue to next batch.
      If "Run all": run post-execution phases (5-8) after execution completes.
      If "Skip post-execution": skip Phases 5, 6, 8. Phase 7 is already opt-in.
    ```

    ### Replacement Code

    ```
    - **"Approve"**: Present a FOLLOW-UP AskUserQuestion for post-execution options:
      - `header`: "Post-exec"
      - `question`: "Post-execution phases for this task?"
      - `options` (4, `multiSelect: false`):
        1. label: "Run all", description: "Code review + tests + docs after execution completes." (recommended)
        2. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
        3. label: "Skip tests", description: "Skip test execution (Phase 6)."
        4. label: "Skip review", description: "Skip code review (Phase 5)."
      Options are ordered by ascending risk (docs = lowest, review = highest).
      If "Run all": run post-execution phases (5-8) after execution completes.
      If "Skip docs/tests/review": skip the selected phase, run the rest.
      Then auto-commit changes (see below) and continue to next batch.
      The user may also type a freeform response instead of selecting an option,
      using flags to skip multiple phases (e.g., "--skip-docs --skip-tests",
      or "--skip-post" to skip all). Interpret natural language skip intent as
      equivalent to the corresponding flags. Flag reference:
      - `--skip-docs` = skip Phase 8
      - `--skip-tests` = skip Phase 6
      - `--skip-review` = skip Phase 5
      - `--skip-post` = skip Phases 5, 6, 8 (all post-execution)
      Flags can be combined: `--skip-docs --skip-tests` skips both.
    ```

    ## Constraints

    - Edit ONLY lines 493-501 (the "Approve" response handling block for the
      post-exec follow-up). Do not touch the gate AskUserQuestion above it
      (lines 483-491), the "Request changes" handler (line 502-504), the
      "Reject" handler (lines 505-513), or anything else.
    - Preserve the auto-commit reference ("see below") and the "continue to
      next batch" instruction.
    - The replacement must be valid markdown that matches the indentation and
      formatting style of the surrounding SKILL.md content.

    ## What NOT to Do

    - Do NOT modify any other section of SKILL.md.
    - Do NOT modify satellite files (AGENT.md, AGENT.overrides.md, orchestration.md).
    - Do NOT change the gate AskUserQuestion options (Approve/Request changes/Reject/Skip).
    - Do NOT add confirmation dialogs or warning labels to skip options.

    ## Deliverables

    - Updated `skills/nefario/SKILL.md` with the new follow-up block.

    ## Verification

    - The "Run all" path is still one click from the follow-up prompt.
    - 4 options total, all in one prompt (no secondary tier).
    - Options are in risk-gradient order (docs, tests, review).
    - Freeform text flags documented with explicit flag reference.
    - `--skip-post` is documented as shorthand for skipping all.

- **Deliverables**: Updated `skills/nefario/SKILL.md` lines 493-501
- **Success criteria**: Run-all is one click; flat 4-option single-select; risk-gradient ordering; freeform flags documented

---

### Task 2: Update Post-Execution Phase Gating Logic in SKILL.md

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are making a targeted edit to the nefario orchestration SKILL.md file.

    ## What to Do

    Replace the binary `--skip-post` check and the CONDENSE status line in
    `skills/nefario/SKILL.md` (lines 554-556). The current code has a single
    skip check. Replace it with per-phase gating logic.

    ### Current Code (lines 554-556)

    ```
    Print: `Verifying: code review, tests, documentation...`

    If the user said `approve --skip-post`, skip to Wrap-up.
    ```

    ### Replacement Code

    ```
    Determine which post-execution phases to run based on the user's follow-up
    response (structured selection or freeform text flags):
    - Phase 5 (Code Review): Skip if user selected "Skip review" or "Skip all
      post-execution", or typed --skip-review or --skip-post. Also skip if
      Phase 4 produced no code files (existing conditional, unchanged).
    - Phase 6 (Test Execution): Skip if user selected "Skip tests" or "Skip all
      post-execution", or typed --skip-tests or --skip-post. Also skip if no
      tests exist (existing conditional, unchanged).
    - Phase 8 (Documentation): Skip if user selected "Skip docs" or "Skip all
      post-execution", or typed --skip-docs or --skip-post. Also skip if
      checklist has no items (existing conditional, unchanged).

    Print a CONDENSE status line listing only the phases that will actually run:
    - No skips: `Verifying: code review, tests, documentation...`
    - Skip docs: `Verifying: code review, tests...`
    - Skip review + tests: `Verifying: documentation...`
    - All skipped (by user or by existing conditionals): skip the status line
      entirely and proceed directly to Wrap-up.
    ```

    ## Constraints

    - Edit ONLY lines 554-556. Do not touch the Phase 5/6/7/8 section
      implementations below -- they already have their own internal skip
      conditionals (e.g., "Skip if Phase 4 produced no code files").
    - The per-phase gating adds a NEW layer of skip logic (user-requested skips)
      on top of the existing conditional skips. Both must be honored independently.
    - Preserve the "Optional compaction" note at lines 558-560.

    ## What NOT to Do

    - Do NOT modify Phase 5, 6, 7, or 8 implementation sections.
    - Do NOT modify the follow-up AskUserQuestion (Task 1 handles that).
    - Do NOT modify satellite files.

    ## Deliverables

    - Updated `skills/nefario/SKILL.md` lines 554-556.

    ## Verification

    - Each phase has independent skip logic (user request OR existing conditional).
    - The CONDENSE line reflects only phases that will actually run.
    - `--skip-post` skips all three phases (equivalent to all individual flags).

- **Deliverables**: Updated `skills/nefario/SKILL.md` lines 554-556
- **Success criteria**: Per-phase gating with dual-source skip logic; dynamic CONDENSE line

---

### Task 3: Update Verification Summary in SKILL.md

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are making a targeted edit to the nefario orchestration SKILL.md file.

    ## What to Do

    Update the verification summary format at two locations in
    `skills/nefario/SKILL.md`:

    **Location 1: CONDENSE section (line 65)**

    Current:
    ```
    - Post-execution result: fold into wrap-up ("Verification: all checks passed" or "Verification: 2 findings auto-fixed, all tests pass, docs updated")
    ```

    Replace with:
    ```
    - Post-execution result: fold into wrap-up ("Verification: all checks passed." or "Verification: 2 findings auto-fixed, all tests pass, docs updated (3 files)." or "Verification: code review passed, tests passed. Skipped: docs." or "Verification: skipped (--skip-post).")
    ```

    **Location 2: Wrap-up sequence (lines 883-887)**

    Current:
    ```
    3. **Verification summary** — consolidate Phase 5-8 outcomes into a single
       block for the report and user summary. Format:
       - Default: "Verification: all checks passed."
       - With fixes: "Verification: N code review findings auto-fixed, all tests pass, docs updated (M files)."
       - Skipped: "Verification: skipped (--skip-post)."
    ```

    Replace with:
    ```
    3. **Verification summary** — consolidate Phase 5-8 outcomes into a single
       block for the report and user summary. Format:
       - All ran, all passed: "Verification: all checks passed."
       - All ran, with fixes: "Verification: N code review findings auto-fixed, all tests pass, docs updated (M files)."
       - Partial skip (user-requested): "Verification: code review passed, tests passed. Skipped: docs."
       - Another partial: "Verification: docs updated (2 files). Skipped: code review, tests."
       - All skipped: "Verification: skipped (--skip-post)."
       Report what ran first (with outcomes), then append "Skipped: <phases>"
       for phases skipped by user choice. Do NOT include phases skipped by
       existing conditionals (e.g., "no code files produced") in the "Skipped:"
       suffix -- those are noted by the phase itself. The "Skipped:" suffix
       tracks user-requested skips only.
    ```

    ## Constraints

    - Edit ONLY the two locations specified above.
    - The verification summary format must be consistent between the CONDENSE
      section and the Wrap-up sequence.

    ## What NOT to Do

    - Do NOT modify Phase 5, 6, 7, or 8 implementation sections.
    - Do NOT modify the follow-up AskUserQuestion or gating logic (Tasks 1-2).
    - Do NOT modify satellite files.

    ## Deliverables

    - Updated `skills/nefario/SKILL.md` at lines 65 and 883-887.

    ## Verification

    - Partial skip states are documented with examples.
    - "Skipped:" suffix distinguishes user-requested from conditional skips.
    - All-skipped state still references `--skip-post`.

- **Deliverables**: Updated `skills/nefario/SKILL.md` at two locations
- **Success criteria**: Granular verification summary with partial-skip examples; user-skip vs. conditional-skip distinction

---

### Task 4: Update Satellite Files

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Tasks 1, 2, 3
- **Approval gate**: no
- **Prompt**: |
    You are updating satellite files to reflect changes made to the nefario
    SKILL.md. The SKILL.md now uses granular per-phase skip flags instead of
    the coarse `--skip-post` binary option.

    ## What to Do

    Update three files to replace `--skip-post` references with the new
    granular skip documentation:

    ### File 1: `nefario/AGENT.overrides.md` (line 53)

    Current:
    ```
    Users can skip post-execution with `approve --skip-post` at the plan approval gate.
    ```

    Replace with:
    ```
    Users can skip individual post-execution phases at approval gates: "Run all"
    (default), "Skip docs", "Skip tests", or "Skip review". Freeform flags
    --skip-docs, --skip-tests, --skip-review, --skip-post also accepted.
    ```

    ### File 2: `docs/orchestration.md` (line 104)

    Current:
    ```
    At each approval gate, after selecting "Approve", a follow-up prompt offers the option to skip post-execution phases (Phases 5, 6, and 8). Phase 7 is already opt-in.
    ```

    Replace with:
    ```
    At each approval gate, after selecting "Approve", a follow-up prompt offers
    granular control: "Run all" (default), "Skip docs" (Phase 8), "Skip tests"
    (Phase 6), or "Skip review" (Phase 5). Freeform flags (--skip-docs,
    --skip-tests, --skip-review, --skip-post) can skip multiple phases at once.
    Phase 7 (deployment) is opt-in.
    ```

    ### File 3: `docs/orchestration.md` (line 374)

    Current:
    ```
    - **Approve** -- Gate clears. A follow-up prompt offers "Run all" (post-execution phases) or "Skip post-execution". Downstream tasks are unblocked.
    ```

    Replace with:
    ```
    - **Approve** -- Gate clears. A follow-up prompt offers "Run all" (default),
      "Skip docs", "Skip tests", or "Skip review". Freeform flags for multi-skip.
      Downstream tasks are unblocked.
    ```

    ### File 4: `nefario/AGENT.md` (line 595)

    Current:
    ```
    Users can skip post-execution with `approve --skip-post` at the plan approval gate.
    ```

    Replace with:
    ```
    Users can skip individual post-execution phases at approval gates: "Run all"
    (default), "Skip docs", "Skip tests", or "Skip review". Freeform flags
    --skip-docs, --skip-tests, --skip-review, --skip-post also accepted.
    ```

    Note: AGENT.md line 595 should mirror AGENT.overrides.md line 53 exactly.
    AGENT.md is derived from overrides during the build process, but both
    files should be updated now for consistency.

    ## Constraints

    - Edit ONLY the four lines/blocks specified above.
    - Ensure all four files are consistent with each other and with the
      SKILL.md changes (which are already committed by Tasks 1-3).
    - Keep the replacement text concise -- these are summary references,
      not full documentation.

    ## What NOT to Do

    - Do NOT modify SKILL.md (already updated by Tasks 1-3).
    - Do NOT modify the-plan.md (no --skip-post references exist there).
    - Do NOT add new sections to any file.

    ## Deliverables

    - Updated `nefario/AGENT.overrides.md`
    - Updated `docs/orchestration.md` (two locations)
    - Updated `nefario/AGENT.md`

    ## Verification

    - All four files use consistent language about the new skip options.
    - No stale `--skip-post` references remain as the only documented path.
    - `--skip-post` is mentioned as one of the freeform flags (not deprecated).

- **Deliverables**: Updated satellite files (4 files, 4 edit locations)
- **Success criteria**: All files consistent; no stale `--skip-post`-only references; `--skip-post` preserved as freeform shorthand

---

### Cross-Cutting Coverage

| Dimension | Coverage | Justification |
|-----------|----------|---------------|
| **Testing** | Not included | No executable code is produced. All changes are to markdown instruction files (SKILL.md, AGENT.md, orchestration.md). There is no test infrastructure for skill files. |
| **Security** | Not included | No attack surface created. Changes affect orchestration UX flow (how the user selects skip options), not authentication, authorization, user input processing, or infrastructure. |
| **Usability -- Strategy** | Covered by synthesis conflict resolution | Both ux-strategy-minion and devx-minion contributed to Phase 2 planning. The synthesis resolves their conflict and preserves both specialists' key principles (progressive disclosure, one-click default, risk-gradient ordering, no confirmation dialogs). |
| **Usability -- Design** | Not included | No user-facing UI is produced. AskUserQuestion is a CLI tool with fixed rendering; the design space is limited to option count, labels, and descriptions. |
| **Documentation** | Covered by Task 4 | Satellite documentation files are updated as the final task, ensuring consistency across all references. |
| **Observability** | Not included | No runtime components, services, or APIs are produced. |

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no user-facing UI, no web-facing components)

### Risks and Mitigations

**Risk 1: AskUserQuestion 4-option limit (LOW)**
The documented constraint is 2-4 options. The follow-up prompt uses exactly 4. If rendering issues occur with 4 options, drop "Skip review" (highest risk, least commonly skipped) and keep it as freeform-only (`--skip-review`).
*Mitigation*: 4 is within the documented range. Fallback is straightforward.

**Risk 2: No structured skip-all option (LOW)**
"Skip all post-execution" is not a structured option -- users must type `--skip-post`. This is deliberate: skip-all should require more intent than skipping one phase.
*Mitigation*: `--skip-post` is documented in the freeform flag reference. Users who previously used "Skip post-execution" will see it in the "Other" freeform path.

**Risk 3: Inconsistency across four files (MEDIUM)**
Four files must be updated consistently. A mismatch between SKILL.md (source of truth) and satellite files creates confusion.
*Mitigation*: Task 4 is blocked by Tasks 1-3, ensuring SKILL.md is finalized before satellites are updated. Phase 3.5 architecture review (lucy) will catch mismatches.

**Risk 4: Dual-channel input ambiguity (LOW)**
A user could select "Run all" and then type "--skip-docs" in the same response. The SKILL.md now documents a precedence rule: freeform text overrides structured selection.
*Mitigation*: Explicitly documented in the SKILL.md replacement text (Task 1).

### Execution Order

```
Batch 1: Task 1 (follow-up prompt)
         |
         v
Batch 2: Task 2 (gating logic) + Task 3 (verification summary) [parallel]
         |
         v
Batch 3: Task 4 (satellite files)
```

No approval gates. All tasks are easy-to-reverse (markdown edits to instruction files), and the scope is tightly defined. Gate classification: easy to reverse + low blast radius (0-1 dependents for each individual file) = NO GATE per the reversibility/blast-radius matrix.

### Verification Steps

After all tasks complete:

1. **SKILL.md internal consistency**: The follow-up AskUserQuestion (Task 1), gating logic (Task 2), and verification summary (Task 3) must reference the same flag names and phase mappings.
2. **Satellite consistency**: All four satellite files must describe the new skip options in language consistent with SKILL.md.
3. **No stale references**: `grep -r "skip-post" skills/ nefario/ docs/` should show `--skip-post` only as one of multiple documented options (not as the sole mechanism).
4. **Preserved behavior**: The "Run all" path must still be the default and require exactly one click from the follow-up prompt.
5. **Flag mapping completeness**: `--skip-docs` -> Phase 8, `--skip-tests` -> Phase 6, `--skip-review` -> Phase 5, `--skip-post` -> Phases 5+6+8.
