#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Deprecated: Tessl plugin mode auto-discovers evals/ directly.
# This script is now a no-op - evals are published in-place from evals/.
# Use `tessl eval run .` instead.

ROOT = File.expand_path("..", __dir__)
EVAL_DIR = File.join(ROOT, "evals")

abort "Missing evals/ directory" unless Dir.exist?(EVAL_DIR)

skill_count = Dir.children(EVAL_DIR).count { |entry| File.directory?(File.join(EVAL_DIR, entry)) && !entry.start_with?(".") }
puts "Tessl eval scenarios ready in evals/ (#{skill_count} skills) - no staging needed for plugin mode"
