# Delegation Plan: Nefario Skill UX with Structured Prompts and Quieter Commit Hooks

**Team name**: nefario-ux-hooks
**Description**: Convert nefario SKILL.md decision points to AskUserQuestion, suppress commit hook noise during orchestrated sessions, and add AskUserQuestion guidance to ux-strategy-minion and ai-modeling-minion AGENT.md files.

---

## Task 1: Update SKILL.md decision points to use AskUserQuestion

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This changes the interactive contract of every future nefario session. All four decision points are modified. High blast radius (every orchestrated session), moderate reversibility (text changes, but users build muscle memory around interaction patterns). MUST gate per classification matrix.

- **Prompt**: |
    You are updating the nefario orchestration skill to use Claude Code's
    `AskUserQuestion` tool for user-facing decision points.

    ## Context

    The SKILL.md at `skills/nefario/SKILL.md` is the instruction document
    for the main Claude Code session during nefario orchestration. The main
    session has native access to `AskUserQuestion`. Your job is to replace
    four freeform text decision prompts with natural language instructions
    that direct the main session to use AskUserQuestion.

    ## What to Do

    Modify `skills/nefario/SKILL.md` to convert four decision points. For
    each, replace the freeform prompt block with a natural language
    AskUserQuestion instruction using parameter-name anchors (NOT literal
    JSON tool call specs). Each instruction block should be inline where the
    current prompt appears.

    ### Decision Point 1: Approval Gates (Phase 4, step 5)

    Current location: around lines 453-486 (the `Reply: approve / request
    changes / reject / skip` block).

    Replace the `Reply: approve / request changes / reject / skip` line and
    surrounding instruction with:

    - Print the decision brief (DECISION, RATIONALE, IMPACT, DELIVERABLE,
      Confidence) as normal conversation output ABOVE the AskUserQuestion call.
    - Then present the decision using AskUserQuestion:
      - `header`: "Gate"
      - `question`: the DECISION line from the brief
      - options (4, `multiSelect: false`):
        1. label: "Approve", description: "Accept and continue execution.
           Code review + tests run after." (recommended)
        2. label: "Request changes", description: "Send feedback for revision
           (max 2 rounds)."
        3. label: "Reject", description: "Drop this task and its dependents
           from the plan."
        4. label: "Skip", description: "Defer; re-presented before wrap-up."

    Response handling (keep existing logic, wire to option labels):
    - "Approve": auto-commit, continue to next batch. Post-execution phases
      run after all execution completes.
    - "Request changes": follow up with a normal conversational message
      asking what changes are needed (AskUserQuestion cannot capture free
      text). Send feedback to agent. Cap at 2 rounds.
    - "Reject": present a SECONDARY AskUserQuestion for confirmation:
      - `header`: "Confirm"
      - `question`: "Reject <task>? This will also drop: <list dependents>"
      - options (2, `multiSelect: false`):
        1. label: "Confirm reject", description: "Remove task and dependents."
        2. label: "Cancel", description: "Go back to the gate decision."
    - "Skip": defer the gate. Continue with non-blocked tasks.
    - User selects "Other" and types "approve --skip-post": honor it.
      Auto-commit, skip Phases 5, 6, 8.

    Keep the `Post-execution: code review + tests + docs (skip with
    "approve --skip-post")` note in the decision brief text printed above
    AskUserQuestion so users know the escape hatch exists.

    ### Decision Point 2: Verification Escalation (Phase 5)

    Current location: around lines 578-585 (the `Options: fix manually /
    accept as-is / skip remaining verification` block).

    Replace with AskUserQuestion instruction:
    - `header`: "Issue"
    - `question`: the one-sentence finding description from the escalation brief
    - options (3, `multiSelect: false`):
      1. label: "Accept as-is", description: "Proceed with current code.
         Log finding for later." (recommended)
      2. label: "Fix manually", description: "Pause orchestration. You fix
         the code, then resume."
      3. label: "Skip verification", description: "Skip all remaining code
         review and test checks."

    Keep the escalation brief (VERIFICATION ISSUE, Phase, Agent, Finding,
    File, Auto-fix attempts) printed above.

    ### Decision Point 3: Calibration Check (Phase 4, step 5 anti-fatigue)

    Current location: around lines 510-513 (the "Are the gates
    well-calibrated..." text).

    Replace with AskUserQuestion instruction:
    - `header`: "Calibrate"
    - `question`: "5 consecutive approvals without changes. Gates well-calibrated?"
    - options (2, `multiSelect: false`):
      1. label: "Gates are fine", description: "Continue with current
         gating level." (recommended)
      2. label: "Fewer gates next time", description: "Note for future
         plans: consolidate more aggressively."

    ### Decision Point 4: PR Creation (Wrap-up, step 10)

    Current location: around lines 678-681 (the `Create PR for
    nefario/<slug>? (Y/n)` block).

    Replace with AskUserQuestion instruction:
    - `header`: "PR"
    - `question`: "Create PR for nefario/<slug>?"
    - options (2, `multiSelect: false`):
      1. label: "Create PR", description: "Push branch and open pull
         request on GitHub." (recommended)
      2. label: "Skip PR", description: "Keep branch local. Push later."

    ## Formatting Rules

    - Use natural language with parameter-name anchors (e.g., `header:`,
      `question:`, `options:`, `multiSelect:`). Do NOT write literal JSON
      tool call blocks.
    - Name the tool explicitly: "Present using AskUserQuestion" so the main
      session reliably invokes the tool rather than printing plain text.
    - Keep each instruction block inline at the location of the current
      decision point. Do NOT extract them into a reusable template.
    - Immediately after each AskUserQuestion instruction, include the
      response-handling mapping (option label -> action).

    ## What NOT to Do

    - Do NOT modify the compaction checkpoint (around lines 286-303 and
      369-385). Leave it exactly as-is.
    - Do NOT change any phase logic, agent spawning, or task management.
    - Do NOT add `AskUserQuestion` to any agent's `tools:` frontmatter.
    - Do NOT modify nefario's AGENT.md.
    - Do NOT restructure SKILL.md sections beyond the specific decision
      point replacements.

    ## Deliverables

    Modified `skills/nefario/SKILL.md` with four decision points converted
    to AskUserQuestion instructions.

    ## Success Criteria

    - All four decision points use AskUserQuestion natural language
      instructions with parameter-name anchors.
    - Compaction checkpoint is untouched.
    - The `approve --skip-post` escape hatch is documented in the gate
      brief text (not as a visible AskUserQuestion option).
    - "Reject" has a secondary AskUserQuestion confirmation step.
    - Each AskUserQuestion instruction is immediately followed by its
      response-handling mapping.
    - One option per decision point is marked "(recommended)".

    When you finish, mark the task completed with TaskUpdate and send a
    message to the team lead summarizing what you produced and where the
    deliverables are. Include file paths.

- **Deliverables**: Modified `skills/nefario/SKILL.md`
- **Success criteria**: Four decision points use AskUserQuestion instructions; compaction untouched; approve --skip-post documented; reject has confirmation; response handling wired to option labels.

---

## Task 2: Add orchestrated-session marker to commit hook

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none (parallel with Task 1)
- **Approval gate**: no
- **Gate reason**: Low blast radius (only the hook file), easy to reverse (3-line addition). No gate needed.

- **Prompt**: |
    You are adding an orchestrated-session marker check to the nefario
    project's commit hook so it exits silently during orchestrated sessions.

    ## Context

    The Stop hook at `.claude/hooks/commit-point-check.sh` fires every time
    Claude finishes a response. During nefario orchestration, this creates
    noise -- the hook outputs ~30 lines of commit checkpoint instructions
    that clutter the conversation. The orchestration SKILL.md already
    manages commits directly (auto-commit after gate approvals and at
    wrap-up), so the hook is redundant during orchestrated sessions.

    The hook already uses session-scoped marker files for other purposes:
    - `/tmp/claude-commit-defer-<session-id>.txt` (defer marker)
    - `/tmp/claude-commit-declined-<session-id>` (declined marker)

    ## What to Do

    ### Step 1: Add marker check to commit-point-check.sh

    In `.claude/hooks/commit-point-check.sh`, add an early-exit guard in
    the `main()` function. Place it AFTER the existing `defer_marker` check
    (around line 136) and BEFORE the sensitive patterns file check (around
    line 140):

    ```bash
    # --- Orchestrated session? Exit silently ---
    local orchestrated_marker="/tmp/claude-commit-orchestrated-${session_id}"
    if [[ -f "$orchestrated_marker" ]]; then
        exit 0
    fi
    ```

    This exits with code 0 (allow stop, no output).

    ### Step 2: Add marker creation/cleanup to SKILL.md

    In `skills/nefario/SKILL.md`:

    1. In Phase 4 "Branch Creation" section (around line 407), AFTER the
       branch creation decision block (after line 407, the last rule about
       using existing branch vs creating new), add a new paragraph:

       "After branch resolution (whether creating a new branch or using an
       existing one), create the orchestrated-session marker to suppress
       commit hook noise:
       `touch /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`"

       IMPORTANT: Place this OUTSIDE the branch creation conditional, not
       inside it. The marker must be created regardless of whether a new
       branch was created.

    2. In the Wrap-up Sequence (step 11, "Return to main", around line 700),
       add cleanup BEFORE the `git checkout main`:

       "Remove the orchestrated-session marker:
       `rm -f /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`"

    ### Step 3: Update commit-workflow.md

    In `docs/commit-workflow.md`, Section 7 "Hook Composition" (around line
    260), add a brief paragraph after the existing description:

    "During nefario-orchestrated sessions, the Stop hook is suppressed via
    a session-scoped marker file
    (`/tmp/claude-commit-orchestrated-<session-id>`). The marker is created
    at the start of Phase 4 (execution) and removed at wrap-up. When the
    marker exists, the hook exits 0 immediately, producing no output. This
    prevents the hook's commit checkpoint from conflicting with the
    SKILL.md-driven auto-commit flow."

    ## What NOT to Do

    - Do NOT modify the hook's behavior for single-agent sessions. The
      hook must continue to work exactly as before when no marker exists.
    - Do NOT change the hook's exit codes or output format for non-marker
      paths.
    - Do NOT add environment variable checks (hooks do not receive custom
      env vars from SKILL.md context).
    - Do NOT detect orchestrated sessions via branch name patterns (fragile,
      false positives).
    - Do NOT make the hook output more concise as part of this task (separate
      concern, out of scope).

    ## Deliverables

    1. Modified `.claude/hooks/commit-point-check.sh` (3-line addition)
    2. Modified `skills/nefario/SKILL.md` (2 single-line additions)
    3. Modified `docs/commit-workflow.md` (1 paragraph addition)

    ## Success Criteria

    - The hook exits 0 silently when the marker file exists.
    - The marker is created after branch resolution in Phase 4.
    - The marker is removed at wrap-up before returning to main.
    - Single-agent sessions (no marker) behave identically to before.
    - The marker path follows the existing naming convention
      (`/tmp/claude-commit-orchestrated-<session-id>`).

    When you finish, mark the task completed with TaskUpdate and send a
    message to the team lead summarizing what you produced and where the
    deliverables are. Include file paths.

