# Domain Plan Contribution: devx-minion

## Planning Question

Evaluate the getting-started experience. (a) Is clone + ./install.sh the right zero-to-value flow? (b) Is the path from "installed" to "first agent interaction" clear? (c) Should there be a "first 5 minutes" guide? (d) Are the README example commands the right ones? (e) Separate quickstart page or inline-in-README?

---

## Recommendations

### (a) Clone + ./install.sh is the right zero-to-value flow -- with adjustments

The current flow (`git clone` then `./install.sh`) is correct for this type of project. There is no npm package to install, no build step, and no runtime to configure. The symlink deployment model means zero-copy, instant updates, and easy rollback -- all properties that a framework-averse developer tool should have. Trying to wrap this in a package manager or installer would add complexity without benefit.

However, the current flow has **three friction points** that increase time-to-first-success:

1. **No prerequisites check.** The README does not mention that Claude Code must already be installed and configured. A developer who clones without Claude Code installed will run `./install.sh` successfully (symlinks are created), then have no way to test. The install script should either check for Claude Code or the README should state the prerequisite explicitly.

2. **No verification step.** After `./install.sh` completes, the developer sees "Installed 28 agents and skills successfully" but has no way to confirm things work. There is no `./install.sh verify` or suggested next command. The install script's output should end with a "what to do next" line -- something like: `Try it: open a Claude Code session and type @gru hello`.

3. **No post-install orientation.** The install output lists 28 checkmarks but says nothing about what to try first. 27 agents is overwhelming if the developer does not know which one to reach for. The output should suggest one specific starting command, not all 27.

**Recommendation**: Keep clone + install as the mechanism. Add a prerequisites note to README (Claude Code required). Add a "next step" line to install.sh output. The install script itself is clean, idempotent, and well-structured -- it needs a better landing, not a different approach.

### (b) The path from "installed" to "first agent interaction" has a gap

After install, the README's "What you get" section shows five example commands. But there is a critical gap: the developer does not know **where to type those commands**. The README assumes the reader knows that `@agent-name` and `/skill-name` are Claude Code interaction patterns. For someone who found this project via GitHub search or a blog post, that context is missing.

The gap is:

```
[install.sh finishes] --> ??? --> [@gru Should we adopt A2A?]
```

The missing step is: "Open Claude Code in any project directory, then type one of these commands." This is one sentence, but its absence breaks the flow entirely.

Additionally, the README shows `/nefario` as a slash command but does not explain why it is different from the `@agent` pattern. The distinction between agents (invoked with `@`) and skills (invoked with `/`) is a Claude Code concept that the README should clarify in one line, not leave as tribal knowledge.

**Recommendation**: Add an explicit "Try it" block between the Install section and the Agent Roster. Something like:

```
## Try it

Open Claude Code in any project, then:

    @security-minion Review this auth flow for vulnerabilities

Agents are invoked with @name for single-specialist work.
For multi-domain tasks, use the /nefario skill:

    /nefario Build an MCP server with OAuth, tests, and user docs
```

This bridges the gap between installation and usage with zero ambiguity about where and how to invoke agents.

### (c) A "first 5 minutes" guide would add significant value -- but inline, not as a separate page

The current documentation has two extremes: the README (high-level, what-you-get) and docs/orchestration.md Section 1 (detailed nefario usage). Nothing occupies the middle ground of "I installed this, now show me what it can do in 5 minutes."

A first-5-minutes section should cover exactly three things:

1. **Try a single agent** -- Pick one agent, give a realistic prompt, show what the interaction looks like. Use `@security-minion` or `@debugger-minion` because their value is immediately obvious ("find vulnerabilities" or "find the root cause" produce concrete, useful output on any codebase).

2. **Try nefario on a small task** -- Show a realistic `/nefario` invocation and briefly describe what happens (meta-plan, specialist consultation, execution). The reader does not need the full nine-phase explanation here -- just enough to understand that nefario coordinates multiple specialists.

3. **Discover more agents** -- Point to the roster table and the orchestration doc. "Now that you have seen two patterns (single agent, orchestrated), browse the roster to see which specialists match your work."

This should live **inline in the README**, not as a separate page. Reasons:

