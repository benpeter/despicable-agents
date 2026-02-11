Remove the overlay mechanism (Option B: hand-maintain nefario). See docs/overlay-decision-guide.md for full analysis and team recommendation.

## What

Delete all overlay infrastructure and mark nefario as hand-maintained. nefario/AGENT.md is already the fully merged result -- no content is lost.

## Why

~2,900 lines of infrastructure for 1 of 27 agents violates YAGNI, KISS, and Lean-and-Mean. The overlay mechanism was introduced 2 days ago and has not justified its complexity. See Decision 9 and Decision 16 in docs/decisions.md for original rationale being superseded.

## Scope

### Delete (artifact removal)
- nefario/AGENT.generated.md
- nefario/AGENT.overrides.md
- validate-overlays.sh
- docs/override-format-spec.md
- docs/validate-overlays-spec.md
- tests/fixtures/ (all 10 overlay test directories)

### Update (documentation)
- docs/agent-anatomy.md: remove "Overlay Mechanism" section (~130 lines), retitle to "Agent Anatomy"
- docs/build-pipeline.md: remove "Merge Step" section, simplify to single-file generation
- docs/decisions.md: add new decision superseding D9 and D16 (Option B chosen, rationale: KISS)
- docs/architecture.md: update sub-documents table (remove "and Overlay System" from agent-anatomy entry)
- move docs/overlay-decision-guide.md to the history folder
- .claude/skills/despicable-lab/SKILL.md: add skip condition for nefario, remove overlay branching logic

### Verify
- install.sh has no stale overlay references
- No other scripts or CI reference validate-overlays.sh or overlay files

## Constraints
- Do NOT modify the-plan.md (nefario spec stays as-is)
- Do NOT modify nefario/AGENT.md (it is already correct and becomes the hand-maintained file)
- Remove x-fine-tuned from nefario/AGENT.md frontmatter (no longer applicable)
- note in the new decision record that infrastructure for patterns should not be built until 2+ agents exhibit the need
