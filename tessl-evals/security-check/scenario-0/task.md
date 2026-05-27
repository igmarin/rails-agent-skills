# Security Check Task

## Problem

A Rails team needs help with a task in this area:

Performs security audits on Rails app code — review in this exact order: authentication/authorization boundaries first→parameter handling→redirects/rendering/output encoding→file handling/network calls/background job inputs→secrets/logging/operational exposure; sections MUST appear in this order even when empty (write "No issues found" and state what evidence needed), verify each finding is exploitable with a concrete attack scenario, exclude false positives (e.g.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Rails-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
