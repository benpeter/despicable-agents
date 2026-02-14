# Meta-Plan: Self-Contained Advisories

## Planning Consultations

### Consultation 1: Advisory Format Design

- **Agent**: ux-strategy-minion
- **Model**: opus
- **Planning question**: The advisory format currently uses `TASK: <task number>` and `CHANGE: <what changed in the task prompt>` -- references that are only meaningful inside the orchestration session. How should an advisory be structured so that a reader who sees only the advisory text (in a synthesis output, execution report, or task list) can evaluate it without opening the originating session? Specifically: what replaces task numbers as anchoring context, how much domain context belongs in each advisory, and where is the line between "self-contained" and "bloated"?
- **Context to provide**: Current ADVISE verdict format from `nefario/AGENT.md` lines 662-676 (VERDICT: ADVISE / WARNINGS with TASK, CHANGE, RECOMMENDATION fields); the execution plan advisory format from `skills/nefario/SKILL.md` lines 1278-1308 (ADVISORIES block with domain, Task N, CHANGE, WHY); Phase 5 code review finding format (VERDICT with FINDINGS referencing file:line-range).
- **Why this agent**: UX-strategy specializes in cognitive load reduction and information architecture. The core problem is making each advisory a self-contained information unit that a reader can evaluate without session context -- this is fundamentally an information design problem.

### Consultation 2: Document Consistency Across Output Surfaces

- **Agent**: software-docs-minion
- **Model**: opus
- **Planning question**: Advisories appear on multiple surfaces: the Phase 3.5 verdict output, the execution plan approval gate ADVISORIES block, the inline summary template, the execution report, and Phase 5 code review findings. How should the advisory format be unified across these surfaces so that every surface presents a self-contained advisory without requiring cross-referencing to a different artifact? What is the minimal set of fields that makes an advisory self-contained across all surfaces, and where do surface-specific fields (like scratch file links) belong?
- **Context to provide**: The five surfaces listed above with their current formats. The SKILL.md advisory format (lines 1278-1308), the nefario AGENT.md verdict format (lines 656-693), the inline summary template (SKILL.md lines 337-357), and the Phase 5 code review format (SKILL.md lines 1664-1673).
- **Why this agent**: software-docs-minion specializes in documentation architecture -- maintaining consistent structure across multiple output surfaces is their domain expertise. They understand how to design formats that work across contexts.

### Consultation 3: Governance Review Format Alignment

- **Agent**: lucy
- **Model**: opus
- **Planning question**: Lucy produces ADVISE verdicts during both Phase 3.5 (plan review) and Phase 5 (code review). Currently the verdict format references task numbers and plan-internal structure. What fields does lucy need in the verdict template to produce advisories that name the concrete artifact, file, or concept they concern -- without sacrificing the brevity that makes verdicts scannable? Also: does the intent-alignment review process need any changes to ensure advisory output references the original user intent rather than plan-internal structure?
- **Context to provide**: Lucy's current verdict format from `lucy/AGENT.md` lines 208-216 (APPROVE/ADVISE/BLOCK with severity classification tags); the Phase 3.5 reviewer prompt template (SKILL.md lines 1079-1096) and Phase 5 code review prompt template (SKILL.md lines 1643-1673).
- **Why this agent**: Lucy is a mandatory reviewer in both Phase 3.5 and Phase 5. She produces advisories in both phases and has direct experience with what context is available when writing verdicts and what context is missing. Her input ensures the new format works from the reviewer's perspective.

### Consultation 4: Simplicity Gate for Format Changes

- **Agent**: margo
- **Model**: opus
- **Planning question**: The proposed change adds context fields to advisories to make them self-contained. What is the minimum set of changes needed to achieve self-containment without over-engineering the format? Specifically: is there a risk of advisories becoming too verbose or structured, defeating their purpose as quick-scan items? What constraints should the format impose to prevent advisory bloat?
- **Context to provide**: Current advisory format (2-3 lines: CHANGE + WHY, with optional Details link); the issue's success criteria (name concrete artifact, state proposal in domain terms, explain rationale with present information); the 3-line maximum per advisory rule (SKILL.md line 1297).
- **Why this agent**: Margo is the YAGNI/KISS enforcer and a mandatory reviewer. She will review the plan regardless, but consulting her during planning prevents an over-engineered format that she would then BLOCK. Her input calibrates how much context is "enough" versus "too much."

## Cross-Cutting Checklist

