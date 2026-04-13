# rails-engine-reviewer examples

Example finding (JSON):

{
  "severity": "high",
  "area": "host-app integration",
  "file": "lib/my_engine/engine.rb",
  "line": 42,
  "risk": "Engine initializer depends on host's `Admin` constant leading to load-order failures",
  "recommendation": "Replace direct constant reference with a configurable adapter or use `defined?` checks and document host contract",
  "proof_of_concept": "Raise occurs during engine load when host doesn't define Admin: NameError: uninitialized constant Admin"
}

Use the schema rails-engine-reviewer/assets/finding-schema.json for structured findings output.