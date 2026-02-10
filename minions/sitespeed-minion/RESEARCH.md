# sitespeed-minion Research: Web Performance and Core Web Vitals

This document provides the research foundation for sitespeed-minion, focused on web performance measurement, performance budgets, Core Web Vitals analysis, and loading strategy optimization. The mission is to measure, diagnose, and prescribe performance improvements that enhance user experience and support SEO objectives.

## Domain Overview

Web performance directly affects user experience, conversion rates, and search rankings. Research shows:
- 1 second delay in page load time decreases conversions by 7%
- 53% of mobile users abandon sites that take longer than 3 seconds to load
- Core Web Vitals are confirmed ranking signals in Google Search

sitespeed-minion focuses on measurement and diagnosis, not implementation. It analyzes performance, recommends optimizations, and defines budgets. Implementation teams (frontend-minion, edge-minion) execute the recommendations.

Performance is a user experience dimension, not just a technical metric. Slow pages frustrate users, reduce engagement, and erode trust.

## Core Web Vitals: LCP, INP, CLS

Core Web Vitals are three user-centric performance metrics that measure loading, interactivity, and visual stability. Google uses these as ranking signals.

### Largest Contentful Paint (LCP)

LCP measures how long it takes for the largest visible content element to render.

**Target**: < 2.5 seconds (good), 2.5-4.0 seconds (needs improvement), > 4.0 seconds (poor)

**What counts as LCP**:
- `<img>` elements
- `<image>` elements inside `<svg>`
- `<video>` elements (poster image, not video itself)
- Background images loaded via CSS `url()`
- Block-level elements containing text nodes

**Common LCP Issues**:
- Slow server response times (TTFB > 600ms)
- Render-blocking JavaScript and CSS
- Slow resource load times (large images, unoptimized fonts)
- Client-side rendering (content not in initial HTML)

**Optimization Strategies**:
- Optimize server response times (CDN, caching, efficient backend)
- Preload critical resources (`<link rel="preload">`)
- Optimize images (WebP/AVIF, responsive images, lazy loading for below-fold)
- Eliminate render-blocking resources (async/defer scripts, inline critical CSS)
- Use server-side rendering or static generation for above-the-fold content

**LCP Attribution**: LCP issues typically are server-related. Rarely isolated to a single element—if main content loads slowly, other elements likely have speed issues too.

### Interaction to Next Paint (INP)

INP measures how quickly a page responds to user interactions (clicks, taps, key presses). It replaced First Input Delay (FID) as a Core Web Vital in March 2024.

**Target**: < 200ms (good), 200-500ms (needs improvement), > 500ms (poor)

**What INP Measures**: Time from user interaction until the next visual update (paint). Captures sustained responsiveness, not just first interaction.

**Key Differences from FID**:
- FID measured only the first interaction
- INP measures all interactions throughout page lifecycle
- INP includes event processing and rendering, not just input delay

**Common INP Issues**:
- Heavy JavaScript execution (long tasks block main thread)
- Insufficient CPU resources (device limitations)
- Event handlers that perform expensive operations
- Synchronous data fetching on click (should pre-fetch or cache)

**Optimization Strategies**:
- Break up long tasks (use `setTimeout` or `requestIdleCallback`)
- Optimize JavaScript (code splitting, tree shaking, remove unused code)
- Defer non-critical scripts
- Use web workers for CPU-intensive operations
- Pre-populate common actions (navigation bars) with cached data
- Debounce/throttle event handlers

**INP captures sustained responsiveness**: A page may respond quickly at first but become sluggish as JavaScript loads and executes. INP penalizes this.

### Cumulative Layout Shift (CLS)

CLS measures unexpected layout shifts during page load. Visual instability frustrates users (clicking the wrong button because content shifted).

**Target**: < 0.1 (good), 0.1-0.25 (needs improvement), > 0.25 (poor)

**CLS Calculation**: Sum of layout shift scores for unexpected shifts. Layout shift score = (impact fraction) × (distance fraction).

**Common CLS Causes**:
- Images without explicit width and height
- Ads, embeds, iframes without reserved space
- Web fonts causing FOIT (Flash of Invisible Text) or FOUT (Flash of Unstyled Text)
- Dynamic content injection (banners, notifications)
- Animations that don't use `transform` or `opacity`

