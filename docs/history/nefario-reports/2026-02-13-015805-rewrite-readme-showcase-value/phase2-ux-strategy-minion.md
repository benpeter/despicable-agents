# Domain Plan Contribution: ux-strategy-minion

## Information Journey Analysis (Current README)

I walked through the current README as a first-time evaluator would -- someone who has landed on the GitHub page and is deciding whether despicable-agents is worth their time. Here is the journey mapped against a 60-second scan target.

### Second-by-second scan path

| Seconds | What the eye hits | What the brain processes | Cognitive state |
|---------|-------------------|-------------------------|-----------------|
| 0-3 | Title + badge | "Despicable Agents... 98% vibe coded" -- playful, but tells me nothing about what this does | Curious but uninformed |
| 3-8 | Opening paragraph | Dense sentence: "A team of domain specialists, an orchestrator that coordinates them, and a governance layer that reviews every plan before execution" -- this is structural description, not value | Still asking "why should I care?" |
| 8-12 | Second paragraph | "This project explores Agent Teams..." -- frames it as an experiment, not a tool I should use | Uncertainty: is this production-ready or a toy? |
| 12-15 | Web Resource Ledger link | Example project, but no context for what it demonstrates | Skipped -- no hook to click |
| 15-30 | Examples section | Code blocks with comments. THIS is where value first appears. But it is buried below two paragraphs that didn't earn attention | Finally engaged -- but 15 seconds in |
| 30-40 | Install section | Clear, concise. Good. | Practical, satisfied |
| 40-50 | Try It section | Wait -- this repeats the Examples section? Same `@security-minion` example appears twice. Confusion. | "Didn't I just read this?" |
| 50-60 | How It Works | Named characters (Gru, Nefario, Lucy, Margo) without context for the naming. "Nine-phase process" is mentioned but not shown | Mental model is incomplete at the 60-second mark |

### 60-Second Scan Verdict: FAILS the target

A first-time evaluator at the 60-second mark understands:
- It is a set of 27 agents for Claude Code (structural fact)
- You can invoke specialists with `@name` (interaction pattern)
- There is an orchestrator called Nefario (structural fact)

A first-time evaluator does NOT understand:
- **Why** 27 coordinated agents are better than writing good CLAUDE.md instructions
- **What problems** this solves that simpler setups do not
- **What governance actually prevents** (concrete examples of caught mistakes)
- **Whether this is production-worthy** or an experiment (the "explores" framing undermines confidence)

The core JTBD for a README evaluator is: "When I find a new tool on GitHub, I want to quickly understand what it gives me that I don't already have, so I can decide whether to invest time in trying it." The current README answers "what is it" but not "why do I need it."

---

## Recommendations

### R1: Lead with the differentiated value, not the structure

The opening paragraph describes the architecture ("a team of domain specialists, an orchestrator, and a governance layer"). Architecture is how it works, not why it matters. The first thing a scanner reads must answer: "What does this give me?"

**Proposed approach**: Open with the job it does for you, framed as outcome, not mechanism. Something in the territory of: "27 domain specialists that review, plan, and execute complex multi-domain tasks in Claude Code -- with governance that catches over-engineering and scope drift before code ships." One sentence. Value-first.

The "explores Agent Teams" framing should be removed or moved far down. It positions the project as experimental, which undermines adoption confidence. If the project works (and the example project suggests it does), present it as a working tool, not a research exploration.

### R2: Add a "What You Get" section BEFORE examples

Progressive disclosure says: give people the reason to care, then show them evidence. Currently the README jumps from "here's what this is" to "here are commands to run" without bridging the gap of "here's what this uniquely provides."

The "What You Get" section should be 4-6 bullet points, each structured as **outcome** (not feature). Following the JTBD pattern: focus on what the user accomplishes, not what the system contains.

Proposed structure for each bullet:
- **Bold outcome statement** -- one line describing what happens for you
- Supporting detail -- one sentence explaining how (the mechanism), kept secondary

Example framing direction:
- "Plans are reviewed before execution" vs. "Six mandatory reviewers catch scope drift and over-engineering before any code runs"
- The second version communicates value. The first communicates mechanism.

Key differentiators to surface (based on my reading of the project):
1. **Governance catches mistakes before execution** -- plans reviewed for intent drift, over-engineering, security gaps
2. **Specialist depth vs. generalist breadth** -- each agent carries deep domain research, not surface-level instructions
3. **Orchestrated multi-domain work** -- issue in, PR out, across multiple specialists
4. **Works on any project** -- install once, available everywhere, zero per-project config
5. **External skill integration** -- nefario discovers and delegates to project-local skills automatically

### R3: Eliminate the Examples/Try It duplication

The Examples section (line 11) and Try It section (line 53) serve the same job: show the user what invocation looks like. Having both creates a "didn't I just read this?" moment -- a textbook cognitive load violation (extraneous load from redundant information).

**Merge into one section.** The Examples section position (early) is correct. The Try It section's additional context (explaining what the specialist returns) is useful but should be folded into the examples, not repeated in a separate section.

### R4: Reorder sections for progressive disclosure

Current order fails the progressive disclosure test. The evaluator's information needs unfold in this order:

1. **What is this?** (1 sentence -- answered)
2. **Why would I want it?** (not answered until deep in the page)
3. **Show me** (examples -- currently too early, before "why")
4. **How do I get it?** (install)
5. **How does it work?** (architecture -- for the now-interested reader)
6. **What are the limits?** (honest limitations -- builds trust)

