# Domain Plan Contribution: product-marketing-minion

## Recommendations

**No product messaging impact.** The `claude-commit-orchestrated` mechanism is purely internal plumbing. It appears nowhere in product-facing content:

- **README.md**: Zero references. The README describes user-facing value (phased orchestration, domain experts, governance gates) without mentioning implementation details like tmp files or marker files.
- **CLAUDE.md**: References "orchestrated sessions" as a concept but never mentions the marker file mechanism.
- **the-plan.md**: Zero references to `claude-commit-orchestrated` or marker files.

The string `claude-commit-orchestrated` appears in 19 files, all of which are internal:

1. **`skills/nefario/SKILL.md`** -- implementation instructions (will be updated by this task)
2. **`.claude/hooks/commit-point-check.sh`** -- the hook itself (will be updated by this task)
3. **`docs/commit-workflow.md`** -- internal architecture documentation describing hook composition (line 259 explicitly names the marker file path)
4. **`docs/decisions.md`** -- architectural decision records (line 223, Decision 17 mentions marker files in rejected alternatives)
5. **15 files under `docs/history/nefario-reports/`** -- historical execution reports documenting past changes

None of these are product-facing messaging, changelogs, feature descriptions, or user-visible content. The README, landing page copy (if any), and user-facing documentation describe orchestration behavior ("phases," "approval gates," "parallel execution") without exposing implementation details.

## Proposed Tasks

No tasks for product-marketing-minion. This change is invisible to users and requires no messaging updates.

**Note for other agents**: `docs/commit-workflow.md` (line 259) should be updated as part of this refactoring -- it explicitly documents the old marker file path and creation/removal lifecycle. This is internal architecture documentation (software-docs-minion's domain), not product messaging.

## Risks and Concerns

**Risk: None from a product messaging perspective.** The abstraction boundary between "what users see" and "how it works internally" is clean. Users interact with `/nefario` and see phased orchestration. They never see or manage tmp files.

**Minor observation**: The `docs/history/nefario-reports/` files contain 15 references to the old mechanism. These are historical records and should not be modified (they document what was true at the time). No risk here -- just noting that the old name will persist in history, which is correct behavior for immutable records.

## Additional Agents Needed

- **software-docs-minion**: To update `docs/commit-workflow.md` (line 259) which describes the marker file mechanism in detail. This is the only non-history, non-implementation file that references `claude-commit-orchestrated` by name.
