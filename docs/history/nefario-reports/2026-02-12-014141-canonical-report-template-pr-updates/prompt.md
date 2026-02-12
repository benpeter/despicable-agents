**Outcome**: Every nefario execution report and PR description follows an identical section structure, and PR descriptions stay accurate when additional work lands on the same branch after the initial nefario run. Currently reports are inconsistent (no template exists — the LLM infers structure from hints), and PR bodies go stale when subsequent nefario runs or manual commits happen on the same branch.

**Success criteria**:
- SKILL.md contains an explicit report template with every section defined (name, order, content guidance, conditional inclusion rules)
- Canonical section order: frontmatter, Summary, Original Prompt, Key Design Decisions, Phases (narrative), Agent Contributions (planning + review tables), Execution (per-task with gates), Decisions (gate briefs with rationale/rejected), Conflict Resolutions, Verification, External Skills (conditional), Files Changed, Working Files (collapsed `<details>` with relative links), Test Plan (conditional), Post-Nefario Updates (conditional)
- The report doubles as the PR body — same content, no separate formatting step
- "Summary" replaces inconsistent naming ("Executive Summary" vs "Summary")
- ALL companion directory files linked from Working Files; ALL PR files linked from Files Changed
- Gates listed with decision, confidence level, and outcome
- When additional commits land on a branch that already has a nefario PR, the PR body gains a "Post-Nefario Updates" section summarizing what changed and why
- The update mechanism is low-friction: either nefario appends automatically on subsequent runs on the same branch, or the user is nudged to run a simple command that appends the update
- Existing reports are NOT modified (historical immutability)
- Phases section uses narrative style from PR #33
- All detected external skills reported in "External Skills" section

**Scope**:
- In: Report template in SKILL.md, wrap-up sequence, PR body generation, PR update mechanism for post-execution changes
- Out: Existing reports, AGENT.md changes, report index generation, companion directory structure, complex automation or hooks

**Constraints**:
- Reference examples: Test Plan (#19), Working Files (#18), Original Prompt (#18), Summary (#22 style), Verification/Conflicts/Execution/Agent Contributions (#30), Phases (#33), Key Design Decisions (#36)
- PR update mechanism must be simple — a skill or a nefario convention, not a git hook or CI pipeline
