# Meta-Plan: Leverage agent_id/agent_type in hook events for commit attribution

## Planning Consultations

### Consultation 1: Hook script enhancement for agent metadata capture

- **Agent**: devx-minion
- **Planning question**: The PostToolUse hook (`track-file-changes.sh`) currently records only file paths in a plain-text ledger (one path per line). The hook receives JSON input via stdin that now includes `agent_id` (for subagents) and `agent_type` (for subagents and `--agent` mode). What is the best ledger format to capture per-file agent attribution without breaking existing consumers? The current ledger is read by: (1) the auto-commit flow in SKILL.md which stages files and generates conventional commit messages with `<type>(<scope>): <summary>`, and (2) the Stop hook `commit-point-check.sh` which reads and deduplicates paths. Consider: plain text with a delimiter (e.g., TSV), JSON lines, or a companion metadata file. The format must remain simple to parse in bash without external dependencies beyond jq.
- **Context to provide**: `track-file-changes.sh`, `commit-point-check.sh`, the ledger format spec in `docs/commit-workflow.md` Section 6, and the auto-commit instructions in `skills/nefario/SKILL.md` Phase 4.
- **Why this agent**: devx-minion owns CLI/tool design, configuration file formats, and developer-facing conventions. The ledger format is a tool interface consumed by multiple components -- this is a DX problem.

### Consultation 2: Commit message format with agent attribution

- **Agent**: ai-modeling-minion
- **Planning question**: The commit message convention is `<type>(<scope>): <summary>` for orchestrated sessions, where "scope is derived from the agent or domain that produced the work." Currently this derivation is heuristic (the main session infers scope from the task it assigned). With `agent_type` now available in hook events, we can capture the agent name at file-write time. Should the scope field use the raw `agent_type` value (e.g., `frontend-minion`), a shortened form (e.g., `frontend`), or the existing domain mapping? How should this interact with the `Co-Authored-By` trailer -- should it change to `Co-Authored-By: frontend-minion <noreply@anthropic.com>`? Consider impact on git log readability, `git shortlog` grouping, and compatibility with conventional commit tooling.
- **Context to provide**: `docs/commit-workflow.md` Section 5, the SKILL.md auto-commit instructions, the `subagent_type` field usage in SKILL.md task spawning.
- **Why this agent**: ai-modeling-minion owns prompt engineering, multi-agent architecture, and agent system prompt changes. The commit attribution format is a multi-agent identity question -- how agents present themselves in artifacts.

### Consultation 3: Security implications of agent metadata in hooks

- **Agent**: security-minion
- **Planning question**: The hook script will now extract `agent_id` and `agent_type` from JSON input and write them to a temp file (the ledger). What are the security considerations? Specifically: (1) Can `agent_type` contain attacker-controlled content that could cause injection when used in commit messages or shell commands? (2) Does storing agent metadata in `/tmp/` create any information leakage concerns beyond what `session_id` already exposes? (3) Should the hook validate that `agent_type` matches a known agent name from the roster, or is it safe to pass through as-is?
- **Context to provide**: `track-file-changes.sh`, `commit-point-check.sh`, `docs/commit-workflow-security.md` (the full security assessment).
- **Why this agent**: security-minion must review any change to hook scripts that process external input and write to shared temp files.

### Cross-Cutting Checklist

- **Testing**: Include test-minion for planning. The hook scripts have no automated tests currently. The planning question: what is the minimal test strategy for the modified hooks? Should we add shell script tests (e.g., bats-core), or is manual verification sufficient given the scripts are simple bash with jq? What test cases cover the new `agent_id`/`agent_type` extraction -- missing fields, empty values, unexpected formats?
- **Security**: Include -- see Consultation 3 above.
- **Usability -- Strategy**: ALWAYS include. Planning question for ux-strategy-minion: The commit log is a developer-facing artifact. How does per-agent attribution in commit messages affect the developer experience when reviewing git history? Does `feat(frontend-minion): add header component` help or hinder scanning? Is there a cognitive load concern with 23+ possible scope values vs. the current smaller set of domain scopes?
- **Usability -- Design**: Exclude. No user-facing UI is involved; this is CLI tooling and git metadata.
- **Documentation**: ALWAYS include. Planning question for software-docs-minion: Which documents need updating if the ledger format changes? At minimum: `docs/commit-workflow.md` Section 5 (commit message convention) and Section 6 (file change tracking / ledger interface). Are there other downstream references to the ledger format or commit message scope derivation?
- **Observability**: Exclude. No production runtime services are affected; this is a local development workflow tool.

### Notable Exclusions

- **iac-minion**: No infrastructure or CI/CD changes -- hooks are local shell scripts, not deployed services.
- **code-review-minion**: Will participate in Phase 5 post-execution review, not needed for planning. The changes are small shell script modifications with a clear security review from security-minion.
- **mcp-minion**: Despite hook events being a Claude Code platform feature, this task does not involve MCP protocol work -- it is consuming existing fields, not designing new tool interfaces.

### Anticipated Approval Gates

1. **Ledger format decision** (MUST gate): The ledger format change affects both hook scripts and the SKILL.md auto-commit consumer. It is hard to reverse (existing ledger files in active sessions would break) and has 2+ dependents (track-file-changes.sh writes it, commit-point-check.sh and SKILL.md auto-commit read it). This is the key architectural decision.

2. **Commit message format** (OPTIONAL gate, likely included): Whether to use `agent_type` as the commit scope, shorten it, or keep the existing approach. This is easy to change later but affects git history readability, so worth a brief confirmation.

### Rationale

This task spans three domains: **developer tooling** (ledger format, hook scripts), **multi-agent identity** (how agents attribute their work in git artifacts), and **security** (validating new external input in hooks). The devx-minion plans the format, ai-modeling-minion plans the attribution semantics, and security-minion reviews the threat surface. ux-strategy-minion ensures the developer-facing output (commit log) remains scannable. software-docs-minion identifies documentation impact.

test-minion is included for planning because the hook scripts currently have zero test coverage, and this change is a natural moment to establish a minimal test baseline -- or explicitly decide not to.

### Scope

**In scope:**
- Modify `track-file-changes.sh` to capture `agent_id` and `agent_type` from hook event JSON
- Modify the ledger format to include agent metadata alongside file paths
- Update `commit-point-check.sh` to handle the new ledger format
- Update SKILL.md auto-commit instructions to use agent metadata for commit message scope
- Update `docs/commit-workflow.md` to reflect new ledger format and commit attribution
- Update `docs/commit-workflow-security.md` if new security considerations arise

**Out of scope:**
- Changes to agent system prompts (AGENT.md files)
- Changes to the orchestration flow itself (phase structure, delegation)
- New hook types or hook event changes (we consume existing fields)
- Automated test infrastructure (may be recommended but not required for this PR)

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | ORCHESTRATION | Agent building/rebuilding | Not relevant -- no agents are being rebuilt |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Claude Code status line config | Not relevant -- no status line changes |

#### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain (hook scripts, commit workflow, ledger format).
