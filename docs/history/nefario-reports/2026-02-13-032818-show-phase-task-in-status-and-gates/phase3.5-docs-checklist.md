# Documentation Impact Checklist

Source: Phase 3.5 architecture review
Plan: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase3-synthesis.md

## Items

- [ ] **[user-docs]** Update using-nefario.md to reflect phase-aware status line and gates
  Scope: Three targeted edits to describe phase visibility in status line and gates
  Files: docs/using-nefario.md
  Priority: MUST (already handled in Task 2)

- [ ] **[software-docs]** Document phase prefix format constraint in nefario SKILL.md
  Scope: Add inline comment documenting 12-character AskUserQuestion header limit
  Files: skills/nefario/SKILL.md
  Priority: MUST (already handled in Task 1, section D)

- [ ] **[software-docs]** Update CHANGELOG or release notes for nefario skill version increment
  Scope: Document status line format change (breaking for tooling that parses status file) and gate header changes
  Files: skills/nefario/CHANGELOG.md or docs/CHANGELOG.md
  Priority: SHOULD

- [ ] **[software-docs]** Update architecture docs if they reference status line format
  Scope: Check docs/architecture.md or related files for hardcoded status format examples
  Files: docs/architecture.md, docs/nefario-orchestration.md
  Priority: SHOULD

- [ ] **[software-docs]** Add ADR for status file format change and gate header convention
  Scope: Document decision to use P<N> prefix notation, dual-channel orientation model, tradeoffs (character limits, shortened task summary)
  Files: docs/adr/NNNN-phase-context-status-gates.md (new)
  Priority: COULD
