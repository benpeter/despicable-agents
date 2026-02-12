# Documentation Impact Checklist

Source: Phase 3.5 architecture review
Plan: phase3-synthesis.md

## Items

- [ ] **[software-docs]** Update Team Approval Gate section in orchestration.md to mention minor/substantial branching
  Scope: Add 1-2 sentences about adjustment classification and re-run behavior to the existing "Adjust team" description
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` (line 386)
  Priority: MUST

- [ ] **[software-docs]** Update Reviewer Approval Gate description in orchestration.md for substantial change re-evaluation
  Scope: Add brief note about substantial reviewer adjustments triggering re-evaluation against the plan
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` (line 78)
  Priority: MUST

- [ ] **[software-docs]** Evaluate Mermaid sequence diagram for re-run loop-back annotation
  Scope: Decide whether the existing Adjust arrow sufficiently represents the re-run or if a minimal annotation is needed
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` (lines 173-304)
  Priority: SHOULD

- [ ] **[software-docs]** Verify orchestration.md and SKILL.md consistency on cap semantics
  Scope: Ensure orchestration.md does not contradict SKILL.md on round-counting (re-run = same round) and re-run cap (1 per gate)
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md`, `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`
  Priority: MUST

- [ ] **[user-docs]** Update Phase 1 description in using-nefario.md to mention re-run on large team changes
  Scope: Extend the "adjust it" clause in the Phase 1 paragraph to note that large changes trigger a planning refresh
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` (line 102)
  Priority: SHOULD

- [ ] **[user-docs]** Update Phase 3.5 description in using-nefario.md to mention reviewer adjustment re-evaluation
  Scope: Currently Phase 3.5 paragraph does not mention adjustment at all; add one clause about reviewer adjustments
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` (line 108)
  Priority: COULD
