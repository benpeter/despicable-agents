[< Back to Architecture Overview](architecture.md)

# Domain Adaptation Guide

## Overview

despicable-agents is a specialist agent team for Claude Code that uses structured orchestration (nefario) to decompose complex tasks, route them to domain experts, and verify the results through governance gates. Out of the box, the team is configured for software development -- but the orchestration engine is domain-agnostic. The domain-specific parts (which agents exist, what phases run after execution, how tasks are classified) live in a single file called a **domain adapter**.

Domain adaptation means replacing that file to retarget the entire team for a different professional domain -- regulatory compliance validation, corpus linguistics, financial auditing, or anything else where structured multi-expert orchestration adds value. You keep the orchestration engine, governance framework, communication protocol, and all infrastructure tooling. You replace the agent roster, delegation rules, review phases, and domain-specific heuristics.

The adapter controls **what** the team knows and **who** does the work. The framework handles **how** work is coordinated, approved, and delivered. This separation means you can create a new domain adapter without understanding nefario's phase machinery, scratch file management, or communication protocol.

## What the Framework Provides

These capabilities are infrastructure. You get them for free with any adapter -- do not rebuild or duplicate them.

- **Nine-phase orchestration** -- meta-plan, specialist consultation, synthesis, architecture review, execution, and post-execution phases. Phase sequencing, transitions, and approval gates are framework-level.
- **Subagent spawning** -- nefario spawns specialist agents as subagents via Claude Code's Task tool. Parallelism, monitoring, and result collection are handled automatically.
- **Scratch directory management** -- per-session scratch directories for phase outputs (`phase1-metaplan.md`, `phase3-synthesis.md`, etc.). Created, named, and cleaned up by the framework.
- **Status line** -- real-time status updates during orchestration via Claude Code's status line mechanism.
- **Context management** -- compaction checkpoints at phase boundaries, scratch file patterns that preserve critical context across compaction events.
- **Approval gates** -- user approval prompts at phase transitions with accept/modify/reject options. Gate mechanics, presentation format, and re-run flow are framework-level.
- **Communication protocol** -- three-tier output taxonomy (SHOW, NEVER SHOW, CONDENSE) controlling what the user sees during orchestration.
- **Skill discovery** -- automatic discovery and delegation to project-local skills (`.skills/`, `.claude/skills/`). See [External Skill Integration](external-skills.md).
- **Report generation** -- execution reports and advisory reports committed to repo history. Template structure and commit conventions are framework-level.
- **Branch and PR mechanics** -- branch creation (`nefario/<slug>`), conventional commits, PR creation with `gh`, secret scanning on PR bodies.
- **Content boundaries** -- untrusted content (issue bodies, external input) is never treated as instructions.
- **Governance framework** -- lucy (intent alignment) and margo (simplicity enforcement) review every plan. This is non-negotiable and cannot be removed by an adapter.
- **Advisory mode** -- `--advisory` flag for recommendation-only sessions (phases 1-3, no code changes).
- **Flag and argument parsing** -- `--advisory`, `--skip-*` flags, and `#<issue>` references are parsed by the framework.

## What the Adapter Must Provide

A domain adapter is a single file at `domains/<domain-name>/DOMAIN.md`. It uses YAML frontmatter for structured data and markdown body sections for prose content. The reference adapter at `domains/software-dev/DOMAIN.md` serves as the canonical format example; this section covers what each piece does and how it varies across domains.

### 1. Agent Roster (section: `## Agent Roster`)

**What it is**: The complete list of specialist agents available for this domain, organized into groups with one-line capability descriptions.

**Format**: Markdown with bold group headers and bulleted agent entries.

| Software Development | Regulatory Compliance (hypothetical) |
|---|---|
| **Protocol & Integration**: mcp-minion, oauth-minion, api-design-minion, api-spec-minion | **Regulatory Frameworks**: gdpr-minion, sox-minion, hipaa-minion |
| **Development & Quality**: frontend-minion, test-minion, debugger-minion, devx-minion, code-review-minion | **Evidence & Audit**: evidence-collector-minion, audit-trail-minion, gap-analysis-minion |
| **Security & Observability**: security-minion, observability-minion | **Risk Assessment**: risk-scoring-minion, control-testing-minion |
| 23 minions across 7 groups | Different count, different groups |

