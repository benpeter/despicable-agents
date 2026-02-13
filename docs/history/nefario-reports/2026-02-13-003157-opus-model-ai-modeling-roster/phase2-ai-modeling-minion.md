# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### (a) Decision Framework Encoding for iac-minion

The iac-minion's current Core Knowledge section is organized by technology (Terraform, Docker, GitHub Actions, Reverse Proxy, Cloud Providers) -- every section assumes containers and managed VMs. There is no deployment strategy selection step; the agent jumps straight to "how to Docker" rather than "should we Docker." The Working Patterns section (`Infrastructure Design Approach`) lists seven steps, and step 3 is "Choose compute resources (instance types, scaling strategy, container orchestration)" -- this hardcodes the assumption that the answer involves instances and containers.

**Recommendation: Add a deployment strategy selection framework as Step 0 in Working Patterns, not as a scoring rubric buried in Core Knowledge.**

Placing the decision framework in Working Patterns (section 3 of the five-section prompt structure) is critical. Claude 4.x models follow instructions literally and sequentially. If the working pattern says "Step 1: gather requirements, Step 2: select deployment strategy, Step 3: design infrastructure for that strategy," the agent will evaluate the strategy question before committing to a technology. If the framework is only in Core Knowledge (section 2), it becomes reference material the agent can cite but will not reliably invoke procedurally.

**Framework structure -- use a requirements-first decision tree, not a technology comparison table:**

```
### Deployment Strategy Selection

Before designing infrastructure, determine the deployment strategy. Evaluate the
workload against these criteria:

1. **Execution model**: Is this request-driven (HTTP, events, scheduled) or
   long-running (persistent connections, background workers, stateful sessions)?
2. **State requirements**: Does the workload need local disk, in-memory state
   across requests, or persistent connections? Or is it stateless per invocation?
3. **Scaling pattern**: Bursty with idle periods? Steady baseline? Predictable
   schedule?
4. **Cold start tolerance**: Can the workload absorb 100-500ms startup latency?
   Or must it maintain sub-50ms response times at all times?
5. **Runtime constraints**: Does it need custom binaries, specific OS packages,
   GPU access, or long execution times (>15 minutes)?

Match results to deployment strategy:
- **Serverless functions** (Lambda, Cloud Functions, Workers): request-driven +
  stateless + bursty/idle + cold-start tolerant + no exotic runtime needs
- **Managed containers** (ECS Fargate, Cloud Run, Fly.io): request-driven or
  long-running + stateless or light state + steady or bursty + cold-start
  sensitive OR needs custom runtime
- **Self-managed containers** (Docker on VMs, Kubernetes): long-running +
  stateful + steady baseline + needs full control over runtime, networking,
  or storage
- **Static hosting** (S3+CloudFront, Cloudflare Pages, GitHub Pages): no
  server-side logic at runtime

State your selection and reasoning before proceeding to infrastructure design.
```

**Why this structure works for prompt compliance:**

1. **Numbered criteria force sequential evaluation.** The agent must answer five questions before reaching the match table. This prevents the model from pattern-matching on a keyword ("deploy") and jumping to Docker.

2. **The match table uses property combinations, not technology names.** This prevents the framework from becoming a lookup table that always returns the same answer. The agent must synthesize multiple signals.

3. **"State your selection and reasoning" is an explicit output instruction.** Claude 4.x models will produce what you ask for. Without this line, the agent might internalize the selection but not make it visible, making it impossible for margo or the human to audit the decision.

4. **The criteria are workload-centric, not technology-centric.** This prevents the opposite bias problem -- the agent evaluates the workload, not its own technology preferences.

**Anti-pattern to avoid: Do not use a weighted scoring matrix.** Scoring matrices in prompts (e.g., "rate each factor 1-5, add up, highest wins") produce inconsistent results because the model applies weights subjectively and inconsistently across contexts. Decision trees with discrete branches are more reliable.


### (b) Opposite-Bias Prevention

The constraint "do NOT hardcode serverless-first" is a prompt engineering problem of encoding neutrality between two valid defaults. Three techniques:

**Technique 1: Require explicit justification for any selection.**

In the Working Patterns framework above, the line "State your selection and reasoning" is the key. By requiring the agent to articulate *why* it chose a strategy, it cannot silently default. The reasoning becomes auditable. If the agent consistently says "serverless because it is simpler" without engaging the five criteria, the prompt needs tuning -- but the reasoning makes the bias visible.

**Technique 2: Frame as diagnosis, not prescription.**

