# Service object skeleton

Purpose: Standard skeleton for service objects in this repo.

Template:

```ruby
# frozen_string_literal: true
class MyService
  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(**kwargs)
    @kwargs = kwargs
  end

  def call
    # Implement behavior
    { success: true, response: {} }
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.first(5).join("\n"))
    { success: false, response: { error: e.message } }
  end
end
```

Notes:
- Return format: { success: bool, response: { ... } }
- Use keyword args and be explicit about inputs.
