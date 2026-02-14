# Code Review Report: Serverless Bias Fix (Issue #91)

**Reviewer**: code-review-minion
**Review Date**: 2026-02-14
**Execution Team**: serverless-bias-fix
**Verdict**: ADVISE

## Summary

This execution addresses GitHub issue #91 by expanding iac-minion to include serverless platforms, recalibrating margo's complexity budget to account for operational burden, clarifying boundaries between iac-minion and edge-minion, adding delegation table routing for deployment strategy tasks, and creating a CLAUDE.md template for target projects to signal deployment preferences.

The implementation is high quality overall. The spec changes are coherent and well-balanced. The built agents correctly implement the expanded specifications. The CLAUDE.md template is well-designed and topology-neutral. Documentation updates are accurate.

**Three issues require attention before merge**:

1. **Critical**: Delegation table inconsistency between synthesis plan and implementation (devx-minion omission)
2. **Moderate**: iac-minion spec-version discrepancy (2.0 vs. planned 1.1)
3. **Minor**: Missing infrastructure proportionality examples in margo/AGENT.md

## Detailed Findings

### Correctness

#### Issue 1: Delegation Table Supporting Agent Mismatch (CRITICAL)

**Location**: `/Users/ben/github/benpeter/2despicable/4/the-plan.md` line 312 and `/Users/ben/github/benpeter/2despicable/4/nefario/AGENT.md` line 127

**Problem**: The synthesis plan (phase3-synthesis.md lines 15-20) shows that devx-minion's recommendation won the conflict resolution for the "Deployment strategy selection" row. The resolution explicitly states:

```
The two new rows will be:
1. "Deployment strategy selection" -- iac-minion primary, edge-minion supporting.
```

However, the original conflict (lines 10-14) shows devx-minion participated in the discussion and the synthesis decision rationale (line 231) states:

```
edge-minion supports because edge/serverless platforms straddle the boundary.
devx-minion supports because developer experience (time-to-first-deploy,
operational burden) is a decision input.
```

**Implemented**:
```markdown
| Deployment strategy selection | iac-minion | edge-minion |
```

**Expected based on synthesis rationale**:
```markdown
| Deployment strategy selection | iac-minion | edge-minion, devx-minion |
```