- **Testing**: Exclude from planning. No executable code is produced -- this is a prompt/format specification change across AGENT.md and SKILL.md files. Testing will be evaluated during Phase 3.5 review (test-minion reviews whether the format changes need test coverage, likely concluding they do not since these are prompt templates).
- **Security**: Exclude from planning. Advisory format changes do not introduce attack surface, handle authentication, or process user input. Security-minion will still review in Phase 3.5 as a mandatory reviewer.
- **Usability -- Strategy**: INCLUDED as Consultation 1. UX-strategy-minion is the primary planning contributor -- the core problem is information design for self-contained readability.
- **Usability -- Design**: Exclude from planning. No user-facing UI components are produced. The advisory format is text-based terminal output, which is ux-strategy's domain (cognitive load, information hierarchy) rather than ux-design's domain (visual hierarchy, interaction patterns).
- **Documentation**: INCLUDED as Consultation 2. software-docs-minion contributes planning expertise on cross-surface format consistency.
- **Observability**: Exclude from planning. No runtime components, services, or APIs are produced. Advisory format changes are static prompt/template changes.

## Anticipated Approval Gates

1. **Advisory format specification** (MUST gate): The unified advisory format definition that will be used across all surfaces. This is hard to reverse (it changes prompt templates across multiple agents and the SKILL.md orchestration spec) and has high blast radius (every downstream task implements this format). Multiple valid approaches exist (field-based vs. prose-based, level of context detail, how to reference artifacts without task numbers). User review ensures the format meets their readability needs.

No other gates anticipated. Once the format is approved, implementation across the various files is mechanical and easily revisable.

## Rationale

This task is primarily an information design problem (how to structure advisory text so it is self-contained) with a documentation consistency dimension (ensuring the format works across the five surfaces where advisories appear). The four selected planning consultants cover:

- **ux-strategy-minion**: Designs the advisory format for self-contained readability (the core challenge).
- **software-docs-minion**: Ensures the format works consistently across all output surfaces (execution gate, reports, inline summaries, verdict files).
- **lucy**: Provides the reviewer's perspective -- what context is available when producing advisories and what fields are needed to ground them in concrete artifacts.
- **margo**: Guards against over-engineering the format, calibrating how much context is "enough" versus "too much."

Agents NOT consulted for planning:
- **security-minion, test-minion**: Mandatory Phase 3.5 reviewers but have no planning expertise to contribute here. The task does not touch security or test domains.
- **devx-minion**: Could contribute CLI output formatting expertise, but the advisory format is tightly coupled to the orchestration flow. UX-strategy covers the information design aspect.
- **code-review-minion**: Will participate in Phase 5 if applicable, but has no planning input for prompt template design.

## Scope

**In scope**:
- ADVISE verdict format in nefario AGENT.md (the format definition used by all reviewers)
- BLOCK verdict format in nefario AGENT.md (if it needs similar self-containment updates)
- Phase 3.5 reviewer prompt templates in nefario SKILL.md (instructions that tell reviewers what to produce)
- Phase 5 code review verdict format in nefario SKILL.md and the-plan.md
- Execution plan approval gate ADVISORIES block format in nefario SKILL.md
- Inline summary template verdict field in nefario SKILL.md
- Lucy AGENT.md and Margo AGENT.md verdict output sections (if their verdict templates need updating to align)
- the-plan.md verdict format specifications (if they exist and diverge)

**Out of scope**:
- Verdict routing mechanics (how BLOCK/ADVISE verdicts flow between phases)
- Phase sequencing (which phases run when)
- Report template layout (how reports are structured -- format changes flow naturally via advisory content)
- Advisory mode (--advisory flag behavior)
- Approval gate interaction mechanics (AskUserQuestion patterns, decision options)

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding from specs | Not relevant -- this task modifies specs manually, not via lab rebuild |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line configuration | Not relevant -- no status line changes |
| despicable-prompter | skills/despicable-prompter/ | LEAF | Task briefing generation | Not relevant -- advisory format, not task briefing |
| nefario | skills/nefario/ | ORCHESTRATION | Multi-phase orchestration | Active orchestration skill (invoking context) -- not included as resource |

### Precedence Decisions

No conflicts. No external skill overlaps with the advisory format domain. The `despicable-lab` skill may be useful during execution (to rebuild agents after spec changes), but it is a LEAF skill invoked manually, not integrated into the delegation plan.
