MODE: META-PLAN

You are creating a revised meta-plan after the user adjusted the team composition.

## Task

<github-issue>
Nefario misclassifies logic-bearing markdown files (phase-skipping and team assembly)

**Outcome**: Nefario's orchestration correctly identifies that .md file changes can contain substantive logic (system prompts, agent definitions, orchestration rules). This fixes two downstream problems:
1. **Phase-skipping**: No longer incorrectly skips phases by classifying such work as "docs-only," preventing silently dropped quality gates.
2. **Team assembly**: Recognizes that work on agent system prompts, orchestration rules, and similar logic-bearing markdown constitutes LLM prompt design / multi-agent architecture work, and selects ai-modeling-minion (and other relevant specialists) accordingly during Phase 1 meta-plan.

**Success criteria**:
- Changes to AGENT.md, SKILL.md, RESEARCH.md, and similar logic-bearing markdown files are NOT classified as docs-only
- Docs-only classification still applies to genuinely documentation-only changes (e.g., README prose, user guides, changelog entries)
- The distinction is clear and documented so future contributors understand the boundary
- When a task involves modifying agent system prompts or orchestration logic (even in .md files), ai-modeling-minion is included in team assembly during Phase 1
- More broadly: specialist selection in Phase 1 considers the semantic content of files, not just their extension

**Scope**:
- In: Docs-only detection logic in nefario orchestration (SKILL.md, AGENT.md, or wherever the classification lives)
- In: Phase 1 team assembly logic -- specialist selection should account for logic-bearing markdown as prompt engineering / multi-agent architecture work
- Out: Other phase-skipping logic, unrelated orchestration changes, agent prompt content
</github-issue>

---
Additional context: make the ai-modeling-minion part of the roster from the outset and run all agents on opus

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## Original Meta-Plan
The following meta-plan was produced for the original team. Use it as context for the revised plan, not as a template to minimally edit.

Read: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase1-metaplan.md

## User's Adjustment
Added: lucy. Removed: devx-minion.

## Revised Team
ai-modeling-minion, lucy, ux-strategy-minion, software-docs-minion

## Constraint Directives
- Keep the same scope and task description
- Preserve external skill integration decisions unless the team change removes all agents relevant to a skill's domain
- Generate planning consultations for ALL agents in the revised team
- Re-evaluate the cross-cutting checklist against the new team
- Produce output at the same depth and format as the original
- Do NOT change the fundamental scope of the task
- Do NOT add agents the user did not request (beyond cross-cutting requirements)
- Design planning questions as a coherent set -- each question should address aspects that no other agent on the team covers, and questions should reference cross-cutting boundaries where relevant

## Instructions
1. Read relevant files to understand the codebase context
2. Analyze the task against your delegation table with the revised team
3. For each specialist in the revised team, write a specific planning question that draws on their unique expertise
4. Return the revised meta-plan in the structured format
5. Write your complete revised meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase1-metaplan-rerun.md
