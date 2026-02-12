**Outcome**: Before nefario dispatches specialists for planning, the user sees which agents were selected and can approve, adjust, or veto the team composition. This prevents wasted compute on specialists the user considers irrelevant and gives the user visibility into orchestration decisions early.

**Success criteria**:
- After Phase 2 team selection, nefario presents the chosen specialists with rationale before proceeding
- User can approve the team as-is, remove specialists, or add specialists not initially selected
- Phase 2 does not proceed to specialist dispatch until the user confirms
- Existing Phase 3.5 architecture review gate continues to work unchanged

**Scope**:
- In: Nefario SKILL.md orchestration flow, Phase 2 team selection logic, approval gate UX
- Out: Phase 3.5 review gate changes, agent AGENT.md files, the-plan.md, adding new agents
