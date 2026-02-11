## Domain Plan Contribution: devx-minion

### Recommendations

#### 1. Argument Parsing Structure

The argument parsing should be documented as a new top-level section in each SKILL.md, placed immediately after the YAML frontmatter and before the first behavioral section. It defines a contract the skill follows on every invocation. The section should be called **"Input Resolution"** (not "argument parsing" -- it is resolving what the user wants, not parsing a grammar).

**Input Resolution rules (both skills share this logic):**

```
## Input Resolution

On invocation, classify the input into one of four modes:

1. **Issue mode** (`#<number>` as first token):
   - Extract the issue number (digits only after `#`)
   - Trailing text after the issue number = supplemental context
   - Fetch the issue (see Issue Fetch below)
   - Combine: issue body + newline + trailing text (if any) = effective input

2. **Issue mode with supplement** (`#<number> <trailing text>`):
   - Same as (1), with trailing text appended to the issue body
   - The trailing text is appended with a blank line separator:
     `<issue body>\n\n---\nAdditional context: <trailing text>`

3. **Plain text mode** (first token is NOT `#<number>`):
   - Entire input is the task description (current behavior, unchanged)

4. **Empty input** (no arguments):
   - Existing empty-input behavior applies (examples for prompter, error for nefario)
```

Modes 1 and 2 are actually the same code path (trailing text is either empty or present). This simplifies implementation to: "Does input start with `#` followed by digits? If yes, issue mode. Otherwise, plain text mode."

**Update `argument-hint` in frontmatter** to signal the new capability:

```yaml
# despicable-prompter
argument-hint: "<idea or task description> | #<issue-number> [extra context]"

# nefario
argument-hint: "<task description> | #<issue-number> [extra context]"
```

The pipe-separated format follows CLI convention for alternative invocation patterns. The bracket notation signals optional arguments.

#### 2. Issue Fetch Procedure

The fetch procedure should be a reusable block in both skills (identical wording, copy-pasted -- skills cannot share code). Place it as a subsection under Input Resolution:

```
### Issue Fetch

Prerequisites:
- Verify `gh` is available: `command -v gh >/dev/null 2>&1`
- If unavailable, stop with error (see Error Messages below)

Fetch:
  gh issue view <number> --json number,title,body,state,labels

Validation:
- If `gh` exits non-zero (issue not found, auth failure, network error):
  stop with error (see Error Messages below)
- If issue state is "closed": proceed normally (do not block on closed issues;
  the user may be reopening or referencing)

The effective input is:
- Issue body alone (if no trailing text)
- Issue body + separator + trailing text (if trailing text provided)

The issue title and number are retained in context for later use
(prompter uses them for write-back; nefario uses them for the status line).
```

#### 3. Error Message Design

Three error scenarios, each following the "what went wrong / how to fix / how to get help" pattern. These are the exact messages the skills should output:

**gh CLI not available:**
```
Cannot fetch GitHub issue: `gh` CLI is not installed or not in PATH.

Install: https://cli.github.com
Verify:  gh --version

Alternatively, paste the issue content directly:
  /despicable-prompter <paste issue body here>
```

This message: (a) names the problem specifically, (b) provides the install link and verification command, (c) offers a workaround that does not require installing anything. The workaround is critical -- it means the user is never blocked.

**Issue not found (gh exits non-zero):**
```
Cannot fetch issue #<number>: <gh error output, first line only>

Check:
  - Issue exists: gh issue view <number>
  - You are in the correct repository
  - You are authenticated: gh auth status
```

This message: (a) includes the issue number for context, (b) passes through gh's own error (which distinguishes 404 from auth failure from network error), (c) provides three diagnostic commands in decreasing likelihood order. The first line of gh's error is sufficient -- it already says "Could not resolve to an issue" or "HTTP 404" etc.