**Optimization Strategies**:
- Set explicit dimensions on images and video (`width` and `height` attributes)
- Reserve space for ads and embeds (min-height, aspect-ratio)
- Use `font-display: swap` or `font-display: optional` to manage web font loading
- Avoid inserting content above existing content (unless triggered by user)
- Use CSS transforms for animations (not top/left/width/height)
- Preload fonts and critical images

**CLS and User Expectations**: CLS only counts unexpected shifts. Shifts triggered by user interaction (clicking a button that reveals content) don't count.

## Lighthouse Performance Audits and Scoring

Google Lighthouse is an open-source tool that audits web pages for performance, accessibility, best practices, and SEO. Lighthouse Performance score (0-100) is weighted across multiple metrics.

### Lighthouse Scoring Weights (v11+)

**Core Web Vitals (weighted heavily)**:
- **LCP**: 25%
- **CLS**: 25%
- **Total Blocking Time (TBT)**: 30% (lab proxy for INP)

**Additional Metrics**:
- **Speed Index**: 10% (how quickly content is visually displayed)
- **First Contentful Paint (FCP)**: 10% (time until first text/image rendered)

**Total**: 100% score = weighted average of individual metric scores.

### Lighthouse Metrics Explained

**First Contentful Paint (FCP)**: Time until the first text, image, or canvas renders.
- **Good**: < 1.8s
- **Needs Improvement**: 1.8-3.0s
- **Poor**: > 3.0s

**Speed Index**: How quickly content is visually populated during load. Measures visual progress over time.
- **Good**: < 3.4s
- **Needs Improvement**: 3.4-5.8s
- **Poor**: > 5.8s

**Total Blocking Time (TBT)**: Sum of time the main thread is blocked by long tasks (> 50ms). Lab proxy for FID/INP.
- **Good**: < 200ms
- **Needs Improvement**: 200-600ms
- **Poor**: > 600ms

**Time to Interactive (TTI)**: Time until page is fully interactive (deprecated in Lighthouse v10, less relevant than TBT/INP).

### Lighthouse Opportunities and Diagnostics

**Opportunities**: Recommendations with estimated savings (e.g., "Properly size images: Est. savings 1.2s").

**Common Opportunities**:
- Eliminate render-blocking resources
- Properly size images
- Serve images in next-gen formats (WebP, AVIF)
- Efficiently encode images
- Enable text compression
- Reduce unused JavaScript
- Reduce unused CSS
- Minify JavaScript/CSS
- Preconnect to required origins
- Preload key requests

**Diagnostics**: Additional information about performance (no estimated savings).

**Common Diagnostics**:
- Minimize main-thread work
- Reduce JavaScript execution time
- Avoid enormous network payloads
- Serve static assets with efficient cache policy
- Avoid an excessive DOM size

### Lighthouse CI Integration

Lighthouse CI enables automated performance testing in CI/CD pipelines.

**Setup Example (GitHub Actions)**:
```yaml
name: Lighthouse CI
on: [pull_request]
jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: treosh/lighthouse-ci-action@v9
        with:
          urls: |
            https://example.com
            https://example.com/about
          uploadArtifacts: true
```

**Assertions**: Set minimum score thresholds to fail builds if performance degrades.

```javascript
// lighthouserc.json
{
  "ci": {
    "assert": {
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "first-contentful-paint": ["error", {"maxNumericValue": 2000}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}]
      }
    }
  }
}
```

## Performance Budget Tools and Enforcement

Performance budgets define acceptable limits for page weight, load times, and metric scores. Budgets prevent performance regressions by failing builds that exceed limits.

### Defining Performance Budgets

**Metric-Based Budgets**: Set targets for performance metrics.
- LCP < 2.5s
- INP < 200ms
- CLS < 0.1
- FCP < 1.8s
- TBT < 200ms

**Resource-Based Budgets**: Limit total page weight by resource type.
- Total page size: < 1.5 MB
- JavaScript: < 300 KB (compressed)
- CSS: < 50 KB (compressed)
- Images: < 500 KB (compressed)
- Fonts: < 100 KB

**Quantity-Based Budgets**: Limit number of resources.
- Total HTTP requests: < 50
- JavaScript files: < 10
- Third-party scripts: < 5

**Best Practice**: Start with current baseline, then set 20% improvement targets. Gradually tighten budgets over time.

### bundlesize Tool

