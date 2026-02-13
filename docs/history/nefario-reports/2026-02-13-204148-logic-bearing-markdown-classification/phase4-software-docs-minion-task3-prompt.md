You are updating two documentation files to reflect a new classification boundary for logic-bearing markdown files. The canonical definition is now in `skills/nefario/SKILL.md` at the Phase 5 skip conditional. Your job is vocabulary alignment and a decision record -- NOT duplicating the full definition.

## What to do

### 1. Update docs/orchestration.md Phase 5 description

File: `/Users/ben/github/benpeter/2despicable/3/docs/orchestration.md`

Find the Phase 5 description line that says something like:
```
Runs when Phase 4 produced or modified code files. Skipped if Phase 4 produced only documentation or configuration.
```

Replace with:
```
Runs when Phase 4 produced or modified code or logic-bearing markdown files (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md). Skipped if Phase 4 produced only documentation-only files (README, docs/, changelogs).
```

### 2. Add decision entry to docs/decisions.md

File: `/Users/ben/github/benpeter/2despicable/3/docs/decisions.md`

Add Decision 30 after the last existing entry. Follow the existing format:

```markdown
### Decision 30: Logic-Bearing Markdown Classification

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-13 |
| **Choice** | Classify markdown files as logic-bearing or documentation-only based on filename conventions. AGENT.md, SKILL.md, RESEARCH.md, and CLAUDE.md are logic-bearing. README.md, docs/*.md, and changelogs are documentation-only. Logic-bearing files are treated as code for Phase 5 review and team assembly purposes. |
| **Alternatives rejected** | (1) Extension-based classification (.md = documentation). Rejected because system prompts and orchestration rules use .md extension but are functionally code. (2) Content-analysis heuristics (scan for YAML frontmatter, prompt patterns). Rejected because it is fragile, adds prompt complexity, and produces inconsistent results across sessions. |
| **Rationale** | In an LLM agent system, system prompts ARE the code. AGENT.md files control agent behavior, SKILL.md files control orchestration workflow, RESEARCH.md informs prompt content. Extension-based classification caused Phase 5 code review to be skipped for these files and ai-modeling-minion to be excluded from team assembly. Filename-based classification is deterministic, compact, and matches the project's existing naming conventions. |
| **Consequences** | Phase 5 code review now runs for changes to logic-bearing markdown. ai-modeling-minion is included in team assembly for agent/orchestration file modifications. Classification boundary is documented at the Phase 5 skip conditional in SKILL.md. The delegation table in nefario/AGENT.md diverges from the-plan.md (flagged for human owner reconciliation). |
```

## What NOT to do

- Do NOT duplicate the full classification table from SKILL.md. Reference docs get vocabulary alignment only.
- Do NOT modify the-plan.md. It is a protected file. The divergence is noted in Decision 30's Consequences.
- Do NOT modify SKILL.md or AGENT.md -- those are handled by other tasks.
- Do NOT create new documentation files. All changes go into existing files.
- Do NOT modify docs/agent-anatomy.md (dropped per advisory review).

## Files to modify

- `/Users/ben/github/benpeter/2despicable/3/docs/orchestration.md`
- `/Users/ben/github/benpeter/2despicable/3/docs/decisions.md`

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
