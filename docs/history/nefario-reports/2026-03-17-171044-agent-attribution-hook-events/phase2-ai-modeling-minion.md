## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### 1. Scope Field: Use a shortened form of `agent_type`, not the raw value

The raw `agent_type` from hook events will be the full agent name (e.g., `frontend-minion`, `security-minion`, `code-review-minion`). Using it directly as the conventional commit scope produces messages like:

```
feat(frontend-minion): add header component
fix(code-review-minion): address review findings
```

This is too verbose. Conventional commit scopes should be short domain labels that group related work, not agent identity strings. The `-minion` suffix is noise -- it communicates system internals (agent naming convention) rather than the domain of the change.

**Recommended approach: strip `-minion` suffix and use the remaining domain word(s) as scope.**

- `frontend-minion` -> `frontend`
- `security-minion` -> `security`
- `code-review-minion` -> `code-review`
- `software-docs-minion` -> `docs`
- `ai-modeling-minion` -> `ai-modeling`
- `ux-strategy-minion` -> `ux-strategy`
- `ux-design-minion` -> `ux-design`

For non-minion agents (nefario, lucy, margo, gru), use the name as-is since they are already short.

**Implementation**: A simple bash substitution (`${agent_type%-minion}`) handles this. No lookup table needed. This is deterministic, requires no maintenance when new agents are added, and produces readable scopes.

**Why not a static domain mapping table**: The existing heuristic approach where the orchestrator infers scope from the task description is fragile -- it depends on the LLM making a good guess. A mapping table (agent_type -> domain label) would be more precise but requires maintenance whenever agents change. The suffix-stripping approach gets 90% of the value with zero maintenance.

#### 2. Co-Authored-By: Keep generic `Claude`, do NOT use agent names

The `Co-Authored-By` trailer should remain:

```
Co-Authored-By: Claude <noreply@anthropic.com>
```

Do NOT change it to agent-specific attribution like `Co-Authored-By: frontend-minion <noreply@anthropic.com>`. Reasons:

- **`git shortlog -s` grouping**: Each distinct `Co-Authored-By` name creates a separate entry in `git shortlog`. With 23+ agents, this fragments the "AI-authored" contribution count into 23+ buckets, making it impossible to answer "how much did AI contribute?" at a glance. A single `Claude` entry keeps all AI work aggregated.

- **GitHub contributor graph**: GitHub treats each unique Co-Authored-By as a separate contributor. 23 phantom contributors pollute the contributor list and misrepresent the project's human team size.

- **Semantic accuracy**: The scope field already carries the domain context. Adding it to Co-Authored-By is redundant. The trailer's job is to mark the commit as AI-assisted, not to identify which sub-agent.

- **Conventional commit tooling compatibility**: Tools like commitlint, semantic-release, and standard-version parse Co-Authored-By trailers. Non-standard names (especially with hyphens) may cause warnings or parsing issues.

The scope field (`feat(frontend): ...`) is the right place for agent domain attribution. The trailer is the right place for "this was AI-assisted."

#### 3. Handle missing `agent_type` gracefully

The `agent_type` field is only present in hook events when:
- The session was started with `--agent` flag, OR
- The hook fires inside a subagent context

In single-agent sessions without `--agent`, `agent_type` will be absent from the PostToolUse JSON. The existing behavior (no scope in single-agent commits, heuristic scope in orchestrated commits) must be preserved as the fallback.

**Decision logic for scope derivation:**

```
if agent_type is present and non-empty:
    scope = agent_type with "-minion" suffix stripped
else if orchestrated session (nefario status file exists):
    scope = heuristic from task context (existing behavior)
else:
    scope = omitted (single-agent format: "<type>: <summary>")
```

This means the ledger must distinguish "no agent_type recorded" from "agent_type was empty string." Use a sentinel or simply omit the field in the ledger entry when not present.

#### 4. Ledger-to-commit aggregation logic

