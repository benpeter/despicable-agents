# Meta-Plan: Rewrite README to Showcase Value

## Planning Consultations

### Consultation 1: Product Positioning and Feature Messaging

- **Agent**: product-marketing-minion
- **Planning question**: Given the current README at `/Users/ben/github/benpeter/2despicable/2/README.md` and the system's capabilities documented in `docs/architecture.md`, `docs/orchestration.md`, `docs/using-nefario.md`, and `docs/build-pipeline.md` -- what is the strongest value proposition for despicable-agents that differentiates it from simpler agent setups (single-agent prompts, basic multi-agent frameworks, manual Claude Code usage)? Specifically: (1) Draft a "What You Get" section following the structure in the task brief, filling the `<gap/>` placeholders with capabilities that genuinely differentiate this system. (2) Recommend which examples best demonstrate capabilities that *require* multi-agent orchestration (not things a single agent could do). (3) Identify any existing README sections that undersell the system or fail to differentiate.
- **Context to provide**: Current README.md, docs/architecture.md (system design), docs/orchestration.md (nine-phase process), docs/build-pipeline.md (research-backed agent creation), docs/external-skills.md (extensibility), docs/using-nefario.md (user-facing workflow)
- **Why this agent**: Product positioning is this agent's core domain. It can identify the strongest differentiation angles and ensure the README communicates value rather than just describing structure. This agent directly addresses the task's core problem: "currently the README describes low-level structure without conveying the system's distinctive capabilities."

### Consultation 2: User Journey and Cognitive Load Review

- **Agent**: ux-strategy-minion
- **Planning question**: Review the current README at `/Users/ben/github/benpeter/2despicable/2/README.md` from a first-time visitor perspective. The target reader is a developer evaluating whether to adopt despicable-agents. (1) Map the current information journey -- what does a reader learn at each section, and where do they drop off or get confused? (2) Evaluate whether the 60-second scan criterion is achievable with the current structure and propose section ordering that optimizes for progressive disclosure: value proposition first, then proof/examples, then details. (3) Flag any cognitive load issues -- walls of text, unclear jargon, or sections that create more questions than they answer.
- **Context to provide**: Current README.md, the task's success criteria (especially the 60-second comprehension target)
- **Why this agent**: The task is fundamentally about making the README communicate effectively to evaluators. UX strategy expertise in cognitive load reduction, progressive disclosure, and user journey mapping directly applies to README structure and scannability.

### Consultation 3: Documentation Structure and Accuracy

- **Agent**: user-docs-minion
- **Planning question**: Review the current README at `/Users/ben/github/benpeter/2despicable/2/README.md` against the actual system capabilities documented in `docs/using-nefario.md` and `docs/orchestration.md`. (1) Identify any claims or descriptions in the current README that are inaccurate, incomplete, or misleading relative to the codebase's actual capabilities. (2) For each section of the README, note where the language could be more concrete and user-oriented (showing what the user experiences rather than describing internal architecture). (3) Recommend the right level of detail for each section -- what belongs in the README vs. what should be delegated to linked docs.
- **Context to provide**: Current README.md, docs/using-nefario.md, docs/orchestration.md, docs/agent-catalog.md, docs/architecture.md
- **Why this agent**: User-docs-minion specializes in end-user-facing documentation -- ensuring accuracy, appropriate detail level, and user-oriented language. The task explicitly requires "no inaccuracies introduced" and "all claims match current codebase capabilities."

## Cross-Cutting Checklist

- **Testing**: EXCLUDE. This task modifies only README.md (documentation content). No executable output is produced. test-minion has nothing to test.
- **Security**: EXCLUDE. README.md contains no authentication, user input processing, secret management, or attack surface. Pure documentation content change.
- **Usability -- Strategy**: INCLUDE (Consultation 2 above). Core to the task -- the entire goal is making the README communicate effectively to evaluating developers within 60 seconds.
- **Usability -- Design**: EXCLUDE for planning. No UI components, visual layouts, or interaction patterns are being produced. The README is plain Markdown text.
- **Documentation**: INCLUDE (Consultation 3 above). The task IS documentation. user-docs-minion provides accuracy validation and user-oriented writing expertise. software-docs-minion is not needed for planning because this is end-user-facing content, not architecture documentation.
- **Observability**: EXCLUDE. No runtime components, APIs, or services are being created or modified.

## Anticipated Approval Gates

**One gate anticipated**: The final README content before commit.

- **Classification**: OPTIONAL (easy to reverse -- it is a single Markdown file; moderate blast radius -- it is the project's front door but has no downstream task dependents within this plan).
- **Rationale**: The README is the public face of the project, so the user likely wants to review the final text. However, since it is a single easily-revised file, a gate is optional rather than mandatory. I recommend including it because the task involves subjective judgment about positioning and messaging.

## Rationale

Three specialists are selected for planning, all chosen because this task is fundamentally about **communication and positioning**, not technical implementation:

1. **product-marketing-minion** is primary because the core problem is positioning -- the README describes structure instead of communicating value. This agent's expertise in feature messaging, competitive differentiation, and value proposition directly fills the `<gap/>` placeholders and reshapes the narrative.

2. **ux-strategy-minion** is included because the 60-second comprehension target is a user journey design problem. Section ordering, progressive disclosure, and scannability are UX strategy concerns, not just writing concerns.

3. **user-docs-minion** is included because the task requires accuracy ("all claims match current codebase capabilities") and appropriate detail calibration (what belongs in README vs. linked docs). This agent grounds the marketing agent's positioning in verified facts.

No technical execution agents (frontend, test, security, etc.) are needed because the deliverable is a single Markdown file with no code, infrastructure, or API changes.

## Scope

**Goal**: Rewrite README.md so that someone evaluating despicable-agents understands its value proposition within 60 seconds of reading.

**In scope**:
- New "What You Get" section (before Examples) following the provided structure draft, with `<gap/>` placeholders filled
- Updated Examples section demonstrating capabilities that justify multi-agent orchestration
- Review and update of all existing README sections where they undersell or fail to differentiate
- Accuracy validation against current codebase capabilities

**Out of scope**:
- CLAUDE.md, the-plan.md, agent AGENT.md files, docs/ directory
- Adding new capabilities to the system (README documents what exists)
- Changing the agent roster, orchestration process, or any code

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent building/rebuilding | Not relevant -- task does not involve agent regeneration |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Claude Code status line config | Not relevant -- task does not involve status line configuration |
| despicable-prompter | skills/despicable-prompter/ | LEAF | Task briefing generation | Not relevant to execution -- but notable as a "goodie" to highlight in the README content |
| nefario | skills/nefario/ | ORCHESTRATION | Multi-agent orchestration | Not relevant -- this is the invoking skill itself, not a delegated tool |

### Precedence Decisions

No precedence conflicts. None of the discovered skills overlap with the specialist agents selected for this task (product-marketing-minion, ux-strategy-minion, user-docs-minion). The skills are noted as content to reference in the README itself (particularly `/despicable-prompter` and `/despicable-lab` as "goodies"), not as tools for executing this task.
