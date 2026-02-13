Align docs/ files with rewritten README

**Outcome**: All documentation files are consistent with the rewritten README.md. No stale reviewer counts, no orphaned references, no terminology drift.

**Context**: The README was rewritten in PR nefario/rewrite-readme-showcase-value. A Phase 8 audit identified inconsistencies in docs/ files that were out of scope for the README rewrite. This task addresses those findings.

**Success criteria**:
- All four MUST findings in decisions.md are resolved
- Both SHOULD findings are evaluated and addressed if warranted
- No new inconsistencies introduced
- ADR immutability respected (historical decisions get addendum notes, not rewrites)

**Scope**:
- In: docs/decisions.md, docs/orchestration.md, docs/architecture.md
- Out: README.md (already done), the-plan.md, AGENT.md files, skills/

**Findings to address**:

### MUST Fix (all in decisions.md)

1. **Decision 10 (line ~128)**: States "Six ALWAYS reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo)". ux-strategy-minion is now discretionary, not ALWAYS. Add an addendum note cross-referencing the rework decision.

2. **Decision 12 Consequences (line ~153)**: States "6 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5)". Now stale -- count is 5. Add addendum note.

3. **Decision 15 Consequences (line ~191)**: States "Every /nefario run incurs review cost (6 ALWAYS + 0-4 conditional reviewers)". This describes current behavior and is factually wrong. Update to "5 ALWAYS + 0-6 discretionary reviewers".

4. **Decision 20 Consequences (line ~262)**: States "Phase 3.5 minimum review cost increases (6 ALWAYS reviewers)". Add addendum note with corrected count.

### SHOULD Fix

5. **"Six cross-cutting dimensions" (orchestration.md lines 20, 44, 334; architecture.md line 113)**: Technically correct (the checklist HAS six dimensions, distinct from five reviewers). But the word "six" near reviewer discussions causes confusion. Consider adding a parenthetical clarification: "six cross-cutting dimensions (distinct from the five mandatory reviewers)" in at least one prominent location.

6. **"Six domain groups" (orchestration.md line ~318)**: States "all six domain groups" but the agent roster shows seven groups. Verify correct count against the-plan.md and fix if it's a pre-existing error.

**Approach for ADR entries**: Decisions 10, 12, and 20 are historical records. Do NOT rewrite the original decision text. Instead, add an addendum at the end of each decision entry:

```markdown
> **Update ({date})**: The ALWAYS reviewer count was reduced from 6 to 5 when ux-strategy-minion was moved to the discretionary pool. See Decision N (Phase 3.5 reviewer composition rework).
```

Decision 15 describes current behavior, not a historical snapshot -- update the consequences text directly.