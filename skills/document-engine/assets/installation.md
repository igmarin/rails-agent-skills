# Engine Installation Guide

Install from RubyGems:

1. Add to Gemfile:
   gem 'my_engine'
2. bundle install
3. Mount in host app (config/routes.rb):
   Rails.application.routes.draw do
     mount MyEngine::Engine => '/my_engine'
   end
4. Run installer generator if present:
   rails generate my_engine:install
5. Run migrations if installer copied them:
   bundle exec rake db:migrate

Install from local path (development):

1. In host Gemfile:
   gem 'my_engine', path: 'engines/my_engine'
2. bundle install
3. Mount and run as above

Verification checklist:
- [ ] Engine mounts at the expected path and responds to a simple request
- [ ] No NameError/LoadError on boot
- [ ] Initializer file created and contains documented keys

Notes: prefer mounting under a clearly namespaced path. If the engine exposes background jobs or migrations, document those in the README and release notes.