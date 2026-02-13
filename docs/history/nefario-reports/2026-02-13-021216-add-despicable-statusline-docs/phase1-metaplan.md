# Phase 1: Meta-Plan

## Task Summary

Document the `/despicable-statusline` skill in project documentation so users understand what it does, what it modifies, the four config states it handles, and its safety properties -- without changing the skill itself.

## Meta-Plan

### Planning Consultations

#### Consultation 1: Documentation structure and placement

- **Agent**: software-docs-minion
- **Planning question**: Given the existing documentation structure (README.md, docs/architecture.md, docs/deployment.md, docs/using-nefario.md, docs/external-skills.md), where should the `/despicable-statusline` skill be documented? Should it get its own page in docs/, be added to an existing page (deployment.md already has a "Skills" section, using-nefario.md already has a "Status Line" section with manual setup instructions), or both? What level of detail is appropriate for each location? Note: using-nefario.md already documents a manual status line setup (lines 166-198) -- the new documentation should explain the skill as the automated alternative to that manual process.
- **Context to provide**: docs/architecture.md (Sub-Documents table), docs/deployment.md (Skills section), docs/using-nefario.md (Status Line section), README.md (Documentation section), .claude/skills/despicable-statusline/SKILL.md (full content)
- **Why this agent**: Documentation architecture expertise -- knows how to structure documentation for discoverability, avoid duplication, and maintain consistent cross-referencing patterns across a docs/ tree.

#### Consultation 2: User journey and discoverability

- **Agent**: user-docs-minion
- **Planning question**: A new user installing despicable-agents encounters the status line feature. How should we present the `/despicable-statusline` skill so they understand: (1) what it does at a glance, (2) when/why to use it, (3) what it modifies and the four config states (no statusLine, inline without nefario, already has nefario, non-standard/script file), (4) safety properties (backup, rollback, idempotency)? Should the documentation include a "before/after" example of settings.json, or is that too much detail for user-facing docs? How do we frame the relationship between the manual setup in using-nefario.md and the automated skill?
- **Context to provide**: .claude/skills/despicable-statusline/SKILL.md (full content), docs/using-nefario.md (Status Line section, lines 166-198)
- **Why this agent**: User documentation expertise -- knows how to explain developer tools at the right abstraction level, balancing completeness with readability for the target audience.

### Cross-Cutting Checklist

- **Testing**: EXCLUDE. This task produces only documentation (Markdown files). No executable output, no code, no configuration changes. Phase 6 test execution will still run if tests exist in the project, but test-minion has nothing to contribute to planning a documentation task.
- **Security**: EXCLUDE. No code changes, no auth surface, no user input handling, no new dependencies. The skill itself (which is out of scope) handles settings.json safely, but the documentation task does not introduce attack surface.
- **Usability -- Strategy**: EXCLUDE with justification. This is a documentation-only task for an existing skill. There are no user-facing workflow changes, journey modifications, or cognitive load implications to assess. The skill's UX was already designed; we are documenting it as-is. Including ux-strategy-minion would add overhead without material planning value for a docs task.
- **Usability -- Design**: EXCLUDE. No UI components, visual layouts, or interaction patterns are produced. Pure documentation.
- **Documentation**: INCLUDED via Consultations 1 and 2. software-docs-minion handles structural placement; user-docs-minion handles content quality and user-facing clarity.
- **Observability**: EXCLUDE. No runtime components, production services, or web-facing output. Pure documentation.

### Anticipated Approval Gates

None. This task is purely additive documentation with low blast radius and high reversibility. No downstream tasks depend on the documentation structure, and Markdown changes are trivially reversible via git. A gate would add interaction overhead without meaningful risk reduction.

### Rationale

This is a narrowly scoped documentation task. Two agents are consulted for planning:

1. **software-docs-minion** -- The project has an established docs/ tree with cross-references, a Sub-Documents table in architecture.md, and existing content in multiple locations that mention the status line or skills. Getting the structural placement right (avoid duplication, maintain cross-referencing patterns, decide between new page vs. additions to existing pages) requires documentation architecture expertise.

2. **user-docs-minion** -- The skill handles four config states and has safety properties (backup, rollback, idempotency) that need to be communicated clearly without overwhelming the reader. There is also a relationship between the existing manual setup instructions and the new automated skill that needs to be framed correctly. User documentation expertise ensures the content is pitched at the right level.

No other specialists are needed for planning. The task does not involve code, infrastructure, security, APIs, or UI -- only Markdown documentation for an existing, working skill.

### Scope

**In scope:**
- Document `/despicable-statusline` in project docs (README and/or docs/)
- Explain what the skill does, what it modifies (~/.claude/settings.json), the four config states
- Document idempotency and safety (backup/rollback)
- Integrate with existing documentation structure (cross-references, Sub-Documents table)
- Reconcile with existing manual status line documentation in using-nefario.md

**Out of scope:**
- Changes to the SKILL.md itself
- Changes to nefario's SKILL.md
- Statusline styling or behavior changes
- Changes to install.sh or deployment scripts

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | ORCHESTRATION | Agent build pipeline | Not relevant -- agent rebuilding has no bearing on documentation task |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line configuration | Subject of documentation, not an execution tool. Read for content reference during writing, not invoked. |

#### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the specialists assigned to this task (software-docs-minion, user-docs-minion). The despicable-statusline skill is the subject being documented, not a competing tool for the documentation work.
