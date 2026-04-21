# Structured Logging — Canonical Examples

Every `Rails.logger.*` call in this codebase uses **exactly two positional arguments**:

```ruby
Rails.logger.<level>(static_string, { event: "dot.namespaced", ...domain_fields })
```

Copy the shapes below verbatim. Do not invent variants.

## Template

```ruby
Rails.logger.info("<event.name>", {
  event: "<event.name>",
  # ...domain fields (ids, amounts, counts, statuses)...
})
```

The static string and the `event:` value are conventionally identical — pick the event name, use it for both.

## Worked example — a payment processing service

```ruby
module Payments
  class ProcessCharge
    def self.call(order_id:, amount_cents:)
      new(order_id: order_id, amount_cents: amount_cents).call
    end

    def initialize(order_id:, amount_cents:)
      @order_id = order_id
      @amount_cents = amount_cents
    end

    def call
      Rails.logger.info("payment.charge_started", {
        event: "payment.charge_started",
        order_id: @order_id,
        amount_cents: @amount_cents
      })

      order = Order.find(@order_id)

      if order.already_paid?
        Rails.logger.warn("payment.charge_skipped_already_paid", {
          event: "payment.charge_skipped_already_paid",
          order_id: @order_id
        })
        return { success: true, response: { status: :already_paid } }
      end

      response = PaymentGateway.charge(order: order, amount_cents: @amount_cents)

      Rails.logger.info("payment.charge_succeeded", {
        event: "payment.charge_succeeded",
        order_id: @order_id,
        amount_cents: @amount_cents,
        gateway_id: response.id
      })

      { success: true, response: { gateway_id: response.id } }
    rescue PaymentGateway::DeclinedError => e
      Rails.logger.error("payment.charge_declined", {
        event: "payment.charge_declined",
        order_id: @order_id,
        amount_cents: @amount_cents,
        error: e.message,
        backtrace: e.backtrace.first(5).join("\n")
      })
      { success: false, response: { error: { message: e.message } } }
    rescue StandardError => e
      Rails.logger.error("payment.charge_failed", {
        event: "payment.charge_failed",
        order_id: @order_id,
        error: e.message,
        backtrace: e.backtrace.first(5).join("\n")
      })
      raise
    end
  end
end
```

This example demonstrates every rule at once:

- **Four log statements** at three levels (info, warn, error).
- **Static string** first arg every time — no interpolation anywhere.
- **Hash** second arg every time, first key `event:`.
- **Dynamic data** (order_id, amount_cents, error, backtrace) only in the hash.
- **Error rescues** log `e.message` AND `e.backtrace.first(5).join("\n")`.
- **Specific rescues** (`DeclinedError`) precede the generic `StandardError`.

## Forbidden shapes

| Shape | Why it fails |
|---|---|
| `Rails.logger.info("order #{id} started")` | Interpolation destroys log-aggregator grouping |
| `Rails.logger.info(event: "order.started", order_id: id)` | Single-hash call — no static-message dimension |
| `Rails.logger.info("order started")` | Single-string call — no structured fields |
| `Rails.logger.info("order.started", event: "order.started", order_id: id)` | Hash is a keyword-arg mash, not a literal — always use `{ ... }` explicitly |
| `Rails.logger.info("order.started", { type: "order.started", ... })` | Wrong key — must be `event:`, not `:type`/`:action`/`:name` |
| `rescue => e; Rails.logger.error(e.message); end` | Missing backtrace; missing event hash; missing static string |

## Event naming

Events are dot-namespaced: `<domain>.<action_past_tense>` or `<domain>.<action_state>`.

Good: `order.created`, `payment.charge_declined`, `subscription.renewal_scheduled`, `inventory.import_partial_success`.

Bad: `OrderCreated` (PascalCase), `order-created` (kebab), `create_order` (verb-first), `processing` (no namespace).

## Quick self-check before committing any logger call

1. Count the positional args. Exactly two? If not, stop.
2. Is the 1st arg a bare `"string literal"` with no `#{...}`? If not, stop.
3. Is the 2nd arg written as `{ event: "...", ... }`? If not, stop.
4. On error paths: is `backtrace: e.backtrace.first(5).join("\n")` in the hash? If not, stop.
