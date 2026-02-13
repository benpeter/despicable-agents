# Meta-Plan: Show Phase and Task in Status Line and Gates

## Planning Consultations

### Consultation 1: Gate Message Templates and Phase Context

- **Agent**: devx-minion
- **Planning question**: The nefario SKILL.md defines 11 distinct AskUserQuestion instances with headers like "Team", "Review", "Plan", "Gate", "Post-exec", "Confirm", "Calibrate", "Security", "Issue", "PR", and "Existing PR". The status line disappears during AskUserQuestion prompts, creating an orientation gap. How should we embed phase/step context into AskUserQuestion headers or question text so that users always know where they are in the orchestration? Consider: (a) should the `header` field carry phase context (e.g., "Phase 1 > Team") or should it go in the `question` text? (b) what format balances brevity with orientation? (c) should all 11 gate types get phase context or only certain ones? Review the current header/question patterns in SKILL.md lines 466-468, 785-787, 1017-1018, 1142-1144, 1283-1285, 1294-1296, 1318-1319, 1358-1359, 1467-1468, 1496-1497, 1688-1689, 1881-1882.
- **Context to provide**: The 11 AskUserQuestion instances in SKILL.md, the Visual Hierarchy system from #57, the existing phase announcement markers
- **Why this agent**: devx-minion specializes in CLI interaction design, developer-facing UX conventions, and information display patterns. Gate message formatting is a developer experience concern.

### Consultation 2: Status File Content Design

- **Agent**: ux-strategy-minion
- **Planning question**: The status file at `/tmp/nefario-status-$sid` currently contains only a task summary (max 48 chars, e.g., "Build MCP server with OAuth..."). The issue asks to include both phase and task title (e.g., "Phase 3: Synthesis | Restore phase announcements"). How should the status file content be structured given: (a) the status line has limited horizontal space (it already shows directory, model, and context percentage), (b) users need "where am I?" orientation at a glance, (c) the file is written once per phase boundary and read continuously by the status line command, (d) during AskUserQuestion the status line is hidden so the gate itself must carry orientation. What is the right information density for the status line vs. the gate?
- **Context to provide**: Current status line format from despicable-statusline SKILL.md (line 45), current status file write in SKILL.md (lines 362-368), the phase announcement patterns (lines 176-201)
- **Why this agent**: ux-strategy-minion evaluates cognitive load, information architecture, and user journey coherence. This is fundamentally about what information the user needs at different touchpoints and how much is too much.

### Consultation 3: Phase Transition Status Updates

- **Agent**: ux-design-minion
- **Planning question**: Currently the status file is written once at Phase 1 start with a static task summary. The issue requires updating it at each phase boundary. The SKILL.md defines phase transitions at Phase 1, 2, 3, 3.5, and 4 (phases 5-8 use a combined CONDENSE line). Where exactly in the SKILL.md flow should the status file update calls be placed? Should the update happen before or after the phase announcement marker? Should mid-execution gate names also appear in the status (e.g., "Phase 4: Execution > Gate: DB Schema")? Consider the interaction between the status file update and the phase announcement -- they serve the same orientation purpose in different UI channels.
- **Context to provide**: SKILL.md phase transition points, the existing status write at lines 362-368, phase announcement rules at lines 176-201, the execution batch loop at lines 1209+
- **Why this agent**: ux-design-minion handles interaction patterns and timing of visual signals. The question is about when and where status updates fire relative to other orientation signals -- an interaction design concern.

## Cross-Cutting Checklist

- **Testing**: EXCLUDE for planning. No executable code is produced -- this is a SKILL.md and documentation-only change. test-minion will participate in Phase 3.5 review (mandatory) and can assess whether the status file write pattern is testable.
- **Security**: EXCLUDE for planning. The status file mechanism already exists with `chmod 600` permissions. No new attack surface is created. security-minion will participate in Phase 3.5 review (mandatory).
- **Usability -- Strategy**: INCLUDED as Consultation 2 (ux-strategy-minion). Planning question addresses information density and cognitive load at the status line and gate touchpoints.
- **Usability -- Design**: INCLUDED as Consultation 3 (ux-design-minion). Planning question addresses interaction timing and visual signal placement.
- **Documentation**: INCLUDE for planning -- user-docs-minion should assess whether `docs/using-nefario.md` needs updates to describe the new phase-in-status behavior.
- **Observability**: EXCLUDE for planning. No runtime components or production services are affected. The status file is a local development tool.

