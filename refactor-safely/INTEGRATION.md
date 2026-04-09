# Refactor Safely Integration Guide

Use this file when you need deeper chaining guidance than the summary table in `SKILL.md`.

## rspec-best-practices

Use before any structural change to create characterization tests.

**Trigger:** You cannot describe which test proves current behavior.

**Hand-off artifact:** A passing characterization spec that fails if behavior drifts.

## rails-architecture-review

Use when refactor findings indicate deeper boundary problems.

**Trigger:** Repeated leakage across models/controllers/services.

**Hand-off artifact:** Severity-ranked architecture findings and smallest credible next improvement.

## rails-code-review

Use after structural changes are complete and tests are green.

**Trigger:** You need an external quality pass on safety, readability, and Rails conventions.

**Hand-off artifact:** Review findings with remediation suggestions ordered by severity.

## ruby-service-objects

Use when extraction target is business workflow logic that does not belong in controller/model.

**Trigger:** Repeated orchestration or transaction flow is embedded in framework classes.

**Hand-off artifact:** Service object contract (`.call`), boundary rules, and migration sequence.
