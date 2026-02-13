You are updating docs/orchestration.md to reflect the approved the-plan.md changes.
software-docs-minion is removed from mandatory Phase 3.5 reviewers and replaced
by ux-strategy-minion. Phase 8 no longer merges a Phase 3.5 checklist.

The file is at: `/Users/ben/github/benpeter/2despicable/3/docs/orchestration.md`

## Changes to make

### A. Mandatory reviewer table

Find and replace the software-docs-minion row:

Replace:
```
| software-docs-minion | ALWAYS | Produces documentation impact checklist for Phase 8 (impact assessment, not full review) |
```

With:
```
| ux-strategy-minion | ALWAYS | Every plan needs journey coherence review and simplification audit before execution |
```

### B. Discretionary reviewer table

Remove the ux-strategy-minion row. The table should have 5 rows:
ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion.

### C. Discretionary pool size reference

Search for "6-member" or similar pool size references and update to "5-member".

### D. software-docs-minion exception paragraph

Delete any paragraph about software-docs-minion producing a documentation impact checklist rather than a standard review.

### E. Phase 8 description

Find the Phase 8 description. Replace any text about "merging the Phase 3.5 documentation impact checklist" with a description that says the checklist is generated at the Phase 7-to-8 boundary by evaluating execution outcomes against the outcome-action table. Owner tags and priority are assigned by the orchestrator.

## What NOT to change

- Do NOT modify the mermaid sequence diagram
- Do NOT modify Phase 4-7 descriptions
- Do NOT modify Phase 8 sub-step descriptions (8a, 8b)

## Verification

After making changes:
1. Search for "software-docs-minion" -- should not appear in Phase 3.5 context. May still appear in Phase 8 sub-step descriptions.
2. Search for "Phase 3.5 checklist" or "merge" in Phase 8 context -- should not appear.
3. Verify ux-strategy-minion is in mandatory table.
4. Verify discretionary table has 5 rows.

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
