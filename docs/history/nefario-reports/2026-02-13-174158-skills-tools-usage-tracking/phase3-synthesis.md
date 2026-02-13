## Delegation Plan

**Team name**: session-resources-tracking
**Description**: Add skills invoked and tool usage tracking to nefario execution reports

### Conflict Resolutions

**Separate section vs. merged into External Skills**: devx-minion argued for a new
standalone `## Session Resources` section, separate from External Skills. ai-modeling-minion
argued for enriching the existing External Skills table with an `Invoked` column and
adding a sibling `## Resource Usage` section. ux-strategy-minion argued for evolving
External Skills into a broader Session Resources section that subsumes it.

**Resolution**: Evolve External Skills into `## Session Resources`. The ux-strategy-minion's
argument is decisive: External Skills has never appeared in any of the 50+ existing reports
(it is always omitted because no external skills have been discovered in any session to
date). Renaming and broadening an always-omitted section costs nothing in backward
compatibility and prevents the real risk of two confusingly-similar skills sections
coexisting. The devx-minion's concern about conflating "discovered" vs. "used" is valid
but addressable within a single section using subsections. The ai-modeling-minion's
`Invoked` column approach adds complexity to a table that has never been rendered.

The merged section structure:
- `## Session Resources` (replaces `## External Skills`)
  - `### External Skills` subsection (the original table, shown when skills were discovered -- preserves existing semantics)
  - `### Skills Invoked` subsection (new -- list of skills actually used during the session)
  - `### Tool Usage` subsection (new -- best-effort orchestrator tool counts)

The entire section is collapsed by default in a `<details>` block per ux-strategy-minion
and test-minion recommendations.

**Section naming**: devx-minion proposed "Session Resources", ai-modeling-minion proposed
"Resource Usage", ux-strategy-minion proposed "Session Resources". Adopting "Session
Resources" -- it is concise, forward-compatible, and the consensus pick.

**Tool count granularity**: All specialists agreed on session-total granularity (not
per-phase or per-agent). Adopted. The counts reflect the orchestrator's own tool usage
only; subagent tool usage is opaque. Label the subsection "Tool Usage" with a disclaimer.

**Frontmatter field**: devx-minion proposed conditional `skills-invoked` (omit when only
`/nefario`). ux-strategy-minion proposed `skills-used`. Adopting `skills-used` as the
field name (matches verb pattern of `agents-involved`), with conditional inclusion: INCLUDE
WHEN 1+ skills beyond `/nefario` were invoked. `/nefario` is implicit for all nefario
reports and listing it adds noise to frontmatter. The markdown body section always lists
`/nefario` for completeness, but the frontmatter field only appears when additional skills
were used.

**Advisory mode handling**: ai-modeling-minion argued for omitting Resource Usage entirely
in advisory mode. test-minion argued advisory mode still invokes skills. Resolution: the
section is always structurally present when there is data to report. Advisory mode
sessions still invoke `/nefario` at minimum. However, the Tool Usage subsection is
omitted in advisory mode (minimal tool activity, not useful for analysis). Skills
Invoked subsection is always included.

---

