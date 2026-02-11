# UX Strategy Review: GitHub Issue Integration

## Verdict: ADVISE

The plan is solid but has four UX concerns that should be addressed to improve user experience.

## Non-Blocking Issues

### 1. Write-back surprise factor (MEDIUM)

**Issue**: despicable-prompter silently overwrites the GitHub issue body after generation. This is potentially destructive and surprising behavior. While GitHub preserves edit history, users accustomed to read-only workflows may not expect an analysis tool to mutate upstream data.

**Recommendation**: Add a one-line confirmation after the fetch but before write-back:
```
Fetched issue #42 (will update after generating brief)
```

This sets expectation without adding friction. The "no confirmation prompts" decision prevents blocking writes, but a status line provides awareness without workflow interruption.

### 2. Trailing text semantics are inconsistent (HIGH)

**Issue**: Trailing text has different behaviors in the two skills:
- **despicable-prompter**: Appends to issue body → enriches brief → written back to issue
- **nefario**: Appends to prompt only → NOT written back to issue

From the user's mental model: `/tool #42 extra text` looks identical in both cases, but one mutates the issue and one doesn't. This violates principle of least surprise.

**Recommendation**: Make trailing text ephemeral for BOTH skills. For despicable-prompter, append trailing text when generating the brief but do NOT include it in the write-back. This aligns with the conflict resolution note that "skip phase 8" shouldn't pollute the issue. The same principle applies to all trailing text: it's a session-scoped augmentation, not a persistent edit.

Updated behavior:
```
Input:  #42 plus add integration tests
Brief:  Generated from (issue body + trailing text)
Write:  Contains only the brief (no trailing text persisted)
```

### 3. Issue reference discoverability (LOW)

**Issue**: The `#42` pattern is intuitive for GitHub users, but there's no in-band hint that this mode exists. The empty input examples show it, but users must invoke with no arguments to see that.

**Recommendation**: Update the argument-hint to make the pattern more discoverable:
```yaml
argument-hint: "#<issue-number> [extra context] | <task description>"
```

The brackets signal optionality. The pipe separator is already established convention.

### 4. Error message formatting (LOW)

**Issue**: Error messages use triple-backtick blocks, which render as code blocks in terminal output. This adds visual noise for what should be plain diagnostic text.

**Recommendation**: Remove the triple backticks from error message formatting. Use plain text with indentation for structure:

```
Cannot fetch GitHub issue: `gh` CLI is not installed or not in PATH.

Install: https://cli.github.com
Verify:  gh --version

Alternatively, paste the issue content directly:
  /despicable-prompter <paste issue body here>
```

The backticks around `gh` are fine (inline code), but the whole block shouldn't be fenced.

## Positive Observations

- Content boundary markers (`<github-issue>` tags) are a strong defense against prompt injection
- Secret scanning gate is appropriately paranoid for public issue write-back
- Refinement offer update for issue mode is exactly right
- `Resolves #N` in PR body creates clean workflow loop
- Provenance HTML comment is good practice
- `--body-file` approach sidesteps shell quoting issues elegantly

## Summary

The core UX design is sound. Address the trailing text inconsistency (HIGH priority) and consider adding write-back awareness (MEDIUM). The other two are nice-to-haves.
