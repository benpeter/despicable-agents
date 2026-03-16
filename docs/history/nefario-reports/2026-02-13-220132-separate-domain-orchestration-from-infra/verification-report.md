# Behavioral Equivalence Verification

## Assembly Output Diff
- Lines changed: 138 (additions + removals counted individually)
- Original: 869 lines; Assembled: 955 lines (+86 net)
- Semantic differences:
  1. **CRITICAL: Post-execution pipeline truncated.** The `post-execution-phases` marker block contains only the first 29 lines of Phase 5 (up to the start of the code review prompt template). Phases 6, 7, 8, the rest of Phase 5 (code review prompt body, security escalation, secret scan patterns), and the original synthesis-awareness notes + skip option documentation are all missing. Root cause: DOMAIN.md's `## Post-Execution Pipeline` section contains markdown code blocks with `## Changed Files`, `## Execution Context`, `## Your Review Focus`, and `## Instructions` inside them. The awk section extractor in `assemble.sh` treats these as H2 headings, splitting the section prematurely at line 29 of 139.
  2. **Content added (not in original).** The `architecture-review` section from DOMAIN.md injects "Review Focus Descriptions" (10 items), "Review Examples" (3 code blocks: good ADVISE, bad ADVISE, good BLOCK), and an H3 "Custom Reviewer Prompts" subsection with ux-strategy-minion prompt template. These were NOT present in the original AGENT.md. This is a semantic expansion, not equivalence.
  3. **Content removed (in original, not in assembled).** A 7-line paragraph explaining discretionary reviewer evaluation mechanics ("During synthesis, nefario evaluates each discretionary reviewer against the delegation plan using a forced yes/no enumeration...") was present in the original at lines 649-655. The DOMAIN.md's `## Architecture Review` section does not include this paragraph. This paragraph provided behavioral guidance for the synthesis step.
  4. **Content removed (in original, not in assembled).** The post-execution section in the original (lines 789-803) included:
     - 4-line summary of all post-execution phases (5-8) with brief descriptions
     - 3-line synthesis awareness notes ("Test strategy does not need a dedicated execution task", etc.)
     - 4-line skip option documentation ("Skip docs", "Skip tests", "Skip review", freeform flags)
     These are all absent from the assembled output.
  5. **Minor: Heading format changes.** "**Mandatory reviewers (ALWAYS):**" changed to "### Mandatory Reviewers"; "**Discretionary reviewers...**" changed to "### Discretionary Reviewers". Functionally equivalent for LLM consumption.
  6. **Minor: Label removal.** "**File-Domain Awareness**: When analyzing..." lost the bold label prefix. Content preserved.
  7. **Expected: Assembly markers.** 24 `<!-- @domain:... BEGIN/END -->` comment lines added. These are HTML comments -- invisible to markdown rendering and semantically neutral for LLM processing.

## SKILL.md Markers
- Total markers added: 7 (all `<!-- INFRASTRUCTURE -->`)
- All are HTML comments: yes
- Behavioral impact: none (standalone informational annotations, not inside functional content)

## Adapter Completeness
- Audit items extracted/marked: 12/12 (9 extracted into DOMAIN.md, 3 marked with preserved content)
- Missing items: none -- all identified extraction seams have corresponding markers
- **BUT**: The extraction of `post-execution-pipeline` is broken due to the awk parsing bug, so while the marker exists and DOMAIN.md contains the full content, the assembly does not produce correct output.

## Governance Invariants
- lucy in mandatory reviewers: yes (line 556 and line 668)
- margo in mandatory reviewers: yes (line 556 and line 669)
- Cross-cutting checklist preserved: yes (6 dimensions with agent assignments, identical to original)
- Gate examples preserved: yes (MUST-gate and no-gate examples identical to original)

## Assembly Idempotence
- Second run identical: yes (diff exit code 0)

## Unmatched Markers
- meta-plan-checklist: preserved (6-line checklist identical to original)
- synthesis-cross-cutting: preserved (placeholder text identical to original)
- synthesis-review-agents: preserved (3-line template identical to original)

## Install Verification
- install.sh exit code: 0
- Symlinks created: 29 (27 agents + 2 skills)
- AGENT.md symlink target correct: yes (`/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`)

## Verdict: FAIL

### Failures Requiring Remediation

**F1 (Critical): Post-execution pipeline content truncated**

The awk H2 heading parser in `assemble.sh` (line 73: `/^## [^#]/`) does not track whether it is inside a markdown code fence (`` ``` ``). When DOMAIN.md sections contain code blocks with H2-level headings (e.g., `## Changed Files`), the parser treats them as new section boundaries, splitting the section and discarding most of the content.

Impact: The assembled AGENT.md is missing ~110 lines of post-execution pipeline content (Phases 6-8, most of Phase 5, security escalation, test discovery, documentation outcome-action table, marketing tiers).

Remediation: Modify the awk section extractor to track code fence state. When inside a `` ``` `` block, do not match `/^## /` as a heading. Example fix:

```awk
# Add code fence tracking
/^```/ { in_fence = !in_fence }
!in_fence && /^## [^#]/ { ... existing heading logic ... }
```

**F2 (Moderate): Content added that was not in original**

The `## Architecture Review` section in DOMAIN.md includes "Review Focus Descriptions", "Review Examples", and "Custom Reviewer Prompts" subsections that were not in the original AGENT.md. This is a semantic expansion, not equivalence.

Impact: The model receives additional guidance (focus descriptions per reviewer, good/bad examples of ADVISE and BLOCK verdicts, a full ux-strategy-minion prompt template) that was not previously present. This is likely beneficial but is not behavioral equivalence.

Remediation: Either (a) accept this as an intentional enhancement and document it, or (b) remove these subsections from DOMAIN.md to match the original, or (c) backport them to the original before the extraction to establish a clean baseline.

**F3 (Moderate): Content removed from original**

Two blocks of content present in the original AGENT.md are not in the assembled output:
1. The 7-line discretionary reviewer evaluation paragraph (synthesis behavioral guidance)
2. The post-execution summary block (4-phase summary, synthesis awareness notes, skip option documentation)

Impact: The model loses guidance on how to evaluate discretionary reviewers during synthesis, and loses the synthesis-mode awareness notes about which post-execution phases handle what (test strategy, documentation, code review).

Remediation: Add the missing content to DOMAIN.md in the appropriate sections, or restructure the template to keep these as infrastructure content outside the domain markers.