### Task 1: Update TEMPLATE.md -- Session Resources section and related rules

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This template change defines the target format that all downstream SKILL.md changes reference. It also replaces an existing section (External Skills) which is a structural change to the report schema. Multiple valid approaches existed (separate section, merged section, enriched table); the user should confirm the chosen structure before it propagates.
- **Prompt**: |
    You are updating the nefario execution report template to add skills and tool
    usage tracking. This is a template/documentation change -- no code is involved.

    ## Context

    The nefario execution report template at
    `docs/history/nefario-reports/TEMPLATE.md` defines the canonical structure for
    all orchestration reports. You are adding a "Session Resources" section that
    tracks which skills were invoked and what tools the orchestrator used during
    a session. This replaces the existing "External Skills" section, which has never
    appeared in any actual report (it is always omitted because no external skills
    have been discovered in any session).

    ## What to Do

    Read `docs/history/nefario-reports/TEMPLATE.md` and make these changes:

    ### 1. Add `skills-used` frontmatter field

    Add a new row to the Frontmatter Fields table:
    ```
    | `skills-used` | conditional | Array of skill names invoked during session (beyond `/nefario`). INCLUDE WHEN 1+ additional skills used. OMIT WHEN only `/nefario` was invoked. |
    ```
    Place it directly after the `agents-involved` row.

    In the frontmatter skeleton, add `skills-used` as a conditional field with a
    comment, placed after `agents-involved`:
    ```yaml
    agents-involved: [{agent1}, {agent2}, ...]
    skills-used: [{skill1}, {skill2}]
    ```

    ### 2. Replace External Skills section with Session Resources

    In the skeleton, replace the `## External Skills` section and everything up to
    `## Working Files` with:

    ```markdown
    ## Session Resources

    <details>
    <summary>Session resources</summary>

    ### External Skills

    | Skill | Classification | Recommendation | Tasks Used |
    |-------|---------------|----------------|------------|
    | {skill-name} | {LEAF/ORCHESTRATION} | {how it was used} | {task numbers} |

    ### Skills Invoked

    - `/nefario` -- orchestration workflow
    - `/{skill-name}` -- {brief description} ({task numbers or context})

    ### Tool Usage

    | Tool | Count |
    |------|-------|
    | Task (subagent) | {N} |
    | Read | {N} |
    | Edit | {N} |
    | Write | {N} |
    | Bash | {N} |
    | Grep | {N} |
    | Glob | {N} |

    Counts are best-effort, reflecting the orchestrator's own tool usage only.
    Subagent internal tool usage is not tracked.

    </details>
    ```

    ### 3. Update Conditional Section Rules table

    Replace the External Skills row with:
    ```
    | Session Resources | Always (section is structurally present in all reports) | Never omitted entirely |
    | Session Resources: External Skills subsection | Meta-plan discovered 1+ external skills | No external skills discovered |
    | Session Resources: Tool Usage subsection | `mode` != `advisory` AND tool counts extractable | `mode` = `advisory` OR counts not available |
    ```

    ### 4. Update Collapsibility Rules table

    Add a row for Session Resources:
    ```
    | Session Resources | yes | |
    ```

    And remove any "All other sections" row that would contradict this, or ensure
    Session Resources is listed before the catch-all row.

    ### 5. Update Report Writing Checklist

    Replace step 14 ("Write External Skills (if any discovered)") with:
    ```
    14. Write Session Resources (collapsed; External Skills subsection if any discovered;
        Skills Invoked list always; Tool Usage table if mode != advisory and counts
        available, otherwise omit Tool Usage subsection gracefully)
    ```

    ### 6. Add formatting rules

    In the Formatting Rules section, add:
    ```
    - **Session Resources**: Always collapsed. Skills Invoked list always includes
      `/nefario` as first entry. Tool Usage table omits tools with zero usage.
      If tool counts are not available (e.g., context was heavily compacted),
      replace the Tool Usage subsection with: "Tool counts not available for this
      session." If the entire section would contain only `/nefario` in Skills
      Invoked and no other data, the section still appears (collapsed) for
      structural consistency.
    ```

    ## What NOT to Do

    - Do NOT bump the template version from 3. This is an additive change.
    - Do NOT modify any section outside of External Skills / Session Resources,
      the frontmatter, the conditional rules table, the collapsibility table,
      the formatting rules, and the report writing checklist.
    - Do NOT add tool counts to the YAML frontmatter (too noisy for machine parsing).
    - Do NOT add per-phase or per-agent tool count breakdowns.

    ## Deliverables

    - Updated `docs/history/nefario-reports/TEMPLATE.md` with all changes above

    ## Success Criteria

    - The skeleton shows `## Session Resources` with three subsections (External Skills, Skills Invoked, Tool Usage)
    - The section is wrapped in `<details>` tags
    - `skills-used` appears in frontmatter fields table with conditional inclusion rule
    - Conditional Section Rules table has entries for Session Resources and its subsections
    - Collapsibility Rules table includes Session Resources as collapsed
    - Report Writing Checklist step 14 references Session Resources
    - Formatting Rules include Session Resources guidance
    - No version bump
- **Deliverables**: Updated `docs/history/nefario-reports/TEMPLATE.md`
- **Success criteria**: Template contains Session Resources section replacing External Skills, with frontmatter field, conditional rules, collapsibility rules, formatting rules, and checklist step all updated

