# Domain Plan Contribution: software-docs-minion

## Recommendations

### The Phase 3.5 checklist is reconstructable -- with one structural gap

After reviewing what I currently produce in Phase 3.5 against the two proposed replacement sources (synthesis plan + execution outcomes), my assessment is that **the removal is safe** with one mitigation. Here is the analysis:

**What the outcome-action table already covers well:**
- New API endpoints -> API docs
- Architecture changes -> C4 diagrams
- Gate-approved decisions -> ADRs
- New projects -> README
- Config changes -> config reference
- README staleness -> review pass

These are mechanical pattern matches. The execution outcomes (files changed, services added, gates approved) provide clear signals that nefario can match against the outcome-action table without my pre-analysis. There is no information loss here.

**What the synthesis plan covers well:**
- Task deliverables and file paths (I currently read these to derive my checklist items)
- Agent assignments (I use these to understand scope)
- Technology choices (I flag when these need ADRs)

Again, nefario at Phase 8 boundary has access to exactly the same synthesis plan I read at Phase 3.5. No information loss.

**The one structural gap: derivative documentation consistency**

The real-world Phase 3.5 review at `nefario/scratch/re-review-revised-plans-all-reviewers/phase3.5-software-docs-minion.md` demonstrates the pattern. My ADVISE finding was not about what documentation actions the outcome-action table would trigger. It was about **derivative documentation files that reference the changing system** -- files that are not deliverables of the plan, not touched by execution, but will become inconsistent if left alone.

This is the category the outcome-action table misses: documentation that needs updating because its *content references* something the plan changes, not because the plan produces documentation as a deliverable. Concretely:

- The plan changed Phase 3.5 BLOCK resolution behavior in SKILL.md
- Three other docs files (using-nefario.md, compaction-strategy.md, decisions.md) described the old behavior
- Execution would not touch those files, so execution outcomes would show no signal
- The outcome-action table has no row for "existing docs reference changed behavior"

### Mitigation: add one row to the outcome-action table

Add a row to the outcome-action table:

| Execution Outcome | Documentation Action | Owner |
|---|---|---|
| Specification/config files modified (SKILL.md, AGENT.md, CLAUDE.md, etc.) | Scan for derivative docs referencing changed sections | software-docs-minion |

This turns the gap from "requires a specialist to spot at plan time" into "nefario can pattern-match at Phase 8 boundary." The documentation agent then gets a work item to grep for cross-references rather than needing to have pre-identified them.

Alternatively, a lighter approach: add a standing instruction to the Phase 8 software-docs-minion prompt: "For each specification file modified during execution, search the repository for other documentation files that reference the modified sections and update them for consistency."

### The priority classification is not lost

My Phase 3.5 checklist assigns MUST/SHOULD/COULD priority to each item. This classification can be self-derived at Phase 8:
- MUST: items matching the outcome-action table for correctness (new API = API docs, new project = README)
- SHOULD: items matching the table for completeness (architecture change = C4 update, gate decision = ADR)
- COULD: derivative consistency, README review passes

The Phase 8 agent can apply this heuristic without pre-classification.

### Owner routing is not lost

The `[software-docs]` vs `[user-docs]` tags I assign are already implicit in the outcome-action table's Owner column. Nefario can derive routing directly from the table match.

### Net assessment

Removing software-docs-minion from Phase 3.5 eliminates one mandatory agent spawn per orchestration. The information I produce is 95% derivable from the two proposed sources. The remaining 5% (derivative documentation consistency) is addressable by a one-row table addition or a standing prompt instruction. The tradeoff is favorable.

## Proposed Tasks

### Task 1: Add derivative-documentation row to outcome-action table

**What**: Add a row to the outcome-action table in both `the-plan.md` and `skills/nefario/SKILL.md` for "specification/config files modified -> scan for derivative docs referencing changed sections."

**Deliverables**: Updated outcome-action table in both files.

**Dependencies**: None. Can be done first.

### Task 2: Remove software-docs-minion from Phase 3.5 mandatory reviewers

