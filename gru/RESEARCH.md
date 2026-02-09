# Gru Research: AI/ML Technology Landscape & Strategic Assessment

Research compiled for the gru agent -- AI technology radar, trend evaluation,
and strategic technology decision support.

---

## 1. Technology Readiness Frameworks

### ThoughtWorks Technology Radar

The ThoughtWorks Technology Radar is the industry gold standard for
practitioner-driven technology assessment, published biannually by ThoughtWorks'
Technology Advisory Board. The framework uses four rings:

- **Adopt** -- strong confidence, proven in production, should be standard
- **Trial** -- ready for use but not fully proven; worth investing in on a project
- **Assess** -- worth exploring to understand impact; not ready for trial
- **Hold** -- proceed with caution; do not start new work with this

The radar organizes technologies into four quadrants: Techniques, Tools,
Platforms, and Languages & Frameworks.

**Volume 33 (November 2025) highlights:**
- Context engineering consolidation -- the practice of systematically managing
  what goes into an LLM context window is maturing
- MCP protocol adoption acceleration
- Agentic systems powered by SLMs (Small Language Models) -- the radar
  recommends SLMs as the default for agentic workflows, reserving large models
  only when necessary
- Continuous compliance (Adopt) -- policy-as-code with OPA, SBOMs in CD pipelines
- MCP-powered UI testing (Trial) -- Playwright and Selenium MCP servers

Sources:
- https://www.thoughtworks.com/radar
- https://www.thoughtworks.com/content/dam/thoughtworks/documents/radar/2025/11/tr_technology_radar_vol_33_en.pdf
- https://www.thoughtworks.com/about-us/news/2025/thoughtworks-tech-radar-33-rapid-ai

### Gartner Hype Cycle

The Gartner Hype Cycle maps technologies through five stages:

1. **Innovation Trigger** -- breakthrough, early proofs-of-concept, media interest
2. **Peak of Inflated Expectations** -- success stories plus many failures
3. **Trough of Disillusionment** -- interest wanes, providers shake out
4. **Slope of Enlightenment** -- second/third-gen products, broader adoption
5. **Plateau of Productivity** -- mainstream adoption, market viability clear

**2025 Hype Cycle for AI key positions:**
- AI Agents -- Peak of Inflated Expectations (fastest advancing)
- AI-Ready Data -- Peak of Inflated Expectations
- Generative AI -- entering Trough of Disillusionment; >80% production adoption
  projected by 2026
- Synthetic Data -- climbing Slope of Enlightenment
- AI Engineering / ModelOps -- cornerstone of enterprise AI systems

**Critical limitation**: The hype cycle's predictive accuracy is disputed. Studies
show fewer than 20% of technologies follow the classic five-stage pattern. Use
it as a conversation framework, not a predictive model.

Sources:
- https://www.gartner.com/en/newsroom/press-releases/2025-08-05-gartner-hype-cycle-identifies-top-ai-innovations-in-2025
- https://www.gartner.com/en/articles/hype-cycle-for-artificial-intelligence
- https://www.pragmaticcoders.com/blog/gartner-ai-hype-cycle

### Practical Hype Detection Methodology

Separating signal from noise requires looking beyond announcements:

1. **Production usage** -- who is running this in production, at what scale?
2. **Community velocity** -- GitHub stars are vanity; contributor count, issue
   resolution rate, and release cadence are substance
3. **Second-order effects** -- are companies hiring for it? Are conferences
   dedicating tracks to it?
4. **Failure stories** -- absence of public failure reports often means the
   technology is not being used seriously
5. **Benchmark independence** -- who created the benchmark? Self-benchmarking
   is marketing
6. **Revenue signal** -- are customers paying for it, or is it funded by VC
   subsidies?

---

## 2. Foundation Model Landscape (2025-2026)

### Current Leaderboard Snapshot

**Chatbot Arena (LMSYS/LMArena) -- December 2025:**
- Gemini 3 Pro leads overall Arena (1501 Elo)
- Grok 4.1 (1483 Elo)
- Claude Opus 4.5
- GPT-5.2

**SWE-bench Verified (software engineering):**
- Claude Opus 4.5 -- first model to break 80% (80.9%)
- Indicates strong coding/reasoning capability gap between model families

