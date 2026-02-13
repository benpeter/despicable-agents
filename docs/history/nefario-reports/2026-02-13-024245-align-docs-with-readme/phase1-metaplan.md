# Phase 1: Meta-Plan -- Align docs/ with Rewritten README

## Task Summary

Resolve 4 MUST findings and 2 SHOULD findings in docs/decisions.md, docs/orchestration.md, and docs/architecture.md that became stale after the README rewrite (PR #58) and the Phase 3.5 reviewer rework. All findings were identified by a Phase 8 documentation audit.

## Planning Consultations

### Consultation 1: ADR addendum wording and documentation consistency

- **Agent**: software-docs-minion
- **Planning question**: Four entries in decisions.md reference "6 ALWAYS reviewers" which is now 5. Decisions 10, 12, and 20 are historical records where the original text was correct at time of writing -- they need addendum notes, not rewrites. Decision 15 describes current runtime behavior and needs a direct update. What is the correct addendum format for this ADR log? Should addenda go inside the decision table or as a note below? How should we cross-reference the rework decision that changed the count?
- **Context to provide**: docs/decisions.md (full file), the Phase 8 audit findings, the rework decision (Phase 3.5 reviewer composition rework from 2026-02-12)
- **Why this agent**: software-docs-minion owns ADR format, documentation consistency, and cross-reference patterns. The core challenge here is respecting ADR immutability while correcting stale information -- this is squarely in software-docs-minion's domain.

### Consultation 2: Disambiguation wording for "six dimensions" vs "five reviewers"

- **Agent**: user-docs-minion
- **Planning question**: Three references to "six dimensions" (orchestration.md lines 20, 44, 334) and one in architecture.md (line 113) are technically correct -- the cross-cutting checklist HAS six dimensions, distinct from the five mandatory reviewers. But proximity to reviewer discussions causes confusion. What parenthetical clarification would disambiguate without cluttering the text? Also: orchestration.md line 318 says "six domain groups" but the architecture diagram shows seven. How should the group count be corrected -- simple number fix, or does the surrounding sentence need restructuring?
- **Context to provide**: docs/orchestration.md (relevant sections), docs/architecture.md (cross-cutting section and Mermaid diagram), the seven groups listed in the architecture diagram
- **Why this agent**: user-docs-minion specializes in clarity for readers. The SHOULD findings are readability/confusion issues, not structural documentation concerns. user-docs-minion's perspective on reader cognitive load will produce better disambiguation wording than a purely structural approach.

### Consultation 3: Messaging consistency review

- **Agent**: product-marketing-minion
- **Planning question**: The README was rewritten to showcase value (PR #58). These docs/ files are contributor/architecture documentation, not user-facing marketing. However, the README introduced specific terminology (e.g., "five mandatory reviewers", "discretionary reviewers") that should be consistent across all documentation. Review the four MUST findings and two SHOULD findings: are there any terminology or framing inconsistencies beyond the numerical counts that we should address while we are touching these files?
- **Context to provide**: Current README.md (the rewritten version), the six findings from the issue, docs/decisions.md, docs/orchestration.md, docs/architecture.md
- **Why this agent**: product-marketing-minion reviewed the README rewrite and has context on the terminology choices made there. Catching terminology drift now prevents a second documentation alignment pass later.

## Cross-Cutting Checklist

- **Testing**: EXCLUDE. This task produces only documentation edits (Markdown text changes). No code, no configuration, no infrastructure. Nothing to test.
- **Security**: EXCLUDE. Documentation-only changes with no security implications. No auth, APIs, user input, secrets, or dependencies involved.
- **Usability -- Strategy**: EXCLUDE. No user-facing workflow changes, journey modifications, or cognitive load implications beyond documentation readability (which user-docs-minion covers in Consultation 2).
- **Usability -- Design**: EXCLUDE. No user-facing interfaces produced.
- **Documentation**: INCLUDED. software-docs-minion (Consultation 1) and user-docs-minion (Consultation 2) are both consulted. This is the core domain of the task.
- **Observability**: EXCLUDE. No runtime components produced.

## Anticipated Approval Gates

**Zero mid-execution gates expected.** All six findings are well-specified (exact line numbers, exact corrections needed). The changes are additive (addendum notes) or minimal text corrections. They are easy to reverse (documentation edits). No downstream tasks depend on these changes. Per the reversibility/blast-radius matrix, none qualify for a gate.

One execution plan approval gate will occur as usual after Phase 3.5.

## Rationale

This is a well-scoped documentation consistency task with precisely identified findings. The primary planning value comes from:

1. **software-docs-minion**: Owns the ADR format. The main challenge is getting the addendum pattern right -- respecting immutability while correcting stale counts. This is a documentation architecture question, not a mechanical text replacement.
2. **user-docs-minion**: Owns reader clarity. The SHOULD findings are about disambiguation -- the right parenthetical wording matters for cognitive load. A documentation specialist will produce better wording than the orchestrator guessing.
3. **product-marketing-minion**: Has context from the README rewrite. Can catch terminology drift that the numerical findings don't cover.

Other agents were not selected because:
- No code, infrastructure, security surface, or runtime components are involved.
- The task scope is explicitly bounded to three files in docs/.
- The findings are fully enumerated -- no discovery or analysis phase needed.

## Scope

**In scope**: docs/decisions.md, docs/orchestration.md, docs/architecture.md -- six specific findings (4 MUST, 2 SHOULD) as enumerated in the issue.

**Out of scope**: README.md (already done), the-plan.md, AGENT.md files, skills/, nefario execution report history files (historical records, not active documentation).

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuild and version checking | Not relevant -- no agent rebuilds needed for documentation edits |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Claude Code statusline configuration | Not relevant -- no statusline changes needed |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the documentation consistency domain of this task.
