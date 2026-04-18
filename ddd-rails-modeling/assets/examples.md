# ddd-rails-modeling examples

Example mapping (JSON):

{
  "aggregates": [
    {
      "name": "Order",
      "model": "Order",
      "repository": "OrderRepository",
      "services": ["OrderCreator", "OrderCanceler"],
      "events": ["order.created", "order.canceled"],
      "owner": "team-orders"
    }
  ],
  "bounded_contexts": [
    {"name": "Orders", "path": "app/models/order*", "owner": "team-orders"},
    {"name": "Billing", "path": "app/services/billing/*", "owner": "team-billing"}
  ]
}

Use mapping_schema.json to validate this file and keep a machine-readable mapping between domain concepts and Rails artifacts.
