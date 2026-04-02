# Model Context Protocol (MCP) Ruby Server for Rails Agent Skills

This directory contains a minimalist Ruby-based server that implements the [Model Context Protocol (MCP)](https://github.com/isomorphic-protocol/server). Its purpose is to expose the `SKILL.md` files in the parent `rails-agent-skills` repository as queryable resources for AI agents.

This allows AI tools (like Gemini CLI, Cursor, Claude, Windsurf, etc.) to fetch specific skill documentation on demand, rather than needing to load the entire repository into context. This saves tokens, improves performance, and makes the skill library more flexible for various AI environments.

## How it Works

The `server.rb` script starts an `MCP::Server` instance, which listens for MCP requests on `STDIN` (Standard Input) and sends JSON responses back over `STDOUT` (Standard Output). It leverages a clean, object-oriented design:

*   **`MCP::Server`**: The main orchestrator, responsible for the input/output loop and error handling.
*   **`MCP::RequestHandler`**: Parses incoming requests and dispatches them to the correct logic.
*   **`MCP::ResourceLocator`**: Dedicated to finding and reading `SKILL.md` files.
*   **`MCP::Response`**: Standardizes the format of all success and error responses.

It supports two primary MCP methods:

1.  **`ListResources`**: Returns a list of all `SKILL.md` files found in the parent repository, formatted as MCP resources (with a `skill/` prefix for `name`).
2.  **`ReadResource`**: Reads and returns the content of a specific `SKILL.md` file based on its `uri`.

## Getting Started

1.  **Ensure Ruby is installed:** This server requires a Ruby environment (version 2.7 or higher recommended). No special gems are needed beyond `json` and `pathname`, which are part of Ruby's standard library.

2.  **Navigate to the `mcp_server` directory:**
    ```bash
    cd rails-agent-skills/mcp_server
    ```

3.  **Run the server:**
    ```bash
    ruby server.rb
    ```
    The server will start listening for requests.

## Integration with AI Tools

To integrate this MCP server with your AI development environment, you'll need to configure your specific AI tool to launch and connect to this server via `STDIO`. Refer to your AI tool's documentation for how to configure custom MCP servers.

Example (conceptual for a CLI tool that supports `--mcp-server`):

```bash
# From your project root, or anywhere
# The command should start the server process and typically pipe its STDIN/STDOUT
AI_CLI_TOOL --mcp-server "ruby /path/to/rails-agent-skills/mcp_server/server.rb"
```

## Testing the Server (using Minitest)

To ensure the server is functioning correctly, unit tests are provided for the core components.

1.  **Install dependencies:** Ensure you have `minitest` installed. You can use Bundler from within the `mcp_server` directory if you create a `Gemfile` (which we've done):
    ```bash
    bundle install
    ```

2.  **Run the tests:**
    ```bash
    bundle exec ruby -Ilib test/resource_locator_test.rb
    bundle exec ruby -Ilib test/request_handler_test.rb
    ```

    *Note: Fully testing the `MCP::Server`'s STDIN/STDOUT loop in Minitest typically involves more advanced Ruby process management (`Open3`), which is outside the scope of basic unit tests and the `README.md` example. The provided tests focus on the core logic encapsulated in `ResourceLocator` and `RequestHandler`.*

## Contributing

Feel free to contribute improvements to this MCP server. If adding new features, ensure they adhere to the MCP specification and are thoroughly tested.
