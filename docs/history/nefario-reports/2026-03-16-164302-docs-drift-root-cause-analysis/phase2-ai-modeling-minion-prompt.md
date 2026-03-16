You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

The nefario orchestration framework (despicable-agents) was designed with a Phase 8 (Documentation)
that should prevent documentation drift. However, when the framework was used to orchestrate
6 PRs on the web-resource-ledger project (PRs #51-#57), significant documentation drift
accumulated anyway. A subsequent explicit docs drift audit found and fixed 13 OpenAPI discrepancies,
17 README items, missing CONTRIBUTING sections, and stale historical docs.

Five failure patterns were identified:
(a) User-directed full skip with no debt visibility ("Skipped per user directive")
(b) "Handled inline" self-assessment with no verification
(c) "Covered by Task N" declarations where the task covered only a subset
(d) Scope misjudgment (classifying secret-introducing changes as "internal-only")
(e) Cross-PR drift accumulation (each PR's docs scope was too narrow)

## Your Planning Question

Analyze the nefario SKILL.md Phase 8 specification and identify structural weaknesses that allow
these five failure patterns. Focus on: what prompt engineering changes to Phase 8 would make
checklist generation mandatory/non-skippable, resistant to self-assessment shortcuts, and
capable of catching outcome-action table gaps? How should the Phase 8 prompts be restructured
so the calling session cannot bypass doc coverage assessment even when the user skips execution?

Read these files for context:
- /Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md (Phase 8 spec, post-execution phases section)
- /Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md (nefario system prompt)
- /Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0022-docs-drift-audit/outcome.md

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ai-modeling-minion

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase2-ai-modeling-minion.md
