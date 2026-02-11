# Domain Plan Contribution: software-docs-minion

## Recommendations

### 1. The Documentation Must Reflect Two Audiences, Not One

The current documentation speaks to a single audience: contributors working
on the despicable-agents repo. The decoupled toolkit serves two distinct audiences:

- **Toolkit users**: Developers who install despicable-agents to use it on their
  own projects. They need: installation, configuration, usage patterns, what to
  expect in their project (reports, branches, scratch files).
- **Toolkit contributors**: Developers who work on despicable-agents itself. They
  need: architecture docs, build pipeline, overlay system, design decisions.

Every document must be evaluated against the question: "Who is this for?"
Documents that conflate both audiences must be split or restructured.

### 2. Documentation Inventory and Classification

After reading all documentation files, here is the classification of each
document by audience and what needs to change:

| Document | Current Audience | Target Audience | Change Needed |
|----------|-----------------|-----------------|---------------|
| README.md / CLAUDE.md | Contributor | Both | Major restructure |
| docs/deployment.md | Contributor | Both | Rewrite to cover toolkit installation for users |
| docs/orchestration.md | Contributor | Contributor | Minor -- remove hardcoded paths in examples |
| docs/using-nefario.md | User | User | Minor -- add note about external project usage |
| docs/architecture.md | Contributor | Contributor | Minor -- update system context to show external project pattern |
| docs/agent-anatomy.md | Contributor | Contributor | None |
| docs/build-pipeline.md | Contributor | Contributor | None |
| docs/decisions.md | Contributor | Contributor | Add decision for the decoupling itself |
| docs/compaction-strategy.md | Contributor | Contributor | Update scratch path references |
| docs/commit-workflow.md | Contributor | Contributor | Update branch naming if it changes |
| TEMPLATE.md | Both | Both | Parameterize report path, add external project guidance |
| docs/agent-catalog.md | User | User | None |

### 3. README Must Become the Toolkit Front Door

The current README is a developer-facing project summary. It must be restructured
as the front door for toolkit users. The critical gap: there is no "I cloned this
repo, now how do I use it on my project?" path.

Proposed README structure:

```
# despicable-agents

One-paragraph description: what it is, who it is for.

## Quick Start
1. Clone
2. Run install.sh
3. Use /nefario on your project

## What You Get
- 27 specialist agents (link to catalog)
- Nefario orchestrator (link to using-nefario)
- Despicable-prompter briefing coach

## Using on Your Project
What happens in your project when you invoke /nefario:
- Reports go to <report-path> in YOUR project
- Branches are created in YOUR repo
- Scratch files go to <scratch-location>

## Developing despicable-agents Itself
Link to docs/architecture.md for contributors.

## Key Rules
(existing content, compressed)

## License
```

The key insight: "What happens in YOUR project" is the section that does not
exist today and is the most important section for toolkit users.

### 4. CLAUDE.md Needs a Toolkit Layer vs. Project Layer Split

The current CLAUDE.md is a single file mixing toolkit-level instructions
(engineering philosophy, agent boundaries) with project-specific instructions
(do not modify the-plan.md, versioning, orchestration reports). These serve
different purposes:

- **Toolkit-level instructions**: Apply when any agent operates on any project.
  These are baked into agent system prompts and do not need to be in CLAUDE.md.
- **Project-level instructions**: Apply only when working on despicable-agents.
  These belong in the project CLAUDE.md.

After decoupling, the despicable-agents CLAUDE.md should contain ONLY
project-specific instructions for working on this repo. Toolkit-level guidance
lives in agent prompts (already the case) and user-facing docs (README,
using-nefario.md).

Current CLAUDE.md sections and their classification:

| Section | Classification | Action |
|---------|---------------|--------|
| Structure | Project-specific | Keep |
| Key Rules | Project-specific | Keep |
| Engineering Philosophy | Both (but agents already embed this) | Keep for contributors |
| Versioning | Project-specific | Keep |
| Deployment | Project-specific | Keep, update to mention toolkit usage |
| Orchestration Reports | Needs split | The instruction to generate reports is SKILL.md's job; the path should be cwd-relative |

The Orchestration Reports section in CLAUDE.md currently says reports go to
`docs/history/nefario-reports/TEMPLATE.md`. This is fine as a project-specific
instruction because when an agent is working on despicable-agents, that is
where reports go. The SKILL.md is what needs to be path-agnostic, not the
project CLAUDE.md.

### 5. docs/deployment.md Must Cover Two Installation Stories

Currently, deployment.md describes one story: "how agents get from this repo
to ~/.claude/agents/". The decoupled toolkit needs two stories:

