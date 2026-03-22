# Implementation Guide — Rails Agent Skills

Step-by-step install and verification for the **`rails-agent-skills`** repository on each supported platform.

- **What this library is:** [README](../README.md)
- **How to chain skills:** [workflow-guide.md](workflow-guide.md)
- **Skill file conventions:** [architecture.md](architecture.md)

## Cursor

Cursor loads skills from `~/.cursor/skills/` (or `~/.cursor/skills-cursor/`). Each subdirectory with a `SKILL.md` file is discovered automatically.

### Option A: Symlink (recommended for development)

```bash
ln -s /path/to/rails-agent-skills ~/.cursor/skills-cursor/rails-agent-skills
```

### Option B: Clone directly

```bash
git clone <your-repo-url> ~/.cursor/skills-cursor/rails-agent-skills
```

### Cursor Verification

1. Open Cursor
2. Skills should appear in the skills panel
3. Test by asking: "Review this Rails controller" — the agent should invoke `rails-code-review`

### Cursor Updating

If using a symlink, pull the latest from the repo:

```bash
cd /path/to/rails-agent-skills && git pull
```

---

## Codex (OpenAI)

Codex discovers skills from `~/.codex/skills/`. Each subdirectory with a `SKILL.md` file is loaded.

### Installation

```bash
# 1. Clone the repository
mkdir -p ~/.codex/skills
git clone <your-repo-url> ~/.codex/skills/rails-agent-skills

# 2. Restart Codex
```

### Windows (PowerShell)

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.codex\skills"
git clone <your-repo-url> "$env:USERPROFILE\.codex\skills\rails-agent-skills"
```

### Codex Verification

```bash
ls -la ~/.codex/skills/rails-agent-skills
```

### Codex Updating

```bash
cd ~/.codex/skills/rails-agent-skills && git pull
```

---

## Claude Code

Claude Code uses a plugin system. Skills are loaded from plugin directories.

### Claude Code Installation

```bash
# From Claude Code CLI:
/add-plugin /path/to/rails-agent-skills
```

Or manually reference the plugin in your Claude Code configuration.

### Claude Code How It Works

- `.claude-plugin/plugin.json` declares the plugin metadata
- Skill directories with `SKILL.md` files are discovered
- The `hooks/session-start` script injects skill awareness at session start

### Claude Code Verification

Start a new Claude Code session. The session-start hook should load the `rails-agent-skills` bootstrap skill automatically.

---

## Session Start Hook

All platforms support a session-start hook that automatically injects the `rails-agent-skills` bootstrap skill at the beginning of each session. This helps the AI agent discover available skills without manual intervention.

The hook is defined in `hooks/hooks.json` and executed by `hooks/session-start`.

### Session Hook Mechanics

1. When a session starts, the hook reads `rails-agent-skills/SKILL.md`
2. The content is injected as additional context
3. The AI agent now knows which skills are available and when to invoke them

### Platform Differences

| Platform | Context injection field |
|----------|----------------------|
| Claude Code | `hookSpecificOutput.additionalContext` |
| Cursor / Others | `additional_context` |

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Skills not discovered | Check symlink path and restart the platform |
| Hook not firing | Verify `hooks/session-start` is executable (`chmod +x`) |
| Skills not invoked | Check that `rails-agent-skills` is loaded at session start |
| Wrong platform behavior | Verify the correct plugin config for your platform |
