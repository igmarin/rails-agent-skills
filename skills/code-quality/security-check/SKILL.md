---
name: security-check
type: atomic
license: MIT
description: >
  Use when performing security audits on Rails application code — must check authentication/authorization, parameter handling, redirects/rendering, file/network/job inputs, and secrets/logging, verify each finding is exploitable with a concrete attack scenario before reporting (excluding false positives without using representative file paths), and present sections in the exact order specified, even if empty. Code review for XSS, CSRF, SSRF, SQL injection, open redirects, secrets.
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
  4. You have searched the workspace using file listing/search tools to find
     actual Rails codebase files (e.g. under app/controllers, app/models) and 
     audited them, rather than stating no source code was provided.
```
You MUST use your filesystem and search tools (like listing directories and searching patterns) to locate any source files in the workspace. Only if the workspace is completely empty may you return a checklist and state that no source files were provided.

## Core Process

**Core principle:** Prioritize exploitable issues over style. Assume any untrusted input can be abused.

### 0. Inspect the Workspace
Before writing any findings or analysis, you MUST run search and directory listing tools to find source files in the workspace (e.g. controllers, models, config files). Perform a code-level security review on the actual files found. Do not claim no source code was provided without first checking the workspace.

### Review Order

Review in this sequence, and produce output sections in this same order (see Output Style):

1. Authentication and authorization boundaries.
2. Parameter handling and sensitive attribute assignment.
3. Redirects, rendering, and output encoding.
4. File handling, network calls, and background job inputs.
5. Secrets, logging, and operational exposure.
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

1. **Format**: Produce sections in the review order defined in Core Process, even when empty — write "No issues found" and state what evidence would be needed to verify the category.
   ```text
   ## Authentication & Authorization
   ## Parameter Handling & Sensitive Attribute Assignment
   ## Redirects, Rendering & Output Encoding
   ## File Handling, Network Calls & Background Job Inputs
   ## Secrets, Logging & Operational Exposure
   ```
2. **Finding details & Exploitability**: Each finding carries:
   - **Severity:** **High** or **Medium** (not "Critical")
   - **Attack path:** input → reach → impact
   - **Affected file:** path + line, e.g. `app/controllers/documents_controller.rb:42`
   - **Mitigation:** smallest credible fix
   - Do not use representative file paths as if they were confirmed evidence.
   - **Verification Steps & Quality Gates**:
     - **Hypothetical Exploitability Proof**: Even if no source files are provided and no vulnerabilities are found, you MUST include a **Hypothetical Exploitability Verification** sub-section inside the **Verification Steps & Quality Gates** section of the output `answer.md` (never as a separate top-level section interleaving the findings and the gates). Show a concrete example of a hypothetical vulnerability (e.g. an unscoped SQL query or open redirect) and detail exactly what the corresponding concrete attack scenario (exploit request/payload) would look like, proving how to confirm exploitability in practice.
3. **No Implied Paths**: When no source code is analyzed, do NOT include any specific directory paths or file patterns (such as 'app/views/', 'app/controllers/') even in grep command examples or search patterns; instead, use generic placeholders like 'SRC_DIR/' or 'CONTROLLER_DIR/'. For hypothetical examples, use completely abstract placeholder names like `HYPOTHETICAL_DIR/hypothetical_controller.rb` to prevent them from being mistaken for real workspace file references.
4. **Language**: Must be in English unless explicitly requested otherwise.


## Integration

| Skill | When to chain |
|-------|---------------|
| **code-review** | For full code review including non-security concerns |
| **review-architecture** | When security issues stem from architectural problems |
| **review-migration** | When reviewing migration security (data exposure, constraints) |

| **security-review-process** *(from ruby-core-skills)* | Process discipline: OWASP checklist, Ruby-level security concerns |
