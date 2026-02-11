# Domain Plan Contribution: devx-minion

## Recommendations

### 1. Foundational Principle: Context at the Point of Decision

The core problem is that gates present decisions without context, forcing the user into one of two bad states: (a) approve blindly, or (b) interrupt the flow to open files, reconstruct state, and verify manually. Both degrade trust in the orchestration.

The fix is to embed enough inline context at every gate that the user can make an informed decision from what is printed in the terminal. "Enough" means: what changed, why, and what the consequences of approving or rejecting are. The scratch file path is the escape hatch for users who want to verify details -- it is NOT the primary information delivery mechanism.

### 2. Gate Taxonomy and Context Requirements

The SKILL.md defines seven distinct gate types. Each has different context requirements:

| Gate Type | Current Context | Missing Context |
|-----------|----------------|-----------------|
| **Execution Plan Approval** | Task list, advisories, review summary, scratch path | Already well-specified after prior improvement. Minor: scratch path should include a one-line explanation of what the file contains. |
| **Mid-Execution Decision Brief** | Task title, agent, decision, rationale, impact, deliverable path, confidence | Deliverable path alone is opaque. Needs: 2-3 line summary of what the deliverable contains (key files created/modified, size of change). |
| **Phase 5 Code Review Escalation** | Title, phase, agent, finding, producing agent, file path, attempt count | Good structure. Needs: the actual code snippet or config line at issue (3-5 lines), not just a description of the finding. |
| **Phase 6 Test Failure Escalation** | (Implicit -- follows Phase 5 pattern) | Needs: test name, assertion that failed, expected vs actual. Test failures without this context are useless. |
| **Security BLOCK Escalation** | Max 5-line brief before auto-fix | Good constraint. Needs: severity classification (critical/high/medium), affected file path. Already mostly adequate. |
| **Compaction Checkpoint** | Phase complete, compact command, resume instruction | These are NOT decisions -- they are workflow prompts. Context is adequate. No changes needed. |
| **PR Creation Prompt** | Branch name | Needs: file count, line count delta, commit count. User should know the scale of what they are pushing. |
| **Calibration Check** | "5 consecutive approvals" | Adequate. It is a meta-question, not a deliverable decision. |

### 3. The Artifact Summary Pattern

For gates that present deliverables (mid-execution gates, PR creation), the most impactful change is adding an **artifact summary block**. This is a 3-5 line block that appears right after the DELIVERABLE line and summarizes what is in the referenced files.

**Pattern:**

```
DELIVERABLE: /path/to/main-file.md
  Changed: skills/nefario/SKILL.md (gate format section, +45/-12 lines)
  Changed: nefario/AGENT.md (ADVISE verdict format, +8/-3 lines)
  Created: docs/orchestration.md section 3.2 (new)
  Summary: Restructured gate output to include inline advisories
           and artifact context at every decision point.
```

Rules for the artifact summary:
- List each file with a parenthetical description of the change scope and line delta
- Maximum 5 files listed; if more, show top 4 + "and N more files"
- One-line `Summary:` that describes the deliverable in plain language
- The summary answers: "If I approve this, what am I agreeing went into the codebase?"

The producing agent must generate this summary as part of their completion message (the SKILL.md already requires agents to "send a message to the team lead summarizing what you produced and where the deliverables are"). This recommendation makes that requirement more structured.

### 4. Scratch Path Presentation

Current scratch paths are printed as bare absolute paths:
```
FULL PLAN: /var/folders/3k/.../nefario-scratch-ws8Oik/my-slug/phase3-synthesis.md
```

These paths are long, opaque, and intimidating. Recommendations:

**a) Always use absolute paths.** The user may be in a different working directory. Relative paths create confusion. This is already the practice; preserve it.

**b) Add a label describing the file content.** Do not just print a path -- say what is in it:
```
FULL PLAN: <path>/phase3-synthesis.md (complete task prompts, agent assignments, dependency graph)
```

