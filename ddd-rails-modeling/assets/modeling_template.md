# DDD Rails Modeling Template

Use this template to produce a minimal domain mapping for a feature or service.

1) Identify aggregates
- name: (e.g., Order)
- model: (ActiveRecord model)
- repository: (optional PORO/repository class)
- services: list of service objects interacting with the aggregate
- events: domain events emitted by aggregate
- owner: team or owner

2) Identify bounded contexts
- name, path globs, owner

3) Output JSON validated against mapping_schema.json

4) Provide migration notes if aggregate introduces tables or cross-context references

Example output file: ddd-rails-modeling/assets/examples.md
