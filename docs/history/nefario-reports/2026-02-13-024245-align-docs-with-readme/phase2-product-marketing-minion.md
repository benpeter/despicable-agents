## Domain Plan Contribution: product-marketing-minion

### Recommendations

I examined the README (the terminology baseline from PR #58) against the three target files for terminology and framing inconsistencies. Here is what I found.

#### Terminology Mapping: README vs. docs/

The README introduced a two-tier reviewer vocabulary:

| README term | Meaning |
|---|---|
| "mandatory reviewers" / "five mandatory reviewers" | Always-invoked reviewers (security-minion, test-minion, software-docs-minion, lucy, margo) |
| "discretionary reviewers" | Nefario-selected, user-approved reviewers from a 6-member pool |

The docs/ layer uses different terms for the same concepts:

| docs/ term | Used in | README equivalent |
|---|---|---|
| "ALWAYS reviewers" | decisions.md (lines 128, 153, 188, 191, 262), orchestration.md (line 57 heading, lines 61-65, 340) | "mandatory reviewers" |
| "ALWAYS" as inclusion rule | orchestration.md cross-cutting table (line 340, 342), architecture.md (implicit via checklist description) | "mandatory" |
| "conditional reviewers" | decisions.md (lines 128, 150, 191) | "discretionary reviewers" |
| "Discretionary reviewers" | orchestration.md (line 67 heading, lines 69-76) | Already aligned |
| "conditional at..." trigger | decisions.md (line 150) | domain-signal-based discretionary selection |

The canonical source (the-plan.md) uses "Mandatory reviewers" and "Discretionary reviewers" -- the same terms the README adopted. The docs/ layer is stale, retaining the older "ALWAYS"/"conditional" vocabulary from the pre-PR-58 era.

#### Specific Terminology Inconsistencies Found

**1. orchestration.md -- Phase 3.5 section (lines 57-76):**
- The heading says "Mandatory reviewers (ALWAYS):" -- this mixes both vocabularies in one phrase. Should say "Mandatory reviewers:" to match README and the-plan.md.
- The second heading says "Discretionary reviewers (selected by nefario, approved by user):" -- already aligned, no change needed.
- The mandatory reviewer table still lists ux-strategy-minion as a mandatory reviewer with "ALWAYS" trigger. This is the primary factual error (count bug). After removal, the table has 5 mandatory reviewers, matching the README.

**2. orchestration.md -- Cross-cutting concerns table (lines 336-343):**
- "Usability -- Strategy" row lists ux-strategy-minion with inclusion rule "ALWAYS include". This should change to a conditional/discretionary inclusion rule matching the-plan.md ("Include when plan includes user-facing workflow changes, journey modifications, or cognitive load implications").
- Note: This cross-cutting checklist is about Phase 2 planning inclusion, not Phase 3.5 review. The checklist still says the default is to include and exclusion requires justification, which may remain appropriate. However, saying "ALWAYS include" for ux-strategy-minion creates cognitive dissonance with the reviewer table 270 lines earlier, where ux-strategy-minion is now discretionary. Recommend aligning the language.

**3. decisions.md -- Decision 10 (line 128):**
- "Six ALWAYS reviewers" -- count is now 5, and terminology should say "five mandatory reviewers".
- "four conditional reviewers" -- the discretionary pool is now 6. Terminology should say "six discretionary reviewers" (or "up to six discretionary reviewers").
- Lists ux-strategy-minion as an ALWAYS reviewer. Should be removed from the ALWAYS list and added to the discretionary list.

**4. decisions.md -- Decision 12 (line 153):**
- "6 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5)" -- count is now 5. This is a historical consequence statement. Recommend appending a note or updating to reflect the subsequent change, e.g., "6 ALWAYS reviewers at time of decision (later reduced to 5 when ux-strategy-minion moved to discretionary pool)."

**5. decisions.md -- Decision 15 (line 191):**
- "(6 ALWAYS + 0-4 conditional reviewers)" -- should be "(5 mandatory + 0-6 discretionary reviewers)". Both count and terminology need updating.

**6. decisions.md -- Decision 20 (line 262):**
- "Phase 3.5 minimum review cost increases (6 ALWAYS reviewers)" -- should say "5 mandatory reviewers" (or note the subsequent reduction).

**7. architecture.md -- Cross-cutting concerns (line 117):**
- Lists ux-strategy-minion under "Usability -- Strategy" with no inclusion qualifier, but the framing says "mandates considering six dimensions" which implies all are always considered. This section describes the planning checklist (Phase 2), not the reviewer roster (Phase 3.5). The six dimensions themselves remain valid -- ux-strategy-minion is still a specialist consulted during planning. However, the implicit "always" framing here may confuse readers who associate ux-strategy-minion with the mandatory reviewer list. Recommend adding a brief note or adjusting the description to clarify that "considered" in planning (Phase 2) differs from "mandatory reviewer" in Phase 3.5.

#### Framing Inconsistency: "ALWAYS" as a design concept vs. a label

The docs/ layer uses "ALWAYS" as a capitalized keyword throughout (like a technical enum value: "ALWAYS reviewers", "ALWAYS include", "ALWAYS means ALWAYS"). The README uses lowercase natural language ("mandatory reviewers", "five mandatory reviewers"). The-plan.md has already moved to the README's vocabulary. This creates a split personality in the documentation:

- Reader enters via README: learns "mandatory" and "discretionary"
- Reader goes deeper into docs/: encounters "ALWAYS" and "conditional" for the same concepts
- Reader reads decisions.md: sees historical "ALWAYS" labels alongside references to Decision 15 which says "ALWAYS means ALWAYS"

This is not a blocking problem for comprehension, but it creates unnecessary cognitive translation. Since the-plan.md (source of truth) and README (entry point) are already aligned on "mandatory"/"discretionary", the docs/ layer should follow.

#### What Should NOT Change

Decision entries in decisions.md are historical records. The content of choices, rationale, and alternatives rejected should preserve the terminology used at the time the decision was made. The appropriate fix is:

- For decisions whose **consequences are now factually wrong** (counts): add a brief inline note like "(subsequently reduced to 5 when ux-strategy-minion moved to discretionary pool)" or update the consequence with a note referencing the change.
- For terminology within decision choice/rationale text: leave as-is. These are historical artifacts. Changing "ALWAYS" to "mandatory" in a 2026-02-09 decision entry would revise history.
- For **non-historical** prose (section headings, table headers, introductory text, descriptions of the current system): update to "mandatory"/"discretionary".

### Proposed Tasks

**Task 1: Fix orchestration.md reviewer roster and terminology (MUST)**
- Update Phase 3.5 mandatory reviewer table: remove ux-strategy-minion, add it to discretionary table
- Change heading from "Mandatory reviewers (ALWAYS):" to "Mandatory reviewers:"
- Update cross-cutting concerns table: change ux-strategy-minion inclusion rule from "ALWAYS include" to conditional language matching the-plan.md
- Fix discretionary pool count reference if any exists ("0-4" becomes "0-6")
- Estimated scope: 4 line-level edits

**Task 2: Fix decisions.md stale counts and add historical notes (MUST for counts, SHOULD for terminology notes)**
- Decision 10 (line 128): Fix "Six ALWAYS reviewers" to "Five mandatory reviewers" and "four conditional" to "six discretionary". Move ux-strategy-minion from ALWAYS to conditional list.
- Decision 12 (line 153): Add note to consequences: "(subsequently reduced to 5 mandatory reviewers when ux-strategy-minion moved to discretionary pool)"
- Decision 15 (line 191): Fix "(6 ALWAYS + 0-4 conditional reviewers)" to "(5 mandatory + 0-6 discretionary reviewers)"
- Decision 20 (line 262): Fix "(6 ALWAYS reviewers)" to "(5 mandatory reviewers)"
- Estimated scope: 4-6 line-level edits

**Task 3: Clarify architecture.md cross-cutting section (SHOULD)**
- The cross-cutting concerns list in architecture.md describes the six planning dimensions, not the reviewer roster. ux-strategy-minion remains a valid specialist for planning. However, the current framing implies all six are mandatory considerations, which could confuse readers about ux-strategy-minion's Phase 3.5 status. Add a one-line note distinguishing planning dimensions (Phase 2) from mandatory reviewers (Phase 3.5), or simply ensure no "ALWAYS" language appears in this section.
- Estimated scope: 1 line addition or 0 changes (depending on whether the planner judges the risk of confusion sufficient to act on)

### Risks and Concerns

**Risk 1: Rewriting historical decisions.**
Decisions.md entries are decision records, analogous to ADRs. Changing the text of a historical choice or rationale misrepresents what was decided at the time. The fix for stale counts should use inline annotations (e.g., parenthetical notes, "Note:" addenda) rather than rewriting the original text. This preserves the decision log's integrity as a historical record.

**Risk 2: Cross-cutting checklist vs. reviewer roster confusion.**
The cross-cutting concerns checklist (six dimensions, used in Phase 2 planning) is a separate concept from the Phase 3.5 reviewer roster (5 mandatory + up to 6 discretionary). Both appear in orchestration.md and architecture.md. Currently, ux-strategy-minion appears in both lists, but with different statuses (discretionary reviewer, but still a valid cross-cutting concern). The edits must preserve this distinction. Specifically, removing ux-strategy-minion from the Phase 3.5 mandatory table must not accidentally remove it from the Phase 2 cross-cutting checklist.

**Risk 3: Terminology scope creep.**
The task scope is the three target files. But "ALWAYS"/"conditional" terminology also appears in: nefario/AGENT.md, the-plan.md (already updated), and execution reports in docs/history/. The plan should explicitly exclude these from scope to prevent scope creep. Execution reports are historical artifacts and should never be edited.

### Additional Agents Needed

- **lucy**: Should review the final edits for consistency with the-plan.md (source of truth) and ensure no convention drift is introduced. Lucy's role in intent alignment makes it well-suited to verify that the terminology changes correctly reflect the canonical spec without introducing new inconsistencies.
- **software-docs-minion**: If architecture.md's cross-cutting section is modified, software-docs-minion should verify the change does not create inconsistency with using-nefario.md (the user-facing orchestration guide), which describes Phase 3.5 as "Security and testing reviews are mandatory; others trigger based on plan scope" -- already using natural language rather than "ALWAYS" labels, and already aligned with the new terminology direction.
