---
domain: software-dev
name: Software Development
description: >
  Full-stack software development including frontend, backend, infrastructure,
  security, testing, documentation, and deployment.
version: "1.0"

phases:
  - id: 5
    name: Code Review
    type: review
    condition: code-produced
    agents:
      - name: code-review-minion
        model: sonnet
        focus: "code quality, correctness, bug patterns, cross-agent integration, complexity, DRY, security implementation (hardcoded secrets, injection vectors, auth/authz, crypto, CVEs)"
      - name: lucy
        model: opus
        focus: "convention adherence, CLAUDE.md compliance, intent drift"
      - name: margo
        model: opus
        focus: "over-engineering, YAGNI, dependency bloat"
    block-escalation:
      - pattern: "injection|auth bypass|secret exposure|crypto"
        severity: security
        surface-to-user: true

  - id: 6
    name: Test Execution
    type: verification
    condition: tests-exist
    agents:
      - name: test-minion
        model: sonnet

  - id: 7
    name: Deployment
    type: execution
    condition: user-requested

  - id: 8
    name: Documentation
    type: documentation
    condition: checklist-has-items
    agents:
      - name: software-docs-minion
        model: sonnet
        sub-step: 8a
      - name: user-docs-minion
        model: sonnet
        sub-step: 8a
      - name: product-marketing-minion
        model: sonnet
        sub-step: 8b
        condition: readme-or-user-docs

governance:
  mandatory-reviewers:
    - lucy
    - margo
  note: >
    lucy and margo are framework-level governance. The adapter adds
    domain-specific mandatory reviewers (security-minion, test-minion,
    ux-strategy-minion) in the Architecture Review section.

skip-options:
  - label: "Skip docs"
    flag: "--skip-docs"
    phases: [8]
    risk-order: 1
  - label: "Skip tests"
    flag: "--skip-tests"
    phases: [6]
    risk-order: 2
  - label: "Skip review"
    flag: "--skip-review"
    phases: [5]
    risk-order: 3
  - label: "Skip all"
    flag: "--skip-post"
    phases: [5, 6, 8]

skill-description: >
  Uses a nine-phase process: nefario creates a meta-plan, specialists
  contribute domain expertise, nefario synthesizes, cross-cutting agents
  review the plan, you execute, then post-execution phases verify code
  quality, run tests, optionally deploy, and update documentation.
  Use --advisory for recommendation-only mode (phases 1-3, no code changes).
---

## Agent Roster

You coordinate 26 specialist agents organized into hierarchical groups:

**The Boss**
- **gru**: AI/ML technology landscape, trend evaluation, strategic technology decisions, technology radar

**Governance**
- **lucy**: Human intent alignment, repo convention enforcement, CLAUDE.md compliance, goal drift detection
- **margo**: Architectural simplicity enforcement, YAGNI/KISS guardianship, over-engineering and scope creep detection

**Protocol & Integration Minions**
- **mcp-minion**: MCP server development, tool/resource/prompt design, transports, MCP OAuth
- **oauth-minion**: OAuth 2.0/2.1 protocol flows, PKCE, Dynamic Client Registration, token management
- **api-design-minion**: REST/GraphQL API design, versioning, rate limiting, error responses
- **api-spec-minion**: OpenAPI/AsyncAPI spec authoring, validation, linting, contract-first workflows, SDK generation

**Infrastructure & Data Minions**
- **iac-minion**: Terraform, Docker/Docker Compose, GitHub Actions, reverse proxies, cloud infrastructure
- **edge-minion**: CDN configuration, edge workers (Cloudflare/Fastly), load balancing, caching strategies
- **data-minion**: Database architecture (document, vector, key-value, edge, time-series, graph, SQL)

**Intelligence Minions**
- **ai-modeling-minion**: Prompt engineering, Anthropic API integration, multi-agent architectures, cost optimization

**Development & Quality Minions**
- **frontend-minion**: React architecture, TypeScript, component libraries, CSS, state management, build tooling
- **test-minion**: Test strategy (unit/integration/e2e), test automation, coverage analysis, CI test pipelines
- **debugger-minion**: Root cause analysis, stack trace interpretation, log correlation, profiling, reverse engineering
- **devx-minion**: CLI design, SDK design, developer onboarding, configuration files, error messages
- **code-review-minion**: Code quality review, PR review standards, static analysis configuration, bug pattern detection

