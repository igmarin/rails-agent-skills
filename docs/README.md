# Rails Agent Skills Documentation

This documentation is the public map for the Rails Agent Skills library: 41 public Rails skills, 9 callable agents, an MCP distribution, and the evaluation process used to keep the skills useful.

For the high-level project value proposition, start with the [root README](../README.md). For installation and runtime setup, use the [MCP server README](../mcp_server/README.md).

## Quick Start Decision Map

| If you are... | Use this |
|---------------|----------|
| New to the project | `load-context` and [Discovery & Context](workflows/discovery.md) |
| Ready to build a feature | [Development workflow](workflows/development.md) |
| Reviewing code | [Review workflow](workflows/review.md) |
| Not sure where to start | `skill-router` |
| Installing the library | [Implementation guide](implementation-guide.md) |
| Validating skill quality | [Eval provenance](eval-provenance.md) and [Skill optimization](skill-optimization-guide.md) |

## Architecture: Skills vs. Workflows

The repository uses a hybrid model to keep agent context focused:

1. **Skills** are atomic expert instructions such as `code-review`, `plan-tests`, or `create-service-object`. Agents load them on demand through the MCP `use_skill` tool or through an installed skill host.
2. **Workflows** are higher-level chains that combine multiple skills into a complete development loop, such as TDD feature work, code review, setup, quality checks, or engine development.

## Master Workflow Index

| Stage | Guide | Description | Primary skills |
|-------|-------|-------------|----------------|
| Discovery | [Discovery & Context](workflows/discovery.md) | Understand codebase and onboarding context | `load-context`, `setup-environment` |
| Planning | [Planning & Design](workflows/planning.md) | PRDs, tasks, and domain language | `create-prd`, `generate-tasks`, `define-domain-language` |
| Setup | [Setup & Configuration](workflows/setup.md) | CI/CD and infrastructure references | `setup-environment` |
| Development | [Development](workflows/development.md) | TDD and implementation | `plan-tests`, `write-tests`, `triage-bug` |
| Quality | [Code Quality](workflows/quality.md) | Conventions, refactoring, and docs | `apply-code-conventions`, `refactor-code`, `write-yard-docs` |
| Review | [Review & Validation](workflows/review.md) | Review, security, and architecture | `code-review`, `security-check`, `review-architecture` |
| Engines | [Engine Development](workflows/engines.md) | Building and releasing Rails engines | `create-engine`, `release-engine` |

## Core Principles

### Tests Gate Implementation

Implementation code waits until a test exists, has run, and fails for the expected reason. This is the central quality rule across code-producing skills.

### Workflow Chaining

Skills are building blocks. Workflows define the sequence. Follow `skill-router` or the [integration matrix](reference/integration-matrix.md) when the next step is unclear.

### Evaluation Ownership

Tessl validates publishable skills from `tile.json` using `tessl-evals/`. The upcoming `ruby-skill-bench` gem will use `personal-evals/` for full-context skill and workflow validation. Root `evals/` is generated Tessl staging output and should not be committed.

## Reference & Authoring

- [Skill Catalog](reference/skill-catalog.md) - Complete list of 41 public skills and 9 callable agents.
- [Calling Skills Guide](calling-skills.md) - Syntax and execution contexts (MCP, CLI, Chat).
- [Integration Matrix](reference/integration-matrix.md) - How skills connect.
- [Workflow Guide](workflow-guide.md) - Narrative guide for daily use.
- [Implementation Guide](implementation-guide.md) - IDE and MCP setup overview.
- [Architecture](architecture.md) - Repository layout and `SKILL.md` conventions.
- [Eval Provenance](eval-provenance.md) - Canonical eval ownership policy.
- [Skill Template](skill-template.md) - Template for creating new skills.
