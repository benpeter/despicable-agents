# Frontend Development Research

## React 19+ Patterns

### Server Components and Actions

React 19 introduces fundamental changes to how data flows through applications. Server Components enable React to render components on the server, streaming HTML to the client while maintaining React's composability. This shifts the paradigm from "fetch in useEffect" to "fetch in Server Components."

**Actions** are functions that replace traditional event handlers and integrate with React's transition and concurrent features. Actions can run on both client and server:
- Form integration: Pass functions to `action` and `formAction` props of form elements
- Automatic form submission handling
- Integration with React transitions for pending states
- Error boundary integration for error handling

**Modern Hook Patterns:**
- Data-first render flows prioritize Server Components over client-side fetching
- Async data handling moves to the server when possible
- Client-side fetching (`useEffect`) reserved for truly interactive, client-controlled flows
- Rule of thumb: "Can this live in a loader or Server Component?" before defaulting to client fetching

### The use() Hook

The `use()` API is a game-changer for reading resources during render:
- Read promises: `use(promise)` causes React to Suspend until resolution
- Conditional context reading: Unlike hooks, `use()` can be called after early returns and in conditionals
- Error handling via nearest Suspense boundary
- Loading states managed by Suspense fallback
- Primary use case: Server Components consuming async data
- Limited but growing Client Component support via server actions

