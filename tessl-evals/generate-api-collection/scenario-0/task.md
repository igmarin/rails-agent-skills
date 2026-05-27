# Generate Api Collection Task

## Problem

A Rails team needs help with a task in this area:

Sync API collections with REST endpoints — when creating or modifying any REST API endpoint you MUST also create or update the corresponding Postman Collection v2.1 JSON file: one collection per app or engine in `docs/api-collections/` or `spec/fixtures/api-collections/`, use `{{base_url}}` variable, each request MUST include a description and at least one test script (e.g.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
