## Delegation Plan

**Team name**: serverless-bias-fix
**Description**: Fix structural serverless bias in the agent system (GitHub issue #91). Four coordinated spec changes to the-plan.md, one CLAUDE.md template, edge-minion framing update, plus agent rebuilds.

---

### Conflict Resolutions

**Conflict 1: Delegation table row naming**

- edge-minion recommends "Serverless platform configuration" (describes the infrastructure setup work for serverless platforms).
- devx-minion recommends avoiding "serverless" in row names entirely (use task-type routing, not solution-category routing, consistent with existing table conventions).

**Resolution**: devx-minion's position wins. The existing delegation table uses task-type descriptions ("Infrastructure provisioning", "CI/CD pipelines", "Database selection & modeling"), not solution-category descriptions. A "Serverless platform deployment" row would break this convention and pre-classify work by solution before the strategy decision happens. The two new rows will be:

1. **"Deployment strategy selection"** -- the meta-decision of serverless vs. containers vs. hybrid. iac-minion primary, edge-minion supporting.
2. **"Platform deployment configuration"** -- setting up the chosen platform's deployment config (wrangler.toml, serverless.yml, SAM templates, Terraform for Lambda, docker-compose). iac-minion primary, edge-minion supporting.

"Platform deployment configuration" is platform-neutral phrasing (covers both serverless and container config) and describes a task type, not a solution category.

**Conflict 2: Nefario regeneration (scope expansion)**

- lucy flags that nefario/AGENT.md embeds the delegation table verbatim. Changing the table in the-plan.md without regenerating nefario means the deployed nefario routes from the stale table. lucy recommends either bumping nefario's spec-version to 2.1 or an explicit manual regen step.
- This was not in the original issue scope (iac-minion, margo, delegation table, CLAUDE.md template).

**Resolution**: Include nefario regeneration. lucy is correct that without this step the delegation table fix is dead on arrival. However, nefario's spec (its orchestration logic, working patterns, etc.) is NOT changing -- only embedded data changes. Rather than bumping nefario's spec-version (which would imply a spec change), include an explicit regeneration in the /despicable-lab task with a note explaining why. The despicable-lab rebuild step already rebuilds from the-plan.md; it will pick up the new table rows during regeneration.

**Conflict 3: Complexity budget model (margo vs. ai-modeling-minion)**

- margo proposes a two-column table (self-managed vs. managed/serverless) applied to the existing four categories, keeping the same conceptual model.
- ai-modeling-minion proposes splitting into two independent dimensions (build-time vs. operational), with new operational categories (self-managed infra: 8, managed service: 3, serverless: 1, etc.) and a lifetime weight multiplier.

**Resolution**: margo's two-column model wins for the spec. It is simpler, stays closer to the existing format, and follows margo's own principles (KISS). ai-modeling-minion's model adds valuable concepts (build-time vs. operational distinction, lifetime weighting) but encodes too much scoring machinery for a heuristic budget. The synthesis takes three things from ai-modeling-minion's contribution: (1) the shared vocabulary (self-managed, managed, serverless) for cross-agent coherence, (2) the principle that operational complexity is "paid continuously" (as framing rationale in the spec, not as a formula), and (3) the requirement that agents state their selection and reasoning explicitly. The two-column table from margo, augmented with the infrastructure proportionality heuristic, provides sufficient recalibration without over-engineering the assessment tool.

---

### Task 1: Update iac-minion spec in the-plan.md

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This is the foundational spec change. All other tasks depend on its design decisions (deployment strategy framework, remit expansion, boundary clarification). Hard to reverse once downstream agents are built from it.
- **Prompt**: |
    You are updating the iac-minion specification in `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 722-748) to address the structural serverless bias identified in GitHub issue #91.

    ## What to change

    1. **Expand the Remit** to include serverless platforms as a peer technology alongside Docker and Terraform. Add these bullet points:
       - "Serverless platforms (AWS Lambda, Cloudflare Workers/Pages, Cloud Functions, Vercel Functions)"
       - "Deployment strategy selection (evaluating serverless vs. container vs. self-managed for a given workload)"

    2. **Update the Domain line** to include serverless. Change from:
       "Infrastructure as Code, CI/CD, containerization, deployment"
       to:
       "Infrastructure as Code, CI/CD, containerization, serverless platforms, deployment"

    3. **Add to "Does NOT do"** a boundary clarification with edge-minion:
       "Edge-layer runtime behavior (caching strategy, edge function optimization, CDN routing rules) (-> edge-minion)"
       This clarifies the boundary: iac-minion handles where/how code deploys (including to serverless platforms); edge-minion handles how it runs well at the edge once deployed.

    4. **Expand the Research Focus** to include:
       "Serverless deployment patterns, cold start optimization, FaaS cost modeling, serverless vs. container decision criteria, when serverless is inappropriate (long-running processes, stateful workloads, cold-start-sensitive workloads)"

       Note the explicit inclusion of "when serverless is inappropriate" -- this ensures the research and resulting AGENT.md cover both directions, preventing opposite-bias.

    5. **Bump spec-version** from 1.0 to 1.1

    ## Framing constraints (critical)

    - Do NOT add language like "prefer serverless" or "default to serverless for simple workloads." The spec teaches the domain without encoding a preference.
    - Do NOT remove existing Docker/Terraform/reverse proxy content. Serverless is additive.
    - The spec describes WHAT iac-minion knows and does. The deployment strategy decision framework (five-criteria decision tree, "Step 0" before infrastructure design) will be built into the AGENT.md by /despicable-lab from the spec + research. The spec's Research Focus guides what research is gathered; the Working Patterns in the built AGENT.md will contain the procedural framework.
    - Keep the change minimal and surgical per the project's KISS philosophy.

    ## Boundary clarification rationale

    The iac-minion / edge-minion boundary follows this principle:
    - iac-minion: "where does it run and how does it get there" (deployment target selection, CI/CD pipelines, infrastructure-as-code, platform configuration)
    - edge-minion: "how does it run well once it's there" (caching, routing, edge functions, storage bindings, runtime optimization)

    For shared config files (wrangler.toml, serverless.yml): iac-minion owns the file structurally (deployment targets, bindings, resource definitions); edge-minion reviews/advises on edge-specific runtime settings.

    ## What NOT to do

    - Do not modify any other agent's spec section
    - Do not modify the delegation table (that is a separate task)
    - Do not add platform-specific implementation details (those go in RESEARCH.md and AGENT.md via the build pipeline)
    - Do not write an exhaustive serverless catalog -- cover the major platforms and patterns per YAGNI

    ## Files to modify

    - `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 722-748 only -- the iac-minion spec section)

    ## Deliverables

    - Updated iac-minion spec section in the-plan.md with expanded remit, updated domain, boundary clarification, expanded research focus, and bumped spec-version.