A single commit may contain files from multiple agents (e.g., after a gate approval that spans two task batches, or when the orchestrator itself edits files alongside a subagent's changes). The scope derivation needs an aggregation rule:

- **All files from same agent**: Use that agent's scope. `feat(frontend): ...`
- **Files from multiple agents**: Use the agent that authored the majority of files. If tied, use the orchestrator's scope (likely `nefario`).
- **Mix of agent-attributed and unattributed files**: Prefer the agent-attributed scope.

This aggregation happens at commit time, not at ledger-write time. The ledger stores per-file attribution; the commit logic resolves it.

**Keep this aggregation simple.** A majority-wins rule is clear and deterministic. Do not attempt weighted scoring or multi-scope formats (`feat(frontend,security): ...`) -- conventional commit parsers expect a single scope string.

#### 5. No changes needed to agent system prompts (AGENT.md files)

The `agent_type` value in hook events comes from the Claude Code runtime, not from anything the agent's system prompt controls. The runtime populates it from the `name` field in the agent's YAML frontmatter. No agent prompts need modification for this feature.

### Proposed Tasks

1. **Define scope derivation rules in commit-workflow.md** (docs update)
   - Add the suffix-stripping rule to Section 5
   - Add the aggregation rule (majority-wins for multi-agent commits)
   - Add the fallback chain (agent_type present -> stripped scope, absent -> heuristic or omitted)
   - Explicitly document that Co-Authored-By stays as `Claude <noreply@anthropic.com>`
   - Dependencies: Depends on devx-minion's ledger format decision (need to know how agent_type is stored to describe how it's consumed)

2. **Update SKILL.md auto-commit instructions** (orchestration update)
   - Replace heuristic scope derivation with ledger-based scope derivation
   - Add the majority-wins aggregation rule to the auto-commit instructions
   - Fallback: when ledger has no agent metadata, use the existing heuristic
   - Dependencies: Depends on ledger format decision

3. **Update commit-point-check.sh scope generation** (hook script update)
   - For single-agent sessions with `--agent`, derive scope from `agent_type` in the ledger
   - For single-agent sessions without `--agent`, continue omitting scope
   - Dependencies: Depends on ledger format decision

### Risks and Concerns

**R1: `agent_type` values are not guaranteed to be stable identifiers**

The `agent_type` field comes from the Claude Code runtime. Its format and content for custom agents (from `--agent` or AGENT.md `name` field) has not been formally versioned. If Anthropic changes how custom agent names flow through to hook events, the suffix-stripping logic could break silently.

**Mitigation**: The suffix-stripping approach (`${agent_type%-minion}`) degrades gracefully -- if the suffix is not present, the full value is used as the scope. This is fail-safe. Also, add a comment in the hook script noting the dependency on the `agent_type` format.

**R2: Multi-agent file ownership conflicts**

In orchestrated sessions, the main session (nefario) and subagents both write files. When nefario creates a file and a subagent edits it (or vice versa), which agent "owns" the file for scope purposes? The ledger records writes chronologically, so the last writer wins during deduplication. This may attribute a file to the wrong agent.

**Mitigation**: The current `track-file-changes.sh` already deduplicates by skipping paths already in the ledger (`grep -qFx`). The first writer wins. This is actually a better default -- the agent that created the file is likely the domain owner. If the format changes to record agent metadata, preserve first-writer-wins semantics for agent attribution even if you allow path re-recording for other purposes.

**R3: Scope explosion in git log**

With 23 agents, there are potentially 23+ different scope values in the git log. This is more than the current heuristic approach produces (which tends toward a smaller set of domain words). However, this is acceptable because:
- The scopes are meaningful domain labels after suffix stripping
- `git log --oneline --grep="(frontend)"` works for filtering
- The scopes are deterministic rather than LLM-inferred, so they are consistent across sessions

This is a risk to acknowledge, not a risk to mitigate. The UX-strategy-minion should weigh in on whether this scope cardinality is acceptable.

**R4: Orchestrator-written files have misleading scope**

When the nefario orchestrator itself writes files (e.g., execution reports, plan documents), those files will have `agent_type: nefario`. This produces `docs(nefario): add execution report`. This is actually correct and useful -- it distinguishes orchestration artifacts from specialist work. But verify that the main session running nefario via `--agent nefario` actually populates `agent_type` in PostToolUse events (the docs say it should for `--agent` mode).

### Additional Agents Needed

None beyond what the meta-plan already includes. The existing consultation set (devx-minion for ledger format, security-minion for input validation, ux-strategy-minion for readability, software-docs-minion for documentation, test-minion for test strategy) covers all dependencies.

One note: the **ux-strategy-minion** consultation is important for validating recommendation #1 (scope cardinality with 23+ agents) and recommendation #2 (keeping Co-Authored-By generic). These are primarily UX decisions about git log readability, and the UX strategist should confirm or challenge them.
