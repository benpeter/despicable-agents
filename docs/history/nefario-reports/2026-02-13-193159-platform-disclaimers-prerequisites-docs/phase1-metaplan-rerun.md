## Meta-Plan

### Task Analysis

This is a documentation-only task: add platform disclaimers, prerequisites, and platform notes across four files (README.md, docs/prerequisites.md, docs/deployment.md, docs/architecture.md). A prior advisory audit already produced ready-to-use copy (Prompts 1 and 2 in the synthesis working file). The execution work is primarily writing and integrating that copy into the correct locations, with quality review to ensure consistency, no overloading of the README, and correct cross-references.

The advisory copy is well-researched and consensus-backed, so the planning question is not WHAT to write but HOW to integrate it cleanly: file ownership, insertion points, cross-reference integrity, and tone consistency with existing docs.

The revised team adds ai-modeling-minion. The "Quick Setup via Claude Code" section involves a copy-pasteable prompt that an LLM (Claude Code) will interpret and execute -- this is a prompt engineering question that ai-modeling-minion is uniquely qualified to evaluate. The advisory draft prompt is functional but has not been reviewed for clarity, completeness, or failure modes from a prompt design perspective.

### Planning Consultations

#### Consultation 1: Documentation Structure and Integration

- **Agent**: software-docs-minion
- **Planning question**: Given the ready-to-use copy from the advisory (Prompts 1 and 2 in `docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis.md`), review the existing README.md, docs/deployment.md, and docs/architecture.md structure. Specifically: (1) Does the proposed README structure (disclaimer blockquote after "Install", prerequisites table after install code block, Platform Notes section before License) create good information hierarchy without overloading the README? (2) For the new docs/prerequisites.md, should it be in the "User-Facing" or "Contributor / Architecture" sub-documents table in architecture.md? (3) The deployment.md already has a "Prerequisites" subsection under "Hook Deployment" mentioning jq -- how should the new platform support table relate to this existing content without duplication? (4) Are there any cross-reference links that need updating beyond the ones listed in the issue? Note: the "Quick Setup via Claude Code" prompt content is being reviewed by ai-modeling-minion for prompt quality -- your focus should be on where it lives in the doc structure and how it connects to the rest of the documentation.
- **Context to provide**: README.md (full), docs/architecture.md (sub-documents tables), docs/deployment.md (full), the advisory Prompts 1 and 2
- **Why this agent**: software-docs-minion owns documentation architecture -- information hierarchy, cross-references, and avoiding doc bloat are their core domain

#### Consultation 2: Developer Onboarding Flow

- **Agent**: devx-minion
- **Planning question**: The advisory proposes a "Quick Setup via Claude Code" section with a copy-pasteable prompt. Review the proposed prompt text and the README flow. (1) Is the proposed prerequisites table scannable enough for a developer who just wants to get started? (2) Should the "Quick Setup via Claude Code" prompt reference live in the README directly or only in docs/prerequisites.md (the advisory puts it only in prerequisites.md -- the README links to it)? (3) The current README install flow is "clone + ./install.sh" -- how should the prerequisites information integrate without making the happy path (macOS with Homebrew) feel burdensome? (4) Is there a risk that the prerequisites table + platform notes + disclaimer makes the README feel like a warning-heavy document instead of an inviting one? Note: focus on the developer journey and onboarding friction, not on the prompt wording itself (ai-modeling-minion covers prompt quality) or the doc cross-reference structure (software-docs-minion covers that).
- **Context to provide**: README.md (full), the advisory Prompts 1 and 2, project's engineering philosophy from CLAUDE.md
- **Why this agent**: devx-minion specializes in developer onboarding friction -- they can assess whether the proposed additions help or hinder the "time to first successful install" experience

#### Consultation 3: Claude Code Setup Prompt Design

- **Agent**: ai-modeling-minion
- **Planning question**: The advisory includes a "Quick Setup via Claude Code" prompt that users paste into Claude Code to detect their platform, check for missing tools, and install them (see Prompt 2, "Quick Setup via Claude Code" section in the synthesis working file). Review this prompt from a prompt engineering perspective. (1) Is the prompt specific enough for Claude Code to execute reliably? Consider: does it give Claude Code enough context to know which package manager to use, how to verify each tool, and what "bash 4.0+" means on macOS specifically (system bash is 3.2, needs Homebrew)? (2) Does the prompt handle edge cases -- what if a tool is installed but at an older version? What if the user is on an unsupported platform? Should the prompt include explicit fallback instructions? (3) Is the prompt too long or too short for a copy-paste use case? Users will paste this into a Claude Code session -- the prompt should be concise but complete enough that Claude Code does not need follow-up questions. (4) Should the prompt be a blockquote in the docs (as currently proposed) or a fenced code block? Blockquotes render differently and are not as easy to select-all-copy in some contexts. Do NOT propose changes to the documentation structure or developer onboarding flow -- those are handled by software-docs-minion and devx-minion respectively.
- **Context to provide**: The advisory Prompt 2 (specifically the "Quick Setup via Claude Code" subsection), the project's CLAUDE.md for context on what Claude Code is and how it operates
- **Why this agent**: ai-modeling-minion specializes in prompt engineering and LLM interaction design. The "Quick Setup" prompt is a user-facing prompt that Claude Code will interpret and execute -- its quality directly determines whether users get a working environment or a confusing failure. This is not a documentation question; it is a prompt design question.

