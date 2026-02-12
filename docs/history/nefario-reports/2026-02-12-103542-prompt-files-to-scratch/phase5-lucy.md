VERDICT: ADVISE

## Requirements Traceability

| Requirement (from review focus) | Plan Element | Status |
|---|---|---|
| Prompt persistence at all agent invocation points (SKILL.md) | "Before spawning" blocks at Phases 1, 2, 3, 3.5, 4, 5, 8 | COVERED |
| Updated scratch directory structure (SKILL.md) | Scratch Directory Structure section lists all `-prompt.md` files | COVERED |
| Updated advisory format (SKILL.md) | Advisory CHANGE/WHY format with Prompt: reference | COVERED |
| Working Files section with Outputs/Prompts group headers (TEMPLATE.md) | Lines 189-199 | COVERED but INCOMPLETE |
| Label convention (TEMPLATE.md) | Lines 276-280 | COVERED |

## Findings

### SKILL.md

- [NIT] `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`:222-254 -- Scratch directory structure and prompt persistence instructions are internally consistent. Every "Before spawning" instruction (Phases 1, 2, 3, 3.5, 4, 5, 8) has a matching `-prompt.md` entry in the structure listing. Secret sanitization is uniformly required. No issues.

- [NIT] `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`:720-727 -- Advisory format adds a `Prompt:` reference line alongside `Details:` for complex advisories. The conditional inclusion rule ("only when Details: is already present") is clear and prevents noise in simple advisories. No issues.

### TEMPLATE.md

- [ADVISE] `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`:189-202 -- Working Files skeleton in the Outputs/Prompts groups only covers Phases 1-3.5. Missing from Outputs: Phase 5 review outputs (`phase5-{reviewer}.md`), Phase 6 (`phase6-test-results.md`), Phase 7 (`phase7-deployment.md`), Phase 8 outputs (`phase8-checklist.md`, `phase8-software-docs.md`, `phase8-user-docs.md`, `phase8-marketing-review.md`). Missing from Prompts: Phase 4 (`phase4-{agent-name}-prompt.md`), Phase 5 (`phase5-{agent-name}-prompt.md`), Phase 8 (`phase8-{agent-name}-prompt.md`). The SKILL.md scratch structure (lines 222-249) lists all of these files, so the template skeleton is incomplete relative to its own source-of-truth.
  FIX: Extend the Outputs group to include Phase 5-8 output files (conditional entries matching the SKILL.md scratch structure). Extend the Prompts group to include Phase 4, 5, and 8 prompt files. Mark conditional files with the same annotations used in the scratch structure (e.g., "BLOCK/ADVISE only", "if Phase 7 ran").

- [ADVISE] `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`:201 -- `prompt.md` (Original Prompt) is listed as an orphaned entry after the Prompts group, not inside either Outputs or Prompts. This breaks the two-group structure the template introduces. It is neither an agent output nor an agent input prompt -- it is the user's original request.
  FIX: Either create a third group header (e.g., `**Other**`) for `prompt.md`, or place it before the Outputs/Prompts groups as a standalone entry (since it represents the input to the entire orchestration, not a specific phase).

## Convention Compliance

- CLAUDE.md "All artifacts in English": PASS. Both files are in English.
- CLAUDE.md "YAGNI / KISS": The prompt persistence pattern adds one file write per agent invocation. This is proportional -- prompts are already constructed in memory; writing them is a single Write call. The traceability value (debugging, auditing) justifies the cost. PASS.
- CLAUDE.md "Session Output Discipline": The prompt writes are silent (no chat output). PASS.
- SKILL.md internal consistency: Scratch directory structure matches all "Before spawning" instructions. PASS.
- TEMPLATE.md / SKILL.md cross-consistency: Template skeleton is incomplete relative to SKILL.md scratch structure. See ADVISE finding above.

## Summary

The SKILL.md changes are internally consistent and well-structured. The prompt persistence instructions follow a uniform pattern across all invocation points with appropriate sanitization. The advisory format update is clean.

The TEMPLATE.md has two minor structural gaps: the Working Files skeleton only covers Phases 1-3.5 (missing 4-8), and `prompt.md` sits outside the Outputs/Prompts grouping. Neither gap will cause runtime failures -- report generation will include all files from the companion directory regardless of whether the template skeleton lists them. But the skeleton's purpose is to be a reference pattern, and an incomplete reference creates ambiguity for the generating agent.
