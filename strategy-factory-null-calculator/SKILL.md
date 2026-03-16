---
name: strategy-factory-null-calculator
description: >
  Use when building variant-based calculators (by program type, tenant, plan), when you
  need a single entry point that picks the right implementation, or when adding a no-op
  fallback (Null Object). Covers Strategy, Factory, and Null Object patterns with
  SERVICE_MAP routing, BaseService template methods, and RSpec testing per variant.
---

# Strategy + Factory + Null Object Calculator Pattern

Implements a **variant-based calculator** system with a single entry point, concrete strategies, and a no-op fallback (Null Object).

**Core principle:** One API for the client: `Calculator::Factory.for(entity).calculate`. The factory picks the strategy; NullService handles unknown variants safely.

## HARD-GATE: Tests Gate Implementation

```
EVERY component (Factory, BaseService, NullService, concrete services) MUST have
its test written and validated BEFORE implementation.
  1. Write the spec for the component (contexts per variant)
  2. Run the spec — verify it fails because the component does not exist yet
  3. ONLY THEN write the component implementation
  4. Repeat for each component: Factory → BaseService → NullService → Concrete
See rspec-best-practices for the full gate cycle.
```

## Quick Reference

| Component | Responsibility |
|-----------|---------------|
| **Factory** | Choose class from entity variant; return instance or NullService |
| **BaseService** | Common `#calculate` flow, guards, call to `compute_result` |
| **NullService** | Never compute; return nil safely |
| **Concrete** | Variant condition in `should_calculate?` and logic in `compute_result` |

## When to Use

- The result depends on a **variant** of the context (program, tenant, plan type, etc.).
- Logic per variant differs and you want it in separate classes.
- You need a **safe fallback** when no supported variant exists (return `nil` or default without raising).
- The client should use **one API**: `SomethingCalculator::Factory.for(entity).calculate`.

## File Structure

```
app/services/<calculator_name>/
├── factory.rb
├── base_service.rb
├── null_service.rb
├── standard_service.rb
├── premium_service.rb
└── README.md
```

## 1. Module and Factory

```ruby
# frozen_string_literal: true

module EligibilityDateCalculator
  class Factory
    SERVICE_MAP = {
      'standard' => StandardEligibilityService,
      'premium'  => PremiumEligibilityService
    }.freeze

    def self.for(animal)
      shelter = animal.shelter
      return NullService.new(animal) unless shelter&.participates_in_eligibility_program?

      program_names = shelter.shelter_programs.pluck(:name)
      service_class = SERVICE_MAP.find { |name, _| program_names.include?(name) }&.last || NullService
      service_class.new(animal)
    end
  end
end
```

Factory rules:
- No qualifying context -> `NullService`
- Variant not in `SERVICE_MAP` -> `NullService`
- Multiple variants -> first match wins (define preference order in `SERVICE_MAP`)

## 2. BaseService

```ruby
# frozen_string_literal: true

module EligibilityDateCalculator
  class BaseService
    attr_reader :animal, :shelter

    def initialize(animal)
      @animal = animal
      @shelter = animal.shelter
    end

    def calculate
      return nil unless should_calculate?
      intake_date = animal.intake_date
      return nil if intake_date.blank?
      compute_result(intake_date)
    end

    private

    def should_calculate?
      shelter&.participates_in_eligibility_program?
    end

    def compute_result(_intake_date)
      nil
    end
  end
end
```

Subclasses override `should_calculate?` and `compute_result`.

## 3. NullService

```ruby
# frozen_string_literal: true

module EligibilityDateCalculator
  class NullService < BaseService
    private

    def should_calculate?
      false
    end
  end
end
```

## 4. Concrete Services

- Inherit from `BaseService`
- `should_calculate?`: call `super` and add variant condition
- `compute_result`: implement the formula

## 5. Usage

```ruby
eligibility_date = EligibilityDateCalculator::Factory.for(animal).calculate
```

## 6. Tests (RSpec)

- **Factory**: `.for` with contexts for each branch (nil shelter, no program, each variant, multiple variants)
- **BaseService**: default `compute_result` returns nil
- **NullService**: `#calculate` always nil
- **Concrete services**: `should_calculate?` true only when variant applies; `compute_result` returns expected values

Use FactoryBot for entity setup. Use `travel_to` for time-dependent calculations.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| No NullService — raising on unknown variant | Use NullService for safe no-op. Raising breaks the client. |
| Factory logic scattered across callers | Centralize in Factory.for(entity). One entry point. |
| BaseService without `should_calculate?` guard | Subclasses forget the guard. Put it in the base class. |
| SERVICE_MAP with string keys that don't match DB values | Verify key names match exactly what's stored in the database |
| No tests per variant | Each variant must have its own spec context |

## Red Flags

- Client code uses `case/when` instead of Factory (the whole point is to avoid conditionals)
- NullService raises instead of returning nil
- Concrete service overrides `#calculate` entirely (should only override `should_calculate?` and `compute_result`)
- SERVICE_MAP is mutable (must be `.freeze`)
- No test for the NullService path

## Integration

| Skill | When to chain |
|-------|---------------|
| **ruby-service-objects** | Base conventions (YARD, constants, `frozen_string_literal`, response style) |
| **rspec-service-testing** | For testing Factory, BaseService, NullService, and concrete strategies |
| **rspec-best-practices** | For general RSpec structure |
