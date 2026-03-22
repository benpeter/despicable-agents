# Lucy Review: Margo YAGNI Calibration

## Original Intent

The user wants margo's YAGNI enforcement calibrated to distinguish between speculative features (no known consumer -- defer) and roadmap-planned features with a concrete consumer (evaluate proportional complexity only). The CLAUDE.local.md "YAGNI Scope" override should be absorbed into the canonical spec and AGENT.md so the system works without the local override.

## Requirement Traceability

| Requirement | Plan Element | Status |
|---|---|---|
| Two-tier YAGNI evaluation (speculative vs. roadmap-planned) | margo/AGENT.md YAGNI Enforcement section (lines 160-184) | COVERED |
| Concrete consumer criteria (milestone/task/issue, active roadmap, planned use) | margo/AGENT.md lines 164-167 | COVERED |
| Proportional complexity filter (trivially non-breaking vs. structurally complex) | margo/AGENT.md lines 172-179 | COVERED |
| Explicit labeling (SPECULATIVE / ROADMAP-PLANNED) | margo/AGENT.md lines 181-184 | COVERED |
| Spec update in the-plan.md | the-plan.md margo remit lines 546-548 | COVERED |
| Decision record | docs/decisions.md Decision 33 lines 453-465 | COVERED |
| CLAUDE.local.md override removed | Decision 33 claims this; actual CLAUDE.local.md still contains override | GAP |

## Verdict

**VERDICT: ADVISE**

## Findings

### 1. [ADVISE] margo/AGENT.md:10 -- x-plan-version matches spec-version (no issue)
  **CHANGE**: x-plan-version is "1.2", spec-version in the-plan.md is 1.2.
  **WHY**: Versions are consistent. The spec-version was not bumped for this change, and the AGENT.md already tracked 1.2 from a prior build. This means the two-tier YAGNI content was added to AGENT.md without a spec-version bump, OR it was added to both the spec and the AGENT.md at version 1.2. Either way, the versions match. No action needed -- noted for completeness.

### 2. [NIT] docs/decisions.md:460 -- Decision 33 date is 2026-03-19, today is 2026-03-21
  **CHANGE**: Decision 33 records the date as 2026-03-19.
  **WHY**: If this decision was drafted two days ago and is being committed now, that is fine -- the date represents the decision date, not the commit date. Consistent with Decision 32 (dated 2026-03-17, committed later). No action required unless the decision was actually made today, in which case update to 2026-03-21.

### 3. [ADVISE] CLAUDE.local.md -- "YAGNI Scope: Roadmap-Aware, Not Myopic" override still present
  **CHANGE**: Decision 33 states "CLAUDE.local.md override removed" in its Consequences field.
  **WHY**: The user's CLAUDE.local.md (at `/Users/ben/github/benpeter/despicable-agents/CLAUDE.local.md`) still contains the "YAGNI Scope: Roadmap-Aware, Not Myopic" section. Since CLAUDE.local.md is gitignored, it cannot be modified by this PR. However, the Decision 33 record claims it was removed, which is currently inaccurate. Either (a) the user needs to manually remove the section from CLAUDE.local.md after merge, or (b) Decision 33's Consequences field should say "CLAUDE.local.md override should be removed by the user after merge" rather than "removed."
  AGENT: nefario (orchestration / decision record authorship)
  FIX: Update Decision 33 Consequences to say "CLAUDE.local.md override to be removed by the user post-merge" or add a post-merge action item. Alternatively, the user removes the override section from CLAUDE.local.md now.

### 4. [NIT] docs/decisions.md:453 -- Decision 33 format is consistent with existing decisions
  **CHANGE**: Decision 33 uses the same table format (Status, Date, Choice, Alternatives rejected, Rationale, Consequences) as Decisions 30-32.
  **WHY**: Format compliance verified. Section header follows the pattern of recent decisions (section heading with decision group name, then ### with numbered title). Consistent.

### 5. [NIT] the-plan.md:546-548 -- Minimal modification to human-edited file
  **CHANGE**: The margo remit bullet for YAGNI was updated from the previous binary wording to reference "two-tier evaluation: speculative features (no concrete consumer) are flagged for exclusion; roadmap-planned items (named consumer on active roadmap) are evaluated for proportional complexity only."
  **WHY**: The change is minimal and scoped -- it modifies only the YAGNI detection bullet within margo's remit. The spec-version remains 1.2, which is acceptable if this change is considered a clarification within the existing version rather than a functional expansion. However, the AGENT.md content now includes substantial new material (the full two-tier justification test with concrete consumer criteria, proportional complexity tiers, and labeling requirements) that goes well beyond the one-line remit update. If this represents a meaningful behavioral change, a spec-version bump to 1.3 would be appropriate to maintain the versioning contract.
  AGENT: nefario (spec version management)
  FIX: Consider bumping spec-version to 1.3 in the-plan.md and x-plan-version to 1.3 in AGENT.md. If the two-tier language was already present at 1.2, no action needed.

### 6. [ADVISE] margo/AGENT.md:160-184 -- Two-tier language faithfully represents user intent
  **CHANGE**: The YAGNI Enforcement section now includes a full two-tier justification test with explicit criteria for "concrete consumer," proportional complexity evaluation (trivially non-breaking vs. structurally complex), and mandatory labeling (SPECULATIVE / ROADMAP-PLANNED).
  **WHY**: Comparing against the user's original CLAUDE.local.md override ("YAGNI Scope: Roadmap-Aware, Not Myopic"), the core intent is preserved: roadmap items with known consumers should not be deferred as YAGNI violations. The AGENT.md version adds rigor the override lacked: (a) explicit criteria for what makes a consumer "concrete," (b) a proportional complexity filter that prevents the exemption from justifying heavyweight additions, and (c) mandatory labeling. These additions strengthen the user's intent rather than drifting from it. The user's override said "If a field, feature, or capability is on the known roadmap with a concrete planned consumer, include it now. Only defer genuinely speculative additions with no planned use case." The AGENT.md version faithfully captures this while adding the complexity proportionality guard that the user did not explicitly request but that prevents the exemption from becoming a blanket bypass. This is a reasonable elaboration, not drift.

### 7. [NIT] margo/AGENT.md:229-230 -- Scope Creep cross-reference to YAGNI two-tier is well-integrated
  **CHANGE**: The "Future-proofing" bullet in Scope Creep Detection now says "(see YAGNI Enforcement for roadmap-planned item evaluation)" instead of treating all future-proofing as scope creep.
  **WHY**: This cross-reference prevents inconsistency between the two sections. Without it, margo could flag a roadmap-planned item as scope creep in one section while accepting it as ROADMAP-PLANNED in another. Good integration.

## Summary

The changes faithfully represent the user's intent to calibrate YAGNI enforcement. The two-tier evaluation is well-structured and adds appropriate rigor. The only substantive concern is Finding 3: Decision 33 claims the CLAUDE.local.md override was removed, but it still exists (gitignored file, cannot be changed by PR). This needs either a user action or a Decision 33 wording fix. Finding 5 (version bump consideration) is secondary but worth addressing for versioning hygiene.
