# Domain Plan Contribution: test-minion

## Recommendations

### 1. Extend the existing bash test suite, do not create a new one

The project already has a well-structured test suite at `/Users/ben/github/benpeter/despicable-agents/tests/test-commit-hooks.sh` with 18 tests covering the tracker hook and commit-point-check hook. The new noise-reduction hooks should be tested by extending this file (or a sibling file following the same pattern), not by introducing a different framework. The existing setup/teardown, JSON helpers, and pass/fail infrastructure are directly reusable.

### 2. Two distinct test domains require different strategies

**Domain A: Git commit output suppression.** The meta-plan identifies that git's own commit hooks (pre-commit, commit-msg) produce inline output. The likely implementation is wrapping `git commit` to capture stdout/stderr and only surface it on error. This is testable: create a real git repo with a custom pre-commit hook that produces output, run the wrapped commit, and assert the output is suppressed on success but surfaced on failure.

**Domain B: Tool output truncation via hooks.** The meta-plan notes that Claude Code PostToolUse hooks can return `suppressOutput: true` to hide hook stdout from verbose mode, and `systemMessage` to inject a message. However, there is **no documented mechanism** for a hook to truncate or modify a tool's native response that Claude sees. The "last 2 lines" behavior will likely need to be achieved through one of:
- A PreToolUse hook on Bash that wraps commands with `| tail -2`
- CLAUDE.md/SKILL.md instructions directing the agent to pipe through tail
- A PostToolUse hook that returns `suppressOutput: true` plus a `systemMessage` containing the truncated output

Each approach has different testability. PreToolUse hooks that modify `updatedInput` are testable by feeding JSON to the hook script and asserting the output JSON. CLAUDE.md instructions are not directly testable via automated tests (they are prompt engineering). PostToolUse hooks with `suppressOutput` are testable at the script level but their effect on the Claude session requires manual verification.

### 3. Error preservation is the critical safety property

The single most important test category is: **errors must not be swallowed**. For every noise-reduction mechanism, there must be a corresponding test that verifies error output is preserved. This means:
- Git commit hook that exits non-zero: stderr must appear in the session
- Bash command that fails: last 2 lines must include the error, or full output must be shown
- Write/Edit tool that fails: error must not be truncated

The risk of this task is not that the suppression does not work -- it is that the suppression works too well and hides real failures.

### 4. Subagent isolation must be verified by absence of the orchestrated marker

The orchestrated-session marker file (`/tmp/claude-commit-orchestrated-<session-id>`) already gates whether the Stop hook is suppressed. Any new noise-reduction hooks should also check for this marker (or use the same gating mechanism). The test should verify that when the marker is absent (i.e., a non-orchestrated or subagent session), the noise reduction is NOT applied. Subagents get their own session IDs, so the marker file created by the main session does not exist for them.

### 5. Test the hook output JSON structure, not the Claude session behavior

We can test hook scripts in isolation: feed them JSON on stdin, capture stdout/stderr, assert exit codes and JSON output. We cannot (and should not try to) test the end-to-end effect on the Claude session in automated tests. The boundary is: scripts produce the correct JSON responses; Claude Code interprets those responses according to its documented behavior.

## Proposed Tasks

### Task T1: Git commit output suppression tests

Add tests to `tests/test-commit-hooks.sh` (or a new sibling `tests/test-noise-reduction.sh` following the same pattern) that verify:

1. **Success path suppresses output.** Create a git repo with a pre-commit hook that writes "HOOK OUTPUT" to stdout. Run the commit wrapper/script. Assert that "HOOK OUTPUT" does NOT appear in the captured output. Assert exit code is 0 (commit succeeded).

2. **Failure path surfaces output.** Create a git repo with a pre-commit hook that writes "ERROR: validation failed" to stderr and exits 1. Run the commit wrapper/script. Assert that "ERROR: validation failed" DOES appear in the captured output. Assert exit code is non-zero.

3. **Commit still happens when output is suppressed.** After a successful wrapped commit, verify with `git log --oneline -1` that the commit was actually created. This guards against accidentally using `--no-verify` which would suppress output by skipping hooks entirely.

4. **Multi-line hook output is fully suppressed on success.** Pre-commit hook produces 50 lines of linting output. After success, none of it appears.

5. **Git commit-msg hook errors also surface.** Similar to test 2 but with a commit-msg hook (runs after pre-commit). Verify that errors from this later phase also surface.

### Task T2: PostToolUse noise-reduction hook tests

If the implementation uses a PostToolUse hook (likely on Bash, Read, Write):

1. **Hook returns correct JSON for successful tool call.** Feed the hook a PostToolUse JSON with a successful `tool_response`. Assert the hook outputs `{"suppressOutput": true, "systemMessage": "<last 2 lines>"}` (or whatever the agreed truncation format is).

2. **Hook preserves full output on tool error.** Feed the hook a PostToolUseFailure JSON (or a tool_response indicating failure). Assert the hook does NOT return `suppressOutput: true`, or returns the full error in `systemMessage`.

3. **Hook handles empty output.** Tool that produces no output. Assert clean JSON with no systemMessage or an empty one.

4. **Hook handles single-line output.** Tool that produces 1 line. Assert that line is preserved (not truncated further).

5. **Hook handles binary/non-text output gracefully.** Bash command output with null bytes or binary data does not crash the hook.

### Task T3: PreToolUse command-wrapping tests (if this approach is chosen)

If the implementation uses a PreToolUse hook to wrap Bash commands:

