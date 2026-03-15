You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Fix the structural serverless bias in the agent system. The agent team defaults to Docker+Terraform for every deployment, even when serverless would suffice. Three gaps compound: (1) iac-minion has zero serverless knowledge, (2) margo's complexity budget penalizes novelty not operational burden, (3) delegation table has no serverless routing.

Solution: four coordinated spec changes in the-plan.md: expand iac-minion spec, recalibrate margo spec, update delegation table, provide CLAUDE.md template for target projects.

Key constraint: Do NOT hardcode "serverless-first" in any AGENT.md. These are generic agents.

## Your Planning Question

The changes require modifying agent behavior through spec changes that `/despicable-lab` will convert into system prompts. This is fundamentally a prompt engineering challenge. Four questions:

(a) **Decision framework encoding**: iac-minion needs a deployment strategy selection framework (serverless vs. container vs. self-managed) in its system prompt. How should decision trees be structured in agent system prompts so they are followed reliably? What patterns prevent the agent from ignoring the framework or applying it rigidly?

(b) **Opposite-bias prevention**: The issue explicitly warns "do NOT hardcode serverless-first." How should the prompt guard against swinging from always-infrastructure to always-serverless? What prompt engineering techniques balance between two valid options without creating a default bias toward either?

(c) **Complexity scoring in prompts**: Margo's complexity budget is being recalibrated to score operational burden. How do you encode nuanced scoring heuristics (not just numbers) in a system prompt so the agent applies them consistently across different contexts?

(d) **Cross-agent coherence**: When iac-minion and margo both get updated specs, their behaviors need to be complementary (iac-minion selects strategy, margo validates complexity). How should the prompt framing ensure these two agents reinforce rather than contradict each other?

## Context

Read these files for context:
- Current iac-minion spec: the-plan.md lines 722-749
- Current margo spec: the-plan.md lines 537-570
- Current iac-minion AGENT.md: minions/iac-minion/AGENT.md (to see how specs translate to built prompts)
- Current margo AGENT.md: margo/AGENT.md (especially Complexity Budget and Boring Technology sections)
- System prompt structure: the-plan.md lines 66-74
- Build pipeline docs: docs/build-pipeline.md

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ai-modeling-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-ai-modeling-minion.md`