**Pattern**: Google dominates multimodal/scientific reasoning; Anthropic leads
coding/safety; OpenAI and xAI compete on general-purpose reasoning.

Sources:
- https://lmarena.ai/
- https://arena.ai/leaderboard
- https://llm-stats.com/leaderboards/llm-leaderboard

### Open Source vs. Proprietary

The performance gap has effectively collapsed:
- MMLU benchmark gap narrowed from 17.5 to 0.3 percentage points in one year
- 89% of organizations using AI leverage open-source models in some form
- Companies using open-source tools report 25% higher ROI vs. proprietary-only

**Key open-source families:**
- **DeepSeek** -- reasoning transparency; chain-of-thought visibility; strong
  for cost-controlled or air-gapped deployments
- **Qwen** (Alibaba) -- strongest multilingual capabilities; leads math/coding
  benchmarks (92.3% AIME25)
- **Mistral** -- Apache 2.0 licensed; efficient MoE architectures; strong
  European ecosystem
- **Llama** (Meta) -- largest ecosystem; strong community tooling

**Strategic implication**: Open-weight models are viable for production. The
decision is no longer "can we use open source?" but "when should we NOT use
open source?" -- typically: highest-stakes reasoning tasks, regulated
environments requiring vendor SLAs, or when proprietary model capabilities
genuinely differentiate.

Sources:
- https://developers.redhat.com/articles/2026/01/07/state-open-source-ai-models-2025
- https://huggingface.co/blog/daya-shankar/open-source-llms
- https://www.swfte.com/blog/open-source-ai-models-frontier-2026

### Three Scaling Laws

Model improvement now follows three distinct scaling paths:

1. **Pre-training scale** -- still the most expensive; diminishing returns at
   the frontier without complementary techniques
2. **Post-training optimization** -- fine-tuning, RLHF, distillation unlock
   significant capability from existing base models
3. **Inference-time compute** -- smaller models "thinking longer" can match
   larger models "thinking less"; democratizes access to advanced reasoning

Inference-time scaling proved that intelligence is not solely about parameter
count. This is the most impactful shift for practitioners: you can often get
better results by spending more inference compute than by upgrading models.

Sources:
- https://magazine.sebastianraschka.com/p/state-of-llms-2025
- https://machinelearningmastery.com/7-agentic-ai-trends-to-watch-in-2026/

---

## 3. Agent Protocols and Standards

### Model Context Protocol (MCP)

MCP has become the de facto standard for connecting AI models to external tools,
databases, and APIs. Originally released by Anthropic in late 2024, it achieved
broad adoption throughout 2025.

**November 2025 specification (latest):**
- **Tasks primitive** -- asynchronous long-running operations; servers create
  tasks, publish progress, deliver results when complete
- **Streamable HTTP transport** -- enables remote MCP deployments; stateless
  support improving
- **Server discovery via .well-known URLs** -- servers advertise capabilities
  without requiring connection first
- **OAuth resource server classification** -- MCP servers now officially OAuth
  Resource Servers per June 2025 spec update
- **Resource Indicators** -- prevent malicious servers from obtaining tokens
  scoped to other resources

**Why MCP won**: It worked with existing AI assistants from day one. Community
beat corporate backing. Being first with a working solution beats being best
with a future solution.

Sources:
- https://modelcontextprotocol.io/specification/2025-11-25
- http://blog.modelcontextprotocol.io/posts/2025-11-25-first-mcp-anniversary/
- https://www.lakera.ai/blog/what-the-new-mcp-specification-means-to-you-and-your-agents

### Google Agent-to-Agent (A2A) Protocol

Launched April 2025 with 50+ technology partners. Now under the Linux Foundation.
Version 0.3 released July 2025 with 150+ supporting organizations.

**Complementary to MCP**: MCP handles agent-to-tool communication; A2A handles
agent-to-agent coordination. In theory complementary; in practice, MCP has
become dominant because most real-world use cases are tool integration, not
multi-vendor agent orchestration.

**Adoption challenge**: By September 2025, A2A had faded from developer
mindshare. MCP's community momentum proved more durable than A2A's corporate
backing. The lesson: protocols win by serving today's use case, not tomorrow's
architecture.

Sources:
- https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/
- https://blog.fka.dev/blog/2025-09-11-what-happened-to-googles-a2a/
- https://www.koyeb.com/blog/a2a-and-mcp-start-of-the-ai-agent-protocol-wars

