## Delegation Plan

**Team name**: fix-post-exec-gate-ux
**Description**: Replace the inverted skip-only multiSelect post-exec gate with an explicit single-select "Run all" default.

### Task 1: Rewrite post-exec gate and consumption logic in SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario orchestration skill to fix a UX anti-pattern
    in the post-execution phase gate.

    ## Problem

    The current post-exec AskUserQuestion uses `multiSelect: true` with
    skip-oriented options. The happy path (run everything) requires selecting
    nothing, which triggers a Claude Code "unanswered question" warning. This
    is a bad UX -- the most common action should be the easiest to take.

    ## File to edit

    `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    ## Change 1: Replace the AskUserQuestion block (lines 1627-1648)

    Find this exact block starting at the "Approve" response handler:

    ```
       - **"Approve"**: Present a FOLLOW-UP AskUserQuestion for post-execution options:
         - `header`: "Post-exec"
         - `question`: "Skip any post-execution phases for Task N: <task title>? (confirm with none selected to run all)\n\nRun: $summary_full"
         - `options` (3, `multiSelect: true`):
           1. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
           2. label: "Skip tests", description: "Skip test execution (Phase 6)."
           3. label: "Skip review", description: "Skip code review (Phase 5)."
         Options are ordered by ascending risk (docs = lowest, review = highest).
         If no options selected: run all post-execution phases (5-8).
         If one or more options selected: skip those phases, run the rest.
         Then auto-commit changes (see below) and continue to next batch.
         The user may also type freeform flags at the same prompt,
         using flags to skip multiple phases (e.g., "--skip-docs --skip-tests",
         or "--skip-post" to skip all). Interpret natural language skip intent as
         equivalent to the corresponding flags. Flag reference:
         - `--skip-docs` = skip Phase 8
         - `--skip-tests` = skip Phase 6
         - `--skip-review` = skip Phase 5
         - `--skip-post` = skip Phases 5, 6, 8 (all post-execution)
         Flags can be combined: `--skip-docs --skip-tests` skips both.
         If the user provides both structured selection and freeform text,
         freeform text overrides on conflict.
    ```

    Replace with:

    ```
       - **"Approve"**: Present a FOLLOW-UP AskUserQuestion for post-execution options:
         - `header`: "Post-exec"
         - `question`: "Post-execution phases for Task N: <task title>\n\nRun: $summary_full"
         - `options` (3, `multiSelect: false`):
           1. label: "Run all (recommended)", description: "Run code review, tests, and documentation."
           2. label: "Skip docs only", description: "Run code review and tests. Skip documentation updates."
           3. label: "Skip all post-exec", description: "Skip code review, tests, and documentation."
         Then auto-commit changes (see below) and continue to next batch.
         The user may also type freeform flags instead of selecting an option,
         using flags to skip specific phases (e.g., "--skip-docs --skip-tests",
         or "--skip-post" to skip all). Interpret natural language skip intent as
         equivalent to the corresponding flags. Flag reference:
         - `--skip-docs` = skip Phase 8
         - `--skip-tests` = skip Phase 6
         - `--skip-review` = skip Phase 5
         - `--skip-post` = skip Phases 5, 6, 8 (all post-execution)
         Flags can be combined: `--skip-docs --skip-tests` skips both.
         If the user provides both structured selection and freeform text,
         freeform text overrides on conflict.
    ```

    ## Change 2: Replace the downstream consumption logic (lines 1723-1736)

    Find this exact block:

    ```
    Determine which post-execution phases to run based on the user's
    multi-select response and/or freeform text flags:
    - Phase 5 (Code Review): Skip if the user's selection includes
      "Skip review", or freeform contains --skip-review or --skip-post.
      Also skip if Phase 4 produced only documentation-only files (see
      Phase 5 file classification table).
    - Phase 6 (Test Execution): Skip if the user's selection includes
      "Skip tests", or freeform contains --skip-tests or --skip-post.
      Also skip if no tests exist.
    - Phase 8 (Documentation): Skip if the user's selection includes
      "Skip docs", or freeform contains --skip-docs or --skip-post.
      Also skip if checklist has no items.
    - If no options were selected and no freeform skip flags were typed,
      run all phases.
    ```

    Replace with:

    ```
    Determine which post-execution phases to run based on the user's
    single-select response and/or freeform text flags:
    - "Run all (recommended)": Run Phases 5, 6, and 8 (subject to existing
      conditional skips: docs-only files skip Phase 5, no tests skip Phase 6,
      empty checklist skips Phase 8).
    - "Skip docs only": Skip Phase 8. Run Phases 5 and 6 (subject to
      existing conditional skips).
    - "Skip all post-exec": Skip Phases 5, 6, and 8.
    - Freeform text: If the user types freeform flags instead of selecting
      an option, interpret them as before:
      - --skip-docs = skip Phase 8
      - --skip-tests = skip Phase 6
      - --skip-review = skip Phase 5
      - --skip-post = skip Phases 5, 6, 8 (all post-execution)
      Flags can be combined. Freeform overrides structured selection on conflict.
    ```

    ## Change 3: Update the nefario AGENT.md skip documentation

    In `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md`, find this block:

    ```
    Users can skip post-execution phases via multi-select at approval gates:
    check "Skip docs", "Skip tests", and/or "Skip review" (confirm with none
    selected to run all). Freeform flags --skip-docs, --skip-tests,
    --skip-review, --skip-post also accepted.
    ```

    Replace with:

    ```
    Users can skip post-execution phases at approval gates by selecting one
    of: "Run all (recommended)", "Skip docs only", or "Skip all post-exec".
    Freeform flags --skip-docs, --skip-tests, --skip-review, --skip-post
    also accepted for granular control.
    ```

    ## What NOT to change

    - Do not modify any other AskUserQuestion blocks in SKILL.md
    - Do not change the Phase 4 approval gate structure
    - Do not change the CONDENSE status line logic (lines 1738-1743) -- it
      remains correct regardless of how skip decisions are made
    - Do not change any Phase 5, 6, or 8 internal logic

    ## Verification

    After making the changes, verify:
    1. The new AskUserQuestion uses `multiSelect: false`
    2. There are exactly 3 options with the exact labels above
    3. The downstream consumption logic references the new labels
    4. Freeform flag documentation is preserved
    5. No other AskUserQuestion blocks were modified
- **Deliverables**: Updated `skills/nefario/SKILL.md` (post-exec gate block + consumption logic), updated `nefario/AGENT.md` (skip documentation paragraph)
- **Success criteria**: (1) `multiSelect: false` in post-exec gate, (2) "Run all (recommended)" is option 1, (3) downstream logic matches new labels, (4) freeform flags preserved, (5) AGENT.md paragraph updated

### Cross-Cutting Coverage
- **Testing**: Not applicable -- this is a prompt/instruction change with no executable code. The change will be validated through the next orchestrated session that hits a post-exec gate.
- **Security**: Not applicable -- no auth, user input processing, or attack surface changes.
- **Usability -- Strategy**: Covered by ux-strategy-minion planning contribution. The 3-option design follows Hick's Law, satisficing behavior, and consistency with existing single-select gates.
- **Usability -- Design**: Not applicable -- no UI components, this is CLI prompt text.
- **Documentation**: The AGENT.md update in Task 1 covers the documentation surface. No user-facing docs exist for this internal orchestration mechanism.
- **Observability**: Not applicable -- no runtime components.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none -- no UI components, no web-facing code, no runtime services, no user docs beyond the AGENT.md paragraph already in scope
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions
None. Single specialist contribution with no conflicts.

### Risks and Mitigations
1. **Mid-frequency skip combinations less discoverable**: "Skip tests only" and "Skip review only" move to freeform-only. Mitigated by preserving freeform flag documentation in the same block. Monitor for user confusion.
2. **Label precision for downstream parsing**: Labels must be exact strings. The consumption logic uses the exact labels from the option definitions, reducing mismatch risk.

### Execution Order
```
Batch 1: Task 1 (no dependencies)
```
Single task, no gates, no batching complexity.

### Verification Steps
1. Read the modified SKILL.md and confirm the AskUserQuestion block uses `multiSelect: false` with 3 options
2. Confirm "Run all (recommended)" is option 1
3. Confirm downstream consumption logic references the new option labels
4. Confirm freeform flag documentation is preserved
5. Confirm AGENT.md paragraph is updated
6. Run next orchestrated session to validate the gate UX end-to-end
