# Phase 3: Synthesis -- Eliminate Redundant Orchestrated-Session Tmp File

## Delegation Plan

**Team name**: eliminate-orchestrated-marker
**Description**: Replace dedicated boolean marker file with nefario-status file check in commit hook and SKILL.md lifecycle, eliminating tmp file sprawl.

### Specialist Consensus

All four specialists agree on the approach. Zero conflicts. Key points of consensus:

- The replacement is safe: nefario-status file exists from P1 through wrap-up, covering the full orchestration window
- `-f` is the correct test (not `-s`): existence-only check is safer than non-empty check
- Earlier suppression (P1 vs P4) is a no-op -- no code changes happen during planning phases
- Exactly 3 files need code/instruction changes, 1 file needs a doc edit
- Historical docs (`docs/history/`) are immutable and excluded from scope
- No product messaging impact
- Both docs specialists agree the doc change is a single-paragraph edit in `docs/commit-workflow.md` line 259

### Task Consolidation

The devx-minion identified 5 tasks across 3 files. Both docs specialists identified the same single-paragraph edit. Since all changes are small, low-risk edits in closely related files, and there are no file ownership conflicts, this consolidates into a single execution task for one agent.

---

### Task 1: Replace orchestrated-session marker with nefario-status check
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    ## Task: Replace orchestrated-session marker with nefario-status check

    Replace the dedicated boolean marker file (`/tmp/claude-commit-orchestrated-${SID}`)
    with a check for the nefario status file (`/tmp/nefario-status-${SID}`) in the
    commit hook and SKILL.md lifecycle instructions. This eliminates a redundant tmp
    file and removes a coordination point nefario must explicitly manage.

    Source issue: #73

    ## Changes Required

    Make these 4 edits across 3 files. Each is a small, surgical change.

    ### Edit 1: Update commit hook orchestration check
    **File**: `.claude/hooks/commit-point-check.sh` (lines 139-143)

    Replace:
    ```bash
    # --- Orchestrated session? Exit silently ---
    local orchestrated_marker="/tmp/claude-commit-orchestrated-${session_id}"
    if [[ -f "$orchestrated_marker" ]]; then
        exit 0
    fi
    ```

    With:
    ```bash
    # --- Nefario-orchestrated session? Exit silently ---
    # When nefario's status file exists, commits are managed by the orchestrator.
    local nefario_status="/tmp/nefario-status-${session_id}"
    if [[ -f "$nefario_status" ]]; then
        exit 0
    fi
    ```

    Key: use `-f` (exists check), NOT `-s` (non-empty check). The hook does not
    parse file contents -- it only checks existence.

    ### Edit 2: Remove marker creation from SKILL.md Phase 4
    **File**: `skills/nefario/SKILL.md` (lines 1216-1218)

    Remove these lines entirely:
    ```
    After branch resolution (whether creating a new branch or using an existing one),
    create the orchestrated-session marker to suppress commit hook noise:
    `SID=$(cat /tmp/claude-session-id 2>/dev/null); touch /tmp/claude-commit-orchestrated-$SID`
    ```

    The nefario-status file created at P1 now serves this purpose. No replacement
    text needed -- just delete these 3 lines.

    ### Edit 3: Remove marker from SKILL.md reject/cleanup
    **File**: `skills/nefario/SKILL.md` (line 569)

    Current line:
    ```
    `SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/claude-commit-orchestrated-$SID /tmp/nefario-status-$SID`
    ```

    Replace with (remove the orchestrated marker from the rm command):
    ```
    `SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/nefario-status-$SID`
    ```

    ### Edit 4: Remove marker from SKILL.md wrap-up cleanup
    **File**: `skills/nefario/SKILL.md` (lines 1757-1761)

    Current text:
    ```
    11. **Clean up session markers** — after PR creation (or if declined),
        if in a git repo:
        Remove the orchestrated-session marker and status sentinel:
        `SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/claude-commit-orchestrated-$SID`
        `rm -f /tmp/nefario-status-$SID`
    ```

    Replace with:
    ```
    11. **Clean up session markers** — after PR creation (or if declined),
        if in a git repo:
        Remove the nefario status file:
        `SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/nefario-status-$SID`
    ```

    Consolidate the two `rm -f` commands into one (no need for separate lines
    when there is only one file to remove).

    ### Edit 5: Update documentation
    **File**: `docs/commit-workflow.md` (line 259)

    Current paragraph:
    > During nefario-orchestrated sessions, the Stop hook is suppressed via a session-scoped marker file (`/tmp/claude-commit-orchestrated-<session-id>`). The marker is created at the start of Phase 4 (execution) and removed at wrap-up. When the marker exists, the hook exits 0 immediately, producing no output. This prevents the hook's commit checkpoint from conflicting with the SKILL.md-driven auto-commit flow.

    Replace with:
    > During nefario-orchestrated sessions, the Stop hook is suppressed by checking for the nefario status file (`/tmp/nefario-status-<session-id>`). This file exists for the duration of any orchestrated session and is removed at wrap-up. When the status file exists, the hook exits 0 immediately, producing no output. This prevents the hook's commit checkpoint from conflicting with the SKILL.md-driven auto-commit flow.

    ## Boundaries

    - Do NOT touch `docs/history/` files -- historical reports are immutable
    - Do NOT touch the `claude-commit-declined` marker (line 311 in commit-workflow.md, line 130 in commit-point-check.sh) -- that is a separate mechanism for a different purpose
    - Do NOT change the nefario-status file's content format or lifecycle -- only the commit hook's check and the SKILL.md's references to the old marker are in scope
    - Do NOT modify `docs/decisions.md` -- it references marker files generically, not by the specific path being changed

    ## Verification

    After making all edits:
    1. Grep for `claude-commit-orchestrated` in `.claude/hooks/`, `skills/nefario/`, and `docs/commit-workflow.md` -- should return zero matches
    2. Grep for `nefario-status` in `.claude/hooks/commit-point-check.sh` -- should return 1 match (the check)
    3. Grep for `nefario-status` in `skills/nefario/SKILL.md` -- should return matches at the reject handler, phase update points, and wrap-up cleanup (but NOT at the old Phase 4 marker creation location)
    4. Confirm `docs/commit-workflow.md` line 259 references `nefario-status` not `claude-commit-orchestrated`

