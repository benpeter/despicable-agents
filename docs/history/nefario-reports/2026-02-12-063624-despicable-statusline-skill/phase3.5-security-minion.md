# Security Review: despicable-statusline Skill

## Verdict: ADVISE

## Warnings

### 1. Command Injection Risk in statusLine.command (MEDIUM)

**Issue**: The plan instructs devx-minion to compose shell commands by string concatenation and parameter expansion, then inject them into `settings.json`. The `statusLine.command` is executed periodically by Claude Code with user privileges.

**Specific vectors**:
- Line 91-95: bash parameter expansion `${current%echo \"\$result\"*}${snippet}echo \"\$result\""` operates on untrusted input (existing user command). If the existing command contains crafted escape sequences or unbalanced quotes, the expansion could produce executable code that differs from intent.
- The snippet `f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null)` uses unvalidated `$sid` in a file path. While `$sid` originates from Claude Code's session management (trusted), there is no explicit validation. If session ID generation changes or is compromised, this becomes a path traversal vector.

**Impact**: Arbitrary code execution in the user's shell context.

**Mitigation**:
- The SKILL.md must instruct Claude Code to validate the existing command structure before modification. Specifically: check for unbalanced quotes, null bytes, and newline characters. Reject modification if found (fall back to State D manual instructions).
- Consider using `jq` for ALL shell command manipulation, not just JSON updates. Store the command as a jq string literal to preserve escaping.
- Add explicit validation: `$sid` must match `[a-zA-Z0-9_-]+` before use in file paths.

### 2. Temp File Race Condition (LOW)

**Issue**: `/tmp/nefario-status-$sid` is created and read without atomic operations or permission verification. On multi-user systems, this file is world-readable by default.

**Impact**: Information disclosure (orchestration phase status is not sensitive, but the pattern is unsafe). No privilege escalation or DoS because the file is only read, not executed.

**Mitigation**: The SKILL.md should document that nefario (when writing status) must use `mktemp` with user-only permissions (`chmod 600`) or write to a user-specific directory like `~/.cache/nefario/`.

### 3. Backup File Overwrites (LOW)

**Issue**: Line 119 specifies a static backup path `~/.claude/settings.json.backup-statusline`. Repeated invocations overwrite the previous backup. If a user invokes the skill, corruption occurs, they invoke again (expecting it to fix itself via idempotency), the first backup is lost.

**Mitigation**: Use timestamped backups or check if backup already exists before overwriting.

### 4. jq Dependency Assumption (INFORMATIONAL)

**Issue**: Line 256-259 claims "a user without jq already has a non-functional status line" but that only holds if they configured statusLine as a command using jq. A user could have no statusLine at all (absent config) and thus no jq dependency yet.

**Mitigation**: The SKILL.md should explicitly check for jq availability and provide a clear error before attempting JSON manipulation, not rely on transitive assumptions.

## Non-Issues (Confirmed Safe)

- **Trust boundary**: settings.json is user-owned, local-only. Modification is within expected privilege domain.
- **Idempotency check** (line 70-73): Safe. Substring match on `nefario-status-` is sufficient for detection. False positives (user manually added that string) are acceptable because the behavior is still correct (no-op).
- **JSON validation** (lines 118-121): Correct approach. Pre/post validation with rollback is appropriate defense.
- **Atomic write pattern** (line 83-84): Correct. Temp file + mv is atomic on POSIX systems.

## Recommendation

Proceed with Task 1 after incorporating mitigations for warnings 1, 2, and 3. These are implementable within the SKILL.md prompt without changing the delegation plan structure. Devx-minion should be instructed to add validation steps for existing command structure and session ID format.
