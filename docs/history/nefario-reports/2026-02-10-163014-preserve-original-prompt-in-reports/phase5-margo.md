# Phase 5: Margo Review -- preserve-original-prompt-in-reports

VERDICT: ADVISE

## Assessment

The changes are minimal and focused. Three markdown files edited, no code, no
new dependencies, no new abstractions. The complexity budget spend is near zero:
a section rename, a 4-line instruction addition in SKILL.md, a bullet text
update in orchestration.md, and a label addition in TEMPLATE.md. This is
proportional to the problem.

The secret scan patterns in SKILL.md (wrap-up step 5, lines 858-863; PR body
scan, line 729) are pre-existing -- not introduced by this change. They are
proportionate: a single grep-based pattern list, not an over-engineered scanning
framework. No concern there.

No gold-plating detected. No unnecessary additions beyond the plan.

## Findings

- [ADVISE] skills/nefario/SKILL.md:140 -- Stale reference: "report's Task section"
  The synthesis plan (Change 3) explicitly called for updating this to "report's
  Original Prompt section" if it still said "report's Task section." It was not
  updated. This creates an inconsistency: TEMPLATE.md and orchestration.md both
  say "Original Prompt" but SKILL.md line 140 still says "Task section."
  FIX: Change "This is the text that appears in the report's Task section." to
  "This is the text that appears in the report's Original Prompt section."

- [NIT] docs/history/nefario-reports/TEMPLATE.md:370 -- Missing checklist step 4a
  The synthesis plan (Change 2, item e) specified adding a step after step 4
  about writing the sanitized prompt to the scratch directory as prompt.md.
  This was not added to the Report Writing Checklist. The instruction does
  exist in SKILL.md Phase 1 (lines 144-147), so the behavior is documented
  -- but the TEMPLATE.md checklist is incomplete relative to the plan spec.
  Non-blocking because SKILL.md is the authoritative runtime instruction
  and it correctly documents the step.
  FIX: After step 4, add: "4a. Write sanitized prompt to scratch directory
  as prompt.md (auto-copied to companion directory at wrap-up step 5)"
  and renumber steps 5-15 to 5a-15a, or use sub-numbering.

## Summary

Two minor issues, both non-blocking. The SKILL.md stale reference (ADVISE) is
a consistency gap that should be fixed before merge -- it takes 5 seconds. The
TEMPLATE.md missing checklist step (NIT) is cosmetic since SKILL.md already
documents the behavior. No over-engineering, no YAGNI violations, no
unnecessary complexity. Changes are well-scoped and proportional.