- **Deliverables**: Modified `.claude/hooks/commit-point-check.sh`, modified `skills/nefario/SKILL.md` (marker creation/cleanup lines), modified `docs/commit-workflow.md`
- **Success criteria**: Hook exits silently with marker; marker created at Phase 4 start; marker cleaned up at wrap-up; single-agent sessions unchanged.

---

## Task 3: Add AskUserQuestion guidance to ux-strategy-minion AGENT.md

- **Agent**: ai-modeling-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none (parallel with Tasks 1-2)
- **Approval gate**: no
- **Gate reason**: Easy to reverse (text addition to agent prompt), low blast radius (single agent). No gate.

- **Prompt**: |
    You are adding a brief advisory about structured choice presentation to
    the ux-strategy-minion's system prompt.

    ## Context

    Claude Code provides an `AskUserQuestion` tool that presents structured
    multiple-choice options to users instead of requiring freeform text
    input. This is a friction reduction technique relevant to the
    ux-strategy-minion's domain (cognitive load management, decision point
    design).

    The guidance should be ADVISORY -- the ux-strategy-minion should
    recommend this pattern in its analyses, but it does NOT call the tool
    itself. Agents run as subagents during orchestration and do not have
    access to AskUserQuestion. The guidance is knowledge the agent carries
    and applies in its recommendations to callers.

    ## What to Do

    Edit `minions/ux-strategy-minion/AGENT.md`. Add a short subsection
    (3-5 sentences, no more than ~100 tokens) under the "Cognitive Load
    Management" section (after the "Reduction Strategies" subsection, around
    line 53). Title it: **Structured Choice Presentation**

    Content should convey:
    - When designing interactive decision points in CLI or conversational
      interfaces, prefer structured choice presentation (e.g., Claude Code's
      `AskUserQuestion` tool) over freeform text prompts.
    - Structured choices reduce cognitive load, prevent input parsing errors,
      and make decision points scannable.
    - Reserve freeform input for open-ended questions where predefined
      options cannot cover the space.
    - Apply Hick's Law: keep options to 2-4 per question; mark the
      recommended default.

    ## What NOT to Do

    - Do NOT add `AskUserQuestion` to the `tools:` field in the YAML
      frontmatter. The agent does not call this tool.
    - Do NOT add examples, code blocks, or lengthy explanations. Keep it
      to 3-5 sentences.
    - Do NOT modify any other section of the AGENT.md.
    - Do NOT change the agent's boundaries or working patterns.

    ## Deliverables

    Modified `minions/ux-strategy-minion/AGENT.md` with the new subsection.

    ## Success Criteria

    - New subsection titled "Structured Choice Presentation" exists under
      "Cognitive Load Management".
    - Content is 3-5 sentences, advisory in tone.
    - `AskUserQuestion` is NOT in the `tools:` frontmatter.
    - No other sections are modified.

    When you finish, mark the task completed with TaskUpdate and send a
    message to the team lead summarizing what you produced and where the
    deliverables are. Include file paths.

