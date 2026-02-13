# UX Strategy Review: always-rerun-phase1-on-team-gate-change

## Verdict: APPROVE

The plan correctly simplifies the user-facing interaction model. My assessment across each review dimension:

### Journey Coherence
The planned flow -- freeform adjustment, count changes, always re-run, delta summary -- is a single coherent path. Removing the minor/substantial fork eliminates a hidden branching point that produced inconsistent output quality depending on how many agents the user changed. The user's mental model becomes: "adjust the team, get a fresh plan." That is clear and predictable.

The delta summary line ("Refreshed for team change (+N, -M). Planning questions regenerated.") provides adequate feedback without forcing the user to understand the mechanism. This satisfies Nielsen's visibility of system status heuristic.

### Cognitive Load
This change is a net reduction in cognitive load:

- **Before**: Two hidden paths with different output quality, a separate re-run cap that could trigger a third behavior (mechanical inline fallback), and interaction states that varied depending on adjustment magnitude.
- **After**: One path. One cap. One behavior.

The conflict resolution (removing the separate 1-re-run cap) is correct from a UX perspective. I originally recommended the cap with a mechanical fallback, but the synthesis correctly identified that the fallback reintroduces the stale-question quality problem. Two caps with different fallback behaviors is exactly the kind of invisible complexity that makes systems unpredictable.

### Simplification Opportunities
None identified. The plan already achieves the simplest viable design: one adjustment path, one bounding mechanism. The three tasks are appropriately scoped -- Task 1 is the core change, Task 2 is necessary cleanup from removing the shared definition, Task 3 is documentation consistency. Nothing can be removed without leaving dangling references or stale docs.

### Jobs-to-be-Done Alignment
The user's job at the Team Approval Gate: "When I see the proposed team, I want to adjust it if needed, so I can get a plan that reflects my actual team." The always-re-run approach serves this job directly -- every adjustment produces a complete, fresh plan for the revised team. The previous minor path compromised this job by producing a partial plan (only new agents got questions).

### One Note (non-blocking)
The cross-gate inconsistency (Team gate always re-runs, Reviewer gate retains minor/substantial) is acceptable as documented. The gates serve different jobs with different cost profiles. However, I note that this creates a learning transfer gap: users who internalize "adjust = full refresh" at the Team gate may be surprised if they later notice the Reviewer gate behaves differently. This is low-risk because the classification is internal and never surfaced, but worth tracking for future simplification if the Reviewer gate is ever revisited.
