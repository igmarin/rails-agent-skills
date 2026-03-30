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

## How to Invoke a Skill or Workflow

Skills are triggered by describing the task in natural language. Codex reads the skill catalog and loads the right skill automatically.

**Patterns that work:**

```
"I want to add a GraphQL mutation for creating orders"
"Review this PR diff for me"
"I got feedback on my PR, help me respond"
"There's a bug where orders are showing the wrong total"
"Create a PRD for this feature"
"Run the TDD Feature Loop for this task"
```

**Name a workflow directly** when you want the full chain:
```
"Follow the Bug Fix workflow for this issue"
"Start with rails-tdd-slices, I need to add a new endpoint"
"Do a DDD-first design for this feature"
```

The TDD Feature Loop pauses at two checkpoints — **Test Feedback** and **Implementation Proposal** — waiting for your approval before continuing. You can skip either by saying "looks good, proceed" or "skip the proposal, go ahead."

See [docs/workflow-guide.md](../docs/workflow-guide.md) for the full list of workflows and invocation examples.

## Updating

```bash
cd ~/.codex/skills/rails-agent-skills && git pull
```

Skills update directly in the installed Codex skills directory.

## Uninstalling

```bash
rm -rf ~/.codex/skills/rails-agent-skills
```
