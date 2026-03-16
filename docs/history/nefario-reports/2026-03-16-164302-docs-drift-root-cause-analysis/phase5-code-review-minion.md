## Code Review: docs-drift Phase 8 restructure

**Reviewer**: code-review-minion
**Files reviewed**:
- `skills/nefario/SKILL.md` (Phase 8, skip handling, CONDENSE lines)
- `docs/history/nefario-reports/TEMPLATE.md` (docs-debt field, Documentation Debt section)
- `nefario/AGENT.md` (post-execution-phases section)

---

VERDICT: ADVISE

FINDINGS:

- [ADVISE] TEMPLATE.md:22 vs TEMPLATE.md:299 -- Frontmatter skeleton (line 22)
  declares `docs-debt: {none | deferred}` (two values), but the Frontmatter
  Fields table (line 299) also lists only `none` and `deferred`. The synthesis
  spec (phase3-synthesis.md) originally specified three values: `none`,
  `deferred`, and `not-evaluated`. The `not-evaluated` value was dropped from
  the implementation. This is defensible (Task 1 makes Phase 8a non-skippable,
  so `not-evaluated` should never occur), but the omission creates a silent
  forward-compatibility gap: if Phase 8a is ever bypassed by a future code path
  (e.g., advisory-mode orchestrations, or Phase 4 producing zero outcomes), the
  report has no valid value to write. The conditional section rule (line 316)
  says `OMIT WHEN docs-debt = none`, which would silently suppress a debt table
  even when evaluation was skipped entirely. Consider either: (a) keeping
  `not-evaluated` as a third value to make the omission explicit and
  auditable, or (b) explicitly documenting in TEMPLATE.md why `not-evaluated`
  was dropped and what value to use for advisory-mode reports.
  AGENT: ai-modeling-minion
  FIX: Either add `not-evaluated` back to the frontmatter skeleton and fields
  table, or add a note to the fields table: "Advisory-mode orchestrations
  (mode: advisory) where Phase 8 does not run should use `none`."

- [ADVISE] SKILL.md:1777 -- CONDENSE line for "all post-exec skipped (8b only)"
  reads: `Assessing: documentation...`. The label "Assessing" implies active
  analysis underway to the reader, but this label appears on the CONDENSE line
  printed BEFORE Phase 8a runs. If Phase 8a finds zero items (checklist empty),
  the eventual wrap-up summary will say "Verification: skipped (--skip-post)."
  with no debt notation -- which reads as if nothing happened. There is no
  CONDENSE confirmation line after Phase 8a completes in the skip-all-post-exec
  path, leaving the user with only the initial "Assessing: documentation..."
  with no follow-up signal. For the skip-docs-only path (line 1775), Phase 5
  and 6 wrap into the consolidated verification summary, providing natural
  closure. The skip-all path has no such carrier. The wrap-up verification
  summary examples (lines 2097 and 2101) handle the debt and no-debt cases, so
  the terminal output is correct -- the gap is that the intermediate CONDENSE
  line ("Assessing: documentation...") is never explicitly resolved in the
  skip-all path when debt is zero.
  AGENT: ai-modeling-minion
  FIX: Add a note after the CONDENSE status line table at line 1777: "When
  Phase 8a completes with 0 items in the skip-all-post-exec path, the wrap-up
  verification summary serves as implicit closure. No additional CONDENSE line
  is needed." This makes the intent explicit rather than leaving it as an
  inference.

- [ADVISE] AGENT.md:838-841 -- The post-execution-phases section still describes
  the skip mechanism as "multi-select at approval gates: check 'Skip docs',
  'Skip tests', and/or 'Skip review' (confirm with none selected to run all)."
  This description is stale: SKILL.md was updated to use a single-select with
  three named options ("Run all", "Skip docs only", "Skip all post-exec"). The
  AGENT.md skip description does not match the actual gate UX. A planning agent
  reading AGENT.md would form an incorrect mental model of the skip mechanism.
  AGENT: ai-modeling-minion
  FIX: Update lines 838-841 to: "Users can skip post-execution phases via
  single-select at the post-execution gate: 'Run all', 'Skip docs only', or
  'Skip all post-exec'. Freeform flags --skip-docs, --skip-tests, --skip-review,
  --skip-post also accepted. Phase 8a (documentation assessment) is
  non-skippable regardless of skip selection."