**c) Group scratch paths when presenting multiple references.** When a gate references several scratch files, present them as a compact block rather than scattering them across the output:
```
REFERENCE FILES:
  Plan:      <scratch>/phase3-synthesis.md
  Security:  <scratch>/phase3.5-security-minion.md
  Test:      <scratch>/phase3.5-test-minion.md
```

**d) Use a short variable for the scratch root.** The first time a scratch path appears in a session (the Phase 1 CONDENSE line), print the full path. In subsequent gates, use a shorter form like `$SCRATCH/` prefix since the full path was already shown. This saves 40+ characters per path reference without losing information.

### 5. Terminal Line Budget per Gate Type

The execution plan approval gate already has a target of 25-40 lines. Here are recommended budgets for the other gate types:

| Gate Type | Target Lines | Hard Ceiling |
|-----------|-------------|--------------|
| Execution Plan Approval | 25-40 | 50 (existing) |
| Mid-Execution Decision Brief | 12-18 | 25 |
| Phase 5 Code Review Escalation | 8-12 | 15 |
| Phase 6 Test Failure Escalation | 8-12 | 15 |
| Security BLOCK Escalation | 3-5 | 5 (existing) |
| PR Creation Prompt | 6-10 | 15 |
| Calibration Check | 3-5 | 5 |

These budgets include the AskUserQuestion prompt lines. The principle: gates that require more judgment get more context; workflow confirmations stay minimal.

### 6. Mid-Execution Decision Brief Enhancement

The current mid-execution gate format (SKILL.md lines 783-797) is the most impactful gate to improve because it is presented during active work, when the user has the least ambient context (earlier phases may have been compacted away).

**Current format:**
```
APPROVAL GATE: <Task title>
Agent: <who produced this> | Blocked tasks: <what's waiting>

DECISION: <one-sentence summary>

RATIONALE:
- <key point 1>
- <key point 2>
- <rejected alternative and why>

IMPACT: <what approving/rejecting means>
DELIVERABLE: <file path(s)>
Confidence: HIGH | MEDIUM | LOW
```

**Proposed enhancement:**
```
APPROVAL GATE: <Task title>
Agent: <who produced this> | Blocked tasks: <what's waiting>

DECISION: <one-sentence summary>

DELIVERABLE:
  <file path 1> (<change description>, +N/-M lines)
  <file path 2> (<change description>, +N/-M lines)
  Summary: <1-2 sentences describing what was produced>

RATIONALE:
- <key point 1>
- <key point 2>
- Rejected: <alternative and why>

IMPACT: <what approving/rejecting means>
Confidence: HIGH | MEDIUM | LOW
```

Key changes:
- **DELIVERABLE moves up**, right after DECISION. The user thinks: "What is the decision?" then "What did it produce?" then "Why?" The current order puts the artifact at the bottom, after rationale -- the user has to scroll past reasoning to find the thing they are approving.
- **DELIVERABLE expands** from a bare path to the artifact summary pattern (see recommendation 3).
- **RATIONALE** uses a `Rejected:` prefix on the last bullet to visually distinguish alternatives from affirmative reasoning.

### 7. Escalation Briefs: Code Snippets, Not Descriptions

For Phase 5 (code review) and Phase 6 (test failure) escalation briefs, the current format describes findings in prose. But when a user sees "injection vulnerability in user input handling," they still need to open the file to understand the actual issue.

**Include the code snippet in the escalation brief:**

```
VERIFICATION ISSUE: SQL injection in query builder
Phase: Code Review | Agent: code-review-minion
Producing agent: data-minion | File: src/db/query.ts:42-45

  const query = `SELECT * FROM users WHERE name = '${input}'`;
  //            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // Should use parameterized query: db.query('SELECT * FROM users WHERE name = $1', [input])

Auto-fix attempts: 2 (unsuccessful)
```

Rules:
- Maximum 5 lines of code in the snippet
- Include the file path with line numbers
- Include a comment showing the recommended fix when possible
- If the issue is structural (not a specific line), describe the pattern instead of showing code

### 8. PR Creation Context

