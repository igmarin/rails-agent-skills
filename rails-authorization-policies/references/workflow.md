# Authorization Implementation Workflow

Step-by-step guide for implementing authorization in Rails applications.

## Step 1: Add Gem

Add to Gemfile:

```ruby
# For Pundit
gem 'pundit'

# For CanCanCan
gem 'cancancan'
```

Run:

```bash
bundle install
```

## Step 2: Generate Policy/Ability

**Pundit:**

```bash
rails g pundit:install
rails g pundit:policy Post
```

**CanCanCan:**

```bash
rails g cancan:ability
```

## Step 3: Define Permissions

Define authorization logic in the generated file. See [EXAMPLES.md](../EXAMPLES.md) for complete code samples.

## Step 4: Authorize in Controller

Add authorization calls to controller actions:

```ruby
def update
  @post = Post.find(params[:id])
  authorize @post        # Pundit
  # or
  authorize! :update, @post  # CanCanCan
  # ...
end
```

## Step 5: Write Tests

Create policy specs and request specs covering all roles. See [EXAMPLES.md](../EXAMPLES.md) for testing patterns.

## Step 6: Validate Coverage

Run all policy specs before deploying:

```bash
bundle exec rspec spec/policies
```

Ensure every role and edge case is explicitly covered.
