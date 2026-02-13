# Security Review: Compaction Gate Context + Clipboard

## Verdict: ADVISE

### Warnings

1. **Command injection via interpolated values in pbcopy (Low risk)**
   The `$summary` and scratch directory path are interpolated into a string passed to `echo '...' | pbcopy`. Because single quotes are used in the echo, shell metacharacter injection is effectively prevented for the pbcopy path itself. However, the plan instructs the devx-minion to interpolate values into the focus string. If `$summary` or the scratch directory path ever contains single quotes, the shell command breaks or behaves unexpectedly. The current SKILL.md already has a comment forbidding backticks, single quotes, and backslashes in focus strings -- this existing control is sufficient. No action needed, but worth noting that the interpolation must continue to respect that constraint.

2. **Clipboard as a trust boundary (Informational)**
   The pbcopy writes a `/compact` command to the system clipboard. The user must paste and execute it manually, which provides a human-in-the-loop gate. This is the correct pattern. The `2>/dev/null` error suppression is acceptable here since pbcopy failure is non-security-relevant (no secrets, no network, clipboard is local-only).

3. **No secret exposure in context display (Confirmed safe)**
   The context usage display (`$context_pct`, `$context_remaining_k`) derives from token counts in `<system_warning>`, which contains no secrets or PII. The values are integers. No data leakage risk.

4. **No clipboard read -- write-only (Confirmed safe)**
   The plan only writes to clipboard (pbcopy), never reads from it (pbpaste). There is no clipboard injection attack surface from external content flowing into the agent.

### Summary

No blocking security concerns. The attack surface is minimal: a local-only clipboard write of a deterministic command string with human-in-the-loop execution. The existing focus-string sanitization comment adequately constrains interpolation risks. All changes are spec-only with no executable runtime code.
