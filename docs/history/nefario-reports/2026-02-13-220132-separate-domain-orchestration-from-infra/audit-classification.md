# Domain/Infrastructure Classification

## SKILL.md

### Section: YAML Frontmatter (lines 1-11)
Classification: MIXED
Rationale: The frontmatter structure (name, description, argument-hint) is infrastructure. The description text references "nine-phase process", specific phase names ("code quality, run tests, optionally deploy, and update documentation"), and the `--advisory` flag semantics -- all domain-specific.
Infrastructure part: YAML frontmatter schema, name field, argument-hint pattern.
Domain-specific part: Description text mentioning nine phases, post-execution phase names (code review, tests, deploy, docs).
Extraction approach: Template the description field; populate from adapter.

### Section: Core Rules (lines 19-27)
Classification: INFRASTRUCTURE
Rationale: Generic enforcement of "follow the full workflow, never skip gates." The advisory-mode exception references "Phases 1-3" and "Phases 3.5-8" by number, but these numbers are structural (the orchestration always has numbered phases). The rule mechanism is domain-independent.

### Section: Argument Parsing (lines 28-138)
Classification: MIXED
Rationale: Flag extraction (`--advisory`), issue mode (`#<N>`), free text mode, issue fetch via `gh`, content boundary markers (`<github-issue>`, `<external-skill>`) are infrastructure. However, the GitHub issue integration (gh CLI, `Resolves #N` in PR body, `source-issue` tracking) is domain-specific to software projects using GitHub.
Infrastructure part: Flag extraction pattern, input mode detection (issue vs. free text), content boundary markers, freeform prompt parsing.
Domain-specific part: GitHub issue fetch (`gh issue view`), `Resolves #N` convention, PR body integration, `gh` CLI dependency.
Extraction approach: Abstract issue fetch into a "task source" adapter. GitHub is one implementation; a regulatory domain might use Jira or a document management system.

### Section: Overview -- Phase List (lines 140-156)
Classification: DOMAIN-SPECIFIC
Rationale: The nine-phase enumeration names domain-specific activities: "Code Review", "Test Execution", "Deployment", "Documentation". The phase count (9) and phase names are specific to software development. A different domain would have different post-execution phases.

### Section: Communication Protocol (lines 158-201)
Classification: MIXED
Rationale: The SHOW/NEVER SHOW/CONDENSE output discipline is infrastructure. However, specific examples reference domain content: "Post-execution phase transitions", "code review, tests, documentation...", "Verbose git command output (use `--quiet` flags)".
Infrastructure part: The three-tier output taxonomy (SHOW, NEVER SHOW, CONDENSE), heartbeat mechanism, suppression of spawning narration.
Domain-specific part: Specific CONDENSE examples ("code review, tests, documentation"), "Verbose git command output" reference, post-execution phase names in examples.
Extraction approach: Keep the taxonomy as infrastructure. Move specific CONDENSE templates and post-execution phase names to the adapter.

### Section: Phase Announcements (lines 202-228)
Classification: MIXED
Rationale: The announcement mechanism (one-line marker with emoji, format pattern `**--- Phase N: Name ---**`) is infrastructure. The specific phase names and numbers (Phase 1: Meta-Plan through Phase 5-8 combined) are domain-specific.
Infrastructure part: Marker format, one-line rule, parenthetical context guidance, positioning rule (start of phase).
Domain-specific part: Phase name table (Meta-Plan, Specialist Planning, Synthesis, Architecture Review, Execution, and the dark-kitchen note for 5-8).
Extraction approach: Phase name/number registry in adapter; announcement mechanism reads from it.

### Section: Visual Hierarchy (lines 229-241)
Classification: INFRASTRUCTURE
Rationale: The three-weight system (Decision, Orientation, Inline) and their visual patterns are domain-independent presentation mechanics.

### Section: Path Resolution (lines 243-254)
Classification: INFRASTRUCTURE
Rationale: Path display rules (absolute paths, no abbreviation, markdown link convention) are domain-independent file management.