**Auth failure (gh auth):**
Not a separate case. The `gh` CLI itself returns a clear auth error message. The "Issue not found" handler passes it through. No need to special-case auth separately -- it would add complexity without helping the user (gh's auth error already says "run `gh auth login`").

#### 4. Prompter Write-Back Design

The despicable-prompter has an additional requirement: writing the generated brief back to the issue and updating its title. This should be a new section in the prompter's SKILL.md, placed after the Output Template section.

```
### Issue Write-Back (Issue Mode Only)

After generating the brief, if the input was resolved from an issue:

1. Extract the brief from the fenced code block (strip the opening/closing ```)
2. Remove the `/nefario ` prefix from the first line (the issue title gets the
   first line; the body gets the rest without the command prefix)
3. Update the issue:
   gh issue edit <number> --title "<first line of brief>" --body "<brief body without first line>"
4. If the edit succeeds, confirm:
   Updated issue #<number>: <new title>
   https://github.com/<owner>/<repo>/issues/<number>
5. If the edit fails, warn but do not treat as fatal:
   Warning: Could not update issue #<number>: <gh error>
   The brief is shown above -- copy it manually.

The brief is ALWAYS shown in chat (the existing output behavior). The write-back
is additive. If it fails, the user still has the brief in their terminal.
```

Key design decisions in this recommendation:

- **Strip `/nefario` prefix for the issue body.** The issue is a standalone artifact; it should not contain a slash-command that only works in Claude Code. The success criteria explicitly state "without `/nefario` prefix."
- **Title from first line.** The first line of the brief is already designed to be a one-line task summary -- it maps directly to an issue title.
- **Non-fatal write-back.** If `gh issue edit` fails (permissions, network), the user still sees the brief in chat. This follows the principle that the primary output channel (stdout/chat) always works, and the secondary channel (issue update) is best-effort.
- **Show the issue URL after update.** This gives the user a clickable link to verify the update, and serves as confirmation that the write-back targeted the correct issue.

#### 5. Nefario Issue Integration

For nefario, the integration is simpler -- it only reads, never writes back. The effective input (issue body + optional trailing text) becomes the task description fed into Phase 1. One additional behavior:

```
### Issue Context (Issue Mode Only)

When input is resolved from an issue, retain in session context:
- `source-issue`: <number>
- `source-issue-title`: <original title before any modification>

Use the issue number in:
- Status line summary: "Nefario: #<number> <truncated summary>"
- Branch name: `nefario/<slug>` (slug derived from effective input, as before)
- PR description: "Resolves #<number>" in the body (enables GitHub auto-close)

Do NOT modify the issue from nefario. The issue is the source of truth for
the task description; nefario's output is the PR, not an issue update.
```

The "Resolves #N" in the PR body is a high-value, low-effort addition. It closes the issue automatically when the PR merges, completing the GitHub workflow loop without any extra user action.

#### 6. Trailing Text Append Semantics

When `#42 also consider caching` is provided, the trailing text "also consider caching" must be appended to the issue body in a way that is clearly delineated. Two options:

**Recommended: Separator block**
```
<issue body as-is>

---
Additional context: also consider caching
```

The horizontal rule (`---`) provides visual separation. The "Additional context:" label makes the provenance clear when reading the combined text. This format works well for both human readers (if they view the issue) and for the LLM consuming it (the label provides semantic context).

**Not recommended: Bare concatenation**
```
<issue body as-is>

also consider caching
```

This is ambiguous -- the trailing text could be mistaken for part of the original issue body. For the prompter this matters because it writes back; for nefario it matters less, but consistency between skills is more important than per-skill optimization.

**For despicable-prompter specifically**: When writing back to the issue in issue mode with trailing text, the write-back should include the trailing text as part of the issue body. The issue should be self-contained after the prompter updates it.

### Proposed Tasks

**Task 1: Add Input Resolution section to both SKILL.md files**
- What: Add the "Input Resolution" section with the four-mode classification, the "Issue Fetch" subsection, and the three error messages to both `skills/despicable-prompter/SKILL.md` and `skills/nefario/SKILL.md`. Update `argument-hint` in both frontmatter blocks.
- Deliverables: Updated SKILL.md files with Input Resolution sections
- Dependencies: None

