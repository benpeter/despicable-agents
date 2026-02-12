Add re-run option when roster changes significantly at team and reviewer approval gates

**Outcome**: When a user adjusts team composition at either the Team Approval Gate or the Reviewer Approval Gate (Phase 3.5), substantial roster changes trigger a re-run of the relevant planning phase so that questions and review coverage reflect the updated composition. At the Team Approval Gate, substantial specialist changes re-run the meta-plan to produce planning questions matching the revised team's domain coverage. At the Reviewer Approval Gate, substantial reviewer changes re-run reviewer identification so that discretionary rationales and domain signals align with the actual reviewer set. This prevents shallow inference from missing important cross-domain interactions that the original planning would have surfaced with the revised composition.

**Success criteria**:
- Team Approval Gate "Adjust team" flow offers a meta-plan re-run path (not just lightweight question generation)
- Reviewer Approval Gate "Adjust reviewers" flow offers a reviewer re-identification path when changes are substantial
- Minor adjustments (1-2 agents changed) still use the fast lightweight path by default at both gates
- Substantial adjustments (3+ agents changed) default to or recommend re-run at both gates
- Re-runs produce output with the same depth as the original phase
- No additional approval gates introduced (re-runs feed back into the existing gate)

**Scope**:
- In: Team Approval Gate "Adjust team" handling in SKILL.md, Reviewer Approval Gate "Adjust reviewers" handling in SKILL.md, nefario AGENT.md if meta-plan mode needs changes
- Out: Phase 2/3 specialist logic, Phase 5 code review, other approval gates, nefario core orchestration flow

---
Additional context: use opus for everything and make sure the ai-modeling-minion is part of the planning and architecture review teams
