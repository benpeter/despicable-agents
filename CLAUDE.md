# despicable-agents

Specialist agent team for Claude Code. 19 agents organized as Gru (boss),
Nefario (orchestrator), and 17 domain-specialist minions.

## Structure

- `the-plan.md` -- canonical spec for all agents (source of truth, human-edited)
- `docs/` -- architecture and design documentation (see [docs/architecture.md](docs/architecture.md))
- `skills/nefario/` -- nefario orchestration skill (symlinked to `~/.claude/skills/nefario`)
- `/lab` -- project-local skill to check and rebuild agents (`.claude/skills/lab/`)
- `gru/` -- AI visionary / technology radar
- `nefario/` -- task orchestrator (planning only, does not write code)
- `minions/*/` -- domain specialists (17 agents across 6 groups)

Each agent directory contains:
- `AGENT.md` -- deployable agent file (YAML frontmatter + system prompt)
- `RESEARCH.md` -- domain research backing the system prompt

## Key Rules

- **Do NOT modify `the-plan.md`** unless you are the human owner or the human owner approves you making changes
- All artifacts in **English**
- **No PII**, no proprietary data -- agents must remain publishable (Apache 2.0)
- Agent boundaries are strict: check "Does NOT do" sections for handoff points

## Technology Preferences

- **Prefer lightweight, vanilla solutions** -- vanilla JS/CSS/HTML over frameworks
  unless a framework adds specific, demonstrable value.
- For example, don't default to React, Vue, Tailwind CSS, jQuery, etc. just because they're popular.
- Always ask: "What does this dependency give me that I can't do simply without it?"

## Versioning

Each agent spec in `the-plan.md` has a `spec-version`. Each built `AGENT.md`
has `x-plan-version` in its frontmatter. When they diverge, use `/lab` to regenerate.

## Deployment

```bash
./install.sh  # Symlinks all agents to ~/.claude/agents/ and /nefario skill to ~/.claude/skills/
```

## Orchestration Reports

After completing nefario orchestration (conversations involving META-PLAN or SYNTHESIS phases),
generate an execution report following the template at `nefario/reports/TEMPLATE.md` and update
the index at `nefario/reports/index.md`.
