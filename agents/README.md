# Agents

This directory contains callable **Rails Agent Skills**. Unlike atomic skills, agents are high-level orchestrators that chain multiple skills together to complete a complex development phase.

## Available Agents

| Agent | Description |
|-------|-------------|
| **[tdd](tdd/)** | Full TDD feature cycle: plan tests → write failing test → implement → review. |
| **[review](review/)** | Systematic PR review: code review → deep dive (security/architecture) → response. |
| **[quality](quality/)** | Pre-PR quality check: conventions → refactoring → documentation. |
| **[engine](engine/)** | End-to-end Rails engine development: scaffold → test → document → release. |
| **[setup](setup/)** | Project onboarding and CI/CD configuration. |
| **[bug-fix](bug-fix/)** | Systematic bug resolution: triage → reproduce → fix → verify. |
| **[graphql](graphql/)** | GraphQL API development with DDD: model → schema → TDD → security. |
| **[migration](migration/)** | Safe database migration: plan → test → deploy with monitoring. |
| **[background-job](background-job/)** | Background job: design → TDD → retry → monitor. |

## How to use

Agents are exposed as **MCP Tools**. Use `list_agents` to discover them, then `use_agent` to load the full `SKILL.md`. Agents orchestrate skills from `skills/` to complete a development task.

For detailed process guides (development stages, TDD flow, etc.), see **[docs/agents/](../docs/agents/README.md)**.