- [NIT] TEMPLATE.md:213 -- The Documentation Debt section inclusion rule reads
  `{INCLUDE WHEN docs-debt = deferred. OMIT WHEN docs-debt = none.}` inline in
  the skeleton body. The conditional section rules table (line 316) already
  encodes this rule formally. Having it in two places is not harmful but creates
  a maintenance surface: if the values change, both locations need updating. Low
  risk given the skeleton is copy-pasted at report time rather than programmatically
  rendered. No change required unless the template tooling is automated later.
  AGENT: ai-modeling-minion
  FIX: No immediate action needed. If a template renderer is ever built, the
  inline annotation should be the canonical source and the rules table the
  derived view.

- [NIT] SKILL.md:2082-2083 -- Step 7 in Phase 8b says "Write output to:
  `$SCRATCH_DIR/{slug}/phase8-software-docs.md`, `phase8-user-docs.md`,
  `phase8-marketing-review.md`". This duplicates the per-agent output
  instructions already given in steps 4 and 5 (which each specify their own
  write targets). The redundancy is harmless and provides a useful summary, but
  "phase8-marketing-review.md" in step 7 was already specified in step 5 at
  line 2070 with the full path. No correctness issue.
  AGENT: ai-modeling-minion
  FIX: No action required.

---

### Correctness Verification (per synthesis verification checklist)

1. **Phase 8a non-skippable in all paths**: CONFIRMED. Lines 1754-1777 show
   all four skip paths ("Run all", "Skip docs only", "Skip all post-exec",
   freeform flags) explicitly retain Phase 8a. The non-skippable assertion at
   line 1769 is structurally backed by the table above it. The canonical note
   "All skipped including 8a: this cannot occur in normal orchestrations"
   (line 1778) is present.

2. **"Handled inline" claims banned**: CONFIRMED. Line 1990-1992 requires
   file path + section citation for any claim that Phase 4 addressed an item.
   Items without evidence stay as UNVERIFIED. The rule at lines 1944-1947
   explicitly names the anti-pattern.

3. **Debt visibility on skip**: CONFIRMED. Lines 1999-2011 specify the CONDENSE
   debt line format, MUST-priority prioritization, and wrap-up summary inclusion.
   The wrap-up examples at lines 2100-2101 cover both the partial-skip-with-debt
   and full-skip-with-debt cases.

4. **Outcome-action table row count**: CONFIRMED. The synthesis spec required
   11 original + 7 new + 1 catch-all = 19 rows. Lines 1960-1980 show 19 rows.
   The catch-all row (line 1980) is present. The table header adds 2 lines
   (header + separator) -- total block is 21 lines including those, matching
   expectation.

5. **Priority assignment updated**: CONFIRMED. Lines 1982-1988 include all new
   categories. "Existing behavior contradicts docs (stale content)" is listed
   as MUST per the synthesis requirement. "New secrets/env vars" and "new
   publicly accessible endpoints" are SHOULD. New response headers, CORS/security
   headers, developer setup changes, and error response changes are COULD.

6. **TEMPLATE.md docs-debt field and Documentation Debt section**: CONFIRMED.
   Field present in skeleton (line 22), fields table (line 299), conditional
   rules (line 316), and report writing checklist step 13a (line 438-439).

7. **AGENT.md 8a/8b split**: CONFIRMED with caveat. The Phase 8 bullet at
   AGENT.md line 830 accurately describes the 8a/8b split and debt recording.
   The stale skip mechanism description (ADVISE finding above) is in a different
   paragraph and does not contradict the Phase 8 bullet itself.

8. **No rejected proposals leaked**: CONFIRMED. No debt ledger file, no
   diff-based scanning, no Phase 5 expansion, no --docs-catchup mode found in
   any of the three files.

---

### Cross-file consistency summary

| Claim | SKILL.md | TEMPLATE.md | AGENT.md | Consistent? |
|-------|----------|-------------|----------|-------------|
| Phase 8a always runs | Yes (line 1769) | Implied by `none`/`deferred` | Yes (line 830) | Yes |
| 8b skippable | Yes (line 2013-2017) | Captured via `deferred` | Yes (line 830) | Yes |
| Debt recorded in report | Yes (lines 2003-2011) | Documentation Debt section | Yes (line 830) | Yes |
| `not-evaluated` value | Not present | Not present | N/A | Consistent but see ADVISE |
| Skip mechanism (single-select) | Yes (line 1659-1662) | N/A | Stale (multi-select) | MISMATCH -- see ADVISE |
| Catch-all row in table | Yes (line 1980) | N/A | N/A | N/A |
