# Bulk Inventory Import Service

## Problem/Feature Description

An e-commerce platform's operations team uploads a CSV of product inventory updates once a day. Each row contains a SKU and a new stock level. The import sometimes contains rows with missing SKUs, negative quantities, or SKUs that don't exist in the database. The team wants a service they can call from a background job, an admin controller, or a one-off Rake task. Critically, the service must handle bad rows gracefully: a single bad row should not prevent the remaining rows from being processed, and the caller must always receive a structured result — never a raw exception.

Your job is to write a Ruby service that accepts a list of inventory update hashes (each with `:sku` and `:quantity` keys), processes each one, and returns a result that distinguishes successes from failures. The service must validate each item before attempting any database change, and must handle both expected failures (record not found, negative quantity) and unexpected ones (database connectivity issues) in a controlled way.

## Output Specification

Produce the following files:

- `app/services/<choose_appropriate_module>/<choose_appropriate_name>.rb` — the service implementation
- `spec/services/<mirrored_path>_spec.rb` — RSpec spec covering: all items valid, some items invalid, all items invalid, and an unexpected exception during processing

Do not create a full Rails application. Use stub comments where real ActiveRecord calls would go (e.g. `# TODO: Product.find_by!(sku: sku)`) so the service structure is clear without a running database.
