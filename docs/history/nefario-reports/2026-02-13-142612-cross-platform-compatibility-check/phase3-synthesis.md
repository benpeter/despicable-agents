## Advisory Report

**Question**: Is despicable-agents cross-platform safe today, and if not, what would it take to support Windows, macOS, and Linux?
**Confidence**: HIGH
**Recommendation**: The project is NOT cross-platform safe today. It works on macOS (with Homebrew bash) and Linux. Stock macOS has a latent bash 3.2 bug. Windows is unsupported. The right next step is documentation (disclaimers + prerequisites), not code changes. Follow YAGNI -- document the current state honestly, defer script hardening until there is user demand.

### Executive Summary

Four specialists audited the codebase (iac-minion, devx-minion, software-docs-minion, security-minion) and reached strong consensus: despicable-agents is a macOS-and-Linux project today, with a latent bug even on stock macOS. Windows support is blocked by fundamental symlink incompatibilities that no small fix can resolve.

The most impactful immediate action is documentation: add a platform disclaimer to the README, document all CLI tool prerequisites, and provide a "paste into Claude Code" prompt for easy setup. Code changes (bash 3.2 compatibility, `$TMPDIR` standardization, Windows copy-based fallback) should be deferred per the project's own YAGNI philosophy -- they solve problems that no users have reported yet.

The confidence is HIGH because all four specialists independently arrived at the same conclusion: document first, harden later, and do not promise Windows support without an architectural decision on the deployment model (symlinks vs. copies vs. WSL-only).

### Team Consensus

1. **The project does NOT work on Windows today.** `install.sh` depends on POSIX symlinks (`ln -sf`) which are not natively available on Windows without Developer Mode or admin privileges. This is a fundamental architectural constraint, not a bug to fix.

2. **Stock macOS has a latent bug.** `commit-point-check.sh` uses bash 4+ features (associative arrays via `local -A`, array initialization via `local -a x=()`). macOS ships bash 3.2 due to GPLv3 licensing. Users without Homebrew bash will experience silent hook failures -- the hooks trap errors and exit 0, so there is no visible error message.

3. **`jq` is an undocumented hard dependency.** Both hook scripts require `jq` for JSON parsing. It is not pre-installed on any platform, not mentioned in the README, and only briefly noted in `docs/deployment.md`. When missing, hooks fail silently (empty string fallback), causing the commit checkpoint system to silently stop working.

4. **Documentation is the right first step.** All specialists agreed: add platform disclaimers, document prerequisites, provide installation guidance. Code changes can wait.

5. **WSL is the recommended Windows path.** When Windows users need to use this project, WSL provides full POSIX compatibility with zero code changes. Git Bash is a degraded experience (symlinks become copies, `chmod` is a no-op, `jq` must be installed separately).

6. **Temp file paths are inconsistently hardcoded.** SKILL.md scratch directory uses `${TMPDIR:-/tmp}` (correct), but hook scripts and status files hardcode `/tmp/` throughout. This works today because all paths hardcode the same thing, but it is fragile and will break cross-platform.

7. **The project should NOT promise Windows support.** All specialists agreed: frame the current state honestly ("tested on macOS and Linux"), provide WSL as a workaround, and track Windows support as a future GitHub issue. Do not say "coming soon" -- say "contributions welcome."

### Dissenting Views

- **Copy-based fallback urgency**: iac-minion recommends implementing a copy-based fallback in `install.sh` for Windows now (detect platform, fall back to `cp -r` if `ln -sf` fails). devx-minion and software-docs-minion recommend deferring this per YAGNI -- document it and wait for user demand. Resolution: **defer per YAGNI.** The project philosophy explicitly favors "don't build it until you need it." No evidence of Windows users hitting this issue exists yet. Document the limitation and track it.

- **Junction points as symlink alternative**: iac-minion listed junction points as an option for directory-level symlinks on Windows. security-minion explicitly recommends AGAINST junctions due to junction traversal attack risk (unprivileged users can create junctions, enabling local privilege escalation by redirecting agent loading to attacker-controlled paths). Resolution: **do not use junctions.** security-minion's analysis is more thorough on this point and the risk is real.

- **Prerequisites page location**: software-docs-minion recommends a standalone `docs/prerequisites.md`. devx-minion recommends embedding prerequisites directly in the README as a checklist. Resolution: **both are correct for different audiences.** The README should contain a concise checklist (scannable), with a link to a more detailed `docs/prerequisites.md` for per-platform install commands. This is additive, not contradictory.

- **`install.sh check` subcommand**: devx-minion strongly recommends adding `./install.sh check` as a prerequisite verification command. iac-minion and software-docs-minion do not mention it. Resolution: **include in the recommendation but as Tier 2 (script hardening), not Tier 1 (documentation).** It is a good developer experience improvement but not urgent for the advisory scope of "document the current state."

