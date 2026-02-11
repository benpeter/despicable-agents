# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### 1. Detecting Orchestration Skills vs. Leaf Skills

The fundamental distinction is: does the external skill define a **multi-step workflow
with sequencing constraints**, or does it expose a **single capability**?

**Heuristic detection approach (content-signal-based, no mandatory metadata):**

During Phase 1 meta-plan, nefario should scan discovered external SKILL.md files and
classify them using content signals. This is a lightweight LLM classification task --
nefario reads the SKILL.md content and applies these heuristics:

| Signal | Weight | Orchestration | Leaf |
|--------|--------|---------------|------|
| Multiple named phases/steps with ordering (e.g., "Phase 1... Phase 2..." or "Step 1: Discovery, Step 2: Build") | Strong | Yes | -- |
| References to other skills it invokes (e.g., "Related Skills" section, `/skill-name` invocations in body) | Strong | Yes | -- |
| Conditional branching ("if X, do Y; otherwise Z") | Moderate | Yes | -- |
| Produces multiple deliverables across different files/domains | Moderate | Yes | -- |
| Single action with clear input/output | Strong | -- | Yes |
| No internal sequencing (all instructions are one-pass) | Moderate | -- | Yes |
| `context: fork` in frontmatter (runs in isolation) | Moderate | -- | Yes |

**Do NOT require external skills to add despicable-agents-specific metadata** like
`x-orchestration: true`. This violates the loose coupling requirement. The detection
must work on vanilla SKILL.md files that know nothing about nefario.

**Classification output** (internal to nefario, not shown to user):

```
External Skill: content-driven-development
Classification: ORCHESTRATION
Confidence: HIGH
Signals: 5 named phases with ordering, invokes 2 sub-skills, conditional branching
Domain overlap: frontend-minion (block implementation), ux-design-minion (design)
```

**Cost note:** This classification happens once per nefario session during Phase 1.
The SKILL.md content is already loaded by Claude Code's progressive disclosure. Nefario
reads the full content only for skills whose description matches the task domain. For
a typical project with 3-8 external skills, this adds ~2K-5K input tokens to the
meta-plan phase -- negligible versus the Phase 2 specialist consultations.

**Optional enhancement (not required for v1):** External skill authors who want to
improve detection accuracy can add a `workflow` or `phases` field to their YAML
frontmatter. Nefario checks for this first (fast path) and falls back to content
heuristics. This is strictly optional and additive -- vanilla skills work without it.

### 2. Precedence Rules

The precedence model has three tiers, applied in order:

**Tier 1 -- Explicit project preference (highest priority):**
If the project's `CLAUDE.md` or `.claude/settings.json` declares skill preferences,
those win unconditionally. Example:

```markdown
# CLAUDE.md
When building blocks, use the content-driven-development skill workflow.
```

This is how the user expresses "I chose this skill for this domain." Nefario should
scan the project CLAUDE.md during meta-plan for such declarations. No new format
needed -- natural language declarations that Claude already understands are sufficient.

**Tier 2 -- Project-local over global:**
A skill installed in the project's `.claude/skills/` or `.skills/` takes precedence
over a global skill in `~/.claude/skills/` for the same domain. This follows Claude
Code's own precedence (project > personal) and the intuition that project-specific
tools were chosen deliberately for that project.

**Tier 3 -- Specificity over generality:**
When an external skill and an internal specialist overlap, the more domain-specific
one wins for its specific domain:

- External `content-driven-development` skill covers AEM block building with deep
  domain knowledge -> it wins over `frontend-minion` for block-building tasks.
- Internal `security-minion` covers security review generically -> it wins for
  security review even within a CDD workflow, because CDD likely has no security
  review phase.

The key insight: **specificity is measured per sub-task, not per overall task.**
A single user request ("build a new block") may decompose into sub-tasks where
different specificity winners apply.

**Conflict resolution when both are equally specific:**
If nefario cannot determine which is more specific (rare), it should **present the
choice at the execution plan approval gate**, not silently pick one. This is a
legitimate ambiguity that the user should resolve. Format:

```
TASKS:
  1. Build hero block                              [external: CDD]
     Alternative: frontend-minion (despicable-agents internal)
     Nefario recommends: CDD (project-local, domain-specific workflow)
```

