# OAuth Minion Research

Research compiled 2026-02-09 for oauth-minion agent specification.

## OAuth 2.0/2.1 Core Concepts

### OAuth 2.1 Evolution

OAuth 2.1 is an updated OAuth 2.0 profile that mandates secure flows, removes risky grants, and hardens token usage. Key changes from OAuth 2.0:

- **PKCE is mandatory** for all authorization code flows (not just public clients)
- **Implicit and Resource Owner Password Credentials (ROPC) grants removed** as insecure
- **Exact redirect URI matching required** (no wildcards)
- **Refresh token rotation required** (each use issues new token, invalidates old)
- **Sender-constrained tokens** to prevent token theft/replay

Source: [OAuth 2.1 Features You Can't Ignore in 2026](https://rgutierrez2004.medium.com/oauth-2-1-features-you-cant-ignore-in-2026-a15f852cb723)

### Authorization Code Flow with PKCE

PKCE (Proof Key for Code Exchange) protects against authorization code interception attacks:

1. Client generates `code_verifier` (cryptographically random string, 43-128 chars)
2. Client creates `code_challenge = BASE64URL(SHA256(code_verifier))`
3. Authorization request includes `code_challenge` and `code_challenge_method=S256`
4. Token request includes original `code_verifier`
5. Server validates `SHA256(code_verifier) == code_challenge`

This ensures the client that requests an access token is the same client that requested the authorization code.

**Best practices:**
- Use S256 (SHA-256) method, not plain
- code_verifier must be 43-128 characters (A-Z, a-z, 0-9, -, ., _, ~)
- Never reuse code_verifier across requests
- PKCE required even for confidential clients in OAuth 2.1

Sources: [Auth0 PKCE Guide](https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-pkce), [Descope PKCE Overview](https://www.descope.com/learn/post/pkce), [Microsoft PKCE Documentation](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)

### PKCE Downgrade Attacks

As of 2026, PKCE downgrade attacks are a significant threat. Attacker intercepts authorization request and strips PKCE parameters. If server accepts non-PKCE requests, attack succeeds.

**Mitigation:** Server must reject authorization code flow requests without PKCE parameters. OAuth 2.1 compliance eliminates this attack vector.

Source: [PKCE Downgrade Attacks: Why OAuth 2.1 is No Longer Optional](https://medium.com/@instatunnel/pkce-downgrade-attacks-why-oauth-2-1-is-no-longer-optional-887731326f24)

## OAuth 2.0 Grant Types

### Authorization Code Flow (RFC 6749 Section 4.1)

Most secure flow for user-facing applications. Used when user delegates access to third-party application.

**Flow:**
1. Client redirects user to authorization server with `client_id`, `redirect_uri`, `scope`, `state`, `code_challenge`
2. User authenticates and consents
3. Authorization server redirects to `redirect_uri` with `code` and `state`
4. Client exchanges `code` + `code_verifier` for access token at token endpoint
5. Server returns `access_token`, `refresh_token` (if requested), `expires_in`, `token_type`

**Key parameters:**
- `response_type=code` (authorization request)
- `grant_type=authorization_code` (token request)
- `state` (CSRF protection, must be cryptographically random and bound to session)
- `scope` (space-delimited list of permissions)

Source: [RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)

### Client Credentials Flow (RFC 6749 Section 4.4)

Machine-to-machine authentication without user context. Client authenticates with its own credentials.

**Flow:**
1. Client POSTs to token endpoint with `grant_type=client_credentials`, `scope`
2. Client authenticates via `Authorization: Basic` header (client_id:client_secret) or JWT bearer assertion
3. Server returns `access_token`, `expires_in`, `token_type`

**Best practices:**
- Only for confidential clients (can securely store client_secret)
- No refresh tokens (client can request new access token anytime)
- Scope should be limited to client's own resources or pre-arranged resource access

Source: [OAuth 2.0 Client Credentials Grant Type](https://oauth.net/2/grant-types/client-credentials/)

### Device Authorization Grant (RFC 8628)

For devices with limited input capability (smart TVs, CLI tools, IoT devices).

**Flow:**
1. Device requests device code from device authorization endpoint
2. Server returns `device_code`, `user_code`, `verification_uri`, `verification_uri_complete`, `expires_in`, `interval`
3. Device displays user code and verification URI to user
4. User navigates to verification URI on separate device, enters user code, authenticates
5. Device polls token endpoint with `device_code` at specified interval
6. Server returns `authorization_pending` until user completes flow, then returns access token

**Best practices:**
- Respect polling interval to avoid rate limiting
- Handle `slow_down` error by increasing interval
- Support `verification_uri_complete` (QR code) for better UX
- Expire device codes after reasonable timeout (typically 10-15 minutes)

Sources: [RFC 8628](https://datatracker.ietf.org/doc/html/rfc8628), [Descope Device Flow Guide](https://www.descope.com/learn/post/device-authorization-flow)

## Token Management

### Token Types

**Access Token:**
- Short-lived credential (typically 15 minutes to 1 hour)
- Can be opaque (random string) or self-contained (JWT)
- Must be validated on every API request
- Transmitted via `Authorization: Bearer <token>` header

**Refresh Token:**
- Long-lived credential (days to months)
- Used to obtain new access tokens without user interaction
- Must be stored securely (encrypted at rest)
- OAuth 2.1 requires rotation on each use

**ID Token (OIDC):**
- JWT containing user identity claims
- Not used for API authorization (that's access token's job)
- Validated by client, not resource server

### Token Introspection (RFC 7662)

Allows resource server to query authorization server about token validity and metadata.

**Introspection Request:**
```http
POST /introspect HTTP/1.1
Host: server.example.com
Authorization: Bearer <introspection_secret>
Content-Type: application/x-www-form-urlencoded

token=<token_to_inspect>&token_type_hint=access_token
```

**Introspection Response:**
```json
{
  "active": true,
  "scope": "read write",
  "client_id": "client123",
  "username": "user@example.com",
  "token_type": "Bearer",
  "exp": 1234567890,
  "iat": 1234564290,
  "sub": "user123"
}
```

**Best practices:**
- Introspection endpoint MUST require authentication (prevent token enumeration)
- Resource server should cache introspection responses (balance liveness vs. performance)
- Authorization server MAY return different scopes to different resource servers (privacy)
- Always use HTTPS
- Invalid/expired tokens return `{"active": false}` (don't leak reason)

Sources: [RFC 7662](https://datatracker.ietf.org/doc/html/rfc7662), [Scalekit Token Introspection Guide](https://www.scalekit.com/blog/oauth-2-0-token-introspection-rfc-7662)

### Token Revocation (RFC 7009)

Allows client to notify authorization server that a token is no longer needed.

**Revocation Request:**
```http
POST /revoke HTTP/1.1
Host: server.example.com
Content-Type: application/x-www-form-urlencoded
Authorization: Basic <client_credentials>

token=<token_to_revoke>&token_type_hint=refresh_token
```

**Best practices:**
- Endpoint MUST use HTTPS
- Revocation of refresh token SHOULD revoke associated access tokens
- Server responds with HTTP 200 for both valid and invalid tokens (prevent token enumeration)
- Clients MUST discard tokens after revocation
- Support both access token and refresh token revocation

Source: [RFC 7009](https://datatracker.ietf.org/doc/html/rfc7009)

### Refresh Token Rotation (OAuth 2.1 Requirement)

Each refresh token use issues new refresh token and invalidates old one.

**Flow:**
1. Client sends refresh token to token endpoint
2. Server validates refresh token
3. Server issues new access token AND new refresh token
4. Server marks old refresh token as used/invalid
5. If old refresh token used again, server detects replay attack and revokes entire grant

**Detection mechanism:**
- Server stores `previous_refresh_token_hash` with each refresh token
- If used token != current token but == previous token, it's a replay
- Revoke all tokens in grant family to mitigate compromise

**Benefits:**
- Limits damage from stolen refresh token
- Detects token theft via replay detection
- Forces periodic re-authentication for long-lived sessions

Source: [OAuth 2.1 Features You Can't Ignore in 2026](https://rgutierrez2004.medium.com/oauth-2-1-features-you-cant-ignore-in-2026-a15f852cb723)

## Dynamic Client Registration (RFC 7591)

Allows clients to register with authorization server at runtime instead of manual pre-registration.

**Registration Request:**
```http
POST /register HTTP/1.1
Host: server.example.com
Content-Type: application/json
Authorization: Bearer <initial_access_token>

{
  "redirect_uris": ["https://client.example.org/callback"],
  "token_endpoint_auth_method": "client_secret_basic",
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "client_name": "Example Client",
  "client_uri": "https://client.example.org",
  "logo_uri": "https://client.example.org/logo.png",
  "scope": "read write",
  "contacts": ["admin@client.example.org"],
  "jwks_uri": "https://client.example.org/jwks.json"
}
```

**Registration Response:**
```json
{
  "client_id": "s6BhdRkqt3",
  "client_secret": "ZJYCqe3GGRvdrudKyZS0XhGv_Z45DuKhCUk0gBR1vZk",
  "client_secret_expires_at": 1234567890,
  "registration_access_token": "reg.access.token",
  "registration_client_uri": "https://server.example.com/register/s6BhdRkqt3",
  "redirect_uris": ["https://client.example.org/callback"],
  "grant_types": ["authorization_code", "refresh_token"],
  "token_endpoint_auth_method": "client_secret_basic"
}
```

**Key concepts:**
- **Initial Access Token:** Bearer token required for registration (prevents open registration)
- **Software Statement:** JWT asserting metadata about client (signed by trusted authority)
- **Registration Access Token:** Allows client to update/delete its registration via PUT/DELETE to `registration_client_uri`

**Best practices:**
- Validate all redirect URIs (exact match, no wildcards)
- Limit scope to reasonable defaults
- Expire client_secret if not used within reasonable time
- Rate limit registration endpoint
- Audit registration events

Sources: [RFC 7591](https://datatracker.ietf.org/doc/html/rfc7591), [Curity DCR Overview](https://curity.io/resources/learn/openid-connect-understanding-dcr/)

## Protected Resource Metadata (RFC 9728)

Defines metadata format for OAuth 2.0 protected resources (APIs) to describe their capabilities.

**Metadata Discovery:**
Resource metadata available at `https://<resource>/.well-known/oauth-protected-resource`

**Example Metadata:**
```json
{
  "resource": "https://api.example.com",
  "authorization_servers": [
    "https://auth.example.com",
    "https://auth-backup.example.com"
  ],
  "bearer_methods_supported": ["header", "body", "query"],
  "resource_signing_alg_values_supported": ["RS256", "ES256"],
  "resource_documentation": "https://api.example.com/docs",
  "resource_policy_uri": "https://example.com/policy",
  "scopes_supported": ["read", "write", "admin"]
}
```

**Key metadata parameters:**
- `resource`: Resource identifier
- `authorization_servers`: Array of issuer identifiers for compatible auth servers
- `bearer_methods_supported`: How bearer tokens are accepted (header, body, query)
- `scopes_supported`: Available scopes for this resource

**MCP Integration:**
MCP clients (claude.ai, Claude Code) use RFC 9728 to discover OAuth server for a protected MCP endpoint. MCP server returns `/.well-known/oauth-protected-resource`, client fetches auth server metadata from `/.well-known/oauth-authorization-server`, then initiates OAuth flow.

Sources: [RFC 9728](https://datatracker.ietf.org/doc/html/rfc9728), [WorkOS RFC 9728 Introduction](https://workos.com/blog/introducing-rfc-9728-say-hello-to-standardized-oauth-2-0-resource-metadata), [MCP Authorization Spec](https://modelcontextprotocol.io/specification/draft/basic/authorization)

## Authorization Server Metadata (RFC 8414)

Defines metadata format for OAuth 2.0 authorization servers to describe their endpoints and capabilities.

**Metadata Discovery:**
Authorization server metadata available at `https://<issuer>/.well-known/oauth-authorization-server`

**Example Metadata:**
```json
{
  "issuer": "https://auth.example.com",
  "authorization_endpoint": "https://auth.example.com/authorize",
  "token_endpoint": "https://auth.example.com/token",
  "token_endpoint_auth_methods_supported": ["client_secret_basic", "private_key_jwt"],
  "token_endpoint_auth_signing_alg_values_supported": ["RS256", "ES256"],
  "userinfo_endpoint": "https://auth.example.com/userinfo",
  "jwks_uri": "https://auth.example.com/.well-known/jwks.json",
  "registration_endpoint": "https://auth.example.com/register",
  "scopes_supported": ["openid", "profile", "email"],
  "response_types_supported": ["code", "token"],
  "grant_types_supported": ["authorization_code", "client_credentials", "refresh_token"],
  "code_challenge_methods_supported": ["S256"],
  "revocation_endpoint": "https://auth.example.com/revoke",
  "introspection_endpoint": "https://auth.example.com/introspect",
  "device_authorization_endpoint": "https://auth.example.com/device"
}
```

**Required metadata:**
- `issuer` (HTTPS URL, no query/fragment)
- `authorization_endpoint` (unless no grant types use it)
- `token_endpoint` (unless only implicit grant)
- `jwks_uri` (for signature verification)
- `response_types_supported`
- `grant_types_supported` (if omitted, only authorization_code is supported)

**Best practices:**
- Clients MUST validate `issuer` matches expected value (prevents metadata spoofing)
- Cache metadata responses (rarely changes, reduces latency)
- Check `code_challenge_methods_supported` for S256 support

Sources: [RFC 8414](https://datatracker.ietf.org/doc/html/rfc8414), [OAuth.net Authorization Server Metadata](https://oauth.net/2/authorization-server-metadata/)

## MCP-Specific OAuth Patterns

### Claude Code vs. claude.ai Differences

**Claude Code CLI:**
- Uses stdio transport for local MCP servers (no OAuth)
- Uses HTTP transport for remote MCP servers (OAuth supported)
- **Known bug (as of January 2026):** Doesn't send `scope` parameter during OAuth flow, causing failures with scope-validating servers
- Workaround: Use claude.ai or Claude Desktop until bug fixed

**claude.ai (web) and Claude Desktop:**
- Only support HTTP transport (all MCP servers are remote)
- Require Dynamic Client Registration (RFC 7591) support
- Known issue: Some spec-compliant OAuth servers fail to connect (infinite about:blank loop)
- Root cause unclear, may be CORS or redirect URI validation issue

**MCP OAuth Requirements (claude.ai):**
1. Protected Resource Metadata endpoint (`/.well-known/oauth-protected-resource`)
2. Authorization Server Metadata endpoint (`/.well-known/oauth-authorization-server`)
3. Dynamic Client Registration endpoint
4. PKCE support (S256 method)
5. Authorization Code flow
6. Token endpoint with refresh token rotation

Sources: [Claude Code MCP Docs](https://code.claude.com/docs/en/mcp), [MCP OAuth Bug Report](https://github.com/anthropics/claude-code/issues/11814), [Build with Matija MCP OAuth Guide](https://www.buildwithmatija.com/blog/oauth-mcp-server-claude)

### MCP Auth Chain

Full authentication flow for claude.ai connecting to OAuth-protected MCP server:

1. **Discovery Phase:**
   - Client requests MCP endpoint (e.g., POST `/mcp`)
   - Server returns 401 with WWW-Authenticate header
   - Client requests `/.well-known/oauth-protected-resource`
   - Server returns `{"authorization_servers": ["https://auth.example.com"]}`
   - Client requests `https://auth.example.com/.well-known/oauth-authorization-server`
   - Server returns authorization server metadata

2. **Registration Phase (claude.ai only):**
   - Client requests Dynamic Client Registration endpoint
   - Server issues client_id and client_secret
   - Client stores credentials

3. **Authorization Phase:**
   - Client generates PKCE code_verifier and code_challenge
   - Client redirects user to authorization_endpoint with code_challenge
   - User authenticates and consents
   - Authorization server redirects to client with authorization code

4. **Token Phase:**
   - Client exchanges code + code_verifier for access token
   - Server validates PKCE and issues access token + refresh token

5. **MCP Request Phase:**
   - Client sends MCP request with `Authorization: Bearer <access_token>`
   - MCP server validates token (introspection or JWT verification)
   - MCP server processes request and returns response

Sources: [MCP Authorization Spec](https://modelcontextprotocol.io/specification/draft/basic/authorization), [MCP OAuth with Auth0](https://medium.com/neural-engineer/mcp-server-setup-with-oauth-authentication-using-auth0-and-claude-ai-remote-mcp-integration-8329b65e6664)

## Cloudflare Workers OAuth Patterns

### @cloudflare/workers-oauth-provider

Official Cloudflare library implementing OAuth 2.1 provider on Workers.

**Key features:**
- Authorization Code flow with PKCE
- Client Credentials flow
- Refresh token rotation
- Token introspection endpoint
- Dynamic Client Registration
- Token storage in KV namespace

**Example token format:**
`userId:grantId:tokenValue` stored in KV as `token:${userId}:${grantId}:${sha256(tokenValue)}`

**Security patterns observed in production:**
- `__Host-` cookie prefix (Secure + no Domain + Path=/)
- HMAC-SHA256 signed session cookies
- One-time CSRF tokens
- OAuth state bound to session via SHA-256 hash
- Introspection endpoint protected by bearer token

Source: [Cloudflare workers-oauth-provider](https://github.com/cloudflare/workers-oauth-provider)

### OAuth Proxy Pattern

Cloudflare Worker as OAuth proxy between client and upstream API.

**Architecture:**
```
Client -> Cloudflare Worker (OAuth) -> Upstream API
          |
          +-- KV (tokens, sessions)
          +-- OAuth Provider (GitHub, Auth0)
```

**Worker responsibilities:**
- Accept OAuth callback and exchange code for token
- Store tokens in encrypted cookies or KV
- Proxy API requests with token in Authorization header
- Refresh tokens when expired
- Revoke tokens on logout

**Benefits:**
- Keeps tokens out of client (browser) storage
- Centralized token management
- CORS handling
- Rate limiting and caching at edge

Sources: [Curity Cloudflare OAuth Proxy](https://github.com/curityio/cloudflare-oauth-proxy-worker), [Stytch MCP OAuth + Workers](https://stytch.com/blog/building-an-mcp-server-oauth-cloudflare-workers/)

### PKCE Bypass Vulnerability (GHSA-qgp8-v765-qxx9)

**Vulnerability:** workers-oauth-provider allowed PKCE downgrade attack (client could omit code_challenge).

**Fix:** Reject authorization requests without PKCE parameters in OAuth 2.1 mode.

**Lesson:** Always validate PKCE presence, even for confidential clients.

Source: [workers-oauth-provider Security Advisory](https://github.com/cloudflare/workers-oauth-provider/security/advisories/GHSA-qgp8-v765-qxx9)

## Common OAuth Debugging Patterns

### Authorization Request Failures

**Invalid redirect_uri:**
- Symptom: "redirect_uri_mismatch" error
- Cause: redirect_uri not registered or doesn't match exactly (case-sensitive, query params matter)
- Fix: Ensure exact match, no wildcards

**Missing or invalid state:**
- Symptom: CSRF validation failure
- Cause: state parameter not sent, not cryptographically random, or not bound to session
- Fix: Generate random state, store in session, validate on callback

**Scope not requested:**
- Symptom: Missing permissions in access token
- Cause: offline or offline_access scope not requested for refresh token
- Fix: Include scope in authorization request

**PKCE validation failure:**
- Symptom: "invalid_grant" error at token endpoint
- Cause: code_verifier doesn't match code_challenge, or code_challenge_method mismatch
- Fix: Use same code_verifier in token request as used to generate code_challenge in auth request

### Token Exchange Failures

**Invalid client credentials:**
- Symptom: "invalid_client" error
- Cause: Wrong client_id/client_secret, or incorrect authentication method
- Fix: Verify credentials, check token_endpoint_auth_methods_supported

**Expired authorization code:**
- Symptom: "invalid_grant" error
- Cause: Authorization code used after expiration (typically 10 minutes)
- Fix: Exchange code immediately after receiving it

**Authorization code replay:**
- Symptom: "invalid_grant" error
- Cause: Authorization code used more than once
- Fix: Store used codes, reject replays

**Wrong Content-Type:**
- Symptom: 400 Bad Request
- Cause: Sending JSON body instead of application/x-www-form-urlencoded
- Fix: Use form-encoded body for token requests

### Runtime Failures

**Token validation failures:**
- Symptom: 401 Unauthorized from API
- Cause: Expired token, invalid signature, wrong audience
- Fix: Check exp claim, verify signature against JWKS, validate aud claim

**Scope insufficient:**
- Symptom: 403 Forbidden
- Cause: Token doesn't have required scope
- Fix: Request correct scope in authorization request

**Refresh token expired:**
- Symptom: "invalid_grant" error when refreshing
- Cause: Refresh token expired or revoked
- Fix: Re-authenticate user (refresh token can't be refreshed)

Sources: [Microsoft OAuth Troubleshooting](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow), [Ory Hydra Debug Guide](https://www.ory.com/docs/hydra/debug), [Markaicode OAuth Debugging Guide](https://markaicode.com/debugging-oauth-authentication-flows-complete-guide/)

## Security Best Practices

### CSRF Protection

**State parameter:**
- Must be cryptographically random (32+ bytes)
- Must be bound to user session (stored server-side or in signed cookie)
- Must be single-use (prevent replay)
- Validated on callback before accepting authorization code

**Example implementation:**
```typescript
// Authorization request
const state = crypto.randomBytes(32).toString('base64url');
await session.set('oauth_state', state);
redirect(`${authzEndpoint}?state=${state}&...`);

// Callback handler
const receivedState = req.query.state;
const storedState = await session.get('oauth_state');
if (receivedState !== storedState) throw new Error('CSRF');
await session.delete('oauth_state'); // Single-use
```

### Redirect URI Validation

**Server-side validation:**
- Exact string match (case-sensitive)
- No wildcards or pattern matching
- Query parameters must match exactly
- Protocol must be https (except localhost for development)

**Client-side best practices:**
- Use /callback path (not root)
- Avoid open redirects after callback
- Validate state before processing code

### Token Storage

**Access tokens:**
- Browser: Memory only (never localStorage/sessionStorage)
- Server: Encrypted database or cache
- Mobile: Keychain/Keystore

**Refresh tokens:**
- Browser: HTTP-only, Secure, SameSite=Strict cookie
- Server: Encrypted database
- Mobile: Keychain/Keystore with biometric protection

**Never log tokens:**
- Scrub tokens from error messages
- Scrub tokens from debug logs
- Scrub tokens from analytics

### Rate Limiting

**Token endpoint:**
- 10 requests/minute per IP
- 5 failed attempts per client_id = temp ban

**Authorization endpoint:**
- 20 requests/minute per IP
- Track by session cookie to prevent session fixation

**Introspection endpoint:**
- 100 requests/minute per client
- Cache responses at resource server

## Related RFCs and Standards

### Core OAuth Specifications

- **RFC 6749:** OAuth 2.0 Authorization Framework (core specification)
- **RFC 6750:** OAuth 2.0 Bearer Token Usage
- **RFC 7009:** OAuth 2.0 Token Revocation
- **RFC 7591:** OAuth 2.0 Dynamic Client Registration
- **RFC 7592:** OAuth 2.0 Dynamic Client Registration Management
- **RFC 7662:** OAuth 2.0 Token Introspection
- **RFC 8414:** OAuth 2.0 Authorization Server Metadata
- **RFC 8628:** OAuth 2.0 Device Authorization Grant
- **RFC 9126:** OAuth 2.0 Pushed Authorization Requests (PAR)
- **RFC 9207:** OAuth 2.0 Authorization Server Issuer Identification
- **RFC 9728:** OAuth 2.0 Protected Resource Metadata

### Security Best Practices

- **RFC 6819:** OAuth 2.0 Threat Model and Security Considerations
- **RFC 8252:** OAuth 2.0 for Native Apps
- **RFC 8725:** JSON Web Token Best Current Practices

### Token Formats

- **RFC 7519:** JSON Web Token (JWT)
- **RFC 7515:** JSON Web Signature (JWS)
- **RFC 7516:** JSON Web Encryption (JWE)

## Failure Modes and Mitigation

### Clock Skew

**Problem:** Token validation fails due to timestamp mismatch between client and server.

**Symptoms:**
- exp claim validation fails for valid token
- iat claim appears to be in future

**Mitigation:**
- Allow 60-120 second clock skew tolerance
- Use NTP on servers
- Log clock skew incidents for monitoring

### Token Leakage

**Attack vectors:**
- Browser history (tokens in URL fragments)
- Referer headers (tokens in URL query params)
- Log files (tokens in error messages)
- Browser localStorage (XSS vulnerability)

**Mitigation:**
- Never put tokens in URL query params
- Use HTTP-only cookies for refresh tokens
- Scrub tokens from logs
- Use SameSite cookie attribute
- Implement Content Security Policy

### Authorization Code Interception

**Attack:** Attacker intercepts authorization code during redirect.

**Mitigation:**
- PKCE prevents code interception (attacker doesn't have code_verifier)
- Short code expiration (10 minutes max)
- Bind code to client_id (validate at token endpoint)
- One-time use enforcement

### Refresh Token Theft

**Attack:** Attacker steals long-lived refresh token.

**Mitigation:**
- Refresh token rotation (OAuth 2.1 requirement)
- Replay detection (if old refresh token used, revoke entire grant)
- Sender-constrained tokens (bind token to client certificate)
- Token revocation endpoint
- Monitor for suspicious refresh patterns (geo, device, frequency)

### Open Redirect

**Attack:** Malicious redirect_uri captures authorization code.

**Mitigation:**
- Exact redirect_uri matching (no wildcards)
- Whitelist approach (pre-register all URIs)
- Reject redirects to different origins
- No path traversal (e.g., ../../evil.com)

## Implementation Patterns from Production

### Token Format (from obsidian-cloud-mcp)

**Structure:** `userId:grantId:tokenValue`

**Storage:** KV key = `token:${userId}:${grantId}:${sha256(tokenValue)}`

**Benefits:**
- Token introspection without database lookup (parse token, hash, lookup KV)
- Grant-level revocation (delete all tokens with same grantId)
- User-level revocation (delete all tokens with same userId)

### Cookie Security (from obsidian-cloud-mcp)

**Pattern:**
```
Set-Cookie: __Host-session=<value>; Secure; HttpOnly; SameSite=Strict; Path=/
```

**__Host- prefix requirements:**
- Must have Secure flag
- Must NOT have Domain attribute (bound to exact host)
- Must have Path=/

**HMAC signature:**
```typescript
const signature = hmac('sha256', cookieSecret, cookieValue);
const signedCookie = `${cookieValue}.${signature}`;
```

### State Validation (from obsidian-cloud-mcp)

**Binding state to session:**
```typescript
// Create state
const state = randomBytes(32).toString('base64url');
const stateHash = sha256(state);
await session.set('oauth_state_hash', stateHash);

// Validate state
const receivedState = req.query.state;
const expectedHash = await session.get('oauth_state_hash');
if (sha256(receivedState) !== expectedHash) throw new Error('Invalid state');
```

**Benefits:**
- State not stored in plaintext (even in session)
- Timing-safe comparison (hash comparison)
- Session-bound validation

### Introspection Response Caching

**Cache key:** `introspection:${sha256(token)}`

**TTL:** MIN(token.exp - now, 5 minutes)

**Invalidation:** On token revocation

**Benefits:**
- Reduces introspection endpoint load
- Lower latency for repeat requests
- Minimal staleness risk (short TTL)
