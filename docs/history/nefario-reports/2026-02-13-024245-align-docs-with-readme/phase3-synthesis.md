# Phase 3: Synthesis -- Align docs/ with Progressive-Disclosure README

## Delegation Plan

**Team name**: align-docs-with-readme
**Description**: Fix stale reviewer counts and add disambiguation clarifications across decisions.md, orchestration.md, and architecture.md after ux-strategy-minion moved from ALWAYS to discretionary in Phase 3.5.

### Task 1: Align docs/ files with Phase 3.5 reviewer composition rework

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |

    ## Task: Align docs/ files with Phase 3.5 reviewer composition rework

    You are editing three architecture documentation files to fix stale reviewer
    counts and add disambiguation clarifications. The Phase 3.5 reviewer composition
    was reworked on 2026-02-12 -- ux-strategy-minion moved from mandatory (ALWAYS)
    to the discretionary reviewer pool. Four MUST findings and two SHOULD findings
    need addressing.

    ### Files in scope

    - `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md`
    - `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md`
    - `/Users/ben/github/benpeter/2despicable/2/docs/architecture.md`

    ### MUST Fixes (4 items)

    **M1. Decision 10 (decisions.md ~line 128)**: The Choice field states
    "Six ALWAYS reviewers (security-minion, test-minion, ux-strategy-minion,
    software-docs-minion, lucy, margo) and four conditional reviewers..."

    This is a historical ADR entry. Do NOT rewrite the original text. Add a
    blockquote addendum BELOW the table (after the table's closing row, before
    the next `###` heading), using this format:

    ```markdown
    > **Update (2026-02-12)**: ALWAYS reviewer count reduced from 6 to 5.
    > ux-strategy-minion moved to discretionary pool (Phase 3.5 reviewer
    > composition rework, [report](history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md)).
    > Discretionary pool expanded from 4 to 6 members.
    ```

    **M2. Decision 12 (decisions.md ~line 153)**: The Consequences field states
    "6 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5)".

    Same treatment -- blockquote addendum below the table:

    ```markdown
    > **Update (2026-02-12)**: ALWAYS reviewer count subsequently reduced
    > from 6 to 5 when ux-strategy-minion moved to discretionary pool
    > ([report](history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md)).
    ```

    **M3. Decision 15 (decisions.md ~line 191)**: The Consequences field states
    "Every `/nefario` run incurs review cost (6 ALWAYS + 0-4 conditional
    reviewers)." and "Constraint encoded in AGENT.overrides.md and AGENT.md."

    Decision 15 describes CURRENT runtime behavior, not a historical snapshot.
    Update the Consequences field DIRECTLY (not an addendum):

    - Change `(6 ALWAYS + 0-4 conditional reviewers)` to
      `(5 ALWAYS + 0-6 discretionary reviewers)`
    - Change `Constraint encoded in AGENT.overrides.md and AGENT.md.` to
      `Constraint encoded in AGENT.md (overlay mechanism removed per Decision 27).`

    **M4. Decision 20 (decisions.md ~line 262)**: The Consequences field states
    "Phase 3.5 minimum review cost increases (6 ALWAYS reviewers)".

    Blockquote addendum below the table:

    ```markdown
    > **Update (2026-02-12)**: ALWAYS reviewer count subsequently reduced
    > from 6 to 5 when ux-strategy-minion moved to discretionary pool
    > ([report](history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md)).
    ```

    ### SHOULD Fixes (2 items)

    **S1. "Six dimensions" disambiguation**: The phrase "six dimensions" (referring
    to the cross-cutting planning checklist) appears near text about "five mandatory
    reviewers" (the Phase 3.5 roster), creating potential reader confusion.

    Add a parenthetical anchor on the FIRST substantive mention in each file to
    anchor the concept. Subsequent mentions in the same file need no change:

    - **orchestration.md line 20**: Change `all six dimensions assessed` to
      `all six dimensions assessed -- Testing, Security, Usability-Strategy,
      Usability-Design, Documentation, Observability`

    - **orchestration.md line 44**: Change `the six cross-cutting dimensions`
      to `the six cross-cutting dimensions (see table below)`

    - **orchestration.md line 334**: No change. The table immediately follows
      and serves as its own clarification.

    - **architecture.md line 113**: Change `mandates considering six dimensions`
      to `mandates considering six cross-cutting dimensions`

    **S2. "Six domain groups" factual error (orchestration.md line 318)**:
    The delegation table covers SEVEN domain groups (Protocol & Integration,
    Infrastructure & Data, Intelligence, Development & Quality, Security &
    Observability, Design & Documentation, Web Quality). This is a pre-existing
    error from before the Decision 20 expansion that added the Web Quality group.

    Change `all six domain groups` to `all seven domain groups`.

    ### Critical distinctions -- do NOT confuse these

    1. **Cross-cutting planning checklist (Phase 2)**: Six dimensions. ux-strategy-minion
       is "ALWAYS include" in this checklist. This is CORRECT per the-plan.md and
       should NOT be changed. The checklist governs which agents to CONSIDER during
       planning, not who reviews in Phase 3.5.

    2. **Phase 3.5 reviewer roster**: Five mandatory + six discretionary. ux-strategy-minion
       is discretionary here. The orchestration.md tables at lines 59-76 already
       reflect this correctly -- do not modify them.

    3. **Historical ADR entries**: Decisions 10, 12, 20 are historical records. Do NOT
       rewrite their original text. Use blockquote addenda below the table only.
       Decision 15 is the exception because it describes current behavior.

    ### What NOT to do

    - Do NOT modify orchestration.md lines 57-76 (Phase 3.5 reviewer tables) -- they are already correct
    - Do NOT change the cross-cutting checklist table (orchestration.md lines 336-343) -- "ALWAYS include" for ux-strategy-minion is correct per the-plan.md
    - Do NOT modify any file outside the three listed above
    - Do NOT create Decision 30 -- out of scope (YAGNI)
    - Do NOT do bulk terminology replacement of "ALWAYS"/"conditional" to "mandatory"/"discretionary" in historical ADR text
    - Do NOT modify lines in compaction-strategy.md that mention "six specialists" -- those refer to planning scenarios, not reviewer counts
    - Do NOT rewrite table cells in Decisions 10, 12, or 20

    ### Addendum format rules

    - Blockquotes go BELOW the decision's table, BEFORE the next `###` or `---` heading
    - Use `> **Update (2026-02-12):**` prefix (the date the rework happened, not today)
    - Link to the nefario report using a relative path from decisions.md:
      `history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md`
    - Do NOT put addenda inside table cells

    ### Verification

    After editing, confirm:
    1. `grep -c "6 ALWAYS" docs/decisions.md` returns 0 hits in non-blockquote lines
       (the original "6 ALWAYS" text remains inside table cells for Decisions 10, 12,
       20 -- that is correct since those are historical. But Decision 15 should no
       longer say "6 ALWAYS".)
    2. Decision 15 says "5 ALWAYS + 0-6 discretionary" and references "Decision 27"
       instead of "AGENT.overrides.md"
    3. orchestration.md line 318 says "seven domain groups"
    4. orchestration.md line 20 includes the dimension enumeration
    5. architecture.md line 113 says "six cross-cutting dimensions"

