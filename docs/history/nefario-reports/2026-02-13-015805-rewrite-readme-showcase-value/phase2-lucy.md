## Domain Plan Contribution: lucy

### Recommendations

#### 1. Factual Inaccuracy: "Six mandatory reviewers" is wrong -- there are five

The README (line 77) says:

> Six mandatory reviewers check every plan.

The canonical spec (`the-plan.md` lines 461-469), `nefario/AGENT.md` (lines 562-570), `skills/nefario/SKILL.md` (lines 713, 747), and `docs/orchestration.md` (lines 57-65) all consistently list **five** mandatory reviewers: security-minion, test-minion, software-docs-minion, lucy, margo. The SKILL.md explicitly says "5 mandatory" in multiple places including the gate presentation format (line 747: `"5 mandatory + N discretionary reviewers proceed to review."`).

This must be corrected to "five" in the rewrite. This is the single most important accuracy fix.

#### 2. Governance capabilities are undersold

The README's "How It Works" section (lines 75-77) compresses all governance into two sentences. Here is what is missing or undersold:

**Phase 3.5 Architecture Review (pre-execution)**:
- Five mandatory reviewers + up to six discretionary reviewers (user-approved via Reviewer Approval Gate)
- APPROVE / ADVISE / BLOCK verdicts with iteration loops (capped at 2 rounds)
- Lucy checks: intent alignment, CLAUDE.md compliance, repo convention enforcement, goal drift detection
- Margo checks: YAGNI violations, over-engineering, scope creep, dependency bloat, premature abstraction
- BLOCK verdicts halt execution until resolved -- this is a meaningful safety mechanism

**Phase 5 Code Review (post-execution)**:
- Three parallel reviewers: code-review-minion (code quality, security implementation), lucy (cross-repo consistency, convention adherence), margo (over-engineering, unnecessary abstractions)
- BLOCK findings route back to the original producing agent for fixes, not to the reviewer
- Security-severity BLOCKs (injection, auth bypass, secret exposure) MUST surface to the user before auto-fix
- This is a second governance checkpoint that the README never mentions

**Approval gates throughout execution**:
- Team Approval Gate (Phase 1 output: user approves specialist team)
- Reviewer Approval Gate (Phase 3.5: user approves discretionary reviewer set)
- Execution Plan Approval Gate (synthesis output: user approves the plan before code runs)
- Mid-execution gates classified by reversibility/blast-radius matrix

The README should convey that governance happens at **multiple checkpoints**, not just once.

#### 3. Post-execution phases (5-8) are invisible in the README

The README says "nine-phase process -- from planning through execution to post-execution verification" but never describes what post-execution verification means. These phases are differentiating:

- **Phase 5 (Code Review)**: Three parallel reviewers catch quality/security/complexity issues
- **Phase 6 (Test Execution)**: Automated test discovery and execution with delta analysis against baseline
- **Phase 7 (Deployment)**: Conditional, runs existing deployment commands on user request
- **Phase 8 (Documentation)**: Conditional, generates documentation based on a checklist of execution outcomes

Simpler agent setups do not have automated post-execution verification. This is a value proposition gap.

#### 4. The `/despicable-prompter` skill is mentioned but not explained

Line 45 mentions `despicable-prompter` in the install output. Line 58 in `docs/using-nefario.md` mentions it for refining vague ideas. The README never explains what it does. The skill transforms rough ideas into structured `/nefario` briefings and can also read/write GitHub issues. If we're showcasing what the system provides, this "briefing coach" is a notable feature.

#### 5. External skill integration is undersold

Lines 49-51 mention that nefario discovers project-local skills, but this is a differentiating capability: nefario automatically discovers and integrates existing Claude Code skills from any project without configuration. No coupling required. This means the agent team adapts to each project's existing tooling.

#### 6. Cross-cutting concerns checklist is not mentioned in the README

The six mandatory dimensions that every plan must evaluate (testing, security, usability-strategy, usability-design, documentation, observability) are a structural feature that prevents specialists from ignoring adjacent concerns. This is a differentiator vs. ad-hoc agent invocation. The README does not mention it.

