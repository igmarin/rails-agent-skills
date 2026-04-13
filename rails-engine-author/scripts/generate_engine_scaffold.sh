#!/usr/bin/env bash
# Simple scaffolding helper (template only). Usage: ./scripts/generate_engine_scaffold.sh my_engine_name
# This script is a template that creates a minimal engine skeleton when executed by the developer.

cat <<'RUBY' > engines/my_engine/lib/my_engine/engine.rb
# frozen_string_literal: true
module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine
  end
end
RUBY

# Note: Replace 'my_engine' with the desired engine name and adjust module names.
