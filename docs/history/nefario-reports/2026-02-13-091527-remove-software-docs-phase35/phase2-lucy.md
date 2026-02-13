## Domain Plan Contribution: lucy

### Recommendations

#### Critical: prompt.md contains contradictions with the current state and the stated task

The orchestration prompt file (`prompt.md`) has two errors that must be corrected before synthesis:

1. **Line 1**: "Phase 3.5 Architecture Review drops from 6 to 5 mandatory reviewers" -- the current mandatory count is **5** (security-minion, test-minion, software-docs-minion, lucy, margo), not 6. The correct statement is "drops from 5 to 4."

2. **Line 4**: "ALWAYS reviewers list is: security-minion, test-minion, ux-strategy-minion, lucy, margo" -- `ux-strategy-minion` is currently in the **discretionary** reviewer pool, not mandatory. The task description and meta-plan both correctly identify the proposed mandatory list as 4 members: security-minion, test-minion, lucy, margo. The prompt.md success criterion introduces a scope expansion (promoting ux-strategy-minion to mandatory) that is NOT part of the user's request.

**Severity**: DRIFT (goal misalignment). If the synthesis plan uses prompt.md success criteria verbatim, it will implement a different change than what was requested. The execution plan must use the corrected list: `security-minion, test-minion, lucy, margo` (4 mandatory reviewers).

#### Answer to planning question (1): Outcome-action table should remain the primary driver

The outcome-action table should remain the primary mechanism for Phase 8 checklist construction. Rationale:

- The outcome-action table maps **concrete execution outcomes** (things that actually happened) to **specific documentation actions**. This is the right granularity for Phase 8, which runs post-execution.
- The synthesis plan provides supplementary context -- task prompts contain deliverables, file paths, and agent assignments that help the orchestrator evaluate which outcome-action rows apply. But the synthesis plan describes what was *planned*, not what was *executed*. Execution may diverge (tasks may be skipped, gates may reject deliverables, scope may change during execution).
- Scanning synthesis plan tasks first creates a risk of generating checklist items for planned-but-not-executed work. The current Phase 8 merge logic already has divergence-flagging for exactly this case (line 1607-1609 of SKILL.md: "For items in the Phase 3.5 checklist that do not correspond to any execution outcome, mark them as: 'Planned but not implemented -- verify if still needed.'"). The whole point of this change is to eliminate that divergence complexity. Do not reintroduce it by making the synthesis plan the primary source.

**Recommended approach**: At the Phase 7-to-8 boundary, the orchestrator evaluates execution outcomes against the outcome-action table (exactly as it does today for the "supplement" step). The synthesis plan is available as reference context for the orchestrator to understand what was intended, but it does not generate checklist items independently. This is a strict simplification: one source (outcome-action table applied to execution outcomes), one pass, no merge, no divergence flagging.

#### Answer to planning question (2): Owner tags and priority should be assigned by the orchestrator

The orchestrator (main session at the Phase 7-to-8 boundary) should assign owner tags and priority. Rationale:

- **Owner tags** are mechanically derivable from the outcome-action table. The table already specifies which agent owns each documentation action (column 3). No judgment is needed -- this is a lookup, not an assessment. Having doc agents self-assign ownership would require each agent to read the full execution outcome set and the outcome-action table, duplicating work and creating potential for inconsistent routing.
- **Priority** is more nuanced, but the orchestrator has the best context for assignment: it knows which changes were gated (MUST priority -- gate-approved decisions always need ADRs), which changes affect users directly (SHOULD priority), and which are internal improvements (COULD priority). A simple heuristic suffices:
  - MUST: items triggered by gate-approved decisions, new projects requiring README, breaking changes requiring migration guides
  - SHOULD: items triggered by user-facing changes (new features, CLI commands, API endpoints)
  - COULD: items triggered by internal changes (architecture changes with no user-facing impact, config reference updates)
- This keeps Phase 8 agents focused on *writing documentation*, not on *deciding what to write*. The checklist they receive is their work order, pre-routed and pre-prioritized.

#### Scope containment verification

I verified the proposed change against the user's original request and the meta-plan scope boundaries:

| Requirement | Plan Element | Status |
|---|---|---|
| Remove software-docs-minion from Phase 3.5 mandatory reviewers | Meta-plan scope: "Phase 3.5 mandatory reviewer list (remove software-docs-minion)" | COVERED |
| Phase 8 self-derives checklist from synthesis plan + execution outcomes | Meta-plan scope: "Phase 8 checklist derivation logic (single-source)" | COVERED |
| Phase 3.5 no longer produces phase3.5-docs-checklist.md | Meta-plan scope: "Scratch directory structure (remove phase3.5-docs-checklist.md)" | COVERED |
| software-docs-minion custom Phase 3.5 prompt removed | Meta-plan scope: "software-docs-minion custom Phase 3.5 prompt" | COVERED |
| Phase 8 sub-steps unchanged | Meta-plan out-of-scope | CORRECTLY EXCLUDED |
| user-docs-minion discretionary role unchanged | Meta-plan out-of-scope | CORRECTLY EXCLUDED |
| Cross-cutting checklist Documentation item unchanged | Meta-plan out-of-scope | CORRECTLY EXCLUDED |
| the-plan.md changes require user approval gate | Constraint in prompt.md | COVERED |

No orphaned tasks (every planned change traces to a requirement). No unaddressed requirements (every requirement has a corresponding scope item). Proportionality is appropriate -- the solution complexity matches the problem complexity (removing an agent from a list and simplifying merge logic).

### Proposed Tasks

