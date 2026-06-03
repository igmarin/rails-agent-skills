---
name: review-migration
type: atomic
license: MIT
description: >
  Use when reviewing production database migrations, performing a migration safety review, planning zero-downtime migration, or deploying database changes safely. Reviews phased rollouts, lock behavior, rollback strategy, strong_migrations, and deployment ordering. Enforces: add nullable-first then backfill then enforce NOT NULL; add indexes with `algorithm: :concurrently` + `disable_ddl_transaction!` on large tables; backfill in batches outside migration transaction; check lock behavior for indexes/constraints/defaults/rewrites; use multi-step rollouts for renames/type changes/unique constraints; deploy code tolerating both old and new schemas during transitions. Never combines schema change and data backfill in one migration, never adds NOT NULL before backfill completes, never drops columns before removing all code references.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Review Migration

Use this skill when schema changes must be safe in real environments.

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

If the project uses `strong_migrations`, follow it. If it does not, apply the same safety rules manually.

## Safe Patterns and Common Mistakes

| Operation | Safe Pattern | Common Mistake | Why It Fails |
|-----------|-------------|----------------|------|
| Add column | Nullable first, backfill later, enforce NOT NULL last | `add_column :t, :col, :string, null: false, default: "x"` on large table | Table rewrite + lock (PG < 11) |
| Add index (large table) | `algorithm: :concurrently` (PG) / `:inplace` (MySQL) + `disable_ddl_transaction!` | `add_index :users, :email` without `algorithm: :concurrently` | Share lock blocks writes |
| Backfill data | Batch job outside migration transaction, throttle to reduce replication lag | `User.update_all(...)` inside migration | Transaction lock held for full duration |
| Rename column | Add new, copy data, migrate callers, drop old | Rename column directly | Breaks running app during deploy |
| Add NOT NULL | After backfill confirms all rows have values | Enforce NOT NULL before backfill completes | Fails or locks on rows missing values |
| Add foreign key | After cleaning orphaned records | Add FK without cleaning orphans | Constraint violation at migration time |
| Remove column | Remove code references first, deploy, then drop column | Drop column while code still reads it | `unknown attribute` errors at runtime |

For every step, state the expected lock or table-rewrite risk explicitly; if negligible, say why.

Deploy code that tolerates both old and new schemas during transitions.

## Code Examples

**Concurrent index (Rails / PostgreSQL):**

```ruby
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
  sleep(0.05) # throttle to reduce replication lag
end

# Step 3 — Deploy: enforce NOT NULL only after all rows are filled
class ChangeConfirmedAtNotNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :confirmed_at, false
  end
end
```

**Type change rollout (5-step):**

1. Add new typed column as nullable.
2. Dual-write old and new columns from application code.
3. Backfill in batches outside the migration transaction.
4. Read from new column after parity checks pass.
5. Stop writing old column, then drop it in a later deploy.

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
