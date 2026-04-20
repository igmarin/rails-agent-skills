# Secure Document Management Authorization

## Problem/Feature Description

A growing legal-tech startup has a Rails application for managing client documents. They recently discovered that their Documents feature has no meaningful access controls: any logged-in user can view, edit, or delete documents belonging to other users. The engineering lead needs proper authorization implemented before their upcoming SOC 2 audit.

The application already has a `User` model with an `admin` boolean attribute, and a `Document` model with a `user_id` foreign key. The business rules are: document owners may read, update, and destroy their own documents; admins may perform any action on any document; authenticated non-owners may only read documents; unauthenticated visitors may not access documents at all.

## Output Specification

Produce the following files implementing authorization for the Documents resource using Pundit:

- `app/policies/document_policy.rb` — the Pundit policy class
- `app/controllers/documents_controller.rb` — the controller with authorization wired up, including the index action
- `spec/policies/document_policy_spec.rb` — RSpec policy spec covering all roles
- `spec/requests/documents_spec.rb` — request spec covering the most critical access scenarios

Additionally, produce `implementation_notes.md` summarizing the approach taken and any setup steps required.
