# lucy Research: Human Intent Alignment and Repo Governance

This document provides the research foundation for lucy, the governance agent
focused on human intent alignment, repo convention enforcement, and CLAUDE.md
compliance. Lucy operates as a proxy for human intent in multi-agent
orchestrations, ensuring plans answer the question the human actually asked.

---

## 1. Goal Alignment in Multi-Agent Systems

Multi-agent orchestrations amplify the risk of goal drift. Each specialist
agent optimizes for its own domain, potentially pushing the overall solution
away from the user's original intent. Goal drift occurs when an agent's
internal objectives shift over time -- even small changes compound across
phases and agents.

### Drift Categories

- **Scope creep**: Plan includes features not requested
- **Over-engineering**: Solution complexity exceeds problem complexity
- **Context loss**: Plan addresses a subtly different problem than originally stated
- **Feature substitution**: Plan delivers adjacent features instead of requested ones
- **Gold-plating**: Agents add polish beyond acceptance criteria
- **Recursive drift**: Early incoherences propagate through dependent phases

### Alignment Verification Techniques

- **Requirement echo-back**: Agent repeats understanding of the task before starting
- **Success criteria definition**: Explicitly state what "done" looks like before work begins
- **Diff against original request**: Compare synthesized plan to original user request, flagging additions and omissions
- **Incremental validation**: Validate alignment at each phase boundary, not just at the end
- **Scope budget**: Define acceptable scope boundaries; flag plans exceeding the budget
- **Decision briefs**: Summarize key decisions and rationale for human review

### Production Detection Methods (2025-2026)

Recent research has produced concrete detection approaches:

- **Coherence-Based Alignment (CBA)**: Introduces a scalar coherence metric that penalizes internal contradictions, providing structural misalignment prevention (PhilArchive, 2025)
- **AlignmentCheck (Meta)**: Uses LM reasoning to compare an agent's action sequence against the user's stated objective, flagging deviations (Partnership on AI, 2025)
- **Secondary monitor models**: Track execution traces to spot goal drift, covert prompt injection, or tool misuse (OpenAI Operator pattern)
- **Semantic drift detection**: Embedding-based comparison of plan outputs against original intent vectors; flags when semantic distance exceeds threshold
- **Verifier models**: Models specifically trained to check the logic and alignment of other models' outputs

### Feedback Loop Design

Effective feedback loops catch drift early:

- Validate alignment at each phase, not just at the end
- Require explicit human approval before transitioning from planning to execution
- Define scope boundaries that are testable, not aspirational
- Summarize key decisions and their rationale for human review
- Keep feedback lightweight -- heavyweight processes get bypassed under pressure

**Sources**: Partnership on AI (2025), "Prioritizing Real-Time Failure Detection in AI Agents"; PhilArchive (2025), "A Structural Architecture for Preventing Goal Drift"; ResearchGate (2025), "Agent Goal Drift in Stateful Systems"

---

## 2. Requirements Traceability

Requirements traceability ensures every implementation can be traced back to an
originating requirement, and every requirement has a clear implementation path.
This bidirectional link prevents scope creep, goal drift, and feature gaps.

### Traceability Matrix Patterns

A traceability matrix maps requirements to implementation artifacts:

- **Requirement ID -> Task ID -> Commit Hash**: Links requirements to tasks and implementation
- **User Story -> Acceptance Criteria -> Test Cases**: Validates that criteria drive test coverage
- **Feature Request -> Design Decision -> Implementation File**: Ensures features are consciously designed

Manual matrices decay quickly. Automation is essential for sustainability.

### Git-Based Traceability (Lightweight)

Modern git workflows enable lightweight traceability through conventions:

- **Branch naming**: `feature/REQ-123-user-authentication` links branches to requirements
- **Commit messages**: `REQ-123: Implement OAuth token refresh` links commits to requirements
- **PR descriptions**: Templates requiring linking PRs to originating issues
- **Issue references**: `Closes #42` or `Fixes #42` in commit messages

