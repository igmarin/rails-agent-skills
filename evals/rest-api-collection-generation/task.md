# Inventory API Collection

## Problem/Feature Description

A warehouse management team has just shipped a new Inventory API in their Rails application. The API covers products and stock adjustments, and the backend engineers have written the controller and routes. However, there is no API collection for the frontend team and QA engineers to use when manually testing or demonstrating the endpoints. The team lead has asked for a machine-readable collection file that the team can import into their HTTP client to start calling the API immediately.

The collection should be usable by anyone with access to the repository — no one should have to manually reconstruct request shapes from the source code.

## Output Specification

Generate an API collection file for the Inventory API endpoints defined in the input files below.

The collection should be importable into a standard HTTP client tool. Save it in the conventional location for API collections in a Rails project.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: app/controllers/api/v1/products_controller.rb ===============
module Api
  module V1
    class ProductsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_product, only: [:show, :update, :destroy]

      # GET /api/v1/products
      def index
        @products = Product.active.order(:name)
        render json: @products
      end

      # GET /api/v1/products/:id
      def show
        render json: @product
      end

      # POST /api/v1/products
      def create
        @product = Product.new(product_params)
        if @product.save
          render json: @product, status: :created
        else
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/products/:id
      def update
        if @product.update(product_params)
          render json: @product
        else
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product.archive!
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:name, :sku, :unit_price, :stock_quantity, :active)
      end
    end
  end
end

=============== FILE: app/controllers/api/v1/stock_adjustments_controller.rb ===============
module Api
  module V1
    class StockAdjustmentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_product

      # GET /api/v1/products/:product_id/stock_adjustments
      def index
        @adjustments = @product.stock_adjustments.recent.limit(50)
        render json: @adjustments
      end

      # POST /api/v1/products/:product_id/stock_adjustments
      def create
        @adjustment = @product.stock_adjustments.build(adjustment_params)
        @adjustment.user = current_user
        if @adjustment.save
          render json: @adjustment, status: :created
        else
          render json: { errors: @adjustment.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_product
        @product = Product.find(params[:product_id])
      end

      def adjustment_params
        params.require(:stock_adjustment).permit(:quantity, :reason, :reference_number)
      end
    end
  end
end

=============== FILE: config/routes.rb ===============
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :products do
        resources :stock_adjustments, only: [:index, :create]
      end
    end
  end
end
