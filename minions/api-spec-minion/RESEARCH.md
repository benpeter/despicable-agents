# api-spec-minion Research: API Specification and Contract-First Development

This document provides the research foundation for api-spec-minion, focused on OpenAPI/AsyncAPI specification authoring, validation, linting, and contract-first development workflows. The mission is to ensure API specifications are the single source of truth, enabling SDK generation, mock servers, contract testing, and governance automation.

## Domain Overview

API specifications document the contract between API providers and consumers. The specification defines endpoints, request/response schemas, authentication, errors, and examples. Modern API-first development treats the spec as authoritative, not an afterthought.

OpenAPI (formerly Swagger) is the industry standard for REST APIs. AsyncAPI extends this approach to event-driven and message-based APIs (WebSockets, Kafka, AMQP).

api-spec-minion focuses on spec authoring and validation, not API design decisions (which belong to api-design-minion). Spec-minion ensures specs are syntactically correct, well-structured, and enable automation workflows (SDK generation, contract testing, mock servers).

## OpenAPI 3.1 Specification

OpenAPI 3.1 is the latest version of the OpenAPI Specification (OAS), released in February 2021. It brings OpenAPI fully compatible with JSON Schema 2020-12.

### OpenAPI Document Structure

An OpenAPI document is a JSON or YAML file describing a REST API. Key sections:

**1. Info Object**: Metadata about the API.
```yaml
openapi: 3.1.0
info:
  title: E-Commerce API
  version: 1.0.0
  description: API for managing products, orders, and customers
  contact:
    name: API Support
    email: support@example.com
```

**2. Servers Object**: Base URLs for the API.
```yaml
servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://staging-api.example.com/v1
    description: Staging
```

**3. Paths Object**: API endpoints and operations.
```yaml
paths:
  /products:
    get:
      summary: List all products
      operationId: listProducts
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Product'
```

**4. Components Object**: Reusable schemas, responses, parameters, examples.
```yaml
components:
  schemas:
    Product:
      type: object
      required:
        - id
        - name
        - price
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
        price:
          type: number
          format: double
        description:
          type: string
```

**5. Security Object**: Authentication and authorization schemes.
```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - BearerAuth: []
```

### OpenAPI 3.1 vs 3.0 Key Changes

**Full JSON Schema Compatibility**: OpenAPI 3.1 schemas are now valid JSON Schema 2020-12. This enables tooling interoperability and eliminates custom extensions.

**Webhooks**: Native support for webhook definitions (callbacks initiated by the API server).

**Nullable and null Type**: Improved null handling aligned with JSON Schema. Use `type: ["string", "null"]` instead of `nullable: true`.

**Discriminator Improvements**: Better polymorphism support for oneOf, anyOf, allOf.

**License Object**: SPDX license identifiers supported (`license: { identifier: "MIT" }`).

**Removed Features**: `exclusiveMinimum` and `exclusiveMaximum` as booleans (use numeric values).

### Best Practices for OpenAPI Specs

**Real Examples Everywhere**: Provide concrete examples for every request and response. Examples clarify intent and enable mock servers.

```yaml
examples:
  ProductExample:
    value:
      id: "550e8400-e29b-41d4-a716-446655440000"
      name: "Wireless Headphones"
      price: 199.99
      description: "Premium wireless headphones with ANC"
```

**Descriptive Operation IDs**: Unique, meaningful IDs for SDK generation.
```yaml
operationId: listProducts  # SDK: client.listProducts()
```

**Tags for Organization**: Group related endpoints.
```yaml
tags:
  - name: Products
    description: Product management operations
  - name: Orders
    description: Order management operations
```

**Use $ref for Reusability**: Define schemas once, reference everywhere.
```yaml
$ref: '#/components/schemas/Product'
```

**Multi-File Specs**: Split large specs into multiple files with $ref.
```yaml
paths:
  /products:
    $ref: './paths/products.yaml'
```