**Task 2: Add Issue Write-Back section to despicable-prompter SKILL.md**
- What: Add the "Issue Write-Back" section after the Output Template section. This covers stripping the `/nefario` prefix, updating issue title and body via `gh issue edit`, confirmation message, and non-fatal failure handling.
- Deliverables: Updated `skills/despicable-prompter/SKILL.md`
- Dependencies: Task 1 (Input Resolution must exist first for the write-back to reference)

**Task 3: Add Issue Context section to nefario SKILL.md**
- What: Add the "Issue Context" subsection covering session context retention (`source-issue`, `source-issue-title`), status line format, and "Resolves #N" in PR body. Update the PR creation section to include the auto-close reference when a source issue exists.
- Deliverables: Updated `skills/nefario/SKILL.md`
- Dependencies: Task 1

**Task 4: Update Empty Input and Examples sections**
- What: Update the despicable-prompter's "Empty Input" examples to include an issue-mode example (`/despicable-prompter #42`). Add a brief example to nefario showing issue-mode invocation. Add at least one issue-mode example to the prompter's Examples section showing the full flow (fetch, generate, write-back).
- Deliverables: Updated example sections in both SKILL.md files
- Dependencies: Tasks 1-3

### Risks and Concerns

1. **`gh` authentication state is unpredictable.** Users may have `gh` installed but not authenticated, or authenticated to the wrong account/org. The error message design above handles this by passing through gh's own error output, but the user experience of "gh exists but auth is broken" is inherently messier than "gh is missing." Mitigation: the error message includes `gh auth status` as a diagnostic step.

2. **Issue body format variability.** GitHub issue bodies can contain anything: markdown, HTML, images, task lists, code blocks, frontmatter-like YAML. The prompter and nefario both consume this as plain text, which is fine for LLM processing. But the write-back step (prompter only) replaces the entire body. If the original issue had task lists, embedded images, or other rich content, it will be lost. Mitigation: this is acceptable because the success criteria define the write-back as replacing the body with the brief. But it should be documented as a known behavior: "The original issue body is replaced with the generated brief."

3. **Race condition on issue body.** Between fetch and write-back (prompter), someone else could edit the issue. This is a theoretical concern with low practical risk (the window is seconds). No mitigation needed for v1 -- just document it as a known limitation if it ever matters.

4. **`#` as a valid start of plain text.** A user typing `/despicable-prompter #hashtag-driven-development` would trigger issue mode and fail. Mitigation: the pattern must be `#` followed by one or more digits only (`#[0-9]+`). `#hashtag` does not match. The regex `^#(\d+)` is sufficient. Document this: "Only `#` followed by digits triggers issue mode."

5. **Issue number zero or negative.** Edge case: `#0` or `#-1`. GitHub does not have issue #0. Mitigation: the `gh issue view 0` command will return an error, which the error handler will catch and display. No special handling needed.

6. **Large issue bodies.** Some issues have very long bodies (design docs, RFCs). This is fine for nefario (it processes long inputs already). For the prompter, the brief generation is robust to long inputs. No special handling needed.

7. **Repository context dependency.** `gh issue view <number>` operates on the current repository (detected from git remote). If the user runs the skill from a different directory or a fork, they will get unexpected results. Mitigation: the error message for "issue not found" includes "You are in the correct repository" as a diagnostic step. This is sufficient for v1.

### Additional Agents Needed

None. The task is scoped to two SKILL.md files, both of which are natural language prompt documents (not code). The devx-minion perspective covers argument parsing design, error messages, and user experience flow. No additional domain expertise is needed beyond what nefario's synthesis will provide.

One note: if the plan included writing automated tests for the argument parsing, a test-minion contribution would be relevant. But since SKILL.md files are declarative prompts consumed by an LLM (not executable code), there is no testable code artifact. Verification is manual: invoke the skill with each mode and confirm behavior.
