---
name: migration
license: MIT
description: >
  Orchestrates safe database migration loop: plan migration for safety → create migration with rollback → test in development → deploy to staging → deploy to production with monitoring. Use when adding columns, creating tables, modifying indexes, or any database schema changes. Trigger: database migration, schema change, add column, create table, modify index, rails migration.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when performing database schema changes with production safety"
  phases: "Phase 1: Migration Planning, Phase 2: Development Testing, Phase 3: Staging Deployment, Phase 4: Production Deployment"
  hard_gates: "Migration Safety Check, Development Tests Pass, Staging Verification, Production Monitoring"
  dependencies: "review-migration"
  keywords: rails, migration, database, schema, postgresql, production, deployment
---
# Migration Agent

Orchestrates safe database migration development and deployment with comprehensive safety checks, testing at each stage, and production monitoring to ensure schema changes don't cause downtime or data loss.

## When to Use

- Adding new database columns or tables
- Modifying existing database schema
- Creating or dropping indexes
- Changing column types or constraints
- Any database schema changes requiring migration
- Production database modifications

## Agent Phases

### Phase 1: Migration Planning

**Objective:** Plan migration for production safety before writing any code.

**Steps:**
1. **skills/infrastructure/review-migration** — Review migration for safety risks:
   - Lock behavior analysis
   - Rollback strategy verification
   - Data migration requirements
   - Performance impact assessment
2. **Migration Strategy** — Choose safe deployment approach:
   - Expand-contract for column changes (add nullable column → backfill data → add constraint → remove default)
   - Phased rollout for table changes
   - Zero-downtime deployment pattern

**Migration Safety Guidelines:**
- Never add non-nullable columns with default values to large tables
- Never remove columns used in production code
- Never change column types without data migration
- Always include down migration for rollback
- Always test migrations on production-like data volume

**HARD GATE — Migration Safety Check:**
- Migration reviewed for safety risks
- Rollback strategy defined and tested
- Performance impact assessed (run EXPLAIN on queries)
- Data migration requirements identified
- Deployment order planned (if multiple migrations)

**If gate fails:** Migration is unsafe for production. Redesign approach.

**Example Migration Safety Review:**
```markdown
# Migration Safety Review: Add status to orders table

## Change Type
Add non-nullable column with default value

## Risk Assessment
- **Table Size:** 1.2M rows (HIGH RISK)
- **Lock Duration:** Estimated 45 seconds (HIGH RISK)
- **Rollback:** Possible but slow (REQUIRES CAREFUL PLANNING)

## Recommended Approach
1. Add nullable column without default
2. Backfill data in batches of 10K rows
3. Add default value and constraint
4. Set column to NOT NULL

## Rollback Strategy
Remove column (requires downtime to avoid orphaned data)
```

---

### Phase 2: Development Testing

**Objective:** Create migration and test thoroughly in development environment.

**Steps:**
1. **Create Migration** — Generate migration with safe approach:
   ```bash
   rails generate migration AddStatusToOrders status:string
   ```
2. **Implement Migration** — Write up and down migrations with safety:
   ```ruby
   class AddStatusToOrders < ActiveRecord::Migration[7.1]
     def change
       add_column :orders, :status, :string, default: 'pending', null: false
       add_index :orders, :status
     end
   end
   ```
3. **Test Migration** — Verify migration works correctly:
   ```bash
   rails db:migrate
   rails db:rollback
   rails db:migrate  # Verify re-runnable
   ```
4. **Test Application** — Ensure app works with new schema:
   - Run relevant tests
   - Verify models use new schema correctly
   - Check for N+1 queries introduced by new columns

**HARD GATE — Development Tests:**
- Migration runs successfully
- Rollback works correctly
- Migration is re-runnable (idempotent)
- Application tests pass with new schema
- No N+1 queries introduced
- Performance acceptable

**If gate fails:** Fix migration or application code before proceeding.

**Example Test Commands:**
```bash
# Migration testing
rails db:migrate
rails db:rollback
rails db:migrate

# Application testing
bundle exec rspec spec/models/order_spec.rb
bundle exec rspec spec/features/order_flow_spec.rb

# Performance testing
bundle exec rake db:performance_test
```

---

### Phase 3: Staging Deployment

**Objective:** Deploy migration to staging environment to verify on production-like data.

**Steps:**
1. **Staging Preparation** — Ensure staging is production-like:
   - Database similar size to production
   - Recent production data snapshot
   - Same PostgreSQL version as production
2. **Deploy Migration** — Run migration on staging:
   ```bash
   rails db:migrate RAILS_ENV=staging
   ```
3. **Verify Deployment** — Confirm staging works correctly:
   - Run smoke tests against staging API
   - Verify application performance
   - Check for errors in logs
4. **Test Rollback** — Verify rollback works on staging:
   ```bash
   rails db:rollback RAILS_ENV=staging
   ```

**HARD GATE — Staging Verification:**
- Migration runs successfully on staging
- Application works correctly with new schema
- Performance acceptable on staging data volume
- Rollback tested and works correctly
- No errors in application logs
- Smoke tests pass

**If gate fails:** Do not proceed to production. Fix issues and re-deploy to staging.

