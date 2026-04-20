# Inline tagged notes alongside YARD

YARD tags document the **contract** (params, returns, raises). Inline tagged notes document the **why** behind code the contract can't capture — business rules, deferred work, workarounds, performance tradeoffs.

Both live on the same public surface. Neither replaces the other.

## Required triggers

| Trigger | Required tag |
|---------|--------------|
| Business-rule constant (rates, caps, thresholds) | `NOTE:` with the rule's source/owner |
| Deferred work / known shortcut | `TODO:` with ticket or next step |
| Workaround for a bug or external limitation | `HACK:` or `FIXME:` with the upstream issue |
| Performance tradeoff or hot path | `OPTIMIZE:` with the measured concern |

Every tag carries **actionable context**: owner, ticket id, deadline, or next step. Naked tags (`# TODO: fix this`) fail review.

## Examples

```ruby
# BAD — naked tag, no context
# TODO: fix this
rate = TIER_RATES.fetch(tier, 0.0)

# GOOD — business-rule constant with NOTE explaining the rule
# NOTE: 50% cap set by Pricing policy v3 (PRI-118, owner: pricing-team).
MAX_DISCOUNT = 0.50

# GOOD — TODO with next step + dependency
# TODO: replace TIER_RATES with DB-backed lookup (PRI-482; blocked on legal).
rate = TIER_RATES.fetch(tier, 0.0)

# GOOD — HACK with upstream issue
# HACK: upstream gem swallows timeouts (repo/issue#412); retry once until patched.
response = ExternalClient.fetch(id)

# GOOD — OPTIMIZE with measured concern
# OPTIMIZE: N+1 on associations.each; p95 = 840ms. Switch to preload when list > 50.
associations.each { |a| a.owner.name }
```

## Interaction with YARD blocks

Tagged notes sit **inside** the method body, next to the code they describe. The YARD block stays on the method signature — do not mix tagged notes into `@param`/`@return`/`@raise` lines.

```ruby
# Computes the tier discount for a subscription.
# @param tier [Symbol] :bronze, :silver, :gold
# @return [Float] discount rate in 0.0..0.5
def discount_for(tier)
  # NOTE: 50% cap set by Pricing policy v3 (PRI-118, owner: pricing-team).
  rate = TIER_RATES.fetch(tier, 0.0)
  [rate, MAX_DISCOUNT].min
end
```

See **rails-code-conventions** for the full rationale and non-documentation triggers.
