# IDE Integration Guide: Using Rails Agent Skills

This guide provides step-by-step instructions on how to integrate and use the Rails Agent Skills library within various Integrated Development Environments (IDEs) and AI-powered coding tools.

There are two primary methods for making skills available to your AI assistant:

1.  **The Symlink Approach**: A quick way to get started by creating symbolic links to `SKILL.md` files or the main `GEMINI.md`. Simple for basic setup, but less efficient for large libraries.
2.  **The Model Context Protocol (MCP) Server Approach**: The The recommended, more advanced method. It allows AI tools to query for specific skills on demand, saving tokens, enabling real-time updates, and ensuring true model independence.

---

## Cursor & Windsurf (VS Code-based Tools)

These tools, built on VS Code, offer excellent integration options for AI context.

### Method 1: The Symlink Approach (Quick Start)

This is the simplest way to make skills available directly to Cursor or Windsurf.

1.  **Clone the `rails-agent-skills` repository** to a local directory (if you haven't already):
    ```bash
    git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills
    ```
2.  **Create a symlink to the `rails-agent-skills` directory** within your Cursor or Windsurf skills directory. The exact path might vary, but commonly:
    *   **Cursor:** `~/.cursor/skills/` or `~/.cursor/skills-cursor/`
    *   **Windsurf:** `~/.windsurf/skills/`

    Example for Cursor:
    ```bash
    ln -s ~/skills/rails-agent-skills ~/.cursor/skills/rails-agent-skills
    # Or for Windsurf:
    # ln -s ~/skills/rails-agent-skills ~/.windsurf/skills/rails-agent-skills
    ```
3.  **Restart your IDE** (Cursor/Windsurf) for the changes to take effect.

**Pros:** Easy to set up.
**Cons:** The entire content of the symlinked skills might be loaded into the AI's context, which can be inefficient for large libraries.

### Method 2: The MCP Server Approach (Recommended)

This method provides on-demand access to skills, saving tokens and improving efficiency.

1.  **Ensure the Ruby MCP Server is set up:**
    *   Follow the instructions in the **[MCP Server README](mcp_server/README.md)** to set up and verify your Ruby MCP server.
2.  **Configure your IDE to use the MCP Server:**
    *   Open your Cursor or Windsurf settings (usually `Ctrl+,` or `Cmd+,`).
    *   Search for "Model Context Protocol Servers" or a similar setting.
    *   Add a new MCP server entry. You will typically be asked for a **"Command"** to run.
    *   **Enter the full path to your Ruby server script:**
        ```bash
        ruby /path/to/your/rails-agent-skills/mcp_server/server.rb
        ```
        (Replace `/path/to/your/rails-agent-skills` with the actual absolute path to your cloned repository.)
3.  **Restart your IDE** for the changes to take effect.

**Pros:** Efficient (token saving), real-time updates, future-proof.
**Cons:** Requires an additional background process.

---

## JetBrains RubyMine (AI Assistant)

Due to how JetBrains IDEs manage their AI context, the **MCP Server is the most robust and recommended method** for integrating the Rails Agent Skills library. The symlink approach is less effective or may not be officially supported for custom skill injection.

1.  **Ensure the Ruby MCP Server is set up:**
    *   Follow the instructions in the **[MCP Server README](mcp_server/README.md)** to set up and verify your Ruby MCP server.
2.  **Configure RubyMine's AI Assistant:**
    *   Open RubyMine's settings (`Ctrl+Alt+S` or `Cmd+,`).
    *   Navigate to the "Tools" or "Languages & Frameworks" section, and look for "AI Assistant" or "Model Context Protocol."
    *   Search for settings related to "Knowledge Sources," "Custom Models," or "External Context Servers."
    *   You will typically need to specify a **"Command"** to launch your MCP server.
        ```bash
        ruby /path/to/your/rails-agent-skills/mcp_server/server.rb
        ```
        (Replace `/path/to/your/rails-agent-skills` with the actual absolute path to your cloned repository.)
    *   The exact UI and terminology in RubyMine's AI settings may evolve, so you might need to search the documentation for the latest guidance on integrating custom knowledge sources or MCP servers.
3.  **Restart RubyMine** for the changes to take effect.

---

## CLI Tools (Gemini CLI, Claude Code, Codex)

Command-line interface (CLI) tools interact with skills differently.

### Method 1: The Symlink (or `--plugin-dir`) Approach

Many CLIs can load skills from a designated directory.

1.  **Clone the `rails-agent-skills` repository** (if you haven't already):
    ```bash
    git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills
    ```
2.  **Configure your CLI tool:**
    *   **Gemini CLI:** Create a symlink to `GEMINI.md`:
        ```bash
        ln -s ~/skills/rails-agent-skills/GEMINI.md ~/.gemini/GEMINI.md
        ```
        (Requires starting a new session to pick up changes.)
    *   **Claude Code:** Use the `--plugin-dir` flag (often wrapped in a shell function as shown in the main `README.md`):
        ```bash
        # Add to ~/.zshrc or ~/.bashrc
        claude() {
          command claude --plugin-dir ~/skills/rails-agent-skills "$@"
        }
        source ~/.zshrc # Or ~/.bashrc
        ```
    *   **Codex:** Clone or symlink directly into its skills directory:
        ```bash
        ln -s ~/skills/rails-agent-skills ~/.codex/skills/rails-agent-skills
        ```

### Method 2: The MCP Server Approach (For Future-Compatible CLIs)

As CLI tools evolve, they may also offer direct MCP server integration.

1.  **Ensure the Ruby MCP Server is set up:**
    *   Follow the instructions in the **[MCP Server README](mcp_server/README.md)**.
2.  **Configure your CLI tool:**
    *   If your CLI tool supports an `--mcp-server` flag or a similar configuration, you would provide the command to start your Ruby server:
        ```bash
        AI_CLI_TOOL --mcp-server "ruby /path/to/your/rails-agent-skills/mcp_server/server.rb"
        ```