**What**: In `the-plan.md` (nefario spec) and `skills/nefario/SKILL.md`:
- Remove software-docs-minion from the mandatory reviewers table
- Remove the dedicated software-docs-minion prompt block in Phase 3.5
- Remove the `phase3.5-docs-checklist.md` file from the scratch directory structure
- Update reviewer count references
- Update the Reviewer Approval Gate presentation format (remove "software-docs" from the mandatory line)

**Deliverables**: Updated the-plan.md, updated SKILL.md.

**Dependencies**: Task 1 (the replacement row must exist before removing the Phase 3.5 input).

### Task 3: Rewrite Phase 8 to self-derive checklist

**What**: In `skills/nefario/SKILL.md`, rewrite the Phase 8 section to:
- Remove step 1a (read Phase 3.5 checklist) entirely
- Promote step 1b (outcome-action table evaluation) to the sole checklist generation mechanism
- Remove step 1c (flag divergence between Phase 3.5 and execution) since there is no Phase 3.5 checklist to diverge from
- Add the standing instruction for derivative documentation scanning
- Preserve the owner routing, priority heuristic, and all sub-steps (8a parallel spawn, 8b marketing review)

**Deliverables**: Updated Phase 8 section in SKILL.md.

**Dependencies**: Task 1 and Task 2.

### Task 4: Update documentation files that reference Phase 3.5 software-docs role

**What**: Search for and update all documentation files that reference software-docs-minion's Phase 3.5 role:
- `docs/orchestration.md` (if it describes the Phase 3.5 reviewer list)
- `docs/using-nefario.md` (if it mentions mandatory reviewers)
- `docs/architecture.md` (if it describes the review phase)
- Any sequence diagrams showing the Phase 3.5 flow

**Deliverables**: Updated documentation files with consistent references.

**Dependencies**: Tasks 2 and 3 (need to know the final state to document accurately).

### Task 5: Update nefario AGENT.md

**What**: Regenerate or manually update `nefario/AGENT.md` to reflect the changes from tasks 1-3. The AGENT.md encodes the Phase 3.5 mandatory reviewers and Phase 8 logic from SKILL.md.

**Deliverables**: Updated nefario/AGENT.md with correct Phase 3.5 reviewer list and Phase 8 self-derivation logic.

**Dependencies**: Tasks 1-3.

## Risks and Concerns

### Low risk: First few orchestrations may produce slightly less precise doc checklists

The Phase 3.5 checklist benefited from a documentation specialist reading the full plan with documentation-specific judgment. The self-derived checklist is mechanical pattern matching. For most orchestrations this is equivalent. For plans with subtle documentation implications (e.g., a refactoring that changes the conceptual architecture without adding new services), the mechanical match may miss that C4 diagrams need updating because no row in the outcome-action table fires.

**Mitigation**: The derivative-documentation row partially addresses this. Additionally, the software-docs-minion in Phase 8 still runs with full specialist judgment -- it just starts without a pre-analyzed checklist. It can identify additional needs when it inspects the actual changes.

### Low risk: Loss of the divergence signal

The current Phase 8 flags "planned but not implemented" items when Phase 3.5 checklist items have no corresponding execution outcome. This was a useful signal for detecting scope cuts or failed tasks that still need documentation cleanup. Without the Phase 3.5 checklist, this signal disappears.

**Mitigation**: This is a minor loss. The execution plan itself (Phase 3 synthesis) lists planned deliverables. Nefario can compare planned vs. actual deliverables at the Phase 7->8 boundary without needing a separate docs checklist. This comparison is already implicit in nefario's orchestration awareness. If desired, add an explicit instruction to Phase 8: "Compare planned deliverables (from synthesis) against execution outcomes. Note any planned items that were not delivered."

### No risk: File path accuracy

My Phase 3.5 checklist provides exact file paths for documentation updates. These paths are derivable from the synthesis plan (which lists deliverables and file paths) and from execution outcomes (which show actual files changed). No information is lost.

## Additional Agents Needed

None. The current team (nefario for the specification changes, software-docs-minion or equivalent for the documentation updates) is sufficient. Lucy should review for intent alignment and convention consistency. Margo should confirm this simplification aligns with YAGNI/KISS principles (it does -- removing a mandatory agent that provides reconstructable information is exactly the kind of simplification margo advocates for).
