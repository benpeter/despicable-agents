## Verdict: ADVISE

- [documentation]: Task 3's cross-link to external-harness-integration.md will sit inside prose that contradicts the implementation.
  SCOPE: `docs/external-harness-integration.md`, "Routing and Configuration" section (final paragraph)
  CHANGE: Task 3's prompt should instruct the author to also update the closing sentence "The `.nefario/routing.yml` path is a proposed convention, not a commitment. The configuration surface will be defined as part of adapter implementation." to reflect that the config surface is now defined (link to routing-config.md). Without this, the cross-link points to the spec while surrounding text says the spec does not exist yet.
  WHY: A reader following the cross-link will encounter contradictory framing in the same paragraph -- the link says "here is the spec" while the prose says "this will be defined later." This undermines the doc's credibility.
  TASK: 3

- [documentation]: The power-user YAML example in external-harness-integration.md uses non-canonical group names (`code-writers`, `data-analysts`) that the loader would reject.
  SCOPE: `docs/external-harness-integration.md`, "Routing and Configuration" section, power-user example (lines 291-292)
  CHANGE: Either (a) add an instruction to Task 3 to update the feasibility study's example YAML to use canonical group IDs, or (b) note in the Task 3 prompt that the feasibility study examples are pre-implementation and the routing-config.md examples are authoritative. Option (a) is cleaner since the stale example will confuse anyone reading the feasibility study after the loader ships.
  WHY: After the loader ships, anyone reading the feasibility study's example and trying it will get a hard validation error. The feasibility study is linked from architecture.md and will remain a reference document.
  TASK: 3
