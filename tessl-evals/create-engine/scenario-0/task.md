# Create Engine Task

## Problem

A Rails team needs help with a task in this area:

Use when creating a Rails engine — choose engine type (Plain/Railtie/Engine/Mountable) before coding, engine should have narrow purpose and small public API, use `isolate_namespace` + `.configure` block, host model references MUST be configurable strings never hard-coded, NEVER auto-apply migrations at boot, initializers must be idempotent and reload-safe, verify dummy app exists (`ls spec/dummy`), verify dummy app boots, confirm no hard-coded host constants, confirm no migration auto-apply patterns, create minimal engine structure first (checkpoint: `bundle exec rake` must pass), define the host-app contract, write minimum integration coverage through the dummy app.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
