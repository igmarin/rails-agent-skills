---
name: test-service
type: atomic
license: MIT
description: >
  Use when writing RSpec tests for service objects in `spec/services/` — write spec FIRST and verify it fails for the right reason, use `subject(:service_call) { described_class.call(params) }` with `describe '.call'`, test the public contract not internal implementation, use `instance_double` for isolation and `create` for integration, cover happy path + error/edge cases + blank/invalid input, use `aggregate_failures` for multi-assertion tests, `change` matchers for state verification, `travel_to` for time-dependent logic, FactoryBot hash factories (`class: Hash` with `initialize_with`) for API responses. Covers `instance_double`, `shared_examples`, `subject`/`let` blocks, `context`/`describe` structure, and error scenario testing. Trigger words: service spec, test service object, spec/services.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Test Service

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

## HARD-GATE

```text
DO NOT implement the service before step 1 is written and failing for the right reason.
1. WRITE:   Write the spec (happy path + error cases + edge cases)
2. RUN:     bundle exec rspec spec/services/your_service_spec.rb
3. VERIFY:  Confirm failures are for the right reason (not a typo or missing factory)
4. FIX:     Implement or fix until the spec passes
5. SUITE:   bundle exec rspec spec/services/ — verify no regressions
```

## Core Process

**Core principle:** Test the public contract (`.call`, `.find`, `.search`), not internal implementation. Use `instance_double` for isolation, `create` for integration.

### Spec Template

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

Use `instance_double` for unit isolation:

```ruby
let(:client) { instance_double(Api::Client) }
before { allow(client).to receive(:execute_query).and_return(api_response) }
```

- **CRITICAL**: Collaborators (such as API clients, external services, or other domain objects) MUST be stubbed using `instance_double` to ensure true unit isolation.
- If the collaborator is instantiated inside the service under test, stub its `.new` constructor to return the `instance_double`:
  ```ruby
  let(:client) { instance_double(CarrierApi::Client) }
  before { allow(CarrierApi::Client).to receive(:new).and_return(client) }
  ```
- Alternatively, design the service to accept the collaborator as an injected dependency, and pass the `instance_double` in the params.
- DO NOT use class-level stubs (e.g., `allow(CarrierApi::Client).to receive(:notify)`) as a fallback or workaround. If a collaborator is called via class methods, you must wrap/instantiate it, inject it, or stub `.new` to return the doubled instance.

Use `create` for integration tests:

```ruby
let(:source_shelter) { create(:shelter, :with_animals) }
```

### FactoryBot Hash Factories for API Responses

When testing API clients, use `class: Hash` with `initialize_with` to build hash-shaped response fixtures. A minimal example:

```ruby
FactoryBot.define do
  factory :api_animal_response, class: Hash do
    tag_number { 'TAG001' }
    status     { 'active' }

    initialize_with { attributes.stringify_keys }
  end
end

# In the spec:
let(:api_response) { build(:api_animal_response, tag_number: 'TAG002') }
```

### New Test File Checklist

- [ ] `subject` defined for the main action
- [ ] `instance_double` for unit / `create` for integration
- [ ] Happy path for each public method
- [ ] Error and edge cases (blank input, invalid refs, failures)
- [ ] Partial success scenarios where relevant
- [ ] `shared_examples` for repeated patterns
- [ ] `aggregate_failures` for multi-assertion tests
- [ ] `change` matchers for state verification
- [ ] Logger expectations for error logging

### Common Mistakes

| Mistake | Correct approach |
|---------|------------------|
| No error scenario tests | Happy path only = false confidence — always test failures |
| `let!` everywhere | Use `let` (lazy) unless the value is needed unconditionally for setup |
| Huge factory setup | Keep factories minimal — only attributes required for the test |
| Spec breaks when implementation changes but behavior is unchanged | Tests that break on refactoring are testing internals, not contracts |

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[PATTERNS.md](./PATTERNS.md)** — Use when you need the full pattern catalog and factory placement guidance
- **[assets/spec_examples.md](assets/spec_examples.md)** — Use when you need additional worked examples beyond the spec template above
- **[assets/testing_checklist.md](assets/testing_checklist.md)** — Use when reviewing a completed service spec for completeness

## Output Style

When completing a service test, output MUST include:

```markdown
# Service Spec — [ServiceName]

## Spec File
- Path: spec/services/<module>/<service>_spec.rb
- Subject: `described_class.call(params)`

## Coverage
- Happy path: ✓ (<n> examples)
- Error cases: ✓ (<n> examples — list error classes/conditions)
- Edge cases: ✓ (<n> examples — blank input, boundary values)
- Isolation: instance_double for <collaborator list>

## TDD Gate
- RED: <failure message confirming missing behavior>
- GREEN: <all examples pass>
- Suite: <full spec/services/ suite status>
```

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | For general RSpec style and TDD discipline |
| **create-service-object** | For the service conventions being tested |
| **integrate-api-client** | For API client layer testing patterns |
| **test-engine** | When testing engine-specific services |
