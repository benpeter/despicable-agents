## Domain Plan Contribution: devx-minion

### Recommendations

#### 1. `prompt.md` Placement and Format

**Where it lives**: In the companion directory alongside the other working files.

The companion directory already exists as the archival home for intermediate artifacts (`nefario/scratch/{slug}/` files copied to `docs/history/nefario-reports/<YYYY-MM-DD>-<HHMMSS>-<slug>/`). The `prompt.md` file is semantically an intermediate artifact -- it is the raw input that started the orchestration. Placing it in the companion directory keeps it with the other working files and avoids cluttering the top-level reports directory with a second file per report.

This means: `docs/history/nefario-reports/<YYYY-MM-DD>-<HHMMSS>-<slug>/prompt.md`

The file should be **written during the scratch file copy step** (wrap-up step 5), not during Phase 1. Rationale: the companion directory does not exist until wrap-up. Writing `prompt.md` into `nefario/scratch/{slug}/` at Phase 1 and then copying it with the rest is the natural flow -- the orchestrator already captures `original-prompt` in session context at Phase 1, so the write instruction should go in Phase 1 (write to scratch) and the file naturally follows the existing copy path to the companion directory.

**What it contains**: Raw prompt with a minimal YAML frontmatter header. The frontmatter provides machine-readable traceability without adding manual overhead.

```markdown
---
type: nefario-prompt
date: "<YYYY-MM-DD>"
task: "<one-line task summary from Phase 1>"
---

<verbatim prompt text, redacted of secrets>
```

Rationale for including frontmatter:
- The `type` field makes `prompt.md` identifiable by tooling (grep, scripts) without relying on filename or directory context.
- The `date` and `task` fields provide standalone context -- if someone copies just this file, they can still identify what it belongs to.
- Three fields is the minimum useful set. No more. Adding `slug`, `report-path`, or `agents-involved` would be redundant with the report frontmatter and violate DRY.

Rationale against raw text only:
- A bare prompt file with no metadata is context-free. If the companion directory were ever separated from its report (unlikely but possible), the file would be opaque.
- Frontmatter costs 4 lines and zero cognitive overhead for a human reader -- the prompt text starts immediately after the `---` delimiter.

#### 2. PR Description Structure

**Recommendation: Keep the full report body as the PR description, but restructure how the "Task" section reads.**

The current approach (full report body, stripped of YAML frontmatter) already works well. PR #13 demonstrates this -- the PR description is comprehensive, self-contained, and serves as the archival record for the branch. Switching to a condensed PR body would lose information and create a second format to maintain.

However, the current "Task" section in the report body already contains the verbatim prompt. The question is: does a PR reviewer recognize the "Task" section as "what was asked"? Looking at PR #13, the Task section is a blockquote starting with:

> Improve nefario skill UX with structured prompts and quieter commit hooks...

This is recognizable but not immediately scannable as "this is the original prompt verbatim." The section heading "Task" is ambiguous -- it could mean "the task we performed" rather than "what was asked."

**Proposed change**: Rename the report section from "## Task" to "## Original Prompt" in the report template itself. This serves both audiences (report readers and PR reviewers) without requiring a separate PR template. The content and formatting rules stay identical (blockquote for short, collapsible for long, redaction for secrets).

This is a single-change approach: one section rename in TEMPLATE.md propagates to both the report and the PR body. No separate PR template, no conditional formatting, no divergent structures.

**Alternative considered and rejected**: Adding a separate "## Original Prompt" section to the PR body that does not exist in the report. This creates format divergence -- the PR body would no longer be a clean derivative of the report body. Two formats means two things to maintain, two things that can drift. KISS says: one format, used in both places.

**Alternative considered and rejected**: Keeping "## Task" in the report but adding an "## Original Prompt" section only at the top of the PR body (prepended by SKILL.md). This creates a duplication problem -- the same prompt appears twice in the PR (once in the prepended section, once in the Task section). Duplication is noise.

#### 3. Writing Sequence in SKILL.md

The `prompt.md` file should be written to the scratch directory at the beginning of Phase 1, immediately after capturing the `original-prompt` in session context. This is the natural point: the prompt is freshly captured, the scratch directory has just been created.

Add one instruction to Phase 1 after the `original-prompt` capture:

> Write the sanitized original prompt to `nefario/scratch/{slug}/prompt.md` with a
> minimal frontmatter header (type: nefario-prompt, date, task summary).

