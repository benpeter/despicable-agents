MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

Add `--advisory` flag to `/nefario` for advisory-only orchestrations (#89).

When `--advisory` is present:
- Phases 1-2 run identically (meta-plan, specialist planning)
- Phase 3 produces a recommendation synthesis instead of an execution plan
- Phases 3.5-8 are skipped (no architecture review, no execution, no code review, no tests, no deployment, no docs)
- A report is generated with `mode: advisory` frontmatter
- No branch is created, no PR is opened
- Reports go to `docs/history/nefario-reports/` with the same naming convention

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ITMTbi/advisory-flag-nefario/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ITMTbi/advisory-flag-nefario/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ITMTbi/advisory-flag-nefario/phase2-software-docs-minion.md

## Key consensus across specialists:

### devx-minion
Recommendation: Four precise insertion points in SKILL.md; flag parsing before issue detection, divergence at Phase 3 synthesis + post-Phase 3, self-contained advisory wrap-up, status lines with ADV prefix.
Tasks: 6 -- flag parsing; advisory synthesis prompt; advisory termination section; advisory wrap-up; status line changes; frontmatter update
Risks: Core Rules conflict needs explicit advisory exception; scope creep risk; ~8% SKILL.md growth
Conflicts: none

### ai-modeling-minion
Recommendation: Use existing MODE: SYNTHESIS with ADVISORY: true directive (orthogonal modifier, not new mode); seven-section advisory output format; three AGENT.md changes.
Tasks: 4 -- AGENT.md updates; SKILL.md synthesis prompt; post-Phase 3 branching; TEMPLATE.md rules
Risks: MODE vs ADVISORY orthogonality must be documented clearly
Conflicts: Disagrees with devx-minion on MODE: ADVISORY-SYNTHESIS (prefers ADVISORY as orthogonal directive)

### software-docs-minion
Recommendation: Single template with conditionals (not separate file); Team Recommendation section as core advisory deliverable; mode enum extended to include advisory.
Tasks: 3 -- extend TEMPLATE.md; update SKILL.md report generation; validate against exemplar
Risks: Template conditionals may become complex if more modes are added
Conflicts: none

## External Skills Context
No external skills relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations (especially: MODE: ADVISORY-SYNTHESIS vs ADVISORY: true directive)
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ITMTbi/advisory-flag-nefario/phase3-synthesis.md`
