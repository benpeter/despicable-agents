# UX Strategy Contribution: Agent Attribution in Commit Messages

## The Core Question

Does putting agent names (e.g., `frontend-minion`, `security-minion`) into the conventional commit scope position improve or degrade the developer experience of scanning git history?

## Assessment: Significant Cognitive Load Risk

### The Cardinality Problem

The current convention uses **domain scopes**: `oauth`, `frontend`, `security`, `docs`. These are intuitive because they map to the *subject matter* of the change -- they answer "what area of the codebase changed?" A developer scanning `git log` can satisfice immediately: "Is this commit in my area of concern?"

Agent-name scopes (`frontend-minion`, `ux-design-minion`, `api-spec-minion`) answer a different question: "Who produced this change?" This is a **producer-centric** framing rather than a **content-centric** framing. The distinction matters enormously for scanability.

There are 27 agents. In conventional commit practice, most projects operate with 5-15 scopes. Going from ~8 domain scopes to 27 agent scopes crosses the threshold where Hick's Law begins to bite: the developer must maintain a mental mapping from agent name to domain area. This is **extraneous cognitive load** -- effort spent translating terminology rather than understanding the change.

### Scanning Behavior Analysis

**`git log --oneline` (the most common view):**

Current (domain scopes):
```
a1b2c3d feat(oauth): add device flow token exchange
d4e5f6g fix(frontend): resolve header layout overflow
h7i8j9k docs: update orchestration architecture
```

Proposed (agent scopes):
```
a1b2c3d feat(oauth-minion): add device flow token exchange
d4e5f6g fix(frontend-minion): resolve header layout overflow
h7i8j9k docs(software-docs-minion): update orchestration architecture
```

Problems observed:
1. **The `-minion` suffix is pure noise.** It consumes ~7 characters per line and carries zero semantic value. In a 72-character budget, that is 10% of the message consumed by boilerplate.
2. **Compound agent names erode scannability.** `ux-design-minion` is 16 characters in the scope position. `ux-strategy-minion` is 18. The scope overwhelms the summary. At a glance, the developer's eye hits the scope first (it's in parentheses, high visual salience), and sees a long hyphenated string rather than a clean domain label.
3. **Agent-to-domain mapping is not 1:1.** Both `api-design-minion` and `api-spec-minion` touch API concerns. Both `ux-design-minion` and `ux-strategy-minion` touch UX concerns. Both `software-docs-minion` and `user-docs-minion` produce docs. A developer searching for "all API changes" now needs to know the full agent roster, not just the domain.
4. **Non-specialist agents break the pattern.** `lucy` and `margo` are governance agents. A scope of `(lucy)` tells a developer nothing about what changed -- only who reviewed or requested the change. Same for `(nefario)` orchestration commits.

**`git shortlog -s` (contributor summary):**

This is where attribution *could* shine -- showing which agents contributed most. But `git shortlog` groups by author, not by scope. The `Co-Authored-By: Claude` trailer already handles authorship. Agent names in scope do not improve shortlog output.

**`git log --grep` (searching history):**

Searching `git log --grep="frontend"` works identically whether the scope is `frontend` or `frontend-minion`. The `-minion` suffix adds nothing to searchability while cluttering results.

**PR diffs and IDE integrations:**

GitHub PR views show commit messages in a compressed format. Long scopes wrap or truncate. IDE git integrations (VS Code source control, JetBrains Git Log) often show only the first ~50 characters. Agent-name scopes consume valuable real estate in these constrained views.

### The Jobs-to-be-Done Lens

When a developer reads git history, they are hiring it for one of these jobs:

1. **"Find the commit that introduced a bug"** -- They need domain/area scoping, not producer identity.
2. **"Understand what changed in this area"** -- They filter by scope. Domain scopes enable this directly; agent scopes require translation.
3. **"Review a PR for merge"** -- Commit messages should tell the story of what changed. Agent names tell the story of how work was organized internally -- an implementation detail the reviewer does not need.
4. **"Audit who/what produced a change"** -- This is the one job that agent attribution serves. But it is a rare, forensic activity, not a daily scanning task.

Job 4 is legitimate but low-frequency. Optimizing the commit scope for a rare forensic need while degrading the experience of jobs 1-3 (daily, high-frequency) is a poor tradeoff.

