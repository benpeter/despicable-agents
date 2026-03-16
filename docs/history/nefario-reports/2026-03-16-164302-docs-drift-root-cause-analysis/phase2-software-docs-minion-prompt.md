You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

The nefario orchestration framework's Phase 8 Documentation phase has an outcome-action table
that maps execution outcomes to documentation actions. This table failed to catch drift across
6 PRs on the web-resource-ledger project.

## Your Planning Question

The outcome-action table covers "New API endpoints" and "Config changed" but missed drift from:
- New secrets (IP_HASH_SEED, CORALOGIX_SEND_KEY, CORS_ORIGINS not documented)
- New response headers (CORS, HSTS, X-RateLimit-Limit not in README)
- Changed error responses (POST error responses missing CORS headers in OpenAPI)
- New endpoints not flagged because existing task "covered" docs (Key Archive endpoint)
- Stale README sections contradicting new behavior (key rotation warning)
- Missing developer setup docs (CONTRIBUTING.md .dev.vars template incomplete)

Also: should OpenAPI spec accuracy be a Phase 6 (test) concern or Phase 8 (docs) concern?
What verification confirms that Phase 4 documentation tasks are complete rather than partial?

Read these files for context:
- /Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md (Phase 8 outcome-action table)
- /Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0022-docs-drift-audit/outcome.md
- /Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0022-docs-drift-audit/decisions.md

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Propose specific additions to the outcome-action taxonomy
4. Return your contribution in this format:

## Domain Plan Contribution: software-docs-minion

### Recommendations
### Proposed Tasks
### Risks and Concerns
### Additional Agents Needed

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase2-software-docs-minion.md
