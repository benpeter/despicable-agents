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
- Do NOT rewrite table cells in Decisions 10, 12, or 20

### Addendum format rules

- Blockquotes go BELOW the decision's table, BEFORE the next `###` or `---` heading
- Use `> **Update (2026-02-12):**` prefix (the date the rework happened, not today)
- Link to the nefario report using a relative path from decisions.md:
  `history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md`
- Do NOT put addenda inside table cells

### Verification

After editing, confirm:
1. Decision 15 says "5 ALWAYS + 0-6 discretionary" and references "Decision 27" instead of "AGENT.overrides.md"
2. orchestration.md line 318 area says "seven domain groups"
3. orchestration.md line 20 area includes the dimension enumeration
4. architecture.md line 113 area says "six cross-cutting dimensions"
5. Decisions 10, 12, 20 have blockquote addenda below their tables
