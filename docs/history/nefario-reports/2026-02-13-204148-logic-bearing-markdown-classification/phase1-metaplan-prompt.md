MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

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

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan (see your Core Knowledge for the output format).

Discovered project-local skills:
- .claude/skills/despicable-lab/SKILL.md
- .claude/skills/despicable-statusline/SKILL.md

Read their frontmatter to determine relevance.

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution -- planning). These are agents whose domain expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase1-metaplan.md
