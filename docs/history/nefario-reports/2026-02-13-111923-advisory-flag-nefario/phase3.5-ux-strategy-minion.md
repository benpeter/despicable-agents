# UX Strategy Review: advisory-flag

**Verdict**: ADVISE

## Assessment

### Journey Coherence: APPROVED
The advisory path (`/nefario --advisory`) and standard path (`/nefario`) serve distinct jobs-to-be-done. The divergence at Phase 3 is logical and well-marked. Status line visibility (`ADV` prefix) prevents mode confusion. The firm boundary preventing mid-session mode switching is excellent friction reduction.

### Cognitive Load: APPROVED WITH NOTES
- Position-independent flag parsing follows principle of least surprise ✓
- Orthogonal `ADVISORY: true` directive (not a new MODE) avoids combinatorial explosion ✓
- ~8% SKILL.md growth (~150-170 lines) is acceptable given self-contained structure ✓

### User Jobs: VALIDATED
All user-facing deliverables serve real needs:
1. "Should I do this?" (advisory synthesis + report)
2. "No branch pollution from exploratory decisions" (advisory termination)
3. "Show me consensus and dissent" (Team Recommendation format)

No feature creep detected.

## Advisory Recommendation: Remove Phase 2 Advisory Context

**Issue**: Task 2 Change 5 adds a 3-line advisory context block to Phase 2 specialist prompts.

**Evidence of unnecessary complexity**:
1. The plan states: "The current orchestration works without one" (Conflict Resolution, Phase 1/2 advisory context section).
2. ai-modeling-minion's original argument holds: Phase 2's job ("contribute planning expertise") is identical for advisory and execution.
3. The cited problem ("specialists occasionally propose execution tasks") is a specialist prompt quality issue, not a mode-specific issue.

**Recommendation**: Delete Task 2 Change 5 entirely.

**Impact if adopted**:
- Removes 40-50 lines from SKILL.md
- Eliminates conditional branch in specialist prompt construction
- Simplifies maintenance (fewer mode-specific behaviors)
- No user-facing impact (the plan's own evidence shows it works without this)

**Impact if rejected**:
- Minor technical debt accumulation
- Specialists receive advisory framing that the plan admits is not strictly necessary

## Other Notes

- Task 3 approval gate is correctly positioned (highest-risk behavioral change).
- Core Rules exception (Task 2 Change 4) is necessary but adds complexity. Acceptable trade-off.
- Team Recommendation format flexibility ("subsections recommended but optional") is good design for an evolving feature.

## Conclusion

This plan serves users well. The advisory mode is a genuine simplification for exploratory decision-making. One non-blocking optimization available (remove Phase 2 advisory context). Recommend proceeding with or without that change.
