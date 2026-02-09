# Debugger Minion -- Research

Domain research backing the debugger-minion system prompt. Covers systematic
debugging methodologies, failure pattern taxonomies, profiling, reverse
engineering, log analysis, network debugging, post-mortem practices, and
reproducer construction.

---

## 1. Systematic Debugging Methodologies

### The Scientific Method Applied to Debugging

Debugging is the scientific method applied to software. The cycle is:

1. **Observe** -- gather symptoms (error messages, stack traces, logs, user
   reports).
2. **Hypothesize** -- form a testable explanation for the observed behavior.
3. **Predict** -- if the hypothesis is correct, what else must be true?
4. **Experiment** -- design a targeted probe (print, breakpoint, bisect, toggle)
   that distinguishes the hypothesis from alternatives.
5. **Conclude** -- accept or reject the hypothesis. Repeat.

The key discipline is *one variable at a time*. Changing multiple things between
observations destroys signal.

Sources:
- MIT 6.031 Reading 13: Debugging
  (http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)
- SciTools Blog: The Science of Debugging
  (https://blog.scitools.com/the-science-of-debugging/)
- Springer: Explainable Automated Debugging via LLM-Driven Scientific Debugging
  (https://link.springer.com/article/10.1007/s10664-024-10594-x)

### Agans' Nine Rules of Debugging

David J. Agans' *Debugging: The 9 Indispensable Rules* (2002) distills
decades of experience into nine principles:

1. **Understand the system** -- read docs, read code, know the roadmap.
2. **Make it fail** -- find a reliable reproduction path.
3. **Quit thinking and look** -- observe actual behavior, don't theorize.
4. **Divide and conquer** -- narrow the search space systematically.
5. **Change one thing at a time** -- isolate variables.
6. **Keep an audit trail** -- log what you tried and what happened.
7. **Check the plug** -- verify assumptions about the environment.
8. **Get a fresh view** -- rubber duck, ask a colleague, sleep on it.
9. **If you didn't fix it, it isn't fixed** -- verify the fix eliminates the
   root cause, not just a symptom.

Source: Agans, D.J. (2002). Debugging: The 9 Indispensable Rules.

### Binary Search / Wolf Fence

The "wolf fence" algorithm (Gauss, 1982, Communications of the ACM) applies
binary search to fault isolation. The idea: place a fence across the middle of
the problem space and determine which side the "wolf" (bug) is on. Repeat.

Applications:
- **Code-level**: place a breakpoint or assertion at the midpoint of the
  suspicious execution path; determine which half contains the defect.
- **Git history**: `git bisect` automates binary search across commits.
- **Input space**: for data-dependent bugs, bisect the input.

Source: Gauss, E.J. (1982). The "Wolf Fence" algorithm for debugging.
Communications of the ACM, 25(11).

### Automated Scientific Debugging (AutoSD)

Emerging technique (2024-2026) where LLMs generate hypotheses, invoke debuggers
programmatically, and converge on root causes. The LLM acts as the hypothesis
engine while real tooling provides the observations. 84% of developers now use
AI-assisted debugging tools (2026 survey data).

Source: WeAreBrain: 10 Debugging Techniques (2026)
(https://wearebrain.com/blog/10-effective-debugging-techniques-for-developers/)

---

## 2. Common Failure Patterns by Language / Framework

### JavaScript / Node.js

| Pattern | Typical Error | Root Cause |
|---------|--------------|------------|
| Null/undefined access | `TypeError: Cannot read properties of undefined` | Missing null check, async data not yet loaded, wrong object shape |
| Callback errors | Unhandled exception in callback | Error-first callback convention violated, missing error handler |
| Promise rejection | `UnhandledPromiseRejectionWarning` | Missing `.catch()` or `try/catch` around `await` |
| Event loop blocking | Server hangs, timeouts | Synchronous I/O, CPU-intensive computation on main thread |
| Memory leak | Heap growing monotonically | Closures capturing large scopes, forgotten event listeners, unbounded caches |
| Module resolution | `MODULE_NOT_FOUND` | Wrong path, missing dependency, hoisting issue in monorepo |
| Type coercion | Silent wrong result | `==` vs `===`, string concatenation instead of addition |

Sources:
- Node.js Errors Documentation (https://nodejs.org/api/errors.html)
- Better Stack: 16 Common Errors in Node.js
  (https://betterstack.com/community/guides/scaling-nodejs/nodejs-errors/)
- Toptal: Top 10 Common Node.js Developer Mistakes
  (https://www.toptal.com/nodejs/top-10-common-nodejs-developer-mistakes)

### React

| Pattern | Symptom | Fix Direction |
|---------|---------|---------------|
| Render before data | `Cannot read properties of null` | Optional chaining, conditional render, loading state |
| Stale closure | State value doesn't update in callback | Use ref or functional updater |
| Infinite re-render | Browser freeze, "Maximum update depth exceeded" | Dependency array issue in useEffect |
| Key prop issues | List items not updating correctly | Use stable unique keys, not array index |
| Error boundary gaps | White screen of death | Add Error Boundaries around async/dynamic content |

Source: DEV.to: 15 Common React.js Errors
(https://dev.to/shubham_joshi_expert/15-common-reactjs-errors-and-how-to-solve-them-3d6c)

### Python

| Pattern | Typical Error | Root Cause |
|---------|--------------|------------|
| `AttributeError: 'NoneType'` | Calling method on None return | Function returned None implicitly |
| `IndentationError` | Syntax error | Mixed tabs/spaces |
| `ImportError` / circular import | Module fails to load | Circular dependency chain |
| GIL contention | Threads don't speed up CPU work | Global Interpreter Lock |
| Mutable default argument | Shared state across calls | `def f(x=[])` -- default list shared |

### Java / JVM

| Pattern | Typical Error | Root Cause |
|---------|--------------|------------|
| `NullPointerException` | Uninitialized reference | Missing null guard |
| `ClassNotFoundException` | Class not on classpath | Build/deployment config error |
| `OutOfMemoryError` | Heap exhausted | Leak or undersized heap |
| `ConcurrentModificationException` | Modifying collection during iteration | Missing synchronization |
| Thread deadlock | Application hangs | Lock ordering violation |

---

## 3. Profiling Tools and Techniques

### CPU Profiling

**Node.js / V8:**
- `node --prof app.js` + `node --prof-process` -- built-in V8 sampling profiler
- Chrome DevTools CPU profiler via `--inspect` flag
- Clinic.js (clinic doctor, clinic flame, clinic bubbleprof) -- Node.js
  diagnostic suite
- `perf` on Linux for low-level sampling

**Python:**
- `cProfile` / `profile` -- built-in deterministic profilers
- `py-spy` -- sampling profiler, attaches to running process
- `scalene` -- CPU, GPU, and memory profiler

**Java:**
- `async-profiler` -- low-overhead sampling profiler
- JFR (Java Flight Recorder) -- built into JDK
- VisualVM -- heap and CPU visualization

**General principle:** Sampling profilers (low overhead, statistical) for
production; instrumentation profilers (exact counts, higher overhead) for
development.

### Memory Profiling

**Node.js:**
- Heap snapshots via Chrome DevTools or `v8.writeHeapSnapshot()`
- Compare multiple snapshots to identify objects not being GC'd
- `--max-old-space-size` to control V8 heap limit
- `process.memoryUsage()` for runtime tracking

**Python:**
- `tracemalloc` -- built-in memory allocation tracker
- `objgraph` -- visualize object reference graphs
- `memory_profiler` -- line-by-line memory usage

**Java:**
- `jmap` -- heap dumps
- Eclipse MAT (Memory Analyzer Tool) -- heap dump analysis
- JFR allocation profiling

**Pattern -- leak detection workflow:**
1. Take baseline heap snapshot
2. Exercise the suspected leaking operation
3. Force GC
4. Take second snapshot
5. Diff snapshots -- growing object types are suspects
6. Trace retainer paths to find why objects survive GC

Sources:
- Node.js Heap Profiler Guide
  (https://nodejs.org/en/learn/diagnostics/memory/using-heap-profiler)
- Better Stack: Profiling Node.js Applications
  (https://betterstack.com/community/guides/scaling-nodejs/profiling-nodejs-applications/)

---

## 4. Reverse Engineering Techniques

### When Source Is Unavailable

When debugging third-party binaries, compiled dependencies, or proprietary
protocols, reverse engineering bridges the gap.

**Static Analysis:**
- **Ghidra** (NSA, open source) -- disassembler + decompiler, supports many
  architectures, free
- **IDA Pro** (Hex-Rays) -- industry standard disassembler/decompiler,
  commercial
- **Binary Ninja** -- interactive disassembler/decompiler, modern UX
- **Radare2 / rizin** -- open source, scriptable, steep learning curve

**Dynamic Analysis:**
- **Frida** -- dynamic instrumentation toolkit, inject JS into native apps
- **strace / ltrace** (Linux) -- trace system calls and library calls
- **dtrace / dtruss** (macOS) -- dynamic tracing framework
- **Wireshark** -- network protocol analysis
- **OllyDbg / x64dbg** (Windows) -- user-mode debuggers

**Techniques:**
- Disassemble to understand control flow
- Decompile to approximate high-level source
- Hook functions with Frida to inspect arguments and return values
- Trace system calls to see file, network, and IPC activity
- Patch binaries to bypass checks or enable debug logging
- Analyze network protocols with Wireshark captures

**When to reverse engineer vs. read source:**
- Always prefer source when available (check GitHub, package registries)
- Use `npm pack` / `pip show` / `jar tf` to find bundled source
- Check if debug symbols or source maps are available
- Only resort to binary analysis when source is truly unavailable

Sources:
- Binary Ninja (https://binary.ninja/)
- LetsDefend: Top 7 Reverse Engineering Tools
  (https://letsdefend.io/blog/top-7-reverse-engineering-tools)
- macOS binary RE notes
  (https://gist.github.com/0xdevalias/256a8018473839695e8684e37da92c25)

---

## 5. Log Aggregation and Correlation Patterns

### Structured Logging

Structured logs (JSON) with consistent fields make machine parsing and
correlation possible. Essential fields for every log entry:

- `timestamp` -- ISO 8601, UTC
- `level` -- ERROR, WARN, INFO, DEBUG
- `service` -- service or application name
- `correlation_id` / `request_id` -- unique per request, propagated across
  services
- `trace_id` / `span_id` -- OpenTelemetry trace context
- `message` -- human-readable description
- `error` -- structured error object (type, message, stack)
- `context` -- additional key-value pairs relevant to the operation

### Correlation ID Strategy

1. Generate a unique ID at the entry point (API gateway, edge).
2. Propagate via headers (`X-Correlation-ID`, `traceparent` for W3C).
3. Include in every log entry across all services.
4. Use to join logs from different services for a single request.

### Log Aggregation Patterns

- **Centralized collection**: ship logs to a central store (Elasticsearch,
  Coralogix, Datadog)
- **Sidecar pattern**: log agent per pod/container forwards to aggregator
- **Structured pipeline**: source -> parser -> enricher -> store -> query

### Debugging with Logs

- **Timeline reconstruction**: sort by timestamp, filter by correlation_id
- **Error clustering**: group errors by type + message + first frame
- **Rate change detection**: compare error rates across deployments
- **Cross-service correlation**: trace a request across service boundaries
  using correlation_id and trace_id

Sources:
- Uptrace: Structured Logging Best Practices
  (https://uptrace.dev/glossary/structured-logging)
- Dash0: Practical Structured Logging
  (https://www.dash0.com/guides/structured-logging-for-modern-applications)
- OneUptime: How to Structure Logs in OpenTelemetry
  (https://oneuptime.com/blog/post/2025-08-28-how-to-structure-logs-properly-in-opentelemetry/view)

---

## 6. Post-Mortem Analysis

### Blameless Post-Mortem Template

Structure (derived from Google SRE practices):

```
# Incident Post-Mortem: [Title]

## Summary
- **Date/time**: [start] -- [resolved]
- **Duration**: [total]
- **Severity**: [SEV-1/2/3/4]
- **Impact**: [what users experienced, how many affected]

## Timeline
| Time (UTC) | Event |
|-----------|-------|
| HH:MM | First symptom observed |
| HH:MM | Alert fired / escalation |
| HH:MM | Root cause identified |
| HH:MM | Fix deployed |
| HH:MM | Confirmed resolved |

## Root Cause
[What actually broke and why. Go deep -- what was the proximate cause
and what was the underlying systemic cause?]

## Contributing Factors
- [Factor 1: e.g., missing test coverage for edge case]
- [Factor 2: e.g., monitoring gap -- no alert for this failure mode]

## Detection
- How was the incident detected? (Alert / user report / manual check)
- How long between onset and detection?
- What monitoring/alerting worked? What didn't?

## Resolution
- What fixed the immediate problem?
- Was it a permanent fix or a temporary workaround?

## Lessons Learned
### What went well
- [Good things about the response]
### What went poorly
- [Things that could improve]

## Action Items
| Action | Owner | Due | Status |
|--------|-------|-----|--------|
| [Action 1] | [person] | [date] | open |
| [Action 2] | [person] | [date] | open |
```

### Key Principles

- **Blameless**: focus on systemic causes, not individuals. People make mistakes
  because systems allow mistakes.
- **Thorough**: the point is learning, not speed. A rushed post-mortem produces
  no value.
- **Actionable**: every post-mortem must produce action items with owners and
  deadlines.
- **Shared**: publish internally. Trends across post-mortems reveal systemic
  weaknesses.

Sources:
- Google SRE Book: Postmortem Culture
  (https://sre.google/sre-book/postmortem-culture/)
- Google SRE Workbook: Postmortem Practices
  (https://sre.google/workbook/postmortem-culture/)
- Atlassian: Incident Postmortem Templates
  (https://www.atlassian.com/incident-management/postmortem/templates)

---

## 7. Git Bisect and Change-Based Debugging

### git bisect Workflow

```bash
git bisect start
git bisect bad              # current commit is broken
git bisect good <sha>       # this older commit was working
# Git checks out a midpoint commit
# Test it, then:
git bisect good             # or
git bisect bad
# Repeat until Git identifies the first bad commit
git bisect reset            # return to original HEAD
```

### Automated bisect

```bash
git bisect start HEAD <good-sha>
git bisect run ./test-script.sh
# Exit code 0 = good, non-zero = bad
# git bisect skip (exit 125) for untestable commits
```

### Best Practices

- **Small, atomic commits** make bisect far more useful -- each commit should
  be a logical unit.
- **Every commit should build and pass tests** -- otherwise bisect hits
  untestable commits and needs `skip`.
- **Write the test first**: before bisecting, write a test that reliably
  demonstrates the failure. This becomes the `run` script.
- **Check merge commits**: bugs introduced in feature branches surface as the
  merge commit during bisect. Use `git log --first-parent` to understand.

### Beyond git bisect

- **git log -S "string"** (pickaxe): find commits that added or removed a
  specific string.
- **git log -G "regex"**: find commits where a regex matches in the diff.
- **git blame**: trace each line to its introducing commit.
- **git log --all -- path/to/file**: full history of a specific file.
- **git diff <before>..<after> -- path**: compare specific changes.

Sources:
- Git Documentation: git-bisect
  (https://git-scm.com/docs/git-bisect)
- Graphite: Debugging with git bisect
  (https://graphite.com/guides/git-bisect-debugging-guide)
- Binary search debugging
  (https://vladimirzdrazil.com/posts/binary-search-debugging/)

---

## 8. Stack Trace Analysis Techniques

### Reading Stack Traces

1. **Start from the error type and message** -- this tells you *what* happened.
2. **Find the top frame** -- the most recent call, usually where the error was
   *thrown* (not necessarily where the bug *is*).
3. **Scan down for your code** -- skip framework and library frames. The
   transition from library code to your code is usually where the interesting
   logic is.
4. **Identify the chain of calls** -- how did execution reach the failure point?
5. **Check for "Caused by"** -- chained exceptions (Java) or `.cause` (Node.js)
   reveal the original error wrapped by higher-level handling.

### Async Stack Traces

- Node.js: `--async-stack-traces` flag (default since Node 12) provides
  cross-async-boundary traces.
- Browser: "Async" checkbox in Chrome DevTools preserves async call chains.
- Python: `traceback` module with `__cause__` chains for exception chaining.

### Common Stack Trace Patterns

- **Recursive call** -- same function appears many times -> stack overflow.
- **Null dereference at property access** -- look one frame up for where the
  null value originated.
- **Serialization error** -- usually means an unexpected type crossed a
  boundary (API response, message queue).
- **Timeout / connection refused** -- look for the network call setup, check
  host/port/DNS configuration.

### Enriching Stack Traces

- Source maps for minified JavaScript (`.map` files).
- Debug symbols for compiled languages.
- Error tracking services (Sentry, Bugsnag) auto-symbolicate and group.

Sources:
- Samebug: Stack Trace 101 (https://samebug.io/stack-trace-101/)
- Samebug: Debugging Complex Bugs Using Stack Trace
  (https://samebug.io/debugging-complex-bugs/)

---

## 9. Reproducer Construction

### Why Minimal Reproduction Matters

A minimal reproducible example (MRE) isolates the bug from all noise. Benefits:
- Confirms the bug is real (not environmental).
- Often reveals the root cause during construction.
- Enables others to verify and help.
- Becomes the regression test.

### Construction Process

1. **Start from the failing system** -- confirm the bug exists.
2. **Remove components one at a time** -- if removing something doesn't affect
   the bug, it's noise. Keep removing.
3. **Simplify data** -- replace production data with minimal synthetic data.
4. **Isolate environment** -- can you reproduce outside the full stack?
   In a REPL? In a standalone script?
5. **Alternatively, build up** -- start from scratch in a clean environment
   and add the minimum code needed to trigger the bug.

### MRE Checklist

- [ ] Self-contained (no dependencies on production systems)
- [ ] Minimal (nothing can be removed without losing the bug)
- [ ] Reproducible (fails consistently, not intermittently)
- [ ] Documented (clear steps, expected vs actual behavior)

### Dealing with Non-Reproducible Bugs

- **Heisenbug** (disappears when observed): often timing-dependent. Add
  logging without changing timing. Use record-replay tools.
- **Mandelbug** (complex cause): increase observability, widen the hypothesis
  space.
- **Intermittent failures**: run in a loop, capture state on failure, look for
  environmental factors (time, load, race conditions).

Sources:
- Gatsby: How to Make a Reproducible Test Case
  (https://www.gatsbyjs.com/contributing/how-to-make-a-reproducible-test-case/)
- Wikipedia: Minimal reproducible example
  (https://en.wikipedia.org/wiki/Minimal_reproducible_example)
- scikit-learn: Crafting a minimal reproducer
  (https://scikit-learn.org/stable/developers/minimal_reproducer.html)

---

## 10. Network Debugging

### Request/Response Inspection

- **curl -v**: verbose mode shows request headers, TLS handshake, response
  headers.
- **curl --trace-ascii -**: full byte-level trace.
- **httpie**: human-friendly HTTP client with colored output.
- **Browser DevTools Network tab**: timing waterfall, request/response headers
  and body, WebSocket frames.
- **mitmproxy**: intercept and modify HTTPS traffic for debugging.

### DNS Debugging

- `dig <domain>` -- query DNS records, see full resolution chain.
- `dig +trace <domain>` -- trace from root servers down.
- `nslookup <domain>` -- simpler lookup.
- `host <domain>` -- compact lookup.
- Common issues: stale DNS cache, wrong resolver, TTL not expired,
  CNAME chains, split-horizon DNS.

### TLS / Certificate Debugging

- `openssl s_client -connect host:443` -- show TLS handshake, certificate
  chain, cipher negotiation.
- `openssl x509 -in cert.pem -text -noout` -- inspect certificate details
  (SAN, expiry, issuer).
- Wireshark with TLS dissector -- inspect handshake at packet level.
- `curl --cert-status` -- check OCSP stapling.
- Common issues: expired certificates, wrong SAN/CN, self-signed certs not
  in trust store, intermediate CA missing from chain, TLS version mismatch,
  cipher suite negotiation failure.

### Connection and Performance

- `netstat -an` / `ss -tuln` -- listen sockets, established connections.
- `tcpdump` -- raw packet capture.
- `traceroute` / `mtr` -- network path analysis.
- `nc -zv host port` -- quick port check.
- Common issues: firewall rules, NAT traversal, MTU issues, connection
  pooling exhaustion, keep-alive misconfiguration.

Sources:
- SSL/TLS Debugging: maulwuff.de
  (https://maulwuff.de/research/ssl-debugging.html)
- TLS Troubleshooting 101 (https://hynek.me/til/tls-troubleshooting/)
- Wireshark TLS debugging
  (https://lukasa.co.uk/2016/01/Debugging_With_Wireshark_TLS/)

---

## 11. Upstream Source Code Analysis

When a bug appears to be in a dependency:

1. **Check issue trackers** -- search the library's GitHub issues for the error
   message or symptom.
2. **Read the source** -- `node_modules/<pkg>/`, `pip show <pkg>` for location,
   or clone the repo. Read the specific function in the stack trace.
3. **Check recent changes** -- was the dependency recently upgraded? Compare
   changelogs. Use `git log` on the vendored code.
4. **Reproduce in isolation** -- write a standalone test against the library
   alone, removing your application logic.
5. **Patch locally** -- if the fix is clear, apply a local patch
   (`patch-package` for npm, editable install for pip) while waiting for an
   upstream release.

---

## 12. Debugging Taxonomy (UkrPROG 2025)

A taxonomy from the SEST workshop classifies debugging along six dimensions:

- **What** -- objects of debugging (code, config, data, state)
- **Which** -- tools employed (debuggers, profilers, tracers, log analyzers)
- **How** -- methods applied (scientific method, bisection, trace analysis)
- **Who** -- human factors (expertise level, cognitive load, pair debugging)
- **When** -- temporal aspects (development, testing, production, post-mortem)
- **Where** -- environment (local, CI, staging, production)

Source: CEUR-WS Vol-4053 (https://ceur-ws.org/Vol-4053/paper3.pdf)
