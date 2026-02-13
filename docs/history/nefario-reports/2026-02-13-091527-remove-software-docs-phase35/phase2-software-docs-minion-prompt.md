You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Remove software-docs-minion from mandatory Phase 3.5 Architecture Reviewers. Phase 8 (Documentation) will self-derive its work order from the synthesis plan and execution outcomes instead of merging two sources (Phase 3.5 checklist + execution outcomes).

## Your Planning Question
You currently produce a documentation impact checklist during Phase 3.5 that feeds into Phase 8. We plan to remove you from Phase 3.5 entirely and have Phase 8 self-derive its checklist from the synthesis plan (task list, deliverables, file paths) plus execution outcomes (files changed, gates approved). What information do you currently capture in the Phase 3.5 checklist that would be difficult to reconstruct from those two sources alone? Are there documentation needs you routinely identify at plan-review time that execution outcomes would miss?

## Context

### Current Phase 3.5 software-docs-minion prompt (from SKILL.md):
The current prompt asks you to:
- Read the full delegation plan from the synthesis file
- Identify all documentation that needs creating or updating
- Produce a checklist with owner tags ([software-docs] or [user-docs]), scope, file paths, and priority (MUST/SHOULD/COULD)
- Max 10 items per checklist
- Return verdict: APPROVE, ADVISE, or (rarely) BLOCK

### Phase 8 current merge logic:
Phase 8 currently merges two sources:
1. Phase 3.5 docs checklist (pre-execution, plan-based)
2. Execution outcomes (post-execution, what actually happened)

It flags divergence when Phase 3.5 checklist items don't correspond to execution outcomes.

### Outcome-action table (from the-plan.md):
| Execution Outcome | Documentation Action | Owner |
|---|---|---|
| New API endpoints created | API reference docs, OpenAPI prose | software-docs-minion |
| Architecture changed | C4 diagram updates, component docs | software-docs-minion |
| Significant design decision made (gate approved) | ADR for each gated decision | software-docs-minion |
| New user-facing feature | Getting-started / how-to guide | user-docs-minion |
| New CLI command or flag | Usage documentation | user-docs-minion |
| Bug fix with user-visible impact | Release notes entry | user-docs-minion |
| README exists and was not updated | README review pass | software-docs + product-marketing |
| New project created | Full README required | software-docs + product-marketing |
| Breaking change introduced | Migration guide | user-docs-minion |
| Configuration changed | Configuration reference update | software-docs-minion |

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: software-docs-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-FHCBRb/remove-software-docs-phase35/phase2-software-docs-minion.md`
