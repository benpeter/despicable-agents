Update `README.md` in the despicable-agents repository to add platform
disclaimers, a condensed prerequisites summary, and a Platform Notes section.

## Context

The advisory audit produced ready-to-use copy in
`docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis.md`.
The specialist team resolved three structural decisions:
- The platform disclaimer goes INSIDE a Prerequisites subsection (after
  the clone command), not before the clone command as a standalone blockquote
- The README gets a condensed 3-line prerequisites summary, not the full
  table -- the full table lives in docs/prerequisites.md
- Platform Notes stays visible (no `<details>` collapse)

## Changes to Make

**Change 1: Add a Prerequisites subsection after the symlink explanation line.**

After the "Symlinks 27 agents..." line and BEFORE the "### Using on Other
Projects" subsection, insert:

```markdown

### Prerequisites

Tested on macOS and Linux. Windows is not currently supported -- see
[Platform Notes](#platform-notes).

The install script needs only `git`. The commit workflow hooks additionally
need **bash 4+** and **jq** -- see [Prerequisites](docs/prerequisites.md)
for per-platform install commands, or paste the
[quick setup prompt](docs/prerequisites.md#quick-setup-via-claude-code) into
Claude Code.
```

This is 6 lines of content -- concise, links to the full details, and keeps
the Install section compact. The platform disclaimer is integrated as the
opening line rather than a separate blockquote.

**Change 2: Add a Platform Notes section before License.**

Use the "Platform Notes" content from Prompt 1 of the advisory report
(lines 153-171 of the advisory). Insert it immediately before the
"## License" section. The content starts with `## Platform Notes` and
covers symlink deployment explanation, Windows options (WSL + Git Bash),
and the bash 4+ / jq hook requirements.

Copy the Platform Notes section exactly as written in the advisory Prompt 1.

## File Structure After Changes

The README section order should be:
1. Title + badges
2. What You Get
3. Examples
4. Install (clone + install.sh + symlink explanation)
5. **Prerequisites** (NEW - condensed summary with links)
6. Using on Other Projects
7. How It Works
8. Agents
9. Documentation
10. Current Limitations
11. Contributing
12. **Platform Notes** (NEW - full platform details)
13. License

## Boundaries

- Do NOT add the full prerequisites table to the README (it lives in docs/prerequisites.md)
- Do NOT add the Claude Code prompt to the README (it lives in docs/prerequisites.md)
- Do NOT use a `<details>` collapse for Platform Notes
- Do NOT modify any content outside the Install section and the new Platform Notes section
- Do NOT change the "Requires Claude Code" line or the clone command

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
