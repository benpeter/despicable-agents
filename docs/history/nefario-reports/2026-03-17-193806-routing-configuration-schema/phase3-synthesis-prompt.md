MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task
Define the YAML schema for `.nefario/routing.yml` and implement config loading with validation.

Source issue: #139 (Routing Configuration Schema)

Scope:
- Schema: `default` harness, optional `groups` (per-agent-group), optional `agents` (per-agent), optional `model-mapping` (tier → provider ID per harness)
- Resolution order: agent > group > default > implicit `claude-code`
- Capability gating: validate agent `tools:` requirements against harness capability list at load time
- Zero-config path: no file present means everything routes to `claude-code`
- Config loading reads from project-level `.nefario/routing.yml` and optional user-level override

Acceptance Criteria:
- Config loads and validates without error for minimal and power-user examples
- Capability gating rejects a config routing a web-research agent to Aider with clear error
- Zero-config path routes all tasks to `claude-code`

Notes: No "did you mean?" suggestions, no JSON Schema output, no CI/CD env var overrides.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase2-api-design-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase2-security-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase2-test-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase2-software-docs-minion.md

## Key consensus across specialists:
- devx-minion: Use yq for YAML parsing; single shell script emitting JSON; ordered validation; canonical group IDs; shallow merge for user overrides; star-quality capability gating errors
- api-design-minion: Exact tool names (Read, Edit, Bash, etc.) matching AGENT.md vocabulary; hardcode capability registry in loader source; no abstraction categories
- ai-modeling-minion: Canonical group IDs only (no arbitrary groups); shallow merge per top-level section; model-mapping defaults in code not schema
- security-minion: User-level must override project-level (untrusted repos); mandate safe YAML parser; 64KB limit; validate string values; warn when project-level loaded
- test-minion: Self-contained bash test script following test-hooks.sh pattern; 14 static YAML fixtures; black-box integration tests; needs config path override for testability
- ux-strategy-minion: Progressive disclosure correct; model-mapping as orthogonal axis; canonical group names; batch error reporting; confirmation signal at startup; user config at ~/.claude/nefario/routing.yml
- software-docs-minion: New standalone docs/routing-config.md; follow adapter-interface.md pattern; add to architecture hub; cross-links

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-frGPTh/routing-configuration-schema/phase3-synthesis.md

IMPORTANT constraints:
- All implementation is shell-based (bash). No TypeScript runtime.
- The project follows the Helix Manifesto: YAGNI, KISS, lean and mean.
- Working directory: /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness
- Use sonnet for execution tasks (devx-minion, test-minion, software-docs-minion).
- Budget 1-2 approval gates max for this relatively contained task.
