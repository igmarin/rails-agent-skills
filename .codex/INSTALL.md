# Installing rails-agent-skills for Codex

Enable Rails skills in Codex via native skill discovery. Clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the repository into Codex skills:**

   ```bash
   mkdir -p ~/.codex/skills
   git clone <your-repo-url> ~/.codex/skills/rails-agent-skills
   ```

   **Windows (PowerShell):**

   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.codex\skills"
   git clone <your-repo-url> "$env:USERPROFILE\.codex\skills\rails-agent-skills"
   ```

2. **Restart Codex** to discover the skills.

## Verify

```bash
ls -la ~/.codex/skills/rails-agent-skills
```

You should see the skill directory under the Codex skills path.

## Updating

```bash
cd ~/.codex/skills/rails-agent-skills && git pull
```

Skills update directly in the installed Codex skills directory.

## Uninstalling

```bash
rm -rf ~/.codex/skills/rails-agent-skills
```
