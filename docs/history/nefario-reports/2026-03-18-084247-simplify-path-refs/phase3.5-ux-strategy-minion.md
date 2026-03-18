## UX Strategy Review — simplify-path-refs

**Verdict: APPROVE**

### Journey coherence
The three tasks form a clean linear sequence with correct dependencies. The narrative arc is clear: co-locate the template, fix path references, update the index. No phase is out of order.

### Cognitive load
TEMPLATE.md moving into the skill directory is a net reduction in cognitive load — a skill owning its own template is the expected mental model. Maintainers no longer need to trace a path across two unrelated directory hierarchies to understand what the skill reads.

The `${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md` reference (Task 2) is marginally harder to parse than a plain relative path. However, the original was a broken 3-level relative path, so the comparison base is zero — any working path is better. The medium risk (symlink resolution) is correctly flagged and testable.

### Simplification
Tasks 1 and 2 could be merged into one task since both touch SKILL.md, but the split is defensible — the deliverables (file move vs. link fix) are conceptually distinct. No simplification is required.

### User JTBD served
"When I invoke the nefario skill from any working directory, I want paths to resolve correctly, so I don't get broken template or doc references." The plan directly serves this job. No speculative scope, no indifferent features.

### No issues requiring design or strategy changes.
