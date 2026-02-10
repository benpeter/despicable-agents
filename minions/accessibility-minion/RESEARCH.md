# accessibility-minion Research: Web Accessibility Standards and Testing

This document provides the research foundation for accessibility-minion, focused on WCAG 2.2 conformance, assistive technology compatibility, and automated accessibility testing. The mission is to ensure web experiences are accessible to all users, including those using screen readers, keyboard navigation, and other assistive technologies.

## Domain Overview

Web accessibility means that websites, tools, and technologies are designed and developed so that people with disabilities can use them. Approximately 1 in 4 adults in the United States has a disability, and accessibility is both a moral imperative and a legal requirement in many jurisdictions.

WCAG (Web Content Accessibility Guidelines) 2.2 is the current standard, building on WCAG 2.1 and 2.0. WCAG defines three conformance levels: A (minimum), AA (standard target), and AAA (enhanced). Most legal requirements target WCAG 2.1 or 2.2 Level AA.

Automated testing catches approximately 30-40% of accessibility issues, with projections suggesting this may reach 57% by 2026. The remaining 60-70% requires manual testing with assistive technologies and human judgment.

## WCAG 2.2 Success Criteria and Techniques

WCAG 2.2 is organized around four principles (POUR): Perceivable, Operable, Understandable, and Robust. Each principle has guidelines, and each guideline has testable success criteria.

### New Success Criteria in WCAG 2.2

WCAG 2.2 was published as a W3C Recommendation on October 5, 2023. It contains 86 success criteria total (compared to 78 in WCAG 2.1), introducing nine new criteria:

**Level A (2 new criteria):**
- **2.4.11 Focus Not Obscured (Minimum)**: When a user interface component receives keyboard focus, the component is not entirely hidden due to author-created content.
- **2.5.7 Dragging Movements**: All functionality that uses a dragging movement for operation can be achieved by a single pointer without dragging.
- **2.5.8 Target Size (Minimum)**: The size of the target for pointer inputs is at least 24 by 24 CSS pixels (with exceptions).

**Level AA (4 new criteria):**
- **2.4.12 Focus Not Obscured (Enhanced)**: When a user interface component receives keyboard focus, no part of the component is hidden by author-created content.
- **2.4.13 Focus Appearance**: When the keyboard focus indicator is visible, the focus indicator meets minimum area and contrast requirements.
- **3.2.6 Consistent Help**: If a help mechanism is available on multiple pages, it occurs in the same relative order unless a change is initiated by the user.
- **3.3.7 Redundant Entry**: Information previously entered by or provided to the user is auto-populated or available for selection.
- **3.3.8 Accessible Authentication (Minimum)**: A cognitive function test is not required for authentication unless alternatives exist.

**Level AAA (3 new criteria):**
- **3.3.9 Accessible Authentication (Enhanced)**: A cognitive function test is not required for authentication.

**Removed Criteria:**
- **4.1.1 Parsing**: Removed as modern browsers handle malformed HTML gracefully.

WCAG 2.2 conformance levels: Level A contains 32 criteria (minimum baseline), Level AA adds 24 criteria (legal standard, 56 total), and Level AAA adds 31 criteria (enhanced accessibility, 87 total).

### Key WCAG Techniques by Category

**Perceivable:**
- Alternative text for images (ALT attributes)
- Captions and transcripts for audio/video
- Text alternatives for non-text content
- Color contrast ratios (4.5:1 for normal text, 3:1 for large text)
- Resizable text without loss of functionality

**Operable:**
- Keyboard accessibility (all functionality via keyboard)
- Sufficient time for users to read and interact
- Avoid seizure-inducing content (no more than 3 flashes per second)
- Skip navigation links
- Descriptive page titles and headings
- Visible focus indicators

**Understandable:**
- Page language identification (lang attribute)
- Predictable navigation and interaction patterns
- Input assistance (labels, instructions, error messages)
- Error identification and suggestions

**Robust:**
- Valid HTML (clean parsing, proper nesting)
- Name, role, value for UI components
- Status messages announced to assistive technologies

### Techniques Documentation

WCAG provides three types of techniques:

- **Sufficient Techniques**: Meet the success criterion
- **Advisory Techniques**: Go beyond requirements (best practices)
- **Failures**: Common mistakes that cause criterion failure

Developers should consult the WCAG 2.2 Techniques document for implementation guidance on each success criterion.

## WAI-ARIA 1.2 Authoring Practices

