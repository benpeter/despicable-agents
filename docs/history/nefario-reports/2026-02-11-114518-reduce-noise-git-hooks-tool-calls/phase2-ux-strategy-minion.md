# Domain Plan Contribution: ux-strategy-minion

## Planning Question

Is "last 2 lines" the right truncation level for all contexts? Should error output get more lines? Should there be a verbosity escape hatch for debugging? What is the right cognitive load balance between too-quiet (operator misses problems) and too-noisy (operator tunes out)?

## Recommendations

### 1. "Last 2 lines" is reasonable as a default, but context-sensitivity is essential

Two lines is a sound starting point for success-path output. It aligns with the SKILL.md Communication Protocol, which already specifies a tight information diet: single-line CONDENSE summaries, no phase transitions, no agent narration. The operator is monitoring the orchestration flow, not debugging individual tool calls. Two lines gives enough signal to confirm "something happened" without demanding reading.

However, a flat "always 2 lines" rule violates Nielsen's heuristic #1 (visibility of system status) when applied to errors. Error output carries higher information density per line -- a stack trace's last 2 lines might show a generic exception message without the root cause that appeared 15 lines earlier. The cognitive cost of *missing* an error (debugging a mystery later) far exceeds the cost of *reading* a few extra lines now.

**Recommendation: Two tiers, not one.**

| Outcome | Lines shown | Rationale |
|---------|-------------|-----------|
| Success (exit 0) | Last 2 lines | Confirms completion. Operator scans, moves on. |
| Error (exit non-zero) | Last 10 lines | Captures the meaningful portion of most error output. Enough context for the operator to decide "is this a real problem or a known noise?" without expanding anything. |

Why 10 for errors, not 5 or 20? Error messages in typical CLI tools (git, npm, linters) concentrate the actionable information in the last 5-15 lines. The 10-line threshold catches the majority of useful error context while staying below the point where the operator's eyes glaze over. This is a satisficing heuristic, not a precision target -- 8 or 12 would also be fine. The key principle is: success output is compressed aggressively, error output is compressed gently.

### 2. Git commit hook output: suppress entirely on success, surface on failure

For git commit hooks specifically (pre-commit, commit-msg), the approach should be even more aggressive than "last 2 lines":

- **Success**: Suppress all hook output. The auto-commit informational line (`Committed N files: path1, path2, ...`) already provides the operator confirmation. Hook output on success is pure noise -- it confirms things the operator did not ask about.
- **Failure**: Show the full hook error output, unsuppressed. A failed commit hook is a meaningful event that requires operator attention. Truncating it risks hiding the root cause.

This maps to the SKILL.md Communication Protocol's existing pattern: NEVER SHOW routine output, SHOW warnings and errors. The git commit hooks are an extension of the auto-commit flow, which is already defined as "silent" (informational line only).

### 3. Differentiate by tool type, not just by line count

The issue mentions Read, Write, and Bash tools, but these have different noise profiles:

- **Bash**: Most variable. Output ranges from 0 lines (`mkdir -p`) to thousands (test suites). The 2-line/10-line tier works well here.
- **Write**: Output is typically a confirmation message ("Wrote N bytes to /path"). Already concise. Truncation may not be needed, but 2 lines is harmless.
- **Read**: The tool result contains the file content that Claude needs to process. Suppressing this output in the *operator's* terminal view does not affect Claude's ability to use it. The operator rarely needs to see what Claude read -- they care about what Claude *did* with it. Suppress Read output entirely in orchestrated sessions. Show "Read: /path/to/file (N lines)" as a 1-line summary if any indication is needed.

**Recommendation: Tool-specific truncation rules.**

| Tool | Success | Error |
|------|---------|-------|
| Bash | Last 2 lines | Last 10 lines |
| Write | Last 2 lines (effectively no change -- already concise) | Full output |
| Read | 1-line summary: path + line count | Full output |

### 4. A debugging escape hatch is desirable but should not be built speculatively

The issue asks whether there should be a verbosity escape hatch. From a UX strategy perspective:

**Yes, the need is real.** When debugging orchestration issues, the operator needs to see full tool output. The current problem (too noisy) and the proposed solution (truncated) both have failure modes. The escape hatch resolves the tension.

**No, do not build it in this iteration.** This is a YAGNI situation. The two-tier model (success/error) handles the vast majority of cases. The few debugging scenarios where full verbosity is needed can be addressed by:

1. Removing the truncation hooks temporarily (edit `settings.json`, remove the hook entry, restart)
2. Running Claude Code with `--verbose` if it supports that
3. Checking the Claude Code session transcript logs

Building a toggle mechanism (environment variable, marker file, `/verbose` command) before confirming the two-tier approach works in practice is premature. If operators frequently find themselves needing full output, that is signal to revisit -- but the solution might be "adjust the line count" rather than "add a toggle."

**Record this as a deferred item** in the execution report. If the operator finds the 2/10 split insufficient after 5+ orchestration sessions, add a marker-file toggle (`touch /tmp/claude-verbose-<session-id>`) that the PostToolUse hook checks to bypass truncation.

### 5. Subagent sessions MUST be unaffected

The scope statement says "main session only" and this is critical to get right. Subagents need full tool output to do their work -- truncating a Read result in a subagent would break the agent's ability to process file content. The implementation must scope truncation to the main orchestration session only.

