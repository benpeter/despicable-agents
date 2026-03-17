## Domain Plan Contribution: security-minion

### Recommendations

#### 1. Input Sanitization for `agent_type` -- MEDIUM risk, straightforward mitigation

**Can `agent_type` contain attacker-controlled content that causes injection?**

Yes, but the practical risk is Medium, not Critical. Here is the reasoning:

**Source of the data.** `agent_type` comes from Claude Code's hook event JSON,
not from arbitrary user input. It is set by:
- The `--agent` CLI flag (which maps to the `name` field in AGENT.md YAML frontmatter)
- The `subagent_type` parameter when spawning subagents via the Task tool

In normal operation, values are agent names like `nefario`, `frontend-minion`,
`security-minion`. However, the hook script cannot trust that values will always
conform to this pattern. The Claude Code runtime is the source, but:

1. A future Claude Code version could change the schema.
2. A malformed or adversarial AGENT.md `name` field could flow through.
3. If the user runs `--agent` with an arbitrary string, that string becomes
   `agent_type`.

**Where the value flows.** The proposed change writes `agent_type` to the
change ledger (a temp file), and it is later read by the commit-point-check
hook to construct commit messages presented via stderr. The commit message
is then executed via `git commit -m "..."`. This creates two injection surfaces:

- **Shell injection in commit message**: If `agent_type` contains shell
  metacharacters (`;`, `$()`, backticks) and is interpolated unquoted into
  `git commit -m $msg`, command injection occurs. **Mitigation**: Always
  double-quote variables. The existing codebase already does this correctly.
  The commit message is constructed by Claude (not the hook), so the hook's
  job is to pass the value safely. As long as the value is quoted when written
  and read, shell injection is prevented.

- **Git trailer injection**: If `agent_type` contains newlines, an attacker
  could inject additional git trailers or headers into commit messages. For
  example, `agent_type` of `frontend-minion\n\nSigned-off-by: attacker@evil.com`
  could add a fake sign-off. **Mitigation**: Strip or reject newlines and
  carriage returns from `agent_type`, just as the existing code does for
  `file_path`.

**Recommended validation for `agent_type` (and `agent_id`):**

```bash
# Validate agent_type: alphanumeric, hyphens, underscores only.
# Max 64 chars. Reject anything else.
if [[ -n "$agent_type" ]] && ! [[ "$agent_type" =~ ^[a-zA-Z0-9_-]{1,64}$ ]]; then
    agent_type=""  # Fall back to empty (unknown agent)
fi
```

This regex matches all current agent names (`security-minion`, `nefario`,
`frontend-minion`, etc.) and rejects anything with spaces, newlines, shell
metacharacters, or excessive length. Failing open (clearing the value to empty)
is acceptable here because `agent_type` is informational, not a security
control. The commit still happens; it just lacks attribution.

#### 2. `/tmp/` Information Leakage -- LOW risk, no change needed

**Does storing agent metadata in `/tmp/` create additional leakage?**

No meaningful additional risk beyond what `session_id` already exposes. Here
is the analysis:

- **Current state**: The ledger file at `/tmp/claude-change-ledger-<session_id>.txt`
  already reveals: (a) that Claude Code is running, (b) the session ID, and
  (c) every file path being modified. This is the highest-value information
  already present.

- **Proposed addition**: Adding `agent_type` (e.g., `frontend-minion`) to each
  ledger line tells a local observer which agent produced each change. This is
  strictly less sensitive than the file paths themselves.

- **Threat model**: The only actors who can read `/tmp/` are: (a) the same user
  (no concern), (b) root (no defense possible), (c) other users on a shared
  system (mitigated by default `/tmp/` permissions -- files are created with
  the user's umask, typically `0600` via `touch`). On macOS (this project's
  platform), `/tmp/` is actually a symlink to `/private/tmp/` with sticky bit,
  and `touch` creates files with `0644` by default.

- **One minor hardening**: Consider creating ledger files with explicit
  permissions: `install -m 0600 /dev/null "$ledger"` instead of `touch "$ledger"`.
  This ensures `0600` regardless of umask. This is a general improvement that
  applies to the existing code, not specifically to the agent metadata addition.

**Verdict**: No new information leakage concern from adding `agent_type` to the
ledger. The optional `0600` hardening is a nice-to-have, not a blocker.

#### 3. Allowlist Validation vs Pass-Through -- RECOMMENDED but not required

**Should `agent_type` be validated against the known agent roster?**

This depends on what the value is used for:

- **For commit message decoration** (e.g., `feat(frontend-minion): add header`):
  Allowlist validation is NOT required. The regex validation in Recommendation 1
  is sufficient. An unknown agent name in a commit message is harmless -- it is
  informational metadata, not a security boundary. Hardcoding a roster would
  create maintenance burden every time an agent is added or renamed.