### 2. Phase Sequence (frontmatter: `phases`)

**What it is**: The post-execution phases (5+) that run after the main execution phase. Infrastructure phases (1-4) are fixed and not adapter-customizable.

**Format**: YAML array in frontmatter. Each phase has `id`, `name`, `type`, `condition`, and optionally `agents` and `block-escalation`.

| Software Development | Regulatory Compliance (hypothetical) |
|---|---|
| Phase 5: Code Review (type: review, condition: code-produced) | Phase 5: Compliance Review (type: review, condition: findings-produced) |
| Phase 6: Test Execution (type: verification, condition: tests-exist) | Phase 6: Evidence Validation (type: verification, condition: evidence-collected) |
| Phase 7: Deployment (type: execution, condition: user-requested) | Phase 7: Report Generation (type: documentation, condition: review-complete) |
| Phase 8: Documentation (type: documentation, condition: checklist-has-items) | -- |

**Named conditions** are evaluated by the orchestration engine at runtime. The vocabulary of conditions is defined in the adapter format spec. Adapters declare which condition each phase requires; the engine handles evaluation.

### 3. Cross-Cutting Checklist (section: `## Cross-Cutting Concerns`)

**What it is**: Mandatory dimensions that every plan must evaluate. For each dimension, the planner either includes the relevant agent or explicitly justifies exclusion.

**Format**: Markdown list with bold dimension names, agent references, and inclusion rules.

| Software Development | Regulatory Compliance (hypothetical) |
|---|---|
| Testing (test-minion) | Evidence Completeness (evidence-collector-minion) |
| Security (security-minion) | Data Privacy (gdpr-minion) |
| Usability -- Strategy (ux-strategy-minion) | Stakeholder Impact (stakeholder-minion) |
| Usability -- Design (ux-design-minion, accessibility-minion) | Audit Trail (audit-trail-minion) |
| Documentation (software-docs-minion, user-docs-minion) | Documentation (compliance-docs-minion) |
| Observability (observability-minion, sitespeed-minion) | Reporting (report-minion) |

### 4. Gate Heuristics (section: `## Gate Classification Examples`)

**What it is**: Domain-specific examples that teach nefario which tasks require user approval gates (MUST-gate) and which can proceed without them (no-gate).

**Format**: Prose with example lists.

| Software Development | Regulatory Compliance (hypothetical) |
|---|---|
| MUST-gate: database schema design, API contract definition, security threat model | MUST-gate: regulatory interpretation, risk classification, remediation priority |
| no-gate: CSS styling, test file organization, documentation formatting | no-gate: evidence formatting, report template selection, citation formatting |

### 5. Reviewer Configuration (sections: `## Architecture Review`, `## Model Selection`)

**What it is**: Which agents review plans before execution (mandatory vs. discretionary), what they focus on, and which model tier each agent uses.

**Format**: Markdown tables for mandatory/discretionary reviewers, prose for review focus descriptions, YAML-like model mapping.

| Software Development | Regulatory Compliance (hypothetical) |
|---|---|
| Mandatory: security-minion, test-minion, ux-strategy-minion, lucy, margo | Mandatory: gdpr-minion, evidence-collector-minion, lucy, margo |
| Discretionary: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion | Discretionary: sox-minion, hipaa-minion, stakeholder-minion |

**Note**: lucy and margo are always mandatory reviewers regardless of domain. They are framework-level governance. The adapter adds domain-specific mandatory reviewers alongside them.

### Additional Required Sections

The adapter also provides: Delegation Table, Post-Execution Pipeline details, Sanitization Patterns, Task Source Integration, Verification Summary Templates, Boundaries, and File-Domain Routing. See the adapter format spec for the complete list of required and optional sections.

## How to Create a New Adapter

### Step 1: Fork the repository

```bash
git clone https://github.com/benpeter/despicable-agents.git
cd despicable-agents
```

### Step 2: Copy the reference adapter

```bash
cp domains/software-dev/DOMAIN.md domains/<your-domain>/DOMAIN.md
```

The software-dev adapter is the reference implementation. Start from it and replace domain-specific content.

### Step 3: Edit DOMAIN.md

