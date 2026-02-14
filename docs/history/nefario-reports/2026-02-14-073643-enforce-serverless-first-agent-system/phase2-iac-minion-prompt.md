You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Enforce serverless-first stance across agent system. The agent system must actively prefer serverless for all deployments unless specific blocking concerns exist. This is rooted in the Helix Manifesto's "lean and mean" and "ops reliability wins" principles.

## Your Planning Question

Your Step 0 currently says "criteria-driven, not preference-driven. No default to any topology." The new framing is: "Start with serverless. The first question is 'can this be done serverless without blocking concerns?' If yes, serverless. If no, document which blocking concern (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale) drives the deviation."

How should Step 0 be restructured to encode this? Specifically:
(a) What should the opening framing statement replace "criteria-driven, not preference-driven" with?
(b) Should the 10-dimension evaluation checklist stay as-is (used to validate blocking concerns) or be restructured as a "blocking concern detector"?
(c) How should the topology recommendation section change from four equal options to serverless-default with escalation?
(d) Your identity line says "topology-neutral" -- what should it say instead?
(e) The RESEARCH.md (line 493) says "The decision must be neutral -- no default to any topology" -- what should this become?

Note: edge-minion is also being consulted on the serverless platform landscape. Your recommendations should focus on the decision framework and Step 0 structure, not on enumerating platform capabilities.

## Context

Read these files for current state:
- the-plan.md (iac-minion spec, lines 726-757)
- minions/iac-minion/AGENT.md (Step 0 at lines 164-188, identity at line 17)
- minions/iac-minion/RESEARCH.md (line 493 and surrounding context)

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
5. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase2-iac-minion.md
