# Domain Plan Contribution: devx-minion

## Recommendations

### 1. Current Platform Status Assessment

After auditing the codebase, here is the complete external dependency inventory and platform compatibility status.

**External CLI tool dependencies:**

| Tool | Used In | Required For | macOS | Linux | Windows (Git Bash) |
|------|---------|--------------|-------|-------|---------------------|
| `bash` 4+ | All `.sh` scripts | Associative arrays (`local -A`), indexed arrays (`local -a`) in `commit-point-check.sh` | Needs Homebrew (system bash is 3.2) | Ships with distro | Ships with Git for Windows (4.4+) |
| `git` | Hook scripts, install.sh (uninstall) | Symlink verification, change tracking | Pre-installed or Xcode CLT | `apt install git` | Required by Claude Code on Windows |
| `jq` | Both hook scripts | JSON parsing of hook input | `brew install jq` | `apt install jq` | Separate install needed |
| `ln -sf` | install.sh | Symlink creation | Native | Native | Requires `MSYS=winsymlinks:nativestrict` or admin/Developer Mode |
| `readlink` | install.sh (uninstall only) | Symlink target verification | BSD variant (no `--help`, no `-f`) | GNU variant | Git Bash includes MSYS2 version |
| `grep` | track-file-changes.sh | Ledger deduplication | Native | Native | Git Bash includes |
| `awk` | commit-point-check.sh | Diff line counting | Native | Native | Git Bash includes |
| `gh` (GitHub CLI) | commit-point-check.sh (suggested, not required) | PR creation suggestion in commit checkpoint | `brew install gh` | `apt install gh` | `winget install GitHub.cli` |

**Verdict: The core install path (install.sh) works on macOS and Linux today. Windows has a real symlink problem. The hook scripts additionally require jq and bash 4+.**

### 2. Platform Compatibility Issues Found

**Critical (blocks install on Windows):**

- `ln -sf` in Git Bash on Windows creates **copies, not symlinks** by default. The entire deployment model depends on symlinks for live-editing. This is the single biggest blocker.
- Workaround exists (`MSYS=winsymlinks:nativestrict` + Developer Mode), but it is non-obvious and fragile.

**Moderate (breaks hooks on stock macOS):**

- macOS ships with bash 3.2 (from 2007). The commit-point-check.sh uses `local -A` (associative arrays), a bash 4.0+ feature. Users who run Claude Code with the system bash will get silent hook failures.
- `jq` is not pre-installed on any platform. Hooks silently fail without it (they trap errors and exit 0, which is safe but confusing).

**Low (cosmetic):**

- `readlink` on macOS is the BSD variant. The current usage (`readlink <path>` without `-f`) works correctly on all platforms -- no issue here.
- Color codes in install.sh use ANSI escapes, which work in all modern terminals including Windows Terminal and Git Bash.

### 3. Documentation Format Recommendations

**(a) Prerequisites section format: Use a simple checklist, not tabs or a table.**

Tables are good for comparison, but a prerequisites section is a "do you have these things" moment. A checklist with copy-pasteable verification commands is the right format. Platform-specific tabs add cognitive load for what should be a 30-second check.

Recommended structure:
```
## Prerequisites

- [ ] **Claude Code** -- [Install guide](https://code.claude.com/docs/en/setup)
- [ ] **git** -- `git --version` (2.20+)
- [ ] **jq** -- `jq --version` (1.6+, required for commit hooks)
- [ ] **bash** 4+ -- `bash --version` (required for commit hooks)
- [ ] **gh** (optional) -- `gh --version` (for PR creation from commit checkpoints)
```

Keep it flat. No tabs. Developers scan, they do not read.

**(b) A "check prerequisites" script: Yes, but as a command, not a separate script.**

Add `./install.sh check` as a third mode alongside `install` and `uninstall`. This keeps the single entry point and follows the pattern users already know. The check command should:

1. Verify each tool exists and meets minimum version
2. Print pass/fail per tool with install hints
3. Exit 0 if all required tools are present, exit 1 if any are missing
4. Detect platform and give platform-specific install commands

