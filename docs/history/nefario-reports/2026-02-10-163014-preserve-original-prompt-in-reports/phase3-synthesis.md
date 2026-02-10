# Delegation Plan

**Team name**: preserve-prompt
**Description**: Capture the original user prompt in PR descriptions, nefario reports, and as a standalone companion file.

## Conflict Resolutions

### Conflict 1: prompt.md format -- frontmatter vs. plain markdown

**devx-minion** recommends YAML frontmatter (type, date, task) for machine-readability and standalone context.

**software-docs-minion** recommends plain markdown with an `# Original Prompt` heading and blockquote, matching the convention of existing companion files (phase1-metaplan.md, phase2-*.md, etc.), which all use plain markdown without frontmatter.

**Resolution: Plain markdown (software-docs-minion's recommendation).**

Rationale:
- Consistency with existing companion directory artifacts is the stronger argument. All other files in the companion directory are plain markdown. Introducing frontmatter on one file creates a format inconsistency.
- The metadata devx-minion wants (date, task summary) already exists in the report's YAML frontmatter. Duplicating it in prompt.md violates DRY and creates a staleness vector.
- The `# Original Prompt` heading provides sufficient standalone context for a human browsing the companion directory on GitHub.
- The `type: nefario-prompt` field for tooling discovery is YAGNI -- no tooling exists or is planned that would consume it.

### Conflict 2: Report section heading -- rename "Task" vs. keep + cross-ref

**devx-minion** recommends renaming `## Task` to `## Original Prompt` in the template. Single change, propagates to both report and PR body.

**software-docs-minion** recommends keeping `## Task` and adding a cross-reference link to prompt.md after the blockquote.

**Resolution: Rename to `## Original Prompt` (devx-minion's recommendation).**

Rationale:
- "Task" is ambiguous -- it could mean "the task we performed" rather than "what was asked." "Original Prompt" is unambiguous for both report readers and PR reviewers.
- The rename is a single change in TEMPLATE.md that propagates to reports and PR descriptions without format divergence. Adding a cross-reference link is an additional change that provides marginal value when the section heading already clarifies the content.
- Backward compatibility is not a concern: existing reports keep `## Task`, new reports use `## Original Prompt`. Both are readable. build-index.sh reads frontmatter, not body headings.
- The cross-reference link to prompt.md adds clutter when the section already contains the verbatim prompt inline. The companion file exists for independent access (browsing the directory), not for readers already in the report.

### Additional decision: prompt.md writing location

Both specialists agree that prompt.md should be written to the scratch directory early and copied via the existing `cp -r` at wrap-up. devx-minion places the write at Phase 1 (after original-prompt capture); software-docs-minion places it at wrap-up (after companion directory creation).

**Resolution: Write at Phase 1 into the scratch directory.**

Rationale:
- The scratch directory already exists at Phase 1 (created by `mkdir -p`). Writing prompt.md there means the file follows the natural copy path with zero additional wrap-up logic.
- If the orchestration aborts before wrap-up, prompt.md stays in the gitignored scratch directory. No leak.
- software-docs-minion's concern about the companion directory not existing is moot -- writing to scratch, not to the companion directory directly.

### Additional decision: Companion directory creation for prompt.md

software-docs-minion flags that the companion directory might not be created if no other scratch files exist, leaving prompt.md orphaned. Since prompt.md is itself written to the scratch directory, the scratch directory will always have at least one file (prompt.md), so the `cp -r` step will always execute. The companion directory creation condition in wrap-up step 5 ("if scratch directory exists and contains files") is satisfied by prompt.md's presence.

**Resolution: No change needed.** The existing conditional handles this correctly once prompt.md is written to scratch in Phase 1.

## Task 1: Update SKILL.md, TEMPLATE.md, and orchestration.md

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Gate reason**: N/A. All changes are additive, reversible markdown edits with 0 downstream dependents. Easy to reverse + low blast radius = NO GATE per the classification matrix.
- **Prompt**: |
    You are making three coordinated edits to preserve the original user prompt
    in nefario orchestration artifacts. All changes are markdown-only -- no code,
    no scripts, no configuration files.

    ## Context

    The nefario orchestration system captures a user's original prompt at Phase 1
    and includes it in the report's "Task" section. We are improving traceability
    by: (a) saving the prompt as a standalone companion file, (b) renaming the
    report section for clarity, and (c) documenting the new artifact.

    ## Change 1: SKILL.md -- Add prompt.md writing to Phase 1

    **File**: `skills/nefario/SKILL.md`

    After the paragraph that captures `original-prompt` (lines 138-142, ending with
    "Replace with `[REDACTED]`."), add a new paragraph:

    ```
    Write the sanitized original prompt to `nefario/scratch/{slug}/prompt.md` as
    plain markdown:

        # Original Prompt

        > <the sanitized verbatim prompt text, in a blockquote>

    Use the same blockquote formatting as the report's Original Prompt section
    (inline for short prompts, no collapsible wrapper in the file -- the file IS
    the expanded version). This file will be automatically copied to the companion
    directory at wrap-up via the existing `cp -r` step.
    ```

    Do NOT modify any other part of Phase 1. Do NOT modify the wrap-up sequence
    (the existing `cp -r nefario/scratch/{slug}/* <companion-dir>/` already handles
    the copy).

    ## Change 2: TEMPLATE.md -- Rename "Task" section to "Original Prompt"

    **File**: `docs/history/nefario-reports/TEMPLATE.md`

    Make these specific changes:

    a) Section heading: Change `### 3. Task` to `### 3. Original Prompt`

    b) All `## Task` headings in examples: Change to `## Original Prompt`

    c) Report Writing Checklist step 7: Change
       "Write Task (verbatim prompt, inline if <20 lines, collapsible if >=20 lines)"
       to
       "Write Original Prompt (verbatim prompt, inline if <20 lines, collapsible if >=20 lines)"

    d) In the Working Files section guidance (Section 8), add `prompt.md` to the
       label convention list:
       - `prompt.md` -> "Original Prompt"

    e) Add a checklist note about prompt.md. After existing step 4
       ("Sanitize verbatim prompt (redact secrets/tokens/keys)"), add:
       "4a. Write sanitized prompt to scratch directory as prompt.md
       (auto-copied to companion directory at wrap-up step 5)"
       Renumber subsequent steps if needed to maintain sequential numbering.

    Do NOT change the YAML frontmatter schema (no version bump -- the body
    section rename does not affect the frontmatter contract).
    Do NOT modify existing reports.
    Do NOT add a cross-reference link in the Original Prompt section body
    (the companion file is for standalone access, not for in-report linking).

    ## Change 3: orchestration.md -- Mention prompt.md artifact

    **File**: `docs/orchestration.md`

    In Section 5 ("Execution Reports"), find the bullet that describes the Task
    section (around line 519). It currently reads:

    > **Task**: The verbatim user request (inline blockquote for short prompts,
    > collapsible for long ones). Secrets and credentials are redacted before
    > inclusion.

    Change it to:

    > **Original Prompt**: The verbatim user request (inline blockquote for short
    > prompts, collapsible for long ones). Secrets and credentials are redacted
    > before inclusion. The verbatim prompt is also saved as a standalone
    > `prompt.md` file in the report's companion directory for independent
    > reference.

    Also update the SKILL.md reference on line 140 if it says "report's Task
    section" -- change to "report's Original Prompt section".

    Do NOT make any other changes to orchestration.md.

    ## Verification

    After making all changes, verify:
    1. `grep -r "## Task" docs/history/nefario-reports/TEMPLATE.md` returns no
       matches (all renamed to "## Original Prompt")
    2. `grep "prompt.md" skills/nefario/SKILL.md` returns the new Phase 1
       instruction
    3. `grep "prompt.md" docs/orchestration.md` returns the new bullet text
    4. `grep "Original Prompt" docs/history/nefario-reports/TEMPLATE.md` returns
       the renamed heading and checklist step
    5. The YAML frontmatter `version: 2` in TEMPLATE.md is unchanged
    6. No existing report files in `docs/history/nefario-reports/` were modified

    ## What NOT to Do

    - Do NOT create prompt.md itself (it is generated at runtime by the orchestrator)
    - Do NOT modify build-index.sh (it reads frontmatter, not body headings)
    - Do NOT modify existing reports (backward compatibility: old reports keep ## Task)
    - Do NOT modify the-plan.md
    - Do NOT modify any agent AGENT.md files
    - Do NOT add YAML frontmatter to the prompt.md format description
    - Do NOT add a cross-reference link from the Original Prompt section to prompt.md
    - Do NOT bump the template version field
    - Do NOT modify install.sh
- **Deliverables**:
    - Modified `skills/nefario/SKILL.md` (Phase 1 gains ~8 lines)
    - Modified `docs/history/nefario-reports/TEMPLATE.md` (section rename + checklist update + working files label)
    - Modified `docs/orchestration.md` (one bullet text update in Section 5)
- **Success criteria**:
    - All verification grep checks pass
    - No existing reports modified
    - TEMPLATE.md version field unchanged at 2
    - SKILL.md wrap-up sequence unchanged (prompt.md flows through existing cp -r)

## Cross-Cutting Coverage

- **Testing**: Not applicable. No executable code produced -- all changes are markdown templates and natural language instructions. Phase 6 will confirm no existing tests are broken by the changes (if tests exist).
- **Security**: Covered within the task prompt. The existing redaction instruction in SKILL.md Phase 1 already applies to the original-prompt text. The prompt.md write instruction explicitly references the "sanitized" prompt. The wrap-up security scan (step 5) provides defense-in-depth. No new attack surface.
- **Usability -- Strategy**: The rename from "Task" to "Original Prompt" is itself a usability improvement -- it reduces ambiguity for PR reviewers and report readers. The standalone prompt.md file provides an additional access pattern (browsing companion directory) without adding cognitive overhead to the primary report-reading flow. No separate ux-strategy review needed for a heading rename.
- **Usability -- Design**: Not applicable. No user-facing interface produced.
- **Documentation**: This task IS the documentation change. software-docs-minion contributed to planning and their recommendations are incorporated in the conflict resolution. The three files being modified are the documentation artifacts themselves.
- **Observability**: Not applicable. No runtime components, services, or APIs.

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no UI, no web-facing output)

## Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Section rename breaks tooling | Low | build-index.sh reads frontmatter, not headings. PR body extraction strips frontmatter, does not parse headings. Verification grep confirms. |
| prompt.md contains secrets | Medium (mitigated) | Phase 1 redaction instruction pre-exists. prompt.md write explicitly references "sanitized" prompt. Wrap-up step 5 security scan is defense-in-depth. |
| Aborted orchestration leaves prompt.md in scratch | None | Scratch directory is gitignored. This is a feature, not a risk. |
| "Original Prompt" heading confusing when despicable-prompter rewrites | Low | TEMPLATE.md already says "Use the text that was passed to nefario." The prompt is what nefario received, not the raw voice transcription. Accurate as-is. |
| Companion directory not created when no scratch files exist | None (resolved) | prompt.md itself is written to scratch, so the scratch directory always has at least one file, and the wrap-up cp -r step always executes. |

## Execution Order

```
Batch 1 (no gates):
  Task 1: devx-minion -- edit SKILL.md + TEMPLATE.md + orchestration.md

Post-execution:
  Phase 5: Code review (skip -- no code files)
  Phase 6: Test execution (run if tests exist)
  Phase 8: Documentation (skip -- this task IS documentation)
```

## Verification Steps

After execution completes:
1. Grep verification (5 checks in the task prompt)
2. Confirm no existing report files were modified
3. Read the three modified files and verify changes match the specification
4. Confirm build-index.sh still runs without errors: `docs/history/nefario-reports/build-index.sh`
