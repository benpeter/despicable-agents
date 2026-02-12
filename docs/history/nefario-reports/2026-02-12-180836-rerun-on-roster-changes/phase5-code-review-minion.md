VERDICT: ADVISE

FINDINGS:

- [ADVISE] skills/nefario/SKILL.md:782-783 -- Reviewer delta summary leaks classification label "substantial" to user
  The delta summary for the reviewer substantial path reads: "Reviewers refreshed for
  substantial change (+N, -M). Rationales regenerated." The word "substantial" is the
  internal classification label. The adjustment classification rules at lines 446-447
  explicitly state: "Classification is internal. Never surface the threshold number or
  classification label to the user." The Team gate delta summary at line 497 correctly
  avoids this, using neutral phrasing: "Refreshed for team change (+N, -M)."
  FIX: Change to "Reviewers refreshed for reviewer change (+N, -M). Rationales
  regenerated." -- matching the neutral phrasing already used in the CONDENSE line
  at line 790 and consistent with the Team gate pattern.

- [ADVISE] skills/nefario/SKILL.md:475-493 -- Phase 1 re-run missing "Before spawning" prompt-write instruction
  Every other nefario/agent spawn in SKILL.md includes a "Before spawning" instruction
  to write the constructed prompt to a scratch file before invocation (lines 306, 530,
  594, 809, 1172, 1373, 1544, 1552). The substantial path for Team adjustment (lines
  475-493) spawns nefario with MODE: META-PLAN but has no "Before spawning" instruction
  to write a `phase1-metaplan-rerun-prompt.md`. The output file
  (`phase1-metaplan-rerun.md`) is listed in the scratch directory structure at line 234,
  but the corresponding prompt file is not.
  FIX: Add before line 476: "**Before spawning nefario for re-run**: Write the
  constructed prompt to `$SCRATCH_DIR/{slug}/phase1-metaplan-rerun-prompt.md`. Apply
  secret sanitization before writing. Then spawn nefario with the same prompt inline."
  Also add `phase1-metaplan-rerun-prompt.md` to the scratch directory structure at
  line 234.

- [ADVISE] skills/nefario/SKILL.md:441-443 -- 0-change no-op does not specify whether it counts against 2-round cap
  The adjustment classification defines the 0-change case as a no-op that re-presents
  the gate unchanged. However, it does not state whether a no-op counts as an
  adjustment round. A reasonable implementation would not count it (no work was done),
  but this is left ambiguous. The Reviewer gate section (lines 755-796) inherits this
  ambiguity by reference.
  FIX: Add a sentence after line 443: "A no-op does not count as an adjustment round."

- [NIT] skills/nefario/SKILL.md:793-796 -- Reviewer gate does not explicitly state lightweight fallback on re-run cap
  The Team gate (lines 450-452) explicitly says what happens when a second substantial
  adjustment hits the re-run cap: "use the lightweight path with a note in the CONDENSE
  line." The Reviewer gate (lines 793-796) references the adjustment classification
  definition but does not repeat this fallback. Since the reviewer substantial path is a
  nefario-internal operation (not a subagent spawn), the lightweight fallback is even
  simpler -- just apply changes directly. The reference via "per adjustment classification
  definition" technically covers this, but the asymmetry in explicitness between the
  two gates could cause implementation divergence.
  FIX: No change required (covered by reference). Optionally add a parenthetical after
  "Cap at 1 re-run per gate" on line 794: "(second substantial adjustment uses lightweight
  path per adjustment classification definition)."

- [NIT] docs/orchestration.md:78 -- Long line could benefit from line break
  Line 78 is a single paragraph spanning the full re-run behavior description for the
  Reviewer Approval Gate. At 440+ characters it is dense but accurate. The content is
  correct and consistent with SKILL.md.
  FIX: No change required. Purely a readability preference.
