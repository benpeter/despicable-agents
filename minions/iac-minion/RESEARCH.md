# Infrastructure as Code Research

Research backing the iac-minion agent system prompt.

## Terraform Best Practices

### Module Design and Composition

**Module Philosophy**: Keep modules focused and single-purpose. Each module should do one thing and do it well. Don't create modules called "everything-my-app-needs." The best practice is to keep modules relatively small and pass in their dependencies, which improves flexibility for future refactoring because the module doesn't know or care how those identifiers are obtained by the calling module.

**Module Layering**: Teams often nest modules (calling one module from within another) to create a layered infrastructure model where high-level components consist of lower-level components. The facade pattern creates a high-level module that presents a simple API to consumers while orchestrating multiple complex modules under the hood.

**Module Separation at Scale**: A reliable pattern for managing Terraform modules at scale is to clearly separate core platform modules from application-level modules. The platform team owns stable, reusable building blocks (VPCs, networking, IAM baselines), while application teams consume those building blocks through thinner, app-focused modules.

Sources:
- [Terraform Module Composition | Brainboard Blog](https://blog.brainboard.co/terraform-module-composition/)
- [Module Composition | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/develop/composition)
- [10 Best Practices for Managing Terraform Modules at Scale](https://spacelift.io/blog/terraform-modules-at-scale)

### State Management

**Remote Backend**: Store Terraform state in a remote backend like AWS S3, Terraform Cloud, or Azure Storage. Enable state locking to prevent race conditions using DynamoDB for AWS or Terraform Cloud locks.

**State File Size**: Don't include more than 100 resources (and ideally only a few dozen) in a single state. Any operation on a resource can potentially affect other resources managed in the same state file, so keep the potential blast radius of your operations small by managing resources in separate workspaces when possible.

**State Isolation**: Split up workspaces based on team responsibilities and required privileges. For real projects, folder-based environments (separate directories with separate state files) win over Terraform workspaces. This keeps production, staging, and development completely separate—different state files, backends, even providers if needed.

Sources:
- [Managing Terraform State - Best Practices & Examples](https://spacelift.io/blog/terraform-state)
- [Best Practices - Workspaces - HCP Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/best-practices)
- [20 Terraform Best Practices to Improve your TF workflow](https://spacelift.io/blog/terraform-best-practices)

### Versioning Strategy

Terraform follows Semantic Versioning (SemVer), a three-part versioning scheme (e.g., v1.2.3):
- **Major versions** introduce breaking changes
- **Minor versions** add new backward-compatible functionality
- **Patch versions** fix bugs without changing the API or functionality

Best practice is to use semantic versioning religiously and maintain a compatibility matrix for your modules. Bump the major version when making breaking changes and provide clear migration guides.

Terraform supports a variety of version constraint syntax, including exact versions, version ranges, and operators like greater than or equal to (>=) and less than or equal to (<=).

Sources:
- [Advanced Terraform Module Usage: Versioning, Nesting, and Reuse Across Environments - DEV Community](https://dev.to/patdevops/advanced-terraform-module-usage-versioning-nesting-and-reuse-across-environments-43j0)
- [Version Constraints - Configuration Language | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/expressions/version-constraints)

### Documentation and Inputs/Outputs

For every module, define its inputs and outputs and document them thoroughly to enable consumers to use them effectively. However, don't build a module to launch just one EC2 instance or a bucket unless it's reused. Modules should provide value through abstraction and reusability.

Sources:
- [Terraform Best Practices: Modules and State Management](https://durbanod.com/blog/terraform-best-practices-modules-and-state-management)

## Docker and Container Optimization

### Multi-Stage Build Benefits

Multi-stage builds use multiple FROM statements in your Dockerfile, with each FROM instruction using a different base image and beginning a new stage of the build. You can selectively copy artifacts from one stage to another, leaving behind everything you don't want in the final image.

**Key Benefits**:
- Reduce the size of your final image by creating a cleaner separation between building and final output
- Create smaller container images with better caching and smaller security footprint
- Execute build steps in parallel for more efficient builds
- For compiled languages (C, Go, Rust), compile in one stage and copy binaries into a final runtime image without bundling the entire compiler

Sources:
- [Multi-stage | Docker Docs](https://docs.docker.com/build/building/multi-stage/)
- [Docker Multistage Builds: How to Optimize Your Images](https://spacelift.io/blog/docker-multistage-builds)

### Docker Best Practices

**1. Use Lightweight Base Images**: For runtime stages, use a lightweight image that contains only the required runtime dependencies, which helps reduce the final image size and improves security. Alpine Linux and distroless images are popular choices.

**2. Optimize Cache Layers**: Organize your Dockerfile stages to optimize the build process by placing the stages that are less likely to change towards the beginning of the Dockerfile, which allows the cache to be reused more effectively for subsequent builds.

**3. Minimize Dependencies**: Avoid including unnecessary dependencies and files by using an appropriate base or parent image that only contains the packages you need. Clean up package manager caches after installing dependencies.

**4. BuildKit Optimization**: Many patterns run more efficiently when using BuildKit backend, as BuildKit efficiently skips unused stages and builds stages concurrently when possible.

Sources:
- [Best practices | Docker Docs](https://docs.docker.com/build/building/best-practices/)
- [Advanced Dockerfiles: Faster Builds and Smaller Images Using BuildKit and Multistage Builds | Docker](https://www.docker.com/blog/advanced-dockerfiles-faster-builds-and-smaller-images-using-buildkit-and-multistage-builds/)

### Container Security and Hardening

**Capability Management**: The most secure setup is to drop all capabilities (`--cap-drop all`) and then add only required ones. Avoid running containers with the `--privileged` flag, which adds ALL Linux kernel capabilities.

**Base Image Selection**: Start with a minimal base image like Alpine or a slim version of popular distributions. Smaller images contain fewer components, reducing the potential attack surface.

**Non-Root Execution**: Containers should run as non-root service users when possible to limit their ability to perform malicious tasks if compromised, following the principle of least privilege. Enable user namespace remapping to map container users to non-root users on the host.

**Security Policies**: Docker supports policies for SELinux, Seccomp, and AppArmor. Keep them enabled to ensure sane defaults are applied to containers, including restrictions for dangerous system calls. Do not disable the default profiles that Docker supplies.

**Namespace Isolation**: Avoid sharing host namespaces with containers. Sharing PID or network namespaces allows containers to see and kill PIDs running on the host or connect to privileged ports.

**Image Signing**: Docker Content Trust is a mechanism for signing and verifying images. Image creators can sign their images to prove authorship and consumers can verify trust by comparing the image's public signature.

**Host Security**: Docker security is only as good as the protection surrounding your host. Fully harden your host environment by regularly updating OS and kernel, enabling firewalls, and restricting direct host access.

Sources:
- [Docker Security - OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [21 Docker Security Best Practices: Daemon, Image, Containers](https://spacelift.io/blog/docker-security)
- [Hardening Docker containers, images, and host - security toolkit](https://www.redhat.com/en/blog/hardening-docker-containers-images-and-host-security-toolkit)

## GitHub Actions CI/CD

### Reusable Workflows

Reusable workflows let you break your automation into modular, shareable pieces. A reusable workflow is a complete workflow file that other workflows can call as a job, functioning like a function that accepts inputs and can return outputs.

**Key Benefits**:
- Avoids duplication and makes workflows easier to maintain
- Allows you to create new workflows more quickly by building on the work of others
- Promotes best practice by using workflows that are well designed, tested, and proven effective

**2026 Updates**: GitHub shipped increases to reusable workflow depth, giving developers more flexibility to build sophisticated self-service workflows. GitHub is also working on parallel steps, one of the most requested features, with a goal to ship it before mid-2026.

Sources:
- [Let's talk about GitHub Actions - The GitHub Blog](https://github.blog/news-insights/product-news/lets-talk-about-github-actions/)
- [Reuse workflows - GitHub Docs](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
- [How to Create Reusable Workflows in GitHub Actions](https://oneuptime.com/blog/post/2026-01-25-github-actions-reusable-workflows/view)

### Workflow Design Patterns

**Modular Design**: Each workflow should focus on a specific task (testing, building, deployment) to ensure clarity and reusability.

**Inputs and Secrets**: For a workflow to be reusable, the values for `on` must include `workflow_call`, and you can define inputs and secrets, which can be passed from the caller workflow and then used within the called workflow.

**Versioning and Organization**: Teams centralize workflows in a monorepo where all changes require code-owner approval, use semantic versioning, avoid breaking changes by sticking to a 1.x.x version scheme, and generally release new workflow versions weekly.

Sources:
- [Best practices to create reusable workflows on GitHub Actions - Incredibuild](https://www.incredibuild.com/blog/best-practices-to-create-reusable-workflows-on-github-actions)
- [Building organization-wide governance and re-use for CI/CD and automation with GitHub Actions - The GitHub Blog](https://github.blog/enterprise-software/devops/building-organization-wide-governance-and-re-use-for-ci-cd-and-automation-with-github-actions/)

### Secrets Management and Environment Protection

**Secret Types and Scope**: GitHub supports secrets at multiple levels:
- Environment secrets are limited to jobs referencing that particular environment
- Organization secrets allow all workflows in repositories that have been granted access to use those secrets
- Repository-level secrets

**Encryption**: Secrets use Libsodium sealed boxes so that they are encrypted before reaching GitHub through the UI or REST API. GitHub Actions can only read a secret if you explicitly include the secret in a workflow.

**Environment Protection and Approval**: For environment secrets, you can enable required reviewers to control access to the secrets. A workflow job cannot access environment secrets until approval is granted by required approvers.

**Best Practices**:
- Rotate GitHub Actions secrets regularly (30-90 days)
- Use OIDC over long-lived tokens
- Implement environment-based access controls with approval workflows
- Avoid hardcoded secrets
- Use descriptive naming conventions
- Store secrets at the environment level rather than repository level when possible to limit access based on deployment stages

Sources:
- [Using secrets in GitHub Actions - GitHub Docs](https://docs.github.com/actions/security-guides/using-secrets-in-github-actions)
- [8 GitHub Actions Secrets Management Best Practices to Follow - StepSecurity](https://www.stepsecurity.io/blog/github-actions-secrets-management-best-practices)
- [Best Practices for Managing Secrets in GitHub Actions | Blacksmith](https://www.blacksmith.sh/blog/best-practices-for-managing-secrets-in-github-actions)

## Caddy v2 Reverse Proxy

### Basic Configuration Patterns

The `reverse_proxy` directive proxies requests to one or more backends with configurable transport, load balancing, health checking, request manipulation, and buffering options.

**Simple Single Domain Proxy**: A sample config includes the domain followed by `reverse_proxy` pointing to the backend port, with websocket support and proxy headers enabled by default.

**Multiple Subdomains/Applications**: When hosting multiple applications on your server, you want to reverse proxy each domain to a different server, with dedicated Caddyfile configuration containing `reverse_proxy localhost:PORT`.

Sources:
- [Reverse proxy quick-start — Caddy Documentation](https://caddyserver.com/docs/quick-starts/reverse-proxy)
- [reverse_proxy (Caddyfile directive) — Caddy Documentation](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy)

### Advanced Configuration

**Transport Options**: Transport configuration includes options for read/write buffers, PROXY protocol (v1/v2), timeouts, TLS settings, keepalive configuration, and connection management.

**SPA with API Pattern**: For Single Page Applications coupled with APIs, you can use handle blocks to treat API endpoints exclusively, with one handle block for reverse_proxy backend and another for serving static files.

**Host Header Management**: If the hostname being proxied to differs from the original hostname, the `--change-host-header` flag resets the Host header to that of the backend so the TLS handshake can complete successfully.

**Load Balancing**: With multiple upstreams and health checks, two servers can load balance all requests.

Sources:
- [Common Caddyfile Patterns — Caddy Documentation](https://caddyserver.com/docs/caddyfile/patterns)
- [Caddy as simple Reverse Proxy and File Server | Hetzner Community](https://community.hetzner.com/tutorials/caddy-as-simple-reverse-proxy-and-file-server/)

### Automatic HTTPS

Caddy automatically provisions and renews SSL/TLS certificates using ACME (Let's Encrypt by default). This is one of Caddy's most compelling features—automatic HTTPS with zero configuration.

## Hetzner Cloud

### API and Deployment

Using the Cloud API, you're able to manage all cloud services and resources linked to them, such as Floating IPs, Volumes, and Load Balancers. The Hetzner Cloud API operates over HTTPS and uses JSON as its data format. It's a RESTful API that utilizes HTTP methods and HTTP status codes to specify requests and responses.

**Deployment Patterns**:
- Deploying Hetzner Cloud servers from GitHub Actions
- Using a Hetzner cloud plugin for Jenkins CI to schedule builds on dynamically provisioned VMs
- Provisioning Kubernetes clusters on Hetzner Cloud

Sources:
- [Hetzner API overview](https://docs.hetzner.cloud/)
- [API - Hetzner Docs](https://docs.hetzner.com/cloud/api/)

### Pricing Model

**Billing Structure**: Servers have both a monthly price cap and a price per hour. Your server's bill never exceeds its monthly price cap. If you delete your cloud server before the end of the billing month, you will only be billed for the hourly rate.

**Instance Families**: Hetzner provides four instance families:
- CX: cost-optimized
- CAX: ARM-based
- CPX: regular performance
- CCX: dedicated vCPUs

**All-Inclusive Pricing**: Pricing covers traffic, IPv4/IPv6, DDoS protection, and firewalls at no extra charge. You'll get at least 20 TB of inclusive traffic for cloud servers at EU locations, 1TB in US locations, and 0.5 TB in Singapore.

**Backups**: Backups are billed with a monthly flat price, which is 20% of the price of the server you activate them for.

Sources:
- [Hetzner Cloud VPS Pricing Calculator (Feb 2026)](https://costgoat.com/pricing/hetzner)
- [FAQ - Hetzner Docs](https://docs.hetzner.com/cloud/billing/faq/)

## Infrastructure Cost Optimization

### Primary Optimization Strategies

**Rightsizing Resources**: Overprovisioning is one of the most common (and expensive) mistakes in cloud infrastructure. Analyze usage patterns, identify underutilized resources, and apply best practices like rightsizing instances, using reserved or spot instances, and eliminating idle services.

**Auto-scaling**: Auto-scaling automatically adjusts your cloud resources based on current demand, adding more resources when your application experiences increased traffic or workload, and reducing resources when demand decreases, ensuring you only pay for what you use.

**Reserved and Spot Instances**: Leverage commitment-based discounts by locking in one- or three-year commitments at significantly reduced rates for predictable workloads. Spot instances provide spare computing capacity at significantly reduced prices and are ideal for flexible workloads like batch processing, data analysis, and testing.

**Storage Optimization**: Storage can be a major cost in the cloud. Review current storage use and set up lifecycle policies to move data to cheaper storage tiers as it gets older.

Sources:
- [18 Cloud Cost Optimization Best Practices for 2026](https://spacelift.io/blog/cloud-cost-optimization)
- [Mastering Cloud Cost Optimization? 15+ Best Practices for 2025](https://www.cloudzero.com/blog/cloud-cost-optimization/)

### Organizational Approaches

**FinOps Practice**: Many organizations employ a cross-functional FinOps team with members from IT, finance, and engineering, which rely on reporting and automation to increase ROI by continuously identifying opportunities for efficiency and taking action regarding cloud optimization in real-time.

**Monitoring and Governance**: Set up governance policies to control cloud usage and costs by defining who can provision resources, setting spending limits, and establishing usage guidelines.

**Serverless and Managed Services**: Leverage serverless and managed services with autoscaling features that adjust to demand as a modern cost optimization strategy.

Sources:
- [What is cloud cost optimization? | IBM](https://www.ibm.com/think/topics/cloud-cost-optimization)
- [Top 15 Cloud Cost Optimization Strategies in 2025 - Tips & Tactics](https://ternary.app/blog/cloud-cost-optimization-strategies/)

## SSL/TLS Certificate Management

### Let's Encrypt and ACME Protocol

Let's Encrypt is a free, automated, and open Certificate Authority brought to you by the nonprofit Internet Security Research Group (ISRG). Let's Encrypt uses the ACME protocol to verify that you control a given domain name and to issue you a certificate.

**What is ACME**: The Automatic Certificate Management Environment (ACME) protocol is a communications protocol for automating interactions between certificate authorities and their users' servers, allowing the automated deployment of public key infrastructure at very low cost. The protocol, based on passing JSON-formatted messages over HTTPS, has been published as an Internet Standard in RFC 8555.

Sources:
- [Let's Encrypt](https://letsencrypt.org/)
- [How It Works - Let's Encrypt](https://letsencrypt.org/how-it-works/)
- [Automatic Certificate Management Environment - Wikipedia](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment)

### ACME Clients

In order to interact with the Let's Encrypt API and get a certificate, a piece of software called an "ACME client" is required. For most people the recommended choice is the Certbot ACME client. Other popular ACME clients include acme.sh (a Unix shell script implementation) and various platform-specific tools like Certify The Web for Windows.

**Certificate Validation**: When you get a certificate from Let's Encrypt, servers validate that you control the domain names in that certificate using "challenges," as defined by the ACME standard. Most of the time, this validation is handled automatically by your ACME client.

Sources:
- [Getting Started - Let's Encrypt](https://letsencrypt.org/getting-started/)
- [ACME Client Implementations - Let's Encrypt](https://letsencrypt.org/docs/client-options/)
- [GitHub - acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh)

## Server Deployment Patterns

### Key Deployment Strategies

**Canary Deployment**: Canary deployment involves releasing a new version to a small percentage of users first before gradually increasing the traffic, improving availability by detecting problems early before a service is exposed to the entire system.

**Blue-Green Deployment**: Blue-green deployment maintains two identical production environments (blue and green) with only one receiving live traffic at any time. This allows for quick rollbacks and zero-downtime deployments.

**Rolling Deployment**: With rolling deployment, the fleet is divided into portions so that all of the fleet isn't upgraded at once. During the deployment process two software versions, new and old, are running on the same fleet. This method allows a zero-downtime update.

Sources:
- [8 Deployment Strategies Explained and Compared](https://www.apwide.com/8-deployment-strategies-explained-and-compared/)
- [How to Improve Availability Using Deployment Patterns](https://newsletter.systemdesign.one/p/deployment-patterns)

### Best Practices

**Shared Pipeline Configs**: If your services follow similar patterns, use a shared, parameterized pipeline config instead of building each one from scratch.

**Service Dashboard**: Maintain a centralized service dashboard that tracks version, build status, deployment time, and ownership for every service.

**Infrastructure as Code**: Treat infrastructure as code. Version control your infrastructure and update it as part of your continuous delivery pipeline.

**DevOps Practices**: Each team delivers software using DevOps practices, in particular, continuous deployment. The team delivers a stream of small, frequent changes that are tested by an automated deployment pipeline and deployed into production.

**Service-Instance-Per-Container Pattern**: The service-instance-per-container pattern is lightweight and retains many of the benefits of virtualization that VMs boast. In this pattern, each microservice instance runs in its own container.

Sources:
- [Top 6 Microservices Deployment Patterns & Best Practices](https://www.superblocks.com/blog/microservices-deployment)
- [Deployment Strategies & Release Best Practices | by Christopher Grant | Medium](https://medium.com/@cgrant/deployment-strategies-release-best-practices-6e557c3f39b4)

## Infrastructure Observability

### Key Observability Patterns

Three primary design patterns address key challenges in monitoring cloud-native applications:

1. **Distributed Tracing**: Improves visibility into request flows across services for latency analysis and root cause detection. Tracks application requests as they flow from frontend devices to backend services and databases.

2. **Application Metrics**: Provides structured instrumenting with meaningful performance indicators for real-time monitoring.

3. **Infrastructure Metrics**: Focuses on monitoring the operational environment to assess resource utilization and health.

Sources:
- [Tracing and Metrics Design Patterns for Monitoring Cloud-native Applications](https://arxiv.org/html/2510.02991v1)
- [6 Observability Design Patterns for Microservices Every CTO Should Know](https://www.simform.com/blog/observability-design-patterns-for-microservices/)

### Common Implementation Pattern

The most common pattern involves using Prometheus for metrics collection, Grafana for visualization, and Kubernetes-native resources for automated scaling.

### Design Patterns for Observable Services

Service monitoring design patterns fall into three categories:
1. **Health Checks**: Verify services are running correctly
2. **Real-time Alerting**: Notify when issues occur like services becoming unresponsive or using excessive resources
3. **Troubleshooting approaches**

Sources:
- [5 Design Patterns for Building Observable Services - Salesforce Engineering Blog](https://engineering.salesforce.com/5-design-patterns-for-building-observable-services-d56e7a330419/)

### Data Sources for Observability

Effective infrastructure monitoring includes several observability data sources:
- **Metrics**: Provide quantitative data for visualizations and performance analysis
- **Event logs**: Give insights into system activities for troubleshooting
- **Distributed traces**: Record transaction journeys through infrastructure

### Monitoring vs. Observability

While observability digs into the why, monitoring focuses on the what. Observability is about understanding the internal workings of your system based on generated data and digging into why problems happen.

Sources:
- [Observability vs Monitoring - Difference Between Data-Based Processes - AWS](https://aws.amazon.com/compare/the-difference-between-monitoring-and-observability/)
- [Microservices Observability: Patterns, Pillars & Tools](https://www.groundcover.com/microservices-observability)
