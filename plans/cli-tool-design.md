# CLI Tool Design — Rails Agent Skills

## Vision

Turn this repository into a Ruby gem that doubles as a CLI tool.
`gem install rails-agent-skills` gives you:

- `rails-agent run tdd "build user auth"` — execute agents with LLM backing
- `rails-agent list skills` — discover available skills
- `rails-agent show code-review` — read a skill's instructions
- `rails-agent test write-tests` — run skill evals
- `rails-agent lint` / `rails-agent validate` — CI-ready quality checks

## Architecture

```
rails-agent-skills/
├── lib/
│   └── rails_agent_skills/           # Shared core (extracted from mcp_server/)
│       ├── version.rb
│       ├── skill_catalog.rb          # ← moved from mcp_server/lib/mcp_skills/
│       ├── resource_discovery.rb     # ← moved from mcp_server/lib/mcp_skills/
│       └── frontmatter.rb            # ← extracted: deduplicated YAML parser
│
├── cli/                              # New CLI application
│   ├── rails-agent-skills.gemspec
│   ├── Gemfile
│   ├── exe/
│   │   └── rails-agent               # Entry binary
│   ├── lib/
│   │   └── rails_agent_skills/
│   │       ├── cli.rb                # CLI dispatcher (Thor)
│   │       ├── commands/
│   │       │   ├── run.rb
│   │       │   ├── list.rb
│   │       │   ├── show.rb
│   │       │   ├── search.rb
│   │       │   ├── test.rb
│   │       │   ├── lint.rb
│   │       │   ├── validate.rb
│   │       │   └── install.rb
│   │       ├── agent_runner.rb       # Phase executor + gate enforcer
│   │       ├── context_loader.rb     # Reads project context
│   │       └── backends/
│   │           ├── interface.rb      # Backend adapter interface
│   │           ├── anthropic.rb
│   │           ├── openai.rb
│   │           ├── mcp_client.rb
│   │           └── ollama.rb
│   └── test/
│
├── mcp_server/                       # MCP server (requires lib/)
│   └── lib/mcp_skills/
│       ├── list_skills_tool.rb       # Now depends on lib/rails_agent_skills
│       ├── skill_tool.rb
│       ├── list_agents_tool.rb
│       ├── agent_tool.rb
│       ├── list_workflows_tool.rb    # deprecated
│       ├── workflow_tool.rb          # deprecated
│       └── ...
│
├── agents/                           # 9 callable agents
├── skills/                           # 41 atomic skills
├── docs/                             # Documentation
├── tile.json                         # Skills manifest
└── agents.json                       # Agent reference
```

## CLI Commands

```
rails-agent run <agent> [task]
  --backend anthropic|openai|mcp|ollama
  --model <model-id>
  --project-root <path>      (default: Dir.pwd)
  --dry-run                  (print steps without executing)
  --verbose                  (stream LLM output)

rails-agent list [skills|agents]
  --format table|json

rails-agent show <skill-or-agent-name>
  --format markdown|json

rails-agent search <query>

rails-agent test <skill-name>
  --scenario <n>

rails-agent lint
  --all

rails-agent validate
  --tile <path>

rails-agent install
  --hooks
  --project
  --user
```

## Core New Modules

### AgentRunner

The execution engine. Reads an agent's SKILL.md, extracts phases from
frontmatter, iterates phases sequentially, prompts an LLM backend per
phase, enforces hard-gate checks between phases.

```ruby
module RailsAgentSkills
  class AgentRunner
    Result = Struct.new(:phases_completed, :artifacts, :logs, :passed,
                        keyword_init: true)

    def self.call(agent_name:, task:, backend:,
                  project_root: Dir.pwd, verbose: false)
      new(agent_name: agent_name, task: task, backend: backend,
          project_root: project_root, verbose: verbose).call
    end

    def call
      agent_md = load_agent_skill_md
      phases  = Frontmatter.phases(agent_md)
      context = ContextLoader.call(@project_root)

      phases.each_with_object(
        Result.new(phases_completed: [], artifacts: [], logs: [], passed: true)
      ) do |phase, result|
        break result unless result.passed

        skill = resolve_skill(phase.dependency)
        prompt = build_prompt(phase: phase, skill: skill, context: context)
        output = @backend.call(prompt: prompt, system_prompt: SYSTEM_PROMPT)
        result.passed = evaluate_gate(phase.gate) if phase.gate
        result.phases_completed << phase.name
        result.artifacts << output
        result.logs << output
      end
    end
  end
end
```

