[< Back to README](../README.md)

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

## Quick Setup

Paste the following into a Claude Code session and it will detect your platform,
check what is missing, and install it:

```
Check if these tools are installed and install or upgrade any that are
missing or too old:
- git 2.20+
- jq 1.6+
- bash 4.0+ (on macOS, the system bash is 3.2 -- needs brew install bash)
- gh CLI (optional, for PR creation)
Then run ./install.sh in this repo to deploy the agents.
```

## Verify Your Setup

```bash
bash --version   # Should show 4.0+
git --version    # Should show 2.20+
jq --version     # Should show 1.6+
gh --version     # Optional, should show 2.x+
```

