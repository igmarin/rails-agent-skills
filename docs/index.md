# Rails Agent Skills — documentation (tile)

Reference material for this tile: workflows, authoring, setup, and MCP. Linked from `tile.json` so Tessl validation can reach every doc in `docs/` and the MCP server notes.

**How to read this:** start with the [Workflow guide](workflow-guide.md) if you want to **chain skills** in day-to-day Rails work; use the [Implementation guide](implementation-guide.md) if you are **installing or wiring** the plugin or tile. For a high-level overview of the repository, see the root [README](../README.md).

## Entry skill

- [rails-skills-orchestrator](../rails-skills-orchestrator/SKILL.md) — pick the right skill and enforce the tests-before-implementation gate

## Guides

- [Workflow guide](workflow-guide.md) — chaining skills in typical Rails workflows
- [Architecture](architecture.md) — repository layout and `SKILL.md` structure
- [Implementation guide](implementation-guide.md) — install paths and agent hooks
- [Skill design principles](skill-design-principles.md)
- [Skill optimization guide](skill-optimization-guide.md) — eval-driven loop: baseline-vs-context targets and how to lift skill scores
- [Skill template](skill-template.md)
- [VS Code setup](vs-code-setup.md)
- [Plugin validation](plugin-validation.md)

## MCP server

- [MCP server README](../mcp_server/README.md)