### Section: Scratch Directory (lines 255-365)
Classification: MIXED
Rationale: The secure creation mechanism (mktemp, chmod 700), slug generation, lifecycle (creation, overwrites, cleanup) are infrastructure. The scratch directory structure (lines 303-328) lists domain-specific file names: `phase5-code-review-minion-prompt.md`, `phase5-lucy-prompt.md`, `phase5-margo-prompt.md`, `phase6-test-results.md`, `phase7-deployment.md`, `phase8-checklist.md`, `phase8-software-docs.md`, `phase8-user-docs.md`, `phase8-marketing-review.md`.
Infrastructure part: mktemp creation, chmod, slug rules, lifecycle management, `-prompt.md` convention, generic `phaseN-{agent}.md` naming pattern.
Domain-specific part: The complete file listing in lines 303-328, which names specific agents and phase files.
Extraction approach: Define a naming pattern in infrastructure (`phase{N}-{agent}-prompt.md`); the specific file list is derived from the adapter's phase/agent definitions.

### Section: Inline Summary Template (lines 336-357)
Classification: INFRASTRUCTURE
Rationale: The summary template format (Agent, Phase, Recommendation, Tasks, Risks, Conflicts, Verdict, Full output path) is domain-independent. The `Phase: planning | review` values are structural, not domain-specific.

### Section: Phase 1: Meta-Plan (lines 367-461)
Classification: MIXED
Rationale: The mechanism (slug generation, scratch directory creation, status file writing, prompt construction, secret sanitization, nefario spawning, external skill discovery) is infrastructure. The secret sanitization patterns (`sk-`, `key-`, `AKIA`, `ghp_`, `github_pat_`, `token:`, `bearer`, `password:`, `passwd:`, `BEGIN.*PRIVATE KEY`) are domain-specific to software/cloud credentials. The meta-plan prompt template references "delegation table" and "specialists" generically.
Infrastructure part: Slug generation, scratch dir creation, status file lifecycle, prompt file writing, spawning pattern, external skill discovery steps.
Domain-specific part: Secret sanitization regex patterns (lines 381-382). These patterns are software/cloud-specific.
Extraction approach: Move secret patterns to the adapter as a `sanitization-patterns` list.

### Section: Team Approval Gate (lines 463-601)
Classification: MIXED
Rationale: The gate mechanism (AskUserQuestion with Approve/Adjust/Reject, adjustment rounds, re-run logic, cap at 2 rounds) is infrastructure. The "27-agent roster" reference, the domain list ("dev tools, frontend, backend, data, AI/ML, ops, governance, UX, security, docs, API design, testing, accessibility, SEO, edge/CDN, observability"), and the adjustment handling that references specific agent names are domain-specific.
Infrastructure part: Gate presentation pattern, AskUserQuestion structure, 3-option template, re-run flow, 2-round cap, no-op detection, cleanup on reject.
Domain-specific part: "27-agent roster" (line 535), domain enumeration (line 531-532), agent name references throughout adjustment handling.
Extraction approach: The domain list and roster size come from the adapter. The gate mechanism is parameterized by roster metadata.

### Section: Phase 2: Specialist Planning (lines 609-690)
Classification: INFRASTRUCTURE
Rationale: The specialist spawning pattern (parallel, opus for planning, prompt template with task/question/context/instructions, output collection, inline summary, second-round agent additions) is domain-independent. The prompt template is generic ("domain plan contribution", "recommendations", "proposed tasks", "risks", "additional agents needed"). The advisory context add-on is also generic.

### Section: Phase 3: Synthesis (lines 692-795)
Classification: INFRASTRUCTURE
Rationale: The synthesis spawning (MODE: SYNTHESIS, combining specialist contributions, external skills integration, writing to scratch file, compact summary tracking) is domain-independent orchestration. The advisory variant is also generic.

### Section: Compaction Checkpoint -- Post Phase 3 (lines 796-852)
Classification: INFRASTRUCTURE
Rationale: Context usage extraction, compaction gate (AskUserQuestion with Skip/Compact), clipboard copy, focus string interpolation, wait-for-continue pattern. All domain-independent context management.

