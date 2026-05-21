# Calling Skills and Agents

Rails Agent Skills can be invoked in three distinct ways depending on the environment, the user's intent, and the level of autonomy desired. Understanding the syntax and context for each method ensures you get the most out of your AI coding assistant.

## The 3 Execution Contexts

| Method | Syntax | Best For | Level of Autonomy |
|--------|--------|----------|-------------------|
| **MCP `use_skill`** | Autonomous tool call by the agent | Autonomous, multi-step agent workflows where the LLM dynamically loads context | High |
| **Chat Commands** | `@skill-name` or `/skill-name` | Explicitly forcing the agent to follow a specific skill's instructions immediately | Low (Human-directed) |
| **CLI (`gh skill` / `tessl` / `skills.sh`)** | `gh skill install ...` or `npx skills add ...` | Local installation, pinning versions, or running CI/CD evaluations | Manual setup/execution |

---

### 1. MCP (`use_skill`)

When the repository is connected to an MCP (Model Context Protocol) client (like Claude Desktop, Cursor, or Windsurf), the AI agent has access to the library's metadata. 

**Syntax:**
The LLM automatically invokes the `use_skill(skill_name)` tool based on the user's prompt. 
*Example User Prompt:* "Please review this pull request for security vulnerabilities."
*Agent Action:* Autonomously loads `security-check` and `code-review`.

**When to use:**
Use this method when you want the agent to autonomously figure out which skills apply to your broad request. It minimizes the cognitive load on the developer.

---

### 2. Chat Commands (`@` or `/`)

In environments that support explicit context injection (like Cursor, Windsurf, or Gemini CLI), developers can force the agent to use a specific skill immediately.

**Syntax:**
- **Cursor / Windsurf:** `@skill-name` (e.g., `@write-tests Can you add coverage for the new order model?`)
- **Gemini CLI:** `/activate_skill skill-name` or `/skill-name`

**When to use:**
Use this when you know exactly which skill or agent you want to follow and want to bypass the autonomous discovery phase. It is highly effective for enforcing strict constraints (like the "Tests Gate Implementation" rule) on specific tasks.
---

### 3. CLI (`gh skill` / `tessl` / `skills.sh`)

For manual installation, version pinning, or evaluation, you can interact with the skills directly via the terminal.

**Syntax:**
*Installing via GitHub CLI:*
```bash
# Install a specific skill for the current project
gh skill install igmarin/rails-agent-skills code-review --scope project
```

*Installing via skills.sh:*
```bash
# Add the entire library to your workspace
npx skills add igmarin/rails-agent-skills
```

*Evaluating via Tessl:*
```bash
# Run evaluations to measure skill quality
tessl eval run .
```

**When to use:**
Use the CLI method when setting up a new project, configuring CI/CD pipelines, or when you need to pin your workspace to a specific release tag of a skill for reproducible results.

---

## Using Agents

Agents are orchestrated multi-step processes that chain multiple skills together. They are the primary way to execute complex Rails development tasks with built-in quality gates and TDD enforcement.

### MCP Agent Usage

When connected via MCP, agents are discovered and executed using two dedicated tools:

**Discover available agents:**
```text
list_agents
```
Returns metadata for all 9 agents: tdd, quality, review, setup, engine, bug-fix, graphql, migration, background-job

**Load and execute a specific agent:**
```text
use_agent(agent_name: "tdd")
```
Returns the full agent instructions with phases, hard gates, and skill chaining

**Example MCP interaction:**
- User: "I need to implement a new feature following TDD best practices"
- Agent: Calls `list_agents` → identifies `tdd` agent → calls `use_agent("tdd")` → executes the full TDD cycle with gates

### Chat Command Agent Usage

In environments that support chat commands, you can invoke agents directly:

**Cursor / Windsurf:**
```text
@tdd Implement the user authentication feature
```

**Gemini CLI:**
```text
/activate_agent tdd
```

### Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **tdd** | Full TDD feature cycle | Implementing new features with test-first discipline |
| **quality** | Code quality sweep | Pre-PR quality checks, refactoring, documentation |
| **review** | Systematic PR review | Code review, security audits, architecture review |
| **setup** | Project setup and CI/CD | New project setup, environment configuration |
| **engine** | Rails engine development | Creating, testing, and releasing Rails engines |
| **bug-fix** | Bug resolution | Fixing reported bugs with TDD discipline |
| **graphql** | GraphQL API development | Building GraphQL APIs with domain modeling |
| **migration** | Database migration | Safe database schema changes and deployment |
| **background-job** | Background job implementation | Robust async processing with retry strategies |

### Agent Advantages

Compared to ad-hoc skill chaining, agents provide:

- **Hard Gates:** Enforced checkpoints (e.g., "tests must pass before implementation")
- **TDD Enforcement:** Built-in test-first discipline for code changes
- **Consistent Structure:** Standardized phases and error recovery
- **Integration Points:** Clear predecessor/successor relationships
- **Production Readiness:** Security checks, monitoring, and deployment guidance