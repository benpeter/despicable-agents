## Meta-Plan

### Task Analysis

The task is to add the alembic symbol (U+2697) as a visual prefix to nefario's
status line and all user-facing messages during orchestration. This touches
three files:

1. **`skills/nefario/SKILL.md`** -- The orchestration skill. Contains:
   - 7 `echo "P<N> ... | $summary"` status file writes (lines 367, 580, 654, 730, 1184, 1314, 1331)
   - 6 phase announcement templates `**--- Phase N: Name ---**` (lines 185-189, template at 181)
   - 12+ AskUserQuestion `header` values ("P1 Team", "P3.5 Review", "P4 Gate", etc.)
   - CONDENSE line templates (lines 159, 165, 170, 171)
   - Various inline user-facing strings
2. **`nefario/AGENT.md`** -- The nefario agent file. Its system prompt does not
   produce status line messages directly (it returns plans, not status), but
   any user-facing output format templates it defines need the prefix.
3. **`.claude/skills/despicable-statusline/SKILL.md`** -- The statusline
   configuration skill. The shell snippet that reads `/tmp/nefario-status-$SID`
   and appends it to `$result`. The symbol may need to be part of the status
   file content, or prepended by the statusline reader.

The task is primarily a text-editing task across markdown files with careful
attention to Unicode rendering (U+2697 with/without variant selectors) in
terminal contexts.

### Planning Consultations

#### Consultation 1: Status line Unicode rendering strategy

- **Agent**: devx-minion
- **Planning question**: The alembic symbol (U+2697) needs to render correctly in the Claude Code status line (monospace terminal context). The issue specifies using text variant selector (U+FE0E) for monospace/status-line contexts to avoid double-width rendering. Where exactly should the variant selector be applied vs. the emoji presentation? Specifically: (a) In the `/tmp/nefario-status-$SID` file content written by `echo` in bash, should the symbol include U+FE0E? (b) In markdown phase announcements rendered by Claude Code's UI, should it use the emoji variant or text variant? (c) What is the correct bash syntax to echo a string containing U+2697 U+FE0E reliably across macOS terminals? Review the existing status line shell snippet in `.claude/skills/despicable-statusline/SKILL.md` and advise on the integration approach.
- **Context to provide**: The despicable-statusline SKILL.md (full file), the status file echo patterns from `skills/nefario/SKILL.md` (lines 365-368, 577-581), and the constraint that targets are macOS Terminal, VS Code integrated terminal, and iTerm2.
- **Why this agent**: devx-minion owns CLI design, terminal output, and developer-facing configuration. Unicode rendering in terminal status lines is squarely in their domain.

### Cross-Cutting Checklist

- **Testing**: Exclude from planning. The task produces no executable code -- only markdown template changes and shell echo strings. Terminal rendering is verified visually per the success criteria, not via automated tests. Phase 6 will discover no test changes and skip.
- **Security**: Exclude from planning. No new attack surface, no auth changes, no user input processing. The changes are purely cosmetic string prefixes in markdown and shell echo statements.
- **Usability -- Strategy**: Include. The alembic symbol IS the UX of this task -- it creates a visual identity for nefario orchestration sessions. ux-strategy-minion should advise on consistency of application (which messages get the prefix, which do not) and cognitive load implications.
  - **Planning question**: The alembic symbol will prefix nefario's status line, phase announcements, and user-facing messages. Review the full set of user-facing nefario outputs (phase markers, CONDENSE lines, AskUserQuestion headers, gate briefs) and advise: should ALL of these get the prefix, or only a subset? What is the right balance between "distinctive identity" and "visual noise"? Consider that users see these messages in a fast-scrolling terminal during multi-phase orchestrations.
- **Usability -- Design**: Exclude from planning. There are no UI components, visual layouts, or HTML being produced. This is terminal text output. The symbol choice (alembic) is already decided per the issue constraints.
- **Documentation**: Include. software-docs-minion should assess documentation impact.
  - **Planning question**: The nefario SKILL.md and AGENT.md are being modified to add a symbol prefix. Are there other documentation files (README, docs/architecture.md, the-plan.md) that reference nefario's output format and would need updating for consistency? Identify any documentation that quotes nefario phase markers or status line format verbatim.
- **Observability**: Exclude from planning. No runtime components, no services, no logging/metrics/tracing changes. The status file is a simple `/tmp` sentinel, not an observability system.

### Anticipated Approval Gates

None anticipated. All changes are:
- Easy to reverse (additive string prefixes in markdown/shell)
- Low blast radius (the three files are self-contained; no downstream build or code depends on the exact prefix text)
- Clear best practice (the symbol is already decided, placement is mechanical)

This falls squarely in the "NO GATE" quadrant (easy to reverse + low blast radius). The execution plan will likely have 0 gates.

### Rationale

This task is narrow in scope but requires precision across multiple files. The
two planning consultations target the only areas of genuine judgment:

1. **devx-minion**: How to correctly render U+2697 with variant selectors in
   terminal shell commands. Getting the Unicode encoding wrong would cause
   alignment issues in the status line -- the primary risk in this task.

2. **ux-strategy-minion** (cross-cutting, mandatory): Which user-facing outputs
   should carry the prefix. The issue says "all user-facing messages" but there
   are multiple categories (status file, phase markers, gate headers, CONDENSE
   lines) with different visibility and frequency. A UX perspective prevents
   over-application that creates visual noise.

3. **software-docs-minion** (cross-cutting, mandatory): Impact assessment for
   documentation that may quote nefario output formats.

No other specialists add planning value. The actual changes are mechanical
string insertions once the strategy is decided.

### Scope

**In scope**:
- Adding alembic prefix to nefario status file writes (`/tmp/nefario-status-$SID`)
- Adding alembic prefix to phase announcement markers (`**--- Phase N: Name ---**`)
- Adding alembic prefix to AskUserQuestion headers
- Adding alembic prefix to CONDENSE lines
- Updating despicable-statusline skill if the status snippet needs changes
- Updating nefario AGENT.md if it contains user-facing output templates

**Out of scope**:
- Other agents' messaging or symbols
- Emoji/symbols for lucy, margo, or minions
- Terminal compatibility testing beyond macOS
- Changing the symbol itself (U+2697 is a constraint, not a decision)
- Modifying `the-plan.md` (per CLAUDE.md rules)

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent rebuilding from specs | Not relevant -- no agent spec changes in `the-plan.md` |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line configuration | Relevant as reference -- the status line shell snippet defines how `/tmp/nefario-status-$SID` is consumed. Changes may be needed to prepend the symbol at the reader level rather than the writer level. Include as available skill for the execution task that modifies status line integration. |
| despicable-prompter | `skills/despicable-prompter/` | LEAF | Task briefing generation | Not relevant to this task |
| nefario | `skills/nefario/` | ORCHESTRATION | Multi-agent orchestration | This IS the file being modified. Not used as a skill during execution -- it is the edit target. |

User-global skills (non-despicable-agents): `juli` -- personal journal skill. Not relevant.

#### Precedence Decisions

No precedence conflicts. `despicable-statusline` is a reference/resource for the execution task, not a competing specialist. The execution agent will read it to understand the shell snippet format but will edit the SKILL.md files directly (not invoke the skill).
