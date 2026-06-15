---
name: security-check
type: atomic
license: MIT
description: >
  Rails security audit with hard gates: NEVER reproduce credentials, tokens, API keys, or secrets verbatim in output — flag secrets by file path and line number only. Use when the user asks for a security audit, vulnerability scan, security review, or penetration test of a Rails application, or asks to check for XSS, CSRF, SSRF, SQL injection, open redirects, secrets exposure, authentication flaws, or authorization bypasses. Must check authentication/authorization, parameter handling, redirects/rendering, file/network/job inputs, and secrets/logging, verify each finding is exploitable with a concrete attack scenario before reporting (excluding false positives without using representative file paths), and present sections in the exact order specified, even if empty. Code review for XSS, CSRF, SSRF, SQL injection, open redirects, secrets.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Security Check

## HARD-GATE: Credential Handling

```text
CREDENTIAL HANDLING (W007 — Insecure Credential Exposure Defense):
- NEVER reproduce credentials, tokens, API keys, passwords, or secrets verbatim
  in output — flag by file path and line number only.
- When a finding involves secrets in code or logs, report:
    Affected file: app/config/initializers/foo.rb:12
    Finding: API key present in plain text — move to Rails credentials or ENV
  Do NOT quote the secret value itself.
- Exploitability Verification sub-sections MUST use generic placeholder values
  (e.g. "<REDACTED>", "<TOKEN>") — never the actual credential.
- If a file scan returns a secret value, stop — report its location, not its content.
```

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

## Core Process

**Core principle:** Prioritize exploitable issues over style. Treat all untrusted input as potentially abused.

### 0. Inspect the Workspace
Before writing any findings or analysis, you MUST run search and directory listing tools to find source files in the workspace (e.g. controllers, models, config files). Perform a code-level security review on the actual files found. Only if the workspace is completely empty may you return a checklist and state that no source files were provided.

### Review Order

Review in this sequence, and produce output sections in this same order:

1. Authentication and authorization boundaries.
2. Parameter handling and sensitive attribute assignment.
3. Redirects, rendering, and output encoding.
4. File handling, network calls, and background job inputs.
5. Secrets, logging, and operational exposure.
6. **Verify each finding:** Confirm it is exploitable with a concrete attack scenario before reporting. Exclude false positives (e.g., `html_safe` on a developer-defined constant, not user input).

> **Validation gate:** The first output section must always be "Authentication & Authorization". If no auth/authz issue exists, open with "Authentication & Authorization: no issues found" before any other category.

### Severity Levels

#### High

- **Missing/bypassable authorization** — unprotected sensitive actions
- **Injection** — SQL, shell, YAML, or constantization via user input
- **Unsafe redirects / SSRF** — outbound requests or redirects driven by user-controlled values
- **Blind file upload trust** — filename, content type, or destination unvalidated
- **Secrets in code/logs** — tokens or credentials committed or printed

#### Medium

- **Weak parameter filtering** — `permit!` or unscoped mass assignment
- **Unsanitized HTML output** — user-controlled content rendered without sanitization
- **Plaintext sensitive logging** — PII or credentials in log statements
- **Hidden security behavior** — auth logic buried in callbacks or jobs without guardrails
- **Brittle custom auth** — reimplements what framework primitives provide safely

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

## Output Style

When asked to perform a security audit, your output MUST include:

1. **Section order** — One section per review area in the exact sequence specified; write "No issues found" for empty sections and note what evidence would be needed to verify that category
2. **Finding details** — Each finding carries:
   - **Severity:** **High** or **Medium** (not "Critical")
   - **Attack path:** input → reach → impact
   - **Affected file:** path + line, e.g. `app/controllers/documents_controller.rb:42`
   - **Mitigation:** smallest credible fix
   - **Hypothetical Exploitability Verification** sub-section: concrete example vulnerability and exploit request/payload proving exploitability. This sub-section belongs inside Verification Steps & Quality Gates, never as a top-level section.
3. **No Implied Paths** — When no source code is analyzed, use generic placeholders like `SRC_DIR/` or `HYPOTHETICAL_DIR/hypothetical_controller.rb`
4. **Language** — Must be in English unless explicitly requested otherwise

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[PITFALLS.md](PITFALLS.md)** — Use when you need detailed examples of common security pitfalls and false positives to avoid

## Integration

| Skill | When to chain |
|-------|---------------|
| **code-review** | For full code review including non-security concerns |
| **review-architecture** | When security issues stem from architectural problems |
| **review-migration** | When reviewing migration security (data exposure, constraints) |
| **security-review-process** *(from ruby-core-skills)* | Process discipline: OWASP checklist, Ruby-level security concerns |