Git-based traceability scales well for small-to-medium projects and integrates
naturally with developer workflows. It breaks down when requirements live
outside git (Jira, Linear, client documents).

### Automated Verification

- **PR gate checks**: Block merges unless PR is linked to a requirement
- **Coverage reports**: Show which requirements lack implementation or tests
- **Change impact analysis**: Identify all artifacts affected by a requirement change

**Sources**: Salo & Poranen, "Requirements management in GitHub with a lean approach" (CEUR-WS Vol-1525); Sodiuswillert, "Requirements Traceability in Systems & Software Engineering"

---

## 3. Software Governance Patterns

Software governance establishes organizational policies and enforces them
through tooling and process. Effective governance stands on five pillars: a
standardized SDLC, robust quality gates, integrated security, consistent
tooling standards, and comprehensive monitoring.

### Policy-as-Code Enforcement

Policy-as-Code codifies organizational policies in machine-readable formats
and enforces them automatically:

- **Open Policy Agent (OPA)**: General-purpose policy engine for Kubernetes, CI/CD, APIs
- **Conftest**: Tests configuration files against OPA policies
- **GitHub CODEOWNERS**: Enforces review requirements based on file paths
- **Branch protection rules**: Prevents force-pushes, requires status checks, enforces review counts
- **Custom ESLint rules**: Enforce project-specific naming and structural conventions
- **Danger**: PR bot that checks for convention violations in file locations, naming, required files

Policy-as-Code removes ambiguity. "All production deployments must be reviewed
by SRE" becomes a gate that cannot be bypassed.

### Configuration Drift Detection

Configuration drift is a silent killer -- systems that diverge from declared
state become unpredictable and fragile:

- **Infrastructure as Code (IaC)**: All configuration stored in version-controlled code
- **Drift detection tools**: Chef InSpec, Terraform plan, custom audit scripts
- **Immutable infrastructure**: Replace components rather than patching in place
- **Secrets management**: Never commit secrets; use vault solutions

### Continuous Compliance Monitoring

Compliance is continuous, not a one-time audit:

- **Dependabot / Renovate**: Automate dependency updates and security patches
- **Snyk**: Scans for vulnerabilities in dependencies and container images
- **git-secrets / pre-commit hooks**: Prevent committing secrets
- **License compliance**: Verify dependency licenses are compatible

Continuous compliance shifts governance left -- catching issues at commit time
rather than audit time.

### Minimum Viable Governance

Start with high-impact areas (version control, peer reviews, automated tests)
and evolve the framework as the organization grows. Do not try to implement
everything at once.

**Sources**: JFrog, "What is Software Governance?"; 3Pillar Global, "Governance Processes in Software Development"; developers.dev, "Effective Software Development Governance"

---

## 4. Convention-Over-Configuration Enforcement

Convention-over-configuration reduces cognitive load by establishing sensible
defaults and predictable patterns. Teams spend less time deciding where things
go and more time building.

### Core Principles

- **Predictable file structure**: Models in one place, controllers in another, views in a third
- **Naming conventions**: Names imply relationships (a `User` model maps to a `users` table)
- **Implicit behavior**: Conventions infer routing, validation, and wiring from naming alone
- **Configuration by exception**: Only configure what deviates from convention

This philosophy reduces boilerplate and makes codebases instantly familiar to
new contributors. The tradeoff: customization requires explicitly opting out.

### Enforcement Through Tooling

Conventions mean nothing without enforcement:

- **ESLint plugins / custom rules**: Enforce project-specific naming and structural conventions
- **Danger**: PR automation checking for convention violations
- **Pre-commit hooks**: Reject commits violating conventions
- **CI checks**: Fail builds if conventions are violated
- **Nx generators / constraints**: Enforce boundaries and scaffolding conventions in monorepos

The goal is to make convention violations impossible, not just discouraged.

### Directory Structure Standards

Standard structures reduce context-switching:

- **Monorepo patterns**: `packages/`, `apps/`, `libs/` for Nx/Turborepo
- **Feature-sliced design**: Group by feature rather than technical layer
- **Domain-driven design**: Organize by domain boundaries
- **Flat config**: Single configuration file at project root for unified tooling

