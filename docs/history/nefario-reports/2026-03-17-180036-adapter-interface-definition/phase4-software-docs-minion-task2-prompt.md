Make two small edits to link the new `docs/adapter-interface.md` into the existing documentation structure.

## Working Directory

/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness

## Edit 1: `docs/architecture.md`

In the "Contributor / Architecture" table, add a new row for the adapter interface document. Add it after the "External Harness Roadmap" row:

```
| [Adapter Interface](adapter-interface.md) | DelegationRequest/DelegationResult type definitions, adapter behavioral contract |
```

## Edit 2: `docs/external-harness-roadmap.md`

In the Issue 1.1 section, after the "Acceptance criteria" list, add:

```
**Specification**: [docs/adapter-interface.md](adapter-interface.md)
```

This creates a forward pointer from the roadmap issue to the delivered specification.

## What NOT to Do

- Do NOT modify `docs/adapter-interface.md`
- Do NOT modify any other files
- Do NOT change existing content in either file -- only add the specified lines
