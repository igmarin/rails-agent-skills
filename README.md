# Rails Agent Skills

Rails-specific implementation and review procedures for the `ruby-rails` project profile. The shared `work-router` selects one entry; invoke a specialist directly when the task is clear.

## Entries

- `rails-feature`: ordinary behavior changes.
- `rails-review`: diff reviews, with optional security, architecture, or migration checks.
- `rails-maintenance`: setup, conventions, refactoring, and engine maintenance.

Specialist cards remain available for Rails APIs, authorization, background jobs, GraphQL, Hotwire, migrations, performance, security, engines, setup, and tests. Ruby language patterns live in `ruby-core-skills`.

## Migration

| Old persona | Use |
|---|---|
| `tdd`, `bug-fix` | `rails-feature` |
| `review` | `rails-review` |
| `quality`, `setup` | `rails-maintenance` |
| `background-job`, `graphql` | `implement-background-job`, `implement-graphql` |
| `migration` | `rails-feature` to implement; `review-migration` to review production risk |
| `engine` | `create-engine`, `review-engine`, or `release-engine` for that task |
| `rails-agent-skills` catalog | shared `work-router` |

Run `scripts/validate-skills.sh` after registry or profile changes.
