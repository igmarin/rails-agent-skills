# Skill Graph

Generated from `directory.json`, `skills.sh.json`, and each skill's `## Integration` table. Run `./scripts/render-skill-graph.sh` to regenerate.

## Catalog Graph

```mermaid
graph LR
  subgraph API
    generate-api-collection
    implement-graphql
  end
  subgraph Code_Quality
    apply-code-conventions
    apply-stack-conventions
    code-review
    implement-authorization
    refactor-code
    review-architecture
    security-check
  end
  subgraph Context
    load-context
    setup-environment
  end
  subgraph Engines
    create-engine
    create-engine-installer
    document-engine
    extract-engine
    release-engine
    review-engine
    test-engine
    upgrade-engine
  end
  subgraph Infrastructure
    implement-background-job
    implement-hotwire
    optimize-performance
    review-migration
    seed-database
    version-api
  end
  subgraph Testing
    plan-tests
    test-service
    write-tests
  end
  subgraph Personas
    tdd
    review
    setup
    quality
    engine
    bug-fix
    graphql
    migration
    background-job
  end
  apply-code-conventions --> apply-stack-conventions
  apply-code-conventions --> implement-background-job
  apply-code-conventions --> write-tests
  apply-code-conventions --> security-check
  apply-code-conventions --> code-review
  apply-stack-conventions --> apply-code-conventions
  apply-stack-conventions --> code-review
  apply-stack-conventions --> write-tests
  apply-stack-conventions --> review-architecture
  background-job --> load-context
  background-job --> tdd
  code-review --> review-architecture
  code-review --> review-migration
  create-engine --> test-engine
  create-engine --> review-engine
  create-engine --> document-engine
  create-engine --> create-engine-installer
  create-engine --> generate-api-collection
  document-engine --> create-engine
  document-engine --> create-engine-installer
  document-engine --> release-engine
  document-engine --> generate-api-collection
  extract-engine --> create-engine
  extract-engine --> test-engine
  extract-engine --> refactor-code
  generate-api-collection --> create-engine
  generate-api-collection --> version-api
  implement-authorization --> write-tests
  implement-background-job --> review-migration
  implement-background-job --> security-check
  implement-background-job --> write-tests
  implement-graphql --> plan-tests
  implement-graphql --> write-tests
  implement-graphql --> security-check
  implement-hotwire --> write-tests
  implement-hotwire --> apply-stack-conventions
  implement-hotwire --> code-review
  optimize-performance --> write-tests
  optimize-performance --> review-migration
  release-engine --> document-engine
  release-engine --> upgrade-engine
  release-engine --> test-engine
  review-architecture --> code-review
  review-engine --> create-engine
  review-engine --> test-engine
  review-engine --> upgrade-engine
  review-migration --> code-review
  review-migration --> implement-background-job
  review-migration --> security-check
  security-check --> code-review
  security-check --> review-architecture
  security-check --> review-migration
  seed-database --> write-tests
  seed-database --> review-migration
  setup-environment --> load-context
  tdd --> load-context
  test-engine --> create-engine
  test-engine --> review-engine
  test-engine --> write-tests
  test-service --> write-tests
  test-service --> test-engine
  upgrade-engine --> test-engine
  upgrade-engine --> create-engine
  upgrade-engine --> release-engine
  version-api --> generate-api-collection
  version-api --> test-engine
```

## Notes

- Edges are drawn from each skill's `## Integration` table (predecessor/successor references).
- Only local skills in `directory.json` appear as nodes. Skills moved to `ruby-core-skills` (see `deprecated_skills` in `directory.json`) are not drawn — they live in a separate repo.
- Self-references are skipped. Duplicate edges are not deduplicated by Mermaid.
- Regenerate with `./scripts/render-skill-graph.sh`. Run `./scripts/render-skill-graph.sh --check` in CI to fail on drift.
