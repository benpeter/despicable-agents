## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. Platform Support Disclaimer -- Placement and Phrasing

The disclaimer belongs in two locations:

**README.md** -- Add a "Platform Support" callout immediately after the "Install" heading, before the code block. This is where developers hit the first platform-dependent instruction (`./install.sh`). Use a simple bold-text callout, not a badge. Badges communicate status at a glance but bury detail; a callout communicates "stop and read this before you proceed." Phrasing should be honest, specific about what breaks, and link to the tracking issue or roadmap for updates.

**docs/deployment.md** -- Add a "Platform Support" section at the top, after the back-link. This page documents the symlink model and install.sh behavior, which are the two highest-impact platform-specific items. The disclaimer here can be more technical (specific incompatibilities rather than just "not supported").

Do NOT add disclaimers to every sub-document. Two locations is sufficient -- the entry point (README) and the deployment-specific page. Other docs are architecture/design docs that are platform-agnostic by nature.

**Phrasing guidance for an Apache 2.0 open-source project:**
- Lead with what works, then state what does not. "Tested on macOS and Linux. Windows is not yet supported."
- Be specific about the failure mode, not vague. "install.sh relies on POSIX symlinks and Bash 4+ features" is better than "may not work on Windows."
- Link to a tracking issue so users can follow progress.
- Avoid "coming soon" -- use "contributions welcome" which is honest and actionable for an open-source project.

#### 2. Prerequisites/Dependencies Page -- Standalone vs. Embedded

**Recommendation: Create a new standalone `docs/prerequisites.md`** and add it to the architecture.md sub-documents table under "User-Facing."

Rationale:
- The deployment.md page already documents symlink mechanics and install.sh behavior. Mixing CLI tool prerequisites into it creates two concerns in one page.
- Prerequisites are a Day 1 onboarding concern. They need to be findable without reading about symlink architecture.
- The README "Install" section should link to it: "For prerequisite tools, see [Prerequisites](docs/prerequisites.md)."
- The page should be task-oriented: "what do I need" then "how do I get it" then "how do I verify."

**Content structure for prerequisites.md:**

```
# Prerequisites

## Required
- Claude Code (link to install docs)
- Git (version X+)
- Bash 4.0+ (macOS ships Bash 3.2; upgrade via Homebrew)
- jq (used by commit workflow hooks)

## Optional
- gh CLI (GitHub CLI, for PR creation at session wrap-up)

## Per-Platform Install

### macOS
<commands>

### Linux (Debian/Ubuntu)
<commands>

### Linux (Fedora/RHEL)
<commands>

### Windows
Not yet supported. See [Cross-Platform Roadmap](#cross-platform-roadmap) or tracking issue #XX.

## Verify Your Setup
<verification commands>
```

**Important detail**: The page should include a "paste this list to Claude Code and ask it to install what is missing" note. This is a clever onboarding shortcut that fits the project's nature (it IS a Claude Code toolkit).

#### 3. Cross-Platform Roadmap -- Format and Location

**Recommendation: GitHub Issue, not a docs page.** A roadmap in docs/ goes stale the moment work starts. A GitHub issue with a checklist is the living tracking artifact. The README and prerequisites.md link to it.

The issue should contain:
- A checklist of the 17 identified platform issues, grouped by severity
- Labels: `platform`, `windows`, `help-wanted`
- A brief section on the architectural approach (POSIX compatibility layer vs. platform-specific install paths)

If the team later decides to formally support Windows, THAT decision warrants an ADR (e.g., `docs/adr/0001-cross-platform-support-strategy.md`). The ADR would document the chosen approach (e.g., "use PowerShell install script alongside bash" vs. "require WSL" vs. "rewrite install.sh in a cross-platform language"). Until the decision is made, the tracking issue is the right artifact.

#### 4. Integration with Existing Docs Structure

The docs hub (`docs/architecture.md`) has two tables: "User-Facing" and "Contributor / Architecture." The new page fits cleanly:

| Table | Document | Rationale |
|-------|----------|-----------|
| User-Facing | `prerequisites.md` | Users need this to get started |
| Contributor / Architecture | No new page needed | Cross-platform work is tracked in a GitHub issue, not a design doc (yet) |

The README changes are inline edits (disclaimer + link), not new sections.

### Proposed Tasks

#### Task 1: Add platform disclaimer to README.md

**What**: Add a "Platform Support" callout to the Install section of README.md, between the "Install" heading and the code block.

**Deliverable**: Updated README.md with disclaimer text and link to tracking issue.

**Dependencies**: The tracking issue (Task 4) should be created first so the README can link to it.

**Suggested copy** (prompt for execution):

