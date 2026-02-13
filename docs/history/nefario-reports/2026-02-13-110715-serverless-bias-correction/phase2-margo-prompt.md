You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Advisory-only consultation: The despicable-agents system has a structural bias against serverless infrastructure. When starting greenfield projects, the system flags serverless as over-engineering / YAGNI / anti-KISS. But serverless is actually simpler than server-based alternatives for most greenfield cases (no servers, no scaling, no Docker, no Terraform). We need to recalibrate the system's complexity heuristics.

## Your Planning Question

Your complexity budget assigns "New technology: 10 points" and "New service: 5 points." Your "Boring Technology" heuristic frames decade-old tech as safe and newer tech as innovation-token spends. But serverless platforms (AWS Lambda launched 2014, Vercel production since 2020, Cloudflare Workers since 2018) are now boring technology by any reasonable measure. Meanwhile, Terraform state management, Docker layer optimization, and reverse proxy configuration are all accidental complexity that serverless eliminates entirely.

How should your complexity budget and "boring technology" heuristic be updated to correctly account for the fact that serverless is often simpler, not more complex? Specifically:
(a) Should "serverless deployment" score LOWER than "server + container + orchestration" on your complexity budget?
(b) Should the "boring technology" heuristic include serverless platforms as boring?
(c) What signals should trigger margo to flag server infrastructure as over-engineering when serverless would suffice?

## Context

Read the following files:
- /Users/ben/github/benpeter/despicable-agents/margo/AGENT.md (your current heuristics)
- /Users/ben/github/benpeter/despicable-agents/margo/RESEARCH.md (your research backing)

The user's core observation: `vercel deploy` is 1 command. Docker + Terraform + Caddy is dozens of config files. The complexity budget should reflect operational burden, not just novelty.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. Return your contribution in this format:

## Domain Plan Contribution: margo

### Recommendations
<your expert recommendations>

### Proposed Tasks
<specific tasks>

### Risks and Concerns
<things that could go wrong>

### Additional Agents Needed
<or "None">

5. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase2-margo.md
