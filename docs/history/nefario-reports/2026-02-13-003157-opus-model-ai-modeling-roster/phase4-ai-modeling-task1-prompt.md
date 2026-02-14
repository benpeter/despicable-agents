You are updating the iac-minion specification in `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 722-748) to address the structural serverless bias identified in GitHub issue #91.

## What to change

1. **Expand the Remit** to include serverless platforms as a peer technology alongside Docker and Terraform. Add these bullet points:
   - "Serverless platforms (AWS Lambda, Cloudflare Workers/Pages, Cloud Functions, Vercel Functions)"
   - "Deployment strategy selection (evaluating serverless vs. container vs. self-managed for a given workload)"

2. **Update the Domain line** to include serverless. Change from:
   "Infrastructure as Code, CI/CD, containerization, deployment"
   to:
   "Infrastructure as Code, CI/CD, containerization, serverless platforms, deployment"

3. **Add to "Does NOT do"** a boundary clarification with edge-minion:
   "Edge-layer runtime behavior (caching strategy, edge function optimization, CDN routing rules) (-> edge-minion)"
   This clarifies the boundary: iac-minion handles where/how code deploys (including to serverless platforms); edge-minion handles how it runs well at the edge once deployed.

4. **Expand the Research Focus** to include:
   "Serverless deployment patterns, cold start optimization, FaaS cost modeling, serverless vs. container decision criteria, when serverless is inappropriate (long-running processes, stateful workloads, cold-start-sensitive workloads)"

   Note the explicit inclusion of "when serverless is inappropriate" -- this ensures the research and resulting AGENT.md cover both directions, preventing opposite-bias.

5. **Bump spec-version** from 1.0 to 2.0

## Advisory: spec-version 2.0 (from lucy governance review)

The project's versioning convention (the-plan.md line 63) states "bump major for remit changes, minor for refinements." Task 1 adds two new remit bullets (serverless platforms, deployment strategy selection) and expands the Domain line -- these are remit expansions, not refinements of existing remit items. Therefore the correct bump is 2.0, not 1.1. margo (adding "infrastructure overhead" to an existing bullet) and edge-minion (framing only, no remit expansion) are correctly 1.1.

## Advisory: deviation from issue #91 documented (from lucy governance review)

Issue #91 proposes adding a Principles line to iac-minion: "Serverless is the default for greenfield; server infrastructure is the escalation path." This plan intentionally omits that addition. The framing constraints below prevent adding "prefer serverless" language. This is a deliberate departure from the issue's solution section, consistent with the issue's own "What NOT to do" section ("Do NOT hardcode 'serverless-first'"). The plan resolves the contradiction between the issue's solution section and its constraints section in favor of topology-neutrality.

## Advisory: boundary symmetry with edge-minion (from test-minion review)

The "Does NOT do" boundary clarification you add to iac-minion must use terminology that will be symmetric with what Task 3 adds to edge-minion. Use consistent terms: "edge-layer runtime behavior" in iac-minion's exclusion should mirror "deployment configuration" in edge-minion's exclusion. Both specs should reference each other by name.

## Framing constraints (critical)

- Do NOT add language like "prefer serverless" or "default to serverless for simple workloads." The spec teaches the domain without encoding a preference.
- Do NOT remove existing Docker/Terraform/reverse proxy content. Serverless is additive.
- The spec describes WHAT iac-minion knows and does. The deployment strategy decision framework (five-criteria decision tree, "Step 0" before infrastructure design) will be built into the AGENT.md by /despicable-lab from the spec + research. The spec's Research Focus guides what research is gathered; the Working Patterns in the built AGENT.md will contain the procedural framework.
- Keep the change minimal and surgical per the project's KISS philosophy.

## Boundary clarification rationale

The iac-minion / edge-minion boundary follows this principle:
- iac-minion: "where does it run and how does it get there" (deployment target selection, CI/CD pipelines, infrastructure-as-code, platform configuration)
- edge-minion: "how does it run well once it's there" (caching, routing, edge functions, storage bindings, runtime optimization)

For shared config files (wrangler.toml, serverless.yml): iac-minion owns the file structurally (deployment targets, bindings, resource definitions); edge-minion reviews/advises on edge-specific runtime settings.

## What NOT to do

- Do not modify any other agent's spec section
- Do not modify the delegation table (that is a separate task)
- Do not add platform-specific implementation details (those go in RESEARCH.md and AGENT.md via the build pipeline)
- Do not write an exhaustive serverless catalog -- cover the major platforms and patterns per YAGNI

## Files to modify

- `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 722-748 only -- the iac-minion spec section)

## Deliverables

- Updated iac-minion spec section in the-plan.md with expanded remit, updated domain, boundary clarification, expanded research focus, and bumped spec-version to 2.0.

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
