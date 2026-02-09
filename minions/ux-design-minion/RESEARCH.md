# UX Design Minion Research

Research compiled for the ux-design-minion agent, covering UI/UX design patterns, design systems, accessibility, and visual design principles.

## Design System Foundations

### Material Design 3

Material Design 3 represents a modern evolution in design systems with significant advances in personalization and adaptability.

**Core Principles:**
- Seven key foundations: Color, Typography, Shape, Motion, Interaction, Layout, and Elevation
- Dynamic Color system that adapts to user preferences and wallpaper
- Personal, Adaptive, and Expressive design philosophy
- "Material 3 Expressive" (2025) introduces enhanced use of color, shape, size, motion, and containment

**Component Architecture:**
- Extensive library of 35 abstract shapes
- 10-step corner radius scale for granular visual control
- Components built with accessibility standards by default
- Five width-based breakpoints: Compact, Medium, Expanded, Large, Extra-large

**Key Innovation:**
Dynamic Color matching system theme or wallpaper for personalization. Accessibility is a core design value, not an afterthought, integrated into all components.

**Sources:**
- [Material Design 3 - Google's latest design system](https://m3.material.io/)
- [Mastering Material 3 Foundations Guide](https://medium.com/design-bootcamp/mastering-material-3-foundations-a-comprehensive-guide-for-ui-ux-designers-63a6fe40e750)
- [Material 3 Design System](https://zoewave.medium.com/material-3-design-system-e91a15d303a0)
- [Expressive Design: Google's UX Research](https://design.google/library/expressive-material-design-google-research)

### Apple Human Interface Guidelines

The HIG provides unified, platform-agnostic design guidance with platform-specific details.

**Core Principles:**
- **Clarity:** Interfaces should be legible, precise, and easy to understand
- **Deference:** UI helps users focus on content by minimizing visual clutter
- **Depth:** Visual layers and realistic motion convey hierarchy

**Structure:**
Organized into Platforms, Foundations, Patterns, Components, Inputs, and Technologies. Merged platform-specific guidance into unified documentation while preserving relevant platform details.

**Philosophy:**
Guidelines, not rigid rules. Innovation is encouraged when built on solid understanding of core principles and offers demonstrably better experience.

**Platform Evolution:**
VisionOS for Apple Vision Pro introduces spatial computing concepts that fundamentally rethink interfaces in three-dimensional space.

**Sources:**
- [Human Interface Guidelines Official](https://developer.apple.com/design/human-interface-guidelines/)
- [Understanding Apple's HIG](https://medium.com/design-bootcamp/understanding-apples-human-interface-guidelines-282a4adebdee)
- [Apple HIG Complete iOS Design Guide 2026](https://www.nadcab.com/blog/apple-human-interface-guidelines-explained)

## Accessibility Standards and Compliance

### WCAG 2.2 AA Requirements

WCAG 2.2 builds on 2.1 with enhanced support for cognitive disabilities, motor disabilities, and mobile devices.

**Four Core Principles (POUR):**

1. **Perceivable:**
   - Text alternatives for non-text content
   - Content presentable in different ways without losing information
   - Enhanced visual and auditory content presentation

2. **Operable:**
   - All functionality available from keyboard
   - Sufficient time for users to read and use content
   - Clear navigation with headings and consistent structure
   - Minimum visibility for focus indicators (new in 2.2)
   - Focused elements not obscured by other content (new in 2.2)

3. **Understandable:**
   - Readable and understandable text
   - Predictable page behavior and operation
   - Help users avoid and correct mistakes

4. **Robust:**
   - Compatible with assistive technologies
   - Support for current and future technologies

**WCAG 2.2 Additions (9 new success criteria):**
- Focus indicator visibility requirements
- Reduced complex gestures requirement (e.g., dragging on touchscreens)
- Alternative authentication methods (biometric, email-based) that don't rely on memory

**Implementation Best Practices:**
- Embed accessibility from the start
- Use checklist as roadmap
- Prioritize high-impact issues
- Document progress
- Integrate into ongoing workflows

**Sources:**
- [Web Content Accessibility Guidelines (WCAG) 2.1](https://www.w3.org/TR/WCAG21/)
- [WCAG 2.2 Summary and Checklist](https://www.wcag.com/blog/wcag-2-2-aa-summary-and-checklist-for-website-owners/)
- [Ultimate WCAG Accessibility Checklist](https://www.browserstack.com/guide/wcag-compliance-checklist)
- [WebAIM's WCAG 2 Checklist](https://webaim.org/standards/wcag/checklist)

### APCA (Advanced Perceptual Contrast Algorithm)

APCA represents next-generation contrast calculation, addressing gaps between mathematical compliance and human perception.

**Key Differences from WCAG 2:**
- Calculates contrast based on luminance relative to foreground vs. background
- Considers font size and font weight
- Scoring system up to ~100 (higher = better contrast)

**Contrast Thresholds:**
- **Lc 15:** Absolute minimum for non-text distinguishable objects
- **Lc 30:** Minimum for placeholder or disabled text
- **Lc 45:** Minimum for larger/heavier text (headings)
- **Lc 60+:** Optimal reading experience

**Integration with Modern Color:**
Works particularly well with OKLCH color space. APCA + OKLCH L channel allows approximately 40 units of difference to reach Lc ≥ 60 threshold.

**Sources:**
- [APCA Contrast Calculator](https://apcacontrast.com/)
- [Understanding APCA](https://www.accessibilitychecker.org/blog/apca-advanced-perceptual-contrast-algorithm/)
- [APCA: The new color contrast standard](https://medium.com/design-bootcamp/apca-the-new-color-contrast-standard-for-web-accessibility-f634511a3462)

## Design Tokens and Architecture

### W3C Design Tokens Specification

The first stable version (2025.10) was released in October 2025, establishing a vendor-neutral standard.

**Purpose:**
- Standardize design decision sharing across tools and platforms
- Ensure no single vendor controls the format
- Provide freedom to choose best tools without compatibility concerns

**File Format:**
- JSON files following specification structure
- Media type: `application/design-tokens+json`
- Extensions: `.tokens` or `.tokens.json`
- Minimum: name/value pair

**Advanced Features:**
- Composite types for complex properties (shadows, gradients, borders, typography)
- Token aliasing using curly brace syntax for complete values
- JSON Pointer notation for property-level references
- Modern color space support
- Standardized theming support

**Industry Adoption:**
10+ design tools support or implement the standard: Penpot, Figma, Sketch, Framer, Knapsack, Supernova, zeroheight. Reference implementations in Style Dictionary, Tokens Studio, Terrazzo.

**Sources:**
- [Design Tokens Specification First Stable Version](https://www.w3.org/community/design-tokens/2025/10/28/design-tokens-specification-reaches-first-stable-version/)
- [Design Tokens Format Module 2025.10](https://www.designtokens.org/tr/drafts/format/)
- [Understanding W3C Design Token Types](https://designtokens.substack.com/p/understanding-w3c-design-token-types)
- [Design Tokens Community Group](https://www.designtokens.org/)

### CSS Custom Properties and Theme Switching

**Design Tokens as CSS Variables:**
CSS custom properties (variables starting with `--`) serve as the implementation layer for design tokens, holding colors, fonts, sizes, or any reusable style information.

**Dark Mode Implementation Patterns:**

1. **System Preference Detection:**
   - Use `@media (prefers-color-scheme: dark)` to override tokens
   - Respects user's OS-level preference
   - Automatic switching based on system settings

2. **Manual Theme Toggling:**
   - Use data attributes or CSS classes (e.g., `data-theme="dark"`)
   - JavaScript functions toggle modes dynamically
   - Persisted to localStorage for consistency

3. **Modern CSS Functions:**
   - CSS `light-dark()` function adapts based on user preferences
   - Simplifies mode switching without code duplication

**Benefits:**
- Dynamic values that can change in response to user input
- Elements automatically reflect changes when variable updates
- Consistent, reusable framework for design attributes
- Seamless mode transitions without rewriting styles

**Sources:**
- [Dark Mode Theming with CSS and Design Tokens](https://medium.com/@brcsndr/you-dont-know-css-dark-mode-theming-and-swapping-with-css-and-design-tokens-ac1273936940)
- [Implementing Light and Dark Mode with Style Dictionary](https://www.alwaystwisted.com/articles/a-design-tokens-workflow-part-7)
- [Developer's guide to design tokens and CSS variables](https://penpot.app/blog/the-developers-guide-to-design-tokens-and-css-variables/)

## Component Library Patterns

### React Spectrum

React Spectrum is a TypeScript-first component library implementing a modern design system with advanced features.

**Architecture:**
- TypeScript-based component library
- Atomic CSS generation at build time for tiny bundle sizes
- Style macros colocate styles with component code
- Server-side rendering and React Server Components support

**Key Features:**
- **Performance:** Atomic CSS, fast runtime performance, optimized Core Web Vitals
- **Accessibility:** Built-in support for 30+ languages, RTL support, date/number formatting
- **AI-Ready:** Comprehensive markdown docs, llms.txt, agent-friendly MCP server
- **Modern:** Dark/light mode switching, Spectrum 2 v1.0 (December 2025)

**Spectrum 2 Improvements:**
- Modern, refined components
- Better accessibility and performance
- Enhanced styling flexibility with style macros

**Sources:**
- [React Spectrum Official](https://react-spectrum.adobe.com/)
- [GitHub: React Spectrum](https://github.com/adobe/react-spectrum)
- [React Spectrum Architecture](https://react-spectrum.adobe.com/architecture.html)
- [Spectrum 2 v1.0 Release](https://react-spectrum.adobe.com/releases/v1-0-0)

### Radix UI Primitives

Low-level, unstyled UI component library with focus on accessibility and developer experience.

**Core Philosophy:**
- Components as base layer for design systems
- Incremental adoption possible
- Complete styling control (no default styles)
- WAI-ARIA design pattern adherence

**Accessibility Features:**
- Correct ARIA and role attributes out of the box
- Focus management with sensible defaults and customization
- Full keyboard support for expected interactions
- Tested across modern browsers and assistive technologies

**Component Patterns:**
- **Compound components:** Related components work together (Dialog = Trigger + Content + Title + Close)
- **Polymorphic components:** `asChild` prop allows rendering as different HTML elements
- **Maximum flexibility:** Style with any solution

**Sources:**
- [Radix Primitives Introduction](https://www.radix-ui.com/primitives/docs/overview/introduction)
- [Radix Accessibility](https://www.radix-ui.com/primitives/docs/overview/accessibility)
- [GitHub: Radix Primitives](https://github.com/radix-ui/primitives)

### shadcn/ui

Component library with unique "copy into your codebase" approach, built on Radix and Tailwind.

**Design Token Integration:**
- Uses consistent CSS variables: `--primary`, `--background`, `--foreground`
- Define tokens once, consume everywhere
- Values like `--radius-sm`, `--radius-md` stored as CSS variables
- Tracks Figma variables in `global.css`

**2026 Best Practices:**
- **Component Structure:** Separate `ui/` (raw shadcn), `primitives/` (lightly modified), `blocks/` (product-level compositions)
- **Wrapper Pattern:** Create `AppButton` wrappers instead of importing raw components
- **Block Reuse:** Focus on reusable blocks, not just individual components

**AI-Native Advantages:**
- TypeScript + consistent Next.js patterns
- All code in codebase (full AI context)
- Predictable composition patterns
- Built-in accessibility context

**Figma Integration:**
Import/export design tokens (variables) in OKLCH, HEX, RGB, HSL. Fully compatible with Tailwind CSS 4 and shadcn/ui themes.

**Sources:**
- [shadcn/ui Best Practices for 2026](https://medium.com/write-a-catalyst/shadcn-ui-best-practices-for-2026-444efd204f44)
- [The anatomy of shadcn/ui](https://manupa.dev/blog/anatomy-of-shadcn-ui)
- [shadcn/ui Official](https://www.shadcn.io)

## Accessibility Testing Tools

### axe-core

The global standard in automated accessibility testing, invented by Deque.

**Capabilities:**
- Finds ~57% of WCAG issues automatically
- Rule types for WCAG 2.0, 2.1, 2.2 (levels A, AA, AAA)
- Best practice rules beyond WCAG
- ARIA role and property verification
- Complete ARIA supported roles and attributes list

**Integration Options (7 packages):**
- Command-line interface
- Playwright, Puppeteer integrations
- React integration
- WebDriverIO, WebDriverJS

**ARIA Support:**
Validates ARIA roles, properties, and attributes to ensure semantic HTML and ARIA are correctly implemented.

**Sources:**
- [GitHub: axe-core](https://github.com/dequelabs/axe-core)
- [How to Test React Applications for Accessibility](https://oneuptime.com/blog/post/2026-01-15-test-react-accessibility-axe-core/view)
- [Axe Platform](https://www.deque.com/axe/)

### Screen Reader Testing

**ChromeVox:**
- Chrome screen reader extension
- Validates keyboard navigation and focus order
- Screen reader output verification
- Keyboard command navigation
- Experience website exactly as screen reader users do

**Automation Tools:**
Pa11y automates accessibility testing from command line or CI/CD, generating reports highlighting violations, contrast issues, and ARIA errors.

**Sources:**
- [29 Best Accessibility Testing Tools](https://www.testmuai.com/blog/accessibility-testing-tools/)
- [Automating Screen Readers for Accessibility Testing](https://assistivlabs.com/articles/automating-screen-readers-for-accessibility-testing)

## Responsive Design Strategies

### Breakpoint Strategies

**Standard Breakpoints (2025):**
- 320px (small mobile)
- 481px (large mobile)
- 769px (tablet)
- 1025px (desktop)

**Breakpoint Categories:**
- **Device-based:** Standard phone, tablet, desktop sizes
- **Content-based:** Where layout breaks visually
- **Layout-based:** Structural elements
- **Component-based:** Within individual components
- **Orientation-based:** Portrait/landscape
- **Interaction-based:** Hover vs. touch

**Modern Approach (2026):**
- Content-driven thresholds, not fixed device widths
- Combined with fluid layouts and container queries
- Focus on 2-3 meaningful breakpoints instead of 5-6

**Sources:**
- [Responsive Design Breakpoints in 2025](https://www.browserstack.com/guide/responsive-design-breakpoints)
- [Responsive Design Breakpoints: 2025 Playbook](https://dev.to/gerryleonugroho/responsive-design-breakpoints-2025-playbook-53ih)

### Mobile-First Approach

**Tailwind Pattern:**
Mobile-first breakpoint system where unprefixed utilities apply to all screen sizes, prefixed utilities apply at specific breakpoints and above.

**Benefits:**
- Single column and smaller fonts as basis
- No mobile breakpoints needed unless optimizing for specific models
- Typically requires only 2-3 breakpoints total

**Sources:**
- [Tailwind CSS Responsive Design](https://tailwindcss.com/docs/responsive-design)

### Container Queries

One of the most significant technical shifts in 2026: components adapt based on parent container instead of viewport.

**Use Cases:**
- Page uses media queries for sidebar vs. stacked layouts
- Individual components use container queries to adapt to allocated space
- Component-based responsiveness independent of viewport

**Represents:** The future of component-based responsive design.

**Sources:**
- [Do We Still Need Breakpoints in Responsive Design?](https://blog.openreplay.com/need-breakpoints-responsive-design/)
- [Responsive Web Design in 2026: Trends and Best Practices](https://www.keelis.com/blog/responsive-web-design-in-2026:-trends-and-best-practices)

## Typography

### Visual Hierarchy Principles

**Typographic Hierarchy:**
Shows readers which information to focus on, what's most important, and what supports main points.

**Core Strategies:**
- Reading patterns (Z and F patterns)
- Rule of thirds
- Scale (size differentiation)
- Typography (font choice and pairing)
- Contrast
- White space
- Proximity

**Font Usage:**
- Limit to 1-2 font families
- Use variations within families (weight, size, style)
- **Weight:** Bold vs. regular for emphasis
- **Size:** Large headers vs. smaller body text
- **Style:** Italic for emphasis or distinction

**Sources:**
- [What is Visual Hierarchy?](https://www.interaction-design.org/literature/topics/visual-hierarchy)
- [How to Structure an Effective Typographic Hierarchy](https://www.toptal.com/designers/typography/typographic-hierarchy)
- [Introduction to typography hierarchy](https://uxcel.com/blog/beginners-guide-to-typographic-hierarchy)

### Modular Type Scales

**Concept:**
Based on musical scales where each step is proportional to the last.

**Common Ratios:**
- Perfect fourth (1.333)
- Major third (1.25)
- Golden ratio (1.618)

**Implementation:**
1. Start with base number (body text size)
2. Multiply/divide by chosen ratio
3. Determine sizes of other elements
4. Maintains harmonious visual hierarchy

**Benefits:**
- Typography adapts to different screen sizes
- Maintains relative size ratios
- Enhanced compositions and improved readability

**Sources:**
- [Modular Type Scaling for Frontend Developers](https://www.kalamuna.com/blog/modular-type-scaling-frontend-developers)
- [Different types of typographic scales](https://cieden.com/book/sub-atomic/typography/different-type-scale-types)

### Fluid Typography

**Definition:**
Text sizing that scales proportionally based on viewport dimensions, creating smooth, continuous scaling.

**CSS Clamp Implementation:**
```css
font-size: clamp(min, ideal, max);
```

- Minimum value (smallest allowed size)
- Ideal value (scaling value using viewport units)
- Maximum value (largest allowed size)

**Browser Support:**
91.4% of browsers support CSS `clamp()` (2026).

**Accessibility:**
If max font size ≤ 2.5 × min font size, text passes WCAG SC 1.4.4 on modern browsers.

**Best Practices:**
- Combine relative units (rem) with viewport units (vw)
- Test on multiple browsers and zoom levels
- Use container query units for component-based fluid type

**Sources:**
- [Modern Fluid Typography Using CSS Clamp](https://www.smashingmagazine.com/2022/01/modern-fluid-typography-css-clamp/)
- [Fluid Typography Tool](https://fluidtypography.com/)
- [Generating font-size CSS Rules and Creating a Fluid Type Scale](https://moderncss.dev/generating-font-size-css-rules-and-creating-a-fluid-type-scale/)
- [Container Query Units and Fluid Typography](https://moderncss.dev/container-query-units-and-fluid-typography/)

## Color Theory and Systems

### OKLCH Color System

Modern color space introduced by Björn Ottosson (2020) for more uniform lightness and wider gamut.

**Advantages over HSL/traditional LCH:**
- More uniform lightness axis
- Wider color gamut coverage
- Simplified accessibility contrast calculations
- Linear L channel

**Browser Support (2026):**
- Chrome 111+
- Safari 15.4+
- Firefox 113+
- Native `oklch()` parsing
- GUI support in DevTools color pickers

**APCA Integration:**
OKLCH's linear L channel allows ~40 units of difference to reach APCA Lc ≥ 60 (optimal reading).

**Sources:**
- [OKLCH in CSS: why we moved from RGB and HSL](https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl)
- [Color experiments with OKLCH](https://clhenrick.io/blog/color-experiments-with-oklch/)
- [The Ultimate OKLCH Guide](https://oklch.org/posts/ultimate-oklch-guide)

## Interaction Design

### Micro-interactions

**Definition:**
Subtle, task-based animations or responses that guide, inform, or delight users during interactions.

**Four Components (Dan Saffer):**
1. **Trigger:** Action that starts the micro-interaction
2. **Rule:** How the product reacts to the trigger
3. **Feedback:** System tells user about interaction status (visual, auditory, haptic)
4. **Loops and Modes:** Meta-rules about the micro-interaction behavior

**Common Patterns:**
- Contact/newsletter sign-up forms
- Social media like/share buttons
- Call to action buttons
- Tap and hold elements
- Horizontal scroll buttons
- Progress indicator bars
- Audio/visual feedback
- Hover to reveal text/images
- Page transitions
- Button hover animations

**Benefits:**
- Instant feedback confirms actions
- Guides users through website naturally
- Makes navigation more intuitive
- Helps users understand without waiting or guessing

**Best Practices:**
- Design with intention
- Feel natural and intuitive
- Blend with rest of design
- Never take users out of experience

**Sources:**
- [14 Micro-interaction Examples to Enhance UX](https://userpilot.com/blog/micro-interaction-examples/)
- [Micro Interactions in Web Design 2025](https://www.stan.vision/journal/micro-interactions-2025-in-web-design)
- [The Role of Micro-interactions in Modern UX](https://www.interaction-design.org/literature/article/micro-interactions-ux)
- [15 best microinteraction examples](https://webflow.com/blog/microinteractions)

## Form Design and Validation

### Accessible Form Validation

**HTML5 Constraint Validation:**
- Attributes: `required`, `type`, `min`, `max`, `pattern`
- `:invalid` pseudo-class (matches on page load)
- `:user-invalid` pseudo-class (matches after user interaction)

**ARIA Requirements:**
- `aria-invalid="true"` on fields with errors
- Ensures assistive technologies recognize and announce errors
- `aria-describedby` for detailed input information
- Alert role on error messages for immediate announcement

**Error Message Patterns:**
- Inline messages appear after focus moves to next field
- Don't use color/icons alone to identify errors
- Provide same information in alternative method
- Summary list in Page alert component at top of form
- Focus summary immediately after submission attempt

**Best Practices:**
- Never rely on visual cues alone
- Provide clear, actionable error messages
- Indicate field with error and explain how to fix
- Position errors near associated fields

**Sources:**
- [A Guide To Accessible Form Validation](https://www.smashingmagazine.com/2023/02/guide-accessible-form-validation/)
- [WebAIM: Usable and Accessible Form Validation](https://webaim.org/techniques/formvalidation/)
- [Best Practices for Form Validation and Error Messages](https://www.digitala11y.com/anatomy-of-accessible-forms-errors-of-the-ways/)
- [The Anatomy of Accessible Forms: Error Messages](https://www.deque.com/blog/anatomy-of-accessible-forms-error-messages/)

## Edge Case Design

### Loading, Empty, and Error States

**Loading States:**
- **Skeleton screens:** Visual placeholders during data loading
  - Simplified versions of components
  - Indeterminate progress
  - New norm for full-page loading (LinkedIn, YouTube, Slack)
- **Loading indicators:** Signal processing without progress indication
- **Progressive loading:** Content appears as it loads

**Empty States:**
- Occur when no data to display
- First login experience
- Empty list/table
- User clears all items
- Something goes wrong

**Design Approach:**
- Educate about expected data type
- Visual cues for next action
- Clear guidance on where to go next
- For errors: plain language explanation + resolution steps

**Error States:**
- Inform what went wrong
- Guide user on what to do next
- Plain language error messages
- Actionable resolution steps

**UI State Coverage:**
Design for all states: default, empty, loading, error, disabled, success, interactive/hover, partial. Ensures seamless, intuitive experience regardless of backend state.

**Sources:**
- [Loading, empty and error states pattern](https://design-system.agriculture.gov.au/patterns/loading-error-empty-states)
- [Loading patterns - Carbon Design System](https://carbondesignsystem.com/patterns/loading-pattern/)
- [Empty states – Carbon Design System](https://carbondesignsystem.com/patterns/empty-states-pattern/)
- [Empty state UX examples and design rules](https://www.eleken.co/blog-posts/empty-state-ux)
- [What's a skeleton screen?](https://www.uxdesigninstitute.com/blog/whats-a-skeleton-screen/)

## Focus Management and Keyboard Navigation

### Keyboard Navigation Patterns

**Primary Keyboard Interactions:**
- **Tab:** Move focus to next interactive element
- **Shift + Tab:** Move backward
- **Enter:** Activate buttons, follow links
- **Space:** Activate buttons, toggle checkboxes
- **Escape:** Close modals, dismiss menus
- **Arrow keys:** Navigate within components (dropdowns, tab panels)

**ARIA Pattern Requirements:**
Unlike native HTML form elements, ARIA-enabled GUI components require author-provided keyboard support.

**Key Principles:**
- Maintain visible focus
- Predictable focus movement
- Distinguish between keyboard focus and selected state

**Advanced Patterns:**

1. **Roving tabindex:**
   - Tab key moves into/out of widget
   - Arrow keys manipulate focus within widget
   - Used for complex widgets with many focusable elements

2. **aria-activedescendant:**
   - Focus remains on container element
   - Updates `aria-activedescendant` with reference to selected element
   - Alternative to moving focus directly

**Best Practices:**
- Prefer semantic HTML over ARIA
- Always maintain visible focus indicator
- Set focus to element that makes sense in user's context

**Sources:**
- [Developing a Keyboard Interface - W3C](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/)
- [Focus & Keyboard Operability](https://usability.yale.edu/web-accessibility/articles/focus-keyboard-operability)
- [Keyboard focus - web.dev](https://web.dev/learn/accessibility/focus)
- [Accessible Navigation Menus](https://www.accesify.io/blog/accessible-navigation-menus-aria-roles-keyboard-support-focus-order/)

## Design System Documentation

### Storybook Patterns

**Documentation Approaches:**
- Pair Storybook with purpose-built documentation layer
- Embed Storybook stories next to design-token tables
- Include accessibility guidelines and release notes
- Single source of truth for designers, engineers, and PMs

**Storybook Docs Addon:**
Auto-generates usage, props, and code snippets. Contributors see same information without digging through repos.

**Design Token Documentation:**
- `storybook-design-token` addon displays tokens from stylesheets and icon files
- Add tokens to Storybook Docs with custom Doc Blocks
- Card or table presentation views
- Colour tokens and spacing scales beside interactive examples

**2026 Best Practices:**
- Define tokens in configuration files
- Create reusable component patterns
- Document in Storybook
- Enforce consistent spacing, colors, typography
- Incorporate Figma documentation alongside Storybook
- Showcase design components and story code together

**Sources:**
- [Top Storybook Documentation Examples](https://www.supernova.io/blog/top-storybook-documentation-examples-and-the-lessons-you-can-learn)
- [Storybook Design Token addon](https://storybook.js.org/addons/storybook-design-token)
- [4 ways to document your design system with Storybook](https://storybook.js.org/blog/4-ways-to-document-your-design-system-with-storybook/)

## Summary

This research provides comprehensive foundation for the ux-design-minion agent across:

- **Design Systems:** Material Design 3, Apple HIG, modern design system patterns
- **Accessibility:** WCAG 2.2 AA compliance, APCA contrast, testing tools
- **Design Tokens:** W3C standards, CSS custom properties, theming
- **Component Libraries:** React Spectrum, Radix UI, shadcn/ui patterns
- **Responsive Design:** Modern breakpoint strategies, mobile-first, container queries
- **Typography:** Visual hierarchy, modular scales, fluid typography
- **Color:** OKLCH color system, APCA contrast requirements
- **Interaction:** Micro-interactions, transitions, feedback patterns
- **Forms:** Validation patterns, error states, accessibility
- **Edge Cases:** Loading, empty, error state design
- **Keyboard/Focus:** Navigation patterns, ARIA, focus management
- **Documentation:** Storybook patterns, design system documentation

All material is vendor-neutral, based on industry standards and best practices, suitable for publication under Apache 2.0 license.
