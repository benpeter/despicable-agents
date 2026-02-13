## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### (1) At what phase boundaries should skill invocations be recorded?

**Skills invoked** should be recorded at a single point: **After Phase 4 (Execution)**. The reasoning:

- Phases 1-3 are all nefario subagent calls (meta-plan, specialist planning, synthesis). These are internal orchestration -- the agents are *consulted*, not skills *invoked*. The existing `agents-involved` frontmatter field and Agent Contributions section already capture this.
- Phase 4 is where execution agents actually use skills. The orchestrator knows which task prompts included skill references (because the synthesis plan explicitly assigns skills to tasks via the "Available Skills" section in task prompts). After Phase 4 tasks complete, the orchestrator should record which skills were referenced in task prompts AND which skills agents reported actually invoking (from their completion messages).
- The existing "External Skills" section in the template tracks skills *discovered* during meta-plan with a `Tasks Used` column. This is already the right place to capture invocation data -- the column exists but relies on Phase 4 data to fill it. The new "Skills Invoked" tracking is the mechanism to populate that column reliably.

Do NOT add tracking at every phase boundary. That adds session context overhead for minimal value. A single accumulation point at Phase 4 wrap-up is sufficient.

#### (2) Can tool usage counts be extracted from conversation context reliably?

**This is inherently best-effort.** Here is the analysis:

- **What the calling session (main agent) can observe**: It sees its own tool calls (Task, TaskList, TaskUpdate, TeamCreate, Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion). These are directly countable because they appear in the conversation context.
- **What subagents use**: The calling session does NOT see subagent tool calls. When a subagent runs via the Task tool, the calling session sees only the prompt sent and the result returned. Internal tool usage (how many Read/Write/Bash calls the subagent made) is opaque.
- **Practical implication**: Tool counts can only capture the *orchestrator's own* tool usage, not aggregate usage across all agents. This is still useful -- it shows orchestration overhead (how many gates, how many task spawns, how many file reads the orchestrator did) -- but it is NOT a complete picture of all tools used in the session.

**Recommendation**: Frame this as "Orchestrator Tool Usage" rather than "Tool Usage" to set correct expectations. Include counts for the orchestrator's tool calls only. Do not attempt to reconstruct subagent tool usage -- that data is not available without runtime instrumentation (which is explicitly out of scope).

The orchestrator can count its own tool calls by maintaining a simple tally in session context. Increment at each tool call boundary. This is ~20 tokens of session context overhead (a flat map of tool name to count).

#### (3) What is the minimal session context overhead?

Two new fields in session context:

```
skills-invoked: [{name: "despicable-lab", tasks: [1, 3]}, ...]
orchestrator-tools: {Task: 8, TaskList: 12, AskUserQuestion: 4, Bash: 6, Read: 3, Write: 2, Edit: 5}
```

Estimated overhead: **40-80 tokens** depending on number of skills and tool variety. This is well within acceptable limits -- the existing inline summaries are 80-120 tokens each, and there are typically 3-6 of them. Adding 40-80 tokens for resource tracking is ~5-10% increase in session context accumulation.

For comparison, the existing Data Accumulation items already tracked per phase total roughly 300-600 tokens. This addition is marginal.

#### (4) How to distinguish "discovered" from "invoked"

The existing `External Skills` section in TEMPLATE.md already captures *discovered* skills with a `Tasks Used` column. The distinction is clear:

- **Discovered** = found during Phase 1 meta-plan skill scan. Captured in the existing Data Accumulation item "External skills discovered (count, names, classifications, recommendations)."
- **Invoked** = actually referenced in a Phase 4 task prompt's "Available Skills" section AND the executing agent reported using it. Captured by the new `skills-invoked` session context field.

The template does not need a separate section for invoked vs. discovered. Instead:
1. The existing `External Skills` table should be enriched with an `Invoked` column (boolean or "Yes"/"No") alongside the existing `Tasks Used` column.
2. A skill can be discovered but not invoked (row exists, `Invoked` = No, `Tasks Used` = none).
3. A skill can be both discovered and invoked (row exists, `Invoked` = Yes, `Tasks Used` = task numbers).
4. Internal orchestration skills (like `/nefario` itself) are NOT tracked here -- they are the orchestration mechanism, not a resource used by execution tasks.

For the new **orchestrator tool usage** tracking, add a new section to the template called `## Resource Usage` that sits after `External Skills` and before `Working Files`. This section has two subsections: skills invoked (which can be folded into the existing External Skills table via the `Invoked` column) and orchestrator tool counts.

### Proposed Tasks

#### Task 1: Add `skills-invoked` to Data Accumulation in SKILL.md

**What**: Add a new accumulation item under "After Phase 4 (Execution)" in the Data Accumulation section of SKILL.md. The item instructs the orchestrator to record which external skills were included in task prompts and which tasks reported invoking them.

**Deliverable**: Updated `skills/nefario/SKILL.md` Data Accumulation section.

**Dependencies**: None.

**Detail**: Add after the existing `existing-pr` item:
```
- `skills-invoked`: list of external skills that execution agents reported using.
  For each: skill name and task numbers. Derive from task completion messages
  and the "Available Skills" sections in task prompts. If no external skills
  were used, note "none".
```

#### Task 2: Add `orchestrator-tools` to Data Accumulation in SKILL.md

**What**: Add a new accumulation item under "At Wrap-up" in the Data Accumulation section. The orchestrator tallies its own tool calls at wrap-up time by reviewing what tools it used during the session. This is best-effort -- the model counts from its own conversation context.

**Deliverable**: Updated `skills/nefario/SKILL.md` Data Accumulation section.

**Dependencies**: None (can run in parallel with Task 1).