bundlesize is a npm package that checks JavaScript bundle sizes in CI/CD.

**Setup**:
```json
// package.json
{
  "bundlesize": [
    {
      "path": "./dist/bundle.js",
      "maxSize": "150 KB"
    },
    {
      "path": "./dist/vendor.js",
      "maxSize": "100 KB"
    }
  ]
}
```

**CI Integration**:
```yaml
# GitHub Actions
- run: npm run build
- run: npx bundlesize
```

**Fails builds** if bundle sizes exceed limits. Prevents JavaScript bloat.

### SpeedCurve Performance Budgets

SpeedCurve is a performance monitoring service with comprehensive budget features.

**Budget Types in SpeedCurve**:
- Lighthouse metric scores (LCP, CLS, Speed Index)
- Resource sizes (JavaScript, CSS, images, fonts)
- Total page weight
- Request counts
- Custom metrics (via User Timing API)

**Alerts**: SpeedCurve can trigger alerts (email, Slack, PagerDuty) when budgets are violated.

**Synthetic vs. RUM Budgets**: Set budgets for both synthetic (lab) tests and RUM (field) data.

**Synthetic Budgets**: Run in controlled environments (consistent device, network, location). Useful for catching regressions in CI/CD.

**RUM Budgets**: Monitor field data from real users. Catch performance issues affecting actual users (device diversity, network variability).

### Performance Budget Workflow

1. **Baseline**: Measure current performance across key pages
2. **Define**: Set budgets for metrics, resources, and quantities
3. **Implement**: Integrate budget checks into CI/CD
4. **Monitor**: Track performance over time with RUM
5. **Alert**: Get notified when budgets are violated
6. **Iterate**: Tighten budgets gradually as performance improves

**Budget Violations**: When budgets are exceeded, investigate root cause, optimize, and re-test. Don't just raise budgets—that defeats the purpose.

## Image Optimization Strategy

Images are often the heaviest resources on web pages. Optimizing images can reduce page weight by 50-70%.

### Modern Image Formats

**AVIF (AV1 Image File Format)**:
- Up to 60% smaller than JPEG
- Supports HDR, transparency
- Excellent compression at high quality
- Browser support: Chrome, Firefox, Safari (2021+), Edge

**WebP**:
- 25-34% smaller than JPEG
- 26% smaller than PNG (lossless)
- Supports transparency
- Wide browser support (2010+)

**JPEG XL**:
- Next-generation format, better compression than AVIF
- Lossless JPEG transcoding (convert JPEG to JPEG XL without re-encoding)
- Browser support: Limited (Chromium removed support in 2023, controversy ongoing)

**Recommendation**: Use AVIF as primary format, WebP as fallback, JPEG/PNG as final fallback.

### Responsive Images

Serve different image sizes based on device screen resolution and viewport width.

**srcset Attribute**:
```html
<img src="image-800.jpg"
     srcset="image-400.jpg 400w,
             image-800.jpg 800w,
             image-1200.jpg 1200w"
     sizes="(max-width: 600px) 400px,
            (max-width: 1000px) 800px,
            1200px"
     alt="Description">
```

**Picture Element (Format Fallback)**:
```html
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="Description">
</picture>
```

**Benefits**:
- Mobile users download smaller images (reduced payload)
- Desktop users get high-resolution images
- Reduces LCP by loading appropriately sized images

### Lazy Loading

Delay loading images until they are needed (user scrolls near them).

**Native Lazy Loading**:
```html
<img src="image.jpg" loading="lazy" alt="Description">
```

**Browser Support**: All modern browsers (Chrome, Firefox, Safari, Edge)

**Critical Images**: Do NOT lazy load above-the-fold images. Lazy loading increases LCP for visible images.

**Best Practice**: Lazy load images below the fold. Eager load (default) or preload above-the-fold images.

### Image Compression

**Lossless Compression**: Reduces file size without quality loss (PNG, WebP lossless, AVIF lossless).

**Lossy Compression**: Reduces file size with acceptable quality loss (JPEG, WebP lossy, AVIF lossy).

**Compression Tools**:
- **ImageOptim** (macOS): GUI for compressing images
- **Squoosh** (web): Google's web-based image compressor
- **Sharp** (Node.js): Fast image processing library
- **ImageMagick**: Command-line image manipulation

**CDN Image Optimization**: Cloudflare, Fastly, and Cloudinary automatically optimize and serve images in optimal formats.

