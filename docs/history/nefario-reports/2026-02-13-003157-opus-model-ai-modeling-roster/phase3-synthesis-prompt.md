MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

Fix the structural serverless bias in the agent system (GitHub issue #91). Four coordinated changes: expand iac-minion spec (1.0->1.1), recalibrate margo spec (1.0->1.1), update delegation table, provide CLAUDE.md template. Plus edge-minion framing update if needed. Then rebuild affected agents via /despicable-lab.

Additional context: use opus for all agents during execution, make ai-modeling part of the roster.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-margo.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-edge-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-lucy.md

## Key consensus across specialists:

### margo
Two-column complexity budget (novelty + operational burden scored independently); managed services score lower but never zero; infrastructure proportionality heuristic with 5 concrete signals as investigation triggers, not vetoes.

### edge-minion
Split boundary: "where/how it gets there" (iac-minion) vs "how it runs well once there" (edge-minion). 5 concrete escalation triggers for serverless-to-container. Rename delegation row to "Serverless platform configuration". Add one sentence to edge-minion spec acknowledging Workers/Pages as full-stack serverless.

### devx-minion
CLAUDE.md template as single optional `## Deployment` section in prose. Agents recommend simplest-viable without asking when no preference. Existing infra artifacts (Dockerfile, terraform/) serve as implicit signals. Delegation table row "Serverless platform deployment" breaks convention -- use task-type routing not solution-category.

### ai-modeling-minion
Place deployment decision tree in Working Patterns as Step 0. Use 5 workload-centric criteria. Require explicit justification. Split margo budget into build-time and operational dimensions. Align agents via shared vocabulary (self-managed, managed, serverless).

### lucy
All four changes map to three gaps. CRITICAL: nefario's AGENT.md embeds delegation table and must be regenerated (bump spec-version to 2.1 or explicit manual regen). CLAUDE.md template at docs/claudemd-template.md. Three drift risks flagged.

## Key Conflicts to Resolve

1. **Delegation table row naming**: edge-minion says "Serverless platform configuration", devx-minion says avoid "serverless" in the row name entirely (use task-type routing). These are different positions.

2. **Nefario regeneration**: lucy flags that nefario must be regenerated since it embeds the delegation table. This was not in the original scope but is a necessary cascading change.

## External Skills Context
One DEFERRED external skill: /despicable-lab for rebuilding affected agents after spec changes.

## Instructions
1. Review all specialist contributions
2. Resolve the delegation table naming conflict
3. Resolve the nefario regeneration requirement
4. Incorporate risks and concerns into the plan
5. Create the final execution plan in structured format
6. Ensure every task has a complete, self-contained prompt
7. Include the DEFERRED /despicable-lab macro-task for agent rebuilds
8. All agents should use model: opus (per user directive)
9. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase3-synthesis.md
