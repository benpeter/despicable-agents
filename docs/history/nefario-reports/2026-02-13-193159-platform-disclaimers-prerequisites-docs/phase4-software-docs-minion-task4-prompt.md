Add a row for `docs/prerequisites.md` to the User-Facing sub-documents
table in `docs/architecture.md`.

## Context

The sub-documents table in `docs/architecture.md` currently has two
User-Facing rows under the "### User-Facing" heading.

## Change to Make

Add a new row as the FIRST row in the User-Facing table (before "Using
Nefario"), since prerequisites logically come first in a reader's journey:

```markdown
| [Prerequisites](prerequisites.md) | Required CLI tools, per-platform installation, setup verification |
```

The table should become:

```markdown
### User-Facing

| Document | Covers |
|----------|--------|
| [Prerequisites](prerequisites.md) | Required CLI tools, per-platform installation, setup verification |
| [Using Nefario](using-nefario.md) | Orchestration workflow, phases, when to use `/nefario` vs `@agent`, tips for success |
| [Agent Catalog](agent-catalog.md) | Per-agent capabilities, model tiers, example invocations, boundaries |
```

## Boundaries

- Do NOT modify the Contributor / Architecture table
- Do NOT modify any other content in architecture.md
- This is a single-line addition

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
