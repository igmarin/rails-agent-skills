# Rails skill docs

Use the root [README](../README.md) for the pack map and migration guide. This repo owns Rails-specific procedures; Ruby language patterns belong in `ruby-core-skills`. Install both through the `ruby-rails` profile. The shared `work-router` lives in `agnostic-planning-skills`.

## Maintainer references

- [Architecture](architecture.md): ownership, registries, and loading rules.
- [Skill design principles](skill-design-principles.md): authoring constraints.
- [Skill structure](skill-structure.md): what belongs in the prompt vs. optional references.
- [Skill template](skill-template.md): minimal starting point.
- [Data flow](data-flow.md): external data and the rs-guard integration.

Run `scripts/validate-skills.sh` after changing the registry or skill files. Run `ruby spec/eval_context_builder_spec.rb` after changing the context builder.
