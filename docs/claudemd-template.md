[< Back to Architecture Overview](architecture.md)

# CLAUDE.md Template: Deployment Section

A template for target projects that want to signal deployment preferences to the despicable-agents team.

## When to omit this section

Most projects do not need a Deployment section. You should omit it entirely if:

- You have no strong preference and are happy to evaluate what agents recommend.
- Your project already contains infrastructure artifacts (`Dockerfile`, `terraform/`, `wrangler.toml`, `docker-compose.yml`, etc.) that make the deployment approach obvious.
- You are early in development and deployment decisions have not been made yet.

When no Deployment section exists, agents recommend an approach and explain their reasoning. You can accept or redirect. Existing infrastructure files in your repository serve as implicit signals -- agents read them and factor them into recommendations without needing explicit prose.

**Only add this section when you have preferences or constraints that are not already captured by your project files.**

## The template

Add the following `## Deployment` section to your project's `CLAUDE.md`, replacing the placeholder with your situation:

```markdown
## Deployment

<!-- Optional. Omit this section entirely if you have no deployment
     preferences -- agents will recommend an approach and explain
     their reasoning. You can accept or redirect. -->

We deploy on [platform/approach].

<!-- Add context that helps agents understand your deployment situation:
     existing infrastructure, constraints, team capacity, or preferences. -->
```

That is the entire template. One sentence declaring the platform or approach, with optional context underneath. The section captures preferences and context, not decisions -- the agent team uses this as input when making technical recommendations.

## Examples

The examples below show different levels of specificity. All are valid. Use whichever level matches what you know about your situation.

### Minimal

```markdown
## Deployment

We deploy on Vercel.
```

One sentence is enough. Agents will work within this constraint without needing justification.

### Specific platform (serverless)

```markdown
## Deployment

We deploy on Cloudflare Pages with Workers functions. Budget is under
$25/month. Team is experienced with JavaScript but has no Docker experience.
```

### Specific platform (self-managed)

```markdown
## Deployment

We deploy on a Hetzner VPS using Docker Compose. We have an existing
Terraform setup and a CI/CD pipeline via GitHub Actions.
```

### General preference

```markdown
## Deployment

Keep deployments simple -- prefer managed platforms where possible. We are
a small team (2 developers) and cannot dedicate time to maintaining
infrastructure. Fast iteration speed matters more than fine-grained control.
```

### Mixed infrastructure

```markdown
## Deployment

We run stateful services (Postgres, Redis) on a Hetzner VPS with Docker
Compose and deploy stateless APIs and frontends to Cloudflare Workers.
CI/CD runs through GitHub Actions.
```

### No preference

Do not add a Deployment section at all. Section absence is the signal: agents will recommend an approach and explain their reasoning, and you decide whether to accept or redirect.

## What this section is not

The Deployment section is not an infrastructure blueprint or a binding contract. It gives agents enough context to make relevant recommendations. You are not committing to anything by writing it -- you are telling agents where you are starting from so they can meet you there.

## Discoverability

Consider linking to this template from your project's `docs/architecture.md` or equivalent documentation index so that contributors can find it when setting up deployment preferences.
