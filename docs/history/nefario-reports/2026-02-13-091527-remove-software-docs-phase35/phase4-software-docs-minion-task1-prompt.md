You are updating the-plan.md to reflect two changes: (1) software-docs-minion
is removed from mandatory Phase 3.5 reviewers and replaced by ux-strategy-minion,
and (2) Phase 8 self-derives its documentation checklist from execution outcomes
only (no Phase 3.5 checklist input).

## What to change

The file is at: `/Users/ben/github/benpeter/2despicable/3/the-plan.md`

### Change 1: Phase 3.5 invocation model description (~line 178-186)

Replace the Phase 3.5 description to swap software-docs-minion for ux-strategy-minion in the mandatory list, remove ux-strategy-minion from the discretionary list, and delete the sentence about software-docs-minion producing a documentation impact checklist.

### Change 2: Mandatory reviewers table (~line 461-469)

Replace the software-docs-minion row with:
| ux-strategy-minion | ALWAYS | Every plan needs journey coherence review and simplification audit before execution |

### Change 3: Discretionary reviewers table (~line 471-480)

Remove the ux-strategy-minion row. The table should have 5 rows:
ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion.

### Change 4: Phase 8 description (~line 247-249)

Verify the Phase 8 description doesn't reference "Phase 3.5 checklist" or "merge". The current text already describes self-derivation from execution outcomes, so this may need no change. If there is any reference to Phase 3.5 checklist, remove it.

### Change 5: Pool size references

Search for "6-member pool" or similar pool size references that should now be "5-member pool" due to ux-strategy-minion moving to mandatory.

## What NOT to change

- Do NOT modify any agent specs (everything below the agent specs section)
- Do NOT modify the delegation table, cross-cutting checklist, working patterns, or any section outside Phase 3.5 and Phase 8
- Do NOT add new rows to the outcome-action table
- Do NOT modify the model selection section

## Deliverables

Updated `/Users/ben/github/benpeter/2despicable/3/the-plan.md` with exactly the changes above.

## Verification

After making changes, search the-plan.md for "software-docs-minion" and verify it does NOT appear in any Phase 3.5-related context. It should still appear in agent specs, the delegation table, Phase 8 sub-steps, and other non-Phase-3.5 contexts. Also verify "6-member pool" does not appear.

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
