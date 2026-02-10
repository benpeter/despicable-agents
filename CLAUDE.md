# despicable-agents

Specialist agent team for Claude Code. 27 agents organized as Gru (boss),
Nefario (orchestrator), Lucy and Margo (governance), and 23 domain-specialist minions.

## Structure

- `the-plan.md` -- canonical spec for all agents (source of truth, human-edited)
- `docs/` -- architecture and design documentation (see [docs/architecture.md](docs/architecture.md))
- `skills/nefario/` -- nefario orchestration skill (symlinked to `~/.claude/skills/nefario`)
- `/despicable-lab` -- project-local skill to check and rebuild agents (`.claude/skills/despicable-lab/`)
- `/despicable-prompter` -- project-local skill to coach intent-focused `/nefario` briefings (`.claude/skills/despicable-prompter/`)
- `gru/` -- AI visionary / technology radar
- `nefario/` -- task orchestrator (planning only, does not write code)
- `lucy/` -- governance (consistency, intent alignment)
- `margo/` -- governance (simplicity, YAGNI/KISS)
- `minions/*/` -- domain specialists (23 agents across 7 groups)

Each agent directory contains:
- `AGENT.md` -- deployable agent file (YAML frontmatter + system prompt)
- `RESEARCH.md` -- domain research backing the system prompt

## Key Rules

- **Do NOT modify `the-plan.md`** unless you are the human owner or the human owner approves you making changes
- All artifacts in **English**
- **No PII**, no proprietary data -- agents must remain publishable (Apache 2.0)
- Agent boundaries are strict: check "Does NOT do" sections for handoff points

## Engineering Philosophy

This project follows the [Helix Manifesto](https://github.com/adobe/helix-home/blob/main/manifesto.md).
Key principles that apply to all work here:

- **YAGNI** -- don't build it until you need it. No speculative features.
- **KISS** -- simple beats elegant. If it's hard to explain, it's too complicated.
- **Lean and Mean** -- minimize code and dependencies actively. Fewer lines, fewer deps, fewer moving parts.
- **Ops reliability wins** -- simple, fast, and up beats elegant.
- **More code, less blah, blah** -- prioritize working code and commits over lengthy discussion.
- **Intuitive, Simple & Consistent** -- in that priority order.
- **Latency is not an option** -- uncached things are fast. <300ms fast. Always.
- **Prefer lightweight, vanilla solutions** -- vanilla JS/CSS/HTML over frameworks
  unless a framework adds specific, demonstrable value.
  Don't default to React, Vue, Tailwind CSS, jQuery, etc. just because they're popular.
  Always ask: "What does this dependency give me that I can't do simply without it?"

## Versioning

Each agent spec in `the-plan.md` has a `spec-version`. Each built `AGENT.md`
has `x-plan-version` in its frontmatter. When they diverge, use `/despicable-lab` to regenerate.

## Deployment

```bash
./install.sh  # Symlinks all agents to ~/.claude/agents/ and /nefario skill to ~/.claude/skills/
```

## Orchestration Reports

After completing nefario orchestration (conversations involving META-PLAN or SYNTHESIS phases),
generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md` and
regenerate the index by running `docs/history/nefario-reports/build-index.sh`.
