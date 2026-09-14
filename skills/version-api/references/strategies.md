# Versioning Strategies Comparison

Compare URL path vs header-based versioning approaches.

## URL Path Versioning

**Format:** `/api/v1/users`, `/api/v2/users`

### Pros
- Simple and explicit
- Easy to test and debug
- Cache-friendly
- API documentation generators support it well

### Cons
- URL changes with each version
- Breaking REST "permanent URL" principle
- Clients must update URLs

### Best For
- Public APIs with external consumers
- APIs where version must be obvious
- Simple deployment and testing

## Header Versioning

**Format:** `Accept: application/json; version=2`

### Pros
- Clean URLs (no version in path)
- More "RESTful"
- Easy to add version negotiation
- URL bookmarks remain valid across versions

### Cons
- Harder to test (must set headers)
- Not visible in URL
- Some caching proxies may ignore headers
- More complex client implementation

### Best For
- Internal APIs
- APIs with sophisticated clients
- When URL stability is important

## Recommendation

**Use URL path versioning for most Rails APIs.** It's simpler, more explicit, and easier to maintain. Only use header versioning when URL stability is a critical requirement.

## Hybrid Approach

Support both for maximum flexibility:

```ruby
# config/routes.rb
namespace :api do
  # Default version when not specified
  namespace :v1 do
    resources :users
  end
end

# In controller or concern
def api_version
  # Check header first, fall back to URL path
  header_version = request.headers['Accept']&.match(/version=(\d+)/)&.to_a&.last
  path_version = params[:version]
  header_version || path_version || '1'
end
```