### Task 2: Update SKILL.md -- Data Accumulation and Wrap-up Sequence

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario orchestration skill to support the new Session
    Resources tracking in execution reports.

    ## Context

    Task 1 added a `## Session Resources` section to the report template
    (`docs/history/nefario-reports/TEMPLATE.md`). Now the orchestration skill
    (`skills/nefario/SKILL.md`) needs matching updates so the calling session
    knows how and when to collect skills/tools data.

    The Session Resources section has three subsections:
    - External Skills (existing table, moved under new parent)
    - Skills Invoked (list of skills the session actually used)
    - Tool Usage (best-effort orchestrator tool counts)

    ## What to Do

    Read `skills/nefario/SKILL.md` and make these changes:

    ### 1. Update Data Accumulation -- "At Wrap-up" boundary

    Find the "At Wrap-up" section in Data Accumulation (around line 2024).
    Add two new items after the existing bullet points:

    ```
    - `skills-invoked`: list of skills invoked during the session. Always includes
      `/nefario`. Add any other skills the session invoked (e.g., `/despicable-lab`,
      `/despicable-prompter`). Scan conversation context for skill invocations
      (look for Skill tool calls). For each: skill name and brief usage context.
    - `orchestrator-tools` (best-effort): approximate counts of tools the
      orchestrator itself called during the session. Scan conversation context and
      tally by tool name. Include tools with non-zero counts only. Common tools:
      Task, TaskList, TaskUpdate, TeamCreate, SendMessage, AskUserQuestion, Bash,
      Read, Write, Edit, Glob, Grep, Skill. If context was compacted and counts
      cannot be reliably determined, note "not available". These counts reflect
      orchestration overhead only, not subagent tool usage (which is opaque to
      the calling session).
    ```

    ### 2. Update Wrap-up Sequence step 6

    Find step 6 in the Wrap-up Sequence ("Write execution report"). Add to the
    list of instructions after the existing items:

    ```
       -- include a Session Resources section (collapsed). Always include Skills
          Invoked list (from skills-invoked). Include External Skills subsection
          if any were discovered. Include Tool Usage table if mode != advisory
          and orchestrator-tools data is available. Omit Tool Usage subsection
          gracefully if counts are not available.
    ```

    Also update the existing External Skills instruction in step 6. The current
    text says:
    ```
       -- include an External Skills section if any were discovered (name, classification,
          recommendation, and which execution tasks used them). Omit if none discovered.
    ```
    Replace it with:
    ```
       -- the External Skills data (if any were discovered) is now a subsection within
          Session Resources, not a standalone section. Include the External Skills
          subsection within Session Resources when skills were discovered.
    ```

    ### 3. Update compaction checkpoint focus strings

    Find the Phase 3.5 compaction checkpoint focus string (around line 1235).
    Add `skills-invoked` to the "Preserve:" list. It belongs after `scratch
    directory path` in the preserve list. The orchestrator-tools tally does not
    need preservation at Phase 3.5 (it is computed at wrap-up from conversation
    context, not accumulated incrementally).

    ### 4. Update the "Canonical section order" reference

    Find the comment in the Report Template subsection that says "Canonical section
    order (12 top-level H2 sections)". The count may need updating since External
    Skills was replaced by Session Resources (same count, different name). Verify
    the count is still correct and the comment accurately reflects the section names.

    ## What NOT to Do

    - Do NOT add per-phase tracking of tools or skills. All tracking happens at
      wrap-up as a single scan of conversation context.
    - Do NOT add incremental tool counting at every tool call boundary. This adds
      overhead for marginal benefit. The wrap-up scan is sufficient.
    - Do NOT modify any phase logic (Phases 1-8). Only Data Accumulation,
      Wrap-up Sequence, and compaction focus strings are in scope.
    - Do NOT modify the Phase 3 compaction checkpoint focus string. Skills are
      not yet invoked at Phase 3.

    ## Deliverables

    - Updated `skills/nefario/SKILL.md` (Data Accumulation, Wrap-up Sequence,
      compaction focus string, section count reference)

    ## Success Criteria

    - "At Wrap-up" has `skills-invoked` and `orchestrator-tools` items
    - Wrap-up Sequence step 6 references Session Resources with all three subsections
    - The old External Skills standalone instruction is replaced with the subsection reference
    - Phase 3.5 compaction focus string includes `skills-invoked`
    - Section count reference is accurate