The prompt should say "determine the deployment strategy" (diagnostic framing), not "consider whether serverless would be simpler" (prescriptive framing). Diagnostic framing keeps the agent in evaluation mode. Prescriptive framing introduces anchoring bias toward whatever option is named first.

In the iac-minion spec and research focus, do NOT add language like "prefer serverless when possible" or "default to serverless for simple workloads." Instead, add "serverless platforms (AWS Lambda, Cloudflare Workers, Vercel)" to the Remit bullet list as a peer technology alongside Docker and Terraform, and add "serverless deployment patterns, cold start optimization, function-as-a-service cost modeling" to the Research Focus. This teaches the domain without encoding a preference.

**Technique 3: Include examples of both directions in the research focus.**

The RESEARCH.md (which feeds the AGENT.md build) should include examples where serverless wins AND examples where containers win. The build step distills research into Core Knowledge, and if both outcomes are represented in the knowledge base, the agent will not default to either. Specifically, the research focus should include:

- "Serverless vs. container decision criteria"
- "When serverless is wrong: long-running processes, stateful workloads, cold start sensitivity"
- "When containers are wrong: idle compute cost, operational burden for simple workloads"

This gives the `/despicable-lab` builder material for both sides of the decision.


### (c) Complexity Scoring in Margo's Prompt

Margo's current Complexity Budget (lines 55-62 of AGENT.md) uses a point system:

```
- New technology: 10 points
- New service: 5 points
- New abstraction layer: 3 points
- New dependency: 1 point
```

The problem: this scoring penalizes novelty (new technology = 10 points) but does not capture operational burden. A Terraform+Docker+VM stack that is "boring" technology scores 0 on the technology axis but imposes significant ongoing operational cost (patching, monitoring, scaling, on-call). A serverless function that uses a new-to-the-team platform scores 10 points for novelty but has near-zero operational burden.

**Recommendation: Add an operational dimension to the complexity budget, not replace the novelty dimension.**

```
### Complexity Budget

Every project has a finite complexity budget. Approximate costs:

**Build-time complexity** (paid once):
- New technology to the team: 10 points (learning curve, unfamiliar failure modes)
- New service boundary: 5 points (deployment pipeline, networking, monitoring setup)
- New abstraction layer: 3 points (indirection, cognitive load)
- New dependency: 1 point (supply chain risk, upgrade burden)

**Operational complexity** (paid continuously):
- Self-managed infrastructure: 8 points per component (patching, scaling, monitoring, on-call)
- Managed service with SLA: 3 points per service (vendor lock-in, configuration drift)
- Serverless / fully managed: 1 point per function (cold starts, platform limits)
- Manual deployment process: 5 points (human error, availability)
- Automated deployment pipeline: 2 points (pipeline maintenance)

Total complexity = build-time + (operational x expected project lifetime weight).
For projects expected to run >1 year, weight operational 2x. For short-lived
projects (<3 months), weight build-time 2x.

When budget is exhausted, simplify before adding more. Every addition must
justify its budget spend against actual requirements.
```

**Why this encoding works:**

1. **Two dimensions prevent single-axis optimization.** The agent cannot game the budget by always picking the "least novel" option (which is what happens now) or the "least operational" option (which would create a serverless bias).

2. **The lifetime weight introduces context sensitivity.** The agent must consider whether the project is a weekend prototype or a multi-year production service. This is the kind of nuanced judgment that simple point systems miss.

3. **Concrete anchors (8, 3, 1) prevent subjective drift.** Without specific numbers, the model will invent its own scale and apply it inconsistently. The exact numbers matter less than their relative ordering being correct and stable.

4. **The "paid once" vs. "paid continuously" framing explains the WHY.** Claude 4.x follows rules better when it understands the reasoning. "Operational complexity is paid continuously" tells the model why 8 points for self-managed infrastructure is justified, making it more likely to apply the score correctly in ambiguous cases.

**Risk: point inflation.** With two dimensions, total scores will be higher. Margo's threshold for "budget exhausted" needs recalibration. I recommend not setting a numeric threshold in the prompt. Instead, keep the instruction "is the budget proportional to the problem size?" which forces relative assessment rather than absolute cutoffs. Absolute cutoffs break when the scoring system changes.


### (d) Cross-Agent Coherence Between iac-minion and margo

The current system has iac-minion and margo operating independently. Their specs do not reference each other's decision frameworks. This creates a risk: iac-minion selects a deployment strategy for workload reasons, and margo evaluates that selection using a complexity framework that has different criteria. They could reach contradictory conclusions.

**Recommendation: Align on a shared vocabulary, not shared logic.**

