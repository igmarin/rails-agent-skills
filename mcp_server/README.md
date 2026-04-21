# Rails Agent Skills — MCP Server

A Ruby MCP server that exposes the `rails-agent-skills` skill library to AI tools (Windsurf, Cursor, Claude Code, RubyMine, etc.) via the [Model Context Protocol](https://modelcontextprotocol.io) official spec (JSON-RPC 2.0, stdio transport).

Built on the [official Ruby MCP SDK](https://github.com/modelcontextprotocol/ruby-sdk) (`gem 'mcp'`).

---

## Compatibility

| Requirement | Version |
|-------------|---------|
| Ruby | 3.1+ |
| `mcp` gem | 0.13+ |
| Bundler | 2.x |

---

## What it exposes

| Type | Prefix | Source |
|------|--------|--------|
| **Resources** | `skill/<name>` | Every `SKILL.md` + support files (`EXAMPLES.md`, `TESTING.md`, `PATTERNS.md`, `HEURISTICS.md`, `TASK_TEMPLATES.md`) in each skill directory |
| **Resources** | `doc/<name>` | All `*.md` files under `docs/` |
| **Resources** | `workflow/<name>` | All `*.md` files under `.windsurf/workflows/` |
| **Tool** | `use_skill` | Invocable tool: given a `skill_name`, returns the full `SKILL.md` content |

Adding a new skill directory to the repo automatically makes it available — no server changes needed.

---

## Architecture

```text
mcp_server/
├── server.rb                          # Entry point: MCP::Server + StdioTransport
├── Gemfile                            # gem 'mcp' (official SDK), minitest, rake
├── Rakefile                           # bundle exec rake test
├── Dockerfile                         # Container image for Docker-based deployment
├── registry.json                      # Metadata for MCP registries (smithery.ai, glama.ai)
├── lib/
│   └── mcp_skills/
│       ├── resource_registry.rb       # Service: discovers all resources (skills + docs + workflows)
│       ├── skill_resource_builder.rb  # Service: builds MCP::Resource objects for skills
│       ├── doc_resource_builder.rb    # Service: builds MCP::Resource objects for docs/workflows
│       └── skill_tool.rb             # MCP::Tool: 'use_skill' invocable by the agent
└── test/
    ├── test_helper.rb
    ├── resource_registry_test.rb
    ├── skill_resource_builder_test.rb
    ├── doc_resource_builder_test.rb
    └── skill_tool_test.rb
```

**Service objects:**

- **`McpSkills::ResourceRegistry`** — scans the repo for all exposable files. Single source of truth. Zero hardcoded skill names.
- **`McpSkills::SkillResourceBuilder`** — maps a skill directory path to an `MCP::Resource` with `file://` URI and `skill/` name prefix.
- **`McpSkills::DocResourceBuilder`** — same for `docs/` and `.windsurf/workflows/` with `doc/` and `workflow/` prefixes.
- **`McpSkills::SkillTool`** — `MCP::Tool` subclass. `call(skill_name:)` reads and returns the `SKILL.md` content.

---

## Getting started

```bash
git clone https://github.com/igmarin/rails-agent-skills.git ~/rails-agent-skills
cd ~/rails-agent-skills/mcp_server
bundle install
```

**Run the server manually** (stdio — for debugging):

```bash
bundle exec ruby server.rb
```

**Inspect with the MCP inspector:**

```bash
npx @modelcontextprotocol/inspector bundle exec ruby server.rb
```

---

## Integration with Claude Code

The repo includes a pre-populated `.mcp.json` at the root. When you open the cloned repo as a project in Claude Code, the server is registered automatically — no manual config needed.

For **global** setup (available in every project), add to `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/YOUR/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/YOUR/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

Replace the path with your actual clone location, then start a new Claude Code session.

---

## Integration with Windsurf

The config goes in your **global** Windsurf MCP file (`~/.codeium/windsurf/mcp_config.json`):

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/YOUR/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/YOUR/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

Reload Windsurf (`Cmd+Shift+P` → "Reload Window"). The server will appear in the MCP panel.

> **Why `BUNDLE_GEMFILE`?** The server's `Gemfile` lives inside `mcp_server/`, not at the repo root. Setting this env var tells Bundler exactly which Gemfile to use regardless of working directory.

---

## Integration with Cursor

Open **Settings → MCP** (or edit `~/.cursor/mcp.json`) and add:

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/YOUR/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/YOUR/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

Restart Cursor.

---

## Integration with RubyMine

Open **Settings → Tools → AI Assistant → Model Context Protocol** and add a new server:

- **Command:** `bundle exec ruby mcp_server/server.rb`
- **Working directory:** `/YOUR/PATH/TO/rails-agent-skills`
- **Environment:** `BUNDLE_GEMFILE=/YOUR/PATH/TO/rails-agent-skills/mcp_server/Gemfile`

Restart RubyMine.

---

## Docker

For environments without Ruby, or for containerized deployment:

```bash
cd mcp_server
docker build -t rails-agent-skills-mcp .
docker run --rm -i rails-agent-skills-mcp
```

The container uses stdio transport — wire it up the same way as the Ruby command, replacing `bundle exec ruby server.rb` with `docker run --rm -i rails-agent-skills-mcp`.

**Docker Hub** (published image):

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "docker",
      "args": ["run", "--rm", "-i", "igmarin/rails-agent-skills-mcp"]
    }
  }
}
```

---

## End-to-end use case

1. You open any Rails project in Windsurf (or Claude Code, Cursor, etc.).
2. The IDE loads this MCP server from its config.
3. You ask: *"I need to add a GraphQL mutation — which skill should I use?"*
4. The agent calls `tools/call use_skill` with `skill_name: "rails-graphql-best-practices"`.
5. The server reads `rails-graphql-best-practices/SKILL.md` and returns the full instructions.
6. The agent follows the skill workflow without loading the entire repo into context.

---

## Running tests

```bash
bundle exec rake test
```

Tests are written with Minitest: each file validates real behavior of a service object, not just structure.

---

## Auto-discovery of new skills

`ResourceRegistry` uses glob patterns (`**/SKILL.md`, `docs/**/*.md`, `.windsurf/workflows/*.md`). When you add a new skill directory with a `SKILL.md`, it appears in `resources/list` on the next server start — no code changes required.

---

## Public registries

This server is listed on:

- [smithery.ai](https://smithery.ai) — auto-indexed from GitHub
- [glama.ai](https://glama.ai) — submit via their website
- [modelcontextprotocol.io/registry](https://modelcontextprotocol.io) — community servers list

---

## Contributing

- Follow TDD: write the failing test first, then the implementation.
- Service objects live in `lib/mcp_skills/` and must be independently testable (no `MCP::Server` dependency in unit tests).
- All MCP protocol behavior is handled by the `mcp` gem — do not reimplement wire format in service objects.