- **Deliverables**: Modified `minions/ux-strategy-minion/AGENT.md`
- **Success criteria**: New subsection under Cognitive Load Management; advisory tone; ~100 tokens; tools: frontmatter unchanged.

---

## Task 4: Add AskUserQuestion guidance to ai-modeling-minion AGENT.md

- **Agent**: ai-modeling-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none (parallel with Tasks 1-3)
- **Approval gate**: no
- **Gate reason**: Easy to reverse, low blast radius. No gate.

- **Prompt**: |
    You are adding a brief advisory about interactive tool patterns to the
    ai-modeling-minion's system prompt.

    ## Context

    Claude Code provides an `AskUserQuestion` tool for structured
    multiple-choice prompts. When designing agent systems, orchestration
    skills, or multi-agent workflows, this tool is the preferred way to
    present decision points to users. The ai-modeling-minion should carry
    this knowledge and recommend it when designing prompts for skills or
    agent systems that interact with users.

    The guidance should be ADVISORY -- the ai-modeling-minion recommends
    this pattern when designing systems, but it does NOT call the tool
    itself.

    ## What to Do

    Edit `minions/ai-modeling-minion/AGENT.md`. Add a short subsection
    (3-5 sentences, no more than ~100 tokens) under the "Multi-Agent
    Architecture" section (after the "Stateless single-turn interpretation"
    subsection, around line 202). Title it: **Interactive Patterns in Skills**

    Content should convey:
    - When designing Claude Code skills or orchestration workflows that
      present choices to users, prefer structured choice tools (Claude
      Code's `AskUserQuestion`) over freeform text prompts.
    - In SKILL.md instructions, reference AskUserQuestion using natural
      language with parameter-name anchors (e.g., `header:`, `options:`,
      `multiSelect:`) rather than literal JSON tool call specs. This is
      more resilient to schema changes.
    - Structured choices prevent input parsing ambiguity and reduce
      cognitive load at decision points.

    ## What NOT to Do

    - Do NOT add `AskUserQuestion` to the `tools:` field in the YAML
      frontmatter.
    - Do NOT add examples, code blocks, or lengthy explanations. Keep it
      to 3-5 sentences.
    - Do NOT modify any other section of the AGENT.md.

    ## Deliverables

    Modified `minions/ai-modeling-minion/AGENT.md` with the new subsection.

    ## Success Criteria

    - New subsection titled "Interactive Patterns in Skills" exists under
      "Multi-Agent Architecture".
    - Content is 3-5 sentences, advisory in tone.
    - Mentions parameter-name anchors as the preferred referencing pattern.
    - `AskUserQuestion` is NOT in the `tools:` frontmatter.
    - No other sections are modified.

    When you finish, mark the task completed with TaskUpdate and send a
    message to the team lead summarizing what you produced and where the
    deliverables are. Include file paths.

- **Deliverables**: Modified `minions/ai-modeling-minion/AGENT.md`
- **Success criteria**: New subsection under Multi-Agent Architecture; advisory tone; ~100 tokens; tools: frontmatter unchanged.

---

## Cross-Cutting Coverage

| Dimension | Coverage | Justification |
|-----------|----------|---------------|
| **Testing** | Phase 6 (post-execution) | No executable code produced. Hook change is a 3-line bash guard. SKILL.md is a markdown instruction file. Automated testing not applicable. Manual validation during a nefario dry run is the appropriate verification. Phase 6 will confirm no test regressions. |
| **Security** | Phase 3.5 review (security-minion) | No new attack surface, auth, user input processing, or dependencies. Hook change adds an early exit (reduces code paths, does not add them). Phase 3.5 security-minion review is sufficient. |
| **Usability -- Strategy** | Task 1 (decision point design) + Phase 3.5 review | The ux-strategy-minion's planning contribution directly informs Task 1. Phase 3.5 ux-strategy-minion reviews the final plan for journey coherence. |
| **Usability -- Design** | Not applicable | No user-facing interfaces created. AskUserQuestion rendering is controlled by Claude Code, not by us. |
| **Documentation** | Task 2 includes commit-workflow.md update; Phase 8 handles any remaining | The commit-workflow.md update is in Task 2 (hook behavior change documentation). SKILL.md is self-documenting. Phase 8 will check for additional documentation needs. |
| **Observability** | Not applicable | No runtime components, services, or APIs created or modified. |

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: None triggered. No runtime components (observability-minion not needed). No user-facing interfaces (ux-design-minion, accessibility-minion not needed). No web-facing components (sitespeed-minion not needed).

## Conflict Resolutions

### Conflict 1: Task 1 and Task 2 both modify SKILL.md

Both the AskUserQuestion conversion (Task 1) and the commit hook marker (Task 2) modify `skills/nefario/SKILL.md`. However, they modify different sections:
- Task 1 modifies decision point blocks (approval gates, verification escalation, calibration check, PR creation).
- Task 2 adds single-line marker creation (Phase 4 branch section) and cleanup (wrap-up step 11).

**Resolution**: Both tasks are assigned to the same agent (devx-minion) to avoid file ownership conflicts. The agent handles both sets of changes in a single editing session. If the team framework requires separate agents, Task 2's SKILL.md changes must run after Task 1 to avoid merge conflicts.

**Update**: Task 1 (SKILL.md decision points) and Task 2 (hook + marker) are assigned to devx-minion. The agent executes Task 1 first (larger change), then Task 2 (smaller, additive change to different sections). This eliminates file contention entirely.

### Conflict 2: "Approve (Recommended)" labeling

The ux-strategy-minion recommends marking "Approve" as "(Recommended)" on the label itself. The ai-modeling-minion notes that it's unclear whether AskUserQuestion natively supports a "(Recommended)" syntax or if it's just text appended to the label.

**Resolution**: Use "(recommended)" as part of the option description or as a parenthetical in the SKILL.md instruction. The natural language approach ("mark approve as recommended") lets the main session figure out the best way to present it within AskUserQuestion's actual schema. This is more resilient than assuming a specific syntax.

### Conflict 3: approve --skip-post handling

The ux-strategy-minion recommends NOT surfacing `approve --skip-post` as a visible option (progressive disclosure via "Other"). The ai-modeling-minion suggests it could be a follow-up question after "Approve". The meta-plan specified it should stay accessible.

**Resolution**: Follow ux-strategy-minion's recommendation. Keep `approve --skip-post` as an "Other" escape hatch, not a visible option. Document it in the decision brief text printed above AskUserQuestion. This minimizes option count at the gate (4 options is already at the Hick's Law limit) while preserving the expert path. The meta-plan's success criteria says "must use Claude Code's native AskUserQuestion tool" -- the "Other" freeform input is native AskUserQuestion functionality.

