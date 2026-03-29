## Phase 3.5 Review: security-minion

**Verdict**: APPROVE

**Scope reviewed**: Translation pipeline security -- temp file handling, content injection via crafted AGENT.md, stripping completeness, output validation, file permission model.

### Assessment

The plan addresses the primary security concerns correctly:

1. **File creation TOCTOU (CWE-367)**: Handled. `umask 077` before write, no create-then-chmod race. This matches the adapter behavioral contract requirement for 0600 temp files.

2. **Frontmatter delimiter confusion**: Handled. Structural awk state machine distinguishes frontmatter `---` from body horizontal rules. Fail-closed on unclosed frontmatter. Corpus smoke test validates all 27 agents.

3. **Output validation**: Handled. Four checks: no residual frontmatter, non-empty output, size sanity warning, null byte rejection. Fail-closed design throughout.

4. **No shell injection surface**: The translator reads a file, processes with awk/sed, writes to a caller-provided path. No user-controlled strings are interpolated into shell commands. The `--output PATH` is used as a file operand, not interpolated into a shell string. The `task_prompt` is not processed by the translator at all.

5. **Sed pattern narrowness**: Correct scoping -- PascalCase tool tokens only (`TaskUpdate`, not `Task`), compound patterns (`nefario-scratch`, not `scratch`), `CLAUDE.md` deliberately preserved. This prevents false-positive stripping that could silently corrupt agent instructions.

6. **No content injection by translator**: The translator strips content but never adds content (except the one-line provenance comment for conventions-md format). No preamble injection, no template expansion. This minimizes the attack surface for injecting instructions via the translation layer.

### Advisory Notes (non-blocking)

**A1: Output path traversal** -- The plan states the caller provides `--output PATH`. The translator should validate that the output path is writable and does not traverse to unexpected locations (e.g., `--output /etc/passwd`). In practice, the caller is the adapter layer (trusted), and the adapter already validates `working_directory`. But a defensive `realpath` check on the output path before writing would add defense-in-depth. Low severity since the caller is internal infrastructure, not user-facing.

**A2: Sed pattern file integrity** -- The `lib/claude-code-patterns.sed` file is loaded at runtime. If an attacker could modify this file, they could inject arbitrary sed commands that alter agent instructions (stored prompt injection vector). Since this file lives in the repo under version control and is deployed via `install.sh`, the risk is mitigated by standard VCS controls. No action needed beyond normal code review practices.

**A3: Frontmatter JSON construction via printf** -- Building JSON with printf (no jq) is fragile if frontmatter values contain characters that break JSON syntax (double quotes, backslashes, newlines). The plan specifies flattening multi-line descriptions, but does not mention escaping special characters in the JSON output. If a `description:` field contains a literal `"` character, the JSON will be malformed. The devx-minion implementing Task 1 should ensure JSON-special characters are escaped in the printf construction. Low severity -- malformed JSON causes a parse error (fail-loud), not a security bypass.

These are implementation-time considerations, not plan-level blockers. The security design is sound.
