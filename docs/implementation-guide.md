# Implementation Guide — Rails Agent Skills

Step-by-step install and verification for the **`rails-agent-skills`** repository on each supported platform.

- **What this library is:** [README](../README.md)
- **How to chain skills:** [agent-guide.md](agent-guide.md)
- **Skill file conventions:** [architecture.md](architecture.md)

The recommended way to use this library is via the **MCP Server Approach**. The primary path for users is the official MCP distribution, with Docker available for repeatable installs and local Ruby/Bundler available for development or debugging.

---

## MCP Server (Recommended)

The MCP server exposes docs and agents as resources and loads skills on demand through the `use_skill` and `use_agent` tools.

For complete MCP setup instructions, exact host-specific config snippets, Docker examples, official registry details, and troubleshooting, see [mcp_server/README.md](../mcp_server/README.md). That file is the canonical source of truth for MCP setup.

### Official MCP and Docker (Primary for users)

For shared team installs, use the versioned Docker image documented in [mcp_server/README.md](../mcp_server/README.md). The current public examples use:

```text
igmarin/rails-agent-skills-mcp:5.1.5
```

### Local Ruby/Bundler (Primary for development)

Clone the repo and install the MCP server dependencies:

```bash
git clone https://github.com/igmarin/rails-agent-skills.git ~/skills/rails-agent-skills
cd ~/skills/rails-agent-skills/mcp_server
bundle install
```

Then configure your MCP host with the exact template from [mcp_server/README.md](../mcp_server/README.md). In Claude Code, opening the repo already picks up the bundled root `.mcp.json`.

### Docker fallback

If you do not want to manage a local Ruby toolchain, use the Docker setup documented in [mcp_server/README.md](../mcp_server/README.md).

---

## Alternative: The Symlink Approach (Legacy)

If you cannot use MCP, you can symlink the `CLAUDE.md` or `GEMINI.md` files to your agent's global configuration directory.

### Claude Code
```bash
ln -sf ~/skills/rails-agent-skills/CLAUDE.md ~/.claude/CLAUDE.md
```

### Gemini CLI
```bash
ln -s ~/skills/rails-agent-skills/GEMINI.md ~/.gemini/GEMINI.md
```

---

## Session Start Hook

The session-start hook automatically injects the `skill-router` bootstrap skill at the beginning of each session.

| Platform | Integration Method |
|----------|--------------------|
| Claude Code | Handled via `~/.claude/CLAUDE.md` |
| Cursor / Windsurf | Handled via MCP `resources/list` |
| Gemini CLI | Handled via `~/.gemini/GEMINI.md` |

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| MCP Server Timeout | Ensure you are using **absolute paths** for both the command and `BUNDLE_GEMFILE`. |
| "Gem not found" | Run `bundle install` inside the `mcp_server/` directory. |
| Skills not appearing | Restart your IDE or start a new Claude Code session (`/reset`). |
| Resource Bloat | The server is configured to hide individual skills. Use the `use_skill` tool to load them by name. |