## Risks and Mitigations

### Risk 1: Main session ignores AskUserQuestion instructions (HIGH impact, LOW probability)

The main Claude Code session might output the decision as plain text instead of invoking AskUserQuestion.

**Mitigation**: Use explicit phrasing "Present using AskUserQuestion" (tool name as proper noun) with parameter-name anchors. This pattern is confirmed to improve tool call reliability. If it fails, the user can still respond with freeform text (the response handling logic already supports text input for backward compatibility).

### Risk 2: AskUserQuestion schema changes break SKILL.md (MEDIUM impact, LOW probability)

Claude Code updates could change AskUserQuestion parameter names or behavior.

**Mitigation**: Natural language instructions with parameter-name anchors (not literal JSON) degrade gracefully. If a parameter is renamed, the model will likely still understand the intent and adapt.

### Risk 3: Marker not created if branch creation is skipped (MEDIUM impact, LOW probability)

If the user is already on a non-main branch, the branch creation block is skipped. The marker creation instruction must be placed OUTSIDE this conditional.

**Mitigation**: Task 2's prompt explicitly instructs placing the marker AFTER the branch resolution decision, not inside it. The SKILL.md instruction says "After branch resolution (whether creating a new branch or using an existing one)".

### Risk 4: "Approve (Recommended)" may encourage rubber-stamping (LOW impact, MEDIUM probability)

