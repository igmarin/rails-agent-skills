---
name: review-migration
license: MIT
description: >
  Use when planning or reviewing production database migrations, adding columns, indexes,
  constraints, backfills, renames, table rewrites, or concurrent operations. Covers phased
  rollouts, lock behavior, rollback strategy, strong_migrations compliance, and deployment
  ordering for schema changes.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Review Migration

Use this skill when schema changes must be safe in real environments.

## Quick Reference

| Operation | Safe Pattern |
|-----------|-------------|
| Add column | Nullable first, backfill later, enforce NOT NULL last |
| Add index (large table) | `algorithm: :concurrent` (PG) / `:inplace` (MySQL) |
| Backfill data | Batch job, not inside migration transaction |
| Rename column | Add new, copy data, migrate callers, drop old |
| Add NOT NULL | After backfill confirms all rows have values |
| Add foreign key | After cleaning orphaned records |
| Remove column | Remove code references first, then drop column |

## HARD-GATE

```text
DO NOT combine schema change and data backfill in one migration.
DO NOT add NOT NULL on a column that hasn't been fully backfilled.
DO NOT drop columns before all code references are removed.
```

## Core Process

1. Identify the database and table-size risk.
2. Separate schema changes from data backfills.
3. Check lock behavior for indexes, constraints, defaults, and rewrites.
4. Plan deployment order between app code and migration code.
5. Plan rollback or forward-fix strategy.

## Safe Patterns

- Deploy code that tolerates both old and new schemas during transitions.
- Add indexes concurrently when supported.
- Backfill in batches outside a long transaction when volume is high.
- Use multi-step rollouts for renames, type changes, and unique constraints.
- For every step, state the expected lock or table-rewrite risk explicitly; if negligible, say why.

If the project uses `strong_migrations`, follow it. If it does not, apply the same safety rules manually.

**Type change rollout pattern:**

```text
1. Add the new typed column as nullable.
2. Dual-write old and new columns from application code.
3. Backfill in batches outside the migration transaction.
4. Read from the new column after parity checks pass.
5. Stop writing the old column, then drop it in a later deploy.
```

## Code Examples

**Concurrent index (Rails / PostgreSQL):**

```ruby
# Migration file
class AddIndexOnUsersEmail < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :users, :email, algorithm: :concurrently
  end
end
```

> `disable_ddl_transaction!` is required — concurrent index creation cannot run inside a transaction.

**Nullable-first column with deferred NOT NULL (Rails):**

```ruby
# Step 1 — Deploy: add nullable column
class AddConfirmedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :confirmed_at, :datetime
  end
end

# Step 2 — Backfill outside migration (background job or script)
User.in_batches(of: 1_000) do |batch|
  batch.update_all(confirmed_at: Time.current)
end

# Step 3 — Deploy: enforce NOT NULL only after all rows are filled
class ChangeConfirmedAtNotNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :confirmed_at, false
  end
end
```

**Batch backfill snippet (safe for large tables):**

```ruby
# Run this as a Rake task or background job, never inside a migration transaction
BATCH_SIZE = 1_000

User.where(confirmed_at: nil).in_batches(of: BATCH_SIZE) do |batch|
  batch.update_all(confirmed_at: Time.current)
  sleep(0.05) # throttle to reduce replication lag
end
```

## Common Mistakes

| Mistake | Why It Fails | Fix |
|---------|-------------|-----|
| `add_column :t, :col, :string, null: false, default: "x"` on large table | Full table rewrite + lock (PG < 11) | Add nullable, backfill, then add NOT NULL |
| `add_index :users, :email` without `algorithm: :concurrently` | Acquires share lock; blocks writes | Add `algorithm: :concurrently` + `disable_ddl_transaction!` |
| Backfill inside migration with `User.update_all(...)` | Holds transaction lock for full duration | Move backfill to a separate job |
| Rename column directly | Breaks running app during deploy | Add new column, dual-write, migrate callers, drop old |
| Drop column while code still reads it | Runtime `unknown attribute` errors | Remove code references first, deploy, then drop |

## Output Style

1. List risks first.
2. For each risk include: Migration step, likely failure mode, explicit lock/table-rewrite risk, safer rollout, rollback or forward-fix note.
3. Ensure backwards compatibility steps are included.
4. Always include explicit phased patterns for column renames, type changes, and unique constraints. If one does not apply, mark it `Not applicable` and explain why.
5. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **code-review** | When reviewing PRs that include migrations |
| **implement-background-job** | For backfill jobs that run after schema change |
| **security-check** | When migrations expose or move sensitive data |

## Additional Resources

- [PATTERNS.md](PATTERNS.md) — Advanced migration patterns for complex schema operations
