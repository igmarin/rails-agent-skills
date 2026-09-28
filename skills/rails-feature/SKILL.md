---
name: rails-feature
type: workflow
description: Use for an ordinary Rails behavior change when no specialist card such as migrations, authorization, GraphQL, jobs, or Hotwire is the main task.
---

# Rails Feature

1. Read app instructions, schema/routes relevant to the change, and one neighboring implementation/test.
2. For behavior changes, add a focused example in the app's existing test framework and run it to establish the current failure.
3. Implement the smallest change that fits the app's conventions; keep queries, authorization, and side effects at their existing boundaries.
4. Run the focused spec and the relevant project checks. Add documentation for public APIs when the app requires it.

Use the specialist card directly when the feature centers on a migration, authorization, background job, GraphQL, Hotwire, performance, API versioning, or an engine. Ask for a checkpoint only for production data, security/authorization, deployment, or irreversible changes.
