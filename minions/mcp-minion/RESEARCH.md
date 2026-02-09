# MCP Minion Research

Research conducted 2026-02-09 for building MCP server development expertise.

## MCP Specification Overview

### Current Version & Governance

The latest MCP specification was released on **2025-11-25**, with a release candidate from 2025-11-11. Major updates included:
- Asynchronous operations
- Statelessness support
- Server identity mechanisms
- Community-driven registry for discovering MCP servers

In December 2025, Anthropic donated MCP to the **Agentic AI Foundation (AAIF)**, a Linux Foundation directed fund, co-founded by Anthropic, Block, and OpenAI.

Previous major release (2025-06-18) introduced authorization clarifications and Resource Indicators to prevent malicious servers from obtaining access tokens.

**Sources:**
- [MCP Specification 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25)
- [MCP GitHub Repository](https://github.com/modelcontextprotocol/modelcontextprotocol)
- [Pento: A Year of MCP](https://www.pento.ai/blog/a-year-of-mcp-2025-review)

### Protocol Architecture

MCP is an open protocol enabling seamless integration between LLM applications and external data sources/tools. Architecture components:

**Hosts**: LLM applications that initiate connections
**Clients**: Connectors within the host application
**Servers**: Services that provide context and capabilities

**Base Protocol:**
- JSON-RPC 2.0 message format
- Stateful connections (though stateless is supported in Streamable HTTP)
- Server and client capability negotiation

**Sources:**
- [MCP Specification](https://modelcontextprotocol.io/specification/2025-11-25)

## Core MCP Primitives

### Tools

**Purpose**: Executable functions that perform actions or computations (e.g., add numbers, fetch API data, process files). Tools are model-driven — the AI chooses when and how to call them.

**Design Best Practices:**
- Use intuitive names and human-readable descriptions reflecting purpose
- Follow naming pattern: `{service}_{action}_{resource}` (e.g., `slack_send_message`, `linear_list_issues`)
- Define strict input parameter schemas using Zod for validation and autocomplete
- Include concrete usage examples (models learn from demonstrations)
- Return both human-readable text content and structured data
- Make each tool call self-contained (create connections per call, not at server start)
- Implement async handlers returning content and structured output

**Anti-Pattern**: The "API wrapper one-on-one pattern" — exposing one MCP tool per API endpoint inflates tool count and dramatically reduces task completion rates.

**Sources:**
- [Composio: How to Use Prompts, Resources, and Tools](https://composio.dev/blog/how-to-effectively-use-prompts-resources-and-tools-in-mcp)
- [Klavis: 4 Design Patterns for Better MCP Servers](https://www.klavis.ai/blog/less-is-more-mcp-design-patterns-for-ai-agents)
- [Phil Schmid: MCP Best Practices](https://www.philschmid.de/mcp-best-practices)
- [Docker: MCP Server Best Practices](https://www.docker.com/blog/mcp-server-best-practices/)

### Resources

**Purpose**: Data entities the server exposes (static like greetings/config, or dynamic like user profiles/database records). Resources are application-driven — the client decides how to use the data. Resources provide context without heavy computation.

**Design Best Practices:**
- Declare static or dynamic templates with URI patterns
- Support argument completions for path parameters
- Return content with optional MIME types
- Ideal for configuration, documents, reference material

**Sources:**
- [Composio: How to Use Prompts, Resources, and Tools](https://composio.dev/blog/how-to-effectively-use-prompts-resources-and-tools-in-mcp)
- [TypeScript SDK Server Docs](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/server.md)

### Prompts

**Purpose**: Reusable templates that guide AI interactions, structuring how models ask questions, explain concepts, or interact with users. Prompts are user-driven — typically exposed through slash commands or menu options.

**Design Best Practices:**
- Use clear, actionable names (e.g., `summarize-errors`, not `get-summarized-error-log-output`)
- Validate all required arguments up front
- Keep prompts deterministic and stateless (same input → same output)
- Embed resources directly if needed for model context
- Provide concise descriptions to improve UI discoverability
- Generate message sequences with role and content

**Sources:**
- [Composio: How to Use Prompts, Resources, and Tools](https://composio.dev/blog/how-to-effectively-use-prompts-resources-and-tools-in-mcp)
- [Speakeasy: What are MCP Prompts?](https://www.speakeasy.com/mcp/core-concepts/prompts)
- [TypeScript SDK Server Docs](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/server.md)

## TypeScript SDK Patterns

### Core Architecture

The `@modelcontextprotocol/sdk` provides:
- MCP server libraries for tools/resources/prompts
- Transport support: Streamable HTTP, stdio, HTTP+SSE
- Auth helpers (OAuth)
- MCP client libraries with transports and OAuth helpers

**Peer Dependencies:**
- Zod v4 (required for schema validation)

**Middleware Architecture:**
- Middleware packages published for specific runtimes/frameworks
- Intentionally thin adapters — no new MCP functionality or business logic

**Sources:**
- [TypeScript SDK GitHub](https://github.com/modelcontextprotocol/typescript-sdk)
- [npm: @modelcontextprotocol/sdk](https://www.npmjs.com/package/@modelcontextprotocol/sdk)

### Server Creation Pattern

**Primary Class:** `McpServer` from `@modelcontextprotocol/server`

**Setup Steps:**
1. Import `McpServer`, `ResourceTemplate`, and transport
2. Define handlers with Zod schemas
3. Connect to transport (StdioServerTransport or Streamable HTTP)

**Schema Validation:**
- Use typed schemas (Zod recommended) for `inputSchema` and `outputSchema` on tools
- Use `argsSchema` on prompts and resources
- Validation failures during registration prevent incorrect invocations

**Example Pattern** (from SDK docs):
```typescript
import { McpServer } from '@modelcontextprotocol/server';
import { z } from 'zod';

const server = new McpServer({
  name: 'example-server',
  version: '1.0.0'
});

// Tool registration
server.addTool({
  name: 'calculate-bmi',
  description: 'Calculate Body Mass Index',
  inputSchema: z.object({
    weight: z.number(),
    height: z.number()
  }),
  handler: async ({ weight, height }) => {
    const bmi = weight / (height * height);
    return {
      content: [{ type: 'text', text: `BMI: ${bmi.toFixed(2)}` }],
      bmi
    };
  }
});
```

**Sources:**
- [TypeScript SDK Server Docs](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/server.md)
- [Medium: Creating an MCP Server Step-by-Step](https://michaelwapp.medium.com/creating-a-model-context-protocol-server-a-step-by-step-guide-4c853fbf5ff2)

### DNS Rebinding Protection

When using Streamable HTTP with Express:
- Use `createMcpExpressApp()` to create an Express app with DNS rebinding protection enabled by default
- When binding to `127.0.0.1` or `localhost`, protection activates automatically
- For `0.0.0.0` deployments, provide explicit `allowedHosts` array

**Sources:**
- [TypeScript SDK Server Docs](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/server.md)

## Transport Mechanisms

### stdio Transport

**Characteristics:**
- Runs locally on the same machine as the client
- Communicates via standard input/output streams
- Client spawns MCP server as child process
- Client writes to server's STDIN, server responds to STDOUT
- No network configuration required (eliminates network overhead and security concerns)
- Limited to local environments
- Rarely times out unless server process hangs
- No CORS issues (runs locally)

**Use Cases:**
- Local or personal use
- Individual machine installations
- Development and testing

**Sources:**
- [Roo Code: MCP Server Transports](https://docs.roocode.com/features/mcp/server-transports)
- [MCPcat: Comparing stdio vs SSE vs Streamable HTTP](https://mcpcat.io/guides/comparing-stdio-sse-streamablehttp/)
- [AWS Builder: stdio vs Streamable HTTP](https://builder.aws.com/content/35A0IphCeLvYzly9Sw40G1dVNzc/mcp-transport-mechanisms-stdio-vs-streamable-http)

### Streamable HTTP Transport

**Characteristics:**
- **Modern standard for remote MCP server communication** (replaces HTTP+SSE)
- Operates over HTTP/HTTPS with single MCP endpoint supporting POST and GET
- Server runs as independent process handling multiple client connections
- Uses Server-Sent Events (SSE) over same connection for streaming and server-initiated communication
- Supports both stateless (simple APIs) and stateful (resumability, advanced features) modes
- Can timeout due to slow responses or connection problems
- Requires CORS configuration for cross-origin access

**Use Cases:**
- Remote servers accessed over network
- Enterprise and production deployments
- Single deployment serving multiple clients
- Centralized updates

**Deployment Patterns:**
- Multi-node patterns documented in SDK examples
- `sseAndStreamableHttpCompatibleServer.ts` supports legacy and modern clients simultaneously

**Sources:**
- [Roo Code: MCP Server Transports](https://docs.roocode.com/features/mcp/server-transports)
- [MCPcat: Comparing stdio vs SSE vs Streamable HTTP](https://mcpcat.io/guides/comparing-stdio-sse-streamablehttp/)
- [TypeScript SDK Server Docs](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/server.md)

### HTTP+SSE Transport (Deprecated)

**Status**: Supported for backwards compatibility only. New implementations should prefer Streamable HTTP.

**Sources:**
- [TypeScript SDK Server Docs](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/server.md)

## MCP OAuth & Authorization

MCP authorization relies on a "Discovery Trifecta" of RFCs that transforms OAuth from manually configured parts into a dynamic, discoverable protocol.

### RFC 9728 - Protected Resource Metadata

**Published**: April 2025 (after 8.5-year journey)

**Purpose**: Solves the "missing link" — how a client, starting only with a Resource Server's address, knows which authorization server to talk to and what parameters to request.

**MCP Requirements:**
- MCP servers MUST implement RFC 9728 when authorization is required
- Return HTTP 401 with `WWW-Authenticate` header containing `resource_metadata` URL
- PRM document MUST include `authorization_servers` field indicating where clients obtain tokens

**Sources:**
- [Descope: MCP Authorization Specification](https://www.descope.com/blog/post/mcp-auth-spec)
- [WorkOS: MCP Authorization in 5 Easy OAuth Specs](https://workos.com/blog/mcp-authorization-in-5-easy-oauth-specs)
- [Kane.mx: Technical Deconstruction of MCP Authorization](https://kane.mx/posts/2025/mcp-authorization-oauth-rfc-deep-dive/)

### RFC 7591 - Dynamic Client Registration

**Published**: July 2015

**Purpose**: Solves how clients obtain a `client_id` programmatically, enabling scale in federated ecosystems. Allows new AI applications to register with authorization servers without human intervention.

**Sources:**
- [Descope: MCP Authorization Specification](https://www.descope.com/blog/post/mcp-auth-spec)
- [WorkOS: MCP Authorization in 5 Easy OAuth Specs](https://workos.com/blog/mcp-authorization-in-5-easy-oauth-specs)

### PKCE - Proof Key for Code Exchange

**RFC**: RFC 7636 (part of OAuth 2.1)

**MCP Requirements:**
- MCP clients MUST implement PKCE
- MUST use S256 code challenge method when technically capable
- Helps prevent authorization code interception and injection attacks
- Requires clients to create secret verifier-challenge pair

**Sources:**
- [Descope: MCP Authorization Specification](https://www.descope.com/blog/post/mcp-auth-spec)
- [WorkOS: MCP Authorization in 5 Easy OAuth Specs](https://workos.com/blog/mcp-authorization-in-5-easy-oauth-specs)

### Additional Relevant RFCs

- **RFC 8707**: Resource Indicators (prevents malicious servers from obtaining access tokens)
- **RFC 8414**: Authorization Server Metadata
- **RFC 7662**: Token Introspection (validates opaque tokens)

**Sources:**
- [WorkOS: MCP Authorization in 5 Easy OAuth Specs](https://workos.com/blog/mcp-authorization-in-5-easy-oauth-specs)
- [Medium: Remote MCP OAuth 2.1, DCR, and PRM](https://medium.com/@yagmur.sahin/remote-mcp-in-the-real-world-oauth-2-1-9d149de6e475)

### OAuth Anti-Pattern: Token Passthrough

**Definition**: MCP server accepts tokens from MCP client without validation.

**Why It's Harmful:**
- Violates "least privileged" access per user
- High blast radius for confused deputy errors
- Circumvents RBAC at upstream API
- Makes auditing messy

**Correct Pattern**: MCP servers should implement token introspection (RFC 7662) or validate tokens locally.

**Sources:**
- [Medium: MCP Patterns & Anti-Patterns for Enterprise AI](https://medium.com/@thirugnanamk/mcp-patterns-anti-patterns-for-implementing-enterprise-ai-d9c91c8afbb3)
- [Solo.io: MCP Authorization Patterns](https://www.solo.io/blog/mcp-authorization-patterns-for-upstream-api-calls)

## Advanced MCP Design Patterns

### 1. Layered Tool Pattern

**Problem**: Exposing many tools reduces task completion rates.

**Solution**: Favor polymorphic design exposing fewer tools with more parameters. Block's Layered Tool Pattern reduced the entire Square API platform to just three conceptual tools.

**Sources:**
- [Klavis: 4 Design Patterns for Better MCP Servers](https://www.klavis.ai/blog/less-is-more-mcp-design-patterns-for-ai-agents)

### 2. Progressive Disclosure Pattern

**Implementation:**
1. Agent identifies relevant services based on user intent
2. Server returns categories (e.g., Repos, Issues, PRs for GitHub)
3. Only when agent selects specific action does it receive complete parameter schema
4. Agent can then execute the action

**Benefit**: Reduces context window pollution, improves tool selection accuracy.

**Sources:**
- [Klavis: 4 Design Patterns for Better MCP Servers](https://www.klavis.ai/blog/less-is-more-mcp-design-patterns-for-ai-agents)

### 3. Code Mode Pattern

**Implementation**: Instead of sequential tool calls, agents write complete programs using available APIs, executed in secure sandboxes.

**Benefit**: More efficient, composable, testable workflows.

**Sources:**
- [Klavis: 4 Design Patterns for Better MCP Servers](https://www.klavis.ai/blog/less-is-more-mcp-design-patterns-for-ai-agents)

### 4. Single Responsibility Pattern

**Principle**: Each MCP server should have one clear, well-defined purpose.

**Benefits:**
- Maintainability
- Scalability
- Reliability
- Clear team ownership

**Anti-Pattern**: Monolithic server handling databases, files, external APIs, and email in one service.

**Sources:**
- [Docker: MCP Server Best Practices](https://www.docker.com/blog/mcp-server-best-practices/)
- [DEV: Running Efficient MCP Servers](https://dev.to/om_shree_0709/running-efficient-mcp-servers-in-production-metrics-patterns-pitfalls-42fb)

## Smart MCP Server Pattern (Embedded LLM Intelligence)

### Concept

MCP servers can embed LLM intelligence to become "smart servers" where the LLM provides reasoning while the MCP bridge provides execution.

### Architecture Layers

**Optimizer Layer**: Pre-filters common requests through pattern matching
**Router Model**: Handles complex or ambiguous tasks requiring deeper reasoning
**Tool Groups**: Organize specialized capabilities
**Single Endpoint**: Consolidates downstream API complexity behind unified interface

**Significance**: MCP servers become critical bridge between AI reasoning and real-world actions, handling everything from data access to command execution with standardized auditing and policy enforcement.

**Sources:**
- [Elastic Path: MCP Magic Moments - LLM Patterns](https://www.elasticpath.com/blog/mcp-magic-moments-guide-to-llm-patterns)
- [MCP Docs: Building MCP with LLMs](https://modelcontextprotocol.io/tutorials/building-mcp-with-llms)
- [Zscaler: LLM-Powered Threat Intel](https://www.zscaler.com/blogs/product-insights/operationalizing-threat-intelligence-zscaler-integrations-mcp-server)

## Claude Code & claude.ai MCP Integration

### Setup Methods

**CLI Wizard** (official):
```bash
claude mcp add
```
Steps through configuration interactively.

**Direct Configuration** (preferred for complex setups):
- Edit configuration file directly (typically JSON)
- Provides more control and flexibility
- Easier for testing and maintaining multiple MCP servers

### Connection Methods

**HTTP servers**: Recommended for remote MCP servers (most widely supported for cloud services)
**stdio**: For local MCP servers

### Claude Code as MCP Server

Claude Code can act as an MCP server via:
```bash
claude mcp serve
```

Exposes Claude Code's file editing and command execution tools via MCP protocol.

**Sources:**
- [Claude Code Docs: Connect to MCP](https://code.claude.com/docs/en/mcp)
- [Scott Spence: Configuring MCP Tools in Claude Code](https://scottspence.com/posts/configuring-mcp-tools-in-claude-code)
- [Clockwise: Claude Code MCP Configuration](https://www.getclockwise.com/blog/claude-code-mcp-tools-integration)
- [ksred.com: Claude Code as MCP Server](https://www.ksred.com/claude-code-as-an-mcp-server-an-interesting-capability-worth-understanding/)

## Common MCP Gotchas & Limitations

### 1. Authentication & Authorization Complexity

**Issue**: Current MCP spec requires every server supporting authentication to operate as fully-fledged Identity Provider (IdP), rather than allowing servers to validate existing tokens from trusted IdPs (e.g., Okta-issued JWTs).

**Impact**: Massive burden for teams wanting to expose simple REST-like APIs for LLMs.

**Sources:**
- [Shrivu Shankar: Everything Wrong with MCP](https://blog.sshh.io/p/everything-wrong-with-mcp)

### 2. Context Window & Performance Issues

**Issue**: When assistant searches through many documents (~30+), hits context window limit and returns partial results. LLM reliability negatively correlates with instructional context amount. As users integrate more tools, performance degrades while costs increase.

**Workaround**: Implement progressive disclosure pattern, use layered tool pattern to reduce context pollution.

**Sources:**
- [Shrivu Shankar: Everything Wrong with MCP](https://blog.sshh.io/p/everything-wrong-with-mcp)

### 3. Search Limitations

**Issue**: MCP can't support semantic search — protocol relies on underlying APIs supporting only fuzzy or exact string matching, not semantic understanding.

**Example**: "What's our company's Q3 performance?" wouldn't return relevant documents.

**Sources:**
- [Shrivu Shankar: Everything Wrong with MCP](https://blog.sshh.io/p/everything-wrong-with-mcp)

### 4. Tool Description Problems

**Issue**: Two extremes:
- Incomplete or poorly described tools (agent doesn't know when to use them)
- Too many tools with lengthy descriptions (context window overload, potential timeout)

**Workaround**: Follow naming convention `{service}_{action}_{resource}`, provide concise descriptions, use layered tool pattern.

**Sources:**
- [Shrivu Shankar: Everything Wrong with MCP](https://blog.sshh.io/p/everything-wrong-with-mcp)
- [Docker: MCP Server Best Practices](https://www.docker.com/blog/mcp-server-best-practices/)

### 5. Security: stdio Low-Friction Exploit Path

**Issue**: stdio support makes it frictionless to run local servers, but creates low-friction path for non-technical users to download and run third-party code on local machines.

**Mitigation**: User education, code review of third-party MCP servers, sandboxing.

**Sources:**
- [Shrivu Shankar: Everything Wrong with MCP](https://blog.sshh.io/p/everything-wrong-with-mcp)

### 6. Prompt Injection via Tool Trust

**Issue**: Tools often trusted as part of assistant's system prompts, giving them authority to override agent behavior. Creates vulnerability to prompt injection attacks.

**Mitigation**: Validate tool outputs, sanitize inputs, implement security-minion review patterns.

**Sources:**
- [Shrivu Shankar: Everything Wrong with MCP](https://blog.sshh.io/p/everything-wrong-with-mcp)

### 7. Configuration Errors

**Issue**: Incorrect JSON syntax, misplaced commas, improper file paths prevent server from starting. Primary source of frustration.

**Workaround**: Use schema validation, provide clear error messages, create configuration templates.

**Sources:**
- [Microsoft: MCP Troubleshooting](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-troubleshooting)
- [Kelen: Troubleshooting MCP Configuration](https://en.kelen.cc/faq/troubleshooting-mcp-configuration-and-npx-issues-on-windows)

### 8. Windows npx Issues

**Issue**: On Windows, Node.js has difficulties spawning batch files like `npx.cmd` without setting shell option. By default, node is denied PS1 script execution.

**Workaround**: Set shell option explicitly, use full path to npx, or use WSL.

**Sources:**
- [Kelen: Troubleshooting MCP Configuration on Windows](https://en.kelen.cc/faq/troubleshooting-mcp-configuration-and-npx-issues-on-windows)

### 9. API Rate Limiting

**Issue**: Many MCP implementations interact with external APIs, susceptible to rate limiting. Too many requests in short period → external service blocks server.

**Workaround**: Implement request throttling, caching, exponential backoff.

**Sources:**
- [CData: Shortcomings of MCP](https://www.cdata.com/blog/navigating-the-hurdles-mcp-limitations)

### 10. Lack of Comprehensive Error-Handling Standard

**Issue**: MCP doesn't enforce comprehensive error-handling standard. Scope limited to discovery and invocation, omitting tool governance, versioning, or lifecycle management.

**Impact**: Inconsistent implementations, interoperability challenges.

**Workaround**: Establish project-specific error handling conventions, document error schemas.

**Sources:**
- [CData: Shortcomings of MCP](https://www.cdata.com/blog/navigating-the-hurdles-mcp-limitations)

### 11. Production Environment Constraints

**Issue**: Many host app environments (especially deployed APIs) have stringent requirements. stdio transport simply won't work in production.

**Solution**: Always use Streamable HTTP for production deployments.

**Sources:**
- [FeatureForm: What MCP Gets Wrong](https://www.featureform.com/post/what-mcp-gets-wrong)

## MCP Testing Strategies

### Unit Testing

- Test individual tool handlers with mock inputs
- Validate schema definitions catch invalid inputs
- Test error handling paths
- Mock external API calls

### Integration Testing

- Test full MCP server initialization
- Test transport layer (stdio or HTTP)
- Test client-server communication
- Test OAuth flow if applicable

### Best Practices

- Start from feature-rich SDK examples and remove unnecessary features
- Provide clear titles and descriptions for discoverability
- Use `getDisplayName` utility on clients for correct display names across API versions
- Return `resourceLink` content items from tools to reference large resources without embedding
- Structure responses with both human-readable text and structured data

**Sources:**
- [TypeScript SDK Server Docs](https://github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/server.md)
- [Phil Schmid: MCP Best Practices](https://www.philschmid.de/mcp-best-practices)

## Key Takeaways from Past Project Work

### From obsidian-cloud-mcp Project

**Architecture Patterns:**
- Cloudflare Worker as OAuth proxy (Hono + `@cloudflare/workers-oauth-provider`)
- Hetzner server runs Docker: Obsidian, MCP server, Caddy reverse proxy
- Token introspection (RFC 7662) validates opaque tokens from Worker KV
- Email whitelist stored in OAUTH_KV

**Security Best Practices:**
- Introspection endpoint requires Bearer auth (`INTROSPECTION_SECRET`)
- Email whitelist in KV storage (not hardcoded)
- PII scrubbed from git history
- Terraform state needs remote backend for production
- Dockerfile dependencies pinned to commit hashes
- Log output sanitized (no PII, no full response bodies, no KV keys)

**Gotchas:**
- `worker-configuration.d.ts` can be >400KB — always use offset/limit
- Workflow heredocs: single-quoted delimiter prevents shell expansion but GitHub Actions expressions still expand

## Summary of Key Resources

### Official Documentation
- [MCP Specification 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25)
- [TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Community MCP Servers](https://github.com/modelcontextprotocol/servers)
- [Claude Code MCP Integration](https://code.claude.com/docs/en/mcp)

### Best Practice Guides
- [Phil Schmid: MCP Best Practices](https://www.philschmid.de/mcp-best-practices)
- [Docker: MCP Server Best Practices](https://www.docker.com/blog/mcp-server-best-practices/)
- [Klavis: 4 Design Patterns](https://www.klavis.ai/blog/less-is-more-mcp-design-patterns-for-ai-agents)
- [MCP Best Practices Official](https://modelcontextprotocol.info/docs/best-practices/)

### OAuth & Security
- [Descope: MCP Auth Spec](https://www.descope.com/blog/post/mcp-auth-spec)
- [WorkOS: MCP Authorization in 5 Easy OAuth Specs](https://workos.com/blog/mcp-authorization-in-5-easy-oauth-specs)
- [Kane.mx: Technical Deconstruction](https://kane.mx/posts/2025/mcp-authorization-oauth-rfc-deep-dive/)
- [Solo.io: MCP Authorization Patterns](https://www.solo.io/blog/mcp-authorization-patterns-for-upstream-api-calls)

### Limitations & Gotchas
- [Shrivu Shankar: Everything Wrong with MCP](https://blog.sshh.io/p/everything-wrong-with-mcp)
- [CData: Navigating the Hurdles](https://www.cdata.com/blog/navigating-the-hurdles-mcp-limitations)
- [FeatureForm: What MCP Gets Wrong](https://www.featureform.com/post/what-mcp-gets-wrong)
- [Merge: 6 Challenges of MCP](https://www.merge.dev/blog/mcp-challenges)