### Section: Advisory Termination and Advisory Wrap-up (lines 854-935)
Classification: MIXED
Rationale: The termination mechanism (skip phases, proceed to wrap-up) and wrap-up sequence (timestamp, collect files, write report, commit, clean up) are infrastructure. The commit message format `docs: add nefario advisory report for <slug>` is domain-specific (conventional commit type). The statement "no branch created, no PR opened" assumes a git/PR workflow.
Infrastructure part: Termination decision, wrap-up sequence steps, scratch cleanup, status file removal, presentation format.
Domain-specific part: Git commit message format, "no PR" assumption, conventional commit type prefix.
Extraction approach: Commit message template in adapter.

### Section: Phase 3.5: Architecture Review (lines 937-1236)
Classification: MIXED
Rationale: The review mechanism (identify reviewers, present gate, spawn reviewers, collect verdicts, revision loop) is infrastructure. The specific mandatory and discretionary reviewer lists are domain-specific.
Infrastructure part: Reviewer approval gate interaction (AskUserQuestion with Approve/Adjust/Skip), spawning pattern (parallel, opus/sonnet split), verdict collection (APPROVE/ADVISE/BLOCK format), revision loop (2-round cap), escalation to user (PLAN IMPASSE), minor/substantial adjustment path classification, domain signal evaluation pattern.
Domain-specific part: Mandatory reviewer list (security-minion, test-minion, ux-strategy-minion, lucy, margo -- lines 947-951), discretionary reviewer pool with domain signals (ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion -- lines 958-964), ux-strategy-minion custom prompt (lines 1163-1236), reviewer focus descriptions ("security gaps", "test coverage", "observability gaps"), ADVISE/BLOCK examples referencing software concepts (OAuth, JWT, auth/callback.ts).
Extraction approach: Mandatory/discretionary reviewer lists and their domain signals move to adapter. Custom reviewer prompts (like ux-strategy) are adapter content. The verdict format (APPROVE/ADVISE/BLOCK) and revision loop are infrastructure.

### Section: Compaction Checkpoint -- Post Phase 3.5 (lines 1312-1355)
Classification: INFRASTRUCTURE
Rationale: Same infrastructure pattern as the Phase 3 compaction checkpoint. Focus string content references "execution plan", "ADVISE notes", "gate decision briefs" -- all generic orchestration concepts.

### Section: Execution Plan Approval Gate (lines 1357-1480)
Classification: MIXED
Rationale: The gate presentation format (orientation line, task list, advisories, risks, review summary, plan reference) is infrastructure. The specific advisory domain labels ("[testing]", "[security]", "[usability]") are populated from reviewers and are thus domain-influenced but not hardcoded here. The "What NOT to Show" list is infrastructure.
Infrastructure part: Progressive disclosure layout, task list format, advisory format (CHANGE/WHY/SCOPE), risk/conflict sections, line budget guidance, AskUserQuestion structure (Approve/Request changes/Reject).
Domain-specific part: No explicitly domain-specific content in this section. Domain specificity enters through the content of the plan, not the gate format.
Extraction approach: None needed -- this section is effectively infrastructure.

### Section: Phase 4: Execution (lines 1488-1706)
Classification: MIXED
Rationale: Branch creation, team creation, task spawning, execution loop, monitoring, gate handling, auto-commit, deferred task handling are all infrastructure orchestration mechanics. Domain-specific elements: git branch naming (`nefario/<slug>` -- lines 1513), conventional commit format (`<type>(<scope>): <summary>` with `Co-Authored-By` -- lines 1684-1685), `git push`/`gh pr` integration, PR detection via `gh pr list`.
Infrastructure part: Execution loop (batch spawning, monitoring, gate checkpoints), TeamCreate/TaskCreate/TaskUpdate integration, deferred task pattern, auto-commit mechanism structure, gate decision briefs, calibration check.
Domain-specific part: Git branch naming convention, conventional commit format, `Co-Authored-By` trailer, `gh pr list` for existing PR detection, post-execution phase skip options naming ("Skip docs", "Skip tests", "Skip review") and flags (`--skip-docs`, `--skip-tests`, `--skip-review`, `--skip-post`).
Extraction approach: Branch naming template, commit message template, post-execution skip option labels/flags -- all move to adapter.