Update the YAML frontmatter:
- `domain`: kebab-case identifier (e.g., `regulatory-compliance`)
- `name`: human-readable name (e.g., `Regulatory Compliance`)
- `description`: one-paragraph summary of the domain
- `phases`: your post-execution phase sequence
- `governance`: keep lucy and margo; add domain-specific mandatory reviewers
- `skip-options`: user-selectable phase skips matching your phases
- `skill-description`: one-paragraph description for the SKILL.md frontmatter

Replace all markdown body sections with your domain content. Every required section (listed in the adapter format spec) must be present.

### Step 4: Build the agent AGENT.md files

Create agent directories and AGENT.md files for each specialist in your roster. Each agent needs:
- YAML frontmatter (name, model, description, etc.)
- System prompt with domain expertise
- Boundaries ("Does NOT do" section)

Optionally create RESEARCH.md files with domain research backing each agent's system prompt.

### Step 5: Assemble nefario's AGENT.md

The nefario AGENT.md contains `<!-- @domain:section-name BEGIN -->` / `<!-- @domain:section-name END -->` assembly markers. The assembly process reads your DOMAIN.md and replaces marker content with the corresponding adapter sections.

Run the assembly script:
```bash
./assemble.sh <your-domain>
```

This produces a materialized `nefario/AGENT.md` where all markers contain your domain's content.

### Step 6: Install

```bash
./install.sh
```

This symlinks all agents and skills to `~/.claude/`. Available in every Claude Code session.

### Step 7: Test

Run a simple orchestration to verify the adapter works end-to-end:
```
/nefario <a representative task for your domain>
```

Verify that:
- Phase 1 (meta-plan) references your agents by name
- Phase 3 (synthesis) uses your delegation table
- Phase 3.5 (architecture review) invokes your mandatory reviewers
- Post-execution phases match your phase sequence
- Governance (lucy, margo) still participates

## SKILL.md vs. AGENT.md: What to Edit

The nefario orchestrator has two files: `nefario/AGENT.md` (the agent definition) and `skills/nefario/SKILL.md` (the orchestration skill). They handle domain content differently.

| Question | Edit this file | Mechanism |
|---|---|---|
| Change the agent roster or delegation table? | `DOMAIN.md` (assembled into `nefario/AGENT.md`) | `<!-- @domain:* -->` markers in AGENT.md are fully replaced with adapter content |
| Change post-execution phases or review config? | `DOMAIN.md` (assembled into `nefario/AGENT.md`) | Same marker replacement |
| Change cross-cutting checklist or gate examples? | `DOMAIN.md` (assembled into `nefario/AGENT.md`) | Same marker replacement |
| Change orchestration infrastructure (phase sequencing, gate mechanics, communication protocol)? | Do NOT edit. This is framework-level. | Fixed in SKILL.md |
| Change scratch file naming or compaction? | Do NOT edit. This is framework-level. | Fixed in SKILL.md |

**Key asymmetry**: `nefario/AGENT.md` uses `<!-- @domain:section-name BEGIN -->` / `<!-- @domain:section-name END -->` markers. The assembly script replaces everything between matching markers with adapter content. `SKILL.md` uses `<!-- DOMAIN-SPECIFIC: ... -->` and `<!-- INFRASTRUCTURE -->` comment annotations to document which sections are domain-specific vs. framework-level, but **SKILL.md is not assembled** -- it contains inline domain-specific content that the assembly script annotates or replaces in-place.

In practice: if you need to change domain content, edit `DOMAIN.md` and re-run assembly. If the content you want to change is in SKILL.md (identified by `<!-- DOMAIN-SPECIFIC -->` comments), that section needs in-place editing in SKILL.md and is not yet covered by automated assembly. The AGENT.md marker system is the primary adapter mechanism.

## What You Do NOT Need to Change

These are framework-level and should not be modified when creating a new domain adapter:

- **`skills/nefario/SKILL.md` infrastructure sections** -- phase sequencing, gate mechanics, communication protocol, scratch directory management, compaction strategy, status line, report generation, advisory mode. Marked with `<!-- INFRASTRUCTURE -->` comments.
- **`lucy/AGENT.md` and `margo/AGENT.md`** -- governance agents are domain-agnostic. Lucy checks intent alignment and convention adherence. Margo checks simplicity and YAGNI. Both work with any domain.
- **`install.sh`** -- the install script symlinks agents and skills. It works with any set of agents in the expected directory structure.
- **`.claude/hooks/`** -- commit workflow hooks are framework-level tooling.
- **`the-plan.md`** -- this is the canonical spec for the software-dev domain. Your domain will have its own equivalent planning document.
- **`docs/` architecture documentation** -- describes the framework. Your domain may add its own docs but should not modify framework docs.

