You are rewriting the CLAUDE.md deployment template to encode serverless-first as the system default. The template currently presents all deployment options as equals. The new version establishes that omission = serverless default, and the section exists primarily for when projects need to deviate from serverless.

## File
`/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md`

## Changes to make

### "When to omit this section" (lines 7-17)

Replace the entire content from "Most projects do not need..." through "...not already captured by your project files." with:

```
Most projects do not need a Deployment section. You should omit it entirely if:

- You are deploying to serverless/managed platforms (the system default).
- Your project already contains infrastructure artifacts (`wrangler.toml`, `vercel.json`, `netlify.toml`, serverless framework configs, etc.) that confirm the serverless approach.
- You are early in development and have no blocking reason to deviate from serverless.

When no Deployment section exists, agents default to serverless/managed platforms and select the best fit for your workload (e.g., Cloudflare Workers, Vercel, AWS Lambda). Existing infrastructure files in your repository serve as implicit signals -- agents read them and factor them into recommendations without needing explicit prose.

**Add this section only when you need to deviate from the serverless default** -- because you have blocking concerns (persistent connections, long-running processes, compliance-mandated control, or proven cost optimization at scale) or because you have existing non-serverless infrastructure that agents should respect.
```

### Template HTML comment (lines 26-28)

Replace: `<!-- Optional. Omit this section entirely if you have no deployment preferences -- agents will recommend an approach and explain their reasoning. You can accept or redirect. -->`

With: `<!-- Optional. Omit this section entirely to use the serverless default. Add this section to deviate from serverless or to specify a particular serverless platform. -->`

### Examples section (lines 38-92)

Restructure examples into two groups. Replace the current examples with:

```
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
```

### "What this section is not" (lines 94-96)

Replace: "The Deployment section is not an infrastructure blueprint or a binding contract. It gives agents enough context to make relevant recommendations. You are not committing to anything by writing it -- you are telling agents where you are starting from so they can meet you there."

With: "The Deployment section is not an infrastructure blueprint or a binding contract. When present, it overrides or refines the system's serverless default -- it tells agents where you are starting from so they can meet you there. When absent, agents default to serverless/managed platforms appropriate for your workload."

## What NOT to do
- Do not modify the Discoverability section
- Do not modify the opening line or the back-link
- Do not add any new sections
- Keep the template block (```markdown ... ```) structure intact

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
