# Lucy: Architecture Review -- Phase 3 Synthesis

## Verdict: ADVISE

The synthesis plan addresses all five user feedback items, respects the nefario change boundary, and demonstrates YAGNI discipline in most areas. Three findings require adjustment before or during execution. None are blocking.

---

## Requirements Traceability

| User Feedback Item | Plan Coverage | Status |
|--------------------|---------------|--------|
| 1. Configuration gap (routing + model specification DX) | Task 1, Change 1: New "Routing and Configuration" section with three granularity levels, model-mapping, capability gating, YAML examples | COVERED |
| 2. Worktree isolation (resolve Open Question 2) | Task 1, Change 2: Definitive position on worktrees as default, notes on pre-existing concurrency concern | COVERED |
| 3. Quality parity = user responsibility, model spec required | Task 1, Change 3: Removes Open Question 3, adds quality parity statement to Recommendations | COVERED |
| 4. Aider result collection (accept LLM summarization) | Task 1, Change 4: Closes Open Question 5, updates Gap Analysis and Aider subsection | COVERED |
| 5. Codex-first roadmap in md file | Task 2: New `docs/external-harness-roadmap.md` with milestone/issue structure | COVERED |

All five feedback items have corresponding plan elements. No stated requirement is missing from the plan.

---

## Finding 1: Scope -- Roadmap Milestones 5-8 and "Future" Framing

**SCOPE / ADVISE**

**WHAT**: Task 2 defines 4 concrete milestones (13 issues) plus 4 "Future Milestones" (5-8: Gemini CLI Adapter, Capability-Based Routing, Quality Outcome Logging, Hardening). The future milestones are headline-level only (2-3 sentences each), which is appropriate. However, the user asked for "a sequenced roadmap document for executing on the Codex CLI delegation path" that is "extensible for adding other tools later."

**WHY THIS MATTERS**: Milestones 5-8 are reasonable at headline level and do not violate YAGNI since they contain no decomposed issues. However, Milestone 7 ("Quality Outcome Logging") introduces a feature the user explicitly said is their responsibility (feedback item 3). Even as a future sketch, including it sends a signal that the system should eventually track quality outcomes -- which contradicts the user's stated position.

**RECOMMENDATION**: Keep Milestones 5, 6, and 8 as sketched. Either remove Milestone 7 entirely or reframe it as "User-Side Observability Tooling" with a note that this is a convenience feature the user may or may not want, not a system capability. The current description ("Optional per-harness outcome tracking... Enables data-driven routing decisions over time") edges toward the auto-routing intelligence the user explicitly rejected.

---

## Finding 2: Scope -- Adapter Interface Definition Before First Adapter (YAGNI Tension)

**SCOPE / ADVISE**

**WHAT**: Issue 1.1 (Adapter Interface Definition) defines DelegationRequest and DelegationResult types as a design document before any adapter is built. My Phase 2 input recommended "Build the Codex adapter. Extract the interface after Aider validates it." The synthesis plan chose to define a minimal interface first (Issue 1.1), build Codex against it (Milestone 2), then validate with Aider (Milestone 3), with Issue 3.4 tracking what changed.

**WHY THIS MATTERS**: The conflict resolution section (line 469) explicitly acknowledges and resolves this tension: "Define a minimal interface in Issue 1.1 (types, not code)... This balances YAGNI with the practical need for a target shape when building the first adapter." This is a defensible position. The interface is a design document, not a framework, and Issue 3.4 explicitly validates whether the abstraction held.

**RECOMMENDATION**: Acceptable as-is. The plan's own safeguard (Issue 3.4 as abstraction health check) addresses the YAGNI concern. The Conflict Resolutions section makes the tradeoff visible and reasoned. No change needed, but during execution the software-docs-minion should be reminded that Issue 1.1 deliverable is a design doc with type definitions, not runnable code or an interface library.

---

## Finding 3: Convention -- "What NOT to Build" vs. Issue 4.2 Progress Monitoring

**CONVENTION / ADVISE**

**WHAT**: The "What NOT to Build" section in the roadmap template states "No auto-routing intelligence" and "No quality tracking or benchmarking." However, Issue 4.2 (Progress Monitoring Integration) includes the scope item "Other future tools: define progress event contract for adapters." This pre-defines a progress contract for tools that do not yet exist.

**WHY THIS MATTERS**: Per CLAUDE.md's YAGNI principle, defining a contract for "other future tools" in the same issue that wires up Codex and Aider progress is premature. The progress event contract should emerge from Milestones 2 and 3 experience, not be pre-defined.

**RECOMMENDATION**: Narrow Issue 4.2's scope to Codex and Aider progress only. Remove the "Other future tools: define progress event contract for adapters" bullet. A generic progress contract can be extracted when a third adapter (Milestone 5) is built.

---

## Finding 4: Positive -- Nefario Change Boundary

No finding. The plan explicitly states in the Scope and Boundaries section: "Nefario change boundary: Changes are limited to Phase 4 execution routing (the step where nefario spawns execution agents via the Task tool). Planning phases 1-3.5 are unchanged." This matches my Phase 2 recommendation exactly. Issue 4.1's acceptance criteria include "Orchestrator code changes limited to Phase 4 execution routing." The boundary is well-defined and correctly scoped.

---

## Finding 5: Positive -- CLAUDE.md Compliance

No violations detected against project CLAUDE.md:

- **English**: All artifacts in English. Confirmed.
- **No PII / publishable**: Task 1 and Task 2 prompts both include "Do not mention any specific company names beyond tool names." The "What NOT To Do" sections reinforce this.
- **YAGNI/KISS**: Enforced through the "What NOT to Build" section, explicit line limits on new sections (40-60 lines), and headline-only future milestones.
- **No the-plan.md modification**: Neither task touches the-plan.md. Confirmed.
- **Session Output Discipline**: Not applicable (documentation tasks, no bash commands).

---

## Finding 6: Positive -- Approval Gate Placement

The single approval gate on Task 1 (report iteration) is correctly placed. The gate reason is sound: report positions (routing config design, worktree stance, quality parity policy, result collection strategy) cascade into the roadmap. Approving wrong positions would produce a misaligned roadmap. The sequential dependency chain (Task 1 -> gate -> Task 2 -> Task 3) is the minimum viable structure.

---

## Summary of Recommendations

| # | Type | Finding | Action |
|---|------|---------|--------|
| 1 | SCOPE | Milestone 7 (Quality Outcome Logging) contradicts user's explicit position that quality parity is their responsibility | Remove or reframe as optional user-side tooling with explicit caveat |
| 2 | SCOPE | Issue 1.1 adapter interface before first adapter | Acceptable as-is (safeguarded by Issue 3.4). No change needed. |
| 3 | CONVENTION | Issue 4.2 pre-defines progress contract for future tools | Remove "Other future tools" scope item from Issue 4.2 |

Findings 1 and 3 are minor adjustments that can be incorporated during Task 2 execution. Neither requires plan restructuring. The synthesis plan is well-aligned with user intent.