Do NOT make iac-minion aware of margo's scoring, and do NOT make margo aware of iac-minion's decision tree. Each agent should remain a specialist in its own domain. Instead, align them through shared terminology:

1. **iac-minion outputs its reasoning using the five criteria** (execution model, state requirements, scaling pattern, cold start tolerance, runtime constraints). This is its natural output from the decision framework.

2. **Margo's operational complexity dimension uses the same deployment categories** (self-managed infrastructure, managed service, serverless/fully managed). When margo scores operational complexity, she uses the same three-tier model that iac-minion uses to select strategy.

3. **The connection point is the deployment category name.** iac-minion says "I selected managed containers because the workload is long-running with custom runtime needs." Margo says "Managed containers score 3 operational points per service -- proportional for this problem." They reinforce each other because they share the category vocabulary, even though they evaluate it from different angles (workload fit vs. complexity cost).

**What to avoid:**

- Do NOT add "check with margo" instructions to iac-minion or "check with iac-minion" to margo. Cross-agent awareness creates coupling that breaks when either agent is updated independently.
- Do NOT duplicate the decision framework in margo's prompt. Margo evaluates complexity, not deployment strategy. If margo starts second-guessing strategy selection, the boundary between the two agents collapses.
- Do NOT add a "deployment strategy review" row to margo's Working Patterns. Margo reviews all plans for complexity -- deployment strategy is just one thing she evaluates, using her general complexity budget framework.

**The delegation table already handles coordination.** Nefario routes "infrastructure provisioning" to iac-minion (primary) with security-minion (supporting). Margo enters the picture during governance review, which happens after iac-minion produces a plan. The sequence is: iac-minion proposes -> margo evaluates -> nefario synthesizes. No spec changes needed to the orchestration flow.


## Proposed Tasks

### Task 1: Update iac-minion spec in the-plan.md

**What changes:**
- Add to Remit: "Serverless platforms (AWS Lambda, Cloudflare Workers, Cloud Functions, Vercel Functions)" and "Deployment strategy selection (serverless vs. container vs. self-managed)"
- Add to Research Focus: "Serverless deployment patterns, cold start optimization, FaaS cost modeling, serverless vs. container decision criteria, when serverless is inappropriate"
- Bump spec-version to 2.0 (remit change -- new domain area added)

**What does NOT change:**
- No "prefer serverless" or "default to serverless" language anywhere
- No removal of existing Docker/Terraform content
- No prescriptive framing in the spec

**Prompt engineering notes for the `/despicable-lab` builder:**
- The builder (Step 2) will read the updated spec + RESEARCH.md and generate a new AGENT.md
- The Working Patterns section MUST include a deployment strategy selection step BEFORE the infrastructure design steps
- The Core Knowledge section MUST include a new subsection on serverless platforms as a peer to the existing Docker, Terraform, and Reverse Proxy sections
- The decision framework should be in Working Patterns, not Core Knowledge -- this is a procedural step, not reference knowledge
- Include the five-criteria decision tree from recommendation (a) in Working Patterns

### Task 2: Update margo spec in the-plan.md

**What changes:**
- Expand Remit bullet on "Reviewing plans for unnecessary complexity" to explicitly include "including operational complexity and infrastructure overhead"
- Add to Research Focus: "Operational complexity metrics, build-time vs. run-time complexity tradeoffs, infrastructure simplicity patterns"
- Bump spec-version to 1.1 (refinement within existing remit -- margo already evaluates complexity, this refines the scoring dimensions)

**What does NOT change:**
- Margo does NOT gain deployment strategy expertise
- Margo does NOT reference iac-minion's framework
- No technology-specific scoring (no "serverless = 1 point" in the spec -- that goes in AGENT.md via the build pipeline)

**Prompt engineering notes for the `/despicable-lab` builder:**
- The Complexity Budget section must expand to two dimensions (build-time and operational)
- The operational dimension must use the same three-tier deployment vocabulary (self-managed, managed, serverless) so it aligns with iac-minion output
- Keep the point system but add the lifetime weight factor
- Do NOT set an absolute complexity threshold -- keep the "proportional to problem size" framing

### Task 3: Update delegation table in the-plan.md

**What changes:**
- Add row: "Serverless deployment design | iac-minion | edge-minion" under Infrastructure & Data
- Add row: "Deployment strategy selection | iac-minion | margo" under Infrastructure & Data

