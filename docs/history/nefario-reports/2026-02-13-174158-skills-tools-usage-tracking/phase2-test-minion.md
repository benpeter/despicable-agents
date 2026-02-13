# Domain Plan Contribution: test-minion

## Recommendations

### 1. Edge Cases to Cover

The new "Skills & Tools Used" section introduces several edge cases that must be handled gracefully in the template and SKILL.md guidance:

**Empty skills list**: When no skills were invoked during the session (e.g., a pure agent-only orchestration with no external skills and no project-local skills). The section should either be omitted entirely (following the External Skills precedent) or show a minimal "No skills invoked" row. I recommend omitting the section entirely when empty -- this matches the existing External Skills pattern (`OMIT WHEN: No external skills discovered`). Simpler, less visual noise.

**Advisory mode**: Advisory orchestrations (phases 1-3 only) still invoke skills -- the nefario skill itself is always in play, and project-local skills like despicable-lab or despicable-prompter may be discovered. However, tools usage in advisory mode is minimal (Read, Grep, Write for scratch files, subagent spawning). The section should still be included if skills were used, but tool counts will naturally be lower. No special advisory-mode handling is needed beyond the standard conditional inclusion rules.

**Tool counts unavailable**: This is the most important edge case. The issue explicitly states tool counts are "best-effort." The template must handle graceful degradation:
- If counts are available: show the table with counts
- If counts are partially available: show counts where known, use "--" or "n/a" for unknowns
- If no counts are extractable: omit the tool counts sub-table entirely, or show a single line: "Tool counts not available for this session."

The SKILL.md guidance should make clear that missing tool counts are NOT a report defect. The report writer should never fabricate or estimate counts.

**Very large tool count tables**: In complex orchestrations with 20+ tools, the table could dominate the report. Recommendations:
- Cap the table at the top 10-15 tools by count, with a summary row ("Other tools: N total invocations across M tools") for the rest
- Alternatively, collapse the entire section in `<details>` to prevent visual domination
- I recommend collapsibility (matching Agent Contributions and Working Files patterns already established)

**Subagent tool attribution**: When nefario spawns subagents for specialist planning and execution, those subagents use tools too. The report should track tools at the session level (the calling session's tool usage), NOT attempt to attribute tools per-subagent. Per-subagent tracking is infeasible from conversation context and would require runtime instrumentation (explicitly out of scope).

**Skills vs. External Skills disambiguation**: The existing "External Skills" section tracks skills *discovered* during meta-plan. The new section tracks skills *invoked* during the session. These are overlapping but different concepts. A skill could be discovered but not invoked (advisory mode, or skill deemed unnecessary during execution). A skill could be invoked without being "discovered" (the nefario skill itself, despicable-lab used for validation). The template should clearly distinguish:
- "External Skills" = skills discovered during meta-plan (existing section, unchanged)
- New section = skills actually invoked/used during the session

### 2. Conditional Inclusion Table Entry

Yes, the Conditional Section Rules table in TEMPLATE.md needs a new entry. Recommended:

| Section | INCLUDE WHEN | OMIT WHEN |
|---------|-------------|-----------|
| Skills & Tools | Session invoked 1+ skills (including nefario itself) OR tool usage data is available | No skills or tools data to report (unlikely in practice, but possible for aborted sessions with no execution) |

In practice, this section will almost always be included since nefario itself is a skill. The more useful conditional is around tool counts specifically:

| Sub-section | INCLUDE WHEN | OMIT WHEN |
|-------------|-------------|-----------|
| Tool Counts | Tool usage counts extractable from conversation context | Counts not available (graceful omission, not an error) |

However, I want to flag a concern: if the section is *always* included (because nefario is always a skill), then making it conditional adds complexity without value. Consider making it unconditional but collapsible. The tool counts sub-table within it can be conditional.

### 3. Validating Existing Reports Remain Valid (Additive Only)

This is fundamentally a backwards compatibility question. The validation approach:

**Structural validation** (can be done at PR review time):
- The new section must be ADDED to the template skeleton, not replace or reorder existing sections
- No existing YAML frontmatter fields are modified or removed
- No existing conditional rules are altered
- No existing section ordering changes
- The `version` field stays at `3` (this is an additive addition, not a schema-breaking change -- but see risk below about version bump)

**Practical validation against existing reports**:
- Pick 3-5 existing reports spanning different modes (full, advisory, plan) and verify:
  1. They would still be valid under the updated template (no required fields added to frontmatter)
  2. The absence of the new section does not make them incomplete (new section must be optional for old reports)
  3. The build-index.sh (if/when it exists) does not break on reports missing the new section

**Specific checks**:
- The `version: 3` in existing reports is unchanged by this feature
- If a version bump to `4` is introduced, the template must document that v3 reports are grandfathered
- The new section's position in the canonical section order should be documented (I recommend placing it after "External Skills" and before "Working Files," since it's a session metadata section)

**Recommendation**: Do NOT bump the template version for this change. It is purely additive. A new optional section does not invalidate old reports. Reserve version bumps for breaking changes (renamed fields, removed sections, changed semantics of existing fields).

### 4. Report Writing Checklist Update

