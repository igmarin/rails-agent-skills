---
name: migration
type: persona
tags: [personas]
license: MIT
description: >
  Orchestrates safe database migration with hard gates: plan migration assessing lock behavior, rollback strategy, and performance impact with EXPLAIN → use expand-contract for column changes (add nullable→backfill→enforce NOT NULL), never combine schema change and data backfill in one migration → test idempotent migrate/rollback/re-migrate cycle and full suite in development → verify on staging with production-like data → deploy to production with monitoring and rollback readiness; phases planning→development testing→staging→production. Use when adding columns, creating tables, modifying indexes, or any database schema changes. Trigger: database migration, schema change, add column, create table, modify index, rails migration.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when performing database schema changes with production safety"
  phases: "Phase 1: Migration Planning, Phase 2: Development Testing, Phase 3: Staging Deployment, Phase 4: Production Deployment"
  hard_gates: "Migration Safety Check, Development Tests Pass, Staging Verification, Production Monitoring"
  dependencies:
    - source: self
      skills: [review-migration, load-context]
  keywords: rails, migration, database, schema, postgresql, production, deployment
---
# Migration Persona

Safe database migration orchestration with hard gates, testing at each stage, and production monitoring to ensure schema changes don't cause downtime or data loss.

## Key Safety Rules

- Use **expand-contract** for column changes on large tables; never add non-nullable columns with a default in a single `ALTER TABLE`
- Always include a `down` migration; always test against production-like data volumes; never skip staging

---

## Phase 1: Migration Planning

1. **Invoke `skills/infrastructure/review-migration`** — assesses lock behavior, rollback strategy, backfill requirements, and performance impact (`EXPLAIN` queries). If unavailable, perform these checks manually: identify table lock duration, confirm a rollback path exists, enumerate backfill steps, and run `EXPLAIN ANALYZE` on affected queries.
2. **Choose deployment pattern:**
   - *Expand-contract* for column changes: add nullable column → batch backfill → add constraint → remove old default
   - *Phased rollout* for table-level changes
   - Zero-downtime deployment for everything touching large tables

**HARD GATE — Migration Safety Check:**
- [ ] Safety risks reviewed; rollback strategy defined and tested
- [ ] Performance impact assessed with `EXPLAIN`
- [ ] Backfill requirements and deployment order identified

**If gate fails:** Redesign the migration approach before proceeding.

---

## Phase 2: Development Testing

1. **Generate migration:**
   ```bash
   rails generate migration AddStatusToOrders status:string
   ```
2. **Implement using safe expand-contract pattern** (each step runs as a **separate migration** in production; shown together here for development clarity):
   ```ruby
   class AddStatusToOrders < ActiveRecord::Migration[7.1]
     def up
       add_column :orders, :status, :string
       add_index :orders, :status
       Order.in_batches(of: 10_000).update_all(status: 'pending')
       change_column_null :orders, :status, false
       change_column_default :orders, :status, 'pending'
     end

     def down
       remove_column :orders, :status
     end
   end
   ```
3. **Test migration cycle:**
   ```bash
   rails db:migrate && rails db:rollback && rails db:migrate
   bundle exec rspec spec/models/order_spec.rb spec/features/order_flow_spec.rb
   ```

**HARD GATE — Development Tests:**
- [ ] Migration runs, rolls back, and re-runs successfully (idempotent)
- [ ] Application tests pass; no N+1 queries introduced

**If gate fails:** Fix migration or application code before proceeding.

---

## Phase 3: Staging Deployment

**Prerequisites:** Staging DB must match production in size, data shape, and PostgreSQL version.

```bash
RAILS_ENV=staging bundle exec rails db:migrate
curl https://staging.example.local/api/health
curl https://staging.example.local/api/orders
RAILS_ENV=staging bundle exec rails db:rollback
```

**HARD GATE — Staging Verification:**
- [ ] Migration completes without errors on staging data volume
- [ ] Smoke tests pass; error rate unchanged; rollback confirmed working

**If gate fails:** Do not proceed to production. Fix and re-deploy to staging.

---

## Phase 4: Production Deployment

**Pre-deployment checklist:**
- Staging deployment verified
- Team notified; deployment window scheduled (prefer low-traffic, e.g. 2 AM Sunday)
- Rollback command ready to execute

```bash
RAILS_ENV=production bundle exec rails db:migrate

# Monitor in real-time
tail -f log/production.log
heroku pg:diagnostics --app production-app

# Smoke tests
curl https://api.example.local/health
curl https://api.example.local/api/orders

# Rollback if needed
# RAILS_ENV=production bundle exec rails db:rollback
```

**HARD GATE — Production Monitoring (first 15 minutes):**
- [ ] Migration completes without errors
- [ ] Error rate < 0.1% (no spike from baseline)
- [ ] p99 API latency < 500 ms
- [ ] DB CPU and lock wait times within normal range
- [ ] Smoke tests pass

**If gate fails:** Roll back immediately if error rate or latency exceeds thresholds. Investigate before redeploying.

---

## Error Recovery

**Migration fails in production:**
1. Assess error logs and database state
2. If critical: rollback immediately (`rails db:rollback RAILS_ENV=production`)
3. Investigate root cause → redesign migration → restart full cycle

**Rollback itself fails:**
1. Engage DBA for manual intervention
2. Document incident and improve migration process

---

## Output Style

When completing a migration cycle, produce a **Migration Report** covering: **Plan** (change description, pattern used, rollback strategy, lock assessment), **Development** (migration file path, idempotent cycle result, test suite result, N+1 check), **Staging** (migration time, smoke test result, rollback tested), and **Production** (deploy timestamp, post-migration error rate vs baseline, p99 latency, monitoring result).

---

## Anti-Patterns to Avoid

- **Non-reversible migrations:** Every migration MUST have a working `down` method.
- **Missing EXPLAIN:** Always run `EXPLAIN ANALYZE` on queries affected by schema changes before deploying.
- **Deploying during peak traffic:** Schedule migrations during low-traffic windows.
