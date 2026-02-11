# Domain Plan Contribution: devx-minion

## Recommendations

### Problem 1: Git Commit Hook Output Suppression

**Current state**: No active custom git hooks exist in `.git/hooks/` (all `.sample` files). The Claude Code Stop hook (`commit-point-check.sh`) is already suppressed during orchestrated sessions via the marker file at `/tmp/claude-commit-orchestrated-<session-id>`. The noise source is git's own output when `git commit` runs -- git status messages, the commit summary line (`[branch abc1234] message`), and any future pre-commit/commit-msg hook output.

**Recommended approach: SKILL.md and CLAUDE.md instructions to use quiet git commit flags.**

The simplest approach is to add `--quiet` to all `git commit` commands in the orchestration flow. The `--quiet` flag suppresses the commit summary output. This works at the git layer, which is the correct level of abstraction.

Do NOT use `--no-verify` -- the issue explicitly states "Existing hook and tool functionality is unchanged." Hooks must still run; only their noise is suppressed.

For error surfacing: `git commit --quiet` still writes to stderr on errors (e.g., hook failures, empty commits). The Bash tool captures stderr, so errors still surface naturally. No special error-handling wrapper is needed.

**Why not a PreToolUse hook on Bash?** A PreToolUse hook that intercepts `git commit` commands and injects `--quiet` is more complex (regex matching, edge cases with heredocs and multi-line commands) and harder to debug than a one-word change to SKILL.md instructions. The SKILL.md already prescribes how auto-commits work; just add `--quiet` to the prescribed command. KISS.

**Why not a wrapper script?** A wrapper script adds a file, a maintenance burden, and another indirection layer. `--quiet` is a git built-in that does exactly what we need.

**Specific change**: In SKILL.md and CLAUDE.md, wherever auto-commit instructions exist, use:
```bash
git commit --quiet -m "$(cat <<'EOF'
<type>(<scope>): <summary>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

Additionally, add a CLAUDE.md instruction that auto-commits during orchestrated sessions should always use `--quiet`.

### Problem 2: Reducing Read, Write, and Bash Tool Output

**Current state**: No existing mechanism to truncate tool output. Claude Code PostToolUse hooks can return `suppressOutput: true` to hide hook stdout from verbose mode, but this does NOT suppress the tool's own output. There is no hook API to truncate or replace a tool's native output. The `updatedInput` field on PreToolUse can modify tool input before execution.

**Recommended approach: PostToolUse hook with `systemMessage` guidance, combined with CLAUDE.md instructions.**

After extensive review of the Claude Code hooks API, here is the key constraint: **there is no hook mechanism to truncate or replace tool output for Read, Write, or Bash.** The `suppressOutput` field only controls whether the *hook's own stdout* appears in verbose mode -- it does not touch the tool's output that Claude sees. The `updatedMCPToolOutput` field exists but only works for MCP tools, not built-in tools.

Given this constraint, the approach must be indirect. Here are the options ranked by reliability:

#### Option A (Recommended): CLAUDE.md instructions + selective PreToolUse for Bash

1. **CLAUDE.md instruction**: Add a project-level instruction telling the orchestration main session to minimize verbose output from tool calls. Specifically:
   - For Bash commands that are not diagnostic/debugging: pipe through `2>&1 | tail -2` when output is not needed for decision-making.
   - For Read calls: use `offset` and `limit` parameters to read only what is needed.
   - For Write/Edit calls: these already produce minimal output (success/failure) -- no action needed.

2. **PreToolUse hook on Bash (optional, for git commands specifically)**: A PreToolUse hook that detects `git commit`, `git add`, and `git push` commands and appends `2>&1 | tail -2` to suppress verbose output while preserving the last 2 lines (which typically contain the commit summary or error). This targets the highest-noise commands without broadly modifying all Bash calls.

```json
{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/quiet-git-output.sh",
          "timeout": 5
        }
      ]
    }
  ]
}
```

The hook script would:
```bash
#!/usr/bin/env bash
set -euo pipefail
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only modify git commands that produce verbose output
if echo "$command" | grep -qE '^git (commit|add|push|pull|fetch|checkout|merge|rebase)'; then
  # Wrap command to capture output and show last 2 lines
  # Preserve exit code so errors still propagate
  updated_command="${command} 2>&1 | tail -2"
  jq -n --arg cmd "$updated_command" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      updatedInput: { command: $cmd }
    }
  }'
