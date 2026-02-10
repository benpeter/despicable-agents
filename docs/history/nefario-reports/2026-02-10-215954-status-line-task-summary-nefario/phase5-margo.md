# Phase 5 Review: margo (simplicity / YAGNI / KISS)

## File Reviewed

`/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

---

VERDICT: ADVISE

FINDINGS:

- [ADVISE] skills/nefario/SKILL.md:140-148 -- Sentinel file mechanism adds a side-channel coupling for uncertain benefit
  AGENT: devx-minion
  FIX: The sentinel file (`/tmp/nefario-status-${slug}`) exists purely so external statusline scripts can read it. This is not inherently wrong, but note: (a) the comment on line 145 is the only documentation of who consumes this file -- no consumer script exists in this repo, meaning the integration point is entirely implicit; (b) the 51-character truncation rule plus "..." append logic is micro-specification for a `/tmp` file read by an unspecified consumer. If the consumer is a personal dotfile script, this works fine but is un-testable from this repo's perspective. Consider: if no consumer script exists yet, this is speculative infrastructure (YAGNI). If one does exist, reference it in the inline comment so future readers understand the contract. No code change required -- just awareness that this is the one piece that leans speculative.

- [NIT] skills/nefario/SKILL.md:586-588 -- activeForm prefix has a reasonable 80-char overflow rule but adds a conditional branch to every task creation
  AGENT: devx-minion
  FIX: The `"Nefario: <summary> -- <task-specific activeForm>"` pattern with the 80-char fallback is simple enough. The fallback rule ("if combined exceeds 80 chars, use just the task-specific activeForm") is a sensible escape hatch. No change needed. Flagging only to note that this is the most operationally visible part of the change -- if the summary is garbled (bad truncation, odd characters from the task description), it will be visible in every task's UI display. The truncation logic at line 141 should be sufficient to prevent this.

## Summary

The changes are minimal and proportionate. Three surgical additions (summary extraction, activeForm prefix, sentinel cleanup) totaling approximately 20 lines of specification. No new dependencies, no new abstraction layers, no technology expansion.

The one mild YAGNI concern is the sentinel file: it creates a `/tmp` file for an external consumer that is not defined in this repository. If the consumer already exists in the user's dotfiles, the concern is moot. If it does not yet exist, this is building the producer side of an integration before the consumer exists -- classic "build it and they will come." The cost is low (3 lines of shell), but worth noting.

The activeForm prefix and description prefix changes are straightforward UX improvements that surface context where the user needs it. No over-engineering detected.

Overall complexity budget impact: approximately 0.5 points (one small implicit integration contract). Well within budget.
