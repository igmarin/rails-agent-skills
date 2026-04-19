# Rails Context Engineering — Worked Examples

Three concrete scenarios showing the exact shape of a Context Summary, a Confusion Block, and an engine-boundary summary. Use these as templates, not as generic patterns to tweak.

## Example 1 — Happy path: add a field to an existing model

**Task:** Add `fulfilled_at` timestamp to `Order` and expose it in the JSON API.

```text
### Context Summary
- Scope: Order model + Api::V1::OrdersController (JSON serializer)
- Rails version: 7.1.3 (from Gemfile.lock)
- Relevant tables: orders (id, state, placed_at, shipped_at) — db/schema.rb:118-135
- Relevant routes: resources :orders, only: %i[index show update] — config/routes.rb:42
- Nearest pattern: app/models/order.rb:24 (state machine with aasm, timestamp callbacks on transition)
- Nearest spec: spec/models/order_spec.rb:12 (shared context `with a placed order`)
- Engine boundary: N/A
- Gotchas: Order uses aasm; timestamps are set in `after_transition` blocks, not via `touch`. Serializer is Blueprinter (app/blueprints/order_blueprint.rb:8) — not ActiveModelSerializers.
- Confusion: NONE
```

Context loaded. Next: rails-tdd-slices — first failing spec should assert `fulfilled_at` is set on the `ship!` transition.

## Example 2 — Drift: spec and code disagree

**Task:** Fix bug where `User#display_name` returns email instead of full name for users with a profile.

```text
### Context Summary
- Scope: User#display_name (app/models/user.rb:67)
- Rails version: 7.1.3
- Relevant tables: users (email, first_name, last_name), profiles (user_id, display_name_override) — db/schema.rb:201-240
- Relevant routes: N/A (model-level change)
- Nearest pattern: app/models/user.rb:67 (current implementation returns `email`)
- Nearest spec: spec/models/user_spec.rb:45 (asserts it returns `"#{first_name} #{last_name}"` — currently passing against stubbed code)
- Engine boundary: N/A
- Gotchas: Profile.display_name_override was added in migration 20260201_add_profile_overrides.rb but never wired into User#display_name.
- Confusion: SEE BELOW

### Confusion Block
- Ambiguity: The spec at user_spec.rb:45 expects full-name behavior, but production code returns email. Which is the intended behavior?
- Evidence:
  - spec/models/user_spec.rb:45 — expects `"Ada Lovelace"`
  - app/models/user.rb:67 — `def display_name; email; end`
  - db/migrate/20260201_add_profile_overrides.rb introduces `profiles.display_name_override` but nothing reads it
- Options:
  A. Treat spec as source of truth: return `"#{first_name} #{last_name}"`, fall back to email; also wire in `profile.display_name_override` when present
  B. Treat code as source of truth: update spec to expect email; drop the unused column
- Recommendation: A — the migration and spec both indicate the intended direction; current code is the regression
- Needed from you: Confirm A, or point to the product decision behind B
```

Context loaded. Waiting on Confusion resolution before proposing the fix.

## Example 3 — Engine boundary: change spans host app + mounted engine

**Task:** Add a "Resend invite" button to the admin users screen. `Invitations` lives in a mounted engine.

```text
### Context Summary
- Scope: Admin::UsersController (host) + Auth::InvitationsController (engine Auth::Engine)
- Rails version: 7.1.3
- Relevant tables: users, auth_invitations (token, expires_at, user_id) — db/schema.rb (host) + engines/auth/db/schema.rb
- Relevant routes:
  - host: namespace :admin { resources :users } — config/routes.rb:18
  - engine: mount Auth::Engine, at: "/auth" — config/routes.rb:3
  - engine internal: resources :invitations, only: %i[create] — engines/auth/config/routes.rb:7
- Nearest pattern: app/controllers/admin/users_controller.rb:88 (existing `reset_password` action calls `Auth::PasswordResets::Create.call(user:)`)
- Nearest spec: spec/requests/admin/users_spec.rb:52 (pattern for admin-triggered engine actions, uses `Auth::Engine.routes.url_helpers`)
- Engine boundary: Auth::Engine — host must call through `Auth::Invitations::Create.call(user:)`, NOT `Auth::InvitationsController` directly. Engine exposes the service object as the integration point.
- Gotchas: Engine uses its own `current_admin` helper via isolate_namespace; host's Pundit policies do not apply inside the engine. Token TTL is 48h (Auth::Engine.config.invitation_ttl).
- Confusion: NONE
```

Context loaded. Next: ddd-boundaries-review — confirm the host→engine call goes through the service object, not the controller.
