# Data Flow Disclosure

This document describes every surface in `rails-agent-skills` that sends repository content to third-party LLM providers, and how to disable each one.

## Why this matters

This repository teaches security discipline (see `skills/code-quality/security-check/SKILL.md`). Two of its own automation surfaces send source code — staged diffs and PR diffs — to external LLM providers. That is a real data-flow concern. Both surfaces are documented here so contributors can make an informed choice.

## Surface 1: Pre-commit hook (`hooks/pre-commit-rs-guard`)

**Status:** DISABLED by default. Opt-in via `RS_GUARD_ENABLED=true`.

**What leaves the machine:** the staged diff (`git diff --cached --unified=5`) is written to a temp file and passed to the `rs-guard` binary, which sends it to a configured LLM provider for review.

**Provider:** read from `.reviewer.toml` (default: `deepseek`, model `deepseek-v4-flash`). The provider API key is read from the environment:

| Provider   | Environment variable  |
|------------|-----------------------|
| DeepSeek   | `DEEPSEEK_API_KEY`    |
| OpenAI     | `OPENAI_API_KEY`      |
| Kimi       | `KIMI_API_KEY`        |
| Qwen       | `DASHSCOPE_API_KEY`   |
| OpenRouter | `OPENROUTER_API_KEY`  |

**Activation conditions (both required):**

1. `RS_GUARD_ENABLED=true` is set in the environment.
2. One of the provider API keys above is present.

If either is missing, the hook exits `0` without calling any external service.

**How to disable:**

- Unset `RS_GUARD_ENABLED`, or set `RS_GUARD_ENABLED=false`.
- Remove the hook from `hooks/hooks.json` (delete the `PreCommit` block).
- Do not set any provider API key in your environment.

**How to enable:**

```bash
export RS_GUARD_ENABLED=true
export DEEPSEEK_API_KEY=sk-...   # or another provider's key
git commit -m "..."              # hook runs rs-guard --dry-run, prints advisory review
```

The hook always runs with `--dry-run` and never blocks the commit. Output is informational only.

## Surface 2: CI PR review (`.github/workflows/rs-guard-review.yml`)

**Status:** active on every non-draft pull request.

**What leaves the machine:** the PR diff is sent to DeepSeek via `rs-guard`, and the review is posted as a comment on the PR.

**Provider:** DeepSeek (`DEEPSEEK_API_KEY` secret from the repository).

**How to disable:**

- Remove the workflow file `.github/workflows/rs-guard-review.yml`, or
- Gate it behind a label or path filter by editing the `on:` trigger.

**Permissions:** the workflow uses `permissions: contents: read, pull-requests: write` and `actions/checkout` pinned to a commit SHA with `persist-credentials: false`. It falls back to `GH_PAT` if `GITHUB_TOKEN` is unavailable.

## Surface 3: Binary download (`scripts/rs-guard-install.sh`)

**Status:** runs in CI and locally when invoked.

**What leaves the machine:** an HTTP GET to `https://github.com/nebulaideas/rs-guard/releases/download/<version>/<asset>` to download the `rs-guard` binary. No repository content is sent. The download is verified against a pinned SHA256 in `bin/rs-guard.manifest`.

**How to disable:** do not run `scripts/rs-guard-install.sh` locally; in CI, remove the workflow step.

## Verification

- `RS_GUARD_ENABLED` is not set by any script in this repository. It must be provided by the user's environment.
- No API keys are stored in the repository. `.gitignore` excludes `report.json`, `review-result.txt`, `rs-guard-metrics.json`, and `.rs-guard/` artifacts.
- The `security-check` skill's credential-handling hard gate applies to skill output, not to this repo's own automation — this document is the equivalent disclosure for the repo's own data flow.
