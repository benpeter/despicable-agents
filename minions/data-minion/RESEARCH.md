# Data Architecture Research

Research backing the data-minion agent system prompt.

## MongoDB Schema Design Patterns

### Core Principles

MongoDB's fundamental principle is that **data accessed together should be stored together**. Structure your data model based on application data access patterns to optimize performance. The choice between embedding and referencing is the foundational decision.

### Embedding vs. Referencing

**Embedding** is ideal for:
- One-to-one or one-to-many relationships
- Related data frequently accessed together
- Ensures data locality, reducing the need for multiple queries
- Denormalization for read performance

**Referencing** is suitable for:
- Many-to-many relationships
- Related data is large or updated frequently
- Avoiding unbounded array growth
- Normalization for write flexibility

### Key Schema Design Patterns

**Polymorphic Pattern**: Store documents with more similarities than differences in a single collection. Allows queries to run across a single collection when there's variety in document structure but shared characteristics.

**Schema Versioning Pattern**: Allows previous and current versions of documents to exist side by side in a collection. Essential as data schemas evolve during an application's lifetime.

**Attribute Pattern**: Useful for large documents with many similar fields where a subset shares common characteristics for sorting or querying. Moves dynamic fields into key-value pairs within a nested document.

**Bucket Pattern**: Time-series or IoT data grouped into buckets. Instead of one document per measurement, store multiple measurements in arrays within a single document.

**Computed Pattern**: Pre-compute expensive calculations and store the results. Particularly useful for aggregations that don't change frequently.

**Subset Pattern**: Store only frequently accessed data in the main document, with full data in a separate collection. Reduces working set size.

### Performance Considerations

**16 MB document size limit** - avoid unbounded arrays that can grow uncontrollably. Use bucketing or referencing to manage large datasets.

**Indexing Best Practices**:
- Compound indexes (combining multiple fields into a single index)
- Covered queries (ensure the index contains all queried fields)
- TTL indexes (automatically expiring data for logs or session data)

Schema design has tremendous impact on application performance - performance issues frequently trace back to poor schema design.

