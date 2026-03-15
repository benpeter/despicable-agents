You are making a minimal framing update to the edge-minion specification in `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 751-784) to acknowledge full-stack serverless platforms.

## What to change

1. **Add one sentence to the Remit section** (after the existing bullet list) or as a new bullet:
   "Cloudflare Workers/Pages, Vercel, and Netlify function as full-stack serverless platforms. Edge-minion covers edge-layer behavior (caching, routing, edge functions, storage bindings) on these platforms; deployment strategy and CI/CD are iac-minion's domain."

2. **Add to "Does NOT do"**:
   "Full-stack serverless deployment configuration (Vercel project settings, Netlify build config, wrangler.toml deployment targets) (-> iac-minion). Edge-minion covers edge runtime behavior on these platforms."

3. **Bump spec-version** from 1.0 to 1.1

## Advisory: boundary symmetry with iac-minion (from test-minion review)

The "Does NOT do" boundary you add to edge-minion must use terminology symmetric with what Task 1 adds to iac-minion. iac-minion will add: "Edge-layer runtime behavior (caching strategy, edge function optimization, CDN routing rules) (-> edge-minion)". Your edge-minion exclusion should use consistent terms that mirror this — specifically using "deployment configuration" terminology so both specs reference each other by name with matching scope terms.

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

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
