MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

Outcome: A user forking despicable-agents for a non-software domain (e.g., regulatory compliance validation, corpus linguistics) can identify and replace only the domain-specific parts -- agent roster, phase definitions, gate/approval semantics, coordination patterns -- without needing to understand or modify the domain-independent infrastructure (skill discovery, tool plumbing, team mechanics, report generation). This makes the system a reusable orchestration framework rather than a software-development-specific tool.

Success criteria:
- Clear boundary exists between domain-specific configuration (agents, phases, gates, coordination semantics) and domain-independent infrastructure (skill mechanics, subagent spawning, message delivery, report format)
- A hypothetical domain adapter can define its own phase sequence, gate criteria, and agent roster without editing infrastructure files
- Documentation explains what a domain adapter must provide vs. what the framework handles
- Existing software-development behavior is preserved -- current agents and orchestration work identically after the separation

Scope:
- In: nefario SKILL.md orchestration logic, phase/gate definitions, agent roster selection, approval semantics, documentation of the separation boundary
- Out: Actually building non-software-domain agent sets, changing AGENT.md file format, modifying Claude Code platform integration

Constraints:
- Do not narrow or dismiss this work as YAGNI. The separation is a deliberate architectural investment in reusability.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/phase2-margo.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/phase2-devx-minion.md

## Key consensus across specialists:

### ai-modeling-minion
Recommendation: Use typed phase system (planning/consultation/review/execution/verification) with 8 configurable surfaces; keep spawning/scratch/status/compaction/report in engine.
Tasks: 6 -- audit; schema design; extraction; assembly tooling; documentation; behavioral validation
Risks: prompt coherence fragmentation (HIGH); condition predicate explosion (MEDIUM)

### lucy
Recommendation: Lucy/margo remain universal framework-level governance. Cross-cutting dimensions are ALL domain-specific; the pattern of mandatory review is universal but specific dimensions are adapter-supplied.
Tasks: 3 -- split lucy software-specific checks; define adapter governance contract; verify CLAUDE.md compliance stays domain-agnostic
Risks: losing governance universality; adapter authors removing mandatory governance

### margo
Recommendation: Section comment markers in existing SKILL.md, NOT separate files. Five data structures = minimum adapter contract. Do NOT build config loader/registry/validation.
Tasks: 5 -- audit SKILL.md; audit AGENT.md; write docs/domain-adaptation.md; add section markers; verify behavior
Risks: over-engineering (plugin infrastructure for zero users)

### devx-minion
Recommendation: Markdown+YAML frontmatter in directory structure (domains/<name>/). Extend /despicable-lab for validation. Three-tier documentation.
Tasks: 6 -- create domain directory; extract default adapter; tutorial; extend validation; update install.sh; reference spec
Risks: adapter format complexity; validation scope creep

### KEY CONFLICT TO RESOLVE
margo advocates minimal intervention (section markers in existing monolithic file, documentation only) while ai-modeling-minion and devx-minion advocate more structured extraction (schema, directory structure, validation tooling). The issue explicitly says "do not dismiss as YAGNI" but the Helix Manifesto says "lean and mean." Lucy is neutral on format but clear that governance stays universal.

## External Skills Context
No external skills detected relevant to this task. Two discovered (despicable-lab, despicable-statusline) -- neither applies.

## Instructions
1. Review all specialist contributions
2. Resolve the key conflict between margo's minimalism and ai-modeling/devx's richer approach
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Use opus model for ALL tasks (user directive)
7. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/phase3-synthesis.md
