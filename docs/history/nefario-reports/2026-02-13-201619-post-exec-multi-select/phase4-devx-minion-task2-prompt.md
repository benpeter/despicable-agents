You are updating satellite documentation files to reflect the post-execution
multi-select change made in the nefario skill. Task 1 already updated
`skills/nefario/SKILL.md`. Now update references in three other files.

## Changes needed

### File 1: `/Users/ben/github/benpeter/2despicable/4/nefario/AGENT.md`

Lines 775-777 currently read:
```
Users can skip individual post-execution phases at approval gates: "Run all"
(default), "Skip docs", "Skip tests", or "Skip review". Freeform flags
--skip-docs, --skip-tests, --skip-review, --skip-post also accepted.
```

Replace with:
```
Users can skip post-execution phases via multi-select at approval gates:
check "Skip docs", "Skip tests", and/or "Skip review" (confirm with none
selected to run all). Freeform flags --skip-docs, --skip-tests,
--skip-review, --skip-post also accepted.
```

### File 2: `/Users/ben/github/benpeter/2despicable/4/docs/orchestration.md`

**Location 1** -- Lines 113-116 currently read:
```
At each approval gate, after selecting "Approve", a follow-up prompt offers
granular control: "Run all" (default), "Skip docs" (Phase 8), "Skip tests"
(Phase 6), or "Skip review" (Phase 5). Freeform flags (--skip-docs,
--skip-tests, --skip-review, --skip-post) can skip multiple phases at once.
```

Replace with:
```
At each approval gate, after selecting "Approve", a multi-select follow-up
lets users check which phases to skip: "Skip docs" (Phase 8), "Skip tests"
(Phase 6), or "Skip review" (Phase 5). Confirm with none selected to run
all. Freeform flags (--skip-docs, --skip-tests, --skip-review, --skip-post)
also accepted.
```

**Location 2** -- Lines 473-474 currently read:
```
- **Approve** -- Gate clears. A follow-up prompt offers "Run all" (default),
  "Skip docs", "Skip tests", or "Skip review". Freeform flags for multi-skip.
```

Replace with:
```
- **Approve** -- Gate clears. A multi-select follow-up lets users check
  phases to skip ("Skip docs", "Skip tests", "Skip review"; none selected
  = run all). Freeform flags also accepted.
```

### File 3: `/Users/ben/github/benpeter/2despicable/4/docs/using-nefario.md`

No changes needed. The reference at line 83 (`/nefario #42 skip phase 8`)
is a freeform flag example, which is unchanged. The Phase 5 description at
line 112 does not mention the skip interface.

## What NOT to change

- Do NOT modify content unrelated to the post-exec skip interface.
- Do NOT change the Mermaid diagrams in orchestration.md (the "Skip review"
  at line 206/208 refers to the Phase 3.5 reviewer approval gate, which is
  a completely different feature).
- Do NOT update files in `docs/history/` -- those are historical records.

## Verification

After making changes, read back each modified section to confirm the text
accurately describes the multi-select interaction.

## Task tracking

When you finish your task, mark it completed with TaskUpdate (task ID: 2) and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
