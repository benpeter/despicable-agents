MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

The nefario orchestration framework was designed with Phase 8 (Documentation) to prevent
documentation drift. When used on 6 WRL PRs, significant drift accumulated anyway. Analyze
WHY the framework's Phase 8 safeguards failed, and propose concrete changes to SKILL.md,
AGENT.md, the-plan.md to prevent this failure class.

Five failure patterns: (a) user-directed skip with no debt visibility, (b) "handled inline"
self-assessment with no verification, (c) "covered by Task N" partial coverage, (d) scope
misjudgment, (e) cross-PR drift accumulation.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase2-margo.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase2-software-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase2-ux-strategy-minion.md

## Key consensus across specialists:

## Summary: ai-modeling-minion
Phase: planning
Recommendation: Split Phase 8 into 8a (Assessment — always runs) and 8b (Execution — skippable). Assessment produces file-read-verified checklist recorded as debt when skipped.
Tasks: 3 — Split Phase 8 into assessment/execution; Expand outcome-action table; Add baseline doc scan
Risks: Assessment adds ~$0.004/PR cost; over-complex assessment could slow iteration
Conflicts: none

## Summary: lucy
Phase: planning
Recommendation: Resolve "ALWAYS include" vs "Conditional" contradiction. Make checklist generation always run, delegated to software-docs-minion not self-assessed by nefario.
Tasks: 6 — Fix ALWAYS/Conditional contradiction; External checklist generation; Phase 5 scope expansion; Eliminate unverified "handled inline"; Add debt record on skip; Cross-session state consideration
Risks: Phase 5 scope expansion could slow code review; cross-session state adds complexity
Conflicts: none

## Summary: margo
Phase: planning
Recommendation: Three low-complexity fixes: always-generate checklist, expand outcome-action table, eliminate "handled inline" as skip reason. NOT recommended: cross-PR debt tracker, automated diff tools, mandatory Phase 8.
Tasks: 3 — Always-generate checklist (~1 complexity); Expand table (0 complexity); Ban "handled inline" skip (0 complexity)
Risks: Over-engineering if all proposals adopted; debt tracker is YAGNI
Conflicts: Disagrees with cross-PR debt tracker and diff-based scan proposals

## Summary: software-docs-minion
Phase: planning
Recommendation: Add 7 rows to outcome-action table, add diff-based augmentation, split OpenAPI between Phase 6 (behavioral) and Phase 8 (completeness), mandatory checklist on skip.
Tasks: 4 — Expand table with 7 rows; Add diff-based scan; Phase 6/8 OpenAPI split; Verification of Phase 4 doc tasks
Risks: Diff-based scan adds complexity; OpenAPI split may over-engineer
Conflicts: none

## Summary: ux-strategy-minion
Phase: planning
Recommendation: Make skip cost visible through existing interaction points. Skip tally in gate, unconditional checklist generation, doc-debt report field, cross-session debt ledger, escalation at 3+ skips.
Tasks: 5 — Skip tally in gate; Unconditional checklist; doc-debt frontmatter; Cross-session ledger; Escalation threshold
Risks: Cross-session ledger adds state management complexity
Conflicts: Tension with margo on cross-session state (margo says YAGNI)

## Key Consensus Points
1. UNIVERSAL: Checklist generation must always run, even when Phase 8 execution is skipped
2. UNIVERSAL: Expand the outcome-action table (missing categories caused drift)
3. UNIVERSAL: "Handled inline" must not be accepted as sufficient without verification
4. TENSION: Cross-session debt tracking (ux-strategy wants it, margo says YAGNI)
5. TENSION: Diff-based doc scan (software-docs wants it, margo says fix process first)
6. CONSENSUS: Phase 5 review scope only covers changed files, not missing files

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase3-synthesis.md

IMPORTANT: The target files for changes are in /Users/ben/github/benpeter/despicable-agents/:
- skills/nefario/SKILL.md — the orchestration workflow spec
- nefario/AGENT.md — nefario's system prompt (if changes needed)
- the-plan.md — canonical spec (ONLY if human owner approves)
- docs/ — architecture documentation

Each task prompt must include the EXACT file paths, line ranges, and current content to modify.
Tasks should produce spec changes (markdown edits), not code.
