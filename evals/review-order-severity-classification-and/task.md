# Review the Promotions Feature PR

## Problem/Feature Description

The Greenfield Commerce platform recently added a promotions feature through a community contribution. The PR was submitted by a developer who is strong in feature delivery but less experienced with Rails security and performance conventions. Before this can be merged to main, the team needs a thorough review of the code to catch any issues that could cause problems in production.

Your job is to produce a complete code review of the provided diff. The application is a standard Rails 7 API app backed by PostgreSQL. The review should help the developer understand what must be addressed before the PR can be merged, what is strongly recommended, and what is optional. The team's review process requires that any items needing re-review are clearly flagged.

## Output Specification

Produce a single file **`review.md`** containing your complete review. Structure it by area (e.g. Controllers, Queries, Migrations, Security, etc.) and classify every finding with a severity. For each finding include the affected location, what the problem is, and a concrete fix suggestion. End the review with a clear statement about next steps — specifically whether a follow-up review pass is needed and under what conditions.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: app/controllers/promotions_controller.rb ===============
# frozen_string_literal: true

class PromotionsController < ApplicationController
  def index
    @promotions = Promotion.all
    render json: @promotions.map { |p|
      {
        id: p.id,
        title: p.title,
        discount_percent: p.discount_percent,
        used_count: p.orders.count,
        creator: p.created_by.name
      }
    }
  end

  def apply
    promotion = Promotion.find(params[:id])
    order = Order.find(params[:order_id])

    # Calculate the discounted total
    base_total = order.line_items.sum { |item| item.quantity * item.unit_price }
    discount_amount = base_total * (promotion.discount_percent / 100.0)
    final_total = base_total - discount_amount
    tax = final_total * 0.08
    order.update!(total_cents: ((final_total + tax) * 100).round)

    order.applied_promotions << promotion
    promotion.increment!(:usage_count)

    flash_message = "Promotion applied! You saved #{discount_amount.round(2)} on your order."

    render json: {
      message: flash_message.html_safe,
      order_total_cents: order.total_cents
    }
  end

  def create
    @promotion = Promotion.new(params.require(:promotion).permit!)

    if @promotion.save
      render json: @promotion, status: :created
    else
      render json: { errors: @promotion.errors }, status: :unprocessable_entity
    end
  end
end

=============== FILE: db/migrate/20240315_add_promotions.rb ===============
class AddPromotions < ActiveRecord::Migration[7.1]
  def change
    create_table :promotions do |t|
      t.string :title, null: false
      t.decimal :discount_percent, null: false
      t.integer :usage_count, default: 0
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    create_table :applied_promotions do |t|
      t.integer :promotion_id, null: false
      t.integer :order_id, null: false
      t.timestamps
    end
  end
end

=============== FILE: app/models/promotion.rb ===============
class Promotion < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  has_many :orders, through: :applied_promotions
  has_many :applied_promotions
end