**Detail**: Add to the "At Wrap-up" section:
```
- `orchestrator-tools` (best-effort): approximate counts of tools the orchestrator
  itself called during the session. Include: Task, TaskList, TaskUpdate, TeamCreate,
  AskUserQuestion, Bash, Read, Write, Edit, Glob, Grep. Omit tools with zero usage.
  These counts reflect orchestration overhead only, not subagent tool usage.
```

#### Task 3: Add `Invoked` column to External Skills table in TEMPLATE.md

**What**: Extend the existing External Skills table with an `Invoked` column that distinguishes discovered-but-unused skills from actually-invoked skills. Add a new `## Resource Usage` section for orchestrator tool counts.

**Deliverable**: Updated `docs/history/nefario-reports/TEMPLATE.md`.

**Dependencies**: None (can run in parallel with Tasks 1-2).

**Detail**:
- External Skills table gains `Invoked` column: `| Skill | Classification | Recommendation | Invoked | Tasks Used |`
- New section `## Resource Usage` after External Skills, before Working Files:
  ```markdown
  ## Resource Usage

  <details>
  <summary>Resource usage</summary>

  ### Skills Invoked

  {Count} of {total discovered} external skills invoked during execution.
  {Or "No external skills discovered." if none.}

  ### Orchestrator Tool Counts

  | Tool | Count |
  |------|-------|
  | Task | {N} |
  | TaskList | {N} |
  | AskUserQuestion | {N} |
  | ... | ... |

  Counts are best-effort, reflecting the orchestrator's own tool usage only.
  Subagent tool usage is not tracked.

  </details>
  ```

- Add conditional inclusion rule: `Resource Usage` section: INCLUDE WHEN `mode` != `advisory`. OMIT WHEN `mode` = `advisory` (no execution occurs, no tools to track).

#### Task 4: Update Report Writing Checklist in TEMPLATE.md

**What**: Add a step to the Report Writing Checklist for populating the Resource Usage section from accumulated session context data.

**Deliverable**: Updated checklist in `docs/history/nefario-reports/TEMPLATE.md`.

**Dependencies**: Task 3.

**Detail**: Insert after step 14 (Write External Skills):
```
14a. Write Resource Usage (if mode != advisory; skills invoked count from
     skills-invoked, orchestrator tool counts from orchestrator-tools)
```

#### Task 5: Update Wrap-up Sequence step 6 in SKILL.md

**What**: Update the report generation instruction in the Wrap-up Sequence to include the new Resource Usage section, drawing from the accumulated `skills-invoked` and `orchestrator-tools` data.

**Deliverable**: Updated `skills/nefario/SKILL.md` Wrap-up Sequence.

**Dependencies**: Tasks 1, 2.

**Detail**: Add to step 6 instructions:
```
- include a Resource Usage section (collapsed) with skills invoked count
  and orchestrator tool counts. Counts are best-effort from session context.
  Omit if advisory mode.
```

#### Task 6: Update compaction checkpoint focus strings in SKILL.md

**What**: Ensure the compaction checkpoint focus strings preserve the new `skills-invoked` and `orchestrator-tools` session context fields so they survive context compaction.

**Deliverable**: Updated compaction focus strings in `skills/nefario/SKILL.md`.

**Dependencies**: Tasks 1, 2.

**Detail**: Add `skills-invoked, orchestrator-tools` to the "Preserve:" list in the Phase 3.5 compaction checkpoint focus string. The Phase 3 checkpoint does not need it (skills are not yet invoked at that point). The post-Phase 4 optional compaction note should mention these fields if a checkpoint is added there in the future.

### Risks and Concerns

1. **Tool count accuracy**: The orchestrator counting its own tool calls from conversation context is inherently approximate. After compaction, earlier tool calls may be summarized away. Mitigation: frame as "best-effort" and "approximate" in both the Data Accumulation instructions and the report template. Do not imply precision.

2. **Context overhead creep**: Adding two new fields (40-80 tokens) is marginal now, but every incremental addition compounds. The session context accumulation is already 300-600 tokens. Monitor total size across future features. This specific addition is well within budget.

3. **Subagent tool usage is invisible**: The calling session cannot see what tools subagents used. This is a hard platform constraint (subagent conversations are opaque). Do NOT promise aggregate tool counts across all agents -- it is not achievable without runtime instrumentation. The scope correctly excludes this, but the template wording must be clear to avoid user confusion.

4. **Skills invoked vs. skills available**: A task prompt may list a skill in its "Available Skills" section, but the agent may not actually invoke it. The orchestrator can only know if the agent's completion message mentions the skill. If the agent silently uses a skill without reporting it, it will not be captured. Mitigation: this is acceptable for "best-effort" tracking. The task prompt references are the primary signal; agent self-reporting is supplementary.

5. **Backward compatibility**: Existing reports do not have a `Resource Usage` section. This is fine -- the section has a conditional inclusion rule and is additive. The issue explicitly states existing reports remain valid. No backfilling needed.

6. **Advisory mode exclusion**: Advisory mode sessions (Phases 1-3 only) have no execution, so no skills are invoked and no meaningful tool counts exist beyond planning-phase orchestration. The Resource Usage section should be omitted entirely in advisory mode to avoid empty/misleading sections.

### Additional Agents Needed

**devx-minion**: Should review the proposed changes to SKILL.md and TEMPLATE.md for consistency with existing patterns, section ordering conventions, and the compaction checkpoint focus string format. The devx-minion owns the developer experience of the orchestration workflow and should validate that the new Data Accumulation items integrate cleanly with the existing structure.

No other additional agents needed. The changes are confined to SKILL.md (orchestration instructions) and TEMPLATE.md (report format), both of which are within scope for the agents already involved.
