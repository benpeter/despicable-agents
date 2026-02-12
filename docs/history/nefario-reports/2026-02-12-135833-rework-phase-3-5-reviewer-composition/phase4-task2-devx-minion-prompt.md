You are updating the nefario SKILL.md to implement the new Phase 3.5 reviewer
composition model with a user approval gate.

## What to Do

Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`.
Make these changes to the Phase 3.5 section (starts at line ~601):

### A. Replace "Identify Reviewers" section (lines ~606-621)

Replace the current section with:

```markdown
### Identify Reviewers

From the delegation plan, determine which reviewers to include:

**Mandatory** (always spawned, not user-adjustable):
- security-minion
- test-minion
- software-docs-minion (documentation impact checklist role -- see prompt below)
- lucy
- margo

**Discretionary** (selected by nefario, approved by user):

Evaluate each discretionary reviewer against the delegation plan. For each,
determine whether the plan produces artifacts in the reviewer's domain.

| Reviewer | Domain Signal |
|----------|--------------|
| ux-strategy-minion | Plan includes user-facing workflow changes, journey modifications, or cognitive load implications |
| ux-design-minion | Plan includes tasks producing UI components, visual layouts, or interaction patterns |
| accessibility-minion | Plan includes tasks producing web-facing HTML/UI that end users interact with |
| sitespeed-minion | Plan includes tasks producing web-facing runtime code (pages, APIs serving browsers, assets) |
| observability-minion | Plan includes 2+ tasks producing runtime components that need coordinated logging/metrics/tracing |
| user-docs-minion | Plan includes tasks whose output changes what end users see, do, or need to learn |

For each discretionary reviewer, decide yes/no with a one-line rationale
grounded in the specific plan content (reference task numbers or deliverables).

Examples of good rationales (plan-grounded, specific):
- "Task 3 adds CLI flags affecting user workflow" (references task + impact)
- "Tasks 1-2 produce React components with user interaction" (specific artifacts)

Examples of bad rationales (generic, not plan-grounded):
- "Might have UX implications" (vague, no task reference)
- "Good to have a review" (no domain signal match)
```

### B. Add "Reviewer Approval Gate" section (after Identify Reviewers, before Spawn Reviewers)

Insert a new section:

```markdown
### Reviewer Approval Gate

Present discretionary picks to the user for approval before spawning any
reviewers. If no discretionary reviewers were selected, auto-approve with a
CONDENSE note ("Reviewers: 5 mandatory, no additional reviewers needed") and
skip the gate.

**Presentation format** (target 6-10 lines):

~~~
REVIEWERS: <1-sentence plan summary>
Mandatory: security, test, software-docs, lucy, margo (always review)

  DISCRETIONARY (nefario recommends):
    <agent-name>       <rationale, max 60 chars, reference tasks>
    <agent-name>       <rationale, max 60 chars, reference tasks>

  NOT SELECTED from pool:
    <remaining pool members, comma-separated>

Full plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md
~~~

Format rules:
- Mandatory line: flat comma-separated, one line, presented as fact not choice.
  Use short names (security, test, software-docs, lucy, margo).
- DISCRETIONARY block: one agent per line with plan-grounded rationale. Rationale
  must reference specific plan content (task numbers, deliverables), not the
  reviewer's general capability. Max 60 characters per rationale.
- NOT SELECTED: flat comma-separated list of remaining discretionary pool members.
- No "ALSO AVAILABLE" block listing the full agent roster. The decision space is
  the 6-member discretionary pool only.

**AskUserQuestion**:
- `header`: "Review"
- `question`: "<1-sentence plan summary>"
- `options` (3, `multiSelect: false`):
  1. label: "Approve reviewers"
     description: "5 mandatory + N discretionary reviewers proceed to review."
     (recommended)
  2. label: "Adjust reviewers"
     description: "Add or remove discretionary reviewers before review begins."
  3. label: "Skip review"
     description: "Skip architecture review. The Execution Plan Approval Gate still applies."

**Response handling**:

**"Approve reviewers"**: Gate clears. Spawn mandatory + approved discretionary
reviewers.

**"Adjust reviewers"**: User provides freeform adjustment. Constrained to the
6-member discretionary pool. If the user requests an agent outside the pool,
note it is not a Phase 3.5 reviewer and offer the closest match from the pool.
Cap at 2 adjustment rounds, same as the Team Approval Gate. After adjustment,
spawn the final approved set.

**"Skip review"**: Skip Phase 3.5 entirely. Proceed directly to the Execution
Plan Approval Gate. No reviewers are spawned. The plan is presented as-is.
The execution plan gate still occurs -- the user still has a checkpoint before
code runs. Do NOT add friction or warnings to the skip path.
```

### C. Update "Spawn Reviewers" section (lines ~622-653)

Update the opening to say:

```markdown
### Spawn Reviewers

Spawn all approved reviewers in parallel (mandatory + user-approved discretionary).
Use opus for lucy and margo (governance reviewers requiring deeper reasoning);
use sonnet for all others:
```

The rest of the spawn section stays the same, EXCEPT add a special prompt
template for software-docs-minion. After the generic reviewer prompt template,
add:

```markdown
**software-docs-minion prompt** (replaces the generic reviewer prompt):

