# Rails Architecture Review — Examples

## High-Severity: Controller Doing Too Much

```ruby
# Bad: multi-step domain workflow in controller
class OrdersController < ApplicationController
  def create
    order = Order.new(order_params)
    Inventory.check!(order.line_items)
    Pricing.apply_promotions!(order)
    order.save!
    NotifyWarehouseJob.perform_later(order.id)
    redirect_to order
  end
end
```

**Finding:**
- **Severity:** High
- **Affected file:** `app/controllers/orders_controller.rb` — `#create`
- **Risk:** Controller runs a multi-step domain workflow. Any step failure leaves partial state; logic is untestable without HTTP. Adding a new caller (background job, API) requires duplicating the workflow.
- **Improvement:** Extract to `Orders::CreateOrder.call(params)`. Controller calls it and handles response/redirect only.

---

## High-Severity: Business Logic in Callbacks

```ruby
# Bad: concern mixing audit, notifications, and external API in callbacks
module Auditable
  extend ActiveSupport::Concern
  included do
    after_create :log_creation
  end

  def log_creation
    AuditLog.create!(...)
    Slack.notify("#audit", ...)
    UserMailer.admin_alert(...).deliver_later
  end
end
```

**Finding:**
- **Severity:** High
- **Affected file:** `app/models/concerns/auditable.rb`
- **Risk:** `after_create` triggers Slack and email — invisible side effects on every save. Any model that includes `Auditable` inherits this blast. Tests require stubbing external services just to save a record.
- **Improvement:** Remove from callback. Call `AuditService.record(record)` explicitly in the service layer. Keep `AuditLog.create!` only in the concern if needed; move Slack/mailer to the caller.

---

## Medium-Severity: Concern Mixing Unrelated Responsibilities

A concern that handles auditing AND sends Slack messages AND sends emails is three concerns, not one. Each responsibility should be extractable independently.

**Finding:**
- **Severity:** Medium
- **Affected file:** `app/models/concerns/auditable.rb`
- **Risk:** Can't add auditing without also pulling in Slack/email. Reuse is blocked.
- **Improvement:** Split into `Auditable` (database log only) and move notifications to an explicit `AuditNotifier` service called from the service layer.

---

## Output Format Reference

Every finding must include all four fields:

```
**Severity:** High | Medium
**Affected file:** app/path/to/file.rb — ClassName#method
**Risk:** what goes wrong if left unaddressed
**Improvement:** the smallest credible refactor
```