### Section: Post-Execution Phases 5-8 (lines 1722-2006)
Classification: DOMAIN-SPECIFIC
Rationale: The entire post-execution verification pipeline is software-development-specific. Phase 5 (code review with code-review-minion, lucy, margo), Phase 6 (test discovery and execution with package.json/Makefile/pyproject.toml patterns), Phase 7 (deployment), Phase 8 (documentation with software-docs-minion, user-docs-minion, product-marketing-minion, outcome-action table, marketing tier system) are all deeply tied to software development.

Specific domain-specific content:
- Phase 5: File classification table (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md, README.md as logic-bearing vs. documentation-only -- lines 1761-1768). Three reviewers: code-review-minion, lucy, margo with software-specific review foci. Security-severity BLOCK patterns (injection, auth bypass, secret exposure, crypto). Secret scanning patterns in escalation briefs.
- Phase 6: Test discovery patterns (package.json scripts, Makefile targets, pyproject.toml, CI configs, test file globs -- lines 1878-1883). Framework configs (vitest, jest, pytest -- line 1884). Layered execution (lint, unit, integration/E2E).
- Phase 7: Deployment command execution pattern.
- Phase 8: Outcome-action table (API endpoints, architecture changes, CLI commands, user-facing features -- lines 1919-1931). Priority assignment (MUST/SHOULD/COULD). Sub-step 8b marketing tier system with software-specific criteria (orchestration, governance, specialist depth, install-once -- lines 1974-1978).

Extraction approach: The entire post-execution pipeline definition (which phases exist, what each does, which agents they use, file classification tables, test discovery patterns, outcome-action tables) moves to the adapter. Infrastructure retains only the dark-kitchen pattern, the generic CONDENSE line format, and the skip-determination logic structure.

### Section: Wrap-up (lines 2007-2096)
Classification: MIXED
Rationale: The wrap-up sequence structure (review deliverables, capture timestamp, verification summary, auto-commit, collect working files, write report, commit report, PR creation/update, cleanup, present to user, shutdown teammates) is infrastructure. Domain-specific elements: verification summary examples reference "code review", "tests", "docs", "AGENT.md", "CLAUDE.md". PR creation uses `gh pr create`, git commands, conventional commit conventions. Post-Nefario Updates section format references "Commits", "Files changed" table.
Infrastructure part: Wrap-up sequence steps (1-14), companion directory creation, sanitization-before-copy, report generation trigger, status file cleanup, teammate shutdown, feature branch handling.
Domain-specific part: Verification summary format examples (lines 2014-2022) naming software phases. PR creation mechanics (lines 2033-2085) including `gh pr create`, body file generation, secret scanning patterns, `Resolves #N`. Post-Nefario Updates format (lines 2267-2303). Commit message (`docs: add nefario execution report`).
Extraction approach: Verification summary templates, PR creation logic, commit message templates, and Post-Nefario Updates format move to adapter. The wrap-up sequence skeleton stays as infrastructure.

### Section: Report Generation (lines 2108-2265)
Classification: MIXED
Rationale: The data accumulation pattern (tracking phase data at boundaries in scratch files and session context) and the report template reference are infrastructure. The specific data fields tracked are partly domain-specific.
Infrastructure part: Data accumulation pattern, scratch file reference, session context tracking, report template reference (`TEMPLATE.md`), incremental writing concept, wrap-up sequence structure, compaction fallback.
Domain-specific part: Phase-specific data fields: "Code review findings count (BLOCK/ADVISE/NIT)", "Test results (pass/fail/skip counts)", "Deployment status", "Documentation files created/updated" (lines 2161-2164). The `skills-invoked` and `compaction-events` tracking are infrastructure. The `existing-pr` field is domain-specific (GitHub PR).
Extraction approach: Post-execution data field definitions move to adapter. Generic phase-boundary tracking stays as infrastructure.

### Section: Troubleshooting (lines 2097-2107)
Classification: INFRASTRUCTURE
Rationale: Platform-specific workaround for Claude Code message delivery timing. No domain content.

---

## AGENT.md

### Section: YAML Frontmatter (lines 1-13)
Classification: MIXED
Rationale: Frontmatter structure (name, description, model, memory, x-plan-version, x-build-date) is infrastructure. The description text ("specialist agents", "handoffs between specialists", "plan-execute-verify cycle") is generic enough to be infrastructure. The specific metadata fields are infrastructure.
Infrastructure part: All frontmatter fields and their schema.
Domain-specific part: None -- the description is sufficiently generic.
Extraction approach: None needed.