### CDN and Image Delivery

**Content Delivery Networks (CDNs)**: Distribute images from servers geographically close to users, reducing latency.

**Image CDN Features**:
- Automatic format conversion (AVIF, WebP, JPEG fallback)
- Automatic resizing based on device
- Compression optimization
- Lazy load placeholder generation (LQIP: Low Quality Image Placeholder)

**Cloudflare Image Resizing**:
```html
<img src="https://example.com/cdn-cgi/image/width=800,format=auto/image.jpg">
```

**Fastly Image Optimizer**: Automatically serves AVIF or WebP based on browser support.

## Loading Strategy Optimization

Loading strategies control when and how resources are fetched and parsed.

### Resource Hints

**dns-prefetch**: Resolve DNS early for third-party domains.
```html
<link rel="dns-prefetch" href="https://fonts.googleapis.com">
```

**preconnect**: Establish early connection (DNS + TCP + TLS handshake) for critical origins.
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
```

**prefetch**: Fetch low-priority resources during idle time for future navigation.
```html
<link rel="prefetch" href="/next-page.html">
```

**preload**: Fetch high-priority resources early in page load.
```html
<link rel="preload" href="/critical.css" as="style">
<link rel="preload" href="/hero-image.jpg" as="image">
```

**modulepreload**: Preload JavaScript modules.
```html
<link rel="modulepreload" href="/app.js">
```

**Use Cases**:
- **preconnect**: Third-party fonts, analytics (Google Fonts, Google Analytics)
- **preload**: Critical CSS, hero images, fonts
- **dns-prefetch**: Fallback for older browsers (preconnect preferred)
- **prefetch**: Next page resources (pagination, navigation)

### Script Loading Strategies

**Synchronous (default)**: Blocks HTML parsing until script loads and executes. Slowest, causes render blocking.

**async**: Loads script in parallel, executes as soon as loaded (potentially interrupting HTML parsing).
```html
<script src="analytics.js" async></script>
```
**Use case**: Independent scripts (analytics, ads) that don't depend on DOM or other scripts.

**defer**: Loads script in parallel, executes after HTML parsing completes, in order.
```html
<script src="app.js" defer></script>
```
**Use case**: Scripts that depend on DOM or other scripts.

**Best Practice**:
- Critical scripts: Inline in `<head>` (small) or use preload + defer
- Analytics/ads: async
- Application scripts: defer
- Third-party widgets: async (if independent) or defer

### Critical CSS

Critical CSS is the minimal CSS required to render above-the-fold content. Inline critical CSS in `<head>` to eliminate render-blocking.

**Extraction Tools**:
- **Critical** (npm package): Extracts critical CSS automatically
- **Penthouse**: Alternative critical CSS extraction tool

**Workflow**:
1. Extract critical CSS for key page templates
2. Inline critical CSS in `<head>`
3. Load full CSS asynchronously with `media="print" onload="this.media='all'"`

**Example**:
```html
<style>
  /* inlined critical CSS here */
