## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### (a) Interface Contract: Domain Adapter to Orchestration Engine

The current architecture already has a latent separation -- nefario AGENT.md holds domain knowledge (roster, delegation table, cross-cutting checklist, gate heuristics, model selection, post-execution reviewer lists), while SKILL.md holds infrastructure (spawning protocol, scratch files, status line, compaction, report generation, gate interaction mechanics). The problem is that SKILL.md also embeds domain-specific content (phase announcements naming specific phases, reviewer prompt templates referencing software concepts, conditional phase logic tied to "code" vs "docs" file classification).

**Recommended adapter interface contract:**

The domain adapter should be a single declarative configuration file (e.g., `domain.yaml` or a dedicated section within the nefario agent) that the orchestration engine reads at startup. The contract should expose these surfaces:

1. **Agent Roster** -- List of available agents with name, description, domain group, and default model. This replaces the hardcoded "Agent Team Roster" section in AGENT.md.

2. **Delegation Table** -- Task-type-to-agent routing. Maps task type strings to primary and supporting agent names. This replaces the "Delegation Table" section.

3. **Phase Sequence** -- Ordered list of phase definitions (see section b below). Each phase declares its name, type (planning/review/execution/verification), entry condition, exit condition, and whether it is conditional or mandatory.

4. **Cross-Cutting Concerns** -- List of mandatory dimensions, each with: dimension name, responsible agent(s), inclusion rule (always / conditional with predicate), and default stance (include / exclude-with-justification).

5. **Gate Classification Heuristics** -- The reversibility/blast-radius matrix is domain-independent (it is a general decision-theory pattern). But the *examples* of what constitutes "hard to reverse" vs "easy to reverse" are domain-specific. The adapter should provide:
   - A set of labeled examples for each quadrant (e.g., in software: "schema migration" = hard to reverse; in IVDR: "clinical evaluation plan" = hard to reverse)
   - Optionally, a predicate function or keyword list that helps classify domain-specific artifacts

6. **Artifact Classification** -- The Phase 5 file classification table (logic-bearing vs documentation-only) is entirely domain-specific. The adapter should provide a classification scheme for artifacts produced during execution, mapping file patterns to categories that drive post-execution phase triggers.

7. **Reviewer Configuration** -- Mandatory reviewers and discretionary reviewer pool with domain signals. This replaces the hardcoded reviewer tables in both AGENT.md and SKILL.md.

8. **Post-Execution Phase Definitions** -- Which verification phases exist, what triggers them, what agents run them, and what verdict semantics apply.

**What stays in the engine (not configurable):**

- Subagent spawning protocol (Task tool mechanics, parallel vs sequential)
- Scratch file management (mktemp, directory structure naming conventions, lifecycle)
- Status line mechanics (sentinel file writing, SID resolution)
- Compaction checkpoint protocol (AskUserQuestion mechanics, clipboard integration)
- Report generation infrastructure (template rendering, companion directory, index)
- Gate interaction mechanics (AskUserQuestion structure, response handling flow, anti-fatigue calibration)
- Communication protocol (SHOW/NEVER SHOW/CONDENSE taxonomy)
- Content boundary markers (`<github-issue>`, `<external-skill>` tags)
- External skill discovery and classification protocol (scan, classify, precedence)

#### (b) Phase Sequence Declaration

The current 9-phase model is software-development-specific in its labels and conditional logic, but the *structure* is domain-independent. It follows a universal pattern:

```
Plan --> Consult --> Synthesize --> Review --> Execute --> Verify --> Report
```

The adapter should declare phases using a schema like:

