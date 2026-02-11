## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. Update `argument-hint` frontmatter to show both invocation modes

The `argument-hint` is the primary discoverability mechanism for skill syntax. When a user types `/despicable-prompter` or `/nefario`, Claude Code shows this hint. It must communicate both invocation modes at a glance.

**despicable-prompter**: Change from `"<rough idea or task description>"` to:

```yaml
argument-hint: "#<issue> | <rough idea or task description>"
```

**nefario**: Change from `"<task description>"` to:

```yaml
argument-hint: "#<issue> | <task description>"
```

Rationale for this format:
- The pipe `|` separator is already established in the codebase (`despicable-lab` uses `[agent-name ...] | --check | --all`), so it is a known convention.
- `#<issue>` is placed first because it is the more structured (and new) mode. Users who already know the free-text mode will not be confused; users discovering the skill for the first time see the most precise option first.
- Angle brackets `<issue>` signal a placeholder. The `#` prefix is literal and is visually distinct. No additional explanation needed in the hint itself.

#### 2. Add an Argument Parsing section to both skills

Both SKILL.md files currently lack explicit argument parsing documentation. The despicable-prompter has an "Edge Cases" section covering empty input and narrow input, but no structured argument parsing section. Nefario has no argument parsing at all -- its Phase 1 just receives the task description inline.

Add an **Argument Parsing** section near the top of each SKILL.md (after the identity paragraph, before the core logic). This follows the pattern established by `despicable-lab/SKILL.md` (lines 16-24), which has a dedicated "Argument Parsing" section immediately after the identity block.

Structure:

```markdown
## Argument Parsing

Arguments: `#<issue> | <description text>`

- **`#<n>`** (issue mode): Fetch GitHub issue #n ...
- **`#<n> <trailing text>`** (issue + append mode): ...
- **Free text** (current behavior): ...
- **No arguments**: ...
```

This makes the argument handling explicit and unambiguous for Claude Code to follow. Without it, the issue-detection logic would be buried in prose and easy to misinterpret.

#### 3. Add examples for issue mode in despicable-prompter

The despicable-prompter SKILL.md has three worked examples (Vague Input, Implementation-Heavy Input, Well-Formed Input) plus two edge cases. These examples are the primary teaching mechanism -- they show Claude Code what the output should look like for each input class.

Add **one** new example showing the issue-fetch flow. A single example is sufficient because the issue mode is a different invocation path, not a different output format. The output template is the same; only the input source changes.

Suggested placement: after the existing three examples, before "Edge Cases". Title it "Example 4: Issue Reference".

The example should show:
- Input: `/despicable-prompter #42` (with a brief description of what the issue contains)
- Steps performed: fetched issue, extracted body, classified input, generated brief
- Output: the same fenced `/nefario` code block format as all other examples
- Post-output: the write-back behavior (updated issue body and title)

Keep it concise. The example's purpose is to confirm that the output template does not change and to demonstrate the write-back step. It is not needed to re-teach the classification logic.

#### 4. Update the empty-input edge case in despicable-prompter

The existing empty-input handler (lines 143-152) shows example invocations. This should be updated to include the issue-reference syntax:

```
Examples:
  /despicable-prompter add search to the docs site
  /despicable-prompter #42
  /despicable-prompter refactor the config system it's too complex
```

Adding one `#42` example into the existing list is enough. It communicates the feature's existence without over-documenting.

#### 5. Do NOT add examples to the nefario SKILL.md

The nefario SKILL.md is an orchestration workflow document (1,188 lines). It has no examples section. It does not show input/output pairs. The issue integration for nefario is a simple input-source change: instead of reading the task description from inline text, it reads it from a GitHub issue. This does not warrant examples -- the argument parsing section (recommendation 2) is sufficient documentation.

Adding examples to the nefario SKILL.md would break its existing structural pattern and add noise to an already long document.

#### 6. Document the write-back behavior inline, not in a separate section

