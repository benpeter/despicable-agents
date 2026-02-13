#60 Align docs/ files with new progressive-disclosure README

**Outcome**: All documentation files are consistent with the rewritten README.md. No stale reviewer counts, no orphaned references, no terminology drift.

**Context**: The README was rewritten in PR #58. A Phase 8 audit identified inconsistencies in docs/ files that were out of scope for the README rewrite. This task addresses those findings.

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

5. **"Six cross-cutting dimensions" (orchestration.md lines 20, 44, 334; architecture.md line 113)**: Technically correct (the checklist HAS six dimensions, distinct from five reviewers). But the word "six" near reviewer discussions causes confusion. Consider adding a parenthetical clarification.

6. **"Six domain groups" (orchestration.md line ~318)**: States "all six domain groups" but the agent roster shows seven groups. Verify correct count against the-plan.md and fix if it's a pre-existing error.

---
Additional context: consider all approvals given, skip test and security post-exec phases. I delegate to Lucy agent to answer all questions and give all approvals. Make sure to include user-docs-minion, software-docs-minion, and product-marketing-minion in the roster. Work all through to PR creation without interactions, also do not interrupt to propose compactions.
