You are creating a CLAUDE.md template document for target projects that want to signal their deployment preferences to the despicable-agents team.

## What to create

Create `/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md` containing a documented `## Deployment` section that target projects can add to their CLAUDE.md.

## Template design requirements

1. **Format**: Follow existing docs/ conventions:
   - First line: `[< Back to Architecture Overview](architecture.md)`
   - Second line: `# CLAUDE.md Template: Deployment Section`
   - Content follows after the heading

2. **"When to omit" guidance at the TOP** (from user-docs review): The most important message is "you probably don't need this section." Place this guidance BEFORE the template itself. Users who don't need the section should learn this immediately, not discover it buried in comments. Follow progressive disclosure: essential information (when NOT to use this) before details (how to use it).

3. **The template section itself** should be a single optional `## Deployment` section written in Markdown prose (not YAML, not JSON, not structured key-value pairs). CLAUDE.md is read by LLMs, not parsed by machines.

4. **Template content**: A one-sentence declaration ("We deploy on [platform/approach].") followed by a SINGLE guiding HTML comment (from ux-strategy review — collapse multiple categories into one):

   ```markdown
   ## Deployment

   <!-- Optional. Omit this section entirely if you have no deployment
        preferences -- agents will recommend an approach and explain
        their reasoning. You can accept or redirect. -->

   We deploy on [platform/approach].

   <!-- Add context that helps agents understand your deployment situation:
        existing infrastructure, constraints, team capacity, or preferences. -->
   ```

   Note: Only ONE guiding comment, not four separate category comments. This reduces hidden cognitive load.

5. **Default behavior explanation** (from ux-strategy review): Use user-facing language, not internal agent framing. Say: "When no Deployment section exists, agents recommend an approach and explain their reasoning. You can accept or redirect." Do NOT reference internal concepts like "simplest-viable principle" vs "serverless category" -- these are agent design concerns, not user concerns.

6. **Four examples** showing different specificity levels, each with equal weight (no bias toward any topology):
   - **Minimal** (from ux-strategy review — shows the lower bound): "We deploy on Vercel." (one sentence, no justification needed)
   - Specific platform (serverless): "We deploy on Cloudflare Pages with Workers functions. Budget under $25/month. Team is experienced with JavaScript but has no Docker experience."
   - Specific platform (self-managed): "We deploy on a Hetzner VPS using Docker Compose. We have an existing Terraform setup and CI/CD pipeline via GitHub Actions."
   - General preference: "Keep deployments simple -- prefer managed platforms where possible. We're a small team (2 developers) and cannot maintain infrastructure."
   - No preference (explain that section absence is the signal)

   **Equal weight verification** (from test-minion review): Examples should have similar word counts (variance <20% across topology-specific examples). No example should be substantially more detailed than others.

7. **Hybrid example** (from user-docs review): Consider adding one hybrid/multi-constraint example, e.g., "We run stateful services on a VPS but deploy stateless APIs to serverless" or similar. Real projects often have mixed infrastructure.

8. **Surrounding context**: The doc should explain:
   - This is an OPTIONAL section to add to an existing CLAUDE.md, not a standalone file
   - When no Deployment section is present, agents recommend an approach and explain their reasoning — you can accept or redirect
   - Existing infrastructure artifacts (Dockerfile, terraform/, wrangler.toml, docker-compose.yml) serve as implicit signals even without a Deployment section
   - The section captures preferences and context, not decisions -- the agent team makes the technical recommendation

9. **Discoverability** (from user-docs review): Add a note at the end of the document suggesting that docs/architecture.md could link to this template. The actual linking will be done in Task 6 (docs staleness check).

## What NOT to do

- Do not create an opinionated infrastructure blueprint
- Do not include enumerated fields to fill in (every field creates a decision the user must make)
- Do not include platform rankings or recommendations
- Do not include any PII or project-specific data (Apache 2.0 publishable)
- Do not recommend specific providers or runtimes in the template itself
- Do not lean examples toward any particular topology -- equal representation
- Do not add structured comment guidance for machine-parseable signals (e.g., `<!-- deployment-platform: cloudflare-pages -->`). CLAUDE.md is read by LLMs, not parsed by machines. Prose is sufficient.

## Files to create

- `/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md`

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
