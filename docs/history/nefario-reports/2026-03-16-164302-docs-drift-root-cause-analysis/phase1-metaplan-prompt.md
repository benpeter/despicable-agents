MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

## Task

The nefario orchestration framework (despicable-agents) was designed with a Phase 8 (Documentation)
that should prevent documentation drift. However, when the framework was used to orchestrate
6 PRs on the web-resource-ledger project (PRs #51-#57, "Act 1"), significant documentation drift
accumulated anyway. A subsequent explicit docs drift audit (evolution/0022-docs-drift-audit) found
and fixed:

1. **openapi.yaml**: 13 spec-vs-code discrepancies (+357/-56 lines)
2. **README.md**: 17 drift items including a dangerously false key rotation warning, missing secrets,
   missing endpoints, missing staging docs (+128/-9 lines)
3. **CONTRIBUTING.md**: Missing .dev.vars template expansion, missing staging deployment docs (+51 lines)
4. **PRODUCT.md/MVP.md**: Stale pre-implementation docs with no status headers (+8 lines)

Root cause patterns visible in the nefario reports for these PRs:

- **Key-versioning (PR #54)**: Phases 5-8 "Skipped per user directive (skip all post-exec)"
  → README retained dangerously false key rotation warning, new endpoints undocumented
- **Staging-and-tos (PR #55)**: Phases 5-8 "handled inline during execution"
  → Missing staging environment section, 3 missing secrets in README
- **Hashed-ip-logging (PR #56)**: Phase 8 "Skipped (internal logging change, no user-facing docs needed)"
  → Missing IP_HASH_SEED secret documentation
- **CORS/HSTS/ratelimit (PR #57)**: Phases 5-8 "handled inline during execution"
  → Missing response header documentation, missing OpenAPI error responses
- **Auth-identity + list-captures (PR #51)**: Phase 8 "Skipped. Documentation covered by Task 3"
  → Various OpenAPI discrepancies

The task is to analyze WHY the framework's existing Phase 8 and documentation safeguards failed
to catch this drift, and propose concrete changes to the despicable-agents framework (SKILL.md,
AGENT.md, the-plan.md, or new mechanisms) to prevent this class of failure in future orchestrations.

This is a self-reflexive analysis: the framework analyzing its own failure modes.

## Working Directory
/Users/ben/github/benpeter/despicable-agents

## Key Files for Context
- `skills/nefario/SKILL.md` — the orchestration workflow (Phase 8 spec is here)
- `nefario/AGENT.md` — nefario's system prompt
- `the-plan.md` — canonical spec for all agents
- `docs/orchestration.md` — orchestration documentation
- WRL nefario reports: /Users/ben/github/benpeter/web-resource-ledger/docs/history/nefario-reports/
- WRL drift audit: /Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0022-docs-drift-audit/

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution -- planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Djh1cT/docs-drift-root-cause-analysis/phase1-metaplan.md
