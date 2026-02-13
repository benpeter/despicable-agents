# Margo Review: advisory-flag

**VERDICT: ADVISE**

## Assessment

The plan is well-scoped and proportional to the problem. Adding an `--advisory` flag to an existing orchestration skill is a modest feature. The `ADVISORY: true` orthogonal directive approach is the right call -- it avoids combinatorial mode explosion. Five tasks for modifying three markdown files is reasonable, not inflated. No new dependencies, no new services, no new technologies.

## Non-blocking concerns

### 1. Task 5 is unnecessary overhead

Task 5 is a trivial one-line addition to the SKILL.md description and a short paragraph to the overview. This does not warrant a separate task with its own subagent spawn, prompt, dependency chain, and success criteria. It should be folded into Task 2 or Task 3 as a final step. The overhead of spawning a subagent for a 2-line edit exceeds the complexity of the edit itself.

**Simpler alternative**: Add "also append this sentence to the description and this paragraph to the overview" to Task 2 or Task 3's prompt. Eliminate Task 5 entirely.

### 2. Advisory report format is somewhat rigid for a v1

The advisory report format in Task 1 (AGENT.md) specifies seven sections (Executive Summary, Team Consensus, Dissenting Views, Supporting Evidence, Risks and Caveats, Next Steps, Conflict Resolutions). The plan itself acknowledges "only two exemplars exist" and "the format may need refinement after 3-5 more uses." This is at mild tension with YAGNI -- specifying a rigid seven-section format before you have enough data to know which sections consistently provide value.

The mitigation (TEMPLATE.md subsections marked "recommended but optional") partially addresses this. Not blocking because the format is defined in markdown specification, not executable code -- it is cheap to change later. But worth noting: if the first few advisory runs produce reports where "Dissenting Views" or "Conflict Resolutions" are consistently "None," consider collapsing those into a single "Notable Disagreements" section or making them truly conditional.

### 3. SKILL.md growth trend deserves attention (not this plan's problem)

The plan notes ~150-170 lines added (~8% growth). This is fine for this change. However, SKILL.md is already a large specification file. If it keeps growing at this rate with future features, it will cross the threshold where the specification itself becomes a cognitive load problem. This is not a concern for this plan -- it is a trend to watch.

## What the plan gets right

- **Orthogonal directive over new mode**: Correct design. Avoids combinatorial explosion. KISS.
- **No Phase 1 changes**: Justified by evidence (this advisory orchestration itself proves Phase 1 is identical).
- **Firm "no mid-session conversion" boundary**: Prevents scope creep in the runtime behavior. Clean separation.
- **Single template with conditionals**: Correct over a separate advisory template. One template is simpler than two.
- **No new dependencies, no new files (except report output)**: Minimal surface area change.
- **Approval gate on Task 3 only**: Correctly placed at the highest-risk, hardest-to-reverse change.