**Versioning in URL or Header**: Include version in server URL (`/v1`) or via custom header.

## AsyncAPI 3.0 Specification

AsyncAPI describes event-driven and message-based APIs (Kafka, RabbitMQ, WebSockets, MQTT). It extends the OpenAPI philosophy to asynchronous communication.

### AsyncAPI Document Structure

Similar to OpenAPI but focused on channels (topics, queues) and messages instead of HTTP endpoints.

**Example (Kafka Topic)**:
```yaml
asyncapi: 3.0.0
info:
  title: Order Events API
  version: 1.0.0

channels:
  orderCreated:
    address: orders.created
    messages:
      OrderCreatedMessage:
        payload:
          type: object
          properties:
            orderId:
              type: string
            customerId:
              type: string
            total:
              type: number

operations:
  publishOrderCreated:
    action: send
    channel:
      $ref: '#/channels/orderCreated'
```

**Key Differences from OpenAPI**:
- **Channels** instead of paths (topics, queues, WebSocket routes)
- **Messages** instead of request/response pairs
- **Operations**: send, receive, publish, subscribe
- **Bindings**: Protocol-specific details (Kafka partition, RabbitMQ exchange)

**AsyncAPI 3.0 Changes**: Decoupled channels from operations, improved reusability, added request-reply pattern support.

### AsyncAPI Use Cases

**Event Streaming**: Kafka, AWS Kinesis, Azure Event Hubs

**Message Queues**: RabbitMQ, AWS SQS, Google Pub/Sub

**WebSockets**: Real-time bidirectional communication

**MQTT**: IoT device communication

**Server-Sent Events (SSE)**: Unidirectional streaming

## Spectral: API Linting and Validation

Spectral is an open-source JSON/YAML linter by Stoplight, designed for OpenAPI and AsyncAPI specifications. It enforces style guides, detects errors, and ensures spec consistency.

### Spectral Architecture

Spectral evaluates documents against rulesets. Each rule targets specific paths in the document (via JSONPath) and applies checks.

**Rule Example**:
```yaml
rules:
  operation-summary:
    description: Operations must have summaries
    severity: warn
    given: $.paths[*][*]
    then:
      field: summary
      function: truthy
```

### Built-In Rulesets

**OpenAPI Ruleset**: Validates OpenAPI 2.0, 3.0, 3.1 specs.

**AsyncAPI Ruleset**: Validates AsyncAPI 2.x, 3.x specs.

**Spectral Built-In Functions**: `truthy`, `falsy`, `pattern`, `length`, `schema`, `enumeration`, `undefined`.

### Custom Rulesets

Organizations create custom rulesets to enforce API style guides.

**Example Custom Rules**:
- Operation IDs must follow camelCase
- All endpoints must have examples
- Error responses must include `error` and `message` fields
- API paths must not exceed 4 segments

**Custom Ruleset Example**:
```yaml
extends: spectral:oas
rules:
  path-segment-limit:
    description: Paths must not exceed 4 segments
    severity: error
    given: $.paths[*]~
    then:
      function: pattern
      functionOptions:
        match: "^\\/([^\\/]+\\/){0,3}[^\\/]+$"

  require-example:
    description: All operations must have examples
    severity: warn
    given: $.paths[*][*].responses[*].content[*]
    then:
      field: examples
      function: truthy
```

### Spectral CLI and CI Integration

**Install**:
```bash
npm install -g @stoplight/spectral-cli
```

**Validate OpenAPI Spec**:
```bash
spectral lint openapi.yaml
```

**Custom Ruleset**:
```bash
spectral lint openapi.yaml --ruleset .spectral.yaml
```

**CI Integration (GitHub Actions)**:
```yaml
name: Lint API Spec
on: [pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install -g @stoplight/spectral-cli
      - run: spectral lint openapi.yaml
```

**Exit codes**: Spectral returns non-zero exit codes on errors, failing CI builds.

## Contract-First Development Workflow

