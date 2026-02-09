# Software Documentation Research

Research backing the software-docs-minion agent system prompt. Focus: technical and architectural documentation for developers, not end-user documentation.

## C4 Model for Software Architecture

The C4 model provides a hierarchical approach to documenting software architecture through four levels of abstraction.

### The Four Levels

**Context Diagram (Level 1)**: The highest-level view showing the system as a single box surrounded by users and external systems. Answers "what does this system do and who uses it?" Essential for stakeholder communication.

**Container Diagram (Level 2)**: Shows how the system is composed of applications, databases, and services. Reveals technology choices and communication patterns between containers. Note: C4 "containers" are deployment units, not Docker containers specifically.

**Component Diagram (Level 3)**: Zooms into a single container to show its internal components. For a web application, this might show controllers, services, and repositories and their relationships.

**Code Diagram (Level 4)**: Class-level detail. Rarely used in practice since code is often self-documenting at this level. Reserved for highly regulated environments or complex legacy systems.

### When to Use C4

You don't need all four levels for every system. For most projects, Context + Container diagrams suffice. Component diagrams add value for complex services. Code diagrams are optional.

**Sources**: [C4 model](https://c4model.com/), [C4 model diagrams](https://c4model.com/diagrams), [Miro C4 guide](https://miro.com/diagramming/c4-model-for-software-architecture/)

## Mermaid Diagram Syntax

Mermaid enables diagram-as-code, keeping diagrams version-controlled alongside code.

### Core Diagram Types

**Flowcharts**: Nodes (shapes) connected by edges (arrows). Useful for process flows, decision trees, algorithm visualization. Gotcha: avoid using "end" in lowercase in node labels (breaks parsing).

**Sequence Diagrams**: Show interactions between actors/systems over time. Essential for documenting API flows, authentication sequences, distributed system communication.

**Class Diagrams**: Model object-oriented structure. Mermaid distinguishes methods (with parentheses) from attributes (without). Supports inheritance, composition, multiplicity notation.

**C4 Diagrams**: Experimental support in Mermaid. Syntax compatible with PlantUML C4 diagrams. Layout is manual (order of statements affects positioning).

**State Diagrams**: Document state machines and lifecycle transitions.

**ER Diagrams**: Entity-relationship modeling for database schema documentation.

### Best Practices

All diagrams start with a type declaration. Comments use `%%` prefix. Use descriptive node labels. For large/complex diagrams, consider the elk renderer (available since Mermaid 9.4).

**Sources**: [Mermaid syntax reference](https://mermaid.js.org/intro/syntax-reference.html), [Mermaid flowcharts](https://mermaid.js.org/syntax/flowchart.html), [Mermaid sequence diagrams](https://mermaid.ai/open-source/syntax/sequenceDiagram.html), [Mermaid C4 diagrams](https://mermaid.ai/open-source/syntax/c4.html)

## Architecture Decision Records (ADRs)

ADRs document the "why" behind architectural choices. Introduced by Michael Nygard in 2011.

### Nygard Template Format

**Title**: Short, descriptive name (e.g., "Use PostgreSQL for primary datastore")

**Status**: proposed | accepted | deprecated | superseded. Status creates a lifecycle. Deprecated/superseded ADRs reference their replacement.

**Context**: What problem led to this decision? What constraints exist? What options were considered? This is where the reasoning lives.

**Decision**: The actual choice made. Clear, concise statement.

**Consequences**: All results of this decision—positive, negative, and neutral. Consequences affect future work. Don't hide the downsides.

### ADR Management

ADRs live in the repository, typically under `docs/adr/` or `adr/`. Use lightweight formats (Markdown). Number sequentially (0001-use-postgresql.md). Never delete ADRs; deprecate them instead.

An ADR is immutable once accepted. If context changes, write a new ADR that supersedes the old one.

**Sources**: [ADR templates](https://adr.github.io/adr-templates/), [Michael Nygard ADR template](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/locales/en/templates/decision-record-template-by-michael-nygard/index.md), [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)

## Documentation Minimalism

Minimalism is "just enough, just in time" documentation. Write only what users need, nothing more.

### Core Principles

**Document the WHY, not the WHAT**: Code is self-documenting for "what" when well-written. Documentation should explain reasoning, constraints, tradeoffs—things code cannot express.

**Task-Oriented**: Users need to solve problems, not learn your entire system. Structure documentation around tasks ("how do I...?") rather than system structure.

**Just-In-Time**: Provide information when needed, not upfront. Progressive disclosure reduces cognitive load.

### What NOT to Do

Minimalism is not cutting corners. Advanced users (developers, API consumers) need conceptual information. Don't eliminate necessary context. Don't confuse minimalism with under-resourcing.

Avoid redundancy. Never duplicate information across documents. Single source of truth.

### Long-Term Benefits

Minimal documentation is easier to maintain. Less surface area means fewer stale docs. Translation and localization costs decrease. Teams can pivot faster.

**Sources**: [Minimalism in technical writing - Archbee](https://www.archbee.com/blog/minimalism-in-technical-writing), [ClickHelp minimalism guide](https://clickhelp.com/clickhelp-technical-writing-blog/minimalism-in-technical-documentation/), [Opensource.com on minimalism](https://opensource.com/article/17/10/adopting-minimalism-your-docs)

## Docs-as-Code Workflow

Treat documentation like code: version control, review process, automated builds, CI/CD deployment.

### Core Workflow

Documentation lives in Git alongside code. Markdown is the standard format. Static site generators (Jekyll, Hugo, MkDocs, Docusaurus) convert Markdown to HTML. CI/CD pipelines (GitHub Actions, GitLab CI) build and deploy on commit.

### Benefits

Version control tracks every change. Pull request workflow enables review. Developers use familiar tools. Documentation stays in sync with code. Branch-based workflows support feature documentation.

### Tools in 2026

**Fern**: Git-native, CLI tooling, automated CI/CD, API references, SDK generation.

**Mintlify**: GitHub/GitLab sync, automatic builds, visual editor, OpenAPI integration.

**ReadMe**: rdme CLI, GitHub Actions support, OpenAPI sync.

Static site generators remain popular: MkDocs for simplicity, Docusaurus for React-based sites, Hugo for speed.

**Sources**: [Fern docs-as-code](https://buildwithfern.com/post/docs-as-code-solutions-api-teams), [GitBook on docs-as-code](https://www.gitbook.com/blog/what-is-docs-as-code), [Building a Markdown-based documentation system](https://medium.com/@rosgluk/building-a-markdown-based-documentation-system-72bef3cb1db3)

## OpenAPI Documentation Patterns

OpenAPI (formerly Swagger) is the standard for REST API documentation.

### Best Practices

**Design-First Approach**: Write the OpenAPI spec before code. Benefits include early collaboration, mock servers for testing, and automated validation.

**Single Source of Truth**: OpenAPI spec is authoritative. Generate code and documentation from the spec, not the reverse.

**Real Examples**: Include real request/response examples for every endpoint. Developers learn by example.

**Organization**: Use tags to group related endpoints. Split large specs into multiple files using `$ref` for easier navigation. Follow URL hierarchy in file structure.

**Automation**: Generate documentation as part of CI/CD. Keep specs and code in sync through automated checks.

### Generation Tools

**Swagger UI**: Original OpenAPI documentation generator. Most widely used.

**ReDoc**: Focus on readability with multi-column layouts.

**OpenAPI Generator**: Generates server stubs and client SDKs in multiple languages from OpenAPI specs.

Documentation generation tools create human-readable docs from machine-readable OpenAPI specs. Code generation tools create server/client code from specs. Both approaches keep specifications as the single source of truth.

**Sources**: [OpenAPI best practices](https://learn.openapis.org/best-practices.html), [OpenAPI tools](https://openapi.tools/), [Stoplight API documentation guide](https://stoplight.io/api-documentation-guide)

## README Structure and Best Practices

The README is the front door to your project. It should enable a new developer to become productive quickly.

### Essential Sections

**What**: Brief description of what the project does and what problem it solves.

**Why**: Why does this project exist? What gap does it fill?

**Quick Start**: Get from zero to "hello world" in minutes. Minimal steps.

**Installation**: Detailed setup instructions. Include prerequisites.

**Usage**: Common use cases with examples. Task-oriented.

**Contributing**: How to contribute (or link to CONTRIBUTING.md).

**License**: License information (or link to LICENSE file).

### Best Practices

Keep it concise. Use headers, bullet points, and images. Avoid jargon. Short paragraphs. If the README grows too long, split into separate documents and link them.

Ask new developers to follow your README during onboarding, then discuss pain points and iterate.

### Onboarding Focus

README files are critical for onboarding. New contributors should understand project structure, coding practices, and contribution requirements from the README.

Time-to-first-contribution matters. A good README minimizes time-to-first-success.

**Sources**: [GitHub README best practices](https://github.com/jehna/readme-best-practices), [Creating the perfect README](https://dev.to/github/how-to-create-the-perfect-readme-for-your-open-source-project-1k69), [README files for internal projects](https://blogs.incyclesoftware.com/readme-files-for-internal-projects)

## Code-Level Documentation Guidelines

Code comments are documentation's last resort. Use them wisely.

### When to Document

**Document the WHY**: Explain reasoning, constraints, tradeoffs, non-obvious decisions. Why this approach? Why not alternatives?

**Document constraints**: Pre-conditions, post-conditions, invariants, concurrency requirements, performance characteristics.

**Document gotchas**: Surprising behavior, edge cases, subtle bugs that were fixed.

### When NOT to Document

**Don't document the WHAT**: If code clearly shows what it does, comments are redundant. Good naming makes "what" self-evident.

**Don't state the obvious**: `count++` does not need `// adds 1 to count`.

**Don't compensate for bad code**: If code is hard to understand without comments, refactor the code. Break it into smaller, clearer functions.

### Structured Documentation

**Docstrings**: Structured comments for classes, functions, modules. Describe purpose, parameters, return values, exceptions, examples. Language-specific formats (JSDoc, Python docstrings, Javadoc).

Docstrings enable automated documentation generation and IDE tooltips. They're not comments—they're structured metadata.

### Balance

Over-documentation adds noise. Under-documentation creates confusion. The right balance: document the "why" and let well-named code document the "what."

**Sources**: [Code documentation best practices - Codacy](https://blog.codacy.com/code-documentation), [Google documentation best practices](https://google.github.io/styleguide/docguide/best_practices.html), [Code comments vs documentation - Swimm](https://swimm.io/blog/code-comments-vs-documentation)

## Diagram-Driven Architecture Communication

Visual communication reduces ambiguity and increases shared understanding.

### Why Diagrams Matter

Architecture diagrams are visual tools that distill complex technical concepts into intuitive visuals anyone can understand. They provide a common language for technical and non-technical stakeholders.

Diagrams align project goals across teams, departments, and stakeholders. They document decisions, guide implementation, and onboard new team members.

### Types of Architecture Diagrams

**System Context Diagrams**: High-level view showing the system, its users, and external systems. Answers "what does this system do?"

**System Architecture Diagrams**: Show components and their communication patterns. Document how pieces fit together.

**Component Diagrams**: Replace generic blocks with specific technologies and integration points. Show concrete technology choices.

**Deployment Diagrams**: Show where components run (servers, containers, cloud services). Document infrastructure.

### Best Practices

Use consistent notation. Label everything clearly. Show relationships explicitly. Update diagrams when architecture changes—outdated diagrams are worse than no diagrams.

Diagrams should be version-controlled alongside code. Use text-based diagram formats (Mermaid, PlantUML) to enable diffs and pull request reviews.

**Sources**: [AWS architecture diagramming](https://aws.amazon.com/what-is/architecture-diagramming/), [vFunction architecture diagram guide](https://vfunction.com/blog/architecture-diagram-guide/), [Medium: writing good architecture diagrams](https://medium.com/@jancalve/writing-good-software-architecture-diagrams-15c51eca4ce7)

## Documentation-Driven Development

Write the documentation before the code. Also called design-first or spec-first development.

### Core Concept

Define the API contract (or system behavior) in documentation form first. Then implement to match the documentation.

For APIs, this means writing the OpenAPI specification before writing endpoint handlers. For features, this means writing the user-facing documentation before writing the implementation.

### Benefits

**Early collaboration**: Frontend and backend teams can work in parallel using mock APIs.

**Consistency**: Easier to enforce when the contract is agreed upon first.

**Validation**: Documentation serves as acceptance criteria. If the implementation doesn't match the docs, one of them is wrong.

**Automated tooling**: Generate code, tests, and mocks from specifications.

### Workflow

1. Write the specification or documentation (OpenAPI spec, API contract, feature docs)
2. Review and agree on the contract with stakeholders
3. Generate mocks for testing (optional)
4. Implement to match the specification
5. Write tests that validate the implementation matches the specification
6. Keep spec and implementation in sync through automated checks

**Sources**: [Spec-driven API development - Apideck](https://www.apideck.com/blog/spec-driven-development-part-1), [API design-first approach - APIs You Won't Hate](https://apisyouwonthate.com/blog/a-developers-guide-to-api-design-first/), [Documentation-Driven Development](https://gist.github.com/zsup/9434452)

## Developer Onboarding Documentation Patterns

Structured onboarding documentation reduces time-to-productivity by 40%.

### Four-Phase Onboarding

**Day 1**: Environment setup, access credentials, accounts. Step-by-step instructions for local development environment. Standardize setup across the team to prevent wasted time.

**Week 1**: Architecture overview, codebase tour, workflow introduction. Provide an annotated code tour showing patterns, conventions, and common pitfalls.

**Weeks 2-3**: First real project. Right-sized: not too open-ended (overwhelming), not too trivial (busywork). Should deliver real value while building skills.

**Week 4**: Full independence. Developer can navigate codebase, make changes, submit PRs without constant guidance.

### Essential Documentation Types

**Getting Started Guide**: Environment setup, running tests, building the project. Step-by-step.

**Architecture & Design Docs**: How the system is constructed. C4 diagrams, component descriptions, technology choices.

**Code Tour**: Annotated overview of codebase structure. Where to find things. Naming conventions. Key abstractions.

**Code Samples**: Examples showing team standards, best practices, architectural patterns. Guide newcomers to produce consistent code.

### Key Principle

Iterate the documentation with new hires. Ask them to use the README/onboarding docs, then discuss pain points and update. Onboarding docs should evolve based on real onboarding experiences.

**Sources**: [Developer onboarding guide template - River](https://rivereditor.com/blogs/write-developer-onboarding-guide-30-days), [Developer onboarding documentation must-haves](https://www.multiplayer.app/blog/developer-onboarding-documentation/), [Developer onboarding best practices - Cortex](https://www.cortex.io/post/developer-onboarding-guide)

## Summary of Key Patterns

1. **C4 Model**: Hierarchical architecture documentation (Context, Container, Component, Code). Most projects need only Context + Container.

2. **Mermaid Diagrams**: Diagram-as-code for version control. Flowchart, sequence, class, C4, state, ER diagrams.

3. **ADRs**: Document architectural decisions with status, context, decision, consequences. Immutable once accepted.

4. **Minimalism**: Document the "why," not the "what." Task-oriented. Just-in-time.

5. **Docs-as-Code**: Version control, Markdown, CI/CD, review process. Documentation is code.

6. **OpenAPI**: Design-first API documentation. Single source of truth. Real examples. Automated generation.

7. **README**: Front door to the project. Quick start, installation, usage. Enable time-to-first-success.

8. **Code Comments**: Document "why," not "what." Use docstrings for structured metadata. Refactor instead of commenting obvious code.

9. **Diagrams**: Visual communication for architecture. Version-controlled, text-based formats. Update with code.

10. **Onboarding**: Four-phase approach. Getting started guide, architecture docs, code tour, code samples. Iterate with new hires.
