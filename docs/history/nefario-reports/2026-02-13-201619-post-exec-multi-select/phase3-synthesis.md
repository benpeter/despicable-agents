# Phase 3: Synthesis -- Post-Exec Multi-Select

## Delegation Plan

**Team name**: post-exec-multi-select
**Description**: Replace the post-execution single-select skip interview with a multi-select so users can pick exactly which phases to skip.

### Design Decisions (Consensus)

All three specialists converged on the same core design. No conflicts require
resolution.

1. **Skip framing**: Options represent phases to SKIP (not phases to run).
   Unchecked = runs. This preserves the zero-action = run-all invariant.
2. **No "Run all" option**: Submitting with nothing checked IS "run all."
   A separate "Run all" checkbox creates logical contradictions.
3. **3 options, risk-gradient order**: Skip docs (lowest risk), Skip tests
   (medium), Skip review (highest). Matches current label convention.
4. **Response format**: Comma-space-separated string of selected labels.
   Parsing should use semantic matching ("if the user selected X"), not
   format-specific string splitting.
5. **Freeform flags unchanged**: `--skip-docs`, `--skip-tests`,
   `--skip-review`, `--skip-post` remain as a parallel power-user channel.
   Freeform overrides structured selection on conflict.
6. **CONDENSE line unchanged**: It consumes skip booleans, not raw responses.
   No changes needed.
7. **multiSelect: true likely works via Space bar**: The original "broken"
   report was based on Enter-key expectation. Space bar is standard TUI
   checkbox convention. ai-modeling-minion confirmed the response format
   from Anthropic's Agent SDK docs.

### Task 1: Update SKILL.md post-exec AskUserQuestion and gating logic
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This changes the core user interaction for post-execution
  phase control. The AskUserQuestion definition and the downstream gating
  logic are tightly coupled -- reviewing them together is more coherent than
  splitting across two gates. Hard to reverse once users encounter the new
  prompt; high blast radius (all post-execution phases depend on this).
- **Prompt**: |
    You are updating the post-execution skip interview in the nefario
    orchestration skill. The goal: replace the 4-option single-select with a
    3-option multi-select using `multiSelect: true`.

    ## Context

    The post-execution follow-up AskUserQuestion is at lines 1550-1570 of
    `/Users/ben/github/benpeter/2despicable/4/skills/nefario/SKILL.md`.
    The skip determination logic is at lines 1645-1662 of the same file.

    ## What to change

    ### 1. AskUserQuestion block (lines 1550-1570)

    Replace the current block:
    ```
    - `question`: "Post-execution phases for Task N: <task title>?\n\nRun: $summary_full"
    - `options` (4, `multiSelect: false`):
      1. label: "Run all", description: "Code review + tests + docs after execution completes." (recommended)
      2. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
      3. label: "Skip tests", description: "Skip test execution (Phase 6)."
      4. label: "Skip review", description: "Skip code review (Phase 5)."
    ```

    With:
    ```
    - `question`: "Skip any post-execution phases for Task N: <task title>?
      (confirm with none selected to run all)\n\nRun: $summary_full"
    - `options` (3, `multiSelect: true`):
      1. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
      2. label: "Skip tests", description: "Skip test execution (Phase 6)."
      3. label: "Skip review", description: "Skip code review (Phase 5)."
    ```

    Key points:
    - Question text changes to "Skip any post-execution phases..." with the
      guidance "(confirm with none selected to run all)".
    - Remove the "Run all" option entirely. Zero selections = run all.
    - 3 options, ordered by ascending risk (docs, tests, review).
    - No "(recommended)" marker on any option.
    - `multiSelect: true` instead of `multiSelect: false`.

    Update the response interpretation text (lines 1558-1560) to describe
    multi-select behavior:
    - If no options selected: run all post-execution phases (5-8).
    - If one or more options selected: skip those phases, run the rest.

    ### 2. Freeform flag text (lines 1562-1570)

    Minor wording update only. Change:
    ```
    The user may also type a freeform response instead of selecting an option,
    ```
    To:
    ```
    The user may also type freeform flags at the same prompt,
    ```

    This reflects that freeform is a parallel channel, not an alternative to
    structured selection. The flag reference table (--skip-docs, --skip-tests,
    --skip-review, --skip-post) stays exactly as-is.

    Add after the flag reference:
    ```
    If the user provides both structured selection and freeform text,
    freeform text overrides on conflict.
    ```

    ### 3. Skip determination logic (lines 1645-1662)

    The current logic references "Skip review", "Skip tests", "Skip docs" as
    single-select labels. With multi-select, the response is a comma-space-
    separated string of selected labels. Update the logic:

    Replace:
    ```
    Determine which post-execution phases to run based on the user's follow-up
    response (structured selection or freeform text flags):
    - Phase 5 (Code Review): Skip if user selected "Skip review" or typed
      --skip-review or --skip-post. Also skip if Phase 4 produced no code
      files (existing conditional, unchanged).
    - Phase 6 (Test Execution): Skip if user selected "Skip tests" or typed
      --skip-tests or --skip-post. Also skip if no tests exist (existing
      conditional, unchanged).
    - Phase 8 (Documentation): Skip if user selected "Skip docs" or typed
      --skip-docs or --skip-post. Also skip if checklist has no items
      (existing conditional, unchanged).
    ```

    With:
    ```
    Determine which post-execution phases to run based on the user's
    multi-select response and/or freeform text flags:
    - Phase 5 (Code Review): Skip if the user's selection includes
      "Skip review", or freeform contains --skip-review or --skip-post.
      Also skip if Phase 4 produced no code files.
    - Phase 6 (Test Execution): Skip if the user's selection includes
      "Skip tests", or freeform contains --skip-tests or --skip-post.
      Also skip if no tests exist.
    - Phase 8 (Documentation): Skip if the user's selection includes
      "Skip docs", or freeform contains --skip-docs or --skip-post.
      Also skip if checklist has no items.
    - If no options were selected and no freeform skip flags were typed,
      run all phases.
    ```

    The key semantic change: the logic now checks whether each label
    "is included in" the multi-select response (which may contain multiple
    labels), rather than checking whether the response "equals" a single label.

    ### 4. CONDENSE line (lines 1657-1662)

    No changes. The CONDENSE logic consumes skip booleans, not raw responses.
    Verify the label-to-phase mapping is still consistent after your changes
    above. It should be, since the labels are unchanged.

    ## What NOT to change

    - Do NOT modify any code outside the two sections described above
      (AskUserQuestion block + skip determination logic + freeform text).
    - Do NOT change the CONDENSE status line logic.
    - Do NOT change the verification summary format in the wrap-up section.
    - Do NOT change the approval gate options (Approve/Request changes/
      Reject/Skip) -- only the FOLLOW-UP after "Approve" changes.
    - Do NOT touch Phase 5, 6, 7, or 8 implementation details.

    ## Files to modify

    - `/Users/ben/github/benpeter/2despicable/4/skills/nefario/SKILL.md`
      (the only file for this task)

    ## Verification

    After making changes, read back the modified sections to confirm:
    1. The AskUserQuestion uses `multiSelect: true` with exactly 3 options.
    2. Question text includes "confirm with none selected to run all".
    3. No "Run all" option exists.
    4. Options are ordered: Skip docs, Skip tests, Skip review.
    5. Skip determination logic uses "includes" semantics for multi-select.
    6. Freeform override rule is documented.
    7. CONDENSE section is unchanged.
