MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final advisory report.

## Original Task

Advisory-only request -- no execution, no post-processing. Consult specialists on whether the despicable-agents system has a serverless bias, where it lives, and how to correct it. Determine:
1. Where anti-serverless bias lives in the system
2. The right entry point to encode serverless-first for greenfield
3. Whether a dedicated serverless agent is needed or existing agents can absorb it
4. What greenfield defaults should look like

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase2-iac-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase2-margo.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase2-gru.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase2-devx-minion.md

## Key consensus across specialists:

1. **iac-minion** (planning): Serverless should be the default for greenfield. Add deployment strategy triage as Step 0. Restructure from tool-first to decision-first. Operational complexity ratio is 10:1 (server vs serverless). Critical: margo coordination required.

2. **margo** (planning): Split complexity budget (self-managed 8pts vs managed/serverless 3pts). Add "Infrastructure Over-Engineering" detection pattern. Add serverless to boring tech examples. Risk: over-correction.

3. **gru** (planning): Lambda and CF Workers are ADOPT. Vercel is TRIAL. No new agent needed -- expand iac-minion and edge-minion. Vendor lock-in is highest-severity risk.

4. **lucy** (planning): CLAUDE.md is most enforceable entry point for preferences. Agents stay generic (publishability). The bias is 3 gaps not 1 convention. Layered fix needed.

5. **devx-minion** (planning): 50:1 time-to-first-deploy penalty. Define 5-level escalation path. Current system starts at Level 4, should start at Level 0-1. Complexity should be opt-in, not opt-out.

## External Skills Context
No external skills detected relevant to this advisory.

## Instructions

This is an ADVISORY-ONLY synthesis. There is no execution plan -- the output is a consolidated advisory report with recommendations.

1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Synthesize into a coherent advisory with:
   - Root cause analysis (where the bias lives)
   - Recommended changes (prioritized, with specific entry points)
   - Agent roster recommendation (new agent vs. distributed knowledge)
   - Greenfield defaults recommendation
   - Implementation roadmap (if the user decides to act)
4. Be specific about WHAT to change and WHERE -- reference file paths, section names, line numbers
5. Write your complete synthesis to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase3-synthesis.md
