# Tessl Eval Source

This directory contains tracked, Tessl-native eval scenario source for the publishable skills listed in `tile.json`.

Tessl currently validates skills, not repository agents. Do not add `agents/**` scenarios here.

## Directory Roles

| Path | Role |
|------|------|
| `tessl-evals/` | Tracked source for Tessl-native skill scenarios. |
| `evals/` | Generated Tessl staging output. It is ignored and must not be committed. |
| `personal-evals/` | Tracked examples for the upcoming `ruby-skill-bench` full-context evaluator. Not Tessl input. |

## Stage Tessl Scenarios

Before publishing, run:

```bash
ruby scripts/stage-tessl-evals.rb
```

The staging script flattens each tracked `tessl-evals/<skill>/scenario-0/` directory into `evals/<skill>/` because Tessl expects every direct child of `evals/` to be a runnable scenario with `task.md`, `criteria.json`, and `capability.txt`.

## Validate Tessl Coverage

```bash
ruby scripts/validate-tessl-evals.rb
```

## Regenerate Baseline Scenarios

```bash
ruby scripts/generate-tessl-evals.rb
```

See [../docs/eval-provenance.md](../docs/eval-provenance.md) for the canonical eval ownership policy.
