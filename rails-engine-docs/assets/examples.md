# rails-engine-docs examples

1) Minimal initializer

MyEngine.configure do |config|
  config.api_key = ENV['MY_ENGINE_API_KEY']
  config.default_limit = 50
end

2) Mounting example

Rails.application.routes.draw do
  mount MyEngine::Engine => '/my_engine'
end

3) Verify migration namespace

# in host app console
ActiveRecord::Base.connection.table_exists?('my_engine_users')