~~~
Task:
  subagent_type: software-docs-minion
  description: "Nefario: software-docs-minion review"
  model: sonnet
  prompt: |
    You are reviewing a delegation plan before execution begins.
    Your role: produce a documentation impact checklist for Phase 8.

    ## Delegation Plan
    Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md

    ## Your Review Focus
    Identify all documentation that needs creating or updating as a result
    of this plan. Do NOT write the documentation. Produce a checklist of
    what needs to change.

    ## Checklist Format
    Write the checklist to: $SCRATCH_DIR/{slug}/phase3.5-docs-checklist.md

    Use this format:

    ```markdown
    # Documentation Impact Checklist

    Source: Phase 3.5 architecture review
    Plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md

    ## Items

    - [ ] **[software-docs]** <what to update>
      Scope: <what specifically changes, one line>
      Files: <exact file path(s) affected>
      Priority: MUST | SHOULD | COULD

    - [ ] **[user-docs]** <what to update>
      Scope: <what specifically changes, one line>
      Files: <exact file path(s) affected>
      Priority: MUST | SHOULD | COULD
    ```

    Rules:
    - Owner tag: [software-docs] or [user-docs] to pre-route to Phase 8 agent
    - One line per item for the description
    - Scope: one line of intent, not a paragraph
    - Priority: MUST (required for correctness), SHOULD (improves completeness),
      COULD (nice to have)
    - Max 10 items. If you identify more than 10, the plan has documentation-heavy
      changes and the full analysis belongs in Phase 8.

    ## Verdict
    After writing the checklist, return your verdict:
    - APPROVE: Plan has adequate documentation coverage in its task prompts
    - ADVISE: Documentation gaps exist but are addressable in Phase 8
      (include the gaps as checklist items)
    - Do NOT use BLOCK for documentation concerns. Gaps are addressed through
      the checklist in Phase 8. Only BLOCK if the plan fundamentally cannot be
      documented (no clear deliverables, contradictory outputs, etc.) -- this
      should be extremely rare.

    Write your verdict to: $SCRATCH_DIR/{slug}/phase3.5-software-docs-minion.md

    Be concise. Focus on identifying WHAT needs documenting, not writing docs.
~~~
```

### D. Add phase3.5-docs-checklist.md to Scratch Directory Structure

Find the Scratch Directory Structure section in SKILL.md (should be around lines
227-252). Add this line in the appropriate position (after the phase3.5-* files):

```
  phase3.5-docs-checklist.md          # documentation impact checklist (Phase 8 input)
```

### E. No changes to Process Verdicts or Revision Loop sections

These sections remain unchanged. software-docs-minion's verdict file is still
read by the same verdict processing loop. The checklist is a secondary artifact
that only Phase 8 consumes.

## What NOT to Do

- Do NOT modify Phase 4 (Execution) or any post-execution phase except Phase 8
  (that is Task 3)
- Do NOT modify the compaction checkpoints
- Do NOT modify the Execution Plan Approval Gate
- Do NOT change the revision loop logic
- Do NOT modify Phase 1, 2, or 3 sections

## Context

- The Team Approval Gate from #48 (PR #51, already merged to main) establishes
  the pattern: AskUserQuestion with 3 options, freeform adjust constrained to
  a pool, 2-round adjustment cap. This gate reuses that pattern.
- The compaction checkpoint after Phase 3 happens BEFORE this gate. The
  compaction checkpoint after Phase 3.5 happens AFTER this gate and after
  verdict processing. Both remain unchanged.
- software-docs-minion produces TWO outputs: the checklist file (consumed by
  Phase 8) and the verdict file (consumed by the Phase 3.5 verdict loop).
  This is consistent -- the verdict loop reads the verdict file as it does
  for all reviewers; the checklist is an additional artifact.

## Deliverables

Updated `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` with:
1. New Identify Reviewers section (mandatory + discretionary)
2. New Reviewer Approval Gate section with AskUserQuestion spec
3. Updated Spawn Reviewers section
4. New software-docs-minion prompt template producing documentation impact checklist
5. Scratch Directory Structure updated with phase3.5-docs-checklist.md

## Success Criteria

- Mandatory reviewers list matches: security-minion, test-minion, software-docs-minion, lucy, margo
- Discretionary pool matches: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion
- Reviewer Approval Gate uses AskUserQuestion with header "Review" and 3 options
- "Skip review" skips Phase 3.5 entirely (no reviewers spawned)
- "Adjust reviewers" constrained to discretionary pool with 2-round cap
- Auto-skip gate when 0 discretionary reviewers selected
- software-docs-minion prompt produces checklist to phase3.5-docs-checklist.md
- software-docs-minion verdict is APPROVE or ADVISE (BLOCK only in extreme cases)
- Generic reviewer prompt template unchanged for all other reviewers
- Scratch Directory Structure includes phase3.5-docs-checklist.md

When you finish your task, mark it completed with TaskUpdate and send a message
to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
