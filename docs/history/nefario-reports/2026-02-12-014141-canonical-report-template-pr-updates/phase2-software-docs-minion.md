## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. TEMPLATE.md should be deleted, not deprecated

The issue requires SKILL.md to contain the explicit template. Having two files
that define report structure -- even if one is marked "secondary" or "reference"
-- violates the single-source-of-truth principle. The project already learned this
lesson with the overlay mechanism: infrastructure serving edge cases creates
maintenance burden. TEMPLATE.md was created as a standalone reference when SKILL.md
had only fragmentary inline hints. Once SKILL.md contains the full canonical
template, TEMPLATE.md becomes a duplication liability.

**Proposed approach**: Delete TEMPLATE.md. Move it to `docs/history/TEMPLATE.md`
if historical preservation is desired (consistent with how overlay-decision-guide.md
was archived). The git history preserves the full content regardless.

Do NOT keep it as a "rendered reference" -- that creates two documents that must
stay synchronized, which is exactly the problem the issue is solving.

#### 2. Conditional sections: use inclusion rules in the template, not template variants

The template should define ALL sections in canonical order, with each section
annotated with its inclusion condition. This is simpler and more maintainable
than maintaining multiple template variants or complex conditional logic.

**Proposed encoding pattern** (inline in SKILL.md):

```markdown
### N. Section Name

**Include when**: <condition in plain English>
**Omit when**: <inverse condition>

<content guidance, format example>
```

Sections that are always present get no inclusion annotation (absence of condition
means "always include"). Conditional sections get a one-line inclusion rule.

The canonical section list from the issue with conditions:

| # | Section | Condition |
|---|---------|-----------|
| 0 | YAML Frontmatter | Always |
| 1 | Title | Always |
| 2 | Summary | Always |
| 3 | Original Prompt | Always |
| 4 | Key Design Decisions | Always (may be "None" for trivial changes) |
| 5 | Phases | Always |
| 6 | Agent Contributions | Always |
| 7 | Execution | Always |
| 8 | Decisions (gate briefs) | Include when gates > 0 |
| 9 | Conflict Resolutions | Include when conflicts arose during planning/review |
| 10 | Verification | Always (even if all phases skipped -- state that) |
| 11 | External Skills | Include when external skills were discovered |
| 12 | Files Changed | Always |
| 13 | Working Files | Always (collapsed details; "None" if no companion dir) |
| 14 | Test Plan | Include when tests were produced or modified |
| 15 | Post-Nefario Updates | Include when subsequent commits land on the branch |

Wait -- I need to reconcile this with the issue's canonical order. The issue
specifies: frontmatter, Summary, Original Prompt, Key Design Decisions, Phases
(narrative), Agent Contributions (planning + review tables), Execution (per-task
with gates), Decisions (gate briefs with rationale/rejected), Conflict Resolutions,
Verification, External Skills, Files Changed, Working Files, Test Plan,
Post-Nefario Updates. This differs from the TEMPLATE.md ordering and from the
actual report ordering observed in practice. The issue's ordering should be
treated as authoritative.

#### 3. Observed inconsistencies to fix

Analysis of 5 recent reports reveals these structural inconsistencies:

