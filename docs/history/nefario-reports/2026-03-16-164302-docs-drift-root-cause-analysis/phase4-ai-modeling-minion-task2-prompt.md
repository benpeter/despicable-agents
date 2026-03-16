You are expanding the Phase 8 outcome-action table in the nefario orchestration
skill to cover documentation drift categories that were missed in the WRL project.

## Target file
`/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

## Current table location

The table is in the Phase 8a section. Find the outcome-action table that starts with:
```
| Outcome | Action | Owner |
|---------|--------|-------|
| New API endpoints | ...
```

## New rows to add

Add these rows AFTER the existing rows (after "Spec/config files modified") and BEFORE any
text that follows the table:

| New secrets / environment variables | README secrets/env section, CONTRIBUTING .dev.vars template, deployment docs | software-docs-minion |
| New response headers | API reference, OpenAPI response headers | software-docs-minion |
| Error response shape changed | OpenAPI error response definitions | software-docs-minion |
| Existing behavior changed (not breaking) | Scan docs referencing changed behavior for stale content | software-docs-minion |
| New publicly accessible endpoint (incl. health, well-known) | README endpoint table, OpenAPI spec | software-docs-minion |
| Developer setup dependencies changed | CONTRIBUTING setup section, getting-started | software-docs-minion |
| CORS / security header changes | API reference, security docs | software-docs-minion |
| Any other file touched in Phase 4 referenced by existing docs | Verify documentation references still accurate | software-docs-minion |

## Update priority assignment

The priority assignment section follows the table. Currently:
```
Priority assignment:
- MUST: gate-approved decisions, new projects, breaking changes
- SHOULD: user-facing features, new APIs
- COULD: config refs, derivative docs
```

Update to:
```
Priority assignment:
- MUST: gate-approved decisions, new projects, breaking changes,
  existing behavior contradicts docs (stale content)
- SHOULD: user-facing features, new APIs, new secrets/env vars,
  new publicly accessible endpoints
- COULD: config refs, derivative docs, new response headers,
  CORS/security headers, developer setup changes, error response changes
```

## What NOT to change
- Do NOT modify any existing table rows
- Do NOT modify the Phase 8 structure (already done)
- Do NOT change priority levels of existing rows

When you finish, report: file paths with change scope and line counts.