```yaml
phases:
  - id: meta-plan
    name: "Meta-Plan"
    type: planning
    mandatory: true
    description: "Identify which specialists to consult"
    gate_after: team-approval  # references a gate definition

  - id: specialist-planning
    name: "Specialist Planning"
    type: consultation
    mandatory: true
    parallel: true
    description: "Domain experts contribute perspectives"

  - id: synthesis
    name: "Synthesis"
    type: planning
    mandatory: true
    gate_after: plan-approval
    compaction_checkpoint: true

  - id: architecture-review
    name: "Architecture Review"
    type: review
    mandatory: true  # can be skipped by user, but always offered
    gate_before: reviewer-approval
    compaction_checkpoint: true

  - id: execution
    name: "Execution"
    type: execution
    mandatory: true
    batch_gated: true  # uses dependency graph + gate boundaries

  - id: quality-review
    name: "Quality Review"
    type: verification
    mandatory: false
    condition: "execution_produced_reviewable_artifacts"
    dark_kitchen: true

  - id: validation
    name: "Validation"
    type: verification
    mandatory: false
    condition: "validation_targets_exist"
    dark_kitchen: true

  - id: deployment
    name: "Deployment"
    type: verification
    mandatory: false
    condition: "user_requested_deployment"
    dark_kitchen: true

  - id: documentation
    name: "Documentation"
    type: verification
    mandatory: false
    condition: "documentation_checklist_nonempty"
    dark_kitchen: true

gates:
  team-approval:
    type: team-selection
    adjustable: true
    max_rounds: 2

  reviewer-approval:
    type: reviewer-selection
    adjustable: true
    max_rounds: 2
    skip_allowed: true

  plan-approval:
    type: plan-review
    skip_allowed: false
```

Key design decisions for the phase schema:

1. **Phase types, not phase numbers.** The engine knows how to handle `planning`, `consultation`, `review`, `execution`, and `verification` phase types. Domain adapters compose from these types. This means a regulatory compliance domain could have `specialist-planning --> synthesis --> compliance-review --> execution --> audit-verification` without needing to shoehorn it into "Phase 3.5".

2. **Conditions are named predicates, not inline code.** The adapter names a condition (`execution_produced_reviewable_artifacts`); the engine provides the evaluation mechanism. The adapter also provides the artifact classification scheme that the predicate uses. This avoids embedding domain logic in the engine while keeping the engine responsible for evaluation mechanics.

3. **Dark kitchen is a phase attribute, not a concept tied to specific phase numbers.** Any verification-type phase can be marked `dark_kitchen: true`, which tells the engine to run it silently with only BLOCK escalation.

4. **Advisory mode derives from the phase sequence.** The engine knows that `--advisory` means "run only planning-type and consultation-type phases, then synthesize an advisory report." The adapter does not need to declare advisory behavior separately -- it falls out of phase type annotations.

5. **Gate definitions are separate from phases.** Gates reference phases by ID. The engine handles gate interaction mechanics (AskUserQuestion, response handling, revision caps). The adapter declares which phases have gates and what gate type applies.

#### (c) Risks of Over-Abstraction

This is the critical question. Here are the specific risks I see, ordered by severity:

**Risk 1: Prompt coherence fragmentation (HIGH)**

The current system's effectiveness comes from the tight coupling between nefario's domain knowledge and its orchestration behavior. When nefario sees a task involving "OAuth flows," it knows (a) route to oauth-minion as primary, security-minion as supporting, (b) this is likely hard-to-reverse with high blast radius, so gate it, (c) the cross-cutting security dimension is mandatory here, (d) Phase 5 code review should focus on auth patterns. This chain of reasoning works because all the knowledge lives in one coherent prompt context.

If the domain adapter is loaded as a separate file and referenced indirectly, nefario's reasoning quality will degrade. The model works best when knowledge is inline and contextually integrated, not when it must dereference configuration. This is a fundamental LLM characteristic, not a prompt engineering failure.

**Mitigation:** The adapter should be *assembled into* the nefario prompt at invocation time, not referenced as an external file. Think of it as a build step: `domain.yaml` + `engine-template.md` --> fully materialized `AGENT.md`. The model sees one coherent document. The separation exists in source, not at runtime.

