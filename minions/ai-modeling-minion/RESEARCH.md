# AI Modeling Minion - Domain Research

Comprehensive research backing the ai-modeling-minion system prompt. Covers
Anthropic API integration, prompt engineering, multi-agent architecture,
cost/latency optimization, output validation, and tool routing patterns.

---

## Table of Contents

1. [Anthropic API Reference](#1-anthropic-api-reference)
2. [Prompt Engineering for Claude](#2-prompt-engineering-for-claude)
3. [Prompt Caching](#3-prompt-caching)
4. [Model Selection and Characteristics](#4-model-selection-and-characteristics)
5. [Multi-Agent Architecture Patterns](#5-multi-agent-architecture-patterns)
6. [Output Validation and Structured Outputs](#6-output-validation-and-structured-outputs)
7. [Tool Routing Logic](#7-tool-routing-logic)
8. [Cost and Latency Optimization](#8-cost-and-latency-optimization)
9. [Context Engineering](#9-context-engineering)
10. [Error Handling and Resilience](#10-error-handling-and-resilience)
11. [System Prompt Design Patterns](#11-system-prompt-design-patterns)
12. [Sources](#12-sources)

---

## 1. Anthropic API Reference

### 1.1 Messages API

The Messages API is the primary interface for Claude model interaction.

**Endpoint**: `POST https://api.anthropic.com/v1/messages`

**Core parameters**:
- `model`: Model identifier (e.g., `claude-opus-4-6`, `claude-sonnet-4-5`, `claude-haiku-4-5`)
- `max_tokens`: Maximum output token count
- `system`: Array of system content blocks (text, with optional `cache_control`)
- `messages`: Array of user/assistant message turns
- `tools`: Array of tool definitions
- `tool_choice`: Tool selection strategy (`auto`, `any`, or force a specific tool)
- `output_config`: Output format configuration (structured outputs, effort control)
- `thinking`: Extended thinking configuration
- `stream`: Boolean for streaming responses

**Recent API changes (2025-2026)**:
- Structured outputs moved from beta to GA. Parameter path: `output_config.format`
- Strict tool use (`strict: true`) is GA on all models
- Fine-grained tool streaming is GA (no beta header required)
- Consecutive user/assistant messages are now auto-combined instead of erroring
- First input message no longer needs to be a user message
- Prefilled responses on last assistant turn deprecated for Opus 4.6+
- Tool Search Tool (beta): dynamic tool loading for large tool sets via `defer_loading: true`
- Adaptive thinking available on Opus 4.6: `thinking: {"type": "adaptive"}`
- Effort parameter for thinking depth control

### 1.2 Tool Use

Claude 4 models have built-in token-efficient tool use and parallel tool calling.

**Strict tool use** (`strict: true`) guarantees schema-validated tool parameters
via constrained decoding. The model literally cannot produce invalid tool
parameter JSON.

**Tool descriptions** are critical for agent performance. Each tool should be
self-contained with an unambiguous purpose and minimal overlap with other tools.
Poor tool descriptions derail agents more than poor system prompts.

**Tool Search Tool** allows Claude to work with hundreds or thousands of tools
by loading them on demand (`defer_loading: true`), keeping the active context
window small.

### 1.3 Streaming vs Non-Streaming

**Non-streaming** is preferred when:
- Output is small structured JSON (<500 tokens)
- Complete output is needed before processing (e.g., schema validation)
- Server-side processing patterns (MCP servers, API backends)

**Streaming** is preferred when:
- Interactive chat with visible text output
- Long-form content generation
- Time-to-first-token matters for UX

### 1.4 Extended Thinking

Extended thinking enables step-by-step internal reasoning before producing output.

- `thinking: {"type": "enabled", "budget_tokens": N}` -- explicit budget
- `thinking: {"type": "adaptive"}` -- model decides (Opus 4.6 only)
- Minimum budget: 1,024 tokens
- Adds latency; reserve for complex disambiguation or multi-step reasoning
- Not needed for simple intent classification or structured output tasks

---

## 2. Prompt Engineering for Claude

### 2.1 Claude 4.x Behavioral Model

Claude 4.x models (Sonnet 4.5, Opus 4.5, Opus 4.6) follow instructions
literally rather than inferring intent. Key implications:

- **Be explicit**: Specify exactly what you want. The model does what you ask,
  nothing more.
- **Explain why**: Provide context and motivation behind instructions. This helps
  Claude generalize to edge cases.
- **Examples beat rules**: When showing format, tone, or style expectations,
  examples are the most reliable mechanism.
- **XML tags**: Claude is fine-tuned to pay special attention to XML tags.
  Use `<instructions>`, `<context>`, `<examples>`, `<output_format>` to
  clearly separate sections.
- **Tell what to DO, not what NOT to do**: Positive framing produces better
  compliance.
- **Opus 4.6 specifics**: Reduce aggressive language around tool triggering.
  Prefer "Use this tool when..." over "CRITICAL: You MUST use this tool when..."

### 2.2 System Prompt Architecture

A well-structured system prompt follows this pattern:

```
You are [role]. [One sentence on core mission.]

Goal: [Success definition]
Constraints: [Hard boundaries]

<instructions>
[Explicit, numbered steps or rules]
</instructions>

<context>
[Domain knowledge, schemas, reference material]
</context>

<examples>
[3-5 diverse input/output pairs, including edge cases]
</examples>

<output_format>
[Exact specification of desired output structure]
</output_format>
```

**The 4-block pattern**: INSTRUCTIONS / CONTEXT / TASK / OUTPUT FORMAT.

### 2.3 Few-Shot Example Design

- 3-5 examples for constrained outputs, 10-15 for complex formatting
- Examples should be diverse and representative, covering edge cases
- Place examples in system prompt (cacheable) rather than user messages
- Include negative examples showing common mistakes and their corrections
- Combine chain-of-thought with few-shot for complex reasoning tasks

### 2.4 Dynamic Context Injection

Inject volatile runtime data (dates, user identifiers, session context) into
the **user message**, not the system prompt. This preserves cache efficiency
on the system prompt while keeping dynamic values fresh.

```
System: [static domain knowledge, examples -- cached]
User: "Today is 2026-02-09 (Sunday). User intent: {intent}"
```

### 2.5 Output Format Enforcement

Ranked by reliability:
1. **Structured outputs** (`output_config.format` with JSON schema) -- guaranteed
2. **Strict tool use** (`strict: true`) -- guaranteed for tool parameters
3. **XML wrapping** with explicit format instructions -- high reliability
4. **Few-shot examples** with format constraints -- good reliability
5. **Text instructions alone** -- lowest reliability

---

## 3. Prompt Caching

### 3.1 Mechanics

Prompt caching allows reuse of prompt prefixes across API calls:

1. Mark a content block with `cache_control: {"type": "ephemeral"}`
2. First request: full processing + cache write (1.25x base cost for 5m TTL)
3. Subsequent requests within TTL: cache read (0.1x base cost -- 90% discount)
4. Cache is refreshed on every use (no additional cost for refresh)

### 3.2 Cache Hierarchy

Caching follows the order: `tools` -> `system` -> `messages`. Changes at any
level invalidate that level and all subsequent levels.

**What invalidates cache**:
- Tool definition changes -> invalidates everything
- Web search or citations toggle -> invalidates system + messages
- Speed setting changes -> invalidates system + messages
- `tool_choice` changes -> invalidates messages only
- Image presence changes -> invalidates messages only
- Thinking parameter changes -> invalidates messages only

### 3.3 Minimum Cacheable Sizes

| Model | Minimum Tokens |
|-------|---------------|
| Opus 4.6, Opus 4.5 | 4,096 |
| Sonnet 4.5, Opus 4.1, Sonnet 4 | 1,024 |
| Haiku 4.5 | 4,096 |

### 3.4 TTL Options

| TTL | Cache Write Cost | Cache Read Cost | Best For |
|-----|-----------------|-----------------|----------|
| 5 minutes (default) | 1.25x base | 0.1x base | Frequent requests within 5 min |
| 1 hour | 2x base | 0.1x base | Infrequent requests, agentic workflows |

### 3.5 Breakpoints

- Up to 4 cache breakpoints per request
- Breakpoints themselves are free
- System automatically checks up to 20 blocks backward from each breakpoint
- Place breakpoints at the end of static content and before editable content

### 3.6 Pricing (Per Million Tokens)

| Model | Base Input | 5m Cache Write | 1h Cache Write | Cache Read | Output |
|-------|-----------|---------------|---------------|------------|--------|
| Opus 4.6 | $5 | $6.25 | $10 | $0.50 | $25 |
| Sonnet 4.5 | $3 | $3.75 | $6 | $0.30 | $15 |
| Haiku 4.5 | $1 | $1.25 | $2 | $0.10 | $5 |

### 3.7 Tracking Cache Performance

Response `usage` fields:
- `cache_creation_input_tokens`: tokens written to cache (first request)
- `cache_read_input_tokens`: tokens read from cache (subsequent)
- `input_tokens`: tokens after last cache breakpoint (always processed fresh)
- Total: `cache_read + cache_creation + input_tokens`

### 3.8 Workspace Isolation (Feb 2026)

Starting February 5, 2026, caches are isolated per workspace (not per
organization). Different workspaces within the same org do not share caches.

---

## 4. Model Selection and Characteristics

### 4.1 Current Model Lineup

| Feature | Opus 4.6 | Sonnet 4.5 | Haiku 4.5 |
|---------|----------|-----------|-----------|
| **API ID** | claude-opus-4-6 | claude-sonnet-4-5 | claude-haiku-4-5 |
| **Pricing (in/out)** | $5/$25 MTok | $3/$15 MTok | $1/$5 MTok |
| **Context window** | 200K / 1M (beta) | 200K / 1M (beta) | 200K |
| **Max output** | 128K tokens | 64K tokens | 64K tokens |
| **Latency** | Moderate | Fast | Fastest |
| **Extended thinking** | Yes | Yes | Yes |
| **Adaptive thinking** | Yes | No | No |
| **Knowledge cutoff** | May 2025 | Jan 2025 | Feb 2025 |

### 4.2 Selection Framework

| Use Case | Recommended Model | Rationale |
|----------|------------------|-----------|
| Simple intent classification | Haiku 4.5 | Fastest, cheapest, sufficient accuracy |
| Structured output generation | Haiku 4.5 | Cost-effective with constrained decoding |
| Complex multi-step reasoning | Opus 4.6 | Best reasoning capability |
| Agent orchestration | Opus 4.6 or Sonnet 4.5 | Needs planning and delegation skills |
| Code generation / review | Opus 4.6 | Highest coding benchmark scores |
| Balanced accuracy + cost | Sonnet 4.5 | Sweet spot for most production tasks |
| High-volume inner agent | Haiku 4.5 | Cost and latency critical |
| Agentic long-running tasks | Opus 4.6 | 128K output, 1M context, sustained operation |

### 4.3 Model Routing Pattern

Use different models for different parts of a pipeline:
- **Triage/classification**: Haiku 4.5 (fast, cheap)
- **Analysis/reasoning**: Sonnet 4.5 (balanced)
- **Complex/creative**: Opus 4.6 (most capable)

This "model cascade" or "model routing" pattern can reduce costs 2-5x versus
using the strongest model for everything.

### 4.4 Token Estimation

- ~1.33 tokens per English word
- ~1.5-2 tokens per word in other languages (longer words, compound nouns)
- JSON structure adds ~20-30% overhead vs plain text
- Emoji: typically 1-2 tokens each

---

## 5. Multi-Agent Architecture Patterns

### 5.1 Core Patterns

**Orchestrator-Worker (Primary Pattern)**:
A lead agent coordinates the process, delegating to specialized sub-agents that
operate in parallel. The orchestrator decomposes queries into subtasks, each
with an objective, output format, tool guidance, and clear boundaries.

**Inner/Outer Agent**:
The outer agent (e.g., Claude Code with Opus) has full conversation context and
makes high-level decisions. The inner agent (e.g., Haiku in an MCP server) is a
specialized, stateless interpreter. Each agent has its own system prompt, model,
and capabilities.

**Agents as Tools**:
Specialized agents are wrapped as callable functions that other agents can
invoke. All routing passes through the main agent.

**Sequential Pipeline**:
Agents chained in a predefined order, each processing the output of the previous
agent. Best for well-defined multi-step workflows.

**Concurrent Fan-Out**:
Multiple agents run simultaneously on the same task, each providing independent
analysis from their specialization. Results are synthesized by the orchestrator.

### 5.2 Design Principles (from Anthropic Engineering)

- Multi-agent systems work mainly because they help spend enough tokens on
  subtasks that benefit from focused attention
- Sub-agents should have clean context windows with condensed summaries returned
  to the orchestrator
- Each sub-agent needs: an objective, an output format, tool/source guidance,
  and clear task boundaries
- Use `plan_mode_required` for sub-agents that modify production code or
  security-sensitive files

### 5.3 Stateless Single-Turn Interpretation

For inner agents (e.g., embedded in MCP servers):
- No conversation history between calls
- Each request is independent: system prompt + user intent -> structured output
- Advantages: simpler, faster, cheaper, no context management
- Disadvantage: cannot ask clarifying questions
- Mitigation: return a structured `clarification_needed` response type

### 5.4 Agent-to-Agent Communication

**Key frameworks/protocols**:
- **Claude Code Agent Teams**: Multiple agents coordinate directly with others,
  splitting larger tasks into segmented jobs
- **Google A2A Protocol**: Open standard (Apache 2.0) for agent interoperability.
  Agent Cards describe capabilities in JSON, JSON-RPC 2.0 over HTTP(S)
- **MCP**: Tool-based communication between host applications and servers.
  Complementary to A2A (MCP is host-to-tool, A2A is agent-to-agent)

---

## 6. Output Validation and Structured Outputs

### 6.1 Structured Outputs (GA)

Structured outputs use constrained decoding to guarantee JSON schema compliance.

**How it works**: Your JSON schema is compiled into a grammar that restricts
token generation during inference. The model literally cannot produce tokens
that violate the schema.

**API usage**:
```json
{
  "output_config": {
    "format": {
      "type": "json_schema",
      "schema": { ... }
    }
  }
}
```

**Available on**: Haiku 4.5, Sonnet 4.5, Opus 4.5, Opus 4.6.

**Performance**: First request has 100-300ms grammar compilation overhead.
Compiled grammar is cached for 24 hours.

**Limitation**: Guarantees structural validity, not semantic accuracy. The model
can still produce perfectly formatted incorrect answers.

**SDK support**: Python SDK supports Pydantic models directly via `.parse()`.
TypeScript SDK supports Zod schemas.

### 6.2 Three-Layer Validation Strategy

1. **Constrained decoding** (structured outputs / strict tool use): Guarantees
   valid structure at generation time. Prevents malformed JSON entirely.

2. **Schema validation** (post-generation): Validate output against Zod/Pydantic
   schemas after generation. Catches semantic issues that structural validation
   misses (e.g., field value ranges, cross-field consistency).

3. **Business logic validation**: Domain-specific rules (valid date ranges,
   known enum values, referential integrity). Example: verify a date string
   represents a valid future date, not just a matching regex.

### 6.3 Error Recovery

- **Primary**: Use structured outputs to prevent malformed JSON entirely
- **Retry with feedback**: If output fails validation, re-prompt with the error:
  "Your previous output was invalid: {error}. Please correct."
  Maximum 2 retries.
- **Deterministic fallback**: After retries exhausted, bypass LLM and return a
  safe default or error response
- **Circuit breaker**: After N consecutive failures, bypass LLM temporarily

### 6.4 Strict Tool Use

Add `strict: true` to tool definitions to guarantee schema-valid tool parameters.
Can be combined with structured outputs in the same request.

---

## 7. Tool Routing Logic

### 7.1 Core Principle

The LLM selects the tool; the tool executes deterministically. Variance is
confined to the selection, not the runtime behavior.

**Reserve LLM reasoning for decisions** that deterministic programs cannot make:
diagnosis, interpretation, and connection across contexts. Delegate execution
to deterministic systems.

### 7.2 When to Use LLM vs Deterministic Code

**LLM**:
- Natural language intent with ambiguous phrasing
- Contextual reasoning needed (relative dates, implicit references)
- Multiple valid interpretations requiring judgment
- New/unknown intent types not covered by deterministic rules

**Deterministic**:
- Structured API calls with all fields present
- Known patterns with reliable regex/keyword extraction
- Simple CRUD operations with explicit parameters
- Speed-critical paths where LLM latency is unacceptable

### 7.3 Routing Implementation Patterns

**Pure code routing** (simplest):
```
if input.has_all_required_fields -> deterministic
if input.is_natural_language -> LLM
default -> LLM
```

**Hybrid pattern-matching** (recommended for most cases):
- Run regex/keyword detection first (fast, deterministic, cheap)
- Fall through to LLM only for genuinely ambiguous inputs
- Example: "create task: Buy groceries due tomorrow" can be parsed without LLM

**LLM-based routing** (most flexible):
- Use the LLM itself to classify intent before processing
- More flexible but slower and costlier
- Appropriate when intent categories are highly dynamic

### 7.4 Decision Diagram

```
Input received
  |
  v
Structured API call with all fields? -> YES -> Deterministic handler
  |
  NO
  v
Pattern-matchable (regex/keyword)? -> YES -> Deterministic handler
  |
  NO
  v
LLM interpretation -> Structured output -> Handler
```

---

## 8. Cost and Latency Optimization

### 8.1 Cost Reduction Hierarchy (by impact)

1. **Prompt caching** (highest impact): 90% savings on cache hits. The single
   most important cost lever for systems with stable system prompts.

2. **Model selection**: Haiku 4.5 is 5x cheaper than Opus 4.6 for input and
   output. Use the cheapest model that meets accuracy requirements.

3. **Deterministic bypass**: Avoid LLM calls entirely for well-structured
   inputs. Zero cost, zero latency.

4. **Output length control**: Tight `max_tokens`. Structured outputs prevent
   verbose explanations. Shorter outputs = less generation time and cost.

5. **Prompt compression**: Remove filler, condense instructions, use
   abbreviations. 15-30% token reduction without quality loss.

6. **Batch API**: 50% discount for non-urgent batch processing.

7. **Model routing/cascade**: Use cheap model for triage, expensive model only
   for complex cases. 2-5x cost reduction for mixed workloads.

### 8.2 Cost Estimation Template

```
Per-request cost (cache hit, Haiku 4.5):
  Cached system prompt: {N} tokens * $0.10/MTok = ${...}
  Fresh user input: {M} tokens * $1.00/MTok = ${...}
  Output: {O} tokens * $5.00/MTok = ${...}
  Total: ~${...} per request

Monthly at {R} requests/day:
  ${total} * {R} * 30 = ${monthly}
```

### 8.3 Latency Optimization

1. **Model selection**: Haiku 4.5 has fastest TTFT (~0.5s)
2. **Prompt caching**: Reduces latency up to 85% for long prompts
3. **Tight max_tokens**: Less generation time
4. **Skip extended thinking**: For simple tasks, thinking adds latency
   without proportional quality gains
5. **Non-streaming**: For small structured outputs, avoids streaming overhead
6. **Connection reuse**: Keep HTTP connections alive between API calls
7. **Prompt minimization**: Every extra input token adds to TTFT

### 8.4 Rate Limiting

Anthropic uses a token bucket algorithm with three limits:
- Requests per minute (RPM)
- Input tokens per minute (ITPM) -- cached tokens do NOT count
- Output tokens per minute (OTPM)

**Monitoring headers**:
- `anthropic-ratelimit-requests-remaining`
- `anthropic-ratelimit-tokens-remaining`
- `anthropic-ratelimit-requests-reset`

Proactively throttle when remaining limits are low rather than waiting for 429s.

---

## 9. Context Engineering

### 9.1 Core Principle

Context is a finite, precious resource. Context engineering is the process of
optimizing the utility of tokens against inherent LLM constraints to
consistently achieve desired outcomes.

### 9.2 Strategies

**Just-in-time context retrieval**: Use lightweight identifiers and load full
data on demand. Do not pre-load everything into the context window.

**Progressive disclosure**: Let agents incrementally discover context. Start
with summaries, drill into details only when needed.

**Sub-agent architecture**: Specialized agents with clean context windows,
returning condensed summaries to the orchestrator. Each sub-agent sees only
what it needs.

**Compaction**: Summarize conversation history when approaching context limits.
Older turns get progressively condensed.

**Token-efficient tools**: Design tools to return minimal, structured data.
Filter and process data before it reaches the model.

**Code execution with MCP**: Execute complex logic in a single tool step
rather than consuming context tokens for intermediate reasoning.

### 9.3 Multi-Context Window Management

For long-running agents spanning hours or days:
- Use a different prompt for the first context window that sets up the
  environment with all necessary context
- Each subsequent context window receives a condensed summary of prior work
- Harness structure manages state persistence across windows

---

## 10. Error Handling and Resilience

### 10.1 Error Types and Strategies

| Error | Code | Strategy |
|-------|------|----------|
| Rate limit | 429 | Exponential backoff with `retry-after` header |
| Server overload | 529 | Exponential backoff starting at 1s |
| Timeout | - | Retry with same parameters; consider shorter prompt |
| Malformed output | - | Retry with error feedback; fallback to deterministic |
| Content refusal | 200 (stop_reason: refusal) | Return error to caller; do not retry |
| Max tokens hit | 200 (stop_reason: max_tokens) | Increase max_tokens or restructure output |

### 10.2 Retry Pattern

```
attempt = 0
while attempt < max_retries:
  try:
    response = call_api(params)
    if response.stop_reason == "refusal": return error (do not retry)
    if response.stop_reason == "max_tokens": adjust and retry
    validate(response) -> success or retry with error feedback
  catch 429: wait retry-after or exponential backoff
  catch 529: exponential backoff
  catch other: propagate
  attempt++
return fallback_response
```

### 10.3 Circuit Breaker

After N consecutive failures (e.g., 5):
- Bypass LLM entirely
- Return deterministic fallback
- Log alert for investigation
- Reset after cooldown period

### 10.4 Proactive Monitoring

- Read `anthropic-ratelimit-requests-remaining` to preemptively throttle
- Track cache hit rates to detect cache invalidation issues
- Monitor per-request cost to catch unexpected cost spikes
- Log `stop_reason` distribution to detect model behavior changes

---

## 11. System Prompt Design Patterns

### 11.1 Prompt-as-Contract

A good system prompt reads like a short contract:
- **Role**: Who the agent is
- **Goal**: What success looks like
- **Constraints**: Hard boundaries (what the agent must not do)
- **Output format**: Exact specification of desired output structure

### 11.2 Prompt Versioning

- Treat prompts like code: version control, code review, testing
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Decouple prompts from application code (store as separate files)
- Immutability: once a version is created, never modify it
- Test against a suite of representative inputs before deploying

### 11.3 Prompt Testing

- Maintain 50+ input-output test pairs
- Run all inputs against new prompt version
- Compare outputs using LLM-as-judge or exact match
- Gate deployment on test pass rate (e.g., >95%)
- Use small-sample testing (20 queries) for quick iteration during development

### 11.4 Automated Prompt Optimization

Recent approaches (2025-2026):
- Feedback-driven iteration using error analysis and LLM-generated hints
- Evolutionary prompt engineering with mutation/selection cycles
- "Prompt Learning" using natural language feedback for iterative improvement
- Achievable improvements: 9-37% depending on domain

---

## 12. Sources

### Official Anthropic Documentation
- [Messages API](https://platform.claude.com/docs/en/api/messages)
- [Prompt Caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
- [Structured Outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)
- [Tool Use Overview](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
- [Tool Use Implementation](https://platform.claude.com/docs/en/agents-and-tools/tool-use/implement-tool-use)
- [Models Overview](https://platform.claude.com/docs/en/about-claude/models/overview)
- [Choosing a Model](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model)
- [Pricing](https://platform.claude.com/docs/en/about-claude/pricing)
- [Prompt Engineering Overview](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview)
- [Claude Prompting Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- [Claude 4 Best Practices](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Extended Thinking](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
- [Advanced Tool Use](https://www.anthropic.com/engineering/advanced-tool-use)

### Anthropic Engineering Blog
- [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [How We Built Our Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

### Anthropic Announcements
- [Introducing Claude Opus 4.6](https://www.anthropic.com/news/claude-opus-4-6)
- [Claude Developer Platform Release Notes](https://platform.claude.com/docs/en/release-notes/overview)

### Multi-Agent Patterns
- [Google A2A Protocol](https://github.com/a2aproject/A2A) (Apache 2.0)
- [Google ADK Multi-Agent Patterns](https://developers.googleblog.com/developers-guide-to-multi-agent-patterns-in-adk/)
- [OpenAI Agents SDK - Orchestrating Multiple Agents](https://openai.github.io/openai-agents-python/multi_agent/)
- [Microsoft AI Agent Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns)
- [LangChain Multi-Agent Docs](https://docs.langchain.com/oss/python/langchain/multi-agent)

### Prompt Engineering Resources
- [Anthropic Interactive Prompt Engineering Tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial)
- [Prompt Builder: Claude Best Practices 2026](https://promptbuilder.cc/blog/claude-prompt-engineering-best-practices-2026)
- [Prompt Engineering for LLMs (DextraLabs)](https://dextralabs.com/blog/prompt-engineering-for-llm/)

### Cost Optimization
- [LLM Cost Optimization Guide (Koombea)](https://ai.koombea.com/blog/llm-cost-optimization)
- [Cost-Effective LLM Applications (Glukhov)](https://www.glukhov.org/post/2025/11/cost-effective-llm-applications/)
- [LLM Cost Optimization 2026 (ByteIota)](https://byteiota.com/llm-cost-optimization-stop-overpaying-5-10x-in-2026/)
- [Prompt Compression for LLMs (MLM)](https://machinelearningmastery.com/prompt-compression-for-llm-generation-optimization-and-cost-reduction/)

### Structured Output and Validation
- [Hands-On Guide to Anthropic Structured Outputs (TDS)](https://towardsdatascience.com/hands-on-with-anthropics-new-structured-output-capabilities/)
- [Zero-Error JSON with Claude (Medium)](https://medium.com/@meshuggah22/zero-error-json-with-claude-how-anthropics-structured-outputs-actually-work-in-real-code-789cde7aff13)
- [Structured Output Guide (Agenta)](https://agenta.ai/blog/the-guide-to-structured-outputs-and-function-calling-with-llms)

### Tool Routing and Agent Design
- [Everything Deterministic Should Be (Vexjoy)](https://vexjoy.com/posts/everything-that-can-be-deterministic-should-be-my-claude-code-setup/)
- [Agent System Design Patterns (Databricks)](https://docs.databricks.com/aws/en/generative-ai/guide/agent-system-design-patterns)
- [MCP LLM Patterns: Routers, Tool Groups](https://www.elasticpath.com/blog/mcp-magic-moments-guide-to-llm-patterns)

### Prompt Management
- [Prompt Versioning Best Practices (Latitude)](https://latitude-blog.ghost.io/blog/prompt-versioning-best-practices/)
- [Definitive Guide to Prompt Management (Agenta)](https://agenta.ai/blog/the-definitive-guide-to-prompt-management-systems)

### Error Handling
- [Retries, Fallbacks, and Circuit Breakers (Portkey)](https://portkey.ai/blog/retries-fallbacks-and-circuit-breakers-in-llm-apps/)
- [LLM Challenges: Retry Logic (TableFlow)](https://tableflow.com/blog/handling-llm-challenges)
