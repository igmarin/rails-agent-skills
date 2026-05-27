# Load Context Task

## Problem

A Rails team needs help with a task in this area:

Use before writing code, tests, or PRDs in a Rails project — DO NOT propose code until a Context Summary is posted: load minimum context (read `db/schema.rb` + `config/routes.rb` + `Gemfile.lock`, if `rails-ai-bridge` is running use `get_project_context` tool to retrieve project structure/routes/models/dependencies), then load one neighbor of each kind by grepping for similar files like `grep -r "class.*Controller" app/controllers`, if requirements conflict or specs and code drift produce a Confusion Block first, cite files read (path:line), re-check context when scope changes mid-conversation.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