ARIA (Accessible Rich Internet Applications) fills gaps in HTML's semantic vocabulary. It provides roles, states, and properties that describe UI components to assistive technologies.

### Core ARIA Principles

**First Rule of ARIA**: Don't use ARIA if you can use native HTML. Native HTML elements have built-in accessibility.

**Example**: Use `<button>` instead of `<div role="button">`. The native button comes with keyboard support, focus management, and semantic meaning.

**Second Rule**: Don't change native semantics unless absolutely necessary. `<button role="heading">` is confusing.

**Third Rule**: All interactive ARIA controls must be keyboard accessible.

**Fourth Rule**: Don't use `role="presentation"` or `aria-hidden="true"` on focusable elements.

**Fifth Rule**: All interactive elements must have an accessible name.

### ARIA Roles

ARIA roles define what an element is (button, dialog, tab, etc.). Key role categories:

**Landmark Roles**: Define page regions (banner, navigation, main, contentinfo, complementary, search, form).

**Widget Roles**: Interactive components (button, checkbox, radio, tab, slider, combobox, tooltip).

**Document Structure Roles**: Organize content (article, heading, list, listitem, table, row, cell).

**Live Region Roles**: Dynamic content (alert, log, status, timer, marquee).

Modern HTML5 elements map to ARIA roles implicitly:
- `<nav>` = `role="navigation"`
- `<main>` = `role="main"`
- `<aside>` = `role="complementary"`
- `<header>` = `role="banner"` (when top-level)
- `<footer>` = `role="contentinfo"` (when top-level)

### ARIA States and Properties

**States**: Dynamic values that change during interaction (aria-expanded, aria-checked, aria-pressed, aria-selected).

**Properties**: Describe relationships and characteristics (aria-label, aria-labelledby, aria-describedby, aria-controls, aria-haspopup).

**Key Attributes**:
- **aria-label**: Provides accessible name directly
- **aria-labelledby**: References another element's text as label
- **aria-describedby**: References another element's text as description
- **aria-live**: Announces dynamic content changes (off, polite, assertive)
- **aria-hidden**: Removes element from accessibility tree (use sparingly)

### ARIA Design Patterns (APG)

The ARIA Authoring Practices Guide (APG) provides design patterns for common UI components:

- **Accordion**: Collapsible content sections
- **Alert/Alert Dialog**: Important messages requiring attention
- **Breadcrumb**: Navigation path to current page
- **Button**: Clickable actions
- **Carousel**: Rotating content display
- **Combobox**: Editable select dropdown
- **Dialog (Modal)**: Focused interaction requiring response
- **Disclosure**: Show/hide content toggle
- **Listbox**: Selectable list of options
- **Menu/Menubar**: Application-style menu navigation
- **Tabs**: Layered content panels
- **Tooltip**: Contextual help on hover/focus
- **Tree View**: Hierarchical list navigation

Each pattern includes:
- Keyboard interaction requirements
- ARIA role, state, and property usage
- Screen reader considerations
- JavaScript behavior implementation

APG patterns are reference implementations, not rigid requirements. Adapt patterns to your context.

## Axe-Core Rules and Configuration

Axe-core is the de facto standard for automated accessibility testing, maintained by Deque Systems. It powers Lighthouse accessibility audits, browser extensions, and CI/CD integrations.

### Axe-Core Architecture

Axe-core runs in the browser and evaluates the DOM against a ruleset. Rules check for WCAG violations and return:

- **Violations**: Issues that definitely fail WCAG
- **Incomplete**: Issues requiring manual review
- **Passes**: Checks that passed
- **Inapplicable**: Rules that don't apply to the page

### Key Axe Rules

Axe-core includes 70+ rules covering WCAG 2.0, 2.1, and 2.2. Key rules:

**Images and Media:**
- `image-alt`: Images must have alt text
- `image-redundant-alt`: Alt text should not be redundant with surrounding text
- `audio-caption`: Audio-only content must have captions
- `video-caption`: Video content must have captions

**Forms:**
- `label`: Form inputs must have labels
- `label-content-name-mismatch`: Visible label matches accessible name
- `autocomplete-valid`: Autocomplete attribute values are valid

**Keyboard and Focus:**
- `focus-order-semantics`: Focus order follows DOM order
- `tabindex`: tabindex values should not exceed 0
- `scrollable-region-focusable`: Scrollable regions must be keyboard accessible

