VERDICT: ADVISE

FINDINGS:

- [ADVISE] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:140-148 -- Summary extraction lacks explicit sanitization for shell metacharacters before writing to sentinel file. While `echo "$summary"` is quoted in the example, the instruction doesn't mandate that the orchestrator must use proper quoting when constructing the actual Bash command.
  AGENT: devx-minion
  FIX: Add explicit instruction: "Ensure proper quoting when constructing the Bash command. Example: `bash -c "echo \"\$summary\" > /tmp/nefario-status-\${slug}"`" or use Write tool instead of Bash for safer file creation.

- [ADVISE] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:140-148 -- No validation or error handling for summary extraction. If the task description is empty or missing, the sentinel file will be created with an empty or invalid value.
  AGENT: devx-minion
  FIX: Add validation step: "If task description is empty or missing, use a default summary (e.g., 'Orchestration in progress')."

- [ADVISE] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:140-148 -- Truncation logic is clearly specified (51 chars + "..." if truncated), but the instruction doesn't clarify how to count characters for multi-byte UTF-8 sequences. Task descriptions may contain emojis or international characters.
  AGENT: devx-minion
  FIX: Clarify truncation behavior: "Count characters (not bytes). Use string slicing that respects Unicode code points. If the description contains multi-byte UTF-8 characters, ensure truncation doesn't split a character."

- [ADVISE] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:140-148 -- The chmod 600 permission is correct for security (owner-only read), but the instruction doesn't explain why this is necessary or what happens if chmod fails.
  AGENT: devx-minion
  FIX: Add brief explanation: "chmod 600 restricts read access to the current user, preventing other users on the system from seeing task summaries. If chmod fails (e.g., unsupported filesystem), the sentinel file will remain world-readable (644 default), but orchestration should continue."

- [NIT] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:140-148 -- The inline comment "# Status file: read from custom statusline scripts" is helpful but could be clearer about the sentinel file's lifecycle (created at Phase 1, cleaned at wrap-up).
  AGENT: devx-minion
  FIX: Expand comment: "# Sentinel file for custom statusline scripts (created Phase 1, cleaned at wrap-up)"

- [NIT] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:586-588 -- The activeForm truncation logic ("If the combined string exceeds 80 characters, use just the task-specific activeForm") is clear, but doesn't specify whether to count the summary + " -- " + task-specific string when checking the 80-char limit.
  AGENT: devx-minion
  FIX: Clarify: "If the combined string (`Nefario: <summary> -- <task-specific activeForm>`) exceeds 80 characters, omit the summary prefix and use only the task-specific activeForm."

- [APPROVE] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:167,208,267,351,764 -- All Task description fields are consistently updated to "Nefario: <phase>" format. Good coverage across meta-plan, specialist planning, synthesis, review, and code review phases.

- [APPROVE] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:981 -- Sentinel file cleanup is correctly placed alongside the orchestrated-session marker cleanup at wrap-up (Phase 11). Both use the same `${slug}` variable for consistency.

- [APPROVE] /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md:140-148 -- Truncation specification is clear: 51 chars from task description, append "..." if truncated, ensuring "Nefario: " prefix + summary stays within 60 chars total.
