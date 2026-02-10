# Meta-Plan: Improve Nefario Skill UX with Structured Prompts and Quieter Commit Hooks

## Planning Consultations

### Consultation 1: Interactive Decision UX for Multi-Phase Orchestration

- **Agent**: ux-strategy-minion
- **Planning question**: The nefario orchestration skill has five user-facing decision points: (1) approval gates with `Reply: approve / request changes / reject / skip`, (2) compaction checkpoints with `type continue`, (3) PR creation with `(Y/n)`, (4) verification issue escalation with `Options: fix manually / accept as-is / skip remaining verification`, and (5) calibration check after 5 consecutive approvals. We want to convert these from freeform text prompts to Claude Code's `AskUserQuestion` tool, which presents structured multiple-choice options (users can always select "Other" for free text). What is the optimal way to structure these decision points? Consider: cognitive load of each decision, whether multiSelect is appropriate anywhere, which option should be "(Recommended)" for each, and how the flow should handle the "Other" escape hatch. Also assess: the compaction checkpoint is deliberately excluded from this change (requires user to run `/compact`) -- does this create a UX inconsistency, and if so, how should we handle it?
- **Context to provide**: Full SKILL.md (at `/Users/ben/.claude/skills/nefario/SKILL.md`), focusing on the five decision point locations (lines 288-303 for compaction, 454-486 for approval gates, 578-584 for verification escalation, 510-513 for calibration check, 678-681 for PR creation). AskUserQuestion supports `question`, `options` array, `multiSelect: true`, and "(Recommended)" labels.
- **Why this agent**: UX strategy expertise in cognitive load management, progressive disclosure, and decision point design. This agent can evaluate whether the current freeform approach is truly the pain point or if the decision structure itself needs rethinking, and can apply Hick's Law and satisficing principles to option design.

### Consultation 2: AskUserQuestion Tool Integration in Agent System Prompts

- **Agent**: ai-modeling-minion
- **Planning question**: We want to add guidance to the ux-strategy-minion and ai-modeling-minion AGENT.md files about preferring Claude Code's `AskUserQuestion` tool for interactive flows in agent-designed systems. Two questions: (1) What is the correct way to reference `AskUserQuestion` in an agent system prompt -- should it be prescriptive ("always use AskUserQuestion for decision points") or advisory ("prefer AskUserQuestion when presenting choices")? How does this interact with the `tools:` allowlist in agent frontmatter? (2) For the nefario SKILL.md specifically, how should the structured prompts be specified in the skill instructions so that the executing session (which has access to AskUserQuestion natively) uses them correctly? Should the SKILL.md contain literal `AskUserQuestion` tool call specifications, or natural language instructions that the session will interpret?
- **Context to provide**: Current ux-strategy-minion AGENT.md (at `/Users/ben/github/benpeter/despicable-agents/minions/ux-strategy-minion/AGENT.md`), ai-modeling-minion AGENT.md (at `/Users/ben/github/benpeter/despicable-agents/minions/ai-modeling-minion/AGENT.md`), SKILL.md (at `/Users/ben/.claude/skills/nefario/SKILL.md`). Note that the ux-strategy-minion's `tools:` list does not currently include `AskUserQuestion`. Note that the SKILL.md is executed by the main Claude Code session, not by nefario as an agent -- the main session has full tool access.
- **Why this agent**: Expert in Claude Code API behavior, prompt engineering for tool use, and multi-agent architecture. Knows how tool allowlists work, how SKILL.md instructions translate to tool calls, and the right level of specificity for tool use guidance in system prompts.

### Consultation 3: Commit Hook Noise Suppression

- **Agent**: devx-minion
- **Planning question**: The nefario orchestration skill triggers git commits during execution (auto-commit after gate approval, wrap-up commit). The user reports that "the git commit hook floods the main session with noise." Looking at the project's hook configuration (`.claude/settings.json`), there are two Claude Code hooks: a `Stop` hook (`commit-point-check.sh`) and a `PostToolUse` hook on Write/Edit (`track-file-changes.sh`). The Stop hook outputs lengthy stderr instructions when uncommitted changes are detected, which surfaces in the conversation. The PostToolUse hook is silent (exit 0). During orchestrated sessions, the SKILL.md drives auto-commits directly (not via the Stop hook), but the Stop hook may still fire when agents finish sub-tasks or when the session pauses. How should we suppress or minimize this noise? Options include: (a) having the Stop hook detect orchestrated sessions and exit silently, (b) redirecting stderr output in the hook, (c) making the hook output more concise, (d) disabling the Stop hook during orchestrated runs via a session marker. What is the cleanest approach that preserves the hook's value for single-agent sessions while eliminating noise during orchestrated runs?
- **Context to provide**: `.claude/settings.json` (at `/Users/ben/github/benpeter/despicable-agents/.claude/settings.json`), `commit-point-check.sh` (at `/Users/ben/github/benpeter/despicable-agents/.claude/hooks/commit-point-check.sh`), `track-file-changes.sh` (at `/Users/ben/github/benpeter/despicable-agents/.claude/hooks/track-file-changes.sh`), `commit-workflow.md` (at `/Users/ben/github/benpeter/despicable-agents/docs/commit-workflow.md`), SKILL.md Phase 4 auto-commit section.
- **Why this agent**: CLI design and developer experience specialist. Understands hook composition patterns, session detection, and the tradeoff between information density and noise in CLI output. Can evaluate whether the hook should be smarter or whether the orchestration should manage the hook lifecycle.

