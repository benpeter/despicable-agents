VERDICT: APPROVE

FINDINGS:

- [NIT] skills/despicable-prompter/SKILL.md:282 -- The Example 4 closing text "Adjust anything (re-run /despicable-prompter #42 to update), or /nefario #42 to execute." appears outside the fenced code block, matching the new Refinement Offer convention for issue mode. This is consistent. No action needed, noting for completeness.

- [ADVISE] skills/nefario/SKILL.md:98-113 -- The "Issue Context" section introduces four integration points (status line, branch name, PR body, report frontmatter) that go beyond the fetch-and-use pattern described in the prompt. The prompt says "/nefario #42 fetches issue #42 and uses its body as the task prompt" -- the PR body `Resolves #N` linkage, report frontmatter `source-issue` field, and status line inclusion are additive enhancements not explicitly requested. However, these are natural consequences of issue integration and align with the stated outcome of "keeping issue trackers as the source of truth." They do not violate any rules and are sensible engineering. No fix required, but note the scope expansion for the record.
  FIX: None needed. These are reasonable corollaries of the feature.

- [NIT] skills/nefario/SKILL.md:44 -- The comment "The trailing text is NOT written back to the issue; it augments the prompt only" is a good clarification that differentiates nefario behavior from despicable-prompter behavior (where trailing text IS included in write-back). This asymmetry is intentional per the prompt ("The prompter additionally writes its output back to the issue, closing the loop" vs. nefario which only reads). Noting the design intent is correctly captured.

- [NIT] skills/nefario/SKILL.md:1118-1120 -- The `Resolves #<source-issue>` PR body addition in Phase 4 step 10 is correctly placed within the existing PR creation flow. It references `source-issue` from the Issue Context section (line 109). The wording "Insert it after the frontmatter-stripped content and before the end of the body file" is clear and actionable.

## Convention Adherence

Both files follow existing patterns:
- YAML frontmatter `argument-hint` field updated consistently in both files
- Section heading levels match existing hierarchy (## for top-level sections, ### for subsections)
- Code blocks use consistent fencing style (triple backticks, no language specifier for shell examples, matching existing convention)
- Error message formatting follows the existing pattern in the codebase (structured blocks with context and remediation steps)
- Markdown bullet formatting matches existing style (dash-prefixed, bold labels)
- The "Argument Parsing" section is placed after "Core Rules" in both files, maintaining logical reading order (rules first, then input handling)

## CLAUDE.md Compliance

- All content is in English
- No PII or proprietary data introduced
- No changes to `the-plan.md`
- No new dependencies or frameworks introduced
- Scope restricted to `skills/despicable-prompter/SKILL.md` and `skills/nefario/SKILL.md` only (verified via `git diff --name-only main..HEAD`)
- No AGENT.md files, install.sh, or docs were modified (matches scope constraint from prompt)

## Intent Alignment

The implementation matches all six success criteria from the prompt:
1. `/despicable-prompter #42` -- fetches, generates brief, updates issue title+body (Argument Parsing + Issue Fetch + Issue Write-Back sections)
2. `/nefario #42` -- fetches and uses body as task prompt (Argument Parsing + Issue Fetch sections)
3. `/despicable-prompter #42 also consider caching` -- trailing text appended before processing (line 25-30 in prompter)
4. `/nefario #42 skip phase 8` -- trailing text appended to task description (line 34-44 in nefario)
5. Non-existent issues -- clear error from `gh` non-zero exit (Issue Fetch step 2 in both files)
6. `gh` CLI unavailable -- clear error message with install link (Issue Fetch step 1 in both files)

Both skills also include prompt injection defense via `<github-issue>` content boundary markers and secret scanning before write-back (despicable-prompter only, since nefario does not write back).

## Scope Compliance

Only the two SKILL.md files were modified. No out-of-scope changes detected.
