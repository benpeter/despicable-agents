## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. Canonical Definition Placement: SKILL.md Only (Single Source of Truth)

The boundary definition should live in **SKILL.md only**, specifically in the Post-Execution Phases section where the phase-skipping conditional currently says `"produced no code files (only docs/config)"`. This is the point of use -- the exact location where the classification decision is made at runtime.

**Why SKILL.md, not AGENT.md:**
- SKILL.md contains the phase-skipping conditionals (lines 1648-1670). This is where the classification is *applied*. Placing the definition at the point of application follows the documentation-minimalism principle of "just in time."
- AGENT.md contains the delegation table and External Skill Classification (ORCHESTRATION vs LEAF). Adding file-type classification there would create a second classification taxonomy in a file that already has one. That risks confusion between the two.
- The primary consumers are AI agents reading these as system prompts. An AI agent executing Phase 5 reads SKILL.md instructions, not AGENT.md. Placing the definition where it is consumed eliminates the need for cross-referencing.

**Why not both:** Duplication between AGENT.md and SKILL.md is the documented divergence risk for this project. Decision 3 (RESEARCH.md vs AGENT.md separation) already captures the principle that redundancy leads to drift. AGENT.md and SKILL.md have independent edit cycles; duplicating the classification boundary would create the same drift problem.

**Why not a separate document:** A separate doc (e.g., `docs/file-classification.md`) would be discoverable by humans browsing `docs/` but invisible to the AI agent at runtime -- it would not be loaded into context when SKILL.md is being followed. The boundary must be embedded in the instruction flow, not linked from it.

#### 2. Include Worked Examples, But Tightly Scoped (3-4 Examples)

Yes, worked examples are essential. AI agents reading system prompts perform better with concrete examples than with abstract definitions alone. However, the examples must be minimal -- SKILL.md is already a long prompt, and each additional line has a marginal cost to context window and attention.

**Recommended format: inline table, 3-4 rows.** A compact table at the classification boundary definition point, not a separate section. Each row is one file pattern with its classification and a one-phrase rationale. This format:
- Provides the concrete anchoring that makes the boundary unambiguous
- Adds ~6-8 lines (table header + 3-4 rows), well within noise tolerance for SKILL.md
- Is scannable -- an AI agent can parse a table faster than prose paragraphs

**Suggested examples (to be refined by ai-modeling-minion who defines the actual boundary):**

| File Pattern | Classification | Rationale |
|-------------|---------------|-----------|
| `AGENT.md` in an agent directory | Logic-bearing | Contains system prompt instructions that control agent behavior |
| `SKILL.md` | Logic-bearing | Contains phase conditionals and orchestration workflow |
| `README.md` | Documentation-only | Describes the project; does not control runtime behavior |
| `docs/*.md` (architecture, decisions) | Documentation-only | Reference material for humans and planning phases |

Three to four examples is the sweet spot: enough to establish the pattern (what makes something "logic-bearing" is that it controls agent behavior at runtime), few enough to avoid clutter. More examples would risk the definition section competing for attention with the phase instructions themselves.

#### 3. Existing Documentation That Should Reference the Distinction

**`docs/orchestration.md`** -- Section 1, Phase 5 description (line ~189-191) currently says: "Skipped if Phase 4 produced only documentation or configuration with no code." This should be updated to reference the logic-bearing/documentation-only distinction, at minimum replacing "documentation" with "documentation-only markdown" to signal that not all `.md` files are skip-worthy. A brief parenthetical or footnote pointing to SKILL.md as the authoritative source is sufficient. orchestration.md is a contributor-facing architecture document -- it should reflect the vocabulary without duplicating the full definition.

**`docs/decisions.md`** -- A new decision entry should be added documenting this classification boundary. Decision 15 already captures the *symptom* ("the orchestrator skipped Phase 3.5 twice for 'documentation-only' tasks") but does not formalize the *resolution* as a classification system. A new decision entry records the "why" -- why this boundary exists, what alternatives were considered (e.g., extension-based classification, content heuristics), and what the consequences are. This is exactly the kind of lasting architectural decision that belongs in the decision log.

**`docs/agent-anatomy.md`** -- This document describes AGENT.md structure. It would benefit from a single sentence noting that AGENT.md files are classified as logic-bearing markdown in the orchestration context, with a link to SKILL.md. This is a natural place for the cross-reference since agent-anatomy.md already explains what AGENT.md *is*.

**`the-plan.md`** -- Lines 189-191 contain the Phase 5 skip condition using the same ambiguous wording. Since the-plan.md must not be modified by agents, I recommend flagging this to the human owner: the-plan.md Phase 5 description should adopt the logic-bearing/documentation-only vocabulary to stay consistent with the fix in SKILL.md. This is a terminology alignment, not a behavioral change.

#### 4. Documentation Format for AI Agent Consumers

For AI agents reading system prompts, the optimal format is:

**Inline definition + classification table + operational rule.** Three elements, tightly co-located:

1. **Definition** (1-2 sentences): What "logic-bearing markdown" means and what "documentation-only markdown" means. Crisp, unambiguous. No preamble.
2. **Classification table** (3-4 rows): Concrete examples as recommended above. Tables are the highest-signal-to-noise format for AI agents parsing structured boundaries.
3. **Operational rule** (1 sentence): The decision rule that uses the classification. E.g., "Treat logic-bearing markdown as code for phase-skipping purposes."

