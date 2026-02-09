# Edge-Minion Research

Research backing the edge-minion agent system prompt, covering CDN architecture, edge computing, caching strategies, and content delivery optimization.

## Edge Computing Platforms

### Fastly Compute@Edge

Fastly's Compute platform compiles custom code to WebAssembly and runs it at the edge using the WebAssembly System Interface. This architecture enables full request/response control at the edge with near-native performance.

**VCL to Compute Migration**: All VCL service logic can be accomplished in Compute services in any supported language. Common patterns from VCL have equivalent Compute code. Service chaining allows customers to create VCL-to-Compute-to-VCL "sandwich" architectures to leverage features from both platforms.

**Infrastructure as Code Pattern**: Compute versions can be stored with source code, allowing coordination of edge releases with backend updates and making them dependent.

**Edge Data Storage**: Key-value storage at the edge in versionless containers for fast data access without origin round trips.

### Cloudflare Workers

Cloudflare Workers provide JavaScript-based edge compute with multiple storage backends:

**Workers KV**: Low-latency key-value storage optimized for high-read, low-write workloads (thousands of RPS reads, 1 write RPS per unique key limit). Frequently read keys benefit from internal caching with latencies in the 500µs to 10ms range. Ideal for session data, credentials, and configuration data that doesn't require immediate consistency.

**R2 Storage**: Object storage for large unstructured data without egress bandwidth fees, suitable for media assets and user-uploaded files.

**D1**: SQL-based native serverless database for structured data at the edge.

**Durable Objects**: Provide low-latency coordination and consistent storage through global uniqueness and transactional storage API. SQLite storage (recommended for new Durable Objects) offers relational queries, indexes, transactions, and better performance than legacy key-value backed objects. Enable concurrent writes using multi-version concurrency control (MVCC) and fine-grained locking while maintaining ACID compliance.

**Multi-Storage Architecture**: Applications commonly use KV for session data, R2 for large files, and D1 or Durable Objects for transactional data—choosing the right storage for each access pattern.

## HTTP Caching Standards

### RFC 9111: HTTP Caching (2022)

RFC 9111 is the current HTTP caching standard, defining how caches should store and reuse HTTP responses across browser caches, proxies, and CDNs.

**Cache-Control Header**: Prescribes caching behavior for intermediary caches between client and origin server.

**Stale-While-Revalidate**: Allows caches to reuse stale responses while revalidating in the background. After a response becomes stale, the cache can serve it for requests within a specified window while triggering background revalidation. This effectively hides the latency penalty of revalidation from clients.

**Stale-If-Error**: Enables serving stale content when the origin is unavailable, trading freshness for stability.

### Surrogate Keys

Surrogate-Key headers allow tagging cached objects with space-separated identifiers. When the cache processes a response with Surrogate-Key headers, it associates those tags with the request URL. This enables purging by tag rather than URL—critical for managing complex dependencies where one entity appears across multiple pages.

## CDN Cache Invalidation

### Invalidation Methods

**Single URL Purge**: Recommended method for targeted cache invalidation. Removes specific cached objects by exact URL.

**Wildcard/Path Pattern Purges**: Invalidate all cached objects matching a path pattern (e.g., `/products/*`, `/static/css/*`). Useful for front-end builds, catalog updates, or template changes.

**Tag/Surrogate Key Purges**: Advanced pattern where responses are tagged during caching, then purged by tag. Any object with that tag is removed. Essential for complex dependency management (e.g., a product appearing in recommendations, category pages, search results, and landing pages).

**Full Account Purges**: Rarely recommended; only for complete cache resets.

### Modern Invalidation Strategies

**Versioned Assets with Soft Purging**: Most reliable approach combines content-addressed filenames for static assets (e.g., `main.ab12c.js`) with soft purging of entry points. Build tools (webpack, Vite, Parcel) generate unique filenames on each build, making aggressive caching safe. Entry points (HTML) use soft purge options like stale-while-revalidate for stability and lower latency.

**Automation**: Trigger purges via dashboard, API, or CI/CD hooks for deployment integration.

## Multi-CDN Architecture

### Multi-CDN Use Cases

- Establishing extra redundancy for mission-critical events
- Enhancing performance in geographic regions where one CDN has specialized coverage
- High availability requirements across many regions
- Performance variance between providers in different areas
- Regulatory or commercial risk distribution across vendors
- Absorbing large traffic bursts that exceed single-provider capacity

