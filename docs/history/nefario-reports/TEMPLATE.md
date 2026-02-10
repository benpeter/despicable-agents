# Nefario Execution Report Template

This template defines the format for execution reports generated after nefario orchestration runs. Reports document the planning process, decisions made, and execution outcomes.

## File Naming Convention

Reports are written to `docs/history/nefario-reports/<YYYY-MM-DD>-<HHMMSS>-<slug>.md`:

- `<YYYY-MM-DD>`: date of orchestration
- `<HHMMSS>`: local time at report creation, 24-hour format, zero-padded (e.g., `143022` for 2:30:22 PM). Capture this timestamp at wrap-up time when the report is actually written, not at Phase 1.
- `<slug>`: kebab-case, lowercase, max 40 chars, derived from task description. Strip articles (a/an/the). Only alphanumeric characters and hyphens.

Create `docs/history/nefario-reports/` directory if it doesn't exist.

## YAML Frontmatter

Reports use exactly 10 fields in the frontmatter:

```yaml
---
type: nefario-report
version: 2 # v1 reports coexist -- build-index.sh reads both
date: "<YYYY-MM-DD>"
time: "HH:MM:SS"
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
- **version**: Template version, currently `2`
- **date**: Orchestration date in YYYY-MM-DD format
- **time**: Local time of report generation in HH:MM:SS format (24-hour)
- **task**: One-line description of the orchestration task
- **mode**: `full` (all phases) or `plan` (planning only, no execution)
- **agents-involved**: Array of agent names that participated
- **task-count**: Number of execution tasks in the plan
- **gate-count**: Number of approval gates presented
- **outcome**: `completed`, `partial`, or `aborted`

## Body Structure

The report body uses an inverted pyramid: most important information first, detail last.

### 1. Report Title

```markdown
# <task frontmatter value>
```

### 2. Summary

2-3 sentences. What happened and why it matters. A PR reviewer reads this and knows whether to care.

```markdown
## Summary

Replaced sequential numbering with timestamps in report filenames and replaced
manual index mutation with an idempotent build script. This eliminates both the
TOCTOU race and merge conflicts during parallel orchestration.
```

### 3. Original Prompt

The verbatim user request in a blockquote. Use the text that was passed to nefario (may already be cleaned by despicable-prompter).

The PR description inherits this section automatically, since the PR body is derived from the report body (stripped frontmatter). Renaming here propagates to the PR.

**SECURITY NOTE**: Before including the verbatim prompt, remove any secrets, tokens, API keys, or credentials that may have been in the original text. Replace with `[REDACTED]`.

**Short prompts (<20 lines)** -- inline blockquote:

```markdown
## Original Prompt

> Eliminate merge conflicts when multiple nefario sessions generate reports
> in parallel. The current sequence-number approach has a TOCTOU race.
```

**Long prompts (>=20 lines)** -- collapsible:

```markdown
## Original Prompt

<details>
<summary>Original prompt (expand)</summary>

> Full verbatim prompt here, redacted of any secrets.
> Can span many lines.

</details>
```

### 4. Decisions

Key choices made during planning and execution.

**Non-gate decisions** use the existing format:

```markdown
## Decisions

#### Timestamps Over Sequence Numbers

**Rationale**:
- Timestamps require no coordination between sessions
- Sub-second collision probability is negligible
- Filenames remain human-readable and sort chronologically

**Alternatives Rejected**:
- UUID-based filenames: not human-readable, don't sort chronologically
- Lock file protocol: doesn't solve git merge conflicts across branches
```

**Gate decision briefs** include outcome and confidence fields:

```markdown
#### Naming + Index Strategy

**Rationale**:
- Timestamps eliminate coordination needs
- Idempotent index regeneration removes concurrent-write conflicts
- Rejected append-only index due to ordering and conflict issues

**Gate outcome**: approved
**Confidence**: HIGH
```

**Conflict Resolutions**: If any conflicts arose between specialist recommendations, document how they were resolved. If none, state "None".

### 5. Agent Contributions

Inside a collapsible `<details>` block. Summary line states counts.

```markdown
## Agent Contributions

<details>
<summary>Agent Contributions (2 planning, 6 review)</summary>

### Planning

**devx-minion**: Recommended timestamp-based filenames for conflict-free parallel writes.
- Adopted: HHMMSS naming convention, idempotent index script
- Risks flagged: sub-second collisions (accepted as negligible)

**data-minion**: Analyzed frontmatter parsing requirements for generated index.
- Adopted: POSIX shell script reading YAML frontmatter
- Risks flagged: none

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: ADVISE. Recommended adding a test for duplicate timestamp detection; accepted as future work.

**ux-strategy-minion**: APPROVE. No concerns.

**software-docs-minion**: APPROVE. No concerns.

**lucy**: APPROVE. Consistent with existing conventions.

**margo**: BLOCK. Flagged unnecessary complexity in dual-format fallback. Resolved: kept minimal 5-line handler for legacy reports.

</details>
```

Important: blank line after `<summary>` and before `</details>` for GitHub rendering.

Proportional detail by verdict:
- **APPROVE** = 1 line: `**agent**: APPROVE. No concerns.`
- **ADVISE** = 2-3 lines: verdict + concern + recommendation
- **BLOCK** = 3-4 lines: verdict + issue + resolution

### 6. Execution

Files changed table and approval gates with enriched briefs.

```markdown
## Execution

### Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| docs/history/nefario-reports/build-index.sh | created | POSIX shell script to regenerate index |
| docs/history/nefario-reports/TEMPLATE.md | modified | Updated naming convention |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Naming + Index Strategy | nefario | HIGH | approved | 1 |

#### Naming + Index Strategy

**Decision**: Adopt timestamp naming with idempotent index regeneration.
**Rationale**: Eliminates coordination between sessions; frontmatter already contains all data needed for index.
**Rejected**: Append-only index (still conflicts), UUID filenames (not human-readable).
```

If no files changed: "None". If no gates: "None".

### 7. Process Detail

Inside a collapsible `<details>` block.

```markdown
## Process Detail

<details>
<summary>Process Detail</summary>

### Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | devx-minion, data-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, lucy, margo |
| Execution | devx-minion (5 tasks) |
| Code Review | code-review-minion, lucy, margo |
| Test Execution | (skipped -- no tests exist) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- docs were the primary deliverables) |

Conditional phases that did not run use the format: `(skipped -- <reason>)` in the Agents column.

### Verification

| Phase | Result |
|-------|--------|
| Code Review | 0 BLOCK, 2 ADVISE -- all resolved |
| Test Execution | 42 pass, 0 fail, 2 skip |
| Deployment | (skipped -- not requested) |
| Documentation | 2 files created, 1 modified |

For phases that did not run, use the skipped format: `(skipped -- <reason>)`.

### Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~8m |
| Synthesis | ~3m |
| Architecture Review | ~5m |
| Execution | ~15m |
| Code Review | ~4m |
| Test Execution | ~3m |
| Deployment | (skipped) |
| Documentation | ~5m |
| **Total** | **~45m** |

### Outstanding Items

- [ ] Outstanding item 1
- [ ] Outstanding item 2

If none: "None"

</details>
```

Important: blank line after `<summary>` and before `</details>` for GitHub rendering.

### 8. Working Files

Preserved intermediate artifacts from the orchestration run. Inside a
collapsible `<details>` block.

When a companion directory exists (scratch files were collected at wrap-up):

```markdown
## Working Files

<details>
<summary>Working files (N files)</summary>

Companion directory: [<YYYY-MM-DD>-<HHMMSS>-<slug>/](./<YYYY-MM-DD>-<HHMMSS>-<slug>/)

- [Phase 1: Meta-plan](./companion-dir/phase1-metaplan.md)
- [Phase 2: devx-minion](./companion-dir/phase2-devx-minion.md)
- [Phase 2: software-docs-minion](./companion-dir/phase2-software-docs-minion.md)
- [Phase 3: Synthesis](./companion-dir/phase3-synthesis.md)
- [Phase 3.5: security-minion](./companion-dir/phase3.5-security-minion.md)
- ...

</details>
```

When no companion directory exists (no scratch files for this run):

```markdown
## Working Files

None
```

Important notes for the template:
- The companion directory is a sibling directory in the same
  `docs/history/nefario-reports/` folder, named as the report filename
  without `.md` (e.g., `2026-02-10-143322-slug/`)
- Relative links use `./companion-dir/filename.md` format
- File list is generated from whatever files actually exist in the companion
  directory -- not a fixed set
- Label convention: `Phase N: description` where description is derived from
  filename (phase1-metaplan -> "Meta-plan", phase2-{agent} -> agent name,
  phase3-synthesis -> "Synthesis", phase3.5-{agent} -> agent name,
  prompt.md -> "Original Prompt")
- N in the summary line is the actual file count
- Blank line after `<summary>` and before `</details>` for GitHub rendering
- Section is ABSENT for existing/older reports (backward compatibility:
  absence = no working files)

### 9. Metrics

Reference data table (same fields as v1 Layer 1 header block).

```markdown
## Metrics

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

## Index File

The report index (`docs/history/nefario-reports/index.md`) is a derived view
generated automatically by CI on push to main. It is not committed from branches
and is not part of the orchestration workflow.

The index is built by `docs/history/nefario-reports/build-index.sh`, which reads
YAML frontmatter from all report files and produces a chronological table. The
script is idempotent -- running it multiple times produces the same output.

To preview the index locally before pushing (optional): `docs/history/nefario-reports/build-index.sh`

## Incremental Writing

For long-running orchestrations, write a partial report after Phase 3 (synthesis). Include available data and mark sections as "In Progress". Overwrite with the complete report at wrap-up.

## Report Writing Checklist

When generating a report:

1. Collect all accumulated data from phase boundaries
2. Generate filename slug (kebab-case, strip articles, max 40 chars)
3. Capture current local time as HHMMSS for filename
4. Sanitize verbatim prompt (redact secrets/tokens/keys)
5. Write YAML frontmatter with all 10 fields (version: 2)
6. Write Summary
7. Write Original Prompt (verbatim prompt, inline if <20 lines, collapsible if >=20 lines)
8. Write Decisions (with enriched gate briefs including rationale + rejected alternatives)
9. Write Agent Contributions (collapsible, 2 groups: Planning + Architecture Review)
10. Write Execution (files + gates)
11. Write Process Detail (collapsible, includes Verification)
12. Write Working Files section (collapsible, list all files in companion directory with phase labels; or "None" if no companion directory)
13. Write Metrics
14. Present report path to user
