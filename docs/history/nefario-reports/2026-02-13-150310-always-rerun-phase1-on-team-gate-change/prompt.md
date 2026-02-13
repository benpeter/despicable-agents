<github-issue>
**Outcome**: Any roster adjustment at the Team Approval Gate triggers a full Phase 1 re-run, so that all agents' planning questions reflect the updated team composition. Currently, minor adjustments (1-2 changes) use a lightweight path that only generates questions for added agents, leaving existing agents' questions stale relative to the new roster. Since planning questions directly shape Phase 2 specialist focus, coherent questions across the full team produce better planning contributions.

**Success criteria**:
- Minor/substantial adjustment classification is removed from SKILL.md
- Any roster change at the Team Approval Gate triggers a full Phase 1 re-run
- Re-run prompt includes the original task, prior meta-plan, and structured delta (same as current substantial path)
- 1 re-run cap per gate is preserved
- 2 adjustment round cap is preserved
- AGENT.md references to minor/substantial paths are removed or updated

**Scope**:
- In: SKILL.md Team Approval Gate adjustment handling, AGENT.md if it references the minor/substantial distinction
- Out: Phase 1 meta-plan logic itself, other approval gates, Phase 3.5 reviewer adjustment gate
</github-issue>

---
Additional context: use opus for all agents
