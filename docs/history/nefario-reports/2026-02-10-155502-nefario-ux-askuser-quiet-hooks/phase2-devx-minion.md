# Domain Plan Contribution: devx-minion

## Recommendations

### The Problem in Detail

The `commit-point-check.sh` Stop hook fires every time Claude finishes a response. During nefario orchestration, this happens many times per session -- after spawning agents, after monitoring task completion, after processing gate approvals, and during wrap-up. Each firing that finds uncommitted changes outputs a ~30-line stderr block containing:

- A commit checkpoint template with formatting instructions
- Staging commands listing every changed file
- PR creation suggestions
- Extensive instructions about commit message conventions

This output is injected into the conversation as Claude's context (because exit code 2 blocks the stop and feeds stderr back). The nefario SKILL.md already drives auto-commits after gate approvals (Phase 4, step 5) and at wrap-up (step 8), making the Stop hook entirely redundant during orchestrated sessions. The hook output does not just add noise -- it actively fights the orchestration flow by trying to take over commit behavior that SKILL.md already manages.

### Recommended Approach: Session Marker File (Option C/D Hybrid)

Use a session-scoped marker file -- consistent with the existing `defer_marker` and `declined_marker` patterns already in the hook. The hook checks for the marker early and exits silently when it exists.

**Why this approach wins over alternatives:**

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| (a) Branch name detection (`nefario/*`) | Zero config, auto-detects | Fragile: breaks if branch naming changes. Also fires during non-orchestrated work on a nefario branch (e.g., manual follow-up). False positives. | Reject |
| (b) More concise output | Reduces but does not eliminate noise. Even a 1-line output on every stop during orchestration is unacceptable -- it accumulates across 20+ stops per session. | Still noise | Reject |
| (c) Session marker file | Consistent with existing patterns (defer, declined markers). Explicit opt-in. Zero false positives. Easy to debug (file exists or not). | Requires SKILL.md to create the marker | **Accept** |
| (d) Environment variable | Clean, no file I/O | Claude Code hooks do not receive custom env vars from SKILL.md context. The hook only gets stdin JSON + standard env. Not viable without platform changes. | Reject |

### Mechanism Design

**Marker file path:** `/tmp/claude-commit-orchestrated-<session-id>`

This follows the exact naming convention of the existing markers:
- `/tmp/claude-change-ledger-<session-id>.txt` (ledger)
- `/tmp/claude-commit-defer-<session-id>.txt` (defer marker)
- `/tmp/claude-commit-declined-<session-id>` (declined marker)

**Hook change (commit-point-check.sh):** Add an early-exit check right after the existing `defer_marker` check (around line 137), before any file processing:

```bash
# --- Orchestrated session? Exit silently ---
local orchestrated_marker="/tmp/claude-commit-orchestrated-${session_id}"
if [[ -f "$orchestrated_marker" ]]; then
    exit 0
fi
```

This is 3 lines of code. It slots in naturally with the existing guard clauses. The exit code is 0 (allow stop), so it is completely silent -- no stderr output at all.

**SKILL.md change:** At the start of Phase 4 (Execution), immediately after branch creation but before spawning any agents, create the marker:

```bash
touch /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}
```

This instruction should be added to the "Branch Creation" section of Phase 4 in SKILL.md. The marker persists for the session duration and suppresses all Stop hook checkpoint output.

**Cleanup:** At wrap-up (after step 11 -- return to main), remove the marker:

```bash
rm -f /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}
```

If the session crashes or is interrupted, the marker persists in `/tmp/` until the system cleans it or the next session starts. This is harmless -- session IDs are unique, so a stale marker from session A never affects session B.

### Why Not Defer-All?

The existing `defer-all` mechanism (already in the hook) might seem like it solves this -- the SKILL.md could simply trigger a defer at session start. But defer-all has different semantics: it defers commits to wrap-up, implying they should eventually happen via the hook. The orchestrated marker says "this session manages its own commits via SKILL.md; the hook should not participate at all." The distinction matters for:

1. **Correctness**: defer-all expects the hook to eventually run at wrap-up. The orchestrated marker says "never run."
2. **Clarity**: A developer debugging hook behavior sees `orchestrated_marker` and immediately understands why the hook is silent. `defer_marker` would be misleading -- it implies the hook will run later.
3. **Future flexibility**: If we later want orchestrated sessions to use the hook differently (e.g., for validation-only, without output), the orchestrated marker gives us a distinct control point.

