MODE: META-PLAN

You are creating a revised meta-plan after a team adjustment.

## Task
<github-issue>
The post-execution skip interview (after Phase 4) currently uses single-choice AskUserQuestion options like "Skip to Phase 8" or "Run Phase 5". Change this to a multi-select so the user can pick exactly which post-execution phases to run (e.g., run Phase 5 code review and Phase 8 docs but skip Phase 6 tests and Phase 7 deploy).
</github-issue>

## Working Directory
/Users/ben/github/benpeter/2despicable/4

## Original Meta-Plan
The following meta-plan was produced for the original team. Use it as context for the revised plan, not as a template to minimally edit.

Read the original meta-plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase1-metaplan.md

## Team Adjustment
- Added: ai-modeling-minion
- Removed: (none)

## Revised Team
ux-strategy-minion, devx-minion, ai-modeling-minion

## Constraints
- Keep the same scope and task description
- Preserve external skill integration decisions unless the team change removes all agents relevant to a skill's domain
- Generate planning consultations for ALL agents in the revised team
- Re-evaluate the cross-cutting checklist against the new team
- Produce output at the same depth and format as the original
- Do NOT change the fundamental scope of the task
- Do NOT add agents the user did not request (beyond cross-cutting requirements)
- Design planning questions as a coherent set -- each question should address aspects that no other agent on the team covers, and questions should reference cross-cutting boundaries where relevant

## Instructions
1. Read the original meta-plan
2. Read relevant files to understand the codebase context
3. Generate planning consultations for all 3 agents in the revised team
4. Re-evaluate the cross-cutting checklist
5. Write your complete revised meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase1-metaplan-rerun.md