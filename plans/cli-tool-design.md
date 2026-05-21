# CLI Tool Design — Rails Agent Skills

## Vision

Turn this repository into a Ruby gem that doubles as a CLI tool.
`gem install rails-agent-skills` gives you:

- `rails-agent run tdd "build user auth"` — execute agents with LLM backing
- `rails-agent list skills` — discover available skills
- `rails-agent show code-review` — read a skill's instructions
- `rails-agent test write-tests` — run skill evals
- `rails-agent lint` / `rails-agent validate` — CI-ready quality checks
- `rails-agent server` / `rails-agent mcp` — start the embedded MCP server directly

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

rails-agent server           (starts the embedded MCP server)
rails-agent mcp              (alias for rails-agent server)
```

## Core New Modules

### AgentRunner (ReAct Tool-Execution Loop & Interactive Pause)

The execution engine. Reads an agent's SKILL.md, extracts phases from
frontmatter, and runs a ReAct (Reasoning and Acting) execution loop.
Instead of treating LLM output as static text, the AgentRunner executes tool calls
(such as reading files or running shell commands) locally on behalf of the agent,
respecting safety approvals, and feeds results back to the LLM.

It also supports an interactive pause/resume mechanism when gates fail
or user inputs are required, prompting the developer using interactive UI libraries (like `tty-prompt`).

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
      
      # JIT/Lazy Context: Initialize with lazy handlers, not a full dump
      context = ContextLoader.new(@project_root)

      phases.each_with_object(
        Result.new(phases_completed: [], artifacts: [], logs: [], passed: true)
      ) do |phase, result|
        break result unless result.passed

        # ReAct execution loop for the current phase (runs tools JIT)
        loop_result = run_react_loop(phase: phase, context: context)
        
        if loop_result.gate_failed?
          result.passed = handle_interactive_pause(phase)
          break result unless result.passed
        end

        result.phases_completed << phase.name
        result.artifacts << loop_result.artifacts
      end
    end

    private

    def run_react_loop(phase:, context:)
      # Prompts LLM, handles tool calls (e.g. read_file, run_command),
      # enforces confirmation permissions for destructive commands.
    end

    def handle_interactive_pause(phase)
      # Invokes tty-prompt to ask user: "Gate failed (e.g. specs failed). Resume/Abort/Retry?"
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

### ContextLoader (Lazy / JIT Context)

Avoids dumping the entire codebase schema and routes into the initial system prompt,
which would blow out token usage. Instead, context loading is lazy and JIT. The
ContextLoader exposes tools to the AgentRunner (e.g., `get_db_schema`, `get_routes`,
`find_models`) that the LLM backend calls dynamically only when needed.

```ruby
module RailsAgentSkills
  class ContextLoader
    def initialize(project_root)
      @project_root = project_root
    end

    # Fast, high-level metadata loaded initially
    def initial_summary
      {
        ruby_version: read_if_exists(".ruby-version"),
        gemfile_summary: summarize_gemfile
      }
    end

    # Called JIT when the LLM triggers a schema query tool
    def db_schema
      @db_schema ||= read_if_exists("db/schema.rb")
    end

    # Called JIT when the LLM triggers a routes query tool
    def routes
      @routes ||= read_if_exists("config/routes.rb")
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
| Error handling / Gate | Pause via `tty-prompt` on gate failure | Prompts user interactively to resolve or abort in place |
| Tool-Execution Loop | ReAct active tool execution loop | Agent actively invokes tools dynamically during phases |
| Context Loading | Lazy / JIT context loading | Exposes specialized tools instead of dumping whole files upfront |
| Embedded Server | Ship MCP server in CLI gem | Allows running server via `rails-agent server` directly |
| Safe Executions | Interactive command confirmation | Protects user's filesystem from unapproved destructive commands |
| Output format | Plain text stdout, optional `--json` | Pipe-friendly for CI |
| LLM streaming | Via `--verbose` flag | See agent thinking in real-time |

## Gemspec Dependencies

```ruby
spec.add_dependency "thor", "~> 1.3"
spec.add_dependency "json", "~> 2.19"
spec.add_dependency "tty-prompt", "~> 0.23"
spec.add_development_dependency "minitest"
spec.add_development_dependency "webmock"
spec.add_development_dependency "vcr"
```

No external MCP server binary wrapper needed — packaged inside the gem.
