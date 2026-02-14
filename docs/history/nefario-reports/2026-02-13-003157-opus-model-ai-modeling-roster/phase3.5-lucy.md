# Lucy Review -- Governance Alignment

**Verdict: ADVISE**

## Requirements Traceability

| Issue #91 Gap | Plan Coverage | Status |
|---|---|---|
| Gap 1: iac-minion has zero serverless knowledge | Task 1 (remit, domain, research focus, boundary) | Covered |
| Gap 2: margo's complexity budget penalizes novelty not burden | Task 2 (remit, research focus, two-column model via build) | Covered |
| Gap 3: Delegation table has no serverless routing | Task 4 (two new rows) | Covered |
| Gap 4: CLAUDE.md template for target projects | Task 5 (docs/claudemd-template.md) | Covered |
| Edge-minion framing (full-stack serverless ack) | Task 3 (boundary clarification) | Covered |
| Nefario stale delegation table | Task 7 (data-staleness rebuild) | Covered |
| Docs staleness | Task 6 (surgical updates) | Covered |

All three gaps from issue #91 plus the CLAUDE.md template (fourth deliverable) are addressed. No stated requirements are missing from the plan.

## Findings

- [ADVISE]: iac-minion spec-version bump 1.0 to 1.1 may undercount the change magnitude
  SCOPE: `/Users/ben/github/benpeter/2despicable/4/the-plan.md` iac-minion spec-version (line 748)
  CHANGE: Consider whether the bump should be 2.0 instead of 1.1. The project's versioning convention (the-plan.md line 63) states "bump major for remit changes, minor for refinements." Task 1 adds two new remit bullets (serverless platforms, deployment strategy selection) and expands the Domain line -- these are remit expansions, not refinements of existing remit items.
  WHY: If the convention is applied strictly, iac-minion's change qualifies as a major version bump. Using 1.1 creates a precedent where remit expansion is treated as a refinement, weakening the signal that spec-version major bumps are supposed to carry. margo (adding "infrastructure overhead" to an existing bullet) and edge-minion (framing only, no remit expansion) are correctly 1.1 under the same convention.
  TASK: 1

- [ADVISE]: Issue #91 requests a Principles addition for iac-minion that the plan intentionally omits
  SCOPE: Task 1 prompt, framing constraints
  CHANGE: No change needed if the human approves this deviation. The plan should explicitly note this is a deliberate departure from the issue text, not an oversight.
  WHY: Issue #91 proposes adding a Principles line to iac-minion: "Serverless is the default for greenfield; server infrastructure is the escalation path." The plan's Task 1 explicitly forbids this ("Do NOT add language like 'prefer serverless'"). This is a sound design decision -- it keeps iac-minion topology-neutral per the issue's own "What NOT to do" section ("Do NOT hardcode 'serverless-first'"). But the issue text does request it as a spec change. The conflict between the issue's solution section (add the principle) and its constraints section (don't hardcode serverless-first) should be resolved by the human, not silently by the plan. The plan's Conflict Resolutions section documents three conflicts but does not document this one.
  TASK: 1

- [ADVISE]: Task 6 assigns lucy as the agent for docs staleness checking
  SCOPE: Task 6 agent assignment
  CHANGE: Consider assigning software-docs-minion instead of lucy. Lucy's remit is governance (convention enforcement, intent alignment, CLAUDE.md compliance). Updating documentation content for accuracy is software-docs-minion's remit ("Architecture documentation", "README structure and content").
  WHY: Lucy's "Does NOT do" section in the-plan.md (line 519) states lucy does not do "writing code or documentation (-> appropriate minion)." Updating stale doc references is documentation work, not governance work. Lucy can review the updates afterward (Phase 5 code review), but should not be the producing agent. This is a boundary violation per the agent spec.
  TASK: 6

## Items Verified (No Issues Found)

- **Delegation table convention**: Task 4 correctly uses task-type naming ("Deployment strategy selection", "Platform deployment configuration") consistent with existing table entries ("Infrastructure provisioning", "CI/CD pipelines"). The conflict resolution documenting why "Serverless platform deployment" from the issue was renamed is well-reasoned.
- **CLAUDE.md template placement**: `docs/claudemd-template.md` follows docs/ conventions. The back-link format `[< Back to Architecture Overview](architecture.md)` matches the majority pattern (10 of 13 existing docs files use this format).
- **Nefario regeneration scope**: Task 7 correctly classifies the nefario rebuild as data-staleness, not spec-change. nefario's spec-version stays at 2.0. The plan does not bump nefario's spec-version, which is correct -- only the embedded delegation table data changes.
- **"Does NOT do" additions**: Task 1 adds "Edge-layer runtime behavior (caching strategy, edge function optimization, CDN routing rules) (-> edge-minion)" to iac-minion. Task 3 adds "Full-stack serverless deployment configuration ... (-> iac-minion)" to edge-minion. Both follow the existing pattern: description of excluded work + arrow to responsible agent.
- **Scope containment**: No scope creep detected. Every task traces to one of the three issue gaps or the CLAUDE.md template deliverable. No adjacent features, no technology introductions, no pre-optimization.
- **CLAUDE.md compliance**: Plan respects all CLAUDE.md rules -- English artifacts, no PII, no the-plan.md modification without human approval (approval gates on Tasks 1 and 2), KISS/YAGNI philosophy. The "Do NOT modify the-plan.md" rule is handled by the approval gates, which is the correct mechanism.
- **No opposite bias**: Task 1 framing constraints explicitly prevent swinging from "always servers" to "always serverless." Research focus includes both "when serverless wins" and "when serverless is inappropriate." Success criteria include neutrality verification.
- **Cross-cutting coverage**: Properly justified exclusions for test-minion, security-minion, ux-design-minion, observability-minion. The CLAUDE.md template (Task 5) correctly triggers user-docs-minion as a discretionary reviewer.