Contract-first (design-first) development treats the API specification as the source of truth. The spec is written before implementation, reviewed, and used to generate mocks, SDKs, and tests.

### Contract-First Workflow Steps

**1. Design the Spec**: Write OpenAPI/AsyncAPI spec collaboratively (API designers, frontend, backend).

**2. Review and Approve**: Stakeholders review spec for correctness, completeness, clarity.

**3. Generate Mocks**: Use spec to generate mock servers for frontend development (Prism, MSW, WireMock).

**4. Implement Backend**: Backend team implements API matching the spec.

**5. Contract Testing**: Automated tests validate implementation matches spec (Pact, Dredd, Schemathesis).

**6. Generate SDKs**: Generate client SDKs from spec (openapi-generator, Speakeasy, Fern).

**7. Keep Spec in Sync**: Spec is updated for API changes; implementation follows spec.

### Benefits of Contract-First

**Parallel Development**: Frontend and backend teams work simultaneously. Frontend uses mock servers while backend is under development.

**Single Source of Truth**: Spec documents the contract. Implementation follows spec, not the other way around.

**Fewer Breaking Changes**: Spec changes are reviewed before implementation, catching breaking changes early.

**Automated Tooling**: Mocks, SDKs, tests, documentation are generated from spec, reducing manual work.

**API Governance**: Spectral enforces style guides automatically, ensuring consistency across APIs.

### Code-First vs. Contract-First

**Code-First**: Write implementation first, generate spec from code (annotations, reflection).

**Advantages**:
- Faster initial development
- Spec always matches implementation

**Disadvantages**:
- Spec is an afterthought, often incomplete or stale
- Frontend blocked until backend is implemented
- Breaking changes discovered late

**Contract-First**: Write spec first, implement to match spec.

**Advantages**:
- Parallel development
- Early detection of breaking changes
- Spec as contract, not documentation

**Disadvantages**:
- Initial overhead
- Requires discipline to keep spec and implementation in sync

**Recommendation**: Use contract-first for new APIs or APIs with multiple consumers. Use code-first for internal, single-consumer APIs where speed matters more than governance.

## SDK Generation from OpenAPI

SDKs (Software Development Kits) provide language-specific clients for consuming APIs. Generating SDKs from OpenAPI specs ensures consistency and reduces manual client code.

### Major SDK Generation Tools

