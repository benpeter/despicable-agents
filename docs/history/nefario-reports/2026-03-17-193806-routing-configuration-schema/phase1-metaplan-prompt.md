MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
<github-issue>
## Milestone 1: Adapter Foundation

**Goal**: Define the YAML schema for `.nefario/routing.yml` and implement config loading with validation.

## Scope

- Schema: `default` harness, optional `groups` (per-agent-group), optional `agents` (per-agent), optional `model-mapping` (tier → provider ID per harness)
- Resolution order: agent > group > default > implicit `claude-code`
- Capability gating: validate agent `tools:` requirements against harness capability list at load time; hard error with actionable message on mismatch
- Zero-config path: no file present means everything routes to `claude-code`
- Config loading reads from project-level `.nefario/routing.yml` and optional user-level override

## Dependencies

- Depends on #138 (Adapter Interface Definition) — config references types from interface definition

## Acceptance Criteria

- Config loads and validates without error for the minimal (`default: claude-code`) and power-user examples from the feasibility study
- Capability gating rejects a config that routes a web-research agent to Aider with a clear error message
- Zero-config path routes all tasks to `claude-code`

**Notes**: No "did you mean?" suggestions, no JSON Schema output, no CI/CD env var overrides — these are premature for a first implementation.

---
*From External Harness Roadmap §1.2*
</github-issue>

## Working Directory
/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan.

Project-local skills found:
- despicable-lab: project-local skill to check and rebuild agents
- despicable-statusline: project-local skill to configure nefario status

Neither is relevant to this task (configuration schema and loader implementation).

## Key Context Files
- Adapter interface spec: docs/adapter-interface.md (deliverable of #138, defines DelegationRequest/DelegationResult types)
- Feasibility study: docs/external-harness-integration.md (contains routing config examples and capability gating design)
- Roadmap: docs/external-harness-roadmap.md (defines scope, acceptance criteria, YAGNI constraints)
- Project structure: this is a shell/Markdown-based project with no TypeScript runtime. Configuration should use shell-friendly YAML parsing.

## Instructions
1. Read relevant files to understand the codebase context
2. Analyze the task against your delegation table
3. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning). These are agents whose domain expertise is needed to create a good plan.
4. For each specialist, write a specific planning question that draws on their unique expertise.
5. Return the meta-plan in the structured format.
6. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase1-metaplan.md