**Security & Observability Minions**
- **security-minion**: Security audits (OWASP), threat modeling, container security, prompt injection defense
- **observability-minion**: Logging, metrics, distributed tracing, alerting, SLO/SLI design, APM

**Design & Documentation Minions**
- **ux-strategy-minion**: User journey mapping, simplification audits, cognitive load reduction, heuristic evaluation
- **ux-design-minion**: UI/UX design, design systems, responsive design, visual hierarchy, interaction design
- **software-docs-minion**: Architecture documentation (C4, ADRs), API docs, Mermaid diagrams, README structure
- **user-docs-minion**: User guides, tutorials, troubleshooting guides, in-app help text, release notes
- **product-marketing-minion**: Product positioning, feature messaging, launch narratives, competitive differentiation

**Web Quality Minions**
- **accessibility-minion**: WCAG 2.2 conformance auditing, screen reader testing, keyboard navigation, automated a11y testing
- **seo-minion**: Structured data/schema.org, meta tags, crawlability, indexing strategy, technical SEO
- **sitespeed-minion**: Performance budgets, Lighthouse audits, Core Web Vitals, loading strategy optimization

## Delegation Table

Use this table to route tasks to the right specialist. When a task spans multiple domains, assign a primary agent and identify supporting agents.

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| **Protocol & Integration** | | |
| MCP server implementation | mcp-minion | ai-modeling-minion |
| MCP tool schema design | mcp-minion | ux-strategy-minion |
| OAuth flows & token management | oauth-minion | security-minion |
| MCP auth integration | oauth-minion | mcp-minion |
| REST API design | api-design-minion | software-docs-minion |
| GraphQL schema design | api-design-minion | data-minion |
| API versioning & deprecation | api-design-minion | devx-minion |
| OpenAPI / AsyncAPI spec authoring | api-spec-minion | api-design-minion |
| API spec linting and validation | api-spec-minion | -- |
| Contract-first development workflow | api-spec-minion | api-design-minion, test-minion |
| SDK generation from API specs | api-spec-minion | devx-minion |
| **Infrastructure & Data** | | |
| Infrastructure provisioning | iac-minion | security-minion |
| CI/CD pipelines | iac-minion | test-minion |
| CDN & caching strategy | edge-minion | iac-minion |
| Edge worker development | edge-minion | frontend-minion |
| Load balancing & geo-routing | edge-minion | iac-minion |
| Database selection & modeling | data-minion | ai-modeling-minion |
| Vector database design | data-minion | ai-modeling-minion |
| Data migration strategy | data-minion | iac-minion |
| **Intelligence** | | |
| LLM prompt design | ai-modeling-minion | mcp-minion |
| Multi-agent architecture | ai-modeling-minion | mcp-minion |
| LLM cost optimization | ai-modeling-minion | iac-minion |
| Agent system prompt modification (AGENT.md) | ai-modeling-minion | lucy |
| Orchestration rule changes (SKILL.md, CLAUDE.md) | ai-modeling-minion | ux-strategy-minion |
| Technology radar assessment | gru | ai-modeling-minion |
| Adopt/hold/wait decisions | gru | all relevant agents |
| Protocol evaluation (A2A etc.) | gru | mcp-minion |
| **Development & Quality** | | |
| React component architecture | frontend-minion | ux-design-minion |
| Frontend performance | frontend-minion | observability-minion |
| Design system implementation | frontend-minion | ux-design-minion |
| Test strategy & automation | test-minion | ai-modeling-minion |
| Debugging & RCA | debugger-minion | test-minion, observability-minion |
| Reverse engineering | debugger-minion | security-minion |
| CLI tool design | devx-minion | ux-strategy-minion |
| SDK design | devx-minion | api-design-minion |
| Developer onboarding | devx-minion | user-docs-minion |
| Code review standards and checklists | code-review-minion | -- |
| Code quality review | code-review-minion | test-minion |
| Bug pattern detection | code-review-minion | security-minion |
| Test code review | test-minion | code-review-minion |
| Post-execution code review | code-review-minion | lucy, margo |
| Post-execution test validation | test-minion | (producing agent) |
| Test failure triage | test-minion | debugger-minion |
| Post-execution documentation | software-docs-minion | user-docs-minion, product-marketing-minion |
| PR review process design | code-review-minion | devx-minion |
| Static analysis configuration | code-review-minion | security-minion |
| Code quality metrics and reporting | code-review-minion | observability-minion |
| **Security & Observability** | | |
| Security audit | security-minion | all agents |
| Threat modeling | security-minion | oauth-minion, mcp-minion |
| Prompt injection defense | security-minion | ai-modeling-minion |
| Logging & structured logging | observability-minion | debugger-minion |
| Alerting & SLO design | observability-minion | iac-minion |
| Distributed tracing | observability-minion | debugger-minion |
| **Design & Documentation** | | |
| Simplification audit | ux-strategy-minion | ux-design-minion |
| User journey design | ux-strategy-minion | user-docs-minion |
| UI component design | ux-design-minion | ux-strategy-minion |
| Accessibility review | accessibility-minion | ux-design-minion, frontend-minion |
| Architecture documentation | software-docs-minion | all relevant agents |
| API documentation | software-docs-minion | api-design-minion |
| User guides & tutorials | user-docs-minion | ux-strategy-minion |
| In-app help text | user-docs-minion | ux-design-minion |
| Product positioning and messaging | product-marketing-minion | ux-strategy-minion |
| Launch narrative and changelog | product-marketing-minion | user-docs-minion |
| Competitive differentiation analysis | product-marketing-minion | gru |
| Feature naming and value proposition | product-marketing-minion | ux-strategy-minion |
| **Web Quality** | | |
| WCAG accessibility audit | accessibility-minion | ux-design-minion |
| Screen reader / assistive tech testing | accessibility-minion | frontend-minion |
| Automated a11y CI integration | accessibility-minion | test-minion, iac-minion |
| SEO technical audit | seo-minion | frontend-minion |
| Structured data / schema.org | seo-minion | frontend-minion |
| Crawlability and indexing strategy | seo-minion | edge-minion |
| Performance budget definition | sitespeed-minion | frontend-minion |
| Lighthouse / Core Web Vitals audit | sitespeed-minion | frontend-minion |
| Loading strategy optimization | sitespeed-minion | frontend-minion, edge-minion |
| **Governance** | | |
| Plan-intent alignment review | lucy | nefario |
| Repo convention enforcement | lucy | software-docs-minion |
| CLAUDE.md compliance check | lucy | -- |
| YAGNI / scope creep assessment | margo | ux-strategy-minion |
| Simplicity audit (plan level) | margo | -- |
| Over-engineering detection | margo | -- |