- GitHub renders README.md as the landing page. Every click away from README is a conversion loss.
- The content is 15-20 lines, not a full tutorial. It does not justify its own page.
- Developers who land on the repo and scroll through README should hit "Install," then "Try it," then "Learn more" -- all without clicking away.

If the README becomes too long, the detailed orchestration guide (docs/orchestration.md Section 1) is the right place for expanded getting-started content. But the README itself should contain the minimum viable onboarding path.

**Recommendation**: Add a "Try it" or "Getting started" section to README between Install and Agent Roster, containing a single-agent example, a nefario example, and a pointer to the roster. Keep it under 25 lines.

### (d) The README example commands need restructuring

The current "What you get" block shows five examples:

```
@gru Should we adopt A2A or double down on MCP?
@security-minion Review this auth flow for vulnerabilities
@debugger-minion This function leaks memory under load -- find the root cause
@frontend-minion Refactor this component to use web components instead of React
/nefario Build an MCP server with OAuth, tests, and user docs
```

**What works well:**

- The examples demonstrate real, non-trivial tasks (not "hello world" examples).
- The range of domains (strategy, security, debugging, frontend, orchestration) communicates breadth.
- The `/nefario` example naturally shows cross-domain coordination.

**What needs improvement:**

1. **The examples are in a code block, not a callout.** They look like CLI commands to run in a terminal. They are actually Claude Code interactions. The presentation should make this clear -- either label the block ("In any Claude Code session:") or use a different formatting pattern.

2. **Too many examples before explaining the model.** Five examples, then the explanation of how agents work. The value prop ("single-domain to specialist, multi-domain to nefario") should come first, then 2-3 examples that illustrate the model. Currently, the examples demonstrate breadth before the reader understands the system. That is showing features before establishing the concept.

3. **The first example is the weakest for a cold open.** `@gru Should we adopt A2A or double down on MCP?` assumes the reader knows what A2A and MCP are. It demonstrates gru's strategic advisory role, but for a first impression, a universally relatable example works better. `@security-minion Review this auth flow for vulnerabilities` or `@debugger-minion` are better cold-open examples because every developer has auth flows and bugs.

4. **The nefario example should be the climax, not one of five.** The orchestration capability is the project's most distinctive feature. It should be separated and highlighted, not listed alongside single-agent invocations as if they are equivalent.

**Recommendation**: Restructure to lead with the concept, then illustrate with 2-3 examples:

```
Single-domain work goes to the specialist:

    @security-minion Review this auth flow for vulnerabilities
    @debugger-minion This function leaks memory under load -- find the root cause

Multi-domain work goes to /nefario, which coordinates across specialists:

    /nefario Build an MCP server with OAuth, tests, and user docs
```

This order tells the story: specialists for focused work, nefario for complex work. Fewer examples, better understood.

### (e) Inline in README, with docs/orchestration.md as the deep dive

For this project, a separate quickstart page would be an antipattern. Here is why:

- **The project IS the quickstart.** Clone, install, use. There is no configuration, no API keys, no server to run, no accounts to create. The "getting started" experience is two shell commands followed by typing in Claude Code. That is 30 seconds, not a tutorial.

- **GitHub README is the landing page.** Most developers will never click into `docs/`. The README must be self-contained for the 80% use case: understand what this is, install it, try it, decide whether to learn more.

- **Separate quickstart pages create maintenance burden.** Two locations explaining "how to get started" will drift apart. The README is the canonical getting-started path.

- **The deep dive already exists.** docs/orchestration.md Section 1 ("Using Nefario") is an excellent extended guide. It covers when to use nefario vs. direct agents, how to write good prompts, and what the nine phases do. That is the "first 30 minutes" guide. It just needs to be discoverable from README.

**Recommendation**: README gets an inline "Try it" section (15-25 lines). The Documentation section at the bottom of README should promote the orchestration guide more prominently as the natural next step ("New to the project? Start with the [Orchestration Guide](docs/orchestration.md) to see how agents work together.").

---

## Proposed Tasks

### Task 1: Add "Try it" section to README

**What to do**: Insert a new section between "Install" and "Agent Roster" that bridges the gap from installation to first use. Must include: (a) one-line note that agents are available in any Claude Code session after install, (b) one single-agent example with brief explanation, (c) one nefario example showing multi-agent coordination, (d) the `@agent` vs `/skill` distinction in one sentence.

**Deliverables**: Updated README.md with "Try it" section (15-25 lines).

