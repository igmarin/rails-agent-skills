# Shipping Cost Calculator Service

## Problem/Feature Description

A logistics company needs a service to calculate shipping costs for packages. The business rules are: standard shipping is free above a weight threshold, express shipping has a per-kg surcharge with a minimum charge, and overnight shipping has a flat rate plus a fuel surcharge percentage. The team is expanding the shipping options and the code currently has magic numbers scattered throughout — the same weight limit appears in four different places, and the surcharge percentage is buried as a literal in a conditional. This has led to bugs when one occurrence was updated and another was not.

Additionally, the team needs a standalone validator that checks whether a package's dimensions are within allowed shipping limits. This validator will be used by both the shipping calculator and a separate customs declaration service, so it should be self-contained and stateless.

Your task is to write the Ruby service layer for the shipping cost calculator. The rules should be cleanly encoded so that changing a business parameter requires updating exactly one place. Document the public API so that future developers understand the accepted parameters and return values without reading the implementation.

## Output Specification

Produce the following files:

- `app/services/<module>/shipping_cost_calculator.rb` — main calculator service
- `app/services/<module>/package_validator.rb` — the stateless package dimension validator
- Any documentation or companion files you consider appropriate for the module
- `spec/services/<mirrored_path>/shipping_cost_calculator_spec.rb` — specs for standard, express, and overnight shipping, and for packages above/below the weight threshold

Do not create a full Rails application. Use plain Ruby with realistic values. The focus should be on the structure, documentation style, and how business rules are encoded — not whether the application runs end-to-end.