**Example Staging Verification:**
```bash
# Deploy to staging
RAILS_ENV=staging bundle exec rails db:migrate

# Smoke tests
curl https://staging.example.com/api/orders
curl https://staging.example.com/api/health

# Check logs
heroku logs --tail --app staging-app

# Test rollback
RAILS_ENV=staging bundle exec rails db:rollback
```

---

### Phase 4: Production Deployment

**Objective:** Deploy migration to production with monitoring and rollback readiness.

**Steps:**
1. **Pre-Deployment Checklist** — Verify production readiness:
   - Migration reviewed and approved
   - Staging deployment successful
   - Rollback plan documented
   - Team notified of deployment window
   - Monitoring tools configured
2. **Deploy Migration** — Run migration on production:
   ```bash
   rails db:migrate RAILS_ENV=production
   ```
3. **Monitor Deployment** — Watch for issues:
   - Monitor application logs for errors
   - Check database performance metrics
   - Monitor API response times
   - Verify application health checks
4. **Verify Success** — Confirm production working correctly:
   - Run smoke tests against production
   - Check key user journeys work
   - Verify no increase in error rates
5. **Prepare Rollback** — Have rollback ready if issues detected:
   ```bash
   # Ready to execute if needed
   rails db:rollback RAILS_ENV=production
   ```

**HARD GATE — Production Monitoring:**
- Migration completes without errors
- Application remains responsive during migration
- No increase in error rates
- Performance metrics acceptable
- Smoke tests pass
- Rollback plan ready if needed

**If gate fails:** IMMEDIATE rollback if critical issues detected. Investigate and redeploy.

**Example Production Deployment:**
```bash
# Deploy during low-traffic window (e.g., 2 AM Sunday)
RAILS_ENV=production bundle exec rails db:migrate

# Monitor logs in real-time
tail -f log/production.log

# Check application health
curl https://api.example.com/health

# Monitor database performance
heroku pg:diagnostics --app production-app

# Smoke tests
curl https://api.example.com/api/orders
curl https://api.example.com/api/users

# If issues detected, rollback immediately
# RAILS_ENV=production bundle exec rails db:rollback
```

---

## Integration

| Predecessor | This Agent | Successor |
|-------------|---------------|-----------|
| review-migration | migration | deployment |
| load-context | migration | production-monitoring |
| None (standalone) | migration | quality |

## When to Use This vs. Individual Skills

- **Full migration lifecycle (all phases):** Use this agent
- **Only review migration safety:** Use `review-migration`
- **Only create migration:** Use `rails generate migration`
- **Not sure about migration safety:** Use `review-migration` first

## HARD-GATE: Production Safety

**NEVER deploy migration to production before:**
- Migration reviewed for safety risks
- Rollback strategy defined and tested
- Development tests pass
- Staging deployment successful
- Production monitoring configured
- Rollback plan ready

**If gate fails:** Migration is not production-ready. Address safety concerns.

## Error Recovery

**If migration fails in production:**
1. **Immediate Assessment** — Check error logs and database state
2. **Rollback Decision** — If critical, rollback immediately
3. **Investigation** — Analyze failure root cause
4. **Fix Migration** — Redesign migration to address failure
5. **Re-deploy** — Go through full agent cycle again

**If rollback fails:**
1. **Emergency Response** — Engage DBA immediately
2. **Manual Intervention** — Manual database surgery may be required
3. **Post-Incident** — Document failure and improve process

## Output Style

```markdown
# Migration Deployment Report — [Date]

## Migration
- **File:** db/migrate/20240514000001_add_status_to_orders.rb
- **Change:** Add status column to orders table
- **Approach:** Expand-contract pattern

## Safety Review
- **Risk Assessment:** Medium (table size: 1.2M rows)
- **Rollback Strategy:** Remove column (requires downtime)
- **Performance Impact:** Acceptable (< 5 seconds)
- **Status:** ✓ APPROVED

## Development Testing
- **Migration:** ✓ PASS
- **Rollback:** ✓ PASS
- **Re-runnable:** ✓ PASS
- **Application Tests:** ✓ PASS (485/485)
- **Performance:** ✓ ACCEPTABLE

## Staging Deployment
- **Migration:** ✓ PASS
- **Application Health:** ✓ PASS
- **Smoke Tests:** ✓ PASS
- **Rollback Test:** ✓ PASS
- **Status:** ✓ VERIFIED

## Production Deployment
- **Migration Time:** 2024-05-14 02:00 UTC
- **Duration:** 4.2 seconds
- **Application Health:** ✓ PASS
- **Error Rate:** No increase
- **Performance:** ✓ ACCEPTABLE
- **Smoke Tests:** ✓ PASS
- **Rollback Ready:** ✓ YES

## Status
**DEPLOYMENT SUCCESSFUL** — Production migration completed without issues
```

## Anti-Patterns to Avoid

- **Unsafe migrations:** Never add non-nullable columns with defaults to large tables
- **No rollback:** Never deploy migration without tested rollback strategy
- **Skipping staging:** Always test on production-like data before production
- **Ignoring performance:** Always assess performance impact of migrations
- **Blind deployment:** Never deploy without monitoring and rollback readiness
- **Schema drift:** Ensure all environments use same schema version