#### 7. CLAUDE.md compliance: README content is consistent with CLAUDE.md directives

Verified: The README is in English (CLAUDE.md: "All artifacts in English"), references the Helix Manifesto philosophy, and follows the project's structure conventions. No CLAUDE.md violations in the current README or in the proposed rewrite scope.

#### 8. Architecture terminology inconsistency (minor, not README)

`docs/architecture.md` opens with "four-tier hierarchy" (line 3) but has a section titled "Three-Tier Hierarchy" (line 37). `docs/decisions.md` (line 19) confirms the choice is "Four-tier hierarchy." The README avoids this term entirely (just says "4 named roles and 23 minions"), which is fine. If the rewrite introduces tier terminology, use "four-tier" to match the canonical decision.

### Proposed Tasks

**Task 1: Accuracy audit pass**
- Fix "six mandatory reviewers" to "five mandatory reviewers"
- Verify all other numerical claims (27 agents, 23 minions, 7 groups, 2 skills, 9 phases) against the codebase -- I have verified these are currently correct
- Verify all agent name references match actual agent directories
- **Deliverable**: Corrected README with no factual inaccuracies
- **Dependencies**: Must happen before any structural rewrite to avoid propagating the error

**Task 2: Surface governance and post-execution verification as differentiators**
- Add visible mention of the dual governance checkpoints (pre-execution review in Phase 3.5, post-execution code review in Phase 5)
- Mention approval gates as user control points (the user is always in the loop at key decisions)
- Mention that BLOCK verdicts halt execution -- this is not rubber-stamp review
- Convey post-execution phases (code review, test execution, conditional documentation) as quality assurance the user gets automatically
- Keep it scannable: bullets, not paragraphs
- **Deliverable**: Expanded "How It Works" section or equivalent that conveys governance depth without walls of text
- **Dependencies**: Task 1 (accuracy fixes)

**Task 3: Verify rewritten README against canonical sources**
- After the README is rewritten, lucy should review the final content against `the-plan.md`, `docs/architecture.md`, `docs/orchestration.md`, and `skills/nefario/SKILL.md` to verify no new inaccuracies were introduced
- **Deliverable**: APPROVE / ADVISE / BLOCK verdict on the rewritten README
- **Dependencies**: Tasks 1 and 2 complete

### Risks and Concerns

1. **Inaccuracy propagation risk**: The "six mandatory reviewers" error already exists in several nefario execution reports in `docs/history/`. A README rewrite that fixes this to "five" will create inconsistency with historical reports. This is acceptable -- historical reports are snapshots, not living docs -- but the rewrite should not introduce similar errors.

2. **Over-selling risk**: The rewrite task asks to "showcase what despicable-agents uniquely provides." This creates pressure to claim capabilities that work better in theory than in practice. Every claim in the README must be verifiable against the current codebase. Claims about quality of output (e.g., "catches all security issues") should be avoided in favor of structural claims (e.g., "security-minion reviews every plan before execution").

3. **Scope creep risk**: The task says "rewrite README to showcase value" -- this could expand into rewriting docs/architecture.md, docs/using-nefario.md, or the agent catalog. The scope should be strictly limited to README.md. If related docs need updates, those should be separate tasks.

4. **Governance depth vs. scannability tension**: The success criteria require the README to be "scannable (bullet-based, no walls of text)" while also communicating governance depth that is currently undersold. The solution should use progressive disclosure: brief mention in the README with links to `docs/using-nefario.md` and `docs/orchestration.md` for depth. Do not try to explain the full Phase 3.5 mechanism in the README.

### Additional Agents Needed

None. The current planning team is sufficient for a README rewrite. The writing will be done by the executing agents; lucy's role is accuracy verification, which this contribution covers. product-marketing-minion should be involved for positioning and messaging (which aligns with the delegation table entry "Product positioning and messaging"), and I see they are already a natural fit for the README rewrite task.
