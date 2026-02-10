# Security Review: ADVISE

1. **Redaction timing**: Make prompt.md writing instruction explicit that it uses the already-sanitized value. Recommend: "Write the **already-sanitized** original prompt..."
2. **Scan pattern gaps**: Add `ghp_`, `github_pat_`, `AKIA` to the security scan pattern list in SKILL.md wrap-up step 5.
3. **PR body defense-in-depth**: Add a grep-based secret scan on the PR body file before `gh pr create`.
