# Setup Environment Task

## Problem

A Rails team needs help with a task in this area:

Emit a generic Rails development-environment setup runbook for the user to execute locally — agent reads .ruby-version, Gemfile, docker-compose.yml, .env.example and flags mismatches but NEVER executes commands or reads filled-in .env or echoes secrets; covers Docker, environment variables, database, test suite, linters, and IDE in Steps 1–7 plus Final Verification.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
