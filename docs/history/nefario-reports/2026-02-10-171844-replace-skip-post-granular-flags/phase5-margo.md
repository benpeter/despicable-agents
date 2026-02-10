# Phase 5: Margo Review -- Replace --skip-post with Granular Skip Flags

## VERDICT: ADVISE

### Summary

The changes are proportional to the request. A binary skip option was replaced
with a flat 4-option single-select plus freeform flag support. No new
dependencies, no new abstraction layers, no technology additions. The complexity
budget spend is near zero -- this is markdown instruction text, not executable
code. Scope is well-contained: four files, four edit locations, all consistent
with each other.

The synthesis made a good call resolving the devx-minion vs. ux-strategy-minion
conflict in favor of the simpler flat 4-option design over the two-tier
progressive disclosure pattern. That was the right simplification.

### Findings

- [ADVISE] skills/nefario/SKILL.md:766-770 -- Verification summary in Wrap-up
  section (step 7) was NOT updated to reflect granular skip states. It still
  shows the old format with `tests skipped (none found)` as the partial-skip
  example, which conflates conditional skips with user-requested skips. The
  Wrap-up Sequence (step 3, lines 910-918) WAS updated correctly with the
  "Skipped:" suffix convention. These two locations now describe different
  formats for the same output.
  AGENT: devx-minion
  FIX: Align lines 766-770 with lines 910-918. Replace the step 7 examples
  with the same format used in the wrap-up sequence:
  ```
  Build the **Verification summary** from Phase 5-8 outcomes:
  - All ran, all passed: "Verification: all checks passed."
  - All ran, with fixes: "Verification: N code review findings auto-fixed, all tests pass, docs updated (M files)."
  - Partial skip (user-requested): "Verification: code review passed, tests passed. Skipped: docs."
  - All skipped: "Verification: skipped (--skip-post)."
  The "Skipped:" suffix tracks user-requested skips only. Phases skipped
  by existing conditionals (e.g., "no code files") are not listed.
  ```

- [NIT] skills/nefario/SKILL.md:65 -- The CONDENSE example for post-execution
  result was updated but now has only two examples (all-passed and partial-skip)
  instead of also showing the with-fixes variant. The original had only two
  examples as well, so this is not a regression, but worth noting that the
  CONDENSE line and the wrap-up sequence now show different example sets. Not
  blocking -- CONDENSE examples are illustrative, not exhaustive.
  AGENT: devx-minion
  FIX: No action needed. The CONDENSE line is a condensed reference; showing
  every variant would defeat the purpose.

- [NIT] skills/nefario/SKILL.md:504 -- The instruction "Then auto-commit changes
  (see below) and continue to next batch" was moved from after the "Run all" /
  "Skip" handling to after the freeform flag reference block. This means the
  auto-commit instruction now appears after the flag documentation (line 513:
  "Flags can be combined...") rather than immediately after the response
  handling. The logical flow is: user selects option -> determine what to skip ->
  auto-commit -> next batch. The current placement has the auto-commit
  instruction missing from the follow-up response handling block entirely --
  it appears only via the separate "Auto-commit after gate approval" section
  at line 527. This is fine because the auto-commit section at 527-541 is
  the authoritative reference. The inline "see below" was redundant.
  AGENT: devx-minion
  FIX: No action needed. The auto-commit section at lines 527-541 is the
  single source of truth.

### Complexity Assessment

| Dimension | Before | After | Delta |
|-----------|--------|-------|-------|
| AskUserQuestion options | 2 | 4 | +2 (within documented 2-4 limit) |
| Skip flags documented | 1 (--skip-post) | 4 (--skip-docs, --skip-tests, --skip-review, --skip-post) | +3 (essential: matches the 3 skippable phases) |
| Gating logic lines | 2 | 12 | +10 (per-phase conditionals, essential) |
| Files changed | -- | 4 | Proportional |
| New dependencies | -- | 0 | Good |
| New abstraction layers | -- | 0 | Good |

The added complexity is essential, not accidental. Each new flag maps directly
to a phase that can be skipped. The gating logic enumerates per-phase skip
conditions because three phases can now be independently controlled. There is no
unnecessary indirection or over-engineering.

### What Was Done Well

1. `--skip-post` preserved as a freeform shorthand rather than being deprecated.
   No breaking change for existing users.
2. Risk-gradient ordering (docs < tests < review) is a good UX choice that
   costs zero complexity.
3. Skip-all deliberately removed from structured options and relegated to
   freeform. This is the right call -- requiring more intent for a more
   destructive action.
4. Satellite files are consistent with SKILL.md.
5. No scope creep -- the changes do exactly what was requested and nothing more.
