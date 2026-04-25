---
name: api-rest-collection
license: MIT
description: >
  Use when creating or modifying REST API endpoints (Rails controllers, engine routes,
  API actions). Requires generating or updating an API Collection file (e.g., Postman
  Collection v2.1) so the new or changed endpoints can be tested. Trigger words:
  endpoint, API route, controller action, API collection, request collection.
license: MIT
---
# REST API Collection

**Core principle:** Every API surface (Rails app or engine) has a single API collection file that stays in sync with its endpoints.

## Quick Reference

| Aspect | Rule |
|--------|------|
| When | Create or update collection when creating or modifying any REST API endpoint (route + controller action) |
| Format | Postman Collection JSON v2.1 (`schema` or `info.schema` references v2.1) is a good default standard |
| Location | One file per app or engine — `docs/api-collections/<app-or-engine-name>.json` or `spec/fixtures/api-collections/`; if a collection folder already exists, update the existing file |
| Language | All request names, descriptions, and variable names must be in **English** |
| Variables | Use `{{base_url}}` (or equivalent) for the base URL so the collection works across environments |
| Per request | method, URL (with variables for base URL), headers (Content-Type, Authorization if needed), body example when applicable |
| Validation | See validation steps in the HARD-GATE section below |

## HARD-GATE: Generate on Endpoint Change

```
When you create or modify a REST API endpoint (new or changed route and controller action),
you MUST also create or update the corresponding API collection file so the
flow can be tested. Do not leave the collection missing or outdated.

EXCEPTION: GraphQL endpoints — use rails-graphql-best-practices instead.
```

After generating or updating the collection, validate the output:
- Confirm the JSON is syntactically valid.
- Verify the collection can be imported into a compatible API client (e.g. Postman) without errors.
- Confirm all new or changed endpoints are represented and that `{{base_url}}` (or equivalent) is used consistently.

## Collection Structure

Minimum per request — `method`, `url` with `{{base_url}}`, headers, body for POST/PUT:

```json
{
  "name": "Create order",
  "request": {
    "method": "POST",
    "header": [{ "key": "Content-Type", "value": "application/json" }],
    "url": "{{base_url}}/orders",
    "body": { "mode": "raw", "raw": "{\"product_id\": 1}" }
  }
}
```

See [EXAMPLES.md](./EXAMPLES.md) for a multi-endpoint collection with auth token variables.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Missing Content-Type or body for POST/PUT | Include headers and example body so the request works out of the box |
| Skipping validation after generation | Always verify the JSON is well-formed and imports correctly before committing (see HARD-GATE) |

## Integration

| Skill | When to chain |
|-------|----------------|
| **rails-engine-author** | When the engine exposes HTTP endpoints |
| **rails-engine-docs** | When documenting engine API or how to test endpoints |
| **rails-code-review** | When reviewing API changes (ensure collection was updated) |
| **rails-engine-testing** | When adding request/routing specs (collection can mirror those flows) |