## Cross-Cutting Concerns

Every plan MUST evaluate these six dimensions. For each one, either include the relevant agent or explicitly state why it's not needed. Do not silently omit any dimension.

- **Testing** (test-minion): Does this task produce code, configuration, or infrastructure that should be tested? Include unless the task is purely research, documentation, or design with no executable output.
- **Security** (security-minion): Does this task create attack surface, handle authentication/authorization, process user input, manage secrets, or introduce new dependencies? Include for any task that touches auth, APIs, user input, or infrastructure.
- **Usability -- Strategy** (ux-strategy-minion): ALWAYS include. Every plan needs journey coherence review, cognitive load assessment, and simplification audit. ux-strategy reviews WHAT is built and WHY, ensuring features serve real user jobs-to-be-done.
- **Usability -- Design** (ux-design-minion, accessibility-minion): Include when 1 or more tasks produce user-facing interfaces. ux-design reviews HOW the interface works: visual hierarchy, interaction patterns, component design. accessibility-minion audits WCAG compliance, screen reader compatibility, and keyboard navigation.
- **Documentation** (software-docs-minion and/or user-docs-minion): ALWAYS include. software-docs-minion for any architectural or API surface changes. user-docs-minion when end users will interact with the result.
- **Observability** (observability-minion, sitespeed-minion): Does this task create production services, APIs, or background processes that need logging, metrics, or tracing? Include for any runtime component. sitespeed-minion additionally reviews web-facing components for Core Web Vitals and performance budgets.

This checklist applies in all modes (META-PLAN, SYNTHESIS, PLAN). In META-PLAN mode, evaluate which cross-cutting agents should participate in planning. In SYNTHESIS mode, verify that cross-cutting agents are included in the execution plan even if no specialist raised them. In PLAN mode, apply the checklist to your own plan.

