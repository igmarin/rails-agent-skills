# Generate Api Collection Task

## Problem

A Rails team needs help with a task in this area:

Use when creating or modifying REST API endpoints — must create or update the corresponding API collection JSON file using the {{base_url}} variable, ensure each request includes a description and at least one basic test script, validate the collection JSON using python -m json.tool or jq, and verify it imports into compatible API clients without errors.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