**Story 1 (existing, rename to "Development")**: Working on despicable-agents
itself -- symlinks, instant updates, version control benefits.

**Story 2 (new, "Installing the Toolkit")**: Using despicable-agents on other
projects -- clone, run install.sh, what gets installed where, what to expect.
This section answers: "I installed it, now what shows up in my project when I
use it?"

The hook deployment section needs careful treatment. Currently hooks are
project-local to despicable-agents. The decision about whether hooks are part
of the toolkit installation or remain project-local will determine whether
deployment.md needs a hooks section for toolkit users.

### 6. docs/orchestration.md Needs Path Parameterization in Examples

orchestration.md has 4 hardcoded path references that assume the target is
despicable-agents:

1. Section 4 "Report Location and Naming": `docs/history/nefario-reports/<YYYY-MM-DD>-<HHMMSS>-<slug>.md`
2. Section 4 "Index": `docs/history/nefario-reports/index.md`
3. Section 4 "When Reports Are Generated": `docs/history/nefario-reports/`
4. Section 5 "Feature Branch Creation": `nefario/<slug>` and `agent/<name>/<slug>`

These are architectural descriptions, not operational instructions (SKILL.md
handles the operational paths). The fix is to describe the paths as cwd-relative
conventions rather than absolute paths within despicable-agents. For example:

- Current: "Reports are written to `docs/history/nefario-reports/`"
- Updated: "Reports are written to `docs/history/nefario-reports/` in the target project's repository"

This is a wording change, not a structural change. The section about CI
(build-index.sh, GitHub Actions) should note that CI is specific to projects
that choose to adopt it -- it is not automatic.

### 7. Report Template Needs Minimal Changes

The TEMPLATE.md itself is mostly path-agnostic already. The only self-referential
element is the implicit assumption that `docs/history/nefario-reports/` exists.
The SKILL.md handles directory creation with `mkdir -p`, so the template does
not need to change structurally.

However, the template should add a brief note in the File Naming Convention
section clarifying that the report directory is relative to the target project
root, not the despicable-agents repo. One sentence addition.

### 8. docs/compaction-strategy.md Scratch Path Reference

Section 2 "Directory Structure" shows `nefario/scratch/{slug}/` as the scratch
directory. If the scratch directory location changes (e.g., to a temp directory
outside the project), this document needs to reflect that. The change depends
on the path resolution strategy from devx-minion's contribution.

### 9. What the Toolkit Should Generate in External Projects

When nefario operates on an external project, it should NOT bootstrap heavy
infrastructure. The principle is minimal footprint -- only create what is
needed for the current operation:

**Always created (by SKILL.md mkdir -p)**:
- Scratch directory (wherever it is resolved to)
- Report directory (wherever it is resolved to)

**Never auto-created**:
- CI workflows (user opt-in, provide a template they can copy)
- build-index.sh (user opt-in)
- .claude/hooks/ (user opt-in -- but document how to adopt them)
- .claude/settings.json (user must configure this themselves)

**Consider creating on first nefario run**:
- A brief `.nefario-reports/README.md` or header comment in the first report
  explaining what this directory is, why it exists, and how to use it. This
  is important because a developer encountering `docs/history/nefario-reports/`
  in their project for the first time needs context. A 5-line README serves
  this purpose.

This "first-run README" is the only bootstrapping artifact I recommend. It
costs nothing, explains itself, and prevents confusion.

### 10. docs/architecture.md System Context Update

The C4 Context diagram currently shows:

```
System_Ext(codebase, "Target Codebase", "Project being developed")
```

This is already correct -- it already treats the target codebase as external.
The diagram does not need to change. However, the opening paragraph says
"despicable-agents is a specialist agent team for Claude Code" without
mentioning the "operates on any project" model. One sentence addition:
"The team operates on any project via Claude Code -- agents and skills are
installed globally and invoked from the target project's working directory."

## Proposed Tasks

### Task D1: Restructure README.md as Toolkit Front Door

**What**: Rewrite README.md to serve toolkit users as the primary audience
while preserving contributor paths. Add "Quick Start", "What You Get", "Using
on Your Project" sections. Move contributor details behind a link to
docs/architecture.md.

**Deliverables**: Updated `README.md`

**Dependencies**: Depends on devx-minion's path resolution strategy (Task D1
needs to know where reports and scratch files go to write the "Using on Your
Project" section). Also depends on the install.sh packaging decision (to
accurately describe the Quick Start).

### Task D2: Rewrite docs/deployment.md for Two Installation Stories

**What**: Add a "Installing the Toolkit" section describing the user-facing
installation story. Rename the existing symlink content to "Development
Workflow" or similar. If hooks become part of the global install, add a hooks
section for toolkit users.

