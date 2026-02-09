# Nefario Execution Report Template

This template defines the format for execution reports generated after nefario orchestration runs. Reports document the planning process, decisions made, and execution outcomes.

## File Naming Convention

Reports are written to `nefario/reports/<YYYY-MM-DD>-<NNN>-<slug>.md`:

- `<YYYY-MM-DD>`: date of orchestration
- `<NNN>`: zero-padded sequence number. Determine by globbing `nefario/reports/<YYYY-MM-DD>-*.md` and counting. First report of the day is 001, second is 002, etc.
- `<slug>`: kebab-case, lowercase, max 40 chars, derived from task description. Strip articles (a/an/the). Only alphanumeric characters and hyphens. No path separators or special characters.

Create `nefario/reports/` directory if it doesn't exist.

## YAML Frontmatter

Reports use exactly 10 fields in the frontmatter:

```yaml
---
type: nefario-report
version: 1
date: "<YYYY-MM-DD>"
sequence: <N>
task: "<one-line task description>"
mode: full | plan
agents-involved: [<list>]
task-count: <N>
gate-count: <N>
outcome: completed | partial | aborted
---
```

### Field Descriptions

- **type**: Always `nefario-report`
- **version**: Template version, currently `1`
- **date**: Orchestration date in YYYY-MM-DD format
- **sequence**: Zero-padded sequence number (001, 002, etc.)
- **task**: One-line description of the orchestration task
- **mode**: `full` (all phases) or `plan` (planning only, no execution)
- **agents-involved**: Array of agent names that participated
- **task-count**: Number of execution tasks in the plan
- **gate-count**: Number of approval gates presented
- **outcome**: `completed`, `partial`, or `aborted`

## Body Structure

The report body uses three-layer progressive disclosure:

### Layer 1 — Header Block (max 15 lines)

A markdown table with key metrics:

```markdown
| Metric | Value |
|--------|-------|
| Date | YYYY-MM-DD |
| Task | One-line description |
| Duration | ~Xm (approximate minutes) |
| Outcome | completed/partial/aborted |
| Planning Agents | N agents consulted |
| Review Agents | N reviewers |
| Execution Agents | N agents spawned |
| Gates Presented | N of M approved |
| Files Changed | N created, M modified |
| Outstanding Items | N items |
```

### Layer 2 — Executive Summary + Decisions

**Executive Summary**: 2-3 sentence summary of what was accomplished.

**Decisions**: For each significant decision made during orchestration:

```markdown
#### [Decision Title]

**Rationale**:
- Key point 1
- Key point 2
- Key point 3

**Alternatives Rejected**:
- Alternative 1 and why it was rejected
- Alternative 2 and why it was rejected
```

**Conflict Resolutions**: If any conflicts arose between specialist recommendations, document how they were resolved. If none, state "None".

### Layer 3 — Process Detail

Detailed breakdowns in separate sections:

#### Phases Executed

Table showing which phases ran and which agents participated:

```markdown
| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | agent1, agent2, agent3 |
| Synthesis | nefario |
| Architecture Review | reviewer1, reviewer2 |
| Execution | executor1, executor2 |
```

#### Files Created/Modified

Table of file system changes:

```markdown
| File Path | Action | Description |
|-----------|--------|-------------|
| /path/to/file | created | What this file does |
| /path/to/other | modified | What changed |
```

If no files changed: "None"

#### Approval Gates

Table of gates presented during execution:

```markdown
| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Choose framework | tech-stack-minion | MEDIUM | approved | 1 |
| API contract | api-design-minion | HIGH | approved | 1 |
```

If no gates: "None"

#### Outstanding Items

Markdown checklist of items not completed:

```markdown
- [ ] Outstanding item 1
- [ ] Outstanding item 2
```

If none: "None"

#### Timing

Table with approximate phase durations (use `~` prefix):

```markdown
| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~8m |
| Synthesis | ~3m |
| Architecture Review | ~5m |
| Execution | ~15m |
| **Total** | **~33m** |
```

## Index File Update

After writing the report, update `nefario/reports/index.md`.

If index.md doesn't exist, create it with:

```markdown
# Nefario Orchestration Reports

Reports from nefario orchestration runs.

| Date | Seq | Task | Outcome | Agents |
|------|-----|------|---------|--------|
```

Prepend a new row to the table with:
- Date (YYYY-MM-DD)
- Sequence (NNN)
- Task (slug as markdown link to report file: `[slug](YYYY-MM-DD-NNN-slug.md)`)
- Outcome (completed/partial/aborted)
- Agent count (total agents involved)

Example row:
```markdown
| 2026-02-09 | 001 | [extract-report-template](2026-02-09-001-extract-report-template.md) | completed | 2 |
```

## Incremental Writing

For long-running orchestrations, write a partial report after Phase 3 (synthesis). Include available data and mark sections as "In Progress". Overwrite with the complete report at wrap-up.

## Report Writing Checklist

When generating a report:

1. ✅ Collect all accumulated data from phase boundaries
2. ✅ Generate filename slug (kebab-case, strip articles, max 40 chars)
3. ✅ Determine sequence number by globbing existing reports for today
4. ✅ Write YAML frontmatter with all 10 fields
5. ✅ Write Layer 1 header block table
6. ✅ Write Layer 2 executive summary and decisions
7. ✅ Write Layer 3 process detail sections
8. ✅ Update index.md with new row (prepend, newest first)
9. ✅ Present report path to user
