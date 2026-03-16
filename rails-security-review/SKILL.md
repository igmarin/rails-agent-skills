---
name: rails-security-review
description: >
  Use when reviewing Rails code for security risks, assessing authentication or
  authorization, auditing parameter handling, redirects, file uploads, secrets management,
  or checking for XSS, CSRF, SSRF, SQL injection, and other common vulnerabilities.
---

# Rails Security Review

Use this skill when the task is to review or harden Rails code from a security perspective.

**Core principle:** Prioritize exploitable issues over style. Assume any untrusted input can be abused.

## Quick Reference

| Area | Key Checks |
|------|------------|
| Auth | Permissions on every sensitive action |
| Params | No `permit!`, whitelist only safe attributes |
| Queries | Parameterized — no string interpolation in SQL |
| Redirects | Constrained to relative paths or allowlist |
| Output | No `html_safe`/`raw` on user content |
| Secrets | Encrypted credentials, never in code or logs |
| Files | Validate filename, content type, destination |

## Review Order

1. Check authentication and authorization boundaries.
2. Check parameter handling and sensitive attribute assignment.
3. Check redirects, rendering, and output encoding.
4. Check file handling, network calls, and background job inputs.
5. Check secrets, logging, and operational exposure.

## Severity Levels

### High-Severity Findings

- Missing or bypassable authorization checks
- SQL, shell, YAML, or constantization injection paths
- Unsafe redirects or SSRF-capable outbound requests
- File upload handling that trusts filename, content type, or destination blindly
- Secrets or tokens stored in code, logs, or unsafe config

### Medium-Severity Findings

- Unscoped mass assignment through weak parameter filtering
- User-controlled HTML rendered without clear sanitization
- Sensitive data logged in plaintext
- Security-relevant behavior hidden in callbacks or background jobs without guardrails
- Brittle custom auth logic where framework primitives would be safer

## Review Checklist

- Are permissions enforced on every sensitive action?
- Are untrusted inputs validated before database, filesystem, or network use?
- Are redirects and URLs constrained?
- Are secrets stored and logged safely?
- Are security assumptions explicit and testable?

## Examples

**High-severity (unscoped redirect):**

```ruby
# Bad: user-controlled redirect
redirect_to params[:return_to]
```

- **Severity:** High. **Attack path:** Attacker sets `return_to=https://evil.com` to redirect victims. **Mitigation:** Redirect only to relative paths or an allowlist.

**Medium-severity (mass assignment):**

```ruby
# Bad: permit too much
params.require(:user).permit!
```

- **Severity:** Medium. **Risk:** `permit!` allows privilege escalation. **Mitigation:** Permit only safe attributes; never permit `role`, `admin`, or other privilege fields from request params.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Only internal users access this" | Internal tools get compromised. Apply same security standards. |
| `permit!` "just for now" | It will ship. Whitelist attributes from day one. |
| "Rails handles CSRF automatically" | Only if `protect_from_forgery` is active and tokens are verified. |
| String interpolation in SQL | SQL injection. Always use parameterized queries. |
| `html_safe` on user content | XSS. Only use on developer-controlled strings. |
| Secrets in environment files committed to git | Use encrypted credentials. Rotate compromised secrets immediately. |

## Red Flags

- `permit!` anywhere in production code
- String interpolation in `where()`, `find_by_sql()`, or `execute()`
- `redirect_to params[:url]` without validation
- `html_safe` or `raw` called on user-provided data
- Secrets or API keys in committed files (`.env`, `secrets.yml`)
- No authorization check before destructive actions
- Background job inputs not validated (jobs are entry points too)

## Output Style

Write findings first.

For each finding include:
- Severity
- Attack path or failure mode
- Affected file or area
- Smallest credible mitigation

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-code-review** | For full code review including non-security concerns |
| **rails-architecture-review** | When security issues stem from architectural problems |
| **rails-migration-safety** | When reviewing migration security (data exposure, constraints) |
