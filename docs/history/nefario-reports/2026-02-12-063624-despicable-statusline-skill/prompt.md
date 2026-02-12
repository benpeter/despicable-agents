**Outcome**: A `/despicable-statusline` skill that configures the user's Claude Code status line to include nefario orchestration phase as the last element. The skill reads the user's existing status line config, preserves everything as-is, and appends the nefario status snippet that reads from `/tmp/nefario-status-$sid`. Users who don't have a status line yet get a sensible default plus the nefario element.

**Success criteria**:
- Existing status line config is fully preserved (no elements changed, reordered, or removed)
- Nefario status is appended as the very last `| $ns` element
- If the nefario snippet is already present, the skill is a no-op (idempotent)
- If no status line is configured yet, a reasonable default is created with nefario status appended
- Skill follows existing extension pattern (lives in claude-skills repo, symlinked to ~/.claude/skills/)

**Scope**:
- In: Skill definition that modifies ~/.claude/settings.json statusLine config
- Out: Changes to the /tmp/nefario-status write mechanism, changes to nefario's SKILL.md, statusline script styling
