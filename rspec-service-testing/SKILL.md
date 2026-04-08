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

**Core principle:** Test the public contract (`.call`, `.find`, `.search`), not internal implementation. Use `instance_double` for isolation, `create` for integration.

## Workflow: Write → Run → Verify → Fix

```text
1. WRITE:   Write the spec (happy path + error cases + edge cases)
2. RUN:     bundle exec rspec spec/services/your_service_spec.rb
3. VERIFY:  Confirm failures are for the right reason (not a typo or missing factory)
4. FIX:     Implement or fix until the spec passes
5. SUITE:   bundle exec rspec spec/services/ — verify no regressions
```

**DO NOT implement the service before step 1 is written and failing for the right reason.**

## Quick Reference

| Aspect | Rule |
|--------|------|
| File location | `spec/services/module_name/service_spec.rb` |
| Subject | `subject(:service_call) { described_class.call(params) }` |
| Unit isolation | `instance_double` for collaborators |
| Integration | `create` for DB-backed tests |
| Multi-assertion | `aggregate_failures` |
| State verification | `change` matchers |
| Time-dependent | `travel_to` |
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

## Spec Template

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

    context 'when shelter is not found' do
      let(:params) { super().merge(shelter: { shelter_id: 999_999 }) }

      it 'returns error response' do
        expect(service_call[:success]).to be false
      end
    end

    context 'when input is blank' do
      let(:params) { { shelter: { shelter_id: nil }, items: [] } }

      it 'returns error response with meaningful message' do
        aggregate_failures do
          expect(service_call[:success]).to be false
          expect(service_call[:errors]).not_to be_empty
        end
      end
    end
  end
end
```

## Two Testing Styles

### Unit Tests (with `instance_double`)

```ruby
let(:client) { instance_double(Api::Client) }

before do
  allow(client).to receive(:execute_query).and_return(api_response)
end
```

### Integration Tests (with `create`)

```ruby
let(:source_shelter) { create(:shelter, :with_animals) }
let(:target_shelter) { create(:shelter, :with_animals) }
```

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

## Error Scenarios to Always Test

- Blank/nil inputs
- Invalid references (record not found)
- Failed HTTP requests, JSON parsing errors, network errors
- Partial failures (some items succeed, some fail)
- Graceful handling of non-critical failures

## New Test File Checklist

- [ ] `frozen_string_literal: true` pragma
- [ ] `require 'spec_helper'`
- [ ] `subject` defined for the main action
- [ ] `instance_double` for unit / `create` for integration
- [ ] Happy path for each public method
- [ ] Error and edge cases (blank input, invalid refs, failures)
- [ ] Partial success scenarios where relevant
- [ ] `shared_examples` for repeated patterns
- [ ] `aggregate_failures` for multi-assertion tests
- [ ] `change` matchers for state verification
- [ ] Logger expectations for error logging

## Common Mistakes

| Mistake | Correct approach |
|---------|-----------------|
| Testing private methods directly | Test through the public interface (`.call`) |
| Mock returning mock returning mock | Test with real objects when over-mocking; use `instance_double` for one level |
| No error scenario tests | Happy path only = false confidence — always test failures |
| `let!` everywhere | Use `let` (lazy) unless the value is needed unconditionally for setup |
| Huge factory setup | Keep factories minimal — only attributes required for the test |
| Spec breaks when implementation changes but behavior is unchanged | Tests that break on refactoring are testing internals, not contracts |

## Integration

| Skill | When to chain |
|-------|---------------|
| **rspec-best-practices** | For general RSpec style and TDD discipline |
| **ruby-service-objects** | For the service conventions being tested |
| **ruby-api-client-integration** | For API client layer testing patterns |
| **rails-engine-testing** | When testing engine-specific services |
