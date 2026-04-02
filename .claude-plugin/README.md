# Rails Agent Skills Plugin

This directory contains the standardized plugin configuration for Rails Agent Skills across multiple AI tools and LLMs.

## Supported Platforms

| Platform | Version | Config | Installation |
|----------|---------|--------|--------------|
| **Claude Code** | Latest | `plugin.json` | Marketplace discovery (see below) |
| **Cursor** | Latest | `.cursor-plugin/plugin.json` | Symlink to `~/.cursor/skills/` |
| **Windsurf** | Latest | `.windsurf-plugin/plugin.json` | Symlink to `~/.windsurf/skills/` |
| **Codex** | Latest | `.codex/` | See `.codex/INSTALL.md` |

## Architecture

- **`plugin.json`** — Unified plugin manifest (Claude Code standard)
- **`marketplace.json`** — Claude Code marketplace registry
- Cross-platform compatibility through standardized `name`, `displayName`, `version`, `keywords`

## File Structure

```
rails-agent-skills/
├── .claude-plugin/
│   ├── plugin.json          # Claude Code plugin manifest
│   ├── marketplace.json     # Claude Code marketplace registry
│   └── README.md           # This file
├── .cursor-plugin/
│   └── plugin.json         # Cursor-compatible plugin manifest
├── .windsurf-plugin/
│   └── plugin.json         # Windsurf-compatible plugin manifest
└── [skill directories]/
    └── SKILL.md
```

## Installation by Platform

### Claude Code

**Option 1: Global (Recommended)**

Register the marketplace in `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "rails-agent-skills": {
      "source": "directory",
      "path": "/path/to/rails-agent-skills"
    }
  }
}
```

Then skills appear in `/skills` menu automatically.

**Option 2: GitHub Remote**

Register directly from GitHub (once published):

```json
{
  "extraKnownMarketplaces": {
    "rails-agent-skills": {
      "source": "github",
      "repo": "igmarin/rails-agent-skills",
      "path": ".claude-plugin"
    }
  }
}
```

### Cursor

```bash
ln -s /path/to/rails-agent-skills ~/.cursor/skills/rails-agent-skills
```

Or clone directly:

```bash
git clone https://github.com/igmarin/rails-agent-skills.git ~/.cursor/skills/rails-agent-skills
```

### Windsurf

```bash
ln -s /path/to/rails-agent-skills ~/.windsurf/skills/rails-agent-skills
```

Or clone directly:

```bash
git clone https://github.com/igmarin/rails-agent-skills.git ~/.windsurf/skills/rails-agent-skills
```

### Codex

See [`.codex/INSTALL.md`](../.codex/INSTALL.md)

## Key Differences Across Tools

| Feature | Claude Code | Cursor | Windsurf | Codex |
|---------|-------------|--------|----------|-------|
| Discovery | Marketplace registry | Skills directory | Skills directory | Custom handler |
| Auto-update | Via marketplace | Manual git pull | Manual git pull | Manual |
| Hooks support | Yes | Yes | Yes | Limited |
| YAML frontmatter | Yes | Yes | Yes | Yes |

## Standardization

All platform-specific configs are kept in sync:

- ✅ Same `name`: `rails-agent-skills`
- ✅ Same `version`: Updated together
- ✅ Same `keywords`: Searchable across platforms
- ✅ Same `license`: MIT
- ✅ Same `author`: igmarin
- ✅ Same `skills` path: `./` (platform root)

## Updating

When updating skills:

1. Modify skill files in the project root
2. Update `version` in **all** `plugin.json` files (Claude, Cursor, Windsurf)
3. Git commit and push
4. Users can pull updates:
   - **Claude Code**: Marketplace auto-discovers (if using GitHub source)
   - **Cursor/Windsurf**: Run `git pull` in the skills directory
   - **Codex**: Follow `.codex/INSTALL.md` update process

## LLM Compatibility

These skills are designed to work with:

- **Claude 3.5 Sonnet** (recommended for Claude Code)
- **Claude 3.5 Haiku** (for lighter tasks)
- **Claude 4** (when available)
- **Other compatible LLMs** (Cursor, Windsurf with their default models)

Each skill includes guidance on which models work best for that workflow.