- **Secure temp directory abstraction**: security-minion recommends a `secure_tmpdir()` function with NTFS ACL handling via `icacls` for native Windows. Other specialists accept `$TMPDIR` standardization as sufficient. Resolution: **defer the Windows-specific `icacls` abstraction.** If the project adopts WSL as the recommended Windows path (consensus), the NTFS ACL problem does not arise. The `$TMPDIR` standardization is the right fix for macOS/Linux consistency and can be done independently of Windows support.

### Supporting Evidence

#### Infrastructure (iac-minion)

Complete audit of bash compatibility across all shell scripts:
- `install.sh` and `track-file-changes.sh`: clean, bash 3.2 compatible
- `commit-point-check.sh`: 4 instances of bash 4+ features (associative arrays, array init), all fatal on bash 3.2
- External tool inventory: 12 tools used across scripts, with `jq` and `bash 4+` as the only non-standard dependencies
- Temp path audit: 6+ locations hardcode `/tmp/` instead of using `${TMPDIR:-/tmp}`

The POSIX alternatives for bash 4+ features are straightforward:
- Associative array dedup -> `awk '!seen[$0]++'` or `sort -u` on temp file
- Array initialization -> newline-delimited strings with `while read` loops
- All other constructs (`[[ ]]`, `${BASH_SOURCE[0]}`, `set -euo pipefail`) are bash 3.2 compatible

#### Developer Experience (devx-minion)

Tiered approach to cross-platform stability:
- **Tier 1 (documentation, do now)**: README platform notes, prerequisites checklist, Claude Code setup prompt, WSL guidance for Windows
- **Tier 2 (script hardening, defer)**: bash version guard in hooks, `jq` existence check, `install.sh check` subcommand, Windows platform detection with warnings
- **Tier 3 (true cross-platform, likely YAGNI)**: PowerShell install script, CI matrix testing on all three platforms, junction/mklink support

Key developer experience insight: the "paste into Claude Code" setup prompt is a natural fit for this project. Claude Code detects the platform, knows package managers, and can install missing tools. This sidesteps the entire cross-platform install instruction problem.

#### Documentation (software-docs-minion)

Recommended documentation structure:
- **README.md**: minimal disclaimer (1 blockquote) + prerequisites checklist + link to details
- **docs/deployment.md**: platform support table with specific technical dependencies
- **docs/prerequisites.md** (new): standalone page with per-platform install commands, Claude Code prompt, verification commands
- **GitHub issue**: cross-platform tracking checklist (17 items) with approach options
- Do NOT create a roadmap doc (goes stale) -- the GitHub issue is the living artifact

Two-location disclaimer strategy: README (entry point for new users) and deployment.md (entry point for platform-specific details). No disclaimers needed in other docs -- they are architecture/design docs that are platform-agnostic.

#### Security (security-minion)

Key security findings specific to cross-platform:
- **`chmod` no-op on Windows is a fail-open condition.** The scratch directory security model (`chmod 700`) silently degrades to "inherited ACLs from parent" on NTFS. If the temp directory has permissive inherited ACLs (enterprise network shares, custom TEMP paths), session state files become readable by other users.
- **Junction traversal is a real attack vector.** Do not use NTFS junctions as a symlink replacement -- unprivileged users can create junctions and redirect agent loading to attacker-controlled paths.
- **The fail-closed design in sensitive-patterns.txt is safe cross-platform.** It uses bash built-in tests, not `grep`. The pattern matching uses bash globs, not regex. Both work identically across platforms.
- **CRLF injection in the ledger is cosmetic, not a security issue.** Windows line endings could cause duplicate ledger entries but do not bypass the sensitive file filter.
- **WSL is the safe path for Windows.** Full POSIX semantics, no permission model degradation, no symlink workarounds.

### Risks and Caveats

1. **Stock macOS bash 3.2 is a live bug, not just a cross-platform concern.** Any macOS user without Homebrew bash has silently broken commit hooks today. This is the only finding that affects the current supported platform (macOS). All other issues are Windows-specific or future concerns.

2. **Claude Code's hook invocation model is opaque.** We do not control how Claude Code resolves `#!/usr/bin/env bash` or expands `$CLAUDE_PROJECT_DIR`. If Claude Code uses a different shell or quoting convention on Windows, hook scripts may break in ways we cannot reproduce. This is a Claude Code platform behavior question that requires testing, not just code analysis.

3. **Enterprise Windows environments may block symlinks entirely.** Group Policy can disable `SeCreateSymbolicLinkPrivilege` even with Developer Mode. This means even the WSL path might be restricted in some corporate environments. There is no mitigation for this -- it is a policy constraint outside the project's control.

