# User Role Promotion Feature — TDD Walkthrough

## Problem/Feature Description

The admin team needs a new `Users::PromoteToAdmin` service (`app/services/users/promote_to_admin.rb`) that promotes a regular user to admin status. The service should accept a `user:` keyword argument and return the standard hash format with `:success` and `:response` keys. On success, the user's `role` attribute should be set to `"admin"` in the database. If the user is already an admin, the service should return failure with an error message rather than silently no-oping.

This is a brand-new feature — the service class does not exist yet. The tech lead wants to see TDD practiced correctly from the beginning, with tests written before any implementation code.

## Output Specification

Produce an `answer.md` file that demonstrates the full TDD cycle:
- The spec written before any implementation, along with the exact command to run it
- The concrete failure output from running that spec against the missing implementation
- The minimal implementation code that makes the spec pass
- The passing output from re-running the spec
- Additional passing runs at broader scope levels
- Self-audit and resource loading sections
