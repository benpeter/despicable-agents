# Security Review: Decouple Self-Referential Assumptions

## Verdict

**BLOCK**

## Blocking Issues

### 1. Scratch Files in $TMPDIR (HIGH severity)

**Symlink attacks (CWE-61)**
- Creating `$TMPDIR/nefario-scratch/${CLAUDE_SESSION_ID}/{slug}/` with `mkdir -p` is vulnerable to symlink race conditions
- An attacker could pre-create a symlink at that path pointing to sensitive directories (`~/.ssh`, `/etc`, project source)
- Mitigation REQUIRED: Use `mktemp -d` for atomic secure directory creation

**World-readable temp files (CWE-732)**
- On multi-user systems, `/tmp` is typically world-readable (mode 1777)
- Scratch files contain: prompts with potential credentials, architectural details, PII from requirements, API responses
- Other users on the system can enumerate and read these files
- Session ID predictability makes this worse (see below)
- Mitigation REQUIRED: `chmod 700` on scratch directory, umask 077 for all file creation

**Session ID predictability**
- `CLAUDE_SESSION_ID` origin and entropy not specified
- Fallback `$(date +%s)-$$` uses epoch timestamp and process ID -- both easily enumerate-able
- Enables other users to discover and access scratch directories
- Mitigation REQUIRED: Document that `CLAUDE_SESSION_ID` must be cryptographically random. Use `mktemp -u XXXXXXXX` for fallback (8 random chars).

### 2. Arbitrary Write via NEFARIO_REPORTS_DIR (MEDIUM severity)

**Path injection (CWE-22, CWE-73)**
- No validation on `NEFARIO_REPORTS_DIR` environment variable
- An attacker with env var control can write reports to arbitrary filesystem locations:
  - `/etc/cron.d/YYYY-MM-DD-HH-MM-SS-malicious-report.md` (cron job injection if running as root)
  - `~/.ssh/authorized_keys` (SSH backdoor)
  - `~/.bashrc`, `~/.profile` (shell backdoor)
  - `/tmp/../../../etc/motd` (directory traversal)
- Mitigation REQUIRED: Validate `NEFARIO_REPORTS_DIR` with:
  1. Canonicalize path with `realpath`
  2. Verify path is within project working directory OR user explicitly acknowledged
  3. Blocklist sensitive system directories: `/etc`, `/sys`, `/proc`, `/boot`, `~/.ssh`

### 3. Sensitive Data Persistence (MEDIUM severity)

**Indefinite temp file retention**
- Plan states scratch files are "Never auto-deleted by the skill"
- Sensitive data accumulates in world-readable temp space until reboot
- On long-running systems (servers, CI runners), this is indefinite persistence
- Mitigation REQUIRED: Add cleanup phase at wrap-up OR trap handlers for unexpected exit

**Scratch files committed to version control**
- Wrap-up step 5 copies scratch files to report companion directory
- Companion directory is inside the project (cwd-relative)
- Most projects are git repos -- scratch files are likely committed
- Scratch files contain prompts, which may contain API keys, credentials, internal architecture details
- Mitigation REQUIRED: Sanitize scratch before copying to companion dir:
  - Redact or exclude files containing API keys, tokens (grep for common patterns)
  - Warn user before committing scratch files
  - Consider making companion dir creation opt-in rather than default

## Non-Blocking Advisories

### 4. Git Operations Trust (LOW severity)

**Unvalidated repository operations**
- Plan adds "check if git repo" but doesn't validate:
  - That the git repo is trusted
  - That the user intended to commit to THIS repo (cwd-based operation may surprise users)
  - That the remote isn't malicious
- Recommendation: Before branch creation/commits, verify:
  - Repo has no remotes, OR
  - Remote is explicitly allow-listed, OR
  - User confirms the operation

**Credential exposure**
- Git operations may trigger credential helpers
- In shared environments (CI/CD, dev servers), credentials could be exposed to processes with ptrace access
- Recommendation: Document the credential exposure surface in security guidance

### 5. Install Script Symlink Safety (LOW severity)

**Symlink redirection**
- install.sh modifications don't show validation that `~/.claude/agents/` and `~/.claude/skills/` aren't malicious symlinks
- An attacker pre-creating these as symlinks could redirect agent installations to sensitive locations
- Recommendation: Verify target directories aren't symlinks before writing, OR use `ln -sf` with absolute paths only

## Required Changes for BLOCK Resolution

The following changes are MANDATORY before proceeding to execution:

1. **Secure temp directory creation**
   - Replace `mkdir -p $TMPDIR/nefario-scratch/...` with `mktemp -d -t nefario-scratch-${CLAUDE_SESSION_ID}-${slug}.XXXXXX`
   - Apply `chmod 700` immediately after creation
   - Set umask 077 before creating any scratch files