**Sources:**
- [React v19 Official Release](https://react.dev/blog/2024/12/05/react-19)
- [What's new in React 19 - Vercel](https://vercel.com/blog/whats-new-in-react-19)
- [React Stack Patterns 2026](https://www.patterns.dev/react/react-2026/)
- [React has changed, your Hooks should too](https://allthingssmitty.com/2025/12/01/react-has-changed-your-hooks-should-too/)

---

## TypeScript 5.x for Frontend

### Key Features

**Const Type Parameters:**
Preserve exact literal values in generic functions, particularly valuable for framework authors and utility libraries. This enables more precise type inference when working with literal types.

**Performance Improvements:**
- TypeScript 5.x compiler is ~20% faster than 4.x
- Project references enable incremental builds for monorepos
- Enterprise projects see significant build time reductions

**Direct Execution:**
TypeScript 5.8 enables running `.ts` files directly:
- `node --experimental-strip-types` flag
- `--rewriteRelativeImportExtensions` compiler option
- `--erasableSyntaxOnly` for runtime execution
- Tools like `ts-node` streamlined

### Best Practices

**TypeScript as Standard:**
78% enterprise adoption rate in 2025. Starting with TypeScript from day one is now considered best practice, especially for large-scale applications. Benefits include:
- Superior IDE auto-completion and error hints
- Better code navigation and refactoring
- Self-documenting code through type definitions
- 43% reduction in runtime errors for enterprise applications

**Type-Safe Full-Stack Development:**
The blurred line between client and server enables shared type systems across the stack:
- Backend procedures and validation share types with frontend
- Database schemas inform TypeScript types
- Reduced integration bugs through compile-time checking
- "Backendless" patterns where frontend engineers own more stack

**Advanced Type Features:**
Modern frontend development emphasizes:
- Conditional types for complex type logic
- Mapped types for transforming object types
- Template literal types for string manipulation at type level
- Discriminated unions for state machines
- Utility types (`Pick`, `Omit`, `Partial`, `Required`, etc.)

**Sources:**
- [TypeScript 5.x and Beyond](https://medium.com/@beenakumawat004/typescript-5-x-and-beyond-the-new-era-of-type-safe-development-c984eec4225f)
- [TypeScript Best Practices for Large-Scale Web Applications](https://johal.in/typescript-best-practices-for-large-scale-web-applications-in-2026/)
- [Frontend Development Trends 2026](https://talent500.com/blog/frontend-development-trends-2026/)

---

## React Spectrum Component Architecture

### Three-Layer Architecture

React Spectrum implements a unique split-component architecture that separates concerns into three distinct layers. This enables reusability across design systems while maintaining high-quality accessibility and behavior.

**Layer 1: React Stately (State Management)**
- Collection of hooks providing state management and core logic
- Platform-agnostic: no assumptions about rendering environment
- Theme and design system agnostic
- Accept common props and return state management interface
- Example: `useListState`, `useToggleState`, `useOverlayTriggerState`

**Layer 2: React Aria (Behavior & Accessibility)**
- Implements ARIA practices specification patterns
- Mouse, touch, and keyboard behaviors
- Accessibility (ARIA attributes, roles, semantics)
- Internationalization support (RTL, locale-aware formatting)
- Example: `useButton`, `useFocusRing`, `useTextField`

**Layer 3: React Spectrum (Design Implementation)**
- Spectrum design language in React components
- Composed from React Aria hooks and React Stately state management
- Visual design, styling, and theme application
- Example: `<Button>`, `<TextField>`, `<ComboBox>`

### Key Benefits

**Flexibility:**
Not all components need all layers. Simple components may skip state management, while complex components compose all three layers. Developers can use only the layers they need.

**Reusability:**
The separation enables teams to:
- Build custom design systems on React Aria + React Stately foundations
- Maintain consistent behavior across different visual treatments
- Share accessibility and interaction patterns across projects

**Quality:**
- Production-tested accessibility implementation
- Comprehensive keyboard navigation
- Screen reader support
- Mobile touch target sizing
- Focus management patterns

**TypeScript-First:**
All layers provide full TypeScript definitions with precise prop types and state interfaces.

**Sources:**
- [React Spectrum GitHub](https://github.com/adobe/react-spectrum)
- [React Spectrum Architecture](https://github.com/adobe/react-spectrum)

---

## Tailwind CSS v4

### Major Changes

**Performance:**
- Full builds up to 5x faster
- Incremental builds over 100x faster (measured in microseconds)
- Complete engine rewrite in Rust provides 10x performance improvement

**Modern CSS Foundation:**
Built on cutting-edge CSS features:
- Cascade layers for style prioritization
- Registered custom properties with `@property`
- `color-mix()` for dynamic color manipulation
- CSS container queries

**Simplified Configuration:**
- Automatic content detection via heuristics
- Zero-configuration setup for most projects
- Single line in CSS file: `@import "tailwindcss"`
- Fewer dependencies

### New Features

**nth-* Utility:**
Joins `first-*` and `last-*` for targeting specific children:
```html
<div class="nth-2:bg-blue-500">
  <!-- Second child has blue background -->
</div>
```

**@utility Directive:**
Bundle multiple CSS declarations under a single Tailwind-style class:
```css
@utility clip-text {
  clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%);
  -webkit-clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%);
}
```

**@theme Block:**
Declare design tokens (colors, spacing, fonts, radii, shadows, animations, breakpoints) that Tailwind uses to generate utilities.

### Best Practices

**Component Organization:**
- Extract repeated patterns into reusable components
- Centralize theme in configuration
- Use linting and plugins for consistency
- Avoid "class soup" by wrapping common patterns

**Responsive Design:**
Mobile-first approach with breakpoint prefixes:
- Base styles without prefix (mobile)
- `sm:`, `md:`, `lg:`, `xl:` for larger screens
- Container queries for component-level responsiveness

**Class Organization:**
`prettier-plugin-tailwindcss` automatically sorts classes according to predefined order for consistency and readability.

**Dark Mode:**
Use `dark:` variant with CSS custom properties:
```html
<div class="bg-white dark:bg-gray-900">
```

**Sources:**
- [Tailwind CSS v4.0 Official Release](https://tailwindcss.com/blog/tailwindcss-v4)
- [Tailwind CSS v4 Tips](https://www.nikolailehbr.ink/blog/tailwindcss-v4-tips/)
- [Tailwind CSS Best Practices](https://infinum.com/handbook/frontend/react/tailwind/best-practices)
- [Tailwind CSS in Large Projects](https://medium.com/@vishalthakur2463/tailwind-css-in-large-projects-best-practices-pitfalls-bf745f72862b)

---

## Vite Configuration and Optimization

### Build Performance

**Dynamic Imports:**
Code splitting via dynamic imports reduces initial bundle size and speeds up both build and load times:
```javascript
const Component = React.lazy(() => import('./Component'));
```

**Target Configuration:**
`build.target` specifies browser targets. Modern browsers only (ES modules) reduces build time by excluding legacy polyfills.

**Sourcemap Control:**
Disable sourcemaps in production to speed up builds:
```javascript
build: {
  sourcemap: false
}
```

### Code Splitting and Chunking

**Manual Chunks:**
Configure Rollup to split third-party dependencies:
```javascript
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        vendor: ['react', 'react-dom'],
      }
    }
  }
}
```

**Rolldown vs Rollup:**
Use Rolldown (Vite's experimental Rust-based bundler) for faster builds and more aligned dev/build experience.

### Plugin Performance

**Hook Optimization:**
`buildStart`, `config`, and `configResolved` hooks should be fast. Long operations delay dev server startup and time-to-interactive.

**Asset Optimization:**
`vite-plugin-imagemin` automatically optimizes images during build, reducing bundle size and build time.

### Development Environment

**Browser Extensions:**
Extensions interfere with requests and slow down startup/reload, especially with dev tools open. Use dev-only browser profile or incognito mode.

**Module Pre-bundling:**
Vite pre-bundles dependencies using esbuild, converting CommonJS/UMD to ESM and consolidating many small modules into fewer requests.

**Sources:**
- [Optimize Vite Build Time](https://dev.to/perisicnikola37/optimize-vite-build-time-a-comprehensive-guide-4c99)
- [Vite Performance Guide](https://vite.dev/guide/performance)
- [How to optimize Vite app](https://dev.to/yogeshgalav7/how-to-optimize-vite-app-i89)
- [Vite Configuration Mastery Guide](https://new2026.medium.com/the-complete-guide-to-mastering-vite-config-js-325319d0071d)

---

## Core Web Vitals Optimization

### Current Metrics (2026)

In March 2024, Google replaced FID (First Input Delay) with INP (Interaction to Next Paint) as a Core Web Vital. The three metrics are:

**1. Largest Contentful Paint (LCP)** - under 2.5 seconds
Measures loading performance by tracking when the largest content element becomes visible.

**2. Interaction to Next Paint (INP)** - under 200 milliseconds
Measures responsiveness by observing the latency of all interactions throughout page lifetime.

**3. Cumulative Layout Shift (CLS)** - under 0.1
Measures visual stability by quantifying unexpected layout shifts during page lifecycle.

### LCP Optimization

**Image Optimization:**
- Use modern formats: WebP or AVIF
- Implement responsive images with `srcset`
- Compress images without quality loss
- Lazy load below-the-fold images
- **Critical:** Ensure LCP image loads immediately (no lazy loading)

**Fetch Priority API:**
Boost LCP element priority:
```html
<img src="hero.jpg" fetchpriority="high" />
```

**Server Response Time:**
- Upgrade to faster hosting infrastructure
- Implement server-side caching
- Use CDN to serve content from edge locations
- Optimize database queries

**Render-Blocking Resources:**
- Defer non-critical JavaScript
- Inline critical CSS in HTML head
- Use `async` or `defer` attributes on scripts

### CLS Optimization

**Prevent Layout Shifts:**
Set explicit dimensions for all images and videos:
```html
<img src="photo.jpg" width="800" height="600" />
```

**Common Causes:**
- Images without dimensions
- Ads or embeds that inject content
- Web fonts causing text reflow
- Dynamically injected content

**Font Loading:**
Use `font-display: swap` or `font-display: optional` to prevent invisible text during font loading.

### INP Optimization

**JavaScript Execution:**
- Code split to load only necessary JavaScript
- Remove unused code
- Minimize third-party scripts
- Defer non-critical scripts

**Long Tasks:**
Break up long JavaScript tasks into smaller chunks using `setTimeout` or `requestIdleCallback`.

**Web Workers:**
Move heavy computation off main thread to Web Workers.

**Sources:**
- [Understanding Core Web Vitals](https://developers.google.com/search/docs/appearance/core-web-vitals)
- [Core Web Vitals 2026 Complete Guide](https://senorit.de/en/blog/core-web-vitals-2026)
- [Core Web Vitals Optimization Guide](https://skyseodigital.com/core-web-vitals-optimization-complete-guide-for-2026/)
- [How to Track Web Vitals in React](https://oneuptime.com/blog/post/2026-01-15-track-web-vitals-lcp-fid-cls-react/view)

---

## State Management Comparison (2026)

### Current Landscape

State management in 2026 follows a **hybrid approach**:
- **React Query (TanStack Query)** for server state (~80% of server-state patterns)
- **useState/useReducer + Context** for local and environment state
- **Lightweight stores** (Zustand, Jotai) for shared client state
- **Redux Toolkit** for large, multi-team enterprise projects

Zustand has seen 30%+ year-over-year growth and appears in ~40% of projects.

### Redux Toolkit

**Best For:** Large, long-lived enterprise apps with 5+ developers needing strict patterns.

**Characteristics:**
- Default way to use Redux in 2026
- Cuts boilerplate compared to classic Redux
- Integrates with React-Redux hooks
- RTK Query for data fetching, caching, background sync
- Strong TypeScript support
- Powerful Redux DevTools

**When to Choose:**
- Multi-team coordination needed
- Strict architectural patterns required
- Time-travel debugging valuable
- Complex state machines
- Need middleware ecosystem

### Zustand

**Best For:** Mid-size apps with moderate shared state needs.

**Characteristics:**
- Small, fast, scalable
- Hook-based API
- Flux-inspired but not strict
- Minimal boilerplate
- **No Provider wrapper required** (major difference from Redux)
- Simple API: `create()` a store, use it anywhere
- TypeScript-friendly

**When to Choose:**
- Want simplicity without sacrificing power
- Prefer hooks over components
- Don't need Redux DevTools
- Team is small to medium
- State is moderate in complexity

### React Context API

**Best For:** Localized or small-scale state sharing.

**Characteristics:**
- Built into React
- Prevents prop drilling
- Provider/Consumer pattern
- Works well with useState/useReducer

**When to Choose:**
- State is truly local to a component subtree
- Performance isn't critical (Context re-renders consumers)
- Simple theme or i18n state
- Avoid for frequent updates (performance issues)

### Signals (Jotai, Nanostores)

**Best For:** Fine-grained reactivity needs.

**Characteristics:**
- Atomic state updates
- Minimal re-renders
- Similar philosophy to Zustand but more granular
- Growing adoption for micro-frontend architectures

### Decision Framework

```
Server state? → React Query / TanStack Query
Global client state (complex)? → Redux Toolkit
Global client state (simple)? → Zustand or Jotai
Local component state? → useState/useReducer
Prevent prop drilling? → Context API (for non-frequent updates)
```

**Sources:**
- [Zustand Comparison](https://zustand.docs.pmnd.rs/getting-started/comparison)
- [Top 5 React State Management Tools in 2026](https://www.syncfusion.com/blogs/post/react-state-management-libraries)
- [Redux vs Zustand vs Context API in 2026](https://medium.com/@sparklewebhelp/redux-vs-zustand-vs-context-api-in-2026-7f90a2dc3439)
- [State Management Comparison](https://prakashinfotech.com/state-management-comparing-redux-toolkit-zustand-and-react-context)

---

## CSS Architecture and Design Tokens

### Design Token Strategy

**Definition:**
Design tokens are low-level design decisions (colors, spacing, fonts, radii, shadows, animations, breakpoints) stored as variables that CSS frameworks consume to generate utilities.

**Tailwind CSS Integration:**
Tailwind v4 introduces `@theme` blocks where tokens are declared:
```css
@theme {
  --color-brand-primary: #3b82f6;
  --spacing-unit: 0.25rem;
  --font-sans: 'Inter', system-ui, sans-serif;
}
```

**Benefits:**
- Centralized control over design decisions
- Platform-agnostic (can export to iOS, Android, web)
- Consistent UIs across projects
- Easy adaptation to design changes without refactoring
- Single source of truth

### CSS Modules

**Scoping Strategy:**
CSS Modules provide local scoping to prevent class name collisions:
```javascript
import styles from './Button.module.css';
<button className={styles.primary}>Click</button>
```

**Benefits:**
- Encapsulated component styles
- No global namespace pollution
- Works with any preprocessor (Sass, PostCSS)
- Can consume design tokens

**When to Use:**
- Need stronger style isolation than Tailwind
- Prefer co-located CSS files
- Working with legacy codebases
- Team prefers traditional CSS authoring

### Tailwind CSS

**Utility-First Approach:**
Compose styles from low-level utility classes:
```html
<button class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
  Click me
</button>
```

**Design Token Integration:**
Define tokens in `tailwind.config.js` or `@theme`:
```javascript
theme: {
  extend: {
    colors: {
      brand: {
        primary: 'var(--color-brand-primary)',
      }
    }
  }
}
```

**Best Practices:**
- Document design system in Storybook
- Create reusable component patterns
- Extract repeated class combinations to components
- Use `@apply` sparingly (defeats the purpose of utility-first)
- Enforce consistent spacing, colors, typography

### Architecture Evolution

**BEM → Tailwind → Design Tokens:**
- **BEM**: Structured naming conventions for maintainability
- **Tailwind**: Utility-first approach for rapid development
- **Design Tokens**: Foundation variables enabling robust, scalable architecture

Modern approach: Combine all three:
1. Design tokens as single source of truth
2. Tailwind consumes tokens to generate utilities
3. BEM-like component structure for reusable patterns

**Sources:**
- [Tailwind Design Tokens Complete Guide](https://nicolalazzari.ai/articles/integrating-design-tokens-with-tailwind-css)
- [CSS Architecture: From BEM to Tailwind to Tokens](https://www.superflex.ai/blog/css-architecture)
- [Tailwind CSS 4 @theme Guide](https://medium.com/@sureshdotariya/tailwind-css-4-theme-the-future-of-design-tokens-at-2025-guide-48305a26af06)
- [Tailwind CSS Best Practices 2025-2026](https://www.frontendtools.tech/blog/tailwind-css-best-practices-design-system-patterns)

---

## Accessibility Implementation

### ARIA Authoring Practices Guide (APG)

The APG describes how to apply accessibility semantics to common design patterns and widgets, providing:
- Design patterns for interactive components
- Functional examples with code
- In-depth guidance for fundamental practices
- Keyboard interaction patterns
- ARIA attribute usage

**Sources:** [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)

### Focus Management

**aria-activedescendant Pattern:**
For composite widgets (listbox, tree, grid), manage focus programmatically:
```html
<div role="listbox" aria-activedescendant="option-2">
  <div role="option" id="option-1">Option 1</div>
  <div role="option" id="option-2">Option 2</div>
  <div role="option" id="option-3">Option 3</div>
</div>
```

**Programmatic Focus Movement:**
Move focus in response to user actions:
- Modal dialogs: Move focus into modal on open, return to trigger on close
- Form validation errors: Move focus to first error
- Dynamic content: Move focus to new content when appropriate
- Keyboard navigation: Manage focus for arrow key navigation in composite widgets

### ARIA Roles and Attributes

**Role Taxonomy:**
ARIA introduces roles describing element purpose:
- `role="button"` - Clickable functionality (when not using `<button>`)
- `role="dialog"` - Modal or popup requiring focus management
- `role="navigation"` - Navigation landmarks
- `role="search"` - Search functionality
- `role="alert"` - Important, time-sensitive messages

**Key Attributes:**
- `aria-label` - Accessible name when visual label doesn't exist
- `aria-labelledby` - Reference to element(s) providing label
- `aria-describedby` - Reference to element(s) providing description
- `aria-hidden` - Hide from accessibility tree
- `aria-live` - Announce dynamic content changes
- `aria-expanded` - Collapsed/expanded state
- `aria-selected` - Selection state in lists/tabs

### Modal and Dialog Patterns

**Required Attributes:**
```html
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title" aria-describedby="dialog-desc">
  <h2 id="dialog-title">Confirmation</h2>
  <p id="dialog-desc">Are you sure you want to proceed?</p>
  <button>Cancel</button>
  <button>Confirm</button>
</div>
```

**Focus Management:**
- On open: Move focus to modal (first focusable element or close button)
- During: Trap focus within modal (no escaping to background)
- On close: Return focus to trigger element

**Keyboard Support:**
- Escape key closes modal
- Tab cycles through focusable elements within modal
- Enter/Space activates buttons

### Best Practices

**Native HTML First:**
Use native HTML elements whenever possible. ARIA is for custom widgets without HTML equivalents.

**WCAG 2.2 Compliance:**
Target AA level as minimum:
- Perceivable: Text alternatives, captions, adaptable layout
- Operable: Keyboard accessible, sufficient time, seizure prevention
- Understandable: Readable, predictable, input assistance
- Robust: Compatible with assistive technologies

**Testing:**
- Screen reader testing (NVDA, JAWS, VoiceOver)
- Keyboard-only navigation
- Automated tools (axe, Lighthouse)
- Manual testing with real users

**Sources:**
- [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [Focus Management Guide](https://govtnz.github.io/web-a11y-guidance/ka/accessible-ux-best-practices/keyboard-a11y/keyboard-focus/focus-management.html)
- [React Accessibility Best Practices](https://www.allaccessible.org/blog/react-accessibility-best-practices-guide)
- [ARIA Labels Implementation Guide](https://www.allaccessible.org/blog/implementing-aria-labels-for-web-accessibility)

---

## Testing with Vitest and Playwright

### Testing Strategy in 2026

**Layered Full-Stack Strategy:**
1. **Unit tests**: Vitest (for Vite/ESM) or Jest (legacy/enterprise)
2. **Component tests**: React Testing Library with Vitest Browser Mode
3. **Integration tests**: MSW (Mock Service Worker) for API mocking
4. **E2E tests**: Playwright or Cypress for 3-5 critical flows in CI

### Vitest Browser Mode

**Component Testing in Real Browsers:**
Vitest Browser Mode runs tests in actual browser environments using Playwright, WebdriverIO, or preview mode.

**Advantages:**
- Faster feedback than full E2E tests
- Isolated component testing
- Better debugging (real browser DevTools)
- Access to browser APIs (window, document, localStorage)
- Render JSX, import CSS directly in tests

**Example:**
```javascript
import { render, screen } from '@testing-library/react';
import { test, expect } from 'vitest';
import { Button } from './Button';

test('button renders and is clickable', async () => {
  render(<Button>Click me</Button>);
  const button = screen.getByRole('button', { name: /click me/i });
  expect(button).toBeInTheDocument();
});
```

### Vitest vs Playwright

**Vitest Browser Mode:**
- Runs `component.test.tsx` **in the browser**
- Write tests the same way you write app code
- Full browser API access
- Component-level isolation
- 10-20x faster than Jest on large codebases

**Playwright Component Testing:**
- Runs `component.test.tsx` **in Node.js**
- Message channel for browser communication
- More E2E-oriented workflow
- Full page context available

### User-Focused Testing Patterns

**React Testing Library Philosophy:**
Test behavior, not implementation:
```javascript
// Good - tests user behavior
const button = screen.getByRole('button', { name: /submit/i });
await user.click(button);
expect(screen.getByText(/success/i)).toBeInTheDocument();

// Avoid - tests implementation details
expect(component.state.submitted).toBe(true);
```

**Vitest Interactivity API:**
```javascript
import { page } from '@vitest/browser/context';

test('form submission', async () => {
  await page.getByRole('textbox').fill('test@example.com');
  await page.getByRole('button').click();
  await expect(page.getByText('Success')).toBeVisible();
});
```

### Performance Benefits

Vitest's Vite integration and browser-native design provides:
- Instant hot module replacement during test development
- Parallel test execution
- Smart re-run (only changed tests)
- Native ESM support (no transpilation overhead)

**Sources:**
- [Vitest Component Testing Guide](https://vitest.dev/guide/browser/component-testing)
- [Testing in 2026 Full Stack Strategies](https://www.nucamp.co/blog/testing-in-2026-jest-react-testing-library-and-full-stack-testing-strategies)
- [Vitest & Playwright Testing Guide](https://strapi.io/blog/nextjs-testing-guide-unit-and-e2e-tests-with-vitest-and-playwright)
- [React Component Testing with Vitest Browser Mode](https://akoskm.com/react-component-testing-with-vitests-browser-mode-and-playwright/)

---

## Code Splitting, Lazy Loading, Virtualization

### Code Splitting

**Definition:**
Break down large JavaScript bundles into smaller chunks loaded on demand. Only the code needed for current view is fetched initially.

**Route-Based Code Splitting:**
The best starting point for code splitting:
```javascript
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./Dashboard'));
const Settings = lazy(() => import('./Settings'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

**Component-Based Code Splitting:**
For large components not needed on initial render:
```javascript
const HeavyChart = lazy(() => import('./HeavyChart'));
```

**Benefits:**
- Reduced initial bundle size
- Faster time-to-interactive
- Better caching (unchanged chunks stay cached)
- Scales better as application grows

### Lazy Loading

**Definition:**
Defer loading non-essential resources until needed. In React, load components only when required instead of including in initial bundle.

**Pattern:**
```javascript
const LazyComponent = React.lazy(() => import('./LazyComponent'));

function Parent() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <LazyComponent />
    </Suspense>
  );
}
```

**Error Boundaries:**
Wrap lazy components in error boundaries:
```javascript
<ErrorBoundary fallback={<ErrorMessage />}>
  <Suspense fallback={<Loading />}>
    <LazyComponent />
  </Suspense>
</ErrorBoundary>
```

**Benefits:**
- Faster initial load time
- Reduced bundle size
- Optimized resource usage
- Improved time-to-interactive

### Virtualization

**Problem:**
Rendering hundreds or thousands of list items causes performance issues:
- Large DOM size
- Memory consumption
- Slow initial render
- Janky scrolling

**Solution:**
Render only visible items in viewport using libraries like `react-window` or `react-virtualized`.

**Example with react-window:**
```javascript
import { FixedSizeList } from 'react-window';

function VirtualList({ items }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>{items[index]}</div>
      )}
    </FixedSizeList>
  );
}
```

**When to Use:**
- Lists with 100+ items
- Infinite scrolling
- Large data tables
- Chat message history
- File explorers

**Libraries:**
- `react-window` - Lightweight, modern
- `react-virtualized` - Feature-rich, larger bundle
- `@tanstack/react-virtual` - Headless, flexible

**Sources:**
- [Optimizing React Apps with Code Splitting and Lazy Loading](https://medium.com/@ignatovich.dm/optimizing-react-apps-with-code-splitting-and-lazy-loading-e8c8791006e3)
- [React Code-Splitting Official Docs](https://legacy.reactjs.org/docs/code-splitting.html)
- [React Lazy Loading Guide](https://strapi.io/blog/lazy-loading-in-react)
- [React Performance Optimization Techniques](https://www.surajon.dev/optimizing-react-applications-for-maximum-performance)

---

## Framer Motion and Animation Patterns

### Core Concepts

**Motion Component:**
Foundation of animations in Motion (formerly Framer Motion):
```javascript
import { motion } from 'motion/react';

<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  transition={{ duration: 0.5 }}
>
  Content
</motion.div>
```

**Animation Props:**
- `initial` - Starting values when element enters DOM
- `animate` - Target values to animate to
- `exit` - Values when element leaves DOM (requires AnimatePresence)
- `transition` - Configuration (duration, delay, easing)

### Transition Configuration

**Types:**
```javascript
// Spring physics (default)
transition={{ type: 'spring', stiffness: 100, damping: 10 }}

// Duration-based
transition={{ duration: 0.3, ease: 'easeInOut' }}

// Delay
transition={{ delay: 0.2 }}
```

**Easing Functions:**
- `easeIn`, `easeOut`, `easeInOut`
- `linear`
- Custom cubic-bezier: `[0.17, 0.67, 0.83, 0.67]`

### Enter/Exit Animations

**AnimatePresence:**
Keeps elements in DOM during exit animation:
```javascript
import { AnimatePresence, motion } from 'motion/react';

<AnimatePresence>
  {isVisible && (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 20 }}
    >
      Content
    </motion.div>
  )}
</AnimatePresence>
```

**Key Points:**
- Elements perform `exit` animation before React removes from DOM
- Requires AnimatePresence wrapper
- Use `key` prop to track element identity

### Variants

**Choreographed Animations:**
Define animation states that cascade down component tree:
```javascript
const variants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      staggerChildren: 0.1
    }
  }
};

<motion.ul variants={variants} initial="hidden" animate="visible">
  <motion.li variants={variants}>Item 1</motion.li>
  <motion.li variants={variants}>Item 2</motion.li>
  <motion.li variants={variants}>Item 3</motion.li>
</motion.ul>
```

**Benefits:**
- Synchronized animations across components
- Staggered children animations
- Cleaner code (no repeated animation props)
- Orchestration controls (delayChildren, staggerChildren)

### Advanced Patterns

**Scroll-Triggered Animations:**
```javascript
import { motion, useScroll, useTransform } from 'motion/react';

const { scrollYProgress } = useScroll();
const opacity = useTransform(scrollYProgress, [0, 1], [0, 1]);

<motion.div style={{ opacity }}>
  Fades in on scroll
</motion.div>
```

**Gesture Animations:**
```javascript
<motion.div
  whileHover={{ scale: 1.1 }}
  whileTap={{ scale: 0.95 }}
  whileFocus={{ outline: '2px solid blue' }}
>
  Interactive element
</motion.div>
```

**Layout Animations:**
Automatically animate layout changes:
```javascript
<motion.div layout>
  Content that smoothly animates position/size changes
</motion.div>
```

### Performance Best Practices

**GPU-Accelerated Properties:**
Animate these for best performance:
- `opacity`
- `transform` (translate, scale, rotate)
- `filter` (blur, brightness)

**Avoid:**
- Layout properties (width, height, padding, margin)
- Color properties (animating colors is expensive)
- Box-shadow (use scale or opacity instead)

**will-change:**
Motion automatically applies `will-change` for animated properties.

**Sources:**
- [Motion React Animation Docs](https://motion.dev/docs/react-animation)
- [Motion React Component Docs](https://motion.dev/docs/react-motion-component)
- [Advanced Animation Patterns with Framer Motion](https://blog.maximeheckel.com/posts/advanced-animation-patterns-with-framer-motion/)
- [Creating React Animations in Motion](https://blog.logrocket.com/creating-react-animations-with-motion/)

---

## Additional Research Notes

### Component Composition Patterns

**Compound Components:**
Components that work together to form a cohesive unit:
```javascript
<Select>
  <Select.Trigger>Choose option</Select.Trigger>
  <Select.Options>
    <Select.Option value="1">Option 1</Select.Option>
    <Select.Option value="2">Option 2</Select.Option>
  </Select.Options>
</Select>
```

**Render Props:**
Share code between components using a prop whose value is a function:
```javascript
<DataProvider>
  {({ data, loading }) => (
    loading ? <Spinner /> : <DataView data={data} />
  )}
</DataProvider>
```

**Hooks for Logic Reuse:**
Extract stateful logic into custom hooks:
```javascript
function useLocalStorage(key, initialValue) {
  const [value, setValue] = useState(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue];
}
```

### Performance Patterns

**Memoization:**
- `React.memo()` - Prevent unnecessary component re-renders
- `useMemo()` - Memoize expensive calculations
- `useCallback()` - Memoize function references

**When to Use:**
- Component renders frequently with same props
- Expensive calculations in render
- Passing callbacks to memoized children
- **Caution:** Premature optimization adds complexity

**Concurrent Features:**
- `useTransition()` - Mark state updates as non-urgent
- `useDeferredValue()` - Defer re-rendering of non-urgent parts
- `startTransition()` - Wrap state updates to mark as transitions

### Progressive Enhancement

**Strategy:**
1. Build core functionality with semantic HTML
2. Enhance with CSS for presentation
3. Add JavaScript for interactivity
4. Ensure graceful degradation

**React Server Components fit this model:**
- Server renders HTML
- Client hydrates for interactivity
- Progressively enhance with client-side features

### Mobile-First Responsive Design

**Breakpoint Strategy:**
```javascript
// Tailwind breakpoints
sm: '640px'   // Small devices
md: '768px'   // Medium devices
lg: '1024px'  // Large devices
xl: '1280px'  // Extra large
2xl: '1536px' // 2X extra large
```

**Container Queries:**
Component-level responsiveness based on container size, not viewport:
```css
@container (min-width: 400px) {
  .card { grid-template-columns: 1fr 1fr; }
}
```

### Form Handling

**Controlled Components:**
React state as single source of truth:
```javascript
const [value, setValue] = useState('');
<input value={value} onChange={e => setValue(e.target.value)} />
```

**Uncontrolled Components:**
Use refs for form values:
```javascript
const inputRef = useRef();
<input ref={inputRef} />
// Access with inputRef.current.value
```

**Libraries:**
- `react-hook-form` - Performant, flexible, minimal re-renders
- `formik` - Feature-rich, larger bundle
- `zod` + `react-hook-form` - Type-safe validation

### Browser API Integration

**Intersection Observer:**
Detect when elements enter/leave viewport:
```javascript
const observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      // Element is visible
    }
  });
});
observer.observe(element);
```

**ResizeObserver:**
React to element size changes:
```javascript
const observer = new ResizeObserver(entries => {
  entries.forEach(entry => {
    const { width, height } = entry.contentRect;
    // React to size change
  });
});
```

**Web Storage:**
- `localStorage` - Persistent storage
- `sessionStorage` - Session-scoped storage
- Always wrap in try/catch (may be disabled)
- Max ~5-10MB per origin

---

## Summary of Key Principles

1. **React 19 shifts to server-first data flows** - Use Server Components and Actions where possible, client fetching as fallback

2. **TypeScript is the standard** - 78% enterprise adoption, start with TypeScript from day one

3. **React Spectrum provides production-grade patterns** - Three-layer architecture (Stately/Aria/Spectrum) separates state, behavior, and design

4. **Tailwind v4 is fast and modern** - Rust engine, automatic content detection, built on modern CSS features

5. **Vite is the build tool of choice** - Fast dev server, optimized production builds, excellent DX

6. **Core Web Vitals drive performance decisions** - LCP < 2.5s, INP < 200ms, CLS < 0.1

7. **State management is hybrid** - React Query for server state, Zustand/Context for client state, Redux Toolkit for enterprise

8. **Design tokens are foundational** - Single source of truth for design decisions

9. **Accessibility is not optional** - WCAG 2.2 AA minimum, native HTML first, ARIA for custom widgets

10. **Test strategy is layered** - Vitest for unit/component, Playwright for E2E, focus on user behavior

11. **Code split everything** - Route-based splitting minimum, component-based for heavy features

12. **Animate with purpose** - Framer Motion for complex animations, CSS transitions for simple ones, GPU-accelerated properties only
