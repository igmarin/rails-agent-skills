# Order Processing Module Architecture Review

## Problem/Feature Description

An e-commerce startup is scaling up its engineering team and wants to establish code quality standards before onboarding three new backend engineers. The tech lead has noticed that the order processing module has grown organically and suspects it has accumulated some structural problems that will slow the new hires down. She wants a written architecture review that can be shared with the team to inform a future refactoring sprint and establish what "healthy Rails code" looks like in this codebase.

The review should focus on the kinds of structural problems that cause bugs as the system grows — misplaced responsibilities, tight coupling, and logic that ends up in the wrong layer — rather than surface-level style preferences. The team wants concrete, ranked findings they can use to plan work, not a catalogue of every possible improvement.

Produce an architecture review of the code below. Save the review as `architecture-review.md`.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: app/controllers/orders_controller.rb ===============
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    @order.user = current_user

    ActiveRecord::Base.transaction do
      @order.save!
      @order.line_items.each do |item|
        item.product.decrement!(:stock_quantity, item.quantity)
      end
      payment = PaymentGateway.charge(
        amount: @order.total_cents,
        token: params[:payment_token],
        description: "Order ##{@order.id}"
      )
      @order.update!(payment_reference: payment.id, status: :paid)
      OrderMailer.confirmation(@order).deliver_now
      Segment.track(user_id: current_user.id, event: "order_placed", properties: { order_id: @order.id })
    end

    redirect_to @order
  rescue PaymentGateway::ChargeError => e
    @order.update(status: :payment_failed)
    flash[:error] = e.message
    render :new
  end

  private

  def order_params
    params.require(:order).permit(:shipping_address, :billing_address, line_items_attributes: [:product_id, :quantity])
  end
end

=============== FILE: app/models/order.rb ===============
class Order < ApplicationRecord
  belongs_to :user
  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items

  accepts_nested_attributes_for :line_items

  before_save :calculate_total
  after_create :reserve_inventory
  after_commit :sync_to_warehouse, on: [:create, :update]

  scope :recent, -> { where("created_at > ?", 30.days.ago) }
  scope :for_reporting, -> {
    joins(:line_items, :products)
      .select("orders.*, SUM(line_items.quantity * products.unit_price) as computed_total, COUNT(line_items.id) as item_count")
      .group("orders.id")
      .having("SUM(line_items.quantity * products.unit_price) > 0")
  }

  def calculate_total
    self.total_cents = line_items.sum { |i| i.quantity * i.product.unit_price_cents }
  end

  def reserve_inventory
    line_items.each { |i| i.product.decrement!(:reserved_quantity, i.quantity) }
  end

  def sync_to_warehouse
    WarehouseApi.push_order(self.as_json(include: :line_items))
  end
end

=============== FILE: app/models/concerns/auditable.rb ===============
module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_creation
    after_update :log_changes
    after_destroy :log_deletion
  end

  def log_creation
    AuditLog.create!(event: "created", record_type: self.class.name, record_id: id, payload: self.as_json)
    Slack.notify("#audit", "#{self.class.name} #{id} created")
    UserMailer.admin_alert("Record created: #{self.class.name} #{id}").deliver_later
  end

  def log_changes
    AuditLog.create!(event: "updated", record_type: self.class.name, record_id: id, payload: self.previous_changes)
    Slack.notify("#audit", "#{self.class.name} #{id} updated")
  end

  def log_deletion
    AuditLog.create!(event: "deleted", record_type: self.class.name, record_id: id, payload: {})
    Slack.notify("#audit", "#{self.class.name} #{id} deleted")
  end
end