The PR creation prompt currently shows only the branch name. Before the user decides to push and create a PR, they should know the scale of what they are publishing:

```
PR: Create PR for nefario/improve-gate-context-clarity?
Branch: nefario/improve-gate-context-clarity
Commits: 3 | Files changed: 4 | Lines: +127/-34
  skills/nefario/SKILL.md (+85/-22)
  nefario/AGENT.md (+18/-6)
  docs/orchestration.md (+24/-6)
  docs/history/nefario-reports/2026-02-11-*.md (report)
```

This takes 5-6 lines and gives the user full confidence about what they are pushing without running `git diff --stat` manually.

### 9. Context Volume Scaling

Not all gates have the same amount of context to present. The format must handle:

**Minimal context (single file, small change):**
```
APPROVAL GATE: Update error message format
Agent: devx-minion | Blocked tasks: none

DECISION: Replace generic error codes with descriptive messages

DELIVERABLE:
  src/errors.ts (+12/-8 lines, error message text changes only)

RATIONALE:
- Matches CLI error message best practices (what happened, how to fix, how to get help)
- Rejected: error code lookup table (adds indirection without benefit)

IMPACT: Improves developer debugging experience. Low risk, easily reversible.
Confidence: HIGH
```
Total: 13 lines. Clean, fast to read.

**Heavy context (multi-file, architectural decision):**
```
APPROVAL GATE: Restructure plugin loading architecture
Agent: devx-minion | Blocked tasks: Tasks 4, 5, 6

DECISION: Replace synchronous plugin loading with lazy initialization

DELIVERABLE:
  src/plugins/loader.ts (+142/-67 lines, new lazy loading mechanism)
  src/plugins/registry.ts (+38/-12 lines, plugin manifest caching)
  src/plugins/types.ts (+24/-0 lines, new PluginManifest interface)
  tests/plugins/loader.test.ts (+89/-0 lines, new test suite)
  Summary: Plugins now load on first use instead of at startup.
           Startup time reduced from ~800ms to ~200ms in benchmarks.

RATIONALE:
- Measured: 4 of 12 plugins used in a typical session; loading all 12 upfront wastes ~600ms
- Manifest-based discovery allows loading without importing plugin code
- Rejected: dynamic import() (breaks bundling in some environments)
- Rejected: worker threads (adds complexity for marginal concurrency gain)

IMPACT: Changes plugin initialization contract. All plugins must export a manifest.
        3 blocked tasks depend on this architecture.
Confidence: MEDIUM (multiple viable alternatives existed)
```
Total: 22 lines. Fits within the 25-line budget with room for the AskUserQuestion.

The format naturally scales: more files and more rationale bullets add lines, but the structure stays the same. No conditional formatting rules needed.

### 10. Handling the "What Was I Approving Again?" Problem

After compaction, the user may lose context about earlier gates and decisions. Each gate should be self-contained -- it should make sense even if the user has forgotten everything that came before.

Concrete rules:
- Never refer to "the decision from Task 2" without restating what that decision was
- The DECISION line must be a complete sentence, not a reference to a prior context
- If a gate depends on a prior gate decision, state the dependency explicitly: "This task implements the lazy loading approach approved in Task 2 (plugin architecture restructure)"

This costs one extra line per gate but eliminates the "scroll back to understand" problem entirely.

## Proposed Tasks

### Task 1: Enhance mid-execution decision brief format in SKILL.md

**What to do:** Modify the Phase 4 approval gate format in SKILL.md (lines 783-797) to:
- Move DELIVERABLE above RATIONALE
- Expand DELIVERABLE into the artifact summary block (file list with change scope, line deltas, one-line summary)
- Add `Rejected:` prefix convention for alternative-rejection bullets in RATIONALE
- Add self-containment rule: gates must not reference prior decisions without restating them
- Add producing-agent completion message requirements: agents must include file paths, line deltas, and a 1-2 sentence summary in their completion messages

**Deliverables:** Updated SKILL.md Phase 4 section (approval gate format).

**Dependencies:** None. This is the core formatting change.