### 3. Delegation Plan Structure for Deferral

When nefario defers to an external orchestration skill, the delegation plan models it
as a **single macro-task** that wraps the external workflow. Nefario does not decompose
the external skill's internal phases -- that is the external skill's job.

**Delegation plan entry for a deferred task:**

```markdown
### Task 1: Build hero block (deferred to CDD)
- **Agent**: main-session (skill invocation)
- **Skill**: content-driven-development
- **Model**: per skill default
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes (the external skill's output is reviewed before dependents)
- **Gate reason**: External orchestration -- review CDD's deliverables before
  despicable-agents post-processing
- **Delegation type**: DEFERRED
- **Prompt**: |
    Invoke the content-driven-development skill for the following task:
    "Build a hero block with headline, image, and CTA."

    After CDD completes, report:
    - Files created/modified (paths and change scope)
    - Which CDD phases executed
    - Any CDD-internal decisions that were made

    Do NOT override CDD's workflow phases. Follow CDD's phased process
    as defined in its SKILL.md.
- **Deliverables**: Block implementation per CDD's output
- **Success criteria**: CDD workflow completes, block renders correctly
```

**Key design decisions in this structure:**

1. **`Delegation type: DEFERRED`** -- New field that signals to the orchestrator that
   this task runs an external workflow, not a despicable-agents specialist. The
   orchestrator tracks it differently: it does not send mid-task messages, does not
   apply file ownership rules to the external skill's output, and does not attempt
   to decompose the task further.

2. **Gate after deferral** -- Even though nefario defers the work, it still gates the
   output. This is critical: nefario is responsible for the overall quality of the
   orchestrated session. The gate reviews what the external skill produced, not how
   it produced it.

3. **Invocation mechanism** -- The deferred task is invoked via `/skill-name` in the
   main session context (or via the Skill tool if running as a subagent). This uses
   Claude Code's native skill invocation, which already handles skill loading,
   argument passing, and context management. Nefario does not need to reimplement
   any of this.

4. **Phase 3.5 still applies** -- Work produced by the deferred task goes through
   Phase 3.5 architecture review and Phase 5 code review like any other task output.
   The external skill handles the "how to build it" workflow; despicable-agents
   handles the "is it safe, tested, documented, and aligned" review.

### 4. Hybrid Scenarios: Partial Deferral

The most common hybrid pattern is: external skill handles domain-specific work,
despicable-agents handles cross-cutting concerns. The acceptance test scenario is
exactly this: CDD handles block building, despicable-agents handles security review.

**Design the delegation plan as a mixed task list:**

```markdown
### Task 1: Build hero block (deferred to CDD)
- Delegation type: DEFERRED
- ...

### Task 2: Security review of hero block
- Agent: security-minion
- Blocked by: Task 1
- Delegation type: INTERNAL
- Prompt: |
    Review the block implementation produced by the CDD workflow in Task 1.
    Focus on: XSS vectors in block HTML, CSP compliance, input sanitization...

### Task 3: Accessibility review of hero block
- Agent: accessibility-minion
- Blocked by: Task 1
- Delegation type: INTERNAL
- ...
```

**The rule for hybrid decomposition:** Nefario defers the *primary domain work* to
the external orchestration skill and sequences *cross-cutting review tasks* after it.
The cross-cutting tasks always come from despicable-agents specialists because:

1. External skills typically lack security/accessibility/observability phases.
2. Despicable-agents' cross-cutting checklist is mandatory and cannot be delegated away.
3. The external skill's output is treated as "execution output" that flows into
   nefario's post-execution phases (5-8) normally.

**What nefario should NOT do in hybrid scenarios:**

- Do NOT inject despicable-agents phases into the external skill's workflow. If CDD
  has phases 1-5, nefario does not insert "Phase 2.5: security check" into CDD's flow.
- Do NOT run despicable-agents specialists in parallel with the external skill's
  internal phases. The external skill may have sequencing constraints nefario cannot
  see.
- Do NOT attempt to parse/understand the external skill's internal state. Treat the
  deferred task as opaque until it completes.

### 5. Meta-Plan Integration (Phase 1 Changes)

The meta-plan phase needs a new step between "analyze the task" and "identify
specialists":