### Section: Identity (lines 15-17)
Classification: INFRASTRUCTURE
Rationale: "You are Nefario, the orchestrator agent" -- generic orchestrator identity. "Decompose tasks, route them to the right minions, manage dependencies, return structured delegation plans" -- domain-independent orchestration description.

### Section: Core Rules (lines 19-22)
Classification: INFRASTRUCTURE
Rationale: "Follow the full process unless user explicitly asked not to" and "never skip gates" are domain-independent enforcement rules.

### Section: Invocation Modes (lines 24-44)
Classification: INFRASTRUCTURE
Rationale: META-PLAN, SYNTHESIS, PLAN modes and the Task tool fallback are orchestration mechanics. The advisory directive (lines 46-54) modifying output format is also generic.

### Section: Agent Team Roster (lines 58-104)
Classification: DOMAIN-SPECIFIC
Rationale: The entire 26-agent roster with group names, agent names, and one-line descriptions is specific to the software development domain. Groups like "Protocol & Integration Minions", "Infrastructure & Data Minions", "Development & Quality Minions", "Security & Observability Minions", "Design & Documentation Minions", "Web Quality Minions" are all software-specific.

### Section: Delegation Table (lines 106-199)
Classification: DOMAIN-SPECIFIC
Rationale: The full delegation table mapping task types to primary/supporting agents is entirely software-development-specific. Every row names software tasks (MCP server implementation, OAuth flows, REST API design, CI/CD pipelines, React component architecture, WCAG audit, SEO audit, etc.) and software agents.

### Section: External Skill Integration (lines 201-249)
Classification: INFRASTRUCTURE
Rationale: Skill discovery (.claude/skills/, .skills/), classification (ORCHESTRATION vs LEAF), precedence rules, deferral pattern -- all domain-independent mechanisms for composing external capabilities.

### Section: Task Decomposition Principles (lines 251-269)
Classification: MIXED
Rationale: The 100% rule, decomposition approach, dependency types are domain-independent. File-Domain Awareness (lines 269) references specific file types: AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md as "prompt engineering and multi-agent architecture artifacts" and routing through ai-modeling-minion. This is domain-specific routing guidance.
Infrastructure part: 100% rule, deliverable-based decomposition, file ownership, dependency types (sequential, parallel, coordination).
Domain-specific part: File-Domain Awareness paragraph naming specific file types and their routing to specific agents.
Extraction approach: File-domain routing rules move to adapter.

### Section: Cross-Cutting Concerns (lines 271-288)
Classification: DOMAIN-SPECIFIC
Rationale: The six mandatory dimensions (Testing, Security, Usability-Strategy, Usability-Design, Documentation, Observability) with their specific agent assignments and trigger conditions are software-development-specific. A regulatory compliance domain would have different cross-cutting concerns (e.g., audit trail, jurisdiction, data retention).

### Section: Approval Gates (lines 290-407)
Classification: MIXED
Rationale: The gate mechanics (classification matrix, decision brief format, response handling, anti-fatigue rules, cascading gates, gate vs notification distinction) are infrastructure. The classification examples (lines 312-315: "database schema design", "API contract definition", "CSS styling", "test file organization") are domain-specific.
Infrastructure part: Gate classification matrix (reversibility x blast radius), decision brief format (DECISION, DELIVERABLE, RATIONALE, IMPACT, Confidence), response handling (approve, request changes, reject, skip), anti-fatigue rules, cascading gate rules (dependency order, parallel independent, max 3 levels).
Domain-specific part: Examples of MUST-gate tasks ("database schema design, API contract definition, UX strategy recommendations, security threat model, data model design") and no-gate tasks ("CSS styling, test file organization, documentation formatting") at lines 312-315.
Extraction approach: Move examples to adapter. Keep the classification matrix and response handling as infrastructure.

### Section: Model Selection (lines 409-419)
Classification: DOMAIN-SPECIFIC
Rationale: The model assignments per phase reference specific agents: "code-review-minion on sonnet, lucy on opus, margo on opus" (Phase 5), "test-minion, software-docs-minion, user-docs-minion, product-marketing-minion on sonnet" (Phase 6-8). These are software-agent-specific assignments.

