# despicable-agents

Specialist agent team for Claude Code. 19 agents organized as Gru (boss),
Nefario (orchestrator), and 17 domain-specialist minions.

## Structure

- `the-plan.md` -- canonical spec for all agents (source of truth, human-edited)
- `/lab` -- project-local skill to check and rebuild agents (`.claude/skills/lab/`)
- `gru/` -- AI visionary / technology radar
- `nefario/` -- task orchestrator (planning only, does not write code)
- `minions/*/` -- domain specialists (17 agents across 6 groups)

Each agent directory contains:
- `AGENT.md` -- deployable agent file (YAML frontmatter + system prompt)
- `RESEARCH.md` -- domain research backing the system prompt

## Key Rules

- **Do NOT modify `the-plan.md`** unless you are the human owner
- All artifacts in **English**
- **No PII**, no proprietary data -- agents must remain publishable (Apache 2.0)
- Agent boundaries are strict: check "Does NOT do" sections for handoff points

## Versioning

Each agent spec in `the-plan.md` has a `spec-version`. Each built `AGENT.md`
has `x-plan-version` in its frontmatter. When they diverge, use `/lab` to regenerate.

## Deployment

```bash
# Symlink all agents to ~/.claude/agents/
for agent in gru/AGENT.md nefario/AGENT.md; do
  name=$(basename $(dirname "$agent"))
  ln -sf "$(realpath "$agent")" ~/.claude/agents/"$name".md
done
for agent in minions/*/AGENT.md; do
  name=$(basename $(dirname "$agent"))
  ln -sf "$(realpath "$agent")" ~/.claude/agents/"$name".md
done
```
