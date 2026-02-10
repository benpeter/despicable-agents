# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### Question 1: How to Reference AskUserQuestion in AGENT.md System Prompts

**Recommendation: Advisory, not prescriptive. Do NOT add AskUserQuestion to `tools:` allowlists.**

The key architectural fact: AskUserQuestion is only available to the **main Claude Code session**. Subagents spawned via the `Task` tool do not have access to it. Every agent in this project runs as a subagent during nefario orchestration (the most common execution path). Therefore:

1. **Do not add AskUserQuestion to any agent's `tools:` frontmatter.** Adding it would be misleading -- the tool would appear in the agent's schema when run standalone (`claude --agent ux-strategy-minion`) but would be silently stripped when the agent runs as a subagent during orchestration. This creates a confusing inconsistency where the same agent behaves differently depending on invocation path.

2. **Frame the guidance as a design recommendation, not a tool instruction.** The ux-strategy-minion and ai-modeling-minion should advise *callers* to use structured prompts when presenting choices. This is analogous to how these agents already recommend patterns (progressive disclosure, cognitive load reduction) without directly invoking UI frameworks themselves.

3. **Use advisory language in the system prompt.** The right framing is:

   > When designing interactive decision points in Claude Code skills or orchestration
   > workflows, prefer structured choice presentation (Claude Code's `AskUserQuestion`
   > tool) over freeform text prompts. Structured choices reduce cognitive load, prevent
   > input parsing errors, and make decision points scannable. Reserve freeform input for
   > open-ended questions where predefined options cannot cover the space.

   This is knowledge the agent carries and applies in its recommendations. It does not
   instruct the agent to call the tool itself.

4. **Placement in AGENT.md.** Add the guidance as a short subsection within the relevant
   knowledge section:
   - **ux-strategy-minion**: Under "Cognitive Load Management" or "Friction Logging" --
     it is a friction reduction technique for CLI/conversational interfaces.
   - **ai-modeling-minion**: Under "Multi-Agent Architecture" or as a new brief
     "Interactive Tool Patterns" subsection -- it is a tool-use design pattern for
     agents that design other agents or skills.

5. **Keep it brief.** 3-5 sentences maximum per agent. These agents already have large
   system prompts (~2000-3000 tokens). Adding a paragraph is fine; adding a full section
   with examples would bloat the prompt without proportional value. The agents are smart
   enough to apply the principle from a concise statement.

### Question 2: How to Reference AskUserQuestion in SKILL.md

**Recommendation: Natural language instructions with parameter hints. Not literal tool call JSON.**

The SKILL.md is interpreted by the main Claude Code session, which has full tool access
including AskUserQuestion. The question is whether the SKILL.md should contain literal
tool call specifications (JSON-like parameter blocks) or natural language descriptions.

**Use natural language with parameter-name anchors.** Here is why:

1. **SKILL.md is not a code file -- it is an instruction document.** The main session
   reads SKILL.md as guidance and translates it to tool calls. Literal JSON tool call
   specs would be fragile: if the AskUserQuestion schema changes (parameter names,
   option limits), every literal spec in SKILL.md breaks. Natural language descriptions
   are resilient to minor schema evolution.