**Why**: The framework is designed so that domain changes are isolated to the adapter file and agent definitions. Modifying infrastructure creates a maintenance fork that diverges from upstream improvements.

## Governance Constraints

### lucy and margo Are Always Present

lucy (intent alignment, convention enforcement) and margo (simplicity enforcement, YAGNI/KISS) are framework-level governance reviewers. They participate in every Phase 3.5 Architecture Review regardless of domain. The adapter's `governance.mandatory-reviewers` field must include both.

This is enforced by design: adapters **can add** governance reviewers but **cannot remove** lucy and margo.

### Review Focus Hints

lucy and margo's review focus adapts naturally to the domain because they review the plan content, not domain-specific artifacts. lucy checks whether the plan aligns with the user's stated intent. margo checks whether the plan is unnecessarily complex. Both work with any domain.

For domain-specific review concerns, add domain experts as mandatory reviewers in your adapter. For example, a regulatory compliance adapter might add `gdpr-minion` as a mandatory reviewer to ensure every plan considers data privacy implications.

### Extending Governance

To add a domain-specific governance reviewer:

1. Add the agent to `governance.mandatory-reviewers` in DOMAIN.md frontmatter
2. Add the agent to the `## Architecture Review > ### Mandatory Reviewers` table with trigger `ALWAYS` and a rationale
3. Add a review focus description in `### Review Focus Descriptions`
4. Ensure the agent's AGENT.md exists in the appropriate directory

The new reviewer will be spawned alongside lucy and margo during Phase 3.5 for every plan.

## Troubleshooting

### Assembly failures

**Symptom**: Assembly script errors or produces empty sections in AGENT.md.

**Cause**: Missing required section in DOMAIN.md. The assembly script expects specific H2 section names (e.g., `## Agent Roster`, `## Delegation Table`).

**Solution**: Compare your DOMAIN.md section headers against the reference adapter (`domains/software-dev/DOMAIN.md`). Section names must match exactly. Check for typos or extra whitespace in headers.

### YAML frontmatter errors

**Symptom**: Install or assembly fails with YAML parse errors.

**Cause**: Malformed YAML in DOMAIN.md frontmatter. Common issues: missing quotes around version strings, incorrect indentation in `phases` array, unescaped special characters in descriptions.

**Solution**: Validate your frontmatter with a YAML linter. The `version` field must be quoted (`"1.0"` not `1.0`). Phase `id` values must be integers. Condition values must be from the named condition vocabulary.

### Phase condition not triggering

**Symptom**: A post-execution phase is skipped when it should run (or runs when it should be skipped).

**Cause**: The `condition` field references a named condition that does not match the runtime state. For example, `code-produced` evaluates to false if Phase 4 only produced documentation-only markdown.

**Solution**: Review the named condition vocabulary in the adapter format spec. Ensure your condition matches what actually happens during execution. If you need a new condition, it must be added to the framework's condition evaluation engine.

### Agent name mismatches

**Symptom**: Nefario references an agent that does not exist, or spawns the wrong agent.

**Cause**: Agent name in DOMAIN.md (roster, delegation table, reviewer config) does not match the directory name or AGENT.md frontmatter `name` field.

**Solution**: Agent names must be consistent across all three locations: DOMAIN.md references, directory name (`minions/<name>/`), and AGENT.md frontmatter. Use kebab-case consistently. Run `ls minions/` to verify directory names.

### Gate heuristic problems

**Symptom**: Too many or too few approval gates during execution. Users are asked to approve trivial tasks, or high-impact tasks execute without approval.

**Cause**: Gate classification examples in `## Gate Classification Examples` do not match the domain's risk profile. Nefario uses these examples to calibrate gate placement.

**Solution**: Review your MUST-gate and no-gate examples. MUST-gate should list tasks where an incorrect decision has high reversal cost. No-gate should list tasks that are low-risk and easily reversible. Add more examples if nefario's calibration is off.
