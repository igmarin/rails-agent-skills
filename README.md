# Rails Agent Skills

![Rails Agent Skills Logo](https://github.com/user-attachments/assets/55e84f62-52ab-44a5-8b0f-9fe1bdb12212)

**Rails Agent Skills turns AI coding assistants into disciplined Rails collaborators.**

It is a curated library of **41 public Rails agent skills** and **9 callable agents** that teach AI tools how to plan, test, implement, document, and review Rails work using production-minded conventions.

The project is built around one non-negotiable rule:

```text
Write test -> run test -> verify it fails for the right reason -> implement -> verify it passes
```

That TDD gate is encoded directly into the skills and agents, so agents do not just produce plausible Rails code. They follow a repeatable engineering process.

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
> [![Official MCP Registry](https://img.shields.io/badge/MCP%20Registry-Official-1f6feb)](https://registry.modelcontextprotocol.io/?q=io.github.igmarin%2Frails-agent-skills-mcp)
> [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-igmarin%2Frails--agent--skills--mcp-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/igmarin/rails-agent-skills-mcp)
> [![Cloudflare Worker](https://img.shields.io/badge/Cloudflare%20Worker-Streamable%20HTTP-F38020?logo=cloudflare&logoColor=white)](https://rails-agent-skills-mcp.ismael-marin.workers.dev/health)
> [![skills.sh](https://img.shields.io/badge/skills.sh-igmarin-black)](https://www.skills.sh/igmarin/rails-agent-skills)
> [![Glama](https://img.shields.io/badge/Glama-Connect-000?logo=glama&logoColor=fff)](https://glama.ai/mcp/connectors/dev.workers.ismael-marin.rails-agent-skills-mcp/ruby-on-rails-mcp-skills)
> [![GitHub tag](https://img.shields.io/github/v/tag/igmarin/rails-agent-skills?label=release)](https://github.com/igmarin/rails-agent-skills/tags)
> [![tessl](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.tessl.io%2Fv1%2Fbadges%2Figmarin%2Frails-agent-skills)](https://tessl.io/registry/igmarin/rails-agent-skills)
> [![smithery badge](https://smithery.ai/badge/ismael-marin/rails-agent-skills)](https://smithery.ai/servers/ismael-marin/rails-agent-skills)
> [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

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
| `skills/` | 41 public atomic skills. Each skill has a `SKILL.md` entry point with task-specific instructions. |
| `agents/` | 9 callable agents that chain skills into full development loops (tdd, quality, review, setup, engine, bug-fix, graphql, migration, background-job). |
| `docs/` | Public documentation, architecture, agent guides, skill catalog, and evaluation policy. |
| `mcp_server/` | Official Ruby MCP server exposing docs, agents, and skills via `list_skills`, `use_skill`, `list_agents`, `use_agent`. |
| `tessl-evals/` | Tessl-native eval scenarios for publishable skills in `tile.json`. |
| `personal-evals/` | Open examples for the upcoming `ruby-skill-bench` full-context evaluator. |

The skills are not long-form tutorials. They are executable instructions for AI agents: when to gather context, when to stop for a checkpoint, how to write the first failing test, what Rails conventions to apply, and how to review the result.

## Start Here

Rails Agent Skills can be invoked in three distinct ways depending on your environment and desired level of autonomy:
1. **MCP (`use_skill`)**: Autonomous tool calls by the agent (e.g., Claude Desktop, Cursor).
2. **Chat Commands**: Explicitly forcing the agent to use a skill via `@skill-name` or `/skill-name`.
3. **CLI (`gh skill` / `tessl`)**: Manual installation or evaluations in the terminal.

**[Read the complete guide on Calling Skills and Agents](docs/calling-skills.md)** for syntax examples and when to use each method.

The recommended way for autonomous usage is through the MCP server. MCP keeps the agent context small: docs are exposed as resources, available skills are discoverable through `list_skills`, agents through `list_agents`, and individual files are loaded on demand via `use_skill` / `use_agent`.

| Path | Best for | Start here |
|------|----------|------------|
| Official MCP Registry | Finding the verified MCP server metadata and latest published version | [MCP registry entry](https://registry.modelcontextprotocol.io/?q=io.github.igmarin%2Frails-agent-skills-mcp) |
| Docker Hub image | Running without a local Ruby toolchain | [Docker image](https://hub.docker.com/r/igmarin/rails-agent-skills-mcp) |
| Cloudflare Worker | Hosted Streamable HTTP MCP for registries and hosted clients | [health check](https://rails-agent-skills-mcp.ismael-marin.workers.dev/health) |
| Smithery | Discovering and connecting through Smithery's MCP gateway | [Smithery listing](https://smithery.ai/servers/ismael-marin/rails-agent-skills) |
| Local Ruby/Bundler | Local development, debugging, and repository checkout workflows | [mcp_server/README.md](mcp_server/README.md) |
| GitHub CLI skills | Installing selected skills into a specific agent host | [GitHub CLI install](#install-selected-skills-with-github-cli) |
| skills.sh | Registering and adding the entire library to your workspace | [skills.sh install](#install-with-skillssh) |

### MCP Quick Start

For hosted MCP clients and registries that support Streamable HTTP, use the Cloudflare Worker endpoint:

```text
https://rails-agent-skills-mcp.ismael-marin.workers.dev/mcp
```

Useful public checks:

```text
Health: https://rails-agent-skills-mcp.ismael-marin.workers.dev/health
Server card: https://rails-agent-skills-mcp.ismael-marin.workers.dev/.well-known/mcp/server-card.json
```

For repeatable team installs, prefer the versioned Docker image published from a Git release tag:

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "docker",
      "args": ["run", "--rm", "-i", "igmarin/rails-agent-skills-mcp:5.1.5"]
    }
  }
}
```

For local development, clone the repo and run the Ruby server:

```bash
git clone https://github.com/igmarin/rails-agent-skills.git ~/rails-agent-skills
cd ~/rails-agent-skills/mcp_server
bundle install
bundle exec ruby server.rb
```

See [mcp_server/README.md](mcp_server/README.md) for host-specific MCP configuration for Claude Code, Cursor, Windsurf, RubyMine, OpenCode, and other stdio MCP clients.

When configuring MCP in external tools, use absolute paths for `cwd` and `BUNDLE_GEMFILE`. Relative paths and `~` are a common cause of gem-loading and timeout failures.

### Using Agents via MCP

Agents are the primary way to orchestrate multi-step Rails development tasks. When connected via MCP, agents can automatically discover and execute them using two tools:

**1. Discover available agents:**

```text
Agent calls: list_agents
Returns: 9 agents with metadata (tdd, quality, review, setup, engine, bug-fix, graphql, migration, background-job)
```

**2. Load and execute a specific agent:**

```text
Agent calls: use_agent(agent_name: "tdd")
Returns: Full agent instructions with phases, gates, and skill chaining
```

**Example usage in MCP:**
- User: "I need to implement a new feature with TDD"
- Agent: Calls `list_agents` → discovers `tdd` agent → calls `use_agent("tdd")` → executes full TDD cycle

**Available agents:**
- **tdd**: Full TDD feature cycle (test → implement → review → PR)
- **quality**: Code quality sweep (conventions → refactor → docs)
- **review**: Systematic PR review (review → deep dive → response)
- **setup**: Project setup and CI/CD configuration
- **engine**: Rails engine development lifecycle
- **bug-fix**: Bug triage and resolution with TDD
- **graphql**: GraphQL API development with domain modeling
- **migration**: Safe database migration deployment
- **background-job**: Robust background job implementation

Agents enforce hard gates (like "tests must pass before implementation") and include TDD enforcement, making them more reliable than ad-hoc skill chaining.

## Daily Workflow

Depending on your environment (MCP vs. Chat Commands), you can orchestrate your daily Rails work using these common loops. For explicit control in Cursor or Windsurf, prepend these with `@` (e.g., `@load-context`). In MCP, simply describe the goal and the agent will load them automatically.

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

**For a new feature from scratch:**
```text
create-prd -> generate-tasks -> TDD feature loop
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

See [docs/agent-guide.md](docs/agent-guide.md) and [docs/agents/](docs/agents/) for the full process guide containing detailed Mermaid diagrams of each phase.

## Skill Catalog

The library contains 41 public skills organized by Rails development concern.

| Category | Examples |
|----------|----------|
| Planning | `create-prd`, `generate-tasks`, `plan-tickets` |
| Testing | `plan-tests`, `write-tests`, `test-service`, `triage-bug` |
| Code quality | `code-review`, `respond-to-review`, `security-check`, `refactor-code` |
| Architecture and DDD | `define-domain-language`, `review-domain-boundaries`, `model-domain`, `review-architecture` |
| Rails implementation | `create-service-object`, `implement-background-job`, `implement-authorization`, `implement-hotwire` |
| APIs | `generate-api-collection`, `implement-graphql`, `integrate-api-client`, `version-api` |
| Engines | `create-engine`, `test-engine`, `document-engine`, `release-engine`, `upgrade-engine` |
| Infrastructure | `review-migration`, `optimize-performance`, `seed-database` |
| Orchestration | `skill-router` |

Use [docs/reference/skill-catalog.md](docs/reference/skill-catalog.md) for the complete catalog and [docs/reference/integration-matrix.md](docs/reference/integration-matrix.md) for skill chaining.

## Quality And Evaluation

This repo uses two complementary evaluation layers.

| Layer | Status | What it validates |
|-------|--------|-------------------|
| Tessl | Public and active | Tessl-native scenarios in `tessl-evals/` validate the quality of publishable skills from `tile.json`. Tessl does not validate repository agents today. |
| `ruby-skill-bench` | Coming soon | The upcoming Ruby gem will run `personal-evals/` examples with full skill or agent context, including `SKILL.md` plus companion resources bundled as XML. |

Root `evals/` is generated Tessl staging output and must stay untracked. `tessl-evals/` is the tracked Tessl source. `personal-evals/` is the tracked source for open custom-evaluator examples.

See [docs/eval-provenance.md](docs/eval-provenance.md) for the canonical eval ownership policy and [docs/skill-optimization-guide.md](docs/skill-optimization-guide.md) for the baseline-vs-context optimization loop.

## Install Selected Skills With GitHub CLI

Requires [GitHub CLI](https://cli.github.com/) v2.90.0+ with `gh skill`.

```bash
# Install all skills interactively
gh skill install igmarin/rails-agent-skills

# Install a specific skill for the current project
gh skill install igmarin/rails-agent-skills code-review --scope project

# Install a specific skill globally
gh skill install igmarin/rails-agent-skills code-review --scope user

# Install pinned to a release tag
gh skill install igmarin/rails-agent-skills code-review --pin v5.1.5 --scope user

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
| Install and configure MCP | [mcp_server/README.md](mcp_server/README.md) |
| Browse all skills | [docs/reference/skill-catalog.md](docs/reference/skill-catalog.md) |
| Understand skill chaining | [docs/reference/integration-matrix.md](docs/reference/integration-matrix.md) |
| Follow agent guides | [docs/agent-guide.md](docs/agent-guide.md) |
| Understand repository structure | [docs/architecture.md](docs/architecture.md) |
| Understand eval ownership | [docs/eval-provenance.md](docs/eval-provenance.md) |
| Optimize skill eval quality | [docs/skill-optimization-guide.md](docs/skill-optimization-guide.md) |

## Contributing

When contributing skills, agents, docs, or MCP behavior:

- Keep generated artifacts in English unless a user explicitly asks for another language.
- Preserve the tests-gate-implementation rule for every code-producing skill.
- Do not add tickets unless the user asks for ticket generation.
- Do not commit generated root `evals/` output.
- Keep public docs consistent with `tile.json`, `server.json`, and the latest release tag.

## Install With skills.sh

Requires [skills.sh](https://www.skills.sh/) CLI.

```bash
# Add the library to your workspace
npx skills add igmarin/rails-agent-skills
```

## Acknowledgments

Huge thanks to [Mumo Carlos (@mumoc)](https://github.com/mumoc). His mentorship shaped many of the habits reflected here, especially the discipline around quality, clarity, and thoughtful use of tools.