This three-part structure should replace the current parenthetical `"(only docs/config)"` at the Phase 5 skip conditional in SKILL.md. It should NOT be placed in a separate subsection or a preamble -- it should be embedded at the decision point.

**What to avoid:**
- Lengthy prose explanations. AI agents extract rules from structured content more reliably than from paragraphs.
- A separate "File Classification" section earlier in SKILL.md. This would separate the definition from its application, forcing the agent to hold two distant sections in working memory.
- ADR format within SKILL.md. ADRs belong in `docs/decisions.md` -- the SKILL.md needs the operational rule, not the decision history.

### Proposed Tasks

#### Task D1: Update Phase 5 skip conditional in SKILL.md with classification boundary

**What to do:** Replace the current ambiguous `"produced no code files (only docs/config)"` wording in SKILL.md (lines 1648-1670) with the inline definition + classification table + operational rule. The exact classification criteria come from ai-modeling-minion; this task applies the documentation format.

**Deliverables:**
- Updated SKILL.md Phase 5 section with the three-part classification boundary (definition, table, rule)
- The same vocabulary applied consistently to all phase-skipping conditionals in SKILL.md (Phase 5, and any other conditionals that reference "code files" vs "docs")

**Dependencies:** Depends on ai-modeling-minion delivering the classification criteria (what makes a file "logic-bearing"). software-docs-minion formats and places the criteria; ai-modeling-minion defines the criteria.

#### Task D2: Update AGENT.md Phase 5 description with consistent vocabulary

**What to do:** Update the Phase 5 description in `nefario/AGENT.md` (the Post-Execution Phases section, line 764) to use "logic-bearing markdown" / "documentation-only markdown" vocabulary consistently with SKILL.md. Do NOT duplicate the full classification table -- a single sentence referencing the distinction is sufficient since AGENT.md is a summary layer and SKILL.md is the operational layer.

**Deliverables:**
- Updated nefario/AGENT.md with consistent Phase 5 skip condition wording

**Dependencies:** Depends on Task D1 (SKILL.md is the source of truth; AGENT.md aligns to it).

#### Task D3: Update docs/orchestration.md Phase 5 description

**What to do:** Update the Phase 5 description in `docs/orchestration.md` (~line 189-191) to use the logic-bearing/documentation-only vocabulary. Brief parenthetical or footnote referencing SKILL.md as the authoritative definition. No full classification table duplication.

**Deliverables:**
- Updated docs/orchestration.md with consistent vocabulary

**Dependencies:** Depends on Task D1.

#### Task D4: Add decision entry to docs/decisions.md

**What to do:** Add a new decision entry documenting the logic-bearing vs documentation-only markdown classification boundary. Follow the existing decision entry format (Status, Date, Choice, Alternatives rejected, Rationale, Consequences). Number sequentially after the current last decision.

**Deliverables:**
- New decision entry in docs/decisions.md

**Dependencies:** Depends on Task D1 (needs the final classification criteria to document accurately). Can run in parallel with D2 and D3.

#### Task D5: Add cross-reference in docs/agent-anatomy.md

**What to do:** Add a single sentence in the AGENT.md Structure section noting that AGENT.md files are classified as logic-bearing markdown in the orchestration context. Include a brief reference to SKILL.md for the full classification.

**Deliverables:**
- Updated docs/agent-anatomy.md with cross-reference

**Dependencies:** Depends on Task D1.

#### Recommendation for human owner (not a task)

**the-plan.md update:** Lines 189-191 of the-plan.md describe the Phase 5 skip condition as "Skipped if Phase 4 produced only documentation or configuration with no code." This should be updated to use the logic-bearing/documentation-only vocabulary for consistency. This is flagged as a recommendation per project rules -- agents must not modify the-plan.md.

### Risks and Concerns

1. **Over-documentation risk.** Five deliverables (D1-D5) for a single classification boundary risks violating the project's "Lean and Mean" principle. Mitigation: D1 is the only substantive deliverable. D2, D3, D5 are vocabulary alignment changes (1-2 sentences each). D4 is a decision record that the project already tracks for all architectural choices. If margo flags this as over-engineering, D5 (agent-anatomy cross-reference) is the most expendable.

2. **Definition drift between SKILL.md and reference docs.** Even with SKILL.md as the single source of truth, the reference docs (orchestration.md, AGENT.md) could drift if someone updates SKILL.md without updating the references. Mitigation: The reference docs should use the vocabulary ("logic-bearing markdown") without repeating the full definition or examples. Vocabulary-only references are low-drift: they signal that a concept exists without duplicating its content.

3. **Classification table becoming stale.** New file types may emerge that don't fit the 3-4 examples. Mitigation: The table is illustrative, not exhaustive. The definition (the 1-2 sentence rule) is what governs; the table aids comprehension. Adding a note like "representative examples, not exhaustive" prevents the table from being treated as a closed list.

4. **the-plan.md divergence.** If the human owner does not update the-plan.md, the source-of-truth spec will use different vocabulary than the operational documents. This is a known limitation -- flagged but not actionable by agents.

### Additional Agents Needed

None. The current team (ai-modeling-minion for classification criteria, software-docs-minion for documentation placement, lucy for alignment) is sufficient. The documentation changes are straightforward vocabulary alignment across a small number of files, all within the despicable-agents project itself.