**Impact**: This is a correctness issue. The synthesis plan acknowledged that developer experience (devx-minion's domain) is a legitimate input to deployment strategy selection. The final conflict resolution omitted devx-minion from the supporting column, but the rationale (line 231) still references devx-minion's input. Either the synthesis rationale or the table row is incorrect.

**Recommendation**: Verify whether devx-minion should be a supporting agent for "Deployment strategy selection". If yes, add it to both the-plan.md line 312 and nefario/AGENT.md line 127. If no, remove the devx-minion reference from the synthesis rationale. Based on the conflict discussion, devx-minion's inclusion seems justified (DX considerations like time-to-first-deploy and operational burden ARE deployment strategy inputs).

**Severity**: Critical - this is a routing correctness issue that affects how nefario delegates deployment strategy tasks.

---

#### Issue 2: iac-minion spec-version Discrepancy (MODERATE)

**Location**: `/Users/ben/github/benpeter/2despicable/4/the-plan.md` line 757

**Problem**: The synthesis plan task specification (lines 38-104) states:

```
5. **Bump spec-version** from 1.0 to 1.1
```

Success criteria (line 103):
```
(5) spec-version is 1.1
```

**Implemented**:
```yaml
spec-version: 2.0
```

**Analysis**: The spec was bumped to 2.0 instead of 1.1. This is not necessarily wrong - the remit expansion (adding serverless platforms, deployment strategy selection, boundary clarifications) could justify a major version bump rather than a minor bump. However, the discrepancy between plan and implementation should be documented.

**Recommendation**: Either:
- Document why 2.0 was chosen instead of 1.1 (remit expansion warrants major version bump), OR
- Change spec-version to 1.1 per the original plan

Given that the remit DID expand significantly (new technology category, new decision framework, new research focus), 2.0 seems defensible. However, the plan explicitly called for 1.1, so this deviation should be explained.

**Severity**: Moderate - versioning inconsistency could confuse future maintainers. Does not affect runtime behavior.

---

#### Issue 3: Missing Infrastructure Proportionality Examples (MINOR)

**Location**: `/Users/ben/github/benpeter/2despicable/4/margo/AGENT.md` lines 126-133

**Problem**: The synthesis plan (lines 133-137) specifies that the infrastructure proportionality heuristic should include "five concrete signals":

```
(1) deploy pipeline exceeds application code for a small project
(2) scaling machinery without scale evidence
(3) ops surface exceeds team capacity
(4) >5 infrastructure config files for a 1-2 file deploy
(5) deployment ceremony requiring >3 steps when git-push deploy suffices
```

**Implemented**: Only three signals are present in margo/AGENT.md (deploy pipeline size, scaling machinery without evidence, observability stack maintenance).

**Missing**:
- ">5 infrastructure config files for a 1-2 file deploy"
- "deployment ceremony requiring >3 steps when git-push deploy suffices"
- "ops surface exceeds team capacity"

**Impact**: The built agent provides fewer concrete signals than the spec intended. This reduces the actionability of the infrastructure proportionality guidance.

**Recommendation**: Add the missing two signals to margo/AGENT.md line 127 (Infrastructure Proportionality section). This enhances the heuristic's practical utility.

**Severity**: Minor - the existing signals are sufficient for basic assessment, but the missing signals add value.

---

### Testing

**Status**: Not applicable for this change type. The synthesis plan (line 414) correctly identifies that test-minion is not needed for specification document changes. The /despicable-lab build pipeline has its own cross-check phase (Step 3) which validates internal consistency.

**Post-execution testing**: Phase 6 should verify that the built agents behave correctly when invoked (deployment strategy selection produces criteria-based recommendations, margo applies two-column budget correctly).

---

### Readability

**Overall**: High. All modified files are well-structured and clearly written.

**the-plan.md spec changes**: Concise, surgical changes that preserve existing content while adding new capabilities. No wholesale rewrites.

**iac-minion/AGENT.md**: The "Step 0: Deployment Strategy Selection" section (lines 166-189) is clear and actionable. The 10-criteria evaluation framework is comprehensive. The topology recommendation section provides concrete guidance without bias.

**margo/AGENT.md**: The two-column complexity budget (lines 53-79) is intuitive and well-explained. The operational complexity section (lines 86-119) provides strong rationale for the recalibration. The infrastructure proportionality section (lines 120-133) is clear, though missing some examples (see Issue 3).

**edge-minion/AGENT.md**: The full-stack serverless platform clarification (lines 26-27) is concise and accurate. The boundary statement in "Does NOT do" (lines 785-789) is symmetric with iac-minion's boundary.

**docs/claudemd-template.md**: Excellent progressive disclosure. The template itself is minimal (one sentence + optional context). The examples cover diverse topologies without bias. The explanation of default behavior is clear.

---

### Design

**Overall**: The design achieves the stated goals: eliminate serverless bias, add deployment strategy routing, recalibrate complexity assessment.

**Topology Neutrality**: Verified. The iac-minion deployment strategy framework (lines 166-189) evaluates workloads against criteria without defaulting to any topology. The "when serverless is inappropriate" research focus (line 754-755) ensures balanced coverage. The margo complexity budget scores managed/serverless lower than self-managed (as expected given operational burden reduction) but never scores zero (acknowledging configuration and vendor complexity).

**Boundary Symmetry**: The iac-minion / edge-minion boundary is well-defined and symmetric. iac-minion owns "where does it run and how does it get there" (deployment strategy, CI/CD, platform config). edge-minion owns "how does it run well once it's there" (caching, routing, edge functions, runtime optimization). Both agents' "Does NOT do" sections reference each other correctly.

**Delegation Table Routing**: The two new rows ("Deployment strategy selection", "Platform deployment configuration") follow the existing task-type naming convention (not solution-category naming). Primary/supporting assignments are logical (iac-minion primary, edge-minion supporting for both).

**CLAUDE.md Template Design**: The template correctly uses declarative prose (not structured key-value pairs), provides balanced examples (serverless, self-managed, general preference, mixed), and explains default behavior clearly. The "when to omit this section" guidance prevents over-specification.

---

### Security

**Status**: No security concerns. This change modifies specification text and documentation, not executable code. No attack surface, no user input, no secrets, no infrastructure changes.

**PII/Proprietary Data**: Verified. No project-specific data, no PII, no proprietary patterns. All content is publishable under Apache 2.0.

---

### Maintainability

**DRY Compliance**: No significant duplication detected. The delegation table is embedded verbatim in nefario/AGENT.md (expected - this is how the build pipeline works). The shared vocabulary (self-managed, managed, serverless/fully managed) is used consistently across iac-minion and margo without direct cross-references (good design - alignment through shared terminology, not coupling).

**Documentation Freshness**: The staleness check (Task 6) correctly updated docs/agent-catalog.md and docs/architecture.md. The architecture.md document now references claudemd-template.md (line 145). No stale references remain in the checked documentation.

**Versioning Consistency**: All three spec-bumped agents (iac-minion, margo, edge-minion) have matching x-plan-version in their AGENT.md frontmatter:
- iac-minion: spec-version 2.0 in the-plan.md, x-plan-version 2.0 in AGENT.md (Issue 2 aside)
- margo: spec-version 1.1 in the-plan.md, x-plan-version 1.1 in AGENT.md
- edge-minion: spec-version 1.1 in the-plan.md, x-plan-version 1.1 in AGENT.md

All build dates are 2026-02-13, consistent with execution timing.

---

### Cross-Agent Integration

**iac-minion ↔ edge-minion boundary**: Symmetric and well-defined. Both agents reference each other's domains in their "Does NOT do" sections. The wrangler.toml example (edge-minion/AGENT.md line 26) correctly assigns runtime bindings to edge-minion and deployment targets to iac-minion.

**iac-minion ↔ margo vocabulary alignment**: Both agents use the same three-tier deployment vocabulary (self-managed, managed, serverless/fully managed). This alignment happens through shared terminology, not direct cross-references (correct design - no coupling).

**Delegation table consistency**: The two new rows in the-plan.md (lines 312-313) match the two new rows in nefario/AGENT.md (lines 127-128) exactly (modulo Issue 1). The nefario rebuild correctly picked up the delegation table changes.

---

### Spec vs. Implementation Fidelity

**iac-minion spec changes**:
- ✅ Remit expanded to include serverless platforms (line 739)
- ✅ Remit expanded to include deployment strategy selection (line 740)
- ✅ Domain updated to include serverless platforms (line 728)
- ✅ "Does NOT do" includes edge-layer boundary clarification (line 744)
- ✅ Research focus includes serverless patterns and decision criteria (lines 750-755)
- ⚠️ spec-version is 2.0 (plan called for 1.1) - see Issue 2

**iac-minion AGENT.md implementation**:
- ✅ "Step 0: Deployment Strategy Selection" framework present (lines 166-189)
- ✅ Framework is criteria-driven, not preference-driven (verified)
- ✅ Covers serverless, containers, self-managed, hybrid (verified)
- ✅ "When serverless is inappropriate" coverage present in research (RESEARCH.md)

**margo spec changes**:
- ✅ Remit expanded to include infrastructure overhead and operational burden (line 544)
- ✅ Research focus includes operational complexity and infrastructure proportionality (lines 567-572)
- ✅ spec-version is 1.1 (matches plan)

**margo AGENT.md implementation**:
- ✅ Two-column complexity budget present (lines 53-79)
- ✅ Operational complexity section present (lines 86-119)
- ✅ Infrastructure proportionality section present (lines 120-133)
- ⚠️ Infrastructure proportionality examples are incomplete (see Issue 3)
- ✅ Topology-neutral framing verified (serverless not exempt from complexity scoring)

**edge-minion spec changes**:
- ✅ Full-stack serverless platform acknowledgment present (lines 776-779)
- ✅ "Does NOT do" includes deployment config boundary clarification (lines 785-789)
- ✅ spec-version is 1.1 (matches plan)

**Delegation table changes**:
- ✅ Two new rows added to the-plan.md under Infrastructure & Data (lines 312-313)
- ✅ Rows use task-type naming (not solution-category naming) as specified
- ⚠️ "Deployment strategy selection" supporting agents may be incomplete (see Issue 1)
- ✅ nefario/AGENT.md delegation table updated (lines 127-128)

**CLAUDE.md template**:
- ✅ Created at docs/claudemd-template.md
- ✅ Follows docs/ conventions (back-link, heading format)
- ✅ Template is declarative prose, not structured data
- ✅ Three balanced examples (serverless, self-managed, general preference)
- ✅ Explains default behavior when section is absent
- ✅ No platform bias detected

**Documentation staleness fixes**:
- ✅ docs/architecture.md updated to reference claudemd-template.md (line 145)
- ✅ No stale references found in docs/agent-catalog.md
- ✅ No stale references found in docs/orchestration.md (not modified, verified correct)

---

## Verification Checklist

Per synthesis plan lines 478-492:

1. ✅ **Spec consistency**: iac-minion 2.0, margo 1.1, edge-minion 1.1 in the-plan.md
2. ⚠️ **Delegation table**: Two new rows exist with primary/supporting assignments (Issue 1: devx-minion possibly missing)
3. ✅ **AGENT.md builds**: x-plan-version matches spec-version for all three agents
4. ✅ **Nefario table**: nefario/AGENT.md contains both new rows
5. ✅ **iac-minion neutrality**: AGENT.md includes deployment strategy selection with criteria-based evaluation (not "prefer serverless")
6. ⚠️ **Margo recalibration**: Two-column budget present, infrastructure proportionality present (Issue 3: missing examples)
7. ✅ **Edge-minion boundary**: "Does NOT do" includes deployment configuration handoff to iac-minion
8. ✅ **Template**: docs/claudemd-template.md exists with balanced examples
9. ✅ **Docs freshness**: No stale references in docs/agent-catalog.md or docs/orchestration.md
10. ✅ **No opposite bias**: iac-minion/AGENT.md evaluates workload criteria neutrally (verified lines 166-189)

---

## Files Changed

### Specification Changes
- `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (iac-minion spec, margo spec, edge-minion spec, delegation table)

### Agent Builds
- `/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/AGENT.md` (v2.0)
- `/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/RESEARCH.md` (expanded)
- `/Users/ben/github/benpeter/2despicable/4/margo/AGENT.md` (v1.1)
- `/Users/ben/github/benpeter/2despicable/4/margo/RESEARCH.md` (expanded)
- `/Users/ben/github/benpeter/2despicable/4/minions/edge-minion/AGENT.md` (v1.1)
- `/Users/ben/github/benpeter/2despicable/4/minions/edge-minion/RESEARCH.md` (expanded)
- `/Users/ben/github/benpeter/2despicable/4/nefario/AGENT.md` (delegation table update)

### Documentation
- `/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md` (new)
- `/Users/ben/github/benpeter/2despicable/4/docs/architecture.md` (template reference added)

---

## Recommendations

### Critical (Must Fix Before Merge)

**1. Resolve delegation table devx-minion discrepancy**

Either add devx-minion to the supporting agents for "Deployment strategy selection" or explain why it was omitted despite the synthesis rationale stating it should be included.

**Recommended action**: Add devx-minion to the supporting column:

```markdown
| Deployment strategy selection | iac-minion | edge-minion, devx-minion |
```

Apply to both `/Users/ben/github/benpeter/2despicable/4/the-plan.md` line 312 and `/Users/ben/github/benpeter/2despicable/4/nefario/AGENT.md` line 127.

**Rationale**: The synthesis rationale (phase3-synthesis.md line 231) explicitly states "devx-minion supports because developer experience (time-to-first-deploy, operational burden) is a decision input." This is a valid point - DX considerations ARE deployment strategy inputs.

### Moderate (Should Fix Before Merge)

**2. Document iac-minion spec-version rationale**

Either document why 2.0 was chosen instead of 1.1, or change to 1.1 per the plan.

**Recommended action**: Add a comment in the commit message or execution report explaining that the remit expansion justified a major version bump (2.0) rather than the planned minor bump (1.1). This is defensible given the scope of changes (new technology category, new decision framework, new boundary clarifications).

### Minor (Nice to Have)

**3. Add missing infrastructure proportionality examples to margo/AGENT.md**

Add the two missing signals to make the heuristic more actionable:
- ">5 infrastructure config files for a 1-2 file deploy"
- "deployment ceremony requiring >3 steps when git-push deploy suffices"

**Recommended action**: Edit `/Users/ben/github/benpeter/2despicable/4/margo/AGENT.md` line 127 to include all five signals from the spec.

---

## Verdict: ADVISE

This execution is high quality and addresses the serverless bias issue comprehensively. The spec changes are well-designed, the built agents correctly implement the specs, and the CLAUDE.md template is excellent.

**Three issues prevent an APPROVE verdict**:

1. **Critical**: Delegation table devx-minion inconsistency requires resolution
2. **Moderate**: iac-minion spec-version discrepancy (2.0 vs. planned 1.1) should be documented
3. **Minor**: Missing infrastructure proportionality examples reduce margo's actionability

**Recommended next steps**:

1. Fix Critical Issue 1 (devx-minion delegation table entry)
2. Document Moderate Issue 2 (spec-version rationale) OR change to 1.1
3. Optionally fix Minor Issue 3 (add missing proportionality examples)

Once Issue 1 is resolved, this work is ready to merge. Issues 2 and 3 are quality improvements but not blockers.

---

## Security Review

No security concerns. No PII, no hardcoded secrets, no injection vectors. All content is publishable under Apache 2.0.

---

## Cross-Agent Integration Quality

The boundary definitions between iac-minion and edge-minion are symmetric and well-designed. The shared vocabulary between iac-minion and margo (self-managed, managed, serverless) creates alignment without coupling. The delegation table updates correctly route deployment strategy tasks to iac-minion with appropriate supporting agents (modulo Issue 1).

---

## Maintainability Assessment

Version tracking is correct (x-plan-version matches spec-version for all agents). Documentation is fresh (no stale references). The changes are surgical and well-scoped (no wholesale rewrites). Future maintainers will be able to understand the rationale and boundaries clearly.

---

**Review completed**: 2026-02-14
**Reviewed by**: code-review-minion
**Execution**: serverless-bias-fix (GitHub issue #91)
**Verdict**: ADVISE (resolve Critical Issue 1, document Moderate Issue 2)