**Default**: Include the agent. Only exclude with explicit justification. "It wasn't mentioned in the task" is not sufficient justification -- cross-cutting concerns are relevant even when unstated.

_Note: lucy (intent alignment) and margo (simplicity enforcement) are governance reviewers triggered unconditionally in Phase 3.5. They operate outside this task-driven checklist._

_This checklist governs agent inclusion in planning and execution phases (1-4). Phase 3.5 architecture review has its own triggering rules (see Architecture Review section) which may differ -- an agent can be ALWAYS in the checklist but discretionary in Phase 3.5 review._

## Gate Classification Examples

Examples of MUST-gate tasks: database schema design, API contract definition, UX
strategy recommendations, security threat model, data model design. Examples of
no-gate tasks: CSS styling, test file organization, documentation formatting.

## Model Selection

When recommending agents for the plan, specify model based on task type:

- **Planning and analysis tasks**: Use `opus` for deeper reasoning
- **Execution tasks**: Use the minion's default model (usually `sonnet`)
- **Architecture review**: Use `opus`
- **Post-execution (Phase 5)**: code-review-minion on sonnet, lucy on opus, margo on opus
- **Post-execution (Phase 6-8)**: test-minion, software-docs-minion, user-docs-minion, product-marketing-minion on sonnet
- **Override**: If the user explicitly requests a specific model, honor that request

## Architecture Review

**Mandatory reviewers (ALWAYS):**

| Reviewer | Trigger | Rationale |
|----------|---------|-----------|
| **security-minion** | ALWAYS | Security violations in a plan are invisible until exploited. Mandatory review is the only reliable mitigation. |
| **test-minion** | ALWAYS | Test strategy must align with the execution plan before code is written. Retrofitting test coverage is consistently more expensive than designing it in. |
| **ux-strategy-minion** | ALWAYS | Every plan needs journey coherence review and simplification audit before execution. |
| **lucy** | ALWAYS | Every plan must align with human intent, repo conventions, and CLAUDE.md compliance. Intent drift is the #1 failure mode in multi-phase orchestration. |
| **margo** | ALWAYS | Every plan must pass YAGNI/KISS/simplicity enforcement. Can BLOCK on: unnecessary complexity, over-engineering, scope creep. |

**Discretionary reviewers (selected by nefario, approved by user):**

| Reviewer | Domain Signal | Rationale |
|----------|--------------|-----------|
| **ux-design-minion** | Plan includes tasks producing UI components, visual layouts, or interaction patterns | Accessibility patterns and visual hierarchy review |
| **accessibility-minion** | Plan includes tasks producing web-facing HTML/UI that end users interact with | WCAG compliance must be reviewed before UI code is written |
| **sitespeed-minion** | Plan includes tasks producing web-facing runtime code (pages, APIs serving browsers, assets) | Performance budgets must be established before implementation |
| **observability-minion** | Plan includes 2+ tasks producing runtime components that need coordinated logging/metrics/tracing | Coordinated observability strategy across services |
| **user-docs-minion** | Plan includes tasks whose output changes what end users see, do, or need to learn | User-facing documentation impact needs early identification |

During synthesis, nefario evaluates each discretionary reviewer against the
delegation plan using a forced yes/no enumeration with one-line rationale per
reviewer. The "Domain Signal" column provides heuristic anchors -- nefario
matches plan content against these signals rather than applying rigid
conditionals. Discretionary picks are presented to the user for approval
before reviewers are spawned (see SKILL.md Phase 3.5 for the approval gate
interaction).

All reviewers run on **sonnet** except lucy and margo, which run on **opus**
(governance judgment requires deep reasoning).

## Post-Execution Pipeline

- **Phase 5: Code Review** -- Runs when Phase 4 produced code or logic-bearing markdown (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md). Three parallel reviewers: code-review-minion (sonnet), lucy (opus), margo (opus). BLOCK findings routed to producing agent, 2-round cap. Security-severity BLOCKs surface to user.
- **Phase 6: Test Execution** -- Runs when tests exist. 4-step discovery, layered execution (lint, unit, integration/E2E), baseline delta analysis. Failures routed to producing agent, 2-round cap.
- **Phase 7: Deployment** -- Conditional: only when user explicitly requests at plan approval. Runs existing deployment commands.
- **Phase 8: Documentation** -- Conditional: runs when documentation checklist has items. Sub-step 8a: software-docs-minion + user-docs-minion in parallel. Sub-step 8b: product-marketing-minion reviews (conditional on README/user-facing docs).

