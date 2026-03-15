You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Enforce serverless-first stance across agent system. The agent system must actively prefer serverless for all deployments unless specific blocking concerns exist. This is rooted in the Helix Manifesto's "lean and mean" and "ops reliability wins" principles.

## Your Planning Question

The CLAUDE.md template (`docs/claudemd-template.md`) is currently topology-neutral -- it says "agents recommend an approach" when no section exists, and presents serverless, self-managed, and general preference examples as equals. The new requirement is that the template encodes serverless-first as the strong default. When a project has no Deployment section, the system should default to serverless (not "recommend an approach"). When a project has a Deployment section, it should be framed as "we deploy on X (deviation from serverless default because: Y)."

How should the template change? Specifically:
(a) What should the "When to omit this section" guidance say now that omission means "use serverless default"?
(b) How should the examples change -- should the self-managed example explicitly show the "deviation because" framing?
(c) Does the "What this section is not" paragraph need updating?
(d) How do you enforce this at governance level -- when reviewing a plan, do you check that non-serverless choices have documented blocking concerns?
(e) Which documentation artifacts beyond the template reference "topology-neutral" or "criteria-driven" framing that would become inconsistent? Check docs/agent-catalog.md, docs/architecture.md, and any other docs/ files.

Note: margo is being consulted on enforcement mechanics. Your focus should be on template design, governance checking, and cross-document consistency.

## Context

Read these files for current state:
- docs/claudemd-template.md (the current template)
- docs/agent-catalog.md (check for topology-neutral references)
- docs/architecture.md (check for topology-neutral references)

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
5. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase2-lucy.md
