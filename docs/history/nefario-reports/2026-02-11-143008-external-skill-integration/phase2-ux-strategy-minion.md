# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### 1. Cognitive Load Walk-Through: Install, Invoke, See CDD in Meta-Plan

I walked through the acceptance test scenario step by step, identifying every
decision point, uncertainty, and moment of potential confusion.

**Step 1: Install despicable-agents into a project with CDD skills.**

The user runs `./install.sh` from the despicable-agents repo. This installs 27
agents and 2 skills to `~/.claude/`. The CDD skills already live in the project's
`.skills/` directory. No conflict -- different namespaces (`~/.claude/agents/` vs
`.skills/`). No configuration merging. No naming collisions.

Cognitive load: LOW. Two independent installs, no interaction between them.
This is the right model -- keep it.

**Step 2: User invokes `/nefario 'build a new block'`.**

This is where the first confusion point emerges. The user's mental model is:
"CDD knows how to build blocks. Nefario knows how to orchestrate. I want both."
But the user does not know HOW nefario will discover CDD, or whether it will.
The critical question in the user's mind: **"Will this just work, or do I need
to do something?"**

Friction point: If the user has to manually tell nefario about CDD (e.g.,
"use the CDD skill"), the integration has failed. The JTBD is "orchestrate my
task using all available expertise" -- the user hired nefario to figure out WHO
can help, not to be told who can help.

**Recommendation: Discovery must be automatic and silent.** Nefario reads the
project's skill directories during Phase 1 (meta-plan) the same way it reads
CLAUDE.md and codebase files. No user action required. If CDD is present,
nefario sees it. If it is not present, nothing changes.

**Step 3: Meta-plan output references CDD.**

The user sees the CONDENSE line: `Planning: consulting devx-minion,
content-driven-development skill, ...`. This is the moment of truth.

Friction point: The user sees an unfamiliar entity in the planning list. Today,
the meta-plan only lists despicable-agents specialists (named agents with known
roles). An external skill appearing in that list creates a recognition problem:
"Is content-driven-development an agent or a skill? Why is it different from
the other names?"

**Recommendation: Use a consistent but visually distinct label.** In the CONDENSE
line, external skills should appear with a suffix that makes them scannable but
not alarming: `content-driven-development (project skill)` vs. `devx-minion`.
The parenthetical "(project skill)" is enough to answer "what is this?" without
demanding attention. Do NOT use different formatting (bold, brackets, icons) --
that creates a visual hierarchy problem where the external skill draws more
attention than the specialists.

**Step 4: Execution plan shows CDD deferral.**

The approved plan shows a task like:
```
3. Build block using CDD workflow     [content-driven-development, sonnet]
   Produces: block implementation via CDD phases
   Depends on: Task 2
```

Friction point: The user may wonder "will nefario's phases conflict with CDD's
phases?" This is the deepest confusion risk: two orchestrators, potentially
two sets of phases, potentially two approval flows.

**Recommendation: Make the deferral relationship explicit in the plan.** The task
description should say something like: "Follow the content-driven-development
skill's phased workflow (Content Discovery, Implementation, Validation). Nefario
coordinates pre-work and post-work; CDD owns the implementation sequence." This
tells the user: nefario knows CDD has a process and is respecting it. One
sentence eliminates the "two orchestrators fighting" anxiety.

### 2. How Nefario Should Present Delegation Decisions Involving External Skills

The execution plan approval gate (the main thing users read carefully) needs to
handle three scenarios with external skills:

**Scenario A: External skill replaces a specialist entirely.**
Example: CDD's building-blocks skill replaces frontend-minion for block work.

Presentation: Show the task as assigned to the external skill. Do NOT show
the specialist it replaced. The user does not care about the routing decision --
they care about the outcome. Add a one-line note in the ADVISORIES section:
```
ADVISORIES:
  [delegation] Task 3: Build hero block
    CHANGE: Assigned to building-blocks (project skill) instead of frontend-minion
    WHY: Project has a domain-specific skill for block development
```

This uses the existing advisory delta format. The user sees that a routing
decision was made, can understand why, and can override it if needed.

**Scenario B: External orchestration skill subsumes multiple tasks.**
Example: CDD's phased workflow replaces what would have been 3 separate tasks
(content model, implementation, testing).

