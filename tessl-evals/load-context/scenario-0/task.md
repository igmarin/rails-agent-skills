# Load Context Task

## Problem

A Rails team needs help with a task in this area:

Use before writing code, tests, or PRDs in an existing Rails project — must load baseline context by reading db/schema.rb, config/routes.rb, or using the get_project_context tool, and load one neighbor of each kind for each layer touched (such as a controller, service, or spec) by running a grep command to find and inspect sibling implementations.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