```
Phase 1 additions:
1. [existing] Read relevant files to understand codebase context
2. [NEW] Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the project directory
   b. Read SKILL.md frontmatter (name, description) for each
   c. For skills whose description domain-matches the task, read full content
   d. Classify each matching skill as ORCHESTRATION or LEAF
   e. Check project CLAUDE.md for explicit skill preferences
3. [existing] Analyze the task against delegation table
4. [NEW] Cross-reference external skills against delegation table:
   - For each ORCHESTRATION skill that covers a sub-task: mark as DEFER candidate
   - For each LEAF skill that covers a sub-task: mark as INVOKE candidate
   - For sub-tasks not covered by external skills: route to internal specialists
5. [existing] Return meta-plan with specialist consultations
```

The meta-plan output gains a new section:

```markdown
### External Skill Integration

#### Discovered Skills
| Skill | Classification | Domain | Recommendation |
|-------|---------------|--------|----------------|
| content-driven-development | ORCHESTRATION | AEM block development | DEFER for block-building tasks |
| building-blocks | LEAF (invoked by CDD) | Block scaffolding | Handled within CDD deferral |

#### Deferral Plan
- Task "build a new block" defers to CDD skill
- Cross-cutting reviews (security, accessibility, docs) remain with despicable-agents
- CDD output feeds into Phase 5-8 post-execution pipeline
```

### 6. Synthesis Integration (Phase 3 Changes)

The synthesis phase needs awareness of deferred tasks when resolving conflicts and
producing execution order:

- **Conflict resolution**: When a specialist recommends work that overlaps with a
  deferred external skill, nefario should prefer the deferral (the external skill is
  more domain-specific by definition -- it was installed for this project).
- **Execution order**: Deferred tasks are scheduled like any other task in the
  topological sort. Their dependencies and dependents work normally.
- **Prompt generation**: For deferred tasks, the prompt instructs the main session to
  invoke the external skill, not a despicable-agents agent. The prompt format is
  described in Recommendation 3 above.

## Proposed Tasks

### Task A: Design External Skill Discovery and Classification

**What**: Define the algorithm nefario uses to discover external skills during Phase 1,
classify them as ORCHESTRATION vs. LEAF, and cross-reference against the delegation table.

**Deliverables**:
1. Discovery algorithm specification (pseudocode in the design doc)
2. Classification heuristics table (content signals and weights)
3. Precedence rules specification
4. Cross-reference logic between external skills and delegation table

**Dependencies**: None (this is the foundational design)

**Agent**: ai-modeling-minion (multi-agent coordination design) + devx-minion
(developer experience for the discovery surface)

### Task B: Design Deferral Mechanism

**What**: Define how nefario's delegation plan represents deferred tasks, how the
execution phase invokes external skills, and how deferred task output feeds into
post-execution phases.

**Deliverables**:
1. Deferred task schema (new fields in delegation plan format)
2. Execution-phase invocation flow (how the main session runs external skills)
3. Post-execution integration specification (how deferred output enters Phase 5-8)
4. Hybrid scenario patterns (partial deferral examples)

**Dependencies**: Task A (needs discovery/classification output)

**Agent**: ai-modeling-minion

### Task C: Update Nefario AGENT.md

**What**: Add external skill awareness to nefario's system prompt: discovery step in
meta-plan, deferral support in synthesis, new delegation plan fields.

**Deliverables**:
1. Updated nefario AGENT.md with external skill integration logic
2. Updated delegation table (or notes on how external skills extend it)

**Dependencies**: Task A, Task B (needs finalized design)