- **Deliverables**: Updated `decisions.md`, `orchestration.md`, `architecture.md`
- **Success criteria**: All four MUST findings resolved with correct addendum format. Both SHOULD findings addressed. No unintended changes to correct text (reviewer tables, cross-cutting checklist). Historical ADR entries preserved with addenda, not rewritten (except Decision 15).

### Cross-Cutting Coverage

- **Testing**: Not applicable -- documentation-only edits with no executable output.
- **Security**: Not applicable -- no attack surface, auth, user input, secrets, or dependency changes.
- **Usability -- Strategy**: Not applicable -- no user-facing workflow changes. These are contributor/architecture docs.
- **Usability -- Design**: Not applicable -- no UI components produced.
- **Documentation**: This task IS documentation. software-docs-minion is the executing agent.
- **Observability**: Not applicable -- no runtime components.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**: none -- no user-facing workflow changes, no UI, no web-facing runtime, no runtime components, no end-user documentation changes
- **Not selected**: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

**1. ADR modification approach (software-docs-minion vs. product-marketing-minion)**

software-docs-minion recommended blockquote addenda below tables for historical decisions. product-marketing-minion recommended inline parenthetical notes within consequence text (e.g., "(subsequently reduced to 5...)"). user-docs-minion recommended direct updates to consequence text with parenthetical change notes.