**Deliverables**: Updated `docs/deployment.md`

**Dependencies**: Depends on devx-minion's packaging model (what install.sh
installs). Depends on the hook packaging decision.

### Task D3: Update Path References Across Documentation

**What**: Update hardcoded self-referential paths in docs/orchestration.md,
docs/compaction-strategy.md, and docs/history/nefario-reports/TEMPLATE.md to
use cwd-relative language. Add "in the target project's repository" qualifiers
where needed. Update docs/architecture.md opening paragraph.

**Deliverables**: Updated `docs/orchestration.md`, `docs/compaction-strategy.md`,
`docs/history/nefario-reports/TEMPLATE.md`, `docs/architecture.md`

**Dependencies**: Depends on devx-minion's path resolution strategy (if scratch
paths change, compaction-strategy.md references change too). This task can
partially proceed in parallel -- the orchestration.md and architecture.md
changes are independent of the path decision.

### Task D4: Add First-Run README for Report Directory

**What**: Create a brief README template (5-10 lines) that the SKILL.md writes
to the report directory on first use. Explains what the directory is, what
reports contain, and links to the despicable-agents docs for the full report
format specification.

**Deliverables**: A README template string embedded in SKILL.md (or a separate
template file if the team prefers). The template is written to
`<report-dir>/README.md` only when the directory is first created.

**Dependencies**: Depends on devx-minion's path resolution strategy (where is
the report directory?).

### Task D5: Update docs/using-nefario.md for External Project Context

**What**: Add a brief section to using-nefario.md clarifying that nefario
operates on whichever project the user's working directory is in. Mention
that reports, branches, and commits target the cwd project. Add one example
showing invocation from an external project.

**Deliverables**: Updated `docs/using-nefario.md`

**Dependencies**: None. This is additive and can run in parallel with all
other tasks.

### Task D6: Add Design Decision for the Decoupling

**What**: Add a new decision entry to docs/decisions.md documenting the
"Decouple self-referential assumptions" architectural decision. Capture the
two-mode model (self-evolution vs. external project), the path resolution
strategy chosen, the packaging model, and rejected alternatives.

**Deliverables**: Updated `docs/decisions.md`

**Dependencies**: Depends on ALL other tasks completing, since this decision
documents the final outcome. Should be one of the last tasks in the plan.

## Risks and Concerns

### Risk 1: Documentation-Implementation Drift During Execution

Multiple documentation files reference paths and behaviors that will change
during this task. If implementation tasks (SKILL.md changes, install.sh
changes) and documentation tasks execute in parallel, the documentation may
describe the old behavior or the wrong new behavior.

**Mitigation**: Documentation tasks (D1-D5) should execute AFTER the
implementation tasks that change the paths and packaging. Task D6 (the design
decision) should be last. The exception is Task D5 (using-nefario.md) which
is additive and safe to run in parallel.

### Risk 2: Over-Documentation of the Toolkit Model

There is a risk of creating extensive "how to use the toolkit" documentation
that duplicates what the README and using-nefario.md already cover. The
principle of minimal documentation applies: toolkit users need to know (a)
how to install, (b) what happens in their project, and (c) where to go for
more. They do not need a separate "Toolkit User Guide".

**Mitigation**: No new documentation files. All changes are updates to
existing documents. The README and using-nefario.md are the two user-facing
entry points. Everything else is contributor-facing.

### Risk 3: Stale Cross-References Between Documents

The docs/ directory has extensive cross-references (architecture.md links to
orchestration.md, deployment.md, etc.). If documents are restructured, links
may break.

**Mitigation**: After all documentation tasks complete, run a link check
across all Markdown files in docs/. This can be a simple grep for relative
links and verification that targets exist.

### Risk 4: First-Run README May Feel Intrusive

Writing a README.md into the user's project on first nefario run could feel
like the toolkit is "polluting" the project. Some users may not want toolkit
artifacts in their repo.

**Mitigation**: Keep the README extremely brief (5-10 lines). Only create it
when the report directory is first created (not on every run). Consider making
it a commented header in the first report instead of a separate file, if the
team feels a separate file is too intrusive.

## Additional Agents Needed

**user-docs-minion**: If the decoupling produces any user-facing behavioral
changes (new CLI flags, new installation steps, changed default behaviors),
user-docs-minion should review the using-nefario.md and README changes for
clarity and task-orientation. This is a review role, not a planning role -- the
Phase 3.5 architecture review will cover it if user-docs-minion is triggered
as a conditional reviewer.

Otherwise, none. The current planning team (devx-minion, ux-strategy-minion,
test-minion, software-docs-minion) covers all the documentation dimensions.
The implementation does not require documentation specialists beyond what is
already planned.
