# Document the Subscription Billing Service

## Problem/Feature Description

The platform team at CloudSub has recently shipped a `SubscriptionBillingService` that handles plan upgrades, downgrades, and cancellations. The service is already implemented and all specs are passing, but the module has no inline documentation. Two junior engineers joining the team next week need to consume these classes from a new payment gateway integration, and the tech lead wants the public API fully documented before the onboarding begins.

The service handles complex input hashes and can raise several exceptions. Without proper docs, consumers will have to read the full implementation to understand what parameters are accepted, what the return shape looks like, and what exceptions they need to rescue.

Your task is to add YARD documentation to the provided Ruby source file. Do not change the logic — only add documentation.

## Input Files

The following file is provided as input. Extract it before beginning.

=============== FILE: app/services/subscription_billing_service.rb ===============
# frozen_string_literal: true

module Billing
  class SubscriptionBillingService
    VALID_PLANS = %w[starter growth enterprise].freeze

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      validate!
      result = process_change
      { success: true, response: result }
    rescue InvalidPlanError => e
      { success: false, response: { error: e.message } }
    rescue PaymentGatewayError => e
      { success: false, response: { error: e.message, retryable: true } }
    end

    def self.supported_plans
      VALID_PLANS
    end

    private

    def validate!
      raise InvalidPlanError, "Unknown plan: #{@params[:plan]}" unless VALID_PLANS.include?(@params[:plan])
      raise ArgumentError, "customer_id is required" unless @params[:customer_id]
    end

    def process_change
      case @params[:action]
      when "upgrade"   then upgrade_plan
      when "downgrade" then downgrade_plan
      when "cancel"    then cancel_subscription
      else raise ArgumentError, "Unknown action: #{@params[:action]}"
      end
    end

    def upgrade_plan
      { plan: @params[:plan], effective_date: Time.current, previous_plan: @params[:current_plan] }
    end

    def downgrade_plan
      { plan: @params[:plan], effective_date: end_of_billing_period, previous_plan: @params[:current_plan] }
    end

    def cancel_subscription
      { cancelled_at: Time.current, refund_eligible: @params[:plan] != "starter" }
    end

    def end_of_billing_period
      Time.current.end_of_month
    end
  end

  class InvalidPlanError < StandardError; end
  class PaymentGatewayError < StandardError; end
end

## Output Specification

Produce a single updated file:

- `app/services/subscription_billing_service.rb` — the source file with YARD documentation added to all public surfaces (the class itself, `self.call`, `self.supported_plans`, `initialize`)

Do not modify the Ruby logic — only add YARD comments.
