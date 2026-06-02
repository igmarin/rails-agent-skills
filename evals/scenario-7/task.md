# Document Parser — Model Spec with Shared Behavior

## Problem/Feature Description

The content team has a `Document` model (`app/models/document.rb`) with two instance methods that need test coverage:

- `#parseable?` — returns true if the document's `content_type` is one of `['text/plain', 'text/html', 'application/json']`
- `#word_count` — returns the number of words in the `body` attribute, treating nil body as zero words

Both methods are pure domain logic with no external dependencies. Additionally, there are two other models in the codebase — `Attachment` and `Note` — that include the same `Parseable` concern, so the team wants shared examples that can be reused across these model specs.

Write a spec for `Document` that covers both methods, and define shared examples for the `Parseable` concern that can later be included in `Attachment` and `Note` specs.

## Output Specification

Produce an `answer.md` file containing:
- The complete `Document` model spec file (with path)
- The shared examples file (with path, placed under `spec/support/shared_examples/`)
- TDD proof for at least one of the methods
- Self-audit and resource loading sections
