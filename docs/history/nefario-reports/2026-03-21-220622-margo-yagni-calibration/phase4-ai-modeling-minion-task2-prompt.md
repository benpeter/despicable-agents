You are updating the margo spec section in `the-plan.md` to reflect the
two-tier YAGNI calibration change.

## What to change

In `the-plan.md`, find the margo spec section (starts with `#### margo`). Make TWO edits:

### Edit 1: Update the YAGNI remit line

The current line reads:
```
- Detecting YAGNI violations (building things not yet needed)
```

Replace with:
```
- Detecting YAGNI violations using two-tier evaluation: speculative features
  (no concrete consumer) are flagged for exclusion; roadmap-planned items
  (named consumer on active roadmap) are evaluated for proportional complexity only
```

### Edit 2: Bump spec-version

Change `**spec-version**: 1.1` to `**spec-version**: 1.2`

## Constraints

- Do NOT modify any other part of the margo spec (Domain, Principles, Does
  NOT do, Tools, Model, Research focus).
- Do NOT modify any other agent's spec.
- Keep the remit update concise -- the-plan.md is a spec, not a manual.

## Files

- `the-plan.md` -- the only file you modify

## Context

This change aligns the spec with the AGENT.md update from Task 1, which
replaced the binary YAGNI justification test with a two-tier evaluation
distinguishing speculative features from roadmap-planned items.

## Deliverables

- Updated margo spec in `the-plan.md` with remit line update and version bump

When you finish, report back with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
- The approach you chose, what alternatives you considered but rejected
