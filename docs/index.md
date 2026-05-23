# Rails Agent Skills Documentation Index

Master index for the Rails Agent Skills library. Start here to navigate the public documentation for the 38 skills, 9 callable agents, and evaluation policy.

## Quick Start

- [Root README](../README.md) - Project value, audience, install paths, and documentation map.
- [Implementation Guide](implementation-guide.md) - Installation overview.
- [Calling Skills Guide](calling-skills.md) - Syntax and execution contexts (CLI, Chat).
- [Agent Guide](agent-guide.md) — How to chain skills in real Rails work.
- [Skill Catalog](reference/skill-catalog.md) - Complete list of 38 public skills and 9 callable agents.

## Agent Stages & Guides

- [Discovery & Context](agents/discovery.md)
- [Agent Guides Index](agents/README.md)

- [Development (TDD)](agents/development.md)
- [Code Quality & Refactoring](agents/quality.md)
- [Review & Security](agents/review.md)
- [Engine Development](agents/engines.md)
- [Setup & CI/CD](agents/setup.md)

## Architecture & Principles

- [Skill Design Principles](skill-design-principles.md) - Why skills are structured this way.
- [Architecture](architecture.md) - Repository layout and `SKILL.md` conventions.
- [Skill Structure](skill-structure.md) - Canonical skill file shape.
- [Skill Optimization](skill-optimization-guide.md) - Baseline-vs-context evaluation loop.
- [Eval Provenance](eval-provenance.md) - Ownership rules for `tessl-evals/`, `personal-evals/`, and generated `evals/`.
- [Skill Template](skill-template.md) - Template for contributing new skills.

## Platform Setup

- [Implementation Guide](implementation-guide.md)
- [VS Code Setup](vs-code-setup.md)
- [Plugin Validation](plugin-validation.md)
