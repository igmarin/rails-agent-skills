# rails-engine-installers

Provides a template for Rails install generators used by mountable engines.

Include templates/initializer.rb.tt and any migration templates under templates/db/migrate when implementing.

Usage:
- Copy files into an engine's lib/generators directory and adapt names.
- Use `rails generate my_engine:install` in the host app to run the installer.
