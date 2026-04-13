# Compact examples (few-shot)

Example 1 — Move a PORO (pricing calculator)

Task: "Extract the Pricing::Calculator into MyEngine with no host-model dependency yet."

Expected output (JSON):

{
  "slice_name": "pricing_calculator",
  "actions": [
    "move app/services/pricing/calculator.rb -> my_engine/app/services/my_engine/pricing_calculator.rb",
    "rename module Pricing::Calculator -> MyEngine::PricingCalculator",
    "add minimal spec to spec/services/my_engine/pricing_calculator_spec.rb"
  ],
  "verification_commands": [
    "bundle exec rspec spec/services/pricing/ spec/requests/orders/"
  ]
}

Example 2 — Add adapter for current_user

Task: "Engine needs current_user; provide a configurable provider seam."

Expected output (JSON):

{
  "slice_name": "order_creator_adapter",
  "actions": [
    "add lib/my_engine/configuration.rb with current_user_provider attr_accessor",
    "change OrderCreator.for_request to use MyEngine.config.current_user_provider.call(request)",
    "document host initializer and expected callable signature"
  ],
  "verification_commands": [
    "bundle exec rspec spec/services/order_creator_spec.rb"]
}