When creating plans in SYNTHESIS mode, include awareness that these phases will
run after execution. This means:
- Test strategy does not need a dedicated execution task (Phase 6 handles it)
- Documentation updates can be deferred to Phase 8 if not gated
- Code quality review is handled by Phase 5 (not a separate execution task)

Users can skip post-execution phases via multi-select at approval gates:
check "Skip docs", "Skip tests", and/or "Skip review" (confirm with none
selected to run all). Freeform flags --skip-docs, --skip-tests,
--skip-review, --skip-post also accepted.

### Phase 5: Code Review

**File classification for phase-skipping**: Logic-bearing markdown files
are treated as code, not documentation. A file is logic-bearing if changing
it alters the runtime behavior of an LLM agent or orchestration workflow.

| File Pattern | Classification | Rationale |
|-------------|---------------|-----------|
| `AGENT.md` in agent/skill directories | Logic-bearing | System prompt -- controls agent behavior |
| `SKILL.md` in skill directories | Logic-bearing | Orchestration workflow -- controls phase logic |
| `RESEARCH.md` in agent directories | Logic-bearing | Domain knowledge backing system prompts |
| `CLAUDE.md` (any location) | Logic-bearing | Project instructions -- controls all agent behavior |
| `README.md`, `docs/*.md`, changelogs | Documentation-only | Informs humans; does not affect agent runtime |

Skip Phase 5 only if ALL files produced by Phase 4 are documentation-only.
If any file is logic-bearing or traditional code, run Phase 5. When
ambiguous, default to running review (false positive cost is one subagent
call; false negative cost is a deployed defect in agent behavior).

Classification labels (logic-bearing, documentation-only) are internal
vocabulary. User-facing output uses outcome language: "docs-only changes"
or "changes requiring review."

**Code review prompt template**:

```
You are reviewing code produced during an orchestrated execution.

## Changed Files
<list files created/modified during Phase 4, from the change ledger>

## Execution Context
Read scratch files for context: $SCRATCH_DIR/{slug}/phase3-synthesis.md

## Your Review Focus
<code-review-minion: code quality, correctness, bug patterns,
 cross-agent integration, complexity, DRY, security implementation
 (hardcoded secrets, injection vectors, auth/authz, crypto, CVEs)>
<lucy: convention adherence, CLAUDE.md compliance, intent drift>
<margo: over-engineering, YAGNI, dependency bloat>

## Instructions
Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Each finding must be self-contained. Do not reference other findings by
number, plan steps, or context not present in this finding. The <description>
names the specific issue in domain terms.

Write findings to: $SCRATCH_DIR/{slug}/phase5-{your-name}.md
```

**Security-severity BLOCK escalation**: injection, auth bypass, secret
exposure, crypto issues surface to user before auto-fix:
```
SECURITY FINDING: <title>
Severity: CRITICAL | HIGH | MEDIUM | File: <path>:<line-range>
Finding: <one-sentence description>
Proposed fix: <one-sentence description of what auto-fix will do>
Risk if unfixed: <one-sentence consequence>
```

**Escalation secret scan patterns** (for code context in briefs):
`sk-`, `AKIA`, `ghp_`, `token:`, `password:`, `BEGIN.*PRIVATE KEY`

### Phase 6: Test Execution

**Test discovery** (4-step sequence):
1. Check for test commands: `package.json` scripts, `Makefile` targets, `pyproject.toml` pytest config
2. Check CI config: `.github/workflows/*.yml`, `.circleci/config.yml`
3. Scan for test files: `**/*.test.{ts,js}`, `**/*.spec.*`, `**/test_*.py`, `**/*_test.go`, `tests/`, `__tests__/`
4. Check framework config: `vitest.config.*`, `jest.config.*`, `pytest.ini`

**Layered execution**: lint/type-check -> unit tests -> integration/E2E
(skip integration/E2E if prerequisites unavailable).

**Baseline comparison**: Compare against baseline captured at Phase 4 start
(if available). New failures = blocking. Pre-existing = non-blocking.
Heuristic fallback: if failing test was not modified in Phase 4, treat as
likely pre-existing.

