# rails-engine-testing examples

1) Quick verify
   - Run: bundle exec rspec spec/engine_spec.rb
   - Expect: spec boots Rails dummy app and runs a smoke test for engine mount point

2) Migration check
   - Run: rake my_engine:install:migrations && bundle exec rails db:migrate
   - Expect: migrations apply without table name collisions

3) Namespacing check
   - Simple test: assert defined?(MyEngine::Engine) == "constant"
