# User Documentation Research

Research backing the user-docs-minion agent system prompt. This document covers best practices for end-user documentation, tutorials, help content, and user-facing technical communication.

## The Divio Documentation System

The [Divio documentation system](https://docs.divio.com/documentation-system/) provides a comprehensive framework for organizing documentation into four distinct types, each serving a different user need:

### Four Documentation Types

**Tutorials**: Learning-oriented documentation for beginners. Must be useful for the beginner, easy to follow, meaningful, extremely robust, and kept up-to-date. Tutorials guide users through a series of steps to complete a project, helping them gain basic competence.

**How-to Guides**: Task-oriented documentation that helps users achieve specific goals. Should allow for slightly different ways of doing the same thing with just enough flexibility that users can see how it applies to slightly different examples. Users enter with a goal and the guide helps them achieve it.

**Technical Reference**: Information-oriented documentation describing the system. The only job is to describe as clearly and completely as possible. Anything else (explanation, discussion, instruction, speculation, opinion) is a distraction that makes reference harder to use and maintain.

**Explanation**: Understanding-oriented documentation that clarifies concepts and provides background. Helps users develop a deeper understanding of the system.

### Key Principles

Documentation must be explicitly structured around these four types, kept separate and distinct. This division makes it obvious to both author and reader what material goes where. Each type serves a different purpose and requires a different approach to creation. Understanding these implications helps improve documentation quality and maintainability.

**Sources**: [Divio Documentation System Introduction](https://docs.divio.com/documentation-system/introduction/), [About Divio Documentation](https://docs.divio.com/documentation-system/)

## Progressive Disclosure

[Progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/) is a fundamental information architecture pattern for managing complexity in user documentation.

### Core Concept

Introduced by Jakob Nielsen in 1995, progressive disclosure reveals complexity gradually rather than all at once. Present users with the most important information first, with the option to explore more content for those who need it.

### Benefits

- Satisfies requirements for both power and simplicity
- Reduces cognitive load and prevents user overwhelm
- Allows advanced users to access detailed information without cluttering the interface for beginners
- Increases task completion rates by focusing users on immediate needs

### Implementation Patterns

**Accordions**: Give users control over when and if they need content. Particularly helpful for presenting lots of content like FAQs. Users can expand only the sections relevant to their needs.

**Tabs**: Organize content into categories so users can choose what they need when they need it. Each tab represents a distinct context or use case.

**Dropdown Menus**: Keep UIs uncluttered by hiding long lists until needed. Users can focus on current tasks without distraction from irrelevant content.

### Design Considerations

A single secondary screen is typically sufficient for each instance of progressive disclosure. Multiple layers can confuse users and make finding "buried" functionality hard. Balance accessibility with simplicity.

**Sources**: [Progressive Disclosure - Nielsen Norman Group](https://www.nngroup.com/articles/progressive-disclosure/), [Progressive Disclosure - UXPin](https://www.uxpin.com/studio/blog/what-is-progressive-disclosure/), [Progressive Disclosure - LogRocket](https://blog.logrocket.com/ux-design/progressive-disclosure-ux-types-use-cases/)

## Task-Oriented Documentation

Task-oriented documentation structures content around user goals rather than system features. Users consult documentation to solve problems or complete tasks, not to read for enjoyment.

### Framework and Structure

The [Diátaxis framework](https://gitbook.com/docs/guides/docs-best-practices/documentation-structure-tips) provides a systematic approach organizing content into tutorials, how-to guides, reference, and explanation. Within this framework, how-to guides are goal-oriented: users enter with a goal and the guide helps them achieve it.

### Content Organization

**User Mental Model**: Structure your table of contents to mirror the user's mental model and workflow rather than your product's technical architecture. Use a professional taxonomy that is task-oriented, guiding users from broad onboarding concepts to specific, granular functions.

**Logical Progression**: Organize content logically by starting with an introduction, followed by basic steps, then moving to advanced topics. Include a table of contents and index for easy navigation.

**Templates for Consistency**: Use templates for consistent on-page design. Templates lock in structure and consistency, making documentation easier to maintain and scan.

### Task Analysis

Task-oriented writing requires comprehensive task analysis before writing begins. Technical writers should interview users and observe what they do through contextual inquiry. Tasks can be discovered by reviewing voice-of-customer material from marketing and customer logs from technical support.

### Writing Approach

Focus on practical guidance that helps users achieve specific goals. Each guide should clearly state the goal, prerequisites, steps, and expected outcome. Use imperative mood (commands) for steps: "Click Save" rather than "You can click Save."

**Sources**: [GitBook Documentation Structure](https://gitbook.com/docs/guides/docs-best-practices/documentation-structure-tips), [GitHub Developer Documentation Guide](https://github.blog/developer-skills/documentation-done-right-a-developers-guide/), [ClickLearn End User Documentation](https://www.clicklearn.com/blog/user-documentation/)

## Readability and Plain Language

Readability determines whether users can understand and act on documentation. Plain language makes content accessible to the broadest possible audience.

### Readability Metrics

**Definition**: Readability scores are numerical measures evaluating how easy or difficult text is to read, considering factors like sentence length, word complexity, and syllable count. Common metrics include Flesch-Kincaid Reading Ease, Flesch-Kincaid Grade Level, and SMOG Index.

**Sentence Length Impact**: Shortening sentences can have the biggest impact on readability scores and ease of reading. A common factor across readability formulas is sentence length.

**Limitations**: Most readability formulas were not created for technical documents. They assume short words are always better, which isn't true for technical terminology. Most of what makes a document usable is not included in readability formulas.

### Plain Language Principles

Plain language operates on four core principles:

**Clarity**: Eliminate ambiguity. Say exactly what you mean using concrete, specific language.

**Conciseness**: Use no more words than necessary. Every word should serve a purpose.

**Organization**: Present information in a logical sequence that matches user needs and mental models.

**Appropriateness**: Tailor content to the audience's knowledge level and needs. Don't write to the most technical user if most users are beginners.

### Technical Writing Guidelines

- Use simple language whenever possible
- Define complex language when it must be used
- Choose strong active verbs over passive constructions
- Use short sentences on average (aim for 15-20 words)
- Break up long paragraphs (3-5 sentences is ideal)
- Use lists for steps or multiple items
- Write in second person ("you") to engage readers directly

**Sources**: [Readable - Readability for Technical Writers](https://readable.com/blog/readability-for-technical-writers/), [ClickHelp Readability Metrics](https://clickhelp.com/clickhelp-technical-writing-blog/readability-metrics-explained-how-to-measure-and-improve-your-texts-clarity/), [ClickHelp Plain Language Basics](https://clickhelp.com/clickhelp-technical-writing-blog/basics-of-plain-language-in-technical-documentation/)

## Troubleshooting Guides

Troubleshooting guides are self-service resources that help users resolve problems without contacting support. According to [Zendesk data](https://dev.to/elliot_brenya/how-to-write-a-troubleshooting-guide-that-actually-helps-users-2hh9), 91% of customers want to use a knowledge base if it's available and fits their needs.

### Structure and Format

**Decision Trees**: Visual flows that guide users through diagnostic questions to identify their specific issue and solution.

**Step-by-Step Instructions**: Clear, sequential steps to resolve each problem. Include prerequisites, expected outcomes, and what to do if the steps don't work.

**FAQs**: Answers to common questions organized by topic or frequency. Best for quick, simple issues with straightforward answers.

**Symptom-Based Organization**: Group problems by what users experience, not by technical cause. Users search for "error message X" not "database connection failure."

### Content Best Practices

**Problem Description**: Clearly describe the symptom or error message users will see. Use the exact language from error messages.

**Likely Causes**: Outline the most common reasons for the issue, ordered by probability. This helps users understand the problem.

**Solutions with Branching**: Provide step-by-step solutions with branching paths for different scenarios. "If X happens, try Y. If Z happens instead, try W."

**Visual Aids**: Include screenshots or diagrams where helpful. Visual cues make technical steps clearer and reduce confusion.

**Clear, Concise Language**: Avoid jargon. Write for the user's level of technical understanding, not for developers.

### Empowerment and Efficiency

Troubleshooting guides empower customers to solve problems independently, reducing support ticket volume and wait times. They also provide consistency in how issues are resolved across the user base.

**Sources**: [How to Write Troubleshooting Guides](https://dev.to/elliot_brenya/how-to-write-a-troubleshooting-guide-that-actually-helps-users-2hh9), [Archbee Troubleshooting Guide](https://www.archbee.com/blog/troubleshooting-guide), [Document360 Troubleshooting Guide](https://document360.com/blog/troubleshooting-guide/)

## Release Notes and Changelogs

Release notes communicate product changes to end users in an accessible, engaging way. They differ from changelogs (technical version history) by focusing on user impact and value.

### Know Your Audience

Understanding who reads release notes guides tone, language, and content decisions. End-users need straightforward language focused on benefits, while developers need technical specifics and versioning details. Avoid jargon for non-technical audiences.

### Structure and Organization

**Clear Headings**: Organize with categories like "New Features," "Enhancements," "Bug Fixes," and "Breaking Changes." This helps users quickly find what matters to them.

**Scannable Format**: Use separate clickable links, drop-downs, and subheadings for easy navigation. Few users will read every detail, so make content easy to skim.

**Essential Information**: Include product name, version number, and release date. This helps users identify if they're using the latest version.

### Writing Principles

**Concise and Focused**: Apply the 80/20 rule: 80% useful content, 20% promotion. Avoid lengthy explanations that cause fatigue. Users want to know benefits quickly.

**User-Centric Language**: Focus on user value, not technical implementation. Explain what users can now do and why it matters to them. Avoid technical jargon unless writing for technical users.

**Visual Elements**: Use images, screenshots, GIFs, or short videos to replace lengthy explanations. Visuals make release notes more appealing and memorable, improving understanding.

**Clear, Simple Language**: While announcing technical updates, avoid complex language that creates barriers. Make updates relatable and understandable for all users.

### User Value Focus

Always keep the user in mind. The main objective is providing clear, concise, relevant information that benefits the reader. Explain how changes improve their workflow or solve their problems.

**Sources**: [Appcues Release Notes Guide](https://www.appcues.com/blog/release-notes-examples), [Changelogfy Best Practices](https://changelogfy.com/blog/write-release-notes-best-practices/), [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), [Getbeamer Release Notes](https://www.getbeamer.com/blog/release-notes-best-practices)

## In-App Help Text and Microcopy

Microcopy refers to small bits of text in interfaces designed to engage users and guide them to actions. This includes button labels, error messages, form instructions, CTAs, and tooltip hints.

### Tooltip and Help Text Best Practices

**Keep It Concise**: Tooltip microcopy should be as short as possible. Shorter copy increases the odds that users will read it all the way through. Use as few words as you can while maintaining clarity.

**Be Clear and Specific**: Provide specific information rather than generic examples. Use plain language, avoid jargon, and ensure content is accessible to users with disabilities.

**Avoid Sensitive Content**: Everything related to sensitive topics (privacy, security, legal) should always be visible and static, not hidden in tooltips. Critical information must not require user action to reveal.

**Use Active Verbs**: Interactive elements like buttons should always begin with active verbs. This incentivizes action and helps users understand what will happen when they interact. "Save changes" is clearer than "Save."

**Focus on Helpfulness**: Keep microcopy helpful rather than salesy. Users need guidance, not marketing messages, when using your product.

### Writing for Context

Different contexts require different microcopy approaches:

**Error Messages**: Explain what went wrong and what to do about it. "Email format is invalid. Use format: name@domain.com" is better than "Invalid email."

**Empty States**: Turn empty screens into onboarding opportunities. Guide users to take their first action rather than just saying "No items yet."

**Form Instructions**: Provide just-in-time help near form fields. Explain requirements before users make mistakes, not after.

**Button Labels**: Be specific about outcomes. "Delete account" is clearer than "Delete" alone.

### Testing and Iteration

Microcopy is not one-and-done. Test different options to see what resonates with users. User behavior guides what works best. A/B test copy variations and measure completion rates, error rates, and user feedback.

**Sources**: [Userpilot Microcopy UX](https://userpilot.com/blog/microcopy-ux/), [Smashing Magazine Microcopy Tips](https://www.smashingmagazine.com/2024/06/how-improve-microcopy-ux-writing-tips-non-ux-writers/), [Justinmind Microcopy](https://www.justinmind.com/ux-design/microcopy), [Userpilot Tooltip Design](https://userpilot.com/blog/tooltip-ui-design/)

## Getting Started Tutorials and Onboarding

Getting-started tutorials are critical for user activation. The goal is helping users reach their "aha moment" - the point where they first realize the product's value and why they need it.

### The Aha Moment

An aha moment is a moment of sudden insight or discovery where users first understand product value. The key is helping users hit that moment quickly, ideally during onboarding. Research shows improvements in a user's first 5 minutes can drive a 50% increase in lifetime value.

### Onboarding Best Practices

**Keep It Simple**: Three-step tours have a 72% completion rate, while seven-step tours drop to 16%. Focus on essential actions only. Don't try to teach everything at once.

**Time-to-Value Focus**: Guide users to their aha moment as quickly as possible. Show benefits immediately, not after lengthy setup. Every step before value delivery increases drop-off risk.

**Interactive Over Static**: Products with interactive onboarding flows see 50% higher activation rates than those using static tutorials. Let users do rather than just read.

**Progressive Disclosure**: Use progressive disclosure, interactive tutorials, and smart empty state design to reduce cognitive load and accelerate time-to-value. Transform casual browsers into activated users.

### Design Strategies

**Personalized Flows**: Design personalized onboarding experiences based on user role, goals, or experience level. Different users need different paths to value.

**Quick Wins**: Structure tutorials around quick wins that demonstrate value immediately. First success should happen within minutes, not hours.

**Contextual Guidance**: Provide help when and where users need it, not all upfront. Use tooltips, walkthroughs, and progressive hints that appear at relevant moments.

### Testing and Optimization

Dig into user data, ask for direct feedback, and run A/B tests to find what makes users say "aha!" Track activation metrics: time to first value, feature adoption, and onboarding completion rates.

**Sources**: [Appcues Aha Moment Guide](https://www.appcues.com/blog/aha-moment-guide), [Userpilot Aha Moment](https://userpilot.com/blog/aha-moment/), [Chameleon User Onboarding](https://www.chameleon.io/blog/successful-user-onboarding), [ProductLed Aha Moments](https://productled.com/blog/how-to-use-aha-moments-to-drive-onboarding-success)

## Screenshots and Visual Aids

When instructions include visuals like screenshots or videos, users complete tasks [67% more successfully](https://www.archbee.com/blog/screenshots-in-technical-documentation) compared to text-only instructions.

### When to Use Screenshots

Capture screenshots for multi-step processes or new features you want to emphasize. Use them when you need to show users exactly what to look for, especially in software documentation where precision matters.

### Quality and Format Standards

**File Format**: Use PNG format for screenshots (lossless) and SVG for drawings. PNG preserves clarity while SVG ensures perfect scaling.

**File Size**: Compress screenshots under 100KB using tools like TinyPNG. Large files slow page loads and frustrate users.

**Consistency**: Stick to a standard approach for annotations. Use red rectangles for emphasis, single-color arrows with the same thickness, and uniform fonts. Consistency helps users process visuals faster.

**Backgrounds**: Keep backgrounds uncluttered to draw attention to essential elements. Remove or blur irrelevant windows, tabs, and desktop items.

### Cropping and Framing

**Focus on Relevant Elements**: Crop screenshots to show only relevant interface elements. Use selective captures of specific dialog boxes or form fields when full-screen captures would include unnecessary information.

**Maintain Context**: Ensure important contextual elements remain visible to orient the user. Don't crop so tightly that users can't recognize where they are in the interface.

### Annotations and Context

**Text Introduction**: Always introduce screenshots with text to set the stage. This helps readers know what they're looking at and why it matters.

**Highlight Key Elements**: Use arrows, boxes, or numbered callouts to draw attention to specific UI elements. Make the visual guidance explicit.

**Descriptive Captions**: Include captions that explain what the screenshot shows and what action to take.

### Security and Accessibility

**Privacy Protection**: Keep names out of screenshots in publicly available documentation. Blur sensitive information or use dummy accounts for examples.

**Accessibility**: Include alt text for all images. Use descriptive file names. Optimize file sizes for users with limited bandwidth.

**Sources**: [Archbee Screenshots in Documentation](https://www.archbee.com/blog/screenshots-in-technical-documentation), [Medium Screenshots in Documentation](https://medium.com/technical-writing-is-easy/screenshots-in-documentation-27b45342aad8), [Pimpmysnap Screenshot Best Practices](https://www.pimpmysnap.com/blog/using-screenshots-for-documentation-best-practices-and-tips), [Ritza Screenshot Guidelines](https://styleguide.ritza.co/screenshots/screenshot-guidelines-for-technical-documentation/)

## Documentation Site Information Architecture

Effective information architecture (IA) creates the information backbone of documentation sites. While related, IA and navigation are distinct: [IA is the structure, navigation is the UI](https://www.nngroup.com/articles/ia-vs-navigation/) that helps users reach information.

### Hierarchical Organization

Documentation sites typically use sidebar navigation listing topics within product scope, with documents grouped in parent-child trees. Hierarchical organization helps users understand and visualize the body of information.

### Navigation Types

**Global Navigation**: Always visible navigation showing primary categories. Provides consistent orientation across all pages.

**Local Navigation**: Specific to a section or page, showing subcategories and related content within that context.

**Contextual Navigation**: Links embedded within content to guide users to related information. "See also" links, inline references, and related article suggestions.

### Planning IA Structure

**Site Architecture Definition**: Information architecture defines the overarching structure and relationship between all areas of a site.

**Sitemap Creation**: The sitemap lists all labeled pages and shows hierarchy, structure, and often page goals. It's informed by the IA.

**Navigation Design**: Navigation guides users via links to all areas of the website. It's implemented based on the IA and sitemap.

### Best Practices

**Clear Structure and Labeling**: Both navigation and IA require clear, logical structure and clear labeling. Use terms from the user's vocabulary, not internal jargon.

**Progressive Disclosure**: Manage information complexity by displaying only necessary or requested information at any given time. Layer information at different levels, from overview to detail.

**User Mental Models**: Structure IA around how users think about tasks and information, not how your system is architected internally.

**Sources**: [Nielsen Norman Group IA vs Navigation](https://www.nngroup.com/articles/ia-vs-navigation/), [Optimal Workshop IA vs Navigation](https://www.optimalworkshop.com/blog/information-architecture-vs-navigation-creating-a-seamless-user-experience), [I'd Rather Be Writing Navigation](https://idratherbewriting.com/files/doc-navigation-wtd/design-principles-for-doc-navigation/)

## Documentation Testing Methods

Testing documentation usability ensures content meets user needs and enables successful task completion. According to research, effective testing [improves user experience, reduces support requests](https://document360.com/blog/test-documentation-usability/), and increases customer retention.

### Testing Methods

**Paraphrase Testing**: Ask users to repeat documentation back in their own words to check comprehension. Testers go through documentation section by section. If users can't paraphrase content, comprehension is insufficient. This reveals whether you've packed too much information into sentences or paragraphs.

**Task-Based Testing**: Determine how easy it is for users to find and understand information through various user scenarios. Most relevant for instructional documentation like user manuals, installation guides, and troubleshooting manuals. Give users realistic tasks and observe where they struggle.

**Plus-Minus Testing**: Testers mark particular sections with pluses and minuses to convey positive or negative reading experiences. This reveals users' emotional reactions to documentation. Explore reasons for ratings in follow-up interviews.

### Testing Process

**Recruit Representative Users**: Test with actual target users, not just internal team members. Different user segments may have different needs.

**Provide Realistic Scenarios**: Give testers real-world tasks they would perform with your product. Don't lead them through ideal paths.

**Observe and Record**: Watch how users interact with documentation. Note where they pause, get confused, or give up. Screen recordings and think-aloud protocols capture valuable insights.

**Collect Feedback**: Use surveys, interviews, and analytics to understand what works and what doesn't. Ask specific questions about clarity, completeness, and usefulness.

### Benefits of Testing

Documentation testing improves user experience, reduces customer support requests, enhances brand loyalty, and increases long-term customer retention. It ensures product documentation aligns with user needs, contributing to overall product and business success.

**Sources**: [Document360 Testing Documentation Usability](https://document360.com/blog/test-documentation-usability/), [Technical Writer HQ Testing Methods](https://technicalwriterhq.com/documentation/how-to-test-documentation-usability/), [BetterDocs Usability Testing Guide](https://betterdocs.co/technical-documentation-test-usability-testing/), [Archbee Testing Technical Documents](https://www.archbee.com/blog/test-technical-documents-usability)

## Key Principles Summary

1. **Structure Documentation by User Need**: Use the Divio framework (tutorials, how-to, reference, explanation) to organize content by user intent, not system architecture.

2. **Write Task-Oriented Content**: Every page should answer "what can I do with this?" Focus on user goals, not feature lists.

3. **Progressive Disclosure**: Start simple, reveal complexity gradually. Don't overwhelm users with everything at once.

4. **Plain Language First**: Write clearly and concisely. Avoid jargon. Favor active voice and short sentences. Define technical terms when they must be used.

5. **Visual Aids Enhance Understanding**: Screenshots, diagrams, and videos significantly improve task completion. Use them generously but purposefully.

6. **Test with Real Users**: Documentation testing is not optional. Paraphrase testing, task-based testing, and plus-minus testing reveal where users struggle.

7. **Onboard to Value Quickly**: Get users to their aha moment fast. First success should happen in minutes. Interactive beats static.

8. **Empathetic Error Guidance**: Error messages, troubleshooting guides, and help text should tell users what to do, not just what went wrong.

9. **Consistent Structure and Style**: Use templates, maintain consistent terminology, follow a style guide. Consistency reduces cognitive load.

10. **User Language, Not Developer Language**: Use terms from the user's vocabulary. Mirror the user's mental model, not the system's technical model.
