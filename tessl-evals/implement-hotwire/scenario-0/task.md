# Implement Hotwire Task

## Problem

A Rails team needs help with a task in this area:

Creates Hotwire UIs with progressive enhancement — ALWAYS start with plain HTML, NEVER use Turbo Frames for full page navigation, output MUST include Verification: verify degraded mode without JavaScript (disable JS in browser or run `rails test:system` with Capybara `:rack_test` driver, checklist must confirm forms submit/links navigate/data persists after reload), plus system/browser checks for frame/stream/Stimulus behavior, use Turbo Frames for replacing page sections, Turbo Streams for broadcasting, Stimulus only when beyond Turbo.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