**Color and Contrast:**
- `color-contrast`: Text has sufficient contrast with background (4.5:1 for normal, 3:1 for large)
- `color-contrast-enhanced`: Enhanced contrast (7:1 for normal, 4.5:1 for large) for AAA

**Structure:**
- `page-has-heading-one`: Page must have one h1
- `heading-order`: Heading levels should not skip
- `landmark-one-main`: Page must have one main landmark
- `region`: Content must be contained in landmarks

**ARIA:**
- `aria-allowed-attr`: ARIA attributes are valid for the role
- `aria-required-attr`: Required ARIA attributes are present
- `aria-valid-attr-value`: ARIA attribute values are valid
- `aria-hidden-focus`: aria-hidden elements should not be focusable

### WCAG 2.2 Support in Axe-Core

Axe-core 4.5.0 (released October 2022) introduced support for WCAG 2.2, including the `target-size` rule for 2.5.8 Target Size (Minimum). WCAG 2.2 rules are disabled by default until WCAG 2.2 becomes more widely adopted and legally required. To use these rules, configure axe products to use the WCAG 2.2 ruleset.

Because few WCAG 2.2 criteria can be automated without false positives, `target-size` is likely the only WCAG 2.2-specific rule added to axe-core. Axe-core releases new minor versions every 3-5 months, introducing new rules and features.

### Configuring Axe-Core

Axe-core supports custom configurations:

**Select specific rules:**
```javascript
axe.run({
  rules: {
    'color-contrast': { enabled: true },
    'image-alt': { enabled: true },
    'label': { enabled: false }  // disable specific rule
  }
});
```

**Select WCAG level:**
```javascript
axe.run({
  runOnly: {
    type: 'tag',
    values: ['wcag2aa', 'wcag21aa', 'wcag22aa']
  }
});
```

**Exclude specific elements:**
```javascript
axe.run({
  exclude: [
    ['.third-party-widget'],
    ['#legacy-component']
  ]
});
```

### Integration Points

**Browser Extensions:**
- axe DevTools (Chrome, Firefox, Edge)
- Accessibility Insights (Chrome, Edge)

**CI/CD Integration:**
- @axe-core/cli: Command-line axe runner
- axe-playwright: Playwright integration
- axe-puppeteer: Puppeteer integration
- jest-axe: Jest integration

**Frameworks:**
- react-axe: React development integration
- angular-axe: Angular development integration

## Screen Reader Behavior Differences

Screen readers interpret web content differently based on their design philosophy and target platform. Testing with multiple screen readers is essential.

### Major Screen Readers

**NVDA (NonVisual Desktop Access):**
- Platform: Windows (free, open-source)
- Browser pairing: Firefox (primary), Chrome (secondary)
- Strengths: Frequent updates, extensive community support, most commonly used (65.6% of respondents in 2025 surveys)
- Behavior: Strictly adheres to DOM and accessibility tree, excellent for spotting structural issues like missing alt text or improper heading hierarchy
- Navigation: Offers Screen Layout mode with automatic Focus Mode switching for properly marked elements
- 2025-2026: AI-powered image descriptions, automatic add-on updates, improved handling of dynamic content updates

**JAWS (Job Access With Speech):**
- Platform: Windows (commercial, $90-$1,475/year for single-user licenses)
- Browser pairing: Chrome, Firefox, Edge
- Strengths: Second most popular (60.5% usage), widely used in enterprise, extensive application support
- Behavior: Uses heuristics to enhance usability, can infer missing labels or adjust for poorly written markup (may mask accessibility issues during audits)
- Navigation: Browse Mode with automatic Forms Mode switching
- 2025-2026: FSCompanion AI assistant helps users learn the software

**VoiceOver:**
- Platform: macOS, iOS (built-in)
- Browser pairing: Safari (primary), Chrome (secondary)
- Strengths: Tight OS integration, gestures on mobile
- Behavior: Safari-specific features, may not match other screen readers

**TalkBack:**
- Platform: Android (built-in)
- Browser pairing: Chrome
- Strengths: Gesture-based mobile interaction
- Behavior: Similar to VoiceOver on mobile, touch-based navigation

**Narrator:**
- Platform: Windows (built-in)
- Browser pairing: Edge
- Strengths: Built-in, improving rapidly
- Behavior: Standards-compliant but limited feature set

### Screen Reader + Browser Combinations

Screen reader behavior varies by browser. Best combinations:

- **NVDA + Firefox**: Most standards-compliant
- **JAWS + Chrome**: Enterprise standard
- **VoiceOver + Safari**: macOS/iOS native
- **TalkBack + Chrome**: Android standard
- **Narrator + Edge**: Windows built-in

