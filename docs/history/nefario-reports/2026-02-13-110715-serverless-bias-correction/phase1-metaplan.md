# Meta-Plan: Serverless Bias Correction Advisory

**Mode**: META-PLAN (advisory-only -- no execution, no post-processing)

## Analysis

The user identifies a systemic bias in the agent system: serverless
infrastructure is incorrectly classified as "complex" / "over-engineering"
when it is actually simpler than the server-based alternatives for greenfield
projects. This is an advisory consultation -- specialists analyze the question
from their domains and produce recommendations. No code will be written.

### Where the Bias Lives (Initial Assessment)

After reading the relevant agent files, the bias is **not a single explicit
statement** but rather a **structural omission combined with framing effects**:

1. **iac-minion's remit and knowledge** (`the-plan.md` lines 722-748,
   `minions/iac-minion/AGENT.md`): The entire agent is organized around
   Terraform, Docker, Docker Compose, GitHub Actions, reverse proxies, and
   "server deployment and operations." Serverless is mentioned nowhere in the
   remit, nowhere in the AGENT.md knowledge base, and only once in the
   RESEARCH.md (a passing mention of "Serverless and Managed Services" as a
   cost optimization strategy, line 247). The iac-minion will naturally
   recommend what it knows: VMs, containers, Terraform state management,
   Docker multi-stage builds. For a greenfield project, this means the agent
   will propose a Docker + Terraform + reverse proxy stack when `vercel deploy`
   or a single Lambda function would suffice.

2. **margo's complexity budget** (`margo/AGENT.md` lines 55-62): "New
   technology: 10 points, New service: 5 points." Serverless platforms are
   "new technology" from margo's framing, even though they are actually
   simpler (no servers, no scaling config, no Docker, no Terraform for basic
   deployments). The complexity budget scores infrastructure choices by their
   novelty, not their operational burden.

3. **margo's "Boring Technology" heuristic** (`margo/AGENT.md` lines 171-179):
   "Choose boring technology. Boring tech has decades of production hardening."
   This frames Terraform + Docker + Nginx as "boring" (decades old) and
   serverless as "new" (innovation token spend). But AWS Lambda is 12 years old,
   Vercel has been production-ready since 2020, and Cloudflare Workers since
   2018. Serverless IS boring technology now.

4. **The absence in the delegation table** (`the-plan.md` lines 297-358):
   There is no "serverless deployment" row. "Infrastructure provisioning"
   routes to iac-minion, which means serverless is handled by an agent whose
   entire knowledge base is server-centric.

5. **edge-minion knows some serverless** (`minions/edge-minion/AGENT.md`):
   Cloudflare Workers, D1, KV, R2, Durable Objects -- but scoped to CDN/edge
   compute, not general serverless deployment. The edge-minion would not
   naturally be consulted for "deploy a new API" even if Workers would be the
   simplest path.

6. **data-minion has serverless database knowledge** (`minions/data-minion/AGENT.md`
   lines 172-174): Neon serverless PostgreSQL, Turso. But this is scoped to
   database selection, not deployment strategy.

7. **No CLAUDE.md anti-serverless directive**: The project CLAUDE.md and user
   CLAUDE.md do not mention serverless at all -- the bias is entirely emergent
   from agent knowledge gaps and heuristic framing, not from an explicit rule.

### The Four Questions

1. **Bias correction**: The bias is distributed across (a) iac-minion's knowledge
   gap, (b) margo's heuristic framing, (c) absence in the delegation table.
2. **Entry point**: Multiple touch points needed -- no single fix suffices.
3. **Agent roster**: Needs analysis -- dedicated agent vs. distributed knowledge.
4. **Greenfield defaults**: Needs specialist input on what "simple" means per
   domain.

## Planning Consultations

### Consultation 1: Infrastructure Simplicity Assessment

- **Agent**: iac-minion
- **Planning question**: You are being asked to critically assess your own
  knowledge base. Your current remit covers Terraform, Docker, GitHub Actions,
  reverse proxies, and cloud provider patterns. Serverless platforms (AWS Lambda,
  Cloudflare Workers, Vercel, Netlify, Deno Deploy, Cloudflare Pages) are absent
  from your knowledge. For a greenfield project that needs a simple API or a
  static site with a few server functions, compare the operational complexity of:
  (a) your current default stack (Terraform + Docker + reverse proxy + server),
  and (b) a serverless deployment (e.g., `vercel deploy` or a single Lambda).
  What serverless knowledge should be added to your remit? What should remain
  outside your scope? Should serverless be your default recommendation for
  greenfield, with server infrastructure as the escalation path when serverless
  constraints are hit?