Example output:
```
Checking prerequisites for despicable-agents...
  [ok] git 2.39.0
  [ok] bash 5.2.15
  [!!] jq not found
       Install: brew install jq (macOS) | apt install jq (Ubuntu/Debian)
  [ok] gh 2.40.0 (optional)

1 required tool missing. Install it and re-run ./install.sh
```

**(c) How to communicate "macOS/Linux only" without sounding immature:**

Do NOT say "macOS/Linux only" -- that frames a negative. Instead, state what IS supported and what the status is for other platforms. Use the same pattern as Claude Code's own docs.

Recommended language for the README:

> **Tested on macOS and Linux.** Windows support via WSL works but is not tested in CI. Native Windows (Git Bash) has known limitations with symlinks -- see [Platform Notes](#platform-notes) for workarounds.

This is honest, specific, and gives Windows users an immediate path (WSL) rather than a dead end. The phrase "not tested in CI" signals this is a maturity/resource issue, not an architectural one.

For a dedicated section lower in the README:

> ### Platform Notes
>
> despicable-agents uses symlinks for deployment (`install.sh` creates symlinks to `~/.claude/agents/`). This works natively on macOS and Linux.
>
> **Windows users** have two options:
> 1. **WSL (recommended):** Run `./install.sh` inside WSL. Claude Code supports WSL natively.
> 2. **Git Bash:** Enable Developer Mode in Windows Settings, then run with `MSYS=winsymlinks:nativestrict ./install.sh`. Symlinks require elevated permissions or Developer Mode on Windows.
>
> The commit workflow hooks require **bash 4+** and **jq**. macOS ships with bash 3.2 -- install a newer version via `brew install bash`. See [Prerequisites](#prerequisites) for details.

**(d) CLI tool documentation with cross-platform install instructions:**

Use a single table with one row per tool and platform-specific install commands. This is the most scannable format for developers who need to install one missing tool.

```markdown
## Required Tools

| Tool | Version | macOS | Ubuntu/Debian | Windows |
|------|---------|-------|---------------|---------|
| git | 2.20+ | `xcode-select --install` or `brew install git` | `sudo apt install git` | [git-scm.com](https://git-scm.com/downloads/win) (required for Claude Code) |
| jq | 1.6+ | `brew install jq` | `sudo apt install jq` | `winget install jqlang.jq` |
| bash | 4.0+ | `brew install bash` | Pre-installed | Included with Git for Windows |
| gh | 2.0+ | `brew install gh` | See [cli.github.com](https://cli.github.com) | `winget install GitHub.cli` |

**Note:** `git` and `bash 4+` are required for core functionality. `jq` is required for commit workflow hooks. `gh` is optional (used for PR creation suggestions).
```

**(e) The "paste this list and ask Claude Code to install them" approach:**

This is viable and clever. Claude Code can run shell commands, so the user pastes a block and Claude Code handles the platform detection and package manager selection. Format it as a single copy-pasteable prompt, not individual commands.

Recommended format in the README:

> ### Quick Setup
>
> After cloning, paste this into Claude Code and it will install any missing prerequisites:
>
> ```
> Check if these tools are installed and install any that are missing:
> - git 2.20+
> - jq 1.6+
> - bash 4+ (on macOS, the system bash is 3.2 -- install via brew)
> - gh CLI (optional, for PR creation)
> Then run ./install.sh
> ```

This works because:
- Claude Code detects the platform automatically
- It knows the right package manager (brew, apt, winget, etc.)
- It can verify versions and only install what is actually missing
- It runs `./install.sh` at the end, closing the loop

The key design choice: give it as a plain-English prompt, not a bash script. Claude Code understands natural language better than a script that tries to handle every platform. This also means it works on platforms we have not tested -- Claude Code will figure out the right package manager for Fedora, Arch, etc.

### 4. Cross-Platform Stability Path

For achieving actual cross-platform stability, there are three tiers of effort:

**Tier 1 -- Documentation only (low effort, high value):**
- Add platform notes, prerequisites, and the Claude Code prompt to README
- Add `./install.sh check` command
- Document WSL as the recommended Windows path
- This is the right first step and may be sufficient for months

**Tier 2 -- Script hardening (moderate effort):**
- Add bash version check at top of hook scripts (degrade gracefully on bash 3.2)
- Add `jq` existence check in hook scripts (already fail-safe, but could warn)
- Make `install.sh` detect platform and warn about symlink issues on Windows
- Add `--copy` flag to `install.sh` for Windows users who cannot use symlinks (copies instead of symlinks, with a warning that live-editing will not work)

**Tier 3 -- True cross-platform (high effort, questionable value):**
- Rewrite `install.sh` to detect Windows and use `mklink` or junction points
- Add a `install.ps1` PowerShell equivalent
- CI matrix testing on macOS, Ubuntu, Windows
- This is YAGNI unless Windows usage is significant

My recommendation: **Do Tier 1 now. Defer Tier 2 and Tier 3** until there is evidence of Windows users hitting issues. The project's own engineering philosophy (YAGNI, lean and mean) supports this.


## Proposed Tasks

### Task 1: Add Prerequisites and Platform Notes to README

**What:** Add three new sections to `README.md`: Prerequisites checklist, Platform Notes, and Quick Setup (Claude Code prompt).

**Deliverables:**
- Updated `README.md` with Prerequisites section (tool checklist with versions)
- Platform Notes section with Windows guidance (WSL recommended, Git Bash workaround)
- Quick Setup section with copy-pasteable Claude Code prompt for dependency installation
- Updated "Current Limitations" to include platform note

**Dependencies:** None. Can be done first.

### Task 2: Add `./install.sh check` Command

**What:** Add a `check` subcommand to `install.sh` that verifies prerequisites (git, jq, bash version, gh) with platform-specific install hints and color-coded pass/fail output.

**Deliverables:**
- Updated `install.sh` with `check` subcommand
- Platform detection (macOS/Linux/Windows-Git-Bash)
- Per-tool version check with clear pass/fail output
- Platform-specific install commands in failure messages
- Exit code 0 (all present) or 1 (missing tools)

**Dependencies:** None. Can be done in parallel with Task 1.

### Task 3: Update `docs/deployment.md` Prerequisites

**What:** Expand the existing Prerequisites section in deployment.md (currently just mentions jq and chmod) to include the full tool inventory with version requirements.

**Deliverables:**
- Updated deployment.md with complete prerequisites table
- Cross-reference to README Quick Setup
- Note about `./install.sh check` command

**Dependencies:** Task 1 (for consistent language), Task 2 (for check command reference).


## Risks and Concerns

1. **Windows symlink model is fundamentally incompatible.** The project's core value proposition (edit agent files, changes are immediately live) depends on symlinks. A `--copy` fallback would work for install but lose the live-editing benefit. This is not a bug to fix -- it is an architectural constraint. Document it honestly rather than promising Windows support that delivers a degraded experience.

2. **bash 3.2 on stock macOS is a silent failure.** The hook scripts use `local -A` (associative arrays) which silently fail or produce unexpected behavior on bash 3.2. Since hooks trap errors and exit 0, users will never see an error -- they will just not get commit checkpoints. This is confusing. At minimum, the hooks should check bash version and warn on stderr.

3. **jq is a hidden dependency.** It is not mentioned in the README or install instructions, only in `docs/deployment.md` under "Prerequisites" in the Hook Deployment section. A user who clones and runs `./install.sh` will succeed, but their hooks will silently fail. The `./install.sh check` command would surface this.

4. **The "Claude Code prompt" approach depends on Claude Code being available.** This is a reasonable assumption for this project (Claude Code is a prerequisite), but the prompt should be positioned as a convenience, not the only path. Keep the manual install table as the primary reference.

5. **`gh` CLI is mentioned in commit-point-check.sh output but is truly optional.** The hook suggests `gh pr create` commands but also provides a fallback (`git push`). This should be clearly labeled "optional" in prerequisites to avoid users installing tools they do not need.


## Additional Agents Needed

**software-docs-minion** should be involved for the actual README and deployment.md prose. The devx-minion contribution above provides the information architecture (what sections, what format, what content) and ready-to-use prompts, but the docs specialist should review the final language for consistency with existing documentation tone and structure.

**iac-minion** may have useful input on the `./install.sh check` implementation, particularly around platform detection patterns and cross-platform shell scripting conventions. However, this is a simple enough script that it could be handled without specialist input.

No other agents are needed beyond those already in the planning team.


## Appendix: Ready-to-Use Prompts

The user requested prompts for the execution phase. Here they are.

### Prompt A: Platform Disclaimer for README

Insert after the current "Install" section:

```markdown
### Platform Support

**Tested on macOS and Linux.** Windows support via WSL works but is not tested in CI. Native Windows (Git Bash) has known limitations with symlinks -- see [Platform Notes](#platform-notes) for workarounds.

### Prerequisites

The install script (`./install.sh`) requires only `git`. The commit workflow hooks require additional tools:

| Tool | Version | Required For | Install |
|------|---------|--------------|---------|
| git | 2.20+ | Core (install, hooks) | Pre-installed on macOS (`xcode-select --install`). `sudo apt install git` on Ubuntu. |
| bash | 4.0+ | Commit hooks | macOS ships 3.2 -- run `brew install bash`. Pre-installed on Linux. |
| jq | 1.6+ | Commit hooks | `brew install jq` (macOS). `sudo apt install jq` (Ubuntu/Debian). |
| gh | 2.0+ | PR suggestions (optional) | `brew install gh` (macOS). See [cli.github.com](https://cli.github.com). |

Run `./install.sh check` to verify prerequisites.
```

Add before "Contributing":

```markdown
### Platform Notes

despicable-agents uses symlinks for deployment. `install.sh` creates symlinks from the repository to `~/.claude/agents/`, so edits to agent files are immediately live. This works natively on macOS and Linux.

**Windows users** have two options:
1. **WSL (recommended):** Clone the repo inside WSL and run `./install.sh`. Claude Code supports WSL natively.
2. **Git Bash:** Enable Developer Mode in Windows Settings (Settings > Update & Security > For developers), then run: `MSYS=winsymlinks:nativestrict ./install.sh`. Without Developer Mode, symlink creation requires an elevated (admin) terminal.

The commit workflow hooks (`.claude/hooks/`) require **bash 4+** and **jq**. macOS ships with bash 3.2 -- install a newer version via Homebrew (`brew install bash`).
```

### Prompt B: Required CLI Tools with "Ask Claude Code" Install

Add to README after Prerequisites:

```markdown
### Quick Setup

After cloning, paste this into a Claude Code session to install any missing prerequisites and deploy:

> Check if these tools are installed and install any that are missing:
> - git 2.20+
> - jq 1.6+
> - bash 4.0+ (on macOS, system bash is 3.2 -- needs brew install bash)
> - gh CLI (optional, for PR creation)
> Then run ./install.sh in this repo to deploy the agents.
```

### Prompt C: Cross-Platform Stability (for future execution)

```
Harden install.sh and hook scripts for cross-platform use:

1. Add `./install.sh check` subcommand that:
   - Detects platform (macOS/Linux/Windows-Git-Bash/WSL)
   - Checks each required tool: git (2.20+), bash (4.0+), jq (1.6+), gh (2.0+, optional)
   - Prints color-coded pass/fail per tool
   - Shows platform-specific install commands for missing tools
   - Exits 0 if all required present, 1 if any missing

2. Add bash version guard to commit-point-check.sh:
   - At top of main(), check BASH_VERSINFO[0] >= 4
   - If bash < 4, write warning to stderr and exit 0 (degrade gracefully)
   - This prevents silent failures on macOS stock bash

3. Add jq existence check to both hook scripts:
   - Before first jq call, check `command -v jq`
   - If missing, write warning to stderr and exit 0

4. In install.sh install_agents(), add Windows detection:
   - Check if running in MSYS/Git Bash (`[[ "$OSTYPE" == msys* ]]`)
   - If yes, check for MSYS=winsymlinks:nativestrict
   - Warn if not set, with instructions to enable Developer Mode
```
