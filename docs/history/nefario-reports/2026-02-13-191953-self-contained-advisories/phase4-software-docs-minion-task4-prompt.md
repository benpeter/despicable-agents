You are updating the execution report template to use the new
self-contained advisory format in the Agent Contributions section.

File: `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`

Read Task 1's deliverable first:
`/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md` (Verdict Format
section) to see the canonical format.

## What to Change

In the Agent Contributions section, under "Architecture Review" (around
line 113-117), update the ADVISE template line:

Replace:
```
**{agent-name}**: ADVISE. {Concern and recommendation.}
```

With:
```
**{agent-name}**: ADVISE. SCOPE: {artifact or concept}. CHANGE: {what was proposed}. WHY: {rationale}.
```

This aligns the report template with the canonical three-field advisory
format. The structured fields ensure report readers can evaluate advisories
without opening the reviewer's scratch file.

For multi-advisory verdicts (reviewer produced multiple warnings), each
advisory gets its own line:
```
**{agent-name}**: ADVISE.
- SCOPE: {artifact 1}. CHANGE: {proposal}. WHY: {reason}.
- SCOPE: {artifact 2}. CHANGE: {proposal}. WHY: {reason}.
```

## What NOT to Do

- Do not change the Phases narrative section (it uses prose, not structured blocks)
- Do not retroactively update existing reports in docs/history/nefario-reports/
- Do not change the skeleton structure or frontmatter
- Do not change the APPROVE or BLOCK template lines
- Do not change the Planning subsection format

## Deliverables

Updated `TEMPLATE.md` with structured ADVISE line format in Agent
Contributions section.

## Success Criteria

- ADVISE template line uses SCOPE/CHANGE/WHY fields
- Multi-advisory format documented
- APPROVE and BLOCK lines unchanged
- No changes outside Agent Contributions section

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
