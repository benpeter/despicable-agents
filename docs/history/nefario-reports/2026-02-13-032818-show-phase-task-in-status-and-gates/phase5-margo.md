# Margo Review -- Phase-Context Status and Gates

VERDICT: ADVISE

## Summary

The changes are proportional to the problem: adding phase context to an existing status file mechanism and existing gate headers. No new abstractions, no new dependencies, no new services. The inline status-write pattern (repeated at each phase boundary rather than extracted into a helper) is the right call -- it keeps each instruction self-contained and avoids indirection for a 2-line shell snippet. The documentation changes in `using-nefario.md` are minimal and appropriate.

Complexity budget impact: ~0. This is a refinement of existing mechanisms, not new infrastructure.

## Findings

- [ADVISE] `skills/nefario/SKILL.md`:1398 -- Header "P4 Calibr." deviates from plan
  The synthesis plan specified `"P4 Calibrate"` (12 chars, fits within limit). The implementation used `"P4 Calibr."` (10 chars) -- an abbreviated form with a trailing period that is less readable. "Calibrate" is a complete word; there is no need to truncate it. This is a minor inconsistency with the approved plan.
  FIX: Change `"P4 Calibr."` to `"P4 Calibrate"` at line 1398 to match the plan. It fits within 12 characters.

- [NIT] `skills/nefario/SKILL.md`:1311-1316 -- Mid-execution gate status update adds a third write pattern
  The mid-execution gate status update (`P4 Gate | $task_title`) introduces a variant of the status write where the content is a gate title rather than the task summary. This is fine for now but creates a subtle third format (phase-label + summary, phase-label + gate-title, cleanup removal). Not blocking -- just noting that if more status variants emerge, consider whether a single consistent format would serve better.
  FIX: No action needed now. Monitor for format proliferation in future changes.

## What was checked and is clean

- No new dependencies introduced.
- No new abstraction layers. Status writes are inline, not extracted into helpers.
- No scope creep: changes are limited to Phases 1-4 status writes and gate headers, plus wrap-up. Dark kitchen phases (5-8) correctly excluded per scope.
- Character limit documentation note at line 468-469 is proportionate (2 lines, placed near the first gate definition).
- `docs/using-nefario.md` changes are minimal (~6 lines), describe the experience not the mechanism, and do not expose implementation details (status file format, gate header format).
- Manual configuration example in `using-nefario.md` (lines 199-217) is untouched.
- Follow-up gates (Post-exec, Confirm, PR, Existing PR) are correctly left unchanged.
- Summary truncation updated from 48 to 40 characters with updated budget math at line 363-364.
