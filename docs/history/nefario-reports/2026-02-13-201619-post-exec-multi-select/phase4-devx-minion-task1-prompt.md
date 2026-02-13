You are updating the post-execution skip interview in the nefario
orchestration skill. The goal: replace the 4-option single-select with a
3-option multi-select using `multiSelect: true`.

## Context

The post-execution follow-up AskUserQuestion is at lines 1550-1570 of
`/Users/ben/github/benpeter/2despicable/4/skills/nefario/SKILL.md`.
The skip determination logic is at lines 1645-1662 of the same file.

## What to change

### 1. AskUserQuestion block (lines 1550-1570)

Replace the current block:
```
- `question`: "Post-execution phases for Task N: <task title>?\n\nRun: $summary_full"
- `options` (4, `multiSelect: false`):
  1. label: "Run all", description: "Code review + tests + docs after execution completes." (recommended)
  2. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
  3. label: "Skip tests", description: "Skip test execution (Phase 6)."
  4. label: "Skip review", description: "Skip code review (Phase 5)."
```

With:
```
- `question`: "Skip any post-execution phases for Task N: <task title>?
  (confirm with none selected to run all)\n\nRun: $summary_full"
- `options` (3, `multiSelect: true`):
  1. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
  2. label: "Skip tests", description: "Skip test execution (Phase 6)."
  3. label: "Skip review", description: "Skip code review (Phase 5)."
```

Key points:
- Question text changes to "Skip any post-execution phases..." with the
  guidance "(confirm with none selected to run all)".
- Remove the "Run all" option entirely. Zero selections = run all.
- 3 options, ordered by ascending risk (docs, tests, review).
- No "(recommended)" marker on any option.
- `multiSelect: true` instead of `multiSelect: false`.

Update the response interpretation text (lines 1558-1560) to describe
multi-select behavior:
- If no options selected: run all post-execution phases (5-8).
- If one or more options selected: skip those phases, run the rest.

### 2. Freeform flag text (lines 1562-1570)

Minor wording update only. Change:
```
The user may also type a freeform response instead of selecting an option,
```
To:
```
The user may also type freeform flags at the same prompt,
```

This reflects that freeform is a parallel channel, not an alternative to
structured selection. The flag reference table (--skip-docs, --skip-tests,
--skip-review, --skip-post) stays exactly as-is.

Add after the flag reference:
```
If the user provides both structured selection and freeform text,
freeform text overrides on conflict.
```

### 3. Skip determination logic (lines 1645-1662)

The current logic references "Skip review", "Skip tests", "Skip docs" as
single-select labels. With multi-select, the response is a comma-space-
separated string of selected labels. Update the logic:

Replace:
```
Determine which post-execution phases to run based on the user's follow-up
response (structured selection or freeform text flags):
- Phase 5 (Code Review): Skip if user selected "Skip review" or typed
  --skip-review or --skip-post. Also skip if Phase 4 produced no code
  files (existing conditional, unchanged).
- Phase 6 (Test Execution): Skip if user selected "Skip tests" or typed
  --skip-tests or --skip-post. Also skip if no tests exist (existing
  conditional, unchanged).
- Phase 8 (Documentation): Skip if user selected "Skip docs" or typed
  --skip-docs or --skip-post. Also skip if checklist has no items
  (existing conditional, unchanged).
```

With:
```
Determine which post-execution phases to run based on the user's
multi-select response and/or freeform text flags:
- Phase 5 (Code Review): Skip if the user's selection includes
  "Skip review", or freeform contains --skip-review or --skip-post.
  Also skip if Phase 4 produced no code files.
- Phase 6 (Test Execution): Skip if the user's selection includes
  "Skip tests", or freeform contains --skip-tests or --skip-post.
  Also skip if no tests exist.
- Phase 8 (Documentation): Skip if the user's selection includes
  "Skip docs", or freeform contains --skip-docs or --skip-post.
  Also skip if checklist has no items.
- If no options were selected and no freeform skip flags were typed,
  run all phases.
```

The key semantic change: the logic now checks whether each label
"is included in" the multi-select response (which may contain multiple
labels), rather than checking whether the response "equals" a single label.

### 4. CONDENSE line (lines 1657-1662)

No changes. The CONDENSE logic consumes skip booleans, not raw responses.
Verify the label-to-phase mapping is still consistent after your changes
above. It should be, since the labels are unchanged.

## What NOT to change

- Do NOT modify any code outside the two sections described above
  (AskUserQuestion block + skip determination logic + freeform text).
- Do NOT change the CONDENSE status line logic.
- Do NOT change the verification summary format in the wrap-up section.
- Do NOT change the approval gate options (Approve/Request changes/
  Reject/Skip) -- only the FOLLOW-UP after "Approve" changes.
- Do NOT touch Phase 5, 6, 7, or 8 implementation details.

## Files to modify

- `/Users/ben/github/benpeter/2despicable/4/skills/nefario/SKILL.md`
  (the only file for this task)

## Verification

After making changes, read back the modified sections to confirm:
1. The AskUserQuestion uses `multiSelect: true` with exactly 3 options.
2. Question text includes "confirm with none selected to run all".
3. No "Run all" option exists.
4. Options are ordered: Skip docs, Skip tests, Skip review.
5. Skip determination logic uses "includes" semantics for multi-select.
6. Freeform override rule is documented.
7. CONDENSE section is unchanged.

## Task tracking

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