### Cross-Cutting Checklist

- **Testing**: EXCLUDE. This task produces only markdown documentation files. No code, no configuration, no infrastructure. There is nothing to test programmatically. The verification step (check cross-references, render markdown) is part of the documentation agent's deliverable, not a test-minion concern.
- **Security**: EXCLUDE. No code changes, no new attack surface, no auth/secrets/input handling. The content being documented (platform security considerations) was already analyzed in the advisory -- this task just writes it down.
- **Usability -- Strategy**: INCLUDE. The README is the primary onboarding surface. ux-strategy-minion should review whether the proposed additions (disclaimer, prerequisites, platform notes) create cognitive overload for new users or whether the information architecture serves the user journey well. However, this is lightweight enough to handle as an architecture review (Phase 3.5) rather than a planning consultation -- the advisory already resolved the strategic question ("document, don't code"), and the planning consultations above address the tactical placement questions.
- **Usability -- Design**: EXCLUDE. No UI components, no visual layouts, no interaction patterns. This is markdown documentation.
- **Documentation**: INCLUDED as Consultation 1 (software-docs-minion). This is the primary domain of the task.
- **Observability**: EXCLUDE. No runtime components, no services, no APIs. Pure documentation.

### Anticipated Approval Gates

**Zero approval gates recommended.** Rationale:

- All four files being modified are documentation (easy to reverse -- just edit or revert)
- The content is pre-approved: it comes from a prior advisory audit that the user already reviewed and accepted
- No downstream tasks depend on specific content choices in these docs
- The gate classification matrix yields "NO GATE" for easy-to-reverse + low-blast-radius work

The only verification needed is a final check that the README is not overloaded (listed in the issue), which is a quality criterion for the task itself, not an approval gate.

### Rationale

This task is scoped, low-risk documentation work with ready-to-use copy. Three planning consultations are needed:

1. **software-docs-minion** -- because the core challenge is integrating new content into existing doc structure without duplication or broken cross-references. The advisory produced the content; this agent plans the integration.
2. **devx-minion** -- because the README is the primary onboarding surface and the additions (disclaimer, prerequisites, platform notes) could either help or hurt the developer experience depending on placement and tone.
3. **ai-modeling-minion** -- because the "Quick Setup via Claude Code" prompt is a user-facing prompt that an LLM will interpret and execute. Prompt quality (specificity, edge case handling, copy-paste ergonomics) directly determines whether the setup experience works or fails. This is a prompt engineering review, not a documentation review.

Other specialists were considered and excluded:
- **ux-strategy-minion**: The user journey concern (README overload) is real but lightweight -- it is better handled in Phase 3.5 architecture review than as a planning consultation. The mandatory cross-cutting inclusion is satisfied by their presence in Phase 3.5.
- **user-docs-minion**: The prerequisites.md is closer to developer docs (install instructions) than end-user docs (tutorials, help text). software-docs-minion covers this.
- **product-marketing-minion**: The README tone question (warning-heavy vs. inviting) is a valid concern, but devx-minion covers the developer-facing aspect, and the scope is too small to warrant marketing input.

### Scope

**In scope**:
- Add platform support disclaimer blockquote to README.md
- Add prerequisites table to README.md
- Add "Quick Setup via Claude Code" reference to README.md
- Add "Platform Notes" section to README.md
- Create docs/prerequisites.md with per-platform install commands
- Add platform support table to docs/deployment.md
- Add prerequisites.md to docs/architecture.md sub-documents table
- Verify README is not overloaded

**Out of scope**:
- Script hardening (Tier 2, tracked in #102)
- Windows/cross-platform support (Tier 3, tracked in #103)
- Any code changes to install.sh, hook scripts, or SKILL.md
- Creating GitHub issues (already exist: #102, #103)

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/SKILL.md` | LEAF | Agent building and version checking | NOT RELEVANT -- this task does not modify agents or the-plan.md |
| despicable-statusline | `.claude/skills/despicable-statusline/SKILL.md` | LEAF | Claude Code status line configuration | NOT RELEVANT -- this task does not touch status line configuration |

#### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the documentation domain of this task.
