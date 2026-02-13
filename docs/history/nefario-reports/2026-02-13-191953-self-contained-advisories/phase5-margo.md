VERDICT: ADVISE

FINDINGS:

- [ADVISE] skills/nefario/SKILL.md:1128-1151 -- Reviewer prompt contains 3 full examples (good ADVISE, bad ADVISE, good BLOCK) that are duplicated verbatim in both the generic reviewer prompt (lines 1128-1151) and the ux-strategy-minion prompt (lines 1203-1225). This is 48 lines of identical content across two prompt templates.
  AGENT: ai-modeling-minion (prompt author, or whichever agent wrote the SKILL.md changes)
  FIX: Two of the three examples are justified -- the good/bad ADVISE contrast is the primary enforcement mechanism, and the BLOCK example shows a different format. The duplication across the two prompt templates is the real issue. Extract the examples into a single "Advisory Format Reference" section in SKILL.md and reference it from both prompt templates with a note like "Follow the advisory format examples in the Advisory Format Reference section above." This eliminates 24 lines of duplication without losing instructional value. The 3 examples themselves are the minimum needed: 1 good ADVISE (positive example), 1 bad ADVISE (negative example for contrast), 1 good BLOCK (different format). Reducing to 2 would lose either the negative example or the BLOCK format.

- [NIT] nefario/AGENT.md:656-693 -- The Verdict Format section grew from ~6 lines to ~33 lines with 4 content rules and 7 field definitions. The content rules (lines 681-689) are valuable for enforcement but partially redundant with the self-containment paragraph at line 675. The paragraph at 675-679 already says "a reader seeing only the advisory block can answer what/what/why" -- the content rules at 681-689 then re-state the same constraint per-field.
  AGENT: ai-modeling-minion
  FIX: No action needed -- this is borderline. The per-field rules are more specific and actionable than the summary paragraph, which makes them useful for LLM reviewers who benefit from explicit field-level instructions. The redundancy is minor (the summary paragraph serves as a quick mental model, the rules serve as a checklist). Leave as-is.

- [ADVISE] lucy/AGENT.md:213 and margo/AGENT.md:249 -- Each governance agent received a single bullet adding self-containment instructions to their Output Standards. These are lightweight and proportional additions. However, the instruction "Each finding names the specific file, config, or concept it concerns -- not 'Task 3' or 'the approach'" partially overlaps with existing instructions in both agents (lucy line 212: "Always cite the exact plan element"; margo line 244-246: "Be specific: 'this abstraction layer...' not 'this is too complex'").
  AGENT: ai-modeling-minion
  FIX: The overlap is minimal and the new bullets add a distinct constraint (no plan-internal references like "Task 3"). The existing instructions focus on specificity of citations; the new ones focus on self-containment for isolated reading. Leave as-is -- the marginal redundancy is justified by the distinct concern.

- [NIT] docs/history/nefario-reports/TEMPLATE.md:116-129 -- The ADVISE line format in the template was updated to include SCOPE/CHANGE/WHY fields. This is consistent with the advisory format defined in nefario/AGENT.md and enforced in the reviewer prompts. The single-advisory and multi-advisory examples are clear.
  AGENT: ai-modeling-minion
  FIX: No action needed. The template update is the minimum change to keep report format aligned with the advisory format.

Summary: The changes are proportional to the goal of making advisories self-contained. The total addition across all 5 files is ~140 lines, which is reasonable for a cross-cutting format change that touches the advisory schema, reviewer prompts, governance agents, and report template. The primary complexity concern is the duplication of 3 examples across two reviewer prompt templates in SKILL.md -- extracting those to a shared section would reduce maintenance burden without losing instructional value.