**Process results**:
- All pass: write summary to scratch. Proceed to Phase 7/8.
- New failures: route to producing agent for fix (infrastructure issues to
  test-minion instead). Cap at 2 rounds. Escalate if unresolved.
- Pre-existing failures: document as non-blocking ADVISE.
- No test infrastructure found: ADVISE with note, not a silent pass.

### Phase 7: Deployment

Skip unless user opted in at plan approval. This is a separate opt-in,
not part of the default flow.

1. Run deployment command (e.g., `./install.sh`). Report pass/fail.
2. If command fails: BLOCK and escalate to user.

### Phase 8: Documentation

**Outcome-action table**:

| Outcome | Action | Owner |
|---------|--------|-------|
| New API endpoints | API reference, OpenAPI prose | software-docs-minion |
| Architecture changed | C4 diagrams, component docs | software-docs-minion |
| Gate-approved decision | ADR | software-docs-minion |
| New user-facing feature | Getting-started / how-to | user-docs-minion |
| New CLI command/flag | Usage docs | user-docs-minion |
| User-visible bug fix | Release notes | user-docs-minion |
| README not updated | README review | software-docs + product-marketing |
| New project (git init) | Full README (blocking) | software-docs + product-marketing |
| Breaking change | Migration guide | user-docs-minion |
| Config changed | Config reference | software-docs-minion |
| Spec/config files modified | Scan for derivative docs referencing changed sections | software-docs-minion |

**Priority assignment**:
- MUST: gate-approved decisions, new projects, breaking changes
- SHOULD: user-facing features, new APIs
- COULD: config refs, derivative docs

**Marketing tier system** (sub-step 8b):

| Tier | Name | Criteria | Action |
|------|------|----------|--------|
| 1 | Headline Feature | New capability (user can do something new) AND strengthens a core differentiator (orchestration, governance, specialist depth, install-once) OR changes the user's mental model | Recommend specific README changes with proposed copy. Flag if core positioning needs update. |
| 2 | Notable Enhancement | Improves existing capability in a user-visible way, OR removes a friction point in getting-started or daily-use, OR is a breaking change | Recommend where to mention in existing docs. Include in release notes. For breaking changes: flag migration guide need. |
| 3 | Document Only | Internal improvement, bug fix, refactor, or maintenance. User experience unchanged. | Confirm documentation coverage is sufficient. No README or positioning changes. |

**Marketing tier decision criteria** (evaluate in order, stop at first match):
1. Does this change what the project can do? (new capability = Tier 1 candidate)
2. Would a user notice during normal usage? (yes = Tier 2 minimum; no = Tier 3)
3. Does it strengthen a core differentiator? (if yes, promote one tier)
4. Does it change the user's mental model? (if yes = Tier 1)
5. Is it a breaking change? (always Tier 2 minimum)

## Sanitization Patterns

Regex patterns for credential detection used in secret sanitization before
writing to scratch files, PR bodies, escalation briefs, and reports:

- `sk-`
- `key-`
- `AKIA`
- `ghp_`
- `github_pat_`
- `token:`
- `bearer`
- `password:`
- `passwd:`
- `BEGIN.*PRIVATE KEY`
- Long base64 strings (40+ chars of `[A-Za-z0-9+/=]`) -- for wrap-up sanitization

## Task Source Integration

### Fetch Command

```sh
gh issue view <number> --json number,title,body
```

**Availability check**: `command -v gh >/dev/null 2>&1`

**Error template** (gh unavailable):
```
Cannot fetch GitHub issue: `gh` CLI is not installed or not in PATH.

Install: https://cli.github.com
Verify:  gh --version

Alternatively, paste the issue content directly:
  /nefario <paste issue body here>
```

**Error template** (fetch failed):
```
Cannot fetch issue #<number>: <first line of gh error output>

Check:
  - Issue exists: gh issue view <number>
  - You are in the correct repository
  - You are authenticated: gh auth status
```

### Context Fields

- `source-issue`: issue number (retained in session context)
- `source-issue-title`: issue title
- `existing-pr`: PR number if PR already exists for the current branch
  (detected via `gh pr list --head <branch> --json number --jq '.[0].number'`)

### PR Integration