Marking "Approve" as recommended could accelerate approval fatigue.

**Mitigation**: The decision brief (printed before AskUserQuestion) includes rationale, rejected alternatives, and confidence level -- these are the primary brakes on rubber-stamping. The calibration check (Decision Point 3) remains as a secondary brake.

### Risk 5: Two-step flow for "Request changes" adds friction (LOW impact, MEDIUM probability)

Users who previously typed "request changes: fix the naming" in one step now need to select "Request changes" then type their feedback in a follow-up.

**Mitigation**: Accept the tradeoff. The structured first step prevents misparses (the model interpreting feedback text as a gate command). The "Other" freeform input lets expert users type "request changes: fix the naming" in one shot if they prefer.

## Execution Order

```
Batch 1 (parallel, no dependencies):
  Task 1: Update SKILL.md decision points (devx-minion) [GATE]
  Task 2: Add orchestrated-session marker to commit hook (devx-minion)
  Task 3: Add AskUserQuestion guidance to ux-strategy-minion AGENT.md (ai-modeling-minion)
  Task 4: Add AskUserQuestion guidance to ai-modeling-minion AGENT.md (ai-modeling-minion)

APPROVAL GATE: Task 1 deliverable (SKILL.md decision points)
  Blocked: none (all other tasks are independent)

Post-execution (Phases 5-8): code review, tests, documentation
```

