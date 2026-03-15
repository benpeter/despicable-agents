# Meta-Plan: Fix Post-Exec Gate UX

## Planning Consultations

#### Consultation 1: Post-exec gate option design
- **Agent**: ux-strategy-minion
- **Planning question**: The current post-exec gate uses a multiSelect pattern where the happy path (run all phases) means selecting nothing, which triggers a Claude Code "unanswered question" warning. We want to replace this with a single-select pattern where explicit named options cover the common combinations. What should the option list look like? Consider: (1) which skip combinations are actually useful vs. combinatorial noise, (2) how to label "run all" as the obvious default, (3) ordering by frequency of use, (4) keeping the list short enough to scan instantly. The options must work within AskUserQuestion single-select constraints.
- **Context to provide**: Current SKILL.md lines 1627-1648 (the existing multiSelect block), the issue constraints (multiSelect: false, freeform flags still work), and examples of other AskUserQuestion single-select patterns in the same file (e.g., lines 515-519 for team approval)
- **Why this agent**: UX-strategy specializes in cognitive load reduction and making the happy path obvious. The core problem is a UX anti-pattern -- this is their domain.

### Cross-Cutting Checklist
- **Testing**: No -- this is a prompt/skill file change with no executable output. The success criteria are behavioral (UX flow), not testable via automated tests.
- **Security**: No -- no attack surface, auth, user input processing, or dependency changes.
- **Usability -- Strategy**: ALWAYS include -- covered as Consultation 1 above.
- **Usability -- Design**: No -- no visual UI components; this is a CLI prompt interaction pattern.
- **Documentation**: No -- SKILL.md is the documentation. The change is self-documenting within the file. No user-facing docs reference this internal gate mechanism.
- **Observability**: No -- no runtime components.

### Anticipated Approval Gates
None. This is a single-file, easily reversible change to SKILL.md with no downstream dependents. The diff will be small and reviewable inline.

### Rationale
This task is narrowly scoped: one AskUserQuestion block in SKILL.md needs to change from multiSelect to single-select with explicit options. The only planning question that benefits from specialist input is what the option list should look like -- that is a UX-strategy question about cognitive load and happy-path design. The implementation itself (editing the SKILL.md text) is straightforward prompt engineering that ai-modeling-minion can handle in execution, but the option design benefits from ux-strategy input during planning.

Only one planning consultation is needed because:
- The file to change is identified (SKILL.md lines 1627-1648)
- The technical approach is specified (multiSelect: false)
- The constraints are clear (freeform flags preserved, no other files touched)
- The only open question is the option set design

### Scope
- **In scope**: SKILL.md post-exec AskUserQuestion block (lines ~1627-1648), option definitions, question text
- **Out of scope**: Phase 4 approval gate structure, other AskUserQuestion instances, nefario AGENT.md, any other files

### External Skill Integration
No external skills detected relevant to this task.