**Task 1: Update the-plan.md**
- What: Remove software-docs-minion from the Phase 3.5 mandatory reviewers table. Update Phase 8 description to state that the checklist is derived from execution outcomes via the outcome-action table (no merge with Phase 3.5 checklist). Update the mandatory reviewer count from 5 to 4 in all relevant locations. Remove the software-docs-minion exception paragraph. Remove the "Merge documentation checklist from Phase 3.5" language in Phase 8 description.
- Deliverables: Updated `the-plan.md` with narrowly scoped diff
- Dependencies: None
- Gate: MUST (the-plan.md is canonical source of truth; constraint requires explicit user approval)

**Task 2: Update SKILL.md**
- What: Remove software-docs-minion from the mandatory reviewers section. Remove the software-docs-minion custom prompt block. Update Phase 8 logic to remove step 1a (read Phase 3.5 checklist), step 1c (flag divergence), and simplify step 1 to: "Generate checklist from execution outcomes using the outcome-action table." Remove `phase3.5-docs-checklist.md` from the scratch directory structure listing. Update the Reviewer Approval Gate presentation to show 4 mandatory reviewers. Remove the software-docs-minion exception paragraph.
- Deliverables: Updated `skills/nefario/SKILL.md`
- Dependencies: Task 1 (derives from the-plan.md changes)

**Task 3: Update AGENT.md**
- What: Update nefario's AGENT.md to reflect 4 mandatory reviewers in the Architecture Review Agents synthesis template. Remove the software-docs-minion exception paragraph. Update any references to mandatory reviewer count.
- Deliverables: Updated `nefario/AGENT.md`
- Dependencies: Task 1

**Task 4: Update docs/orchestration.md**
- What: Update Phase 3.5 mandatory reviewer table (remove software-docs-minion row). Remove software-docs-minion exception paragraph. Update Phase 8 description to remove merge language. Update the mermaid diagram if it references software-docs-minion in Phase 3.5 flow.
- Deliverables: Updated `docs/orchestration.md`
- Dependencies: Task 1

### Risks and Concerns

**Risk 1 (LOW): Missed documentation items that only plan analysis would catch**

The software-docs-minion's Phase 3.5 review could theoretically identify documentation needs that are not captured by the outcome-action table -- for example, a plan that deprecates a concept without removing code (no execution outcome triggers, but conceptual documentation needs updating). However:
- The outcome-action table is comprehensive for the common cases.
- The synthesis plan's task prompts already contain deliverables with file paths, which the orchestrator can scan for documentation-relevant signals.
- Missed documentation is cheap to fix post-execution (non-blocking, no rework cascade).
- The "Documentation (ALWAYS)" cross-cutting checklist item in Phase 1 ensures documentation is considered during planning regardless.

Mitigation: none needed beyond the existing outcome-action table. The cost of a missed documentation item is low (fixable in a subsequent session), while the cost of running an extra mandatory reviewer on every orchestration is consistent.

**Risk 2 (MEDIUM): prompt.md success criteria drift propagating to synthesis**

As noted above, the prompt.md contains an incorrect mandatory reviewer list (includes ux-strategy-minion, which was never requested). If synthesis uses prompt.md success criteria as-is, the execution plan will implement an unrequested change.

Mitigation: Nefario must use the corrected list (security-minion, test-minion, lucy, margo) during synthesis. The meta-plan's "Proposed mandatory reviewers" section correctly states the 4-member list.

**Risk 3 (LOW): Inconsistent mandatory count across artifacts**

The mandatory reviewer count appears in multiple locations across 4 files. Missing one creates inconsistency.

Mitigation: Execution tasks should include an explicit checklist of all locations where the mandatory count or list appears. I identified these locations:

| File | Location | Current Value |
|---|---|---|
| `the-plan.md` | Phase 3.5 mandatory reviewer table (line ~179) | 5 rows including software-docs-minion |
| `the-plan.md` | Phase 3.5 description in nefario invocation model (line ~183-184) | "Mandatory reviewers (security-minion, test-minion, software-docs-minion, lucy, margo)" |
| `the-plan.md` | software-docs-minion exception paragraph (line ~184) | "software-docs-minion produces a documentation impact checklist for Phase 8" |
| `nefario/AGENT.md` | Architecture Review Agents synthesis template (line ~513) | "Mandatory (5): security-minion, test-minion, software-docs-minion, lucy, margo" |
| `nefario/AGENT.md` | Mandatory reviewer table (line ~562-570) | 5 rows including software-docs-minion |
| `nefario/AGENT.md` | software-docs-minion exception paragraph (line ~633-638) | Full exception paragraph |
| `skills/nefario/SKILL.md` | Mandatory reviewer section | 5 mandatory including software-docs-minion |
| `skills/nefario/SKILL.md` | software-docs-minion custom prompt block (lines ~907-972) | Full custom prompt |
| `skills/nefario/SKILL.md` | Phase 8 merge logic (lines ~1583-1611) | Three-step merge with Phase 3.5 checklist |
| `skills/nefario/SKILL.md` | Scratch directory structure (line ~289) | Lists phase3.5-docs-checklist.md |
| `skills/nefario/SKILL.md` | Reviewer Approval Gate presentation | Shows mandatory count |
| `docs/orchestration.md` | Phase 3.5 mandatory reviewer table (line ~59-65) | 5 rows including software-docs-minion |
| `docs/orchestration.md` | software-docs-minion exception paragraph (line ~90) | Full exception paragraph |
| `docs/orchestration.md` | Phase 8 description (line ~162) | "merging the Phase 3.5 documentation impact checklist" |

### Additional Agents Needed

None. The current planning team (software-docs-minion + lucy) is sufficient. software-docs-minion provides the domain perspective on what information might be lost; lucy provides the alignment and consistency perspective. The execution is mechanical text editing across 4 files -- no additional domain expertise is needed beyond what planning provides.
