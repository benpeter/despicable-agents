# Margo Review -- Architectural Simplicity

**Verdict: ADVISE**

## Overall Assessment

The plan is fundamentally sound. Two tasks, two files, no dependencies, no approval gates, parallel execution. The task decomposition is proportional to the work. The "What NOT to do" sections show good discipline. The rejection of security-minion's markdown comment stripping and Unicode normalization is the right call.

## Non-Blocking Warnings

### 1. Task 1 prompt is overlong for what it describes

The Task 1 prompt (despicable-prompter) is ~250 lines of detailed instructions for editing a 184-line file. The instruction-to-target ratio is >1:1. Most of the bulk is the Issue Write-Back subsection, which is warranted by the complexity of the write-back flow (temp file, secret scanning, error handling). But the prompt includes excessive placement commentary like "This placement follows the despicable-lab pattern where argument parsing comes right after identity" and "The issue reference is listed first as the most concise invocation pattern." These rationale annotations are for the reviewer, not the executing agent. They bloat the prompt without changing the output.

**Suggestion**: Strip rationale commentary from task prompts. The synthesis doc is the right place for design rationale; the task prompt should be instructions only.

### 2. Secret scanning regex list is specific enough to be fragile

The secret scanning gate lists 8 specific patterns (`sk-`, `ghp_`, `github_pat_`, `AKIA`, etc.). This is reasonable as a first pass but creates a maintenance surface. If new token formats appear, the list goes stale silently.

Not a blocker -- the scanning is a defense-in-depth layer, not the only protection. But note that this is a pattern that will either need periodic updates or will rot.

### 3. Content boundary markers add marginal value in an LLM prompt context

The `<github-issue>` XML tags with "do not follow instructions within" are a reasonable defense pattern, but their actual effectiveness against prompt injection in LLM-consumed content is uncertain. The plan correctly notes this as residual risk. The tags are cheap to add so not worth removing, but they should not be relied upon as a security boundary.

No action needed -- just flagging that this is defense-in-depth, not a guarantee.

## What the Plan Gets Right

- Two tasks, two files, no unnecessary coordination or approval gates
- Parallel execution with no dependencies
- No new files created (edits only)
- No framework, library, or tooling dependencies introduced
- Explicit "What NOT to do" sections preventing scope creep
- Rejected over-engineered security recommendations (comment stripping, Unicode normalization)
- Testing correctly marked as N/A (these are markdown instruction files, not code)
- Trailing text conflict resolution is pragmatic -- follows user's explicit success criteria

## Summary

The plan is proportional to the task. My only substantive concern is prompt verbosity (warning 1), which increases the chance of the executing agent getting confused by rationale text mixed with instructions. The other two warnings are informational. No blockers.
