## Domain Plan Contribution: user-docs-minion

### Recommendations

**Placement: New section in `docs/using-nefario.md`, not a standalone doc.**

The status line setup is a single-setting configuration that enhances the nefario usage experience. It belongs in the same document users read when learning to use nefario. A standalone `docs/status-line-setup.md` would create a disconnected page for a topic that takes under 2 minutes -- users would need to discover it separately, and it adds one more entry to an already 13-document `docs/` directory. Appending to `docs/deployment.md` is wrong because deployment covers the contributor/architecture audience (install.sh, symlinks, hooks), while the status line is a user-facing workflow enhancement.

Specifically: add a new H2 section `## Status Line` at the end of `docs/using-nefario.md`, just before the horizontal rule and architecture link. This positions it after the "Tips for Success" section, which is where a user who has read the guide would naturally look for optional enhancements.

**Why not deployment.md**: The architecture.md index explicitly categorizes `deployment.md` as "Contributor / Architecture" and `using-nefario.md` as "User-Facing." The status line guide targets end users, so it belongs in the user-facing document.

**Document type**: This is a how-to guide (task-oriented, assumes basic competence, achieves a specific goal). Keep it tightly scoped: one goal, one configuration block, one explanation of what it shows.

**Headings for scannability**:
```
## Status Line
### What It Shows
### Setup
### How It Works
```

Three subsections, each 2-5 sentences. The "Setup" section is the core action (copy JSON into settings.json). "What It Shows" sets expectations before the user acts. "How It Works" is a brief explanation of the sentinel file mechanism for users who want to understand session isolation.

**Critical finding: sentinel filename mismatch.**
The `settings.json` status line command reads `/tmp/nefario-status-${CLAUDE_SESSION_ID}`, but SKILL.md writes to `/tmp/nefario-status-${slug}` (where slug is derived from the task description, not the session ID). These are different values. This means the status line as currently configured will never find the sentinel file nefario creates. The documentation must either:
1. Document the *actual* working behavior (using the slug-based filename), requiring a different status line command that scans for any `/tmp/nefario-status-*` file, OR
2. Flag this as a bug to be fixed before documentation ships (either SKILL.md should use `${CLAUDE_SESSION_ID}` or settings.json should match the slug pattern).

This mismatch must be resolved before or alongside the documentation task. Documenting a broken configuration would fail the "under 2 minutes" success criterion because users would follow the steps and see nothing.

### Proposed Tasks

**Task 1: Resolve sentinel filename mismatch** (prerequisite)
- **What**: Determine whether the sentinel file should use `${CLAUDE_SESSION_ID}` (as settings.json expects) or `${slug}` (as SKILL.md currently writes). The original design planning documents (phase2-devx-minion.md in the nefario report history) recommended `${CLAUDE_SESSION_ID}`, but the implementation used `${slug}`.
- **Deliverable**: A decision on which naming scheme is correct, and a fix to whichever file is wrong (either SKILL.md or settings.json). Note: the issue scope says "Out: changes to nefario SKILL.md" -- if the fix needs to go in SKILL.md, this dependency must be escalated.
- **Dependencies**: None. This blocks Task 2.
- **Owner**: devx-minion or the human owner (this is a technical implementation question outside user-docs scope).

**Task 2: Write the status line section in `docs/using-nefario.md`**
- **What**: Add an H2 "Status Line" section at the end of `docs/using-nefario.md` (before the final horizontal rule). Content:
  - **What It Shows**: 1-2 sentences describing the status line display during nefario orchestration (working directory, model, context usage, and nefario task summary). Include a text example of what the status line looks like, e.g.: `/Users/you/project | Claude Opus 4 | Context: 12.3% used | Build MCP server with OAuth...`
  - **Setup**: The `statusLine` JSON block to add to `~/.claude/settings.json`. Present it as a copyable code block. One sentence explaining where to put it (top-level key in settings.json). Note that `jq` must be installed.
  - **How It Works**: 2-3 sentences explaining the mechanism: nefario writes a task summary to a temporary file at orchestration start, the status line command reads it, the file is cleaned up when orchestration ends. Mention that each session is isolated (separate sentinel files prevent cross-session interference). Do NOT explain the slug/session-ID mechanics in detail -- that is implementation detail users do not need.
- **Deliverable**: Updated `docs/using-nefario.md` with the new section.
- **Dependencies**: Task 1 (must know the correct sentinel filename to document the correct `statusLine` command).

**Task 3: Update architecture.md sub-documents table**
- **What**: Check whether the `using-nefario.md` entry in the architecture.md sub-documents table needs its description updated to mention the status line. Current description: "Orchestration workflow, phases, when to use `/nefario` vs `@agent`, tips for success". Consider appending ", status line setup" if the section is substantial enough to warrant mention.
- **Deliverable**: One-line edit to architecture.md, or explicit decision to leave it unchanged.
- **Dependencies**: Task 2.

### Risks and Concerns

**Risk 1 (HIGH): Sentinel filename mismatch breaks the entire guide.**
As detailed above, SKILL.md writes `/tmp/nefario-status-${slug}` but settings.json reads `/tmp/nefario-status-${CLAUDE_SESSION_ID}`. If we document the settings.json command as-is, users will never see nefario status. If we document a glob-based approach (`/tmp/nefario-status-*`), we lose session isolation (one of the success criteria). This must be resolved before the documentation task executes.

**Risk 2 (MEDIUM): settings.json is user-owned, not project-owned.**
The status line configuration lives in `~/.claude/settings.json` (the user's global settings), not in a project file. The guide must make clear this is a one-time global setup, not per-project. It must also warn users who already have a custom `statusLine` configuration that they need to merge, not replace.

**Risk 3 (LOW): jq dependency is not called out.**
The status line command uses `jq` for JSON parsing. If a user does not have `jq` installed, the status line will silently fail. The guide should mention this prerequisite briefly (one line).

**Risk 4 (LOW): Scope says "Out: changes to nefario SKILL.md" but the mismatch may require a SKILL.md fix.**
If the resolution to Risk 1 requires changing SKILL.md, the issue scope needs to be expanded or the fix needs to be tracked separately.

### Additional Agents Needed

**devx-minion**: Required to resolve the sentinel filename mismatch (Task 1). This is a developer experience / tooling question -- whether the sentinel should use `${CLAUDE_SESSION_ID}` or `${slug}` depends on technical constraints of how Claude Code exposes the session ID to shell commands in the status line context versus how nefario generates the slug. The devx-minion who originally designed this mechanism (visible in the nefario report history at `docs/history/nefario-reports/2026-02-10-215954-status-line-task-summary-nefario/phase2-devx-minion.md`) is the right expert to resolve the discrepancy.

No other additional agents needed beyond what is already planned.