### Consultation 4: User Documentation Impact

- **Agent**: user-docs-minion
- **Planning question**: The `docs/using-nefario.md` Status Line section (lines 166-217) currently describes the status bar as showing "the task summary." The "What Happens" section (lines 98-120) describes phase announcements but does not mention phase awareness in the status line or gates. What documentation changes are needed to reflect: (a) status line now shows phase + task, (b) approval gates now include phase context in their headers? Should the "How It Works" subsection (lines 195-197) be updated to describe the phase-updating behavior? Assess whether the manual configuration example (lines 200-216) needs to change or if the status line command remains the same (it reads whatever is in the file).
- **Context to provide**: Current using-nefario.md content, the despicable-statusline SKILL.md, the status file mechanism
- **Why this agent**: user-docs-minion assesses documentation impact for user-facing changes. The status line and gate behavior are user-visible features that need accurate documentation.

## Anticipated Approval Gates

One approval gate is likely: the format decision for how phase context appears in AskUserQuestion headers/questions. This is a hard-to-reverse choice (all 11 gate patterns would be changed) with high blast radius (every future orchestration session is affected). The specific format pattern (e.g., "Phase 1 > Team" vs. "Team [Phase 1]" vs. phase in question text) warrants user review.

## Rationale

Four specialists are proposed for planning consultation:

1. **devx-minion** -- The core deliverable is a change to 11 AskUserQuestion gate message templates. These are developer-facing interaction points, and devx-minion's expertise in CLI message formatting directly applies to the header/question format decision.

2. **ux-strategy-minion** -- The fundamental question is information architecture: what information goes where (status line vs. gate), and how much is appropriate for each channel. This is a cognitive load and user journey question.

3. **ux-design-minion** -- The timing and placement of status file updates relative to phase announcements is an interaction design question. The two channels (status line and chat output) need coordinated visual signals.

4. **user-docs-minion** -- The user-facing documentation describes the current status line behavior. Changes need to be reflected accurately. Early assessment prevents documentation drift.

Not included for planning: software-docs-minion (architecture docs are not affected -- SKILL.md changes are covered by the executing agent), product-marketing-minion (no README or positioning impact), accessibility-minion (no web UI changes), seo-minion and sitespeed-minion (not web-facing), observability-minion (no runtime components). software-docs-minion will still participate in Phase 3.5 review (mandatory) for documentation impact checklist.

## Scope

**In scope**:
- Update nefario SKILL.md status file write to include phase + task title at each phase boundary
- Update SKILL.md AskUserQuestion gate message templates to include phase/step context
- Update `docs/using-nefario.md` to reflect new status line and gate behavior
- Optionally update despicable-statusline SKILL.md if the display format needs changes

**Out of scope**:
- Changing Claude Code's AskUserQuestion UI rendering behavior
- Modifying how Claude Code handles the status line during interview prompts
- Changes to post-execution dark kitchen phases (5-8)
- Changes to the status line shell command (it reads whatever is in the file -- the change is in what gets written)

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent rebuild/check | Not relevant to this task |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line configuration | Potentially relevant -- the display format section may need review if status content changes break assumptions |
| despicable-prompter | `skills/despicable-prompter/` | LEAF | Briefing coach | Not relevant to this task |
| nefario | `skills/nefario/` | ORCHESTRATION | Task orchestration | This is the primary file being modified; not used as a delegated skill |

### Precedence Decisions

No precedence conflicts. The despicable-statusline skill configures the status line command, which reads the status file. The proposed changes modify what gets written TO the file (in SKILL.md), not how the file is read (in despicable-statusline). However, if the status content format changes (e.g., longer strings), the despicable-statusline SKILL.md documentation example may need updating for consistency. This will be evaluated during synthesis.
