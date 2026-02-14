# Phase 3: Synthesis -- Enforce Serverless-First Across Agent System

## Design Decision Resolutions

### Decision A: Edge-first sub-preference within serverless

**Resolution: Include, but as a RECOMMENDATION within iac-minion's Step 0, not a mandatory evaluation tier.**

Edge-minion's reasoning is sound -- the Helix Manifesto's latency principle ("<300ms fast. Always.") does favor edge platforms, and edge serverless largely eliminates cold starts. However, encoding a mandatory edge-first evaluation step risks over-prescribing for teams with existing cloud serverless infrastructure (Lambda, Cloud Functions). The escape criteria edge-minion proposes (5 yes/no questions) are fast to evaluate, but adding a second mandatory decision tier between "serverless" and "which serverless" creates complexity that margo would rightfully flag.

**Compromise**: iac-minion's Step 0 cascade reads: "1. Default: Serverless. 2. Within serverless, prefer edge platforms when latency sensitivity is high or cold starts are a concern (edge-minion advises on platform selection). 3. Escalation: Container..." This makes edge-first a recommendation informed by the latency principle, not a mandatory gate. The detailed edge-vs-cloud-serverless escape criteria belong in edge-minion's domain (not duplicated in iac-minion).

### Decision B: Decision 31 for policy supersession

**Resolution: Include. Lucy is correct that this is necessary.**

