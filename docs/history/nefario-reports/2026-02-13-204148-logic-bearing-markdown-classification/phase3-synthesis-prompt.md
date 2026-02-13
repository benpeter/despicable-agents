MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

Nefario misclassifies logic-bearing markdown files (phase-skipping and team assembly).

Nefario's orchestration currently treats all .md files as "documentation." This causes two problems:
1. Phase-skipping: Phase 5 code review is skipped for changes to AGENT.md, SKILL.md, RESEARCH.md because they are classified as "docs-only"
2. Team assembly: ai-modeling-minion is not included in Phase 1 team assembly when the task involves modifying agent system prompts or orchestration rules in .md files

Success criteria:
- Changes to AGENT.md, SKILL.md, RESEARCH.md, and similar logic-bearing markdown files are NOT classified as docs-only
- Docs-only classification still applies to genuinely documentation-only changes (e.g., README prose, user guides, changelog entries)
- The distinction is clear and documented so future contributors understand the boundary
- When a task involves modifying agent system prompts or orchestration logic (even in .md files), ai-modeling-minion is included in team assembly during Phase 1
- More broadly: specialist selection in Phase 1 considers the semantic content of files, not just their extension

Additional context: make the ai-modeling-minion part of the roster from the outset and run all agents on opus.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase2-software-docs-minion.md

## Key consensus across specialists:

ai-modeling-minion: Use filename-primary classification (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md = logic-bearing) with directory context as tiebreaker; default to logic-bearing for edge cases (conservative). Add delegation table entries for agent prompt/orchestration work. Fix Phase 5 conditional. 4 tasks.

lucy: Simple enumerated filename list is proportional (YAGNI/KISS). Add one-sentence classification note to Task Decomposition section. No the-plan.md changes needed but note divergence for human owner. 3 tasks.

ux-strategy-minion: Keep phase-skip silent during execution (dark kitchen). Add parenthetical explanation in wrap-up verification summary. Never surface classification labels to users -- use outcome language only. 2 tasks.

software-docs-minion: Canonical definition in SKILL.md only (at the phase-skip conditional). AGENT.md and docs get vocabulary alignment (1-2 sentences). Use 3-part inline structure with classification table and worked examples. 5 tasks.

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase3-synthesis.md
