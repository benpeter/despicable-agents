Create the file `docs/prerequisites.md` in the despicable-agents repository.

## Context

This is a new documentation page listing CLI tool prerequisites for
installing and using despicable-agents. The content has been pre-approved
from an advisory audit. Your job is to write the file using the approved
content with specific modifications from specialist review.

## Base Content

Use the content from Prompt 2 in the advisory report at
`docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis.md`
(lines 175-259). Copy this content as the starting point for
`docs/prerequisites.md`.

## Modifications to Apply

Three changes from specialist review:

1. **Breadcrumb correction (from lucy's review)**: The breadcrumb at the top
   of the file must follow the User-Facing convention. Change it from:
   `[< Back to Architecture Overview](architecture.md)`
   to:
   `[< Back to README](../README.md)`
   This is because prerequisites.md is categorized as User-Facing (it appears
   in the User-Facing table in architecture.md). All User-Facing docs link
   back to the README, not to architecture.md.

2. **Wording change in the Claude Code prompt**: In the "Quick Setup via
   Claude Code" section, change the prompt text from:
   "Check if these tools are installed and install any that are missing:"
   to:
   "Check if these tools are installed and install or upgrade any that are missing or too old:"

3. **Format change for the Claude Code prompt**: Change the prompt from a
   blockquote (lines prefixed with `>`) to a fenced code block (triple
   backticks with no language tag). This gives users a copy button on
   GitHub and clean select-copy behavior. The prompt is an instruction to
   paste, not a quote -- a code fence is semantically correct and
   practically better for copy-paste UX.

The resulting "Quick Setup via Claude Code" section should look like:

````markdown
## Quick Setup via Claude Code

Already have Claude Code? Paste the following into a Claude Code session and it
will detect your platform, check what is missing, and install it:

```
Check if these tools are installed and install or upgrade any that are
missing or too old:
- git 2.20+
- jq 1.6+
- bash 4.0+ (on macOS, the system bash is 3.2 -- needs brew install bash)
- gh CLI (optional, for PR creation)
Then run ./install.sh in this repo to deploy the agents.
```
````

## Verification

- File starts with `[< Back to README](../README.md)` breadcrumb (User-Facing convention)
- Has Required and Optional tool tables
- Has Install by Platform sections for macOS, Linux (Debian/Ubuntu), Linux (Fedora/RHEL), Windows
- Has Quick Setup via Claude Code section with fenced code block (not blockquote)
- Has Verify Your Setup section with version check commands
- The prompt text says "install or upgrade any that are missing or too old"

## Boundaries

- Do NOT modify any other files
- Do NOT add content beyond what is in the advisory Prompt 2 (plus the three modifications above)
- Do NOT change the tool versions or platform-specific install commands

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts (e.g., "docs/prerequisites.md (new file, +N lines)")
- 1-2 sentence summary of what was produced
