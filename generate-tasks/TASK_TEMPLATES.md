# Task List Templates

## Detailed Checklist

```markdown
# Task List: [Feature Name]

Based on: `prd-[feature-name].md` *(only if PRD was the source)*

## Relevant Files

- `path/to/file1.ext` - Why this file is relevant.
- `path/to/file1.spec.ext` (or `.test.ext`) - Tests for file1.
- `path/to/file2.ext` - Why this file is relevant.

### Notes

- Tests live next to or mirror the code they cover.
- Run tests: `[project's test command]` *(replace with project's test command)*
- After green tests: add YARD on public Ruby API, update README/diagrams/docs as needed, then self code review before PR.

## Instructions for Completing Tasks

Check off each task when done: change `- [ ]` to `- [x]`. Update the file after each sub-task, not only after a full parent task.

## Tasks

- [ ] 0.0 Create feature branch
  - [ ] 0.1 Create and checkout branch (e.g. `git checkout -b feature/[feature-name]`)
- [ ] 1.0 [Parent task title]
  - [ ] 1.1a Write spec for [behavior] (`spec/path/to/spec.rb`)
  - [ ] 1.1b Run spec — verify it fails (feature does not exist yet)
  - [ ] 1.1c Implement [behavior] to pass spec (`app/path/to/file.rb`)
  - [ ] 1.1d Run spec — verify it passes and no other tests break
- [ ] 2.0 [Parent task title]
  - [ ] 2.1a Write spec for [behavior] (`spec/path/to/spec.rb`)
  - [ ] 2.1b Run spec — verify it fails (feature does not exist yet)
  - [ ] 2.1c Implement [behavior] to pass spec (`app/path/to/file.rb`)
  - [ ] 2.1d Run spec — verify it passes
- [ ] 3.0 YARD and public API documentation
  - [ ] 3.1 Add YARD to new/changed public classes and methods (`app/path/to/file.rb`) — English only
  - [ ] 3.2 Run `yard doc` or project doc task if applicable — fix warnings on touched files
- [ ] 4.0 Update documentation artifacts
  - [ ] 4.1 Update README or module README if behavior or setup changed (`README.md` or `docs/...`)
  - [ ] 4.2 Update diagrams or architecture docs if flows or boundaries changed (`docs/...`, ADRs)
- [ ] 5.0 Code review before merge
  - [ ] 5.1 Self-review full diff (rails-code-review checklist); fix Critical/Suggestion items
  - [ ] 5.2 Security/architecture pass if scope warrants (rails-security-review, rails-architecture-review)
  - [ ] 5.3 Open PR or request review — attach summary of doc/YARD updates
```

## Phased Plan

```markdown
# Implementation Plan: [Feature Name]

Based on: `prd-[feature-name].md` *(only if PRD was the source)*

## Work Type

- Rails monolith / engine / API-only / external integration

## Phases

### Phase 1: [Goal]
- Target behavior:
- First failing spec:
- Likely files:
- Dependencies / decisions:

### Phase 2: [Goal]
- Target behavior:
- First failing spec:
- Likely files:
- Dependencies / decisions:

## Completion

- YARD updates
- README / diagrams / docs updates
- Self-review with follow-up skills
```