**Sources**:
- [MongoDB Schema Design Best Practices - GeeksforGeeks](https://www.geeksforgeeks.org/mongodb/mongodb-schema-design-best-practices-and-techniques/)
- [MongoDB Schema Design: Data Modeling Best Practices](https://www.mongodb.com/developer/products/mongodb/mongodb-schema-design-best-practices/)
- [Building with Patterns: A Summary](https://www.mongodb.com/blog/post/building-with-patterns-a-summary)
- [Schema Design Patterns - MongoDB Docs](https://www.mongodb.com/docs/manual/data-modeling/design-patterns/)

---

## Vector Databases

### Comparison Matrix

**Pinecone**: Fully managed service with enterprise-grade vector search. Excellent scalability and SLAs. Best managed experience but premium pricing ($50–$500+/mo minimum). Simple path to production for enterprise applications.

**Weaviate**: Schema-based vector database designed for knowledge graphs and contextual search. GraphQL interface makes it highly developer-friendly. Ideal when combining vector search with complex data relationships. Strong for semantic search applications.

**Chroma**: Straightforward approach for internal tools and proof-of-concept systems. Fast time-to-implementation. Best for experimental or academic settings where simplicity matters more than extreme performance.

**pgvector**: PostgreSQL extension adding vector search capabilities. Ideal for teams already using Postgres who want to unify structured data with vector search. Full SQL support and transactional guarantees. Realistically maxes out at 10–100 million vectors before performance degrades. Great for avoiding new infrastructure.

### Scalability Considerations

- Pinecone, Milvus/Zilliz, and Qdrant support **billions of vectors**
- pgvector realistically caps at **10–100 million vectors**
- Chroma and Weaviate scale to medium workloads (millions of vectors)

### Embedding Strategies

Most vector databases (except Weaviate/Chroma modules or Pinecone's Assistant) **don't natively create embeddings**. Typical workflow:
1. Run data through embedding model (OpenAI, Hugging Face, Cohere, etc.)
2. Store the resulting vectors in the database

The **embedding model and database serve different purposes**:
- Embedding model determines quality and relevance of vectors
- Database impacts search performance and scalability
- Even the best database can't compensate for poor embeddings

**Embedding selection considerations**:
- Model dimensionality (384, 768, 1536 dimensions common)
- Domain specificity (general-purpose vs. specialized)
- Multi-language support
- Cost per token
- Inference latency

**Sources**:
- [Exploring Vector Databases - Mehmet Ozkaya](https://mehmetozkaya.medium.com/exploring-vector-databases-pinecone-chroma-weaviate-qdrant-milvus-pgvector-and-redis-f0618fe9e92d)
- [Vector Database Comparison 2025 - LiquidMetal AI](https://liquidmetal.ai/casesAndBlogs/vector-comparison/)
- [Best Vector Databases in 2025 - Firecrawl](https://www.firecrawl.dev/blog/best-vector-databases-2025)
- [The 7 Best Vector Databases in 2026 - DataCamp](https://www.datacamp.com/blog/the-top-5-vector-databases)

---

## Redis / Valkey

### Overview

Valkey is a fork of Redis maintaining API compatibility. Both support the same data structures and patterns. Valkey is fully open-source with open contributions, while Redis changed licensing in 2024.

### Data Structures

- **Strings**: Basic key-value storage
- **Lists**: Ordered collections, implemented as linked lists
- **Sets**: Unordered collections of unique values
- **Sorted Sets**: Sets ordered by score
- **Hashes**: Field-value pairs within a single key (like mini-documents)
- **Bitmaps**: Bit-level operations on strings
- **HyperLogLogs**: Probabilistic cardinality estimation
- **Streams**: Append-only log data structure for message queuing
- **Geo-spatial indices**: Location-based queries

### Design Patterns

**Read-Aside Caching**: Most common pattern. Application checks cache before database. On miss, fetch from database and populate cache with TTL.

**Write-Through**: Write to cache and database simultaneously. Ensures cache consistency but adds latency.

**Write-Behind**: Write to cache immediately, asynchronously persist to database. Higher performance but risk of data loss.

**Pipelining**: Batch multiple commands in a single network round-trip. Reduces latency for bulk operations.

**Pub/Sub**: Real-time messaging with pattern matching. Supports chat rooms, notifications, server-to-server communication.

**Distributed Locking**: Use SETNX or Redlock algorithm for coordination across multiple instances.

**Negative Result Caching**: Cache absence of data (e.g., "user not found") to prevent repeated expensive queries.

### Use Cases

**Caching**: Frequently-accessed data stored client-side in application memory. Session caching, API response caching, computed results.

**Message Queuing**: Ordered delivery of messages to different users. Notification systems, job queues with Streams.

**Real-time Updates**: High-performance, low-latency design supports real-time requirements. Inventory updates, leaderboards, analytics dashboards.

**Rate Limiting**: Token bucket or sliding window algorithms using sorted sets or strings with expiry.

**Session Management**: Store user sessions with automatic expiry via TTL.

**Sources**:
- [Design patterns for Valkey - AWS](https://d1.awsstatic.com/product-marketing/Design%20Patterns%20for%20Valkey.pdf)
- [Valkey vs Redis: How to Choose in 2026](https://betterstack.com/community/comparisons/redis-vs-valkey/)
- [Redis/Valkey Use Cases](https://seholee.com/blog/redis-valkey-usage/)

---

## SQLite / libSQL / Turso

### SQLite as Application Database

SQLite is a **self-contained, serverless, zero-configuration** SQL database engine. The most widely deployed database in the world (in every smartphone, browser, operating system).

**Strengths**:
- Embedded in application (no separate server process)
- Single file database (easy backup, copy, version)
- ACID compliant with full transaction support
- Fast for read-heavy workloads
- Zero administration
- Cross-platform file format

**When to Use SQLite**:
- Local-first applications
- Edge computing
- Mobile applications
- Desktop applications
- Embedded systems
- Development and testing
- Small-to-medium websites (< 100K hits/day)
- Data analysis and analytics pipelines

**When NOT to Use SQLite**:
- High write concurrency (writers block readers)
- Network file systems (locking issues)
- Very large datasets (> 1TB becomes impractical)
- Complex user management (no per-user permissions)

### libSQL

libSQL is an **open-source, open-contribution fork of SQLite** that maintains full compatibility while adding modern features:

**Key Features**:
- SQLite-compatible API and file format
- Encryption at rest
- Embedded replicas (local database that syncs with remote)
- WebAssembly support
- HTTP-based replication protocol
- Server mode for remote access (like PostgreSQL/MySQL)

### Turso

Turso is a **distributed database built on libSQL** for edge deployment. Designed to minimize query latency globally.

**Architecture**:
- Deploy databases everywhere (servers, browsers, devices)
- Embedded replicas in your application (local-speed reads)
- Automatic synchronization between primary and replicas
- HTTP-based protocol (works in serverless environments)

**Use Cases**:
- Global applications with users worldwide
- Edge computing and serverless
- Multi-tenant SaaS (database per tenant)
- AI agents and assistants (embedded intelligence)
- Mobile apps with offline support

**Embedded Replicas**: A local copy of the remote primary database inside your application. Behaves like SQLite but syncs changes automatically. Reads are instant, writes go to primary and sync back.

**Sources**:
- [libSQL - Turso](https://docs.turso.tech/libsql)
- [GitHub - tursodatabase/libsql](https://github.com/tursodatabase/libsql)
- [Why SQLite is so great for the edge](https://turso.tech/blog/why-sqlite-is-so-great-for-the-edge-ee00a3a9a55f)
- [Turso - Databases Everywhere](https://turso.tech/)

---

## DuckDB

### Core Characteristics

DuckDB is an **in-process SQL OLAP database** designed for analytical workloads. "SQLite for analytics" - embedded, lightweight, optimized for complex analytical queries rather than transactional workloads.

**Architecture**:
- Columnar storage format (unlike row-based SQLite)
- Vectorized execution engine (processes data in batches)
- Runs directly within application (no separate server)
- Zero configuration and dependencies

### Performance Patterns

**Vectorized Execution**: Processes chunks of data at a time, dramatically reducing interpreter overhead for large scans and joins.

**Columnar Storage**: Scans only columns needed for query. Parquet becomes first-class storage format, not staging artifact.

**Filter Pushdown**: Push filters as close to data source as possible. Reduces data scanned before processing.

### SaaS and Embedded Analytics Patterns

**Tenant Isolation**: Query-level row filtering or separate database files per tenant.

**File Layouts**: Organize Parquet files by partition keys (date, tenant_id) for efficient pruning.

**Query Limits**: Set max_memory and timeout to prevent runaway queries.

**Extension Strategy**: Vector similarity, geospatial, HTTP, and other extensions available. Load only what you need.

### Data Pipeline Patterns

**Materialized View Pattern**: Long queries fail when mixing cleaning, joining, and metrics. Split work into stages (CTEs or views) with focused purpose. Final view for consumption.

**Parquet-First**: DuckDB scans Parquet column-by-column. Staging stops being "a table" and becomes a declarative expression - pipeline evaluated, not persisted.

**Streaming Inserts**: Handles > 1 million rows inserted per second. Well-suited for materialized view patterns in streaming analytics.

### Query Organization

Use CTEs and views to organize complex analytics:
1. Raw data ingestion (views over Parquet/CSV)
2. Cleaning and normalization (CTEs)
3. Business logic and joins (CTEs)
4. Aggregations and metrics (final view)

Improves both readability and performance through better query plans.

**Sources**:
- [DuckDB: The Analytics Database Revolution - DEV](https://dev.to/emiroberti/duckdb-the-analytics-database-revolution-a-comprehensive-guide-442b)
- [DuckDB Inside Your SaaS: Patterns That Hold Up](https://medium.com/@Praxen/duckdb-inside-your-saas-patterns-that-hold-up-296e9655061d)
- [5 DuckDB CTE + View Patterns for Fast, Clean Analytics](https://medium.com/@connect.hashblock/5-duckdb-cte-view-patterns-for-fast-clean-analytics-be60b14a8237)
- [Streaming Patterns with DuckDB](https://duckdb.org/2025/10/13/duckdb-streaming-patterns)

---

## Kafka Event Streaming

### Architecture and Core Concepts

Kafka is a **distributed event streaming platform** implementing pub/sub architecture with durable, ordered, append-only logs.

**Key Components**:
- **Topics**: Categories for events (like channels)
- **Partitions**: Topics split into ordered, immutable logs for parallelism
- **Producers**: Publish events to topics
- **Consumers**: Subscribe to topics and process events
- **Consumer Groups**: Multiple consumers sharing partition load
- **Brokers**: Kafka servers storing and serving data

**Event Streaming**: Continuous flow of events over time, stored in append-only log. Like a DVR - events recorded as they happen and can be replayed later.

**Pull vs. Push**: Kafka uses **pull model** - consumers request next records from broker. Preferred in practice because:
- Consumers control consumption rate
- Prevents overwhelming consumers
- Enables replay and reprocessing
- Supports multiple consumer groups at different speeds

### Event Streaming Patterns

**Event Notification**: Microservice broadcasts event to signal domain change. Minimal data in event (e.g., "user created", just ID). Loosely coupled - consumers decide whether to act.

**Event-Carried State Transfer**: Full data in event. Consumers maintain local cache without querying origin service. Reduces coupling but increases event size.

**Event Sourcing**: Application state derived from sequence of events. Events are source of truth. Enables audit trails, time travel, replay.

**CQRS (Command Query Responsibility Segregation)**: Separate write and read models. Events from write side update read-optimized views. Often combined with event sourcing.

### Processing Patterns

**Processor Topology**: Graph of stream processors (nodes) connected by streams (edges). Defines computational logic for stream processing application.

**Kafka Streams**: Client library for building stream-processing applications and microservices on Kafka. Handles:
- Partitioning of events
- State redistribution during scaling
- Fault tolerance and rebalancing
- Exactly-once semantics

**Stateful Processing**: Maintain state (aggregations, windows, joins) using local state stores backed by changelog topics in Kafka.

**Windowing**: Group events by time (tumbling, hopping, session windows) for time-based aggregations.

### Reliability and Guarantees

**Exactly-Once Semantics**: No duplicates, no data loss.
- Idempotent producers prevent duplicate writes
- Transactions group reads, state updates, and writes atomically
- Read-committed consumers expose only committed data downstream

**Replication**: Topics replicated across brokers for fault tolerance. Configurable replication factor (typically 3).

**Partitioning Strategy**: Events with same key go to same partition (ordering guarantee). Null key = round-robin distribution.

### Best Practices

**Asynchronous Communication**: Kafka between microservices avoids bottlenecks of synchronous calls. Highly available - outages handled gracefully with minimal interruption.

**Schema Management**: Use schema registry (Confluent Schema Registry, Avro, Protobuf) for event schema evolution and compatibility.

**Topic Design**: Separate topics by domain, not by consumer. Topics are facts about the world, not delivery mechanisms.

**Retention Policies**: Configure based on use case - infinite retention for event sourcing, time-based for operational data, size-based for high-volume streams.

**Monitoring**: Track consumer lag (how far behind consumers are), partition distribution, replication status, throughput.

**Sources**:
- [Event-driven architectures with Kafka and Kafka Streams - IBM](https://developer.ibm.com/articles/awb-event-driven-architectures-with-kafka-and-kafka-streams/)
- [Top 10 Kafka Design Patterns - Tech In Focus](https://medium.com/@techInFocus/top-10-kafka-design-patterns-that-can-optimize-your-event-driven-architecture-0f895e6abff9)
- [Kafka Event-Driven Architecture Done Right](https://estuary.dev/blog/kafka-event-driven-architecture/)
- [Kafka Streams Architecture - Confluent](https://docs.confluent.io/platform/current/streams/architecture.html)

---

## Polyglot Persistence

### Core Philosophy

Polyglot persistence is the practice of using **different database technologies within a single application**, with each database selected based on its fitness for specific data characteristics and access patterns. Recognizes that no single database optimally serves all use cases.

### Key Principles

**Technology-Data Alignment**: Match storage technology to data characteristics and query patterns. Time-series data to time-series DB, documents to document store, relationships to graph DB.

**Independent Scalability**: Different components scale according to specific demands. Cache scales independently from transactional DB from analytical warehouse.

**Evolutionary Architecture**: Support incremental changes and technology adoption. Start simple, add specialized databases as needs arise.

**Performance Optimization**: Leverage databases for their intended workloads rather than forcing one tool to do everything.

### Database Selection Framework

Map requirements to **The Four V's**:
- **Volume**: How much data? (MB to PB)
- **Velocity**: How fast is it changing? (writes/sec)
- **Variety**: How structured? (rigid schema to schema-free)
- **Veracity**: How critical is consistency? (ACID to eventual)

**Selection by Use Case**:
- **ACID Transactions**: PostgreSQL, MySQL, Oracle (relational DBMS)
- **Flexible Documents**: MongoDB, CouchDB, Firestore
- **Relationship Traversal**: Neo4j, Neptune (graph databases)
- **High-Volume Writes**: Cassandra, HBase, DynamoDB (column-family)
- **Ephemeral Data**: Redis, Memcached (in-memory caches)
- **Time-Series**: InfluxDB, TimescaleDB
- **Vector Search**: Pinecone, Weaviate, pgvector
- **Analytics**: DuckDB, Snowflake, BigQuery

### Domain-Driven Design Integration

Use **bounded contexts** from DDD to segment data responsibility:
- Each bounded context owns its data store
- Choose database type appropriate for that context's needs
- Avoid shared databases across bounded contexts
- Event-driven integration between contexts

### Implementation Considerations

**Benefits**:
- Optimized performance per use case
- Right tool for the right job
- Scalability tailored to specific needs
- Technology evolution without full rewrites

**Challenges**:
- Operational complexity (multiple systems to manage)
- Data consistency across stores (eventual consistency patterns)
- Transaction boundaries (distributed transactions difficult)
- Developer expertise across technologies
- Monitoring and observability across systems

**Mitigation Strategies**:
- Start with one database, add others only when justified
- Use managed services to reduce operational burden
- Event streaming (Kafka) for cross-database consistency
- Standardize on observability platform across all databases

**Sources**:
- [Polyglot Persistence: A Strategic Approach](https://medium.com/@rachoork/polyglot-persistence-a-strategic-approach-to-modern-data-architecture-e2a4f957f50b)
- [bliki: Polyglot Persistence - Martin Fowler](https://martinfowler.com/bliki/PolyglotPersistence.html)
- [.NET Architect's Guide to Polyglot Persistence](https://developersvoice.com/blog/scalability/dotnet-polyglot-persistence-guide/)
- [Polyglot Persistence vs Multi-Model Databases](https://circleci.com/blog/polyglot-vs-multi-model-databases/)

---

## CQRS and Event Sourcing

### CQRS (Command Query Responsibility Segregation)

**Core Principle**: Separate write operations (commands) from read operations (queries). A method should either read or write data - never both.

**Architecture**:
- **Write Model (Command Side)**: Handles state mutations, enforces business rules, optimized for consistency
- **Read Model (Query Side)**: Denormalized views optimized for query performance
- **Synchronization**: Events or change data capture keeps read models updated

**When to Use CQRS**:
- Read/write ratio heavily skewed (many more reads than writes)
- Different scaling requirements for reads vs writes
- Different teams working on read vs write logic
- Complex domain requiring domain-driven design
- Need for multiple read representations (different views of same data)

**Benefits**:
- Independent scaling of reads and writes
- Optimized data models for each use case
- Read models can be rebuilt from events
- Simplified query logic (no complex joins)

### Event Sourcing

Store application state as **chronological sequence of events**. Events are immutable facts about what happened. Current state derived by replaying events.

**Event Store**: Append-only log of all events. Source of truth for application state.

**Projection**: Process events to build read models (materialized views). Can rebuild at any time by replaying events.

**Benefits**:
- Complete audit trail (who did what when)
- Time travel (state at any point in history)
- Replay events for debugging
- Enable new features by replaying old events
- Natural fit for event-driven architectures

**Challenges**:
- Event schema evolution (events stored forever)
- Query complexity (may need to replay many events)
- Storage requirements (all events retained)
- Eventual consistency between write and read models

### Combined CQRS + Event Sourcing

**Synergy**: Event store is write model and source of truth. Read models generated from events, typically highly denormalized.

**Data Flow**:
1. Command arrives, validated against write model
2. Event stored in event store
3. Event published to message broker
4. Read model subscribers update their views
5. Queries served from optimized read models

**Synchronization Methods**:
- Message brokers (Kafka) for pub/sub
- Change data capture (CDC) from event store
- Polling event store for new events

**Read Replicas**: Write operations to primary database, reads to replicas. After command stored in write DB, events trigger updates in read (query) DB.

**Scaling Benefits**: Most beneficial when reads >> writes. Read model scales horizontally for query load, write model runs on fewer instances.

**Sources**:
- [CQRS Pattern - Azure Architecture](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs)
- [Pattern: CQRS - Microservices.io](https://microservices.io/patterns/data/cqrs.html)
- [CQRS Pattern - AWS Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/cqrs-pattern.html)
- [What is CQRS in Event Sourcing - Confluent](https://developer.confluent.io/courses/event-sourcing/cqrs/)
- [Understanding Event Sourcing and CQRS](https://mia-platform.eu/blog/understanding-event-sourcing-and-cqrs-pattern/)

---

## Serverless Databases

### Overview

Serverless databases abstract infrastructure management, automatically scale based on load, and charge based on actual usage rather than provisioned capacity.

### Neon

**Architecture**: Shared-storage separating compute and storage. Compute is standard Postgres, storage is custom-built multi-tenant system shared across compute nodes.

**Key Features**:
- True serverless (auto-scaling, scale-to-zero)
- Database branching (instant copies for dev/test)
- Standard Postgres (all extensions work)
- Separate compute and storage pricing
- Sub-second cold starts

**Use Cases**: Pure PostgreSQL experience with instant branching, serverless scaling, minimal vendor lock-in. Ideal for Postgres purists.

**Recent**: Acquired by Databricks (May 2025).

### Supabase

**Architecture**: Backend-as-a-Service (BaaS) with Postgres as one component.

**Key Features**:
- Auth + Database + Storage + Realtime + Edge Functions
- Row Level Security (RLS) at database layer
- Real-time subscriptions on database changes
- PostgREST for instant APIs
- Database branching (less mature than Neon/PlanetScale)

**Use Cases**: Comprehensive backend platform for rapid application development. Choose when you need integrated backend services, not just database.

### PlanetScale

**Architecture**: Built on Vitess (YouTube's MySQL scaling solution).

**Key Features**:
- Highly scalable MySQL and PostgreSQL
- Database branching with deploy requests
- Non-blocking schema changes
- Global data distribution
- Horizontal sharding built-in

**Use Cases**: Scaling existing MySQL applications or building highly available applications with global distribution. Gold standard for MySQL scalability.

### Turso (covered in SQLite section)

**Architecture**: Distributed libSQL (SQLite fork) for edge deployment.

**Key Features**:
- SQLite compatibility
- Embedded replicas (local database + remote sync)
- Deploy databases globally
- HTTP-based protocol

**Use Cases**: Edge applications, multi-tenant SaaS (DB per tenant), global low-latency apps.

### Comparison Summary

**Choose Neon** if you:
- Need pure PostgreSQL
- Want database branching for dev workflows
- Value minimal vendor lock-in
- Don't need integrated auth/storage

**Choose Supabase** if you:
- Want comprehensive BaaS (auth, storage, functions)
- Need real-time features
- Prefer integrated platform over best-of-breed
- Building product, not managing infrastructure

**Choose PlanetScale** if you:
- Need massive scale (millions of users)
- Use MySQL or migrating from MySQL
- Require global distribution
- Need non-blocking schema migrations

**Choose Turso** if you:
- Building edge-first applications
- Need multi-tenant with DB-per-tenant
- Want embedded replicas for offline support
- Prefer SQLite developer experience

**Sources**:
- [6 Best Serverless SQL Databases for Developers (2026)](https://www.devtoolsacademy.com/blog/serverless-sql-databases/)
- [Neon vs. Supabase: Which One Should I Choose](https://www.bytebase.com/blog/neon-vs-supabase/)
- [Comparing Popular Cloud Databases - Neon, Supabase, PlanetScale](https://kenny-io.hashnode.dev/comparing-popular-cloud-databases-neon-supabase-planetscale)
- [Supabase vs PlanetScale vs Neon](https://getsabo.com/blog/supabase-vs-neon)

---

## Connection Pooling, Replication, and Sharding

### Connection Pooling

**Problem**: Each request creating its own database connection overwhelms the database with connection management overhead rather than query processing.

**Solution**: Connection pooling caps connections, reuses them, prevents connection storms.

**Benefits**:
- Reduced connection overhead
- Lower memory usage on database
- Prevents connection exhaustion
- Faster response times (connections already established)

**Popular Poolers**:
- **PgBouncer** (PostgreSQL): Lightweight, efficient
- **pgpool-II** (PostgreSQL): Connection pooling + load balancing
- **HikariCP** (Java): High-performance JDBC pooler
- **SQLAlchemy** (Python): Built-in pooling

**Configuration Considerations**:
- **Pool Size**: Match to database connection limit and application needs
- **Max Overflow**: Additional connections allowed during spikes
- **Timeout**: How long to wait for available connection
- **Recycle Time**: Close connections after age to prevent stale connections

### Database Replication

**Purpose**: Create copies of database on multiple servers to distribute read traffic and improve availability.

**Master-Slave (Primary-Replica) Replication**:
- One instance handles all writes
- Multiple replicas synchronize from master
- Replicas handle read operations
- Most common pattern

**Multi-Master Replication**:
- Multiple instances accept writes
- Changes synchronized between masters
- Complex conflict resolution
- Use when writes needed across regions

**Synchronous vs. Asynchronous**:
- **Synchronous**: Write confirmed only after replicas acknowledge (stronger consistency, higher latency)
- **Asynchronous**: Write confirmed immediately, replicas update later (lower latency, eventual consistency)

**Benefits**:
- Read scalability (distribute queries across replicas)
- Availability (failover to replica if master fails)
- Reduced latency (replicas near users)
- Load reduction on master

### Database Sharding

**Definition**: Horizontally partition data across multiple independent database instances. Each shard contains subset of total data.

**Sharding Strategies**:

**Range-Based Sharding**: Data divided by ranges (e.g., A-M on shard1, N-Z on shard2)
- Simple to implement
- Risk of uneven distribution

**Hash-Based Sharding**: Hash function determines shard (e.g., hash(user_id) % num_shards)
- Even distribution
- Difficult to rebalance

**Geographic Sharding**: Data divided by region
- Reduced latency for regional queries
- Natural fit for GDPR/data sovereignty

**Directory-Based Sharding**: Lookup table maps entities to shards
- Flexible reassignment
- Additional lookup overhead

**Benefits**:
- Horizontal scalability beyond single server
- Improved query performance (smaller datasets per shard)
- Fault isolation (one shard failure doesn't affect others)

**Challenges**:
- Cross-shard queries expensive
- Distributed transactions complex
- Rebalancing difficult
- Application awareness required

### Sharded Replication (Combined Approach)

**Architecture**: Each shard has primary + replicas. Combines benefits of both patterns.

**Data Flow**:
1. Data sharded across multiple primary instances (by shard key)
2. Each primary has one or more replicas
3. Read queries distributed across replicas of appropriate shard
4. Write operations directed to primary of corresponding shard

**Benefits**:
- Horizontal scaling (sharding) + read scaling (replication)
- High availability per shard
- Reduced latency (read replicas near users)

**Use Cases**: Large-scale applications needing both write and read scalability (social networks, SaaS platforms, ecommerce).

**Sources**:
- [Understanding Database Scaling and Sharding Patterns](https://pulkitxm.com/blogs/understanding-database-scaling-sharding)
- [Replication vs. Partitioning vs. Sharding](https://noncodersuccess.medium.com/replication-vs-partitioning-vs-sharding-vs-database-federation-96d7c7db8b1e)
- [Scaling PostgreSQL: Read Replicas, Sharding, and Beyond](https://www.meerako.com/blogs/postgresql-database-scaling-strategies-sharding-replication)
- [Replication, Clustering, and Connection Pooling - PostgreSQL wiki](https://wiki.postgresql.org/wiki/Replication,_Clustering,_and_Connection_Pooling)

---

## Edge and Embedded Database Patterns

### Edge Database Characteristics

**Edge databases run close to users/devices** rather than centralized data centers. Goals: minimize latency, enable offline operation, reduce bandwidth.

**Key Technologies**:
- **Cloudflare D1**: SQLite at the edge on Cloudflare Workers
- **Turso/libSQL**: Distributed SQLite with embedded replicas
- **DuckDB**: Embedded analytics at the edge
- **IndexedDB**: Browser-based NoSQL storage

### Embedded Database Patterns

**Local-First Architecture**: Application works offline with local database. Syncs changes when online.

**Benefits**:
- Instant reads (no network)
- Offline functionality
- Reduced bandwidth costs
- Lower backend load

**Challenges**:
- Conflict resolution (concurrent offline edits)
- Data size limits (client storage constraints)
- Schema migrations (client databases at different versions)

### Edge Replication Patterns

**Hub-and-Spoke**: Central primary database, edge replicas for reads. Writes go to primary, replicated to edges.

**Multi-Write with CRDT**: Conflict-free replicated data types allow concurrent writes at multiple edges. Eventually consistent.

**Change-Based Sync**: Track changes since last sync (timestamps, version vectors). Send deltas rather than full state.

### Use Cases

**Multi-Tenant SaaS**: Database per tenant at edge. Isolated, fast, scales linearly with tenants.

**AI Agents**: Embedded database in agent for context/memory. No external dependencies.

**Mobile Apps**: SQLite on device with cloud sync. Works offline, fast local queries.

**Analytics at Edge**: DuckDB embedded for log analysis, metrics aggregation before sending to central warehouse.

---

## Database Selection Decision Framework

### Step 1: Understand Access Patterns

**Questions to Ask**:
- Read-heavy or write-heavy? (ratio?)
- Simple lookups or complex queries?
- Transactional consistency required?
- Real-time or analytical workload?
- Data access patterns (by key, range, relationship, full-text)?

### Step 2: Evaluate Data Characteristics

**Structure**:
- Rigid schema? → Relational (PostgreSQL, MySQL)
- Flexible documents? → Document store (MongoDB)
- Key-value pairs? → Redis/Valkey
- Relationships central? → Graph (Neo4j)
- Time-series? → InfluxDB, TimescaleDB
- Vectors for AI? → Pinecone, Weaviate, pgvector

**Volume**:
- < 1GB: SQLite, embedded databases
- 1GB - 1TB: PostgreSQL, MySQL, MongoDB
- > 1TB: Distributed databases (Cassandra, sharded PostgreSQL)

**Velocity**:
- < 1K writes/sec: Most relational databases
- 1K - 100K writes/sec: Tuned relational or NoSQL
- > 100K writes/sec: Cassandra, Kafka + stream processing

### Step 3: Match Scalability Requirements

**Vertical Scaling**: Bigger single server
- Simplest to manage
- Limited by hardware
- PostgreSQL, MySQL can scale vertically far

**Horizontal Scaling - Replication**: Read replicas
- Scales reads, not writes
- Adds availability
- Works for most read-heavy apps

**Horizontal Scaling - Sharding**: Partition data
- Scales reads AND writes
- Complex to manage
- Use only when vertical + replication insufficient

### Step 4: Consider Operational Constraints

**Self-Hosted vs. Managed**:
- Self-hosted: More control, more operational burden
- Managed: Less control, less operational burden, higher cost

**Expertise Available**:
- Team knows PostgreSQL well? → PostgreSQL
- No database expertise? → Managed service (Supabase, Neon)

**Budget**:
- Tight budget? → Self-hosted PostgreSQL, SQLite
- Willing to pay for convenience? → Managed services

### Step 5: Polyglot Persistence Decision

**Start Simple**: One database initially (usually PostgreSQL).

**Add Specialized Databases When**:
- Clear performance bottleneck (caching → Redis)
- Different access pattern (analytics → DuckDB)
- Specific capability needed (search → Elasticsearch, vector → Pinecone)

**Avoid Premature Polyglot**: Operational complexity has real cost. Justify each additional database with measured performance gain or specific capability requirement.

### Common Patterns

**Transactional + Cache**: PostgreSQL/MySQL + Redis
**Transactional + Search**: PostgreSQL + Elasticsearch
**Transactional + Analytics**: PostgreSQL + DuckDB/BigQuery
**Transactional + Vector AI**: PostgreSQL + Pinecone (or pgvector if scale permits)
**Event-Driven**: Kafka + multiple downstream stores
**Global Low-Latency**: Turso/D1 (edge SQLite) + Redis (edge cache)

---

## Summary

Data architecture in modern applications is about **choosing the right tool for each job** while managing complexity. Key principles:

1. **Start with access patterns, not technology** - understand how data will be queried before selecting database
2. **Embedded and edge databases are underrated** - SQLite, libSQL/Turso, DuckDB solve more problems than assumed
3. **Vector search is first-class in AI era** - treat it as core concern, not afterthought
4. **Kafka for event streaming** - when you need event-driven architecture, Kafka is the proven foundation
5. **Polyglot persistence is fine when justified** - but every additional database has operational cost
6. **CQRS when reads >> writes** - separate models enables independent scaling
7. **Replication before sharding** - simpler and solves most scaling problems
8. **Choose databases for their strengths** - documents to MongoDB, relationships to Neo4j, caching to Redis, analytics to DuckDB

The best data architecture is one that **matches your specific needs** rather than following trends. Complexity should be justified by measurable requirements, not speculation.
