---
name: optimize-performance
license: MIT
description: >
  Optimizes Rails performance with a mandated workflow — measure baseline FIRST, write a regression spec asserting query count with a `make_database_queries` matcher and show it FAILING BEFORE any fix, apply the minimal optimization (eager load/index/cache), re-run the spec to confirm PASSES at the new count, then verify with EXPLAIN ANALYZE confirming plan change (Seq Scan→Index Scan), report output order MUST strictly match work order: measure→identify bottleneck with Bullet or rack-mini-profiler→RED regression spec→fix→GREEN regression spec→EXPLAIN ANALYZE→quantified improvement (queries: N→M, p95: Xms→Yms). Use when investigating slow endpoints, eliminating N+1 queries, implementing caching strategies, profiling with Bullet or rack-mini-profiler, or optimizing database queries with EXPLAIN ANALYZE. Trigger words: performance, optimize, N+1, slow query, caching, Bullet, profiling.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Optimize Performance

Identify and fix performance bottlenecks in Rails applications.

## Quick Reference

| Tool | Use |
|------|-----|
| `bullet` | N+1 detection in development |
| `rack-mini-profiler` | Endpoint timing breakdown |
| `EXPLAIN ANALYZE` | Query plan analysis |

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

## Core Process

1. **Measure baseline** — record current timing
2. **Write regression spec** — assert query count
3. **Identify bottleneck** — use Bullet or rack-mini-profiler
4. **Apply fix** — eager load, caching, or index
5. **Verify** — confirm improvement with EXPLAIN ANALYZE
6. **Validate** — regression spec passes

## Extended Resources

**N+1 Prevention**
```ruby
# Bad
Post.all.each { |p| p.author.name }

# Good
Post.includes(:author).each { |p| p.author.name }
```

**Regression Spec (Query Count Assertion)**
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

**EXPLAIN ANALYZE Verification**
Run directly in `rails dbconsole` (PostgreSQL) after applying an index or query change:
```sql
EXPLAIN ANALYZE
  SELECT posts.*, users.name
  FROM posts
  INNER JOIN users ON users.id = posts.author_id
  WHERE posts.published = true;
```

- [SKILL.md](./SKILL.md)
- [EXAMPLES.md](./EXAMPLES.md)
- [references/tools.md](./references/tools.md)
- [Rails Performance Guide](https://guides.rubyonrails.org/v4.1/performance_testing.html)
- [Active Record Querying](https://guides.rubyonrails.org/active_record_querying.html)
- [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)
- [Bullet gem](https://github.com/flyerhzm/bullet)

## Output Style

1. **Baseline** — timing or query count with source (log line, profiler output, EXPLAIN row).
2. **Bottleneck** — specific cause + the tool that surfaced it (`bullet`, `rack-mini-profiler`, or `EXPLAIN ANALYZE` — at least one named).
3. **Regression spec — RED** — spec with `make_database_queries(count: <unoptimized>)`, shown failing.
4. **Fix** — minimal code change (eager load, index, cache, scope rewrite).
5. **Regression spec — GREEN** — rerun output at the new count.
6. **EXPLAIN ANALYZE** — actual output rows for any DB-touching change; call out `Seq Scan → Index Scan` or `actual time` delta.
7. **Quantified improvement** — `queries: N → M`, `p95: X ms → Y ms`. Numbers, not adjectives.
8. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | For regression specs |
| **review-migration** | When adding an index |
