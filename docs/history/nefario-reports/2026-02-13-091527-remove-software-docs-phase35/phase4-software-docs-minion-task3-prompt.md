You are updating nefario/AGENT.md to reflect the approved the-plan.md changes.
software-docs-minion is removed from mandatory Phase 3.5 reviewers and replaced
by ux-strategy-minion.

The file is at: `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`

## Changes to make

### A. Architecture Review Agents synthesis template

Find the line that lists mandatory reviewers (looks like):
```
- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
```

Change to:
```
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
```

### B. Mandatory reviewer table

Find and replace the software-docs-minion row in the mandatory reviewer table:

Replace:
```
| **software-docs-minion** | ALWAYS | Produces documentation impact checklist consumed by Phase 8. Role is scoped to impact assessment, not full documentation review. |
```

With:
```
| **ux-strategy-minion** | ALWAYS | Every plan needs journey coherence review and simplification audit before execution. |
```

### C. Discretionary reviewer table

Remove the ux-strategy-minion row from the discretionary table. The table should have 5 rows:
ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion.

### D. software-docs-minion exception paragraph

Delete the entire paragraph that starts with "**software-docs-minion exception**:" -- this describes the special checklist role that no longer exists.

## What NOT to change

- Do NOT modify any other sections of AGENT.md
- Do NOT change the YAML frontmatter
- The mandatory count stays at 5
- Do NOT add a ux-strategy-minion exception paragraph

## Verification

After making changes:
1. Search for "software-docs-minion" in Phase 3.5 context -- should not appear
2. Verify ux-strategy-minion appears in mandatory table and synthesis template
3. Verify discretionary table has 5 rows (no ux-strategy-minion)
4. Verify the exception paragraph is deleted

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
