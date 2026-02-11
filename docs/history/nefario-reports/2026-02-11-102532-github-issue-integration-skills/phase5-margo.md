# Margo Code Review: GitHub Issue Integration

## Review Scope

Files reviewed:
- `skills/despicable-prompter/SKILL.md` (119 lines added)
- `skills/nefario/SKILL.md` (94 lines added)

Compared against the task prompt at `prompt.md`.

---

VERDICT: APPROVE

FINDINGS:

- [ADVISE] skills/despicable-prompter/SKILL.md:39-87 + skills/nefario/SKILL.md:49-96 -- The Issue Fetch section is nearly identical in both files (same `gh` check, same `gh issue view` call, same error messages, same `<github-issue>` content boundary wrapping). This is ~40 lines of duplicated specification. Currently acceptable because SKILL.md files are self-contained prompt documents (not code that can import shared modules), but worth noting: if a third skill ever needs issue fetch, extract a shared reference section or a conventions doc that both skills cite.
  FIX: No immediate action. If a third consumer appears, extract a `docs/conventions/issue-fetch.md` and reference it from each SKILL.md. Do not do this now (YAGNI).

- [NIT] skills/despicable-prompter/SKILL.md:101-108 -- The secret-scanning pattern list in the write-back section (`sk-`, `ghp_`, `github_pat_`, `AKIA`, `token:`, `bearer`, `password:`, `passwd:`, `BEGIN.*PRIVATE KEY`, `://.*:.*@`) is thorough and justified because it gates writing to a public GitHub issue. No over-engineering concern here -- this is appropriate defense in depth for a write-back to a remote service.
  FIX: None.

- [NIT] skills/nefario/SKILL.md:98-113 -- The "Issue Context" section adds four integration points (status line, branch name, PR body, report frontmatter). These are all lightweight touch-points, not new mechanisms. The section reads cleanly as a checklist. No YAGNI concern -- each point maps to an existing nefario feature that needs issue-awareness.
  FIX: None.

- [NIT] skills/despicable-prompter/SKILL.md:260-282 -- Example 4 (issue reference) is well-placed and correctly demonstrates the end-to-end flow including the write-back confirmation and the updated refinement offer. Good that it shows the full lifecycle rather than just the fetch.
  FIX: None.

## Summary

The changes are well-scoped to the task prompt requirements. Both skills gain `#<n>` argument parsing, issue fetch with error handling, content boundary tagging (prompt injection defense), and appropriate follow-through (write-back for prompter, context propagation for nefario). No speculative features were added. The nefario side correctly avoids write-back (the PR with "Resolves #N" is the only output artifact, which is the simplest loop-closing mechanism). The prompter side's write-back is requested behavior, not over-engineering.

The only structural concern is the duplication between the two Issue Fetch sections, but extracting shared conventions now would be premature -- there are only two consumers, and SKILL.md files need to be self-contained for the LLM to follow them without cross-file lookups.

No over-engineering. No unrequested features. No dependency bloat. Approve.
