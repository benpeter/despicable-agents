# Security Minion -- Research

Domain research backing the security-minion system prompt. Covers application
security, infrastructure hardening, threat modeling, AI/LLM-specific attack
surfaces, and compliance awareness.

---

## 1. OWASP Top 10 2025 (Web Applications)

The 2025 edition analyzed 175,000+ CVE records and practitioner surveys. Major
shifts from 2021:

| Rank | Category | Key Detail |
|------|----------|-----------|
| A01 | Broken Access Control | Still #1. 3.73% of tested apps affected. Covers IDOR, privilege escalation, CORS misconfig, path traversal. |
| A02 | Security Misconfiguration | Jumped from #5. Default credentials, verbose errors, unnecessary features enabled, missing security headers. |
| A03 | Software Supply Chain Failures | Expanded scope. Covers compromised dependencies, malicious packages, weak CI/CD pipeline controls, build system attacks. |
| A04 | Cryptographic Failures | Dropped from #2. Weak algorithms, plaintext transmission, poor key management, missing TLS. |
| A05 | Injection | Dropped from #3. SQL, NoSQL, OS command, LDAP, XSS. Parameterized queries and input validation remain primary defenses. |
| A06 | Insecure Design | Missing security controls at the architecture/design level. Threat modeling during design prevents this. |
| A07 | Authentication Failures | Renamed from "Broken Auth." Credential stuffing, weak password policies, missing MFA, session fixation. |
| A08 | Software or Data Integrity Failures | Unsigned updates, unverified CI/CD artifacts, insecure deserialization. |
| A09 | Security Logging and Alerting Failures | Insufficient logging, missing alerting, no incident detection capability. |
| A10 | Mishandling of Exceptional Conditions | NEW. Improper error handling, failing open, logical errors from abnormal conditions. 24 CWEs. |