- **Context to provide**: Current iac-minion AGENT.md, the-plan.md spec for
  iac-minion (lines 722-748), the user's observation that serverless is simpler
  than the current default stack for most greenfield projects.
- **Why this agent**: The iac-minion is the primary agent affected by the bias.
  It needs to self-assess where serverless fits in its remit and where the
  complexity boundaries actually lie.

### Consultation 2: Complexity Budget Recalibration

- **Agent**: margo
- **Planning question**: Your complexity budget assigns "New technology: 10 points"
  and "New service: 5 points." Your "Boring Technology" heuristic frames decade-old
  tech as safe and newer tech as innovation-token spends. But serverless platforms
  (AWS Lambda launched 2014, Vercel production since 2020, Cloudflare Workers
  since 2018) are now boring technology by any reasonable measure. Meanwhile,
  Terraform state management, Docker layer optimization, and reverse proxy
  configuration are all accidental complexity that serverless eliminates entirely.
  How should your complexity budget and "boring technology" heuristic be updated
  to correctly account for the fact that serverless is often simpler, not more
  complex? Specifically: (a) Should "serverless deployment" score LOWER than
  "server + container + orchestration" on your complexity budget? (b) Should the
  "boring technology" heuristic include serverless platforms as boring? (c) What
  signals should trigger margo to flag server infrastructure as over-engineering
  when serverless would suffice?
- **Context to provide**: Current margo AGENT.md complexity budget section,
  boring technology section, the user's framing of the problem.
- **Why this agent**: Margo is the YAGNI/KISS enforcer. If margo's heuristics
  incorrectly penalize serverless, the entire system inherits that bias. Margo
  needs to recalibrate.

### Consultation 3: Technology Radar Assessment of Serverless Maturity

- **Agent**: gru
- **Planning question**: Using your adopt/trial/assess/hold framework, classify
  the following serverless platforms: AWS Lambda, Cloudflare Workers/Pages,
  Vercel, Netlify, Deno Deploy. For each, assess: production maturity, community
  velocity, failure mode documentation, vendor lock-in risk, and cost model
  predictability. The goal is to establish whether serverless is legitimately
  "boring technology" that should be a default recommendation for greenfield
  projects, or whether it still carries enough risk to warrant case-by-case
  assessment. Also: should the despicable-agents roster include a dedicated
  serverless agent, or should serverless knowledge be distributed across
  iac-minion and edge-minion?
- **Context to provide**: gru's adopt/trial/assess/hold framework, the user's
  observation that serverless is being incorrectly treated as complex, the
  current agent roster structure.
- **Why this agent**: Gru's role is strategic technology assessment. The question
  of whether serverless is "adopt" or "trial" directly determines how it should
  be treated in the system's defaults.

### Consultation 4: Convention and Entry Point Design

- **Agent**: lucy
- **Planning question**: If we want to encode "serverless-first for greenfield
  projects" as a system-level default, where should this convention live?
  Options: (a) project CLAUDE.md as a technology preference, (b) margo's
  heuristics as a complexity calibration, (c) iac-minion's working patterns
  as a "start here" default, (d) the delegation table in the-plan.md as a new
  routing row, (e) a combination. From your perspective as convention enforcer,
  which encoding is most enforceable, least likely to drift, and most discoverable
  by agents during planning? Consider the resolution hierarchy (CLAUDE.md vs
  agent knowledge vs delegation table) and where a "greenfield defaults" directive
  would have the most consistent effect.
- **Context to provide**: The CLAUDE.md hierarchy, the-plan.md delegation table
  structure, lucy's convention enforcement process.
- **Why this agent**: Lucy enforces conventions and CLAUDE.md compliance. The
  question of WHERE to encode serverless-first is a convention design question --
  lucy's core domain.

### Consultation 5: Developer Experience for Serverless Defaults

