MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

Align docs/ files with new progressive-disclosure README (#60). Fix 4 MUST findings and evaluate 2 SHOULD findings across decisions.md, orchestration.md, and architecture.md. All findings relate to stale reviewer counts after ux-strategy-minion moved from ALWAYS to discretionary.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-T1yIjX/align-docs-with-readme/phase2-software-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-T1yIjX/align-docs-with-readme/phase2-user-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-T1yIjX/align-docs-with-readme/phase2-product-marketing-minion.md

## Key consensus across specialists:

### software-docs-minion
Phase: planning
Recommendation: Blockquote addenda below ADR tables, not inside. Decision 15 gets direct update (current behavior, not historical). Consider creating Decision 30 as cross-reference target for addenda. AGENT.overrides.md reference in Decision 15 is also stale (Decision 27).
Tasks: 3 -- ADR addenda for Decisions 10/12/20; Direct update for Decision 15; Optional Decision 30
Risks: orchestration.md line 340 "ALWAYS include" for ux-strategy-minion is correct (planning inclusion, not Phase 3.5 review); executing agent must understand this distinction
Conflicts: none

### user-docs-minion
Phase: planning
Recommendation: Anchor "six dimensions" with full list on first mention in orchestration.md; use "cross-cutting" qualifier in architecture.md line 113. Fix "six domain groups" to "seven" (pre-existing error confirmed against the-plan.md and architecture diagram).
Tasks: 2 -- Disambiguate "six dimensions" references with parenthetical clarifications; Fix "six domain groups" to "seven"
Risks: Cross-cutting planning checklist ux-strategy-minion "ALWAYS include" could be confused with Phase 3.5 reviewer status
Conflicts: none

### product-marketing-minion
Phase: planning
Recommendation: Systematic ALWAYS/conditional vs mandatory/discretionary terminology drift exists but should NOT be bulk-replaced in historical ADRs. The docs layer intentionally uses more technical terminology (ALWAYS/conditional) vs README's user-facing terms (mandatory/discretionary). This is appropriate -- different audiences. Only fix where factually wrong.
Tasks: 1 -- Assess terminology drift and make targeted fixes only where current-behavior text is factually wrong
Risks: Must preserve distinction between planning checklist (Phase 2, six dimensions) and reviewer roster (Phase 3.5, five mandatory)
Conflicts: none

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-T1yIjX/align-docs-with-readme/phase3-synthesis.md`

## Additional Context
- User directive: all approvals pre-given, skip test and security post-exec phases, no compaction interrupts, work through to PR
- Scope: docs/decisions.md, docs/orchestration.md, docs/architecture.md ONLY
- Out of scope: README.md, the-plan.md, AGENT.md files, skills/
- The rework was done in nefario report 2026-02-12-135833. There is no Decision 30 yet.
- Decision on Decision 30: Do NOT create Decision 30 -- this is YAGNI for a documentation alignment task. Addenda should reference the nefario report directly.
- Gate budget: 0 mid-execution gates (all changes are well-specified, additive, easy to reverse)
- Model for execution: sonnet (documentation edits, not deep reasoning)
- This is a single-task execution -- one agent can handle all three files since the edits are interdependent and consistency matters
