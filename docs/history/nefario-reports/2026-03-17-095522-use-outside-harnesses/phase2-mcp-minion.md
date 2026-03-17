## Domain Plan Contribution: mcp-minion

### Recommendations

#### 1. MCP is the wrong abstraction layer for orchestrator-to-harness communication

MCP connects an LLM host to tools and context. In MCP's architecture, the
orchestrating session is the **host/client** and external coding tools would be
**servers**. The protocol is designed for the model to invoke discrete,
short-lived tool calls -- read a file, query a database, send a message. It is
not designed for delegating multi-minute, multi-file coding tasks with
intermediate progress, approval gates, and structured result collection.

The experimental **Tasks primitive** (SEP-1686, spec 2025-11-25) partially
addresses the duration gap -- it enables call-now-fetch-later semantics with a
durable state machine (working / input_required / completed / failed /
cancelled). However, Tasks are still experimental (retry semantics and expiry
policies are open questions), and they only solve the *duration* problem, not
the *delegation semantics* problem: MCP Tasks do not model agent identity,
skill advertisement, multi-turn conversation, or structured handback of
deliverables (file lists, change summaries, approval-gate metadata).

**Verdict**: MCP should not be the inter-agent communication layer between the
orchestrator and external coding tools.

#### 2. MCP's value is on the *tool side*, not the *delegation side*

Where MCP does matter for this project:

- **External tools as MCP servers**: Cursor, Codex CLI, Windsurf, and Cline all
  support MCP *as clients* -- they can consume MCP servers. This means the
  orchestrator could expose context (repo state, task prompts, constraint files)
  via an MCP server that any harness can consume. This is a useful pattern for
  providing harnesses with shared context, but it is orthogonal to the
  delegation question.

- **Claude Code as MCP server**: `claude mcp serve` exposes Claude Code's file
  editing and Bash tools via MCP. Other MCP clients (Cursor, Windsurf) can
  invoke Claude Code through this interface. But this is the *reverse* of what
  we need -- it exposes Claude Code's tools to others, not the other way around.

- **External tools as MCP servers wrapping harnesses**: A thin MCP server could
  wrap Aider, Cursor, or Codex CLI, exposing a `code_task` tool. The
  orchestrator (Claude Code) would invoke this tool via its MCP client
  capabilities. This is technically feasible today but has serious DX and
  lifecycle issues (see Risks). Multiple community MCP servers already exist for
  Aider (disler/aider-mcp-server, sengokudaikon/aider-mcp-server,
  eiliyaabedini/aider multi-coder). These demonstrate that MCP-wrapping works
  at the tool-call level but they do not solve orchestration concerns.

#### 3. A2A (Agent-to-Agent Protocol) is architecturally closer to the delegation model

Google's A2A protocol (v0.3, under Linux Foundation / AAIF since Dec 2025)
is explicitly designed for the pattern we need:

| Feature | A2A | MCP | Current Subagents |
|---------|-----|-----|-------------------|
| Task lifecycle | Explicit states (working, input-required, completed, failed, cancelled, rejected) | Experimental Tasks primitive | Implicit via TaskList polling |
| Agent discovery | Agent Cards (JSON: identity, capabilities, skills, auth) | Server capability negotiation | Hardcoded delegation table |
| Progress monitoring | SSE streaming + polling + push notifications (webhooks) | SSE for tool progress, Tasks for async polling | TaskList + SendMessage |
| Multi-turn interaction | Send follow-up messages to same taskId | Not native -- tools are one-shot | SendMessage bidirectional |
| Result format | Artifacts (typed content parts) attached to Tasks | Tool call return (content array) | Free-form text via SendMessage |
| Transport | JSON-RPC 2.0 over HTTPS, SSE, gRPC (v0.3+) | JSON-RPC 2.0 over stdio or Streamable HTTP | Claude Code internal |

A2A's task lifecycle maps cleanly to nefario's execution model:
- `working` = agent executing batch task
- `input_required` = mid-execution approval gate or clarification needed
- `completed` = deliverable ready for gate review
- `failed` = agent error requiring escalation
- `cancelled` = user rejected at gate

A2A's Agent Card maps to the delegation table -- each harness publishes what it
can do, what models it supports, and how to authenticate.

**However**: A2A adoption in coding tools is currently near zero. No major
coding tool (Cursor, Aider, Codex CLI, Windsurf, Cline) exposes an A2A
endpoint. The protocol has strong enterprise/Google Cloud adoption but has not
penetrated the developer tooling space. Building A2A adapters for each tool
would require the same wrapper effort as MCP, with less ecosystem momentum in
this domain.

#### 4. The report should model a three-layer protocol stack

The research report should not frame this as "MCP vs A2A" but as three
distinct layers, each with its own protocol concerns:

```
Layer 3: Orchestration Protocol (delegation, lifecycle, results)
         -- How tasks are assigned, monitored, and completed
         -- A2A is the closest standard; custom protocol is the pragmatic choice

Layer 2: Context Sharing Protocol (repo state, constraints, prompts)
         -- How harnesses receive task context and constraints
         -- MCP resources/prompts are well-suited here

Layer 1: Process Invocation (starting/stopping harness processes)
         -- How the orchestrator launches and manages harness processes
         -- stdio, subprocess, HTTP -- transport-level concern
```

The current subagent model collapses all three layers into Claude Code's
internal Task/SendMessage/TaskList mechanism. Externalizing harnesses requires
making each layer explicit.

#### 5. Result collection protocol requirements

