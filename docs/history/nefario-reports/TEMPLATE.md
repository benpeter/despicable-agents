# Nefario Execution Report Template (v3)

Canonical template for nefario execution reports. Referenced from
`skills/nefario/SKILL.md`. All reports must follow this skeleton.

## Skeleton

```markdown
---
type: nefario-report
version: 3
date: "{YYYY-MM-DD}"
time: "{HH:MM:SS}"
task: "{one-line task description}"
source-issue: {N}
mode: {full | plan}
agents-involved: [{agent1}, {agent2}, ...]
task-count: {N}
gate-count: {N}
outcome: {completed | partial | aborted}
---

# {task}

## Summary

{2-3 sentences. What happened and why it matters. A PR reviewer reads this and knows whether to care.}

## Original Prompt

> {Verbatim user request, redacted of secrets. If >=20 lines, wrap in <details> instead of blockquote.}

## Key Design Decisions

#### {Decision Title}

**Rationale**:
- {Why this choice was made}
- {Supporting reasoning}

**Alternatives Rejected**:
- {Alternative}: {why rejected}

#### {Decision Title 2}

**Rationale**:
- {Why}

**Alternatives Rejected**:
- {Alternative}: {why rejected}

### Conflict Resolutions

{Description of conflicts between specialist recommendations and how they were resolved. "None." if no conflicts arose.}

## Phases

{Narrative account of the orchestration arc. 1-2 paragraphs per phase. NOT tables.}

### Phase 1: Meta-Plan

{What was identified: specialists selected, scope defined, risks anticipated.}

### Phase 2: Specialist Planning

{Per-specialist summary of recommendations, adopted items, and risks flagged.}

### Phase 3: Synthesis

{How specialist input was merged. Conflicts, agreements, final plan shape.}

### Phase 3.5: Architecture Review

{Reviewer count and verdicts. Brief per-reviewer summary.}

### Phase 4: Execution

{What was executed, by whom. Brief per-task summary.}

### Phase 5: Code Review

{Reviewer verdicts and key findings.}

### Phase 6: Test Execution

{Test results or "Skipped ({reason})."}

### Phase 7: Deployment

{Deployment outcome or "Skipped ({reason})."}

### Phase 8: Documentation

{Documentation outcome or "Skipped ({reason})."}

## Agent Contributions

<details>
<summary>Agent Contributions ({N} planning, {N} review)</summary>

### Planning

**{agent-name}**: {Recommendation summary.}
- Adopted: {items adopted into final plan}
- Risks flagged: {risks identified, or "none"}

**{agent-name}**: {Recommendation summary.}
- Adopted: {items adopted}
- Risks flagged: {risks}

### Architecture Review

**{agent-name}**: APPROVE. No concerns.

**{agent-name}**: ADVISE. {Concern and recommendation.}

**{agent-name}**: BLOCK. {Issue identified.} Resolved: {resolution.}

### Code Review

**{agent-name}**: APPROVE. {Brief note.}

**{agent-name}**: ADVISE. {Finding and resolution.}

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | {task description} | {agent} | {completed/partial/failed} |
| 2 | {task description} | {agent} | {completed/partial/failed} |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [{display-path}]({relative-link}) | {created/modified/deleted} | {what changed} |
| [{display-path}]({relative-link}) | {created/modified/deleted} | {what changed} |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| {gate title} | {agent} | {HIGH/MEDIUM/LOW} | {approved/rejected} | {N} |

#### {Gate Title}

**Decision**: {What was decided.}
**Rationale**: {Why this decision was made.}
**Rejected**: {Alternatives considered and why rejected.}

## Decisions

{Gate briefs with full rationale. One H4 per gate.}

#### {Gate Title}

**Decision**: {What was decided.}
**Rationale**: {Full reasoning.}
**Rejected**: {Alternatives and why.}
**Confidence**: {HIGH/MEDIUM/LOW}
**Outcome**: {approved/rejected}

## Verification

| Phase | Result |
|-------|--------|
| Code Review | {outcome} |
| Test Execution | {outcome or "Skipped ({reason})"} |
| Deployment | {outcome or "Skipped ({reason})"} |
| Documentation | {outcome or "Skipped ({reason})"} |

## External Skills

| Skill | Classification | Recommendation | Tasks Used |
|-------|---------------|----------------|------------|
| {skill-name} | {LEAF/ORCHESTRATION} | {how it was used} | {task numbers} |

## Working Files

<details>
<summary>Working files ({N} files)</summary>

Companion directory: [{YYYY-MM-DD}-{HHMMSS}-{slug}/](./{YYYY-MM-DD}-{HHMMSS}-{slug}/)

- [Original Prompt](./companion-dir/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./companion-dir/phase1-metaplan.md)
- [Phase 2: {agent-name}](./companion-dir/phase2-{agent-name}.md)
- [Phase 3: Synthesis](./companion-dir/phase3-synthesis.md)
- [Phase 3.5: {agent-name}](./companion-dir/phase3.5-{agent-name}.md)
- [Phase 5: {agent-name}](./companion-dir/phase5-{agent-name}.md)
- [Phase 6: Test results](./companion-dir/phase6-test-results.md)
- [Phase 7: Deployment](./companion-dir/phase7-deployment.md)
- [Phase 8: Checklist](./companion-dir/phase8-checklist.md)
- [Phase 8: {agent-name}](./companion-dir/phase8-{agent-name}.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./companion-dir/phase1-metaplan-prompt.md)
- [Phase 2: {agent-name} prompt](./companion-dir/phase2-{agent-name}-prompt.md)
- [Phase 3: Synthesis prompt](./companion-dir/phase3-synthesis-prompt.md)
- [Phase 3.5: {agent-name} prompt](./companion-dir/phase3.5-{agent-name}-prompt.md)
- [Phase 4: {agent-name} prompt](./companion-dir/phase4-{agent-name}-prompt.md)
- [Phase 5: {agent-name} prompt](./companion-dir/phase5-{agent-name}-prompt.md)
- [Phase 8: {agent-name} prompt](./companion-dir/phase8-{agent-name}-prompt.md)

</details>

## Test Plan

{Description of tests produced or modified. Table or prose as appropriate.}

## Post-Nefario Updates

### {YYYY-MM-DD}: {brief description}

{What changed and why. Reference commit or PR.}
```