For despicable-prompter, the write-back (updating issue body and title) should be documented as part of the argument parsing section and reinforced in the example. Do not create a separate "GitHub Integration" or "Write-back" section. The behavior is a consequence of the invocation mode, not a standalone feature. Documenting it inline keeps the skill's structure flat and avoids section proliferation.

Specifically, within the argument parsing bullet for `#<n>`, include the write-back as the last sub-step:

```markdown
- **`#<n>`** (issue mode): Fetch issue #n. Use the issue body as input.
  Classify and generate a brief as normal. After generating the brief:
  update the issue body with the brief content (without the `/nefario` prefix)
  and update the issue title to the brief's first-line summary.
```

### Proposed Tasks

**Task 1: Add argument parsing section and update frontmatter in despicable-prompter/SKILL.md**

- What: Add `argument-hint: "#<issue> | <rough idea or task description>"` to frontmatter. Add an "Argument Parsing" section after the identity paragraph (line 11). Include the issue mode, issue+trailing-text mode, free-text mode, and no-arguments mode. Document the write-back behavior inline within the issue mode bullet. Add "Example 4: Issue Reference" after Example 3. Update the empty-input edge case to include a `#42` example.
- Deliverables: Updated `skills/despicable-prompter/SKILL.md`
- Dependencies: Depends on devx-minion's argument parsing design (for the specific parsing rules and error messages), iac-minion's `gh` CLI invocation patterns (for the exact commands to document), and security-minion's input validation recommendations (for what guardrails to include in the parsing instructions).

**Task 2: Add argument parsing section and update frontmatter in nefario/SKILL.md**

- What: Add `argument-hint: "#<issue> | <task description>"` to frontmatter. Add an "Argument Parsing" section early in the document (after "Core Rules", before "Overview"). Include the issue mode, issue+trailing-text mode, and free-text mode (current behavior). No examples needed. The parsing section should specify that the resolved issue body becomes the task description inserted at `<insert the user's task description>` throughout the phases.
- Deliverables: Updated `skills/nefario/SKILL.md`
- Dependencies: Same as Task 1 (devx-minion, iac-minion, security-minion contributions).

### Risks and Concerns

1. **argument-hint length**: The `argument-hint` is displayed in a constrained UI space (Claude Code's skill invocation autocomplete). If the hint is too long, it may be truncated or visually noisy. The proposed hints (`#<issue> | <rough idea or task description>` = 43 chars, `#<issue> | <task description>` = 29 chars) are within reasonable bounds. The despicable-lab hint is 33 chars (`[agent-name ...] | --check | --all`), so this is consistent. Low risk, but worth verifying visually after implementation.

2. **Nefario SKILL.md length**: The nefario SKILL.md is already 1,188 lines. Adding an argument parsing section adds ~15-25 lines. This is marginal but worth noting -- every addition to this file increases the prompt burden on Claude Code. Keep the section minimal. The argument parsing section should be self-contained and not repeat information already in the Phase 1 instructions.

3. **Documentation-instruction blurring**: SKILL.md files serve a dual role: they are both documentation (for the human reading them) and executable instructions (for Claude Code following them). The argument parsing section must be unambiguous enough for Claude Code to implement correctly while remaining readable for humans maintaining the file. This is the core tension. The despicable-lab SKILL.md handles this well by using a bulleted list with bold argument patterns followed by colon-separated behavior descriptions. Follow that pattern.

4. **Write-back documentation completeness**: The write-back behavior has nuances that must be documented precisely or Claude Code will improvise: (a) what exactly is stripped from the brief before writing to the issue (the `/nefario ` prefix, but what about the trailing "Adjust anything..." line?), (b) does the update replace the entire issue body or append? The success criteria say "updates the issue body with the brief" -- this implies replacement, not append. This must be explicit in the SKILL.md text.

### Additional Agents Needed

None. The current team (devx-minion, iac-minion, security-minion, ux-strategy-minion, software-docs-minion) covers all dimensions of this task. The documentation concerns are fully within my domain and do not require other specialists.