Presentation: Show it as a single task with sub-phases visible but collapsed.
The plan should show:
```
3. Build block (CDD workflow)                [content-driven-development, sonnet]
   Produces: content model, block implementation, test validation
   Phases: Content Discovery -> Implementation -> Validation
   Depends on: Task 2
```

The "Phases:" line is new -- only shown for external orchestration skills. It
tells the user what will happen inside this task without requiring them to know
CDD's internals. This is progressive disclosure: the phase names are visible,
but the details are in the skill's SKILL.md, not in the plan.

**Scenario C: Hybrid -- some work defers to external skill, some to specialists.**
Example: CDD handles block building, but security-minion reviews the code and
software-docs-minion updates architecture docs.

Presentation: Show the CDD task and the specialist tasks as separate items in
the normal task list with normal dependency relationships. The user already
understands the task list format. No special treatment needed beyond the
"(project skill)" suffix on the CDD task.

**Key principle: Do not invent new UI patterns for external skills.** The
existing task list, advisory, and gate formats are sufficient. External skills
should fit into the existing presentation, not create a parallel presentation.
Every new visual pattern is a cognitive tax. Reuse what works.

### 3. Recovery Path When Integration Fails Silently

Silent failure is the most dangerous UX scenario. If nefario cannot detect CDD
and routes block-building to frontend-minion instead, the user gets a working
plan that produces inferior results. The user may not even realize the failure
until they see the output lacks CDD's content-first workflow.

**Three failure modes and recovery paths:**

**Failure 1: Nefario does not discover the external skill.**
Cause: Skill is in an unexpected directory, or discovery scan misses it.
User symptom: The plan uses internal specialists for work the external skill
should handle. The user thinks "why isn't it using CDD?"

Recovery: The user should be able to say "use the CDD skill for block building"
during the "Request changes" flow at the plan approval gate. Nefario should
then re-scan and, if found, incorporate it. If not found, nefario should say
"I could not find a skill named 'CDD' or 'content-driven-development' in
[list of directories scanned]." This gives the user a concrete diagnostic.

**Recommendation: Include discovered skills in the meta-plan output.** Add a
"Discovered project skills" section to the phase 1 scratch file (not the
CONDENSE line -- too noisy for the happy path). The user can check the scratch
file if they suspect a skill was missed. Example:
```
### Discovered Project Skills
- content-driven-development (.skills/content-driven-development/)
- building-blocks (.skills/building-blocks/)
- testing-blocks (.skills/testing-blocks/)
- 12 more skills in .skills/
```

**Failure 2: Nefario discovers the skill but misclassifies it.**
Cause: Nefario treats an orchestration skill as a leaf skill, or vice versa.
User symptom: The plan has CDD as a simple "invoke this" step without
respecting its phased workflow, or CDD gets full orchestration deferral when
it should have been a simple invocation.

Recovery: Same path -- "Request changes" at the approval gate. The user says
"CDD has its own phased workflow, defer to it." This is acceptable because
misclassification should be rare if the detection heuristic is reasonable.

**Recommendation: Do NOT build a complex classification system.** Use a simple
heuristic: if a SKILL.md contains phase/step language and invokes other skills,
treat it as an orchestration skill. If the heuristic is wrong, the user
corrects it once at the approval gate. Building an elaborate classification
taxonomy is over-engineering for a problem that manifests rarely and is easily
corrected by the human.

**Failure 3: External skill invocation fails during execution.**
Cause: Skill has runtime dependencies (scripts, tools) not present, or the
skill's workflow expects user interaction that does not translate to subagent
context.

Recovery: This should surface as a normal task failure during Phase 4, handled
by the existing BLOCK escalation path. The key UX requirement: the error
message should name the external skill and its failure point, not just show a
generic "task failed" message.

**Recommendation: When an execution task using an external skill fails, the
escalation brief should include the skill name and the phase within the skill
where failure occurred.** Example: "Task 3 (content-driven-development, Phase 1:
Content Discovery) failed: script find-block-content.js not found."

### 4. Simplification Audit: What We Should NOT Build

Applying the Kano model and YAGNI principle, here is what I recommend removing
from scope or deferring:

