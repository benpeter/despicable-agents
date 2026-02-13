# Domain Adapter Format Specification

Version: 1.0

## Overview

A domain adapter is a single markdown file (`domains/<domain-name>/DOMAIN.md`)
that captures all domain-specific content needed to materialize nefario's
orchestration for a particular professional domain. The adapter is consumed
at build/install time by an assembly script that produces the final AGENT.md
and annotates SKILL.md. The model never sees the adapter file directly -- it
sees one coherent, assembled document.

## File Format

Markdown with YAML frontmatter. This matches the project convention used by
AGENT.md, SKILL.md, and RESEARCH.md.

### YAML Frontmatter (structured data)

```yaml
---
domain: software-dev           # kebab-case identifier, unique across adapters
name: Software Development     # human-readable display name
description: >
  Full-stack software development including frontend, backend, infrastructure,
  security, testing, documentation, and deployment.
version: "1.0"                 # semver, adapter content version

# Phase sequence -- ordered list of post-execution phases
# Infrastructure phases (1-4) are not listed here; they are fixed.
# Only post-execution phases (5+) are adapter-supplied.
phases:
  - id: 5
    name: Code Review
    type: review
    condition: code-produced        # named condition from vocabulary
    agents:
      - name: code-review-minion
        model: sonnet
        focus: "code quality, correctness, bug patterns, cross-agent integration"
      - name: lucy
        model: opus
        focus: "convention adherence, CLAUDE.md compliance, intent drift"
      - name: margo
        model: opus
        focus: "over-engineering, YAGNI, dependency bloat"
    block-escalation:
      - pattern: "injection|auth bypass|secret exposure|crypto"
        severity: security
        surface-to-user: true

  - id: 6
    name: Test Execution
    type: verification
    condition: tests-exist
    agents:
      - name: test-minion
        model: sonnet

  - id: 7
    name: Deployment
    type: execution
    condition: user-requested

  - id: 8
    name: Documentation
    type: documentation
    condition: checklist-has-items
    agents:
      - name: software-docs-minion
        model: sonnet
        sub-step: 8a
      - name: user-docs-minion
        model: sonnet
        sub-step: 8a
      - name: product-marketing-minion
        model: sonnet
        sub-step: 8b
        condition: readme-or-user-docs

# Governance constraints -- framework-level, not removable by adapter
governance:
  mandatory-reviewers:
    - lucy
    - margo
  note: >
    lucy and margo are framework-level governance. Adapters can ADD
    governance reviewers but cannot remove these two.

# Skip options -- user-selectable phase skips at approval gates
skip-options:
  - label: "Skip docs"
    flag: "--skip-docs"
    phases: [8]
    risk-order: 1           # ascending risk (lowest first)
  - label: "Skip tests"
    flag: "--skip-tests"
    phases: [6]
    risk-order: 2
  - label: "Skip review"
    flag: "--skip-review"
    phases: [5]
    risk-order: 3
  - label: "Skip all"
    flag: "--skip-post"
    phases: [5, 6, 8]

# SKILL.md description template (populates the frontmatter description)
skill-description: >
  Uses a nine-phase process: nefario creates a meta-plan, specialists
  contribute domain expertise, nefario synthesizes, cross-cutting agents
  review the plan, you execute, then post-execution phases verify code
  quality, run tests, optionally deploy, and update documentation.
  Use --advisory for recommendation-only mode (phases 1-3, no code changes).
---
```

### Markdown Body (prose sections)

The body uses H2 sections with specific names that the assembly script
recognizes. Section order does not matter; the assembly script places
content according to the target template's assembly markers.

#### Required Sections

##### `## Agent Roster`

The complete agent team available for this domain. Format matches AGENT.md
roster structure: groups with agent names and one-line descriptions.

```markdown
## Agent Roster

You coordinate N specialist agents organized into hierarchical groups:

**Group Name**
- **agent-name**: One-line description of capabilities

...
```

##### `## Delegation Table`

Maps task types to primary and supporting agents. Markdown table format.

```markdown
## Delegation Table

Use this table to route tasks to the right specialist.

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| ... | ... | ... |
```

##### `## Cross-Cutting Concerns`

Mandatory checklist dimensions. Each dimension names an agent, trigger
condition, and inclusion rule.

```markdown
## Cross-Cutting Concerns

Every plan MUST evaluate these N dimensions. For each one, either include
the relevant agent or explicitly state why it's not needed.

- **Dimension Name** (agent-name): Trigger condition and inclusion rule.
...
```

##### `## Gate Classification Examples`

Domain-specific examples of MUST-gate and no-gate tasks for the
classification matrix.

```markdown
## Gate Classification Examples

Examples of MUST-gate tasks: ...
Examples of no-gate tasks: ...
```

##### `## Model Selection`

Agent-to-model mapping by phase.

```markdown
## Model Selection

- **Planning and analysis tasks**: Use `opus`
- **Execution tasks**: Use the minion's default model (usually `sonnet`)
- **Architecture review**: Use `opus`
- **Post-execution (Phase 5)**: agent on model, ...
- **Post-execution (Phase 6-8)**: agent on model, ...
```

##### `## Architecture Review`