### Task 2: Add artifact summary requirements to agent completion protocol

**What to do:** Update the agent completion message instruction (SKILL.md line 759-761: "When you finish your task, mark it completed with TaskUpdate and send a message to the team lead summarizing what you produced and where the deliverables are. Include file paths.") to require structured output:
- File paths with line deltas (+N/-M)
- Change scope description per file (parenthetical)
- 1-2 sentence deliverable summary
- This structured message becomes the data source for the artifact summary block in gates

**Deliverables:** Updated SKILL.md agent completion instruction.

**Dependencies:** Depends on Task 1 (must align with the artifact summary format).

### Task 3: Enhance escalation briefs with code context

**What to do:** Update Phase 5 escalation brief format (SKILL.md lines 949-955) and Phase 6 failure format to include:
- Code snippet (max 5 lines) with file path and line numbers
- Expected vs actual for test failures
- Recommended fix as a code comment when possible

**Deliverables:** Updated SKILL.md Phase 5 and Phase 6 escalation sections.

**Dependencies:** None. Independent of Task 1.

### Task 4: Add PR creation context block

**What to do:** Update the PR creation prompt (SKILL.md wrap-up step 10, lines 1099-1127) to include:
- Commit count
- File change summary with line deltas (from `git diff --stat`)
- Top-level file list (max 5 files, then "and N more")

**Deliverables:** Updated SKILL.md wrap-up section.

**Dependencies:** None. Independent of other tasks.

### Task 5: Update AGENT.md and docs/orchestration.md for consistency

**What to do:** Propagate formatting changes from Tasks 1-4 into:
- `nefario/AGENT.md`: Update the Decision Brief Format section to match the enhanced format (DELIVERABLE position, artifact summary block, self-containment rule)
- `docs/orchestration.md`: Update Section 3 (Approval Gates) to reflect the new gate formats for all gate types

**Deliverables:** Updated AGENT.md and docs/orchestration.md.

**Dependencies:** Depends on Tasks 1-4 (all format changes must be finalized first).

## Risks and Concerns

### Risk 1: Artifact summary increases agent completion message size

Adding structured file lists and summaries to agent completion messages increases what agents must produce. This adds token cost and introduces a failure mode where agents produce incomplete summaries.

**Mitigation:** The structured format is simple (file path + parenthetical + line delta). Agents already produce this information in their messages; the change is making it structured, not adding new work. If an agent omits the summary, the gate falls back to bare file paths (current behavior) -- it is a graceful degradation, not a failure.

### Risk 2: Code snippets in escalation briefs may expose secrets

If the code under review contains secrets (API keys, tokens), the escalation brief would print them to the terminal.

**Mitigation:** The existing secret scanning patterns in SKILL.md (lines 1252-1255) already detect common credential patterns. Add a rule: before including a code snippet in an escalation brief, scan it against the same patterns. If matches are found, replace the snippet with: "Code snippet omitted (potential secret detected). Review file directly: <path>:<lines>"

### Risk 3: Line deltas require git state that may not exist

Line deltas (+N/-M) come from `git diff --stat`. If the file is newly created (untracked), `git diff` will not show it. If the agent created files without committing, the deltas may be inaccurate.

**Mitigation:** Agents should use `wc -l` for new files and `git diff --stat` for modified files. If neither is available, omit the delta -- the format degrades to the current behavior (bare path). The delta is helpful context, not required.

### Risk 4: Self-containment rule increases gate verbosity

Restating prior decisions in each gate adds 1-2 lines per dependency reference. For a gate with 3 dependencies, that is 3-6 extra lines.

**Mitigation:** The self-containment rule applies to the DECISION line and dependency references only, not to full re-explanation. One sentence per dependency: "Builds on the lazy loading architecture approved in Task 2." This is unlikely to exceed 2 extra lines in practice.

## Additional Agents Needed

None. The devx-minion and ux-strategy-minion cover CLI presentation and information architecture. The software-docs-minion covers documentation consistency. These three specialists plus the mandatory reviewers are sufficient for the scope of this task.