### Backend Interface

The seam for pluggable LLM providers. One adapter = hypothetical seam.
Two+ adapters = real seam.

```ruby
module RailsAgentSkills
  module Backends
    class Interface
      def call(prompt:, system_prompt:, tools: [])
        raise NotImplementedError
      end

      def name
        raise NotImplementedError
      end
    end
  end
end
```

Adapters:
- `Backends::Anthropic` — Claude API (anthropic gem)
- `Backends::OpenAI` — GPT API (ruby-openai gem)
- `Backends::McpClient` — Bridges to an MCP host (Claude Desktop, Cursor)
- `Backends::Ollama` — Local models via ollama HTTP API

### Frontmatter

Extracted from 5 duplicate implementations across tool files.

```ruby
module RailsAgentSkills
  module Frontmatter
    def self.parse(content)      → Hash
    def self.description(content) → String
    def self.keywords(content)    → String
    def self.phases(content)      → Array<Phase>
  end
end
```

### ContextLoader

Reads the user's Rails project for context injection into LLM prompts.

```ruby
module RailsAgentSkills
  class ContextLoader
    def self.call(project_root)
      {
        schema:       read_if_exists("db/schema.rb"),
        routes:       read_if_exists("config/routes.rb"),
        gemfile:      read_if_exists("Gemfile"),
        ruby_version: read_if_exists(".ruby-version"),
        models:       discover_models,
        specs:        discover_specs
      }
    end
  end
end
```

## Migration Plan — 5 Phases

### Phase 0: Extract shared lib (low risk)

Move `skill_catalog.rb` and `resource_discovery.rb` from
`mcp_server/lib/mcp_skills/` to `lib/rails_agent_skills/`.
Rename module from `McpSkills` to `RailsAgentSkills`.
Extract `frontmatter.rb`. Update `mcp_server/` requires.
Run all 51 tests — they must still pass.

### Phase 1: Scaffold CLI (low risk)

Create `cli/` directory with gemspec, Thor dispatcher,
`list`/`show`/`search` commands. Read-only, no execution.
Tests: minitest on each command.

### Phase 2: Backend adapters (medium risk)

Implement `Backend::Interface` + Anthropic + OpenAI adapters.
Add API key config (`~/.rails-agent/config.yml`).
Add `--dry-run` mode for debugging prompts.
Tests: VCR/webmock for API calls.

### Phase 3: Agent execution (high risk)

Implement `AgentRunner` + `ContextLoader`.
Add `rails-agent run <agent>` command.
Parse agent phases from frontmatter.
Enforce hard-gate checks (`bundle exec rspec` exit codes, etc.).
This is the most complex module — the core value proposition.

### Phase 4: Full toolkit (medium risk)

Add `test`, `lint`, `validate`, `install` commands.
Add Ollama and MCP client backends.
Integration tests and CI pipeline.

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| CLI framework | Thor | Standard for Ruby CLIs (rails, bundle) |
| Config storage | `~/.rails-agent/config.yml` | Simple, no database |
| Agent phase parsing | Frontmatter `metadata.phases` | Already present in all 9 agents |
| Skill resolution | Reuse `SkillCatalog` + `ResourceDiscovery` | No new discovery logic needed |
| Error handling | Pause-and-retry on gate failure | User fixes failing tests, agent continues |
| Output format | Plain text stdout, optional `--json` | Pipe-friendly for CI |
| LLM streaming | Via `--verbose` flag | See agent thinking in real-time |

## Gemspec Dependencies

```ruby
spec.add_dependency "thor", "~> 1.3"
spec.add_dependency "json", "~> 2.19"
spec.add_development_dependency "minitest"
spec.add_development_dependency "webmock"
spec.add_development_dependency "vcr"
```

No MCP gem dependency in the CLI — `mcp_server/` keeps that.
