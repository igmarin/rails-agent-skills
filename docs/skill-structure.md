# Canonical SKILL.md Structure

The shape every `SKILL.md` in this library must converge on. The post-eval reinforcement pass uses this document as the audit checklist — if a skill is missing one of these sections, it is under-specified and will be brought into line.

This is the *structural* spec. For *content* principles (when to write a skill, how it should change model behavior), see [skill-design-principles.md](skill-design-principles.md). For the eval-driven loop that decides which skills to reinforce next, see [skill-optimization-guide.md](skill-optimization-guide.md).

---

## The 6 Sections

```text
1. Frontmatter (YAML)
2. Quick Reference         — the bare minimum a model needs to act now
3. HARD-GATE              — non-negotiable blocking rules (always tests-first when code is produced)
4. Core Process           — step-by-step procedure with checkpoints
5. Output Style           — exact shape of artifacts the skill produces
6. Integration            — predecessor / successor skills, doc cross-links
```

Order matters: Quick Reference comes before HARD-GATE so the model sees "what to do" before "what not to do." Output Style comes before Integration so the model knows the deliverable's shape before being handed off downstream.

---

## 1. Frontmatter

Every SKILL.md begins with YAML frontmatter:

```yaml
---
name: rails-something
description: >
  One paragraph. Lead with what the skill does, follow with when to use it,
  end with **trigger words / phrases** the model should pattern-match on.
  This field is the discoverability surface — Tessl, Claude Code, Cursor,
  and Windsurf all use it to route requests.
---
```

**Rules:**
- `name` MUST equal the directory name (validator enforces this).
- `description` is single-paragraph, ≤ ~120 words, ends with a comma-separated list of trigger phrases.
- No other frontmatter keys are required for the cross-platform manifest layer; tile.json carries the rest.

## 2. Quick Reference

A short block — usually a fenced code block or 3–7 bullet points — that lets the model act immediately if it reads nothing else. Examples of what belongs here:

- The minimum command sequence (`rails g`, `bundle exec`, etc.)
- The 1-line decision: "If X, do A. If Y, do B."
- The skill's invariant ("Service objects always return `{ success:, response: }`.")

If a skill has no Quick Reference, the model often skips ahead to Core Process and misses the shortest path.

## 3. HARD-GATE

A **boxed, blocking** statement of what must hold before the model writes any code or returns its final artifact. For every code-producing skill the gate is:

```text
HARD-GATE: Tests Gate Implementation
Implementation code CANNOT be written until:
  1. The test EXISTS
  2. The test has been RUN
  3. The test FAILS for the right reason (feature missing, not a typo)
```

Non-code-producing skills (review skills, planning skills, doc skills) still have a HARD-GATE — usually "do not skip the prior context skill" or "do not output until the deliverable matches Output Style exactly."

The HARD-GATE section must be **scannable**: a 3–6 line block, fenced or quoted, that the model cannot miss while skimming.

## 4. Core Process

The numbered procedure. Includes:

- Explicit **checkpoints** where the skill pauses for user feedback (Test Feedback, Implementation Proposal, Severity Triage — depending on skill).
- Loop bodies (red → green → refactor).
- Branch points ("If the change touches `db/schema.rb`, also load `rails-migration-safety`").

Keep steps imperative ("Write the spec", "Run `bundle exec rspec path/to/spec`") rather than declarative — the skill is an instruction sheet, not documentation of behavior.

## 5. Output Style

The exact shape of every artifact this skill produces. This is the section most often missing today, and it is the biggest baseline-vs-context lever per the [optimization guide](skill-optimization-guide.md). Include:

- Headings, ordering, severity labels (Critical / Suggestion / Nice-to-have).
- Required fields (every PR review must end with a Critical/Suggestion summary; every PRD must include Goals, User Stories, Functional Requirements, Success Metrics).
- Forbidden phrasings ("don't apologize", "no 'just' / 'simply'", "no performative agreement").
- Output language: English unless the user explicitly requests another language.

A skill without Output Style produces wildly different artifacts run-to-run; the eval cannot give it a stable score on the with-context axis.

## 6. Integration

Closes the loop with the rest of the library:

| Field | Content |
|-------|---------|
| **Comes after** | The skill(s) typically invoked before this one. |
| **Comes before** | The next skill in the chain (named, not described). |
| **See also** | Related skills the model should consider but not auto-load. |
| **Workflow refs** | Links to `docs/workflow-guide.md` and the relevant `docs/workflows/NN-*.md` page. |

---

## Validator Coverage

`scripts/validate-plugins.sh` checks the structural pieces the validator can verify deterministically:

- Frontmatter `name` matches directory name
- Frontmatter has `name` and `description` keys
- Skill directory is registered in `tile.json.skills`
- `tile.json ↔ disk` inventory is bidirectionally in sync

The validator does **not** yet enforce the presence of HARD-GATE, Output Style, or Integration sections. Tessl evals catch the behavioural consequences of missing those sections — that is the loop the [optimization guide](skill-optimization-guide.md) describes.

---

## See Also

- [skill-design-principles.md](skill-design-principles.md) — when to create a skill, how it should change model behavior, the 6 design principles.
- [skill-template.md](skill-template.md) — fillable template that already follows this structure.
- [skill-optimization-guide.md](skill-optimization-guide.md) — eval-driven loop for lifting baseline-vs-context scores.
- [architecture.md](architecture.md) — repository layout and `SKILL.md` mechanical conventions.
