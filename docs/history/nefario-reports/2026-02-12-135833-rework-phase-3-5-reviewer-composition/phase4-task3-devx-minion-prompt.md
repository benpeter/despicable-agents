You are updating the nefario SKILL.md Phase 8 documentation section to consume
the Phase 3.5 documentation impact checklist as input.

## What to Do

Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`.
Make these changes to Phase 8 (starts at line ~1251 -- NOTE: line numbers may
have shifted due to Task 2 edits above; search for "#### Phase 8: Documentation"
to find the correct location):

### A. Replace step 1 "Generate checklist" with merge logic

Replace the current step 1 (the "Generate checklist" section with the
outcome-action table) with:

```markdown
1. **Merge documentation checklist** from Phase 3.5 and execution outcomes:

   a. **Read Phase 3.5 checklist**: If `$SCRATCH_DIR/{slug}/phase3.5-docs-checklist.md`
      exists, read it as the starting checklist. These items were identified
      from the plan before execution and have owner tags ([software-docs] or
      [user-docs]), scope, file paths, and priority already assigned.

   b. **Supplement with execution outcomes**: Evaluate execution outcomes
      against the outcome-action table below. For each outcome, check whether
      the Phase 3.5 checklist already covers it. If not, add a new item.

      | Outcome | Action | Owner |
      |---------|--------|-------|
      | New API endpoints | API reference, OpenAPI prose | software-docs-minion |
      | Architecture changed | C4 diagrams, component docs | software-docs-minion |
      | Gate-approved decision | ADR | software-docs-minion |
      | New user-facing feature | Getting-started / how-to | user-docs-minion |
      | New CLI command/flag | Usage docs | user-docs-minion |
      | User-visible bug fix | Release notes | user-docs-minion |
      | README not updated | README review | software-docs + product-marketing |
      | New project (git init) | Full README (blocking) | software-docs + product-marketing |
      | Breaking change | Migration guide | user-docs-minion |
      | Config changed | Config reference | software-docs-minion |

   c. **Flag divergence**: For items in the Phase 3.5 checklist that do not
      correspond to any execution outcome, mark them as: "Planned but not
      implemented -- verify if still needed."

   Write the merged checklist to: `$SCRATCH_DIR/{slug}/phase8-checklist.md`
```

### B. Update step 3 agent prompts (sub-step 8a)

Find the sub-step 8a section (spawning software-docs-minion + user-docs-minion).
Update the text to reference the merged checklist with owner tags:

```markdown
3. **Sub-step 8a** (parallel): spawn software-docs-minion + user-docs-minion
   with their respective checklist items and paths to execution artifacts.

   Each agent's prompt should reference:
   - Work order: `$SCRATCH_DIR/{slug}/phase8-checklist.md`
   - Items tagged with their owner ([software-docs] or [user-docs])
   - Note: Items from Phase 3.5 are pre-analyzed with scope and file paths.
     Execution-derived items may need the agent to inspect changed files for
     full scope.
```

### C. Keep everything else unchanged

Steps 2, 4, 5, 6 remain unchanged. The outcome-action table is retained
(moved into step 1b as supplementation source, not replaced). Sub-step 8b
(product-marketing-minion) is unchanged.

## What NOT to Do

- Do NOT remove the outcome-action table -- it becomes the supplementation
  source for execution-discovered items
- Do NOT modify sub-step 8b (product-marketing-minion)
- Do NOT modify Phase 5, 6, or 7
- Do NOT modify any section outside Phase 8

## Context

- The Phase 3.5 checklist is produced by software-docs-minion during
  architecture review (Task 2 of this plan)
- The checklist is a prediction (based on the plan). Phase 8's execution-outcome
  table is ground truth. Phase 8 unions both.
- If Phase 3.5 was skipped ("Skip review" at the reviewer gate), the
  phase3.5-docs-checklist.md file will not exist. The merge logic handles
  this: step 1a says "if exists" -- if it does not, Phase 8 falls back to
  generating the checklist entirely from execution outcomes (current behavior).

## Deliverables

Updated `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`
Phase 8 section with merge logic.

## Success Criteria

- Phase 8 reads phase3.5-docs-checklist.md if it exists
- Phase 8 supplements (not replaces) with execution-outcome items
- Outcome-action table is preserved as supplementation source
- Divergence flagging is present for planned-but-not-implemented items
- Graceful fallback when phase3.5-docs-checklist.md does not exist

When you finish your task, mark it completed with TaskUpdate and send a message
to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