- **Agent**: devx-minion
- **Planning question**: From a developer experience perspective, what does a
  good "serverless-first greenfield" experience look like? When a developer
  starts a new project, what should the default deployment path be? What are the
  common serverless DX pain points (cold starts, local development, debugging,
  vendor lock-in, cost surprises at scale) and how should the agent system
  help developers navigate them? Should the system have a "complexity escalation
  path" -- start serverless, move to containers when you hit limits -- and if so,
  what are the trigger signals for escalation?
- **Context to provide**: The user's observation that `vercel deploy` is simpler
  than Docker + Terraform, the current iac-minion remit.
- **Why this agent**: DevX-minion specializes in developer onboarding and the
  experience of using tools. The serverless-first question is fundamentally about
  what the simplest developer path should be.

## Cross-Cutting Checklist

- **Testing**: Not included for planning. No code will be written. Test
  implications of serverless (e.g., testing Lambda functions locally) are within
  scope of the advisory but do not require test-minion consultation at the
  planning phase.
- **Security**: Not included for planning. Security implications of serverless
  (shared responsibility model, function-level permissions) are relevant but this
  is an advisory about system bias, not a security review. If recommendations
  lead to agent changes, security review would apply at that point.
- **Usability -- Strategy**: Included via devx-minion (Consultation 5). The
  "developer as user" perspective is the relevant UX lens here -- the question
  is about what the simplest developer experience should be. ux-strategy-minion
  is not needed because this advisory is about infrastructure defaults, not
  end-user journeys.
- **Usability -- Design**: Not applicable. No UI is being designed.
- **Documentation**: Not included for planning. If the advisory leads to agent
  changes, documentation would follow. software-docs-minion would be relevant
  at execution time, not advisory time.
- **Observability**: Not applicable to this advisory. Observability implications
  of serverless (structured logging in Lambda, distributed tracing across
  functions) are within scope of the advisory discussion but do not require
  dedicated observability-minion consultation at planning.

### Justification for Checklist Exclusions

This is an advisory-only consultation -- no code, no infrastructure, no
user-facing changes. The cross-cutting concerns (testing, security,
observability, documentation) are relevant to the TOPIC being discussed
(serverless) but not to the ACTIVITY being performed (analysis and
recommendations). Including these agents in an advisory would be scope creep
by margo's own standards. If the advisory produces actionable recommendations
that lead to agent changes, those changes would go through the full nefario
process including all cross-cutting reviews.

ux-strategy-minion is partially covered via devx-minion's developer experience
consultation, which addresses the "user journey" dimension for the relevant
user persona (developers choosing infrastructure).

## Anticipated Approval Gates

None. This is an advisory consultation -- no execution plan, no deliverables
requiring approval. The output is a report of specialist recommendations that
the user can act on (or not) at their discretion.

## Rationale

Five specialists were chosen because the question has five distinct dimensions:

1. **iac-minion** -- the agent most directly affected by the bias. Its knowledge
   gap IS the bias for deployment recommendations.
2. **margo** -- the agent whose heuristics amplify the bias. Complexity budget
   and boring-tech scoring need recalibration.
3. **gru** -- provides the objective technology maturity assessment that grounds
   the entire discussion. Is serverless boring or not?
4. **lucy** -- answers the "where to encode it" question, which is a convention
   design problem.
5. **devx-minion** -- provides the developer experience perspective that
   contextualizes what "simple" actually means in practice.

Agents NOT included and why:
- **edge-minion**: Already has some serverless knowledge (Workers). Could
  contribute, but the consultation would overlap heavily with iac-minion's
  self-assessment. If gru recommends distributing serverless knowledge,
  edge-minion's role will be addressed in gru's response.
- **data-minion**: Already has serverless database knowledge. Not directly
  relevant to the deployment bias question.
- **security-minion**: Serverless security model is important but orthogonal
  to the bias correction question. Would be consulted if this leads to
  execution.

## Scope

**In scope**: Analysis of where anti-serverless bias lives in the agent system,
recommendations for correcting it, assessment of serverless maturity,
recommendation on agent roster changes, guidance on greenfield defaults.

**Out of scope**: Writing code, modifying agent files, modifying the-plan.md,
modifying CLAUDE.md, creating new agents, executing any changes. This is purely
advisory.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent build/rebuild | Not relevant to this advisory |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | UI configuration | Not relevant to this advisory |

No user-global skills discovered that overlap with this task domain.

### Precedence Decisions

No conflicts -- neither discovered skill overlaps with the advisory domain.
