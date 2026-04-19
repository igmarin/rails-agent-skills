# Performance Optimization Examples

Complete examples for identifying and fixing performance bottlenecks.

## N+1 Query Fixes

### The Problem

```ruby
# Bad - N+1 query
Post.all.each do |post|
  puts post.author.name  # Query for each author!
end
# => 1 query for posts + N queries for authors
```

### The Fix: Eager Loading

```ruby
# Good - includes eager loads
Post.includes(:author).each do |post|
  puts post.author.name
end
# => 2 queries total (posts + authors)

# For nested associations
Post.includes(author: :profile, comments: :user).each do |post|
  puts post.author.name
  puts post.author.profile.bio
  post.comments.each { |c| puts c.user.name }
end
```

### Preload vs Eager Load vs Joins

```ruby
# Use includes (eager load) - separate queries, works with all associations
Post.includes(:author).where("authors.name LIKE ?", "%John%").references(:author)

# Use preload - always separate queries, ignores conditions on associations
Post.preload(:author).where(published: true)

# Use joins - single query with INNER JOIN, duplicates parent rows
Post.joins(:comments).where(comments: { approved: true }).distinct

# Use left_outer_joins - includes records without associations
Post.left_outer_joins(:comments).where(comments: { id: nil }) # posts without comments
```

## Caching Examples

### Fragment Caching

```erb
<%# app/views/posts/show.html.erb %>
<% cache @post do %>
  <h1><%= @post.title %></h1>
  <p><%= @post.body %></p>
  <p>By <%= @post.author.name %></p>
<% end %>
```

### Russian Doll Caching

```erb
<%# app/views/posts/show.html.erb %>
<% cache @post do %>
  <article>
    <h1><%= @post.title %></h1>

    <% cache ["comments", @post.comments.maximum(:updated_at)] do %>
      <section class="comments">
        <%= render @post.comments %>
      </section>
    <% end %>
  </article>
<% end %>
```

### Collection Caching

```erb
<%# app/views/posts/index.html.erb %>
<%= render partial: "post", collection: @posts, cached: true %>
```

### Low-Level Caching

```ruby
# Expensive computation cache
def calculate_user_score(user_id)
  Rails.cache.fetch("user_score/#{user_id}", expires_in: 1.hour) do
    ExpensiveScoreCalculator.call(user_id)
  end
end

# With race condition protection
Rails.cache.fetch("hot_data", race_condition_ttl: 10.seconds) do
  fetch_from_slow_api
end
```

## Query Optimization

### Select Specific Columns

```ruby
# Bad - loads all columns
User.all.map(&:id)

# Good - only load id
User.pluck(:id)

# Multiple columns
User.pluck(:id, :email, :name)

# With conditions
User.where(active: true).pluck(:email)
```

### Batch Processing

```ruby
# Bad - loads all into memory
User.all.each do |user|
  user.update!(last_seen: Time.now)
end

# Good - process in batches
User.find_each(batch_size: 100) do |user|
  user.update!(last_seen: Time.now)
end

# With start point for resuming
User.where("id > ?", last_processed_id).find_each do |user|
  process(user)
end
```

### EXPLAIN ANALYZE

```ruby
# Check query plan in Rails console
puts User.where(email: 'test@example.com').explain

# Detailed analysis
result = ActiveRecord::Base.connection.execute(<<-SQL)
  EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
  SELECT * FROM posts WHERE user_id = 1
SQL
puts JSON.pretty_generate(JSON.parse(result.first["QUERY PLAN"]))
```

## Bullet Configuration

```ruby
# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true          # JavaScript alert
  Bullet.bullet_logger = true  # Log to bullet.log
  Bullet.console = true        # Browser console
  Bullet.rails_logger = true   # Rails log
  Bullet.add_footer = true     # Add footer to HTML
end
```

## Regression Testing

```ruby
# spec/requests/posts_spec.rb
RSpec.describe "Posts", type: :request do
  it "does not produce N+1 queries" do
    create_list(:post, 5, :with_author)

    expect {
      get posts_path
    }.to make_database_queries(count: 3)  # posts + authors + count
  end
end
```

### Custom Query Counter Matcher

```ruby
# spec/support/matchers/query_count.rb
RSpec::Matchers.define :make_database_queries do |count:|
  match do |block|
    query_count = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*|
      query_count += 1
    end

    block.call
    query_count == count
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
```
