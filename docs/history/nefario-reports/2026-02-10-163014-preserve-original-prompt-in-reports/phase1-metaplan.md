# Meta-Plan: Preserve Original Prompt in PR Descriptions and Nefario Reports

## Analysis

### Current State

The nefario orchestration already captures the verbatim user prompt in two ways:
1. **Session context**: SKILL.md Phase 1 captures `original-prompt` and retains it for the report.
2. **Report Task section**: TEMPLATE.md section 3 includes the verbatim prompt as a blockquote (inline for short, collapsible for long), with security redaction guidance.
3. **PR body**: SKILL.md wrap-up uses the report body (stripped of frontmatter) as the PR description. Since the report body contains the Task section, the prompt is already in the PR -- but indirectly, as part of the full report narrative.

### Gaps

1. **No standalone prompt.md file**: The verbatim prompt is embedded in the report but not saved as a separate, machine-readable file alongside it.
2. **PR description lacks a dedicated prompt section**: The PR body is the entire report body. There is no PR-specific template that highlights the original prompt in a dedicated, labeled section (e.g., "## Original Prompt" or "## What Was Asked") separate from the report's narrative structure.
3. **No explicit SKILL.md instruction** to write `prompt.md` as part of wrap-up.

### Scope

**In scope:**
- SKILL.md wrap-up sequence: add step to write `prompt.md` alongside the report
- SKILL.md PR creation: update PR body format to include a dedicated original prompt section
- TEMPLATE.md: add guidance for the `prompt.md` companion file
- docs/orchestration.md: mention the new `prompt.md` artifact

**Out of scope:**
- Despicable-prompter skill changes
- Agent AGENT.md files
- install.sh
- the-plan.md
- Retroactive modification of existing reports

### Files to Modify

| File | Change |
|------|--------|
| `skills/nefario/SKILL.md` | Add `prompt.md` write step in wrap-up; update PR body format |
| `docs/history/nefario-reports/TEMPLATE.md` | Add guidance for `prompt.md` companion file |
| `docs/orchestration.md` | Mention `prompt.md` artifact in Section 5 |

## Planning Consultations

### Consultation 1: Developer Experience and Template Design

- **Agent**: devx-minion
- **Planning question**: The nefario SKILL.md wrap-up currently writes the report and optionally copies scratch files to a companion directory. We want to add: (a) a standalone `prompt.md` file written alongside the report (in the companion directory or in the report directory itself), and (b) a dedicated "Original Prompt" section in the PR description. Design the placement and format of `prompt.md` (where it lives, what it contains beyond the raw prompt -- e.g., metadata header? just the prompt?). Also design the PR body structure -- should the PR description be a condensed version with a prominent prompt section, or the full report body with an added section? Consider that the current PR body is the full report stripped of frontmatter.
- **Context to provide**: `skills/nefario/SKILL.md` (wrap-up section, PR creation section), `docs/history/nefario-reports/TEMPLATE.md`, existing report example
- **Why this agent**: DevX expertise in template design, file organization, and developer-facing artifact structure. The core question is "what format serves reviewers best" -- that's a developer experience question.

### Consultation 2: Documentation Structure

- **Agent**: software-docs-minion
- **Planning question**: We're adding a `prompt.md` companion file to nefario reports and a dedicated prompt section to PR descriptions. From a documentation perspective: (a) Should `prompt.md` be a plain text file, a markdown file with frontmatter, or just raw prompt text? (b) How should the report's existing Task section reference the companion `prompt.md`? (c) Should the TEMPLATE.md report writing checklist be updated to include the prompt.md step? (d) Does docs/orchestration.md Section 5 (Execution Reports) need updates to mention this new artifact?
- **Context to provide**: `docs/history/nefario-reports/TEMPLATE.md`, `docs/orchestration.md` Section 5
- **Why this agent**: Documentation structure expertise -- ensuring the new artifact fits coherently into the existing documentation system without creating redundancy or inconsistency.

## Cross-Cutting Checklist

- **Testing**: Exclude. This task modifies only documentation templates and skill instructions. No executable code is produced. The changes are to markdown templates and natural language instructions in SKILL.md.
- **Security**: Exclude for planning. The existing security redaction guidance (remove secrets, tokens, API keys from verbatim prompts) already covers the prompt content. The new `prompt.md` file contains the same content as the report's Task section. No new attack surface is created. Security review in Phase 3.5 will verify the existing redaction instructions are referenced in the new write step.
- **Usability -- Strategy**: Include via devx-minion consultation above. The core question is about reviewer experience (PR readability, report navigability). devx-minion covers this for developer-facing artifacts. A separate ux-strategy-minion consultation would not add value beyond what devx-minion provides, since the "users" here are PR reviewers and future developers reading reports -- squarely in devx territory.
- **Usability -- Design**: Exclude. No user-facing interface is produced. The artifacts are markdown files and CLI tool instructions.
- **Documentation**: Include -- software-docs-minion consultation above covers documentation structure.
- **Observability**: Exclude. No runtime components, services, or APIs are produced.

## Anticipated Approval Gates

**Zero gates anticipated.** All changes are:
- Additive (new file, new section in existing template)
- Easy to reverse (markdown templates, skill instructions)
- Low blast radius (only affects future nefario orchestration runs)
- Clear best practice (preserving the original prompt is a straightforward traceability improvement)

The reversibility + blast radius matrix classifies all changes as NO GATE.

## Rationale

Two specialists are consulted because this task spans two domains that genuinely contribute different perspectives:

1. **devx-minion**: Owns the artifact design question -- file format, placement, PR body structure. This is the primary domain.
2. **software-docs-minion**: Owns the documentation coherence question -- how new artifacts fit into the existing template/report/orchestration documentation system.

Other specialists were considered and excluded:
- **ux-strategy-minion**: Normally ALWAYS included, but the "users" here are developers reviewing PRs and reading reports. devx-minion's developer experience expertise covers this adequately. Including ux-strategy-minion would produce overlapping recommendations for this specific task.
- **lucy**: Will review in Phase 3.5 (mandatory) for intent alignment and convention adherence.
- **margo**: Will review in Phase 3.5 (mandatory) for simplicity -- particularly important here to prevent over-engineering a simple traceability feature.

## Scope

**Goal**: Ensure the full original user prompt (the `/nefario` briefing) is captured in PR descriptions, nefario execution reports, and as a standalone file -- providing traceability from intent to implementation.

**In scope**: SKILL.md wrap-up and PR creation flow, TEMPLATE.md report template, orchestration.md documentation.

**Out of scope**: Despicable-prompter skill, agent AGENT.md files, install.sh, the-plan.md, retroactive modification of existing reports.
