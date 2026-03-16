# Implementation Guide

Step-by-step instructions for installing and configuring my-cursor-skills on each supported platform.

## Cursor

Cursor loads skills from `~/.cursor/skills/` (or `~/.cursor/skills-cursor/`). Each subdirectory with a `SKILL.md` file is discovered automatically.

### Option A: Symlink (recommended for development)

```bash
ln -s /path/to/my-cursor-skills ~/.cursor/skills-cursor/my-cursor-skills
```

### Option B: Clone directly

```bash
git clone <your-repo-url> ~/.cursor/skills-cursor/my-cursor-skills
```

### Verification

1. Open Cursor
2. Skills should appear in the skills panel
3. Test by asking: "Review this Rails controller" — the agent should invoke `rails-code-review`

### Updating

If using a symlink, pull the latest from the repo:

```bash
cd /path/to/my-cursor-skills && git pull
```

---

## Codex (OpenAI)

Codex discovers skills from `~/.agents/skills/`. Each subdirectory with a `SKILL.md` file is loaded.

### Installation

```bash
# 1. Clone the repository
git clone <your-repo-url> ~/.codex/my-cursor-skills

# 2. Create the skills symlink
mkdir -p ~/.agents/skills
ln -s ~/.codex/my-cursor-skills ~/.agents/skills/my-cursor-skills

# 3. Restart Codex
```

### Windows (PowerShell)

```powershell
git clone <your-repo-url> "$env:USERPROFILE\.codex\my-cursor-skills"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\my-cursor-skills" "$env:USERPROFILE\.codex\my-cursor-skills"
```

### Verification

```bash
ls -la ~/.agents/skills/my-cursor-skills
```

### Updating

```bash
cd ~/.codex/my-cursor-skills && git pull
```

---

## Claude Code

Claude Code uses a plugin system. Skills are loaded from plugin directories.

### Installation

```bash
# From Claude Code CLI:
/add-plugin /path/to/my-cursor-skills
```

Or manually reference the plugin in your Claude Code configuration.

### How It Works

- `.claude-plugin/plugin.json` declares the plugin metadata
- Skill directories with `SKILL.md` files are discovered
- The `hooks/session-start` script injects skill awareness at session start

### Verification

Start a new Claude Code session. The session-start hook should load the `using-my-skills` skill automatically.

---

## Session Start Hook

All platforms support a session-start hook that automatically injects the `using-my-skills` bootstrap skill at the beginning of each session. This helps the AI agent discover available skills without manual intervention.

The hook is defined in `hooks/hooks.json` and executed by `hooks/session-start`.

### How It Works

1. When a session starts, the hook reads `using-my-skills/SKILL.md`
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
| Skills not invoked | Check that `using-my-skills` is loaded at session start |
| Wrong platform behavior | Verify the correct plugin config for your platform |
