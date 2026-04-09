# Untangle the Order Processing Controller

## Problem/Feature Description

The backend team at Verdana Commerce has an `OrdersController` that started out simple but has grown over three iterations into a difficult-to-test monolith. The `create` action now validates subscription state, computes pricing with discount tiers, calculates tax, persists the order, and fires off two async side-effects — all inline. The controller is working correctly in production and has a minimal integration test, but adding the next pricing tier (annual subscriber discount) feels risky because the logic is buried deep in the action and there's no unit-level coverage for the calculation paths.

Your task is to restructure this controller action so the business logic can be tested in isolation and the controller itself is easy to follow. The existing behavior must be preserved exactly — this is not the time to add the new pricing tier or fix anything else. The team cares deeply about being able to trust each change step; they have been burned before when a "quick refactor" introduced a subtle regression that only appeared in production.

## Output Specification

Produce the following files when you are done:

- **`process_log.md`** — a chronological record of your refactoring process. Include: the stable behavior declaration, your planned sequence of steps, and for each completed step a brief note of what changed plus the test results you observed (exit code or pass/fail count). Do not skip steps or summarize retroactively — record results as you go.
- **`app/controllers/orders_controller.rb`** — the refactored controller
- **`app/services/`** — any service or module files you extracted
- **`spec/`** — updated or new spec files

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: app/controllers/orders_controller.rb ===============
# frozen_string_literal: true

class OrdersController < ApplicationController
  def create
    order = Order.new(order_params)

    unless current_user.subscription.active?
      render json: { error: 'Subscription inactive' }, status: :unprocessable_entity
      return
    end

    if order.line_items.empty?
      render json: { error: 'Order must have line items' }, status: :unprocessable_entity
      return
    end

    subtotal = order.line_items.sum { |item| item.quantity * item.unit_price }
    discount = current_user.subscription.tier == 'premium' ? 0.1 : 0.0
    order.total_amount = subtotal * (1 - discount)

    order.tax_amount = order.total_amount * 0.08
    order.grand_total = order.total_amount + order.tax_amount

    if order.save
      NotifyWarehouseJob.perform_later(order.id)
      UserMailer.order_confirmation(current_user, order).deliver_later
      render json: order, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:shipping_address, line_items_attributes: [:product_id, :quantity, :unit_price])
  end
end

=============== FILE: spec/requests/orders_spec.rb ===============
# frozen_string_literal: true

RSpec.describe 'Orders API', type: :request do
  describe 'POST /orders' do
    let(:user) { create(:user, :with_active_premium_subscription) }

    before { sign_in user }

    context 'with valid params and premium subscription' do
      it 'creates an order and applies the premium discount' do
        post '/orders', params: valid_order_params
        expect(response).to have_http_status(:created)
        expect(Order.last.total_amount).to be < Order.last.line_items.sum { |i| i.quantity * i.unit_price }
      end
    end

    context 'with inactive subscription' do
      let(:user) { create(:user, :with_inactive_subscription) }

      it 'returns 422' do
        post '/orders', params: valid_order_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