**Note on parallelism**: Tasks 1 and 2 both modify SKILL.md but touch different sections. Since they are assigned to the same agent (devx-minion), the agent handles both in sequence within a single execution context. Tasks 3 and 4 modify different files and can run fully in parallel with each other and with Tasks 1-2.

**Practical execution**: Since Tasks 1 and 2 share an agent, devx-minion handles them sequentially. Tasks 3 and 4 share ai-modeling-minion, so that agent also handles them sequentially. The two agents (devx-minion and ai-modeling-minion) run in parallel.

## Approval Gate: SKILL.md Decision Point Design

```
APPROVAL GATE: SKILL.md AskUserQuestion Decision Points
Agent: devx-minion | Blocked tasks: none (all other tasks are independent)

DECISION: Four nefario decision points converted from freeform text to
AskUserQuestion structured prompts with natural language parameter anchors.

RATIONALE:
- Approval gates (4 options): approve (recommended), request changes,
  reject (with secondary confirmation), skip. Brief printed above.
- Verification escalation (3 options): accept as-is (recommended), fix
  manually, skip verification. Ordered by disruption level.
- Calibration check (2 options): gates are fine (recommended), fewer gates.
  Converted from open-ended question to binary.
- PR creation (2 options): create PR (recommended), skip PR.
- REJECTED ALTERNATIVE: Including "approve --skip-post" as a visible 5th
  option at gates. Rejected because 5 options exceeds Hick's Law limits
  and tempts users to skip verification they should not skip. Accessible
  via "Other" freeform input instead.

IMPACT: Approving locks in the interaction pattern for all future nefario
sessions. Rejecting means decision points stay as freeform text (current
behavior).
DELIVERABLE: skills/nefario/SKILL.md
Confidence: HIGH (clear UX improvement, low risk, easy to iterate)
```

## Verification Steps

After all tasks complete:

1. **Read `skills/nefario/SKILL.md`** and verify:
   - Four decision points use AskUserQuestion instructions with parameter-name anchors
   - Compaction checkpoints are untouched
   - Reject has secondary confirmation AskUserQuestion
   - approve --skip-post is documented in brief text, not as a visible option
   - Orchestrated-session marker creation appears after branch resolution
   - Marker cleanup appears at wrap-up before returning to main

2. **Read `.claude/hooks/commit-point-check.sh`** and verify:
   - 3-line marker check appears after defer_marker check
   - Exit code is 0 (silent)
   - No other hook behavior is changed

3. **Read `docs/commit-workflow.md`** and verify:
   - New paragraph in Section 7 explains marker suppression

4. **Read `minions/ux-strategy-minion/AGENT.md`** and verify:
   - New "Structured Choice Presentation" subsection under Cognitive Load Management
   - Advisory tone, ~100 tokens
   - tools: frontmatter unchanged

5. **Read `minions/ai-modeling-minion/AGENT.md`** and verify:
   - New "Interactive Patterns in Skills" subsection under Multi-Agent Architecture
   - Advisory tone, mentions parameter-name anchors
   - tools: frontmatter unchanged
