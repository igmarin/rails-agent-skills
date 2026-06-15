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

## Key Safety Rules

- Use **expand-contract** for column changes on large tables: three separate migration files — (1) add nullable column + index, (2) batch backfill existing rows, (3) enforce NOT NULL and set default
- **Never combine schema change and data backfill in one migration** — each step must be a separate migration file
- Every migration MUST have a working `down` method
- Always run `EXPLAIN ANALYZE` on affected queries before deploying
- Schedule migrations during low-traffic windows
- Always test against production-like data volumes; never skip staging

---

## Phase 1: Migration Planning

1. **Invoke `skills/infrastructure/review-migration`** — assesses lock behavior, rollback strategy, backfill requirements, and performance impact (`EXPLAIN` queries). If unavailable, perform these checks manually: identify table lock duration, confirm a rollback path exists, enumerate backfill steps, and run `EXPLAIN ANALYZE` on affected queries.
2. **Choose deployment pattern:** expand-contract for column changes (see Key Safety Rules above), phased rollout for table-level changes, zero-downtime for everything touching large tables.

**HARD GATE — Migration Safety Check:**
- [ ] Safety risks reviewed; rollback strategy defined and tested
- [ ] Performance impact assessed with `EXPLAIN`
- [ ] Backfill requirements and deployment order identified

**If gate fails:** Redesign the migration approach before proceeding.

---

## Phase 2: Development Testing

Deploy each migration file independently.

**Test each migration in sequence:**
```bash
rails db:migrate && rails db:rollback && rails db:migrate
bundle exec rspec spec/models/order_spec.rb spec/features/order_flow_spec.rb
```

**HARD GATE — Development Tests:**
- [ ] Each migration runs, rolls back, and re-runs successfully (idempotent)
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
- Team notified; deployment window scheduled during low-traffic period
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

## Output Style

When completing a migration cycle, produce a **Migration Report**:

```
## Migration Report

**Plan**
- Change: <description>
- Pattern: <expand-contract | phased rollout | zero-downtime>
- Rollback strategy: <steps>
- Lock assessment: <duration and type>

**Development**
- Migration file(s): <paths>
- Idempotent cycle: PASS | FAIL
- Test suite: PASS | FAIL
- N+1 check: PASS | FAIL

**Staging**
- Migration time: <duration>
- Smoke tests: PASS | FAIL
- Rollback tested: YES | NO

**Production**
- Deploy timestamp: <datetime>
- Post-migration error rate: <rate> vs baseline <rate>
- p99 latency: <ms>
- Monitoring result: STABLE | ROLLED BACK
```

---

## Error Recovery

**Migration fails in production:**
1. Assess error logs and database state
2. If critical: `RAILS_ENV=production rails db:rollback`
3. Investigate root cause → redesign → restart full cycle from Phase 1

**Rollback itself fails:**
1. Engage DBA for manual intervention
2. Document incident and improve migration process