4. **The "document and wait" approach has a risk of misleading users.** If the README says "tested on macOS and Linux" without specifics, a Linux user with an unusual setup (Alpine without coreutils, Busybox ash) might assume it works and hit failures. The documentation must be specific about dependencies, not just platform names.

5. **Hook path coupling is fragile.** The temp file paths in `track-file-changes.sh`, `commit-point-check.sh`, and `SKILL.md` must all agree. A partial fix (updating some references but not others) would silently break the commit checkpoint system. Any future `$TMPDIR` standardization must be atomic across all files.

### Next Steps

If the recommendation is adopted, the implementation path has two phases:

**Phase 1 -- Documentation (immediate, low effort)**:
- Add platform disclaimer to README.md (1 blockquote after "Install" heading)
- Add prerequisites checklist to README.md (tool table with versions)
- Add "Quick Setup via Claude Code" prompt to README.md
- Add platform notes section to README.md (symlink explanation, WSL recommendation)
- Create `docs/prerequisites.md` with per-platform install commands
- Add platform support table to `docs/deployment.md`
- Update `docs/architecture.md` sub-documents table
- Create GitHub issue for cross-platform tracking (17-item checklist)

**Phase 2 -- Script hardening (defer until demand)**:
- Fix bash 4+ features in `commit-point-check.sh` (POSIX alternatives)
- Add bash version guard and `jq` existence check to hook scripts
- Standardize temp paths to `${TMPDIR:-/tmp}` across all files
- Add `./install.sh check` subcommand
- Add CRLF normalization to ledger writes
- Consider `shellcheck` CI validation

**Phase 3 -- Windows support (defer indefinitely, track in issue)**:
- Architectural decision: WSL-only vs. copy-based fallback vs. PowerShell script
- If copy-based: implement `create_link()` fallback in `install.sh`
- If WSL-only: document and close
- CI matrix testing on macOS, Ubuntu, Windows

### Conflict Resolutions

1. **Junction points**: iac-minion listed as option, security-minion blocked. Resolved in favor of security-minion -- junction traversal is a real local privilege escalation vector.

2. **Immediacy of code changes**: iac-minion proposed 5 implementation tasks (bash fix, temp paths, copy fallback, docs, shellcheck CI). devx-minion recommended Tier 1 docs only, deferring code. Resolved in favor of devx-minion's tiered approach -- consistent with the project's YAGNI/KISS philosophy from CLAUDE.md.

3. **Prerequisites location**: software-docs-minion wanted standalone `docs/prerequisites.md`, devx-minion wanted inline README checklist. Resolved as complementary -- README gets a concise checklist, `docs/prerequisites.md` gets the detailed per-platform install commands. Both serve different reading contexts.

---

## Appendix: Ready-to-Use Prompts

### Prompt 1: Platform Disclaimer for README

Add to README.md immediately after the "Install" heading and before the existing "Requires Claude Code" line:

```markdown
> **Platform support:** Tested on macOS and Linux. Windows is not currently
> supported -- `install.sh` uses POSIX symlinks that are not available natively
> on Windows. Windows users can try [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
> (untested). See [Platform Notes](#platform-notes) for details and
> [Prerequisites](docs/prerequisites.md) for required tools.
```

Add a "Platform Notes" section before the "License" section at the bottom of README.md:

```markdown
## Platform Notes

despicable-agents uses symlinks for deployment. `install.sh` creates symlinks
from the repository to `~/.claude/agents/` and `~/.claude/skills/`, so edits to
agent files are immediately live without re-installing. This works natively on
macOS and Linux.

**Windows users** have two options:
1. **WSL (recommended):** Clone the repo inside WSL and run `./install.sh`.
   Claude Code supports WSL.
2. **Git Bash:** Enable Developer Mode in Windows Settings, then run:
   `MSYS=winsymlinks:nativestrict ./install.sh`. Without Developer Mode,
   symlink creation requires an elevated (admin) terminal.

The commit workflow hooks require **bash 4+** and **jq**:
- macOS ships bash 3.2 -- install a newer version via `brew install bash`
- jq is not pre-installed on any platform -- see [Prerequisites](docs/prerequisites.md)
```

### Prompt 2: Required CLI Tools Documentation

Create `docs/prerequisites.md`:

