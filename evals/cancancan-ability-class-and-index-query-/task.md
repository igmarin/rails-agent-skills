# Internal Reporting Tool Access Control

## Problem/Feature Description

A mid-size manufacturing company uses an internal Rails application to manage financial and operational reports. The platform has three categories of users: `finance` staff who need full control over reports (create, read, update, destroy), `viewer` staff who can only read reports, and unauthenticated visitors who should be completely blocked.

The `Report` model has a `title`, `body`, and `author_id` field. The `User` model has a `role` attribute that is either `"finance"` or `"viewer"`. The team wants to implement role-based authorization using CanCanCan. They also need the reports listing page to automatically show only the reports each role is permitted to see — finance sees all, viewers see all readable ones.

## Output Specification

Produce the following files:

- `app/models/ability.rb` — the CanCanCan Ability class defining permissions for each role
- `app/controllers/reports_controller.rb` — the controller with CanCanCan authorization integrated, including the index action
- `spec/models/ability_spec.rb` — RSpec spec covering the Ability class for finance, viewer, and guest roles
- `spec/requests/reports_spec.rb` — request spec covering access attempts by different roles
- `implementation_notes.md` — summary of approach and required setup steps