**Prompt engineering rationale:**
- "Serverless deployment design" as a distinct task type ensures nefario routes serverless work to iac-minion rather than treating it as novel/unknown
- edge-minion as supporting for serverless makes sense because edge functions (Cloudflare Workers) straddle the serverless/edge boundary
- "Deployment strategy selection" with margo as supporting ensures the governance review happens for strategy decisions, not just implementation

### Task 4: CLAUDE.md template guidance

**What changes:**
- Create a recommended CLAUDE.md section (template, not prescriptive) that target projects can include to provide deployment context to the agent team

**Prompt engineering rationale:**
- The agents are generic and cannot hardcode deployment preferences
- Project-level CLAUDE.md is where deployment context belongs (volatile, project-specific data in user-side configuration)
- This follows the caching architecture principle: stable knowledge in agent system prompts (cached), project-specific context in CLAUDE.md (read per session)

**Template content suggestion:**

```markdown
## Deployment Context

<!-- Fill in to help infrastructure agents make appropriate decisions -->
- **Hosting preference**: [serverless / containers / VMs / no preference]
- **Cloud provider(s)**: [AWS / GCP / Cloudflare / Hetzner / other]
- **Scale expectations**: [requests per day, concurrent users, data volume]
- **Budget constraints**: [monthly infrastructure budget, cost sensitivity]
- **Operational capacity**: [dedicated ops team / developer-managed / minimal ops]
```

This template means the iac-minion decision framework has concrete project data to evaluate, rather than making assumptions. It also means margo has project context for calibrating her "proportional to problem size" assessment.


## Risks and Concerns

### Risk 1: Research quality determines AGENT.md quality

The `/despicable-lab` build pipeline runs research (Step 1, Sonnet) then build (Step 2, per-spec model). For iac-minion, the build model is Sonnet. The quality of the serverless knowledge in the built AGENT.md depends entirely on what the research step finds. If research produces shallow or biased serverless content (e.g., only AWS Lambda examples), the built agent will have shallow or biased knowledge.

**Mitigation:** The spec's Research Focus should be specific enough to guide research toward balanced content. "Serverless vs. container decision criteria" and "when serverless is inappropriate" explicitly request both sides.

### Risk 2: Margo's dual-dimension scoring increases prompt length

Adding operational complexity scoring roughly doubles the Complexity Budget section in margo's AGENT.md. Margo runs on Opus, which handles long prompts well, but every added token is cost. The current margo AGENT.md is already substantial (~275 lines).

**Mitigation:** The build step should keep the scoring concise -- bullet points with anchored numbers, not explanatory paragraphs. The framework in recommendation (c) above is ~15 lines. Net addition to AGENT.md is modest.

### Risk 3: Spec version coordination

iac-minion goes to 2.0 (remit change), margo goes to 1.1 (refinement). Both must be rebuilt together for coherence. If only one is rebuilt, the shared vocabulary alignment breaks.

**Mitigation:** The execution plan should rebuild both agents in the same `/despicable-lab` invocation. The cross-check phase (Phase 2 of the build pipeline) should catch misalignment if they are rebuilt separately.

### Risk 4: The delegation table additions may create routing ambiguity

"Deployment strategy selection" as a task type overlaps with "Infrastructure provisioning." Nefario might route the same request to both rows.

**Mitigation:** The delegation table note should clarify that "Deployment strategy selection" is the pre-infrastructure decision. In practice, nefario will encounter this as part of a larger task and route to iac-minion for infrastructure regardless -- the new row just ensures the strategy step is not skipped.

### Risk 5: Existing projects with Docker-heavy CLAUDE.md files

Projects that already have Docker/container-specific infrastructure instructions in their CLAUDE.md will override the agent's new neutrality. The iac-minion will read the project CLAUDE.md, see Docker instructions, and continue producing Docker solutions.

**This is actually correct behavior.** The agent should respect project-level context. The fix is for new projects and projects that want to reconsider their deployment strategy. The CLAUDE.md template (Task 4) gives them a structured way to signal their preferences.


## Additional Agents Needed

**No additional specialists are needed for the planning phase.** The four tasks map cleanly to `the-plan.md` changes that `/despicable-lab` will process.

For the **execution phase**, I recommend:

1. **lucy** should review the final spec changes for intent alignment -- ensuring the changes match the stated goal (fix serverless bias) without introducing new biases.

2. **margo** should review her own spec changes (meta-review) -- specifically confirming the dual-dimension scoring does not introduce unnecessary complexity into the complexity assessment framework itself. This is an appropriate use of margo's self-referential review capability.

3. The **code-review-minion** is not needed -- the changes are to `the-plan.md` (a specification document), not code. `/despicable-lab` handles the code generation (AGENT.md builds).