**openapi-generator**:
- Open-source, community-driven
- Supports 50+ languages (Python, JavaScript, Java, Go, Ruby, C#, PHP, Swift, Kotlin)
- Highly customizable via templates (Mustache)
- Active community, extensive documentation

**Speakeasy**:
- Modern, commercial tool with free tier
- OpenAPI-native (fully compatible with OpenAPI ecosystem)
- High-quality SDKs with idiomatic code
- Automated versioning, publishing, CI/CD integration
- Documentation generation included

**Fern**:
- Opinionated, high-quality SDK generation
- Maximum control over SDK structure
- Custom API schema format (Fern Definition) or OpenAPI input
- Automated publishing to package registries (npm, PyPI, Maven)

**APIMatic**:
- Enterprise SDK generation platform
- Developer portal generation
- Multi-language support
- Automated testing and validation

### openapi-generator Configuration

**Generate Python SDK**:
```bash
openapi-generator generate \
  -i openapi.yaml \
  -g python \
  -o ./python-client \
  --additional-properties packageName=example_api_client
```

**Generate TypeScript SDK**:
```bash
openapi-generator generate \
  -i openapi.yaml \
  -g typescript-fetch \
  -o ./typescript-client
```

**Customization**: openapi-generator supports custom templates (Mustache) for fine-grained control over generated code.

### Speakeasy Workflow

Speakeasy emphasizes automation and CI/CD integration.

**Generate SDK**:
```bash
speakeasy generate sdk --schema openapi.yaml --lang typescript
```

**CI Integration**: Speakeasy GitHub Action automatically regenerates SDKs on spec changes.

**Advantages**: High-quality, idiomatic SDKs with minimal configuration. Automated versioning and publishing.

### Fern Workflow

Fern provides maximum control but requires more setup.

**Define API** (Fern format or OpenAPI):
```yaml
# api.yml (Fern format)
name: example-api
endpoints:
  listProducts:
    method: GET
    path: /products
    response: Product[]
```

**Generate SDKs**:
```bash
fern generate --language typescript
```

**Advantages**: Highly customizable, idiomatic SDK structure.

### When to Generate SDKs

**Use SDK Generation When**:
- API has multiple external consumers
- Consistency across languages is important
- You want to reduce client-side boilerplate
- API changes frequently (automation reduces maintenance)

**Skip SDK Generation When**:
- API is internal with a single consumer
- API is simple (REST with standard JSON)
- Consumers prefer direct HTTP clients (flexibility)

## Mock Server Generation

Mock servers return example responses from OpenAPI specs, enabling frontend development before backend implementation.

### Prism: OpenAPI Mock Server

Prism (Stoplight) generates mock servers from OpenAPI 2.0/3.x specs.

**Install**:
```bash
npm install -g @stoplight/prism-cli
```

**Start Mock Server**:
```bash
prism mock openapi.yaml
```

Prism starts an HTTP server on `http://localhost:4010` (default) serving endpoints from the spec.

**Dynamic Responses**: Prism generates responses based on schema definitions. If examples are provided, Prism uses them; otherwise, it generates synthetic data.

**Validation Mode**: Prism can validate requests and responses against the spec.
```bash
prism mock --validate openapi.yaml
```

**Error Simulation**: Prism can simulate error responses (4xx, 5xx) for testing error handling.

**Use Cases**:
- Frontend development before backend is ready
- Integration testing with predictable responses
- Demo environments for stakeholders

### Mock Service Worker (MSW)

MSW intercepts HTTP requests in the browser and Node.js, returning mock responses. It's more flexible than Prism but requires code-based setup (not spec-driven).

**Example**:
```javascript
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/products', (req, res, ctx) => {
    return res(ctx.json([
      { id: '1', name: 'Wireless Headphones', price: 199.99 }
    ]));
  })
);

server.listen();
```

**Use MSW When**: Fine-grained control over responses, integration with test frameworks (Jest, Vitest).

**Use Prism When**: Spec-driven mocks, no code required, quick prototyping.

## Contract Testing with OpenAPI

Contract testing validates that API implementations match their specifications. It ensures providers and consumers agree on the API contract.

### Pact: Consumer-Driven Contract Testing

Pact enables consumer-driven contract testing. Consumers define expectations (contracts), and providers verify they meet those expectations.

**Workflow**:
1. **Consumer writes Pact test**: Defines expected request/response
2. **Pact generates contract**: JSON file describing expectations
3. **Contract published to Pact Broker**: Central repository
4. **Provider verifies contract**: Runs Pact verification tests

**Pact Example (JavaScript)**:
```javascript
const { Pact } = require('@pact-foundation/pact');

const provider = new Pact({
  consumer: 'FrontendApp',
  provider: 'ProductAPI',
});

describe('Product API', () => {
  it('returns a list of products', async () => {
    await provider.addInteraction({
      state: 'products exist',
      uponReceiving: 'a request for products',
      withRequest: {
        method: 'GET',
        path: '/products',
      },
      willRespondWith: {
        status: 200,
        body: [{ id: '1', name: 'Headphones', price: 199.99 }],
      },
    });

    // Consumer code makes request
    const response = await fetch('/products');
    expect(response.status).toBe(200);
  });
});
```

**Provider Verification**:
```javascript
const { Verifier } = require('@pact-foundation/pact');

new Verifier({
  provider: 'ProductAPI',
  providerBaseUrl: 'http://localhost:3000',
  pactBrokerUrl: 'https://pact-broker.example.com',
}).verifyProvider();
```

### OpenAPI + Pact

Pact and OpenAPI serve different purposes:
- **Pact**: Consumer-driven, focuses on actual consumer needs
- **OpenAPI**: Provider-defined, describes full API capability

**Best Practice**: Use both. OpenAPI documents the contract; Pact validates that the provider meets consumer expectations.

### Schemathesis: Property-Based Testing

Schemathesis generates test cases from OpenAPI specs and validates responses match the spec.

**Install**:
```bash
pip install schemathesis
```

**Run Tests**:
```bash
schemathesis run http://api.example.com/openapi.json
```

Schemathesis generates hundreds of requests with varying parameters and validates responses match schema definitions, status codes, and headers.

**Use Case**: Catch edge cases, invalid inputs, and spec violations automatically.

## API Governance Automation

API governance ensures consistency, security, and quality across an organization's APIs. Automation enforces governance policies without manual reviews.

### Breaking Change Detection

Breaking changes (removing endpoints, changing required fields, incompatible types) can break existing clients. Automated detection prevents accidental breakage.

**opendiff (Shopify)**:
```bash
npm install -g @shopify/openapi-diff
openapi-diff old-spec.yaml new-spec.yaml
```

**Output**: Lists breaking changes (removed endpoints, required field changes) and non-breaking changes (new endpoints, optional fields).

**oasdiff**:
```bash
oasdiff breaking old-spec.yaml new-spec.yaml
```

**CI Integration**: Fail builds if breaking changes are detected without explicit approval.

### API Versioning

**Semantic Versioning for APIs**:
- **Major version (v2 → v3)**: Breaking changes
- **Minor version (v2.1 → v2.2)**: New features, backward-compatible
- **Patch version (v2.2.1 → v2.2.2)**: Bug fixes, no API changes

**Best Practice**: Maintain old versions for deprecation periods (6-12 months). Provide migration guides.

### Style Guide Enforcement

Spectral enforces organizational API style guides automatically.

**Common Style Rules**:
- All endpoints must have summaries and descriptions
- Operation IDs must follow naming conventions
- Error responses must include `code` and `message`
- Use standard HTTP status codes
- Pagination must follow cursor-based or offset-based pattern

**Enforcement Workflow**:
1. Define style guide as Spectral ruleset
2. Run Spectral in CI/CD on spec changes
3. Block merges if style violations exist

## Multi-File Spec Management

Large APIs benefit from splitting specs across multiple files. This improves maintainability and collaboration.

### $ref for External Files

OpenAPI supports `$ref` to reference external files.

**Example Directory Structure**:
```
api/
  openapi.yaml       # Main file
  paths/
    products.yaml    # /products endpoints
    orders.yaml      # /orders endpoints
  schemas/
    Product.yaml
    Order.yaml
```

**openapi.yaml**:
```yaml
openapi: 3.1.0
info:
  title: E-Commerce API
  version: 1.0.0

paths:
  /products:
    $ref: './paths/products.yaml'
  /orders:
    $ref: './paths/orders.yaml'
```

**paths/products.yaml**:
```yaml
get:
  summary: List products
  responses:
    '200':
      description: Success
      content:
        application/json:
          schema:
            type: array
            items:
              $ref: '../schemas/Product.yaml'
```

### Bundling Specs

Many tools require a single-file spec. Bundling resolves all $ref references into one file.

**Redocly CLI**:
```bash
npm install -g @redocly/cli
redocly bundle openapi.yaml -o bundled-openapi.yaml
```

**Swagger CLI**:
```bash
npm install -g swagger-cli
swagger-cli bundle openapi.yaml -o bundled-openapi.yaml
```

**When to Bundle**: CI/CD pipelines, SDK generation tools, documentation generation (some tools).

**When NOT to Bundle**: Version control (commit split files, not bundled files).

## Best Practices Summary

### Spec Authoring

- Write specs first, before implementation (contract-first)
- Provide real examples for every endpoint
- Use descriptive operation IDs for SDK generation
- Organize endpoints with tags
- Split large specs into multiple files with $ref

### Validation and Linting

- Run Spectral in CI/CD to enforce style guides
- Validate specs with OpenAPI validators
- Set severity levels (error, warn, info) for rules
- Fail builds on errors, warn on style violations

### SDK Generation

- Use openapi-generator for multi-language support
- Use Speakeasy or Fern for high-quality, idiomatic SDKs
- Automate SDK regeneration on spec changes
- Publish SDKs to package registries (npm, PyPI, Maven)

### Mock Servers

- Use Prism for spec-driven mock servers
- Provide examples in specs for realistic mock responses
- Enable validation mode to catch spec violations early
- Use mock servers for frontend development and demos

### Contract Testing

- Use Pact for consumer-driven contract testing
- Use Schemathesis for property-based spec validation
- Combine OpenAPI (provider contract) with Pact (consumer expectations)
- Run contract tests in CI/CD

### API Governance

- Detect breaking changes automatically (opendiff, oasdiff)
- Version APIs semantically (major.minor.patch)
- Enforce style guides with Spectral
- Provide deprecation periods for old versions

### Multi-File Management

- Split large specs into paths, schemas, responses
- Use $ref for reusability
- Bundle specs for tools requiring single files
- Commit split files to version control, not bundled files

## OpenAPI 3.2 Specification

OpenAPI 3.2.0 was released in September 2025, building on the JSON Schema alignment from 3.1 with significant new capabilities.

### Key New Features

**Multipurpose Tags with Nesting**: The Tag Object now includes `summary`, `parent` (for hierarchical organization), and `kind` (for classification). This enables building taxonomies with tooling support for selective inclusion/exclusion.

**HTTP Method Enhancements**:
- **QUERY method**: Safe, idempotent resource state queries using payloads (separate from POST)
- **additionalOperations**: Define non-standard HTTP methods as standard Operation Objects
- **querystring**: Define all query parameters as a Schema Object for improved control

**Streaming Data Support**: New media types supported:
- Server-Sent Events (`text/event-stream`)
- JSON Lines (`application/jsonl`)
- JSON Sequences (`application/json-seq`)
- Multipart Mixed (`multipart/mixed`)
- `itemSchema` keyword defines the structure of streamed events

**Enhanced Security Features**:
- OAuth 2.0 Device Authorization Flow (for limited-input devices like smart TVs and kiosks)
- `oauth2MetadataUrl` property for OAuth 2.0 Server Metadata auto-discovery

### Migration from 3.1 to 3.2

OpenAPI 3.2 is backward compatible with 3.1 specs. Upgrading involves changing the `openapi` field to `3.2.0` and adopting new features as needed. No breaking changes from 3.1.

### OpenAPI 4.0 (Moonwalk)

OpenAPI 4.0, codenamed "Moonwalk," is in early planning. Goals include simplifying nested structures, improving parameter-based responses, and extending support beyond REST.

## Redocly CLI: Modern OpenAPI Tooling

Redocly CLI is an all-in-one OpenAPI utility for linting, bundling, and documentation generation. It supports OpenAPI 3.2, 3.1, 3.0, 2.0, AsyncAPI 3.0/2.6, and Arazzo 1.0.

### Key Capabilities

**Linting**: Uses simple expressions that understand API specification structure (rather than raw JSONPath). Built-in rules can be mixed, matched, and customized. Supports JSON, Markdown, and Checkstyle output formats.

**Bundling**: Recombines multi-file specs into clean single documents. Output is well-formatted and looks manually crafted.

**Decorators**: Redocly-exclusive customization layer that modifies content during bundling (add code samples, remove schemas, restructure paths).

**Respect (Contract Testing)**: Sends real HTTP requests to API servers and validates responses match the OpenAPI description.

**CLI Commands**:
```bash
redocly lint openapi.yaml              # Lint spec
redocly bundle openapi.yaml -o out.yaml  # Bundle multi-file
redocly preview-docs openapi.yaml       # Preview documentation
redocly stats openapi.yaml             # Spec statistics
```

### Redocly vs Spectral

| Feature | Spectral | Redocly CLI |
|---------|----------|-------------|
| Approach | JSONPath-based rules | Structure-aware rules |
| Custom functions | JavaScript | Decorators + plugins |
| Bundling | No | Yes |
| Contract testing | No | Yes (Respect) |
| Async API | Yes (2.x, 3.x) | Yes (2.6, 3.0) |
| OpenAPI 3.2 | Partial | Full |

**Recommendation**: Use Spectral for custom organizational rulesets and CI enforcement. Use Redocly CLI for bundling, documentation previews, and when structure-aware linting simplifies rule authoring. Both can coexist in a pipeline.

## Spectral Custom Functions (Advanced)

### Writing Custom Functions

Custom functions extend Spectral beyond built-in checks. Functions are JavaScript modules stored in a `functions/` directory next to the ruleset file.

**Function Signature**:
```javascript
import { createRulesetFunction } from "@stoplight/spectral-core";

export default createRulesetFunction(
  {
    input: null,
    options: {
      type: "object",
      properties: { value: true },
      required: ["value"]
    }
  },
  (targetVal, options, context) => {
    if (targetVal !== options.value) {
      return [{ message: `Must equal ${options.value}`, path: context.path }];
    }
  }
);
```

**Context Object** provides: `path` (JSON path to current location), `document` (full document), `documentInventory` (resolved references), `rule` (current rule definition).

**Multiple Results**: Return an array of issues with distinct `path` values for precise error location reporting.

**Async Functions**: Supported for I/O operations, though deterministic functions are preferred for reproducible results.

**Custom Directory**: Use `functionsDir` in ruleset configuration to store functions in a non-default location.

### Enterprise Ruleset Patterns

Large organizations typically build layered rulesets:
1. **Base ruleset**: Extends `spectral:oas`, adds universal rules (operation IDs, descriptions, examples)
2. **Domain rulesets**: Extend base, add domain-specific rules (e.g., payment APIs require idempotency keys)
3. **Team overrides**: Turn specific rules off or change severity for exceptions

## oasdiff: Breaking Change Detection (Deep Dive)

oasdiff is the leading open-source tool for OpenAPI diff and breaking change detection, supporting 250+ checks categorized into three severity levels.

### Severity Levels

- **ERR**: Definite breaking changes that must be avoided (removed endpoints, changed required fields, incompatible type changes)
- **WARN**: Potential breaking changes that require review (changed descriptions that could affect clients, deprecation without sunset date)
- **INFO**: Non-breaking changes for awareness (new optional fields, new endpoints)

### CI/CD Integration

**GitHub Actions**:
```yaml
- uses: oasdiff/oasdiff-action/breaking@main
  with:
    base: specs/openapi-base.yaml
    revision: specs/openapi-revised.yaml
    fail-on: ERR
```

**CLI Usage**:
```bash
oasdiff breaking base.yaml revision.yaml          # Check for breaking changes
oasdiff diff base.yaml revision.yaml              # Full diff
oasdiff changelog base.yaml revision.yaml         # Human-readable changelog
oasdiff flatten openapi.yaml                      # Resolve $ref references
```

**Key Detection Capabilities**:
- Removed endpoints or methods
- Changed required fields (added required, removed optional)
- Incompatible type changes
- Changed enum values (removed values is breaking)
- Modified authentication requirements
- Changed response schemas

### oasdiff vs opendiff

| Feature | oasdiff | opendiff (Shopify) |
|---------|---------|-------------------|
| Checks | 250+ | ~50 |
| Maintained | Active | Low activity |
| CI integration | GitHub Action | Manual |
| Output formats | JSON, YAML, text | JSON |
| OpenAPI 3.1 | Yes | Partial |

**Recommendation**: oasdiff is the preferred tool for breaking change detection. More comprehensive, better maintained, and easier to integrate.

## Pact: Bi-Directional Contract Testing (BDCT)

Beyond consumer-driven testing, Pact now supports bi-directional contract testing where both providers and consumers independently create contracts.

### BDCT Workflow

1. **Consumer**: Writes Pact consumer test, generates consumer contract
2. **Provider**: Publishes OpenAPI specification as provider contract
3. **Pact Broker**: Compares consumer contracts against provider OpenAPI spec
4. **Result**: Compatibility verified without provider having to run Pact verification tests

### Benefits of BDCT

- **Provider independence**: Providers use their existing OpenAPI spec, no Pact-specific verification code needed
- **Decoupled testing**: Consumer and provider tests run independently
- **OpenAPI reuse**: Existing OpenAPI specs serve double duty as provider contracts
- **Faster adoption**: Lower barrier for provider teams already maintaining OpenAPI specs

### Pact Broker Workflow

```
Consumer Test → Consumer Contract → Pact Broker ← Provider Contract ← OpenAPI Spec
                                        ↓
                                  Compatibility Check
                                        ↓
                              can-i-deploy decision
```

**can-i-deploy**: CLI tool that checks if a particular version of a consumer/provider is compatible with its counterparts before deployment.

```bash
pact-broker can-i-deploy --pacticipant FrontendApp --version 1.2.3 --to production
```

## Arazzo Specification

Arazzo 1.0 is a new specification from the OpenAPI Initiative for describing API workflows (sequences of API calls). It complements OpenAPI by defining multi-step processes.

### Use Cases

- Onboarding workflows (create account -> verify email -> set preferences)
- Payment flows (create order -> authorize payment -> capture)
- Any multi-step API interaction that requires specific ordering

### Arazzo Structure

```yaml
arazzo: 1.0.0
info:
  title: Order Workflow
  version: 1.0.0

workflows:
  - workflowId: createOrder
    steps:
      - stepId: createCart
        operationId: createCart
        successCriteria:
          - condition: $statusCode == 201
      - stepId: addItem
        operationId: addCartItem
        parameters:
          - name: cartId
            in: path
            value: $steps.createCart.outputs.cartId
```

### Tool Support

Redocly CLI supports Arazzo 1.0 linting and validation. Spectral does not yet support Arazzo.

## Sources

- [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0)
- [OpenAPI 3.2 Announcement](https://www.openapis.org/blog/2025/09/23/announcing-openapi-v3-2)
- [OpenAPI 3.2 Specification](https://spec.openapis.org/oas/v3.2.0.html)
- [AsyncAPI 3.0 Specification](https://www.asyncapi.com/docs/reference/specification/v3.0.0)
- [Spectral Documentation](https://stoplight.io/open-source/spectral)
- [Spectral Custom Functions](https://github.com/stoplightio/spectral/blob/develop/docs/guides/5-custom-functions.md)
- [SDK Generator Comparison](https://nordicapis.com/review-of-8-sdk-generators-for-apis-in-2025/)
- [Prism Mock Server](https://stoplight.io/open-source/prism)
- [Pact Contract Testing](https://docs.pact.io/)
- [Pact Bi-Directional Contract Testing](https://docs.pactflow.io/docs/bi-directional-contract-testing/contracts/oas/)
- [Contract Testing with OpenAPI (Speakeasy)](https://www.speakeasy.com/blog/contract-testing-with-openapi)
- [oasdiff - OpenAPI Diff and Breaking Changes](https://github.com/oasdiff/oasdiff)
- [oasdiff GitHub Action](https://github.com/oasdiff/oasdiff-action)
- [Redocly CLI](https://redocly.com/redocly-cli)
- [Redocly CLI Commands](https://redocly.com/docs/cli/commands)
- [Arazzo 1.0 Specification](https://spec.openapis.org/arazzo/latest.html)
