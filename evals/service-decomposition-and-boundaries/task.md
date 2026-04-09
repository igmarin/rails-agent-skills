# User Onboarding Orchestration Service

## Problem/Feature Description

A B2B SaaS platform has a multi-step user onboarding flow that was originally written as a single 200-line controller action. The flow involves: creating the user account, setting up the workspace, assigning a default billing plan, and sending a welcome email notification. The team is now refactoring this into a proper service layer. The current controller action mixes HTTP concerns (checking `request.format`, calling `render json:`) directly into the business logic, which has made testing painful.

The team wants a clean service layer where each step is independently testable, the overall flow is easy to understand, and no service class is responsible for producing HTTP responses. The onboarding service will be called from both the web controller and a future REST API endpoint, so it must work identically regardless of calling context.

Your task is to write the Ruby service layer for this onboarding flow. Design it so the main orchestrator coordinates the individual steps without implementing all the details inline. The individual steps (user creation, workspace setup, billing assignment, and notification) should be separate concerns.

## Output Specification

Produce the following files:

- `app/services/<module>/onboarding_service.rb` — the main orchestrator
- At least two sub-service files under the same module (e.g. for workspace setup, billing, or notification)
- `spec/services/<mirrored_path>/onboarding_service_spec.rb` — specs covering successful onboarding and at least one failure scenario

Do not build a full Rails app. Use stub method bodies with comments (e.g. `# TODO: User.create!(...)`) so the architecture and boundaries can be reviewed without a running application. The focus is on the service structure, delegation pattern, and return value contracts.
