---
name: optimize-performance
license: MIT
description: >
  Use when optimizing Rails performance — must follow a strict workflow where the report order matches the work order (measure baseline, identify bottleneck, write and run failing RED regression spec asserting query count using db-query-matchers, apply fix, verify spec is GREEN, check with EXPLAIN ANALYZE in rails dbconsole, and report quantified improvements), and write the regression spec before applying any optimization. Caching, Bullet, profiling, slow query, database query. Trigger words: performance, optimize, N+1, slow query, caching, Bullet, profiling.
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

NEVER write the report as "I applied includes(:author), then wrote a spec
to lock it in." The spec MUST be written and shown failing BEFORE the fix
appears in your output. Reordering for narrative flow fails the audit even
when the underlying work was correct.
```

**Required report order — each step must appear in output:**

1. **Baseline** — timing or query count with source (log line, profiler output, EXPLAIN row).
2. **Bottleneck** — specific cause + the tool that surfaced it (`bullet`, `rack-mini-profiler`, or `EXPLAIN ANALYZE` — at least one named).
3. **Regression spec — RED** — spec asserting the target/optimized query count (e.g. `expect { ... }.to make_database_queries(count: <optimized_count>)` where `optimized_count` is the expected count after the fix), shown failing on the unoptimized code (since the unoptimized code executes more queries than the target count).
4. **Fix** — minimal code change (eager load, index, cache, scope rewrite).
5. **Regression spec — GREEN** — rerun output at the new count (confirming that with the fix applied, the exact same spec asserting the target/optimized count now passes).
6. **EXPLAIN ANALYZE** — actual output rows for any DB-touching change; call out `Seq Scan → Index Scan` or `actual time` delta.
7. **Quantified improvement** — `queries: N → M`, `p95: X ms → Y ms`. Numbers, not adjectives.


Language: English unless explicitly requested otherwise.

## Extended Resources

**Less-Obvious Optimizations**
```ruby
# Use pluck to avoid loading full objects when only a column is needed
Post.where(published: true).pluck(:id, :title)

# Use select to limit loaded columns on large tables
Post.select(:id, :title, :author_id).where(published: true)

# Use counter_cache to avoid COUNT queries in loops
# In migration: add_column :users, :posts_count, :integer, default: 0
# In Post model: belongs_to :user, counter_cache: true
user.posts_count  # no extra query
```

**Regression Spec (Query Count Assertion)**
```ruby
# In the regression spec, execute the controller action or query block that triggers the N+1,
# and assert the target/optimized query count.
RSpec.describe "Post index performance" do
  it "loads posts with authors in a fixed number of queries" do
    create_list(:post, 10, :with_author)

    # In the RED phase (before fix), this triggers 11 queries.
    # Since we assert count: 2, this spec will FAIL (producing a RED result).
    # In the GREEN phase (after fix), it executes only 2 queries and passes.
    expect do
      get posts_path
    end.to make_database_queries(count: 2) # target: 1 posts query + 1 authors query
  end
end
```
Use the `db-query-matchers` gem or a custom `make_database_queries` matcher.

**EXPLAIN ANALYZE Verification**
Run directly in `rails dbconsole` (PostgreSQL) after applying an index or query change:
```sql
EXPLAIN ANALYZE
  SELECT posts.*, users.name
  FROM posts
  INNER JOIN users ON users.id = posts.author_id
  WHERE posts.published = true;
```

- [Active Record Querying](https://guides.rubyonrails.org/active_record_querying.html)
- [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)
- [Bullet gem](https://github.com/flyerhzm/bullet)

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | For regression specs |
| **review-migration** | When adding an index |
