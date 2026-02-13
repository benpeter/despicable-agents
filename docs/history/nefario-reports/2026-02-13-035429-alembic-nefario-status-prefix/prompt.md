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
