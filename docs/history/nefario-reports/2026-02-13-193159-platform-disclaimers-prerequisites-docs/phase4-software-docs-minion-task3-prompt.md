Update the Prerequisites subsection in `docs/deployment.md` to
cross-reference the new `docs/prerequisites.md` page.

## Context

The current "Prerequisites" subsection under "Hook Deployment" (lines 99-103)
reads:

```markdown
### Prerequisites

- Hook scripts must have execute permissions: `chmod +x .claude/hooks/*.sh`
- `jq` must be installed for JSON parsing in hooks
```

A new `docs/prerequisites.md` page has been created as the single source
of truth for all tool requirements. The deployment.md prerequisites should
cross-reference it instead of maintaining a separate incomplete list.

## Change to Make

Replace the Prerequisites subsection content with:

```markdown
### Prerequisites

- Hook scripts must have execute permissions: `chmod +x .claude/hooks/*.sh`
- Hook scripts require **bash 4+** and **jq** -- see [Prerequisites](prerequisites.md) for per-platform install commands
- Symlink deployment requires macOS or Linux. See the project README [Platform Notes](../README.md#platform-notes) for Windows workarounds.
```

This preserves the chmod instruction (deployment-specific), adds the bash 4+
requirement that was previously missing, and links to prerequisites.md for
install commands. The platform note is a single line pointing to the README
for full details.

## Boundaries

- Do NOT add a platform support table to deployment.md (that was considered
  and rejected to avoid duplication)
- Do NOT modify any other sections of deployment.md
- Do NOT move or restructure the Prerequisites subsection -- it stays under
  Hook Deployment

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