### Failover Mechanisms

**DNS-Based Failover**: Common but has limitations due to TTL and DNS resolver caching. Use low TTLs for critical records and DNS-based health checks from multiple locations to automatically switch when endpoints fail.

**Orchestration Layer**: For multi-CDN setups, use DNS load balancing or an orchestration layer for weighted steering and health-aware changes.

**Per-Request Error Tracking**: Origin Shield implementations use per-request error tracking across KPIs to trigger automatic failover to secondary Origin Shield regions.

### Origin Shielding

Origin shielding inserts a stable caching layer in front of the origin that all cache miss traffic flows through. In multi-CDN environments, this provides:

- **Single Upstream Stream**: Origin sees one controlled cache miss stream per region instead of multiple competing streams from different CDNs
- **Reduced Origin Load**: Cuts origin requests, smooths out failovers, and makes cache hit ratios consistent across providers
- **Fast Failover Recovery**: During provider or regional failovers, the shield stays hot and refills the new edge quickly
- **Pre-Warming**: New builds can be staged and pre-warmed in the shield so edges never see a cold cache

## Load Balancing and Geo-Routing

### Geographic Load Balancing

Distributes traffic based on user physical location, routing requests to the nearest edge server to minimize latency. Proximity-based routing directs data to geographically closest edge servers.

### Traffic Distribution Algorithms

Load balancers route traffic based on algorithms including:
- Round-robin
- Least connections
- Geographic proximity
- Device capabilities and current workload
- Network conditions

### Global Server Load Balancing (GSLB)

DNS GSLB makes routing decisions at the network edge, close to each user. Each edge data center runs multiple application instances managed by load balancers to distribute load and prevent overload. GSLB coordinates across edge data centers for global traffic management.

### Adaptive Algorithms

Modern load balancers use machine learning and AI to dynamically adjust to changing network conditions, optimizing routing decisions and resource allocation in real time.

## Edge-Side Rendering and Personalization

### Edge Rendering Architecture

Edge rendering executes rendering logic at CDN edge nodes (physical servers in globally distributed data centers). By 2026, edge SSR is projected to handle over 50% of SSR workloads, making SSR infrastructure complexity comparable to CSR deployment while maintaining performance advantages.

### A/B Testing at the Edge

Edge workers enable A/B testing directly at the edge by deploying JavaScript code that determines which page variant to display. Integration with feature flag services (Split, LaunchDarkly) or custom middleware enables efficient testing without origin round trips.

**Benefits**: Instant personalization, faster testing iteration, reduced origin load, and consistent user experience across geographies.

### Edge Rewriting

Edge rewrites enable instant personalization for faster A/B testing by modifying requests or responses at the edge based on user attributes, cookies, or feature flags.

## DDoS Protection and WAF

### WAF Configuration Best Practices

- Use WAF managed rules as baseline, add custom rules for application-specific needs
- Implement rate limiting to prevent abuse and reduce origin load
- Whitelist CDN IP ranges at firewall/load balancer level
- Place less expensive/free WAF rules at lowest numeric priority to block malicious traffic before reaching higher-priority paid rules
- Test new rules in staging to identify false positives before production deployment

### Layered Defense Architecture

Configure CDN to cache static content and route dynamic content through WAF, ensuring all traffic is inspected before reaching origin. Traffic flow: CDN acceleration → WAF inspection → origin (normal traffic only). This protects against attacks while improving response speed and availability.

### DDoS Protection Integration

Select DDoS protection services that integrate with WAF and filter incoming traffic before it reaches the WAF to mitigate large-scale attacks that could overwhelm the WAF layer.

### Monitoring and Optimization

Monitor CDN analytics and set up alerts for anomalies. Keep CDN IP lists updated for network policies. Continuously adjust WAF and DDoS settings based on traffic patterns to maintain optimal protection.

## Content Delivery Optimization

### HTTP/3 Benefits

HTTP/3 enables multiple file transfers over a single connection, resulting in faster loads, less overhead, and better support for modern web experiences. Offers significant performance improvements over HTTP/1 and HTTP/2, with enhanced reliability and security. Now widely available across major CDN providers.

### Compression Strategies