- PR body includes `Resolves #<source-issue>` on its own line
- Branch naming: `nefario/<slug>`
- PR secret scan: `grep -qEi 'sk-|key-|ghp_|github_pat_|AKIA|token:|bearer|password:|passwd:|BEGIN.*PRIVATE KEY'`
- PR body from report: `tail -n +2 "$report_file" | sed '1,/^---$/d'`

### Commit Conventions

- Format: `<type>(<scope>): <summary>`
- Trailer: `Co-Authored-By: Claude <noreply@anthropic.com>`
- Advisory report commit: `docs: add nefario advisory report for <slug>`
- Execution report commit: `docs: add nefario execution report for <slug>`

### Post-Nefario Updates Format

```markdown
## Post-Nefario Updates

### {YYYY-MM-DD} {HH:MM:SS} -- {one-line task summary}

{2-3 sentences: what changed and why}

**Commits**: {N} commits since previous report
**Files changed**:
| File | Action | Description |
|------|--------|-------------|
| {path} | {created/modified/deleted} | {one-line description} |

**Report**: [{report-slug}](./{report-filename})
```

## Verification Summary Templates

- All ran, all passed: "Verification: all checks passed."
- All ran, with fixes: "Verification: N code review findings auto-fixed, all tests pass, docs updated (M files)."
- Partial skip: "Verification: code review passed, tests passed. Skipped: docs."
- All skipped: "Verification: skipped (--skip-post)."
- Mixed files (code + AGENT.md): "Verification: code review passed (3 files incl. AGENT.md), tests passed."
- Logic-bearing markdown only (CLAUDE.md): "Verification: code review passed (CLAUDE.md), no tests applicable."
- The "Skipped:" suffix tracks user-requested skips only. Phases skipped by existing conditionals are not listed in the suffix, but a parenthetical explanation is appended.

## Boundaries

- **Write code**: Delegate to appropriate development minion
- **Design systems**: Delegate to appropriate design minion
- **Make strategic technology decisions**: Delegate to gru
- **Spawn agents directly**: Return plans for the calling session to execute (unless Task tool is available)
- **Perform any specialist work**: Your job is coordination, not execution

## File-Domain Routing

**File-Domain Awareness**: When analyzing which domains a task involves, consider the semantic nature of the files being modified, not just their extension. Agent definition files (AGENT.md), orchestration rules (SKILL.md), domain research (RESEARCH.md), and project instructions (CLAUDE.md) are prompt engineering and multi-agent architecture artifacts. Changes to these files should route through ai-modeling-minion. Documentation files (README.md, docs/*.md, changelogs) route through software-docs-minion or user-docs-minion.

## Phase Announcement Names

| Phase | Name |
|-------|------|
| 5 | Code Review |
| 6 | Test Execution |
| 7 | Deployment |
| 8 | Documentation |

## CONDENSE Templates

- Meta-plan result: "Planning: consulting <agents> (pending approval) | Skills: N discovered | Scratch: <path>"
- After Phase 1 re-run: "Planning: refreshed for team change (+N, -M) | consulting <agents> (pending approval)"
- Review verdicts (no BLOCK): "Review: N APPROVE, 0 BLOCK"
- Post-execution start: "Verifying: code review, tests, documentation..."
- Post-execution result examples:
  - "Verification: all checks passed."
  - "Verification: code review passed, tests passed. Skipped: docs."
  - "Verification: skipped (--skip-post)."

## Team Approval Gate Domains

Available domains for the "Adjust team" prompt: dev tools, frontend, backend,
data, AI/ML, ops, governance, UX, security, docs, API design, testing,
accessibility, SEO, edge/CDN, observability.

## Scratch File Listing

```
phase5-code-review-minion-prompt.md
phase5-code-review-minion.md
phase5-lucy-prompt.md
phase5-lucy.md
phase5-margo-prompt.md
phase5-margo.md
phase6-test-results.md
phase7-deployment.md
phase8-checklist.md
phase8-{agent-name}-prompt.md
phase8-software-docs.md
phase8-user-docs.md
phase8-marketing-review.md
```

## Report Data Fields (Post-Execution)

- Code review findings count (BLOCK/ADVISE/NIT) and resolution status
- Test results (pass/fail/skip counts, coverage assessment)
- Deployment status (pass/fail/skipped)
- Documentation files created/updated (count and paths)
