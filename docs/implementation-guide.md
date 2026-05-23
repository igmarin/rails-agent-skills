# Implementation Guide — Rails Agent Skills

Step-by-step install and verification for the **`rails-agent-skills`** repository.

- **What this library is:** [README](../README.md)
- **How to chain skills:** [agent-guide.md](agent-guide.md)
- **Skill file conventions:** [architecture.md](architecture.md)

The recommended way to use this library is by installing it as an Agent Skill using the standard `npx skills` CLI.

---

## Agent Skills Installation (Recommended)

The main goal of this repository is to provide atomic skills that are easy to install. You can install the entire catalog using:

```bash
npx skills add igmarin/rails-agent-skills
```

This will download the skills and make them available to any skills-compatible agent (e.g., Cursor, Claude Code, Goose, OpenCode, Gemini CLI, etc.).

---

## Alternative: The Symlink Approach (Legacy)

If you cannot use the `npx skills` command, you can symlink the `CLAUDE.md` or `GEMINI.md` files to your agent's global configuration directory.

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
| Gemini CLI | Handled via `~/.gemini/GEMINI.md` |