else
  exit 0
fi
```

**IMPORTANT CAVEAT**: Piping through `tail` destroys the exit code. The modified command `git commit ... 2>&1 | tail -2` will always exit 0 (tail's exit code) even if `git commit` fails. This must be addressed with `set -o pipefail` or `PIPESTATUS`:

```bash
updated_command="bash -c 'set -o pipefail; ${command} 2>&1 | tail -2'"
```

This preserves the original command's exit code through the pipe.

#### Option B (Simpler but less precise): CLAUDE.md-only approach

Skip the PreToolUse hook entirely. Add a CLAUDE.md section that instructs the orchestrator:

```markdown
## Session Output Discipline

During orchestrated sessions, keep tool output concise:
- Git commands: always use `--quiet` flag on commit, add, push
- Bash commands with expected verbose output: pipe through `| tail -2`
- Read tool: use offset/limit to read only needed sections
- Do not display full file contents after Write/Edit (the tool confirms success)
```

This is less mechanically enforced but simpler, with zero new hook scripts. The trade-off: Claude may not always follow CLAUDE.md instructions perfectly.

#### Option C (Not recommended): PostToolUse hook with systemMessage

A PostToolUse hook that reads tool_response, truncates it, and returns it via `systemMessage`. Problem: this adds the truncated output as a system message BUT does not remove the original verbose output. Claude sees both. Net effect: more noise, not less.

**My recommendation: Option A** -- the CLAUDE.md instruction plus a targeted PreToolUse hook for git commands. This provides mechanical enforcement for the highest-noise commands (git) and advisory enforcement for everything else, without over-engineering the solution.

### Scoping Note: Main Session Only

The issue specifies changes should not affect subagent sessions. Hook configuration in `.claude/settings.json` applies globally to all sessions (main and subagent). However:

- The PreToolUse hook for Bash can check for an environment variable or marker file to only activate during orchestrated sessions. The orchestrated session marker at `/tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}` already exists for this purpose.
- CLAUDE.md instructions can be scoped to orchestrated sessions by prefixing them with "During nefario orchestration sessions..."
- Alternatively, put the hook in `.claude/settings.local.json` (not committed) if it should only apply locally.

The simplest scoping mechanism: the PreToolUse hook checks for the orchestrated marker file and exits 0 (no modification) if it does not exist.

## Proposed Tasks

### Task 1: Add `--quiet` to auto-commit git instructions

**What**: Update SKILL.md auto-commit instructions to use `git commit --quiet`. Add a CLAUDE.md instruction that orchestrated-session auto-commits always use `--quiet` for `git commit`, `git add` (already quiet by default), and `git push --quiet`.

**Deliverables**:
- Modified `skills/nefario/SKILL.md` -- add `--quiet` to all `git commit` command examples/instructions
- Modified `CLAUDE.md` -- add "Session Output Discipline" section
- Modified `docs/commit-workflow.md` -- document the `--quiet` convention

**Dependencies**: None

### Task 2: Create PreToolUse hook for quiet git output

**What**: Create `.claude/hooks/quiet-git-output.sh` -- a PreToolUse hook that wraps verbose git commands with output truncation. Only activates when the orchestrated-session marker exists (scoped to orchestrated sessions). Uses `set -o pipefail` to preserve exit codes through the pipe.

**Deliverables**:
- New file `.claude/hooks/quiet-git-output.sh`
- Modified `.claude/settings.json` -- add PreToolUse hook entry matching `Bash`

**Dependencies**: Task 1 (for the SKILL.md context; can technically be done in parallel)

### Task 3: Add tests for the quiet git output hook

**What**: Add test cases to `tests/test-commit-hooks.sh` (or a new test file) covering:
- Git commit command is modified when orchestrated marker exists
- Git commit command is NOT modified when marker is absent (subagent/standalone session)
- Non-git Bash commands are not modified
- Exit code preservation through `tail` pipe (error case)
- Edge cases: multi-line commands, commands with pipes already present

**Deliverables**:
- Modified or new test file with 5+ new test cases
- All existing tests still pass

**Dependencies**: Task 2

### Task 4: Update documentation

**What**: Update `docs/commit-workflow.md` and `docs/orchestration.md` to document:
- The `--quiet` convention for auto-commits
- The PreToolUse hook for git output truncation
- The scoping mechanism (orchestrated marker)
- The CLAUDE.md output discipline instructions

**Deliverables**:
- Modified `docs/commit-workflow.md`
- Modified `docs/orchestration.md`

**Dependencies**: Tasks 1-2

## Risks and Concerns

### Risk 1: Exit code destruction through `tail` pipe (HIGH)

Piping `git commit 2>&1 | tail -2` destroys the exit code. If `git commit` fails (exit 1), `tail` still exits 0, and the Bash tool reports success. The agent never learns the commit failed.

**Mitigation**: Use `bash -c 'set -o pipefail; <command> 2>&1 | tail -2'` in the PreToolUse hook to propagate the original exit code.

### Risk 2: PreToolUse hook modifying commands that already have pipes (MEDIUM)

If the agent constructs a git command with existing pipes (`git log | head -5`), naively appending `| tail -2` may produce unexpected behavior.

**Mitigation**: The hook should only modify "simple" git commands -- detect if the command already contains `|` and skip modification. Alternatively, only target specific commands: `git commit`, `git push`, `git add` (not `git log`, `git diff`, etc.).

### Risk 3: CLAUDE.md instructions are advisory, not enforced (LOW)

Claude may not always follow CLAUDE.md instructions perfectly. The `| tail -2` pattern for Read/Write output is guidance, not mechanical enforcement.

**Mitigation**: Acceptable risk. The highest-noise source (git commands) is mechanically enforced via the PreToolUse hook. The CLAUDE.md instructions cover the remaining low-noise tools as a best-effort improvement. If needed, additional PreToolUse hooks can be added later.

### Risk 4: Subagent sessions unexpectedly affected (MEDIUM)

If the PreToolUse hook fires in subagent sessions, it could truncate important output that subagents need for their work.

**Mitigation**: The hook checks for the orchestrated-session marker file. Subagents in the same session share the `CLAUDE_SESSION_ID`, so they WOULD see the marker. This needs careful consideration -- the hook should check for a main-session-only marker, not the orchestrated marker. Alternative: have the hook check an environment variable set only in the SKILL.md flow, but hooks do not receive custom env vars from skills. Best approach: accept that subagent git commands are also quieted during orchestrated sessions. Subagents that need verbose git output (rare) can use `git --no-optional-locks log` or explicit verbose flags.

### Risk 5: `suppressOutput` does not do what the issue assumes (LOW)

The issue mentions `suppressOutput` as a potential approach. Per the Claude Code docs, `suppressOutput: true` only hides "stdout from verbose mode output" -- meaning the hook's own stdout is hidden from the verbose transcript. It does NOT suppress or modify the tool's output that Claude sees. This is a documentation/expectation mismatch, not a code risk.

**Mitigation**: Do not rely on `suppressOutput` for tool output reduction. Use PreToolUse `updatedInput` and CLAUDE.md instructions instead.

## Additional Agents Needed

None. The current consultation set (devx-minion for technical approach, ux-strategy-minion for truncation level validation, test-minion for test strategy, software-docs-minion for documentation updates) covers all aspects. The security, accessibility, and sitespeed implications are nil and do not warrant additional planning consultations.
