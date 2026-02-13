You are updating skills/nefario/SKILL.md to reflect the approved the-plan.md
changes. software-docs-minion is removed from mandatory Phase 3.5 reviewers
and replaced by ux-strategy-minion. Phase 8 no longer merges a Phase 3.5
checklist -- it self-derives entirely from execution outcomes.

The file is at: `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

## Changes to make

### A. Mandatory reviewer list (search for "Mandatory" in the Phase 3.5 section)

Remove software-docs-minion from the mandatory list and add ux-strategy-minion.
The mandatory list should be: security-minion, test-minion, ux-strategy-minion, lucy, margo.
Note: software-docs-minion was listed with a special note about its checklist role. Replace
with ux-strategy-minion (no special note needed -- it uses a custom prompt but not a checklist role).

### B. Discretionary reviewer table

Remove the ux-strategy-minion row from the discretionary table. The table should have 5 rows:
ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion.

### C. Reviewer Approval Gate presentation format

Update the mandatory line from mentioning "software-docs" to "ux-strategy":
```
Mandatory: security, test, ux-strategy, lucy, margo (always review)
```

### D. Format rules for short names

Update short name list from "software-docs" to "ux-strategy":
```
Use short names (security, test, ux-strategy, lucy, margo).
```

### E. Discretionary pool size references

Search for all occurrences of "6-member" and replace with "5-member".

### F. Remove software-docs-minion custom prompt block

Delete the entire block that starts with `**software-docs-minion prompt** (replaces the generic reviewer prompt):` through its closing code fence. This is the prompt that produces the Phase 3.5 documentation impact checklist.

### G. Add ux-strategy-minion custom prompt block

In place of the removed software-docs-minion prompt (same location), add a custom prompt for ux-strategy-minion. Use the same pattern as other custom prompts in the file:

```
**ux-strategy-minion prompt** (replaces the generic reviewer prompt):

(code fence)
Task:
  subagent_type: ux-strategy-minion
  description: "Nefario: ux-strategy-minion review"
  model: sonnet
  prompt: |
    You are reviewing a delegation plan before execution begins.
    Your role: evaluate journey coherence, cognitive load, and simplification
    opportunities across the plan.

    ## Delegation Plan
    Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md

    ## Your Review Focus
    1. Journey coherence: Do the planned deliverables form a coherent user
       experience? Are there gaps or contradictions in the user-facing flow?
    2. Cognitive load: Will the planned changes increase complexity for users?
       Are there simpler alternatives that achieve the same goal?
    3. Simplification: Can any planned deliverables be combined, removed, or
       simplified without losing value?
    4. User jobs-to-be-done: Does each user-facing task serve a real user need,
       or is it feature creep?

    ## Instructions
    Return exactly one verdict:
    - APPROVE: No concerns from your domain.
    - ADVISE: <list specific non-blocking warnings>
    - BLOCK: <describe the blocking issue and what must change>

    Write your verdict to: $SCRATCH_DIR/{slug}/phase3.5-ux-strategy-minion.md

    Be concise. Only flag issues within your domain expertise.
(code fence)
```

Use the same code fence pattern (triple backticks) as the other prompts in the file.

### H. Scratch directory structure

Remove the line:
```
  phase3.5-docs-checklist.md          # documentation impact checklist (Phase 8 input)
```

### I. Phase 8 section -- Simplify checklist derivation

Replace the current Phase 8 steps that merge two sources (Phase 3.5 checklist + execution outcomes) with a single-source derivation. The new step 1 should generate the checklist solely from execution outcomes using the outcome-action table.

Remove:
- Step 1a (read Phase 3.5 checklist)
- Step 1b (supplement with execution outcomes -- this becomes the ONLY source)
- Step 1c (flag divergence)

Replace with a single step 1 that evaluates execution outcomes against the outcome-action table and generates checklist items with owner tags and priority.

The outcome-action table should match the existing one in the file, with one addition:
| Spec/config files modified | Scan for derivative docs referencing changed sections | software-docs-minion |

Priority assignment rule:
- MUST: gate-approved decisions, new projects, breaking changes
- SHOULD: user-facing features, new APIs
- COULD: config refs, derivative docs

### J. Phase 8 sub-step 8a prompt reference

Update the note about checklist items:

Replace any text about "Items from Phase 3.5 are pre-analyzed" with:
"Checklist items are derived from execution outcomes. Agents should inspect changed files for full scope when file paths are not specified."

## What NOT to change

- Do NOT modify any other phases (1-4, 5-7)
- Do NOT modify the Execution Plan Approval Gate
- Do NOT modify the Team Approval Gate
- Do NOT change Phase 8 sub-steps (8a spawn pattern, 8b marketing lens)
- Do NOT modify the report template

## Verification

After making changes:
1. Search for "software-docs-minion" -- should NOT appear in Phase 3.5 reviewer context. Should still appear in Phase 8 outcome-action table and sub-step 8a.
2. Search for "phase3.5-docs-checklist" -- should return zero results.
3. Search for "6-member" -- should return zero results.
4. Verify ux-strategy-minion appears in the mandatory list and has a custom prompt.
5. Verify the discretionary table has exactly 5 rows.

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
