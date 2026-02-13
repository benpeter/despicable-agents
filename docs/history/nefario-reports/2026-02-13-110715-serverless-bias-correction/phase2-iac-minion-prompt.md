You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Advisory-only consultation: The despicable-agents system has a structural bias against serverless infrastructure. When starting greenfield projects, the system tends to recommend Docker + Terraform + reverse proxy stacks when serverless (Vercel, Lambda, Cloudflare Workers) would be simpler. The user observes that serverless is super simple -- no servers to manage, no scaling config, no Docker, no Terraform for basic deployments. We need to understand where the bias lives and how to correct it.

## Your Planning Question

You are being asked to critically assess your own knowledge base. Your current remit covers Terraform, Docker, GitHub Actions, reverse proxies, and cloud provider patterns. Serverless platforms (AWS Lambda, Cloudflare Workers, Vercel, Netlify, Deno Deploy, Cloudflare Pages) are absent from your knowledge.

For a greenfield project that needs a simple API or a static site with a few server functions, compare the operational complexity of:
(a) your current default stack (Terraform + Docker + reverse proxy + server),
and (b) a serverless deployment (e.g., `vercel deploy` or a single Lambda).

What serverless knowledge should be added to your remit? What should remain outside your scope? Should serverless be your default recommendation for greenfield, with server infrastructure as the escalation path when serverless constraints are hit?

## Context

Read the following files for full context:
- /Users/ben/github/benpeter/despicable-agents/minions/iac-minion/AGENT.md (your current knowledge base)
- /Users/ben/github/benpeter/despicable-agents/the-plan.md (lines 722-748 for your spec)

The user's core observation: serverless is simpler than the current default stack for most greenfield projects. `vercel deploy` is 1 command with zero infrastructure management. Docker + Terraform + Caddy is dozens of configuration files.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: iac-minion

### Recommendations
<your expert recommendations>

### Proposed Tasks
<specific tasks that should be in the execution plan>

### Risks and Concerns
<things that could go wrong>

### Additional Agents Needed
<or "None">

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase2-iac-minion.md
