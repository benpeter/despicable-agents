# Phase 3.5 Review: security-minion

## Verdict: ADVISE

The synthesis is well-structured and the bias diagnosis is sound. The proposed changes do not introduce security vulnerabilities into the agent system itself. However, the advisory has a meaningful gap: it treats serverless as a deployment and simplicity question without addressing the distinct security model that serverless introduces. Three specific warnings follow.

### Warning 1: iac-minion's serverless knowledge must include serverless security patterns

The proposed iac-minion expansion (Section 2, Priority 1) covers deployment strategy selection, platform config, and cost modeling -- but says nothing about security. Serverless has a fundamentally different security model from server-based infrastructure:

- **Shared responsibility shifts upward**: The cloud provider owns OS patching, runtime updates, and network segmentation. The developer owns function-level IAM, input validation, and secrets management. Teams accustomed to server-based security controls (firewalls, host-based IDS, network ACLs) lose those tools entirely.
- **Function-level permissions**: Each Lambda/Worker/serverless function should have its own least-privilege IAM role. The most common anti-pattern is a single overprivileged role shared across all functions. iac-minion must know to recommend per-function roles.
- **Secrets management changes**: No `.env` files on disk. Secrets go through platform-specific stores (AWS Secrets Manager, Vercel Environment Variables with encryption, Cloudflare Workers Secrets). The iac-minion triage tree should include "how does this platform handle secrets?" as a standard evaluation criterion.
- **Cold start injection surface**: Initialization code runs once per cold start and is cached across invocations. State leakage between invocations (global variables, `/tmp` contents on Lambda) is a real attack vector.
- **Event injection**: Serverless functions are triggered by events (HTTP, queue messages, storage events, cron). Each event source is an input vector. The function must validate the event schema, not just the HTTP request body.

**Recommendation**: Add "Serverless Security Considerations" as a subsection under the proposed "Serverless Deployment Patterns" section in iac-minion's knowledge. This does not need to be deep -- security-minion handles deep security review -- but iac-minion must produce deployment recommendations that are secure by default.

### Warning 2: Vendor lock-in is also a security risk, not just a cost/portability risk

Section 6, Risk 2 frames vendor lock-in purely as a cost and portability concern. It is also a security concern:

- **Single point of trust**: A compromised serverless platform (credential breach, supply chain attack on the runtime) exposes all functions simultaneously. With self-managed infrastructure, you control the blast radius.
- **Opaque runtime environment**: You cannot audit the Lambda execution environment, inspect the Workers V8 isolate, or verify what runs alongside your function. This is a trust decision, not just a deployment decision.
- **Platform-specific vulnerabilities**: CVEs in serverless runtimes (e.g., Lambda container escape, Workers isolate bypass) are outside your control to patch. You depend on vendor response time.
- **Data residency and exfiltration**: Serverless data services (D1, DynamoDB, Vercel KV) may replicate data across regions in ways that conflict with data residency requirements. This is a GDPR and compliance concern, not just a preference.

**Recommendation**: Add a bullet to Risk 2's mitigation acknowledging that vendor lock-in carries security implications (single point of trust, opaque runtime, dependency on vendor patching cadence). The portability assessment that iac-minion produces should include a "security trust" dimension alongside cost and portability.

### Warning 3: The escalation ladder should include a security trigger

The escalation triggers table (Section 4) lists performance, cost, and compatibility triggers for moving between levels. It omits security triggers:

- **Compliance-mandated audit trails** that serverless logging does not satisfy --> escalate to Level 3-4
- **Need for WAF, custom network policies, or mTLS** that the serverless platform does not support natively --> escalate
- **Data classification requiring infrastructure-level encryption controls** (BYOK, HSM integration) --> escalate
- **Incident response requirements** where you need to inspect the host, capture memory, or run forensics --> escalate (impossible on serverless)

The table already includes "Data residency / compliance mandates" at Level 2-3 to Level 4, which partially covers this. But security escalation triggers deserve explicit enumeration so iac-minion does not recommend serverless for workloads with security requirements that serverless cannot satisfy.

**Recommendation**: Add 1-2 security-specific rows to the escalation triggers table: "Compliance-mandated infrastructure audit/forensics" and "Custom network security controls (WAF, mTLS, network segmentation)" as triggers to Level 3-4.

### Summary

None of these warnings are blocking. The advisory correctly identifies the bias and proposes sound structural fixes. The security gap is that serverless is treated as a pure simplicity/cost/DX decision without acknowledging its distinct security model. Adding serverless security patterns to iac-minion's expanded knowledge, acknowledging vendor lock-in as a security risk, and including security escalation triggers would make the advisory complete from a security perspective.
