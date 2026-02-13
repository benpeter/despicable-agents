## Domain Plan Contribution: user-docs-minion

### Recommendations

#### 1. Parenthetical clarification for "six dimensions" references

The word "six" appears in two distinct contexts: six cross-cutting checklist **dimensions** (Testing, Security, Usability-Strategy, Usability-Design, Documentation, Observability) and five mandatory **reviewers** (security-minion, test-minion, software-docs-minion, lucy, margo). A reader scanning the orchestration doc encounters "six" in both the dimensions discussion and the nearby reviewer discussion, creating ambiguity.

**Recommended clarification pattern**: Add a short parenthetical on the first substantive mention in each file, then use the bare phrase afterward. The parenthetical should name what the six dimensions ARE, not explain what they are not. Positive identification is clearer than negative disambiguation.

Specific wording for each location:

- **orchestration.md line 20** (Phase 1 bullet): Change `all six dimensions assessed` to `all six dimensions assessed -- Testing, Security, Usability-Strategy, Usability-Design, Documentation, Observability`. This is the first mention in the file and the most important one to anchor. The em-dash list is lightweight and scannable.

- **orchestration.md line 44** (Phase 3 step 4): Change `the six cross-cutting dimensions` to `the six cross-cutting dimensions (see table below)`. This creates a forward reference to the table at line 336, which lists all six explicitly. No need to repeat the full list here.

- **orchestration.md line 334** (Cross-Cutting Concerns heading paragraph): No change needed. This paragraph immediately precedes the table that enumerates all six dimensions. The table IS the clarification.

- **architecture.md line 113**: Change `mandates considering six dimensions` to `mandates considering six cross-cutting dimensions`. Adding "cross-cutting" links it to the named concept rather than leaving "six dimensions" as a bare number that could be confused with reviewer count. The numbered list immediately following already provides the full enumeration.

This approach follows the principle of progressive disclosure: anchor the concept once with the full list, then use back-references or rely on adjacent tables for subsequent mentions. It avoids cluttering every instance with "(distinct from the five mandatory reviewers)" which is defensive writing that makes the reader aware of a confusion they may not have had.

#### 2. "Six domain groups" at orchestration.md line 318 is a factual error -- fix to "seven"

The delegation table in the-plan.md defines seven domain groups:

1. Protocol & Integration
2. Infrastructure & Data
3. Intelligence
4. Development & Quality
5. Security & Observability
6. Design & Documentation
7. Web Quality

The architecture.md Mermaid diagram (lines 54-91) shows the same seven subgraphs. The README already correctly states "23 minions across 7 domain groups" (lines 72, 78). Orchestration.md line 318 saying "six domain groups" is a pre-existing error that predates the current README rewrite -- it likely dates from before the Decision 20 agent expansion that added the Web Quality group.

**Recommended fix**: Change `all six domain groups` to `all seven domain groups` at orchestration.md line 318.

#### 3. Decision 12 consequences text is stale

Decision 12 in decisions.md (line 153) states: "6 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5)". This was true when ux-strategy-minion was an ALWAYS reviewer. After ux-strategy-minion moved to the discretionary pool, the mandatory reviewer count is 5. This is a MUST-fix item identified in the Phase 8 audit.

The fix should update the number while preserving the historical context of the expansion. Recommended: "5 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5; ux-strategy-minion moved to discretionary in v2.1)".

#### 4. Decision 10 choice text is stale

Decision 10 (line 128) states: "Six ALWAYS reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo)". This enumerates ux-strategy-minion as ALWAYS, which is no longer correct. The fix should update to: "Five ALWAYS reviewers (security-minion, test-minion, software-docs-minion, lucy, margo) and six discretionary reviewers (ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion)."

#### 5. Decision 15 consequences text is stale

Decision 15 (line 191) states: "6 ALWAYS + 0-4 conditional reviewers". The ALWAYS count should be 5, and the discretionary pool is now 6, not 4. Fix to: "5 ALWAYS + 0-6 discretionary reviewers".

#### 6. Cross-cutting checklist inclusion rule for ux-strategy-minion

Orchestration.md line 340 says `ALWAYS include` for Usability -- Strategy (ux-strategy-minion). This is the cross-cutting **planning** checklist, which is conceptually distinct from the Phase 3.5 **reviewer** table. The question is: does ux-strategy-minion's move to discretionary in Phase 3.5 also change its inclusion rule in the planning checklist?

If the planning checklist and reviewer roster are independent (which the architecture suggests -- the checklist governs META-PLAN/SYNTHESIS/PLAN, the reviewer table governs Phase 3.5), then `ALWAYS include` in the checklist may still be correct even though ux-strategy-minion is discretionary for review. However, this creates a subtle distinction that is likely to confuse readers. I flag this for the executing agent to verify against the-plan.md and resolve.

### Proposed Tasks

**Task 1: Fix "six domain groups" to "seven domain groups"**
- File: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md`
- Line: 318
- Change: `all six domain groups` -> `all seven domain groups`
- Classification: Factual error fix (MUST)

**Task 2: Add parenthetical clarification to "six dimensions" references**
- Files: orchestration.md (lines 20, 44), architecture.md (line 113)
- Changes as described in Recommendation 1 above
- Classification: Disambiguation (SHOULD)
- Note: Line 334 in orchestration.md needs no change (table follows immediately)

**Task 3: Fix stale reviewer counts in decisions.md**
- File: `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md`
- Lines: 128 (Decision 10), 153 (Decision 12), 191 (Decision 15)
- Changes as described in Recommendations 3-5 above
- Classification: Factual error fix (MUST)

**Task 4: Verify cross-cutting checklist vs. reviewer roster consistency**
- File: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md`
- Line: 340
- Verify whether ux-strategy-minion's `ALWAYS include` in the planning checklist should change after its move to discretionary in Phase 3.5
- Classification: Consistency check (SHOULD)

### Risks and Concerns

1. **Reader confusion between dimensions and reviewers will persist without the anchor clarification.** The six-dimensions concept and the five-mandatory-reviewers concept share a numeric neighborhood and appear on the same pages. Even with parenthetical clarification, some readers will conflate them. The anchor list on first mention (Recommendation 1, orchestration.md line 20) is the minimum viable disambiguation.

2. **Decision log entries are historical records.** Updating decisions.md reviewer counts is necessary because these entries are cited as the current rationale for the architecture, not just as historical snapshots. However, the edits should preserve the historical arc (what it was, what it changed to, and when). Adding a parenthetical noting the change date prevents readers from thinking the decision always said "five."

3. **The cross-cutting checklist `ALWAYS include` for ux-strategy-minion (orchestration.md line 340) may be intentionally different from the Phase 3.5 reviewer table.** Planning inclusion ("consider this dimension") is conceptually distinct from review assignment ("this agent reviews every plan"). If they are meant to differ, the text needs a clear explanation of why. If they are not meant to differ, the checklist needs updating. Either way, the current state is ambiguous.

4. **compaction-strategy.md references "six specialists" (lines 56, 123).** These refer to a hypothetical planning scenario (six specialists consulted in Phase 2), not to the reviewer count or dimension count. They are not stale and should not be changed, but the executing agent should be aware they exist and consciously leave them alone.

### Additional Agents Needed

- **software-docs-minion**: Should own the execution of all four tasks since these are architecture documentation files. user-docs-minion identified the issues from a readability and disambiguation perspective, but the files are contributor/architecture docs, not end-user docs.
- **lucy**: Should review the final edits to verify that the historical arc in decisions.md is preserved correctly and that the cross-cutting checklist vs. reviewer roster distinction (Risk 3) is resolved consistently with the-plan.md.