### Output Conciseness (Secondary Improvement)

Even for single-agent sessions, the current Stop hook output is verbose (~30 lines). While this is not the primary problem (it fires once in single-agent sessions), it would benefit from tightening. However, this is a separate concern and should NOT be bundled with the orchestrated-session fix. Keep the scope minimal: add the marker check, done.

If desired as a follow-up: reduce the single-agent checkpoint output from ~30 lines to ~10 lines by cutting the commit message rules section and the PR suggestion section (Claude already knows these conventions from CLAUDE.md).

## Proposed Tasks

### Task 1: Add orchestrated-session marker check to commit-point-check.sh

**What to do:** Add an early-exit guard clause in the `main()` function of `.claude/hooks/commit-point-check.sh`. The check should:
1. Compute the marker path: `/tmp/claude-commit-orchestrated-${session_id}`
2. If the marker file exists, `exit 0` (silent, allow stop)
3. Place this check after the `defer_marker` check (line ~137) and before the sensitive patterns file check

**Deliverables:**
- Modified `.claude/hooks/commit-point-check.sh`

**Dependencies:** None. Can run in parallel with Task 2.

### Task 2: Add marker creation/cleanup to SKILL.md

**What to do:** Add two instructions to SKILL.md:
1. In Phase 4 "Branch Creation" section (after the `git checkout -b nefario/<slug>` step), add: "Create the orchestrated-session marker: `touch /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`"
2. In the Wrap-up Sequence (after step 10 -- return to main), add: "Remove the orchestrated-session marker: `rm -f /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`"

**Deliverables:**
- Modified `skills/nefario/SKILL.md` (symlinked to `~/.claude/skills/nefario/SKILL.md`)

**Dependencies:** None. Can run in parallel with Task 1.

### Task 3: Update commit-workflow.md

**What to do:** Add a brief note in Section 7 (Hook Composition) or Section 3 (Trigger Points > Orchestrated Sessions) explaining that the Stop hook is suppressed during orchestrated sessions via a session marker. One paragraph, referencing the marker file path.

**Deliverables:**
- Modified `docs/commit-workflow.md`

**Dependencies:** After Task 1 (so the doc describes the implemented behavior).

## Risks and Concerns

### Risk 1: Marker not created if branch creation is skipped
**Severity:** Low
**Scenario:** SKILL.md says "If already on a non-main feature branch, use it (do not create a nested branch)." If the user starts on an existing branch, the branch creation block is skipped. If the marker creation is only inside the branch creation block, it would be missed.
**Mitigation:** Place the marker creation instruction after the branch creation decision block, not inside it. It should always run at the start of Phase 4, regardless of whether a new branch was created.

### Risk 2: Session ID availability
**Severity:** Very low
**Scenario:** The `CLAUDE_SESSION_ID` environment variable might not be set in all contexts.
**Mitigation:** The hook already handles this with a fallback to `"default"`. SKILL.md runs in the main Claude Code session, which always has `CLAUDE_SESSION_ID`. The SKILL.md instruction should reference `${CLAUDE_SESSION_ID}` directly (Bash will expand it from the environment).

### Risk 3: Stale markers from crashed sessions
**Severity:** Very low
**Scenario:** If a session crashes mid-orchestration, the marker persists in `/tmp/`. A future session with the same session ID would find the marker and suppress the hook.
**Mitigation:** Session IDs are unique per session. `/tmp/` is cleared on reboot. The probability of session ID collision is negligible. No action needed.

### Risk 4: Marker accidentally suppresses single-agent sessions
**Severity:** Very low
**Scenario:** Someone copies the marker touch command into a non-orchestrated workflow.
**Mitigation:** The marker name is explicit (`orchestrated`). It is only documented in SKILL.md and commit-workflow.md. The hook script has a comment explaining its purpose. This is a "don't shoot yourself in the foot" scenario, not a systemic risk.

## Additional Agents Needed

None. The three-agent planning team (ux-strategy-minion, ai-modeling-minion, devx-minion) covers all domains for this task. The hook change is a 3-line shell script modification. The SKILL.md change is two single-line additions. The docs change is one paragraph.
