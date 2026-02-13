# Documentation Audit Findings

Audit of `docs/` files for inconsistencies with the rewritten README.md.

---

## MUST Fix

### Reviewer count: "six ALWAYS reviewers" in decisions.md

The README now correctly states "five mandatory reviewers" (security-minion, test-minion, software-docs-minion, lucy, margo). The orchestration.md Phase 3.5 table (lines 57-65) already correctly lists five mandatory reviewers with ux-strategy-minion moved to discretionary. However, decisions.md has three locations that still reference "6 ALWAYS reviewers" in the context of Phase 3.5 mandatory reviewers:

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md` -- **Issue**: Decision 10 (line 128) states "Six ALWAYS reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo)". This explicitly names ux-strategy-minion as an ALWAYS reviewer, which contradicts the current state where ux-strategy-minion is discretionary. -- **Line(s)**: 128

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md` -- **Issue**: Decision 12 Consequences (line 153) states "6 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5)". This is now stale since the ALWAYS count was reduced from 6 to 5 when ux-strategy-minion was moved to discretionary. -- **Line(s)**: 153

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md` -- **Issue**: Decision 15 Consequences (line 191) states "Every `/nefario` run incurs review cost (6 ALWAYS + 0-4 conditional reviewers)". Should now read "5 ALWAYS + 0-6 discretionary reviewers" to match the current Phase 3.5 structure. -- **Line(s)**: 191

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md` -- **Issue**: Decision 20 Consequences (line 262) states "Phase 3.5 minimum review cost increases (6 ALWAYS reviewers)". Should reference 5 ALWAYS reviewers. -- **Line(s)**: 262

**Note on ADR immutability**: Decisions 10, 12, and 20 are historical records documenting what was decided at the time. The "6 ALWAYS" count was correct when those decisions were made. However, Decision 15 (line 191) describes current consequences that are now factually wrong. The recommended approach: add a note to Decisions 10, 12, and 20 indicating the reviewer count was subsequently changed (with a cross-reference to the rework), and update Decision 15's consequences to reflect the current 5+6 structure. Alternatively, treat all four as historical and leave unchanged -- but this risks confusing anyone who reads decisions.md to understand the current system.

---

## SHOULD Fix

### "Six cross-cutting dimensions" references (orchestration.md, architecture.md)

These references are about the **cross-cutting checklist dimensions** (Testing, Security, Usability-Strategy, Usability-Design, Documentation, Observability), NOT the Phase 3.5 reviewer count. The six dimensions are still six, so these are technically correct. However, they may cause confusion when read alongside the README's "five mandatory reviewers" language.

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` -- **Issue**: Lines 20, 44, 334 reference "six dimensions" and "six cross-cutting dimensions". These are accurate (the checklist has 6 dimensions), but could be confused with the reviewer count. No change needed unless the project wants to add clarifying language. -- **Line(s)**: 20, 44, 334

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/architecture.md` -- **Issue**: Line 113 states "six dimensions". Same as above -- accurate for the cross-cutting checklist, distinct from the reviewer count. -- **Line(s)**: 113

### "Six domain groups" reference (orchestration.md)

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` -- **Issue**: Line 318 states "all six domain groups". The README agent roster table shows 7 domain groups (Protocol & Integration, Infrastructure & Data, Intelligence, Development & Quality, Security & Observability, Design & Documentation, Web Quality). This may be a pre-existing inconsistency unrelated to the README rewrite, but worth noting. -- **Line(s)**: 318

### No "vibe-coded" references in architecture docs

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/architecture.md` -- checked for: "vibe-coded", "vibe coded", or similar framing. No matches found in architecture.md. The term appears only in nefario execution report history files (which are historical records and should not be changed).

### No stale agent count references in external-skills.md

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/external-skills.md` -- checked for: "29 agents", "29-agent", or any specific agent count number. No matches found. The document does not reference a specific agent count.

### No orphaned README anchor links

- **File**: All `docs/*.md` files -- checked for: links containing `README.md#` (anchored links to specific README sections). No matches found. Cross-references from docs to README use `../README.md` without anchors, so the section reordering (removal of #try-it, addition of #what-you-get) does not break any links.

### No "This project explores" framing

- **File**: All `docs/*.md` files -- checked for: "This project explores". No matches found.

---

## No Issues Found

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` -- checked for: references to old README structure, "Try It" section links, reviewer count claims, agent count claims. No issues. The file references `../README.md` without anchors and does not claim a reviewer count.

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` -- checked for: Phase 3.5 mandatory reviewer count. The reviewer table (lines 57-65) correctly lists 5 mandatory reviewers. The "six" references on lines 20, 44, 334 refer to the cross-cutting dimension checklist (which is genuinely six), not the reviewer count.

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/agent-catalog.md` -- checked for: reviewer count claims, agent count claims, README section links. No issues. States "27 agents" which is consistent with the README.

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/external-skills.md` -- checked for: agent count references, reviewer count references. No issues.

---

## Summary

| Priority | Count | Description |
|----------|-------|-------------|
| MUST | 4 findings | decisions.md references "6 ALWAYS reviewers" in Decisions 10, 12, 15, 20 |
| SHOULD | 2 findings | "six dimensions/groups" references that are accurate but may cause confusion |
| Clean | 4 files | using-nefario.md, orchestration.md, agent-catalog.md, external-skills.md |

The primary inconsistency is in `decisions.md`, where four decision entries reference "6 ALWAYS reviewers" -- a count that was correct when those decisions were written but is now stale after ux-strategy-minion was moved from mandatory to discretionary. The most actionable fix is Decision 15 (line 191), which describes current runtime behavior rather than a historical decision.

No orphaned anchor links, no "vibe-coded" references in active docs, no stale agent counts, and no references to removed README sections were found.
