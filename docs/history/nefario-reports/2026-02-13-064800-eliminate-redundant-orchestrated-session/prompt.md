**Outcome**: The commit hook detects orchestrated sessions by checking the nefario status file (`/tmp/nefario-status-${SID}`) instead of a dedicated boolean marker (`/tmp/claude-commit-orchestrated-${SID}`), reducing tmp file sprawl and removing a coordination point that nefario must explicitly manage. The nefario status file already has a clear lifecycle (created at P1, deleted at wrap-up) and conveys strictly more information than the marker it replaces.

**Success criteria**:
- `claude-commit-orchestrated` no longer appears in any project file
- Commit hook suppresses commit prompts during active nefario orchestration (status file present)
- Commit hook prompts normally when no orchestration is active (status file absent)
- SKILL.md no longer instructs nefario to touch or rm the orchestrated marker
- No behavioral change from the user's perspective

**Scope**:
- In: `.claude/hooks/commit-point-check.sh` orchestration check, `skills/nefario/SKILL.md` marker lifecycle instructions
- Out: Change ledger mechanism, defer/declined markers, status file write/read format, despicable-statusline skill

---
Additional context: consider all approvals given, skip test and security post-exec phases. Include user docs, software docs and product marketing in the roster. Work all through to PR creation without interactions.