### OpenAI Agents SDK

Production-ready evolution of the experimental Swarm framework. Lightweight
multi-agent framework with minimal abstractions. Added MCP support and AGENTS.md
specification. Available in Python and TypeScript.

Sources:
- https://openai.github.io/openai-agents-python/
- https://platform.openai.com/docs/guides/agents-sdk

### IETF Draft Specifications (Emerging)

Multiple IETF drafts emerged in October 2025 for agent standardization:
- **agent:// URI Protocol** -- URI-based framework with transport bindings
  (HTTPS, WebSocket, Matrix, Local IPC)
- **HAIDIP** -- HTTP-Based AI Agent Discovery and Invocation Protocol
- **A2T** -- AI Agent to Tool Protocol
- **Agent Networks Framework** -- integrates W3C DID and Verifiable Credentials
  for agent identity
- **SCIM for AI** -- extending identity provisioning for agents

**Assessment**: These are early-stage drafts (expiring April 2026). None have
gained meaningful adoption. Worth monitoring but not worth building on. The
industry is standardizing around MCP + HTTP, not new URI schemes.

Sources:
- https://datatracker.ietf.org/doc/draft-zyyhl-agent-networks-framework/
- https://datatracker.ietf.org/doc/draft-narvaneni-agent-uri/02/
- https://datatracker.ietf.org/doc/draft-rosenberg-aiproto-framework/

---

## 4. Agentic AI: From Hype to Production

### Production Readiness

Gartner predicts 40% of enterprise applications will embed AI agents by end of
2026, up from <5% in 2025. Inquiry volume for multi-agent systems surged 1,445%
from Q1 2024 to Q2 2025.

**Key patterns emerging:**
- Single all-purpose agents being replaced by orchestrated specialist teams
- SLMs (Small Language Models) increasingly preferred for individual agent tasks
- Larger models reserved for planning/orchestration layers
- Context engineering becoming a formal discipline

**Production readiness signals:**
- Multi-agent frameworks moving from experimentation to production
- Protocol maturity (MCP Tasks primitive enables real async workflows)
- Observability integration (structured logging of agent actions, token tracking)
- Cost predictability improving through SLM usage and prompt caching

Sources:
- https://machinelearningmastery.com/7-agentic-ai-trends-to-watch-in-2026/
- https://siliconangle.com/2026/01/18/2026-data-predictions-scaling-ai-agents-via-contextual-intelligence/
- https://foundationcapital.com/where-ai-is-headed-in-2026/

---

## 5. Inference Optimization and Edge AI

### Key Optimization Techniques

**Quantization**: 8-15x compression with <1% accuracy loss. 16-bit to 4-bit
means 4x less memory traffic per token -- critical for bandwidth-constrained
edge devices. Production-ready.

**Speculative Decoding**: Small draft model proposes tokens; larger model
verifies in parallel. 2-3x speedups. Requires careful model pairing but
delivers consistent latency improvements.

**Mixture of Experts (MoE)**: Routes queries through specialist sub-networks.
Strong price-performance tradeoff. Mistral and DeepSeek both leverage MoE
architectures effectively.

**Distillation**: Smaller models trained on larger model outputs. Central to
the open-source model ecosystem. 2025 revealed how much capability this unlocks.

Sources:
- https://developer.nvidia.com/blog/top-5-ai-model-optimization-techniques-for-faster-smarter-inference/
- https://developer.nvidia.com/blog/an-introduction-to-speculative-decoding-for-reducing-latency-in-ai-inference/

### On-Device and Edge Inference

**ExecuTorch (Meta)** hit 1.0 GA in October 2025:
- 50KB base footprint
- 12+ hardware backends (Apple, Qualcomm, Arm, MediaTek, Vulkan)
- 80%+ of popular edge LLMs on HuggingFace work out of the box

**Hardware constraint reality**: Mobile NPUs have 50-90 GB/s memory bandwidth
vs. data center GPUs at 2-3 TB/s -- a 30-50x gap that determines practical
model sizes and throughput.

**Edge AI inference platforms:**
- **Fastly Compute** -- WebAssembly-based edge compute with microsecond-level
  cold starts (35.4 microseconds -- 100x faster than other serverless). Each
  request runs in an isolated Wasm sandbox. Supports Rust, Go, JavaScript, and
  other Wasm-compatible languages. Ideal for request-level logic, A/B testing,
  header manipulation, and lightweight inference at the edge
