# Rails Agent Skills — MCP Server

A Ruby MCP server that exposes the `rails-agent-skills` library to AI tools (Windsurf, Cursor, Claude Code, RubyMine, OpenCode, etc.) via the [Model Context Protocol](https://modelcontextprotocol.io) official spec (JSON-RPC 2.0, stdio transport).

This is the canonical setup guide for the official MCP distribution. It publishes repository docs and agents as resources, discovers skills via `list_skills` and agents via `list_agents`, then loads individual skills/agents on demand through `use_skill` / `use_agent` so agents do not need the full library in context at once.

Built on the [official Ruby MCP SDK](https://github.com/modelcontextprotocol/ruby-sdk) (`gem 'mcp'`).

---

## Compatibility

| Requirement | Version |
|-------------|---------|
| Ruby | 4.0+ |
| `mcp` gem | 0.15+ |
| Bundler | 2.x |

---

## What it exposes

| Type | Prefix / Name | Source |
|------|---------------|--------|
| **Resources** | `doc/<name>` | All `*.md` files under `docs/`, including nested docs such as `docs/agents/*.md` |
| **Resources** | `agent/<name>` | Every agent directory under `agents/<name>/`, exposed from its `SKILL.md` plus supported companion files |
| **Tool** | `list_skills` | Invocable read-only discovery tool: returns public skill names, categories, paths, and frontmatter descriptions |
| **Tool** | `use_skill` | Invocable read-only loader tool: given a `skill_name`, returns structured metadata plus the full `SKILL.md` content for a public skill |
| **Tool** | `list_agents` | Invocable read-only discovery tool: returns available agents with names, paths, descriptions, and keywords |
| **Tool** | `use_agent` | Invocable read-only loader tool: given an `agent_name`, returns structured metadata plus the full `SKILL.md` content for an agent |

Individual **Skills** are no longer exposed as resources to prevent context bloat. Discover them with `list_skills`, then load one on demand with `use_skill`.

Adding a new public skill directory to the repo automatically makes it available through `list_skills` and `use_skill` — no server changes needed.

---

## Architecture

The runtime code lives in `mcp_server/`, while the container build lives at [`../Dockerfile`](../Dockerfile) because the image needs the full repository checkout, including skills, agents, and docs.

```text
mcp_server/
├── server.rb                          # Entry point: MCP::Server + StdioTransport
├── Gemfile                            # gem 'mcp' (official SDK), minitest, rake
├── Rakefile                           # bundle exec rake test
├── registry.json                      # Metadata for MCP registries (smithery.ai, glama.ai)
├── lib/
│   └── mcp_skills/
│       ├── skill_catalog.rb           # Service: builds structured skill metadata
│       ├── resource_registry.rb       # Service: discovers published docs and agents
│       ├── resource_discovery.rb      # Service: resolves published skill/agent topology
│       ├── skill_resource_builder.rb  # Service: builds MCP::Resource objects for agent markdown
│       ├── doc_resource_builder.rb    # Service: builds MCP::Resource objects for docs
│       ├── list_skills_tool.rb        # MCP::Tool: 'list_skills' discovery
│       ├── skill_tool.rb              # MCP::Tool: 'use_skill' loader
│       ├── list_agents_tool.rb        # MCP::Tool: 'list_agents' discovery
│       └── agent_tool.rb              # MCP::Tool: 'use_agent' loader
└── test/
    ├── test_helper.rb
    ├── resource_registry_test.rb
    ├── skill_resource_builder_test.rb
    ├── doc_resource_builder_test.rb
    ├── skill_tool_test.rb
    ├── list_skills_tool_test.rb
    ├── list_agents_tool_test.rb
    └── agent_tool_test.rb
```

**Service objects:**

- **`McpSkills::ResourceRegistry`** — scans the repo for published docs and agents. Single source of truth for the resource set.
- **`McpSkills::ResourceDiscovery`** — resolves the published topology for nested `skills/`, root `agents/`, and `docs/`.
- **`McpSkills::SkillResourceBuilder`** — maps an agent directory path to `MCP::Resource` objects with `file://` URIs and a configurable name prefix.
- **`McpSkills::DocResourceBuilder`** — builds `doc/` resources for markdown files anywhere under `docs/`.
- **`McpSkills::SkillCatalog`** — builds structured skill metadata from discovered `SKILL.md` files.
- **`McpSkills::ListSkillsTool`** — `MCP::Tool` subclass. `call` returns names, paths, categories, and descriptions as structured content.
- **`McpSkills::SkillTool`** — `MCP::Tool` subclass. `call(skill_name:)` returns structured metadata plus the full `SKILL.md` content.

---

## Local Ruby/Bundler (Primary)

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

> **Note:** Always use **absolute paths** to avoid "Gems not found" or timeout errors.

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

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
      "cwd": "/ABSOLUTE/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

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
      "cwd": "/ABSOLUTE/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

---

## Troubleshooting: Gems not found or Timeout

If you encounter errors like `Could not find 'mcp' (>= 0)` or the server times out:

1. **Verify Absolute Paths:** Ensure `cwd` and `BUNDLE_GEMFILE` in your JSON config use absolute paths (e.g., `/Users/name/...` instead of `~/...`).
2. **Pre-install Gems:** Run `cd mcp_server && bundle install` manually in your terminal to ensure the environment is ready.
3. **Manual Test:** Run the following command from any directory to see if it starts without errors:
   `BUNDLE_GEMFILE=/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile bundle exec ruby /ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/server.rb`
4. **Environment Mismatch:** If you use a Ruby manager (rvm, rbenv, asdf), ensure the `command` in your config points to the correct `bundle` executable if `bundle` alone doesn't work.

---

## Integration with RubyMine

Open **Settings → Tools → AI Assistant → Model Context Protocol** and add a new server:

- **Command:** `bundle exec ruby mcp_server/server.rb`
- **Working directory:** `/YOUR/PATH/TO/rails-agent-skills`
- **Environment:** `BUNDLE_GEMFILE=/YOUR/PATH/TO/rails-agent-skills/mcp_server/Gemfile`

Restart RubyMine.

---

## Other Providers (OpenCode, AntiGravity, etc.)

For any other tool that supports the Model Context Protocol via stdio, use the following template. **Crucial:** Most external providers fail if you use relative paths or `~`, so always use **absolute paths**.

```json
{
  "mcpServers": {
    "rails-agent-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/rails-agent-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/rails-agent-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

---

## Docker (Fallback)

For environments without Ruby, or for containerized deployment, Docker remains the fallback path. The primary setup for this repo is still local Ruby/Bundler.

```bash
# From the root of the repository:
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

Use a versioned image tag when you need repeatable installs:

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

`latest` tracks the most recent successful push to `main`. Versioned tags, such as `5.1.5`, are created from Git release tags and should be preferred for shared team configuration.

---

## Docker Security Hardening

The Docker image includes the following security measures:

- **Non-root user:** The container runs as `mcp` (UID 1000) instead of root. All application files are owned by this user.
- **Minimal attack surface:** Build dependencies (`build-base`) are installed as a virtual package and removed after `bundle install`, keeping the final image lean.
- **Base image:** Uses `ruby:4.0.4-alpine` for a minimal footprint.
- **OCI labels:** Includes standard OCI metadata labels alongside the MCP ownership label.

### CI/CD Security Pipeline

The Docker publish workflow (`.github/workflows/docker-publish.yml`) includes:

| Step | Tool | Purpose |
|------|------|---------|
| Vulnerability scan | [Trivy](https://github.com/aquasecurity/trivy) | Fails the build on HIGH/CRITICAL vulnerabilities |
| SBOM generation | [Syft](https://github.com/anchore/syft) (via `anchore/sbom-action`) | Produces an SPDX JSON software bill of materials |
| Image signing | [cosign](https://github.com/sigstore/cosign) | Signs release images with keyless Sigstore signing |
| Scan artifacts | GitHub Actions artifacts | SARIF scan results uploaded for review |

Trivy scans run after every image push. The SBOM and scan results are uploaded as workflow artifacts. Image signing occurs only on tagged releases.

---

## Cloudflare Worker Security

The Cloudflare MCP worker (`cloudflare_mcp/`) includes:

- **Rate limiting (configuration only):** `RATE_LIMIT_MAX_REQUESTS` and `RATE_LIMIT_WINDOW_SECONDS` environment variables are defined in `wrangler.jsonc` (default: 60 requests per 60 seconds). **These vars are not yet enforced in worker code** — application-level rate limiting middleware must be implemented to read and apply them. They serve as the configuration foundation for a future implementation.
- **Environment separation:** Production and staging environments with independent configuration.
- **Dependency auditing:** `npm audit` runs in CI before deployment.
- **TypeScript type checking:** Enforced in CI before deployment.
- **Deployment gating:** The worker only deploys after all security checks and tests pass.

### Cloudflare Dashboard Security Settings

The following settings should be configured manually in the Cloudflare dashboard for the worker domain:

1. **Bot Fight Mode** — Enable under Security → Bots to block known malicious bots.
2. **Block AI bots** — Enable the "AI Scrapers and Crawlers" toggle under Security → Bots to prevent unauthorized AI training crawlers.
3. **AI Labyrinth** — Enable under Security → Bots to trap and waste resources of unauthorized AI bots.
4. **Security.txt** — Configure a `security.txt` file under Security → Settings that includes:
   - Contact email for reporting vulnerabilities
   - Preferred language
   - Policy link (if applicable)

---

## Official MCP Registry

This server is published to the official MCP Registry as:

```text
io.github.igmarin/rails-agent-skills-mcp
```

The official registry does not host this server's code or container image. It stores metadata in root [`server.json`](../server.json), including the server name, repository, stdio transport, and the Docker Hub image reference.

The package entry uses OCI:

```json
{
  "registryType": "oci",
  "identifier": "docker.io/igmarin/rails-agent-skills-mcp:VERSION",
  "transport": {
    "type": "stdio"
  }
}
```

For OCI packages, do not add a package-level `version` field. The MCP Registry expects the package version to be encoded in the image tag inside `identifier`.

The Docker image must include this ownership label:

```dockerfile
LABEL io.modelcontextprotocol.server.name="io.github.igmarin/rails-agent-skills-mcp"
```

You can verify the local image metadata with:

```bash
docker build -t rails-agent-skills-mcp:test .
docker image inspect rails-agent-skills-mcp:test --format '{{ index .Config.Labels "io.modelcontextprotocol.server.name" }}'
```

Expected output:

```text
io.github.igmarin/rails-agent-skills-mcp
```

---

## Cloudflare Streamable HTTP MCP

The repository also includes a hosted Streamable HTTP MCP server under [`../cloudflare_mcp`](../cloudflare_mcp). It is separate from this Ruby stdio server and exists for hosted registries and clients that need a public HTTPS MCP URL.

Use this URL for Smithery or any MCP client that supports Streamable HTTP:

```text
https://rails-agent-skills-mcp.ismael-marin.workers.dev/mcp
```

Useful public checks:

```text
Health: https://rails-agent-skills-mcp.ismael-marin.workers.dev/health
Server card: https://rails-agent-skills-mcp.ismael-marin.workers.dev/.well-known/mcp/server-card.json
```

The Cloudflare Worker is deployed by `.github/workflows/cloudflare-mcp-deploy.yml` after validation. It requires `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN` repository secrets.

---

## Release and Publishing Flow

Normal pushes to `main` publish the Docker `latest` image and deploy the Cloudflare Worker when `cloudflare_mcp/**` changes. They do **not** publish a new MCP Registry version.

Release tags publish immutable versioned artifacts:

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

That tag triggers `.github/workflows/docker-publish.yml`:

1. Build and push `docker.io/igmarin/rails-agent-skills-mcp:X.Y.Z`.
2. Rewrite root `server.json` so `version` is `X.Y.Z` and the OCI `identifier` points at the same Docker image tag.
3. Authenticate to the MCP Registry with GitHub OIDC.
4. Publish `io.github.igmarin/rails-agent-skills-mcp` version `X.Y.Z`.

MCP Registry versions are immutable, so a failed registry publish should be fixed in code and released with a new tag. Do not move or reuse already-pushed release tags unless you intentionally want to rewrite release history.

After a successful release, verify registry discovery with:

```bash
curl "https://registry.modelcontextprotocol.io/v0.1/servers?search=io.github.igmarin/rails-agent-skills-mcp"
```

---

## End-to-end use case

1. You open any Rails project in Windsurf (or Claude Code, Cursor, etc.).
2. The IDE loads this MCP server from its config.
3. You ask: *"I need to add a GraphQL mutation — which skill should I use?"*
4. The agent calls `tools/call list_skills` if it needs to discover available skill names and routing descriptions.
5. The agent calls `tools/call use_skill` with `skill_name: "implement-graphql"`.
6. The server reads `implement-graphql/SKILL.md` and returns structured metadata plus the full instructions.
7. The agent follows the skill workflow without loading the entire repo into context.

---

## Running tests

```bash
bundle exec rake test
```

Tests are written with Minitest: each file validates real behavior of a service object, not just structure.

---

## Auto-discovery of new skills

`ResourceRegistry` uses explicit topology discovery for `skills/*/*/SKILL.md`, `agents/*/SKILL.md`, supported Tessl tile mirrors, and `docs/**/*.md`. When you add a published agent or doc file in those locations, it appears in `resources/list` on the next server start. Published skills become available through `list_skills` and `use_skill` without any server code changes.

---

## Public registries

This server is listed on:

- [cloudflare.com](https://rails-agent-skills-mcp.ismael-marin.workers.dev/mcp) — submit via their website
- [modelcontextprotocol.io](https://registry.modelcontextprotocol.io/?q=io.github.igmarin%2Frails-agent-skills-mcp) — official MCP Registry metadata for the Docker image
- [Glama](https://glama.ai/mcp/connectors/dev.workers.ismael-marin.rails-agent-skills-mcp/ruby-on-rails-mcp-skills) - Connect via Glama

---

## Contributing

- Follow TDD: write the failing test first, then the implementation.
- Service objects live in `lib/mcp_skills/` and must be independently testable (no `MCP::Server` dependency in unit tests).
- All MCP protocol behavior is handled by the `mcp` gem — do not reimplement wire format in service objects.