```markdown
> **Platform support:** Tested on macOS and Linux. Windows is not currently
> supported -- `install.sh` uses POSIX symlinks and Bash 4+ features that
> are not available natively on Windows. See [#XX](link) for the
> cross-platform tracking issue. Contributions welcome.
```

#### Task 2: Add platform details to docs/deployment.md

**What**: Add a "Platform Support" section near the top of deployment.md with specific technical details about platform dependencies: symlinks (`ln -s`), Bash version (`BASH_SOURCE`, `set -euo pipefail`, associative arrays in hooks), `/tmp` path, `readlink` behavior, `chmod +x`, ANSI color codes, `jq` dependency.

**Deliverable**: Updated docs/deployment.md.

**Dependencies**: None (can proceed in parallel with other tasks).

**Suggested copy** (prompt for execution):

```markdown
## Platform Support

The deployment model depends on:

| Feature | Used By | macOS | Linux | Windows |
|---------|---------|-------|-------|---------|
| POSIX symlinks (`ln -s`, `ln -sf`) | install.sh | Yes | Yes | No (NTFS symlinks require admin) |
| Bash 4.0+ | Hook scripts (associative arrays) | Requires Homebrew bash | Yes (default) | No (requires WSL or Git Bash) |
| `readlink` (no flags) | install.sh uninstall | Yes | Yes | No |
| `jq` | Hook scripts | Install via Homebrew | Install via apt/dnf | Install via Scoop/Chocolatey |
| `/tmp/` temp directory | Change ledger, status files | Yes | Yes | No (`%TEMP%` on Windows) |
| `chmod +x` | Hook scripts | Yes | Yes | No-op on NTFS |
| ANSI escape codes | install.sh output | Yes | Yes | Partial (Windows Terminal yes, cmd.exe no) |
| `gh` CLI (optional) | PR creation | Install via Homebrew | Install via apt/dnf | Install via Scoop/Chocolatey |

macOS and Linux are fully supported. Windows is not supported. See [Prerequisites](prerequisites.md) for required tools and installation instructions.
```

#### Task 3: Create docs/prerequisites.md

**What**: Create a new prerequisites page documenting all required and optional CLI tools with per-platform install instructions and a verification section.

**Deliverable**: New file `docs/prerequisites.md`, added to architecture.md User-Facing sub-documents table, linked from README.md Install section.

**Dependencies**: None.

**Suggested content structure** (prompt for execution):

```markdown
[< Back to Architecture Overview](architecture.md)

# Prerequisites

Tools required to install and use despicable-agents.

## Required

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Latest | AI coding assistant that loads the agents |
| [Git](https://git-scm.com/) | 2.20+ | Version control, used by hooks and commit workflow |
| [Bash](https://www.gnu.org/software/bash/) | 4.0+ | install.sh and hook scripts (macOS ships 3.2 -- see below) |
| [jq](https://jqlang.github.io/jq/) | 1.6+ | JSON parsing in hook scripts |

## Optional

| Tool | Purpose |
|------|---------|
| [GitHub CLI (`gh`)](https://cli.github.com/) | PR creation at session wrap-up (graceful degradation if absent) |

## Installation by Platform

### macOS

```bash
# Bash 4+ (macOS ships Bash 3.2 due to licensing)
brew install bash

# jq
brew install jq

# GitHub CLI (optional)
brew install gh
```

Note: The Homebrew-installed bash is at `/opt/homebrew/bin/bash` (Apple Silicon)
or `/usr/local/bin/bash` (Intel). The hook scripts use `#!/usr/bin/env bash`
which resolves to the first `bash` in `$PATH`. Ensure Homebrew's bin directory
is before `/bin` in your `$PATH`.

### Linux (Debian / Ubuntu)

```bash
sudo apt update && sudo apt install -y bash jq
# Optional:
sudo apt install -y gh
```

### Linux (Fedora / RHEL)

```bash
sudo dnf install -y bash jq
# Optional:
sudo dnf install -y gh
```

### Windows