## Recommendation: Separate Attribution from Scope

Agent attribution is valuable information. The conventional commit scope is the wrong place for it.

### Proposed Approach

Keep domain-derived scopes in the conventional commit format (status quo). Add agent attribution as a **git trailer** -- the same mechanism already used for `Co-Authored-By`:

```
feat(oauth): add device flow token exchange

Agent: oauth-minion
Co-Authored-By: Claude <noreply@anthropic.com>
```

For orchestrated sessions with multiple agents contributing to a single commit:

```
feat(auth): add device flow with security review

Agent: oauth-minion
Reviewed-By: security-minion
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Why Trailers Work Better

| Criterion | Scope Position | Trailer |
|-----------|---------------|---------|
| **Scanability of git log** | Degraded (27 long scope values) | Preserved (domain scopes unchanged) |
| **72-char budget** | Consumed by agent names | Unaffected (trailers are in the body) |
| **Searchability** | `git log --grep="oauth-minion"` works | `git log --grep="Agent: oauth-minion"` also works |
| **Forensic querying** | `git log --grep` only | `git log --grep` + structured trailer parsing |
| **IDE compatibility** | Truncation risk in constrained views | Trailers shown in expanded commit view |
| **Progressive disclosure** | Always visible (high salience) | Available on demand (low noise) |

This is a textbook application of **progressive disclosure**: the daily-use information (domain scope) is visible at the summary level; the occasional-use information (agent identity) is one click deeper in the full commit message.

### Scope Derivation Rules (Existing, Preserved)

The current doc says scope is "derived from the agent or domain that produced the work." Recommend making this explicit:

| Agent | Scope |
|-------|-------|
| frontend-minion | `frontend` |
| oauth-minion | `oauth` |
| security-minion | `security` |
| test-minion | `test` |
| software-docs-minion, user-docs-minion | `docs` |
| api-design-minion, api-spec-minion | `api` |
| ux-design-minion, ux-strategy-minion | `ux` |
| edge-minion | `edge` |
| data-minion | `data` |
| iac-minion | `infra` |
| observability-minion | `observability` |
| mcp-minion | `mcp` |
| devx-minion | `devx` |
| sitespeed-minion | `perf` |
| accessibility-minion | `a11y` |
| seo-minion | `seo` |
| ai-modeling-minion | `ai` |
| debugger-minion | (use domain of the fix, not `debug`) |
| code-review-minion | (use domain of the reviewed code) |
| lucy, margo | (use domain of the changed files) |
| product-marketing-minion | `marketing` |
| nefario, gru | (orchestration -- use domain of the changed files) |

This gives ~17 domain scopes, which is on the high end but still within the range where developers can build recognition-based scanning habits. Several (like `debugger-minion`, `code-review-minion`, `lucy`, `margo`) are process agents whose output touches various domains -- using the domain of the files they changed rather than their own name keeps scopes content-centric.

## Risks and Dependencies

1. **Trailer parsing in hooks**: The hook system needs to inject the `Agent:` trailer. This is straightforward -- git supports multi-line commit messages in `git commit -m`. Verify the hook can construct the message body.

2. **Multi-agent commits**: In orchestrated sessions, a single commit may include work from multiple agents (e.g., the wrap-up commit). The `Agent:` trailer handles this naturally (multiple trailers, like multiple `Co-Authored-By` lines).

3. **Scope mapping table maintenance**: Adding a new agent requires adding a scope mapping. This is a documentation burden but a small one, and it forces the useful exercise of deciding what domain a new agent serves.

4. **Existing tooling compatibility**: Git trailers are a well-established convention (`git interpret-trailers`, `git log --format='%(trailers)'`). No compatibility risk.

## Summary

- **Do not use agent names as conventional commit scopes.** The cognitive load cost (27 long, compound scope values vs. ~17 short domain labels) degrades the highest-frequency use case (scanning history).
- **Do use git trailers for agent attribution.** This preserves attribution data for forensic use while keeping the commit log clean for daily scanning.
- **Formalize a scope mapping table** from agent to domain, keeping scopes short, content-centric, and recognizable.
- This is a progressive disclosure decision: show what matters most (the domain) at the scan level; reveal what matters sometimes (the agent) at the detail level.
