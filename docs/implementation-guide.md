# Implementation Guide — Rails Agent Skills

Step-by-step install and verification for the **`rails-agent-skills`** repository on each supported platform.

- **What this library is:** [README](../README.md)
- **How to chain skills:** [workflow-guide.md](workflow-guide.md)
- **Skill file conventions:** [architecture.md](architecture.md)

There are two primary methods for making skills available to your AI assistant:

1. **The Symlink Approach** — Quick to set up; the AI always reads the latest version from the repo.
2. **The MCP Server Approach** — Recommended for large libraries; provides on-demand access, saving tokens and enabling real-time updates.

---

## Claude Code

Claude Code discovers skills from `~/.claude/skills/` and loads `~/.claude/CLAUDE.md` automatically in every session. Two symlinks are required.

### Installation

```bash
# 1. Clone the repo (once per machine)
git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills

# 2. Global instructions (loaded in every session, across all projects)
ln -sf ~/skills/rails-agent-skills/CLAUDE.md ~/.claude/CLAUDE.md

# 3. Skills (adds each skill individually — safe, preserves any existing skills)
mkdir -p ~/.claude/skills
for dir in ~/skills/rails-agent-skills/*/; do
  ln -sf "$dir" ~/.claude/skills/
done
```

Open a new session and run `/skills` — all skills will appear.

### Updating

```bash
cd ~/skills/rails-agent-skills && git pull

# Add any new skills that were added to the repo
for dir in ~/skills/rails-agent-skills/*/; do
  ln -sf "$dir" ~/.claude/skills/
done
```

### New machine

Repeat the installation steps above.

---

## Cursor & Windsurf

### Method 1: Symlink (Quick Start)

```bash
# Clone the repo (once per machine)
git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills

# Cursor
ln -s ~/skills/rails-agent-skills ~/.cursor/skills/rails-agent-skills

# Windsurf
ln -s ~/skills/rails-agent-skills ~/.windsurf/skills/rails-agent-skills
```

Restart your IDE for changes to take effect.

**Updating:** `git pull` in the repo — symlinks reflect changes immediately.

### Method 2: MCP Server (Recommended)

1. Set up the Ruby MCP server — see [MCP Server README](../mcp_server/README.md).
2. Open IDE settings (`Cmd+,`) → search "Model Context Protocol Servers".
3. Add a new server with the command:
   ```bash
   ruby ~/skills/rails-agent-skills/mcp_server/server.rb
   ```
4. Restart your IDE.

---

## Gemini CLI

```bash
# Clone the repo (once per machine)
git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills

# Symlink GEMINI.md to the Gemini CLI global config directory
ln -s ~/skills/rails-agent-skills/GEMINI.md ~/.gemini/GEMINI.md
```

Requires starting a new session to pick up changes.

---

## Codex (OpenAI)

```bash
# Clone directly into Codex skills
mkdir -p ~/.codex/skills
git clone git@github.com:igmarin/rails-agent-skills.git ~/.codex/skills/rails-agent-skills

# Or symlink if you already have the repo cloned
ln -s ~/skills/rails-agent-skills ~/.codex/skills/rails-agent-skills
```

**Windows (PowerShell):**

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.codex\skills"
git clone git@github.com:igmarin/rails-agent-skills.git "$env:USERPROFILE\.codex\skills\rails-agent-skills"
```

**Updating:** `cd ~/.codex/skills/rails-agent-skills && git pull`

---

## JetBrains RubyMine

The MCP Server is the recommended method for RubyMine. The symlink approach is not reliably supported for custom skill injection.

1. Set up the Ruby MCP server — see [MCP Server README](../mcp_server/README.md).
2. Open RubyMine settings (`Cmd+,`) → navigate to Tools → AI Assistant → Model Context Protocol.
3. Add a new MCP server with the command:
   ```bash
   ruby ~/skills/rails-agent-skills/mcp_server/server.rb
   ```
4. Restart RubyMine.

---

## Session Start Hook

The session-start hook automatically injects the `rails-skills-orchestrator` bootstrap skill at the beginning of each session. Defined in `hooks/hooks.json`, executed by `hooks/session-start`.

For Claude Code, `~/.claude/CLAUDE.md` (symlinked from this repo) is the primary mechanism. The session-start hook is retained for completeness and future marketplace support, but is not required for local installs.

| Platform | Context injection field |
|----------|------------------------|
| Claude Code | `hookSpecificOutput.additionalContext` |
| Cursor / Others | `additional_context` |

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| `/skills` shows "No skills found" (Claude Code) | Re-run the `for dir` loop to create per-skill symlinks in `~/.claude/skills/` |
| Skills not available (Claude Code) | Verify symlink: `ls -la ~/.claude/CLAUDE.md` |
| Skills not discovered (Cursor/Codex) | Check symlink/path and restart the platform |
| Hook not firing | Verify `hooks/session-start` is executable: `chmod +x hooks/session-start` |
| Changes not picked up (Claude Code) | Run `git pull` in the repo and start a new session |
| Changes not picked up (Cursor) | Run `git pull` in the repo; symlinks reflect changes immediately |
| Wrong platform behavior | Verify the correct plugin config for your platform (`.claude-plugin/` vs `.cursor-plugin/`) |