2. **Include parameter names as anchors.** Pure prose ("ask the user which option they
   prefer") is too vague -- the model might use plain text output instead of the tool.
   Parameter names ground the instruction against the injected tool schema:

   > Present the approval decision using AskUserQuestion. Use `header: "Gate"` and
   > provide options for approve, request changes, reject, and skip. Mark approve as
   > recommended. Set `multiSelect: false`.

   This pattern -- natural language with key parameter names -- is the optimal tradeoff
   between precision and maintainability. The model matches parameter names against the
   injected schema and constructs the correct call.

3. **One instruction block per decision point, not a reusable template.** Each of the
   five decision points has different options, different recommended defaults, and
   different semantics. Trying to abstract them into a template adds complexity without
   reducing tokens (each instantiation still needs its specific options). Write each
   decision point's AskUserQuestion instruction inline where the decision currently
   appears in SKILL.md.

4. **Include the response-handling mapping.** For each AskUserQuestion call, immediately
   follow with what to do for each possible response. This is already the pattern in
   SKILL.md (e.g., "Response handling: approve -> ..., reject -> ...") -- just keep it
   and wire it to option labels instead of freeform text patterns.

5. **Concrete pattern for the approval gate (as illustration):**

   Current SKILL.md (lines 454-486) shows a freeform text block with
   `Reply: approve / request changes / reject / skip`. Replace with:

   > Present the gate decision using AskUserQuestion:
   > - question: the DECISION line from the brief
   > - header: "Gate"
   > - options:
   >   - label: "Approve", description: "Accept and continue execution" (recommended)
   >   - label: "Request changes", description: "Send feedback for revision (max 2 rounds)"
   >   - label: "Reject", description: "Drop this task and its dependents"
   >   - label: "Skip", description: "Defer; re-present before wrap-up"
   > - multiSelect: false
   >
   > If the user selects "Request changes", follow up with a freeform question
   > asking what changes are needed (AskUserQuestion cannot capture free text,
   > so use a normal message for the follow-up).

   This is natural language, includes parameter names, specifies the options, marks
   the recommended choice, and handles the follow-up flow.

### Critical Design Consideration: AskUserQuestion Cannot Capture Free Text

AskUserQuestion provides structured multiple-choice. It does not have a free-text
input field. Several current decision points need a free-text follow-up:

- **"Request changes"** at approval gates needs the user to describe what changes
- **Verification escalation** has an implicit "fix manually" path that needs context
- **Calibration check** is open-ended ("are gates well-calibrated?")

**Pattern**: Use AskUserQuestion for the initial decision (structured), then follow up
with a normal conversational message for free-text input when needed. Do not try to
cram everything into one AskUserQuestion call. Two-step (structured choice -> optional
freeform follow-up) is better UX than one overloaded interaction.

### Token and Caching Impact

The SKILL.md is loaded into the main session's context as part of the skill invocation.
It benefits from prompt caching if stable. The changes proposed here:

- **Replace** ~30 lines of freeform prompt text with ~40 lines of AskUserQuestion
  instruction text. Net increase: ~10 lines (~150 tokens). Negligible impact.
- **No cache invalidation risk** beyond the normal "SKILL.md changed" invalidation.
  SKILL.md changes are infrequent (once per release), so this is not a concern.
- **No new tool definitions** added to any `tools:` frontmatter, so no cache hierarchy
  disruption for subagent calls.

## Proposed Tasks

### Task 1: Add AskUserQuestion guidance to ux-strategy-minion AGENT.md

- **What**: Add a 3-5 sentence advisory subsection about preferring structured
  choice presentation in CLI/conversational interfaces.
- **Where**: Under "Cognitive Load Management" section, or as a brief addition to
  "Friction Logging > Removal Techniques".
- **Deliverable**: Updated `minions/ux-strategy-minion/AGENT.md`
- **Dependencies**: None. Can execute in parallel with other tasks.
- **Constraint**: Do NOT add AskUserQuestion to the `tools:` frontmatter. The
  guidance is advisory knowledge, not a tool instruction.
- **Token budget**: Add no more than 100 tokens to the system prompt.

### Task 2: Add AskUserQuestion guidance to ai-modeling-minion AGENT.md

- **What**: Add a brief subsection about interactive tool patterns for agent/skill
  design -- specifically, when to prefer structured choice tools over freeform text
  in orchestration workflows and skills.
- **Where**: Under "Multi-Agent Architecture" section or as a new "Interactive Patterns
  in Skills" subsection under "Prompt Engineering".
- **Deliverable**: Updated `minions/ai-modeling-minion/AGENT.md`
- **Dependencies**: None. Can execute in parallel with other tasks.
- **Constraint**: Do NOT add AskUserQuestion to the `tools:` frontmatter. The guidance
  is about designing prompts that recommend structured choices, not about calling the
  tool directly.
- **Token budget**: Add no more than 100 tokens to the system prompt.

### Task 3: Convert SKILL.md decision points to AskUserQuestion instructions

- **What**: Replace the five freeform decision prompts in SKILL.md with natural
  language AskUserQuestion instructions (parameter-name anchored, per-decision-point).
- **Where**: `skills/nefario/SKILL.md`, at the five locations identified in the
  meta-plan (approval gates, PR creation, verification escalation, calibration check;
  compaction excluded).
- **Deliverable**: Updated `skills/nefario/SKILL.md`
- **Dependencies**: Should follow Task 1 and 2 conceptually (the AGENT.md guidance
  informs the pattern), but no hard code dependency. Approval gate on the decision
  point design should precede this task.
- **Detail**: For each decision point, write:
  1. The AskUserQuestion instruction with parameter names (question, header, options
     with labels/descriptions, multiSelect, recommended marking)
  2. The response-handling mapping (option label -> action)
  3. Free-text follow-up instruction where needed (e.g., after "Request changes")

## Risks and Concerns

### Risk 1: AskUserQuestion Schema Instability

AskUserQuestion is a Claude Code native tool. Its schema could change in future
Claude Code versions (parameter names, option count limits, multiSelect behavior).
If SKILL.md contains literal parameter references that no longer match, the main
session will either error or fall back to freeform text.

**Mitigation**: Use natural language with parameter-name anchors (not literal JSON).
This degrades gracefully -- if a parameter is renamed, the model will likely still
understand the intent and adapt. Periodically verify the tool schema against Claude
Code release notes.

### Risk 2: Main Session Ignores AskUserQuestion Instructions

The main Claude Code session might not reliably translate SKILL.md natural language
instructions into AskUserQuestion tool calls. It might output the decision as plain
text instead, especially if the instruction phrasing is ambiguous.

**Mitigation**: Use explicit phrasing: "Present using AskUserQuestion" (tool name as
proper noun) with parameter names. This is the pattern confirmed in memory (brief
parameter-name anchoring dramatically improves tool call reliability). Test with a
dry-run nefario session after implementation.

### Risk 3: Two-Step Interaction Flow Feels Clunky

For "Request changes" and similar paths that need a structured choice followed by
freeform input, the user now has two interaction steps where they previously had one
(they could just type "request changes: fix the naming convention"). This adds a
click-then-type pattern.

**Mitigation**: This is a genuine tradeoff. The structured first step prevents
misparses (e.g., the model interpreting "skip the tests" as a gate response when the
user was providing change feedback). Accept the two-step flow for clarity. The
ux-strategy-minion's planning contribution should weigh in on whether this tradeoff
is acceptable from a cognitive load perspective.

### Risk 4: Option Count Limits

AskUserQuestion supports 2-4 options per question. The approval gate currently has
4 choices (approve, request changes, reject, skip) plus the `--skip-post` variant
of approve. This means 5 logical choices need to fit into 4 option slots.

**Mitigation**: Fold `--skip-post` into the approve flow as a follow-up question:
"Skip post-execution verification? (Y/n)" presented only after the user selects
"Approve". This keeps the primary gate at 4 options and handles the variant as a
progressive disclosure step. Alternatively, make "Approve (skip verification)" a
distinct option and drop one of the less-used options. The ux-strategy-minion should
decide which approach is better.

## Additional Agents Needed

None. The three-agent consultation (ux-strategy-minion, ai-modeling-minion, devx-minion)
covers the full scope:
- UX strategy for decision point design
- AI/prompt engineering for tool integration patterns
- DevX for commit hook noise suppression

No additional agents are needed for planning. The standard Phase 3.5 reviewers
(lucy, margo, security-minion, test-minion, ux-strategy-minion, software-docs-minion)
will review the synthesized plan as usual.
