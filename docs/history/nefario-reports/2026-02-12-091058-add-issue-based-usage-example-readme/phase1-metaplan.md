# Meta-Plan: Add Issue-Based Usage Example to README

## Task Analysis

Add a concrete `/nefario #<issue>` example to the README Examples section (lines 11-30 of `/Users/ben/github/benpeter/2despicable/3/README.md`) showing the issue-driven orchestration workflow. The change is additive: one new example block, existing examples untouched.

The task is **narrow scope**: a single Markdown file edit, no code, no architecture, no runtime components. The issue-driven workflow is already documented in `docs/using-nefario.md` (lines 60-83) and implemented in both `/nefario` and `/despicable-prompter` skills. The README just needs to surface this capability in the Examples section.

## Planning Consultations

### Consultation 1: Example Messaging and Positioning
- **Agent**: product-marketing-minion
- **Planning question**: Given the existing README examples (specialist invocations and a multi-domain `/nefario` task), what is the most compelling way to position the issue-driven workflow? Should the example emphasize the GitHub integration angle ("point it at an issue"), the automation angle ("issue in, PR out"), or the workflow angle ("full 9-phase orchestration from a single command")? What comment line best conveys the value proposition in under 15 words?
- **Context to provide**: README.md lines 11-30 (existing Examples section), `docs/using-nefario.md` lines 60-83 (issue integration docs), the `/nefario` skill argument-hint (`#<issue> | <task description>`)
- **Why this agent**: product-marketing-minion specializes in feature messaging and value propositions. The example's comment line is effectively a one-line pitch -- getting the framing right matters for new users scanning the README.

## Cross-Cutting Checklist

- **Testing**: EXCLUDE. No code produced, no executable output. This is a Markdown text addition.
- **Security**: EXCLUDE. No attack surface, no auth, no user input handling. A documentation edit.
- **Usability -- Strategy**: EXCLUDE for planning. The task is adding a single example to an existing section with an established pattern. The structure and placement are already determined by the existing Examples section format. ux-strategy-minion would have nothing material to contribute to planning a three-line Markdown addition.
- **Usability -- Design**: EXCLUDE. No user-facing interface produced.
- **Documentation**: EXCLUDE for planning consultation. This IS the documentation task -- the user-docs-minion's expertise is in structuring tutorials and help content, but the README Examples section already has an established format (command + comment) that the new example will follow. No structural decisions to make.
- **Observability**: EXCLUDE. No runtime components.

**Justification for minimal consultation**: This task has a single deliverable (3-5 lines of Markdown), a fixed location (README Examples section), an established format to follow (the existing examples), and clear success criteria. The only genuine planning question is about messaging -- which angle best serves new users scanning the README. One specialist covers that.

## Anticipated Approval Gates

**None.** This task scores LOW on both dimensions of the gate classification matrix:
- **Reversibility**: Trivially reversible (additive Markdown edit)
- **Blast radius**: Zero downstream dependents

No approval gate is warranted.

## Rationale

Only product-marketing-minion is consulted because the sole planning decision is messaging: how to frame the issue-driven workflow in a one-line comment that maximizes comprehension for new users. All other aspects are predetermined:
- **Location**: README Examples section (specified in task scope)
- **Format**: Command + comment line (matches existing examples)
- **Content**: `/nefario #<issue>` invocation (specified in task outcome)
- **Constraint**: 1-2 sentences (specified in success criteria)

Involving additional specialists for planning would be over-engineering the planning of a Markdown edit.

## Scope

- **In**: README.md Examples section -- add one `/nefario #<issue>` example with comment
- **Out**: All other README sections, docs/ files, skill definitions, code changes

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent rebuilding | Not relevant -- no agents being rebuilt |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line config | Not relevant -- no status line work |
| despicable-prompter | `skills/despicable-prompter/` | LEAF | Task briefing | Not relevant -- no briefing generation needed |
| nefario | `skills/nefario/` | ORCHESTRATION | Multi-agent orchestration | Not relevant -- this is the orchestrator itself, not a task target |

### Precedence Decisions

No precedence conflicts. None of the discovered skills overlap with this documentation task.
