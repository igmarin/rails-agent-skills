# Team Membership Service — Full Coverage Spec

## Problem/Feature Description

The HR module has a `Teams::AddMember` service (`app/services/teams/add_member.rb`) that handles adding a user to a team. The service accepts `team:` and `user:` keyword arguments. It:
1. Validates the user isn't already a member
2. Creates a `TeamMembership` record linking the user to the team
3. Enqueues a `TeamWelcomeJob` to notify the new member

The service returns the standard `{ success:, response: }` format. Failure cases: user already a member (returns error), team at capacity (returns error with a `capacity_limit` key in the error hash).

The team lead wants a complete, production-ready spec that covers all scenarios and demonstrates rigorous self-auditing before submission. They're particularly concerned that the spec meets all of the project's RSpec conventions — not just the obvious ones.

## Output Specification

Produce an `answer.md` file containing:
- The complete RSpec spec file with path shown at the top
- TDD proof showing RED and GREEN runs
- A thorough self-audit section verifying all conventions
- Resource loading documentation