### Section: MODE: META-PLAN Working Pattern (lines 422-482)
Classification: MIXED
Rationale: The 5-step process and output format are generic. The cross-cutting checklist within the output (lines 448-453) names specific agents (test-minion, security-minion, ux-strategy-minion, ux-design-minion, accessibility-minion, software-docs-minion, user-docs-minion, observability-minion, sitespeed-minion) and specific dimensions.
Infrastructure part: The meta-plan process steps, output structure (Planning Consultations, Cross-Cutting Checklist, Anticipated Approval Gates, Rationale, Scope, External Skill Integration).
Domain-specific part: Cross-cutting checklist dimension names and agent assignments (lines 448-453).
Extraction approach: The checklist dimension list and agent assignments come from the adapter. The output template structure is infrastructure.

### Section: MODE: SYNTHESIS Working Pattern (lines 484-614)
Classification: MIXED
Rationale: The synthesis process (review contributions, resolve conflicts, incorporate risks, add agents, fill gaps, incorporate skills, return execution plan) is infrastructure. The output format's "Architecture Review Agents" section (lines 527-529) hardcodes mandatory reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo) and references "discretionary picks" -- domain-specific. The advisory output format (lines 563-614) is infrastructure (generic report structure).
Infrastructure part: Synthesis process steps, delegation plan output format (team name, description, task list with fields), conflict resolutions, risks/mitigations, execution order, external skills table, verification steps. Advisory report format.
Domain-specific part: Architecture Review Agents mandatory list (line 527), cross-cutting coverage section referencing "6 mandatory dimensions".
Extraction approach: Mandatory reviewer list from adapter. Dimension count derived from adapter's cross-cutting definition.

### Section: Architecture Review (Phase 3.5) definition in AGENT.md (lines 616-765)
Classification: MIXED
Rationale: The review mechanism description (triggering rules, verdict format, BLOCK resolution process, ARCHITECTURE.md template) is mostly infrastructure. The mandatory reviewer table (lines 629-637) names specific agents with domain-specific rationales. The discretionary reviewer table (lines 639-655) names specific agents with domain signals. The ADVISE/BLOCK examples use software concepts (OAuth, JWT, auth/callback.ts, HS256, RS256).
Infrastructure part: Review triggering concept, verdict format (APPROVE/ADVISE/BLOCK) with field specifications (SCOPE, CHANGE, WHY, TASK for ADVISE; SCOPE, ISSUE, RISK, SUGGESTION for BLOCK), self-containment requirements, BLOCK resolution process (2-round cap, all-reviewer re-review), ARCHITECTURE.md template structure.
Domain-specific part: Mandatory reviewer table (5 specific agents -- lines 629-637), discretionary reviewer table (5 specific agents with domain signals -- lines 639-655), model assignments (opus for lucy/margo, sonnet for others -- line 657), ADVISE/BLOCK examples using software concepts (lines 670-718).
Extraction approach: Reviewer tables (mandatory + discretionary with domain signals) move to adapter. Model assignments per reviewer move to adapter. Examples move to adapter. Verdict format schema stays as infrastructure.

### Section: MODE: PLAN (lines 770-780)
Classification: INFRASTRUCTURE
Rationale: "Combine meta-plan and synthesis into a single step" -- generic orchestration shortcut. Advisory variant reference is also generic.

### Section: Post-Execution Phases (5-8) summary in AGENT.md (lines 782-803)
Classification: DOMAIN-SPECIFIC
Rationale: The phase definitions name specific software activities and agents: Phase 5 (code review with code-review-minion, lucy, margo), Phase 6 (tests), Phase 7 (deployment), Phase 8 (documentation with software-docs-minion, user-docs-minion, product-marketing-minion). The awareness guidelines ("Test strategy does not need a dedicated execution task", "Documentation updates can be deferred to Phase 8", "Code quality review is handled by Phase 5") are software-specific.

### Section: Post-execution skip options (lines 800-803)
Classification: DOMAIN-SPECIFIC
Rationale: "Skip docs", "Skip tests", "Skip review" and their flags are software-specific skip options. A different domain would have different post-execution phases to skip.