The existing pattern for session-scoped behavior is the marker file (`/tmp/claude-commit-orchestrated-<session-id>`). The truncation hooks should check for this marker and only truncate when it exists. This automatically scopes the behavior to orchestrated sessions and leaves single-agent sessions and subagent sessions at full verbosity.

**Important caveat**: Verify that subagent sessions have different `CLAUDE_SESSION_ID` values from the main session. If they share a session ID (which would be unexpected but should be confirmed), the marker-file approach would incorrectly truncate subagent output. This is a technical verification task for devx-minion.

### 6. The operator's mental model is "watching a dashboard, not running a debugger"

The fundamental insight driving all of these recommendations: during orchestration, the operator is in *monitoring mode*, not *debugging mode*. Their job is:

1. Follow the phase progression (handled by CONDENSE lines and heartbeats)
2. Make approval decisions at gates (handled by decision briefs and AskUserQuestion)
3. Spot problems early (handled by error surfacing)

Tool output does not serve any of these three jobs. It is infrastructure noise -- the equivalent of watching database query logs while reviewing a pull request. The operator should see *outcomes* (committed 3 files, test passed, write succeeded) not *mechanics* (here are 47 lines of git status output).

The Communication Protocol already encodes this principle for agent-level output (SHOW/NEVER SHOW/CONDENSE). This task extends the same principle to tool-level output. The conceptual alignment is strong.

## Proposed Tasks

### Task 1: Define truncation rules in CLAUDE.md or SKILL.md

Add a "Tool Output Verbosity" section that codifies the truncation rules for orchestrated sessions. This becomes the spec that hook scripts implement. Include the two-tier model (success/error), the tool-specific rules, and the marker-file scoping mechanism. This is a documentation/spec task, not a code task.

**Deliverables**: Updated SKILL.md or CLAUDE.md section
**Dependencies**: None (can run in parallel with hook implementation)

### Task 2: Verify subagent session isolation

Confirm that subagent sessions spawned by the main orchestration session have distinct `CLAUDE_SESSION_ID` values. If they share the main session's ID, the marker-file scoping strategy needs adjustment. This is a quick verification task.

**Deliverables**: Confirmation of session ID isolation (or alternative scoping mechanism)
**Dependencies**: None

### Task 3: UX acceptance criteria for hook testing

Define the operator-facing acceptance criteria that test-minion can translate into test scenarios:

- In orchestrated session, successful `git commit` produces zero lines of hook output in the main transcript
- In orchestrated session, failed `git commit` surfaces the hook error output (untruncated)
- In orchestrated session, Bash tool success output shows at most 2 lines
- In orchestrated session, Bash tool error output shows at most 10 lines
- In single-agent session, all output remains at full verbosity (no truncation)
- Read tool in orchestrated session shows a 1-line path summary, not file content
- Write tool in orchestrated session shows at most 2 lines

**Deliverables**: Acceptance criteria list (this contribution)
**Dependencies**: None

## Risks and Concerns

### Risk 1: Error output truncation hides root causes (MEDIUM)

Even 10 lines may not be enough for some error scenarios (e.g., TypeScript compilation errors that list multiple files). The operator sees a truncated error and cannot diagnose the problem without expanding.

**Mitigation**: The 10-line threshold is a starting point. If the PostToolUse hook truncates, it should append a trailing line: `[N more lines -- check tool output]` so the operator knows content was cut. This is a minimal progressive disclosure cue. The full output remains in the Claude Code transcript/log.

### Risk 2: Operator loses ambient awareness of session progress (LOW)

If tool output is too quiet, the operator may not be able to distinguish "session is working" from "session is stuck." The SKILL.md heartbeat mechanism (status line every 60 seconds of silence) mitigates this, but the combination of suppressed tool output and infrequent heartbeats could create an uncomfortably long silence.

**Mitigation**: The existing heartbeat mechanism is sufficient. Suppressing *tool output* does not suppress *Claude's conversational output* (CONDENSE lines, gate briefs, commit informational lines). The operator still sees the orchestration flow. Quiet tool output between Claude's own messages is expected behavior, not alarming silence.

### Risk 3: Two-tier logic adds complexity to hook scripts (LOW)

Checking exit codes, branching on success/error, counting lines -- this adds logic to hooks that should be simple. More logic means more potential for bugs that could either hide errors (silent failure) or break the pipeline (hook crashes).

**Mitigation**: The implementation should be a single reusable function (e.g., `truncate_output()`) called from the PostToolUse hook. Keep it under 20 lines. Test it with both success and error scenarios. The logic is: capture output, check exit code, count lines, emit last N, append truncation marker if cut. This is a standard Unix pattern (`command 2>&1 | tail -N`), not novel logic.

### Risk 4: Flat "2 lines" may be wrong for some Bash commands (LOW)

Some Bash commands produce exactly 2-3 lines of useful output on success (e.g., `git status --short`, `wc -l`). Truncating to 2 lines preserves the useful information. But commands like `find` or `ls -la` might produce output where the last 2 lines are random entries, not a summary. The operator would see meaningless tail output.

**Mitigation**: This is acceptable. The operator is not reading Bash output for information -- Claude is. The 2-line tail is a "something happened" signal, not a data source. If the operator needs to see full output, they can check the transcript. The truncation line (`[N more lines]`) signals that there was more output.

## Additional Agents Needed

None. The current team (devx-minion for implementation, test-minion for testing, software-docs-minion for documentation) is sufficient. The UX strategy contribution here provides the cognitive load analysis and truncation rules; devx-minion translates them into hook scripts and configuration.
