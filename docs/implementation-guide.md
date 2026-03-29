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

Claude Code uses a plugin system. Skills are loaded from plugin directories and `CLAUDE.md` is automatically included in every session as additional context.

### Claude Code Installation

```bash
# Install from a local path (registers globally — no copy, no reinstall needed):
/add-plugin ~/skills/rails-agent-skills
```

> **Note:** `/plugin install <name>` is for marketplace plugins only. For local paths, use `/add-plugin`.

### Testing locally without installing

```bash
claude --plugin-dir ~/skills/rails-agent-skills
```

This loads the plugin for that session only, without permanently installing it. Useful for testing changes.

### Claude Code How It Works

Two complementary layers provide skill awareness:

1. **`CLAUDE.md`** (root of this repo) — Loaded automatically by Claude Code in every session. Contains the full skills catalog and TDD mandate. Works without any hook configuration.
2. **`hooks/session-start`** — Injects the bootstrap `SKILL.md` as additional context at session start (requires plugin installation).

The `CLAUDE.md` is the primary fallback and ensures skills are always available even if the hook does not fire.

### Claude Code Verification

Start a new Claude Code session. Claude should mention available Rails skills or respond to skill-related prompts without explicit instruction.

---

## Session Start Hook

The session-start hook automatically injects the `rails-agent-skills` bootstrap skill at the beginning of each session. Defined in `hooks/hooks.json`, executed by `hooks/session-start`.

### Session Hook Mechanics

1. When a session starts, the hook reads `rails-agent-skills/SKILL.md`
2. The content is escaped and injected as additional context
3. The AI agent knows which skills are available and when to invoke them

### Platform Differences

| Platform | Context injection field |
|----------|------------------------|
| Claude Code | `hookSpecificOutput.additionalContext` |
| Cursor / Others | `additional_context` |

### Claude Code — CLAUDE.md Fallback

Claude Code also loads `CLAUDE.md` automatically in every session, independently of the hook. This means skills are always available even if:
- The plugin has not been installed yet
- The hook fails to execute
- The session does not trigger `SessionStart`

Both mechanisms work together: `CLAUDE.md` provides baseline context; the hook injects the full bootstrap skill for richer discovery.

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Skills not discovered (Claude Code) | `CLAUDE.md` should still provide context — verify it is present at the repo root |
| Skills not discovered (Cursor/Codex) | Check symlink path and restart the platform |
| Hook not firing | Verify `hooks/session-start` is executable: `chmod +x hooks/session-start` |
| Plugin not recognized (Claude Code) | Use `/plugin install` (not `/add-plugin`); verify `.claude-plugin/plugin.json` has `"hooks"` and `"skills"` fields |
| Skills not invoked | Start a new session after installation; check `CLAUDE.md` is present |
| Wrong platform behavior | Verify the correct plugin config for your platform (`.claude-plugin/` vs `.cursor-plugin/`) |
