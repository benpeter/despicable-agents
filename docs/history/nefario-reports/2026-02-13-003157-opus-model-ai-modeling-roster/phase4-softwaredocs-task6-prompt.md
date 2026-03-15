After the spec and delegation table changes have been made to the-plan.md, review the following documentation files for staleness and update any references that have become inaccurate.

Note: This task was reassigned from lucy to software-docs-minion per lucy's governance review — lucy's "Does NOT do" says "writing code or documentation (-> appropriate minion)."

## Files to check

1. `/Users/ben/github/benpeter/2despicable/4/docs/agent-catalog.md` -- May reference iac-minion's capabilities or margo's complexity budget. Update if it lists remit items that changed.
2. `/Users/ben/github/benpeter/2despicable/4/docs/orchestration.md` -- May contain delegation-related content or routing references. Update if it duplicates or references specific delegation table entries.
3. `/Users/ben/github/benpeter/2despicable/4/docs/architecture.md` -- Hub document. Check if it needs a reference to the new docs/claudemd-template.md.
4. `/Users/ben/github/benpeter/2despicable/4/docs/deployment.md` -- Check if deployment-related content needs updating given the expanded iac-minion scope.

## What to do

For each file:
1. Read the file
2. Identify any content that references iac-minion capabilities, margo's complexity budget, edge-minion's scope, or delegation routing that would now be stale
3. Make minimal, surgical updates to fix staleness
4. If a file needs no changes, skip it
5. If docs/architecture.md exists, add a reference to docs/claudemd-template.md in the appropriate section

## What NOT to do

- Do not rewrite documentation beyond what is needed for accuracy
- Do not add new documentation sections
- Do not modify the-plan.md or any AGENT.md files

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
