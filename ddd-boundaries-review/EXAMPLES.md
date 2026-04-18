# DDD Boundaries Review — Examples

Extended patterns for this skill. Read [SKILL.md](./SKILL.md) first.

## Example: Leakage + Fix

**Before — Billing reaches into Fleet internals:**

```ruby
# app/services/billing/invoice_service.rb
class Billing::InvoiceService
  def call(reservation_id)
    reservation = Fleet::Reservation.find(reservation_id)
    reservation.update!(status: :invoiced)  # Billing mutating Fleet state
    create_invoice(reservation)
  end
end
```

**After — Fleet emits an event; Billing reacts:**

```ruby
# Fleet publishes an outcome; Billing subscribes via a job or hook
class Fleet::Reservation < ApplicationRecord
  def complete!
    update!(status: :completed)
    ReservationCompletedJob.perform_later(id)  # Fire-and-forget event
  end
end

# app/services/billing/invoice_service.rb — no Fleet constants
class Billing::InvoiceService
  def call(reservation_id:, amount_cents:)
    create_invoice(reservation_id:, amount_cents:)
  end
end
```

**Finding format:**

```
Severity: High
Contexts: Billing → Fleet
Leaked term: reservation.update!(status: :invoiced)
Risk: Billing owns Fleet state transitions. Changes to Fleet lifecycle break Billing silently.
Smallest credible fix: Fleet emits ReservationCompleted event; Billing reacts without touching Fleet models.
```

## Pitfalls

| Pitfall | What to do |
|---------|------------|
| "Everything should become a bounded context" | Many apps have a few real contexts — over-splitting creates ceremony |
| Reviewing folders without reviewing language | Directory structure alone does not prove domain boundaries |
| Solving leakage with shared utility modules | Shared utils hide ownership problems instead of fixing them |
| Recommending a rewrite first | Start with the smallest credible boundary improvement |
| One model serving unrelated workflows | Different language in the same object = leaked context — separate them |
| Ownership described as "whoever needs it" | A context with no named owner has no boundary — name it first |
