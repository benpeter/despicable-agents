MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

Make all nefario advisories self-contained and readable in isolation. Currently, advisories reference invisible context — task numbers, plan step details, internal decisions — that only make sense inside the agent conversation that produced them. After this change, each advisory carries enough context that a user reading the synthesis, execution report, or task list can evaluate it without opening the originating agent session.

**Success criteria**:
- Each advisory names the concrete artifact, file, or concept it concerns (not "step 1" or "the approach")
- CHANGE descriptions state what they propose in domain terms, not by referencing plan-internal numbering or structure
- WHY descriptions explain the risk or rationale using information present in the advisory itself
- A user seeing only the advisory block can answer: "what part of the system does this affect, what is suggested, and why"
- The verdict format (ADVISE, and potentially APPROVE/BLOCK) is updated if needed to support this

**Scope**:
- In: Advisory format and instructions across all phases and agents that produce advisories; verdict format definition in nefario and reviewer agent prompts
- Out: Verdict routing mechanics, phase sequencing, report template layout

Additional context: use opus for all agents

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-software-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-margo.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-ai-modeling-minion.md

## Key consensus across specialists:

### ux-strategy-minion
Replace TASK with SCOPE field anchoring to concrete artifacts; keep CHANGE+WHY with domain-term-only content rules; three-question Krug test as self-containment boundary. Notes multiple tasks touch SKILL.md -- should be combined for file ownership.

### software-docs-minion
Canonical three-field format (SCOPE, CHANGE, WHY) across all surfaces; explicit prohibition against plan-internal references; Phase 5 code review stays as-is (already self-contained). Four tasks: define canonical format in AGENT.md, update SKILL.md surfaces, update report template, update reviewer AGENT.md files.

### lucy
Add SUBJECT field naming concrete artifact; reviewer prompts should include original user request reference; BLOCK verdict format also needs self-containment fix. Notes 3-line max may need adjusting to 4; TASK field has routing dependency that nefario parses for injection.

### margo
**KEY DISSENT**: Minimum change = better authoring instructions for existing fields, NOT new fields. Keep 3-line cap. Self-containment test as validation rule. Opposes SCOPE/SUBJECT/ARTIFACT field additions -- argues the problem is content quality, not format structure.

### ai-modeling-minion
Add SUBJECT field; place format spec in reviewer task prompt (not just AGENT.md) for higher model attention; include positive+negative examples; eliminate dual-definition between AGENT.md and SKILL.md. Notes format specs buried in long prompts lose to competing instructions.

## KEY CONFLICT TO RESOLVE

**margo vs. ux-strategy/software-docs/lucy/ai-modeling**: margo argues no new fields needed -- fix authoring instructions only. All others recommend adding a SCOPE/SUBJECT field. This is a genuine content-vs-structure disagreement. Your synthesis must resolve this with rationale.

## External Skills Context
No external skills detected.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. No external skills to incorporate
7. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase3-synthesis.md
