# Generate Implementation Tasks for User Referral Feature

## Problem/Feature Description

The growth team at Loopback, a SaaS CRM, wants to launch a referral program. When an existing user refers a new signup, the referrer earns credits that can be applied to their next invoice. The product manager has written a PRD for this feature and needs a detailed implementation task list that the engineering team can work through sequentially.

The engineering lead has asked that the task list be saved to the project's `/tasks/` folder. The team follows a strict test-driven workflow and expects the task breakdown to reflect that — every implementation step should have corresponding spec steps paired with it, not as an afterthought. They also require that documentation and code review steps appear explicitly at the end, since those are often skipped when not tracked.

Your job is to generate a complete, detailed implementation task checklist from the PRD below.

## Input Files

The following file is provided as input. Extract it before beginning.

=============== FILE: prd-referral-program.md ===============
# PRD: User Referral Program

## Goal
Allow existing users to refer new signups and earn account credits when the referred user activates their account.

## Functional Requirements

1. Each user gets a unique referral code (alphanumeric, 8 chars) generated on account creation.
2. New signups can enter a referral code during registration. If valid, the referral is recorded.
3. When a referred user activates their account (confirms email), the referrer receives 10 credits added to their account.
4. A referral can only be redeemed once per referred user (idempotent credit grant).
5. Users can view how many referrals they've made and total credits earned via a summary endpoint.

## Out of Scope
- Referral expiry
- Multi-level referral chains
- Credit redemption UI (handled by existing billing module)

## Stack
- Rails monolith, PostgreSQL
- RSpec for tests
- Existing models: User (has :credits integer column), Account (belongs_to :user)
=============== END FILE ===============

## Output Specification

Generate and save a detailed implementation task checklist to:

- `tasks/tasks-referral-program.md` — the complete task list with checkboxes

The task list should be complete enough for a Rails engineer to execute from top to bottom without further clarification.