- **Deliverables**: Updated `skills/nefario/SKILL.md` with multi-select
  AskUserQuestion and updated gating logic.
- **Success criteria**: The AskUserQuestion block uses `multiSelect: true`
  with 3 skip options; the gating logic handles multi-select responses;
  freeform flags are preserved with override semantics documented.

### Task 2: Update satellite documentation files
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating satellite documentation files to reflect the post-execution
    multi-select change made in the nefario skill. Task 1 already updated
    `skills/nefario/SKILL.md`. Now update references in three other files.

    ## Changes needed

    ### File 1: `/Users/ben/github/benpeter/2despicable/4/nefario/AGENT.md`

    Lines 775-777 currently read:
    ```
    Users can skip individual post-execution phases at approval gates: "Run all"
    (default), "Skip docs", "Skip tests", or "Skip review". Freeform flags
    --skip-docs, --skip-tests, --skip-review, --skip-post also accepted.
    ```

    Replace with:
    ```
    Users can skip post-execution phases via multi-select at approval gates:
    check "Skip docs", "Skip tests", and/or "Skip review" (confirm with none
    selected to run all). Freeform flags --skip-docs, --skip-tests,
    --skip-review, --skip-post also accepted.
    ```

    ### File 2: `/Users/ben/github/benpeter/2despicable/4/docs/orchestration.md`

    **Location 1** -- Lines 113-116 currently read:
    ```
    At each approval gate, after selecting "Approve", a follow-up prompt offers
    granular control: "Run all" (default), "Skip docs" (Phase 8), "Skip tests"
    (Phase 6), or "Skip review" (Phase 5). Freeform flags (--skip-docs,
    --skip-tests, --skip-review, --skip-post) can skip multiple phases at once.
    ```

    Replace with:
    ```
    At each approval gate, after selecting "Approve", a multi-select follow-up
    lets users check which phases to skip: "Skip docs" (Phase 8), "Skip tests"
    (Phase 6), or "Skip review" (Phase 5). Confirm with none selected to run
    all. Freeform flags (--skip-docs, --skip-tests, --skip-review, --skip-post)
    also accepted.
    ```

    **Location 2** -- Lines 473-474 currently read:
    ```
    - **Approve** -- Gate clears. A follow-up prompt offers "Run all" (default),
      "Skip docs", "Skip tests", or "Skip review". Freeform flags for multi-skip.
    ```

    Replace with:
    ```
    - **Approve** -- Gate clears. A multi-select follow-up lets users check
      phases to skip ("Skip docs", "Skip tests", "Skip review"; none selected
      = run all). Freeform flags also accepted.
    ```

    ### File 3: `/Users/ben/github/benpeter/2despicable/4/docs/using-nefario.md`

    No changes needed. The reference at line 83 (`/nefario #42 skip phase 8`)
    is a freeform flag example, which is unchanged. The Phase 5 description at
    line 112 does not mention the skip interface.

    ## What NOT to change

    - Do NOT modify content unrelated to the post-exec skip interface.
    - Do NOT change the Mermaid diagrams in orchestration.md (the "Skip review"
      at line 206/208 refers to the Phase 3.5 reviewer approval gate, which is
      a completely different feature).
    - Do NOT update files in `docs/history/` -- those are historical records.

    ## Verification

    After making changes, read back each modified section to confirm the text
    accurately describes the multi-select interaction.