- **For access control decisions** (e.g., "only security-minion can edit
  sensitive-patterns.txt"): Allowlist validation WOULD be required. But the
  current design does not use `agent_type` for access control, and I would
  advise against doing so. The `agent_type` field is self-reported by the
  Claude Code runtime and is not cryptographically authenticated. It should
  never be treated as a trusted identity for authorization purposes.

- **For ledger integrity**: The `agent_type` is supplementary metadata on the
  ledger line. Even if it were spoofed, the security properties of the commit
  workflow (staging discipline, sensitive file filtering, branch protection)
  are unaffected because those checks operate on file paths, not agent identity.

**Recommendation**: Use regex validation (Recommendation 1) to ensure safe
characters. Do NOT hardcode an allowlist. Do NOT use `agent_type` for any
authorization decision.

#### 4. Ledger Format Change -- Needs careful design

Adding `agent_type` to the ledger changes its format from one-path-per-line to
a structured format. This introduces a parsing concern:

- **Current format**: `/absolute/path/to/file.ts` (one per line, grep with `-Fx`)
- **Proposed format options**:
  - Tab-separated: `/absolute/path/to/file.ts\tagent_type` -- simple but
    file paths could theoretically contain tabs
  - JSON lines: `{"path":"/absolute/path/to/file.ts","agent_type":"frontend-minion"}`
    -- unambiguous but heavier
  - Separate metadata file: Keep the ledger as-is, write a parallel
    `/tmp/claude-change-meta-<session_id>.json` -- cleanest separation of concerns

**Security recommendation**: If tab-separated, validate that neither `file_path`
nor `agent_type` contains tab characters (both should already be rejected by
existing validations). If JSON lines, use `jq` for both writing and reading to
prevent injection. The separate metadata file approach is safest because it
preserves the existing ledger's security properties (already reviewed and
documented in `commit-workflow-security.md`) without modification.

#### 5. Commit Message Construction Safety

When `agent_type` flows into commit messages (the primary use case), ensure:

1. The value is never interpolated into a shell command without quoting.
2. The value is used as a conventional commit scope, which has a well-defined
   grammar: `type(scope): summary`. The scope should be sanitized to match
   `[a-zA-Z0-9_-]` before insertion.
3. Document in `commit-workflow-security.md` that `agent_type` is untrusted
   input and must be sanitized before use in commit messages, even though it
   originates from Claude Code.

### Proposed Tasks

1. **Add `agent_type`/`agent_id` extraction with regex validation** in
   `track-file-changes.sh`. Extract from JSON, validate with
   `^[a-zA-Z0-9_-]{1,64}$`, fall back to empty string on invalid input.
   Estimated: small change, low risk.

2. **Choose and implement ledger format extension**. Recommend the separate
   metadata file approach (`/tmp/claude-change-meta-<session_id>.json`) to
   avoid changing the existing ledger format. If tab-separated is chosen
   instead, update the `grep -qFx` deduplication logic in `track-file-changes.sh`
   and the ledger reader in `commit-point-check.sh`.

3. **Update `commit-workflow-security.md`** to document: (a) `agent_type` is
   untrusted input requiring sanitization, (b) it must never be used for
   authorization, (c) the regex validation pattern used, (d) the chosen
   ledger format and its parsing safety properties.

4. **Optional hardening: ledger file permissions**. Change `touch "$ledger"` to
   `install -m 0600 /dev/null "$ledger"` (or `umask 077` in the hook). This
   applies to the existing ledger creation, not just the new metadata.

### Risks and Concerns

| Risk | Severity | Mitigation |
|------|----------|------------|
| Shell injection via `agent_type` in commit messages | Medium | Regex validation `^[a-zA-Z0-9_-]{1,64}$`; always quote variables |
| Git trailer injection via newlines in `agent_type` | Medium | Same regex rejects newlines; explicit newline check as defense-in-depth |
| Ledger format change breaks existing `grep -Fx` dedup | Medium | Use separate metadata file to avoid changing ledger format |
| `agent_type` used for authorization in future | High (future) | Document explicitly that `agent_type` is informational only, never for authz |
| `/tmp/` file permissions expose agent metadata | Low | `install -m 0600` for all ledger/metadata files |
| Maintenance burden from hardcoded agent roster allowlist | Low | Do NOT implement an allowlist; regex validation is sufficient |

### Additional Agents Needed

None beyond what is already planned. The security considerations here are
straightforward and can be addressed by whoever implements the hook changes
(likely devx-minion). The key deliverables are:

1. The regex validation pattern (provided above, ready to copy).
2. The decision on ledger format (architectural, not security -- but I have
   stated my preference for separate metadata file).
3. The `commit-workflow-security.md` update (can be done by the implementing
   agent with guidance from this review).
