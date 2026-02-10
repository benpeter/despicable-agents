# Domain Plan Contribution: software-docs-minion

## Recommendations

### (a) prompt.md format: plain Markdown, no frontmatter

`prompt.md` should be a plain Markdown file containing the sanitized verbatim prompt text -- no YAML frontmatter, no metadata headers, no wrapper structure.

**Reasoning:**

1. **Single source of truth**: The report's YAML frontmatter already holds all metadata (date, task summary, agents, outcome). Adding frontmatter to `prompt.md` would duplicate metadata across two files, guaranteeing staleness when one is updated and the other is not.
2. **Machine readability without parsing overhead**: A plain `.md` file is trivially readable by any tool. Frontmatter requires a YAML parser or regex extraction -- unnecessary complexity for what is effectively a verbatim transcript.
3. **Consistency with the companion directory pattern**: The existing companion directory files (`phase1-metaplan.md`, `phase2-*.md`, `phase3-synthesis.md`) are all plain Markdown without frontmatter. They are intermediate artifacts, not indexed documents. `prompt.md` is the same class of artifact -- a preserved input, not a self-describing document.
4. **Raw text was considered and rejected**: A `.txt` file would technically work but loses Markdown rendering benefits. The original prompt may contain formatting (bullet lists, code blocks, emphasis) that should render correctly on GitHub. `.md` preserves this for free.

**Recommended content structure for `prompt.md`:**

```markdown
# Original Prompt

> The full verbatim prompt text here, in a blockquote.
> Multi-line prompts continue naturally.
>
> Code blocks, lists, and other formatting are preserved as-is.
```

The `# Original Prompt` heading provides context when the file is viewed standalone (e.g., browsing the companion directory on GitHub). The blockquote matches the existing convention from the report's Task section. This means the prompt text in the report, in the PR description, and in `prompt.md` all use the same blockquote format -- one convention, three locations.

**Security note**: The existing SKILL.md redaction instruction ("Before including in the report, sanitize: remove any secrets, tokens, API keys, or credentials. Replace with `[REDACTED]`") already applies to the `original-prompt` captured in Phase 1. Since `prompt.md` is written from the same sanitized `original-prompt` variable, no additional redaction step is needed. However, the SKILL.md wrap-up step that writes `prompt.md` should explicitly reference the sanitized prompt, not re-read from raw input, to ensure redaction is not bypassed.

### (b) Report Task section: add a cross-reference link to prompt.md

The report's existing Task section (section 3 in TEMPLATE.md) should remain the primary inline location for the verbatim prompt. Add a single-line cross-reference after the blockquote pointing to the companion file:

**For short prompts (<20 lines):**

```markdown
## Task

> The verbatim prompt here.

Full prompt: [prompt.md](./companion-dir/prompt.md)
```

**For long prompts (>=20 lines):**

```markdown
## Task

<details>
<summary>Original task (expand)</summary>

> The long verbatim prompt here.

</details>

Full prompt: [prompt.md](./companion-dir/prompt.md)
```

**Reasoning:**

- The link goes _after_ the prompt (or after the `</details>` close), not before. Readers hitting the Task section see the prompt first (the primary content), then the link to the standalone file (secondary reference). This follows the inverted pyramid principle already established in the template.
- The link text "Full prompt:" is deliberately terse. It signals that the file exists without adding narrative.
- When no companion directory exists (e.g., older reports or runs where scratch files were empty), the cross-reference is simply absent. This preserves backward compatibility -- the Task section works identically with or without the link.
- The link uses the same `./companion-dir/` relative path convention already established for the Working Files section.

### (c) TEMPLATE.md checklist: yes, update it

The Report Writing Checklist in TEMPLATE.md (currently 15 steps) should be updated. Specifically:

1. **Add a new step between current step 5 (collect working files) and step 6 (write report)**: "Write `prompt.md` to companion directory using the sanitized `original-prompt`." However, this interleaving creates a dependency -- `prompt.md` lives in the companion directory, so the companion directory must exist first. Since step 5 already creates the companion directory (`mkdir -p`), `prompt.md` should be written as a sub-step of step 5 or immediately after it.

**Recommended approach**: Extend current checklist step 7 ("Write Task") to include the cross-reference, and add a new step after step 5 (working files collection) for writing `prompt.md`:

Current step numbering to update:
- Step 5 (collect working files): Add sub-step: "Write `prompt.md` to companion directory"
- Step 7 (Write Task): Add note: "Include cross-reference link to `prompt.md` if companion directory exists"

This avoids adding an entirely new top-level step (which would renumber everything) while still making the `prompt.md` creation explicit in the checklist.

2. **Do not bump the template version**: The template version field (`version: 2`) governs the _report_ format. Adding `prompt.md` as a companion file does not change the report's YAML schema or body section structure -- it adds a link within an existing section. The Working Files section already handles companion directory presence vs. absence gracefully. A version bump would be YAGNI here; `build-index.sh` does not need to know about `prompt.md`.

### (d) docs/orchestration.md Section 5: yes, update it