1. **updatedInput wraps the command correctly.** Feed the hook a PreToolUse JSON for `Bash` with command `ls -la`. Assert the output JSON contains `updatedInput.command` wrapping the original command (e.g., `(ls -la) 2>&1 | tail -2`).

2. **Wrapping preserves exit codes.** Run the wrapped command `false` (exit 1). Assert the wrapper script preserves the non-zero exit code after piping through tail.

3. **Read and Write tools are NOT wrapped.** Feed the hook a PreToolUse JSON for `Read` tool. Assert no `updatedInput` is returned (Read output is not modified this way).

4. **Subagent sessions are not wrapped.** If the hook checks the orchestrated marker, feed it JSON without the marker present. Assert no wrapping occurs. (See Risk R2 below for the nuance here.)

### Task T4: Orchestrated-session scoping tests

1. **Marker present: noise reduction active.** Create the orchestrated marker file. Run the noise-reduction hook. Assert suppression behavior.

2. **Marker absent: noise reduction inactive.** Do NOT create the marker. Run the same hook. Assert full/normal output behavior (no suppression).

3. **Different session ID: not affected.** Create marker for session-A. Run hook with session-B. Assert hook does not suppress (different marker path).

### Task T5: Regression tests for existing hooks

After all changes, run the full existing test suite:

```bash
./tests/test-commit-hooks.sh
```

All 18 existing tests must still pass. This is the regression gate -- no existing commit workflow behavior may change.

## Risks and Concerns

### R1: Error masking is the highest-severity risk

If the noise-reduction mechanism is too aggressive, real errors will be hidden from the operator. This is worse than the current noisy state, because noise is annoying but error masking causes silent failures. The test strategy addresses this with explicit error-path tests for every suppression mechanism, but the implementation must be designed to fail-open (show output if uncertain) rather than fail-closed (suppress if uncertain).

**Mitigation:** Every test for successful suppression must have a mirror test for error preservation. The review checklist should verify a 1:1 ratio of "suppresses on success" to "surfaces on error" tests.

### R2: Subagent scoping is ambiguous in the issue

The issue says "out: tool behavior outside the main session." The meta-plan uses the orchestrated-session marker file to scope behavior. However, the marker file pattern only distinguishes "orchestrated session" from "non-orchestrated session." It does NOT distinguish "main session" from "subagent within the same orchestrated session."

Subagents spawned by the main session get their own `session_id` (confirmed by the Claude Code hooks documentation showing `agent_id` in SubagentStart), so the orchestrated marker for the main session's ID would not exist for subagent session IDs. This means noise reduction would NOT apply to subagents by default, which is the desired behavior.

**But:** if the implementation uses `.claude/settings.json` hooks (which apply project-wide to ALL sessions including subagents), there needs to be explicit gating to NOT suppress output in subagent contexts. The marker-file approach provides this naturally. A CLAUDE.md instruction approach does NOT -- instructions apply to all sessions equally.

**Mitigation:** Add explicit test T4 that verifies session-scoping. Recommend the implementation use marker-file gating rather than CLAUDE.md instructions.

### R3: The "last 2 lines" requirement may be too aggressive for error output

Two lines of output is enough for "Committed 3 files: a, b, c" but may not be enough for a stack trace or multi-line error message. The implementation should distinguish between success output (truncate to 2 lines) and error output (show more, or show all).

**Mitigation:** Tests T2.2 explicitly verifies that error output is not truncated. The ux-strategy-minion should weigh in on whether error output should have a different truncation threshold.

### R4: PreToolUse command wrapping can break piped commands

If the implementation wraps Bash commands by appending `| tail -2`, this breaks commands that are already piped, commands that use here-docs, or commands where the exit code matters (pipe masks exit code unless `set -o pipefail` is used).

**Mitigation:** Test T3.2 specifically tests exit code preservation. If the PreToolUse wrapping approach is chosen, additional tests should cover: already-piped commands, commands with `&&` chains, commands with heredocs, and background commands (`&`).

### R5: PostToolUse hooks cannot modify what Claude sees from the tool

Based on the Claude Code hooks documentation, PostToolUse hooks fire AFTER the tool has already executed. The `tool_response` is already in Claude's context. The `suppressOutput` field only hides the hook's own stdout from verbose mode -- it does NOT suppress or modify the tool's response. The `systemMessage` field adds a message to the user, not to Claude's context.

This means a PostToolUse-only approach **cannot achieve the "last 2 lines" requirement** for what Claude sees. It can only affect what the human operator sees in verbose mode. If the goal is to reduce noise in the operator's view, PostToolUse with `suppressOutput` works. If the goal is to reduce context window consumption, only PreToolUse command wrapping or SKILL.md instructions work.

**Mitigation:** Clarify with the devx-minion what exactly "output is reduced to the last 2 lines in the main session" means: (a) what the operator sees, (b) what Claude's context window contains, or (c) both. The test strategy differs for each.

### R6: No automated end-to-end verification possible

We can test hook scripts in isolation (feed JSON, check output). We cannot automatically test the full chain: "Claude runs a command -> hook fires -> operator sees reduced output." This gap means manual verification is needed for the final integration. The automated tests cover the scripts; a human must verify the session experience.

**Mitigation:** Document a manual test checklist for the implementer to run after automated tests pass. Include specific commands to run in a Claude Code session and expected visible output.

## Additional Agents Needed

None. The current team (devx-minion for implementation, ux-strategy-minion for truncation thresholds, user-docs-minion for documentation) is sufficient. The test strategy outlined here can be executed by the implementing agent alongside the implementation, following the existing bash test patterns in the repo. No specialized test tooling or infrastructure is needed.