For the orchestrator to consume results from external harnesses (whatever the
delegation mechanism), the protocol must support:

1. **Structured deliverable metadata**: File paths changed, line counts, change
   scope (new/modified/deleted). Currently produced by subagents via free-text
   SendMessage; needs formalization.

2. **Completion signal**: Unambiguous "I am done" signal distinguishable from
   "I am still working" and "I need input". MCP tool calls have implicit
   completion (return = done). A2A has explicit task states. Subprocess exit
   codes work for batch-mode tools.

3. **Error propagation with context**: Not just "failed" but *why* -- model
   context exceeded, API rate limited, permission denied, test failure. Needs
   structured error categories the orchestrator can act on (retry vs. escalate
   vs. abort).

4. **Progress streaming**: For long-running tasks, intermediate status (files
   touched so far, current phase). MCP Streamable HTTP SSE can carry this. A2A
   SSE streaming is purpose-built for it.

5. **Git state handback**: External harnesses operating on the same worktree
   need to communicate what they committed (commit hashes, branch state). This
   is domain-specific and not covered by any protocol -- it must be part of the
   wrapper contract.

### Proposed Tasks

#### Task 1: Protocol Landscape Section

**What**: Write the protocol landscape section of the research report covering
MCP, A2A, and the three-layer model described above.

**Deliverables**: Section in `docs/external-harnesses.md` (or whatever the
report is named) covering:
- MCP's architecture, primitives, and why it does not fit the delegation layer
- MCP Tasks primitive status and limitations for long-running coding work
- A2A's architecture, task lifecycle, Agent Cards, and fit for delegation
- The three-layer protocol stack model
- Comparison table (MCP vs A2A vs current subagents vs custom)
- MCP ecosystem status in coding tools (which tools are clients, which are servers)

**Dependencies**: None (can be written first).

#### Task 2: Result Collection Contract Specification

**What**: Define the result collection interface that any harness wrapper must
implement, independent of protocol choice.

**Deliverables**: Section in the research report specifying:
- Structured deliverable format (file paths, line counts, change scope)
- Completion signal semantics (success, failure, needs-input, cancelled)
- Error taxonomy (retryable vs. fatal, with structured categories)
- Progress reporting format (optional, for long-running tasks)
- Git state handback contract (commits, branch, dirty state)

**Dependencies**: Task 1 (informs which protocol concepts to reference).

#### Task 3: MCP-Based Context Sharing Assessment

**What**: Assess whether an MCP server could serve as the context-sharing layer
(Layer 2), providing task prompts, repo constraints, and CLAUDE.md content to
external harnesses that support MCP as clients.

**Deliverables**: Subsection evaluating:
- Which coding tools could consume this MCP server (Cursor, Codex CLI, etc.)
- What resources/prompts to expose (task prompt, constraint files, agent system prompt)
- Whether this adds value over simpler approaches (just write files to disk)
- Security considerations (exposing repo content via MCP)

**Dependencies**: Task 1.

### Risks and Concerns

1. **MCP Tasks is experimental**: Building on Tasks for long-running delegation
   risks breaking changes. The primitive lacks retry semantics and expiry
   policies. If the report recommends MCP Tasks as part of the solution, it
   must caveat the experimental status and track the spec evolution
   (SEP-1686).

2. **A2A has zero adoption in coding tools**: Despite strong protocol design,
   no coding tool speaks A2A. Recommending A2A for harness communication means
   building all adapters from scratch with no ecosystem leverage. The report
   should acknowledge this honestly rather than presenting A2A as a ready
   solution.

3. **Protocol overhead vs. pragmatic wrappers**: Both MCP and A2A add protocol
   complexity (JSON-RPC framing, capability negotiation, transport setup) that
   may not be justified for wrapping CLI tools that accept a prompt and produce
   file changes. A simple subprocess + structured JSON output may be more
   pragmatic. The report should compare protocol-based approaches against
   direct subprocess wrappers without bias toward protocol elegance.

4. **MCP client capabilities vary across tools**: Cursor has full MCP client
   support (tools + resources since v1.6). Aider has no native MCP support
   (community servers only). Codex CLI added MCP in Sep 2025. Windsurf and
   Cline support MCP. This fragmentation means an MCP-based approach would
   only work for a subset of target harnesses.

5. **Bidirectional communication gap**: The current orchestration model uses
   SendMessage for mid-task communication (approval gates, clarification
   requests). MCP tool calls are unidirectional (client calls server, server
   returns). MCP's `elicitation` feature (added 2025) allows servers to request
   input from users but not from other agents. A2A's `input_required` state
   handles this natively. Any custom protocol must address this.

6. **Context window isolation**: Current subagents get a blank context per
   spawn. External harnesses have their own context windows with their own
   system prompts, MCP servers, and configurations. The orchestrator cannot
   control what context an external harness sees, which may cause inconsistent
   behavior or constraint violations. This is a fundamental architectural
   difference from subagents that the report must address.

### Additional Agents Needed

- **api-design-minion**: If the report recommends a custom wrapper protocol
  (which the analysis suggests is likely), the result collection contract
  (Task 2) is essentially an API design problem. api-design-minion should
  review or co-own the contract specification to ensure it follows good API
  design principles (versioning, error taxonomy, extensibility).

Otherwise, the current team is sufficient. The protocol-level analysis is
primarily my domain (MCP) plus general research. A2A assessment does not
require a separate specialist -- it is a protocol comparison exercise within
scope.