**Agent**: ai-modeling-minion (prompt engineering for nefario's system prompt)

### Task D: Update Nefario SKILL.md

**What**: Add discovery scan to Phase 1, deferred task handling to Phase 4 execution,
and any changes to Phase 3.5 and Phase 5-8 for external skill output.

**Deliverables**:
1. Updated SKILL.md Phase 1 (discovery step)
2. Updated SKILL.md Phase 4 (deferred task execution)
3. Updated SKILL.md Phase 3.5 / Phase 5-8 (if changes needed)

**Dependencies**: Task A, Task B, Task C

**Agent**: ai-modeling-minion

### Task E: Documentation

**What**: Create/update documentation for both users and skill maintainers.

**Deliverables**:
1. New `docs/external-skill-integration.md` (architecture doc)
2. Updates to `docs/using-nefario.md` (user perspective)
3. Updates to `docs/orchestration.md` (deferral mechanism details)

**Dependencies**: Task A, Task B (needs finalized design)

**Agent**: software-docs-minion

### Task F: Acceptance Test Validation

**What**: Manually validate the acceptance test scenario from the issue: install
despicable-agents into a project with CDD skill, run `/nefario 'build a new block'`,
verify meta-plan references CDD's phased workflow.

**Deliverables**:
1. Test scenario script/checklist
2. Validation results documented in execution report

**Dependencies**: Task C, Task D (needs updated nefario)

**Agent**: devx-minion or test-minion

## Risks and Concerns

### Risk 1: Over-Engineering the Classification (HIGH)

The heuristic content classification could become a rabbit hole. There is a real
temptation to build a sophisticated classifier with weighted signals, confidence
thresholds, and edge case handling. For v1, the classification should be embedded in
nefario's prompt as natural language guidance ("look for these signals"), not as a
separate tool or formal algorithm. Nefario is an LLM -- it reads SKILL.md content and
makes a judgment call. That is sufficient.

**Mitigation**: Ship with prompt-embedded heuristics. Only build formal classification
if prompt-level detection proves unreliable across 10+ real skill files.

### Risk 2: External Skill Invocation Mechanics (MEDIUM)

The biggest implementation uncertainty is how a subagent spawned via the Task tool
invokes an external skill. Claude Code's `/skill-name` works in the main session, but
the Skill tool's availability in subagent contexts may vary. If the Skill tool is
not available to subagents, the deferred task must run in the main session context.

**Mitigation**: Design the deferral mechanism so deferred tasks always execute in the
main session (the orchestrator's context), not in spawned subagents. This is more
reliable and aligns with how `/nefario` already runs skill invocations (the main
session drives Phase 4 execution). The main session has full access to all skills.

### Risk 3: Nefario System Prompt Size (MEDIUM)

Adding external skill discovery, classification heuristics, precedence rules, and
deferral mechanisms to nefario's AGENT.md will increase its system prompt size. Nefario
already has a substantial prompt (~4K tokens). Adding another ~1K-2K tokens for
external skill integration may push against practical limits for subagent spawning.

**Mitigation**: Keep the additions compact. Use the SKILL.md (which runs in the main
session and has more context budget) for the detailed discovery and execution logic.
The AGENT.md additions should be limited to: (a) awareness that external skills exist,
(b) how to represent them in meta-plan and synthesis output, (c) a pointer to "the
calling session handles discovery and invocation."

### Risk 4: Silent Routing Failures (MEDIUM)

If nefario fails to detect an external orchestration skill and routes work to an
internal specialist instead, the user gets a working but sub-optimal result. They
might not realize their project-specific skill was ignored. This is a UX problem as
much as a technical one.

**Mitigation**: In the execution plan approval gate, show a "Discovered external
skills" section listing what was found and how it was integrated (or why it was not).
This makes the routing decision visible and correctable before execution begins.

### Risk 5: Coupling Through Convention (LOW)

Even with "no mandatory metadata" as a design principle, the heuristic detection
creates implicit coupling. If nefario's heuristics expect "Phase 1... Phase 2..." as
an orchestration signal, external skill authors might unconsciously shape their content
to match. This is not necessarily bad -- it is emergent convention -- but it should be
documented as "these patterns help nefario understand your skill" rather than "you must
structure your skill this way."

**Mitigation**: Frame discovery heuristics as "what nefario looks for" in the skill
maintainer documentation. Emphasize these are best-effort signals, not requirements.

## Additional Agents Needed

**devx-minion** is already in the meta-plan and is essential. The discovery mechanism
design is as much a DX problem as an agent coordination problem. No additional agents
beyond what the meta-plan already identifies.

One note: **lucy** should pay particular attention during Phase 3.5 review to whether
the deferral mechanism respects the project's CLAUDE.md conventions. If a project's
CLAUDE.md says "use CDD for all block work," the deferral mechanism must honor that --
and lucy is the agent who checks CLAUDE.md compliance. This is not a new consultation;
it is a note for lucy's review prompt.
