# UX Strategy Research

Research backing the ux-strategy-minion agent. Focus: UX strategy, usability, simplification, user advocacy.

## Foundational Principles

### Don Norman's Design Philosophy

Don Norman established core principles that define usable design. His six fundamental principles create the foundation for intuitive experiences:

**Visibility**: The more visible an element is, the more likely users will know about it and how to use it. Visibility makes the right actions discoverable.

**Affordances**: Affordances give clues about how to use something. An object's attributes suggest its potential uses. Affordance means "to give a clue" — effective design makes the interface self-explanatory.

**Feedback**: Every interaction requires visible confirmation that the system received and is acting on user input. Feedback closes the interaction loop and prevents uncertainty.

**Constraints**: Design should limit actions to prevent errors. Good constraints guide users toward correct actions and make incorrect ones impossible or obvious.

**Mapping**: Natural mapping between controls and their effects reduces cognitive load. The relationship between controls and results should be intuitive.

**Consistency**: Patterns should remain consistent across the interface. Consistency reduces learning curve and builds transferable mental models.

Norman's human-centered design approach prioritizes human needs, capabilities, and behavior first, then designs to accommodate them. In the AI era, designers must anticipate societal implications and prioritize user empowerment, privacy, and long-term sustainability over short-term gains.

**Sources**:
- [Don Norman's Principles of Design](https://www.interaction-design.org/literature/topics/don-norman)
- [Don Norman's Seven Fundamental Design Principles](https://uxdesign.cc/ux-psychology-principles-seven-fundamental-design-principles-39c420a05f84)

### Steve Krug's Usability Maxims

Steve Krug's "Don't Make Me Think" provides the clearest articulation of usability's core principle: a good interface requires zero thought to use. The title itself is the first law of usability and the ultimate tie-breaker for design decisions.

**Core Insights**:

**Satisficing Over Optimizing**: Users don't search for the best solution — they take the first available option that seems reasonable. Design should optimize for "good enough" discovery, not exhaustive exploration.

**Scanning, Not Reading**: Users scan pages for relevant information and clickable elements rather than reading word-by-word. Design must support rapid scanning through clear visual hierarchy, conventional patterns, and obvious clickability.

**Cognitive Load Accumulation**: Every question mark — every moment of uncertainty — adds cognitive workload. These distractions compound, especially for frequent actions. Eliminate ambiguity relentlessly.

**Clarity Trumps Everything**: Visual hierarchy, conventional patterns, clearly defined areas, obvious clickability, and minimal distractions are the building blocks of clarity.

**Radical Word Reduction**: "Get rid of half the words on each page, then get rid of half of what's left." Brevity isn't just efficiency — it reduces noise and surfaces meaning.

**Navigation and Search**: Unless a site is very small and exceptionally well-organized, every page needs either a search box or a link to search. Users rely on search as a safety net.

**Sources**:
- [Don't Make Me Think: Key Learning Points](https://www.interaction-design.org/literature/article/don-t-make-me-think-key-learning-points-for-ux-design-for-the-web)
- [6 Guiding Principles from Don't Make Me Think](https://medium.com/@yashu02raghuwanshi/6-guiding-principles-from-the-dont-make-me-think-by-steve-krug-8dde3797abe6)

### Jakob Nielsen's 10 Usability Heuristics

Jakob Nielsen's heuristics, developed in 1990 with Rolf Molich and refined in 1994, remain the gold standard for heuristic evaluation. They are broad rules of thumb, not specific guidelines — principles that apply across contexts.

**The 10 Heuristics**:

1. **Visibility of System Status**: Keep users informed about what's happening through timely, appropriate feedback. When users know the system state, they can predict outcomes and determine next steps.

2. **Match Between System and Real World**: Speak the user's language. Use familiar words, phrases, and concepts rather than system-oriented terminology. Follow real-world conventions.

3. **User Control and Freedom**: Users make mistakes. Provide clearly marked "emergency exits" to leave unwanted states without extended dialogues. Support undo and redo.

4. **Consistency and Standards**: Don't make users wonder whether different words, situations, or actions mean the same thing. Follow platform and industry conventions.

5. **Error Prevention**: Better than good error messages is preventing errors in the first place. Eliminate error-prone conditions or check for them and present confirmation options.

6. **Recognition Rather Than Recall**: Minimize memory load by making objects, actions, and options visible. Users shouldn't have to remember information across parts of the interface. Recognition is easier than recall.

7. **Flexibility and Efficiency of Use**: Accelerators — unseen by novices — can speed up expert interactions. Allow users to tailor frequent actions.

8. **Aesthetic and Minimalist Design**: Interfaces shouldn't contain irrelevant or rarely needed information. Every extra unit of information competes with relevant units and diminishes their visibility.

9. **Help Users Recognize, Diagnose, and Recover from Errors**: Error messages should use plain language, precisely indicate the problem, and constructively suggest solutions.

10. **Help and Documentation**: Though it's better if the system doesn't need documentation, it may be necessary. Help should be easy to search, focused on the user's task, list concrete steps, and not be too large.

Heuristic evaluation involves evaluators examining an interface and judging its compliance with these principles. The heuristics haven't changed since 1994 — their longevity proves their fundamental nature.

**Sources**:
- [10 Usability Heuristics for User Interface Design](https://www.nngroup.com/articles/ten-usability-heuristics/)
- [Nielsen's 10 Usability Heuristics](https://blog.uxtweak.com/usability-heuristics/)

## Strategic Frameworks

### Jobs-to-be-Done (JTBD)

Jobs-to-be-Done reframes product design around user outcomes rather than features. The core theory: customers don't buy products — they hire them to accomplish a job. JTBD represents the high-level goals that lead customers to choose your product.

**Key Principles**:

**The Need Behind the Need**: JTBD describes users' real needs, not surface-level feature requests. Understanding the underlying job helps design solutions that more fully and efficiently meet those needs.

**Outcomes Over Features**: Teams that focus on achieving outcomes rather than adding features design better, more effective solutions. Features are means; jobs are ends.

**Life Context, Not Use Context**: JTBD encourages thinking about how products fit into the greater context of users' lives. The user's goal is never "use our software" — it's whatever they're trying to accomplish through it.

**Functional, Social, and Personal Dimensions**: Jobs have functional aspects (the task), social aspects (how it affects others' perception), and personal/emotional aspects (how it makes the user feel).

**Implementation Approach**:

1. Identify jobs users want to accomplish
2. Analyze and define each job
3. List users' desired outcomes for each job
4. Write JTBD statements (format: "When [situation], I want to [motivation], so I can [expected outcome]")
5. Identify the competition (what else could users "hire" for this job?)
6. Evaluate and prioritize opportunities
7. Design solutions to satisfy desired outcomes
8. Track and measure post-launch experience changes

**Sources**:
- [Jobs to Be Done Framework: User Interviews Guide](https://www.userinterviews.com/ux-research-field-guide-chapter/jobs-to-be-done-jtbd-framework)
- [How UX Teams Can Use the JTBD Framework](https://blog.logrocket.com/ux-design/how-ux-teams-can-use-jtbd-framework/)

### Kano Model for Feature Prioritization

The Kano Model, developed by Noriaki Kano in the 1980s, classifies features by their impact on user satisfaction. It transforms feature prioritization from opinion-based debates to a structured, customer-focused process.

**Five Feature Categories**:

**1. Must-Be Features (Basic/Threshold)**
Expected requirements users take for granted. When done well, users are neutral; when missing or poorly executed, users are highly dissatisfied. These are the price of entry — required just to compete. Examples: basic functionality, security, reliability.

**2. Performance Features (Satisfiers)**
Features that yield proportionate satisfaction increases as you invest in them. More is better, following a roughly linear relationship. These differentiate acceptable from excellent products. Examples: speed, capacity, ease of use.

**3. Excitement Features (Delighters)**
Features that yield disproportionate satisfaction increases. If absent, users might not miss them; if present and well-executed, they create dramatic delight. These create competitive advantage and emotional attachment. Examples: unexpected conveniences, innovative capabilities.

**4. Indifferent Features**
Neither good nor bad — they don't affect satisfaction either way. Users aren't aware of these aspects or don't care about them. Investing here wastes resources.

**5. Reverse Features**
Features that actively dissatisfy users. These are things users actively don't want. Example: forcing capital letters in search queries, adding unwanted complexity, mandatory steps that feel pointless.

**Methodology**:

Kano proposes a standardized questionnaire with paired questions for each feature:
- Functional (positive): "How would you feel if this feature is present?"
- Dysfunctional (negative): "How would you feel if this feature is absent?"

Responses map to the five categories. The model reveals which features to prioritize:
1. Prioritize must-be features (deal breakers)
2. Focus on performance features (satisfaction drivers)
3. Add excitement features to wow users
4. Avoid indifferent and reverse features

**Evolution Over Time**: Features migrate categories. Today's excitement features become tomorrow's performance features and eventually must-be features. What delighted users five years ago is now baseline expectation.

**Sources**:
- [The Kano Model: Interaction Design Foundation](https://www.interaction-design.org/literature/article/the-kano-model-a-tool-to-prioritize-the-users-wants-and-desires)
- [Kano Model: What It Is & How to Use It](https://userpilot.com/blog/kano-model/)

## Core Techniques

### Progressive Disclosure

Progressive disclosure is the technique of revealing complexity gradually, exposing only what's needed at each step. It reduces cognitive load by deferring secondary information until users need or request it.

**Benefits**:

Progressive disclosure improves three of usability's five components:
- **Learnability**: New users see only core features, reducing initial overwhelm
- **Efficiency**: Advanced users can access secondary features when needed
- **Error Rate**: Fewer visible options means fewer wrong choices

Additional benefits include simplified interfaces, clearer distinction between primary and secondary features, and reduced learning curves.

**Implementation Patterns**:

**Layered Content**: Present information hierarchically, with the most important content first. Use tabs, accordions, "Show more" links, and scrolling to layer content effectively.

**Secondary Features on Request**: Initially show only the most important options. Disclose specialized features only when users request them. Most users proceed without worrying about added complexity.

**Just-in-Time Information**: Reveal details at the moment they become relevant, not before.

**Critical Challenges**:

The main danger is making incorrect assumptions about users and optimizing based on those assumptions. If you hide the feature users actually need most, progressive disclosure backfires. Additionally, too many layers can overwhelm rather than simplify — each additional interaction adds friction.

**Design Principles**:

- Show the most important options initially
- Offer specialized options on request
- Don't assume you know what's "advanced" — validate with users
- Keep total interaction depth shallow (minimize layers)
- Make it obvious that more options exist

**Sources**:
- [What is Progressive Disclosure?](https://www.interaction-design.org/literature/topics/progressive-disclosure)
- [Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)

### Cognitive Load Theory in UX

Cognitive load theory, developed by educational psychologist John Sweller in the 1980s, is based on the limited capacity of working memory. In UX, cognitive load is the mental effort required to operate a system.

**Working Memory Constraints**:

The average person can hold 7 (plus or minus 2) items in working memory simultaneously. This is a hard biological constraint. When interfaces demand more, users experience cognitive overload — information is lost, errors increase, frustration rises.

**Types of Cognitive Load**:

**Intrinsic Load**: The inherent effort of absorbing new information and tracking goals. This is determined by task complexity and cannot be eliminated, only managed.

**Extraneous Load**: Mental processing that doesn't help users understand content. Examples: inconsistent fonts, unclear navigation, ambiguous labels, unnecessary choices. This is pure waste — design can and must eliminate it.

**Germane Load**: Productive mental effort spent building understanding and mental models. Good design maximizes germane load while minimizing extraneous load.

**Strategies to Reduce Cognitive Load**:

**Progressive Disclosure**: Reveal information as users need it, minimizing initial load.

**Chunking**: Group related information into meaningful units. Phone numbers are chunked (555-1234, not 5551234) because chunks fit working memory better.

**Consistency**: Repeated patterns require less cognitive effort than novel patterns. Users build transferable mental models.

**Clear Visual Hierarchy**: Importance should be visually obvious. Users shouldn't have to figure out what matters.

**Minimize Choices**: Every choice consumes working memory slots. Hick's Law states that decision time increases logarithmically with the number of choices.

**Optimized Response Times**: Fast feedback reduces working memory load. Users don't have to hold as much context while waiting.

**Sources**:
- [Cognitive Load: Laws of UX](https://lawsofux.com/cognitive-load/)
- [Minimize Cognitive Load to Maximize Usability](https://www.nngroup.com/articles/minimize-cognitive-load/)

### User Journey Mapping

User journey mapping visualizes the complete experience users have when trying to accomplish a goal. It provides a holistic view by uncovering moments of frustration and delight throughout a series of interactions.

**Purpose**:

Journey maps help teams understand user motivations, emotions, and challenges at each stage. They create shared understanding across teams and highlight opportunities for improvement. The goal is to see the experience from the user's perspective, not the organization's.

**Key Components**:

**Actor**: The user or persona whose journey is being mapped. Journey maps are typically persona-specific.

**Scenario and Expectations**: The specific goal or task the actor wants to accomplish, plus what they expect will happen.

**Journey Phases**: High-level stages in the journey (e.g., Discover, Evaluate, Purchase, Use, Support).

**Actions**: Actual behaviors and steps users take during each phase. These are observable, concrete actions.

**Mindsets**: Users' thoughts, questions, motivations, and information needs at each stage. What are they thinking? What questions do they have?

**Emotions**: The emotional "ups" and "downs" of the experience, typically plotted as a line across phases. Emotional highs and lows reveal critical moments.

**Opportunities**: Insights gained from mapping that speak to how the experience can be optimized. These flow directly from pain points and emotional lows.

**Types of Journey Maps**:

**Current-State Maps**: Document existing interactions. Show what's happening now. Pinpoint how to enhance the current experience.

**Future-State Maps**: Imagine the ideal experience you want customers to have. Help plan improvements and align on goals.

**Day-in-the-Life Maps**: Broaden scope beyond product interactions to show the user's full context and where your product fits in their life.

**Benefits**:

Journey maps create shared vision, making information memorable and concise. They become the basis for decision-making and prioritization. They shift focus from internal operations to customer experience. They identify pain points (confusing navigation, slow processes) and opportunities (moments to delight, unmet needs).

**Sources**:
- [Journey Mapping 101](https://www.nngroup.com/articles/journey-mapping-101/)
- [Customer Journey Map: Interaction Design Foundation](https://www.interaction-design.org/literature/topics/customer-journey-map)

## Philosophical Approaches

### Invisible Computing and Calm Technology

Mark Weiser, widely considered the father of ubiquitous computing, articulated the philosophy of "calm technology" in 1991. His vision: technology that recedes into the background rather than demanding the foreground.

**Core Philosophy**:

Weiser and John Seely Brown define calm technology as "that which informs but doesn't demand our focus or attention." The goal is technology that serves human needs without colonizing human consciousness. Technology should expand the unconscious, not dominate the conscious.

**Three Waves of Computing**:

1. **First Wave (1940-1980)**: Many people served one computer
2. **Second Wave (1980-2000)**: One person and one computer in uneasy symbiosis
3. **Third Wave (2000+)**: Many computers serving each person everywhere

The third wave requires invisible computing — technology that vanishes into the background, which is a consequence of human psychology rather than technology itself.

**Design Principles for Calm Technology**:

**Peripheral Awareness**: Information should be available in the periphery, moving to the center only when needed. Don't interrupt — inform.

**Amplify the Best of Technology and Humanity**: Technology should enhance human capabilities without replacing human judgment.

**Communicate Without Overwhelming**: Calm technology provides helpful information from sources that blend into the environment, almost as if they weren't there.

**Modern Application**:

In the AI era, this philosophy manifests as interfaces that do the work without showing the work. The best AI products feel simple because the complexity is hidden. Users accomplish their goals without thinking about the technology enabling them.

**Sources**:
- [Calm Technology](https://calmtech.com/papers/computer-for-the-21st-century)
- [What is Calm Technology?](https://bootcamp.uxdesign.cc/what-is-calm-technology-45fe0266251c)

### Conversational UI Patterns for AI

As of 2026, conversational AI has evolved beyond simple chatbots into context-aware, multimodal systems. The design challenge is creating interfaces that combine AI capabilities with human-centered principles.

**Key Shifts in 2026**:

**Beyond Chat-First**: Pure chat interfaces aren't always optimal. The future lies in reimagining UI patterns for human-AI collaboration. Dynamic blocks, governor mechanisms, and milestone markers represent interfaces that combine AI capabilities with human-centered design.

**Multimodal Integration**: Text, voice, and visual cues are no longer separate channels — they inform one continuous interaction. Strong conversational AI design focuses on how context, timing, and modality work together to support user intent.

**Context Persistence**: Conversational AI maintains context across interactions, learning from previous exchanges. This reduces repetition and supports more natural, efficient interactions.

**Privacy and Edge Computing**: On-device chatbots enable privacy-preserving AI. Customer data never leaves the device, reducing leak risk and strengthening compliance with GDPR and HIPAA.

**Design Principles**:

**Align to User Expectations**: UX and UI must match users' expectations, needs, and emotional state. Conversational interfaces are non-linear and unpredictable — design must accommodate this.

**Support Intent, Not Just Input**: The goal isn't replicating human conversation but supporting user intent through the most effective interface pattern (which may not be chat).

**Rapid Iteration**: Vibe coding (prompt-driven development) enables teams to design conversational flows in natural language, test instantly, and iterate rapidly.

**Measure Experience Outcomes**: Success metrics should focus on effort reduction and resolution quality, not just automation rates.

**Sources**:
- [Beyond Chat: How AI is Transforming UI Design Patterns](https://artium.ai/insights/beyond-chat-how-ai-is-transforming-ui-design-patterns)
- [AI Chatbot UX: 2026's Top Design Best Practices](https://www.letsgroto.com/blog/ux-best-practices-for-ai-chatbots)

## Practical Methodologies

### Simplification Audit Methodology

A UX audit evaluates an interface to identify improvement opportunities. Simplification audits specifically target complexity reduction — finding where the interface can be simpler, clearer, and more direct.

**Audit Approach**:

**Multi-Source Data**: Combine expert reviews, analytics, user feedback, and competitor analysis for comprehensive evaluation. Expert judgment plus real user data yields the clearest picture.

**Focus Areas**:

1. **Cognitive Complexity**: Overwhelming layouts, information overload, unclear priorities
2. **Visual Complexity**: Clutter, inconsistency, poor visual hierarchy
3. **Interaction Complexity**: Convoluted workflows, unclear calls-to-action, unnecessary steps

**Reduction Strategies**:

**Remove Elements**: Thoughtfully remove elements to reduce the system to essentials without sacrificing usability. When in doubt, remove secondary information, infrequently used controls, and distracting styles.

**Reduce Choice**: Balance user pathways through careful consideration of presented choices. Every choice adds cognitive load.

**Challenge Existing Steps**: Question whether each step in an experience is truly necessary. Many flows accumulate steps over time without justification.

**Timeline**: A standard UX audit takes 3-4 weeks depending on product complexity and issue depth.

**Audit Outputs**:

- Prioritized list of usability issues
- Heuristics-based recommendations
- User-centric enhancement suggestions
- Data-driven justification for changes

**Sources**:
- [Simplify Your UX Through Reduction](https://www.uxmatters.com/mt/archives/2015/07/simplify-your-ux-through-reduction.php)
- [UX Audit: How to Improve Your Product](https://adamfard.com/blog/ux-audit)

### Friction Logging and Removal

Friction logs are systematic records of user challenges within a product. Each entry highlights a specific interaction (or failed interaction) that signals a friction point — anything from a confusing onboarding screen to an underused feature.

**What Friction Is**:

Friction is anything that prevents users from completing tasks easily. It includes cognitive effort, unnecessary steps, unclear feedback, confusing UI, and anything that makes users think "why is this so hard?"

**Friction Logging Process**:

**Step Through User Flows**: Navigate the product as a new user would, documenting every moment of hesitation, confusion, or extra effort.

**Record Specific Interactions**: Note the exact action attempted, the problem encountered, and the mental effort required.

**Capture User Feedback**: Use micro-surveys to gather real-time feedback without disrupting the flow. In-app surveys build empathy and dig deeper into user sentiment.

**Analyze Session Data**: Monitor session recordings, heatmaps, and in-app events to identify friction points objectively. Users reveal friction through behavior even when they don't report it.

**Removal Techniques**:

**Eliminate Unnecessary Steps**: Challenge every step. If a step doesn't directly contribute to the user's goal, remove it.

**Reduce Interaction Costs**: If a dropdown has only a few options, use radio buttons instead. Auto-select the first input field on a page. Make common paths as frictionless as possible.

**Provide Clear Feedback**: Users should never wonder "did that work?" Immediate, clear feedback eliminates uncertainty friction.

**Simplify and Condense**: Shorter flows with inline guidance reduce friction more effectively than long flows with extensive help documentation.

**Impact**:

Friction-free experiences correlate directly with customer satisfaction. Users complete tasks more easily, with less cognitive effort and fewer distractions. Reducing friction during onboarding notably boosts conversion rates.

**Sources**:
- [Friction Logs: Identify and Overcome Friction Points](https://www.chameleon.io/blog/friction-logs)
- [Friction Log in SaaS: Step-by-Step Guide](https://userpilot.com/blog/friction-log/)

## Summary

UX strategy is the practice of understanding what users are trying to accomplish and designing the simplest possible path to that outcome. It sits at the intersection of user needs, business goals, and technical feasibility, advocating relentlessly for simplicity.

The foundational principle across all methodologies: **reduce**. Reduce cognitive load, reduce steps, reduce choices, reduce visual noise, reduce friction. Every feature added is a tax on every user. The best interface is no interface. When in doubt, remove.

Strategic frameworks like JTBD and Kano help prioritize what to build by understanding user needs and satisfaction drivers. Techniques like progressive disclosure and journey mapping help shape how to build it. Philosophical approaches like calm technology and invisible computing provide the guiding vision: technology should serve, not show.

In the AI era, UX strategy takes on new urgency. AI can create infinitely complex capabilities — UX strategy ensures those capabilities manifest as simple, intuitive experiences. The technology's power should be felt, not seen.
