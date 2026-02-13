You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Remove software-docs-minion from mandatory Phase 3.5 Architecture Reviewers. Phase 8 (Documentation) will self-derive its work order from the synthesis plan and execution outcomes instead of merging two sources.

## Your Planning Question
Phase 8 currently merges two sources: the Phase 3.5 docs checklist (pre-execution) and execution outcomes (post-execution). We want Phase 8 to derive its checklist from a single source: the synthesis plan plus execution outcomes. The synthesis plan already contains task prompts with deliverables, file paths, and agent assignments. How should Phase 8 construct its checklist to maintain the same coverage? Specifically: (1) should the outcome-action table remain the primary driver with synthesis plan as supplementary context, or should the synthesis plan tasks be scanned first? (2) should owner tags and priority be assigned by the orchestrator or by the doc agents themselves?

## Context

### Current Phase 8 logic (from the-plan.md):
Phase 8 is conditional — runs when nefario's documentation checklist has items. Currently nefario generates the checklist at the Phase 7->8 boundary based on execution outcomes using an outcome-action table.

Two sub-steps:
- 8a (parallel): software-docs-minion + user-docs-minion with their respective checklist items
- 8b (sequential after 8a): product-marketing-minion reviews README and user-facing docs (conditional)

### Outcome-action table:
| Execution Outcome | Documentation Action | Owner |
|---|---|---|
| New API endpoints created | API reference docs, OpenAPI prose | software-docs-minion |
| Architecture changed | C4 diagram updates, component docs | software-docs-minion |
| Significant design decision made (gate approved) | ADR for each gated decision | software-docs-minion |
| New user-facing feature | Getting-started / how-to guide | user-docs-minion |
| New CLI command or flag | Usage documentation | user-docs-minion |
| Bug fix with user-visible impact | Release notes entry | user-docs-minion |
| README not updated during execution | README review pass | software-docs + product-marketing |
| New project created | Full README required | software-docs + product-marketing |
| Breaking change introduced | Migration guide | user-docs-minion |
| Configuration changed | Configuration reference update | software-docs-minion |

### Current Phase 3.5 mandatory reviewers:
security-minion, test-minion, software-docs-minion, lucy, margo

### Proposed mandatory reviewers:
security-minion, test-minion, lucy, margo (ux-strategy-minion moves to mandatory)

### Key constraint:
- Phase 8 sub-steps (8a, 8b) and agent spawning logic are OUT of scope
- user-docs-minion discretionary role is OUT of scope
- Cross-cutting checklist "Documentation (ALWAYS)" item in Phase 1 remains

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: lucy

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-FHCBRb/remove-software-docs-phase35/phase2-lucy.md`