**Dependencies**: Depends on the messaging hierarchy decision from product-marketing-minion and information architecture from software-docs-minion (those determine what comes before and after the "Try it" section). This task should execute after the README structure is agreed at Gate 1.

### Task 2: Restructure "What you get" examples

**What to do**: Rework the opening examples to lead with the concept ("specialist for single-domain, nefario for multi-domain"), reduce to 2-3 examples that illustrate the model, and make the nefario orchestration example the climax rather than one-of-five. Remove or downgrade examples that assume domain-specific knowledge (A2A/MCP).

**Deliverables**: Updated README.md "What you get" section.

**Dependencies**: Depends on product-marketing-minion's recommended messaging hierarchy. Likely executes as part of the same README rewrite pass as Task 1.

### Task 3: Add post-install orientation to install.sh output

**What to do**: After the final "Installed N agents and skills successfully" message, print a "Next step" line suggesting a first command to try. Keep it to 2-3 lines. Example: `"\nNext: open Claude Code in any project and try: @security-minion Review this auth flow"`. Also add a prerequisite check or note at the start: if `~/.claude/` does not exist, print a warning that Claude Code may not be installed.

**Deliverables**: Updated install.sh with post-install next-step message and optional prerequisite warning.

**Dependencies**: None. Can execute independently.

### Task 4: Add "prerequisite" note to README Install section

**What to do**: Add a one-line note before or after the install commands stating that Claude Code must be installed. Link to Claude Code's install page if there is a stable URL, otherwise just state the requirement.

**Deliverables**: Updated README.md Install section (1-2 additional lines).

**Dependencies**: None. Can execute independently.

### Task 5: Promote orchestration guide as "next step" in README

**What to do**: In the Documentation section of README, add a sentence or callout that directs new users to docs/orchestration.md Section 1 as the recommended next read after trying the basic examples. Currently all six docs are listed equally -- the orchestration guide should be positioned as the natural next step for users, while the other docs serve contributors and advanced users.

**Deliverables**: Updated README.md Documentation section with promoted link to orchestration guide.

**Dependencies**: Depends on information architecture decisions from software-docs-minion (which may reorganize the docs section entirely).

---

## Risks and Concerns

### Risk 1: README grows too long and loses the "scan in 30 seconds" property

Adding "Try it," restructuring examples, and adding prerequisites all add lines to README. The current README is 91 lines and highly scannable. If we are not disciplined, the rewrite could push it past 150 lines, which defeats the purpose.

**Mitigation**: Set a hard target of 120 lines maximum for README. Every line added must earn its place. The "Try it" section replaces some of the current "What you get" content, not supplements it.

### Risk 2: install.sh changes affect existing users

Modifying install.sh output is low risk (additive, no behavior change), but the prerequisite check could be misinterpreted. If the script prints "Warning: Claude Code may not be installed" but the developer has Claude Code installed in a non-standard location, it creates confusion.

**Mitigation**: Make the prerequisite check informational, not blocking. Print a note, do not exit with an error. Check for `~/.claude/` directory existence as a heuristic, not a definitive test.

### Risk 3: Example commands in README become stale

If agent names change or capabilities shift, the README examples break. This is already a risk with the current five examples, but the "Try it" section makes it more visible because it promises a working interaction.

**Mitigation**: Use examples that exercise stable, core capabilities (security review, debugging) rather than niche features. These are unlikely to change. The README examples should also appear in a testing checklist so they are validated when agents are updated.

### Risk 4: The @agent vs /skill distinction confuses more than it clarifies

Explaining the difference between `@agent` and `/skill` invocation could raise more questions than it answers for developers who do not yet understand Claude Code's extension model. Over-explaining is worse than under-explaining here.

**Mitigation**: One sentence maximum. "Agents are invoked with @name, skills with /name." If the developer already uses Claude Code, this is obvious. If they do not, the detail is not what is blocking them -- installing Claude Code is.

---

## Additional Agents Needed

None. The current team (product-marketing-minion, software-docs-minion, ux-strategy-minion, devx-minion) covers the planning needs for this documentation task. The user-docs-minion could contribute to the getting-started flow design, but its expertise overlaps sufficiently with devx-minion on onboarding patterns that a separate consultation is not necessary -- user-docs-minion should participate in execution (writing) rather than planning.
