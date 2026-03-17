## Milestone 1: Adapter Foundation

**Goal**: Define the `DelegationRequest` and `DelegationResult` types that all adapters implement.

## Scope

- `DelegationRequest`: agent name, task prompt (already stripped of Claude Code-specific instructions), instruction file path, working directory, model tier (`opus` | `sonnet`), required tools list
- `DelegationResult`: exit code, changed files (from git diff), stdout summary, stderr, raw diff reference
- No implementation — types and contracts only
- Language/format matches the surrounding codebase (document the decision; do not assume)

## Dependencies

None — this is the foundation issue.

## Acceptance Criteria

- [ ] Types are defined and documented
- [ ] Interface is minimal — covers Codex and Aider use cases, nothing more
- [ ] No harness-specific fields in the shared types

---
*From [External Harness Roadmap](docs/external-harness-roadmap.md) §1.1*