Proposed section order:
1. Title + one-line value statement
2. **What You Get** (4-6 differentiated outcomes)
3. **Examples** (merged Examples + Try It, trimmed to essentials)
4. **Install** (unchanged, it's already good)
5. **How It Works** (architecture summary for the deeper reader)
6. **Agents** (roster, collapsed -- already uses `<details>`, good)
7. **Documentation** (links to deeper docs)
8. **Current Limitations** (keep -- honesty builds trust)
9. **Contributing** + **License** (unchanged)

### R5: Fix the naming convention cold-start problem

The Despicable Me character names (Gru, Nefario, Lucy, Margo, minions) are charming for existing users but create a cold-start problem for first-time readers. When someone reads "Nefario orchestrates" and "Margo enforces simplicity," they have to learn a naming system before they can understand the architecture.

**Do not remove the names** -- they add personality and memorability. But always pair them with their role on first mention. The current "How It Works" section does this partially ("**Gru** sets technology direction") but the opening paragraph does not.

Rule: Every character name must appear with its functional role in the same phrase, at least on first occurrence in each section.

### R6: Sharpen the "How It Works" section

"Nine-phase process" is mentioned but not shown. This creates a curiosity gap that the README does not resolve (the answer is in docs/using-nefario.md, but readers who haven't clicked yet don't know that). Either:
- Show the phase names in a compact list (progressive disclosure: names now, details in the linked doc), or
- Remove the "nine-phase" claim and just describe the outcome

I recommend the former: a one-line list of phase names gives the reader a mental model of the orchestration sophistication without requiring a click-through.

### R7: Reframe limitations as honest positioning, not apologies

The current limitations section is good -- honesty builds trust. But "mostly vibe-coded" as a limitation reads as self-deprecation that undermines confidence. The badge at the top already signals this playfully. Repeating it in the limitations section with a lowercase, casual tone feels like the project doesn't take itself seriously.

Reframe: the research is real, the architecture is deliberate, and the prompts were iteratively refined with AI assistance. That's a fact, not a limitation.

---

## Proposed Tasks

### Task 1: Rewrite opening paragraph as value-first statement
- **What**: Replace the current structural description + "explores" framing with a single sentence that leads with what the user gets. Remove or relocate the "research preview" framing.
- **Deliverable**: New opening paragraph (1-2 sentences max)
- **Dependencies**: Requires alignment on positioning -- is this a working tool or an experiment? I strongly recommend "working tool" framing.

### Task 2: Create "What You Get" section
- **What**: Write 4-6 bullet points, each leading with an outcome statement (bold) and a one-sentence supporting detail. Place after the opening paragraph and before Examples.
- **Deliverable**: New section, bullet-based, scannable
- **Dependencies**: Depends on Task 1 (positioning alignment). Content should be validated against actual project capabilities -- the product-marketing-minion or software-docs-minion may need to verify claims.

### Task 3: Merge Examples and Try It into single section
- **What**: Combine the two sections. Keep the best examples from each. Remove duplication. Ensure each example demonstrates a different capability (single specialist, orchestrated multi-domain, GitHub issue integration).
- **Deliverable**: Single "Examples" section, 3-4 code blocks with brief context
- **Dependencies**: None

### Task 4: Reorder sections per progressive disclosure model
- **What**: Restructure the README following the order in R4. Move "How It Works" below Install. Move agent roster below "How It Works."
- **Deliverable**: Reordered README
- **Dependencies**: Depends on Tasks 1-3 (new/merged sections must exist first)

### Task 5: Sharpen "How It Works" with phase overview
- **What**: Add a compact list of orchestration phase names to give readers a mental model without requiring click-through. Ensure all character names are paired with functional roles.
- **Deliverable**: Updated "How It Works" section
- **Dependencies**: Verify phase names against current orchestration docs (docs/using-nefario.md)

### Task 6: Reframe limitations section
- **What**: Keep honest limitations but remove self-deprecating tone. Move "vibe-coded" observation out of limitations (the badge already handles it). Ensure remaining limitations are framed as factual constraints, not apologies.
- **Deliverable**: Updated "Current Limitations" section
- **Dependencies**: None

---

## Risks and Concerns

### Risk 1: Over-promising in the "What You Get" section
The biggest risk is writing value claims that exceed what the system actually delivers. Every bullet in "What You Get" must be demonstrably true. If governance catches over-engineering "sometimes" but the README says it "always catches scope drift," trust erodes fast when a user's first experience contradicts the claim. **Mitigation**: Have a technical contributor validate each claim against actual behavior.

### Risk 2: Losing the playful personality
The Despicable Me theming is a genuine differentiator -- it makes the project memorable. Over-professionalizing the README to optimize for scan-time could strip out the personality. **Mitigation**: Keep the character names, keep the badge, keep the tone warm. Just ensure personality doesn't come at the cost of clarity.

### Risk 3: The 60-second target competes with depth
Scannable READMEs risk becoming shallow. Developers evaluating agent frameworks want to trust that there is substance behind the marketing. **Mitigation**: Use progressive disclosure aggressively -- scannable overview up top, depth available via collapsed sections and doc links below. The collapsed agent roster (`<details>`) already does this well.

### Risk 4: "What You Get" becomes a feature list instead of outcome list
The natural tendency is to write "27 specialists, 6 governance reviewers, 9 orchestration phases" -- these are features, not outcomes. Features don't answer "why should I care?" **Mitigation**: Every bullet must pass the "so what?" test. If you can't finish the sentence "...which means you..." with a concrete user benefit, rewrite it.

---

## Additional Agents Needed

- **product-marketing-minion**: Should review and potentially co-author the "What You Get" section. Positioning, differentiation, and value framing are squarely in its domain. My contribution identifies what the section needs from a UX/cognitive perspective; the marketing minion should shape the actual messaging.

The current team is otherwise sufficient. The writing itself (word choice, tone, structure) can be handled by whoever executes the README rewrite, guided by this analysis and the marketing minion's input.
