# Observability Minion Research

Research findings for the observability-minion agent, covering the three pillars of observability (logs, metrics, traces), modern observability platforms, and operational best practices.

## The Three Pillars of Observability

### Logs

Logs are immutable, exhaustive records of discrete events that occur within a system. They help teams understand the "why" of system issues.

**Structured Logging Best Practices:**

- **Consistent Schema**: Use the same field names across all services. If you call it `user_id` in one service, don't call it `userId` or `user` in another. Pick a convention and stick to it.
- **JSON Format**: JSON logging is machine-parsable and human-readable. While it requires 1.5-2x more storage than plain text, GZIP compression typically reduces storage needs by 60-80%.
- **Context is Critical**: Include contextual information like user IDs, session IDs, request IDs, or request sources. Contextual information makes troubleshooting faster and more efficient.
- **Development vs Production**: Colorful pretty-printed logs are nice during development, but in production emit structured JSON which is easier to parse by log aggregators.
- **Security**: Never log sensitive data. If you must log sensitive data, ensure logs are secure and use log obfuscation to obscure sensitive information.

Sources: [Structured Logging Best Practices](https://uptrace.dev/glossary/structured-logging), [JSON Logging Guide](https://www.dash0.com/guides/json-logging), [Better Stack JSON Logging](https://betterstack.com/community/guides/logging/json-logging/)

### Metrics

Metrics are the raw numeric data collected from various sources measuring resource usage, performance, and user behavior. They measure "known knowns."

**Prometheus and PromQL Best Practices:**

- **Label Management**: Avoid unnecessary labels. Overuse of labels leads to high cardinality which affects query performance. Don't use unique IDs as labels unless required.
- **Query Optimization**: Avoid querying large time ranges unless necessary. Unbounded queries (without label filters) can return large datasets impacting performance.
- **Rate Functions**: Use `rate()` for smoothed averages over time, `irate()` for capturing short spikes. Choose the right function for your use case.
- **Aggregation Functions**: Group metrics to summarize and filter large datasets. Aggregation functions help optimize data retrieval.
- **Time Comparisons**: Use the `offset` keyword to compare metrics across different time periods, useful for validating improvements.

Sources: [Prometheus PromQL Best Practices](https://medium.com/@yogeshkolhatkar/prometheus-querying-best-practices-a-complete-guide-a2f0b2899a93), [PromQL Guide](https://last9.io/blog/guide-to-prometheus-query-language/), [PromQL Cheat Sheet](https://signoz.io/guides/promql-cheat-sheet/)

### Traces

A distributed trace tracks an application request as it flows through various parts of an application. Traces help understand the flow and timing of requests across services.

**OpenTelemetry Distributed Tracing:**

- **Spans**: The core building block describing a single operation—when it started, how long it took, what it did, and how it connects to other operations.
- **Span Kinds**: Five types define the span's role: CLIENT (outgoing request), SERVER (request handled by service), PRODUCER (message published), CONSUMER (message processed), INTERNAL (operation within a service).
- **Context Propagation**: The core concept enabling distributed tracing. Use W3C Trace Context standard (default in most OpenTelemetry SDKs) unless you have unique requirements.
- **Span Links**: Associate one span with one or more spans to imply causal relationships across traces.

Sources: [OpenTelemetry Traces](https://opentelemetry.io/docs/concepts/signals/traces/), [Distributed Tracing with OpenTelemetry](https://uptrace.dev/opentelemetry/distributed-tracing), [OpenTelemetry Spans Explained](https://last9.io/blog/opentelemetry-spans-events/)

### Correlation

The value comes from integrating logs, metrics, and traces together rather than analyzing them separately. Correlation ties together all three pillars with contextual information to present a cohesive view of events across different layers of the network stack.

Sources: [Three Pillars of Observability](https://www.ibm.com/think/insights/observability-pillars), [Elastic 3 Pillars](https://www.elastic.co/blog/3-pillars-of-observability)

## OpenTelemetry

### SDK Configuration

**Configuration Approaches:**

- **Zero-Code Autoconfigure**: Configure SDK components through system properties or environment variables with extension points when properties are insufficient.
- **Programmatic Configuration**: APIs for constructing SDK components—all SDK components have a programmatic configuration API.
- **Declarative Configuration**: Some SDKs support experimental YAML-based configuration files.

**Best Practices:**

- **Initialization Timing**: Initialize OpenTelemetry before any instrumented libraries are used. Include SDK and configuration at the very beginning of your application's startup sequence.
- **Agent Configuration**: Keep agent configuration minimal. Define complex processing logic as collector pipelines for better performance and maintainability.
- **Sidecar Deployment**: Deploy the collector as a sidecar. A locally running collector instance allows the agent to efficiently export telemetry data and free up network resources.

Sources: [OpenTelemetry SDK Configuration](https://opentelemetry.io/docs/languages/sdk-configuration/), [OpenTelemetry Best Practices](https://betterstack.com/community/guides/observability/opentelemetry-best-practices/)

### Collector Configuration

**Pipeline Structure:**

Data receiving, processing, and exporting are done using pipelines. A pipeline consists of:

1. **Receivers**: Collect the data
2. **Processors**: Get data from receivers and process it (optional)
3. **Exporters**: Get data from processors and send it outside the Collector

Pipelines operate on three telemetry data types: traces, metrics, and logs.

**Processing Order:**

Data from all receivers is pushed to the first processor, which processes the data and pushes it to the next processor. The order of processors in a pipeline determines the order of processing operations.

**Common Processors:**

- **Batch Processor**: Groups telemetry into batches for more efficient export.
- **Memory Limiter Processor**: Prevents the Collector from consuming too much memory and crashing.

**Service Configuration:**

The service section configures what components are enabled based on receivers, processors, exporters, and extensions sections. The same receiver, processor, or exporter can be used in more than one pipeline.

Sources: [OpenTelemetry Collector Configuration](https://opentelemetry.io/docs/collector/configuration/), [Collector Architecture](https://opentelemetry.io/docs/collector/architecture/), [Collector Guide](https://signoz.io/blog/opentelemetry-collector-complete-guide/)

### Instrumentation Strategies

**Three Main Approaches:**

1. **Manual Instrumentation**: Explicitly define spans, attributes, and events in code. Ideal for fine-grained control.
2. **Auto-Instrumentation**: Hooks into supported libraries automatically (HTTP clients, SQL drivers, etc.). Get visibility fast without changing much code.
3. **Zero-Code Instrumentation**: eBPF provides kernel-level tracing for environments where touching code isn't possible. Works with compiled binaries and across multiple languages—perfect for legacy apps or third-party binaries.

**Strategic Instrumentation:**

Instrument key operations like inbound requests (HTTP GET /checkout, gRPC OrderService.Create). Helper methods and tight loops rarely help debug distributed behavior.

**Performance Considerations:**

Use asynchronous batch exporters that never block application threads. OpenTelemetry SDKs default to async batch exporters that queue spans in memory and export in batches.

Sources: [OpenTelemetry Instrumentation Tutorial](https://www.withcoherence.com/articles/opentelemetry-distributed-tracing-tutorial-and-best-practices), [Implementing Distributed Tracing](https://last9.io/blog/distributed-tracing-with-opentelemetry/)

## Coralogix Platform

Coralogix is a full-stack observability platform providing real-time analysis, monitoring, visualization, and alerting with proprietary Streama technology. It ingests log, metric, tracing, and security data from any source for a single, aggregated view of system health.

### Log Parsing

Logs are captured and converted into JSON documents using regex. Coralogix includes parsing rules to provide value for customers with many fields and nested fields in their log data, with Stringify JSON Field and Parse JSON Field rules enabling parsing of escaped JSON values within fields.

### Alerting

Coralogix has extensive alerting including ratio, time relative, new value, unique count, metric, tracing, and flow alerts. Machine learning algorithms continuously monitor data patterns and flows between system components, triggering dynamic alerts when patterns deviate from the norm.

### TCO Optimization

The Total Cost of Ownership (TCO) Optimizer for logs and traces reduces costs by aligning data priorities with business value. It keeps critical data instantly searchable for real-time analysis and alerting, while routing lower-value data to cost-efficient storage. Users can save up to 70% on observability costs with better data correlation and visibility.

### Log Lifecycle

Coralogix manages the complete lifecycle of logs through different storage tiers based on priority and access patterns, optimizing both performance and cost.

Sources: [Coralogix Platform](https://coralogix.com/), [TCO Optimizer](https://coralogix.com/docs/user-guides/account-management/tco-optimizer/), [Cost Optimization Guide](https://coralogix.com/guides/cost-optimization-capabilities/), [Log Lifecycle](https://coralogix.com/blog/logs-life-cycle-in-coralogix/)

## Grafana Dashboard Design

### Core Design Principles

**Purpose-Driven Design:**

A dashboard should be designed with a specific purpose or use case in mind, telling a story through logical progression of data (large to small, general to specific) or answering a question.

Put yourself in the shoes of your intended user, outlining their specific goals and needs for data visualization.

### Visual Hierarchy

A visual hierarchy is a pattern in which some elements stand out and attract attention more than others, guiding viewers to the information you want them to focus on.

**Key Techniques:**

- **Z-Pattern Scanning**: Users scan content left to right, top to bottom. Place key content in the top left corner.
- **Size Conveys Importance**: Bigger components have greater perception of importance. Emphasize key metrics in large stat panels and place supporting data in smaller panels beneath.
- **Color Psychology**: Eyes are drawn to bright, saturated colors. If an object's color is visually distinct from its background, viewers will notice it first.

### Practical Best Practices

- **Refresh Rate**: Avoid unnecessary dashboard refreshing to reduce network or backend load. If data changes every hour, you don't need a 30-second refresh rate.
- **Documentation**: Add documentation to dashboards and panels using Text panel visualizations to record the dashboard purpose, useful resource links, and instructions.
- **Organization**: Organize panels logically by grouping related metrics together with consistent layouts and visualizations.
- **Visualization Patterns**: Stick to a few data visualization patterns. Graph and singlestat panel types cover about 80% of use cases.
- **Multiple Y-Axes**: Use left and right Y-axes when displaying time series with different units or ranges.

### Advanced Strategies

- **Full-Stack Observability**: Combine metrics, logs, and traces in a single dashboard to connect system behavior with underlying events, allowing spikes in latency to be traced through logs and request paths.
- **Scripting**: Use scripting libraries to generate dashboards and ensure consistency in pattern and style.

Sources: [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/visualizations/dashboards/build-dashboards/best-practices/), [Getting Started with Grafana](https://grafana.com/blog/getting-started-with-grafana-best-practices-to-design-your-first-dashboard/), [AWS Grafana Best Practices](https://docs.aws.amazon.com/grafana/latest/userguide/v10-dash-bestpractices.html)

## SLO/SLI Framework (Google SRE Book)

### Core Definitions

- **SLI (Service Level Indicator)**: A carefully defined quantitative measure of some aspect of the level of service provided. Common examples include latency, error rate, request throughput, and availability.
- **SLO (Service Level Objective)**: A target value or range of values for a service level measured by an SLI.
- **Error Budget**: 1 minus the SLO of the service. A 99.9% SLO service has a 0.1% error budget. If a service receives 1,000,000 requests in four weeks, a 99.9% availability SLO gives a budget of 1,000 errors over that period.

### Error Budgets as Decision Tools

Error budgets are a tool for balancing reliability with other engineering work—a great way to decide which projects will have the most impact. An error budget acts as an early warning signal to tell you when it's time to shift work efforts.

When your error budget is getting close to being spent, divert resources from innovating to addressing technical debt.

### Observability Connection

Product management defines SLOs with expectations on how much uptime they should deliver in a given time period. Observability tools monitor the actual uptime of services. SLIs commonly come from observability and monitoring tools focusing on different parts of your technology stack to understand reliability across the entire user journey.

### Google SRE Framework

SLOs are key to making data-driven decisions about reliability and are at the core of SRE practices. Having good SLOs that measure the reliability of your platform as experienced by your customers provides the highest-quality indication for when an on-call engineer should respond, helping them respond to problems before consuming too much of their error budget.

Sources: [Google SRE Error Budget Policy](https://sre.google/workbook/error-budget-policy/), [Implementing SLOs](https://sre.google/workbook/implementing-slos/), [Complete Guide to Error Budgets](https://www.nobl9.com/resources/a-complete-guide-to-error-budgets-setting-up-slos-slis-and-slas-to-maintain-reliability), [Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)

## Alert Design and On-Call Best Practices

### Alert Design Principles

**Actionable Alerts:**

All alerts should be immediately actionable, with an action that a human is expected to take immediately after receiving the page that the system is unable to take itself.

Design rich alerts that clearly describe an issue and empower on-call engineers to make effective decisions and apply the knowledge recorded in runbooks.

### Alert Fatigue Prevention

Alert fatigue is one of the most dangerous threats to on-call employees. When engineers are bombarded with low-severity alerts, they begin to ignore or delay responses—potentially missing high-priority incidents.

**Key Strategies:**

- **De-duplication**: De-duplicate related alerts to avoid alert fatigue. Alert fatigue comes from poor signal-to-noise ratios. Deduplication, suppression, and prioritization filters ensure that when a phone buzzes, it matters.
- **Severity Classification**: Classify incidents by severity and route only critical alerts to wake people up. Bundle low-priority alerts for review during business hours.
- **Regular Audits**: Regularly audit alert thresholds to avoid over-sensitivity.
- **Dynamic Thresholds**: Instead of static limits, implement dynamic thresholds that adapt based on historical data. If CPU usage spikes at certain times, configure alerts to trigger only when usage is significantly higher than the usual pattern.

### Runbook Patterns

Runbooks should provide the on-call engineer with an overview of how to handle a given alert or type of problem. They should be focused on solving a single problem or alert, laying out the steps needed to validate the issue, determine its severity, and respond.

**Best Practices:**

- **Central Location**: Runbooks should live in a central place accessible by everyone on-call. It can be an internal wiki or knowledge base software.
- **Direct Links**: Alerts should link directly to runbooks.
- **Standard Format**: Establish a standard format used across your organization. This ensures consistency and helps on-call folks quickly figure out the steps even for runbooks they may not have seen before.

### On-Call Best Practices

- **Escalation Procedures**: Best practices require one or two backup engineers for each on-call shift. Escalation alerts can be routed to secondary on-call engineers when alerts aren't answered or when the primary on-call engineer needs help.
- **Separation of Duties**: Keep on-call duties and development duties separate as a best practice.
- **Automation**: Auto-remediation scripts handle predictable problems. Runbook automation turns experience into reusable playbooks.
- **Continuous Improvement**: Set up regular intervals to review alert thresholds, rules, and notifications. Use past incidents to guide changes—if certain alerts were consistently ignored, consider revising or eliminating them.

Sources: [Atlassian On-Call Guide](https://www.atlassian.com/incident-management/on-call/improving-on-call), [Building Effective Runbooks](https://www.tryparity.com/blog/how-to-build-an-effective-runbook-for-on-call), [Alert Fatigue Prevention](https://www.netdata.cloud/academy/what-is-alert-fatigue-and-how-to-prevent-it/), [Google SRE On-Call](https://sre.google/workbook/on-call/)

## Observability Cost Optimization

### High Cardinality Impact

Cost reduction strategies include collecting only metrics that matter, reducing the cardinality of telemetry data, and fine-tuning the granularity of telemetry data collection.

High cardinality occurs when engineers tag metrics with unique IDs such as `user_id:12345`, which can create millions of custom metrics if there are millions of users.

### Log Sampling Challenges

Sampling hides rare events you actually care about—incidents, regressions, and edge-case failures are statistically insignificant and make them the first to disappear under sampling. This represents a fundamental tradeoff in cost optimization strategies.

### Storage and Retention Optimization

**Best Practice Strategies:**

- **Granular Retention Policies**: Examine log retention policies to implement granular controls on how long log data is kept.
- **Tiered Storage**: Send log data to different storage options based on importance. CloudWatch Logs subscriptions allow selectively forwarding logs to S3, which provides more cost-efficient long-term storage compared to retaining logs indefinitely in CloudWatch.
- **Log Filtering**: Utilize log filtering to reduce volume.

### Cardinality Management

**Strategies:**

- **Filtering**: Drop less important labels.
- **Sampling**: Collect metrics from a subset of events or requests rather than all of them.
- **Aggregation**: Prometheus offers mechanisms like aggregation and label-based filtering to manage metric cardinality effectively.

### Modern Approaches

Detecting high cardinality metric conditions involves pinpointing what variables are contributing to the high dimensionality, recommending what can be reduced, and deploying cost control filters.

Sources: [AWS EKS Observability Cost Optimization](https://docs.aws.amazon.com/eks/latest/best-practices/cost-opt-observability.html), [Datadog High Cardinality](https://www.controltheory.com/blog/datadog-high-cardinality-logs/), [Observability Cost Control](https://www.controltheory.com/use-case/cut-observability-costs/), [Strategies to Reduce Observability Costs](https://drdroid.io/engineering-tools/strategies-to-reduce-your-observability-costs)

## Real User Monitoring (RUM) vs Synthetic Monitoring

### Real User Monitoring (RUM)

RUM measures the performance of a page from real users' machines. Generally, a third-party script injects a script on each page to measure and report back on page load data for every request made.

**Characteristics:**

- Collects data from actual users in real-time as they interact with the application.
- Data is organic and unpredictable, representing genuine user behavior.
- Best suited for understanding long-term trends.

### Synthetic Monitoring

Synthetic monitoring involves monitoring the performance of a page in a 'laboratory' environment, typically with automation tooling in a consistent as possible environment. It uses scripted transactions to simulate the path an end user might take through a web application.

**Characteristics:**

- Uses scripted transactions and emulated user behavior to gather data.
- Interactions are predefined and follow a set pattern during each test cycle.
- Well suited to regression testing and mitigating shorter-term performance issues during development.

### Complementary Approach

Synthetic and Real User Monitoring can work in tandem to unlock value that neither product can on its own. Both can help detect where web performance challenges are stemming from and how you ought to address them.

Sources: [MDN RUM vs Synthetic Monitoring](https://developer.mozilla.org/en-US/docs/Web/Performance/Guides/Rum-vs-Synthetic), [Blue Triangle RUM vs Synthetic](https://bluetriangle.com/blog/real-user-monitoring-vs-synthetic-monitoring), [Kentik RUM vs Synthetic](https://www.kentik.com/kentipedia/synthetic-monitoring-vs-real-user-monitoring/), [Coralogix RUM Guide](https://coralogix.com/guides/real-user-monitoring/)

## Key Observability Principles

### Observe, Don't Just Monitor

Monitoring answers "is it broken?" Observability answers "why is it broken?" The goal is to understand system behavior, not just detect failures.

### Structure Your Logs from Day One

Unstructured logs are cheap to write but expensive to analyze. Invest in structured logging early—the cost pays off every time you need to troubleshoot production.

### Alert on Symptoms (SLOs), Not Causes

Alert when users are affected (response time > SLO, error rate > threshold), not when CPU is at 80%. A high CPU that doesn't affect users isn't a page-worthy event.

### Every Alert Should Be Actionable

If an alert doesn't require immediate human action, it's noise. Either make it actionable or demote it to a dashboard metric.

### Observability Is Not Optional

You cannot understand production without observability. It's not a luxury for mature systems—it's how you understand what your system is actually doing.

### Context Is Everything

A metric without context is just a number. Correlate logs, metrics, and traces. Include request IDs, user IDs, and session IDs. Build the ability to jump from a metric spike to the relevant logs to the specific trace.

### Cost Is a First-Class Concern

Observability pipelines can rival infrastructure costs. Design for cost from day one: manage cardinality, use tiered storage, filter before ingest, and regularly audit what you're collecting.

## Summary

Modern observability requires integration across all three pillars (logs, metrics, traces), with correlation being the key to actionable insights. OpenTelemetry provides the standard instrumentation layer, while platforms like Coralogix offer comprehensive observability with cost optimization built in. Grafana provides visualization, Prometheus handles metrics, and SLO/SLI frameworks (from Google SRE) provide the operational methodology. Alert design should prioritize actionability over coverage, and cost optimization should be considered a first-class concern from the beginning.