## Template Notes

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `type` | always | Always `nefario-report` |
| `version` | always | Template version: `3` |
| `date` | always | Orchestration date, `YYYY-MM-DD` |
| `time` | always | Local time of report generation, `HH:MM:SS` (24-hour) |
| `task` | always | One-line task description |
| `source-issue` | conditional | GitHub issue number. INCLUDE WHEN input was a GitHub issue. OMIT WHEN no issue. |
| `mode` | always | `full` (all phases) or `plan` (planning only) |
| `agents-involved` | always | Array of agent names that participated |
| `task-count` | always | Number of execution tasks |
| `gate-count` | always | Number of approval gates presented |
| `outcome` | always | `completed`, `partial`, or `aborted` |

### Conditional Section Rules

| Section | INCLUDE WHEN | OMIT WHEN |
|---------|-------------|-----------|
| Decisions | `gate-count` > 0 | `gate-count` = 0 |
| External Skills | Meta-plan discovered 1+ external skills | No external skills discovered |
| Test Plan | Execution produced test files or test strategy decisions were made | No tests involved |
| Post-Nefario Updates | NEVER in initial report. Appending updates to an existing report after subsequent commits land on the same branch. | Always omit in initial report generation. |

### Collapsibility Rules

| Section | Collapsed (`<details>`) | Always Visible |
|---------|------------------------|----------------|
| Agent Contributions | yes | |
| Working Files | yes | |
| Original Prompt | only when >= 20 lines | when < 20 lines (use blockquote) |
| All other sections | | yes |

Blank line required after `<summary>` tag and before `</details>` for GitHub
rendering compatibility.

### Formatting Rules

- **Review verdict proportional detail**:
  - APPROVE = 1 line: `**agent**: APPROVE. No concerns.`
  - ADVISE = 2-3 lines: verdict + concern + recommendation
  - BLOCK = 3-4 lines: verdict + issue + resolution
