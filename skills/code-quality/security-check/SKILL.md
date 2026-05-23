---
name: security-check
license: MIT
description: >
  Performs security audits and vulnerability assessments on Ruby on Rails application
  code. Use when reviewing Rails code for security risks, assessing authentication or
  authorization, auditing parameter handling, redirects, file uploads, secrets management,
  or checking for XSS, CSRF, SSRF, SQL injection, and other common vulnerabilities.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Security Check

## Quick Reference

| Area | Key Checks |
|------|------------|
| Auth | Permissions on every sensitive action |
| Params | No `permit!`, allowlist only safe attributes |
| Queries | Parameterized — no string interpolation in SQL |
| Redirects | Constrained to relative paths or allowlist |
| Output | No `html_safe`/`raw` on user content |
| Secrets | Encrypted credentials, never in code or logs |
| Files | Validate filename, content type, destination |

## HARD-GATE

```text
BEFORE returning your security review, verify:
  1. The FIRST finding section is "Authentication & Authorization"
  2. All other findings follow auth/authz
  3. If no auth/authz issue exists, open with "Authentication & Authorization:
     no issues found" before any other category
```
If no source files were provided or read, do not fabricate affected files,
line numbers, or exploitable findings. Return a security review checklist and
mark findings as requiring code-level verification.

## Core Process

**Core principle:** Prioritize exploitable issues over style. Assume any untrusted input can be abused.

### Review Order

1. Check authentication and authorization boundaries.
2. Check parameter handling and sensitive attribute assignment.
3. Check redirects, rendering, and output encoding.
4. Check file handling, network calls, and background job inputs.
5. Check secrets, logging, and operational exposure.
6. **Verify each finding:** Confirm it is exploitable with a concrete attack scenario before reporting. Exclude false positives (e.g., `html_safe` on a developer-defined constant, not user input).

### Severity Levels

#### High

- Missing or bypassable authorization checks
- SQL, shell, YAML, or constantization injection paths
- Unsafe redirects or SSRF-capable outbound requests
- File upload handling that trusts filename, content type, or destination blindly
- Secrets or tokens stored in code, logs, or unsafe config

#### Medium

- Unscoped mass assignment through weak parameter filtering
- User-controlled HTML rendered without clear sanitization
- Sensitive data logged in plaintext
- Security-relevant behavior hidden in callbacks or background jobs without guardrails
- Brittle custom auth logic where framework primitives would be safer

### Review Checklist

- Are permissions enforced on every sensitive action?
- Are untrusted inputs validated before database, filesystem, or network use?
- Are redirects and URLs constrained?
- Are secrets stored and logged safely?
- Are security assumptions explicit and testable?

### Examples

**High-severity (unscoped redirect):**

```ruby
# Bad: user-controlled redirect — open redirect / phishing risk
redirect_to params[:return_to]

# Good: relative path only
redirect_to root_path
# Good: allowlist
SAFE_PATHS = %w[/dashboard /settings].freeze
redirect_to(SAFE_PATHS.include?(params[:return_to]) ? params[:return_to] : root_path)
```

**Medium-severity (mass assignment):**

```ruby
# Bad: privilege escalation risk
params.require(:user).permit!

# Good: explicit allowlist — never include role, admin, or privilege fields
params.require(:user).permit(:name, :email)
```

### Pitfalls

Critical anti-patterns: `permit!` on any parameter set, `html_safe` on user content, SQL string interpolation, secrets in committed files. See extended resources for the full list.

## Extended Resources

- [PITFALLS.md](./PITFALLS.md) for the full list of pitfalls.

## Output Style

1. **Format**: Sections must appear in the order below, even when empty — write "No issues found" and state what evidence would be needed to verify the category.
   ```text
   ## Authentication & Authorization
   ## Parameter Handling & Mass Assignment
   ## Query Safety (SQL / NoSQL / shell injection)
   ## Output Encoding & Redirects
   ## File Handling, Network Calls & Background Job Inputs
   ## Secrets, Logging & Operational Exposure
   ```
2. **Finding details**: Each finding carries:
   - **Severity:** **High** or **Medium** (not "Critical")
   - **Attack path:** input → reach → impact
   - **Affected file:** path + line, e.g. `app/controllers/documents_controller.rb:42`
   - **Mitigation:** smallest credible fix
   Do not use representative file paths as if they were confirmed evidence.
3. **Language**: Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **code-review** | For full code review including non-security concerns |
| **review-architecture** | When security issues stem from architectural problems |
| **review-migration** | When reviewing migration security (data exposure, constraints) |
