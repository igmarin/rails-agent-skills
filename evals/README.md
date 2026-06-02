# Eval Scenarios — Tessl Plugin Mode

This directory contains Tessl eval scenarios for the publishable skills in `directory.json`.

Tessl currently validates skills, not repository personas. Do not add `personas/**` scenarios here.

## Directory Roles

| Path | Role |
|------|------|
| `evals/` | Tracked Tessl-native eval scenarios. Auto-discovered by Tessl CLI in plugin mode. |
| `personal-evals/` | Tracked examples for the `ruby-skill-bench` full-context evaluator. Not Tessl input. |

## Run Evals

```bash
tessl eval run . --agent "claude:claude-sonnet-4-6"
```

## Generate/Local Evals

```bash
tessl scenario generate .
```

## Validate

```bash
ruby scripts/validate-tessl-evals.rb   # if script exists
```

See [docs/eval-provenance.md](docs/eval-provenance.md) for the canonical eval ownership policy.