Mandatory and discretionary reviewer tables with domain signals.

```markdown
## Architecture Review

### Mandatory Reviewers

| Reviewer | Trigger | Rationale |
|----------|---------|-----------|
| ... | ALWAYS | ... |

### Discretionary Reviewers

| Reviewer | Domain Signal | Rationale |
|----------|--------------|-----------|
| ... | ... | ... |

### Review Focus Descriptions

- **agent-name**: review focus description
...

### Review Examples

ADVISE and BLOCK examples using domain-specific concepts.
```

##### `## Post-Execution Pipeline`

Complete definition of what each post-execution phase does, including
file classification tables, test discovery patterns, documentation
checklists, and marketing tier definitions.

```markdown
## Post-Execution Pipeline

### Phase 5: Code Review
(file classification table, reviewer prompts, security escalation patterns)

### Phase 6: Test Execution
(test discovery patterns, framework configs, layered execution order)

### Phase 7: Deployment
(deployment command patterns)

### Phase 8: Documentation
(outcome-action table, priority assignment, marketing tiers)
```

##### `## Sanitization Patterns`

Secret/credential patterns for sanitization before writing to scratch
files, PR bodies, and reports.

```markdown
## Sanitization Patterns

Regex patterns for credential detection:
- `sk-`, `key-`, `AKIA`, `ghp_`, `github_pat_`
- `token:`, `bearer`, `password:`, `passwd:`
- `BEGIN.*PRIVATE KEY`
```

##### `## Task Source Integration`

How the domain fetches and references external task sources (e.g., GitHub
issues, Jira tickets, document management systems).

```markdown
## Task Source Integration

### Fetch Command
`gh issue view <number> --json number,title,body`

### Context Fields
- source-issue, source-issue-title
- PR body includes: `Resolves #<number>`
- Branch naming: `nefario/<slug>`

### Commit Conventions
- Format: `<type>(<scope>): <summary>`
- Trailer: `Co-Authored-By: Claude <noreply@anthropic.com>`
- Advisory report: `docs: add nefario advisory report for <slug>`
- Execution report: `docs: add nefario execution report for <slug>`
```

##### `## Verification Summary Templates`

Templates for the verification summary line in wrap-up.

```markdown
## Verification Summary Templates

- All ran, all passed: "Verification: all checks passed."
- All ran, with fixes: "Verification: N code review findings auto-fixed, ..."
...
```

##### `## Boundaries`

Domain-specific "What You Do NOT Do" list derived from the agent roster.

```markdown
## Boundaries

- **Write code**: Delegate to appropriate development minion
- **Design systems**: Delegate to appropriate design minion
...
```

##### `## File-Domain Routing`

Rules for routing files to agents based on their semantic nature.

```markdown
## File-Domain Routing

Agent definition files (AGENT.md), orchestration rules (SKILL.md), ...
route through ai-modeling-minion. Documentation files route through
software-docs-minion or user-docs-minion.
```

#### Optional Sections

##### `## Custom Reviewer Prompts`

Override the generic reviewer prompt template for specific agents.

```markdown
## Custom Reviewer Prompts

### ux-strategy-minion

(complete prompt override for this reviewer)
```

##### `## Phase Announcement Names`

Override phase names for the announcement markers.

```markdown
## Phase Announcement Names

| Phase | Name |
|-------|------|
| 5 | Code Review |
| 6 | Test Execution |
| 7 | Deployment |
| 8 | Documentation |
```

##### `## Domain Conventions`

Any additional domain-specific conventions not covered above.

## Assembly Model

At install time (`./install.sh` or a dedicated assembly script):

1. Read the AGENT.md template (containing `<!-- @domain:section-name -->` markers)
2. Read the active DOMAIN.md adapter
3. For each assembly marker in AGENT.md, replace with the corresponding
   adapter content (YAML frontmatter fields or markdown body sections)
4. Write the materialized AGENT.md
5. The SKILL.md assembly markers are replaced similarly

The assembly is a simple text substitution. No runtime indirection, no
config loader, no plugin lifecycle. The model sees one coherent document.

## Named Condition Vocabulary

Post-execution phase conditions use these observable facts:

| Condition | Meaning |
|-----------|---------|
| `code-produced` | Phase 4 produced code or logic-bearing markdown |
| `tests-exist` | Test infrastructure or test files detected |
| `user-requested` | User explicitly opted in at plan approval |
| `checklist-has-items` | Documentation checklist has actionable items |
| `readme-or-user-docs` | Checklist includes README or user-facing docs |

Conditions are evaluated by the orchestration engine at runtime based on
observable state. Adapters declare which condition each phase requires;
the engine handles evaluation.

## Constraints

- One file per domain. No directory of multiple files.
- No runtime config loading. Assembly happens at install time.
- Governance reviewers (lucy, margo) are framework-level and cannot be
  removed by an adapter. Adapters can add governance reviewers.
- Phase types are fixed: `planning`, `consultation`, `review`, `execution`,
  `verification`, `documentation`. Adapters compose phases from these types.
- Infrastructure phases (1-4) are not adapter-customizable. Only post-execution
  phases and domain-specific content within infrastructure phases are adapter-supplied.
