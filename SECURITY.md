# Security Policy

## Supported Versions

The `rails-agent-skills` catalog is a knowledge registry (Markdown skills, YAML frontmatter, shell hooks, and Ruby utility scripts). It ships no runtime service. Security fixes are applied only to the latest minor line.

| Version | Supported          |
| ------- | ------------------ |
| 7.0.x   | :white_check_mark: |
| < 7.0   | :x:                |

Version is sourced from `directory.json` at the repository root.

## Reporting a Vulnerability

Report security issues **privately** — do not open a public issue.

- **Preferred:** use GitHub Security Advisories (`Security` tab → `Report a vulnerability`).
- **Alternative:** email the maintainer at the address listed on the GitHub profile.

Please include:

- Affected file(s) and line numbers (e.g. `hooks/pre-commit-rs-guard:44`).
- A concrete reproduction or attack scenario.
- Affected version (from `directory.json`).

**Acknowledgement:** within 72 hours. **Status update:** within 7 days. **Disclosure:** target 30 days after a fix is released, coordinated with the reporter. If the report is declined, you will be told why.

## Scope

In scope:

- `hooks/` — SessionStart and pre-commit hooks executed by agent runtimes.
- `scripts/` — install, smoke, and validation scripts (shell + Ruby).
- `.github/workflows/` — CI workflows, including the rs-guard PR review pipeline.
- `bin/rs-guard.manifest` — pinned binary checksum.
- `directory.json`, `skills.sh.json` — registry integrity.

Out of scope (but documented for transparency):

- The upstream `rs-guard` binary itself — report to `nebulaideas/rs-guard`. This repo only pins and verifies its release checksum.
- Skill content quality (handled by `skills/code-quality/security-check/SKILL.md` and the review prompt at `.github/review-prompt.md`).

## Data Flow Disclosure

Two surfaces send repository content to third-party LLM providers:

1. **`hooks/pre-commit-rs-guard`** — sends staged diffs to a configured provider (DeepSeek, OpenAI, Kimi, Qwen, or OpenRouter) on every commit when `RS_GUARD_ENABLED=true` and an API key is set. Disabled by default.
2. **`.github/workflows/rs-guard-review.yml`** — sends PR diffs to DeepSeek and posts review comments on the PR.

See [`docs/data-flow.md`](docs/data-flow.md) for the full data flow, provider list, and opt-out instructions.

## Credential Handling

No credentials, tokens, or API keys are stored in the repository. The `.gitignore` excludes `report.json`, `review-result.txt`, `rs-guard-metrics.json`, and `.rs-guard/` artifacts. Hooks and CI read provider keys from environment variables only.
