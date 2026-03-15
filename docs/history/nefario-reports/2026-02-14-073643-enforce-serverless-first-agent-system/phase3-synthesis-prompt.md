MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

Enforce serverless-first stance across agent system. The agent system must actively prefer serverless for all deployments unless specific blocking concerns exist (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale). This is rooted in the Helix Manifesto's "lean and mean" and "ops reliability wins" principles. The first question is always "can this be done serverless without blocking concerns?" If yes, serverless. If no, document why not.

**Success criteria**:
- iac-minion's Step 0 starts with "serverless unless blocked" — not a neutral evaluation of equal options
- margo's complexity budget actively penalizes self-managed infrastructure when a serverless alternative exists without blocking concerns
- CLAUDE.md template encodes serverless-first as the strong default, not an optional suggestion
- The framing is "why NOT serverless?" (justify deviation), not "which topology fits?" (neutral evaluation)
- Agents remain usable for non-serverless work — the preference is strong, not a hard block

**Constraints**:
- This is an incremental pass on branch nefario/fix-serverless-bias, on top of PR #123
- PR #123 already exists — append Post-Nefario Updates, do not create a new PR
- Push with `git push origin HEAD:nefario/fix-serverless-bias`
- Use opus for all agents

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase2-iac-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase2-margo.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase2-edge-minion.md

## Key consensus across specialists:

## Summary: iac-minion
Phase: planning
Recommendation: Restructure Step 0 from neutral evaluation to serverless-default with blocking concern gate. Replace "criteria-driven, not preference-driven" with "Start with serverless. Only deviate when a documented blocking concern demands it." Two-tier checklist: blocking concern gate first, then validation dimensions.
Tasks: 3 -- Rewrite Step 0 framing and checklist; Update identity line and RESEARCH.md; Rebuild via /despicable-lab
Risks: Over-rotation treating serverless as dogma; cold-start cost measurement gap
Conflicts: none

## Summary: margo
Phase: planning
Recommendation: Three surgical changes to existing complexity budget: burden-of-proof rule (must use managed/serverless column unless documented blocking concern), framing rule #1 amendment (self-managed when serverless viable IS disproportion), framing rule #3 refinement (quantify budget gap, leave platform to gru).
Tasks: 2 -- Update margo spec in the-plan.md; Rebuild via /despicable-lab
Risks: Blocking concerns list maintenance as platforms evolve
Conflicts: none

## Summary: lucy
Phase: planning
Recommendation: Rewrite CLAUDE.md template so omission = serverless default. Examples split into "confirming default" (optional) and "deviating from default" (with blocking concern). New COMPLIANCE check for plan review. Decision 31 entry documenting supersession of topology-neutral stance. margo/AGENT.md "Topology-Neutral" heading is orthogonal and does NOT need changing.
Tasks: 3 -- Rewrite template; Add Decision 31; Governance enforcement update
Risks: Historical advisory contradiction without Decision 31 documentation
Conflicts: none

## Summary: edge-minion
Phase: planning
Recommendation: Add "execution environment constraints" as 5th blocking concern. Adopt edge-first sub-preference within serverless (sequential escape: edge → cloud serverless → containers → self-managed). Near-zero cold starts at edge strengthen the case.
Tasks: 4 -- Add 5th blocking concern; Encode edge-first sub-preference; Update escalation cascade; Validate boundaries
Risks: Platform limits change over time; edge-first may confuse if not tied to latency principle
Conflicts: none

## External Skills Context
`/despicable-lab` (ORCHESTRATION) -- DEFERRED task for rebuilding iac-minion and margo after spec changes. Same pattern as PR #123 Task 7.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Include /despicable-lab as a DEFERRED task for agent rebuilds
7. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase3-synthesis.md

Key design decisions to resolve:
- edge-minion recommends edge-first sub-preference within serverless. Evaluate whether this adds value (aligns with latency principle) or over-prescribes.
- lucy flags that a Decision 31 entry is needed to document the supersession of the topology-neutral stance from PR #123.
- edge-minion proposes a 5th blocking concern (execution environment constraints). Validate whether this is genuinely distinct from the existing four or should be folded into "long-running processes" or similar.
