# Code snippets (per-path)

Service object skeleton

# frozen_string_literal: true
class MyService
  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(**kwargs)
    @kwargs = kwargs
  end

  def call
    # return { success: true, response: { data: ... } }
    { success: true, response: {} }
  end
end

Controller thin-action example

class UsersController < ApplicationController
  def create
    result = CreateUserService.call(user_params: user_params)
    if result[:success]
      render json: result[:response], status: :created
    else
      render json: { errors: result[:response][:error] }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

Model validation example

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end
