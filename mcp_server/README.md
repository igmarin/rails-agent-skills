# Rails Agent Skills — MCP Server

A Ruby MCP server that exposes the `rails-agent-skills` skill library to AI tools (Windsurf, Cursor, Claude, etc.) via the [Model Context Protocol](https://modelcontextprotocol.io) official spec (JSON-RPC 2.0, stdio transport).

Built on the [official Ruby MCP SDK](https://github.com/modelcontextprotocol/ruby-sdk) (`gem 'mcp'`).

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

**Requirements:** Ruby 3.1+, Bundler.

```bash
cd rails-agent-skills/mcp_server
bundle install
```

**Run the server manually** (stdio — mostly for debugging):

```bash
bundle exec ruby server.rb
```

**Inspect with the MCP inspector:**

```bash
npx @modelcontextprotocol/inspector bundle exec ruby server.rb
```

---

## Integration with Windsurf

The config goes in your **global** Windsurf MCP file (`~/.codeium/windsurf/mcp_config.json`), not in the repo — this way it works per machine with the correct absolute paths.

**Steps:**

1. Clone the repo and install dependencies:

   ```bash
   git clone https://github.com/your-org/rails-agent-skills.git ~/Developer/rails-agent-skills
   cd ~/Developer/rails-agent-skills/mcp_server
   bundle install
   ```

2. Open `~/.codeium/windsurf/mcp_config.json` and add the `rails-agent-skills` entry (replace the path with your actual clone location):

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

3. Reload Windsurf (`Cmd+Shift+P` → "Reload Window"). The server will appear in the MCP panel.

The agent can then:

- Browse all skills via `resources/list`
- Read any skill, doc, or workflow via `resources/read`
- Invoke `use_skill` tool to retrieve a skill's instructions by name

## Integration with Cursor

1. Clone the repo and install dependencies (same as above).

2. Open Cursor **Settings → MCP** (or edit `~/.cursor/mcp.json`) and add:

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

3. Restart Cursor.

> **Why `BUNDLE_GEMFILE`?** The server's `Gemfile` lives inside `mcp_server/`, not at the repo root. Setting this env var tells Bundler exactly which Gemfile to use regardless of working directory.

---

## End-to-end use case

1. You open Windsurf in any Rails project.
2. Windsurf loads this MCP server from `~/.codeium/windsurf/mcp_config.json`.
3. You ask: *"I need to add a GraphQL mutation — which skill should I use?"*
4. The agent calls `tools/call use_skill` with `skill_name: "rails-graphql-best-practices"`.
5. The server reads `rails-graphql-best-practices/SKILL.md` and returns the full instructions.
6. The agent follows the skill workflow without loading the entire repo into context.

---

## Running tests

```bash
bundle exec rake test
```

Tests are written with Minitest using TDD: each test file validates real behavior of a service object, not just structure.

---

## Auto-discovery of new skills

`ResourceRegistry` uses glob patterns (`**/SKILL.md`, `docs/**/*.md`, `.windsurf/workflows/*.md`). When you add a new skill directory with a `SKILL.md`, it appears in `resources/list` on the next server start — no code changes required.

---

## Contributing

- Follow TDD: write the failing test first, then the implementation.
- Service objects live in `lib/mcp_skills/` and must be independently testable (no MCP::Server dependency in unit tests).
- All MCP protocol behavior is handled by the `mcp` gem — do not reimplement wire format in service objects.
