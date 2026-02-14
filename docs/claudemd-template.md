[< Back to Architecture Overview](architecture.md)

# CLAUDE.md Template: Deployment Section

A template for target projects that want to signal deployment preferences to the despicable-agents team.

## When to omit this section

Most projects do not need a Deployment section. You should omit it entirely if:

- You are deploying to serverless/managed platforms (the system default).
- Your project already contains infrastructure artifacts (`wrangler.toml`, `vercel.json`, `netlify.toml`, serverless framework configs, etc.) that confirm the serverless approach.
- You are early in development and have no blocking reason to deviate from serverless.

When no Deployment section exists, agents default to serverless/managed platforms and select the best fit for your workload (e.g., Cloudflare Workers, Vercel, AWS Lambda). Existing infrastructure files in your repository serve as implicit signals -- agents read them and factor them into recommendations without needing explicit prose.

**Add this section only when you need to deviate from the serverless default** -- because you have blocking concerns (persistent connections, long-running processes, compliance-mandated control, measured cost optimization at scale, or execution environment constraints) or because you have existing non-serverless infrastructure that agents should respect.

## The template

Add the following `## Deployment` section to your project's `CLAUDE.md`, replacing the placeholder with your situation:

```markdown
## Deployment

<!-- Optional. Omit this section entirely to use the serverless default. Add this section to deviate from serverless or to specify a particular serverless platform. -->

We deploy on [platform/approach].

<!-- Add context that helps agents understand your deployment situation:
     existing infrastructure, constraints, team capacity, or preferences. -->
```

That is the entire template. One sentence declaring the platform or approach, with optional context underneath. The section captures preferences and context, not decisions -- the agent team uses this as input when making technical recommendations.

## Examples

Examples are grouped by relationship to the serverless default. Use whichever level matches your situation.

### Confirming the default (optional -- omitting the section produces the same behavior)

#### Minimal

```markdown
## Deployment

We deploy on Vercel.
```

One sentence is enough. Agents will work within this constraint without needing justification.

#### Specific platform (serverless)

```markdown
## Deployment

We deploy on Cloudflare Pages with Workers functions. Budget is under
$25/month. Team is experienced with JavaScript but has no Docker experience.
```

### Deviating from the default (document the blocking concern)

#### Self-managed with deviation rationale

```markdown
## Deployment

We deploy on a Hetzner VPS using Docker Compose. Deviation from serverless
default: the application requires persistent WebSocket connections for
real-time collaboration, and our existing Terraform + GitHub Actions pipeline
is already production-proven.
```

#### Mixed infrastructure with partial deviation

```markdown
## Deployment

Stateless APIs and frontends deploy to Cloudflare Workers (serverless default).
Stateful services (Postgres, Redis) run on a Hetzner VPS with Docker Compose.
Deviation for stateful tier: persistent connections and data residency
requirements.
```

### No preference

Do not add a Deployment section at all. Section absence is the signal: agents default to serverless/managed platforms appropriate for your workload.

## What this section is not

The Deployment section is not an infrastructure blueprint or a binding contract. When present, it overrides or refines the system's serverless default -- it tells agents where you are starting from so they can meet you there. When absent, agents default to serverless/managed platforms appropriate for your workload.

## Discoverability

Consider linking to this template from your project's `docs/architecture.md` or equivalent documentation index so that contributors can find it when setting up deployment preferences.
