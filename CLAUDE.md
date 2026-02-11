# despicable-agents

Specialist agent team for Claude Code. 27 agents organized as Gru (boss),
Nefario (orchestrator), Lucy and Margo (governance), and 23 domain-specialist minions.

## Structure

- `the-plan.md` -- canonical spec for all agents (source of truth, human-edited)
- `docs/` -- architecture and design documentation (see [docs/architecture.md](docs/architecture.md))
- `skills/nefario/` -- nefario orchestration skill (symlinked to `~/.claude/skills/nefario`)
- `skills/despicable-prompter/` -- briefing coach skill (symlinked to `~/.claude/skills/despicable-prompter`)
- `/despicable-lab` -- project-local skill to check and rebuild agents (`.claude/skills/despicable-lab/`)
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
- **Never delete remote branches** -- do not delete branches on origin, not even after merging PRs
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

### Session Output Discipline

During nefario-orchestrated sessions, minimize tool output noise:

- **Git commands**: Use `--quiet` on `commit`, `push`, and `pull`. Do not use `--no-verify`.
- **Bash commands** producing expected verbose output: When the output is not
  needed for decision-making, pipe through `| tail -2` on success (use
  `set -o pipefail` to preserve exit codes). Show last 10 lines on error
  for debugging context.
- **Read tool**: Use `offset` and `limit` parameters to read only what is needed.
  Do not read entire large files when a section suffices.
- **Write/Edit tools**: Output is already concise. No additional truncation needed.

These conventions apply only during orchestrated sessions (invoked via `/nefario`).
Single-agent sessions and subagents are not affected.
See `skills/nefario/SKILL.md` Communication Protocol for the full orchestration
output specification.

## Versioning

Each agent spec in `the-plan.md` has a `spec-version`. Each built `AGENT.md`
has `x-plan-version` in its frontmatter. When they diverge, use `/despicable-lab` to regenerate.

## Deployment

```bash
./install.sh  # Symlinks 27 agents and 2 skills (/nefario, /despicable-prompter) to ~/.claude/
```

## Orchestration Reports

After completing nefario orchestration (conversations involving META-PLAN or SYNTHESIS phases),
generate an execution report following the format defined in the nefario skill (`skills/nefario/SKILL.md`).
The report index is regenerated automatically by CI on push to main.
