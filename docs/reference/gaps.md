# Gaps

What this pack does not cover yet, and known drift.

## Missing skills

| Gap | Why it matters | Notes |
|-----|----------------|-------|
| `setup-ci-cd` | Catalog already marks this critical. `setup` persona mentions CI but there is no atomic skill. | Highest-priority new skill. |
| Mailers | Action Mailer, previews, deliveries in jobs. | No dedicated skill. |
| Active Storage | Uploads, variants, disk vs S3. | No dedicated skill. |
| Cable / Solid Cable | Realtime beyond Turbo Streams. | Partial overlap with `implement-hotwire`. |
| Kamal / credentials | Deploy, secrets, `credentials.yml.enc`. | `setup-environment` must not echo secrets; it does not deploy. |
| Multi-database | `connects_to`, replicas. | — |
| Solid Cache | Cache store as its own concern. | Partial overlap with `optimize-performance`. |
| I18n | Mentioned in review order, no skill. | — |
| Feature flags | Flipper and friends. | — |

Do not add these in the same change as a quality pass.

## Drift

| Item | Status |
|------|--------|
| `respond-to-review` | Moved to `ruby-core-skills`. Slimmed there in `30bcb46`. |
| `create-prd`, `generate-tasks`, `plan-tickets` | Not in this repo. Planning lives in `agnostic-planning-skills` / core `generate-tdd-tasks`. |
| `AGENTS.md` | Now the host-context source. `CLAUDE.md` and `GEMINI.md` are stubs. |
| Description contract | When + triggers, ≤ 600 chars. Opposite of core's "pack every rule into sentence one". |
| `personal-evals/` | Still has scenarios for moved skills (`skill-ruby-service-objects`, `skill-ddd-rails-modeling`). |
| `.claude/worktrees/` | Old copies of renamed skills. Not in `directory.json`. Do not treat as current. |

## Description strategy conflict

`ruby-core-skills/docs/skill-description-strategy.md` Rule 1 still says to pack every hard rule into one period-free sentence. This repo does not. Follow-up: amend that rule in core so authors do not revert slim descriptions.
