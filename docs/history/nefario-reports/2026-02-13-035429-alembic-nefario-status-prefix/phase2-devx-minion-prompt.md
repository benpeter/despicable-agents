You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

<github-issue>
**Outcome**: Nefario prepends the alembic symbol (⚗️) to its status line display and all user-facing messages during orchestration sessions, giving it a distinctive visual identity that users instantly associate with "nefario is orchestrating."

**Success criteria**:
- Status line entry includes ⚗️ prefix (using text variant ⚗︎ where monospace alignment matters)
- All nefario phase announcements and user-facing messages are prefixed with ⚗️
- Symbol renders correctly in macOS Terminal, VS Code integrated terminal, and iTerm2
- No alignment or double-width issues in the Claude Code status line

**Scope**:
- In: Nefario skill (SKILL.md), nefario agent (AGENT.md), status line config (despicable-statusline skill)
- Out: Other agents' messaging, emoji/symbols for lucy/margo/minions, terminal compatibility testing beyond macOS

**Constraints**:
- Symbol is ⚗️ (U+2697, Alembic) — decided via team brainstorm with lucy, ux-strategy-minion, ux-design-minion
- Use text variant selector (⚗︎ / U+2697 U+FE0E) in monospace/status-line contexts to avoid 2-cell width
</github-issue>

## Your Planning Question

The alembic symbol (U+2697) needs to render correctly in the Claude Code status line (monospace terminal context). The issue specifies using text variant selector (U+FE0E) for monospace/status-line contexts to avoid double-width rendering. Where exactly should the variant selector be applied vs. the emoji presentation? Specifically: (a) In the `/tmp/nefario-status-$SID` file content written by `echo` in bash, should the symbol include U+FE0E? (b) In markdown phase announcements rendered by Claude Code's UI, should it use the emoji variant or text variant? (c) What is the correct bash syntax to echo a string containing U+2697 U+FE0E reliably across macOS terminals? Review the existing status line shell snippet in `.claude/skills/despicable-statusline/SKILL.md` and advise on the integration approach.

## Context

Key files to review:
- `.claude/skills/despicable-statusline/SKILL.md` — how the status line is configured and consumed
- `skills/nefario/SKILL.md` — contains status file echo patterns (e.g., `echo "P1 Meta-Plan | $summary" > /tmp/nefario-status-$SID`)
- `nefario/AGENT.md` — nefario agent definition
- Target terminals: macOS Terminal, VS Code integrated terminal, iTerm2

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: devx-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase2-devx-minion.md`
