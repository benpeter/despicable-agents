# Phase 5: Lucy Review -- preserve-original-prompt-in-reports

## Original User Intent

Preserve the original user prompt in nefario reports and PR descriptions by:
(a) renaming the report section from "Task" to "Original Prompt",
(b) saving the prompt as a standalone `prompt.md` companion file, and
(c) documenting the new artifact across the three relevant files.

## Verdict

**VERDICT: ADVISE**

Two incomplete propagation issues and one missing checklist step. All are
minor but should be fixed before merge to avoid inconsistency.

## Findings

### 1. [ADVISE] skills/nefario/SKILL.md:140 -- Stale "report's Task section" reference

The synthesis plan (Change 3, line 148-149) explicitly instructed: "Also
update the SKILL.md reference on line 140 if it says 'report's Task section'
-- change to 'report's Original Prompt section'."

Line 140 currently reads:
```
`original-prompt`. This is the text that appears in the report's Task section.
```

This was not updated. The TEMPLATE.md section was renamed to "Original
Prompt" but this cross-reference still says "Task section."

**FIX**: Change line 140 of `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` from:
```
`original-prompt`. This is the text that appears in the report's Task section.
```
to:
```
`original-prompt`. This is the text that appears in the report's Original Prompt section.
```

### 2. [ADVISE] docs/history/nefario-reports/TEMPLATE.md:370 -- Missing checklist step 4a for prompt.md

The synthesis plan (Change 2, item e) instructed adding a step 4a after
step 4 ("Sanitize verbatim prompt"):
```
4a. Write sanitized prompt to scratch directory as prompt.md
    (auto-copied to companion directory at wrap-up step 5)
```

The current checklist jumps from step 4 (sanitize) directly to step 5
(write YAML frontmatter) with no mention of writing prompt.md. The
prompt.md writing instruction exists in SKILL.md Phase 1 but is not
reflected in the report writing checklist, creating a gap between the
SKILL.md runtime instructions and the TEMPLATE.md documentation.

**FIX**: Add step 4a after line 370 of `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`. Either insert as "4a" or renumber:
```
4. Sanitize verbatim prompt (redact secrets/tokens/keys)
4a. Write sanitized prompt to scratch directory as prompt.md (auto-copied to companion directory at wrap-up step 5)
5. Write YAML frontmatter with all 10 fields (version: 2)
```

Note: This step documents existing SKILL.md behavior (Phase 1 already
writes prompt.md to scratch). The checklist should reflect what happens.

### 3. [NIT] docs/history/nefario-reports/TEMPLATE.md:333 -- "Task" in Metrics table

The Metrics section (line 333) has a row `| Task | One-line description |`.
This is a data label for the frontmatter `task` field, not the renamed
report section heading. Keeping it as "Task" is **correct** -- it matches
the YAML frontmatter field name `task:` which was intentionally not renamed.
No change needed. Documenting for traceability.

## Consistency Checks Passed

- TEMPLATE.md `version: 2` unchanged (lines 22, 371) -- PASS
- No existing reports modified (all 16 reports still use `## Task`) -- PASS
- `## Task` in SKILL.md line 162 is inside a meta-plan prompt template (section heading for task description to nefario), not the report section -- correctly unchanged -- PASS
- `prompt.md` label added to Working Files convention (TEMPLATE.md line 317) -- PASS
- `prompt.md` mentioned in orchestration.md (line 519) -- PASS
- prompt.md write instruction added to SKILL.md Phase 1 (lines 144-147) -- PASS
- `## Original Prompt` in TEMPLATE.md sections (lines 69, 80, 89) and checklist (line 373) -- PASS
- orchestration.md section 5 updated from "Task" to "Original Prompt" (line 519) -- PASS
- No YAML frontmatter added to prompt.md format -- PASS (plain markdown per synthesis resolution)
- No cross-reference link added in Original Prompt section body -- PASS (per synthesis resolution)

## CLAUDE.md Compliance

- All artifacts in English -- PASS
- No frameworks or dependencies introduced -- PASS (markdown-only changes)
- No PII or proprietary data -- PASS
- YAGNI/KISS maintained -- PASS (minimal changes, no over-engineering)

## Traceability

| Requirement | Plan Element | Status |
|---|---|---|
| Rename "Task" to "Original Prompt" in TEMPLATE.md | Change 2 (items a-c) | DONE |
| Add prompt.md label to Working Files | Change 2 (item d) | DONE |
| Add checklist step 4a for prompt.md | Change 2 (item e) | MISSING |
| Add prompt.md write to SKILL.md Phase 1 | Change 1 | DONE |
| Update orchestration.md bullet | Change 3 | DONE |
| Update SKILL.md "report's Task section" reference | Change 3 (line 148-149) | MISSING |
| Do not modify existing reports | Constraint | PASS |
| Do not bump template version | Constraint | PASS |
| Do not modify build-index.sh | Constraint | PASS |