```markdown
[< Back to Architecture Overview](architecture.md)

# Prerequisites

Tools required to install and use despicable-agents.

## Required

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Latest | AI coding assistant that loads the agents |
| [Git](https://git-scm.com/) | 2.20+ | Version control, used by hooks and install script |
| [Bash](https://www.gnu.org/software/bash/) | 4.0+ | Hook scripts use bash 4+ features (associative arrays) |
| [jq](https://jqlang.github.io/jq/) | 1.6+ | JSON parsing in commit workflow hooks |

## Optional

| Tool | Purpose |
|------|---------|
| [GitHub CLI (`gh`)](https://cli.github.com/) | PR creation suggestions from commit checkpoints |

## Install by Platform

### macOS

macOS ships bash 3.2 (2007) due to GPLv3 licensing. The commit hooks require
bash 4+. Install a current version via Homebrew:

```bash
brew install bash jq
# Optional:
brew install gh
```

The Homebrew bash installs to `/opt/homebrew/bin/bash` (Apple Silicon) or
`/usr/local/bin/bash` (Intel). The hook scripts use `#!/usr/bin/env bash` which
resolves to the first `bash` on `$PATH`. Ensure Homebrew's bin directory appears
before `/bin` in your `$PATH` (Homebrew's installer does this by default).

### Linux (Debian / Ubuntu)

```bash
sudo apt update && sudo apt install -y jq
# Optional:
sudo apt install -y gh
```

Bash 4+ and git are pre-installed on most Linux distributions.

### Linux (Fedora / RHEL)

```bash
sudo dnf install -y jq
# Optional:
sudo dnf install -y gh
```

### Windows

Not currently supported. See the project README for WSL workaround.

## Quick Setup via Claude Code

Already have Claude Code? Paste the following into a Claude Code session and it
will detect your platform, check what is missing, and install it:

> Check if these tools are installed and install any that are missing:
> - git 2.20+
> - jq 1.6+
> - bash 4.0+ (on macOS, the system bash is 3.2 -- needs brew install bash)
> - gh CLI (optional, for PR creation)
> Then run ./install.sh in this repo to deploy the agents.

## Verify Your Setup

```bash
bash --version   # Should show 4.0+
git --version    # Should show 2.20+
jq --version     # Should show 1.6+
gh --version     # Optional, should show 2.x+
```
```

Also add a prerequisites row to the "User-Facing" table in `docs/architecture.md`:

```markdown
| [Prerequisites](prerequisites.md) | Required CLI tools, per-platform installation, setup verification |
```

And add a "Prerequisites" section to the README after the install code block:

```markdown
### Prerequisites

The install script needs only `git`. The commit workflow hooks need additional tools:

| Tool | Version | Required For | Install |
|------|---------|--------------|---------|
| git | 2.20+ | Core | Pre-installed on macOS (`xcode-select --install`). `sudo apt install git` on Ubuntu. |
| bash | 4.0+ | Commit hooks | macOS ships 3.2 -- run `brew install bash`. Pre-installed on Linux. |
| jq | 1.6+ | Commit hooks | `brew install jq` (macOS). `sudo apt install jq` (Ubuntu). |
| gh | 2.0+ | PR suggestions (optional) | `brew install gh` (macOS). See [cli.github.com](https://cli.github.com). |

Or paste the [quick setup prompt](docs/prerequisites.md#quick-setup-via-claude-code) into Claude Code and it will install what is missing.
```

### Prompt 3: Achieving Cross-Platform Stability

Use this prompt in a future `/nefario` session when ready to do the script hardening work:

```
Harden the despicable-agents shell scripts for cross-platform stability. Scope:

1. Fix bash 4+ features in .claude/hooks/commit-point-check.sh:
   - Replace `local -A seen_paths` (associative array) with file-based dedup
     using `awk '!seen[$0]++'` or `sort -u` on a temp file
   - Replace `local -a var=()` with `local var=""` and newline-delimited
     processing via `while read` loops
   - Verify the result works on bash 3.2 (test with: env BASH=/bin/bash bash script.sh on macOS)

2. Add dependency guards to both hook scripts (.claude/hooks/):
   - At the top of main(), check `command -v jq >/dev/null 2>&1` -- if missing,
     write a one-time warning to stderr and exit 0
   - Check BASH_VERSINFO[0] >= 4 -- if too old, write warning to stderr and exit 0
   - Guards must be before any jq or bash 4+ usage

3. Standardize all temp file paths to ${TMPDIR:-/tmp}:
   - In .claude/hooks/track-file-changes.sh (ledger path)
   - In .claude/hooks/commit-point-check.sh (ledger, defer marker, declined marker,
     nefario status check)
   - In skills/nefario/SKILL.md (status files, session-id, PR body temp)
   - Define TEMP_BASE="${TMPDIR:-/tmp}" once at the top of each script
   - CRITICAL: all files must use the same base path -- hooks and SKILL.md share
     file paths. Verify with grep that no bare /tmp/ references remain.

4. Add CRLF normalization to ledger writes in track-file-changes.sh:
   - Pipe through `tr -d '\r'` before appending to ledger

5. Replace `echo -e` with `printf` in install.sh for portability.

Do NOT add Windows-specific code (no icacls, no junction points, no PowerShell).
Do NOT add an install.sh check subcommand (separate task).
Do NOT modify the install.sh symlink mechanism.
Run shellcheck on all modified .sh files before committing.
```