### Testing Priorities

Test with at least two screen readers representing different platforms:
- **Primary**: NVDA (Windows) + VoiceOver (macOS/iOS)
- **Secondary**: JAWS (Windows) + TalkBack (Android)

### ARIA Support Tables

The ARIA-AT (Assistive Technologies) Community Group publishes support tables showing how ARIA patterns are announced by various screen reader + browser combinations. These tables are available through the APG and updated regularly.

**Key insight**: No two screen readers behave identically. Design for standards compliance, then test with real assistive technologies.

## Lighthouse Accessibility Scoring Methodology

Google Lighthouse includes an accessibility audit category that scores pages 0-100. Lighthouse uses axe-core under the hood but applies its own scoring and categorization. The accessibility score is a weighted average of all accessibility audits, with weighting based on axe user impact assessments.

### Lighthouse Accessibility Audit Categories

**Automated Audits:**
- ARIA attributes and roles
- Color contrast
- Form labels
- Image alt text
- Document structure (headings, landmarks)
- Keyboard accessibility

**Manual Audits (not scored):**
- Logical tab order
- Interactive controls are keyboard operable
- Custom controls have associated labels
- Visual order matches DOM order

### Scoring Weights

Lighthouse assigns different weights to audits based on impact. Each accessibility audit is pass or fail; unlike Performance audits, a page does not get points for partially passing an accessibility audit. Heavier weighted audits have a bigger effect on the overall score:

- **Critical issues** (e.g., missing alt text, insufficient contrast): High weight
- **Moderate issues** (e.g., missing labels, heading order): Medium weight
- **Minor issues** (e.g., best practices): Low weight

A single critical issue can drop the accessibility score significantly. Manual audits and low-impact/best-practices audits are not included in the score calculation.

### Lighthouse vs. Full Axe Audit

Lighthouse runs a subset of axe-core rules focused on high-impact, automatable checks. A full axe-core audit (via axe DevTools) includes 70+ rules, while Lighthouse runs ~20 rules.

**Use Lighthouse for**: Quick accessibility checks, CI/CD gates, performance + accessibility together.

**Use axe DevTools for**: Comprehensive accessibility audits, development-time testing, detailed reporting.

### Lighthouse CI Integration

Lighthouse CI enables automated accessibility checks in CI/CD pipelines:

```yaml
# Example: GitHub Actions
- name: Run Lighthouse CI
  run: |
    npm install -g @lhci/cli
    lhci autorun
```

Set accessibility score thresholds to fail builds:

```javascript
// lighthouserc.json
{
  "ci": {
    "assert": {
      "assertions": {
        "categories:accessibility": ["error", {"minScore": 0.9}]
      }
    }
  }
}
```

## Pa11y and Accessibility Testing Tools

Beyond axe-core, several tools provide accessibility testing capabilities.

### Pa11y

Pa11y is a command-line accessibility testing tool that supports multiple engines:

**Engines:**
- **axe-core** (default): Deque's axe-core engine
- **HTML_CodeSniffer**: Alternative WCAG checker

**Usage:**
```bash
pa11y https://example.com
pa11y --runner axe https://example.com
pa11y --standard WCAG2AA https://example.com
```

**CI/CD Integration:**
```bash
pa11y-ci --sitemap https://example.com/sitemap.xml
```

**Advantages:**
- Simple CLI interface
- CI/CD friendly
- Sitemap crawling support

**Limitations:**
- Smaller rule set than full axe DevTools
- Limited reporting compared to browser tools

### WAVE (WebAIM)

WAVE is a browser extension and web service that provides visual feedback on accessibility issues.

**Strengths:**
- Inline visual indicators show exactly where issues are
- Color-coded icons for errors, warnings, features
- Contrast checker built-in

**Use cases:**
- Manual testing during development
- Designer and non-technical stakeholder reviews

### Accessibility Insights

Accessibility Insights (Microsoft) provides assessment and testing tools:

**Features:**
- Automated axe-core checks
- Guided manual assessments
- Tab stops visualization
- Color contrast analyzer
- Heading structure visualization

**Platforms:**
- Browser extension (Chrome, Edge)
- Windows desktop app
- Android mobile app

## Cognitive Accessibility Guidelines (COGA)

Cognitive accessibility addresses the needs of people with cognitive and learning disabilities. COGA (Cognitive and Learning Disabilities Accessibility Task Force) produces W3C guidance.

