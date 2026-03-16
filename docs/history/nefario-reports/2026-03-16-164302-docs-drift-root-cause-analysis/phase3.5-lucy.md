# Phase 3.5 Review: lucy

**Verdict: ADVISE**

## Requirement Traceability

| User Requirement | Plan Element | Status |
|------------------|-------------|--------|
| Understand WHY docs drift happened in WRL despite framework | Root cause analysis in synthesis conflict resolutions | Covered |
| Understand why framework's usual operations did not catch drift | Task 1 (Phase 8 restructure), Task 2 (table gaps) | Covered |
| Fix the structural weakness | Tasks 1-3 | Covered |

The user asked two things: (1) why drift happened, and (2) why the framework did not catch it. The plan addresses both. The root cause analysis is embedded in the synthesis narrative (checklist was never generated because Phase 8 was wholly skippable; outcome-action table had gaps). The fixes are proportional to the diagnosis: 3 tasks, 3 files. No drift detected.

## ALWAYS/Conditional Contradiction — Assessment

The plan (Risk 5) claims the contradiction is "resolved" by making Phase 8a unconditional. This is **partially correct but incomplete**.

The contradiction exists across two levels:

1. **Cross-cutting checklist** (AGENT.md line 295): "Documentation (software-docs-minion and/or user-docs-minion): **ALWAYS include.**" This means documentation agents should be included in planning (Phases 1-2) and execution plans (Phase 4 tasks) for every orchestration.

2. **Phase 8 header** (SKILL.md line 1935): "Phase 8: Documentation **(Conditional)**" — execution depends on whether the checklist has items.

3. **Post-execution description** (AGENT.md line 830): "Phase 8: Documentation -- **Conditional**: runs when documentation checklist has items."

The plan's Task 1 restructures Phase 8 into 8a (always-run assessment) and 8b (conditional execution). Task 3 updates the AGENT.md post-execution description to reflect the 8a/8b split. This resolves the Phase 8 header contradiction.

**However**: the note at AGENT.md line 304 already explains that the cross-cutting checklist governs Phases 1-4 (planning and execution task inclusion), while Phase 3.5 and Phases 5-8 have their own triggering rules. The "ALWAYS include" for Documentation means software-docs-minion should always be considered during planning and task assignment — it does not promise that Phase 8 execution will always run. This means the real contradiction was narrower than the plan suggests: the issue was not that Phase 8 was conditional (that is by design), but that the **assessment/checklist generation** was tied to Phase 8's conditionality, making the checklist invisible when Phase 8 was skipped. The plan fixes exactly this.

No action needed — the fix is correct. I flag this only because the plan's framing of the contradiction could mislead future readers into thinking "ALWAYS include" in the cross-cutting checklist means "Phase 8 always executes." The existing note at line 304 already prevents this misreading, and Task 1's Phase 8a header ("ALWAYS runs") is precisely scoped to assessment, not execution.

## Findings

### 1. CONVENTION: Phase 8 title update missing from Task 1 prompt

**Where**: Task 1 prompt, Change 1.
**Issue**: The current Phase 8 header is "Phase 8: Documentation (Conditional)" (SKILL.md line 1935). After the restructure, the parenthetical should be updated to reflect the new dual nature (e.g., "Phase 8: Documentation (Assessment: always; Execution: conditional)" or simply "Phase 8: Documentation"). The Task 1 prompt describes the internal restructuring into 8a/8b but does not explicitly instruct updating the Phase 8 header itself. The executing agent may or may not infer this.
**Risk**: Low. The agent will likely update it. But explicit is better than implicit for spec changes.
**Fix**: Add to Task 1 prompt: "Update the Phase 8 header from 'Phase 8: Documentation (Conditional)' to reflect that assessment always runs."

### 2. CONVENTION: Task 1 and Task 2 both modify SKILL.md in parallel — merge conflict risk

**Where**: Execution Order, Batch 1.
**Issue**: Tasks 1 and 2 are parallel in Batch 1. Both modify `skills/nefario/SKILL.md`. Task 1 restructures lines 1935-2030 (the Phase 8 section). Task 2 modifies lines 1943-1960 (the outcome-action table within the Phase 8 section). These line ranges overlap. When both subagents write to the same file concurrently, the second write will overwrite the first.
**Risk**: Medium. This is a well-known subagent coordination problem. The second task to complete will clobber the first task's changes to SKILL.md.
**Fix**: Either (a) make Task 2 depend on Task 1, running sequentially in Batch 1, or (b) keep them parallel but have Task 2 write to a separate scratch file, with a merge step after both complete. Option (a) is simpler.

### 3. TRACE: No update to the-plan.md nefario spec-version mentioned

**Where**: Plan scope.
**Issue**: CLAUDE.md states that each agent spec has a `spec-version` in `the-plan.md` and each built `AGENT.md` has `x-plan-version`. Task 3 modifies `nefario/AGENT.md` (post-execution description). If the AGENT.md content diverges from `the-plan.md`, the versioning system flags it for regeneration. The plan does not address whether `the-plan.md` needs a spec-version bump or whether this change is within the scope of the existing spec version.
**Risk**: Low. The change is to a domain-specific section in AGENT.md that may be outside the-plan.md's governance (the post-execution phases are defined in SKILL.md, not in the-plan.md spec). But this should be explicitly noted.
**Fix**: Add a note to Task 3: "This change is to the domain-adapted post-execution description, not to the-plan.md spec. No spec-version bump is needed."

### 4. SCOPE: Plan is well-contained

The plan correctly rejects 4 proposals (persistent debt ledger, diff-based scan, Phase 5 expansion, docs-catchup mode) with clear rationale. The adopted scope is 3 tasks, 3 files, proportional to the problem. No scope creep detected.

## Summary

Two actionable findings: the parallel SKILL.md modification risk (finding 2, medium) and the missing Phase 8 header update instruction (finding 1, low). One traceability note (finding 3, informational). The ALWAYS/Conditional contradiction is substantively resolved by the plan's 8a/8b split. The plan correctly identifies the root cause and applies a proportional fix.
