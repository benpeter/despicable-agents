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
