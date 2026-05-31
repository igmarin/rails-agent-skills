# Complete Example: Write Tests Task (answer.md)

Use this complete, production-ready example to format your output when asked to write or verify RSpec tests.

***

# Plan

1. **Identify the Smallest Boundary**: The task requires marking unpaid invoices overdue when their due date passes. Since this involves database query, state transition, and persistence logic, a **PORO Service Spec** (`spec/services/invoices/mark_overdue_spec.rb`) is the smallest strong boundary that fully isolates this domain behavior.
2. **Draft the Spec First**: Write the spec checking for state transition (`change { invoice.reload.overdue? }.from(false).to(true)`) and ignoring unrelated fields.
3. **Execute TDD RED Gate**: Run the spec command and capture the specific constant lookup failure (`NameError: uninitialized constant Invoices::MarkOverdue`).
4. **Implement Minimal Code**: Create the service class to satisfy the validations and pass the spec.
5. **Execute TDD GREEN Gate**: Re-run the spec to confirm passing status, and run the broader suite to ensure no regressions.
6. **Apply Code Conventions & Linting**: Audit the output against the 18-point checklist and ensure RuboCop passes.

***

# Concrete Artifacts

### 1. Spec File
`# spec/services/invoices/mark_overdue_spec.rb`
```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoices::MarkOverdue do
  describe '.call' do
    subject(:result) { described_class.call(invoice: invoice) }

    context 'when the invoice is unpaid and past its due date' do
      let(:invoice) { create(:invoice, due_date: 2.days.ago, paid_at: nil) }

      it 'marks the invoice overdue' do
        expect { result }.to change { invoice.reload.overdue? }.from(false).to(true)
      end
    end

    context 'when the invoice is already paid' do
      let(:invoice) { create(:invoice, due_date: 2.days.ago, paid_at: Time.current) }

      it 'does not mark the invoice overdue' do
        expect { result }.not_to change { invoice.reload.overdue? }
      end
    end
  end
end
```

### 2. Implementation File
`# app/services/invoices/mark_overdue.rb`
```ruby
# frozen_string_literal: true

module Invoices
  class MarkOverdue
    def self.call(invoice:)
      return { success: false, error: 'Invoice already paid' } if invoice.paid_at.present?

      if invoice.due_date < Time.current
        invoice.update!(overdue: true)
        { success: true }
      else
        { success: false, error: 'Invoice not yet due' }
      end
    end
  end
end
```

***

# TDD Execution Proof

### 1. Observed RED Output

**Run Command:**
```bash
bundle exec rspec spec/services/invoices/mark_overdue_spec.rb
```

**Output:**
```text
An error occurred while loading ./spec/services/invoices/mark_overdue_spec.rb.
Failure/Error:
  RSpec.describe Invoices::MarkOverdue do

NameError:
  uninitialized constant Invoices::MarkOverdue
# ./spec/services/invoices/mark_overdue_spec.rb:5:in `<top (required)>'

Finished in 0.00005 seconds (files took 0.12 seconds to load)
0 examples, 0 failures, 1 error occurred outside of examples
```

### 2. Observed GREEN Output

**Run Command:**
```bash
bundle exec rspec spec/services/invoices/mark_overdue_spec.rb
```

**Output:**
```text
..

Finished in 0.02415 seconds (files took 1.25 seconds to load)
2 examples, 0 failures
```

***

# Verification & Quality Gates

| Check Level | Command | Expected Outcome |
| :--- | :--- | :--- |
| **Focused Spec** | `bundle exec rspec spec/services/invoices/mark_overdue_spec.rb` | `2 examples, 0 failures` |
| **Full File** | `bundle exec rspec spec/services/invoices/mark_overdue_spec.rb` | `2 examples, 0 failures` |
| **Broader Suite** | `bundle exec rspec` | `42 examples, 0 failures` |
| **Code Linter** | `bundle exec rubocop app/services/invoices/mark_overdue.rb` | `no offenses detected` |

***

# Assumptions

1. **ActiveRecord Persistence**: Assumes `Invoice` has attributes `due_date:datetime`, `paid_at:datetime`, and `overdue:boolean` (default: false), matching the schema.
2. **FactoryBot Setup**: Assumes `:invoice` factory is registered and defaults to active, unpaid records.
3. **Time-Cop Safety**: Assumes the test suite uses `travel_to` for testing boundary conditions rather than setting static past dates in `let` without time freezing.
4. **Environment**: This test suite and implementation are verified against standard RSpec 3.x and Rails 7.x/8.x configurations.

***

# Self-Audit Checklist

- [x] No `it`/`specify` descriptions contain the word "and".
- [x] Every `let!` is justified (none used here as lazy `let` is sufficient).
- [x] Time-dependent records are created with dynamic attributes (`2.days.ago`).
- [x] Factories use minimal persistent setup.
- [x] All public APIs documented in English.
