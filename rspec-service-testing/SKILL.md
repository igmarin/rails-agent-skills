---
name: rspec-service-testing
description: >
  Use when writing RSpec tests for service objects, API clients, orchestrators, or
  business logic in spec/services/. Covers instance_double, FactoryBot hash factories,
  shared_examples, subject/let blocks, context/describe structure, aggregate_failures,
  change matchers, travel_to, and error scenario testing.
---

# RSpec Service Testing

Use this skill when writing tests for service classes under `spec/services/`.

**Core principle:** Test the public contract (`.call`, `.find`, `.search`), not internal implementation. Use instance_double for isolation, create for integration.

## Quick Reference

| Aspect | Rule |
|--------|------|
| File location | `spec/services/module_name/service_spec.rb` |
| Subject | `subject(:service_call) { described_class.call(params) }` |
| Unit tests | `instance_double` for collaborators |
| Integration | `create` for DB-backed tests |
| Assertions | `aggregate_failures` for multi-assertion tests |
| State | `change` matchers for before/after |
| Time | `travel_to` for time-dependent behavior |
| API responses | FactoryBot hash factories (`class: Hash`) |

## File Structure

```
spec/
├── services/
│   └── module_name/
│       ├── main_service_spec.rb
│       ├── validator_spec.rb
│       └── response_builder_spec.rb
└── factories/
    └── module_name/
        └── entity_response_factory.rb
```

## Two Testing Styles

### 1. Unit Tests (with `instance_double`)

For testing services in isolation:

```ruby
let(:client) { instance_double(Api::Client) }
let(:builder) { instance_double(Api::Builder) }

before do
  allow(client).to receive(:execute_query).and_return(response)
end
```

### 2. Integration Tests (with `create`)

For services that interact with the database:

```ruby
let(:source_shelter) { create(:shelter, :with_animals) }
let(:target_shelter) { create(:shelter, :with_animals) }
```

## Template for `.call` Orchestrator Services

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ModuleName::MainService do
  describe '.call' do
    subject(:service_call) { described_class.call(params) }

    let(:shelter) { create(:shelter, :with_animals) }
    let(:params) do
      { shelter: { shelter_id: shelter.id }, items: %w[TAG001 TAG002] }
    end

    context 'when input is valid' do
      before { create(:animal, tag_number: 'TAG001', shelter:) }

      it 'returns success' do
        expect(service_call[:success]).to be true
      end
    end

    context 'when shelter is invalid' do
      let(:params) { super().merge(shelter: { shelter_id: 999_999 }) }

      it 'returns error response' do
        expect(service_call[:success]).to be false
      end
    end
  end
end
```

## Conventions

- **`subject`** for the main action under test
- **`let`** for test data, **`before`** only for stubbing
- **`describe`** for method grouping, **`context`** for scenarios
- **`aggregate_failures`** for multi-assertion tests
- **`described_class`** for constants
- **`change`** matchers for state verification
- **`travel_to`** for time-dependent tests
- **Ruby shorthand hash syntax** in `let` blocks

## FactoryBot Hash Factories for API Responses

```ruby
FactoryBot.define do
  factory :api_entity_response, class: Hash do
    transient do
      field1 { FFaker::Name.first_name }
      field2 { FFaker::Random.rand(1..1000) }
    end

    initialize_with do
      columns = ModuleName::Entity::ATTRIBUTES.map { |attr| { 'name' => attr, 'type_text' => 'STRING' } }
      { 'manifest' => { 'schema' => { 'columns' => columns } }, 'result' => { 'data_array' => [[field1, field2]] } }
    end
  end
end
```

## Testing Error Scenarios

Always test these:
- Blank/nil inputs
- Invalid references (record not found)
- Failed HTTP requests / JSON parsing / network errors
- Partial failures (some items succeed, some fail)
- Graceful error handling (non-critical operations)

## Checklist for New Test Files

- [ ] `frozen_string_literal: true` pragma
- [ ] `require 'spec_helper'`
- [ ] `subject` defined for main action
- [ ] `instance_double` for unit / `create` for integration
- [ ] Test `#initialize` with valid and invalid params
- [ ] Happy path for each public method
- [ ] Error/edge cases (blank input, invalid refs, failures)
- [ ] Partial success scenarios
- [ ] `shared_examples` for repeated patterns
- [ ] `aggregate_failures` for multi-assertion tests
- [ ] `change` matchers for state verification
- [ ] Logger expectations for error logging

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Testing private methods directly | Test through the public interface (`.call`) |
| Mock returning mock returning mock | Over-mocking. Test with real objects when possible. |
| No error scenario tests | Happy path only = false confidence. Test failures. |
| `let!` everywhere | Use `let` (lazy) unless value is needed for setup |
| Huge factory setup | Keep factories minimal. Only attributes needed for the test. |
| Not testing partial success | Real services have partial failures. Test them. |

## Red Flags

- Spec file with no error/edge case contexts
- `allow(...).to receive(:anything)` — over-permissive stubbing
- Tests that break when implementation changes but behavior stays correct
- No shared_examples despite repeated patterns across specs
- Missing FactoryBot hash factory for API response testing

## Integration

| Skill | When to chain |
|-------|---------------|
| **rspec-best-practices** | For general RSpec style and TDD discipline |
| **ruby-service-objects** | For the service conventions being tested |
| **ruby-api-client-integration** | For API client layer testing patterns |
| **rails-engine-testing** | When testing engine-specific services |
