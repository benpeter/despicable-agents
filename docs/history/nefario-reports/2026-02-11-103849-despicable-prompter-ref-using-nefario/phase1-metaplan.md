# Phase 1: Meta-Plan

## Task Summary

Add a reference to `/despicable-prompter` in `docs/using-nefario.md` near the "less helpful examples" section. The reference should explain what the skill does in one sentence and help users understand they can paste a vague idea to get a structured briefing back.

This is a small, targeted documentation edit: a few lines added to one file.

## Planning Consultations

### Consultation 1: Documentation placement and wording

- **Agent**: user-docs-minion
- **Planning question**: Given the structure of `docs/using-nefario.md` (lines 51-56 show "less helpful examples" with three vague prompts, followed by "What Happens: The Nine Phases"), where exactly should the `/despicable-prompter` reference go, and how should it be worded so it feels like a natural next step rather than an interruption? Should it be a standalone paragraph after the code block, a callout/tip, or integrated into the existing prose?
- **Context to provide**: Full contents of `docs/using-nefario.md` (101 lines), the SKILL.md for despicable-prompter (describes it as a "briefing coach" that transforms rough ideas into structured `/nefario` commands)
- **Why this agent**: user-docs-minion specializes in user-facing documentation flow, tone, and placement. The key challenge here is making the reference discoverable without disrupting the document's reading flow.

## Cross-Cutting Checklist

- **Testing**: Exclude. This task produces no executable output -- it is a prose edit to a markdown file.
- **Security**: Exclude. No attack surface, authentication, user input, secrets, or dependencies involved.
- **Usability -- Strategy**: Exclude with justification. This is a two-line documentation addition to an existing page. The user journey consideration (vague prompt -> discovery of prompter tool) is the entire task description itself. ux-strategy-minion's journey coherence and cognitive load expertise would not materially improve a plan for inserting a single cross-reference. The user-docs-minion consultation already covers placement and wording.
- **Usability -- Design**: Exclude. No user-facing interfaces are produced.
- **Documentation**: Include -- this IS the documentation task. user-docs-minion is the primary consultant (Consultation 1 above). software-docs-minion is excluded because this is user-facing guidance, not architecture or API surface documentation.
- **Observability**: Exclude. No runtime components, services, or APIs involved.

## Anticipated Approval Gates

None. This task is:
- **Easy to reverse**: It is an additive prose edit to a markdown file
- **Low blast radius**: No downstream tasks depend on this edit
- **No ambiguity**: The user specified exactly what to add and where

Per the gate classification matrix, this is a clear NO GATE case.

## Rationale

Only one specialist is consulted for planning: user-docs-minion. This task is a small, well-scoped documentation edit with a single file in scope and a clear desired outcome. The only planning question that would materially improve the result is about placement and wording within the existing document structure -- which is user-docs-minion's domain.

No other specialists have relevant planning input:
- The content to reference (`/despicable-prompter`) is already fully built and documented in its own SKILL.md
- The target file (`docs/using-nefario.md`) is user-facing prose, not architecture or API docs
- There is no code, infrastructure, security surface, or runtime component involved

## Scope

- **In**: `docs/using-nefario.md` -- add a reference to `/despicable-prompter` near the "less helpful examples" section (lines 51-56)
- **Out**: The despicable-prompter skill itself, other documentation files, README, any code changes
