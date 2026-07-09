# Eval Provenance Policy

This repository uses one public eval source area.

| Path | Purpose | Commit policy |
|------|---------|---------------|
| `personal-evals/` | Open examples for the `ruby-skill-bench` full-context evaluator. | Tracked. |

`ruby-skill-bench` is planned as a Ruby gem for validating skills and workflows with full context. Its `personal-evals/` examples load `SKILL.md` plus companion resources as XML.

Generated scenarios from third-party services or private workflows must stay out of tracked paths. Store them locally in ignored directories such as `private-evals/` when needed for private validation.

Public eval examples must meet one of these criteria:

- They are authored specifically for this repository and released under the repository license.
- They are derived from a permissively licensed source, with attribution and license notes included beside the example.

Do not rename generated scenarios to make them look original. Provenance must describe where the scenario came from and why it can be redistributed.
