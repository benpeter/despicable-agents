# Code Review: GitHub Issue Integration Skills

## Verdict: APPROVE

## Summary

Both SKILL.md files have been reviewed for code quality, shell command correctness, consistency between the two skills, secret scanning patterns, content boundary markers, and markdown structure. The implementation is solid with excellent consistency between the two skills. All shell commands follow best practices, and the security patterns are comprehensive.

## Findings

### ADVISE: despicable-prompter/SKILL.md

- **NIT** line 102-104 -- Secret scanning pattern could be more precise for base64 keys
  FIX: Consider adding length constraints to base64 detection if implementing, e.g., `[A-Za-z0-9+/=]{40,}` for high-entropy strings. Current patterns are adequate for common secrets, but base64-encoded keys may slip through.

- **NIT** line 110-117 -- Temp file cleanup could be more robust
  FIX: Consider wrapping in a trap to ensure cleanup on script interruption:
  ```bash
  body_file=$(mktemp)
  trap "rm -f '$body_file'" EXIT
  echo "$body_content" > "$body_file"
  gh issue edit <number> --title "<new title>" --body-file "$body_file"
  ```
  Current approach is acceptable for normal flows but may leave temp files on interrupt.

### ADVISE: nefario/SKILL.md

- **NIT** line 110-113 -- Missing explicit note about write-back exclusivity
  FIX: Consider adding a note after line 113 clarifying that trailing text is ephemeral (not written to the issue). This is documented in line 44, but repeating in the Issue Context section would improve clarity.

### ADVISE: Both skills

- **NIT** -- GitHub CLI error message parsing
  FIX: Both skills use "first line of gh error output" (despicable-prompter line 64, nefario line 74). Consider showing up to 2-3 lines or the full stderr if short, as some `gh` errors are multiline. Example:
  ```bash
  gh_error=$(gh issue view <number> --json number,title,body 2>&1)
  if [ $? -ne 0 ]; then
    echo "Cannot fetch issue #<number>:"
    echo "$gh_error" | head -n 3
  fi
  ```

## Strengths

1. **Excellent consistency**: Issue fetch logic is nearly identical between the two skills (lines 39-96 in prompter, lines 49-113 in nefario). This reduces maintenance burden and cognitive load.

2. **Content boundary protection**: Both skills use `<github-issue>` tags and explicitly warn against following embedded instructions. The defense-in-depth approach (Rule 7 in prompter, line 96 in nefario) is strong.

3. **Secret scanning patterns**: Comprehensive coverage of common credential formats (API keys, tokens, passwords, private keys, connection strings). The patterns cover:
   - Cloud provider keys: `sk-`, `AKIA` (AWS)
   - GitHub tokens: `ghp_`, `github_pat_`
   - Generic: `token:`, `bearer`, `password:`, `passwd:`
   - PKI: `BEGIN.*PRIVATE KEY`
   - Connection strings: `://.*:.*@`

4. **Robust shell commands**:
   - `command -v gh` for availability check (POSIX-compliant, better than `which`)
   - `--body-file` for `gh issue edit` avoids shell quoting issues
   - `mktemp` without hardcoded paths (respects `$TMPDIR`)
   - `chmod 600` for temp files (security best practice)
   - JSON output format for `gh issue view` (structured, parseable)

5. **Error handling**: Both skills provide actionable error messages with remediation steps (install links, auth status checks, alternative workflows).

6. **Markdown structure**: Both files are well-structured with clear headings, consistent formatting, and proper nesting. The argument-hint in frontmatter matches the documented syntax.

7. **PR integration**: nefario skill correctly includes `Resolves #<number>` in PR body (lines 107-122), enabling GitHub auto-close on merge. This is the right place for issue-PR linkage (not status comments).

## Specific Correctness Checks

### Shell Commands

✅ `command -v gh >/dev/null 2>&1` -- correct POSIX check (lines prompter:45, nefario:55)
✅ `gh issue view <number> --json number,title,body` -- correct JSON output (lines prompter:60, nefario:70)
✅ `body_file=$(mktemp)` -- respects TMPDIR, secure (lines prompter:113, nefario:1108)
✅ `gh issue edit <number> --title "<title>" --body-file "$body_file"` -- avoids quoting issues (prompter:115)
✅ `tail -n +2 "$report_file" | sed '1,/^---$/d'` -- strips YAML frontmatter (nefario:1109)
✅ `rm -f "$body_file"` -- idempotent cleanup (lines prompter:116, nefario:1117)
✅ `chmod 600` for status sentinel (nefario:286) -- restricts to owner only

### Secret Patterns

✅ `sk-` -- OpenAI/Anthropic API keys
✅ `ghp_` and `github_pat_` -- GitHub tokens
✅ `AKIA` -- AWS access keys
✅ `token:`, `bearer`, `password:`, `passwd:` -- generic credentials
✅ `BEGIN.*PRIVATE KEY` -- PEM-encoded keys
✅ `://.*:.*@` -- connection strings with embedded credentials

Missing but acceptable:
- Base64 high-entropy detection (complex regex, high false-positive rate)
- Cloud provider specific patterns (Azure SAS tokens, GCP keys) -- would add noise for edge cases

### Content Boundary Markers

✅ Both skills use `<github-issue>` tags (prompter:79-86, nefario:88-96)
✅ Explicit defense against prompt injection (prompter Rule 7 line 156, nefario line 96)
✅ Clear distinction between task description content and orchestration directives

### Consistency Between Skills

| Element | despicable-prompter | nefario | Match? |
|---------|-------------------|---------|--------|
| Argument syntax | `#<n>` \| `<text>` | `#<n>` \| `<text>` | ✅ |
| Issue fetch logic | lines 39-75 | lines 49-85 | ✅ |
| Content boundaries | lines 76-86 | lines 86-96 | ✅ |
| Error messages | lines 48-70 | lines 58-80 | ✅ |
| Secret patterns (PR body) | (issue only) | lines 1111-1115 | N/A |
| Temp file pattern | `mktemp` + `--body-file` | `mktemp` + `--body-file` | ✅ |

No inconsistencies found. The two skills follow the same patterns where applicable.

## Recommendations

All findings are **non-blocking advisory notes** for future improvement. The current implementation is production-ready and follows best practices for shell scripting, security, and error handling.
