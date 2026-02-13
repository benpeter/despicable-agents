MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

<github-issue>
**Outcome**: Nefario execution reports capture which skills and tools were used during the orchestration session, providing visibility into resource utilization and enabling retrospective analysis of agent behavior patterns.

**Success criteria**:
- Report template includes a section for skills invoked during the session
- Report template includes a section for tools used (with counts if feasible)
- Skills tracking is populated by the calling session from conversation context (no hooks or shell scripting required)
- Tool counts are best-effort — included if extractable from conversation context, omitted gracefully if not
- Existing reports remain valid (new section is additive)

**Scope**:
- In: Report template (`TEMPLATE.md`), skill instructions (`SKILL.md`), report generation guidance
- Out: Runtime hooks, shell-based instrumentation, modifying Claude Code internals, backfilling existing reports
</github-issue>

---
Additional context: use opus for all agents

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase2-devx-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase2-ai-modeling-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase2-ux-strategy-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase2-test-minion.md`

## Key consensus across specialists:

### Summary: devx-minion
Phase: planning
Recommendation: New `## Session Resources` section with `### Skills Invoked` (list) and `### Tool Usage` (table). Session-total granularity only. Placed after External Skills, before Working Files.
Tasks: 3 -- Update TEMPLATE.md with Session Resources section; Update SKILL.md Data Accumulation; Update report writing checklist
Risks: Tool counts may create false precision; section overlap with External Skills needs clarity
Conflicts: none

### Summary: ai-modeling-minion
Phase: planning
Recommendation: Record at single point after Phase 4. Tool counts are best-effort (orchestrator only, subagents opaque). Enrich existing External Skills table with Invoked column; add separate collapsed Resource Usage section for tool counts.
Tasks: 6 -- Update Data Accumulation in SKILL.md (2 items); Update TEMPLATE.md sections (2 items); Update wrap-up sequence; Preserve through compaction
Risks: Tool counts approximate after compaction; subagent usage invisible; skills may be silently used
Conflicts: Disagrees with devx-minion on approach (enrich existing vs. new section)

### Summary: ux-strategy-minion
Phase: planning
Recommendation: Evolve existing External Skills into broader "Session Resources" section. Always collapsed. Late in hierarchy (between Verification and Working Files). Dual placement: frontmatter field for programmatic + collapsed section for humans.
Tasks: 3 -- Restructure External Skills into Session Resources; Add skills-used frontmatter; Update SKILL.md
Risks: Tool counts creating false precision; two confusingly-similar skills sections if not merged
Conflicts: Aligns with concept of merging but differs on implementation from ai-modeling-minion

### Summary: test-minion
Phase: planning
Recommendation: Conditional inclusion (1+ skills or tool data available). Collapsed by default. Cap tool table at 10-15 rows. New step 14a in report checklist.
Tasks: 3 -- Update conditional inclusion rules; Add collapsibility entry; Update checklist and data accumulation
Risks: Confusion between External Skills and new section; never fabricate counts
Conflicts: none

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. If external skills were discovered, include them in the execution plan:
   - ORCHESTRATION skills: create DEFERRED macro-tasks (see Core Knowledge)
   - LEAF skills: list in the Available Skills section of relevant task prompts
   - Apply precedence rules when skills overlap with internal specialists
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase3-synthesis.md`
