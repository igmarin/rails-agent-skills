# Rails Engine Docs — Documentation Gaps Checklist

Verify all gaps are covered before finalizing docs:

| Gap | What must be present |
|-----|---------------------|
| Installation | Exact steps: add gem, bundle, run generator, mount route |
| Configuration | All options, defaults, and required vs optional keys |
| Route mounting | Explicit path shown — never implied |
| Migrations | Install generator steps and when to run them |
| Extension points | Adapters and config blocks documented in code but exposed in README |
| Host assumptions | Any required host model, job backend, or auth integration stated explicitly |
| Upgrade notes | Changelog entries for any step that changes on upgrade |
