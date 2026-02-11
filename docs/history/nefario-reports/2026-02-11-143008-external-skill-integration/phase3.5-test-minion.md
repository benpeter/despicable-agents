## Test-minion Review: ADVISE

The plan correctly identifies that all deliverables are prompt text and documentation -- no executable code is produced. The "Testing: Excluded" decision in Cross-Cutting Coverage is defensible. Automated testing of LLM prompt behavior is inherently brittle and not worth the cost for v1.

However, there are non-blocking concerns:

### 1. Verification step 2 is a mental walkthrough, not a test

The acceptance test scenario (CDD skill in `.skills/`, user runs `/nefario 'build a new block'`) is described as a "mental walkthrough" of the modified AGENT.md. This is reasonable for a prompt-only change, but the plan does not specify WHO performs this walkthrough or WHEN. Recommendation: assign the consistency check and mental walkthrough (verification steps 1-4) explicitly to the final review phase, and ensure the reviewer has access to a real or mock `.skills/` directory with a CDD-like SKILL.md to validate the discovery path end-to-end. A dry run through the actual `/nefario` flow with a test project would provide much higher confidence than reading the prompt and imagining what it would do.

### 2. No validation of edge cases mentioned in risks

The risk table identifies "15+ EDS skills" as a context budget concern and "skill description quality" as a routing accuracy concern. Neither has a documented known-limitation or test scenario. Recommendation: `docs/external-skills.md` (Task 3) should include a "Known Limitations" or "Edge Cases" subsection documenting:
- Behavior when many skills are discovered (context pressure)
- Behavior when SKILL.md has no frontmatter or empty description
- Behavior when two skills have overlapping domains and neither is more specific

These are not bugs to fix but expectations to set. Users hitting these cases should find documentation rather than silence.

### 3. No post-merge smoke test defined

For prompt-only changes of this scope (modifying the orchestrator's core planning logic), the plan should define a lightweight post-merge smoke test: "After merging, run `/nefario` on a project with at least one external skill and verify the meta-plan includes the External Skill Integration section." This takes 2 minutes and catches integration issues that a mental walkthrough cannot.

### Summary

The testing exclusion is appropriate for v1. The three recommendations above are low-cost additions that would meaningfully increase confidence without introducing test infrastructure.
