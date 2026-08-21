# REST API Collection — Examples

## Multi-Endpoint Collection (Postman v2.1)

```json
{
  "info": {
    "name": "Orders API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "List orders",
      "request": {
        "method": "GET",
        "header": [{ "key": "Authorization", "value": "Bearer {{auth_token}}" }],
        "url": "{{base_url}}/orders"
      }
    },
    {
      "name": "Create order",
      "request": {
        "method": "POST",
        "header": [
          { "key": "Content-Type", "value": "application/json" },
          { "key": "Authorization", "value": "Bearer {{auth_token}}" }
        ],
        "url": "{{base_url}}/orders",
        "body": { "mode": "raw", "raw": "{\"product_id\": 1, \"quantity\": 2}" }
      }
    },
    {
      "name": "Show order",
      "request": {
        "method": "GET",
        "header": [{ "key": "Authorization", "value": "Bearer {{auth_token}}" }],
        "url": "{{base_url}}/orders/{{order_id}}"
      }
    }
  ],
  "variable": [
    { "key": "base_url", "value": "http://localhost:3000" },
    { "key": "auth_token", "value": "" },
    { "key": "order_id", "value": "1" }
  ]
}
```

Place this file at `docs/api-collections/orders-api.json` or `spec/fixtures/api-collections/orders-api.json`.
