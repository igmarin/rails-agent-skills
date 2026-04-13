# frozen_string_literal: true
# Template for an install generator that copies migrations and creates an initializer
module MyEngine
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Copies migrations and creates a basic initializer for MyEngine'

      def copy_migrations
        rake 'railties:install:migrations'
      end

      def create_initializer
        template 'initializer.rb.tt', 'config/initializers/my_engine.rb'
      end
    end
  end
end
