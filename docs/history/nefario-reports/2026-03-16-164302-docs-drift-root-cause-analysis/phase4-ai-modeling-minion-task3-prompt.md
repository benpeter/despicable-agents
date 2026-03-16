You are adding documentation debt tracking to the nefario execution report
template and updating the AGENT.md post-execution phase description to reflect
the Phase 8 restructuring.

## Target files

1. `/Users/ben/github/benpeter/despicable-agents/docs/history/nefario-reports/TEMPLATE.md`
2. `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md`

## Change 1: Add `docs-debt` to report template frontmatter

In TEMPLATE.md, find the frontmatter skeleton. Add a new field after `outcome`:
```yaml
docs-debt: {none | deferred}
```

Binary only — no `not-evaluated` state.

## Change 2: Add docs-debt to the Frontmatter Fields table

In TEMPLATE.md, find the Frontmatter Fields table and add a new row:

| `docs-debt` | always | Documentation debt status: `none` (Phase 8a found 0 items or all items addressed in 8b), `deferred` (Phase 8a found items but Phase 8b was skipped) |

## Change 3: Add Documentation Debt section to report skeleton

After the Verification section and before Session Resources, add:

```markdown
## Documentation Debt

{INCLUDE WHEN `docs-debt` = `deferred`. OMIT WHEN `docs-debt` = `none`.}

| Item | Priority | Target Files | Status |
|------|----------|-------------|--------|
| {checklist item description} | {MUST/SHOULD/COULD} | {file paths} | deferred |
```

## Change 4: Add conditional section rule for Documentation Debt

In the Conditional Section Rules table, add:

| Documentation Debt | `docs-debt` = `deferred` | `docs-debt` = `none` |

## Change 5: Update AGENT.md post-execution phases description

In `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md`, find the
Phase 8 bullet in the Post-Execution Phases section. It currently says something like:

```
- **Phase 8: Documentation** -- Conditional: runs when documentation checklist has items.
```

Update to:

```
- **Phase 8: Documentation** -- Phase 8a (assessment) always runs: generates
  documentation checklist from execution outcomes, verifies coverage claims.
  Phase 8b (execution) is conditional: runs when checklist has items and user
  did not skip docs. When 8b is skipped with a non-empty checklist, items are
  recorded as documentation debt in the execution report.
```

## Change 6: Add docs-debt to the report writing checklist

In TEMPLATE.md, find the Report Writing Checklist. After the step about writing
the Verification section, add:

```
N. Write Documentation Debt section (if docs-debt = deferred; include
   Phase 8a checklist items with priority and target files)
```

## What NOT to change

- Do NOT bump the template version
- Do NOT modify the Phase 8 section of SKILL.md (already done)
- Do NOT add cross-session debt tracking or ledger files
- Do NOT modify any other AGENT.md sections

When you finish, report: file paths with change scope and line counts.
