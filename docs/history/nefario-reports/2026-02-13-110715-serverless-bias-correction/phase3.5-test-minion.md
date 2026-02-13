# Phase 3.5 Review: test-minion

## Verdict: ADVISE

The advisory is well-structured and the four-priority plan is sound. No blocking issues. Two non-blocking concerns from a testing perspective:

### 1. Phase E Verification Is Underspecified and Unrepeatable

Section 7, Phase E describes two dry-run tests ("deploy a simple API" greenfield scenario and a WebSocket counter-test). These are manual, narrative-level checks with no defined pass/fail criteria. They verify the happy path once but provide no regression safety. When iac-minion or margo are rebuilt in the future (spec bumps, knowledge updates), these checks will not be re-run because they exist only as prose in an advisory document.

**Recommendation**: When Phase E is executed, capture the dry-run scenarios as lightweight, documented test cases (even if they remain manual) with explicit expected outcomes. For example:

- Input: greenfield project, serverless-first CLAUDE.md, "deploy a 3-endpoint API with PostgreSQL"
- Expected: iac-minion recommends Level 2 (serverless app), delegation routes through "Deployment strategy selection" row, margo does not flag complexity
- Failure: iac-minion proposes Docker/Terraform, or delegation routes through generic "Infrastructure provisioning" row

This makes re-verification possible after future agent rebuilds.

### 2. Testability of the Triage Decision Tree Is Not Addressed

The plan introduces a deployment strategy triage decision tree as a new first step in iac-minion's working pattern. Decision trees are excellent candidates for structured testing -- each branch can be validated with a known input/output pair. The advisory does not mention how to verify the tree produces correct recommendations across its decision space (all-NO path, single-YES paths, multiple-YES paths, edge cases like "WebSockets but low traffic").

**Recommendation**: When building the triage decision tree into iac-minion's AGENT.md, include 3-5 worked examples (scenario + recommended level + rationale) inline in the agent knowledge. These serve as both documentation and implicit test cases that make the decision tree auditable. They also give iac-minion calibration anchors when applying the tree to novel inputs.

### Not In Scope (Acknowledged)

The advisory is about correcting bias in agent knowledge and routing, not about testing serverless deployments themselves. The question of "how should test-minion advise on testing serverless functions" (local emulation, integration testing with cloud services, cold start testing) is a separate concern that would arise during actual project execution, not during this advisory implementation. No gap here.
