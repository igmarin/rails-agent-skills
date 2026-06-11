# Rails Agent Skills

![Rails Agent Skills Logo](https://github.com/user-attachments/assets/d5f7b2e0-c651-41f2-a75f-df21349c883d)

It is a curated library of **public Rails agent skills** and **callable personas** that teach AI tools how to test, implement, document, and review Rails work using production-minded conventions. This repository acts as a pure **Domain Knowledge Registry** and asset catalog of specialized Rails & Ruby AI Skills/Personas, consumable by external MCP or CLI runtimes.

The project is built around one non-negotiable rule:

```text
Write test -> run test -> verify it fails for the right reason -> implement -> verify it passes
```

That TDD gate is encoded directly into the skills and personas, so agents do not just produce plausible Rails code. They follow a repeatable engineering process.

## Part of the AI Skill Ecosystem

This repo is one of 6 in a composable AI skill ecosystem:

| Repo | Role |
|------|------|
| [`ruby-core-skills`](https://github.com/igmarin/ruby-core-skills) | 15 shared Ruby skills + process discipline |
| [**`rails-agent-skills`**](https://github.com/igmarin/rails-agent-skills) | 28 atomic skills + 9 personas |
| [`hanakai-yaku`](https://github.com/igmarin/hanakai-yaku) | 35 atomic skills + 10 personas |
| [`agnostic-planning-skills`](https://github.com/igmarin/agnostic-planning-skills) | 10 atomic skills + 4 personas |
| [`agent-mcp-runtime`](https://github.com/igmarin/agent-mcp-runtime) | Rust CLI runtime (pack resolution, MCP) |
| [`ruby-skill-bench`](https://github.com/igmarin/ruby-skill-bench) | Benchmark/eval engine |

See the [Ecosystem Overview](https://github.com/igmarin/agent-mcp-runtime/blob/main/docs/ecosystem.md) for the full architecture.

*This repo depends on `ruby-core-skills`. See [Migration Guide](https://github.com/igmarin/agent-mcp-runtime/blob/main/docs/migration-guide.md).*

> Supported agent environments
>
> [![ChatGPT](https://custom-icon-badges.demolab.com/badge/ChatGPT-74aa9c?logo=openai&logoColor=white)](#)
> [![Claude](https://img.shields.io/badge/Claude-D97757?logo=claude&logoColor=fff)](#)
> [![Cursor](https://img.shields.io/badge/Cursor-000000?logo=cursor)](#)
> [![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-000?logo=githubcopilot&logoColor=fff)](#)
> [![Google Gemini](https://img.shields.io/badge/Google%20Gemini-886FBF?logo=googlegemini&logoColor=fff)](#)
> [![Mistral AI](https://img.shields.io/badge/Mistral%20AI-FA520F?logo=mistral-ai&logoColor=fff)](#)
> [![OpenCode](https://img.shields.io/badge/OpenCode-4285F4?style=for-the-badge&logoColor=white)](#)
> [![Qwen](https://custom-icon-badges.demolab.com/badge/Qwen-605CEC?logo=qwen&logoColor=fff)](#)
> [![Windsurf](https://img.shields.io/badge/Windsurf-0B100F?logo=windsurf&logoColor=fff)](#)

> Official distribution
>
> [![GitHub tag](https://img.shields.io/github/v/tag/igmarin/rails-agent-skills?label=release)](https://github.com/igmarin/rails-agent-skills/tags)
> [![tessl](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.tessl.io%2Fv1%2Fbadges%2Figmarin%2Frails-agent-skills)](https://tessl.io/registry/igmarin/rails-agent-skills)
> [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
> [![skills.sh](https://skills.sh/b/igmarin/rails-agent-skills)](https://skills.sh/igmarin/rails-agent-skills)
> [![Smithery](https://img.shields.io/badge/Smithery-orange)](https://smithery.ai/skills/ismael-marin/rails-agent-skills)

## What are Agent Skills?

Agent Skills are a lightweight, open format for extending AI agent capabilities with specialized knowledge and workflows. At its core, a skill is a folder containing a `SKILL.md` file. This file includes metadata (`name` and `description`, at minimum) and instructions that tell an agent how to perform a specific task.

This repository follows the Agent Skills standard, meaning you can install the entire catalog of Rails skills atomically into any compatible agent (e.g., Cursor, Claude Code, Goose, OpenCode, Gemini CLI) using:

```bash
npx skills add igmarin/rails-agent-skills
```

 > **Note:** You may see a harmless warning at the end of the install:
> `✗ rails-agent-skills → PromptScript: PromptScript does not support global skill installation`
> This is a known bug in the skills.sh CLI where the PromptScript agent is incorrectly included in
> the global install target list despite not supporting it. All 37 skills install successfully to
> every other supported agent — the warning can be safely ignored.

## Who This Is For

| Reader | What you get |
|--------|--------------|
| Rails developers | Agent instructions for common Rails work: tests, services, APIs, GraphQL, migrations, jobs, Hotwire, engines, security, and review. |
| Team leads | A repeatable workflow that makes AI-assisted work easier to review because tests, docs, and self-review are part of the process. |
| Junior developers | Step-by-step Rails workflow guidance that explains what to do next instead of dumping generic code. |
| Senior developers | Opinionated guardrails for TDD, architecture, review, DDD, engines, performance, and production-safe changes. |
| Recruiters and evaluators | A concrete example of AI tooling designed around engineering discipline, validation, and distribution. |

## What Is In The Repository

| Area | Purpose |
|------|---------|
| `skills/` | 28 public atomic skills for Rails-specific development. Each skill has a `SKILL.md` entry point with task-specific instructions. |
| `skills/personas/` | 9 callable personas that chain skills into full development loops (tdd, quality, review, setup, engine, bug-fix, graphql, migration, background-job). |
| `docs/` | Public documentation, architecture, persona guides, skill catalog, and evaluation policy. |
| `evals/` | Tessl-native eval scenarios for publishable skills in `directory.json`. |
| `personal-evals/` | Open examples for the upcoming `ruby-skill-bench` full-context evaluator. |

**Core Dependency:** This repository depends on `igmarin/ruby-core-skills` for 15 foundational Ruby skills (DDD, Ruby patterns, process skills, code quality, orchestration). Install both repositories for the complete skill set.

The skills are not long-form tutorials. They are executable instructions for AI agents: when to gather context, when to stop for a checkpoint, how to write the first failing test, what Rails conventions to apply, and how to review the result.

## Daily Workflow

Depending on your environment, you can orchestrate your daily Rails work using these common loops. For explicit control in Cursor or Windsurf, prepend these with `@` (e.g., `@load-context`). 

**The core TDD feature loop:**
```text
load-context
  -> plan-tests
  -> write-tests
  -> [verify failing test]
  -> [implement]
  -> [verify passing test]
  -> write-yard-docs
  -> code-review
```

**For a bug:**
```text
bug-fix (triage -> reproduce test -> fix -> verify)
```

**For a GraphQL API:**
```text
graphql (domain modeling -> schema design -> TDD -> security review)
```

**For a database migration:**
```text
migration (plan -> test -> staging -> production deployment)
```

**For a background job:**
```text
background-job (design -> TDD -> retry config -> monitoring)
```

**For a Rails engine:**
```text
create-engine -> test-engine -> document-engine -> review-engine -> release-engine
```

See [docs/persona-guide.md](docs/persona-guide.md) and [docs/personas/](docs/personas/) for the full process guide containing detailed Mermaid diagrams of each phase.

## Skill Catalog

The library contains **28 public Rails-specific skills** organized by development concern, plus **15 core Ruby skills** available from the dependency `igmarin/ruby-core-skills`.

| Category | Local Skills | Core Skills (from ruby-core-skills) |
|----------|-------------|-----------------------------------|
| Testing | `plan-tests`, `write-tests`, `test-service` | `triage-bug`, `test-planning-process`, `tdd-process` |
| Code Quality | `code-review`, `security-check`, `review-architecture`, `apply-code-conventions`, `apply-stack-conventions`, `implement-authorization`, `refactor-code` | `respond-to-review`, `review-process`, `security-review-process`, `refactor-process` |
| DDD | — | `define-domain-language`, `review-domain-boundaries`, `model-domain` |
| Engines | `create-engine`, `test-engine`, `document-engine`, `review-engine`, `release-engine`, `create-engine-installer`, `extract-engine`, `upgrade-engine` | — |
| Infrastructure | `review-migration`, `implement-background-job`, `seed-database`, `optimize-performance`, `version-api`, `implement-hotwire` | — |
| API | `generate-api-collection`, `implement-graphql` | `integrate-api-client` |
| Context | `load-context`, `setup-environment` | — |
| Patterns | — | `create-service-object`, `implement-calculator-pattern` |
| Orchestration | — | `skill-router` |
| Documentation | — | `write-yard-docs` |


Use [docs/reference/skill-catalog.md](docs/reference/skill-catalog.md) for the complete catalog and [docs/reference/integration-matrix.md](docs/reference/integration-matrix.md) for skill chaining.

## Quality And Evaluation

This repo uses two complementary evaluation layers.

| Layer | Status | What it validates |
|-------|--------|-------------------|
| Tessl | Public and active | Tessl-native scenarios in `evals/` validate the quality of publishable skills from `directory.json`. Tessl does not validate repository personas today. |
| `ruby-skill-bench` | Coming soon | The upcoming Ruby gem will run `personal-evals/` examples with full skill or agent context, including `SKILL.md` plus companion resources bundled as XML. |

`evals/` is the tracked Tessl eval source for publishable skills. `personal-evals/` is the tracked source for open custom-evaluator examples.

See [docs/eval-provenance.md](docs/eval-provenance.md) for the canonical eval ownership policy and [docs/skill-optimization-guide.md](docs/skill-optimization-guide.md) for the baseline-vs-context optimization loop.

## Install Selected Skills With GitHub CLI

Requires [GitHub CLI](https://cli.github.com/) v2.90.0+ with `gh skill`.

```bash
# Install the core dependency first for complete functionality
gh skill install igmarin/ruby-core-skills

# Install all skills interactively
gh skill install igmarin/rails-agent-skills

# Install a specific skill for the current project
gh skill install igmarin/rails-agent-skills code-review --scope project

# Install a specific skill globally
gh skill install igmarin/rails-agent-skills code-review --scope user

# Install pinned to a release tag
gh skill install igmarin/rails-agent-skills code-review --pin v6.0.0 --scope user

# Search this repository's skills
gh skill search rails --owner igmarin
```

To target a specific agent host:

```bash
gh skill install igmarin/rails-agent-skills plan-tests --agent claude-code --scope user
gh skill install igmarin/rails-agent-skills plan-tests --agent cursor --scope user
gh skill install igmarin/rails-agent-skills plan-tests --agent codex --scope user
gh skill install igmarin/rails-agent-skills plan-tests --agent gemini-cli --scope user
gh skill install igmarin/rails-agent-skills plan-tests --agent windsurf --scope user
```

Update installed skills:

```bash
gh skill update --dry-run
gh skill update --all
gh skill update --force --all
gh skill update --unpin
```

Pinning to a tag or commit SHA gives you reproducible installs. Provenance metadata is written into each installed `SKILL.md` frontmatter.

## Documentation Map

| Need | Document |
|------|----------|
| Understand the docs system | [docs/README.md](docs/README.md) |
| Browse all skills | [docs/reference/skill-catalog.md](docs/reference/skill-catalog.md) |
| Understand skill chaining | [docs/reference/integration-matrix.md](docs/reference/integration-matrix.md) |
| Follow persona guides | [docs/persona-guide.md](docs/persona-guide.md) |
| Understand repository structure | [docs/architecture.md](docs/architecture.md) |
| Understand eval ownership | [docs/eval-provenance.md](docs/eval-provenance.md) |
| Optimize skill eval quality | [docs/skill-optimization-guide.md](docs/skill-optimization-guide.md) |

## Contributing

When contributing skills, personas, or docs:

- Keep generated artifacts in English unless a user explicitly asks for another language.
- Preserve the tests-gate-implementation rule for every code-producing skill.
- Do not add tickets unless the user asks for ticket generation.
- Keep public docs consistent with `directory.json` and the latest release tag.

## Acknowledgments

Huge thanks to [Mumo Carlos (@mumoc)](https://github.com/mumoc). His mentorship shaped many of the habits reflected here, especially the discipline around quality, clarity, and thoughtful use of tools.