### Section: Main Agent Mode (lines 805-812)
Classification: INFRASTRUCTURE
Rationale: Fallback to direct execution with Task tool. Domain-independent.

### Section: Conflict Resolution (lines 814-822)
Classification: INFRASTRUCTURE
Rationale: Resource contention, goal misalignment, hierarchical authority -- generic orchestration conflict resolution patterns.

### Section: Output Standards (lines 824-849)
Classification: MIXED
Rationale: Delegation plan structure (Scope, Task List, Agent Prompts, Success Criteria, Risk Assessment), status report structure, and final deliverable structure are mostly generic. "Verification Results: Test results, checks passed/failed" and "Execution Reports" reference are domain-influenced but generic enough.
Infrastructure part: Plan structure, status report structure, final deliverable structure.
Domain-specific part: Minimal -- "Test results" in verification results is a minor software reference.
Extraction approach: Not critical to extract. Can be parameterized if needed.

### Section: Boundaries (lines 851-870)
Classification: MIXED
Rationale: "What You Do" is generic orchestration. "What You Do NOT Do" names specific delegations: "Write code" (development minion), "Design systems" (design minion), "Make strategic technology decisions" (gru) -- these are software-specific delegation boundaries.
Infrastructure part: "What You Do" list (decompose, route, identify collaboration, return plans, synthesize, resolve conflicts, detect gaps).
Domain-specific part: "What You Do NOT Do" list naming specific agent roles and software activities.
Extraction approach: "What You Do NOT Do" is derived from the adapter's agent roster and their capabilities.

---

## Summary

### SKILL.md

| Classification | Section Count | Estimated Lines |
|---------------|--------------|-----------------|
| INFRASTRUCTURE | 8 | ~480 |
| DOMAIN-SPECIFIC | 2 | ~310 |
| MIXED | 11 | ~1540 |

### AGENT.md

| Classification | Section Count | Estimated Lines |
|---------------|--------------|-----------------|
| INFRASTRUCTURE | 7 | ~195 |
| DOMAIN-SPECIFIC | 6 | ~330 |
| MIXED | 7 | ~345 |

### Combined Totals

| Classification | Total Sections |
|---------------|---------------|
| INFRASTRUCTURE | 15 |
| DOMAIN-SPECIFIC | 8 |
| MIXED | 18 |

**Total sections analyzed**: 41

**Estimated domain-specific content volume**: ~640 lines of purely domain-specific content, plus ~400 lines of domain-specific parameters embedded within mixed sections. Total domain content to extract: ~1,040 lines across both files.

### Key Extraction Seams Identified

1. **Agent roster and delegation table** (AGENT.md lines 58-199): Largest single block of domain content (~140 lines). Clean extraction -- entire section is replaceable.

2. **Cross-cutting concerns and mandatory checklist** (AGENT.md lines 271-288): Six dimensions with agent assignments. Clean extraction -- list of dimensions with trigger rules.

3. **Mandatory/discretionary reviewer tables** (AGENT.md lines 629-655, SKILL.md lines 947-964): Two tables defining who reviews. Clean extraction -- parameterized by roster.

4. **Post-execution pipeline** (SKILL.md lines 1722-2006, AGENT.md lines 782-803): Largest complex extraction (~310 lines in SKILL.md). Defines phases 5-8 including file classification, test discovery, documentation outcome-action table, marketing tiers. The dark-kitchen pattern (infrastructure) wraps domain-specific phase definitions.

5. **Secret sanitization patterns** (SKILL.md line 381, scattered): Regex patterns for credential detection. Small but scattered across multiple locations.

6. **Phase name registry** (SKILL.md lines 140-156, 210-218): Phase names and numbers used throughout both files. A central registry would enable domain customization.

7. **Git/GitHub integration** (scattered): Branch naming, commit messages, PR creation, `gh` CLI usage. Spread across SKILL.md sections on argument parsing, Phase 4, and wrap-up.

8. **Gate classification examples** (AGENT.md lines 312-315): Software-specific examples of MUST-gate vs. no-gate tasks.

9. **Model selection per agent** (AGENT.md lines 409-419): Maps specific agents to model tiers by phase.

10. **Post-execution skip options** (SKILL.md lines 1636-1652): Phase skip labels and flags tied to software phases.
