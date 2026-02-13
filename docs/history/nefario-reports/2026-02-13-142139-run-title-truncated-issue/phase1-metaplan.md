# Phase 1: Meta-Plan

## Task Summary

Create a GitHub issue documenting that the `$summary` variable used in
AskUserQuestion gate trailing lines (`\n\nRun: $summary`) is truncated to
40 characters -- a constraint inherited from the status line context where
space is limited. In gate contexts (AskUserQuestion prompts), more space is
available, so a full-length summary would be more useful. The issue should
propose maintaining two values: a truncated version for the status line and
a full-length version for gates. Additionally, create a "nice-to-have" label
if priority labels are not available.

## Scope

**In scope**: Create one GitHub issue with clear problem statement, current
behavior, and proposed solution. Create a "nice-to-have" label if needed.
Apply appropriate labels.

**Out of scope**: Implementing the fix. Modifying SKILL.md. Any code changes.

## Planning Consultations

None required.

This task is a well-defined operational action: create a GitHub issue with
specific content the user has already articulated. The problem analysis is
complete (the user identified the truncation concern, the root cause in
Phase 1's 40-char cap, and the proposed dual-value solution). No specialist
domain expertise is needed to plan issue creation.

### Cross-Cutting Checklist

- **Testing**: Not applicable -- no code, configuration, or infrastructure produced.
- **Security**: Not applicable -- no attack surface, auth, user input, secrets, or dependencies.
- **Usability -- Strategy**: Not applicable for planning -- the issue itself documents a UX improvement, but creating the issue ticket does not require UX strategy consultation.
- **Usability -- Design**: Not applicable -- no user-facing interfaces produced.
- **Documentation**: Not applicable -- the GitHub issue IS the documentation artifact.
- **Observability**: Not applicable -- no runtime components.

## Anticipated Approval Gates

None. Creating a GitHub issue is fully reversible (can be closed/deleted) and
has zero downstream dependents. Per the gate classification matrix, this is
"Easy to Reverse + Low Blast Radius" = NO GATE.

## Rationale

The user has provided a complete problem analysis and a clear action directive.
The task produces a single GitHub issue -- no architectural decisions, no code,
no design trade-offs, no multi-domain coordination. Specialist consultation
would add overhead without improving the outcome.

The execution plan will consist of one task: create the issue (and the label
if needed) using `gh` CLI commands.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuild/check | Not relevant -- task does not involve agent rebuilding |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant -- task is issue creation, not status line configuration |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain
(GitHub issue creation).