</style>
<link rel="preload" href="/full.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
```

**Tradeoff**: Increases HTML size. Only inline truly critical CSS (< 10 KB).

## Performance Monitoring: RUM vs. Synthetic

Performance monitoring provides ongoing visibility into page speed. Two approaches: Real User Monitoring (RUM) and Synthetic Monitoring.

### Real User Monitoring (RUM)

RUM collects performance data from actual users in the browser.

**How RUM Works**:
- JavaScript snippet on each page captures metrics
- Metrics sent to monitoring service (Google Analytics, SpeedCurve, Cloudflare Web Analytics)
- Data aggregated by device, location, connection type

**Metrics Collected**:
- Core Web Vitals (LCP, INP, CLS)
- Navigation Timing API metrics (TTFB, domContentLoaded, onLoad)
- Resource Timing API (individual resource load times)
- Custom metrics (User Timing API)

**RUM Advantages**:
- Real-world data from actual users
- Device and network diversity
- Geographic distribution
- Identifies user segments with poor performance

**RUM Limitations**:
- No data until users visit the page
- Affected by outliers (slow devices, poor networks)
- Privacy concerns (user data collection)

**RUM Tools**:
- **Chrome User Experience Report (CrUX)**: Google's public RUM dataset
- **Google Analytics 4**: RUM metrics (experimental)
- **SpeedCurve RUM**: Comprehensive RUM with Core Web Vitals
- **Cloudflare Web Analytics**: Privacy-friendly RUM
- **New Relic**: Full-stack monitoring with RUM

### Synthetic Monitoring (Lab Testing)

Synthetic monitoring tests pages in controlled environments with simulated users.

**How Synthetic Works**:
- Automated tools (Lighthouse, WebPageTest) load pages from specific locations
- Consistent device, network, browser configuration
- Tests run on schedule (every 15 minutes, hourly, daily)

**Synthetic Advantages**:
- Consistent, reproducible results
- Test before users encounter issues
- Catch regressions early in CI/CD
- Test staging environments

**Synthetic Limitations**:
- Doesn't reflect real-world diversity
- Single device, single network condition
- May miss issues only affecting certain user segments

**Synthetic Tools**:
- **Lighthouse**: Chrome DevTools, Lighthouse CI
- **WebPageTest**: Free, comprehensive testing with filmstrips
- **SpeedCurve Synthetic**: Scheduled Lighthouse tests with historical tracking
- **Calibre**: Lighthouse-based synthetic monitoring

### Best Practice: Combine RUM and Synthetic

- **Synthetic for development**: Catch regressions in CI/CD, test staging environments
- **RUM for production insights**: Monitor real users, identify affected segments
- **Synthetic as early warning**: Detects issues before they affect users
- **RUM as validation**: Confirms issues affecting real users

**Workflow**:
1. Develop with Lighthouse locally
2. Gate PRs with Lighthouse CI (synthetic)
3. Deploy to production
4. Monitor with RUM
5. Investigate alerts with synthetic tests for reproducibility

## Bundle Size Analysis and Reduction

JavaScript bundle size directly affects load times and parse/execution time. Reducing bundle size improves LCP, FCP, and TBT.

### Bundle Analysis Tools

**webpack-bundle-analyzer**: Visualizes webpack bundle contents.
```bash
npm install --save-dev webpack-bundle-analyzer
```

```javascript
// webpack.config.js
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

