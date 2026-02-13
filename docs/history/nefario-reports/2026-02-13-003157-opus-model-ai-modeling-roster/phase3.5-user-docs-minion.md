ADVISE

- [user-docs]: CLAUDE.md template location may not be discoverable enough
  SCOPE: Task 5, docs/claudemd-template.md file location
  CHANGE: Add explicit discovery mechanisms -- link from docs/architecture.md (the hub document), add entry to README's docs section if present, or consider docs/guides/ subdirectory for user-facing templates
  WHY: Users configuring deployment preferences need to discover this template exists. Placing it in docs/ alongside architecture documentation may bury it among developer-oriented architecture files. Without a clear path from "I want to configure deployment" to "here's the template", users will not know the Deployment section exists.
  TASK: Task 5

- [user-docs]: Prose format may be too flexible for consistency across target projects
  SCOPE: Task 5, template format design (prose vs. structured)
  CHANGE: Consider adding structured comment guidance for machine-parseable signals while keeping prose primary. Example: `<!-- deployment-platform: cloudflare-pages -->` followed by prose explanation. This preserves human readability while enabling future tooling.
  WHY: Pure prose format means every project will phrase deployment preferences differently. Agents must interpret varied natural language. While LLMs handle this well, structured optional signals would improve routing reliability for nefario and reduce ambiguity in lucy's consistency checks without sacrificing readability.
  TASK: Task 5

- [user-docs]: Default behavior explanation needs prominence
  SCOPE: Task 5, template structure and progressive disclosure
  CHANGE: Place the "When to omit this section" guidance at the TOP of the template document, before the template itself. Current design buries it in HTML comments within the template.
  WHY: Users often copy-paste templates without reading surrounding docs. The most important message is "you probably don't need this section" -- that should be the first thing users see, not embedded in HTML comments. Following progressive disclosure principles: essential information (when NOT to use this) before details (how to use it).
  TASK: Task 5

- [user-docs]: Three examples may not cover edge cases users will encounter
  SCOPE: Task 5, template examples
  CHANGE: Add a fourth example covering hybrid scenarios (e.g., "We have Docker Compose for local dev but deploy to managed platforms" or "We run stateful services on VPS, stateless APIs on serverless"). Also add an example with multiple constraints (budget + team experience + existing infra).
  WHY: Real projects often have mixed infrastructure. Pure categories (serverless-only, self-managed-only, no-preference) do not represent common messy reality where teams have partial existing infrastructure or want different strategies for different components. Users seeing only pure examples may not recognize the template applies to their situation.
  TASK: Task 5
