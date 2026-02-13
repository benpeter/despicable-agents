You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Nefario misclassifies logic-bearing markdown files (phase-skipping and team assembly).

Nefario's orchestration currently treats all .md files as "documentation." This causes two problems:
1. Phase-skipping: Phase 5 code review is skipped for changes to AGENT.md, SKILL.md, RESEARCH.md because they are classified as "docs-only"
2. Team assembly: ai-modeling-minion is not included in Phase 1 team assembly when the task involves modifying agent system prompts or orchestration rules in .md files

The fix must:
- Define a classification boundary between "logic-bearing markdown" and "documentation-only markdown"
- Fix the Phase 5 skip conditional in skills/nefario/SKILL.md
- Fix the Phase 1 team assembly logic in nefario/AGENT.md
- Document the boundary for future contributors

## Your Planning Question

The issue explicitly states success criteria and scope boundaries. As the intent alignment and convention enforcement specialist:

1. Review the issue's success criteria against the two affected files (skills/nefario/SKILL.md and nefario/AGENT.md). Are there any success criteria that the current problem analysis misses or misinterprets? Specifically, the criterion "More broadly: specialist selection in Phase 1 considers the semantic content of files, not just their extension" -- does this require changes beyond what is described in the problem analysis, or is it satisfied by the ai-modeling-minion delegation table fix?

2. The project's CLAUDE.md states "Do NOT modify the-plan.md." Confirm that the proposed scope (changes to SKILL.md and AGENT.md only) does not require corresponding changes to the-plan.md or other protected files. If it does, flag the constraint conflict.

3. The project follows the Helix Manifesto (YAGNI, KISS, Lean and Mean). The classification boundary could range from a simple filename list to an elaborate content-analysis heuristic. What level of sophistication is proportional to the problem? Where does the line fall between "too simple to catch edge cases" and "over-engineered for the actual failure mode"?

4. The fix introduces a new concept ("logic-bearing markdown") into the orchestrator's vocabulary. Does this concept align with existing project terminology and conventions, or does it risk creating inconsistency? Check the project's existing documentation (docs/architecture.md, CLAUDE.md, the-plan.md) for any existing terminology that already covers this distinction.

Note: ai-modeling-minion will define the technical classification criteria. Your role is to ensure the solution stays aligned with what the issue actually asks for and does not drift into adjacent concerns.

## Context

Read these files:
- The GitHub issue success criteria (restated above)
- CLAUDE.md -- project conventions
- docs/architecture.md
- the-plan.md -- check for existing terminology and protected-file constraints (do NOT recommend modifications)
- nefario/AGENT.md -- the file that will be modified (delegation table, task decomposition)
- skills/nefario/SKILL.md -- the file that will be modified (phase-skip conditionals, lines 1638-1710)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase2-lucy.md
