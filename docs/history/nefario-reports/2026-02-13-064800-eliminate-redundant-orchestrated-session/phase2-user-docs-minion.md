# Domain Plan Contribution: user-docs-minion

## Recommendations

**There is one user-facing doc that requires a minor update, and all other references are historical (immutable) or internal.**

The grep results (excluding `docs/history/`) show exactly one user-facing documentation file referencing `claude-commit-orchestrated`:

- **`docs/commit-workflow.md`, line 259** -- Section 7 ("Hook Composition") contains a paragraph that explicitly names the marker file path `/tmp/claude-commit-orchestrated-<session-id>` and describes its lifecycle (created at Phase 4 start, removed at wrap-up). This paragraph must be updated to reflect the new mechanism (checking for `/tmp/nefario-status-<session-id>` instead).

The following files also reference the marker but do **not** require updates:

- **`docs/history/` (16+ files)** -- These are historical nefario execution reports. They are immutable records of past decisions. Editing them would falsify the historical record. No changes needed.
- **`skills/nefario/SKILL.md`** -- This is internal agent instructions, not end-user documentation. It falls under the devx-minion's scope. The user-docs-minion flags it as a dependency but does not own it.
- **`.claude/hooks/commit-point-check.sh`** -- Implementation code, not documentation. Owned by devx-minion.
- **`docs/commit-workflow-security.md`** -- Does not reference the marker at all. No changes needed.

The update to `docs/commit-workflow.md` is a one-paragraph text change. The behavioral description stays the same (hook suppression during orchestrated sessions), only the mechanism name changes (from dedicated marker file to nefario status file).

## Proposed Tasks

### Task 1: Update commit-workflow.md Section 7 paragraph

**File:** `docs/commit-workflow.md`, line 259

**Current text:**
> During nefario-orchestrated sessions, the Stop hook is suppressed via a session-scoped marker file (`/tmp/claude-commit-orchestrated-<session-id>`). The marker is created at the start of Phase 4 (execution) and removed at wrap-up. When the marker exists, the hook exits 0 immediately, producing no output. This prevents the hook's commit checkpoint from conflicting with the SKILL.md-driven auto-commit flow.

**Proposed replacement:**
> During nefario-orchestrated sessions, the Stop hook is suppressed by checking for the nefario status file (`/tmp/nefario-status-<session-id>`). This file already exists for the duration of any orchestrated session and is removed at wrap-up. When the status file exists, the hook exits 0 immediately, producing no output. This prevents the hook's commit checkpoint from conflicting with the SKILL.md-driven auto-commit flow.

**Rationale:** The behavioral description is identical -- the hook is suppressed during orchestrated sessions and active during single-agent sessions. The only change is which file is checked. The paragraph correctly describes the lifecycle: the nefario status file is created at session start and removed at wrap-up, which is a broader window than the old marker (Phase 4 start to wrap-up), but the user-visible behavior is the same.

**Dependency:** This text update should land in the same PR as the hook code change (devx-minion's task), so documentation and implementation stay in sync.

**Effort:** Minimal -- single paragraph replacement.

## Risks and Concerns

1. **Low risk: Lifecycle timing difference.** The nefario status file exists from session start (Phase 1), while the old marker was created at Phase 4 start. This means the hook is now suppressed during planning phases too. This is a minor behavioral expansion but is actually more correct -- there is no reason for the Stop hook to fire during planning phases of an orchestrated session. The updated doc text should not call out the Phase 4 timing; instead it should say the file "exists for the duration of any orchestrated session."

2. **No risk: Historical docs.** The `docs/history/` files are immutable records. They accurately describe the state of the system at the time those decisions were made. Updating them would be incorrect.

3. **No risk: End-user experience.** Users never interact with or need to know about these tmp files. The documentation describes them for contributors and maintainers who need to understand the hook architecture. The mechanism change is invisible to end users of the agent system.

## Additional Agents Needed

- **devx-minion** -- Owns the actual code changes to `commit-point-check.sh` and `SKILL.md`. The doc update in `docs/commit-workflow.md` depends on the devx-minion's implementation being finalized first (so the doc accurately reflects the new mechanism).
- **software-docs-minion** -- May want to verify the `docs/commit-workflow.md` update for technical accuracy, since this doc straddles the line between user-facing explanation and internal architecture reference. However, this is a single-paragraph change and likely does not require a separate review pass.
