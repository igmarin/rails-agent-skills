---
name: api-rest-collection
description: >
  Use when creating or modifying REST API endpoints (Rails controllers, engine routes,
  API actions). Requires generating or updating an API Collection file (e.g., Postman
  Collection v2.1) so the new or changed endpoints can be tested. Trigger words:
  endpoint, API route, controller action, API collection, request collection.
---
# REST API Collection

Use this skill when you add or change a REST API endpoint so that a compatible collection file is generated or updated for testing in a modern API client.

**Core principle:** Every API surface (Rails app or engine) has a single API collection file that stays in sync with its endpoints. All names, descriptions, and variable labels in the collection must be in **English**.

## Quick Reference

| Aspect | Rule |
|--------|------|
| When | Create or update collection when creating or modifying any REST API endpoint (route + controller action) |
| Format | Postman Collection JSON v2.1 (`schema` or `info.schema` references v2.1) is a good default standard. |
| Location | One file per app or engine, e.g. `docs/api-collections/<app-or-engine-name>.json` or `spec/fixtures/api-collections/` |
| Language | All request names, descriptions, and variable names in the collection in **English** |
| Per request | method, URL (with variables for base URL), headers (Content-Type, Authorization if needed), body example when applicable |

## HARD-GATE: Generate on Endpoint Change

```
When you create or modify a REST API endpoint (new or changed route and controller action),
you MUST also create or update the corresponding API collection file so the
flow can be tested. Do not leave the collection missing or outdated.

EXCEPTION: GraphQL endpoints do NOT use REST collections.
For GraphQL, use a dedicated GraphQL client — see note below.
```

## GraphQL Endpoints

Do **not** use this skill for GraphQL endpoints. REST collections do not map cleanly to GraphQL queries and mutations. For GraphQL:

- Use **Insomnia** (preferred) or **GraphQL Playground** for manual testing
- Import the schema directly via introspection or SDL file
- Store an Insomnia workspace export in `docs/insomnia/` if the team needs a shared config

See **rails-graphql-best-practices** for the full GraphQL conventions.

## Language

All generated content in the collection must be in **English**: request names, folder names, descriptions, and variable display names. Do not use another language unless the user explicitly requests it.

## Collection Structure (Postman v2.1 Example)

- **Root:** `info` (name, description, schema `https://schema.getpostman.com/json/collection/v2.1.0/collection.json`), `item` array.
- **Each request (item):** `name` (English), optional `request` with `method`, `url` (string or object with `raw`/`host`/`path`/`variable`), `header` array, `body` when applicable (e.g. raw JSON for POST/PUT).
- Use **variables** for base URL (e.g. `{{base_url}}`) so the collection works across environments.

## Where to Put the File

- Prefer a single collection per application or engine.
- Suggested paths: `docs/api-collections/<name>.json` or `spec/fixtures/api-collections/<name>.json`.
- If the repo already has a collection folder, use that location and update the existing file.

## Example Snippet (structure only)

```json
{
  "info": {
    "name": "My Engine API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Create resource",
      "request": {
        "method": "POST",
        "header": [{ "key": "Content-Type", "value": "application/json" }],
        "url": "{{base_url}}/resources",
        "body": { "mode": "raw", "raw": "{\"name\": \"Example\"}" }
      }
    }
  ],
  "variable": [{ "key": "base_url", "value": "http://localhost:3000" }]
}
```

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Adding an endpoint but not touching the collection | Collection must be updated so the new flow is testable in an API client |
| Using a language other than English for names/descriptions | Standard is English unless the user requests otherwise |
| Hardcoding full URLs instead of variables | Use `{{base_url}}` (or similar) so the collection works in dev/staging/prod |
| Missing Content-Type or body for POST/PUT | Include headers and example body so the request works out of the box |

## Red Flags

- New or changed endpoint with no corresponding API collection update
- Collection file path not documented or inconsistent across the project
- Request names or descriptions in a language other than English without user request

## Integration

| Skill | When to chain |
|-------|----------------|
| **rails-engine-author** | When the engine exposes HTTP endpoints |
| **rails-engine-docs** | When documenting engine API or how to test endpoints |
| **rails-code-review** | When reviewing API changes (ensure collection was updated) |
| **rails-engine-testing** | When adding request/routing specs (collection can mirror those flows) |
