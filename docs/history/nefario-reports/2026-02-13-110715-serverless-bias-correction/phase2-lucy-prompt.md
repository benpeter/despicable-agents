You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Advisory-only consultation: The despicable-agents system has a structural bias against serverless infrastructure. We need to determine the right entry point to encode "serverless-first for greenfield" as a system convention. The bias is emergent -- not from any single explicit rule, but from gaps in agent knowledge and heuristic framing.

## Your Planning Question

If we want to encode "serverless-first for greenfield projects" as a system-level default, where should this convention live? Options:
(a) project CLAUDE.md as a technology preference
(b) margo's heuristics as a complexity calibration
(c) iac-minion's working patterns as a "start here" default
(d) the delegation table in the-plan.md as a new routing row
(e) a combination

From your perspective as convention enforcer, which encoding is most enforceable, least likely to drift, and most discoverable by agents during planning? Consider the resolution hierarchy (CLAUDE.md vs agent knowledge vs delegation table) and where a "greenfield defaults" directive would have the most consistent effect.

Also consider: this is an agent system designed to be generic and publishable (Apache 2.0). "Serverless-first" as a hardcoded default in agent files makes the agents opinionated in a way that may not suit all users. Should the convention be in CLAUDE.md (per-project) rather than baked into agents?

## Context

Read the following files:
- /Users/ben/github/benpeter/despicable-agents/lucy/AGENT.md (your current spec)
- /Users/ben/github/benpeter/despicable-agents/CLAUDE.md (project conventions)
- /Users/ben/github/benpeter/despicable-agents/the-plan.md (design principles, lines 1-76)

The bias is distributed across:
1. iac-minion's knowledge gap (no serverless in remit)
2. margo's complexity budget (scores novelty, not operational burden)
3. Delegation table (no serverless routing row)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. Return your contribution in this format:

## Domain Plan Contribution: lucy

### Recommendations
<your expert recommendations>

### Proposed Tasks
<specific tasks>

### Risks and Concerns
<things that could go wrong>

### Additional Agents Needed
<or "None">

5. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase2-lucy.md
