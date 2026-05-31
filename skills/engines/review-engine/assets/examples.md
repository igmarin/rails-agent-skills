# review-engine examples

## Complete answer.md Example

Below is a complete, high-scoring engine review artifact. Use this structure
as a template — adapt findings and verification output to the actual engine.

---

### Short Plan

1. Inspect `lib/notifications_engine/engine.rb` for namespace isolation and initializer safety.
2. Check host-app integration points — flag direct host constant references.
3. Verify initialization reload behavior (`config.to_prepare`, `ActiveSupport.on_load`).
4. Audit migration/generator install flow for destructive or irreversible changes.
5. Confirm `spec/dummy/` exists and exercises the engine mount point.
6. Summarize findings by severity (HIGH → MEDIUM → LOW).

---

### Findings

#### HIGH

| # | Area | File | Risk | Smallest Credible Fix |
|---|------|------|------|-----------------------|
| H1 | Host integration | `app/services/notifications_engine/notifier.rb:14` | Direct reference to `::User` couples engine to host model — breaks in any host without a `User` class | Replace with `NotificationsEngine.config.user_class.constantize.find(id)` and add `config.user_class = "User"` default |
| H2 | Init / reload | `lib/notifications_engine/engine.rb:23` | `ActionMailer::Base.include(NotificationsEngine::Mailer)` at require-time — not reload-safe, causes double-include on code reload | Move into `ActiveSupport.on_load(:action_mailer) { include NotificationsEngine::Mailer }` |
| H3 | Namespace | `lib/notifications_engine/engine.rb` | Missing `isolate_namespace NotificationsEngine` — routes and models may collide with host | Add `isolate_namespace NotificationsEngine` inside the Engine class |

#### MEDIUM

| # | Area | File | Risk | Smallest Credible Fix |
|---|------|------|------|-----------------------|
| M1 | Migrations | `lib/generators/notifications_engine/install/install_generator.rb` | Generator copies migrations but does not warn about `remove_column` in `db/migrate/20240301_cleanup.rb` | Add reversible check or document the destructive step in CHANGELOG |
| M2 | Dummy app | `spec/dummy/config/routes.rb` | Engine is mounted but no request specs exercise the mount point | Add at least one request spec that hits a mounted engine route |

#### LOW

| # | Area | File | Risk | Smallest Credible Fix |
|---|------|------|------|-----------------------|
| L1 | File layout | `app/models/notifications_engine/` | Two models define methods outside the `NotificationsEngine` module | Move into properly namespaced classes |

---

### Verification Commands

```bash
# Namespace isolation
grep -r "isolate_namespace" lib/

# Host constant leakage
grep -rn "::User\|::Admin\|::ApplicationRecord" app/ lib/ --include="*.rb"

# Initialization reload safety
grep -r "ActiveSupport.on_load" lib/
grep -r "config.to_prepare" lib/
grep -r "initializer" lib/notifications_engine/engine.rb

# Destructive migrations
grep -R "remove_column\|drop_table\|change_column" db/migrate lib/**/db/migrate

# Dummy app presence and mount
test -d spec/dummy && echo "dummy app exists" || echo "MISSING dummy app"
grep "mount" spec/dummy/config/routes.rb
```

---

### Open Assumptions

1. Engine targets Rails 7.0+ — `isolate_namespace` behavior is stable across these versions.
2. No multi-database configuration — migrations assumed to target the primary database.
3. Host app uses Devise for authentication — engine should not assume this; use config seam.

### Recommended Next Steps

1. Fix H1–H3 before merge (all HIGH findings block release).
2. Add request spec coverage for M2 before next release.
3. Chain to `test-engine` skill for dummy app coverage improvements.

---

## Single Finding (JSON Format)

Use the schema `review-engine/assets/finding-schema.json` for structured findings output.

```json
{
  "severity": "high",
  "area": "host-app integration",
  "file": "lib/my_engine/engine.rb",
  "line": 42,
  "risk": "Engine initializer depends on host's `Admin` constant leading to load-order failures",
  "recommendation": "Replace direct constant reference with a configurable adapter or use `defined?` checks and document host contract",
  "proof_of_concept": "Raise occurs during engine load when host doesn't define Admin: NameError: uninitialized constant Admin"
}
```