At wrap-up, the existing `cp -r nefario/scratch/{slug}/* <companion-dir>/` step (step 5) will automatically copy `prompt.md` into the companion directory. No additional wrap-up changes are needed for the file copy.

The Working Files section in the report will automatically list `prompt.md` since it generates the file list from whatever exists in the companion directory.

### Proposed Tasks

#### Task 1: Add prompt.md writing to Phase 1 in SKILL.md

**What to do**: Add an instruction to SKILL.md Phase 1, immediately after the `original-prompt` capture paragraph (lines 139-142), to write the sanitized prompt to `nefario/scratch/{slug}/prompt.md` with minimal YAML frontmatter (type, date, task).

**Deliverables**: Modified `skills/nefario/SKILL.md` -- Phase 1 section gains ~5 lines of instruction.

**Dependencies**: None. This is the foundational change.

#### Task 2: Rename "Task" to "Original Prompt" in TEMPLATE.md

**What to do**: In `docs/history/nefario-reports/TEMPLATE.md`, rename section 3 from "### 3. Task" to "### 3. Original Prompt". Update the heading in the examples from `## Task` to `## Original Prompt`. Update the report writing checklist item 7 from "Write Task" to "Write Original Prompt". Update SKILL.md references if any refer to the "Task section" by name.

**Deliverables**: Modified `docs/history/nefario-reports/TEMPLATE.md`. Possibly modified `skills/nefario/SKILL.md` if it references the section by name.

**Dependencies**: None. Independent of Task 1.

**Note**: This does NOT retroactively rename the section in existing reports. Existing reports keep `## Task` -- this is fine because the content is identical, and report readers understand both headings.

#### Task 3: Update TEMPLATE.md to document prompt.md companion file

**What to do**: In the Working Files section guidance of TEMPLATE.md, add a note that `prompt.md` will be present in the companion directory when it exists. Add a label convention entry: `prompt.md` -> "Original Prompt". Optionally add a note to the Report Writing Checklist mentioning that `prompt.md` is auto-generated in Phase 1 and auto-copied in step 5.

**Deliverables**: Modified `docs/history/nefario-reports/TEMPLATE.md` -- Working Files section gains 2-3 lines.

**Dependencies**: Task 1 (establishes that prompt.md exists).

### Risks and Concerns

**Risk 1: Section rename breaks tooling or references**
- Severity: Low
- The `build-index.sh` script reads YAML frontmatter, not body section headings. The section rename does not affect it.
- The SKILL.md PR body extraction uses `tail -n +2 | sed '1,/^---$/d'` -- this strips frontmatter, it does not parse section headings. No breakage.
- Grep for `## Task` in the codebase to find any hardcoded references before executing.

**Risk 2: prompt.md contains secrets that survive redaction**
- Severity: Medium (mitigated)
- The existing SKILL.md Phase 1 already has redaction instructions ("sanitize: remove any secrets, tokens, API keys, or credentials. Replace with `[REDACTED]`"). The `prompt.md` write instruction must explicitly reference this existing redaction step, not create its own. Single redaction point, single source of truth.
- The wrap-up step 5 also has a security scan of copied files. This is a defense-in-depth layer that catches anything the Phase 1 redaction missed.

**Risk 3: prompt.md written at Phase 1 but orchestration aborts before wrap-up**
- Severity: None (feature, not bug)
- If the orchestration aborts, `prompt.md` stays in `nefario/scratch/{slug}/` which is gitignored. It does not leak into the repo. The scratch directory is the right place for potentially-incomplete artifacts.

**Risk 4: "Original Prompt" heading is confusing when despicable-prompter rewrites the prompt**
- Severity: Low
- The TEMPLATE.md already says: "Use the text that was passed to nefario (may already be cleaned by despicable-prompter)." This is accurate -- the "original prompt" is what nefario received, which is the prompter-refined version. This is the correct behavior: the report traces intent as nefario understood it, not the raw voice transcription.
- If future traceability needs arise for the pre-prompter text, that is a separate concern (and out of scope per the task definition).

### Additional Agents Needed

None. The meta-plan correctly identified devx-minion and software-docs-minion as the two relevant planning specialists. The task is documentation-only (markdown templates and natural language SKILL.md instructions), so no code-focused specialists are needed for planning. The mandatory Phase 3.5 reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo) will catch any gaps during architecture review.
