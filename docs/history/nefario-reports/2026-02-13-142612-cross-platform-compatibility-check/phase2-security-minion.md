## Domain Plan Contribution: security-minion

### Recommendations

#### (a) Security implications of `$TMPDIR` on Windows

On macOS and Linux, `/tmp` is a shared directory but the kernel enforces per-user file permissions via the sticky bit and POSIX ACLs. On Windows, the situation is materially different:

1. **`$TMPDIR` resolves to per-user temp on Windows.** On Git Bash / MSYS2 / WSL, `$TMPDIR` typically maps to `C:\Users\<user>\AppData\Local\Temp` (or the WSL `/tmp`). This is actually **more secure by default** than the shared `/tmp` on Unix -- the user's temp directory is ACL'd to their own SID. Other non-admin users cannot enumerate or access files there.

2. **However, the security model inversion is the problem.** On Unix, the explicit `chmod 700` on the `mktemp -d` result is the defense against other local users. On Windows (native, not WSL), `chmod` is a no-op or has very limited effect -- NTFS uses ACLs, not POSIX permission bits. The **effective** security depends entirely on the inherited ACLs of the parent temp directory, not on anything the scripts do. This means:
   - If a user customizes `TEMP`/`TMP` to point at a shared location (e.g., a network drive, `C:\Temp`), the `chmod 700` call silently does nothing, and the scratch directory is world-readable.
   - Enterprise environments sometimes redirect temp to network shares for roaming profiles -- this is a real-world scenario, not theoretical.

3. **Recommendation: Accept `$TMPDIR` on Windows as the primary path** (it defaults to per-user temp and is the safest general-purpose choice), but add validation that the resolved temp dir is user-owned and not world-accessible. On native Windows via Git Bash, use `icacls` to verify or set ACLs. On WSL, POSIX semantics apply normally.

#### (b) What replaces `chmod 600`/`chmod 700` on Windows/NTFS

Two distinct scenarios:

**WSL (Windows Subsystem for Linux):** Full POSIX permission semantics work as expected. `chmod 700` works correctly. `mktemp -d` works. No changes needed. This is the lowest-friction path for Windows users.

**Git Bash / MSYS2 (native Windows):** `chmod` calls are mapped through the MSYS POSIX-to-Win32 translation layer. Behavior is partial and unreliable:
- `chmod 700` may set the read-only attribute but does NOT modify NTFS ACLs
- The file is still accessible to any process running as the same user (which is fine) but potentially to administrators or other users with `SeBackupPrivilege`
- There is no reliable POSIX permission enforcement

**Replacement strategy for native Windows (Git Bash):**

| Current Unix control | Windows equivalent |
|---|---|
| `chmod 700 dir` | `icacls "$dir" /inheritance:r /grant:r "$USERNAME:(OI)(CI)F"` -- removes inherited ACLs, grants full control only to the current user |
| `chmod 600 file` | `icacls "$file" /inheritance:r /grant:r "$USERNAME:F"` -- same pattern |
| `mktemp -d` | Git Bash bundles a `mktemp` that works. PowerShell requires `[System.IO.Path]::GetTempFileName()` pattern |

**Recommendation:** Create a platform abstraction function:

```bash
secure_tmpdir() {
    local dir
    dir=$(mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX")
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "mingw"* ]]; then
        # Native Windows via Git Bash -- use icacls
        icacls "$(cygpath -w "$dir")" /inheritance:r /grant:r "$USERNAME:(OI)(CI)F" >nul 2>&1
    else
        chmod 700 "$dir"
    fi
    echo "$dir"
}
```

A similar wrapper is needed for `chmod 600` on status files.

#### (c) Fail-closed design and `grep` behavior differences

The `sensitive-patterns.txt` fail-closed design is in `commit-point-check.sh` lines 147-155. There are two separate concerns:

**The fail-closed gate itself is safe across platforms.** It uses `[[ ! -r "$SENSITIVE_PATTERNS_FILE" ]]` -- a bash built-in test, not `grep`. If the patterns file is unreadable, no files are staged. This works identically in bash on all platforms. **No issue here.**

**The `grep` usage in `track-file-changes.sh` line 63** (`grep -qFx`) is the area to scrutinize:

