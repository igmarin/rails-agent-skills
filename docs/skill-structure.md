# Skill file structure

Each registry entry points to one `SKILL.md` with YAML front matter (`name`, `type`, `description`) and the shortest procedure that completes its task. Add headings only when they make a decision or action easier to find; there is no required six-section shape.

Keep `SKILL.md` self-sufficient for required actions. Link optional examples or reference material with a clear instruction to load it only when needed. The context builder includes only the primary `SKILL.md`; it does not follow links.

Use a human-readable description that names the task and its trigger. Keep rules concrete, avoid copying shared Ruby/agent contracts, and require proof only where the task changes behavior or carries material risk.
