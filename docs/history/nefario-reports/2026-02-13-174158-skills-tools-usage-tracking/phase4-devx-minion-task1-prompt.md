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
<summary>Session resources ({N} skills, {M} tool types)</summary>

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

Note: The `<summary>` tag includes inline counts (e.g., "Session resources (2 skills, 5 tool types)") so users can assess whether to expand the collapsed section without opening it.

### 3. Update Conditional Section Rules table

Replace the External Skills row with these rows:
```
| Session Resources | Always (section is structurally present in all reports) | Never omitted entirely |
| Session Resources: External Skills subsection | Meta-plan discovered 1+ external skills | No external skills discovered |
| Session Resources: Skills Invoked subsection | Always included | Never omitted |
| Session Resources: Tool Usage subsection | `mode` != `advisory` AND tool counts extractable | `mode` = `advisory` OR counts not available |
```

Important: The Skills Invoked subsection is always included (even in advisory mode). The Tool Usage subsection is omitted in advisory mode -- this is a structural rule, not a formatting edge case. The advisory mode omission takes precedence over the formatting fallback ("Tool counts not available for this session.").

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
- **Session Resources**: Always collapsed. Summary tag includes inline counts
  (e.g., "Session resources (2 skills, 5 tool types)"). Skills Invoked list
  always includes `/nefario` as first entry. Tool Usage table omits tools
  with zero usage. If tool counts are not available (e.g., context was heavily
  compacted), replace the Tool Usage subsection with: "Tool counts not
  available for this session." If the entire section would contain only
  `/nefario` in Skills Invoked and no other data, the section still appears
  (collapsed) for structural consistency. In advisory mode, the Tool Usage
  subsection is omitted entirely (not replaced with a fallback message).
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
- The `<summary>` tag includes inline count placeholders
- `skills-used` appears in frontmatter fields table with conditional inclusion rule
- Conditional Section Rules table has entries for Session Resources and all three subsections
- Collapsibility Rules table includes Session Resources as collapsed
- Report Writing Checklist step 14 references Session Resources
- Formatting Rules include Session Resources guidance
- No version bump

When you finish, mark task #1 completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
