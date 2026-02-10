# Code Review: Preserve Original Prompt in Reports

## Review Summary

VERDICT: ADVISE

All three files have been modified correctly according to the synthesis plan. The changes are consistent, the terminology is unified, and the instructions are clear. However, there are two findings that warrant attention before this is considered production-ready.

## Findings

### 1. [ADVISE] skills/nefario/SKILL.md:725-732 -- Secret detection regex missing word boundaries
AGENT: devx-minion
DESCRIPTION: The grep regex for secret scanning in the PR body secret scan (lines 725-732) uses bare pattern matching without word boundaries or anchoring. This creates false positive risk. For example, `password:` would match inside a code block discussing password fields, not just actual credentials.

The companion directory secret scan (lines 858-864) has the same issue, though it includes more comprehensive patterns like `AKIA` and `ghp_`.

FIX: Consider adding word boundaries or context anchors to reduce false positives. Example improvement:
```bash
# Secret scan on PR body (more precise patterns)
if grep -qE '(^|[^a-zA-Z0-9])(sk-[a-zA-Z0-9]{20,}|key-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36,}|github_pat_[a-zA-Z0-9_]{82}|AKIA[0-9A-Z]{16}|(token|bearer|password|passwd):\s*[^\s]+|-----BEGIN.*PRIVATE KEY-----)' "$body_file"; then
```

However, this is ADVISE not BLOCK because:
- The current regex is defense-in-depth (a safety net, not primary security)
- False positives are safe failures (user reviews and aborts, no leak occurs)
- The existing instruction "Remove or redact any matches before proceeding" is manual verification anyway
- A more precise regex would be harder to maintain and might introduce false negatives

Recommendation: Document this tradeoff in commit message or inline comment. The current approach prioritizes safety over convenience, which is appropriate for secret detection.

### 2. [ADVISE] skills/nefario/SKILL.md:144-147 -- Missing prompt.md format specification
AGENT: devx-minion
DESCRIPTION: The instruction to write `prompt.md` says "as plain markdown (no YAML frontmatter)" but does not specify the exact format. The synthesis plan (phase3-synthesis.md lines 82-91) shows the format should be:

```markdown
# Original Prompt

> <the sanitized verbatim prompt text, in a blockquote>
```

The SKILL.md instruction should include this format inline so the orchestrator knows what structure to write, rather than requiring the executor to infer it from TEMPLATE.md.

FIX: Add the format specification to lines 144-147:
```markdown
Write the **already-sanitized** original prompt to `nefario/scratch/{slug}/prompt.md`
as plain markdown:

    # Original Prompt

    > <the sanitized verbatim prompt text, in a blockquote>

Use the same blockquote formatting as the report's Original Prompt section
(inline for short prompts, no collapsible wrapper in the file -- the file IS
the expanded version). This file flows to the report's companion directory
via the existing `cp -r` at wrap-up, providing a standalone record of the
original request.
```

This is ADVISE not BLOCK because:
- The format is already specified in TEMPLATE.md (lines 82-91), which is the source of truth for report structure
- A reader can infer the format from "same blockquote formatting as the report's Original Prompt section" by reading TEMPLATE.md
- The file will be generated correctly as long as the executor follows the template

However, including the format inline improves clarity and reduces the need to cross-reference multiple files during execution.

### 3. [NIT] All files -- Terminology consistency achieved
All instances of "## Task" have been correctly renamed to "## Original Prompt" across TEMPLATE.md examples and orchestration.md. The checklist in TEMPLATE.md (step 7, line 373) correctly uses "Write Original Prompt". The Working Files label convention (line 316) correctly adds `prompt.md -> "Original Prompt"`. Excellent consistency.

### 4. [NIT] docs/orchestration.md:519 -- Cross-reference added
The orchestration.md bullet now mentions that the prompt is "also saved as a standalone `prompt.md` file in the report's companion directory for independent reference." This provides good discoverability for users reading the docs.

### 5. [NIT] skills/nefario/SKILL.md:858-864 -- Expanded secret patterns
The companion directory security check now includes `AKIA` (AWS access keys), `ghp_` (GitHub personal access tokens), and `github_pat_` (new GitHub PAT format). This is a material improvement over the previous pattern list and reflects current credential formats. Good addition.

## Cross-Agent Integration

No integration issues detected. The changes are confined to orchestration documentation and instructions. No code files produced, no runtime behavior changed, no API contracts affected.

## Complexity Assessment

Minimal complexity added. The prompt.md file is a straightforward write operation with a simple format. The security scan additions are grep one-liners. The terminology rename is a search-and-replace with no logic changes.

## DRY Assessment

Slight DRY violation: the secret scan patterns appear in two places (PR body scan line 728, companion directory scan line 859). However, this is acceptable because:
- The two scans have different contexts (PR body extraction vs. scratch file collection)
- The patterns are slightly different (PR body scan is more conservative)
- Extracting to a shared function would require additional orchestration state management
- The patterns are simple enough that maintaining two copies is low risk

## Security Implementation

### Hardcoded Secrets
No secrets in the changes. All changes are documentation and natural language instructions.

### Injection Vectors
The secret detection regex is used with `grep -qEi` which is safe (no command injection, no shell expansion in the pattern). The `$body_file` variable in the PR body scan is inside a `grep` command, not a direct shell expansion, so no injection risk there.

The temp file creation (`body_file=$(mktemp)`) is secure -- `mktemp` creates a unique file with safe permissions.

### Auth/Authz
Not applicable. No authentication or authorization logic in these changes.

### Crypto
Not applicable. No cryptographic operations in these changes.

### CVEs
No dependencies added or modified. No CVE exposure.

## Recommendation

ADVISE: Approve with advisories. The two findings above are minor and do not block merge:
1. Secret regex could be more precise, but current approach is defensively safe
2. Format specification could be inline in SKILL.md, but it's already in TEMPLATE.md

Both findings are documentation/clarity improvements, not functional bugs. The code is correct as written.

## Verification Grep Results (from synthesis)

All checks passed:
1. `grep -r "## Task" docs/history/nefario-reports/TEMPLATE.md` → No matches (all renamed to "## Original Prompt") ✓
2. `grep "prompt.md" skills/nefario/SKILL.md` → Returns lines 144, 316 (new Phase 1 instruction + Working Files label) ✓
3. `grep "prompt.md" docs/orchestration.md` → Returns line 519 (new bullet text) ✓
4. `grep "Original Prompt" docs/history/nefario-reports/TEMPLATE.md` → Returns lines 69, 79, 89, 316, 373 (heading, examples, label, checklist) ✓
5. YAML frontmatter `version: 2` in TEMPLATE.md → Unchanged at line 22 ✓
6. No existing reports modified → Confirmed (only TEMPLATE.md, orchestration.md, SKILL.md touched) ✓
