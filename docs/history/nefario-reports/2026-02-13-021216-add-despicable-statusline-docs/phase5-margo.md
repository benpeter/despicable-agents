VERDICT: APPROVE

Documentation is proportional to the feature. The statusline skill has four distinct configuration states, safety/rollback logic, and a non-trivial shell command -- documenting setup, behavior, internals, and a manual fallback is justified, not bloated.

FINDINGS:

- [NIT] docs/using-nefario.md:183 -- The sentence about backup filename and rollback is implementation detail that only the SKILL.md needs. Users do not need to know the backup filename. Consider trimming to just "The skill validates JSON and rolls back on failure. It is idempotent."

No blocking or advisory concerns. Both files are concise, accurately reflect the SKILL.md, and add no speculative content. The deployment.md addition (12 lines, table format) is minimal. The using-nefario.md section (~55 lines including the collapsible manual config) is reasonable given the skill's four-state branching and the inline shell command users might need for manual setup.
