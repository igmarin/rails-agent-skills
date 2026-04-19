# Document the Subscription Discount Calculator

## Problem/Feature Description

Kestrel Software is onboarding three new backend engineers next sprint. One of the first modules they will need to touch is the subscription discount calculator, which determines how much discount a customer receives based on their subscription tier, contract length, and promotional eligibility. The module was written under deadline pressure and has no comments at all. Several engineers have already introduced bugs in this module by misunderstanding its intent — once by removing a guard clause that seemed redundant (it wasn't), and once by changing the order of tier checks (which broke the annual promo logic).

Your task is to add comments throughout the module that will prevent future misunderstandings. The goal is not to explain the mechanics of what each line does — experienced engineers can read Ruby. The goal is to capture the intent, constraints, and gotchas that led to each decision, so that anyone modifying this module in the future understands what they must preserve and why.

Do not refactor or change any existing logic. Only add comments.

## Output Specification

Produce a single output file:

- `app/services/discount_calculator.rb` — the same class with comments added

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: app/services/discount_calculator.rb ===============
# frozen_string_literal: true

class DiscountCalculator
  TIER_RATES = {
    starter:      0.00,
    professional: 0.10,
    enterprise:   0.20
  }.freeze

  ANNUAL_BONUS = 0.05

  PROMO_CODES = {
    "LAUNCH2024" => 0.15,
    "PARTNER50"  => 0.50
  }.freeze

  MAX_DISCOUNT = 0.60

  def self.call(subscription:, promo_code: nil)
    new(subscription: subscription, promo_code: promo_code).call
  end

  def initialize(subscription:, promo_code: nil)
    @subscription = subscription
    @promo_code   = promo_code
  end

  def call
    return 0.0 unless @subscription.active?

    base = TIER_RATES.fetch(@subscription.tier, 0.0)

    base += ANNUAL_BONUS if @subscription.annual?

    promo = PROMO_CODES[@promo_code] || 0.0
    if promo > base
      total = promo
    else
      total = base + promo
    end

    [total, MAX_DISCOUNT].min
  end
end