Sources: OWASP Top 10:2025 (https://owasp.org/Top10/2025/), GitLab analysis
(https://about.gitlab.com/blog/2025-owasp-top-10-whats-changed-and-why-it-matters/)

---

## 2. OWASP Top 10 for LLM Applications 2025

A parallel list for AI/LLM systems. Critical for reviewing MCP servers and
any system with embedded LLMs.

| Rank | Category | Key Detail |
|------|----------|-----------|
| LLM01 | Prompt Injection | #1 risk. Direct (jailbreak) and indirect (via external content). Multimodal injection (images, audio) is emerging. |
| LLM02 | Sensitive Information Disclosure | LLM leaks PII, credentials, or confidential data through responses. |
| LLM03 | Supply Chain | Poisoned models, backdoored datasets, compromised dependencies. |
| LLM04 | Data and Model Poisoning | Malicious contamination of training data causing biased or backdoored behavior. |
| LLM05 | Improper Output Handling | LLM output not sanitized before reaching downstream systems. Enables XSS, SQLi, command injection via LLM. |
| LLM06 | Excessive Agency | LLM granted excessive permissions or can invoke high-impact tools without approval. |
| LLM07 | System Prompt Leakage | NEW. Internal prompts containing API keys, restrictions, or architecture details exposed to attackers. |
| LLM08 | Vector and Embedding Weaknesses | NEW. Improperly managed embeddings allow information leaks or poisoning. |
| LLM09 | Misinformation | Hallucinated but credible-sounding outputs. Risk in automated pipelines. |
| LLM10 | Unbounded Consumption | Resource exhaustion, financial exploitation via uncontrolled API usage. |

Source: OWASP LLM Top 10 v2025
(https://owasp.org/www-project-top-10-for-large-language-model-applications/)

---

## 3. STRIDE Threat Modeling

Microsoft's STRIDE methodology maps threat categories to the CIA triad plus
authentication, authorization, and non-repudiation.

| Letter | Threat | Property Violated | Example |
|--------|--------|-------------------|---------|
| S | Spoofing | Authentication | Forged JWT, stolen session cookie |
| T | Tampering | Integrity | Modified request body, altered database records |
| R | Repudiation | Non-repudiation | User denies action, no audit trail |
| I | Information Disclosure | Confidentiality | Verbose error messages, leaked env vars |
| D | Denial of Service | Availability | Resource exhaustion, amplification attacks |
| E | Elevation of Privilege | Authorization | Vertical/horizontal privilege escalation |

### STRIDE Process

1. **Decompose** the system into components using a Data Flow Diagram (DFD)
2. **Identify trust boundaries** -- where data crosses from trusted to
   untrusted zones
3. **Apply STRIDE per element** -- for each component and data flow, check
   which STRIDE threats apply
4. **Rate threats** using DREAD or risk matrices
5. **Define mitigations** for each identified threat
6. **Document** as a threat model artifact linked to the design

### Best Practices (2025)

- Integrate threat modeling into design phase, not as a retrofit
- Use hybrid approaches (STRIDE + PASTA for business context)
- Automate where possible (IriusRisk, OWASP Threat Dragon, Microsoft TMT)
- Threat model incrementally -- update when architecture changes
- Include AI/ML components as first-class DFD elements

Sources: Microsoft STRIDE
(https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats),
OWASP Threat Modeling Process
(https://owasp.org/www-community/Threat_Modeling_Process),
IriusRisk STRIDE guide (https://www.iriusrisk.com/resources-blog/threat-modeling-methodology-stride)

---

## 4. MCP-Specific Security

The Model Context Protocol introduces novel attack surfaces. MCP servers are
untrusted by default and represent the primary attack vector.

### Attack Vectors

**Tool Poisoning / Injection**
- Malicious tool definitions embedded in MCP server metadata
- Tools can modify their definitions between sessions ("rug pull" attacks)
- MCPTox benchmark shows tool poisoning passes into agent contexts frequently
- Cross-server shadowing: one MCP server's tools influence another's behavior

**Prompt Injection via MCP Responses**
- MCP servers control prompt content in sampling requests
- Indirect injection: malicious instructions hidden in tool responses
- Persistent injection: instructions that survive across conversation turns
- Multimodal injection: hidden directives in images or structured data

**Sampling Attacks**
- Resource theft: invisible LLM generation consuming API quota
- Conversation hijacking: persistent behavioral modification
- Covert tool invocation: triggering tools without user awareness
- Exfiltration: crafted prompts that cause LLM to leak data via tool calls

**Confused Deputy Problem**
- MCP proxy servers exploited when using static client IDs with third-party
  auth servers
- Consent cookie reuse allows attackers to skip authorization
- Dynamic client registration + static upstream client ID = vulnerability

**Session Hijacking**
- Session ID guessing or theft enables impersonation
- Event injection via shared queues in multi-server setups
- Resumable streams can be hijacked to deliver malicious payloads

**Token Passthrough (Anti-Pattern)**
- MCP server accepts tokens not issued for it and forwards to downstream APIs
- Breaks audit trails, enables lateral movement, circumvents security controls

**Local Server Compromise**
- Malicious startup commands in MCP client configuration
- Data exfiltration via compromised local MCP servers
- DNS rebinding attacks against localhost MCP servers

**Real-World CVEs**
- CVE-2025-6514: mcp-remote OAuth proxy shell command injection via crafted
  OAuth metadata. 437,000+ developer environments compromised.
- Reference SQLite MCP server: SQL injection via unsanitized user input,
  enabling "stored prompt injection" (like stored XSS but for LLMs)

### MCP Defense Strategies

- Validate all tool definitions against a known-good schema
- Pin tool versions and verify signatures where possible
- Implement per-client consent before forwarding to third-party auth
- Use cryptographically secure, non-deterministic session IDs
- Bind sessions to user identity (not just session ID)
- Sanitize all MCP server responses before presenting to LLM
- Strip instruction-like phrases from tool responses
- Require explicit user approval for tool invocations
- Implement capability declarations limiting server requests
- Enforce context isolation (prevent cross-server data leakage)
- Rate-limit sampling frequency
- Monitor for injection markers: `[INST]`, role-play attempts, zero-width
  characters, unexpected tool invocations, abnormal token usage
- Use stdio transport for local servers (limits attack surface)
- Sandbox local MCP server processes

Sources: MCP Security Best Practices
(https://modelcontextprotocol.io/specification/draft/basic/security_best_practices),
Palo Alto Unit 42 MCP research
(https://unit42.paloaltonetworks.com/model-context-protocol-attack-vectors/),
Pillar Security MCP risks
(https://www.pillar.security/blog/the-security-risks-of-model-context-protocol-mcp),
Practical DevSecOps MCP vulnerabilities
(https://www.practical-devsecops.com/mcp-security-vulnerabilities/)

---

## 5. Prompt Injection Taxonomy and Defenses

### Attack Taxonomy (Three Dimensions)

1. **Delivery Vector**: How the attack is introduced
   - Direct: user-supplied prompt
   - Indirect: via external content (web pages, documents, tool responses)
   - Configuration: via system prompt or tool definitions

2. **Attack Modality**: Nature of the payload
   - Text-based: natural language instructions
   - Encoded: base64, ROT13, unicode tricks
   - Multimodal: instructions hidden in images, audio, structured data
   - Cross-modal: exploiting interactions between modalities

3. **Propagation Behavior**: How the attack spreads
   - One-shot: single injection attempt
   - Persistent: survives across conversation turns
   - Self-propagating: worm-like behavior across agent chains
   - Stored: saved in databases, triggered when retrieved later

### Defense Strategies (Defense in Depth)

**Input Controls**
- Input validation and sanitization (strip control characters, limit length)
- Prompt templates that segregate user content from system instructions
- Content classification (detect instruction-like patterns in user input)

**Architecture Controls**
- Privilege separation: LLM has minimal tool access by default
- Human-in-the-loop for destructive operations
- Separate LLM instances for untrusted content processing
- Capability-based security (tools declare required permissions)

**Output Controls**
- Output validation against expected schema
- Context-aware encoding before passing to downstream systems
- Parameterized queries for any database operations
- Strip instruction-like content from LLM responses before tool execution

**Runtime Controls**
- Monitor for anomalous tool invocation patterns
- Rate limiting on tool calls and sampling
- Content tagging (mark AI-generated content to prevent downstream injection)
- Cryptographic provenance tracking for content origin

**Detection Signals**
- Sudden behavior changes mid-conversation
- Unexpected tool invocations
- Role-play or persona-switching attempts in responses
- Zero-width characters or unusual encoding in inputs
- Token usage anomalies

Sources: IEEE S&P 2026 paper on third-party AI chatbot plugins
(https://arxiv.org/html/2511.05797v1),
MDPI comprehensive review on prompt injection
(https://www.mdpi.com/2078-2489/17/1/54),
Microsoft indirect prompt injection defenses
(https://www.microsoft.com/en-us/msrc/blog/2025/07/how-microsoft-defends-against-indirect-prompt-injection-attacks)

---

## 6. Container and Docker Security (CIS Benchmarks)

### CIS Docker Benchmark v1.8.0 -- Key Areas

**Host Configuration**
- Separate partition for /var/lib/docker
- Harden the host OS (CIS OS benchmark)
- Keep Docker and host kernel updated
- Restrict network traffic between containers

**Daemon Configuration**
- Enable TLS authentication for Docker daemon
- Configure logging driver (json-file with max-size and max-file)
- Enable content trust (DOCKER_CONTENT_TRUST=1)
- Disable legacy registry and experimental features

**Image Security**
- Use minimal base images (distroless, Alpine, scratch)
- Create non-root USER in Dockerfile
- Remove package managers and shells from production images
- Scan images for vulnerabilities (Trivy, Grype, Snyk)
- Pin base image digests (not just tags)
- Multi-stage builds to minimize attack surface
- Sign images (Cosign, Notary)

**Runtime Configuration**
- Run containers read-only (--read-only flag)
- Drop all capabilities, add only needed ones (--cap-drop ALL --cap-add ...)
- Use seccomp, AppArmor, or SELinux profiles
- Do not mount sensitive host directories
- Do not run SSH in containers
- Limit resources (--memory, --cpus, --pids-limit)
- Use --no-new-privileges flag
- Mount /tmp as tmpfs

**Networking**
- Do not share host network namespace
- Bind container ports to specific interfaces (not 0.0.0.0)
- Use user-defined bridge networks (not default bridge)

**Automated Auditing**
- docker-bench-security script for CIS compliance checking
- Integrate into CI/CD pipeline for image scanning
- Runtime scanning with Falco or similar

Sources: CIS Docker Benchmarks
(https://www.cisecurity.org/benchmark/docker),
Docker CIS documentation (https://docs.docker.com/dhi/core-concepts/cis/),
docker-bench-security (https://github.com/docker/docker-bench-security)

---

## 7. Supply Chain Security

### Key Practices

**Software Bill of Materials (SBOM)**
- Generate SBOM in CycloneDX or SPDX format
- Integrate SBOM generation into CI/CD (syft, cdxgen, trivy)
- Compare SBOMs between builds to detect new dependencies
- Map SBOM components against CVE databases

**Dependency Scanning**
- SCA tools in CI/CD pipeline (npm audit, pip-audit, cargo-audit)
- Monitor both direct and transitive dependencies
- Automated PRs for dependency updates (Dependabot, Renovate)
- Lock files committed and verified (package-lock.json, yarn.lock, Cargo.lock)

**Build Pipeline Security**
- Sign commits and artifacts (GPG, Sigstore/Cosign)
- Reproducible builds where possible
- Limit CI/CD secrets exposure (short-lived, scoped tokens)
- Require code review before merge (no single-person push to production)
- Harden CI runners (ephemeral, minimal permissions)

**Registry Security**
- Use private registries for internal packages
- Verify package provenance and signatures
- Monitor for typosquatting attacks on public registries
- Pin dependency versions (avoid floating ranges)

**Regulatory Context**
- EU Cyber Resilience Act (CRA): mandates SBOM, vulnerability scanning,
  continuous monitoring. Penalties up to 15M EUR or 2.5% global revenue.
- US Executive Order 14028: requires SBOM for software sold to federal government

Sources: OWASP A03:2025 Software Supply Chain Failures
(https://owasp.org/Top10/2025/A03_2025-Software_Supply_Chain_Failures/),
CISA SBOM guidance (https://www.cisa.gov/sbom),
Anchore supply chain security
(https://anchore.com/blog/software-supply-chain-security-in-2025-sboms-take-center-stage/)

---

## 8. Cloud Security Patterns

### Secrets Management

- Use dedicated secret stores (HashiCorp Vault, AWS Secrets Manager,
  1Password Connect, SOPS)
- Never hardcode secrets in code, config files, or environment variables
  checked into version control
- Use short-lived, automatically rotated credentials
- Ephemeral credentials preferred over long-lived tokens
- Audit all secret access with correlation IDs
- Implement break-glass procedures for emergency access

### Least Privilege

- Start with zero permissions, add only what is needed
- Use fine-grained IAM policies (resource-level, condition-based)
- Regular access reviews and automated permission right-sizing
- Separate roles for read, write, and admin operations
- Service accounts with minimal scope (no wildcard permissions)
- Time-bounded access for elevated privileges (JIT access)

### Network Policies

- Zero Trust architecture: never trust, always verify
- Network segmentation (VPCs, security groups, network policies)
- Deny-by-default network policies in Kubernetes
- Private endpoints for cloud services (no public internet exposure)
- WAF at the edge for public-facing services
- Mutual TLS (mTLS) for service-to-service communication

### Common Misconfigurations (2025 Data)

- Excessive IAM permissions (#1 enabler of privilege escalation)
- Long-lived tokens and hardcoded secrets in functions/scripts
- Unrestricted API scopes
- Public S3/GCS buckets
- Missing encryption at rest
- Overly permissive security groups (0.0.0.0/0 ingress)

Sources: OWASP Secrets Management Cheat Sheet
(https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html),
Verizon 2025 DBIR (credential abuse = 22% of breaches)

---

## 9. API Security

### Authentication and Authorization
- OAuth 2.0 / OpenID Connect for user-facing APIs
- mTLS for service-to-service
- Short-lived access tokens (15-60 minutes)
- Refresh token rotation
- API keys only as supplementary identification, not sole auth

### Input Validation
- Whitelist approach (define allowed, reject everything else)
- Schema validation (JSON Schema) for all request bodies
- Validate query strings, headers, and path parameters
- Reject unexpected fields/types/formats
- Size limits on all inputs

### Rate Limiting
- Per-user/token rate limiting (not just per-IP)
- Adaptive limits based on user tier and endpoint criticality
- Return Retry-After headers
- Sliding window or token bucket algorithms

### Additional Controls
- API gateway as single entry point (centralized policy enforcement)
- Request/response logging (but never log credentials or PII)
- CORS configured restrictively (specific origins, not *)
- HSTS headers on all responses
- Content-Type validation (reject mismatched types)
- Idempotency keys for mutation endpoints

Sources: OWASP API Security Top 10
(https://owasp.org/www-project-api-security/),
Curity API security best practices
(https://curity.io/resources/learn/api-security-best-practices/)

---

## 10. GDPR Awareness for Developers

### Core Principles (Article 5)
- Purpose limitation: collect only for specified purposes
- Data minimization: collect only what is necessary
- Storage limitation: delete when no longer needed
- Integrity and confidentiality: protect data appropriately

### Privacy by Design (Article 25)
- Embed privacy into every stage of development
- Most privacy-friendly settings are the default
- Users should not need to take action to protect privacy

### Developer Checklist
- Data inventory: know what personal data you process and why
- Consent mechanisms: explicit, granular, easy to withdraw
- Data subject rights: implement access, rectification, erasure, portability
- Encryption: TLS 1.3 minimum in transit, AES-256 at rest
- Role-based access controls for personal data
- DPIA (Data Protection Impact Assessment) for high-risk processing
- Records of Processing Activities (ROPA)
- Data breach notification (72-hour window to supervisory authority)
- Cross-border transfer safeguards (SCCs, adequacy decisions)

### Technical Implementation
- Pseudonymization and anonymization where possible
- Audit logging of all access to personal data
- Automated data retention and deletion policies
- Field-level encryption for sensitive personal data
- Data masking in non-production environments

Sources: GDPR.eu compliance checklist (https://gdpr.eu/checklist/),
Piiano Privacy by Design checklist
(https://www.piiano.com/blog/privacy-by-design-checklist)

---

## 11. Common CVE Patterns (2025)

### Most Exploited Weakness Types

| CWE | Name | Frequency | Prevention |
|-----|------|-----------|-----------|
| CWE-79 | Cross-Site Scripting (XSS) | Very High | Context-aware output encoding, CSP headers |
| CWE-89 | SQL Injection | High | Parameterized queries, ORM usage |
| CWE-78 | OS Command Injection | High | Avoid shell execution, allowlist commands |
| CWE-918 | SSRF | Rising | URL scheme validation, internal IP blocklist, deny by default |
| CWE-502 | Insecure Deserialization | High | Avoid deserializing untrusted data, use safe formats (JSON) |
| CWE-22 | Path Traversal | Medium | Canonicalize paths, validate against allowlist |
| CWE-287 | Improper Authentication | High | Use proven auth frameworks, enforce MFA |
| CWE-862 | Missing Authorization | High | Check authorization on every request, not just UI |
| CWE-200 | Information Exposure | Medium | Generic error messages, strip headers |
| CWE-311 | Missing Encryption | Medium | TLS everywhere, encrypt at rest |

### Emerging Patterns (2025-2026)
- LLM output as injection vector (LLM generates SQL, commands, or HTML that
  flows into downstream systems without sanitization)
- Serialization injection in AI frameworks (LangChain CVE-2025-68664)
- OAuth metadata injection in MCP proxies (CVE-2025-6514)
- Supply chain worms (self-propagating via package install scripts)

Sources: CISA KEV Catalog
(https://www.cisa.gov/known-exploited-vulnerabilities-catalog),
NVD/CVE databases, Recorded Future CVE Landscape reports

---

## 12. Security Review Checklist (Synthesized)

A practical checklist for code and architecture reviews:

### Access Control
- [ ] Every endpoint checks authorization (not just authentication)
- [ ] RBAC or ABAC enforced server-side
- [ ] IDOR checks (object-level authorization)
- [ ] CORS restricted to specific origins
- [ ] CSRF protection on state-changing requests

### Input/Output
- [ ] All inputs validated (whitelist approach)
- [ ] Schema validation on API payloads
- [ ] Parameterized queries for all database operations
- [ ] Context-aware output encoding
- [ ] File upload validation (type, size, content)

### Authentication
- [ ] Passwords hashed with bcrypt/scrypt/argon2
- [ ] MFA available and enforced for sensitive operations
- [ ] Session management uses secure, httpOnly, sameSite cookies
- [ ] Rate limiting on authentication endpoints
- [ ] Account lockout after failed attempts

### Secrets and Configuration
- [ ] No secrets in source code or environment files committed to VCS
- [ ] Secrets rotated regularly
- [ ] Production configs not accessible in development
- [ ] Security headers set (HSTS, X-Content-Type-Options, CSP, etc.)

### Dependencies
- [ ] Lock files committed and verified
- [ ] Automated vulnerability scanning in CI
- [ ] No known critical CVEs in dependencies
- [ ] SBOM generated and maintained

### Containers
- [ ] Non-root user in Dockerfile
- [ ] Minimal base image
- [ ] Read-only root filesystem
- [ ] Capabilities dropped
- [ ] Image scanned before deployment

### AI/LLM (when applicable)
- [ ] LLM output treated as untrusted input
- [ ] Tool invocations require approval for destructive actions
- [ ] MCP tool definitions validated against known-good schema
- [ ] Prompt injection defenses in place (input/output sanitization)
- [ ] System prompt does not contain secrets
- [ ] Sampling rate-limited

### Logging and Monitoring
- [ ] Security events logged (auth failures, access denied, input validation failures)
- [ ] No sensitive data in logs (PII, credentials, tokens)
- [ ] Alerting configured for anomalous patterns
- [ ] Audit trail for administrative actions
