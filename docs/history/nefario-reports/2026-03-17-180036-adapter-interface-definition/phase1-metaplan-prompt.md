MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

Milestone 1: Adapter Foundation

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

## Working Directory
/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness

## External Skill Discovery
Skills found:
- .claude/skills/despicable-lab/SKILL.md — project-local lab skill for checking/rebuilding agents
- .claude/skills/despicable-statusline/SKILL.md — project-local skill for configuring nefario status

Neither skill is relevant to adapter interface definition. No external skill integration needed.

## Codebase Context
The codebase contains NO programming language code (no JS/TS/Python). It is entirely:
- Shell scripts (install.sh, assemble.sh)
- Markdown files (AGENT.md, RESEARCH.md, SKILL.md, docs/)
- The roadmap explicitly says "Language/format matches the surrounding codebase (document the decision; do not assume)"

Key reference docs:
- docs/external-harness-roadmap.md — full roadmap with all milestones and issue definitions
- docs/external-harness-integration.md — feasibility study with tool inventory and delegation model analysis

## Instructions
1. Read relevant files to understand the codebase context
2. Analyze the task against your delegation table
3. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning)
4. For each specialist, write a specific planning question
5. Return the meta-plan in the structured format
6. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase1-metaplan.md
