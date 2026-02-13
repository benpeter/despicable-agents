# Test-Minion Phase 3.5 Review

## Verdict: ADVISE

**Three non-blocking warnings about verification rigor:**

### 1. Link Validation Gap

The rewritten README will contain multiple links (docs/using-nefario.md, docs/orchestration.md, GitHub issue references, external links like the Web Resource Ledger). The plan acknowledges this risk (line 143) but assigns verification to software-docs-minion with no concrete test plan.

**Recommendation**: Add a verification step that programmatically checks all markdown links are valid. This is simple to automate:
- File paths: verify target files exist (docs/using-nefario.md, docs/orchestration.md, docs/agent-catalog.md, SKILL.md files)
- External URLs: curl HEAD requests to https://github.com/benpeter/web-resource-ledger and any other external links
- Anchor references: verify internal headings exist

This should run as part of Phase 3.5 verification to catch broken links before merge.

### 2. Automated Fact-Checking Opportunities

Several accuracy claims can be verified programmatically instead of relying solely on manual review:
- **Agent count**: Count agent files in skills/ to verify "27 agents + 2 skills" claim
- **Reviewer names**: Extract from docs/orchestration.md to verify FIVE mandatory reviewers (security-minion, test-minion, software-docs-minion, lucy, margo)
- **Phase count**: Extract "nine-phase process" from orchestration.md
- **Skill details**: Verify `/despicable-prompter` and `/despicable-lab` SKILL.md files exist and skills are correctly described

These checks catch transcription errors that manual review might miss. Assign to test-minion or software-docs-minion in Phase 3.5.

### 3. Scannability Metric Ownership

The 120-150 line target and "60-second scan test" success criteria need explicit ownership and pass/fail criteria:
- **Line count**: Clarify how lines are measured (raw `wc -l`? excluding the `<details>` agent table? including frontmatter if any?)
- **60-second scan test**: Who conducts this (UX specialist? multiple readers?)? How do they report pass/fail? Is this a gate or advisory?
- **Progressive disclosure validation**: Confirm "What You Get" section appears before Examples, collapsed sections work as expected

These are measurement clarity issues, not technical gaps. Phase 3.5 review needs explicit owners.

## Assessment

Plan is sound. The approval gate (line 29-30) and five mandatory reviewers provide good governance. The risk mitigations (lines 133-143) adequately address accuracy and over-promising. These warnings are about verification execution detail, not plan substance.

**No blocking issues.** Proceed with Task 1, incorporate link validation into Phase 3.5 software-docs-minion or test-minion review.