### Key COGA Principles

**Clear Language:**
- Use plain language (Flesch-Kincaid 8th grade or lower)
- Avoid jargon and complex terminology
- Define abbreviations on first use
- Use active voice

**Consistent Navigation:**
- Navigation in the same location across pages
- Predictable interaction patterns
- Clear headings and page structure

**Reduced Cognitive Load:**
- Minimize distractions (auto-playing media, animations)
- Provide undo for critical actions
- Break complex tasks into steps
- Avoid time limits where possible

**Visual Design:**
- Whitespace to separate content
- Icons paired with text labels
- Clear visual hierarchy
- Consistent use of color and typography

### WCAG Success Criteria for Cognitive Accessibility

Many WCAG criteria support cognitive accessibility:

- **1.4.8 Visual Presentation (AAA)**: Line height, line length, text spacing for readability
- **2.2.1 Timing Adjustable (A)**: Users can adjust time limits
- **2.2.3 No Timing (AAA)**: No time limits
- **3.1.5 Reading Level (AAA)**: Content at lower secondary education level
- **3.2.3 Consistent Navigation (AA)**: Navigation order consistent across pages
- **3.2.4 Consistent Identification (AA)**: Components with same functionality labeled consistently
- **3.3.2 Labels or Instructions (A)**: Labels provided for user input
- **3.3.5 Help (AAA)**: Context-sensitive help available

### COGA Design Patterns

**Multi-Step Processes:**
- Show progress indicator (step 1 of 3)
- Allow users to go back and review
- Persist data between steps
- Provide clear instructions at each step

**Forms:**
- Clear labels and instructions
- Error messages explain what went wrong and how to fix
- Input format examples (e.g., "MM/DD/YYYY")
- Autocomplete support (3.3.7 in WCAG 2.2)

**Content Structure:**
- Headings describe content sections
- Key information at the top (inverted pyramid)
- Bulleted lists for scannability
- Visual breaks between sections

## Accessible Name Computation

The accessible name is what assistive technologies announce for an element. Computing the accessible name follows a specific algorithm defined in the Accessible Name and Description Computation 1.2 specification (W3C). User agents construct an accessible name string by walking through a list of potential naming methods and using the first that generates a name. The algorithm is invoked recursively when necessary (e.g., when aria-labelledby references another element).

### Accessible Name Sources (Priority Order)

1. **aria-labelledby**: References another element's text
2. **aria-label**: Directly provides label text
3. **Native label**: `<label for="id">` for form inputs
4. **alt attribute**: For images
5. **title attribute**: Fallback (not recommended as primary)
6. **Element content**: For buttons, links, headings

### Examples

**aria-labelledby (highest priority):**
```html
<h2 id="section-title">Account Settings</h2>
<button aria-labelledby="section-title">Edit</button>
<!-- Accessible name: "Account Settings Edit" -->
```

**aria-label:**
```html
<button aria-label="Close dialog">×</button>
<!-- Accessible name: "Close dialog" -->
```

**Native label:**
```html
<label for="email">Email address</label>
<input type="email" id="email" />
<!-- Accessible name: "Email address" -->
```

**Element content:**
```html
<button>Save changes</button>
<!-- Accessible name: "Save changes" -->
```

### Common Mistakes

**Redundant labels:**
```html
<button aria-label="Submit form">Submit form</button>
<!-- aria-label redundant; just use content -->
```

**Missing labels:**
```html
<button><span class="icon-save"></span></button>
<!-- No accessible name; screen reader says "button" -->
```

**Incorrect labelledby:**
```html
<button aria-labelledby="nonexistent-id">Save</button>
<!-- Falls back to content: "Save" -->
```

### Testing Accessible Names

**Browser DevTools:**
- Chrome DevTools: Inspect element → Accessibility tab → Computed Properties
- Firefox DevTools: Inspect element → Accessibility tab → Name

**Screen readers:**
- Listen to what screen reader announces
- Should match visual label where possible

## Best Practices Summary

### WCAG Conformance

- Target WCAG 2.2 Level AA as baseline
- Automate 30-40% with axe-core; manually test the rest
- Test with at least two screen readers (NVDA + VoiceOver recommended)
- Integrate accessibility checks into CI/CD

### ARIA Usage

- First rule: Don't use ARIA if native HTML works
- Use landmark roles to structure page (or HTML5 semantic elements)
- Provide accessible names for all interactive elements
- Test ARIA patterns with real screen readers

