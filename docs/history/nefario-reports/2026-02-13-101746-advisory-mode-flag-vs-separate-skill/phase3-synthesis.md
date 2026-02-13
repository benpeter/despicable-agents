# Phase 3: Synthesis -- Advisory Mode Decision

## Executive Summary

The team unanimously agrees that a separate skill is the wrong answer. The debate
is between building a `--advisory` flag on nefario (devx-minion, ai-modeling-minion,
lucy) and building nothing (margo). After weighing the arguments, the team
recommendation is: **do nothing now, build the flag when pain materializes.**

## Team Positions

### Unanimous Agreement: Not a Separate Skill

All four specialists reject a separate `/nefario-advisory` or `/advisory` skill.
The reasons converge:

- 60-70% code duplication with SKILL.md (ai-modeling-minion's estimate)
- Fork maintenance problem: every SKILL.md change requires mirroring (margo)
- Violates YAGNI, KISS, Lean and Mean (lucy's alignment analysis)
- Fragments discoverability -- users must know the skill exists to find it (devx-minion)
- Creates a boundary question with no clean answer (lucy)

This is a settled question. The team is unanimous. **A separate skill should not
be built.**

### The Central Disagreement: Build the Flag Now vs. Wait

**Build now** (devx-minion, ai-modeling-minion, lucy -- 3 agents):

- The pattern exists and has been used (SDK evaluation precedent)
- `--advisory` is a natural third mode alongside META-PLAN/SYNTHESIS and PLAN
- Implementation is modest: ~60-70 lines added to SKILL.md (ai-modeling-minion)
- No identity drift -- advisory is a subset of what nefario already does (lucy)
- Flag design is well-understood: same input grammar, different output target (devx-minion)
- Report infrastructure exists and can be reused with a type field (lucy)

**Wait** (margo -- 1 agent, BLOCK verdict):

- YAGNI: one usage, zero observed friction
- Natural language already works: the user said "advisory only" and it worked
- SKILL.md is already 1,928 lines -- every conditional branch is maintenance cost
- Formalizing before the pattern stabilizes risks encoding the wrong abstraction
- The question originates from pattern recognition, not from pain
- If pain emerges later, a 3-line string expansion covers it without mode complexity

### Where Lucy Partially Agrees with Margo

Lucy notes that the SDK evaluation "worked" ad hoc and explicitly flags scope
creep risk -- implementation details (template design, build-index.sh changes,
synthesis prompts) belong in a future orchestration, not this advisory. However,
Lucy still recommends the flag because she sees formalization value in consistent
report location, committed-by-default policy, and type-based organization. She
frames this as "the need exists and has been demonstrated" rather than "the pain
is acute."

## Conflict Resolution

The core tension is between **formalization value** (devx-minion, ai-modeling-minion,
lucy) and **premature abstraction risk** (margo).

Both sides have strong arguments. Resolving this requires weighing the project's
engineering philosophy, which explicitly prioritizes:

1. **YAGNI** -- do not build until you need it
2. **KISS** -- simple beats elegant
3. **Lean and Mean** -- fewer lines, fewer moving parts

Margo's position IS the project's engineering philosophy applied literally. The
three pro-flag agents are arguing for an exception based on precedent and
low implementation cost. But margo correctly identifies that:

- One usage is not a pattern
- Zero friction has been reported
- The natural language approach worked on its first attempt
- SKILL.md complexity is already high

The counter-argument -- that ~60-70 lines is modest -- underestimates the true
cost. devx-minion identifies 5 implementation tasks. ai-modeling-minion identifies
5 change locations. margo identifies 7 conditional branch points. The real
implementation is larger than "~60-70 lines" suggests, and it touches the most
complex artifact in the project.

**Resolution**: Margo's BLOCK is upheld. The project's own engineering philosophy
demands that formalization wait for demonstrated need. However, margo's
intermediate proposal -- a 3-line string expansion if friction emerges -- is
noted as the correct first step when the time comes.

## Recommendation

**Do nothing now.** The current approach (natural language directive) works and
has zero observed friction. The project's YAGNI principle is clear: do not build
until pain materializes.

**Confidence: MEDIUM-HIGH.** The recommendation is grounded in the project's own
engineering principles. The "medium" qualifier acknowledges that three experienced
specialists see value in building now, and their arguments about discoverability,
report consistency, and mode cleanliness have genuine merit. If this were a
project with a team of users rather than a single user, the calculus would shift
toward building the flag.

## Conditions That Would Change This Recommendation

Build the `--advisory` flag when ANY of these conditions are met:

1. **Frequency threshold**: 3+ advisory-only runs are completed, suggesting an
   established pattern rather than a one-off.

2. **Reliability failure**: Nefario ignores the "no changes" natural language
   directive and makes unwanted modifications during an advisory run.

3. **Report inconsistency**: Advisory reports produced ad hoc have inconsistent
   structure, location, or commit status, causing findability or quality problems.

4. **Onboarding friction**: A second user needs to discover the advisory
   capability without being told about it.

5. **Workflow integration**: Advisory reports need to feed into downstream
   automation (e.g., `build-index.sh`, report search, decision tracking) that
   requires structured frontmatter.

When the trigger fires, the implementation path is clear (the specialists have
already mapped it):

- **Step 0** (margo's minimal path): Add `--advisory` as a string expansion in
  argument parsing -- 3 lines, zero conditional logic, nefario handles the rest
  via natural language. Try this first.

- **Step 1** (if Step 0 proves insufficient): Full MODE: ADVISORY implementation
  as designed by ai-modeling-minion and devx-minion. ~60-70 lines of SKILL.md
  additions, advisory report template, type-based report organization per lucy's
  design.

## Strongest Arguments Summary

### For Building Now

| Argument | Agent | Strength |
|----------|-------|----------|
| Same workflow, different terminal condition = flag, not new skill | devx-minion | Strong -- correct framing of the architectural question |
| Phases 1-3 identical, clean branch point | ai-modeling-minion | Strong -- the architecture does support this cleanly |
| No identity drift, natural third mode | lucy | Strong -- advisory IS orchestration |
| Report location/type consistency prevents future mess | lucy | Moderate -- only matters at scale |
| Discoverability via argument-hint | devx-minion | Moderate -- only matters with multiple users |

### For Waiting

| Argument | Agent | Strength |
|----------|-------|----------|
| YAGNI: one usage, zero friction | margo | Strong -- directly applies project principles |
| Natural language already works on first attempt | margo | Strong -- the problem is already solved |
| SKILL.md is 1,928 lines, every branch is maintenance cost | margo | Strong -- complexity budget is real |
| Premature abstraction risks encoding the wrong pattern | margo | Moderate -- pattern may evolve with more samples |
| 3-line string expansion covers the gap if friction emerges | margo | Strong -- proves a lighter path exists |

## Dissenting Views (Preserved for Record)

**devx-minion** would likely push back on the "do nothing" recommendation, arguing
that the architecture analysis has already been done and the implementation cost
is known and low. The sunk-cost argument is not valid (analysis is valuable
regardless of whether it leads to implementation), but the point about low
implementation cost is legitimate. The counter-counter: low cost is not the same
as zero cost, and SKILL.md complexity growth is a ratchet that only goes one
direction.

**ai-modeling-minion** would note that the clean phase-by-phase analysis makes
this a textbook case for proactive design. The architecture is ready, the
conditional logic is simple, and waiting means redoing the analysis later. The
counter: YAGNI explicitly accepts re-analysis cost as the price of not building
prematurely. The analysis is documented here and available when needed.

**lucy** would emphasize that the SDK evaluation's ad-hoc report location
(`.local.md` at project root, scratch files in non-standard paths) is already
a convention violation that formalization would prevent. The counter: one
convention violation does not justify a new system -- the next ad-hoc advisory
can simply be directed to the right location in natural language.

## What This Advisory Itself Demonstrates

There is an irony worth noting: this advisory-only orchestration is itself the
second use of the pattern. The very conversation we are in assembled a specialist
team (devx-minion, ai-modeling-minion, margo, lucy) to evaluate a question
without making code changes. It worked via natural language, as margo predicted.
And it produced a well-structured report, as the pro-flag agents wanted.

This is evidence FOR margo's position: the pattern works without formalization,
even on its second use. It is also evidence TOWARD the frequency threshold
(usage count is now 2, not 1). Neither is decisive. The recommendation stands:
wait for the third use, and observe whether friction appears.
