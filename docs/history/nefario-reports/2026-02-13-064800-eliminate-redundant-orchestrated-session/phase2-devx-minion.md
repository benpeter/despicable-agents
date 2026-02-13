# Domain Plan Contribution: devx-minion

## Recommendations

### The replacement is sound but needs one nuance addressed

After reviewing all three touchpoints (the commit hook, the SKILL.md marker lifecycle, and the documentation), switching from the dedicated boolean marker (`/tmp/claude-commit-orchestrated-${SID}`) to the nefario-status file (`/tmp/nefario-status-${SID}`) is a clean simplification. Here is the detailed analysis for each edge case question:

**(a) Scenarios where nefario-status might not exist during active orchestration:**

The nefario-status file is created in Phase 1 (SKILL.md line ~368), well before any code changes happen. It persists through P2, P3, P3.5, and P4, getting updated (overwritten) at each phase boundary. The only removal is at wrap-up (line ~1761) or on reject/abandon (line ~569). There is no gap where the file disappears mid-orchestration.

One potential edge case: if the `echo ... > /tmp/nefario-status-$SID` write at a phase boundary races with the hook's `-f` test, there could be a sub-millisecond window where the file is truncated (empty) before the new content is written. This is a theoretical concern only -- bash `echo "..." > file` is atomic on local filesystems for small writes (single buffer, single `write()` syscall). Not a practical risk on macOS `/tmp` (which is a local filesystem).

**(b) Is `-f` sufficient, or should the hook also check non-empty (`-s`)?**

`-f` (file exists and is a regular file) is sufficient and actually preferable to `-s` (file exists and is non-empty). Here is why:

- The nefario-status file is always written with content (phase label + summary). It is never intentionally empty.
- If we used `-s` and something caused the file to be momentarily empty (e.g., a write race, or a future code path that clears it), the hook would incorrectly fire a commit checkpoint mid-orchestration. That would be a worse failure mode than the alternative.
- Using `-f` means: "if nefario is active (or was active and didn't clean up), suppress the hook." This is the safer default. A stale file after a crashed session is a minor annoyance (suppressed hook in the next session) that self-resolves when the session ID changes.

Recommendation: use `-f` only, matching the current pattern.

**(c) Earlier suppression (P1 vs P4) -- does it cause issues?**

Currently the orchestrated marker is created at P4 start (line ~1218), meaning the commit hook is active during P1-P3.5. Since no code changes happen before P4 (phases 1-3.5 are planning-only), the hook never fires anyway -- there is nothing in the change ledger to trigger it.

With the nefario-status file, suppression starts at P1. This means the commit hook is suppressed during the planning phases too. Impact analysis:

- **Change ledger**: The `track-file-changes.sh` PostToolUse hook is independent of the orchestrated marker. It does not reference either file. The ledger continues to accumulate entries regardless. No impact.
- **Commit checkpoint presentation**: During P1-P3.5, no code files are written (only scratch/planning files under `/tmp`). The ledger would only contain scratch paths that are not in the git working tree, so the hook would exit early at the "no actual git changes" check (line 196-203) even without suppression. No behavioral difference.
- **Wrap-up commit**: At wrap-up, the SKILL.md drives commits directly (not via the hook). The hook suppression is irrelevant here.
- **Abort/reject path**: If the user rejects at the team gate (P1), the cleanup at line 569 removes `nefario-status-$SID` (it already does this!), which means the hook is un-suppressed. Correct behavior.

Net assessment: earlier suppression is a no-op in practice because the hook has nothing to act on during planning phases. It is actually slightly more robust -- it prevents any theoretical edge case where a planning-phase file write accidentally triggers the hook.

### Error message quality in the hook

The current hook comment says `# --- Orchestrated session? Exit silently ---`. When updating, the comment should be updated to reflect the new mechanism. Suggest:

```bash
# --- Nefario-orchestrated session? Exit silently ---
# When nefario's status file exists, commits are managed by the orchestrator.
local nefario_status="/tmp/nefario-status-${session_id}"
if [[ -f "$nefario_status" ]]; then
    exit 0
fi
```

This is better developer documentation for anyone reading the hook. The variable name `nefario_status` is more descriptive than `orchestrated_marker` and directly communicates what is being checked.

## Proposed Tasks

### Task 1: Update commit hook orchestration check
**File**: `.claude/hooks/commit-point-check.sh` (lines 139-143)
**Change**: Replace the `claude-commit-orchestrated` marker check with a `nefario-status` file check. Update the variable name from `orchestrated_marker` to `nefario_status` and update the comment for clarity.

### Task 2: Remove marker creation in SKILL.md Phase 4
**File**: `skills/nefario/SKILL.md` (around line 1216-1218)
**Change**: Delete the two lines that create the orchestrated-session marker (`touch /tmp/claude-commit-orchestrated-$SID`) and the surrounding instructional text. The nefario-status file created at P1 now serves this purpose.

### Task 3: Remove marker from SKILL.md reject/cleanup
**File**: `skills/nefario/SKILL.md` (around line 569)
**Change**: Remove `claude-commit-orchestrated-$SID` from the `rm -f` command in the reject handler. The `nefario-status-$SID` removal already present in that same line is sufficient.

### Task 4: Remove marker from SKILL.md wrap-up cleanup
**File**: `skills/nefario/SKILL.md` (around line 1760)
**Change**: Remove the `rm -f /tmp/claude-commit-orchestrated-$SID` line from wrap-up step 11. The `nefario-status-$SID` removal on the next line handles the hook suppression.

### Task 5: Update documentation
**File**: `docs/commit-workflow.md` (around line 259)
**Change**: Update the paragraph describing hook suppression to reference the nefario-status file instead of the dedicated marker. Note that suppression begins at P1 (not P4) and explain why this is harmless.

## Risks and Concerns

### Low risk: Stale status file from crashed session
If Claude crashes mid-orchestration, the nefario-status file persists in `/tmp`. In the old design, both the orchestrated marker AND the status file would be stale. Now only the status file remains stale. Since session IDs are unique per session, the stale file from session A will not affect session B. The only scenario where this matters is if the user resumes the exact same session after a crash -- but in that case, suppression is actually the desired behavior (the orchestration is still logically active).

### No risk: Behavioral change during planning phases
As analyzed above, the earlier suppression window (P1-P3.5 vs P4-only) causes no behavioral change because the hook has no actionable data during planning phases.

### No risk: File format dependency
The hook uses `-f` (exists check), not any parsing of the file contents. The nefario-status file's content format (phase label + summary) is irrelevant to the hook. The hook does not need to know or care what phase the orchestration is in.

## Additional Agents Needed

None. This is a straightforward file edit task touching a shell script, a SKILL.md, and a documentation file. No additional domain expertise is required beyond what has been analyzed here.
