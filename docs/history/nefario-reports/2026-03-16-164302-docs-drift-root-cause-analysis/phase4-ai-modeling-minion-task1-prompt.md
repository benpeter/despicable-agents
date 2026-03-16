You are modifying the Phase 8 documentation section of the nefario orchestration
skill to fix a structural weakness: the checklist generation step was being skipped
whenever Phase 8 execution was skipped, leaving documentation debt invisible.

## Target file
`/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

## Changes required

### Change 1: Split Phase 8 into Assessment (always) and Execution (skippable)

Read the current Phase 8 section carefully. The section starts with "#### Phase 8: Documentation (Conditional)" header.

Restructure Phase 8 into two sub-phases:

**Phase 8a: Documentation Assessment (ALWAYS runs)**
- Runs regardless of --skip-docs, "Skip docs only", or "Skip all post-exec"
- Evaluates execution outcomes against the outcome-action table
- For each matching outcome, identifies target documentation files
- For any item claimed as "already addressed in Phase 4": requires citing
  the specific file path and section that addresses it. Items without
  evidence stay on the checklist as UNVERIFIED.
- Writes checklist to `$SCRATCH_DIR/{slug}/phase8-checklist.md`
- If checklist is empty: records "Phase 8 assessment: 0 items identified"
- If checklist is non-empty AND Phase 8 execution was skipped: records items
  as documentation debt (see Change 3)

**Phase 8b: Documentation Execution (skippable)**
- This is the current sub-step 8a (spawn doc agents) and sub-step 8b (marketing lens)
- Skipped when user selects --skip-docs or equivalent
- Skipped when Phase 8a checklist is empty
- Renumber: current "Sub-step 8a" becomes "Phase 8b step 1", current
  "Sub-step 8b" becomes "Phase 8b step 2"

### Change 2: Update the Phase 8 header
Change "Phase 8: Documentation (Conditional)" to reflect the new structure.
Something like: "Phase 8: Documentation (8a: always, 8b: conditional)"

### Change 3: Ban "handled inline" as a skip justification

Add an explicit rule after the Phase 8 header:

"Documentation handled during Phase 4 execution does not exempt Phase 8a
assessment. The assessment evaluates ALL execution outcomes, including those
claimed as already addressed. Phase 4 documentation tasks are verified, not
trusted — the checklist confirms coverage rather than assuming it."

### Change 4: Record documentation debt when skipped

When Phase 8a produces a non-empty checklist but Phase 8b execution is skipped:
- Print a CONDENSE line showing only MUST-priority deferred items:
  "Doc debt: N MUST items deferred (item1, item2, ...)" 
  Only show MUST-priority items in the CONDENSE line to avoid cry-wolf fatigue.
  If no MUST items, show total count only: "Doc debt: N items deferred (0 MUST)"
- Include the deferred items in the wrap-up verification summary
- The execution report records these items in a Documentation Debt section

### Change 5: Update skip handling section

Find the section that handles --skip-docs, "Skip docs only", "Skip all post-exec" behavior.
Currently Phase 8 is skipped entirely. Update to clarify:
- --skip-docs = skip Phase 8b (execution). Phase 8a (assessment) always runs.
- "Skip docs only" = same as --skip-docs
- "Skip all post-exec" = skip Phases 5, 6, and 8b. Phase 8a still runs.
- Add: "Phase 8a (assessment) is non-skippable. It runs even when all
  post-execution phases are skipped, producing the documentation checklist
  for debt tracking."

### Change 6: Update the CONDENSE status line

Find where the post-exec CONDENSE line is built. Update:
- When docs are skipped but assessment runs: include "doc assessment" in the list
  e.g., `Verifying: code review, tests, doc assessment...`
- When all post-exec are skipped: `Assessing: documentation...` (Phase 8a still runs)
- The only case where no status line at all: when there are literally zero execution
  outcomes (nothing happened in Phase 4). This should not occur in normal orchestrations.

## What NOT to change

- Do NOT modify the outcome-action table content (rows) — that is Task 2
- Do NOT add diff-based scanning or baseline comparison
- Do NOT add a persistent debt ledger file
- Do NOT modify Phase 5 scope
- Do NOT change the post-exec gate options (the options stay the same;
  what changes is what "Skip docs" means internally)
- Do NOT modify the sub-step 8a/8b agent prompts or marketing tier logic
  (just renumber them to Phase 8b step 1 and Phase 8b step 2)
- Preserve all existing SKILL.md comments (<!-- INFRASTRUCTURE: ... -->,
  <!-- DOMAIN-SPECIFIC: ... -->)

## Deliverables

Modified SKILL.md with:
1. Restructured Phase 8 section (8a always-run assessment, 8b skippable execution)
2. Updated Phase 8 header
3. "Handled inline" ban rule
4. Debt recording mechanism
5. Updated skip handling
6. Updated CONDENSE status lines

When you finish, report: file paths with change scope and line counts.
