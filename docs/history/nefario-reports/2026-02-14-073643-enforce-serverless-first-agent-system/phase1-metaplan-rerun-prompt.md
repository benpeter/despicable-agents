MODE: META-PLAN

You are creating a revised meta-plan after a team adjustment.

## Task

Enforce serverless-first stance across agent system

**Outcome**: The agent system actively prefers serverless for all deployments unless specific blocking concerns exist (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale). This is not a suggestion or one option among equals — it's the default, rooted in the Helix Manifesto's "lean and mean" and "ops reliability wins" principles. The first question is always "can this be done serverless without blocking concerns?" If yes, serverless. If no, document why not.

**Success criteria**:
- iac-minion's Step 0 starts with "serverless unless blocked" — not a neutral evaluation of equal options
- margo's complexity budget actively penalizes self-managed infrastructure when a serverless alternative exists without blocking concerns
- CLAUDE.md template encodes serverless-first as the strong default, not an optional suggestion
- The framing is "why NOT serverless?" (justify deviation), not "which topology fits?" (neutral evaluation)
- Agents remain usable for non-serverless work — the preference is strong, not a hard block

**Scope**:
- In: the-plan.md specs (iac-minion, margo), CLAUDE.md template, agent rebuilds via /despicable-lab, any framing language in docs that says "topology-neutral" or "criteria-driven without preference"
- Out: delegation table (already correct), edge-minion boundaries (already correct), new agents

**Constraints**:
- This is an incremental pass on branch nefario/fix-serverless-bias, on top of PR #123. Stay on this branch. Commit on top of existing commits. Push with `git push origin HEAD:nefario/fix-serverless-bias`. PR #123 already exists — append a Post-Nefario Updates section to its description, do not create a new PR.
- The Helix Manifesto is the philosophical anchor: serverless = lean and mean, linear scalability, ops reliability
- "Don't hardcode serverless-first" (from issue #91's What NOT to do) was about not making agents unusable for non-serverless cases — it was NOT about avoiding a strong preference

use opus for all agents

## Working Directory
/Users/ben/github/benpeter/2despicable/4

## Original Meta-Plan
Read the original meta-plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase1-metaplan.md

The following meta-plan was produced for the original team. Use it as context for the revised plan, not as a template to minimally edit.

## Team Adjustment
Added: edge-minion. Removed: ux-strategy-minion, software-docs-minion, test-minion.

Revised team: iac-minion, margo, lucy, edge-minion.

## Constraint Directives
- Keep the same scope and task description
- Preserve external skill integration decisions unless the team change removes all agents relevant to a skill's domain
- Generate planning consultations for ALL agents in the revised team
- Re-evaluate the cross-cutting checklist against the new team
- Produce output at the same depth and format as the original
- Do NOT change the fundamental scope of the task
- Do NOT add agents the user did not request (beyond cross-cutting requirements)
- Design planning questions as a coherent set -- each question should address aspects that no other agent on the team covers, and questions should reference cross-cutting boundaries where relevant

## Instructions
1. Read relevant files to understand the codebase context
2. Generate planning consultations for all 4 agents in the revised team
3. Re-evaluate the cross-cutting checklist against the new team
4. Return the revised meta-plan in the structured format
5. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase1-metaplan-rerun.md