Consistency matters more than the specific structure chosen. Pick a pattern,
document it, enforce it rigorously.

### File Naming Conventions

Common patterns that reduce ambiguity:

- **kebab-case for files**: `user-profile.ts`, `api-gateway.js`
- **PascalCase for components/classes**: `UserProfile.tsx`, `ApiGateway.java`
- **Suffix conventions**: `.test.ts`, `.spec.ts`, `.stories.tsx`, `.module.css`
- **Index files**: `index.ts` as public API surface for directories

**Sources**: monorepo.tools; typescript-eslint documentation; ESLint flat config documentation

---

## 5. CLAUDE.md Specification and Compliance

CLAUDE.md files provide project-specific instructions to Claude Code agents.
They persist context across sessions, documenting coding standards,
architectural decisions, preferred libraries, and workflow conventions.

### File Hierarchy (Resolution Order)

Claude Code reads CLAUDE.md files from multiple sources with a defined
precedence hierarchy (more specific overrides more general):

| Priority | Location | Scope | Shared |
|----------|----------|-------|--------|
| 1 (highest) | `./CLAUDE.local.md` | Personal + project | No (gitignored) |
| 2 | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Project (team) | Yes (VCS) |
| 3 | `./.claude/rules/*.md` | Project rules (modular) | Yes (VCS) |
| 4 | `~/.claude/CLAUDE.md` | User global | No |
| 5 | `~/.claude/rules/*.md` | User global rules | No |
| 6 (lowest) | Managed policy (system-level) | Organization | Yes (MDM) |

Parent directory CLAUDE.md files are loaded at launch (recursing upward from
cwd). Child directory CLAUDE.md files load on demand when Claude reads files
in those subtrees.

### Import System

CLAUDE.md files can import additional files using `@path/to/import` syntax:

- Both relative and absolute paths allowed
- Relative paths resolve relative to the containing file
- Recursive imports supported (max depth 5)
- Not evaluated inside code spans or code blocks
- First-time imports require user approval

### Well-Structured CLAUDE.md Content

A well-structured CLAUDE.md includes:

- **Project overview**: What the project does, key architectural patterns
- **Development conventions**: File naming, directory structure, module organization
- **Technology preferences**: Preferred libraries, tools, and frameworks
- **Build and deployment**: How to build, test, and deploy
- **Team workflow**: PR standards, review requirements, commit message format
- **Commands**: Exact build/test/lint/deploy commands
- **Gotchas**: Project-specific warnings and edge cases

### CLAUDE.md Anti-Patterns

- **Too long**: Context is precious; every line competes for attention. Aim for under 300 lines.
- **Too vague**: "Format code properly" is useless; "Use 2-space indentation, no semicolons" is actionable
- **Stale**: CLAUDE.md must evolve with the codebase; outdated instructions cause harm
- **Redundant**: Don't repeat what's inferrable from code; focus on what cannot be detected automatically
- **Missing gotchas**: The most valuable CLAUDE.md content is non-obvious constraints

### Modular Rules Directory

`.claude/rules/` enables splitting instructions into focused files:

- All `.md` files discovered recursively
- Path-specific rules via `paths:` YAML frontmatter (glob patterns)
- Symlinks supported for cross-project rule sharing
- Subdirectory organization for larger projects

### Compliance Verification Strategy

Lucy should verify CLAUDE.md compliance by:

1. Reading all CLAUDE.md files in the project hierarchy
2. Extracting actionable directives (technology preferences, naming conventions, banned patterns)
3. Checking plans and code against extracted directives
4. Flagging violations with specific CLAUDE.md line references
5. Verifying consistency between CLAUDE.md declarations and project configuration files (.editorconfig, tsconfig.json, package.json, .eslintrc)

**Sources**: Anthropic, "Using CLAUDE.MD files" (claude.com/blog); Anthropic, "Manage Claude's memory" (code.claude.com/docs/en/memory); Builder.io, "The Complete Guide to CLAUDE.md"; HumanLayer, "Writing a good CLAUDE.md"

