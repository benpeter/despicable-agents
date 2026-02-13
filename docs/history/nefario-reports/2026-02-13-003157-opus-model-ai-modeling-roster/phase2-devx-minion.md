# Domain Plan Contribution: devx-minion

## Recommendations

### (a) Developer Workflow Impact: DX Dimensions of Deployment Strategy

When the agent team recommends a deployment strategy, six DX dimensions
matter. They split cleanly into two categories: dimensions where serverless
has a systematic structural advantage, and dimensions that are
platform-dependent (and therefore should not drive the strategy choice in
the abstract).

**Systematically better with serverless/managed:**

1. **Time-to-deploy (TTFD)**: This is the TTFS metric applied to
   infrastructure. Serverless platforms collapse the path from "code done"
   to "accessible URL" to a single command (`vercel deploy`,
   `wrangler deploy`, `netlify deploy`). Self-managed infrastructure
   interposes multiple prerequisite steps: Dockerfile authoring, registry
   push, Terraform plan/apply, DNS configuration, TLS provisioning, reverse
   proxy setup. Each step is a potential friction point. For a greenfield
   project with no existing infrastructure, the TTFD gap is large -- minutes
   vs. hours. For a project with existing Docker/Terraform infrastructure
   already running, the marginal TTFD is similar. This means the DX
   advantage is strongest exactly where the bias most hurts: new projects
   and simple workloads.

2. **CI/CD simplicity**: Serverless platforms provide opinionated CI/CD out
   of the box (Vercel git integration, Cloudflare Pages git deploy). Self-
   managed requires explicit pipeline authoring (GitHub Actions workflows,
   build steps, deployment steps, rollback logic). The DX difference is not
   just time -- it is also cognitive load. A developer maintaining a
   Terraform + Docker + GitHub Actions pipeline must hold three conceptual
   models in their head. A developer deploying to Vercel holds one.

3. **Operational absence**: The DX win is not just what serverless makes
   easier -- it is what it eliminates entirely. No server patching, no
   capacity planning, no certificate renewal, no monitoring of
   infrastructure health (as distinct from application health). These are
   ongoing costs that do not appear at deploy time but compound over the
   project's lifetime. The agent team should weigh ongoing DX burden, not
   just initial setup friction.