module.exports = {
  plugins: [new BundleAnalyzerPlugin()]
};
```

**source-map-explorer**: Analyzes bundle size using source maps.
```bash
npm install --save-dev source-map-explorer
source-map-explorer bundle.js bundle.js.map
```

**Rollup Plugin Visualizer**: Bundle visualization for Rollup.

### Reduction Strategies

**Code Splitting**: Split code into smaller chunks loaded on demand.
```javascript
// Dynamic import
const module = await import('./heavy-module.js');
```

**Tree Shaking**: Remove unused code (requires ES6 modules).

**Minification**: Remove whitespace, rename variables (UglifyJS, Terser).

**Compression**: Gzip or Brotli compression (server-side).

**Remove Unused Dependencies**: Audit and remove packages not actively used.
```bash
npm install --save-dev depcheck
npx depcheck
```

**Optimize Dependencies**: Replace heavy libraries with lighter alternatives.
- Moment.js (67 KB) → date-fns (2 KB per function) or Intl.DateTimeFormat (native)
- Lodash (full: 71 KB) → Import only needed functions or use native JS

**Differential Serving**: Serve modern ES6+ bundles to modern browsers, legacy bundles to old browsers.

## Third-Party Script Impact Analysis

Third-party scripts (analytics, ads, social widgets) often dominate page weight and block the main thread.

### Common Third-Party Scripts

**Analytics**: Google Analytics, Adobe Analytics, Mixpanel

**Ads**: Google AdSense, Taboola, Outbrain

**Social Media**: Facebook Pixel, Twitter embeds, Instagram embeds

**Tag Managers**: Google Tag Manager, Segment

**A/B Testing**: Optimizely, VWO

**Customer Support**: Intercom, Zendesk, Drift

### Performance Impact

**JavaScript Bloat**: Third-party scripts add 200-500 KB+ of JavaScript.

**Main Thread Blocking**: Analytics and tag managers execute on the main thread, increasing TBT and delaying INP.

**Network Overhead**: Each third-party domain requires DNS lookup, TCP handshake, TLS negotiation.

**Privacy Concerns**: Third-party scripts track users, potentially violating privacy regulations.

### Optimization Strategies

**Defer Loading**: Load third-party scripts after page load.
```html
<script src="analytics.js" defer></script>
```

**Async Loading**: Load scripts without blocking HTML parsing.
```html
<script src="analytics.js" async></script>
```

**Lazy Load Widgets**: Load social embeds only when user scrolls to them (IntersectionObserver).

**Self-Host**: Self-host scripts to reduce third-party connections (Google Fonts, Google Analytics alternatives).

**Audit Regularly**: Remove unused third-party scripts. Every script adds weight and risk.

**Use Facade Techniques**: Display static placeholder for embeds until user clicks (e.g., YouTube embed facade).

## Web Font Loading Optimization

Web fonts improve typography but can cause layout shifts (CLS) and delay content rendering.

### Font Display Strategies

**font-display: swap**: Show fallback font immediately, swap when web font loads. Minimizes FOIT (Flash of Invisible Text) but may cause FOUT (Flash of Unstyled Text).
```css
@font-face {
  font-family: 'MyFont';
  src: url('/fonts/myfont.woff2') format('woff2');
  font-display: swap;
}
```

**font-display: optional**: Use web font only if cached or loads very quickly. Prevents layout shifts.

**font-display: fallback**: Brief invisible period (100ms), then swap if loaded within 3 seconds.

**font-display: block**: Invisible until web font loads (up to 3 seconds). Avoid unless web font is critical.

**Recommendation**: `swap` for most use cases, `optional` for best CLS.

### Font Optimization

**WOFF2 Format**: Use WOFF2 (30% smaller than WOFF, 50% smaller than TTF).

**Subset Fonts**: Include only needed glyphs (Latin, Latin Extended, not full Unicode).
```css
@font-face {
  font-family: 'MyFont';
  src: url('/fonts/myfont-latin.woff2') format('woff2');
  unicode-range: U+0000-00FF; /* Latin */
}
```

**Preload Fonts**: Load fonts early with preload.
```html
<link rel="preload" href="/fonts/myfont.woff2" as="font" type="font/woff2" crossorigin>
```

**Variable Fonts**: Single file with multiple weights/styles (reduces HTTP requests).

## Best Practices Summary

### Core Web Vitals Optimization

- **LCP < 2.5s**: Optimize server response, preload critical resources, use CDN, optimize images
- **INP < 200ms**: Break up long tasks, optimize JavaScript, defer non-critical scripts
- **CLS < 0.1**: Set image dimensions, reserve space for ads, use font-display, avoid injecting content above existing content

### Performance Budgets

- Define metric, resource, and quantity budgets
- Integrate budget checks into CI/CD with Lighthouse CI or bundlesize
- Monitor field data with RUM, enforce budgets with synthetic tests
- Gradually tighten budgets as performance improves

### Image Optimization

- Use modern formats (AVIF, WebP) with JPEG/PNG fallbacks
- Implement responsive images (srcset, picture)
- Lazy load below-the-fold images
- Compress images with tools (Squoosh, Sharp, ImageOptim)
- Use CDN for automatic optimization

### Loading Strategy

- Preload critical resources (fonts, hero images, critical CSS)
- Defer non-critical scripts
- Inline critical CSS (< 10 KB)
- Use resource hints (preconnect for third-party origins)

### Bundle Size Reduction

- Analyze bundles with webpack-bundle-analyzer or source-map-explorer
- Code split and lazy load heavy modules
- Remove unused dependencies with depcheck
- Replace heavy libraries with lighter alternatives

### Third-Party Scripts

- Defer or async load third-party scripts
- Lazy load embeds and widgets
- Audit and remove unused scripts regularly
- Use facade techniques for heavy embeds (YouTube, Vimeo)

### Monitoring

- Combine RUM (field data) and synthetic (lab data) monitoring
- Use RUM for production insights, synthetic for CI/CD gates
- Monitor Core Web Vitals trends over time
- Set up alerts for budget violations

## HTTP Archive and Chrome UX Report

**HTTP Archive**: The Web Almanac provides annual performance benchmarks based on millions of websites. Key findings from 2025:
- JavaScript payloads increased 16% (540 KB to 757 KB median)
- Analysis covers Core Web Vitals (LCP, INP, CLS) plus emerging features (Early Hints, Speculation Rules)
- Data combines lab measurements (WebPageTest) with field data (Chrome UX Report)

**Chrome UX Report (CrUX)**: Google's public dataset of real-world user performance:
- Collects field data from millions of Chrome users worldwide
- Metrics updated daily, split by form factor (mobile/desktop)
- Accessible via API, BigQuery, and visualization tools
- Origin-level and page-level data available
- Primary source for Core Web Vitals field data

**Lab vs. Field Data Distinction**: HTTP Archive provides controlled lab testing (consistent environment), while CrUX provides real-world field data (actual user experiences across devices, networks, geographies).

## Lighthouse v12 Scoring (August 2024+)

**Metric Weights**:
- Total Blocking Time (TBT): 30%
- Largest Contentful Paint (LCP): 25%
- Cumulative Layout Shift (CLS): 25%
- First Contentful Paint (FCP): 10%
- Speed Index (SI): 10%

**Key Change**: Time to Interactive (TTI) removed from scoring in v12.

**Scoring Mechanism**: Raw metric values (milliseconds) are converted to 0-100 scores using log-normal distributions derived from HTTP Archive data. Overall Performance score (0-100) is weighted average of individual metrics. Score >90 is "good."

## Performance Regression Detection in CI/CD

**Tools for CI/CD Integration**:
- **Lighthouse CI**: Asserts on metric thresholds, fails builds on regression
- **Apache JMeter**: Load testing with CI integration (Jenkins, GitHub Actions)
- **Grafana K6**: Modern load testing with scripting (JavaScript-based)
- **Gatling**: Performance testing with excellent CI/CD support
- **bundlesize**: Bundle size regression detection (npm package)

**Detection Methods**:
- Capture median and percentile response times during stable builds as baselines
- Compare subsequent test runs using statistical deviation (not fixed thresholds)
- Track performance drift across releases with trend dashboards
- Correlate metrics (CPU, memory, I/O, API timing) to identify regression sources

**Best Practices**:
- Run performance tests on every build (automated)
- Parallelize tests across environments to reduce cycle time
- Visualize performance trends over time to detect gradual degradation
- Use statistical analysis (not hard thresholds) to reduce false positives

## Modern Image Formats: AVIF vs. WebP vs. JPEG XL (2026)

**AVIF (AV1 Image File Format)**:
- 50% smaller than JPEG, significantly smaller than WebP in many cases
- Best compression at low-to-medium quality levels
- Full modern browser support (Chrome, Firefox, Safari, Edge)
- Recommended as primary format for web delivery

**WebP**:
- 25-34% smaller than JPEG, 26% smaller than PNG (lossless)
- Widespread browser support (since 2010+)
- Most practical for compatibility across all browsers
- Recommended as fallback for AVIF

**JPEG XL**:
- Claims 55% smaller than JPEG, 25% smaller than AVIF (high-quality images)
- Exceptional performance at higher quality levels
- Backward-compatible with JPEG
- Limited browser support (Chromium removed support in 2023, controversy ongoing)
- Not recommended for production web use in 2026 due to lack of support

**Recommended Strategy**: Serve AVIF first, WebP as fallback, JPEG/PNG as final safety net (using `<picture>` element).

## Sources

- [Lighthouse Performance Scoring](https://www.debugbear.com/docs/metrics/lighthouse-performance)
- [Core Web Vitals Optimization Guide 2026](https://skyseodigital.com/core-web-vitals-optimization-complete-guide-for-2026/)
- [Performance Budgets Guide (SpeedCurve)](https://www.speedcurve.com/blog/performance-budgets/)
- [Image Optimization Guide 2026](https://requestmetrics.com/web-performance/high-performance-images/)
- [Real User Monitoring vs. Synthetic Monitoring](https://www.atatus.com/blog/real-user-monitoring-vs-synthetic-monitoring/)
- [Fastly Performance Optimization](https://www.fastly.com/documentation/guides/compute/)
- [Cloudflare Workers Performance](https://workers.cloudflare.com/)
- [HTTP Archive Performance 2025](https://almanac.httparchive.org/en/2025/performance)
- [Chrome UX Report Overview](https://developer.chrome.com/docs/crux)
- [Lighthouse Scoring Methodology](https://developer.chrome.com/docs/lighthouse/performance/performance-scoring)
- [Performance Testing in CI/CD Pipelines](https://www.withcoherence.com/articles/performance-testing-in-cicd-pipelines-best-practices)
- [AVIF vs WebP Comparison 2026](https://imagepulser.com/blog/avif-vs-webp-which-wins-in-2026)
