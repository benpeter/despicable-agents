# code-review-minion Research: Code Quality Review and Review Process Design

This document provides the research foundation for code-review-minion, focused on code quality review practices, static analysis configuration, PR review standards, and review process design. The mission is to ensure code is maintainable, readable, and free of common bugs through effective review practices and automation.

## Domain Overview

Code review is the systematic examination of source code to identify bugs, improve quality, and share knowledge. Studies show code review catches 60-90% of defects before they reach production, reduces technical debt, and improves team collaboration.

code-review-minion focuses on review process design and quality assessment, not implementation. It establishes review standards, configures static analysis, and provides feedback on code quality. Implementation remains with domain specialists (frontend-minion, backend-minion, etc.).

Effective code review balances rigor and speed. Over-critical reviews slow teams down and create friction. Under-critical reviews allow bugs and technical debt to accumulate. The goal is actionable, specific, kind feedback that improves code quality without blocking progress.

## Code Review Best Practices

Code review effectiveness depends on reviewer skills, team culture, and process design.

### Google Engineering Practices

Google's Engineering Practices Guide provides industry-leading code review guidance.

**Core Principle**: "A reviewer should approve a change once they are convinced that it improves the overall health of the codebase, even if it isn't perfect."

**Key Guidelines**:

**1. Focus on Code Health**: Does this change improve or degrade codebase quality?

**2. Bias Toward Approval**: Don't block changes over minor style preferences. Use auto-formatting for style.

**3. Review Within 24 Hours**: Fast reviews reduce context-switching and keep momentum.

**4. Small Changes**: Encourage small, incremental changes (< 400 lines). Large PRs are reviewed poorly.

**5. Provide Context**: Explain why changes are needed, not just what to change.

**6. Be Kind and Respectful**: "Consider renaming for clarity" beats "This variable name is terrible."

**7. Distinguish Blocking vs. Non-Blocking**: Mark suggestions as "nit" (non-blocking) vs. required changes.

**8. Test Coverage**: Ensure new code has appropriate tests.

### Microsoft Code Review Guidelines

Microsoft's guidelines emphasize reviewer responsibility and feedback quality.

**Reviewer Responsibilities**:
- Understand the change's purpose and context
- Check for correctness, performance, security
- Ensure code is maintainable and testable
- Verify tests exist and cover edge cases
- Look for simpler implementations

**Feedback Quality**:
- Specific: Point to exact lines, not vague critiques
- Actionable: Suggest concrete improvements
- Constructive: Explain why changes improve code

**Review Fatigue**: Limit reviews to 200-400 lines per session. Beyond this, defect detection drops significantly.

### Balancing Nitpicking vs. High-Impact Feedback

**Nitpicking**: Minor style preferences, subjective choices, micro-optimizations.

**High-Impact Feedback**: Bugs, security vulnerabilities, architectural issues, scalability problems.

**Strategy**:
- Automate style with linters (ESLint, Prettier, Biome, Ruff, Pylint)
- Save human review for logic, design, security, correctness
- Mark low-priority suggestions as "nit" so authors can defer

**Example**:
- **Nitpick**: "Consider using const instead of let here" (automation should catch this)
- **High-Impact**: "This function doesn't handle null inputs, causing potential crashes"

**Best Practice**: If you're commenting on formatting or style, your linter configuration is insufficient. Fix the linter, not the human.

## Static Analysis Tools Configuration

Static analysis automates code quality checks, catching bugs and style violations before human review.

### JavaScript/TypeScript: ESLint vs. Biome

**ESLint** (established standard):
- Most popular JavaScript linter (90+ million weekly npm downloads)
- Highly customizable with plugins (React, TypeScript, accessibility)
- Large ecosystem of shareable configs (Airbnb, Standard, Google)
- Slower than newer alternatives

**Configuration** (`.eslintrc.json`):
```json
{
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  "rules": {
    "no-unused-vars": "error",
    "no-console": "warn",
    "prefer-const": "error"
  }
}
```

**Biome** (modern alternative):
- Built with Rust, 10-100x faster than ESLint (10,000 files: ESLint 45.2s vs Biome 0.8s)
- Linting + formatting in one tool (replaces ESLint + Prettier)
- Zero configuration defaults with 97% Prettier compatibility
- Successor to Rome (discontinued 2023), now stable at v2.x (423+ lint rules as of 2026)
- Type-aware linting capability added in v2.x
- Smaller ecosystem (fewer plugins than ESLint, ~80% compatibility)