- **Deliverables**: Updated `skills/nefario/SKILL.md` with Data Accumulation, Wrap-up Sequence, compaction focus string, and section count updates
- **Success criteria**: All four subsections of SKILL.md updated; skills-invoked in compaction focus string; wrap-up references Session Resources correctly

---

### Cross-Cutting Coverage

- **Testing** (test-minion): test-minion contributed to planning. No automated tests are needed -- this is a template/documentation change with no executable output. Phase 6 will naturally skip ("no test infrastructure"). Backward compatibility is validated structurally in the task prompts (no version bump, additive only, conditional inclusion rules).
- **Security** (security-minion): Not needed. No auth, APIs, user input, secrets, or infrastructure changes. The changes are markdown template and skill instruction updates.
- **Usability -- Strategy** (ux-strategy-minion): Covered. ux-strategy-minion contributed to planning and their core recommendations (collapse by default, merge into External Skills, late placement in hierarchy) are adopted in the plan.
- **Usability -- Design** (ux-design-minion, accessibility-minion): Not needed. No user-facing UI is produced. The template changes are developer-facing markdown formatting.
- **Documentation** (software-docs-minion, user-docs-minion): The deliverables ARE documentation (report template and skill instructions). software-docs-minion review is handled in Phase 5 (code review of the template changes). No separate user-docs task is needed -- end users do not interact with these files directly.
- **Observability** (observability-minion, sitespeed-minion): Not needed. No runtime components, services, or web-facing code.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - software-docs-minion: The deliverables are documentation artifacts (TEMPLATE.md and SKILL.md). software-docs-minion should review structural consistency of the template changes, conditional rule coherence, and collapsibility pattern correctness. References Tasks 1-2.
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Risks and Mitigations

1. **Tool count accuracy after compaction** (MEDIUM): Long sessions trigger context compaction which may discard individual tool call records. The plan mitigates this with best-effort framing, graceful degradation ("not available"), and wrap-up-only collection. The template explicitly states counts are approximate.

2. **Subagent tool usage is invisible** (LOW): The calling session sees Task tool calls but not tools used within subagent sessions. The plan mitigates this by labeling counts as "orchestrator's own tool usage only" and including a disclaimer in both the template and SKILL.md.

3. **Two skills concepts coexisting** (MEDIUM): "External Skills" (discovered during meta-plan) and "Skills Invoked" (actually used during session) are related but distinct. The plan mitigates this by housing both under a single `## Session Resources` parent section with clear subsection names and keeping External Skills as its own subsection with unchanged semantics.

4. **Frontmatter schema growth** (LOW): Adding `skills-used` is one more conditional field. Mitigated by making it conditional (only when additional skills beyond `/nefario` were used) so most reports do not include it.

5. **No backward incompatibility** (risk confirmation): Existing reports without Session Resources remain valid. The section is additive, no version bump, and the conditional inclusion rule allows omission.

### Execution Order

```
Batch 1: Task 1 (TEMPLATE.md updates) [GATE]
Batch 2: Task 2 (SKILL.md updates)
```

Task 2 depends on Task 1 because the SKILL.md instructions reference the template
structure defined in Task 1. Task 1 has an approval gate because it defines the
structural approach (merged section vs. separate sections, frontmatter field design).

### External Skills

No external skills detected relevant to this task.

### Verification Steps

1. Confirm `## External Skills` no longer appears as a standalone H2 in TEMPLATE.md
2. Confirm `## Session Resources` appears with three subsections in the skeleton
3. Confirm `skills-used` appears in frontmatter fields table with conditional rule
4. Confirm Conditional Section Rules table has Session Resources entries
5. Confirm Collapsibility Rules table has Session Resources as collapsed
6. Confirm Report Writing Checklist step 14 references Session Resources
7. Confirm SKILL.md Data Accumulation has `skills-invoked` and `orchestrator-tools`
8. Confirm SKILL.md Wrap-up Sequence step 6 references Session Resources
9. Confirm Phase 3.5 compaction focus string includes `skills-invoked`
10. Confirm no version bump (still `version: 3`)
11. Spot-check 1-2 existing reports to confirm they remain structurally valid