1. **Line ending differences.** On Windows, `grep` in Git Bash handles both LF and CRLF, but `grep -Fx` (fixed-string, exact full-line match) may fail if the ledger file contains CRLF line endings and the comparison string does not (or vice versa). If the ledger accumulates CRLF entries but the new path has LF, deduplication silently fails and the ledger grows with duplicates. This is **not a security vulnerability** -- it's a functionality issue that could cause duplicate staging prompts, but the sensitive file filter still catches everything.

2. **The sensitive file matching in `commit-point-check.sh` lines 72-89** uses bash glob matching (`[[ "$basename" == $pattern ]]`), NOT `grep`. Bash glob matching is consistent across platforms. **This is safe.**

3. **GNU grep vs BSD grep vs Git Bash grep.** The only `grep` call is in `track-file-changes.sh` for deduplication. The flags used (`-q`, `-F`, `-x`) are POSIX-standard and behave identically across implementations. **No behavioral difference concern.**

**Verdict: The fail-closed design remains safe across platforms.** The only risk is CRLF-induced deduplication failure in the ledger, which is a cosmetic issue, not a security issue. Recommend normalizing line endings in the ledger write path as a defensive measure:

```bash
# In track-file-changes.sh, ensure LF-only writes
echo "$file_path" | tr -d '\r' >> "$ledger" 2>/dev/null || true
```

#### (d) Symlink-to-junction migration on Windows

This is the highest-risk area of the four questions. The current system uses symlinks in two contexts:

1. **`install.sh` deployment symlinks** -- `ln -sf` to create `~/.claude/agents/foo.md -> /path/to/repo/foo/AGENT.md` and `~/.claude/skills/nefario -> /path/to/repo/skills/nefario/`
2. **Claude Code project config** -- `.claude/settings.json` references `$CLAUDE_PROJECT_DIR` which resolves through symlinks

**Windows symlink security concerns:**

| Concern | Detail | Severity |
|---|---|---|
| **Privilege requirement** | Creating symlinks on Windows requires `SeCreateSymbolicLinkPrivilege`, which is not granted to standard users by default. Developer Mode enables it, but enterprise group policies often block Developer Mode. | HIGH (adoption barrier) |
| **Junction semantics differ from symlinks** | Junctions are directory-only, resolve at the filesystem level (not the application level), and do NOT work for files. `install.sh` symlinks individual `.md` files -- junctions cannot replace these. | CRITICAL (functional breakage) |
| **Junction traversal attacks** | Junctions on Windows can be created by unprivileged users (unlike symlinks) and resolve transparently. A malicious local process could replace a junction target to redirect agent loading to an attacker-controlled path. This is the Windows equivalent of symlink attacks in `/tmp`. | HIGH (local privilege escalation vector) |
| **NTFS reparse points and security software** | Some antivirus/EDR solutions flag junction/symlink creation as suspicious behavior. This could cause installation failures in enterprise environments. | MEDIUM |

**Recommendation: Do NOT use junctions as a symlink replacement.** Instead:

1. **For file symlinks (`agents/*.md`):** Use file copy with a sync/update mechanism. Symlinks to individual files cannot be replaced by junctions (junctions are directory-only). The alternative is `mklink` which requires elevated permissions, or file copy with a version-check wrapper.

2. **For directory symlinks (`skills/nefario`):** Junctions work here but introduce the junction traversal risk above. Prefer `mklink /D` (directory symlink) with Developer Mode, or copy-on-install with a freshness check.

3. **For WSL users:** Symlinks work natively. No migration needed.

4. **Validate symlink/junction targets at load time.** Before reading an agent file through a symlink, verify the target path is within the expected repository directory. This prevents junction hijacking:

```bash
validate_symlink_target() {
    local link="$1"
    local expected_prefix="$2"
    local target
    target=$(readlink -f "$link" 2>/dev/null)
    if [[ "$target" != "$expected_prefix"* ]]; then
        echo "ERROR: Symlink target outside expected directory: $target" >&2
        return 1
    fi
}
```

The `install.sh` uninstall function already does target validation (lines 117-122), which is good practice. Extend this to the install path as well.

### Proposed Tasks

**Task 1: Create platform-aware secure temp directory abstraction**
- What: Write a shared shell function library (e.g., `.claude/hooks/lib/platform.sh`) providing `secure_tmpdir()`, `secure_chmod_600()`, and `secure_chmod_700()` that use NTFS ACLs on native Windows and POSIX permissions elsewhere.
- Deliverables: `platform.sh` library, updated `SKILL.md` scratch directory section, updated hook scripts to source the library.
- Dependencies: Decision on which Windows environments to support (WSL-only vs. also Git Bash).