- **Deliverables**: Updated iac-minion spec section in the-plan.md
- **Success criteria**: (1) iac-minion remit includes serverless platforms and deployment strategy selection, (2) "Does NOT do" clarifies edge-minion boundary, (3) research focus includes both "when serverless wins" and "when serverless is wrong" topics, (4) no prescriptive bias toward any deployment topology, (5) spec-version is 1.1, (6) existing Docker/Terraform content is preserved.

---

### Task 2: Update margo spec in the-plan.md

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: margo's complexity budget is used in every governance review. Changes to how complexity is scored affect all future plans. Hard to reverse once agents internalize the new scoring model.
- **Prompt**: |
    You are updating the margo specification in `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 537-570) to address the structural serverless bias identified in GitHub issue #91.

    ## What to change

    1. **Expand the Remit** bullet "Reviewing plans for unnecessary complexity" to explicitly include:
       "Reviewing plans for unnecessary complexity, including infrastructure overhead and operational burden"

    2. **Add to Research Focus**: "Operational complexity metrics, build-time vs. run-time complexity tradeoffs, infrastructure proportionality patterns, boring technology assessment for managed platforms"

    3. **Bump spec-version** from 1.0 to 1.1

    ## Design intent for the AGENT.md build (guidance for /despicable-lab, encoded via spec)

    The following concepts should be reflected in the expanded research focus and remit so that the /despicable-lab build pipeline produces an AGENT.md with:

    a. **Two-column complexity budget**: The existing four-category budget (new technology: 10, new service: 5, new abstraction layer: 3, new dependency: 1) gets a second column distinguishing self-managed from managed/serverless. Managed services score lower because operational burden is eliminated, but never score zero (configuration complexity, vendor failure modes, and cognitive load remain). Approximate managed column: 5, 2, 3, 1 (abstraction layers and dependencies are code-level costs that don't change with hosting).

    b. **Boring technology assessment that is topology-neutral**: A managed platform qualifies as "boring" when it meets the same criteria as any technology: production-hardened (5+ years widespread use), well-understood failure modes, staffable talent, well-documented. Examples: AWS Lambda (2014), Vercel (2015), Cloudflare Workers (2018). The assessment is about unfamiliarity and unproven failure modes, not about where the code runs.

    c. **Infrastructure proportionality heuristic**: Five concrete signals that infrastructure complexity may be disproportionate to the problem: (1) deploy pipeline exceeds application code for a small project, (2) scaling machinery without scale evidence, (3) ops surface exceeds team capacity, (4) >5 infrastructure config files for a 1-2 file deploy, (5) deployment ceremony requiring >3 steps when git-push deploy suffices. These are investigation signals, not automatic vetoes.

    d. **Framing rules**: (1) Margo flags disproportion, not topology. (2) Margo scores complexity honestly regardless of topology -- serverless is not a complexity exemption. (3) Margo asks "is this complexity justified?" not "is this the right platform?" (4) When margo identifies disproportionate infrastructure and alternatives should be evaluated, handoff to gru -- margo names the problem, gru names the solution.

    e. **Shared vocabulary**: Use "self-managed", "managed", "serverless/fully managed" as the three-tier deployment vocabulary. This aligns with iac-minion's deployment strategy categories so the two agents reinforce each other through shared terminology without direct cross-references.

    ## Constraints (critical)

    - This is a SURGICAL change. Do not rewrite margo's simplicity philosophy, YAGNI enforcement, or overall approach.
    - The change adjusts what margo evaluates (adding operational burden alongside novelty) and how (two-column budget, infrastructure proportionality). It does NOT change margo's fundamental role or principles.
    - Do NOT make margo aware of iac-minion's decision framework. Each agent remains a specialist in its own domain. Alignment happens through shared vocabulary, not shared logic.
    - Do NOT add a numeric complexity threshold. Keep the "proportional to problem size" framing.
    - Do NOT add technology-specific scoring to the spec (no "serverless = 1 point"). Technology-specific detail belongs in the AGENT.md via the research/build pipeline.

    ## What NOT to do

    - Do not modify any other agent's spec section
    - Do not modify the delegation table
    - Do not rewrite existing margo principles or "Does NOT do" section

    ## Files to modify

    - `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 537-570 only -- the margo spec section)

    ## Deliverables

    - Updated margo spec section in the-plan.md with expanded remit, expanded research focus, and bumped spec-version.