**Regular Optimization Reviews**: Revisit CDN rules, caching, compression, and network routes periodically to prevent performance decay over time.

**Build-Time Optimization**: Minification, code splitting, and image compression at build time to reduce payload size.

**Adaptive Compression**: For JPEG images to mobile devices, vary compression level based on real-time network conditions, significantly improving mobile page load times.

### Image Optimization

**Modern Formats**: AVIF and WebP offer superior compression and quality compared to JPEG and PNG, significantly reducing download size.

**Responsive Images**: Deliver appropriate image size based on user device, reducing unnecessary downloads and improving load times.

**CDN-Based Optimization**: Modern CDNs serve images with HTTP/3, apply format conversion, and handle responsive sizing automatically.

## Performance Measurement

### Time to First Byte (TTFB)

TTFB measures from request sent (after TCP connection) to first response byte. The right metric for measuring how quickly the CDN serves cached objects.

### Cache Hit Ratio

**Definition**: Percentage of requests served from cache versus origin.

**Impact**: 95% cache hit rate means 95% of requests serve in 10-20ms, only 5% require full origin trip.

**Measurement**: Track CHRedge (cache hits at very edge) and CHRglobal (overall cache hits). CDNs with the best edge caching show CHRedge and CHRglobal values close together.

**Target Metrics**: 85-95% overall cache hit ratio; 95%+ for static assets.

### Key Performance Metrics

- **Cache Hit Ratio**: Primary efficiency indicator
- **TTFB**: Broken down into network/connect versus server/origin time
- **Error Rates**: Track error responses by type and geographic distribution
- **Geographic/ISP Performance**: Measure performance variation across regions and ISPs

### Server-Timing Header

Use Server-Timing header to measure whether a request hit the CDN cache and how long the request took to reach the CDN edge server and origin.

## Connection Coalescing

### Overview

Connection coalescing (introduced in HTTP/2, continued in HTTP/3) enables accessing resources from different hostnames over the same connection when they resolve to the same server.

### Mechanism

All subresources on the same domain reuse the same TCP/TLS (or UDP/QUIC) connection without head-of-line blocking, resulting in a single connection for all subresources and reducing extraneous requests on page loads.

### ORIGIN Frame Extension

HTTP/2 and HTTP/3 ORIGIN Frame extension allows servers to send an "origin-set" to clients on an existing TLS connection, listing additional hostnames it is authorized to serve. This enables connection coalescing to edge servers without managing IP addresses.

### Performance Benefits

- Reduces TLS handshakes by roughly 50%
- Reduces render-blocking DNS queries by over 60%
- Optimizes CPU, memory, and resource utilization by reducing connection overhead

## Edge Database Patterns

### Turso/libSQL Architecture

**libSQL**: Fork of SQLite adding client/server protocol, replication, and extensions. Designed as drop-in SQLite replacement that scales globally over HTTP.

**Turso**: Managed service deploying libSQL databases with read replicas near users. Uses primary-for-writes with many read replicas model. Client SDKs connect over HTTP/WebSockets. Turso handles provisioning and automatic replica placement.

**Replication Pattern**: Ships write-ahead log (WAL) to read replicas at the edge, serving low-latency reads locally while routing writes to primary database.

**Concurrent Writes**: Turso uses MVCC and fine-grained locking to allow writes from multiple threads, overcoming SQLite's single-writer limitation while maintaining ACID compliance.

### Cloudflare D1

D1 uses Durable Objects to ensure serialized writes, contrasting with Turso's primary/replica replication pattern. Leverages Cloudflare's platform primitives for edge database functionality.

### Write Consistency Pattern

Command/Query Segregation (CQS): Use primary region for commands (writes) and edge replicas for queries (reads). Preserves strong consistency for writes while keeping reads fast. Option to block reads until replica catches up to specified replication position for read-your-writes consistency.

## Sources

