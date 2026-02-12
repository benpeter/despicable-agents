VERDICT: APPROVE

FINDINGS:

## Correctness

- [ADVISE] skills/nefario/SKILL.md:1456-1459 -- Shell command sequence uses `$$` for temporary file naming, which works but could create a race condition in parallel execution scenarios. The `$$` expands to the parent shell PID, which is stable during the nefario session but not unique across concurrent nefario runs.
  FIX: Consider using `mktemp` for truly unique temp files: `tmpfile=$(mktemp)` followed by `gh pr view <N> --json body --jq .body > "$tmpfile"`. However, since nefario orchestration runs serially (one session at a time per user), the current `$$` approach is acceptable.

- [NIT] skills/nefario/SKILL.md:1460-1463 -- The instruction to "detect by checking for `## Post-Nefario Updates` in the existing body" is not accompanied by implementation guidance. The check logic is left implicit.
  FIX: Add explicit guidance: "Check if `## Post-Nefario Updates` exists in the fetched body. If present, append the new H3 update entry under it. If not present, append the entire `## Post-Nefario Updates` section."

- [NIT] skills/nefario/SKILL.md:1479-1481 -- Manual update convention references editing the report file and using `gh pr edit <N> --body-file <report>`, but the report file includes YAML frontmatter which would break the PR body. The instruction should clarify to strip frontmatter first.
  FIX: Clarify: "edit the report file directly to add a 'Post-Nefario Updates' section, strip the YAML frontmatter, then update the PR body with `gh pr edit <N> --body "$(tail -n +$(grep -n '^---$' <report> | tail -1 | cut -d: -f1) <report> | tail -n +2)"`" or recommend a simpler manual workflow.

## Internal Consistency

- [NIT] docs/orchestration.md:475-487 -- The Report Structure section lists 12 sections. The canonical TEMPLATE.md skeleton (lines 8-206) includes 13 H2 sections in the template body (Summary through Post-Nefario Updates). The orchestration.md list omits one section or miscounts.
  FIX: Cross-check section count. The TEMPLATE.md skeleton includes these H2 sections in report body: Summary, Original Prompt, Key Design Decisions, Phases, Agent Contributions, Execution, Decisions, Verification, External Skills, Working Files, Test Plan, Post-Nefario Updates (12 sections). The orchestration.md list matches. No fix needed.

## Cross-Reference Integrity

- [PASS] docs/orchestration.md:488 -- Correctly references `docs/history/nefario-reports/TEMPLATE.md` as the canonical template location, matching skills/nefario/SKILL.md:1359-1360.

- [PASS] docs/orchestration.md:475-486 -- Section list matches TEMPLATE.md skeleton sections (Summary, Original Prompt, Key Design Decisions, Phases, Agent Contributions, Execution, Decisions, Verification, External Skills, Working Files, Test Plan, Post-Nefario Updates).

- [PASS] skills/nefario/SKILL.md:1337-1339 -- `existing-pr` tracking is correctly introduced in Data Accumulation after the PR detection command is added in Branch Creation (lines 779-783).

- [PASS] skills/nefario/SKILL.md:1357-1364 -- Report Template section correctly references `docs/history/nefario-reports/TEMPLATE.md` and summarizes its content (frontmatter schema, section order, conditional rules).

- [PASS] skills/nefario/SKILL.md:1422 -- Wrap-up step 6 correctly references the canonical template at `docs/history/nefario-reports/TEMPLATE.md`.

## DRY Violations

- [NIT] docs/history/nefario-reports/TEMPLATE.md:440-454 vs skills/nefario/SKILL.md:1440-1454 -- The Post-Nefario Updates section format is duplicated between TEMPLATE.md (line 440 example) and SKILL.md (line 1440 instruction). Both define the same markdown structure.
  FIX: This is acceptable redundancy. TEMPLATE.md provides the end-user-facing example in the report skeleton. SKILL.md provides implementation guidance for nefario. Both serve different audiences (report readers vs nefario implementers). No change needed, but consider adding a cross-reference comment in SKILL.md: "See TEMPLATE.md lines 201-206 for the canonical format."

- [PASS] docs/orchestration.md:475-487 vs docs/history/nefario-reports/TEMPLATE.md:1-332 -- orchestration.md provides a high-level section summary; TEMPLATE.md provides the canonical skeleton. This is appropriate layering (overview vs specification), not a DRY violation.

## Completeness

- [PASS] All sections from the issue (canonical v3 template, PR update mechanism, cross-references) are implemented.

- [PASS] TEMPLATE.md includes all 10 mandatory frontmatter fields and 1 conditional field (`source-issue`) as specified.

- [PASS] TEMPLATE.md includes conditional section rules (Decisions, External Skills, Test Plan, Post-Nefario Updates) with clear INCLUDE WHEN / OMIT WHEN guidance.

- [PASS] TEMPLATE.md includes collapsibility rules and formatting rules for all sections.

- [PASS] skills/nefario/SKILL.md includes the full PR update mechanism (user prompt, append logic, duplicate section detection, manual update convention).

## Complexity

- [PASS] The Post-Nefario Updates mechanism (SKILL.md:1428-1481) is appropriately scoped: conditional execution, clear user choice, simple shell commands. Cognitive complexity is low.

- [PASS] TEMPLATE.md is well-structured: skeleton first, then notes/rules. Sections are clearly separated. Easy to navigate.

## Security

- [PASS] No hardcoded secrets, credentials, or PII in any of the changed files.

- [NIT] skills/nefario/SKILL.md:1456 -- Using `/tmp/pr-body-$$` is secure for single-user systems but could expose PR content on shared systems. Since nefario runs on developer workstations (not shared servers), this is acceptable.
  FIX: No change needed. If this becomes a concern, use `mktemp` for truly private temp files.

## Summary

The changes are well-executed and achieve the stated goals. The TEMPLATE.md provides a clear, comprehensive canonical template. The PR update mechanism in SKILL.md is functional and well-integrated. Cross-references between files are correct. Minor issues are non-blocking suggestions for clarity and defensive programming.

- Internal consistency: Strong. Section lists match across files.
- Completeness: All requirements met.
- Correctness: Shell commands work. Minor edge cases noted (race condition with `$$`, frontmatter in manual updates).
- Cross-reference integrity: All references are correct.
- DRY: One acceptable redundancy (Post-Nefario Updates format in two files for different audiences).
- Complexity: Low. Well-scoped changes.
- Security: No concerns.