- **Deliverables**: Updated margo spec section in the-plan.md
- **Success criteria**: (1) Remit explicitly mentions infrastructure overhead and operational burden, (2) research focus includes operational complexity and infrastructure proportionality, (3) spec-version is 1.1, (4) no wholesale rewrite of margo's philosophy, (5) no direct references to iac-minion's framework.

---

### Task 3: Update edge-minion spec in the-plan.md

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are making a minimal framing update to the edge-minion specification in `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 751-784) to acknowledge full-stack serverless platforms.

    ## What to change

    1. **Add one sentence to the Remit section** (after the existing bullet list) or as a new bullet:
       "Cloudflare Workers/Pages, Vercel, and Netlify function as full-stack serverless platforms. Edge-minion covers edge-layer behavior (caching, routing, edge functions, storage bindings) on these platforms; deployment strategy and CI/CD are iac-minion's domain."

    2. **Add to "Does NOT do"**:
       "Full-stack serverless deployment configuration (Vercel project settings, Netlify build config, wrangler.toml deployment targets) (-> iac-minion). Edge-minion covers edge runtime behavior on these platforms."

    3. **Bump spec-version** from 1.0 to 1.1

    ## Constraints

    - This is a MINIMAL framing change. Do not expand edge-minion's remit.
    - Do not add new technology coverage. The research and AGENT.md already cover Cloudflare Workers/Pages thoroughly.
    - The purpose is boundary clarification with the newly-expanded iac-minion, not capability expansion.

    ## What NOT to do

    - Do not modify any other agent's spec section
    - Do not add deployment strategy content (that is iac-minion's domain)
    - Do not rewrite existing edge-minion content

    ## Files to modify

    - `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 751-784 only -- the edge-minion spec section)

