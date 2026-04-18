# YARD Tag Examples

Use this file as the canonical reference for common YARD tags used by this skill.

## `@param`

Document each parameter with its type and purpose.

```ruby
# @param plan_id [Integer] ID of the target plan
```

## `@return`

Document the return type and, when relevant, the shape of the response.

```ruby
# @return [Hash] Result with :success and :response keys
```

## `@raise`

Document one tag per exception class that can be raised.

```ruby
# @raise [InvalidPlanError] when the plan does not exist or is inactive
# @raise [PaymentGatewayError] when the payment provider rejects the charge
```
