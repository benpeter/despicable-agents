You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Align docs/ files with new progressive-disclosure README. Fix 4 MUST findings and evaluate 2 SHOULD findings across decisions.md, orchestration.md, and architecture.md. All findings relate to stale reviewer counts ("6 ALWAYS reviewers" is now 5 after ux-strategy-minion moved to discretionary pool).

## Your Planning Question

Three "six dimensions" references (orchestration.md lines 20, 44, 334) and one (architecture.md line 113) are technically correct (the cross-cutting checklist HAS six dimensions, distinct from five mandatory reviewers) but cause confusion near reviewer discussions. What parenthetical clarification disambiguates without cluttering the text?

Also: orchestration.md line ~318 says "all six domain groups" but the architecture diagram (architecture.md) shows seven groups in the Mermaid diagram:
1. Protocol & Integration
2. Infrastructure & Data
3. Intelligence
4. Development & Quality
5. Security & Observability
6. Design & Documentation
7. Web Quality

Is "six domain groups" a pre-existing error that should be fixed to "seven"?

## Context

Read docs/orchestration.md and docs/architecture.md. The cross-cutting checklist has six DIMENSIONS (Testing, Security, Usability-Strategy, Usability-Design, Documentation, Observability) but only five MANDATORY REVIEWERS (security-minion, test-minion, software-docs-minion, lucy, margo). The confusion arises because the word "six" appears in both contexts.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: user-docs-minion

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-T1yIjX/align-docs-with-readme/phase2-user-docs-minion.md`