**DO NOT BUILD: A skill registry or catalog mechanism.**
The meta-plan mentions "SKILL.md conventions for interop signaling." This
sounds like it could become a metadata schema that external skills must adopt.
Do not build this. External skills have their own conventions. Nefario should
read what is already there (name, description in frontmatter, and the markdown
body) and infer what it needs. Any metadata requirements imposed on external
skills are coupling in disguise.

Kano classification: Indifferent. Users do not care about metadata schemas.
They care about "does nefario find and use my skills?" A registry adds
maintenance burden to skill authors with zero user-perceived benefit.

**DO NOT BUILD: Explicit precedence configuration.**
The issue mentions "define precedence rules when external skills and
despicable-agents specialists cover the same domain." Do not build a
configurable precedence system (e.g., a YAML file mapping domains to preferred
skills). Instead, apply one simple rule: **project-local skills take precedence
over global specialists for domain-specific work.** This matches the user's
mental model (my project's skills know my project better than generic
specialists) and requires zero configuration.

If this heuristic is wrong in a specific case, the user overrides it at the
approval gate. One simple rule + override > configurable system.

Kano classification: The precedence heuristic is Must-be (it must exist or
routing is broken). The configuration UI for precedence is Reverse -- it
adds complexity that frustrates users who just want things to work.

**DO NOT BUILD: A "skill compatibility" checker or validator.**
Do not build a tool that checks whether external skills are "compatible" with
nefario. Compatibility is a spectrum, not a binary. Nefario either discovers
and uses a skill or it does not. Validation tooling creates a false sense of
certification and implies a coupling contract.

Kano classification: Indifferent to Reverse. Skill authors do not want to
run a validator. Users do not care about compatibility scores.

**DO NOT BUILD: Changes to install.sh for external skills.**
The install script should not touch, discover, or register external skills.
External skills are managed by their own distribution mechanism (gh upskill,
manual clone, etc.). Nefario discovers them at runtime. Install.sh stays
focused on despicable-agents only.

Kano classification: Reverse. Mixing install concerns creates a confusing
single-responsibility violation. "Why is despicable-agents touching my
project's skills?" is a trust-destroying question.

**DO NOT BUILD: Bidirectional integration documentation.**
The meta-plan mentions documentation for "I'm offering skills that should work
with orchestrators like this." I recommend making this extremely lightweight --
a single section in the existing docs, not a standalone guide. External skill
authors need to know one thing: "If your SKILL.md has a name, description, and
describes a workflow, nefario can discover and delegate to it. No changes
needed." That is one paragraph, not a document.

Kano classification: The one-paragraph explanation is Must-be (skill authors
need to know nefario exists and what it looks for). A comprehensive integration
guide is Indifferent (skill authors will not read it because they do not need
to change anything).

**DEFER: MCP server routing awareness.**
Already marked out of scope in the issue. Confirmed: this is the right call.
Adding MCP awareness to the discovery mechanism adds a completely different
trust model and invocation pattern. Keep the scope to SKILL.md-based discovery
only.

**DEFER: Automated testing of the integration.**
The acceptance test scenario is a manual walkthrough, not an automated test.
Do not build test infrastructure for verifying skill discovery. The feature's
correctness is observable by the user at the approval gate (they can see
whether CDD was included). Automated testing of prompt-based orchestration
decisions is inherently fragile and adds maintenance burden disproportionate
to value.

### Summary of Recommended Approach

The entire integration should feel like one idea: **Nefario reads your project's
skills the same way it reads your project's code -- automatically, at planning
time, and incorporates what it finds into the plan.**

This maps to the user's existing mental model of how nefario works (it reads
my codebase and figures out what to do). Extending "reads my codebase" to
"reads my skills" is a natural, zero-learning-curve extension.

The presentation should reuse every existing pattern (task list, advisories,
gates, CONDENSE lines) with minimal additions (a "(project skill)" suffix and
an optional "Phases:" line for orchestration skills). No new UI concepts, no
new approval flows, no new configuration files.

## Proposed Tasks

### Task 1: Define discovery behavior in nefario AGENT.md
**What**: Add a section to nefario's META-PLAN working pattern that instructs
nefario to scan project skill directories (`.skills/`, `.claude/skills/`) during
Phase 1, read SKILL.md frontmatter and body, and include relevant skills in the
meta-plan alongside specialists.