Not currently supported. See the [cross-platform tracking issue](#XX).

If you are on Windows, you may be able to use WSL (Windows Subsystem for Linux)
with the Linux instructions above, though this is untested.

## Quick Setup via Claude Code

Already have Claude Code running? Paste the following and ask it to install
any missing tools:

> I need these CLI tools for despicable-agents: bash 4+, jq, git 2.20+,
> and optionally gh. Check which are missing and install them.

## Verify Your Setup

```bash
bash --version   # Should show 4.0+
git --version    # Should show 2.20+
jq --version     # Should show 1.6+
gh --version     # Optional -- should show 2.x+
```
```

#### Task 4: Create cross-platform tracking issue on GitHub

**What**: Create a GitHub issue with a checklist of the 17 identified platform issues, grouped by category and severity. Label with `platform`, `windows`, `help-wanted`.

**Deliverable**: GitHub issue with structured checklist. URL linked from README and prerequisites.md.

**Dependencies**: The 17-item inventory from the platform audit.

**Suggested issue body** (prompt for execution):

```markdown
## Cross-Platform Support

despicable-agents is currently tested on macOS and Linux only.
This issue tracks the work needed to support Windows.

### Blocking Issues (install.sh will not run)

- [ ] `ln -s` / `ln -sf` -- POSIX symlinks not available natively on Windows
- [ ] `readlink` -- not available on Windows
- [ ] `BASH_SOURCE[0]` -- not available outside Bash
- [ ] `set -euo pipefail` -- Bash-specific
- [ ] Shebang lines (`#!/usr/bin/env bash`) -- not interpreted on Windows

### Blocking Issues (hooks will not run)

- [ ] Bash 4+ associative arrays (`local -A seen_paths`) in commit-point-check.sh
- [ ] `jq` dependency -- not pre-installed on Windows
- [ ] `/tmp/` hardcoded temp directory paths (change ledger, status files, defer markers)
- [ ] `chmod +x` for hook script permissions -- no-op on NTFS
- [ ] `grep -qFx` -- flags may differ on Windows grep implementations

### Functional Issues

- [ ] ANSI color escape codes in install.sh output -- not supported in cmd.exe
- [ ] `$HOME` environment variable -- `%USERPROFILE%` on Windows
- [ ] Path separators (`/` vs `\`) throughout scripts
- [ ] `~/.claude/` path expansion -- tilde expansion is shell-specific

### Approach Options

**Option A: Require WSL on Windows**
Lowest effort. Document WSL as a prerequisite for Windows users.
Pros: No code changes. Cons: Adds friction for Windows users.

**Option B: Add PowerShell install script**
Write `install.ps1` alongside `install.sh`. Hooks remain Bash (run in Git Bash).
Pros: Native install experience. Cons: Two scripts to maintain, hooks still need Bash.

**Option C: Cross-platform scripting**
Rewrite install.sh and hooks in a cross-platform language (Node.js, Python, or Deno).
Pros: True cross-platform. Cons: Adds a runtime dependency, more complex.

### Current Status

macOS and Linux are supported. Windows support is not planned for the near term.
Contributions toward any of the above approaches are welcome.
```

#### Task 5: Update docs/architecture.md sub-documents table

**What**: Add prerequisites.md to the "User-Facing" sub-documents table.

**Deliverable**: Updated architecture.md.

**Dependencies**: Task 3 (prerequisites.md must exist).

**Row to add:**

```markdown
| [Prerequisites](prerequisites.md) | Required CLI tools, per-platform installation, setup verification |
```

### Risks and Concerns

1. **macOS Bash 3.2 is a latent bug today, not just a Windows issue.** The hook scripts use `local -A` (associative arrays) which require Bash 4+. macOS ships Bash 3.2. If a macOS user has not installed Bash via Homebrew, the commit-point-check.sh hook will fail silently (because of the ERR trap in track-file-changes, and the `set -euo pipefail` in commit-point-check). This is a real bug affecting current macOS users who have not upgraded Bash. The prerequisites doc must call this out prominently, and the README disclaimer should mention Bash 4+ specifically.

2. **Documentation drift risk.** The platform compatibility table in deployment.md will drift from reality as fixes land. Mitigation: the GitHub tracking issue is the living artifact; the deployment.md table is a snapshot that should reference the issue for current status.

3. **Overloading the README.** The README is currently clean and focused. The disclaimer must be minimal -- one blockquote, not a section. The detail belongs in prerequisites.md and the tracking issue, not the README.

4. **"Contributions welcome" without contributor guidance.** Saying "contributions welcome" for Windows support without specifying which approach (WSL, PowerShell, cross-platform rewrite) is preferred may lead to wasted effort. The tracking issue should include the approach options so contributors can discuss before implementing.

5. **`/tmp/` hardcoding is fragile even on macOS.** macOS sandboxing and some CI environments use different temp directories. While `mktemp -d` would be more robust, changing the temp path pattern affects both hook scripts and the SKILL.md instructions that reference these paths. This is a code change concern, not a docs concern, but the prerequisites doc should note that `/tmp/` must be writable.

### Additional Agents Needed

- **devx-minion**: The install.sh script and hook scripts are developer tooling. Cross-platform compatibility is a developer experience concern. devx-minion should assess the 17-item inventory and recommend the best approach (WSL requirement vs. PowerShell port vs. cross-platform rewrite). This is a tooling design decision, not a documentation decision.

- **iac-minion**: If the chosen approach involves CI-based validation of cross-platform compatibility (e.g., running install.sh in a Windows CI runner), iac-minion should advise on the CI configuration.

No other additional agents are needed. The documentation tasks outlined above are squarely within software-docs-minion scope.
