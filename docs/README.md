# Rails Agent Skills Documentation

This documentation is the public map for the Rails Agent Skills library: 41 public Rails skills, 9 callable agents, an MCP distribution, and the evaluation process used to keep the skills useful.

For the high-level project value proposition, start with the [root README](../README.md).

## Quick Start Decision Map

| If you are... | Use this |
|---------------|----------|
| New to the project | `load-context` and [Discovery & Context](agents/discovery.md) |
| Ready to build a feature | [Development Guide](agents/development.md) |
| Reviewing code | [Review Guide](agents/review.md) |
| Not sure where to start | `skill-router` |
| Installing the library | [Implementation guide](implementation-guide.md) |
| Validating skill quality | [Eval provenance](eval-provenance.md) and [Skill optimization](skill-optimization-guide.md) |

## Architecture: Skills vs. Agents

The repository uses a hybrid model to keep agent context focused:

1. **Skills** are atomic expert instructions such as `code-review`, `plan-tests`, or `create-service-object`. Agents load them on demand through an installed skill host.
2. **Agents** are orchestrated multi-step processes that chain multiple skills together into a complete development loop, such as TDD feature work, code review, setup, quality checks, or engine development.

## Master Stage Index

| Stage | Guide | Description | Primary skills |
|-------|-------|-------------|----------------|
| Discovery | [Discovery & Context](agents/discovery.md) | Understand codebase and onboarding context | `load-context`, `setup-environment` |
| Planning | [Planning & Design](agents/planning.md) | PRDs, tasks, and domain language | `create-prd`, `generate-tasks`, `define-domain-language` |
| Setup | [Setup & Configuration](agents/setup.md) | CI/CD and infrastructure references | `setup-environment` |
| Development | [Development](agents/development.md) | TDD and implementation | `plan-tests`, `write-tests`, `triage-bug` |
| Quality | [Code Quality](agents/quality.md) | Conventions, refactoring, and docs | `apply-code-conventions`, `refactor-code`, `write-yard-docs` |
| Review | [Review & Validation](agents/review.md) | Review, security, and architecture | `code-review`, `security-check`, `review-architecture` |
| Engines | [Engine Development](agents/engines.md) | Building and releasing Rails engines | `create-engine`, `release-engine` |

## Core Principles

### Tests Gate Implementation

Implementation code waits until a test exists, has run, and fails for the expected reason. This is the central quality rule across code-producing skills.

### Skill and Agent Chaining

Skills are building blocks. Agents define the sequence. Follow `skill-router` or the [integration matrix](reference/integration-matrix.md) when the next step is unclear.

### Evaluation Ownership

Tessl validates publishable skills from `tile.json` using `tessl-evals/`. The upcoming `ruby-skill-bench` gem will use `personal-evals/` for full-context skill and agent validation. Root `evals/` is generated Tessl staging output and should not be committed.

## Reference & Authoring

- [Skill Catalog](reference/skill-catalog.md) - Complete list of 41 public skills and 9 callable agents.
- [Calling Skills Guide](calling-skills.md) - Syntax and execution contexts (MCP, CLI, Chat).
- [Integration Matrix](reference/integration-matrix.md) - How skills connect.
- [Agent Guide](agent-guide.md) - Narrative guide for daily use.
- [Implementation Guide](implementation-guide.md) - Installation setup overview.
- [Architecture](architecture.md) - Repository layout and `SKILL.md` conventions.
- [Eval Provenance](eval-provenance.md) - Canonical eval ownership policy.
- [Skill Template](skill-template.md) - Template for creating new skills.
