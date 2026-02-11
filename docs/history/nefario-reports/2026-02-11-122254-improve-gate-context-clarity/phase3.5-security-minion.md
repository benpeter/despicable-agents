# Architecture Review: Security

## Verdict
**ADVISE**

## Assessment

The plan is security-sound overall. The core mitigation for code snippet exposure (secret scanning in Task 1 Edit 5) is present and functional, but the pattern list should be expanded for production use.

### Non-Blocking Recommendations

**1. Expand Secret Detection Patterns (Task 1, Edit 5, line 171)**

Current pattern list covers common cloud credentials but misses several important categories. Add:

- `api[_-]?key` (generic API keys)
- `secret[_-]?key` (generic secrets)
- `bearer\s+[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+` (JWT tokens)
- `[a-z0-9+/=]{40,}` context-aware (base64-encoded secrets)
- `://[^:]+:[^@]+@` (connection strings with embedded credentials)
- `aws_session_token` (temporary AWS credentials)
- `BEGIN.*CERTIFICATE` (not just private keys)
- `export\s+\w*(?:PASSWORD|SECRET|TOKEN|KEY)\w*=` (environment variable exports)

Specify case-insensitive matching for all patterns.

Add disclaimer text to the rule: "This is a heuristic scan, not exhaustive. Review all code paths manually for secrets before committing."

**2. Security Escalation Auto-Fix Bias (Task 1, Edit 4, line 146)**

The "Proceed with auto-fix" option is labeled "(recommended)", which may bias users toward blind acceptance of automated fixes without understanding impact. Consider one of:

- Remove "(recommended)" label to let users choose based on context
- Reorder options to put "Review first" as option 1 (making it the visual default)
- Add instruction: "If auto-fix is chosen, show a 10-line diff summary before applying"

**3. Secret Scanning Scope Limitation**

The 5-line CODE CONTEXT window in code review escalations may not capture multiline secrets like PEM blocks or service account JSON keys. Consider:

- Scanning the full file for PEM block patterns (`BEGIN.*PRIVATE KEY` through `END.*PRIVATE KEY`)
- If a PEM block is detected anywhere in the file, omit the entire CODE CONTEXT block and show only: "Code omitted (PEM block detected). Review: <path>"

### What Is Secure

- File paths, line deltas, and change scope descriptions in DELIVERABLE sections: safe metadata, no code exposure
- REQUEST truncation at 80 chars with "..." suffix: prevents prompt injection via long malicious input
- Git command execution in PR gate (Task 1, Edit 7): uses only fixed command strings and branch names from git's own state; no user input interpolation
- Structured format blocks throughout: no injection vectors into prompt evaluation
- Working directory paths: safe to expose (temporary scratch directories, no secrets)

### Risk Summary

| Finding | Severity | Status |
|---------|----------|--------|
| Incomplete secret detection patterns | Medium | Mitigated by existing rule; enhancement recommended |
| Auto-fix bias in security escalation | Low | Non-blocking UX concern |
| Multiline secret detection gaps | Low | Edge case; enhancement optional |
| Code snippet injection into prompts | None | No injection vectors identified |
| Information leakage via metadata | None | File paths and line counts are safe to expose |

## Conclusion

No blocking security issues. The secret scanning mitigation addresses the primary risk (code exposure in escalation briefs). Recommendations above are enhancements for defense-in-depth, not requirements for safe execution.
