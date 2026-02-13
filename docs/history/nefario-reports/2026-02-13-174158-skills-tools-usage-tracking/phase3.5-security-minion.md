# Security Review: Session Resources Tracking

## Verdict: ADVISE

### Non-blocking warnings

1. **Working file credential sanitization already covers this** (Informational). The plan introduces tool counts and skill names into execution reports, which are then committed to git and potentially included in PRs. Tool counts (Read: 42, Bash: 15) and skill names (`/nefario`, `/despicable-lab`) are non-sensitive operational metadata -- no credentials, PII, or architecture secrets are exposed. The existing SKILL.md sanitization checks at wrap-up step 5 (lines 2077-2091) adequately cover the companion directory where scratch files are copied. No additional sanitization is needed for the new Session Resources section content itself.

2. **Tool counts as reconnaissance aid** (Low risk, accepted). In a public repository, detailed tool usage counts could theoretically help an attacker understand orchestration patterns and tooling capabilities. However, this is defense-in-depth theater: the AGENT.md files and SKILL.md are already public and describe the full tool surface in detail. Tool counts add negligible incremental value to an attacker. No action needed.

3. **Skill names in frontmatter `skills-used` field** (Low risk, accepted). The conditional `skills-used` frontmatter field will contain skill names like `/despicable-lab` or `/despicable-prompter`. These are already documented in the public CLAUDE.md and install.sh. No information disclosure concern.

4. **Best-effort tool counting from conversation context** (Informational). The plan has the orchestrator scan conversation context at wrap-up to tally tool counts. This is a read-only operation on data already in context -- no new tool calls, no external requests, no injection surface. The "not available" fallback for compacted sessions is a clean fail-closed pattern. Good design.

### No concerns with

- No secrets, credentials, or PII flow into the new section
- No new external inputs or user-controllable data enters the template
- No new APIs, endpoints, or authentication surfaces
- The `<details>` collapse is a UX choice with no security implications
- Scratch file sanitization (already robust in SKILL.md lines 2077-2091) is not weakened by these changes
- No supply chain, dependency, or infrastructure changes

### Summary

This is an additive template and documentation change with no security-relevant attack surface. The data flowing into Session Resources (skill names, tool counts) is internally generated operational metadata, not user input. Existing sanitization checks in the wrap-up sequence cover the companion directory. No blocking issues.
