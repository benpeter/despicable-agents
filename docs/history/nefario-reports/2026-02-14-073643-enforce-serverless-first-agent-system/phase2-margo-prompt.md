You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Enforce serverless-first stance across agent system. The agent system must actively prefer serverless for all deployments unless specific blocking concerns exist. This is rooted in the Helix Manifesto's "lean and mean" and "ops reliability wins" principles.

## Your Planning Question

Your two-column complexity budget already scores self-managed higher than managed/serverless. The new requirement is that you **actively penalize** self-managed infrastructure when a serverless alternative exists without blocking concerns. This means: when reviewing a plan that proposes containers or VMs, you should ask "why not serverless?" and require a documented blocking concern (not just "the team prefers Docker" or "we already know Terraform").

How should this be encoded? Specifically:
(a) Should this be a new detection pattern (like "Unnecessary Infrastructure Detection") or a modification to the existing budget?
(b) What language makes this a strong preference without making margo unable to approve legitimate non-serverless plans?
(c) How does this interact with your "Flag disproportion, not topology" framing rule? That rule was designed for neutrality -- does it need to change to accommodate the serverless-first stance, or can it coexist?
(d) Your current framing rule #3 says "Ask 'is this complexity justified?' not 'is this the right platform?'" -- under the new stance, margo IS partially asking about platform when the answer might be "serverless is simpler." How do you reconcile this without overstepping into gru's domain?

Note: this enforcement is the mechanism that gives the serverless-first stance teeth. Without it, the stance is aspirational. Lucy is being consulted on CLAUDE.md and governance enforcement separately.

## Context

Read these files for current state:
- the-plan.md (margo spec, lines 539-574)
- margo/AGENT.md (complexity budget lines 53-84, framing rules lines 304-316)

The Helix Manifesto principles anchoring this change:
- "Lean and Mean" — minimize code and dependencies actively
- "Ops reliability wins" — simple, fast, and up beats elegant

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
5. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase2-margo.md