- **Deliverables**: Updated `.claude/hooks/commit-point-check.sh`, `skills/nefario/SKILL.md`, `docs/commit-workflow.md`
- **Success criteria**: All 5 edits applied cleanly; verification grep checks pass; no references to `claude-commit-orchestrated` remain outside `docs/history/` and `docs/decisions.md`

---

### Cross-Cutting Coverage
- **Testing**: No dedicated test task. The commit hook is a bash script without a test suite -- verification is via grep checks in the task prompt. Phase 6 will run any existing tests. The behavioral change is minimal (check a different file path).
- **Security**: No new attack surface. The hook check is switching from one tmp file to another with identical semantics (`-f` existence check, same `/tmp` directory, same session-scoped naming). No secrets, auth, or user input changes.
- **Usability -- Strategy**: Not applicable. This is internal plumbing invisible to users. No user journey, workflow, or cognitive load impact.
- **Usability -- Design**: Not applicable. No UI components or user-facing interfaces.
- **Documentation**: Covered by Edit 5 in Task 1. Single-paragraph update to `docs/commit-workflow.md`.
- **Observability**: Not applicable. No runtime services, APIs, or logging changes.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**: none -- this is a 4-line code change + 1-paragraph doc edit with no user-facing, UI, performance, observability, or user-doc implications
- **Not selected**: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions
None. All four specialists are in complete agreement on approach, scope, and risk assessment.

### Risks and Mitigations
1. **Stale status file from crashed session** (low risk, pre-existing): If Claude crashes mid-orchestration, `/tmp/nefario-status-$SID` persists. This is identical to the current behavior (both files would be stale). Session IDs are unique, so stale files from session A do not affect session B. No mitigation needed beyond what already exists.
2. **Earlier suppression window** (no risk): Hook is now suppressed from P1 instead of P4. devx-minion analysis confirms this is a no-op -- no code changes occur during planning phases, so the hook has nothing to act on.

### Execution Order
```
Task 1 (devx-minion) -- all edits are in one task, no dependencies
```

Single-task plan. No batching or gating needed.

### Verification Steps
1. Grep verification (built into Task 1 prompt)
2. Phase 5 code review will catch any missed references
3. Phase 6 will run existing tests to confirm no regressions
