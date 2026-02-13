## Domain Plan Contribution: devx-minion

### Recommendations

#### 1. Separate section, not merged into External Skills

The existing **External Skills** section tracks *project-local skills discovered during meta-plan* (despicable-lab, despicable-statusline, etc.) -- skills that are external to the nefario orchestration workflow. The new section tracks something different: *which skills the calling session actually invoked during the orchestration* (e.g., `/nefario` itself, `/despicable-lab` if used for a rebuild step). These are orthogonal concerns:

- **External Skills** = "what project-local skills did the meta-plan discover?"
- **Session Resources** (proposed name) = "what skills and tools did the session actually use?"

Merging them would conflate discovery (External Skills) with usage (Session Resources). Keep them as separate H2 sections.

#### 2. Rename the section "Session Resources" (not "Skills and Tools")

"Session Resources" is concise, scannable, and forward-compatible if other resource types are tracked later (e.g., MCP servers, web fetches). It also avoids the word "skills" which would create ambiguity with the existing External Skills section.

#### 3. Two subsections: Skills Invoked and Tool Usage

Within `## Session Resources`, use two subsections:

**Skills Invoked** -- a simple list (not a table). Skills are low-cardinality (typically 1-3 per session). A table adds visual weight for no scanning benefit.

```markdown
### Skills Invoked

- `/nefario` -- orchestration workflow
- `/despicable-lab` -- agent rebuild (task 3)
```

If no skills beyond `/nefario` itself were invoked: `- /nefario -- orchestration workflow` (always present; it is the minimum).

**Tool Usage** -- a table with session-total counts. Per-phase or per-agent granularity is impractical (the calling session cannot reliably attribute tool calls to phases after the fact, and the overhead of tracking per-phase counts contradicts the "best-effort" constraint). Session totals are extractable from conversation context by scanning backward.

```markdown
### Tool Usage

| Tool | Count |
|------|-------|
| Task (subagent) | 14 |
| Read | 23 |
| Edit | 8 |
| Write | 5 |
| Bash | 12 |
| Grep | 6 |
| Glob | 3 |
```

Rationale for session-total granularity:
- **Per-phase**: Requires tracking tool calls across compaction boundaries and attributing them to phases -- fragile and likely to produce inaccurate numbers. The data accumulation model stores summaries at phase boundaries, not per-call telemetry.
- **Per-agent**: Subagent tool calls are invisible to the calling session (Task tool returns the result, not the internal call log). Only the calling session's own tool calls are visible.
- **Session-total**: The calling session can enumerate its own tool calls from conversation context. Simple, accurate, and sufficient for retrospective analysis.

#### 4. Graceful degradation when tool counts are unavailable

If tool counts cannot be reliably extracted (e.g., context was heavily compacted, or the session is being written from partial data):

```markdown
### Tool Usage

Tool counts not available for this session.
```

One line, no table. The section header still appears so the report structure is consistent across all reports. This follows the same pattern used elsewhere in the template (e.g., "Skipped (no test infrastructure)" for Phase 6).

#### 5. Relationship to `agents-involved` frontmatter

`agents-involved` lists which agents participated. This is conceptually distinct from skills invoked (skills are not agents) and tool usage (tools are infrastructure). No redundancy. No changes to `agents-involved` needed.

However, consider adding a `skills-invoked` field to the YAML frontmatter for machine-parseable access:

```yaml
skills-invoked: [nefario, despicable-lab]
```

This enables the build-index.sh script to include skills data in the index without parsing markdown body. The field should be a simple array of skill names (without `/` prefix, matching the kebab-case convention used in `agents-involved`). Mark it as conditional: INCLUDE WHEN skills were invoked, OMIT WHEN only `/nefario` was used (since `/nefario` is always implicit for nefario reports).

Actually, on reflection: `/nefario` is *always* invoked in a nefario report. Including it as a frontmatter field only when *additional* skills were used avoids noise. If the team prefers consistency (always present), that works too -- but the conditional approach is leaner.

#### 6. Placement in the template

Place `## Session Resources` after `## External Skills` and before `## Working Files`. This groups all metadata/context sections together at the bottom of the report, and creates a natural reading flow: External Skills (what was discovered) then Session Resources (what was actually used).

If External Skills is omitted (none discovered), Session Resources still appears in its canonical position.

#### 7. Data accumulation instructions

Add to the **At Wrap-up** boundary in SKILL.md Data Accumulation:

```
**At Wrap-up**:
- Outstanding items
- Approximate total duration
- Skills invoked during session (scan conversation for /skill invocations)
- Tool usage counts (best-effort: scan conversation context for tool calls,
  tally by tool name. If context was compacted, note "not available")
```

This is lightweight -- it happens once at wrap-up, not at every phase boundary. The calling session scans its own conversation context, which is the only reliable source for this data.

#### 8. Report Writing Checklist update

Add a new step after step 14 (External Skills) and before step 15 (Working Files):

```
14a. Write Session Resources (Skills Invoked list + Tool Usage table; degrade
     gracefully if tool counts unavailable)
```

### Proposed Tasks

#### Task 1: Update TEMPLATE.md with Session Resources section

**What**: Add the `## Session Resources` section skeleton to TEMPLATE.md, including `### Skills Invoked` (list format) and `### Tool Usage` (table format with graceful degradation). Add conditional inclusion rule and formatting rules to Template Notes. Add optional `skills-invoked` frontmatter field.

**Deliverables**:
- Updated `docs/history/nefario-reports/TEMPLATE.md`

**Dependencies**: None (can start immediately).

#### Task 2: Update SKILL.md Data Accumulation and Report Writing Checklist

**What**: Add skills-invoked and tool-usage-counts to the "At Wrap-up" boundary in Data Accumulation. Add step 14a to the Report Writing Checklist. Add brief guidance on how the calling session should scan for these data points.

**Deliverables**:
- Updated `skills/nefario/SKILL.md` (Data Accumulation section, Report Writing Checklist section)

**Dependencies**: Task 1 (template defines the target format that the SKILL.md instructions reference).

### Risks and Concerns

1. **Tool count accuracy after compaction**: Long orchestration sessions trigger context compaction, which may discard individual tool call records. The "best-effort" framing and graceful degradation mitigate this, but early sessions may show inconsistent data quality. This is acceptable per the issue's success criteria ("best-effort -- included if extractable, omitted gracefully if not").

2. **Subagent tool usage is invisible**: The calling session sees `Task` tool calls but not the tools used *within* subagent sessions. This means tool counts reflect the orchestrator's direct tool usage, not the full session tree. This is a known limitation and should be documented explicitly in the template notes so report readers do not misinterpret the numbers.

3. **`/nefario` is always invoked**: Every nefario report implies `/nefario` was invoked. Including it in Skills Invoked is technically redundant but aids completeness and consistency. If omitted, the section would often be empty or say "None beyond /nefario" which reads awkwardly. Recommendation: always list `/nefario` as the first entry.

4. **Frontmatter field adds schema complexity**: Adding `skills-invoked` to YAML frontmatter means build-index.sh would need updating. If the index script is considered out of scope, the frontmatter field can be deferred. The markdown body section is sufficient for human readers.

5. **No backward incompatibility**: The new section is purely additive. Existing reports without it remain valid per the issue's success criteria. The conditional inclusion rule ("INCLUDE WHEN session resource data was collected") ensures old reports are not broken.

### Additional Agents Needed

None. The current team is sufficient. This is a template/documentation change with no code generation, infrastructure, or security implications beyond what the planning question already covers. If `build-index.sh` changes are in scope (for the frontmatter field), a code-review-minion pass during Phase 5 would cover it.
