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

Important naming note: The accumulation item is called `skills-invoked` (what
we track in session context). The frontmatter field is called `skills-used`
(what appears in the report YAML). These are different names for the same data
flowing through different contexts. Make this mapping clear in the
accumulation instructions.

## What to Do

Read `skills/nefario/SKILL.md` and make these changes:

### 1. Update Data Accumulation -- "At Wrap-up" boundary

Find the "At Wrap-up" section in Data Accumulation. Add two new items after
the existing bullet points:

```
- `skills-invoked`: list of skills invoked during the session. Always includes
  `/nefario`. Add any other skills the session invoked (e.g., `/despicable-lab`,
  `/despicable-prompter`). Scan conversation context for skill invocations
  (look for Skill tool calls). For each: skill name and brief usage context.
  This data populates the Skills Invoked subsection in the report body.
  When writing the `skills-used` frontmatter field, include only skills beyond
  `/nefario` (which is implicit for all nefario reports). If only `/nefario`
  was invoked, omit the `skills-used` frontmatter field entirely.
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

Find the Phase 3.5 compaction checkpoint focus string (around the Phase 3.5
compaction checkpoint section). Add `skills-invoked` to the "Preserve:" list.
It belongs after `scratch directory path` in the preserve list. The
orchestrator-tools tally does not need preservation at Phase 3.5 (it is
computed at wrap-up from conversation context, not accumulated incrementally).

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
- The `skills-invoked` item notes the mapping to `skills-used` frontmatter field
- The `skills-invoked` item notes that `/nefario` should be excluded from the frontmatter field
- Wrap-up Sequence step 6 references Session Resources with all three subsections
- The old External Skills standalone instruction is replaced with the subsection reference
- Phase 3.5 compaction focus string includes `skills-invoked`
- Section count reference is accurate

When you finish, mark task #2 completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