---

## 6. Scope Validation Techniques

Scope validation ensures plans stay within the boundaries of the original
request. Scope inflation is a common failure mode in multi-agent systems.

### Boundary Definition

Clear scope boundaries prevent creep:

- **In-scope examples**: Concrete examples of features that are in scope
- **Out-of-scope examples**: Concrete examples of features explicitly excluded
- **Acceptance criteria**: Objective criteria for plan acceptance
- **Constraints**: Technical, time, or budget constraints limiting scope

Boundaries should be explicit and testable. "Improve performance" is vague;
"Reduce API response time to < 200ms" is testable.

### Scope Creep Indicators

Common indicators that lucy should flag:

- **Task count inflation**: Original request implied 3 tasks, plan includes 10
- **Technology expansion**: Plan introduces technologies not mentioned in request
- **Abstraction layers**: Plan adds indirection not required by the problem
- **Adjacent features**: Plan includes "nice-to-have" features beyond core request
- **Pre-optimization**: Plan optimizes for future requirements not yet needed
- **Dependency introduction**: Plan adds dependencies not justified by stated needs

### Minimal Viable Implementation

The minimal viable implementation satisfies the request with the least complexity:

- **YAGNI**: Don't build features not explicitly requested
- **KISS**: Prefer simple solutions over complex ones
- **Occam's Razor**: The simplest solution that meets requirements is usually correct

Lucy's default stance is skepticism toward complexity. Additional complexity
requires explicit justification tied to stated requirements.

---

## 7. Repository Consistency Audit Patterns

Repository audits verify that a codebase adheres to its declared conventions.
Lucy performs these audits by reading project configuration and comparing
actual file structure and content against declared standards.

### Structural Audit Checks

- **Directory structure**: Do directories follow the declared pattern?
- **File naming**: Do filenames follow the declared convention (kebab-case, PascalCase, etc.)?
- **Required files**: Are all required files present (README, LICENSE, CLAUDE.md, .gitignore)?
- **Forbidden files**: Are there files that should not exist (.env with secrets, build artifacts)?
- **Module boundaries**: Do import paths respect declared module boundaries?

### Configuration Consistency Checks

- **Package manager**: Does lock file match declared package manager?
- **Node version**: Does .nvmrc / .tool-versions match declared version?
- **TypeScript config**: Does tsconfig.json match declared strictness level?
- **Linter config**: Does ESLint / Prettier config match declared style?
- **Git hooks**: Are pre-commit hooks configured as declared?

### Content Pattern Checks

- **Import patterns**: Are imports using declared module system (ESM vs CJS)?
- **Export patterns**: Are exports following declared conventions (named vs default)?
- **Error handling**: Does error handling follow declared patterns?
- **Logging**: Does logging follow declared format and levels?
- **Test organization**: Are tests co-located or centralized as declared?

---

## 8. Best Practices Summary

### Goal Alignment
- Echo back requirements before starting work
- Define success criteria explicitly and testably
- Validate alignment at each phase boundary
- Compare final plan to original request word-by-word
- Flag scope expansions and require justification

### Convention Enforcement
- Document conventions in CLAUDE.md
- Automate enforcement through linting and CI
- Make violations impossible, not just discouraged
- Audit regularly for drift between convention and practice

### Requirements Traceability
- Link requirements to tasks and commits via naming conventions
- Automate traceability checks in PR gates
- Generate coverage reports showing requirement gaps
- Use git conventions for lightweight traceability

### Scope Validation
- Define in-scope and out-of-scope boundaries explicitly
- Watch for scope creep indicators (task inflation, technology expansion)
- Default to minimal viable implementation
- Require justification for complexity beyond stated requirements

### CLAUDE.md Compliance
- Read all CLAUDE.md files in hierarchy before reviewing
- Extract actionable directives and check plans against them
- Verify configuration file consistency with declared preferences
- Flag stale or contradictory instructions