- **Cloudflare Workers AI** -- inference across 200+ cities, 50+ models,
  OpenAI-compatible API. Integrates with Vectorize (vector DB), R2 (storage),
  D1 (SQL), AI Gateway. Roadmap includes 70B parameter models on edge GPUs

Sources:
- https://v-chandra.github.io/on-device-llms/
- https://www.edge-ai-vision.com/2026/01/on-device-llms-in-2026-what-changed-what-matters-whats-next/
- https://www.fastly.com/resources/datasheets/edge-compute/fastly-compute
- https://developers.cloudflare.com/workers-ai/

---

## 6. AI Regulation Landscape

### EU AI Act Implementation Timeline

The EU AI Act is the world's first comprehensive AI regulation framework.

**Already in effect:**
- August 1, 2024 -- Act entered into force
- February 2, 2025 -- Prohibited AI practices + AI literacy obligations
- August 2, 2025 -- GPAI model rules; governance structures (AI Board,
  Scientific Panel, Advisory Forum); national competent authorities designated

**Upcoming deadlines:**
- **August 2, 2026** -- Majority of rules become enforceable; high-risk AI
  systems (Annex III); transparency rules (Article 50); innovation sandboxes
  required (one per member state); national + EU-level enforcement begins
- **August 2, 2027** -- Rules for high-risk AI in regulated products

**Penalties:**
- Up to EUR 35M or 7% global turnover for prohibited practices
- Up to EUR 15M or 3% for other obligation violations
- Up to EUR 7.5M or 1% for misleading information to authorities

**Practical impact for technology decisions:**
- AI systems classification by risk tier is mandatory
- Transparency obligations affect all GenAI-powered products
- Documentation and human oversight requirements for high-risk systems
- Innovation sandboxes provide safe harbor for experimentation

Sources:
- https://artificialintelligenceact.eu/implementation-timeline/
- https://www.softwareimprovementgroup.com/blog/eu-ai-act-summary/
- https://www.dlapiper.com/en-us/insights/publications/2025/08/latest-wave-of-obligations-under-the-eu-ai-act-take-effect

---

## 7. VC Investment Patterns in AI

### 2025 Funding Landscape

- AI funding increased 75%+ year-over-year from $114B in 2024
- Foundation model companies raised $80B in 2025 (40% of global AI funding)
- U.S. dominance: $159B (79% of global AI funding)
- Global VC hit $120B in Q3 2025 alone (fourth consecutive $100B+ quarter)
- Hyperscaler capex: $300B+ committed in 2025, increasing for 2026

**Key trends:**
- Microsoft, Google, Amazon, NVIDIA account for >50% of all global AI venture
  investment
- Enterprise AI revenue reached $37B in 2025 ($18B in infrastructure)
- Capital concentration: fewer, larger rounds; fewer winners
- Vertical AI (healthcare, finance, legal) attracting targeted investment

### 2026 Predictions

- Enterprise AI budgets increasing but concentrating (more money, fewer vendors)
- Infrastructure layer consolidation expected
- Observability and AI cost management emerging as investment categories

**Investment signals for technology evaluation:**
- Heavy infrastructure investment validates the compute thesis
- Vertical AI investment signals that horizontal platform plays are maturing
- Observability investment signals production adoption is real
- Cost management focus signals the "build everything with AI" phase is
  rationalizing

Sources:
- https://news.crunchbase.com/ai/big-funding-trends-charts-eoy-2025/
- https://news.crunchbase.com/venture/crunchbase-predicts-vcs-expect-more-funding-ai-ipo-ma-2026-forecast/
- https://techcrunch.com/2025/12/30/vcs-predict-enterprises-will-spend-more-on-ai-in-2026-through-fewer-vendors/

---

## 8. Observability for AI Systems

### Coralogix: Leading Observability Platform

Coralogix represents the state-of-the-art in modern observability, particularly
for AI-era workloads:

- **Streama engine** -- eliminates excessive sampling and retention limits;
  enables full data ingestion with real-time insights at lower cost
- **DataPrime query engine** -- unifies logs, metrics, and traces in a single
  query language
