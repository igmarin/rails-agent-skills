# rails-code-review examples

Example finding:

{
  "severity": "high",
  "file": "app/controllers/orders_controller.rb",
  "line": 120,
  "risk": "Unpermitted params used in create leading to mass-assignment of admin flag",
  "recommendation": "Use strong params and whitelist allowed attributes; add test to assert admin cannot be set via params",
  "proof_of_concept": "POST /orders with { order: { amount: 1, admin: true } } sets admin flag to true for new order"
}

Reviewer note examples:
- "Suggest moving business logic to OrderCreator service and adding request specs"
- "Index on orders(user_id, status) would improve query performance for recent reports"