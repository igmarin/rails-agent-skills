# Dummy app setup for engine testing

Purpose: Provide a compact, model-agnostic checklist and commands to set up a dummy Rails app for testing a mountable engine.

Steps:

1. Create dummy app skeleton inside the engine (recommended path: test/dummy or spec/dummy):

   mkdir -p engines/my_engine/test/dummy
   cd engines/my_engine/test/dummy
   bundle init
   bundle add rails -v "~> 7.0"
   bundle install
   rails new . --skip-bundle --skip-git --skip-javascript --skip-action-mailbox --skip-action-text --skip-active-storage --skip-hotwire

2. Mount engine in dummy app's config/routes.rb:

   Rails.application.routes.draw do
     mount MyEngine::Engine => "/my_engine"
   end

3. Configure dummy app to load the engine from the local path (in Gemfile):

   gem "my_engine", path: "../../.."

4. Run bundle install in dummy app and ensure it boots:

   bundle install
   bin/rails runner "puts 'dummy app booted'"

5. Run engine specs against dummy app using RSpec (example):

   # from engine root
   RAILS_ENV=test bundle exec rspec spec --default-path spec

6. Troubleshooting hints:
   - If migrations fail, ensure engine migrations are namespaced and copied into dummy app with `rake my_engine:install:migrations`.
   - Use `bundle exec rails db:create db:migrate` in the dummy app context.
   - Ensure engine's gemspec or path reference matches dummy app Gemfile.

Minimal verification checklist:
- [ ] Dummy app boots without NameError/LoadError
- [ ] Engine routes mount and respond to a simple request
- [ ] Engine migrations run in dummy app context
- [ ] Engine public classes are namespaced and load correctly

Keep this file compact — developer should adapt versions and flags to their Rails version and host app constraints.