- **AI Observability** -- real-time tracking for agent performance, cost,
  quality, security, and anomalies across every AI interaction
- **Olly** -- autonomous observability agent (industry first); enables
  non-technical stakeholders to query observability data
- **Pricing model** -- based on data volume ingested/retained; mix and match
  across data types

**Market position**: Surpassed $1B valuation (June 2025, $115M round). Ranked
#1 in G2 Momentum Grid for Observability Software. Earned 192 G2 badges in
Winter 2026 reports.

**Relevance to technology decisions**: Any AI system running in production needs
observability that understands token usage, agent action chains, cost per
inference, and quality metrics. Observability is a prerequisite for confident
adoption decisions.

Sources:
- https://coralogix.com/
- https://coralogix.com/platform/ai-observability/
- https://www.globenewswire.com/news-release/2025/06/17/3100567/0/en/Coralogix-Surpasses-1B-Valuation-and-Unveils-Industry-s-First-AI-Agent-That-Extends-Observability-Value-Across-the-Enterprise.html

---

## 9. Technology Decision Framework

### The Adopt/Trial/Assess/Hold Decision Matrix

When evaluating a technology for the radar, apply these filters:

**Adopt criteria:**
- Proven in production at multiple organizations
- Clear migration path from alternatives
- Active community and vendor support
- Well-understood failure modes
- Cost model is predictable

**Trial criteria:**
- Working production deployments exist (not just demos)
- Clear value proposition over current approach
- Acceptable risk if the trial fails
- Team has bandwidth and skill to evaluate properly

**Assess criteria:**
- Interesting capability with potential strategic value
- Too early for production commitment
- Worth tracking with dedicated time allocation
- Good for internal experimentation or hackathons

**Hold criteria:**
- Either too immature or actively problematic
- Better alternatives exist
- Migration cost from current approach not justified
- Or: previously adopted technology that should be phased out

### Build vs. Wait vs. Watch Framework

For AI-specific decisions, add a temporal dimension:

- **Build now** -- technology is mature, competitive advantage from early
  implementation, waiting has opportunity cost
- **Wait** -- technology is promising but immature; implementation cost will
  drop significantly within 6-12 months; standards are still evolving
- **Watch** -- interesting but unproven; monitor for production signals;
  assign someone to track but do not allocate engineering time

**Signals that "wait" is the right call:**
- Specification is still changing (version < 1.0 or frequent breaking changes)
- Most usage is in demos, not production
- No established best practices for error handling and failure modes
- Vendor lock-in risk without clear exit strategy
- Cost model is unpredictable or subsidized

### Risk Assessment: Early vs. Late Adoption

**Early adoption risks:**
- Technical debt from pre-1.0 APIs
- Integration costs when standards shift
- Talent scarcity (few people know the technology)
- Vendor viability uncertainty

**Late adoption risks:**
- Competitive disadvantage if the technology is transformative
- Technical debt from NOT adopting (legacy lock-in)
- Talent loss (developers want to work with modern tools)
- Higher migration cost as ecosystem matures without you

**The sweet spot**: Trial when production signals emerge but before mainstream
adoption creates talent competition. Most organizations should be in "adopt"
when ThoughtWorks puts something in "trial" and in "trial" when ThoughtWorks
puts something in "assess."

---

## 10. Current Technology Radar Assessment (February 2026)

Based on all research above, here is a practitioner-focused radar:

### Adopt
- MCP for tool integration
- Prompt caching / context engineering
- SLMs for agentic workflows
- Quantized inference (4-bit/8-bit)
- OpenTelemetry for AI system observability
- Infrastructure-as-code for AI deployments

### Trial
- Multi-agent architectures with specialist agents
- MCP Tasks (async operations)
- Edge AI inference (Cloudflare Workers AI, Fastly Compute)
- Open-weight models for production (DeepSeek, Qwen, Mistral)
- EU AI Act compliance tooling

### Assess
- A2A protocol for multi-vendor agent orchestration
- IETF agent protocol drafts (agent://, HAIDIP)
- On-device LLMs via ExecuTorch
- Speculative decoding in production
- Autonomous observability agents

### Hold
- Building custom agent protocols (use MCP instead)
- Single monolithic LLM approaches (use model routing)
- Ignoring AI regulation timelines
- Proprietary-only model strategies (maintain open-source options)
