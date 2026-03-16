# Installing my-cursor-skills for Codex

Enable Rails skills in Codex via native skill discovery. Clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url> ~/.codex/my-cursor-skills
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/my-cursor-skills ~/.agents/skills/my-cursor-skills
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\my-cursor-skills" "$env:USERPROFILE\.codex\my-cursor-skills"
   ```

3. **Restart Codex** to discover the skills.

## Verify

```bash
ls -la ~/.agents/skills/my-cursor-skills
```

You should see a symlink pointing to your skills directory.

## Updating

```bash
cd ~/.codex/my-cursor-skills && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/my-cursor-skills
```

Optionally delete the clone: `rm -rf ~/.codex/my-cursor-skills`.