**Section naming**:
- "Executive Summary" (3 reports) vs "Summary" (1 report, TEMPLATE.md) -- issue mandates "Summary"
- "Task" (1 report) vs "Original Prompt" (most reports) for the prompt section
- "Phases" section (1 report, PR #33 style) vs absent (most reports) -- issue mandates "Phases" narrative

**Section ordering** (varies across reports):
- Report `2026-02-11-122254`: Original Prompt > Executive Summary > Agent Contributions > Execution > Decisions > Conflict Resolutions > Verification > Files Changed > Working Files
- Report `2026-02-11-132900`: Executive Summary > Original Prompt > Execution > Decisions > Agent Contributions > Verification > Working Files
- Report `2026-02-11-143008`: Executive Summary > Original Prompt > Key Design Decisions > Agent Contributions > Execution > Verification > Conflicts Resolved > Outstanding Items > Working Files
- Report `2026-02-11-125653`: Executive Summary > Original Prompt > Phases > Verification > Agent Contributions > Decisions > Working Files
- TEMPLATE.md order: Summary > Original Prompt > Decisions > Agent Contributions > Execution > Process Detail > Working Files > Metrics

None of these match each other or the issue's canonical order. This confirms the
problem: without an explicit template in SKILL.md, the LLM infers structure
differently each time.

**Frontmatter inconsistencies**:
- Different field sets across reports (some have `version: 2`, some don't; some have `slug`, `branch`, `duration`; some have `status`, some have `outcome`)
- TEMPLATE.md defines 10 fields; actual reports use 7-12 fields with varying names

**Agent Contributions format**:
- Tables (most reports) vs prose with bullets (TEMPLATE.md example)
- Some inside `<details>`, some not
- Planning/review grouping varies

**Working Files format**:
- Some inside `<details>` (TEMPLATE.md, one report), most not
- Relative link format varies: `./dir/file.md` vs just listing filenames

#### 4. The template must be inline in SKILL.md, not referenced

The SKILL.md's current "Report Template" subsection says:
> The report format is defined inline below in the Wrap-up Sequence section.
> No external template file dependency is required.

But the actual wrap-up sequence (steps 1-13) does NOT contain a report template.
It references "follow the report format defined in this skill" but never defines it.
The LLM falls back to TEMPLATE.md or invents structure. This is the root cause of
inconsistency.

The fix: replace the "Report Template" subsection and the vague reference in
step 6 with an actual inline template in SKILL.md. The template should be a
complete Markdown skeleton with placeholder values, not prose describing what
each section should contain. An LLM following a skeleton produces consistent
output; an LLM following prose descriptions produces varied interpretations.

#### 5. PR body = report body (stripped frontmatter), no separate formatting

The issue states: "The report doubles as the PR body -- same content, no
separate formatting step." The current SKILL.md already does this (step 10
strips frontmatter via `tail -n +2 | sed '1,/^---$/d'`). This is correct and
should be preserved. The template design must account for this: the report body
must render well in both contexts (standalone Markdown file and GitHub PR
description).

Key implication: no section should depend on filesystem-relative links that
break in PR context. Working Files links (relative `./companion-dir/file.md`)
work in the report file but break in PR descriptions. This is an acceptable
tradeoff -- the PR body provides the information, and clickable links work
when viewing the report file directly. Document this tradeoff explicitly.

#### 6. Post-Nefario Updates section and PR update mechanism

The issue requires a "Post-Nefario Updates" section when additional commits land
on a branch after the initial nefario PR. Two approaches:

**Option A (recommended): Append-on-subsequent-run**. When nefario detects an
existing PR on the current branch, it appends a "Post-Nefario Updates" section
to the report and updates the PR body. This is low-friction and automatic.

**Option B: Nudge command**. Print a message like "Run `/nefario update-pr` to
update the PR description with recent changes." This requires user action but
is simpler to implement.

I recommend Option A with a fallback to Option B. The detection is straightforward:
`gh pr list --head <branch> --json number` returns existing PRs for the branch.
If a PR exists, the subsequent nefario run appends the update section and runs
`gh pr edit <number> --body-file`.

The "Post-Nefario Updates" section format should be:

```markdown
## Post-Nefario Updates

### Update 1 (YYYY-MM-DD HH:MM)

<summary of what changed and why>

Commits: <short SHAs with one-line messages>
Files: <changed file list>
```

Multiple updates append chronologically.

#### 7. Frontmatter must be locked down to a fixed schema

The issue's `source-issue` field (from the issue integration feature) should be
conditional. The TEMPLATE.md's 10 fields are a good base but need reconciliation
with fields actually appearing in recent reports. Proposed fixed schema:

```yaml
---
type: nefario-report
version: 3          # bump to 3 for this template revision
date: "<YYYY-MM-DD>"
time: "HH:MM:SS"
task: "<one-line task description>"
source-issue: <N>   # conditional: only when input was a GitHub issue
mode: full | plan
agents-involved: [<list>]
task-count: <N>
gate-count: <N>
outcome: completed | partial | aborted
---
```

Version bump to 3 signals the new canonical template. build-index.sh must handle
v2 and v3 reports (add a note in the template).

### Proposed Tasks

#### Task 1: Write canonical report template inline in SKILL.md

**What**: Replace the current "Report Template" subsection and the vague step 6
reference in the Wrap-up Sequence with a complete inline Markdown template skeleton.
The skeleton uses the issue's canonical section order with placeholder values and
inclusion conditions for conditional sections.

**Deliverables**:
- Updated `skills/nefario/SKILL.md` Report Generation section with full template
- Updated Wrap-up Sequence step 6 referencing the inline template
- Updated Report Writing Checklist (currently in TEMPLATE.md, move into SKILL.md
  or remove if redundant with the template itself)

**Dependencies**: None (this is the foundation task)

#### Task 2: Delete TEMPLATE.md (or archive to history)

**What**: Remove `docs/history/nefario-reports/TEMPLATE.md`. Archive to
`docs/history/TEMPLATE-v2-archived.md` if git-history-only deletion is
insufficient for the team.

**Deliverables**:
- TEMPLATE.md removed from report directory
- Any references to TEMPLATE.md in other docs updated or removed

**Dependencies**: Task 1 (template must be in SKILL.md before removing TEMPLATE.md)

#### Task 3: Add Post-Nefario Updates mechanism to SKILL.md

**What**: Add a "Post-Nefario Updates" workflow to the wrap-up sequence. When
nefario detects an existing PR for the current branch, append the update section
to the report and update the PR body. Define the section format and the detection
logic.

**Deliverables**:
- New subsection in SKILL.md wrap-up or a new "PR Update" section
- Detection logic: `gh pr list --head <branch> --json number`
- Section format specification
- PR body update command: `gh pr edit <number> --body-file`

**Dependencies**: Task 1 (the template must define where "Post-Nefario Updates"
appears in the section order)

#### Task 4: Update cross-references and docs

**What**: Update any files that reference TEMPLATE.md or the old report structure.

**Deliverables**:
- Search all `.md` files for references to `TEMPLATE.md`, report format, or
  report template
- Update `docs/architecture.md` sub-documents table if it references TEMPLATE.md
- Update build-index.sh if it references template version (v2 -> v3 compatibility)
- Update CLAUDE.md "Orchestration Reports" section if needed

**Dependencies**: Tasks 1, 2

### Risks and Concerns

1. **Template skeleton length in SKILL.md**: The SKILL.md is already 1416 lines.
   Adding a full template skeleton (estimated 80-120 lines) increases it further.
   Risk: cognitive load for anyone reading SKILL.md. Mitigation: the template
   replaces existing vague prose, so net increase is smaller than it appears.
   The alternative (external file) reintroduces the two-source problem.

2. **Existing reports must NOT be modified**: The issue explicitly states
   "Existing reports are NOT modified (historical immutability)." The version
   bump to v3 handles this -- build-index.sh reads both v2 and v3. But any
   automated tooling must not retroactively reformat old reports.

3. **PR body relative links**: Working Files section uses relative links that
   work in the report file but not in GitHub PR descriptions. This is a known
   tradeoff. Documenting it prevents future "bug" reports.

4. **Post-Nefario Updates and PR body drift**: If manual commits (not nefario runs)
   land on the branch, the PR body goes stale. Option A (automatic detection)
   only triggers on nefario runs. For manual commits, Option B (nudge) is needed.
   Recommend documenting both paths.

5. **build-index.sh version compatibility**: Bumping to v3 requires build-index.sh
   to handle both versions. The current script reads frontmatter fields; adding
   `source-issue` as conditional should not break it, but needs testing.

6. **Phases section is new for most reports**: The issue mandates a "Phases"
   narrative section (PR #33 style). This is a significant structural addition
   that most existing reports lack. The template must make this section's
   content guidance very clear to produce consistent narratives rather than
   just phase tables.

### Additional Agents Needed

- **devx-minion**: Should review the Post-Nefario Updates mechanism for
  developer workflow implications. The PR update flow touches git operations,
  `gh` CLI usage, and developer habits around branch management. devx-minion
  can assess whether the automatic update approach or the nudge approach
  creates less friction.

- No other additional agents needed. The current planning team should be
  sufficient for a documentation-structure task.
