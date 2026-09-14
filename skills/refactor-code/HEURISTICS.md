# Refactor Safety Heuristics

Use this file as a review checklist during structural changes.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Quick refactor, no tests needed" | No characterization tests means no safety net. |
| Mixing behavior change with structural change | Mixed intent is hard to validate and review. |
| Renaming many call sites in one commit | Do small batches with tests between batches. |
| Adding abstractions just to match a pattern | Abstractions must serve a real boundary. |
| Deleting old path before proving new path | Keep temporary compatibility until migration is complete. |

## Red Flags

- Plan touches many unrelated call sites at once.
- No tests prove current behavior before starting.
- Structural cleanup is mixed with new feature work.
- Old and new paths diverge without migration plan.
- New abstractions exist only for pattern purity.
- More than 3 refactor steps without running tests.
- Language like "should", "probably", "seems to" when claiming test success.

## Review Prompts

- What behavior is explicitly declared as stable?
- Which exact tests protect each refactor step?
- What temporary compatibility code exists, and when will it be removed?
- What is the smallest next reversible step?