- **Deliverables**: Updated `nefario/AGENT.md` and `docs/orchestration.md`.
- **Success criteria**: All references to the 4-option single-select are
  replaced with multi-select descriptions. No unrelated changes.

### Cross-Cutting Coverage
- **Testing**: Not applicable for execution tasks. The change is to a prompt
  specification file (SKILL.md), not executable code. Live verification of
  `multiSelect: true` behavior is a runtime concern handled by the user's
  first orchestration after deployment. The risk is documented below and
  the fallback (revert to single-select) is trivial.
- **Security**: Not applicable. No auth, user input processing, secrets, or
  new dependencies. The change modifies how a prompt presents options.
- **Usability -- Strategy**: Covered. ux-strategy-minion provided the core
  design (skip framing, zero-action default, cognitive load analysis). The
  design is fully incorporated into Task 1.
- **Usability -- Design**: Not applicable. No UI components, visual layouts,
  or interaction patterns beyond the terminal multi-select (which is a
  Claude Code platform feature, not a custom UI).
- **Documentation**: Covered by Task 2 (satellite file updates). No new
  user-facing documentation is needed -- the multi-select is self-describing
  via its question text.
- **Observability**: Not applicable. No runtime components, APIs, or
  background processes.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none
  - ux-design-minion: NO -- no UI components produced, only terminal prompt config
  - accessibility-minion: NO -- AskUserQuestion is a platform control; accessibility is Claude Code's responsibility
  - sitespeed-minion: NO -- no web-facing runtime code
  - observability-minion: NO -- no runtime components
  - user-docs-minion: NO -- no change to what end users see/do/learn (this is developer tooling configuration)
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

No conflicts. All three specialists converged independently on the same design:
skip framing, 3 options, no "Run all", zero-action = run all. The only point of
variance was label naming (ai-modeling-minion proposed shorter labels like "Code
review" / "Tests" / "Docs" while ux-strategy-minion and devx-minion kept the
existing "Skip docs" / "Skip tests" / "Skip review"). Resolution: keep the
existing "Skip ..." labels for continuity with current design and freeform flag
naming convention. Users already know these labels.

### Risks and Mitigations

**Risk 1: multiSelect: true does not work as expected (MEDIUM)**
- ai-modeling-minion found the original bug (#12030) was about Enter vs Space
  bar. Space bar toggling is standard TUI convention. The Anthropic Agent SDK
  docs confirm the comma-space-separated response format.
- If it does not work: the current 4-option single-select is the safe fallback.
  Revert is a single-file change (SKILL.md).
- Mitigation: the user will encounter the new multi-select on their first
  orchestration after deployment. If it renders as single-select or breaks,
  revert immediately.

**Risk 2: "Confirm with none selected" is unfamiliar UX (LOW)**
- Question text explicitly states the default. Skip framing makes it
  intuitive: "I didn't ask to skip anything, so everything runs."
- Mitigation: built into the question text.

**Risk 3: Zero-selection response format is undocumented (LOW)**
- If submitting with nothing checked produces an empty string, missing key,
  or unexpected value, the gating logic must handle it.
- Mitigation: the gating logic explicitly states "if no options were selected
  and no freeform skip flags were typed, run all phases." The LLM interprets
  this semantically.

### Execution Order

```
Batch 1: Task 1 (SKILL.md changes) [APPROVAL GATE]
Batch 2: Task 2 (satellite docs, blocked by Task 1)
```

### External Skills

No external skills detected relevant to this task.

### Verification Steps

1. Read back SKILL.md lines 1550-1570 and 1645-1662 after Task 1 to confirm
   multi-select definition and gating logic are correct.
2. Read back AGENT.md lines 775-777 and orchestration.md lines 113-116 and
   473-474 after Task 2 to confirm satellite updates are consistent.
3. First nefario orchestration after deployment serves as live verification
   of `multiSelect: true` behavior.
