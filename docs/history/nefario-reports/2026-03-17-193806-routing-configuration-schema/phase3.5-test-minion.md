## Verdict: ADVISE

The test plan is solid -- acceptance criteria are covered, the fixture matrix is comprehensive, and the established test-hooks.sh pattern is correctly adopted. Three concerns worth addressing:

- [testing]: Mock AGENT.md fixtures use YAML list format for `tools:` but real AGENT.md files use comma-separated strings
  SCOPE: Task 2 mock AGENT.md files and capability gating tests
  CHANGE: The Task 2 prompt should specify that mock AGENT.md `tools:` fields use the actual project format (`tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch` -- comma-separated on one line), not YAML list syntax (`- Read`). Add at least one fixture using each format if the loader is expected to handle both.
  WHY: Every real AGENT.md in the repo uses `tools: Read, Write, Edit, ...` (comma-separated string). If test mocks use list format and the loader is only tested against list format, capability gating could silently break against every real agent. This is exactly the kind of mock/reality divergence that lets bugs through.
  TASK: Task 2

- [testing]: The `--resolve AGENT_NAME` subcommand has no dedicated test coverage
  SCOPE: Task 2 test fixtures and test cases
  CHANGE: Add test cases for the `--resolve` subcommand: (1) resolve an agent with a direct `agents:` override, (2) resolve an agent whose group is in `groups:`, (3) resolve an agent with no override (falls through to default), (4) resolve with `--tier opus` vs default sonnet, (5) resolve with custom `model-mapping`. This is a primary consumer-facing interface -- it needs explicit coverage.
  WHY: The `--resolve` subcommand is how the routing dispatch will actually query the config at runtime. It exercises the resolution order logic (agent > group > default) and model mapping. Testing only the full JSON emit validates loading but not the query path that nefario will use in Phase 4 execution.
  TASK: Task 2

- [testing]: Risk #3 mitigation (group membership drift test) is mentioned in the risk section but absent from Task 2 test list
  SCOPE: Task 2 edge case tests
  CHANGE: Add a test that verifies the loader's hardcoded group-to-agent mapping is consistent with the actual AGENT.md files discovered under `--agent-dir`. This catches drift when agents are added or removed. The test should compare the set of agent directories found on disk against the union of all group members in the loader's registry.
  WHY: The risk section explicitly calls for this test ("Add a test in Task 2 that verifies group mapping against discovered AGENT.md files") but the Task 2 prompt omits it. Without it, adding a 24th minion to the roster would silently leave it out of group routing.
  TASK: Task 2
