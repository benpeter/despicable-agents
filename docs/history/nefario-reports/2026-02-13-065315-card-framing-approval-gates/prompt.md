**Outcome**: Approval gates are visually distinct from surrounding tool output by using inline code spans (backticks) on structural lines, leveraging Claude Code's built-in code highlight color to create card-like separation without any special markdown extensions or rendering features.

**Success criteria**:
- Gate header line uses backtick-wrapped text with box-drawing dash (─) border
- All CAPS-LABEL field names (DECISION:, DELIVERABLE:, RATIONALE:, IMPACT:, Confidence:) are backtick-wrapped
- Closing border line uses backtick-wrapped box-drawing dashes
- Visual Hierarchy table in SKILL.md updated to reflect the new Decision weight pattern
- Gate renders as a visually coherent card in Claude Code terminal output

**Scope**:
- In: SKILL.md approval gate template, Visual Hierarchy table description for Decision weight
- Out: Phase announcement formatting, compaction checkpoint formatting, AskUserQuestion prompts, non-SKILL.md documentation

**Constraints**:
- Only inline code spans (backticks) and box-drawing characters -- no markdown extensions, no special rendering

---
Additional context: consider all approvals given, skip test and security post-exec phases. Include user docs, software docs and product marketing in the roster. Work all through to PR creation without interactions, do not interrupt to propose compactions.