### Cross-Cutting Checklist

- **Testing**: Include test-minion for planning? **No.** The deliverables are SKILL.md (a markdown instruction file), bash hook scripts, and AGENT.md system prompts. None produce executable code that can be unit-tested. The hook script changes are minimal (adding a conditional exit). Manual validation during a nefario run is the appropriate verification, not automated tests.
- **Security**: Include security-minion for planning? **No.** No new attack surface, authentication, user input processing, or dependency changes. The commit hook changes are additive guards (exit earlier in more cases). The SKILL.md changes affect prompt formatting, not security boundaries.
- **Usability -- Strategy**: **ALWAYS include.** Covered by Consultation 1 (ux-strategy-minion). Planning question addresses cognitive load, decision structure, and flow consistency across all five decision points.
- **Usability -- Design**: Include ux-design-minion / accessibility-minion for planning? **No.** No user-facing interfaces are being created. The "UI" here is text-based Claude Code conversation output. The AskUserQuestion tool's rendering is controlled by Claude Code itself, not by us.
- **Documentation**: **ALWAYS include.** However, the documentation impact is minimal -- SKILL.md is itself the documentation for the skill's behavior. No separate docs need updating since the changes are internal to the orchestration flow. **Defer to Phase 8** rather than consulting software-docs-minion during planning. The commit-workflow.md may need a small update if the hook behavior changes, but that is a mechanical update best handled in execution.
- **Observability**: Include observability-minion / sitespeed-minion for planning? **No.** No runtime components, services, or APIs are being created or modified.

### Anticipated Approval Gates

1. **AskUserQuestion decision point design** (produced by execution, informed by ux-strategy-minion planning): The specific option structures for all five decision points. This is a MUST gate because it affects every future nefario run (high blast radius, moderate reversibility -- changing prompt structure after users learn it creates friction). Downstream: all SKILL.md edits depend on this design.

2. **Hook noise suppression approach** (produced by execution, informed by devx-minion planning): The mechanism chosen for suppressing commit hook output during orchestrated sessions. This is an OPTIONAL gate -- it is easy to reverse (config/script change) but has moderate blast radius (affects all orchestrated AND single-agent sessions if done wrong).

Gate budget: 1-2 gates (well within the 3-5 target).

### Rationale

Three specialists are consulted because the task spans three distinct domains:

1. **ux-strategy-minion** -- The core of this task is UX: converting freeform prompts to structured decisions. This is a cognitive load and interaction design problem, not a code problem. The ux-strategy-minion can evaluate whether AskUserQuestion is the right tool for each decision point and design the option structures.

2. **ai-modeling-minion** -- The secondary concern is how to correctly instruct Claude Code (via SKILL.md) to use AskUserQuestion, and how to generalize this pattern into agent system prompts. This is a prompt engineering and tool-use design problem.

3. **devx-minion** -- The hook noise problem is a developer experience issue in CLI tooling. The devx-minion understands hook composition, session detection patterns, and the balance between helpful output and noise.

Agents NOT consulted and why:
- **mcp-minion**: No MCP protocol work involved.
- **frontend-minion**: No UI components. AskUserQuestion is a native Claude Code tool.
- **software-docs-minion**: Documentation updates are mechanical and can be handled in execution. No architectural documentation decisions needed during planning.
- **security-minion**: No security surface changes.
- **lucy/margo**: These are Phase 3.5 reviewers, not planning consultants. They will review the synthesized plan.

### Scope

**What the task is trying to achieve**: Make the nefario orchestration skill's interactive experience smoother by (a) replacing freeform text decision prompts with Claude Code's native `AskUserQuestion` structured prompts, and (b) suppressing git commit hook output that clutters the orchestration conversation.

**In scope**:
- Nefario skill SKILL.md: convert all user decision points (except compaction) to use AskUserQuestion
- Git commit hook (`commit-point-check.sh`): add orchestrated-session detection to suppress noise
- ux-strategy-minion AGENT.md: add guidance on preferring AskUserQuestion for interactive flows
- ai-modeling-minion AGENT.md: add guidance on AskUserQuestion tool integration patterns
- commit-workflow.md: update if hook behavior changes

**Out of scope**:
- Compaction flow (explicitly excluded by task brief)
- Nefario planning logic (AGENT.md, delegation table, phases)
- Other skills (transcribe, obsidian-tasks, etc.)
- Other agent specs beyond ux-strategy-minion and ai-modeling-minion
- The AskUserQuestion tool itself (Claude Code native, not ours to modify)
- PostToolUse hook (track-file-changes.sh) -- already silent
