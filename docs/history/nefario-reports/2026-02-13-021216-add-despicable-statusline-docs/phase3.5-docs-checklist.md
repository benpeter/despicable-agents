# Documentation Impact Checklist

Source: Phase 3.5 architecture review
Plan: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6Op9Al/add-despicable-statusline-docs/phase3-synthesis.md

## Items

- [ ] **[user-docs]** Restructure Status Line section in using-nefario.md
  Scope: Lead with automated `/despicable-statusline` skill, describe four user outcomes, preserve technical subsections, move manual JSON to fallback
  Files: /Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md (lines 166-198)
  Priority: MUST

- [ ] **[software-docs]** Add project-local skills subsection in deployment.md
  Scope: Document `/despicable-lab` and `/despicable-statusline` as project-local skills distinct from globally-installed skills
  Files: /Users/ben/github/benpeter/2despicable/3/docs/deployment.md (after line 110)
  Priority: MUST

- [ ] **[software-docs]** Cross-reference validation between using-nefario.md and deployment.md
  Scope: Verify cross-reference link from deployment.md to using-nefario.md Status Line section resolves correctly
  Files: /Users/ben/github/benpeter/2despicable/3/docs/deployment.md, /Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md
  Priority: SHOULD

- [ ] **[software-docs]** Verify SKILL.md remains authoritative source
  Scope: Confirm manual fallback documentation points to SKILL.md as authoritative source for command details
  Files: /Users/ben/github/benpeter/2despicable/3/.claude/skills/despicable-statusline/SKILL.md
  Priority: SHOULD
