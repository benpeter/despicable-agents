You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Enforce serverless-first stance across agent system. The agent system must actively prefer serverless for all deployments unless specific blocking concerns exist. This is rooted in the Helix Manifesto's "lean and mean" and "ops reliability wins" principles.

## Your Planning Question

The agent system is shifting from "evaluate all topologies equally" to "serverless unless blocked." As the specialist for edge platforms (Cloudflare Workers/Pages, Vercel, Netlify, Fastly Compute), you have deep knowledge of what these platforms can and cannot do. Your input is needed on two aspects:

(a) The blocking concerns list for the serverless-first default is: persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale. From your experience with edge serverless platforms, is this list complete? Are there common legitimate blocking concerns at the edge layer that are missing -- for example, execution environment constraints (CPU time limits, memory limits, no native binaries), storage access patterns that don't fit edge KV/D1, or multi-platform coordination issues?

(b) iac-minion's Step 0 will become "start with serverless." When the workload fits serverless, there's often a secondary decision: full-cloud serverless (Lambda, Cloud Functions) vs. edge serverless (Workers, Vercel Functions). Should the serverless-first default have a sub-preference for edge-first within serverless, given the Helix Manifesto's latency principle ("<300ms fast. Always.")? Or would that over-prescribe and create confusion?

Note: your boundary with iac-minion is clear (edge-layer behavior vs. deployment strategy). This consultation asks for your platform expertise to inform iac-minion's decision framework, not to expand your remit.

## Context

Read these files for current state:
- the-plan.md (edge-minion spec, lines 760-800)
- minions/iac-minion/AGENT.md (Step 0, lines 164-188, for the dimensions being restructured)

The Helix Manifesto principles anchoring this change:
- "Lean and Mean" — minimize code and dependencies actively
- "Ops reliability wins" — simple, fast, and up beats elegant
- "Latency is not an option" — uncached things are fast. <300ms fast. Always.

Blocking concerns list (the ONLY legitimate reasons to deviate from serverless):
- Persistent connections (WebSockets, long-lived TCP)
- Long-running processes (>30s execution, batch jobs)
- Compliance-mandated infrastructure control
- Cost optimization at scale (proven, measured, not speculative)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. Return your contribution in the structured format
5. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase2-edge-minion.md