Section 5 ("Execution Reports") in `docs/orchestration.md` describes the report structure and its artifacts. Two changes are needed:

1. **Mention `prompt.md` in the report structure bullet list** (line 519 area). The Task bullet currently reads:

   > **Task**: The verbatim user request (inline blockquote for short prompts, collapsible for long ones). Secrets and credentials are redacted before inclusion.

   Append a sentence:

   > The verbatim prompt is also saved as a standalone `prompt.md` file in the report's companion directory for independent reference.

   This is a single-sentence addition that documents the artifact's existence without duplicating the template's detailed instructions.

2. **No other changes needed in orchestration.md**. The PR description format is not documented in orchestration.md (it is in SKILL.md and commit-workflow.md), so the PR prompt section change does not require an orchestration.md update. The companion directory pattern is already documented by the Working Files addition from the previous orchestration run.

### Additional consideration: PR description prompt section

While not directly part of my planning question, the PR description change intersects with documentation structure. The current approach uses the full report body as the PR description. A dedicated `## Original Prompt` section in the PR description should:

- Appear early in the PR body (after Summary, before or within the existing structure)
- Use the same collapsible pattern for long prompts
- Not duplicate the full report body -- if the PR body remains the report body, the Task section already serves this purpose with only a heading rename or no change at all

The simplest path: since the PR body _is_ the report body, and the report body already has a `## Task` section containing the verbatim prompt, the PR already includes the prompt. The question is whether "Task" is a clear enough heading for PR reviewers to find the original prompt. I recommend renaming the section to `## Task` remaining as-is -- it is already conventional in the reports, and adding a second "Original Prompt" heading would create redundancy. If the team wants the prompt more prominent in PRs, a better approach is to add a one-line callout at the top of the Summary section: "See [Task](#task) for the original prompt."

## Proposed Tasks

### Task 1: Update TEMPLATE.md

**What to do**: Modify `docs/history/nefario-reports/TEMPLATE.md` to:
- Add `prompt.md` companion file guidance (format, content structure, placement in companion directory)
- Update the Task section template to include the cross-reference link pattern (both short and long prompt variants)
- Update the Report Writing Checklist to include `prompt.md` creation as part of the working files step
- Update the Working Files section example to include `prompt.md` in the file list

**Deliverables**: Modified `TEMPLATE.md`

**Dependencies**: None. This is the foundational change that other tasks reference.

### Task 2: Update SKILL.md wrap-up and PR flow

**What to do**: Modify `skills/nefario/SKILL.md` to:
- Add a step in the wrap-up sequence (after companion directory creation, before report writing) that writes `prompt.md` to the companion directory using the sanitized `original-prompt`
- Update the report writing instructions to include the Task section cross-reference link
- Optionally adjust the PR body generation if the team wants a dedicated prompt section in the PR description beyond what the report's Task section already provides

**Deliverables**: Modified `SKILL.md`

**Dependencies**: Depends on Task 1 (template defines the format that SKILL.md implements).

### Task 3: Update docs/orchestration.md

**What to do**: Add a single sentence to Section 5 bullet list mentioning `prompt.md` as a companion artifact.

**Deliverables**: Modified `docs/orchestration.md`, specifically the Task bullet in the report structure description.

**Dependencies**: Depends on Task 1 (should reflect the final format decision).

## Risks and Concerns

### R1: Redundancy between report Task section and prompt.md

The verbatim prompt will exist in three places: the report's Task section (inline), `prompt.md` (standalone file), and the PR description (via the report body). This is intentional redundancy -- each serves a different access pattern (reading the report, browsing the companion directory, reviewing the PR). However, it means a correction to the prompt text requires updating all three. **Mitigation**: `prompt.md` and the report's Task section are both written from the same sanitized `original-prompt` variable in a single wrap-up pass. The PR body is derived from the report. So in practice, the source is singular; the outputs are just different projections.

### R2: Companion directory might not exist for prompt.md

If the scratch directory is empty or does not exist (unusual but possible for very simple orchestrations), the companion directory is not created, and there is nowhere to put `prompt.md`. **Mitigation**: The SKILL.md step should ensure the companion directory is created unconditionally when `prompt.md` is written, even if no other scratch files exist. This is a minor change to the existing "if scratch dir exists" conditional.

### R3: build-index.sh compatibility

The `build-index.sh` script reads only report `.md` files matching the `????-??-??-*-*.md` glob pattern. `prompt.md` lives in a companion _directory_, not alongside the reports as a peer file. No compatibility issue. Verified: the glob pattern does not match directory contents.

### R4: Template version not bumped -- future confusion

Not bumping the version means there is no machine-readable signal that a report was generated with `prompt.md` support. However, the presence or absence of `prompt.md` in the companion directory is itself the signal, and the Working Files section lists it. This is the same backward-compatibility pattern used for the Working Files section itself (absence = feature not available for this report).

## Additional Agents Needed

None. The current team (devx-minion for artifact design, software-docs-minion for documentation structure) covers the necessary expertise. The mandatory Phase 3.5 reviewers (security, test, ux-strategy, software-docs, lucy, margo) will catch any issues with the synthesized plan.
