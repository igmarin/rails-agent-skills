# Module README Template

Every service module under `app/services/<module_name>/` MUST ship a `README.md` using this shape. One section per service in the module — even single-service modules get a README.

```markdown
# <ModuleName> Services

Brief paragraph: what business capability this module covers.

## <ServiceName>

**Purpose:** one-line summary.

**Inputs:** `params [Hash]` with `:key1`, `:key2`, ...

**Success:** `{ success: true, response: { <domain_key>: <value> } }`

**Failure:** `{ success: false, response: { error: { message: String } } }`

**Raises:** `SomeError` when ..., `OtherError` when ... (internally rescued unless noted).
```

## Notes

- Keep response shapes consistent with the **MANDATORY Response Contract** in `SKILL.md`.
- List exception classes even when rescued internally — readers need the full surface.
- For class-only services (Pattern 3, e.g. validators), document the actual return type (`nil` / error string) instead of the success/failure hash if that's what the class returns.