**Risk 2: Condition predicate explosion (MEDIUM)**

The software-development domain has ~8 specific conditions (code produced, tests exist, user-requested deployment, documentation checklist nonempty, logic-bearing markdown produced, etc.). A regulatory compliance domain might have 15+ conditions (clinical evidence submitted, risk classification determined, notified body review required, etc.). If the engine must evaluate arbitrary domain predicates, it becomes either (a) a general-purpose rule engine (complex, fragile) or (b) dependent on the model interpreting free-text conditions (unreliable).

**Mitigation:** Keep the predicate vocabulary small and grounded in observable facts: artifact existence, artifact classification, user flags, agent output verdicts. The adapter maps domain concepts to these primitive predicates. For example, "clinical evidence submitted" maps to "artifact of type 'clinical-evidence' exists in execution output."

**Risk 3: Losing the "mandatory reviewer" enforcement strength (MEDIUM)**

The current system's mandatory reviewers (security, test, ux-strategy, lucy, margo) are effective precisely because they are hardcoded and unconditional. A generic "the adapter declares mandatory reviewers" risks domains declaring zero mandatory reviewers, or declaring too many, or not understanding what makes a reviewer mandatory vs discretionary. The enforcement strength comes from the specificity.

**Mitigation:** The engine should enforce structural constraints on the adapter: at least N mandatory reviewers (suggest minimum 2), at least one governance-type reviewer, at least one quality-type reviewer. The adapter chooses WHO fills these slots, but the engine ensures the slots exist.

**Risk 4: Gate heuristic degradation (LOW-MEDIUM)**

The reversibility/blast-radius matrix works because nefario has internalized software-specific examples. A generic adapter would need to provide equivalent examples for its domain, and the quality of gate classification depends on the quality of those examples. Bad examples lead to either too many gates (fatigue) or too few (missed high-impact decisions).

**Mitigation:** Ship the software-development adapter as a reference implementation with extensive comments. Make it clear that gate classification examples are the most important part of a domain adapter to get right. Consider providing a "gate calibration" test suite: a set of sample tasks with expected gate classifications.

**Risk 5: Increased token cost per invocation (LOW)**

If the domain adapter is assembled into the prompt, the nefario system prompt grows. The current AGENT.md is already substantial. Adding a generic engine layer plus a domain adapter layer could push the prompt past cache-friendly sizes or increase per-request cost.

**Mitigation:** Prompt caching already addresses this -- the assembled prompt is stable across invocations within a domain. The adapter changes rarely (it is configuration, not per-session data). With the 4,096-token minimum for Opus caching, the combined engine+adapter prompt will cache well. Monitor assembled prompt size; if it exceeds 10K tokens, consider splitting into system (cached) and domain-context (message) sections.

### Proposed Tasks

**Task 1: Audit and Catalog Domain-Specific vs Infrastructure Content**

Go through SKILL.md and AGENT.md line by line and produce a classification spreadsheet: each section/block tagged as `domain-specific`, `infrastructure`, or `mixed`. For mixed blocks, identify the seam where they could be separated. This is the prerequisite for all other tasks.

- Deliverables: Classification document mapping every section of SKILL.md and AGENT.md
- Dependencies: None (can start immediately)
- Agent: ai-modeling-minion (prompt architecture expertise)

**Task 2: Design the Domain Adapter Schema**

Define the YAML/Markdown schema for a domain adapter. Cover all 8 surfaces from recommendation (a). Include JSON Schema or equivalent for validation. Write the schema documentation.

- Deliverables: `docs/domain-adapter-schema.md`, JSON Schema file
- Dependencies: Task 1 (needs the classification to know what to include)
- Agent: ai-modeling-minion (primary), devx-minion (supporting -- schema usability)

**Task 3: Extract Software-Development Domain Adapter**

Take the current domain-specific content from AGENT.md and SKILL.md and express it as the first domain adapter (`domains/software-development.yaml` or equivalent). This is a refactor, not new functionality -- the existing behavior must be preserved exactly.