**Task 2: Harden ledger file writes against CRLF injection**
- What: Add `tr -d '\r'` to ledger write path in `track-file-changes.sh`. Add a line-ending normalization step when reading the ledger in `commit-point-check.sh`.
- Deliverables: Updated hook scripts.
- Dependencies: None.

**Task 3: Design Windows deployment strategy for install.sh**
- What: Decide between (a) WSL-only support with native symlinks, (b) Git Bash support with file copy + sync mechanism, or (c) PowerShell install script for native Windows. Document the decision and security trade-offs of each approach.
- Deliverables: Decision document, updated install.sh or new install.ps1.
- Dependencies: Platform support scope decision.

**Task 4: Document security model differences per platform**
- What: Add a "Platform Security Notes" section to documentation covering: temp directory permissions model, symlink/junction behavior, and any security controls that degrade on specific platforms. This is separate from the general "how to install" docs -- it's the security-specific supplement.
- Deliverables: Documentation section (could be in a platform-support doc or as part of a SECURITY.md).
- Dependencies: Tasks 1 and 3 (to know what the final design is).

**Task 5: Add platform detection to hook scripts**
- What: Add `$OSTYPE` detection at the top of `commit-point-check.sh` and `track-file-changes.sh` to set platform-specific behavior flags. Ensure the scripts exit cleanly (not crash) on unsupported platforms.
- Deliverables: Updated hook scripts with platform detection.
- Dependencies: Task 1 (shared library).

### Risks and Concerns

1. **Silent security degradation on Windows.** The most dangerous outcome is that the scripts appear to work on Windows but `chmod` calls are no-ops, leaving temp files and scratch directories with inherited (potentially permissive) ACLs. Users would have no visible indication that their session state files are less protected than on macOS/Linux. This is a **fail-open** condition -- the opposite of the project's stated design philosophy.

2. **Enterprise Windows environments block symlinks.** Group Policy regularly disables `SeCreateSymbolicLinkPrivilege` even with Developer Mode. An install script that relies on `ln -s` will fail silently or noisily, depending on the Git Bash version. This is an adoption barrier, not a security risk per se, but it could push users toward insecure workarounds (running as admin, disabling security policies).

3. **Session ID in temp file paths.** The current pattern `/tmp/claude-change-ledger-${session_id}.txt` embeds the session ID in a predictable path. On macOS/Linux with `/tmp` sticky bit, this is safe -- other users can see the filename but not read the contents (assuming `chmod 600`). On native Windows without proper ACLs, other local users could read ledger contents (file paths being edited), which leaks information about what the user is working on. Low severity but real.

4. **The `$CLAUDE_PROJECT_DIR` variable in settings.json hook commands.** This is resolved by Claude Code itself. If Claude Code does not properly quote or escape this on Windows paths containing spaces (e.g., `C:\Users\John Doe\projects\...`), the hook command will break. The current quoting (`"$CLAUDE_PROJECT_DIR"`) is correct for bash, but if Claude Code on Windows uses cmd.exe or PowerShell to invoke hooks, the quoting semantics differ entirely. This needs investigation -- it's a Claude Code platform behavior question, not something the project controls.

5. **`grep` and `jq` availability.** The hooks depend on `jq` and `grep`. On macOS, `jq` is not installed by default (requires Homebrew). On Windows Git Bash, `jq` is not bundled. On Linux, it varies by distribution. If `jq` is missing, `json_field` silently returns empty strings, causing the hooks to proceed with default/empty values. The `jq` absence does not create a security hole (the fail-closed pattern catches the important case), but it does cause the hooks to malfunction silently. Recommend adding a dependency check at hook entry.

### Additional Agents Needed

- **devx-minion**: Should own the platform abstraction layer design and the install.sh cross-platform strategy. The security decisions (what ACLs to set, how to validate targets) should come from security-minion, but the implementation ergonomics and developer experience are devx-minion's domain.
- **iac-minion**: If a PowerShell install script (`install.ps1`) is needed for native Windows support, iac-minion should write it. Security-minion should review it.
- **software-docs-minion**: To draft the platform disclaimers and required-tools documentation. Security-minion provides the security-specific content; docs-minion handles structure, tone, and completeness.
