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

## Gemini CLI

Gemini CLI loads `GEMINI.md` automatically if it exists in the workspace or via global configuration.

### Gemini CLI Installation

```bash
# 1. Clone the repo (once per machine)
git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills

# 2. Symlink GEMINI.md to the Gemini CLI global config directory
# (Note: path may vary depending on your OS and Gemini CLI version)
ln -s ~/skills/rails-agent-skills/GEMINI.md ~/.gemini/GEMINI.md
```

Open a new Gemini CLI session and the skills are available in any project.

### Gemini CLI Updating

```bash
cd ~/skills/rails-agent-skills && git pull
# → open a new session, changes are picked up automatically via the symlink
```

---

## Claude Code

Claude Code loads `~/.claude/CLAUDE.md` automatically in **every session, across all projects**. A symlink from that path to the `CLAUDE.md` in this repo is all that is needed — no plugin commands required.

### Claude Code Installation

```bash
# 1. Clone the repo (once per machine)
git clone git@github.com:igmarin/rails-agent-skills.git ~/skills/rails-agent-skills

# 2. Symlink CLAUDE.md to the Claude Code global config directory
ln -s ~/skills/rails-agent-skills/CLAUDE.md ~/.claude/CLAUDE.md
```

That's it. Open a new Claude Code session and the skills are available in any project.

### Claude Code Updating

```bash
cd ~/skills/rails-agent-skills && git pull
# → open a new session, changes are picked up automatically via the symlink
```

### New machine

Repeat the two steps above: `git clone` + `ln -s`.

### Session testing (optional)

To test changes without touching the global config:

```bash
claude --plugin-dir ~/skills/rails-agent-skills
```

This loads the plugin for that session only.

### Claude Code How It Works

`~/.claude/CLAUDE.md` is Claude Code's global memory file — it is injected into every session before the conversation starts, regardless of the current project directory. The symlink means the skills catalog and TDD mandate are always present without any manual step per project or per session.

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

### Claude Code — CLAUDE.md as Primary Mechanism

For Claude Code, `~/.claude/CLAUDE.md` (symlinked from this repo) is the primary and recommended mechanism. The session-start hook is retained in the repo for completeness and future marketplace support, but is not required for local installs.

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Skills not available (Claude Code) | Verify `~/.claude/CLAUDE.md` is a valid symlink: `ls -la ~/.claude/CLAUDE.md` |
| Skills not discovered (Cursor/Codex) | Check symlink/path and restart the platform |
| Hook not firing | Verify `hooks/session-start` is executable: `chmod +x hooks/session-start` |
| Changes not picked up (Claude Code) | Run `git pull` in the repo and start a new session |
| Changes not picked up (Cursor) | Run `git pull` in the repo; symlinks reflect changes immediately |
| Wrong platform behavior | Verify the correct plugin config for your platform (`.claude-plugin/` vs `.cursor-plugin/`) |