The 2026-02-13 advisory (PR #123) explicitly chose topology-neutral framing. This task deliberately reverses that stance. Without a Decision 31 entry, future reviewers will find contradictory guidance with no record of the evolution. The entry must explicitly state what is superseded, what the new stance is, and why -- with reference to the Helix Manifesto principles.

### Decision C: 5th blocking concern (execution environment constraints)

**Resolution: Include as a distinct 5th blocking concern, but with tighter scoping.**

Edge-minion proposes "Execution environment constraints (native binaries, CPU/memory limits, storage access patterns incompatible with platform primitives)." The first two sub-items (native binaries, CPU/memory limits) are genuinely distinct from the existing four -- they describe hard platform capability gaps, not workload characteristics. However, "storage access patterns" is too broad and overlaps with how data-minion would evaluate database selection. A workload needing Postgres does not need to escape serverless -- it needs managed Postgres (RDS, Neon, etc.) alongside serverless compute.

**Scoping**: The 5th blocking concern becomes: "Execution environment constraints (native binaries, CPU/memory limits beyond platform maximums)." Storage is excluded -- it is a data architecture decision, not a compute topology decision. The blocking concern list becomes five items:
1. Persistent connections
2. Long-running processes (>30s)
3. Compliance-mandated infrastructure control
4. Cost optimization at scale (measured, not projected)
5. Execution environment constraints (native binaries, CPU/memory beyond platform limits)

### Decision D: the-plan.md modifications

**Resolution: All the-plan.md changes are included in a single task, gated for human approval.**

Per project rules, the-plan.md is human-edited and requires human approval. Rather than scatter the-plan.md changes across multiple tasks (iac-minion spec + margo spec), consolidate them into one approval-gated task. This is more efficient for the human reviewer and reduces gate fatigue.

### Decision E: lucy AGENT.md governance check

**Resolution: Include the serverless-first compliance check in lucy's AGENT.md, not just in project CLAUDE.md.**

Lucy's recommendation to add a COMPLIANCE check to her plan review checklist is correct. The check should fire when a plan proposes non-serverless infrastructure and the project's CLAUDE.md either has no Deployment section (meaning the default applies) or has one without documented deviation rationale. Severity is ADVISE, not BLOCK -- consistent with lucy's existing enforcement patterns. This is a system-level governance behavior, not a per-project setting.

---

## Delegation Plan

**Team name**: enforce-serverless-first
**Description**: Enforce serverless-first stance across agent system -- update iac-minion Step 0, margo complexity budget, CLAUDE.md template, lucy governance check, and decision log.

### Task 1: Update the-plan.md specs (iac-minion + margo)
- **Agent**: iac-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: the-plan.md is human-edited per project rules. Changes to iac-minion spec (identity, Step 0 restructure, research focus) and margo spec (complexity budget burden-of-proof, framing rules) must be reviewed before agent rebuilds proceed. Hard to reverse, high blast radius (3 downstream tasks depend on this).
- **Prompt**: |
    You are updating `the-plan.md` to encode serverless-first as the default deployment stance for the agent system. This is an incremental change on branch `nefario/fix-serverless-bias`, building on PR #123 which established topology-neutral framing. The current task deliberately shifts from neutral to serverless-first.

    **IMPORTANT**: This file is human-edited per project rules. You are making changes that will be presented for human approval before proceeding.

    ## Changes to make

    ### iac-minion spec (starts at line 726)

    **Line 740** -- Update "Deployment strategy selection" description:
    Change: `Deployment strategy selection (evaluating serverless vs. container vs. self-managed for a given workload)`
    To: `Serverless-first deployment strategy selection (default to serverless; evaluate deviation only when blocking concerns exist)`

    **Lines 750-755** -- Update research focus:
    Replace the segment starting with `serverless deployment patterns` through the end of the research focus with:
    `serverless-first deployment patterns, cold start optimization, FaaS cost modeling, blocking concerns for serverless deviation (persistent connections, long-running processes >30s, compliance-mandated infrastructure control, measured cost optimization at scale, execution environment constraints beyond platform limits).`

    **Bump spec-version** from `2.0` to `2.1` (line 757).

    ### margo spec (starts at line 539)

    **Line 544** -- Add to remit list (after "Reviewing plans for unnecessary complexity..."):
    Add a new bullet: `- Enforcing serverless-first default: when a serverless/managed alternative exists, plans must justify self-managed infrastructure with a documented blocking concern`

    **Do NOT bump margo spec-version** -- the margo AGENT.md changes in Task 2 are hand-edits to an already-built agent, not a spec rebuild trigger. Leave spec-version at 1.1.

    ## File
    `/Users/ben/github/benpeter/2despicable/4/the-plan.md`

    ## What NOT to do
    - Do not modify any other agent specs
    - Do not modify any sections outside the iac-minion and margo spec blocks
    - Do not add new sections to the-plan.md
    - Do not modify the spec structure (headers, field names)
    - Keep changes surgical -- minimal diff
- **Deliverables**: Updated `the-plan.md` with iac-minion spec reflecting serverless-first default and margo spec including burden-of-proof remit item.
- **Success criteria**: `the-plan.md` diff shows only the targeted lines changed. iac-minion spec-version bumped to 2.1. margo spec unchanged except the new remit bullet.

### Task 2: Rewrite iac-minion AGENT.md (identity + Step 0 + RESEARCH.md)
- **Agent**: iac-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are rewriting the iac-minion's AGENT.md and RESEARCH.md to shift from topology-neutral to serverless-first default. This builds on PR #123's topology-neutral framing and deliberately supersedes it.

    ## Changes to AGENT.md (`/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/AGENT.md`)

    ### 1. Identity line (line 17)

    Replace the current identity text. The current text says "You are topology-neutral: you evaluate workloads against criteria and recommend the best-fit deployment model, whether serverless, containerized, or self-managed."

    Replace with: "You are serverless-first: you default to serverless and only escalate to containers or self-managed infrastructure when a specific blocking concern demands it. Blocking concerns are: persistent connections, long-running processes (>30s), compliance-mandated infrastructure control, measured cost optimization at scale, or execution environment constraints (native binaries, CPU/memory beyond platform limits). The burden of proof is on the deviation, not on the default."

    ### 2. Step 0: Deployment Strategy Selection (lines 166-188)

    Replace the entire Step 0 section content (not the heading) with:

    ```
    Before designing infrastructure, evaluate the workload against the serverless-first default. Start with serverless. Only deviate when a specific, documented blocking concern demands it. The burden of proof is on the deviation, not on the default.

    **Tier 1 -- Blocking Concern Gate** (check first):

    | Blocking Concern | Trigger Condition | If Triggered |
    |------------------|-------------------|--------------|
    | Persistent connections | WebSockets, long-lived TCP, gRPC streaming | Container or self-managed |
    | Long-running processes | Execution > 30s, batch jobs, ML training | Container or self-managed |
    | Compliance-mandated infra control | Regulatory requirement for specific infrastructure ownership | Self-managed or dedicated tenancy |
    | Cost optimization at scale | **Measured** (not projected) cost data showing serverless is 3x+ more expensive at sustained load | Container or self-managed |
    | Execution environment constraints | Native binaries, CPU/memory limits beyond platform maximums | Container or self-managed |

    If no blocking concern is triggered, the answer is serverless. Select platform based on workload profile (edge-minion advises on platform selection). Within serverless, prefer edge platforms (Cloudflare Workers, Vercel Edge, Fastly Compute) when latency sensitivity is high or cold starts are a concern -- edge platforms have near-zero cold starts and global distribution aligned with the "<300ms fast" principle.

    **Tier 2 -- Validation Dimensions** (used to refine the selected topology, not to override the default):

    1. Latency sensitivity -- cold start mitigation needed? Edge platform viable?
    2. Scale pattern -- scale-to-zero valuable? Burst capacity needed?
    3. Team expertise -- does the team have ops maturity for the selected topology?
    4. Existing infrastructure -- does this fragment the stack?
    5. Vendor portability -- is lock-in acceptable for this workload?
    6. Data residency -- does the serverless platform operate in required regions?

    Tier 2 dimensions do NOT override the serverless default. They inform implementation choices within the selected topology.

    **Topology cascade** (serverless-first with documented escalation):

    1. **DEFAULT: Serverless** -- No blocking concerns triggered. Deploy serverless. Select platform based on workload profile.
    2. **ESCALATION: Container** -- One or more blocking concerns triggered, but workload does not require hardware-level control or compliance-mandated infrastructure ownership. Document which blocking concern(s) drove the escalation.
    3. **ESCALATION: Self-Managed** -- Compliance-mandated infrastructure control, specialized hardware needs, or container orchestration itself becomes the bottleneck. Document the specific regulatory or hardware requirement.
    4. **HYBRID** -- Different workloads within the same system have different profiles. Evaluate each workload independently through this cascade.

    Every escalation must include a `deviation-reason` citing the specific blocking concern. This creates an audit trail for revisiting decisions when platform capabilities evolve.

    Present the evaluation with rationale tied to blocking concerns (or their absence). Never recommend a non-serverless topology without documenting the specific blocking concern that requires it.
    ```

    ### 3. Update x-plan-version and x-build-date in frontmatter

    - Change `x-plan-version` from `"2.0"` to `"2.1"`
    - Change `x-build-date` to `"2026-02-14"`

    ## Changes to RESEARCH.md (`/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/RESEARCH.md`)

    ### Line 493 area -- Replace neutrality statement

    Replace: "The decision must be neutral -- no default to any topology."

    With: "The decision defaults to serverless. Deviation requires a documented blocking concern: persistent connections, long-running processes (>30s), compliance-mandated infrastructure control, measured cost optimization at scale, or execution environment constraints (native binaries, CPU/memory beyond platform limits). The burden of proof is on the deviation."

    ### Lines 497-516 area -- Replace evaluation criteria table and decision process

    Replace the three-column "Favors X" table with a blocking concern detector format:

    ```
    | Dimension | Blocking Concern? |
    |-----------|-------------------|
    | Execution duration > 30s | Yes -- long-running process |
    | Persistent connections needed | Yes -- persistent connections |
    | Compliance requires infra ownership | Yes -- compliance-mandated control |
    | Measured cost 3x+ at sustained load | Yes -- cost optimization at scale |
    | Native binaries or CPU/memory beyond platform limits | Yes -- execution environment constraints |
    | Cold start tolerance low | No -- mitigate with provisioned concurrency or edge platform |
    | Team lacks serverless experience | No -- invest in learning, not in adding ops burden |
    | Vendor portability critical | No -- use portable serverless patterns (container-based Lambda, standard APIs) |
    ```

    Replace the "Decision Process" steps with:
    ```
    **Decision Process**:
    1. Check blocking concerns (persistent connections, long-running >30s, compliance, measured cost, execution environment constraints)
    2. If no blocking concern triggered: serverless. Select platform based on workload profile.
    3. If blocking concern triggered: document it and escalate to container or self-managed.
    4. Validate with Tier 2 dimensions (latency, scale pattern, team expertise, existing infra, portability, data residency).
    5. For hybrid systems, evaluate each workload independently.
    ```

    Keep the "Hybrid Is Normal" paragraph and the Sources section unchanged.

    ## What NOT to do
    - Do not modify any other files
    - Do not change the section structure of AGENT.md beyond Step 0
    - Do not add new sections
    - Do not modify RESEARCH.md beyond the Deployment Strategy Selection subsection
    - Keep the 10 core knowledge sections unchanged
- **Deliverables**: Updated `minions/iac-minion/AGENT.md` (identity, Step 0, frontmatter) and `minions/iac-minion/RESEARCH.md` (deployment strategy section).
- **Success criteria**: iac-minion identity states "serverless-first." Step 0 starts with blocking concern gate. Topology cascade shows serverless as default with documented escalation. RESEARCH.md table uses blocking-concern format. x-plan-version matches the-plan.md spec-version.

### Task 3: Update margo AGENT.md (complexity budget + framing rules)
- **Agent**: margo
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating margo's AGENT.md to encode the serverless-first default into the existing complexity budget and framing rules. This is three surgical modifications -- no new sections, no new detection patterns.

    ## File
    `/Users/ben/github/benpeter/2despicable/4/margo/AGENT.md`

    ## Change 1: Add burden-of-proof paragraph to Complexity Budget section

    After the paragraph ending "When budget is exhausted, **simplify before adding more**. Every addition must justify its budget spend against actual requirements." (around line 78-79), add:

    ```
    **Default to the managed/serverless column.** When a serverless or fully managed
    alternative exists for a proposed service, plans must use the managed/serverless
    column unless a documented blocking concern prevents it. Blocking concerns are
    specific technical constraints -- not team preference, existing tooling
    familiarity, or speculative future needs. The five blocking concerns are:
    persistent connections, long-running processes (>30s), compliance-mandated
    infrastructure control, measured cost optimization at scale, and execution
    environment constraints (native binaries, CPU/memory beyond platform limits).
    When a blocking concern is cited, it must name the constraint and explain why it
    cannot be worked around within the serverless model.
    ```

    ## Change 2: Amend framing rule #1 (around line 306-308)

    Replace:
    ```
    1. **Flag disproportion, not topology.** The problem is never "you're using
       serverless" or "you're self-hosting." The problem is "this complexity is not
       justified by the actual requirements."
    ```

    With:
    ```
    1. **Flag disproportion, not topology -- but recognize that self-managed
       infrastructure carries inherent operational overhead.** The problem is never
       "you chose the wrong cloud provider." The problem is "this operational burden
       is not justified." When a serverless alternative exists without blocking
       concerns, choosing self-managed infrastructure IS a disproportion signal
       because it adds operational complexity that could be avoided.
    ```

    ## Change 3: Refine framing rule #3 (around line 312-313)

    Replace:
    ```
    3. **Ask "is this complexity justified?" not "is this the right platform?"**
       Platform selection is gru's domain. Complexity assessment is yours.
    ```

    With:
    ```
    3. **Ask "is this complexity justified?" -- and when the answer is "a simpler
       managed/serverless alternative exists," flag the self-managed choice as
       unjustified complexity.** Margo does not select platforms (that is gru's
       domain). Margo identifies when a plan pays unnecessary operational
       complexity. If a plan proposes containers and a serverless option exists
       without blocking concerns, flag the operational overhead as accidental
       complexity. The plan author must provide a documented blocking concern from
       the approved list. If they cannot, escalate to gru for platform
       re-evaluation.
    ```

    ## Change 4: Add serverless-first check to review checklist (step 6-7 area, around line 290-296)

    Between the current step 6 ("Assess complexity budget") and step 7 ("Check infrastructure proportionality"), insert a new step:

    ```
    7. **Check serverless-first compliance**: for each proposed service, does a
       serverless/managed alternative exist? If yes, is there a documented blocking
       concern (persistent connections, long-running processes >30s,
       compliance-mandated control, measured cost at scale, execution environment
       constraints) justifying the self-managed choice? Flag unjustified
       self-managed infrastructure as accidental complexity.
    ```

    Renumber subsequent steps (current 7 becomes 8, current 8 becomes 9, current 9 becomes 10).

    ## Change 5: Update frontmatter

    - Change `x-plan-version` to `"1.1"` (should already be 1.1; verify)
    - Change `x-build-date` to `"2026-02-14"`

    ## What NOT to do
    - Do not add new sections or detection patterns
    - Do not modify the Boring Technology Assessment section (it is orthogonal -- the boring test applies to all topologies)
    - Do not modify the "Topology-Neutral" heading on the Boring Technology Assessment (lucy confirmed this is correct)
    - Do not change margo's identity or mission statement
    - Do not recommend specific platforms -- margo quantifies the complexity gap; gru fills it
    - Keep changes surgical -- three modifications to existing text, one new checklist step
- **Deliverables**: Updated `margo/AGENT.md` with burden-of-proof paragraph, amended framing rules #1 and #3, and new serverless-first compliance step in review checklist.
- **Success criteria**: Complexity budget section states "default to managed/serverless column." Framing rule #1 acknowledges self-managed overhead. Framing rule #3 connects complexity flagging to serverless alternative. Review checklist includes serverless-first check. Boring Technology Assessment unchanged.

### Task 4: Rewrite CLAUDE.md template (serverless default framing)
- **Agent**: lucy
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are rewriting the CLAUDE.md deployment template to encode serverless-first as the system default. The template currently presents all deployment options as equals. The new version establishes that omission = serverless default, and the section exists primarily for when projects need to deviate from serverless.

    ## File
    `/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md`

    ## Changes to make

    ### "When to omit this section" (lines 7-17)

    Replace the entire content from "Most projects do not need..." through "...not already captured by your project files." with:

    ```
    Most projects do not need a Deployment section. You should omit it entirely if:

    - You are deploying to serverless/managed platforms (the system default).
    - Your project already contains infrastructure artifacts (`wrangler.toml`, `vercel.json`, `netlify.toml`, serverless framework configs, etc.) that confirm the serverless approach.
    - You are early in development and have no blocking reason to deviate from serverless.

    When no Deployment section exists, agents default to serverless/managed platforms and select the best fit for your workload (e.g., Cloudflare Workers, Vercel, AWS Lambda). Existing infrastructure files in your repository serve as implicit signals -- agents read them and factor them into recommendations without needing explicit prose.

    **Add this section only when you need to deviate from the serverless default** -- because you have blocking concerns (persistent connections, long-running processes, compliance-mandated control, or proven cost optimization at scale) or because you have existing non-serverless infrastructure that agents should respect.
    ```

    ### Template HTML comment (lines 26-28)

    Replace: `<!-- Optional. Omit this section entirely if you have no deployment preferences -- agents will recommend an approach and explain their reasoning. You can accept or redirect. -->`

    With: `<!-- Optional. Omit this section entirely to use the serverless default. Add this section to deviate from serverless or to specify a particular serverless platform. -->`

    ### Examples section (lines 38-92)

    Restructure examples into two groups. Replace the current examples with:

    ```
    ## Examples

    Examples are grouped by relationship to the serverless default. Use whichever level matches your situation.

    ### Confirming the default (optional -- omitting the section produces the same behavior)

    #### Minimal

    ```markdown
    ## Deployment

    We deploy on Vercel.
    ```

    One sentence is enough. Agents will work within this constraint without needing justification.

    #### Specific platform (serverless)

    ```markdown
    ## Deployment

    We deploy on Cloudflare Pages with Workers functions. Budget is under
    $25/month. Team is experienced with JavaScript but has no Docker experience.
    ```

    ### Deviating from the default (document the blocking concern)

    #### Self-managed with deviation rationale

    ```markdown
    ## Deployment

    We deploy on a Hetzner VPS using Docker Compose. Deviation from serverless
    default: the application requires persistent WebSocket connections for
    real-time collaboration, and our existing Terraform + GitHub Actions pipeline
    is already production-proven.
    ```

    #### Mixed infrastructure with partial deviation

    ```markdown
    ## Deployment

    Stateless APIs and frontends deploy to Cloudflare Workers (serverless default).
    Stateful services (Postgres, Redis) run on a Hetzner VPS with Docker Compose.
    Deviation for stateful tier: persistent connections and data residency
    requirements.
    ```

    ### No preference

    Do not add a Deployment section at all. Section absence is the signal: agents default to serverless/managed platforms appropriate for your workload.
    ```

    ### "What this section is not" (lines 94-96)

    Replace: "The Deployment section is not an infrastructure blueprint or a binding contract. It gives agents enough context to make relevant recommendations. You are not committing to anything by writing it -- you are telling agents where you are starting from so they can meet you there."

    With: "The Deployment section is not an infrastructure blueprint or a binding contract. When present, it overrides or refines the system's serverless default -- it tells agents where you are starting from so they can meet you there. When absent, agents default to serverless/managed platforms appropriate for your workload."

    ## What NOT to do
    - Do not modify the Discoverability section
    - Do not modify the opening line or the back-link
    - Do not add any new sections
    - Keep the template block (```markdown ... ```) structure intact
- **Deliverables**: Updated `docs/claudemd-template.md` with serverless-default framing throughout.
- **Success criteria**: "When to omit" states omission = serverless default. Examples grouped into "confirming default" and "deviating from default." HTML comment references serverless default. "What this section is not" states absence = serverless default.

### Task 5: Add Decision 31 to decisions.md
- **Agent**: lucy
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are adding Decision 31 to the design decisions log. This entry documents the policy shift from topology-neutral (established in PR #123) to serverless-first-default.

    ## File
    `/Users/ben/github/benpeter/2despicable/4/docs/decisions.md`

    ## Change

    Add a new Decision 31 entry at the end of the file, following the existing format. The last decision is currently Decision 30.

    ```
    ### Decision 31: Serverless-First Default (Supersedes Topology-Neutral Stance)

    | Field | Value |
    |-------|-------|
    | **Status** | Implemented |
    | **Date** | 2026-02-14 |
    | **Supersedes** | Topology-neutral stance from PR #123 (2026-02-13 serverless-bias-correction advisory) |
    | **Choice** | Encode serverless-first as the system default. Agents default to serverless and require a documented blocking concern to deviate. Blocking concerns: persistent connections, long-running processes (>30s), compliance-mandated infrastructure control, measured cost optimization at scale, execution environment constraints (native binaries, CPU/memory beyond platform limits). |
    | **Alternatives rejected** | (1) Keep topology-neutral: rejected because false neutrality led to status-quo bias toward familiar infrastructure (Docker/Terraform) rather than criteria-driven evaluation. (2) Hard-block non-serverless: rejected because legitimate use cases (WebSockets, compliance, batch jobs) require non-serverless topologies. |
    | **Rationale** | Rooted in Helix Manifesto principles: "lean and mean" (serverless eliminates infrastructure management overhead) and "ops reliability wins" (managed platform reliability exceeds most self-managed setups). The question shifts from "which topology fits?" (neutral evaluation) to "why NOT serverless?" (justify deviation). This is a strong preference, not a hard block -- the five blocking concerns provide explicit escape hatches. |
    | **Consequences** | iac-minion Step 0 starts with serverless default and blocking concern gate. margo's complexity budget actively penalizes self-managed infrastructure when serverless alternative exists. CLAUDE.md template encodes serverless as the omission default. lucy enforces serverless-first compliance in plan reviews. Historical reports and the topology-neutral advisory are preserved as records of the prior stance -- they are not modified. |
    ```

    ## What NOT to do
    - Do not modify any existing decisions
    - Do not modify the file header or section headers
    - Follow the exact table format used by existing decisions
- **Deliverables**: Updated `docs/decisions.md` with Decision 31 entry.
- **Success criteria**: Decision 31 present with correct format. Supersedes field references PR #123. Alternatives include both topology-neutral and hard-block. Consequences list all four enforcement points.

### Task 6: Update lucy AGENT.md (serverless-first compliance check)
- **Agent**: lucy
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 4
- **Approval gate**: no
- **Prompt**: |
    You are adding a serverless-first compliance check to lucy's plan review behavior. This is a new check that fires when plans propose non-serverless infrastructure.

    ## File
    `/Users/ben/github/benpeter/2despicable/4/lucy/AGENT.md`

    ## Change 1: Add to "Common CLAUDE.md Directives to Check" (around line 109-117)

    Add a new bullet after the existing list:
    ```
    - Serverless-first default: when no Deployment section exists in a project's CLAUDE.md, the system default is serverless. Plans proposing non-serverless infrastructure must cite a documented blocking concern (persistent connections, long-running processes >30s, compliance-mandated control, measured cost at scale, execution environment constraints).
    ```

    ## Change 2: Add serverless-first compliance check to Compliance Verification Process (around lines 101-107)

    Add step 6 after step 5:
    ```
    6. Check serverless-first compliance: when a plan proposes non-serverless infrastructure and the project's CLAUDE.md has no Deployment section with documented deviation rationale, flag as ADVISE. If the project has a Deployment section with non-serverless choice but no blocking concern cited, flag as ADVISE requesting rationale. If the project explicitly documents a blocking concern, APPROVE. This check applies only when infrastructure decisions are part of the plan.
    ```

    ## Change 3: Update frontmatter

    - Change `x-build-date` to `"2026-02-14"`

    ## What NOT to do
    - Do not change lucy's identity or mission statement
    - Do not modify goal drift detection or alignment verification sections
    - Do not change the severity to BLOCK (ADVISE is correct for missing rationale)
    - Do not add new sections -- integrate into existing structure
    - Keep changes minimal
- **Deliverables**: Updated `lucy/AGENT.md` with serverless-first compliance check in two locations.
- **Success criteria**: Compliance Verification Process includes serverless-first step. Common CLAUDE.md Directives includes serverless-first default. Severity is ADVISE, not BLOCK.

### Task 7: Rebuild iac-minion via /despicable-lab (project skill)
- **Agent**: despicable-lab
- **Delegation type**: DEFERRED (project skill)
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1, Task 2
- **Approval gate**: no
- **Prompt**: |
    `/despicable-lab iac-minion`

    Rebuild iac-minion from the updated the-plan.md spec. The spec-version has been bumped to 2.1. The rebuild should produce an AGENT.md that reflects the serverless-first default established in the spec changes.

    NOTE: Task 2 has already made hand-edits to iac-minion/AGENT.md. The /despicable-lab rebuild should confirm these edits are consistent with the spec, or regenerate if needed. If the hand-edits in Task 2 are already consistent with the spec, /despicable-lab may determine no rebuild is necessary (versions already match).

    Since Task 2 directly edits AGENT.md to match the 2.1 spec and bumps x-plan-version, /despicable-lab --check should show iac-minion as current. Run the check to verify.
- **Deliverables**: Verified or rebuilt `minions/iac-minion/AGENT.md` consistent with the-plan.md spec 2.1.
- **Success criteria**: `/despicable-lab --check` shows iac-minion as current (x-plan-version matches spec-version).

### Cross-Cutting Coverage

- **Testing**: Not included. This task modifies agent system prompts and documentation -- no executable code is produced. Phase 6 (test execution) will find no test files to run.
- **Security**: Not included. No new attack surface, authentication, user input processing, or secrets management. The changes are to agent behavioral guidelines (Markdown text).
- **Usability -- Strategy**: Covered via the overall user journey: serverless-first reduces decision fatigue (fewer options to evaluate), aligns with Helix Manifesto latency principles, and preserves escape hatches. ux-strategy review is satisfied by the design decision resolutions above. No separate task needed -- this is an agent behavior change, not a user interface change.
- **Usability -- Design**: Not applicable. No user-facing interfaces are produced.
- **Documentation**: Covered by Tasks 4 (CLAUDE.md template), 5 (Decision 31), and the RESEARCH.md updates in Task 2. software-docs-minion not needed separately -- the documentation changes are embedded in the specialist tasks.
- **Observability**: Not applicable. No runtime components, APIs, or production services.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none
  - ux-design-minion: NO -- no UI components produced
  - accessibility-minion: NO -- no web-facing HTML/UI produced
  - sitespeed-minion: NO -- no web-facing runtime code produced
  - observability-minion: NO -- no runtime components needing coordinated logging/metrics
  - user-docs-minion: NO -- no end-user-facing behavior changes; the CLAUDE.md template is developer documentation (covered by software-docs aspects of Task 4)
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

1. **Edge-minion's mandatory edge-first tier vs. margo's simplicity principle**: Edge-minion proposed a mandatory edge-first evaluation step as a second tier within serverless. This would add decision complexity that margo would flag. **Resolution**: Edge-first is a recommendation within iac-minion's Step 0 ("prefer edge platforms when latency sensitivity is high"), not a mandatory gate. This preserves the value (latency alignment) without the complexity (extra decision tier).

2. **Edge-minion's 3 new blocking concerns vs. iac-minion's 4**: Edge-minion proposed three additions; iac-minion proposed zero changes to the list. **Resolution**: One of edge-minion's three (execution environment constraints) is genuinely distinct and included. Cold start latency is addressed by the edge recommendation, not a blocking concern. Storage access patterns are a data architecture decision (data-minion's domain), not a compute topology decision.

3. **Lucy's "Do NOT modify margo's boring technology assessment" vs. margo's own contribution**: No conflict -- both agree the Boring Technology Assessment heading "Topology-Neutral" is orthogonal to the serverless-first default and should not change.

### Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Over-rotation: serverless treated as dogma | MEDIUM | Blocking concern gate is checked first. Five explicit escape hatches. Framing is "start serverless, check for blockers" not "use serverless regardless." |
| Cost blocker requires measured data for new projects | LOW | Tier 2 validation dimensions inform implementation. Contractual commitments (committed volume) can trigger cost blocker without historical data. |
| Publishability regression: opinionated agents | MEDIUM | The default is a starting position with escape hatches. The CLAUDE.md template is voluntary -- projects adopt it. Agents can still handle non-serverless work. |
| Contradiction with PR #123 advisory | HIGH | Decision 31 explicitly documents supersession with rationale. Historical reports preserved unchanged. |
| Blocking concerns list maintenance | LOW | List is treated as living reference. gru owns technology assessment. Agents verify current platform limits via WebSearch for critical decisions. |
| the-plan.md requires human approval | HARD DEPENDENCY | Task 1 is gated. Tasks 2, 3, 7 are blocked until approval. Tasks 4, 5, 6 run in parallel (no the-plan.md dependency). |

### Execution Order

```
Batch 1 (parallel, no dependencies):
  Task 1: Update the-plan.md specs [iac-minion, opus] -- APPROVAL GATE
  Task 4: Rewrite CLAUDE.md template [lucy, opus]
  Task 5: Add Decision 31 [lucy, opus]

  --- GATE: Task 1 approval ---

Batch 2 (parallel, blocked by Task 1):
  Task 2: Rewrite iac-minion AGENT.md + RESEARCH.md [iac-minion, opus]
  Task 3: Update margo AGENT.md [margo, opus]

Batch 3 (blocked by Task 4):
  Task 6: Update lucy AGENT.md [lucy, opus]

Batch 4 (blocked by Tasks 1 + 2):
  Task 7: /despicable-lab --check iac-minion [DEFERRED, opus]

Git: commit and push to origin HEAD:nefario/fix-serverless-bias
```

### External Skills

| Skill | Classification | Tasks Using | Phases (ORCHESTRATION only) |
|-------|---------------|-------------|---------------------------|
| /despicable-lab | ORCHESTRATION | Task 7 | check, rebuild (if needed) |

### Verification Steps

1. `git diff nefario/fix-serverless-bias~7..HEAD` -- verify all changes are scoped to the expected files
2. iac-minion AGENT.md line 17 contains "serverless-first" (not "topology-neutral")
3. iac-minion Step 0 starts with blocking concern gate, not 10-dimension neutral evaluation
4. margo AGENT.md complexity budget section contains "Default to the managed/serverless column"
5. margo framing rule #1 mentions "self-managed infrastructure carries inherent operational overhead"
6. margo review checklist contains "serverless-first compliance" step
7. CLAUDE.md template "When to omit" says "the system default" for serverless
8. docs/decisions.md contains Decision 31 with "Supersedes" field
9. lucy AGENT.md contains serverless-first compliance check
10. `/despicable-lab --check` shows iac-minion as current
