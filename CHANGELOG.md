# Changelog

All notable changes to this repository will be documented in this file.

This project uses semantic versioning for published skill-library releases.

## [Unreleased]

### Changed

- Converted repository to a pure Agent Skills registry.
- Removed MCP server, Docker, Cloudflare, and CI files to focus strictly on skill distribution via `npx skills`.
- Evicted language-agnostic planning skills (`create-prd`, `generate-tasks`, `plan-tickets`).

## [5.1.5] - 2026-05-11

### Added

- Added a Cloudflare Workers Streamable HTTP MCP server for hosted integrations such as Smithery.
- Added a GitHub Actions workflow to validate and deploy the Cloudflare MCP server from `cloudflare_mcp/`.
- Documented the Cloudflare Worker MCP endpoint, health check, server card, and required deploy secrets.
- Added structured MCP output schemas, tool annotations, and `list_skills` discovery metadata for better registry quality.

### Changed

- Reworked public documentation around MCP-first usage, eval ownership, and the current release line.
- Updated public install examples to the `5.1.5` release line.
- Reinforced the first Tessl worst-score skill batch with clearer Output Style guidance.

## [5.1.3] - 2026-05-11

### Fixed

- Fixed Docker deploy metadata for the MCP server release flow.
- Removed the invalid package-level version field from MCP Registry package metadata.
- Updated the MCP registry follow-up plan after the Docker deploy fix.

## [5.1.2] - 2026-05-11

### Added

- Added official MCP Registry publishing support for `io.github.igmarin/rails-agent-skills-mcp`.
- Added root `server.json` metadata for the official MCP Registry.
- Added Docker image ownership metadata required by the MCP Registry.

## [5.1.1] - 2026-05-11

### Fixed

- Fixed Tessl eval staging and asset links used by the publish/review workflows.
- Updated Tessl review and publish workflow behavior for staged eval assets.
- Clarified Tessl eval handling in `tessl-evals/README.md`.

## [5.0.0] - 2026-05-08

### Added

- Added required `metadata.json` files for all current `personal-evals` scenarios.
- Added metadata validation to `scripts/validate-evals.sh`, including target skill/workflow resolution.
- Added `personal-evals/schema.json` as the metadata contract for custom evaluator scenarios.
- Added XML context bundle generation with `scripts/eval_context_builder.rb`.
- Added test coverage for XML context generation.
- Added `plans/personal-evals-and-custom-evaluator.md` to preserve the custom evaluator plan.

### Changed

- Clarified that `personal-evals/` is the tracked source for open custom evaluator examples.
- Clarified that root `evals/` is generated Tessl staging output and must not be committed.
- Updated eval documentation to describe `skill_bundle_xml` context: `SKILL.md` plus companion resources.
- Updated CodeQL configuration to ignore intentionally messy `personal-evals/**` fixture code.

### Removed

- Removed committed root `evals/` scenarios by moving them into `personal-evals/`.

### Validation

- `rtk bash scripts/validate-evals.sh`
- `ruby scripts/test/eval_context_builder_test.rb`
- `rtk bash scripts/validate-plugins.sh`
- `cd mcp_server && rtk bundle exec rake test`
