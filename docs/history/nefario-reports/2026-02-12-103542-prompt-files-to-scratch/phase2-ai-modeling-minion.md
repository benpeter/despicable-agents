# Domain Plan Contribution: ai-modeling-minion

## Recommendations

**Option A (side-effect writing) is the correct choice.** The synthesis plan already chose this. My contribution confirms and strengthens that decision with LLM-specific reasoning that the other specialists may not have surfaced.

### Question 1: Context Window Pressure

The Task tool spawns a **separate agent with its own context window**. The prompt passed via the `prompt:` parameter becomes the user turn in the spawned agent's context -- it does not remain in the orchestrator's context after the call returns. The orchestrator retains only whatever it kept in its own session (the inline summary template, ~80-120 tokens).

This means: **inline prompt delivery has zero ongoing context pressure on the orchestrator.** Whether you pass 200 tokens or 2,000 tokens in the `prompt:` field, the orchestrator's context window is unaffected after the subagent completes. The prompt is fire-and-forget from the orchestrator's perspective.

File-reference delivery would actually be *worse* for the orchestrator's context: the orchestrator still constructs the full prompt in its reasoning (it has to write the file), then constructs a second artifact (the 3-line preamble). Both artifacts consume orchestrator generation tokens. The file write is an additional tool call round-trip. Net effect: more orchestrator context consumed, not less.

### Question 2: Agent Reliability with File-Reference Instructions

LLM agents are generally reliable at following "read your instructions from this file" patterns -- the Read tool is well-understood and Claude follows file-read instructions consistently. The risk is not that the agent *fails* to read the file. The risks are:

1. **Partial instruction following**: The agent receives a 3-line preamble ("You are X. Read your full instructions from Y. Write output to Z.") and a full AGENT.md system prompt loaded by Claude Code. If the file read fails (path typo, permission issue, race condition with mktemp), the agent has just enough context from the preamble and its system prompt to *plausibly attempt the task* -- but with hallucinated instructions rather than the carefully constructed prompt. This is a **silent degradation** failure mode. The agent produces output that looks structurally correct but misses task-specific context, planning questions, and codebase references. The orchestrator has no reliable way to detect this without parsing the agent's output for expected content markers.

2. **Instruction dilution**: When instructions arrive via an active retrieval step (agent reads a file) rather than the primary prompt channel, they compete with the agent's system prompt for attention. The system prompt (AGENT.md) is always present and always cached. File-retrieved instructions are injected mid-conversation as a Read tool result. In the attention hierarchy, system prompt content has higher salience than tool output content. With inline delivery, the prompt IS the user turn -- it gets full attention weight. With file-reference delivery, the prompt is mediated through a tool call, which empirically receives slightly less consistent adherence for nuanced instructions.

3. **Extra latency and token cost**: Each file read adds one tool call round-trip (~200-500ms depending on file size) plus the tokens to process the Read tool's output. For a 6-agent Phase 2 run in parallel, this is 6 additional Read calls. The latency is absorbed by parallelism, but the token cost is real: each agent now processes the prompt content as tool output (with line number prefixes from the Read tool adding ~15% token overhead) instead of as a clean user message.

**Bottom line**: File-reference delivery works but introduces a failure mode (silent degradation on read failure) that inline delivery cannot have. The inline prompt is structurally guaranteed to reach the agent.

### Question 3: Prompt Fidelity

There is an LLM-specific reason to prefer inline delivery: **content in the `prompt:` parameter of the Task tool becomes the user turn in the spawned agent's conversation.** This is the highest-fidelity channel for task-specific instructions. The attention pattern for user turns is:

```
system prompt (AGENT.md)  -->  cached, stable, role-defining
user turn (prompt:)        -->  fresh, task-specific, highest attention
```

When instructions arrive via a file read instead, the conversation structure becomes:

```
system prompt (AGENT.md)  -->  cached, stable, role-defining
user turn (3-line preamble) -->  minimal, mostly a routing instruction
assistant turn (tool call)  -->  "I'll read the file"
tool result (file content)  -->  the actual instructions, but in tool-result position
```

Tool results receive strong but not maximal attention. For simple, well-structured instructions this difference is negligible. For complex prompts with nuanced constraints (Phase 3 synthesis with conflict resolutions, Phase 4 execution prompts with advisory notes folded in), the positional advantage of user-turn delivery matters. The model is fine-tuned to treat the user turn as the primary request; tool results are supporting evidence.

This is not a dramatic difference -- maybe 2-5% adherence gap on complex multi-constraint prompts -- but it compounds across agents and phases. Side-effect writing preserves the optimal delivery channel at zero cost.

### Question 4: Multi-Agent Pattern Recommendation

In multi-agent architectures, the pattern that consistently produces the best outcomes is: **construct the prompt once, deliver it directly, persist it separately.** This is exactly what Option A does.

The anti-pattern is introducing indirection between prompt construction and prompt delivery. Every layer of indirection (write to file, pass reference, agent reads file) is a potential point of divergence, failure, or degradation. The only reason to accept that indirection is if it solves a real problem -- and the problems it would solve here (context pressure, single source of truth) are either non-existent (context pressure, as analyzed above) or already solved by the side-effect approach (persistence for transparency).

The "single source of truth" argument for Option B is seductive but misleading. The actual source of truth for what an agent received is the prompt that was passed to it. A file that was written and then referenced is not more truthful than a file that was written from the same variable that was passed inline -- both reflect the same constructed prompt. The difference is that with Option A, the file is guaranteed to match what the agent received (same variable, same moment). With Option B, the file IS what the agent must retrieve, but the retrieval itself can fail, introducing a gap between what exists and what was consumed.

## Proposed Tasks

No new tasks proposed. The synthesis plan's single-task approach (devx-minion updates SKILL.md and TEMPLATE.md) is correct. My contribution validates the design decision, not the implementation.

If the user overrides and requests file-reference delivery (Option B), the implementation complexity increases: every phase's Task block prompt template must change, error handling for failed file reads must be specified, and a fallback behavior (what does the agent do if the file read fails?) must be defined. This would warrant a second task for testing the new delivery pattern in a dry-run orchestration.

## Risks and Concerns

1. **Issue text mismatch (medium risk, already flagged)**: The synthesis correctly flags that side-effect writing does not literally satisfy the issue's "agents read their prompt from the file" criterion. From an LLM integration perspective, I want to emphasize: the literal criterion describes a *worse* delivery mechanism. If the user insists on it for auditability reasons ("I want proof the agent used exactly this file"), the counter-argument is that inline delivery is actually MORE auditable -- the prompt is structurally guaranteed to reach the agent, whereas file-reference delivery requires trusting that the agent successfully read and followed the file.

2. **No risk of prompt/file divergence (confirming non-risk)**: The synthesis mentions this as a theoretical con of Option A. In practice, writing a variable to a file and passing the same variable to the Task tool in the same code block cannot diverge. The LLM orchestrator constructs the prompt, writes it, then passes it. There is no async mutation path. This is a non-risk.

## Additional Agents Needed

None. The current team (devx-minion for implementation, ux-strategy-minion for UX perspective, ai-modeling-minion for LLM-specific tradeoffs) covers the decision space adequately. The architecture reviewers (lucy, margo, security, etc.) will validate in Phase 3.5.
