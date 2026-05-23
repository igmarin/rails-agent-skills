---
name: load-context
license: MIT
description: >
  Use before writing code, tests, or PRDs in a Rails project to load the minimum
  context needed to make correct decisions. Inspects `db/schema.rb`,
  `config/routes.rb`, neighboring models, factories, specs, engine boundaries,
  and `Gemfile.lock` to surface existing patterns, naming conventions, and
  gotchas. Produces a concise context summary before any code is proposed, and
  a confusion-management block when requirements are ambiguous or specs and
  code have drifted. Trigger words: load context, gather context, context
  engineering, read the code first, before I code, existing patterns, project
  conventions, where is this defined, ambiguous requirements, spec vs code
  drift, unclear spec, missing requirements, what does the codebase already
  use, match existing style.
metadata:
  user-invocable: "true"
  version: 1.0.0
---
# Load Context

## Quick Reference

| Area | What to check |
|------|---------------|
| Schema | `db/schema.rb` for tables and columns |
| Routes | `config/routes.rb` for surrounding paths |
| Deps | `Gemfile.lock` for Rails version and gems |
| Neighbors | Closest existing sibling file to match style |
| Specs | Closest existing test for behavior drift |

## HARD-GATE

```text
DO NOT propose code, specs, PRDs, or task lists until the Context Summary is posted.
DO NOT silently resolve ambiguity — if requirements conflict or specs and code disagree, post a Confusion Block first.
DO NOT load the entire repo — use targeted reads (schema, routes, one neighbor of each kind).
ALWAYS cite the files you read (path:line where possible) so the user can verify.
ALWAYS re-check context when the user's request changes scope mid-conversation.
```

## Core Process

Load minimum context before any code, spec, or PRD in an existing Rails codebase. A fifteen-second read of `db/schema.rb`, `config/routes.rb`, and one neighbor saves a full retry.

### Process

1. **Scope the change:** In one sentence, name the Rails layer touched (controller, model, service, job, engine, view/Turbo, migration, API, GraphQL).
2. **Load baseline Rails context:** Read at minimum:
   - `db/schema.rb` — tables and columns involved (grep by table name)
   - `config/routes.rb` — routes that border the change
   - `Gemfile.lock` — confirm Rails version + domain gems (sidekiq, pundit, rspec, rails-i18n, graphql, etc.)
3. **Load one neighbor of each kind:** For each Rails layer touched, open the nearest sibling that already solves a similar problem — a comparable controller, service, spec, factory. Use grep to find: `grep -r "class.*Controller" app/controllers`, `grep -r "class.*Service" app/services`, etc.
   Include the grep command used for each neighbor search in the final Context Summary notes.
4. **Detect drift:** If there is an existing spec for the area, compare what it asserts vs what the code currently does. Drift is a red flag — document it.
5. **Post the Context Summary:** Before any proposal, output the template below (see Output Style).
6. **Handle ambiguity:** If steps 2–4 surface a conflict (two patterns used, specs contradict code, missing requirement, unclear boundary), produce a Confusion Block:

```text
### Confusion Block
- Conflict: <what conflicts — e.g., spec asserts X but code does Y>
- Options: <list the options with their tradeoffs>
- Recommendation: <state which option and why, or ask user to choose>
```

Do not pick silently.
7. **Hand off:** With context loaded, proceed to the next skill (`plan-tests`, `apply-stack-conventions`, etc.). The Context Summary travels with the task.

### Pitfalls

| Pitfall | What to do |
|---------|------------|
| Generic "the model, the controller" language | Name the class and file — generic language is the symptom of skipped context |
| Citing paths without line numbers | Use `path:line` when referencing a method, class, or association |
| Ignoring engine boundaries | Name the engine and its host integration points when a mounted engine is touched |
| Ignoring spec/code drift | A passing stale spec is worse than a missing spec — call it out in Confusion |

## Extended Resources

- [EXAMPLES.md](EXAMPLES.md)
- [references/confusion-management.md](references/confusion-management.md)
- [references/context-sources.md](references/context-sources.md)

## Output Style

1. **Context Summary**: Every invocation MUST produce a Context Summary in this exact shape:
   ```text
   ### Context Summary
   - Scope: <one line — Rails layer and nearest class/file area>
   - Rails version: <from Gemfile.lock>
   - Relevant tables: <table names from db/schema.rb, columns that matter>
   - Relevant routes: <resource/member routes from config/routes.rb>
   - Nearest pattern: <path:line — one existing file that solves a similar problem>
   - Nearest spec: <path:line — existing spec for this area (or NONE)>
   - Engine boundary: <engine name or N/A>
   - Gotchas: <domain gem quirks, enum mappings, polymorphic edges, counter caches, soft-delete, single-table inheritance — only list if present>
   - Confusion: <NONE, or a one-line pointer to the Confusion Block below>
   ```
2. **One neighbor per layer**: Do not dump 5 similar files; pick the closest match and name it.
3. **Discovery commands**: List the grep/rg commands used to find the nearest controller, service, spec, factory, or sibling file. If a command was not run, state why.
4. **Facts only, no code**: The summary lists facts about the codebase, not proposed implementation.
5. **Hand-off line**: End the reply with: `Context loaded. Next: <skill-name> — <one-line reason>.`
6. **Language**: Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **plan-tests** | Nearest spec in the summary usually reveals the right first failing spec |
| **triage-bug** / **refactor-code** | Context precedes reproduction or characterization tests |
| **review-architecture** / **define-domain-language** | When context reveals boundary or naming drift |
