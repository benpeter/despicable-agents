You are verifying that the refactored system (nefario AGENT.md assembled from template + software-dev domain adapter) produces functionally identical behavior to the original monolithic AGENT.md.

## What to do

1. **Run the assembly**: Execute `./assemble.sh software-dev` to produce the assembled AGENT.md.

2. **Diff the assembled output against the original**: The original AGENT.md content (before refactoring) is in git history. Use `git show HEAD~2:nefario/AGENT.md` to get the pre-refactor version. Compare the assembled output against that. Differences should be limited to:
   - Assembly marker artifacts (comments) -- these should NOT be present in assembled output
   - Whitespace normalization (acceptable)
   - No semantic content differences (unacceptable)

3. **Check SKILL.md section markers**: Verify that the `<!-- DOMAIN-SPECIFIC -->` and `<!-- INFRASTRUCTURE -->` markers in SKILL.md are HTML comments only and do not alter the file's behavior.

4. **Verify the adapter contract completeness**: Check that every domain-specific section identified in the audit is either:
   - Extracted into DOMAIN.md (for AGENT.md content), or
   - Marked with section markers (for SKILL.md content)

5. **Verify governance invariants**: Confirm that:
   - lucy and margo appear in the assembled AGENT.md's mandatory reviewer list
   - The cross-cutting checklist in the assembled output matches the original
   - Gate classification examples in the assembled output match the original

6. **Run install.sh**: Execute `./install.sh` and verify symlinks are created correctly.

7. **Verify assembly idempotence**: Run `./assemble.sh software-dev` twice and diff the outputs. They must be identical.

8. **Check for the 3 unmatched markers**: The assembly script reported 3 markers without corresponding DOMAIN.md sections (meta-plan-checklist, synthesis-cross-cutting, synthesis-review-agents). Verify these preserve their existing content correctly.

## What to produce

Write a verification report to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/verification-report.md`:

```
# Behavioral Equivalence Verification

## Assembly Output Diff
- Lines changed: N
- Semantic differences: [none | list]

## SKILL.md Markers
- Total markers added: N
- All are HTML comments: yes/no
- Behavioral impact: none/[describe]

## Adapter Completeness
- Audit items extracted/marked: N/N
- Missing items: [none | list]

## Governance Invariants
- lucy in mandatory reviewers: yes/no
- margo in mandatory reviewers: yes/no
- Cross-cutting checklist preserved: yes/no
- Gate examples preserved: yes/no

## Assembly Idempotence
- Second run identical: yes/no

## Unmatched Markers
- meta-plan-checklist: preserved/missing
- synthesis-cross-cutting: preserved/missing
- synthesis-review-agents: preserved/missing

## Install Verification
- install.sh exit code: 0/N
- Symlinks created: N
- AGENT.md symlink target correct: yes/no

## Verdict: PASS / FAIL
[If FAIL, list each failure with remediation]
```

## What NOT to do

- Do not modify any files to make the verification pass. Report failures; the producing agents fix them.
- Do not test non-software-dev adapters (out of scope).

## Key files

- `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md` (with markers, pre-assembly)
- `/Users/ben/github/benpeter/2despicable/3/domains/software-dev/DOMAIN.md`
- `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`
- `/Users/ben/github/benpeter/2despicable/3/assemble.sh`
- `/Users/ben/github/benpeter/2despicable/3/install.sh`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/audit-classification.md`

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- Verdict (PASS/FAIL)
- Summary of findings
- Any failures requiring remediation