2. **NEFARIO_REPORTS_DIR validation**
   - Canonicalize with `realpath`
   - Verify path is within project directory
   - Blocklist: `/etc`, `/sys`, `/proc`, `/boot`, `~/.ssh`, `/var`, `/usr`
   - If validation fails, abort with error message

3. **Scratch sanitization before commit**
   - Before copying scratch to companion dir (wrap-up step 5):
     - Scan scratch files for API key patterns (regex: `[A-Za-z0-9_-]{20,}`, `sk-[a-zA-Z0-9]{48}`, etc.)
     - If matches found, warn user and request confirmation
     - Provide option to exclude prompt files from companion dir

4. **Temp cleanup**
   - Add cleanup phase at wrap-up that removes scratch directory
   - Document that interrupted orchestrations leave scratch files in temp (cleaned on reboot)

## Implementation Guidance

### Secure Temp Directory Pattern

```bash
# WRONG (current plan)
mkdir -p "$TMPDIR/nefario-scratch/${CLAUDE_SESSION_ID}/${slug}"

# RIGHT
SCRATCH_DIR=$(mktemp -d -t "nefario-scratch-${CLAUDE_SESSION_ID}-${slug}.XXXXXX")
chmod 700 "$SCRATCH_DIR"
umask 077  # All subsequent file creation is user-only
```

### NEFARIO_REPORTS_DIR Validation Pattern

```bash
if [ -n "$NEFARIO_REPORTS_DIR" ]; then
  # Canonicalize
  REPORTS_DIR=$(realpath "$NEFARIO_REPORTS_DIR" 2>/dev/null || echo "INVALID")

  # Validate not in blocklist
  case "$REPORTS_DIR" in
    /etc/*|/sys/*|/proc/*|/boot/*|$HOME/.ssh/*|/var/*|/usr/*)
      echo "ERROR: NEFARIO_REPORTS_DIR cannot point to system directory: $REPORTS_DIR"
      exit 1
      ;;
    INVALID)
      echo "ERROR: NEFARIO_REPORTS_DIR is not a valid path: $NEFARIO_REPORTS_DIR"
      exit 1
      ;;
  esac

  # Verify within project (if cwd is known)
  PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  case "$REPORTS_DIR" in
    $PROJECT_ROOT/*)
      # OK
      ;;
    *)
      echo "WARNING: NEFARIO_REPORTS_DIR is outside project directory. Continue? (y/N)"
      read -r CONFIRM
      [ "$CONFIRM" = "y" ] || exit 1
      ;;
  esac
fi
```

### Scratch Sanitization Pattern

```bash
# Before copying scratch to companion dir
if grep -rE '(sk-[a-zA-Z0-9]{48}|[A-Za-z0-9_-]{32,}|-----BEGIN.*PRIVATE KEY)' "$SCRATCH_DIR" >/dev/null 2>&1; then
  echo "WARNING: Scratch files may contain API keys or credentials."
  echo "These will be copied to the report companion directory (likely tracked in git)."
  echo "Continue? (y/N)"
  read -r CONFIRM
  [ "$CONFIRM" = "y" ] || {
    echo "Skipping companion directory creation. Scratch files remain in temp: $SCRATCH_DIR"
    exit 0
  }
fi
```

## Risk Summary

| Risk | Severity | Likelihood | Impact | Mitigation Status |
|------|----------|-----------|--------|-------------------|
| Symlink attack on scratch dir | HIGH | Medium | Arbitrary file write/read | REQUIRED |
| World-readable sensitive data | HIGH | High | Credential theft, PII exposure | REQUIRED |
| Arbitrary write via env var | MEDIUM | Low | System compromise, backdoor | REQUIRED |
| Scratch in version control | MEDIUM | High | Credential leak in git history | REQUIRED |
| Indefinite temp persistence | MEDIUM | Medium | Data accumulation, audit failure | REQUIRED |
| Git repo trust | LOW | Low | Unintended commits to wrong repo | ADVISORY |
| Install symlink redirect | LOW | Low | Agent file overwrite | ADVISORY |

## Conclusion

The portability and zero-config design goals are sound, but the current implementation prioritizes convenience over security in critical areas. Multi-user systems, CI/CD environments, and projects handling credentials or PII face significant risks.

All four REQUIRED mitigations must be implemented before execution. These are not optional hardening measures -- they address vulnerabilities that are HIGH or MEDIUM severity and HIGH likelihood in common deployment scenarios.

After mitigations, the design is acceptable with documentation of remaining risks (advisory items).