- Deliverables: Software-development domain adapter file, updated AGENT.md/SKILL.md referencing the adapter
- Dependencies: Task 2 (needs the schema)
- Agent: ai-modeling-minion

**Task 4: Implement Prompt Assembly**

Build the mechanism that assembles `engine-template + domain-adapter --> materialized AGENT.md` at install time (or invocation time). This ensures the model sees one coherent prompt, not a reference to external configuration.

- Deliverables: Assembly script or build step, updated `install.sh`
- Dependencies: Task 3 (needs the extracted adapter and template)
- Agent: devx-minion (primary -- build tooling), ai-modeling-minion (supporting -- prompt assembly quality)

**Task 5: Write Domain Adapter Documentation**

Document what a domain adapter must provide, what the framework handles, and how to create a new adapter. Include a "creating your first domain adapter" walkthrough.

- Deliverables: `docs/domain-adapter-guide.md`
- Dependencies: Tasks 2, 3 (needs schema and reference implementation)
- Agent: software-docs-minion (primary), ai-modeling-minion (supporting -- technical accuracy)

**Task 6: Validate Behavioral Equivalence**

Verify that the refactored system (engine + software-development adapter) produces identical behavior to the current monolithic system. This means running representative orchestration scenarios and comparing outputs.

- Deliverables: Test scenarios, comparison results, behavioral equivalence report
- Dependencies: Task 4 (needs the assembled system)
- Agent: test-minion (primary), ai-modeling-minion (supporting)

### Risks and Concerns

1. **Behavioral regression during extraction.** The biggest risk is that separating domain content from infrastructure subtly changes nefario's behavior. The current system has been tuned through many iterations; any extraction must preserve exact behavioral equivalence. This is why Task 6 (behavioral validation) is essential and should not be skipped.

2. **Prompt coherence loss.** As discussed in Risk 1 above, the model's ability to reason about domain-specific orchestration decisions depends on having domain knowledge inline. The assembly approach mitigates this, but it adds a build step that must be maintained.

3. **Adapter schema stability.** The adapter schema becomes a public API surface. Changes to the schema are breaking changes for anyone who has written a domain adapter. The schema should be designed conservatively (fewer, more general fields) and versioned from day one.

4. **Over-abstraction of phase conditions.** The temptation will be to make every conditional in SKILL.md configurable via the adapter. Resist this. Many conditionals are infrastructure concerns (e.g., "if context pressure is high, offer compaction") that should remain hardcoded in the engine. Only conditions that genuinely differ between domains belong in the adapter.

5. **SKILL.md complexity.** SKILL.md is already very large (~1500 lines). If the engine template retains all infrastructure logic but now also includes adapter interpolation points, it could become harder to maintain, not easier. The extraction must simplify SKILL.md, not add a layer of indirection on top of existing complexity.

6. **Token budget for assembled prompts.** The software-development domain adapter alone (roster: 26 agents, delegation table: ~80 rows, cross-cutting checklist: 6 dimensions, reviewer config, artifact classification, gate examples) could be 3,000-4,000 tokens. Combined with the engine template, the assembled AGENT.md may approach 8,000-10,000 tokens. This is within Opus's cache-friendly zone but warrants monitoring.

### Additional Agents Needed

- **devx-minion**: Essential for the adapter schema design (Task 2) and the assembly tooling (Task 4). The adapter is a developer-facing configuration surface; devx expertise ensures it is intuitive, well-documented, and follows configuration best practices.

- **lucy**: Should review the final adapter schema and extraction to ensure the separation preserves the intent and governance properties of the current system. Intent alignment is especially important here -- the adapter must not allow configurations that violate the framework's core invariants (e.g., zero mandatory reviewers).

- **margo**: Should review for over-engineering risk. The adapter schema should be minimal and justified. If a field is not needed by at least two plausible domain adapters, it should not be in the schema.