- **Deliverables**: Updated edge-minion spec section with full-stack serverless acknowledgment and boundary clarification
- **Success criteria**: (1) One sentence acknowledging full-stack serverless platforms, (2) "Does NOT do" clarifies deployment config belongs to iac-minion, (3) spec-version is 1.1, (4) no remit expansion.

---

### Task 4: Update delegation table in the-plan.md

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1 (needs iac-minion's expanded remit finalized first)
- **Approval gate**: no
- **Prompt**: |
    You are adding two rows to the delegation table in `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (the table starts at line 299).

    ## What to add

    Add these two rows to the **Infrastructure & Data** section of the delegation table, after the existing "Infrastructure provisioning" row (line 310):

    | Deployment strategy selection | iac-minion | edge-minion, devx-minion |
    | Platform deployment configuration | iac-minion | edge-minion |

    ## Row definitions

    1. **Deployment strategy selection**: The meta-decision of whether a workload should use serverless, containers, managed containers, or static hosting. This is the "Step 0" before infrastructure design. edge-minion supports because edge/serverless platforms straddle the boundary. devx-minion supports because developer experience (time-to-first-deploy, operational burden) is a decision input.

    2. **Platform deployment configuration**: Setting up the chosen platform's deployment configuration -- wrangler.toml for Cloudflare, serverless.yml for AWS, SAM templates, Terraform for Lambda, docker-compose for containers. This is platform-neutral phrasing that covers both serverless and container config. edge-minion supports for edge-specific settings review.

    ## Naming rationale

    These rows follow the existing table convention of using task-type descriptions (what the developer needs done), not solution-category descriptions (what technology is used). "Deployment strategy selection" describes a decision task. "Platform deployment configuration" describes a setup task. Neither pre-classifies by serverless/container.

    ## What NOT to do

    - Do not modify any existing rows in the delegation table
    - Do not add rows outside the Infrastructure & Data section
    - Do not modify any agent spec sections

    ## Files to modify

    - `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (delegation table, lines 299-390, specifically inserting after line 310)

- **Deliverables**: Two new rows in the delegation table under Infrastructure & Data
- **Success criteria**: (1) Two rows added with correct primary/supporting assignments, (2) rows use task-type naming convention, (3) existing rows unmodified.

---

### Task 5: Create CLAUDE.md deployment template

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are creating a CLAUDE.md template document for target projects that want to signal their deployment preferences to the despicable-agents team.

    ## What to create

    Create `/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md` containing a documented `## Deployment` section that target projects can add to their CLAUDE.md.

    ## Template design requirements

    1. **Format**: Follow existing docs/ conventions:
       - First line: `[< Back to Architecture Overview](architecture.md)`
       - Second line: `# CLAUDE.md Template: Deployment Section`
       - Content follows after the heading

    2. **The template section itself** should be a single optional `## Deployment` section written in Markdown prose (not YAML, not JSON, not structured key-value pairs). CLAUDE.md is read by LLMs, not parsed by machines.

    3. **Template content**: A one-sentence declaration ("We deploy on [platform/approach].") followed by HTML comments showing optional context signals. The comments serve as guidance without cluttering the actual CLAUDE.md when filled in:

       ```markdown
       ## Deployment

       <!-- Optional. Omit this section entirely if you have no deployment
            preferences -- the agent team will recommend the simplest viable
            approach for each task. -->

       We deploy on [platform/approach].

       <!-- Add any of these that are relevant to your project: -->
       <!-- Existing infrastructure: "We already run Docker Compose on Hetzner"
            or "We have a Terraform setup in AWS" -->
       <!-- Constraints: "Must stay on AWS" or "No vendor lock-in" or
            "Budget under $20/month" -->
       <!-- Team context: "Team has no Docker experience" or "We are comfortable
            with Kubernetes" -->
       <!-- Preferences: "Prefer managed/serverless where possible" or
            "We self-host for data sovereignty" -->
       ```

    4. **Three filled examples** showing different specificity levels, each with equal weight (no bias toward any topology):
       - Specific platform (serverless): "We deploy on Cloudflare Pages with Workers functions. Budget under $25/month. Team is experienced with JavaScript but has no Docker experience."
       - Specific platform (self-managed): "We deploy on a Hetzner VPS using Docker Compose. We have an existing Terraform setup and CI/CD pipeline via GitHub Actions."
       - General preference: "Keep deployments simple -- prefer managed platforms where possible. We're a small team (2 developers) and cannot maintain infrastructure."
       - No preference (explain that section absence is the signal)

    5. **Surrounding context**: The doc should explain:
       - This is an OPTIONAL section to add to an existing CLAUDE.md, not a standalone file
       - When no Deployment section is present, agents recommend the simplest viable approach without asking, stating their reasoning so the user can redirect
       - Existing infrastructure artifacts (Dockerfile, terraform/, wrangler.toml, docker-compose.yml) serve as implicit signals even without a Deployment section
       - The section captures preferences and context, not decisions -- the agent team makes the technical recommendation

    6. **Default behavior explanation**: When no deployment preference is stated:
       - Agents recommend simplest-viable without asking
       - Agents state what they chose and why, briefly
       - Agents check for existing infrastructure artifacts as implicit signals
       - The default is "simplest viable" (a DX principle), not "serverless" (an implementation category)

    ## What NOT to do

    - Do not create an opinionated infrastructure blueprint
    - Do not include enumerated fields to fill in (every field creates a decision the user must make)
    - Do not include platform rankings or recommendations
    - Do not include any PII or project-specific data (Apache 2.0 publishable)
    - Do not recommend specific providers or runtimes in the template itself
    - Do not lean examples toward any particular topology -- equal representation

    ## Files to create

    - `/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md`

- **Deliverables**: docs/claudemd-template.md with the deployment section template and guidance
- **Success criteria**: (1) Follows docs/ conventions (back-link, heading format), (2) template is declarative prose not structured data, (3) three examples showing different topologies with equal weight, (4) explains default behavior when section is absent, (5) no platform bias.

---

### Task 6: Check and update docs for staleness

- **Agent**: lucy
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1, Task 2, Task 3, Task 4
- **Approval gate**: no
- **Prompt**: |
    After the spec and delegation table changes have been made to the-plan.md, review the following documentation files for staleness and update any references that have become inaccurate:

    ## Files to check

    1. `/Users/ben/github/benpeter/2despicable/4/docs/agent-catalog.md` -- May reference iac-minion's capabilities or margo's complexity budget. Update if it lists remit items that changed.
    2. `/Users/ben/github/benpeter/2despicable/4/docs/orchestration.md` -- May contain delegation-related content or routing references. Update if it duplicates or references specific delegation table entries.
    3. `/Users/ben/github/benpeter/2despicable/4/docs/architecture.md` -- Hub document. Check if it needs a reference to the new claudemd-template.md.
    4. `/Users/ben/github/benpeter/2despicable/4/docs/deployment.md` -- Check if deployment-related content needs updating given the expanded iac-minion scope.

    ## What to do

    For each file:
    1. Read the file
    2. Identify any content that references iac-minion capabilities, margo's complexity budget, edge-minion's scope, or delegation routing that would now be stale
    3. Make minimal, surgical updates to fix staleness
    4. If a file needs no changes, skip it

    ## What NOT to do

    - Do not rewrite documentation beyond what is needed for accuracy
    - Do not add new documentation sections
    - Do not modify the-plan.md or any AGENT.md files

- **Deliverables**: Updated docs files (only those that were stale)
- **Success criteria**: (1) No docs reference outdated iac-minion capabilities, (2) delegation routing references are current, (3) architecture.md references claudemd-template.md if appropriate, (4) changes are minimal.

---

### Task 7: Rebuild affected agents via /despicable-lab

- **Agent**: (DEFERRED -- /despicable-lab project skill)
- **Delegation type**: DEFERRED (project skill)
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1, Task 2, Task 3, Task 4, Task 6
- **Approval gate**: no (the upstream spec changes are already gated)
- **Prompt**: |
    Rebuild the following agents whose specs have changed or whose embedded data has changed:

    1. **iac-minion** -- spec-version bumped from 1.0 to 1.1 (remit expansion, new research focus)
    2. **margo** -- spec-version bumped from 1.0 to 1.1 (complexity budget recalibration, new research focus)
    3. **edge-minion** -- spec-version bumped from 1.0 to 1.1 (framing update, boundary clarification)
    4. **nefario** -- spec-version unchanged (still 2.0), but the delegation table embedded in nefario/AGENT.md has changed. Two new rows were added to the delegation table in the-plan.md. Without regeneration, the deployed nefario routes from the stale table. This is a data-staleness rebuild, not a spec-change rebuild. Force regeneration even if spec-version has not diverged.

    Run /despicable-lab to rebuild all four agents. The build pipeline will:
    - Step 1: Research (gather updated domain knowledge based on new research focus items)
    - Step 2: Build (generate AGENT.md from spec + research)
    - Step 3: Cross-check (verify internal consistency)

    After rebuild, verify that:
    - iac-minion/AGENT.md x-plan-version matches spec-version 1.1
    - margo/AGENT.md x-plan-version matches spec-version 1.1
    - edge-minion/AGENT.md x-plan-version matches spec-version 1.1
    - nefario/AGENT.md contains the two new delegation table rows
    - iac-minion/AGENT.md Working Patterns include a deployment strategy selection step before infrastructure design
    - margo/AGENT.md Complexity Budget has two-column scoring
    - margo/AGENT.md has an Infrastructure Proportionality section

    ## Available Skills
    The following project skill is available for this task:
    - despicable-lab: `.claude/skills/despicable-lab/` (agent build/rebuild pipeline)

- **Deliverables**: Rebuilt AGENT.md files for iac-minion, margo, edge-minion, nefario
- **Success criteria**: (1) x-plan-version matches spec-version for all three spec-bumped agents, (2) nefario/AGENT.md contains new delegation table rows, (3) iac-minion has deployment strategy selection in Working Patterns, (4) margo has two-column complexity budget and infrastructure proportionality heuristic.

---

### Cross-Cutting Coverage

- **Testing** (test-minion): Not included in execution. This task modifies specification documents (the-plan.md) and documentation (docs/), not executable code. The /despicable-lab build pipeline has its own cross-check phase (Step 3) which validates internal consistency. Phase 6 post-execution testing will verify the built agents.
- **Security** (security-minion): Not included in execution. No attack surface, authentication, user input, secrets, or infrastructure changes. The changes are to agent specification text. Security review is covered by Phase 3.5 mandatory review.
- **Usability -- Strategy** (ux-strategy-minion): Covered in Phase 3.5 mandatory review. The CLAUDE.md template (Task 5) is a user-facing configuration artifact whose discoverability and clarity should be reviewed. ux-strategy-minion will evaluate the template's progressive disclosure and cognitive load properties.
- **Usability -- Design** (ux-design-minion, accessibility-minion): Not included. No user-facing interfaces are produced. The CLAUDE.md template is a text document, not a UI.
- **Documentation** (software-docs-minion / user-docs-minion): Covered by Task 6 (staleness check). The CLAUDE.md template (Task 5) IS the documentation deliverable. Post-execution Phase 8 will handle any remaining documentation needs.
- **Observability** (observability-minion, sitespeed-minion): Not included. No runtime components, APIs, or web-facing services produced.

---

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - **user-docs-minion**: The CLAUDE.md template (Task 5) changes what users need to learn about configuring deployment preferences. Early review ensures the template is discoverable and the default behavior explanation is clear. References Task 5.
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion (no UI, no web-facing runtime, no services produced)

---

### Risks and Mitigations

| ID | Risk | Severity | Mitigation |
|----|------|----------|------------|
| R1 | Over-correction: serverless gets a free pass in margo's budget | Medium | Two-column model still charges points per managed service (2 each). Sprawling serverless architectures (6 services) still accumulate 12+ points. Infrastructure proportionality heuristic applies to all topologies. |
| R2 | Boundary ambiguity between iac-minion and edge-minion on shared config files (wrangler.toml) | Medium | Both specs will clarify: iac-minion owns files structurally, edge-minion reviews/advises on edge-specific settings. Documented in both "Does NOT do" sections. |
| R3 | Nefario AGENT.md not regenerated despite delegation table change | High | Explicitly included as a rebuild target in Task 7 with a note explaining the data-staleness (not spec-change) reason. |
| R4 | CLAUDE.md template examples inadvertently bias toward one topology | Low | Task 5 prompt requires three examples with equal weight: one serverless, one self-managed, one general preference. devx-minion is the right agent for template ergonomics. |
| R5 | "Managed" is not binary -- hybrid cases exist (ECS = partially managed) | Low | The two-column model is acknowledged as approximate. margo's AGENT.md should note that teams use judgment for hybrid cases. This is acceptable for a heuristic budget. |
| R6 | Research quality determines AGENT.md quality for iac-minion's new serverless coverage | Medium | Spec's research focus explicitly includes both "serverless vs. container decision criteria" and "when serverless is inappropriate", ensuring balanced research input for the build pipeline. |
| R7 | Docs staleness in agent-catalog.md and orchestration.md | Low | Task 6 explicitly checks these files. |
| R8 | Delegation table routing ambiguity between "Deployment strategy selection" and "Infrastructure provisioning" | Low | "Deployment strategy selection" is the pre-infrastructure meta-decision. "Infrastructure provisioning" is execution of the chosen strategy. The distinction is decision vs. implementation. |

---

### Execution Order

```
Batch 1 (parallel, gated):
  Task 1: iac-minion spec update        [APPROVAL GATE]
  Task 2: margo spec update             [APPROVAL GATE]
  Task 3: edge-minion spec update       (no gate)
  Task 5: CLAUDE.md template            (no gate)

Batch 2 (after Task 1 approved):
  Task 4: delegation table update       (no gate)

Batch 3 (after Tasks 1-4 complete):
  Task 6: docs staleness check          (no gate)

Batch 4 (after Tasks 1-4, 6 complete):
  Task 7: /despicable-lab rebuild       [DEFERRED skill] (no gate)
```

**Gate positions**: Tasks 1 and 2 are the only gates. They are the foundational design decisions that all downstream work depends on. Task 3 (edge-minion framing) is a minimal boundary clarification that follows from Task 1. Task 4 (delegation table) follows from Task 1. Task 5 (template) is independently verifiable. Task 7 (rebuild) builds from the approved specs.

---

### External Skills

| Skill | Classification | Tasks Using | Phases (ORCHESTRATION only) |
|-------|---------------|-------------|---------------------------|
| /despicable-lab | ORCHESTRATION | Task 7 | Research, Build, Cross-check |

---

### Verification Steps

After all tasks complete:

1. **Spec consistency**: Verify iac-minion spec-version 1.1, margo spec-version 1.1, edge-minion spec-version 1.1 in the-plan.md
2. **Delegation table**: Verify two new rows exist under Infrastructure & Data with correct primary/supporting assignments
3. **AGENT.md builds**: Verify x-plan-version matches spec-version for iac-minion, margo, edge-minion
4. **Nefario table**: Verify nefario/AGENT.md contains "Deployment strategy selection" and "Platform deployment configuration" rows
5. **iac-minion neutrality**: Verify iac-minion/AGENT.md Working Patterns include a deployment strategy selection step with criteria-based evaluation (not "prefer serverless")
6. **Margo recalibration**: Verify margo/AGENT.md has two-column complexity budget and infrastructure proportionality section
7. **Edge-minion boundary**: Verify edge-minion/AGENT.md "Does NOT do" includes deployment configuration handoff to iac-minion
8. **Template**: Verify docs/claudemd-template.md exists with balanced examples
9. **Docs freshness**: Verify no stale references in docs/agent-catalog.md, docs/orchestration.md
10. **No opposite bias**: Read iac-minion/AGENT.md end-to-end and confirm it does not default to serverless -- it should evaluate workload criteria neutrally
