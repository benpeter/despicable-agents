# Meta-Plan: Include Orchestration Run Title in All Gates

## Planning Consultations

### Consultation 1: Developer Experience of Gate Prompts

- **Agent**: devx-minion
- **Planning question**: The `question` field in AskUserQuestion gates needs to include the orchestration run title (`$summary`, max 40 chars) so users running parallel nefario sessions can identify which run they are deciding on. There are 12 gate instances across SKILL.md with varying current `question` formats (some have partial context, some have none -- the post-exec gate is the worst with just "Post-execution phases for this task?"). What is the best convention for consistently embedding a run identifier into `question` strings without making them unwieldy? Should it be a prefix pattern (e.g., `[slug] <question>`) or a suffix? How do we keep the question scannable when some are already long (e.g., the P4 Gate includes "Task N: <task title> -- DECISION")? Consider the 12-char `header` cap and that `question` has no documented length limit but is rendered in a terminal prompt.
- **Context to provide**: Full list of 12 gates from the issue audit table, current `question` values for each (from SKILL.md lines 507, 981, 1181, 1309, 1462, 1477, 1541, 1650, 1679, 1869, 2061), the `$summary` variable (40-char truncated task description established in Phase 1 line 389-391).
- **Why this agent**: devx-minion specializes in CLI design, developer onboarding, error messages, and configuration UX. Gate prompts are a CLI interaction pattern -- they need to be scannable, informative, and not noisy. devx-minion can define a convention that works across all 12 gates.

### Consultation 2: UX Strategy for Multi-Session Context

- **Agent**: ux-strategy-minion
- **Planning question**: When a user runs parallel nefario orchestrations in multiple terminals, they lose context at every gate prompt (AskUserQuestion hides the status line). The run title is the primary disambiguator. From a cognitive load perspective: (1) Is the `$summary` (40-char task description) the right identifier, or should we use the `slug` (shorter, kebab-case) or both? (2) The post-exec gate currently says "Post-execution phases for this task?" with zero referent -- it needs both run-level AND task-level context. What information hierarchy makes this scannable? (3) Some gates (P5 Security, P5 Issue) present domain findings -- should the run title compete with the finding description in `question`, or is there a layering approach?
- **Context to provide**: The 12-gate audit table from the issue, the fact that `header` is capped at 12 chars, `$summary` is 40 chars max, `slug` is max 40 chars kebab-case. The status line format is `"P<N> <Phase> | $summary"`.
- **Why this agent**: ux-strategy-minion evaluates cognitive load, user journey coherence, and information hierarchy. The core tension here is adding context without creating noise -- that is a UX strategy question.

## Cross-Cutting Checklist

- **Testing**: Not needed for planning. This is a single-file documentation/specification change (SKILL.md). No executable code is produced. test-minion will participate in Phase 3.5 review as mandatory reviewer.
- **Security**: Not needed for planning. No auth, API, user input, or infrastructure changes. security-minion will participate in Phase 3.5 review as mandatory reviewer.
- **Usability -- Strategy**: INCLUDED as Consultation 2 (ux-strategy-minion). Planning question: How to embed run context in gate prompts without increasing cognitive load, especially for multi-session scenarios.
- **Usability -- Design**: Not needed for planning. No visual UI components are produced -- gates are terminal text prompts, which fall under devx-minion's CLI design domain and ux-strategy-minion's cognitive load assessment.
- **Documentation**: Not needed for planning consultation. The change IS to the skill documentation itself (SKILL.md). No separate docs artifact is needed -- the deliverable is the updated SKILL.md. software-docs-minion and user-docs-minion will review in Phase 3.5 / Phase 8 if warranted.
- **Observability**: Not needed. No runtime components, no logging/metrics changes.

## Anticipated Approval Gates

**Zero execution gates anticipated.** This task modifies a single file (`skills/nefario/SKILL.md`) with consistent textual changes to 12 gate definitions. The changes are:
- Low blast radius (self-contained in one file, no downstream code consumers)
- Easy to reverse (text changes only)
- Low ambiguity (the issue specifies exactly what to do for each gate)

Per the gate classification matrix, this falls in the "NO GATE" quadrant. The only potential gate is if devx-minion and ux-strategy-minion disagree on the convention (prefix vs. suffix, slug vs. summary), which would be resolved in synthesis.

## Rationale

This task is a **specification consistency fix** -- 12 instances of the same pattern (AskUserQuestion gate) need a consistent run-title convention applied. The two planning consultations target the two judgment calls:

1. **devx-minion**: What convention? (the "how" -- prefix format, delimiter, truncation rules for already-long question strings)
2. **ux-strategy-minion**: What information? (the "what" -- summary vs. slug vs. both, layering for gates that already carry domain content)

Other agents are not needed for planning because:
- There is no code to write (just SKILL.md text edits)
- There is no architecture to review (no new components, data flows, or integration points)
- The security, testing, and documentation cross-cutting concerns are handled by Phase 3.5 mandatory reviewers

Two specialists is lean for this scope. The risk of under-consultation is low because the task is well-scoped with a clear problem statement and enumerated instances.

## Scope

**In scope**:
- Define a convention for including the orchestration run title in AskUserQuestion `question` fields
- Apply it to all 12 gates in `skills/nefario/SKILL.md`
- Fix the post-exec gate specifically to include both run-level and task-level context
- Ensure the convention works when the status line is hidden (the core UX problem)

**Out of scope**:
- Changes to `the-plan.md` (this is SKILL.md only)
- Changes to AskUserQuestion infrastructure or the `header` field cap
- Changes to the status line itself
- Changes to the CONDENSE/compaction system
- Any agent AGENT.md files

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent rebuilding from the-plan.md specs | Not relevant -- no agent AGENT.md files are modified |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line configuration | Not relevant -- we are not changing status line config, only gate prompts |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain (SKILL.md gate prompt editing).
