---
name: rails-performance-optimization
description: >
  Optimizes Rails application performance. Use when investigating slow endpoints,
  eliminating N+1 queries, implementing caching strategies, profiling with Bullet
  or rack-mini-profiler, or optimizing database queries with EXPLAIN ANALYZE.
  Trigger words: performance, optimize, N+1, slow query, caching, Bullet, profiling.
---

# Rails Performance Optimization

Identify and fix performance bottlenecks in Rails applications.

**Files:** [SKILL.md](./SKILL.md) · [EXAMPLES.md](./EXAMPLES.md) · [references/tools.md](./references/tools.md)

## HARD-GATE

```text
NEVER optimize without a baseline measurement
ALWAYS write a regression spec before optimizing (query count assertion)
ALWAYS verify with EXPLAIN ANALYZE for database changes

REPORT ORDER MUST MATCH WORK ORDER:
  1. Baseline measurement
  2. Bottleneck identification (Bullet / rack-mini-profiler / EXPLAIN)
  3. Regression spec written + run + FAILS at the unoptimized count
  4. Fix applied
  5. Regression spec rerun + PASSES at the optimized count
  6. EXPLAIN ANALYZE confirms plan change

NEVER write the report as "I applied includes(:author), then wrote a spec
to lock it in." The spec MUST be written and shown failing BEFORE the fix
appears in your output. Reordering for narrative flow fails the audit even
when the underlying work was correct.
```

## Tools Quick Reference

| Tool | Use |
|------|-----|
| `bullet` | N+1 detection in development |
| `rack-mini-profiler` | Endpoint timing breakdown |
| `EXPLAIN ANALYZE` | Query plan analysis |

See [references/tools.md](references/tools.md) for detailed configuration.

## Optimization Workflow

1. **Measure baseline** — record current timing
2. **Write regression spec** — assert query count
3. **Identify bottleneck** — use Bullet or rack-mini-profiler
4. **Apply fix** — eager load, caching, or index
5. **Verify** — confirm improvement with EXPLAIN ANALYZE
6. **Validate** — regression spec passes

## N+1 Prevention

```ruby
# Bad
Post.all.each { |p| p.author.name }

# Good
Post.includes(:author).each { |p| p.author.name }
```

## Regression Spec (Query Count Assertion)

Write this spec **before** applying any optimization to lock in the expected query count:

```ruby
RSpec.describe "Post index performance" do
  it "loads posts with authors in a fixed number of queries" do
    create_list(:post, 10, :with_author)

    expect do
      Post.includes(:author).to_a
    end.to make_database_queries(count: 2) # posts + authors
  end
end
```

Use the `db-query-matchers` gem or a custom `make_database_queries` matcher. The spec must pass after the fix and fail if a future change reintroduces the N+1.

## EXPLAIN ANALYZE Verification

Run directly in `rails dbconsole` (PostgreSQL) after applying an index or query change:

```sql
EXPLAIN ANALYZE
  SELECT posts.*, users.name
  FROM posts
  INNER JOIN users ON users.id = posts.author_id
  WHERE posts.published = true;
```

Key things to check in the output:
- `Seq Scan` on large tables → should become `Index Scan` after adding an index
- `actual time` rows — confirm the new value is lower than the baseline
- `rows` estimate accuracy — large discrepancies indicate stale statistics (`ANALYZE table_name`)

## Examples

See [EXAMPLES.md](EXAMPLES.md) for complete examples including:
- N+1 fixes with `includes`, `preload`, `joins`
- Fragment caching and Russian doll caching
- Query optimization with `pluck` and `find_each`
- Regression testing with custom matchers

## Output Style

When asked to investigate or fix a performance issue, your response MUST contain each section below in this order. Each section is graded — skip one and the audit deducts.

1. **Baseline** — current timing or query count, with the source (log line, profiler output, EXPLAIN row).
2. **Bottleneck** — name the specific cause (e.g. "N+1 between `Post#author` and the index loop"). Cite the profiling tool that surfaced it (`bullet`, `rack-mini-profiler`, `EXPLAIN ANALYZE` — at least one MUST be named).
3. **Regression spec — RED** — show the spec file with `make_database_queries(count: <unoptimized_count>)` (or equivalent assertion at the unoptimized number) and explicitly state "spec FAILS at current count" with the failing output. This block appears in the report BEFORE any code change.
4. **Fix** — the minimal code change (eager load, index migration, cache, scope rewrite). Comes AFTER the failing spec block.
5. **Regression spec — GREEN** — update the assertion to the new count (or keep it if the count was the target), rerun, show "spec PASSES at <fixed_count>".
6. **EXPLAIN ANALYZE** — paste the actual output (or relevant rows) for any DB-touching change. Call out `Seq Scan → Index Scan`, `actual time` improvement, or row-count interpretation.
7. **Quantified improvement** — "queries: N → M", "p95: X ms → Y ms", or "rows scanned: A → B". Numbers, not adjectives.

Self-check before sending: in your response, the line containing the regression spec MUST appear earlier in the document than the line containing the fix. If the order is reversed, rewrite the report — even if the underlying work was done correctly.

## Further Reading

- [Rails Performance Guide](https://guides.rubyonrails.org/v4.1/performance_testing.html)
- [Active Record Querying](https://guides.rubyonrails.org/active_record_querying.html)
- [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)
- [Bullet gem](https://github.com/flyerhzm/bullet)
