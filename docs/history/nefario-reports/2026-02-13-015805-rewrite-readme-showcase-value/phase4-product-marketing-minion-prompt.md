You are rewriting the README.md for the despicable-agents project. This is a Claude Code agent team with 27 specialist agents and 2 skills.

## Your Task

Rewrite `/Users/ben/github/benpeter/2despicable/2/README.md` to clearly communicate what despicable-agents gives you that simpler agent setups don't. A first-time evaluator should understand the value proposition within 60 seconds of reading.

## Current README

Read `/Users/ben/github/benpeter/2despicable/2/README.md` for the current content.

## Section Structure (in this order)

1. **Title + badge** -- keep the vibe-coded badge as-is
2. **Opening paragraph** -- lead with what the user GETS, not what the project IS. Remove the "This project explores" experimental framing. Keep the Agent Teams link but reframe as "Built on" not "explores." Keep the Web Resource Ledger reference.
3. **What You Get** -- new section with four top-level bullets:
   - **Phased orchestration** -- structured phases from meta-planning through execution to post-execution verification, with user approval gates throughout
   - **Research-backed domain experts** -- 27 agents built from domain research, each with strict boundaries so delegation is unambiguous
   - **Built-in governance and quality gates** -- five mandatory reviewers (security, testing, docs impact, intent alignment, simplicity) examine every plan before code runs; post-execution code review and test execution verify output
   - **Goodies** -- execution reports committed to repo, `/despicable-prompter` skill for rough-idea-to-structured-brief, install-once-available-everywhere via symlinks, `/despicable-lab` for version-tracked agent maintenance
4. **Examples** -- merge current Examples and Try It. Show specialists for single-domain, `/nefario` for multi-domain, plus `#42` issue mode. Remove the separate "Try It" section.
5. **Install** -- keep current content, already good
6. **How It Works** -- rewrite as user-experience flow (you describe task, specialists consult, plan reviewed by 5 mandatory reviewers, parallel execution with gates, post-execution verification). Pair character names with functional roles. Link to using-nefario.md.
7. **Agents** -- keep collapsible roster, no changes needed
8. **Documentation** -- keep as-is
9. **Current Limitations** -- reframe "mostly vibe-coded" bullet: change header to "AI-assisted prompt authoring", keep the explanation
10. **Contributing** -- keep as-is
11. **License** -- keep as-is

## Critical Accuracy Requirements

These facts MUST be correct:
- FIVE mandatory reviewers (not six): security-minion, test-minion, software-docs-minion, lucy, margo
- 27 agents + 2 skills (not "29 agents")
- 4 named roles + 23 minions across 7 domain groups
- Nine-phase process (Phases 1-8, with 3.5 making nine)
- `/despicable-prompter` accepts inline text or `#<issue-number>` to pull from GitHub issues
- Nefario auto-discovers project-local skills from `.skills/` and `.claude/skills/`
- `./install.sh` symlinks to `~/.claude/` (not copies)
- Web Resource Ledger link: https://github.com/benpeter/web-resource-ledger

## Verification Files

If you need to verify any claim, read:
- `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md`
- `/Users/ben/github/benpeter/2despicable/2/docs/agent-catalog.md`
- `/Users/ben/github/benpeter/2despicable/2/docs/external-skills.md`

## Style and Tone

- Bullet-based, scannable -- no walls of text
- Honest technical tone -- no marketing buzzwords
- Lead with outcomes, not mechanisms
- Keep Despicable Me personality but pair names with functional roles
- Structural claims over guarantees ("five reviewers examine every plan" not "your code will be secure")
- Target 120-150 lines

## What NOT to Do

- Do not modify any file other than README.md
- Do not add badges, screenshots, or images
- Do not add a table of contents
- Do not use HTML beyond the existing `<details>` block
- Do not introduce unverifiable claims

When you finish, report: file path, line count, and 1-2 sentence summary of what was produced.