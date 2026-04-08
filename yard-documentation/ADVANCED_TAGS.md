# Advanced YARD Tags

Reference for less common YARD tags used in Rails and Ruby engine development.

## @abstract

Marks a method intended to be overridden by subclasses.

```ruby
# @abstract Subclass must implement this to return the queue name.
# @return [String]
def queue_name
  raise NotImplementedError
end
```

## @deprecated

Signals that a method or class should not be used in new code.

```ruby
# @deprecated Use {NewService.call} instead. Will be removed in v3.0.
def old_method
```

## @api private

Documents that a method is part of the private API and may change without notice.

```ruby
# @api private
def internal_reset!
```

## @yield / @yieldparam / @yieldreturn

Documents blocks accepted by a method.

```ruby
# Iterates over each result, yielding the record.
# @yield [record] each result record
# @yieldparam record [ActiveRecord::Base] a single result
# @yieldreturn [void]
def each_result(&block)
```

## @overload

Documents multiple signatures for the same method.

```ruby
# @overload find(id)
#   @param id [Integer] the record ID
#   @return [User]
# @overload find(ids)
#   @param ids [Array<Integer>] multiple IDs
#   @return [Array<User>]
def find(id_or_ids)
```