**Platform-dependent (defer to edge-minion's expertise on specifics):**

4. **Local development experience**: Some serverless platforms provide
   excellent local dev parity (Cloudflare Wrangler, Vercel CLI with `vercel
   dev`), while others have weaker local emulation (Lambda with SAM local
   has known fidelity gaps). Docker Compose gives near-perfect production
   parity locally. This dimension does not cleanly favor either approach --
   it depends on which specific platform. The CLAUDE.md template should let
   users signal their local dev priority so the agent team can weigh this.

5. **Debugging and logs access**: Platform-dependent. Vercel and Cloudflare
   provide structured log tailing. Docker logs are direct and familiar. The
   debugging experience quality varies by platform, not by category.

6. **Rollback ease**: Platform-dependent. Vercel has instant rollback to
   any previous deployment. Cloudflare Workers has version rollback. Docker
   + Terraform rollback requires either image pinning discipline or
   Terraform state manipulation. Neither category is uniformly better.

**Recommendation for spec changes**: iac-minion's new decision framework
should include TTFD as a first-class criterion -- not just "can I deploy
here?" but "how long until a developer goes from code-complete to
production?" This is the criterion most consistently affected by strategy
choice, and the one most invisible in the current Docker+Terraform-only
worldview.

### (b) CLAUDE.md Template Design

The template should follow existing CLAUDE.md conventions from this project
and the user's global CLAUDE.md. Both use the same structural patterns:
top-level H2 headings for major sections, bold text for key terms, bullet
points for rules and preferences, and inline code for technical values. No
YAML, no JSON, no structured data -- CLAUDE.md is Markdown prose read by
LLMs, not parsed by machines.

**Key design principles for the template:**

1. **Optional section, not required**: The deployment section should be one
   section within a larger CLAUDE.md, not a standalone file. Projects that
   do not care about deployment should not have to think about it. The
   section's absence IS the default signal (see part (c) below).

2. **Declarative, not interrogative**: The template should let users state
   what they have and what they want, not answer a questionnaire. "We
   deploy on Vercel" is better than "Platform: Vercel, Type: serverless,
   Tier: pro." Agents are LLMs -- they understand natural language
   declarations better than structured key-value pairs.

3. **Three levels of specificity**: The template should accommodate users at
   different levels of infrastructure knowledge:
   - **Specific platform**: "We deploy on Cloudflare Pages" or "We use
     Docker Compose on Hetzner"
   - **General preference**: "Keep deployments simple -- prefer managed
     platforms" or "We self-host everything"
   - **No preference**: Section absent or "No infrastructure preference"

4. **Context signals, not just preferences**: The template should also
   capture signals that affect strategy selection -- existing
   infrastructure, team expertise, constraints. These give the agent team
   the information to make good recommendations rather than just following
   orders.

**Proposed template section:**

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

**What this template avoids:**

- No enumerated fields to fill in (breaks the "sensible defaults"
  principle -- every field creates a decision the user must make)
- No platform ranking or recommendation (that is the agent team's job,
  informed by edge-minion's expertise)
- No structured format that would require parsing (CLAUDE.md is prose)
- No implicit assumption about what "simple" means (that judgment belongs
  to the agent team, specifically iac-minion and edge-minion)

**Format consistency with existing CLAUDE.md patterns:**

Looking at the project's own CLAUDE.md and the user's global CLAUDE.md,
established conventions are:
- H2 headings for major sections (`## Key Rules`, `## Engineering
  Philosophy`, `## Technology Preferences`)
- Bold terms for emphasis (`**YAGNI**`, `**Prefer lightweight, vanilla
  solutions**`)
- Bullet lists for rules and preferences
- HTML comments for explanatory notes in templates
- Natural language, not structured data
- Sections can be omitted entirely if not relevant

The template section should be documented in `docs/` as a reference for
users setting up their project's CLAUDE.md. It is NOT a standalone file
to be copied wholesale -- it is a section to be added to an existing
CLAUDE.md. The docs page should show the section in context (surrounded by
other typical CLAUDE.md sections) so users understand where it fits.

### (c) Sensible Defaults: What Happens When No Preference Is Stated

**Recommendation: The agents should recommend the simplest viable approach
without asking, but present the recommendation as a recommendation (not a
fait accompli) so the user can redirect if needed.**

Rationale from DX principles:

1. **"Sensible defaults, progressive complexity" means having an opinion.**
   A tool that asks "what deployment platform do you want?" before doing
   anything has failed the zero-config test. The 80% case should work
   without the user having to make infrastructure decisions. The remaining
   20% override via the CLAUDE.md section described above.

2. **Asking is a form of friction.** When a developer says "deploy this,"
   they want deployment, not a platform selection dialog. The agent team
   should infer the right approach from context (project type, existing
   config files, CLAUDE.md signals) and recommend. This matches how good
   CLI tools work -- `git push` does not ask "which remote protocol do you
   want?" It infers from the remote URL.

3. **But recommendations should be visible, not invisible.** The agent
   should state what it chose and why, briefly: "Deploying to Vercel
   (simplest option for a Next.js app with no existing infrastructure).
   If you prefer a different approach, add a `## Deployment` section to
   your CLAUDE.md." This gives the user an exit ramp without making them
   answer questions upfront.

4. **The default should be "simplest viable," not "serverless."** The
   word "serverless" is an implementation category. "Simplest viable" is a
   DX principle. For most projects, simplest viable will be a managed
   platform. For projects with existing Docker infrastructure, simplest
   viable may be extending that infrastructure. The default is a decision
   framework, not a platform. I defer to edge-minion on what "simplest
   viable" maps to for specific project types.

5. **Context signals override the default.** If the project already has a
   `Dockerfile`, `docker-compose.yml`, `terraform/` directory, or
   `wrangler.toml`, those are stronger signals than any default. The agent
   team should read the room: existing infrastructure artifacts are
   implicit deployment preferences. iac-minion's decision framework should
   check for these signals before applying any default.

**Anti-pattern to guard against**: The agent team should NOT ask "Do you
want serverless or self-managed?" as a routing question. That forces the
user to understand a taxonomy they may not care about. Instead, the agents
should make a recommendation based on context and let the user redirect.
This is the same principle that makes `npx create-next-app` good: it gives
you a working project with opinions, and you change what you do not like.

## Proposed Tasks

These are tasks devx-minion should own or contribute to during execution:

1. **CLAUDE.md template section** (primary owner): Draft the `## Deployment`
   template section for target project CLAUDE.md files, following the design
   in recommendation (b) above. Place the documentation in `docs/` with a
   filename consistent with existing patterns (suggest
   `docs/target-project-claude-md.md` or similar -- defer to lucy on naming
   conventions).

2. **Review iac-minion spec for DX criteria** (supporting): Review the
   iac-minion spec changes to ensure the deployment strategy selection
   framework includes TTFD (time-to-first-deploy) and ongoing operational
   DX burden as decision inputs, not just technical capability.

3. **Review delegation table wording** (supporting): Verify the new
   delegation table rows use task descriptions that match how developers
   naturally describe their needs. "Deployment strategy selection" is good.
   "Serverless platform deployment" should perhaps be "Managed platform
   deployment" or "Platform deployment" to avoid biasing the routing
   vocabulary toward serverless (the whole point is to make the strategy
   choice happen upstream of the platform-specific work).

## Risks and Concerns

1. **Opposite-bias risk in template design**: If the CLAUDE.md template
   examples lean too heavily toward serverless ("We deploy on Vercel,"
   "We use Cloudflare Pages"), users may perceive that as a recommendation.
   The template examples should show equal diversity: one serverless, one
   self-managed, one no-preference. Example variety signals that all
   approaches are valid.

2. **Template adoption risk**: The CLAUDE.md template only helps if users
   adopt it. For existing projects that already have a CLAUDE.md, the
   template section is additive and low-friction. For new projects, the
   deployment section should be mentioned in any quickstart or onboarding
   docs. Risk: the template exists in docs/ but nobody discovers it.
   Mitigation: the agent team should suggest adding a `## Deployment`
   section when it encounters a project with no deployment context -- this
   is a behavioral change in iac-minion's working patterns, not just a
   documentation artifact.

3. **"Simplest viable" is subjective without guardrails**: If the default
   is "recommend simplest viable," different agents may have different
   opinions about what that means. iac-minion (with new serverless
   knowledge) might say Vercel. edge-minion might say Cloudflare Pages.
   The delegation table should make it clear who makes the final call --
   currently iac-minion is proposed as primary for "Deployment strategy
   selection," which is correct, but the supporting agents' input should
   inform rather than override.

4. **Delegation table naming precision**: "Serverless platform deployment"
   as a row in the delegation table risks creating the same categorical
   bias in the other direction. Once a task is classified as "serverless,"
   the routing is predetermined. Consider whether the delegation table
   should route on the task ("Deploy this application") rather than the
   solution category ("Serverless platform deployment"). The current table
   routes on task types (e.g., "Infrastructure provisioning," "CI/CD
   pipelines"), not on solution categories -- a "Serverless platform
   deployment" row breaks that convention.

## Additional Agents Needed

No additional agents beyond the current planning team are needed from
devx-minion's perspective. The five-agent team (margo, edge-minion,
devx-minion, ai-modeling-minion, lucy) covers the required expertise.

One note on Phase 3.5 review: **ux-strategy-minion** should review the
CLAUDE.md template during mandatory governance review. The template is a
user-facing configuration artifact -- its discoverability, clarity, and
progressive disclosure properties are UX strategy concerns. The meta-plan
already notes this as covered by Phase 3.5, which is correct.