- **Phases section**: Narrative prose (1-2 paragraphs per phase), NOT tables.
  Include all phases that ran. For skipped phases: `Skipped ({reason}).`
- **Key Design Decisions**: Each decision as H4. Non-gate design decisions.
  For gate decisions, use the Decisions section instead.
- **Conflict Resolutions**: Always present as H3 under Key Design Decisions.
  Write "None." if no conflicts arose.
- **Files Changed**: Must list ALL files in the PR, not a subset. File paths
  in the table must be relative markdown links. Compute the correct `../`
  depth from the actual report directory (which varies — see Report Directory
  detection in SKILL.md). Count directory levels between the report file and
  the repo root, then prepend that many `../` segments to each repo-root-relative
  file path.
- **Verification**: Even if all phases were skipped, include the table with
  skipped annotations.

### Working Files

- Companion directory is a sibling in `docs/history/nefario-reports/`, named
  as the report filename without `.md` (e.g., `2026-02-10-143322-slug/`)
- Use relative links: `./companion-dir/filename.md`
- Label convention: `Phase N: description` (phase1-metaplan -> "Meta-plan",
  phase2-{agent} -> agent name, phase3-synthesis -> "Synthesis",
  phase3.5-{agent} -> agent name, prompt.md -> "Original Prompt").
  Files ending in `-prompt.md` get " prompt" appended to their label
  (e.g., phase2-devx-minion-prompt.md -> "Phase 2: devx-minion prompt").
- N in summary line is actual file count (includes both output and prompt files)
- "None" if no companion directory exists

### PR Body Generation

The PR body is the report body with YAML frontmatter stripped. The report is
written so that frontmatter-stripped content reads as a valid PR description.

Where the report references files within the repository, these references MUST link to the file. Use relative links.

### File Naming Convention

Reports are written to `docs/history/nefario-reports/<YYYY-MM-DD>-<HHMMSS>-<slug>.md`:

- `<YYYY-MM-DD>`: date of orchestration
- `<HHMMSS>`: local time at report creation, 24-hour, zero-padded. Capture at
  wrap-up time, not at Phase 1.
- `<slug>`: kebab-case, lowercase, max 40 chars, derived from task description.
  Strip articles (a/an/the). Only alphanumeric and hyphens.

Create `docs/history/nefario-reports/` directory if it doesn't exist.

## Index File

The report index (`docs/history/nefario-reports/index.md`) is a derived view
generated automatically by CI on push to main. It is not committed from branches
and is not part of the orchestration workflow.

The index is built by `docs/history/nefario-reports/build-index.sh`, which reads
YAML frontmatter from all report files and produces a chronological table. The
script is idempotent -- running it multiple times produces the same output.

To preview the index locally before pushing (optional): `docs/history/nefario-reports/build-index.sh`

## Incremental Writing

For long-running orchestrations, write a partial report after Phase 3
(synthesis). Include available data and mark sections as "In Progress".
Overwrite with the complete report at wrap-up.

## Report Writing Checklist

When generating a report:

1. Collect all accumulated data from phase boundaries
2. Generate filename slug (kebab-case, strip articles, max 40 chars)
3. Capture current local time as HHMMSS for filename
4. Sanitize verbatim prompt (redact secrets/tokens/keys)
4a. Write sanitized prompt to scratch directory as prompt.md
5. Write YAML frontmatter with all fields (version: 3; include `source-issue` only if applicable)
6. Write Summary (2-3 sentences)
7. Write Original Prompt (inline blockquote if <20 lines, collapsible if >=20 lines)
8. Write Key Design Decisions (H4 per decision, with Conflict Resolutions H3 subsection)
9. Write Phases (narrative, 1-2 paragraphs per phase)
10. Write Agent Contributions (collapsible, groups: Planning + Architecture Review + Code Review)
11. Write Execution (Tasks table + Files Changed table + Approval Gates table with per-gate H4 briefs)
12. Write Decisions (if gate-count > 0; gate briefs with full rationale)
13. Write Verification table
14. Write External Skills (if any discovered)
15. Write Working Files (collapsible, relative links to companion directory; or "None")
16. Write Test Plan (if tests were produced or modified)
17. Do NOT write Post-Nefario Updates in initial report
18. Present report path to user
