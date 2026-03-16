## Margo -- Complexity & YAGNI Review

**VERDICT: ADVISE**

The 8a/8b split is structurally sound: it separates an always-run assessment
(cheap) from a skippable execution (expensive), which is the minimum viable
mechanism for tracking docs debt without losing skip ergonomics. The docs-debt
field in the template is a single enum (`none | deferred`) with a conditional
section -- minimal overhead. No rejected proposals (debt ledger, diff scan,
Phase 5 expansion) leaked into the spec.

Two items warrant attention but are not blocking.

---

### FINDINGS

- [ADVISE] `skills/nefario/SKILL.md`:1971-1980 -- **Three outcome-action rows
  overlap with existing rows and should be consolidated.**

  The 8 new rows added to the outcome-action table (lines 1972-1980) bring
  the total from 11 to 19. Three of these overlap with pre-existing rows:

  1. **"New publicly accessible endpoint" (line 1977) overlaps "New API
     endpoints" (line 1962).** A new publicly accessible endpoint IS a new API
     endpoint. The distinction (health checks, .well-known) does not justify a
     separate row -- the action is nearly identical (API reference, OpenAPI spec
     vs. API reference, OpenAPI prose). Consolidate into a single row: "New API
     endpoints (incl. health, well-known)" with combined actions.

  2. **"CORS / security header changes" (line 1979) overlaps "New response
     headers" (line 1974).** CORS headers ARE response headers. A single row
     "Response header changes (incl. CORS, security headers)" with actions
     "API reference, OpenAPI response headers, security docs" covers both.

  3. **"Existing behavior changed (not breaking)" (line 1976) overlaps "Any
     other file touched in Phase 4 referenced by existing docs" (line 1980).**
     Both trigger a scan for stale documentation. The catchall row (1980)
     already covers the case where a behavior change affects existing docs.
     Merge: keep the catchall and add "including non-breaking behavior changes"
     to its action description.

  After consolidation the table would have 16 rows instead of 19. Fewer rows
  means faster assessment in Phase 8a (the LLM evaluates every row against
  execution outcomes). Each removed row is one less evaluation cycle per
  orchestration.

- [ADVISE] `skills/nefario/SKILL.md`:1972 -- **"Spec/config files modified"
  row is vague and risks false positives.**

  "Scan for derivative docs referencing changed sections" is a reasonable
  action, but "spec/config files modified" is extremely broad. Any
  `package.json` change, any `.eslintrc` tweak, any `tsconfig.json` edit
  would match. This row will fire on nearly every orchestration that touches
  configuration, generating checklist noise. Consider scoping it to
  "Project-defining spec files modified (OpenAPI, JSON Schema, AGENT.md spec
  sections)" or similar -- something that distinguishes files with downstream
  documentation from routine config edits.

- [NIT] `docs/history/nefario-reports/TEMPLATE.md`:299 -- **docs-debt field
  description is slightly redundant with the conditional section rule on
  line 316.** The field description says "none (Phase 8a found 0 items or all
  items addressed in 8b), deferred (Phase 8a found items but Phase 8b was
  skipped)" and line 316 repeats the same condition for the Documentation Debt
  section. This is fine for a template (redundancy aids implementers) but worth
  noting -- if the semantics change, two places need updating.

- [NIT] `nefario/AGENT.md`:830 -- The Phase 8 description is a dense single
  line at 340+ characters. Readability would improve by splitting into two
  sentences (one for 8a, one for 8b), but this is stylistic and non-blocking.

---

### Rejected Proposal Leak Check

| Proposal | Status |
|----------|--------|
| Debt ledger (persistent cross-session tracking) | Not present -- confirmed clean |
| Diff scan (automated file-diff-based detection) | Not present -- confirmed clean |
| Phase 5 expansion (adding doc review to code review) | Not present -- confirmed clean |

### Complexity Budget Impact

| Addition | Cost (managed) | Justification |
|----------|---------------|---------------|
| Phase 8a (always-run assessment) | 1 (new abstraction layer) | Directly addresses root cause: docs debt was invisible when Phase 8 was skipped |
| Phase 8b (renamed existing Phase 8 execution) | 0 (rename only) | No new complexity |
| docs-debt frontmatter field | 0.5 (new configuration) | Single enum, minimal |
| Documentation Debt template section | 0.5 (new section) | Conditional, only appears when debt exists |
| 8 new outcome-action rows | 1 (expanded rule set) | 5 of 8 are justified; 3 overlap with existing rows (see ADVISE above) |
| **Total** | **3** | Proportional to the problem if overlapping rows are consolidated |

The overall approach is the minimum viable mechanism: a checklist that always
runs, a field that records whether debt exists, and a conditional report section
that surfaces it. No persistent ledger, no cross-session state, no new tooling.
This is appropriately scoped.
