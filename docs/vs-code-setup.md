# VS Code + AI Extensions Setup

Rails Agent Skills are designed to work with AI-powered VS Code extensions. This guide covers setup with popular LLM extensions.

## Supported Extensions

| Extension | LLM Provider | Setup Complexity | Notes |
|-----------|--------------|------------------|-------|
| [Cline](https://github.com/cline/cline) | Claude, OpenAI, Anthropic | Simple | Recommended for Claude models |
| [Aider](https://aider.chat) | Claude, OpenAI, Local | Medium | Terminal-based, git-aware |
| [GitHub Copilot](https://github.com/features/copilot) | OpenAI (via GitHub) | Simple | Limited skill discovery |
| [Continue](https://continue.dev) | Multiple LLMs | Medium | Highly configurable |

## Installation: Cline (Recommended)

Cline is the best integration for Rails Agent Skills because it:
- Natively supports Claude models (Opus, Sonnet, Haiku)
- Reads custom tool definitions
- Integrates with VS Code's workspace

### Step 1: Install Cline Extension

In VS Code:
1. Open **Extensions** (Cmd+Shift+X on macOS, Ctrl+Shift+X on Linux/Windows)
2. Search for **"Cline"**
3. Install by Saoudrizwan

### Step 2: Configure Cline Settings

Create or edit `.vscode/settings.json` in your project:

```json
{
  "[cline]": {
    "apiProvider": "anthropic",
    "apiKey": "${env:ANTHROPIC_API_KEY}",
    "model": "claude-3-5-sonnet-20241022"
  }
}
```

Or configure via VS Code settings UI:
1. Open **VS Code Settings** (Cmd+, on macOS)
2. Search for **"Cline"**
3. Set:
   - **API Provider**: `anthropic`
   - **Model**: `claude-3-5-sonnet-20241022` (or your preferred Claude model)
   - **API Key**: Point to your `ANTHROPIC_API_KEY` environment variable

### Step 3: Make Skills Discoverable

Cline reads skill definitions from the workspace. Create `.vscode/cline.config.json`:

```json
{
  "skillsPath": "./",
  "skillPattern": "**/SKILL.md",
  "workflowsPath": "./docs/",
  "workflowPattern": "workflow-*.md",
  "customTools": []
}
```

Alternatively, you can manually invoke skills by name in Cline's chat:
- `/create-prd` — Start a new feature with PRD
- `/rails-tdd-slices` — Begin TDD workflow
- `/rails-code-review` — Self-review Rails code
- `/yard-documentation` — Generate YARD docs

### Step 4: Set Environment Variables

Ensure Cline can access your Anthropic API key:

```bash
# In your shell profile (.zshrc, .bashrc, etc.)
export ANTHROPIC_API_KEY="your-api-key-here"
```

Or create a `.env` file in your project root (add to `.gitignore`):

```
ANTHROPIC_API_KEY=your-api-key-here
```

## Installation: Continue (Advanced)

Continue provides a highly configurable AI IDE experience with multi-model support.

### Step 1: Install Continue

In VS Code:
1. Open **Extensions** (Cmd+Shift+X)
2. Search for **"Continue"**
3. Install the official extension

### Step 2: Configure Continue

Edit `~/.continue/config.json`:

```json
{
  "models": [
    {
      "title": "Claude Sonnet",
      "provider": "anthropic",
      "model": "claude-3-5-sonnet-20241022",
      "apiKey": "${ANTHROPIC_API_KEY}",
      "contextLength": 200000
    }
  ],
  "slashCommands": [
    {
      "name": "create-prd",
      "description": "Plan a feature with PRD",
      "prompt": "Use the create-prd skill to outline feature requirements"
    }
  ],
  "customTools": []
}
```

### Step 3: Enable Custom Skills

In VS Code, open the Continue panel and add your skills directory:

1. Click the **Continue icon** (bottom left)
2. Click **Settings** (gear icon)
3. Under **Custom Tools**, add:
   ```json
   {
     "name": "rails-agent-skills",
     "source": "file",
     "path": "${workspaceFolder}/",
     "pattern": "**/SKILL.md"
   }
   ```

## Installation: Aider (Terminal-based)

Aider is git-aware and perfect for Rails development workflows.

### Step 1: Install Aider

```bash
pip install aider-chat
```

### Step 2: Configure Aider

Create `~/.aider.conf.yml`:

```yaml
model: claude-3-5-sonnet-20241022
api-key: ${ANTHROPIC_API_KEY}
auto-commit: true
auto-test: true
dark-mode: true

# Reference your skills
custom-instructions: |
  You have access to Rails Agent Skills.
  Use these patterns when relevant:
  - /rspec-best-practices for testing
  - /rails-code-review for code quality
  - /rails-tdd-slices for TDD workflows
```

### Step 3: Invoke Skills

```bash
# In your Rails project directory
aider

# Then in the aider prompt, reference skills:
# /rails-tdd-slices what's the next failing test for user auth?
# /rails-code-review review the authentication controller
```

## Workflow Example: Cline + Rails Agent Skills

### Scenario: Implement User Authentication

1. **Open Cline** in VS Code (Cmd+L)

2. **Start with PRD**:
   ```
   /create-prd Implement JWT-based authentication for API endpoints
   ```

3. **Get implementation plan**:
   ```
   /generate-tasks Based on the PRD above
   ```

4. **Begin TDD loop**:
   ```
   /rails-tdd-slices What's the first failing spec for JWT auth?
   ```

5. **Code and review**:
   ```
   /rails-code-review Review my authentication controller
   ```

6. **Document**:
   ```
   /yard-documentation Generate docs for the Auth service
   ```

## Environment Setup

### macOS / Linux

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Anthropic API
export ANTHROPIC_API_KEY="sk-ant-..."

# Optional: Set default Claude model
export CLAUDE_MODEL="claude-3-5-sonnet-20241022"
```

### Windows (PowerShell)

```powershell
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "sk-ant-...", "User")
```

### VS Code Workspace

Create `.vscode/settings.json` in your project:

```json
{
  "cline.apiKey": "${env:ANTHROPIC_API_KEY}",
  "cline.model": "claude-3-5-sonnet-20241022",
  "files.exclude": {
    ".vscode/settings.json": false
  }
}
```

## Troubleshooting

### Cline Can't Find Skills

1. Ensure `.vscode/cline.config.json` exists in your project root
2. Verify `skillsPath` points to the correct directory (usually `./`)
3. Check that SKILL.md files have proper YAML frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Brief description
   type: workflow
   ---
   ```

### API Key Not Working

1. Verify `ANTHROPIC_API_KEY` is set:
   ```bash
   echo $ANTHROPIC_API_KEY
   ```

2. Test with `curl`:
   ```bash
   curl https://api.anthropic.com/v1/messages \
     -H "x-api-key: $ANTHROPIC_API_KEY" \
     -H "content-type: application/json" \
     -d '{"model": "claude-3-5-sonnet-20241022", "max_tokens": 10, "messages": [{"role": "user", "content": "hi"}]}'
   ```

3. If using `.env`, ensure extension reads it (Cline does by default)

### Skills Not Invoking

1. Check skill invocation syntax: `/skill-name-with-dashes`
2. Verify skill exists: `ls **/SKILL.md`
3. In Cline, skills must be referenced explicitly — they don't auto-activate
4. For automatic skill detection, use Continue or aider with custom instructions

## Recommended Setup

For Rails development with Rails Agent Skills:

**Best single extension**: **Cline** + Claude Sonnet
- Lowest setup friction
- Full Claude API access
- Native skill detection
- Git integration

**Best flexibility**: **Continue** + multiple models
- Switch between Claude, OpenAI, local LLMs
- Fine-grained tool customization
- Better for experimentation

**Best for CLI developers**: **Aider**
- Terminal-native (no GUI overhead)
- Git-aware context (includes diffs, staged changes)
- Auto-commit after fixes
- Excellent for TDD workflows

## Next Steps

1. **Choose an extension** (Cline recommended)
2. **Install and configure** with your API key
3. **Open a Rails project** and try:
   ```
   /rails-tdd-slices What's our first failing test?
   ```
4. **Follow the skill workflows** as suggested by the AI

See [docs/workflow-guide.md](workflow-guide.md) for full workflow chains and checkpoints.
