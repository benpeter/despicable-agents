ADVISE

1. **Add three-way format consistency check to verification steps**: The plan synchronizes the Decision Brief Format across SKILL.md, AGENT.overrides.md, and AGENT.md manually (Task 2). Verification step 1 says "confirm identical" but doesn't specify how. Add: `diff -u <(grep -A 30 "Decision Brief Format" skills/nefario/SKILL.md) <(grep -A 30 "Decision Brief Format" nefario/AGENT.md)` to catch drift.

2. **Validate secret scanning pattern before deployment**: Edit 5 adds regex-like patterns `(sk-, AKIA, ghp_, token:, password:, BEGIN.*PRIVATE KEY)`. These should be tested against known credential formats to avoid false negatives. Consider adding test cases in verification: create a temp file with sample credentials (AWS key, GitHub token, SSH key) and confirm the pattern matches.

3. **Document graceful degradation boundaries**: Task 1 prompt mentions "graceful degradation: if agent omits summary, gate falls back to bare file paths" but this fallback behavior isn't specified in the format templates. If this is critical path (gates must work even if agents don't provide summaries), the SKILL.md format should document the minimum required fields vs optional fields.

4. **Line count calculation may fail silently**: Risk table mentions "New files use wc -l. Modified files use git diff --stat. If unavailable, omit delta." This fallback should be explicit in the format specification so future agents know when to include deltas vs when to skip.

These are non-blocking. The changes are low-risk (markdown templates), reversible (git revert), and the three-way sync is explicitly addressed in Task 2. But adding basic validation to the verification steps would catch copy-paste errors before the first production orchestration uses the broken format.
