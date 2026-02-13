# Documentation Impact Checklist

Source: Phase 3.5 architecture review
Plan: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1ytDH0/replace-session-id-with-hook/phase3-synthesis.md

## Items

- [ ] **[software-docs]** Update using-nefario.md to explain SessionStart hook mechanism
  Scope: Replace shared file explanation with env var mechanism, update manual config example
  Files: /Users/ben/github/benpeter/despicable-agents/docs/using-nefario.md
  Priority: MUST

- [ ] **[software-docs]** Verify architecture.md or orchestration.md do not reference /tmp/claude-session-id
  Scope: Check if any architecture docs mention the old shared file mechanism
  Files: /Users/ben/github/benpeter/despicable-agents/docs/architecture.md, /Users/ben/github/benpeter/despicable-agents/docs/orchestration.md
  Priority: SHOULD

- [ ] **[software-docs]** Add troubleshooting entry for CLAUDE_SESSION_ID not set
  Scope: Document fallback behavior and how to verify hook is working
  Files: /Users/ben/github/benpeter/despicable-agents/docs/using-nefario.md (troubleshooting section)
  Priority: SHOULD

- [ ] **[software-docs]** Document CLAUDE_ENV_FILE persistence behavior across compaction
  Scope: Explain why hook fires on every SessionStart, not once
  Files: /Users/ben/github/benpeter/despicable-agents/docs/using-nefario.md or docs/orchestration.md
  Priority: COULD

- [ ] **[software-docs]** Update CHANGELOG or migration notes for existing users
  Scope: Document that users should re-run /despicable-statusline to get clean command
  Files: /Users/ben/github/benpeter/despicable-agents/CHANGELOG.md or docs/migration.md
  Priority: SHOULD