- [How we migrated developer.fastly.com from VCL to Compute | Fastly](https://www.fastly.com/blog/how-we-migrated-developer-fastly-com-from-vcl-to-compute-edge)
- [Compute | Fastly Documentation](https://www.fastly.com/documentation/guides/compute/)
- [Service chaining | Fastly Documentation](https://developer.fastly.com/learning/concepts/service-chaining/)
- [Choosing a data or storage product · Cloudflare Workers docs](https://developers.cloudflare.com/workers/platform/storage-options/)
- [Overview · Cloudflare Durable Objects docs](https://developers.cloudflare.com/durable-objects/)
- [Cloudflare Workers KV · Cloudflare Workers KV docs](https://developers.cloudflare.com/kv/)
- [RFC 9111: HTTP Caching](https://www.rfc-editor.org/rfc/rfc9111.html)
- [Understanding Stale-While-Revalidate: Serving Cached Content Smartly | DebugBear](https://www.debugbear.com/docs/stale-while-revalidate)
- [About cache control headers | Fastly Documentation](https://www.fastly.com/documentation/guides/full-site-delivery/caching/about-cache-control-headers/)
- [How to Create CDN Caching Strategies](https://oneuptime.com/blog/post/2026-01-30-cdn-caching-strategies/view)
- [Patterns for safe and efficient cache purging in CI/CD pipelines | Datadog](https://www.datadoghq.com/blog/cache-purge-ci-cd/)
- [Purge cache · Cloudflare Cache (CDN) docs](https://developers.cloudflare.com/cache/how-to/purge-cache/)
- [Using CloudFront Origin Shield to protect your origin in a multi-CDN deployment | AWS](https://aws.amazon.com/blogs/networking-and-content-delivery/using-cloudfront-origin-shield-to-protect-your-origin-in-a-multi-cdn-deployment/)
- [Multi-CDN Strategy: Benefits and Best Practices](https://www.ioriver.io/blog/multi-cdn-strategy)
- [Why use an origin shield as part of a multi-CDN strategy?](https://info.varnish-software.com/blog/multi-cdn-origin-shield)
- [Load Balancing in Edge Computing Environments](https://cyfuture.cloud/kb/load-balancer/load-balancing-in-edge-computing-environments)
- [Global Load Balancing & Geo Targeting | Imperva](https://www.imperva.com/learn/availability/global-load-balancing/)
- [Edge Rendering: A Comprehensive Guide](https://ehosseini.info/articles/edge-rendering/)
- [Better A/B Testing with EdgeWorkers + EdgeKV](https://www.akamai.com/blog/developers/better-a-b-testing-with-edgeworkes-edgekv)
- [Why React Server Components & Edge Rendering Matter in 2025 | FrontendTools](https://www.frontendtools.tech/blog/react-server-components-edge-rendering-guide-2025)
- [Best WAF Solutions for 2026: Top Web Application Firewalls Compared | Fastly](https://www.fastly.com/blog/best-waf-solutions-2025-2026)
- [How to Set Up Cloudflare as a CDN and DDoS Protection](https://oneuptime.com/blog/post/2026-01-08-cloudflare-cdn-ddos-kubernetes/view)
- [Ion — User Experience and Web Performance Optimization | Akamai](https://www.akamai.com/products/web-performance-optimization)
- [Optimizing Images for Web Performance – Frontend Masters Blog](https://frontendmasters.com/blog/optimizing-images-for-web-performance/)
- [What is an image optimizer? | Cloudflare](https://www.cloudflare.com/learning/performance/glossary/what-is-an-image-optimizer/)
- [Cache hit ratios at the edge: a performance study | Fastly](https://www.fastly.com/blog/cache-hit-ratios-edge-performance-study)
- [CDN Performance Metrics: What to Track and How to Monitor](https://blog.paessler.com/cdn-performance-metrics)
- [Optimize Time to First Byte | web.dev](https://web.dev/articles/optimize-ttfb)
- [Connection coalescing with ORIGIN Frames | Cloudflare](https://blog.cloudflare.com/connection-coalescing-with-origin-frames-fewer-dns-queries-fewer-connections/)
- [HTTP/2 connection coalescing | daniel.haxx.se](https://daniel.haxx.se/blog/2016/08/18/http2-connection-coalescing/)
- [SQLite Is Eating the Cloud in 2025: Edge Databases](https://debugg.ai/resources/sqlite-eating-the-cloud-2025-edge-databases-replication-patterns-ditch-server)
- [libSQL - Turso](https://docs.turso.tech/libsql)
- [Turso - Databases Everywhere](https://turso.tech/)
- [Turso Enables Concurrent Writes in libSQL](https://www.webpronews.com/turso-enables-concurrent-writes-in-libsql-for-scalable-edge-databases/)
