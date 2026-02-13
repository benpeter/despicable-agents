You are modifying `nefario/AGENT.md` to fix a team assembly gap: when tasks involve modifying agent system prompts (AGENT.md files) or orchestration rules (SKILL.md, CLAUDE.md), ai-modeling-minion is not included in Phase 1 team assembly because the delegation table has no matching entry.

## What to do

### 1. Add two rows to the delegation table

In `nefario/AGENT.md`, find the delegation table under `## Delegation Table`. In the **Intelligence** section (after the existing "LLM cost optimization" row and before "Technology radar assessment"), add these two rows:

```
| Agent system prompt modification (AGENT.md) | ai-modeling-minion | lucy |
| Orchestration rule changes (SKILL.md, CLAUDE.md) | ai-modeling-minion | ux-strategy-minion |
```

These entries ensure that when a task involves editing agent behavioral specs or orchestration workflows, ai-modeling-minion is routed as primary during META-PLAN.

### 2. Add a File-Domain Awareness principle to Task Decomposition Principles

In the same file, find the `## Task Decomposition Principles` section. After the existing principles ("The 100% Rule", "Decomposition Approach", "File Ownership", "Dependency Types"), add a new principle:

```markdown
**File-Domain Awareness**: When analyzing which domains a task involves, consider the semantic nature of the files being modified, not just their extension. Agent definition files (AGENT.md), orchestration rules (SKILL.md), domain research (RESEARCH.md), and project instructions (CLAUDE.md) are prompt engineering and multi-agent architecture artifacts. Changes to these files should route through ai-modeling-minion. Documentation files (README.md, docs/*.md, changelogs) route through software-docs-minion or user-docs-minion.
```

### 3. Update the Phase 5 summary in Post-Execution Phases section

In the `## Post-Execution Phases (5-8)` section, update the Phase 5 bullet from:
```
- **Phase 5: Code Review** -- Runs when Phase 4 produced code.
```
to:
```
- **Phase 5: Code Review** -- Runs when Phase 4 produced code or logic-bearing markdown (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md).
```

## What NOT to do

- Do NOT add the full classification definition to AGENT.md. The canonical definition lives in SKILL.md (a separate task handles that). AGENT.md gets vocabulary alignment only.
- Do NOT modify the-plan.md. It is a protected file.
- Do NOT add more than two delegation table rows. The existing "LLM prompt design" and "Multi-agent architecture" rows already cover new-from-scratch prompt work. These two new rows cover *modification* of existing agent/orchestration files.
- Do NOT add content heuristics or elaborate classification logic. Keep it to named files and a brief principle.

## File to modify

`/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`

## Context

The delegation table is at lines 106-197. Task Decomposition Principles section follows later in the file. Post-Execution Phases section is around line 757.

The same delegation table exists in `the-plan.md` but must not be modified. The PR description will note the divergence for the human owner.

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