**Deliverables**: Updated nefario/AGENT.md with discovery instructions.

**Dependencies**: Depends on devx-minion's discovery mechanism design (need to
know exactly which directories and what parsing approach).

### Task 2: Define deferral heuristic
**What**: Add a simple classification rule to nefario's synthesis logic: if an
external skill describes a multi-phase workflow and invokes other skills, treat
it as an orchestration skill and defer to its workflow for relevant tasks.
One-paragraph addition to the SYNTHESIS mode instructions.

**Deliverables**: Updated nefario/AGENT.md with deferral heuristic.

**Dependencies**: Depends on ai-modeling-minion's deferral mechanism design.
Must be simple enough to explain in one sentence.

### Task 3: Update execution plan presentation for external skills
**What**: Add the "(project skill)" suffix convention and optional "Phases:"
line to SKILL.md's execution plan approval gate format. Add the advisory
template for delegation routing decisions. Add "Discovered project skills"
section to the phase 1 scratch file template.

**Deliverables**: Updated skills/nefario/SKILL.md.

**Dependencies**: Tasks 1 and 2 (presentation follows from discovery and
deferral design decisions).

### Task 4: Document the integration surface
**What**: Add a section to `docs/using-nefario.md` covering: "Working with
Project Skills" -- one section explaining that nefario auto-discovers project
skills, how they appear in plans, and how to override routing decisions. Add a
brief note to `docs/architecture.md` that external skill discovery is part of
the meta-plan phase.

For skill maintainers: add one paragraph to the architecture doc explaining
what nefario looks for in SKILL.md (name, description, workflow structure).
This is NOT a separate document.

**Deliverables**: Updated docs/using-nefario.md, updated docs/architecture.md.

**Dependencies**: Tasks 1-3 (document what was built).

## Risks and Concerns

### Risk 1: Feature creep toward a "skill framework"
**Severity**: HIGH
**Description**: The integration surface could grow from "nefario reads skills"
to "nefario manages skills" -- a skill registry, compatibility checks, version
management, dependency resolution. Each addition feels small but collectively
they create a framework that external skill authors must learn and maintain.
**Mitigation**: Apply the one-agent rule (Decision 27): do not build
infrastructure for patterns until 2+ real use cases demand it. The CDD
integration is use case #1. Build for it, validate with it, and resist
generalizing until a second skill ecosystem emerges with different needs.

### Risk 2: Two orchestrators create confusion
**Severity**: MEDIUM
**Description**: When nefario defers to CDD, the user is under two
orchestration regimes simultaneously. If CDD asks the user a question
(e.g., "Does content already exist?") while nefario is managing gates,
the interaction models could conflict.
**Mitigation**: The deferral should be complete for the deferred task. While
CDD is running its phases, nefario is waiting. Nefario's gates happen before
and after the CDD task, not during it. The user interacts with one orchestrator
at a time.

### Risk 3: Silent misrouting goes undetected
**Severity**: MEDIUM
**Description**: Nefario routes work to an internal specialist when an external
skill would have been better, and the user does not notice until the output is
suboptimal.
**Mitigation**: The "Discovered project skills" list in the scratch file gives
users a diagnostic tool. The advisory format for routing decisions makes
delegation visible. But ultimately, the user must review the plan -- this is
an inherent property of any routing system.

### Risk 4: External skills with interactive workflows break in subagent context
**Severity**: MEDIUM
**Description**: CDD's workflow includes "Ask the user" steps. When invoked as
a subagent task, the user interaction model may differ (messages go to team
lead, not directly to user). This could cause CDD to hang waiting for input
or produce unexpected interaction patterns.
**Mitigation**: This is an execution-time concern, not a planning concern. The
task prompt for the CDD-deferred task should include a note about the
interaction context: "You are running as a subagent. User interactions go
through the team lead. Proceed with reasonable defaults where possible and
escalate blocking questions."

## Additional Agents Needed

None. The five-agent planning team (devx-minion, ai-modeling-minion,
software-docs-minion, ux-strategy-minion, security-minion) covers the necessary
perspectives. The governance reviewers (lucy, margo) will review in Phase 3.5
as usual. Product-marketing-minion is not needed -- this feature is an internal
mechanism, not a user-facing capability that changes the project's positioning.