**Configuration** (`biome.json`):
```json
{
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space"
  }
}
```

**When to Use**:
- **ESLint**: Mature projects, extensive plugin needs, established teams
- **Biome**: New projects, monorepos, performance-critical CI/CD

### Python: Pylint vs. Ruff

**Pylint** (established):
- Comprehensive Python linter
- Checks code quality, style (PEP 8), errors, refactoring opportunities
- Slower on large codebases

**Configuration** (`.pylintrc`):
```ini
[MESSAGES CONTROL]
disable=C0111,W0212

[FORMAT]
max-line-length=100
```

**Ruff** (modern):
- Written in Rust, 50-200x faster than Pylint (scan: ~0.2s vs ~20s for Flake8)
- Implements Flake8, isort, pydocstyle, pyupgrade, and more (800+ total rules)
- Auto-fixing capability (unlike Pylint)
- Drop-in replacement for multiple tools, though not a "pure" drop-in for Pylint
- Active development, rapidly gaining adoption (2026: preferred for new projects)

**Configuration** (`pyproject.toml`):
```toml
[tool.ruff]
line-length = 100
select = ["E", "F", "W"]
ignore = ["E501"]
```

**When to Use**:
- **Pylint**: Teams prioritizing comprehensive checks, established workflows
- **Ruff**: Performance-critical projects, large codebases, modern tooling

### Other Languages

**Go**: golangci-lint (aggregates 50+ linters)
**Rust**: clippy (official Rust linter)
**Java**: SpotBugs, Checkstyle, PMD
**C#**: StyleCop, Roslyn analyzers
**Ruby**: RuboCop

### CI/CD Integration

Static analysis should run in CI/CD and fail builds on errors.

**Example (GitHub Actions)**:
```yaml
name: Lint
on: [pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run lint
```

**Fail Builds on Errors, Warn on Style**: Configure linters to error on bugs, warn on style violations. Block merges on errors, not warnings.

## Code Complexity Metrics

Complexity metrics quantify how difficult code is to understand and maintain.

### Cyclomatic Complexity

Cyclomatic complexity counts decision points in code (if, while, for, case). It measures the number of independent paths through code.

**Calculation**: Count decision points + 1.

**Thresholds**:
- 1-10: Simple, low risk
- 11-20: Moderate complexity
- 21-50: High complexity, refactor recommended
- 50+: Very high complexity, untestable

**Tools**: SonarQube, CodeClimate, PMD, complexity (Python).

**Limitations**: Treats all control flow equally. Deeply nested code is harder to understand than flat sequences, even with the same cyclomatic complexity.

### Cognitive Complexity

Cognitive complexity measures how difficult code is for humans to understand. It penalizes nesting more heavily than sequential logic.

**Key Differences from Cyclomatic**:
- Increments for each nesting level
- Penalizes nested if/for/while more than flat sequences
- Does NOT increment for readability shortcuts (else, elif, catch)

**Example**:
```python
# Cyclomatic: 4, Cognitive: 7
def process(items):
    for item in items:              # +1
        if item.valid:              # +2 (nested)
            if item.active:         # +3 (doubly nested)
                if item.ready:      # +4 (triply nested)
                    process_item(item)
```

**Thresholds**:
- 0-5: Simple
- 6-15: Moderate
- 16+: Complex, refactor recommended

