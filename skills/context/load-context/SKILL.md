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

## Output Style

### Context Summary Template

Post this block before proposing any code, spec, or PRD:

```text
### Context Summary
**Rails layer:** <controller | model | service | job | engine | view/Turbo | migration | API | GraphQL>
**Files read:**
  - <path>:<line-range> — <one-line finding>
  - <path>:<line-range> — <one-line finding>
  - (repeat for each file)
**Neighbor patterns found:**
  - <layer>: <file path> — <key convention or pattern observed>
  - (repeat per layer)
**Gemfile notes:** Rails <version>; relevant gems: <list>
**Drift detected:** <none | description of spec-vs-code mismatch>
**Ambiguities:** <none | list any unresolved conflicts — triggers a Confusion Block>
**Next step:** <plan-tests | apply-stack-conventions | write migration | etc.>
```

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| Grep returns hundreds of matches | Narrow by subdirectory or add a more specific class-name prefix; never read more than one representative neighbor per layer |
| `db/schema.rb` is absent | Check for `db/structure.sql` (used when `config.active_record.schema_format = :sql`); parse the relevant CREATE TABLE block instead |
| Multiple engines present | Scope all reads to the engine directory that owns the change; note the engine boundary explicitly in the Context Summary |
| No specs exist for the area | Document "no spec coverage" in the Context Summary; treat the code as the sole source of truth and flag the gap |
| Neighbor file is the file being changed | Skip self-reference; pick the next closest sibling that is not the target file |
| Requirements change mid-conversation | Re-run steps 1–4 for the new scope and post a fresh Context Summary before continuing |

## Additional Resources

- [EXAMPLES.md](EXAMPLES.md) — Worked examples showing Context Summary and Confusion Block templates
- [references/confusion-management.md](references/confusion-management.md) — Detailed guidance on handling ambiguity
- [references/context-sources.md](references/context-sources.md) — Comprehensive list of context sources by Rails layer
