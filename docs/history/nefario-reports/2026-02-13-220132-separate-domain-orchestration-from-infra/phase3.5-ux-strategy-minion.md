# UX Strategy Review: Domain Separation Plan

## Verdict: ADVISE

## Journey Coherence: STRONG

The adapter authoring journey is well-structured:
1. Fork repo → 2. Copy example adapter → 3. Edit DOMAIN.md → 4. Build agents → 5. Assemble → 6. Install → 7. Test

This follows a clear mental model: "define your domain's agents and phases, then use the framework's mechanics." The fork-edit-test cycle matches developer expectations. The documentation task (Task 4) explicitly designs this journey.

**Strength**: The separation between "what you define" (agents, phases, gates) and "what the framework handles" (spawning, messaging, reporting) maps to a clear JTBD: "I want to orchestrate specialist agents in my domain without rebuilding orchestration infrastructure."

## Cognitive Load: CONCERNS

### Issue 1: Ambiguous SKILL.md Boundary (MEDIUM SEVERITY)

The plan handles AGENT.md cleanly (assembly markers + extraction) but treats SKILL.md differently: "section markers for in-place replacement, not automated assembly."

**Cognitive load problem**: The adapter author now faces two different mental models:
- AGENT.md: "Don't touch this file, edit DOMAIN.md instead"
- SKILL.md: "Find the marked sections and edit them in place"

This asymmetry requires understanding WHY they differ ("SKILL.md's domain-specific content is too tightly interwoven"). For a forker unfamiliar with the internals, this is extraneous cognitive load.

**User questions this creates**:
- "Do I edit SKILL.md or not?"
- "What happens if I edit the wrong section?"
- "Why can't SKILL.md work like AGENT.md?"
- "If I run assemble.sh again, does it overwrite my SKILL.md edits?"

**Recommendation**: Task 4 documentation must explicitly address this asymmetry. Include:
1. A decision tree: "Which file do I edit for X?"
2. Clear warning about SKILL.md edits being manual (won't be preserved/assembled)
3. Visual distinction in the walkthrough (Section 4) between AGENT.md (hands-off) and SKILL.md (hands-on)

### Issue 2: Assembly Marker Visibility (LOW SEVERITY)

The AGENT.md template will contain markers like `<!-- @domain:roster BEGIN -->` with "(placeholder text explaining what goes here)".

**Question**: After assembly, are the markers removed or preserved in the final AGENT.md?

Task 5 verification says: "Assembly marker artifacts (comments) -- these should NOT be present in assembled output."

But Task 2 prompt shows markers as BEGIN/END pairs replacing content *inclusive of the markers*. This suggests markers are removed.

**Cognitive load risk**: If an adapter author looks at the assembled AGENT.md (post-install), they see clean content with no markers. But if they look at the AGENT.md template (pre-assembly), they see markers. If they don't understand the assembly step, they might edit the template directly and wonder why their changes disappear on next install.

**Recommendation**: Already mitigated by Task 4 documentation (Section 5: "What You Do NOT Need to Change"). Confirm that documentation explicitly says: "Never edit nefario/AGENT.md directly -- it is assembled from the template. Edit domains/your-domain/DOMAIN.md instead."

## Simplification: STRONG with ONE OPPORTUNITY

The single-file DOMAIN.md (vs. six-file directory) is the right call. The margo/devx compromise is well-reasoned.

**Simplification achieved**:
- One adapter file (not six) reduces navigation overhead
- No config loader, registry, or validation tooling eliminates unnecessary infrastructure
- Install-time assembly (not runtime) keeps the deployment model simple

**Opportunity: Defer disassemble.sh (OPTIONAL SIMPLIFICATION)**

Task 3 includes creating `disassemble.sh` (reverse operation: assembled AGENT.md → template + adapter).

**Question**: Is this needed for the first iteration?

The stated use case: "a maintenance tool for when someone edits the assembled AGENT.md and needs to propagate changes back."

But the documentation (Task 4) will explicitly say "don't edit assembled AGENT.md." The workflow is unidirectional: adapter → assembly → AGENT.md.

**YAGNI assessment**: disassemble.sh is a recovery tool for a workflow violation (editing assembled output). It's useful, but not required for the separation to work.

**Recommendation**: Consider deferring disassemble.sh to a follow-up if it proves needed. This reduces Task 3 scope and removes a tool that might confuse the mental model ("wait, can I edit AGENT.md or not?"). If deferred, document it as a known gap in Task 4 ("if you accidentally edit AGENT.md, you'll need to manually extract changes back to DOMAIN.md").

**Severity**: LOW. Keep it if the effort is minimal. Defer if you want maximum simplicity.

## Jobs-to-be-Done: WELL-ALIGNED

Each task serves a real adapter author need:

- Task 1 (audit): "Which parts do I need to replace?" → classification creates a mental map
- Task 2 (adapter format): "What format do I use?" → provides the contract
- Task 3 (assembly): "How do I deploy my adapter?" → makes assembly automatic
- Task 4 (documentation): "How do I get started?" → walkthrough reduces onboarding friction
- Task 5 (verification): "Does this actually work?" → prevents regressions

No unnecessary deliverables. Every output feeds the adapter author's journey.

## Summary

**APPROVE with documentation emphasis**. The plan is sound. The journey is coherent. The simplification choices are correct.

**Critical dependency**: Task 4 (documentation) must handle the SKILL.md asymmetry clearly. The adapter author needs explicit guidance on which files to edit and which to leave alone. Without this, the two-model system (AGENT.md hands-off, SKILL.md hands-on) creates confusion.

**Optional refinement**: Defer disassemble.sh if you want maximum YAGNI compliance. It's useful but not necessary for the success criteria.

**No blockers**. Proceed to execution.
