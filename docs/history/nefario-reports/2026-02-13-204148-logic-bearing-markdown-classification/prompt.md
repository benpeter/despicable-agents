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

---
Additional context: make the ai-modeling-minion part of the roster from the outset and run all agents on opus
