# Domain Plan Contribution: iac-minion

## Recommendations

### (a) Bash 3.2 Compatibility -- Stock macOS Is Broken Today

**`commit-point-check.sh` requires bash 4+ and will fail on stock macOS `/bin/bash` (3.2.57).**

The following bash 4+ features are used in `commit-point-check.sh`:

| Feature | Lines | Bash version required | Impact |
|---------|-------|-----------------------|--------|
| `local -A seen_paths` (associative array) | 170 | 4.0+ | **Fatal**: syntax error, script crashes |
| `local -a ledger_files=()` (array init in local) | 163-165 | 4.0+ (3.2 allows `local -a x` but not `local -a x=()`) | **Fatal**: syntax error |
| `${seen_paths[$filepath]+x}` (associative array subscript) | 173 | 4.0+ | **Fatal** |
| `seen_paths[$filepath]=1` (associative array assignment) | 174 | 4.0+ | **Fatal** |

`install.sh` and `track-file-changes.sh` are clean -- they use only bash 3.2-compatible constructs.

**However**, this may not matter in practice: Claude Code bundles its own shell environment and likely invokes hooks with a modern bash (the user's current macOS has bash 5.3.9 installed via Homebrew). The question is whether Claude Code uses `/bin/bash` or the first `bash` on `$PATH` when resolving `#!/usr/bin/env bash`. On macOS with Homebrew, `env bash` typically resolves to the Homebrew bash 5.x. On a fresh macOS without Homebrew, it would hit `/bin/bash` 3.2 and crash.

**Recommendation**: Fix the bash 4+ dependency regardless. The fix is small and eliminates a class of platform bugs. POSIX-compatible alternatives exist for every construct used (see section e below).

### (b) Windows Story -- Target Git Bash (MSYS2), Not PowerShell

Windows has three possible bash environments:

| Environment | Availability | Symlink support | `/tmp/` | `jq` availability | `mktemp` | `chmod` |
|-------------|-------------|----------------|---------|-------------------|----------|---------|
| **Git Bash (MSYS2)** | Ships with Git for Windows (near-universal for devs) | No real symlinks; `ln -s` creates copies | Mapped to `$TMPDIR` or `C:\Users\...\AppData\Local\Temp` | Must install separately | Available | No-op on NTFS (silently succeeds) |
| **WSL** | Optional install, requires admin | Full POSIX symlinks (within WSL filesystem) | Standard `/tmp/` | `apt install jq` | Available | Works |
| **PowerShell** | Built-in | `New-Item -ItemType SymbolicLink` (requires admin or dev mode) | No `/tmp/` | Must install separately | N/A | N/A |

**Recommendation**: Target **Git Bash** as the primary Windows environment. Rationale:
- Claude Code itself likely requires Git, so Git Bash is available by definition.
- WSL is a heavier dependency (requires Hyper-V/WSL2 install, separate filesystem).
- PowerShell would require rewriting all scripts and is fundamentally a different shell.

**Key Git Bash limitations that affect us**:
1. **Symlinks are fake**: `ln -s` in Git Bash creates a file copy, not a symlink. Updates to the source file are NOT reflected at the target. This breaks the entire `install.sh` paradigm (the docs say "edits are immediately live").
2. **`chmod` is a no-op**: `chmod 700` succeeds silently but does nothing meaningful on NTFS. This weakens the scratch directory security model.
3. **`/tmp/` path mapping**: Git Bash maps `/tmp` to a Windows temp directory, but the path differs from what a native Windows process would see. If Claude Code invokes hooks through a non-MSYS process, `/tmp/` paths in the ledger may not resolve.
4. **`jq` not bundled**: Git for Windows does not include `jq`. Both hooks require it.

### (c) `$TMPDIR` Consistency -- Mixed Usage Today

**Current state**:
- `SKILL.md` scratch directory: Uses `${TMPDIR:-/tmp}` -- **correct**.
- `SKILL.md` status files: Hardcodes `/tmp/nefario-status-$SID` -- **inconsistent**.
- `SKILL.md` session-id: Hardcodes `/tmp/claude-session-id` -- **inconsistent**.
- `SKILL.md` PR body temp: Hardcodes `/tmp/pr-body-$$` -- **inconsistent**.
- `track-file-changes.sh`: Hardcodes `/tmp/claude-change-ledger-...` -- **inconsistent**.
- `commit-point-check.sh`: Hardcodes `/tmp/claude-change-ledger-...`, `/tmp/claude-commit-defer-...`, `/tmp/claude-commit-declined-...`, and checks `/tmp/nefario-status-...` -- **inconsistent**.

**Recommendation**: Standardize all temp file references to `${TMPDIR:-/tmp}`. This is the single most impactful cross-platform fix:
- On macOS, `$TMPDIR` points to `/var/folders/xx/.../T/` (per-user, already set by the OS).
- On Linux, `$TMPDIR` is typically unset, so `/tmp` is the fallback (correct).
- On Git Bash/Windows, `$TMPDIR` resolves to the Windows temp directory, which is accessible from both MSYS and native processes.

**Critical coupling**: The hooks and SKILL.md must agree on the temp file location. If `track-file-changes.sh` writes to `/tmp/claude-change-ledger-X` but `commit-point-check.sh` looks at `${TMPDIR:-/tmp}/claude-change-ledger-X`, they will diverge on macOS where `TMPDIR` is not `/tmp`. Today this works by accident because both hardcode `/tmp/` -- but the scratch directory uses `$TMPDIR` and already lives in a different directory on macOS. Standardize all to `${TMPDIR:-/tmp}` for consistency.

### (d) Symlinks on Windows -- The Core Deployment Problem

This is the **hardest cross-platform issue**. Options:

| Strategy | Pros | Cons |
|----------|------|------|
| **Junction points** (`mklink /J`) | Works without admin; directory-level only; real filesystem link | Git Bash can't create them natively; requires `cmd /c mklink /J`; files only work with hardlinks |
| **`mklink /D`** (directory symlink) | True symlink | Requires admin privileges or Developer Mode enabled |
| **Copy-based deployment** | Works everywhere; no privilege requirements | Edits are NOT live; must re-run install after every change |
| **Git worktree/submodule** | Avoids symlinks entirely | Completely different architecture; complex |

**Recommendation**: Implement a **copy-based fallback** for Windows in `install.sh`. Detect the platform, and if symlinks are not supported (or fail), fall back to copying files. Add a warning that changes require re-running `./install.sh`.

```sh
# Platform detection
create_link() {
    local source="$1" target="$2"
    if ln -sf "$source" "$target" 2>/dev/null; then
        return 0
    fi
    # Fallback: copy
    cp -r "$source" "$target"
    USED_COPY_FALLBACK=true
}
```

At the end, if `USED_COPY_FALLBACK` is set, print a warning:
> "Symlinks not available. Files were copied. Re-run install.sh after changes."

### (e) POSIX Alternatives for Bash-Specific Features

**Associative array (`local -A seen_paths`) in `commit-point-check.sh`**:
Replace with a temporary file-based dedup (the ledger is already a file):
```sh
# Instead of associative array dedup, use sort -u on the ledger
ledger_files=$(sort -u "$ledger")
```
Or use `awk '!seen[$0]++'` for streaming dedup preserving order.

**Array variables (`local -a`)**: Replace with newline-delimited strings and iterate with `while read`. This is standard POSIX sh. The loop logic at lines 184-217 can be restructured to process files one-at-a-time without accumulating arrays, writing filtered results to temp files.

**`[[ ... ]]` conditionals**: These are bash-specific but available in bash 3.2. If targeting pure POSIX sh (`#!/bin/sh`), replace with `[ ... ]` and `case` statements. However, since all scripts use `#!/usr/bin/env bash`, `[[ ]]` is fine as long as we stay on bash (any version).

**`echo -e` in `install.sh`**: Non-portable (some systems' `echo` ignores `-e`). Replace with `printf` for guaranteed escape sequence handling. This is a minor issue but a free fix.

**`${BASH_SOURCE[0]}`**: Bash-specific, not available in POSIX sh. If we ever target `/bin/sh`, replace with `$0` (works for directly-executed scripts, not sourced ones). For current use case (direct execution), this is fine.

**`readlink` in `install.sh`**: macOS `readlink` does not support `-f` (canonicalize). The current code uses bare `readlink` (without `-f`), which works cross-platform for reading one level of symlink. The `the-plan.md` deployment section uses `realpath`, which IS available on recent macOS but NOT on older macOS or minimal Linux (e.g., Alpine without coreutils). The `install.sh` avoids `realpath` and uses `cd ... && pwd` instead -- this is the correct portable pattern.

### External Tool Dependencies

Complete inventory of external tools required by the shell scripts and hooks:

| Tool | Used by | Availability | Windows (Git Bash) | Notes |
|------|---------|-------------|-------------------|-------|
| `bash` | All scripts | macOS (3.2 stock, 5.x Homebrew), Linux | Git Bash bundles bash 5.x | Stock macOS 3.2 breaks commit hook |
| `jq` | Both hooks | Not pre-installed anywhere | Not in Git Bash | **Must be explicitly installed** |
| `git` | commit-point-check.sh | Universal for devs | Git Bash bundles it | Core dependency |
| `gh` | SKILL.md PR workflows | Optional (GitHub CLI) | Available via installer | Only needed for PR creation |
| `grep` | track-file-changes.sh | POSIX standard | Git Bash bundles it | Using `-qFx` (POSIX flags) |
| `awk` | commit-point-check.sh | POSIX standard | Git Bash bundles it | Simple usage, portable |
| `mktemp` | SKILL.md scratch dir | macOS/Linux standard | Git Bash bundles it | `-d` flag is POSIX |
| `sort` | (proposed dedup) | POSIX standard | Git Bash bundles it | |
| `basename`/`dirname` | All scripts | POSIX standard | Git Bash bundles it | |
| `readlink` | install.sh (uninstall) | macOS/Linux | Git Bash bundles it | Without `-f`, portable |
| `realpath` | the-plan.md examples | macOS 13+, most Linux | Not in Git Bash by default | **Avoid in scripts; use `cd && pwd`** |
| `chmod` | SKILL.md scratch dir | POSIX standard | **No-op on Windows** | Security model weakened |
| `touch` | hooks (ledger, markers) | POSIX standard | Git Bash bundles it | |
| `printf` | (proposed echo -e replacement) | POSIX standard | Git Bash bundles it | |

## Proposed Tasks

### Task 1: Fix bash 4+ dependencies in commit-point-check.sh
**What**: Rewrite `commit-point-check.sh` to avoid associative arrays and bash 4+ array initialization. Replace `local -A seen_paths` with file-based dedup (pipe ledger through `awk '!seen[$0]++'`). Replace `local -a var=()` with `local var=""` and newline-delimited processing.
**Deliverables**: Updated `commit-point-check.sh` that passes `shellcheck` and works on bash 3.2.
**Dependencies**: None. Can be done independently.

### Task 2: Standardize temp file paths to use `${TMPDIR:-/tmp}`
**What**: Replace all hardcoded `/tmp/` references with `${TMPDIR:-/tmp}` in:
- `.claude/hooks/track-file-changes.sh` (ledger path)
- `.claude/hooks/commit-point-check.sh` (ledger, defer marker, declined marker, nefario status check)
- `skills/nefario/SKILL.md` (status files, session-id, PR body temp)
- `docs/commit-workflow.md` (example snippets)

Define a single `TEMP_BASE="${TMPDIR:-/tmp}"` variable at the top of each script and reference it throughout.
**Deliverables**: Updated scripts and SKILL.md. Grep for bare `/tmp/` to verify none remain.
**Dependencies**: None. Can be done independently, but test that hooks still interoperate (they share file paths).

### Task 3: Add copy-based fallback to install.sh for Windows
**What**: Add platform detection to `install.sh`. If `ln -sf` fails (or if running on Windows/MSYS), fall back to file/directory copying. Print a clear warning about the copy-based limitation.
Also fix `echo -e` to use `printf` for portability.
**Deliverables**: Updated `install.sh` with `create_link()` helper, platform detection, and copy fallback.
**Dependencies**: None.

### Task 4: Document platform compatibility and prerequisites
**What**: Create a `docs/platform-support.md` document covering:
- Platform support matrix (macOS: full, Linux: full, Windows: partial with caveats)
- Required CLI tools with installation instructions (or "ask Claude Code to install them")
- Known Windows limitations (symlinks become copies, chmod no-op, jq manual install)
- Disclaimer for README about current macOS-primary development

Also add a short disclaimer section to the project README.
**Deliverables**: `docs/platform-support.md`, updated README section.
**Dependencies**: Tasks 1-3 inform what the documentation says (do those first or in parallel and update docs at the end).

### Task 5: Add `shellcheck` CI validation
**What**: Add a simple CI check (GitHub Actions or local script) that runs `shellcheck` against all `.sh` files. This prevents future regressions toward bash 4+ features or non-portable constructs.
**Deliverables**: `.github/workflows/shellcheck.yml` or a `check.sh` script. Configure shellcheck to enforce bash 3.2 compatibility (`# shellcheck shell=bash` with appropriate directive for minimum version).
**Dependencies**: Task 1 must be complete first (current code would fail shellcheck for some issues).

## Risks and Concerns

### Risk 1: Hook path coordination (HIGH)
The temp file paths in hooks and SKILL.md are tightly coupled. If `track-file-changes.sh` writes the ledger to one path and `commit-point-check.sh` reads from a different path (due to inconsistent `$TMPDIR` usage), the commit checkpoint silently stops working. The fix (Task 2) must update ALL references atomically. A missed reference means a silent failure with no error message.

### Risk 2: Windows symlink story is fundamentally limited (MEDIUM)
Even with a copy fallback, the Windows developer experience is degraded: edits to `AGENT.md` files are not live until `install.sh` is re-run. This is a significant workflow difference. For Windows users who use WSL, the full Unix experience is available, but documenting both paths (Git Bash with caveats vs WSL with full support) adds complexity.

### Risk 3: `jq` as undocumented hard dependency (HIGH)
Both hooks silently malfunction if `jq` is not installed. On `track-file-changes.sh`, the `|| echo ""` fallback means file paths are never extracted, so the ledger stays empty and commit checkpoints never fire. This is a silent failure. On `commit-point-check.sh`, the session ID extraction fails, pointing at a nonexistent ledger. Neither hook checks for `jq` availability or produces a helpful error.

**Mitigation**: Add a `jq` presence check at the top of each hook (or a shared preamble). If `jq` is missing, either skip gracefully with a one-time warning or fail with a clear install instruction.

### Risk 4: `chmod 700` security model breaks on Windows (LOW)
The scratch directory security relies on Unix file permissions. On Windows (Git Bash), `chmod` is a no-op -- the scratch directory is readable by any process running as the same Windows user. This is acceptable for a development tool but should be documented.

### Risk 5: Claude Code's own shell invocation is opaque (MEDIUM)
We do not fully control how Claude Code invokes hook commands. The `$CLAUDE_PROJECT_DIR` variable in `settings.json` suggests Claude Code performs its own variable expansion. If Claude Code invokes hooks via a non-bash shell on some platforms, the `#!/usr/bin/env bash` shebang might not be honored (e.g., if invoked as `sh script.sh` instead of `./script.sh`). This is speculative but worth noting -- testing on each platform is required.

### Risk 6: `realpath` in `the-plan.md` deployment examples (LOW)
The `the-plan.md` deployment section uses `realpath` which is not available on all platforms. The `install.sh` script correctly avoids it, but users following the manual deployment docs could hit failures. The manual deployment examples should use `cd ... && pwd` instead.

## Additional Agents Needed

- **devx-minion**: Already involved (confirmed in scratch directory). Essential for evaluating Claude Code's hook invocation behavior across platforms and the developer experience implications of copy-based deployment on Windows.

- **software-docs-minion**: Already involved. Needed for drafting the platform support documentation, README disclaimer, and CLI prerequisites section.

- **security-minion**: Already involved. Should validate that the weakened security model on Windows (no-op `chmod`, copy-based deployment) does not introduce risks beyond acceptable thresholds for a development tool.

- **test-minion** (recommended addition): Should be consulted on how to validate cross-platform behavior. Specifically: can we add a CI matrix that tests `install.sh` and the hooks on macOS, Ubuntu, and Windows (Git Bash) runners? GitHub Actions provides all three. Even a smoke test (`bash -n script.sh` for syntax validation + `shellcheck`) on each platform would catch regressions.

No other specialists needed beyond those already included plus test-minion.