### Automated Testing

- Run axe-core in development and CI/CD
- Use Lighthouse for quick checks and scoring
- Supplement automated testing with manual keyboard and screen reader testing
- Set accessibility score thresholds (minimum 90% Lighthouse score)

### Keyboard Accessibility

- All functionality must be keyboard accessible
- Visible focus indicators (2.4.13 Focus Appearance in WCAG 2.2)
- Logical tab order following DOM order
- Skip links for main content

### Cognitive Accessibility

- Use plain language (8th grade reading level)
- Consistent navigation and interaction patterns
- Minimize distractions and time limits
- Provide clear instructions and error messages

### Screen Reader Testing

- Test with NVDA + Firefox (Windows)
- Test with VoiceOver + Safari (macOS/iOS)
- Listen to full page flow, not just individual components
- Test forms, dynamic content, and interactive widgets

## Additional Research Notes (2026)

### WAI-ARIA 1.2 and 1.3 Status

WAI-ARIA 1.2 is the current standard, with ARIA 1.3 in development. ARIA 1.3 adds features to improve interoperability with assistive technologies and form a more consistent accessibility model for HTML and SVG2. The APG is continuously updated with practical guidance for implementing WCAG and ARIA rules with clear examples and design patterns.

### React Component Libraries and Accessibility

Component libraries that implement accessibility correctly from the start reduce the burden on developers. React Aria provides hooks for many ARIA patterns with behavior and semantics built in, following WAI-ARIA Authoring Practices guidelines. All components are tested with popular screen readers and devices, providing correct semantics via ARIA roles/attributes, handling keyboard/pointer events, managing focus, and providing screen reader announcements. React Aria supports advanced features like accessible drag-and-drop, keyboard multi-selection, and is engineered for internationalization (30+ languages, localized formatting, 13 calendar systems, RTL layout support). See the React Spectrum project on GitHub for implementation details and examples.

### COGA Guidelines Status

The Cognitive and Learning Disabilities Accessibility Task Force (COGA) develops W3C guidance with 8 core guidelines for inclusive design. Key principles include plain language content, consistent navigation, reduced cognitive load, and appropriate visual design (whitespace, line length 60-70 characters, 1.5 line spacing, bullet points over prose). As of early 2026, W3C is requesting comments on Cognitive Accessibility Research Modules and Issue Papers (comment period through February 16, 2026), indicating ongoing refinement.

## Sources

- [WCAG 2.2 Understanding Document](https://www.w3.org/WAI/WCAG22/Understanding/)
- [What's New in WCAG 2.2 (W3C WAI)](https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/)
- [WCAG 2.2 Complete Compliance Guide 2025](https://www.allaccessible.org/blog/wcag-22-complete-guide-2025)
- [ARIA Authoring Practices Guide (APG)](https://www.w3.org/WAI/ARIA/apg/)
- [WAI-ARIA 1.3 Specification (W3C draft)](https://w3c.github.io/aria/)
- [Axe-core GitHub Repository](https://github.com/dequelabs/axe-core)
- [Deque axe-core 4.5 WCAG 2.2 Support](https://www.deque.com/blog/axe-core-4-5-first-wcag-2-2-support-and-more/)
- [Lighthouse Accessibility Scoring (Chrome Developers)](https://developer.chrome.com/docs/lighthouse/accessibility/scoring)
- [NVDA vs JAWS vs VoiceOver 2025 Comparison](https://accessibility-test.org/blog/development/screen-readers/nvda-vs-jaws-vs-voiceover-2025-screen-reader-comparison/)
- [Screen Reader Testing Guide (TestParty)](https://testparty.ai/blog/screen-reader-testing-guide)
- [Accessible Name and Description Computation 1.2 (W3C)](https://w3c.github.io/accname/)
- [Providing Accessible Names and Descriptions (APG)](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/)
- [React Spectrum GitHub](https://github.com/adobe/react-spectrum)
- [W3C Cognitive Accessibility Guidance](https://www.w3.org/WAI/cognitive/)
- [Cognitive Accessibility Guidelines (UK Department for Education)](https://accessibility.education.gov.uk/guidelines/coga)
- [Introductory Guide to COGA (DigitalA11Y)](https://www.digitala11y.com/navigating-the-world-of-cognitive-disabilities-and-cognitive-accessibility-coga/)
- [Automated Accessibility Testing Tools Comparison](https://inclly.com/resources/accessibility-testing-tools-comparison)