A new step should be added between current steps 14 and 15 (after "Write External Skills" and before "Write Working Files"). Proposed:

```
14a. Write Skills & Tools (collapsible; list skills invoked during session with classification;
     include tool usage counts table if extractable from conversation context, omit gracefully if not)
```

The verification guidance in SKILL.md's Data Accumulation section also needs a new tracking item. At the **"At Wrap-up"** boundary, add:

```
- Skills invoked during session (name, classification: LEAF/ORCHESTRATION/PROJECT-LOCAL)
- Tool usage summary (best-effort: tool names and approximate counts from conversation context)
```

This naturally integrates with the existing data accumulation flow without adding new phases or hooks.

## Proposed Tasks

### Task 1: Add Skills & Tools section to TEMPLATE.md

**What to do**: Add the new section to the template skeleton, conditional inclusion rules table, collapsibility rules table, and formatting rules. Place it after External Skills and before Working Files.

**Deliverables**:
- Updated skeleton with new section including tool counts sub-table
- New row in Conditional Section Rules table
- New row in Collapsibility Rules table (collapsed by default)
- Formatting guidance for the section (how to handle missing counts, cap large tables)

**Dependencies**: None -- this is the foundational template change.

### Task 2: Update SKILL.md Data Accumulation and Wrap-up

**What to do**: Add skills/tools tracking to the Data Accumulation section (At Wrap-up boundary) and update the Wrap-up Sequence step 6 to reference the new section.

**Deliverables**:
- New tracking items in "At Wrap-up" data accumulation
- Updated wrap-up step 6 guidance to include the new section
- Guidance on best-effort tool count extraction from conversation context

**Dependencies**: Task 1 (template must define the section structure first).

### Task 3: Update Report Writing Checklist

**What to do**: Add step 14a to the checklist in TEMPLATE.md.

**Deliverables**:
- New checklist step with clear instructions for conditional inclusion

**Dependencies**: Task 1 (section structure must be defined first). Can be combined with Task 1 if the same agent handles both.

### Task 4: Validate backwards compatibility with existing reports

**What to do**: Spot-check 3-5 existing reports (pick one advisory, one full with external skills, one full without, one partial/aborted if available) and confirm:
1. No required fields or sections were added that would make old reports invalid
2. Template version remains at 3
3. Section ordering of existing sections is unchanged

**Deliverables**:
- Brief validation summary confirming additive-only changes
- List of reports checked and confirmation of compatibility

**Dependencies**: Tasks 1-3 (must validate the final state after all changes are applied).

## Risks and Concerns

### Risk 1: Tool count data reliability (MEDIUM)

Extracting tool counts from conversation context is inherently imprecise. The calling session can observe its own tool invocations in the conversation history, but:
- Subagent tool usage is not directly visible to the parent session
- Conversation compaction may lose tool invocation details
- Different Claude Code versions may expose tool usage differently

**Mitigation**: The issue already frames tool counts as "best-effort." The template and SKILL.md guidance must reinforce this framing: present counts when available, omit when not, never fabricate. The report writer should NOT spend significant time manually counting tool invocations.

### Risk 2: Section proliferation in reports (LOW)

This adds another section to an already lengthy report template (12 top-level H2 sections). If tool data is sparse ("nefario skill used, no tool counts"), the section adds noise without value.

**Mitigation**: Collapsibility by default. Also consider a minimum-content threshold: if the only skill is nefario itself and no tool counts are available, the section could be omitted entirely. But this adds conditional complexity. Simpler to just collapse it.

### Risk 3: Confusion between "External Skills" and "Skills & Tools" sections (MEDIUM)

Two sections referencing "skills" creates ambiguity. External Skills tracks *discovery*; the new section tracks *usage*.

**Mitigation**: Clear naming. "External Skills" stays as-is (it has a specific semantic: skills discovered during meta-plan). The new section should be named something distinct like "Session Resources" or "Skills & Tools Used" to differentiate. Alternatively, consider merging the two: extend External Skills to also track invocation status and add tool counts. But this changes the semantics of an existing section, which conflicts with the additive-only constraint.

**Recommendation**: Name the new section "Skills & Tools Used" (emphasizing "used" vs. "discovered"). Add a one-line note in the template distinguishing it from External Skills: "External Skills records skills discovered during meta-plan; this section records skills and tools actually invoked during the session."

### Risk 4: Template version ambiguity (LOW)

If this change does not bump to version 4, there is no way for tooling to distinguish "v3 without this section" from "v3 with this section." This only matters if automated tooling parses reports.

**Mitigation**: Currently no automated tooling parses report bodies (build-index.sh only parses frontmatter). The risk is theoretical. If it becomes practical, a minor version scheme (3.1) could disambiguate without a breaking change.

## Additional Agents Needed

**devx-minion**: Should review the proposed section structure for consistency with how Claude Code exposes tool usage to the calling session. They have practical knowledge of what data is actually extractable from conversation context -- this directly impacts whether tool counts are feasible in practice or just aspirational.

Beyond that, the current team is sufficient. The template and SKILL.md changes are documentation/configuration tasks well within the capabilities of the agents already involved.