**Resolution**: Blockquote addenda below tables (software-docs-minion's approach). Rationale: addenda are visually distinct from the original record, do not break table cell formatting, and follow the established ADR convention (analogous to Decision 14's Note referencing Decision 25). Inline parentheticals within table cells would create inconsistent cell lengths and mix historical text with corrections.

**Exception**: Decision 15 gets a direct update per software-docs-minion's recommendation -- its Consequences field describes current behavior, not a historical snapshot. All three specialists agreed Decision 15 needs direct correction, not an addendum.

**2. Cross-cutting checklist ux-strategy-minion status (all three specialists flagged)**

product-marketing-minion recommended changing orchestration.md line 340 from "ALWAYS include" to conditional language. user-docs-minion flagged it for verification. software-docs-minion correctly identified it as referring to the planning checklist, not Phase 3.5.

**Resolution**: No change. The-plan.md (source of truth, line 421) confirms ux-strategy-minion is "ALWAYS include" in the cross-cutting planning checklist. This is conceptually distinct from the Phase 3.5 reviewer roster. The S1 disambiguation fix (anchoring "six dimensions" with an enumerated list) addresses the confusion risk without incorrectly modifying the checklist.

**3. Terminology drift (product-marketing-minion)**

product-marketing-minion identified systematic "ALWAYS"/"conditional" vs "mandatory"/"discretionary" vocabulary differences between docs/ and README. Recommended targeted fixes where factually wrong but NOT bulk replacement in historical ADR text.

**Resolution**: Adopted. No bulk terminology replacement. Historical ADR text preserves the vocabulary used at decision time. Only factually wrong counts are corrected (via addenda or direct update for Decision 15). Non-historical prose (orchestration.md section headings at lines 57/67) already uses the correct terms from the Phase 3.5 rework.

### Risks and Mitigations

1. **Over-correction of cross-cutting checklist**: The executing agent might confuse the planning checklist "ALWAYS include" with the Phase 3.5 "mandatory/discretionary" distinction and incorrectly change line 340. Mitigated by explicit "do NOT change" instruction in the prompt and a verification step.

2. **Addendum link breakage**: The relative link path from decisions.md to the nefario report must be correct. The path `history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md` is relative to docs/ (since decisions.md is at `docs/decisions.md`). Mitigated by providing the exact link path in the prompt.

3. **Decision 15 AGENT.overrides.md reference**: The secondary fix (changing the stale AGENT.overrides.md reference to cite Decision 27) was identified by software-docs-minion. This is a pre-existing inconsistency in the same Consequences field being edited. Fixing it in the same edit avoids touching the line twice. Included in the task scope.

### Execution Order

Single task, no dependencies, no gates. Execute directly.

```
Batch 1: Task 1 (software-docs-minion)
```

### Verification Steps

1. All four MUST findings resolved (stale counts in Decisions 10, 12, 15, 20)
2. Both SHOULD findings addressed (dimension disambiguation, domain group count)
3. No changes to correct text (Phase 3.5 reviewer tables, cross-cutting checklist table)
4. Historical ADR entries use blockquote addenda, not rewrites (except Decision 15)
5. Relative links in addenda resolve correctly
6. Decision 15 references Decision 27 instead of AGENT.overrides.md