**Tools**: SonarQube (Java, JavaScript, Python, C#, etc.).

**Best Practice**: Prefer cognitive complexity over cyclomatic for human-centric assessment. It better captures mental load.

## PR Review Automation

Automated PR review bots augment human review by catching common issues automatically.

### ReviewDog

ReviewDog is a flexible code review automation framework that integrates linter output into PR comments.

**Features**:
- Supports any linter that outputs line-based warnings
- Posts inline PR comments at error locations
- Integrates with GitHub, GitLab, Bitbucket

**Example (GitHub Actions)**:
```yaml
name: ReviewDog
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: reviewdog/action-eslint@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          reporter: github-pr-review
```

**Supported Linters**: ESLint, Pylint, RuboCop, golangci-lint, and any tool that outputs structured output.

### AI-Powered Code Review

Several AI-based tools provide automated code review:

**CodeRabbit**:
- Integrates with GitHub, GitLab, Bitbucket, Azure DevOps
- Provides AI-generated review comments, summaries, and suggestions
- Focuses on readability, maintainability, potential bugs

**CodeAnt AI**:
- AI-driven code review and quality analysis
- Security scanning integrated
- Supports multiple languages

**Continue CLI**:
- Runs in GitHub Actions with team-specific rules
- Code sent to your LLM provider (no hosted service)
- Customizable rules per team

**Use Cases for AI Review**:
- Catch logic errors not detected by linters
- Suggest alternative implementations
- Flag complex code for refactoring
- Provide context-aware feedback

**Limitations**:
- May produce false positives
- Suggestions may be too verbose
- Cannot replace human judgment on design decisions

**Best Practice**: Use AI review as a supplement, not replacement. Human review remains essential for architecture, security, and domain logic.

### Custom Review Bots

**Danger**:
- JavaScript-based PR automation
- Custom rules for project-specific checks

**Example**:
```javascript
// dangerfile.js
import { danger, warn, fail } from 'danger';

// Warn if PR is too large
if (danger.github.pr.additions + danger.github.pr.deletions > 500) {
  warn('This PR is quite large. Consider breaking it into smaller PRs.');
}

// Fail if tests aren't updated
if (!danger.git.modified_files.includes('test/')) {
  fail('Tests should be updated or added for this change.');
}
```

**Use Cases**:
- Enforce changelog updates
- Require test file changes
- Check for specific file patterns
- Enforce commit message conventions

## Code Quality Metrics and Reporting

Code quality metrics provide objective measures of codebase health.

### SonarQube

SonarQube is a comprehensive code quality platform that analyzes code for bugs, vulnerabilities, code smells, and technical debt.

**Metrics**:
- **Bugs**: Code likely to cause runtime errors
- **Vulnerabilities**: Security issues (SQL injection, XSS, etc.)
- **Code Smells**: Maintainability issues (high complexity, duplication)
- **Technical Debt**: Estimated time to fix issues
- **Coverage**: Test coverage percentage

**Quality Gates**: Define thresholds for metrics (e.g., > 80% coverage, < 3% duplicated code). Fail builds if gates aren't met.

**Integration**: Runs in CI/CD, posts results to PRs, tracks quality over time.

**Languages**: Java, JavaScript, TypeScript, Python, C#, Go, PHP, Ruby, Swift, Kotlin, and more.

### CodeClimate

CodeClimate provides maintainability and test coverage analysis.

**Maintainability Metrics**:
- Cognitive complexity
- Code duplication
- Method/function length
- Argument count

**Quality Grades**: A (excellent) to F (poor) based on maintainability.

**Integration**: GitHub, GitLab, Bitbucket. Posts PR comments with quality changes.

### Code Coverage

Code coverage measures what percentage of code is executed by tests.

**Coverage Types**:
- **Line Coverage**: Percentage of lines executed
- **Branch Coverage**: Percentage of branches (if/else) executed
- **Function Coverage**: Percentage of functions called

**Tools**:
- **JavaScript**: Istanbul/NYC, Jest (built-in)
- **Python**: coverage.py, pytest-cov
- **Java**: JaCoCo
- **Go**: go test -cover

**Thresholds**: Aim for 70-90% coverage. 100% is overkill (diminishing returns). Focus on critical paths.

**Best Practice**: Track coverage trends over time. Fail builds if coverage decreases below a threshold (e.g., 80%).

## PR Review Standards and Checklists

Review standards and checklists ensure consistency across reviewers.

### Review Checklist

**Correctness**:
- Does the code do what it's supposed to do?
- Are edge cases handled?
- Are error cases handled gracefully?

**Testing**:
- Are there tests for new functionality?
- Do tests cover edge cases?
- Are tests readable and maintainable?

**Readability**:
- Is the code easy to understand?
- Are variable and function names descriptive?
- Are comments used where logic is non-obvious?

**Design**:
- Does the code fit the existing architecture?
- Is complexity justified by requirements?
- Are abstractions appropriate (not over- or under-abstracted)?

**Performance**:
- Are there obvious performance issues (N+1 queries, unnecessary loops)?
- Is performance optimization justified (is this a bottleneck)?

**Security**:
- Are inputs validated?
- Are secrets hardcoded?
- Are common vulnerabilities avoided (SQL injection, XSS)?

**Maintainability**:
- Is the code duplicated elsewhere (DRY principle)?
- Will this code be easy to modify later?
- Are dependencies justified?

### When to Block vs. Approve with Comments

**Block (Request Changes)**:
- Bugs or correctness issues
- Security vulnerabilities
- Missing tests for new functionality
- Breaking changes without migration plan
- Violates established architecture

**Approve with Comments (Non-Blocking)**:
- Style suggestions (if linter doesn't catch it)
- Refactoring opportunities (non-critical)
- Performance optimizations (not bottlenecks)
- Documentation improvements

**Comment Types**:
- **"Required:"**: Blocking change
- **"Nit:"**: Non-blocking suggestion
- **"Question:"**: Seeking clarification
- **"Praise:"**: Positive feedback

### Review Comment Effectiveness

**Ineffective Comments**:
- "This is bad" (vague, not actionable)
- "You should know this" (condescending)
- "Why didn't you...?" (accusatory)

**Effective Comments**:
- "Consider extracting this logic into a helper function for testability"
- "This could cause a null pointer exception if `user` is undefined. Suggest adding a null check."
- "Great approach to handling this edge case!"

**Tone Matters**: Write as if you're pair programming, not grading homework.

## Bug Pattern Detection

Common bug patterns can be detected through static analysis and code review.

### Common Patterns by Language

**JavaScript/TypeScript**:
- Unhandled promise rejections
- Mutation of props (React)
- Memory leaks (event listeners not removed)
- Type coercion bugs (== vs ===)
- Incorrect async/await usage

**Python**:
- Mutable default arguments
- Incorrect exception handling (bare except)
- Resource leaks (files not closed)
- Global variable misuse
- Late binding in closures

**Java**:
- Null pointer exceptions
- Resource leaks (streams not closed)
- Thread safety issues
- Serialization bugs
- Equals/hashCode inconsistencies

**Go**:
- Goroutine leaks
- Incorrect error handling
- Race conditions
- Deferred function misuse
- Slice append issues

### Static Analysis for Bug Detection

**SonarQube**: Detects hundreds of bug patterns (null dereference, resource leaks, logic errors).

**ESLint**: Detects JavaScript-specific bugs (no-unsafe-member-access, no-floating-promises).

**SpotBugs (Java)**: Detects common Java bugs (null pointer dereference, infinite loops, concurrency issues).

**Clippy (Rust)**: Detects Rust-specific issues (borrow checker violations, unsafe code, performance anti-patterns).

**Best Practice**: Run static analysis in CI/CD. Fail builds on critical bugs, warn on code smells.

## Review Process Design

Process design determines how reviews are conducted, who reviews, and when.

### Review Assignment Strategies

**Round-Robin**: Distribute reviews evenly across team members.

**Domain Expertise**: Assign reviewers based on code area expertise.

**CODEOWNERS (GitHub)**: Automatically request reviews from file/directory owners.

**Example (`.github/CODEOWNERS`)**:
```
# Frontend team owns all React components
/src/components/ @frontend-team

# Backend team owns API routes
/api/ @backend-team

# Security team reviews authentication
/auth/ @security-team
```

**Load Balancing**: Avoid overloading single reviewers. Use tools to track review load.

### Review Speed vs. Thoroughness

**Fast Reviews (< 1 hour)**:
- Smaller changes (< 100 lines)
- Straightforward bug fixes
- Documentation updates

**Thorough Reviews (2-4 hours)**:
- Large changes (100-400 lines)
- New features
- Architectural changes

**Red Flag (> 4 hours)**:
- Change is too large (split into smaller PRs)
- Complexity is too high (refactor before review)

**Best Practice**: Aim for same-day reviews. Delays cause context loss and reduce effectiveness.

### Pair Programming as Alternative

Pair programming (two developers writing code together) is real-time code review.

**Advantages**:
- Immediate feedback
- Knowledge sharing
- Faster resolution of blockers

**Disadvantages**:
- Resource-intensive (two developers on one task)
- Requires compatible working styles

**When to Use**:
- Complex features
- Onboarding new team members
- Critical bug fixes

**Pair Programming + Async Review**: Pair program for complex logic, async review for final polish and tests.

## Code Review Culture

Effective code review requires a healthy team culture.

### Psychological Safety

Reviewers and authors must feel safe giving and receiving feedback.

**Good Culture**:
- Feedback is about code, not people
- Mistakes are learning opportunities
- Questions are encouraged
- Disagreements are resolved collaboratively

**Bad Culture**:
- Feedback is personal or condescending
- Mistakes are punished
- Questions are dismissed
- Disagreements escalate to conflict

**Building Safety**:
- Praise good code publicly
- Criticize code privately (or in PR comments, not Slack)
- Frame feedback as suggestions, not mandates
- Acknowledge uncertainty ("I might be wrong, but...")

### Review Training

Not all developers are effective reviewers. Training improves review quality.

**Training Topics**:
- What to look for (correctness, tests, readability, design)
- How to give feedback (specific, actionable, kind)
- Distinguishing blocking vs. non-blocking issues
- Balancing speed and thoroughness

**Calibration**: Teams periodically review PRs together to calibrate standards.

### Review Fatigue Management

Reviewing too much code reduces effectiveness.

**Symptoms of Fatigue**:
- Rushed reviews (< 5 minutes for 200+ lines)
- Approval without understanding changes
- Focus on minor style issues, missing major bugs

**Prevention**:
- Limit reviews to 200-400 lines per session
- Distribute review load evenly
- Schedule dedicated review time
- Automate low-value checks (linting, formatting)

## Best Practices Summary

### Review Process

- Review within 24 hours
- Keep PRs small (< 400 lines)
- Use checklists for consistency
- Distinguish blocking vs. non-blocking feedback
- Provide specific, actionable, kind comments

### Automation

- Automate style with linters (ESLint, Biome, Ruff, Pylint)
- Run static analysis in CI/CD (SonarQube, CodeClimate)
- Use review bots for project-specific checks (Danger, ReviewDog)
- Fail builds on critical issues, warn on style violations

### Metrics

- Track code coverage (aim for 70-90%)
- Monitor cyclomatic and cognitive complexity
- Set quality gates (SonarQube, CodeClimate)
- Trend metrics over time (coverage, complexity, technical debt)

### Culture

- Build psychological safety (feedback on code, not people)
- Train reviewers on best practices
- Manage review fatigue (limit review load)
- Celebrate good code and helpful reviews

### Tools by Language

- **JavaScript/TypeScript**: ESLint (mature) or Biome (fast)
- **Python**: Pylint (comprehensive) or Ruff (fast)
- **Go**: golangci-lint
- **Rust**: clippy
- **Java**: SpotBugs, Checkstyle, PMD

## Sources

- [Google Engineering Practices: Code Review](https://google.github.io/eng-practices/review/)
- [Microsoft Code Review Guidelines](https://learn.microsoft.com/en-us/visualstudio/code-quality/)
- [Best Automated Code Review Tools 2026](https://www.qodo.ai/blog/best-automated-code-review-tools-2026/)
- [JavaScript Static Analysis: ESLint vs Biome](https://snyk.io/articles/javascript-static-analysis-eslint-biome/)
- [Biome vs ESLint: Comparing JavaScript Linters and Formatters](https://betterstack.com/community/guides/scaling-nodejs/biome-eslint/)
- [Biome: The ESLint and Prettier Killer? Complete Migration Guide for 2026](https://dev.to/pockit_tools/biome-the-eslint-and-prettier-killer-complete-migration-guide-for-2026-27m)
- [Comparing Ruff, Flake8, and Pylint: Linting Speed](https://trunk.io/learn/comparing-ruff-flake8-and-pylint-linting-speed)
- [Goodbye to Flake8 and PyLint: faster linting with Ruff](https://pythonspeed.com/articles/pylint-flake8-ruff/)
- [How do Ruff and Pylint compare? – Python Developer Tooling Handbook](https://pydevtools.com/handbook/explanation/how-do-ruff-and-pylint-compare/)
- [Code Complexity Metrics Guide](https://daily.dev/blog/7-code-complexity-metrics-developers-must-track)
- [Cyclomatic vs Cognitive Complexity](https://getdx.com/blog/cognitive-complexity/)
- [Cognitive Complexity Vs Cyclomatic Complexity - Key Differences Explained](https://www.graphapp.ai/blog/cyclomatic-complexity-vs-cognitive-complexity-key-differences-explained)
- [How to Automate Code Reviews Using GitHub Actions](https://github.com/orgs/community/discussions/178963)
- [Code Review Bot with Continue and GitHub Actions](https://docs.continue.dev/guides/github-pr-review-bot)
- [ReviewDog GitHub](https://github.com/reviewdog/reviewdog)
