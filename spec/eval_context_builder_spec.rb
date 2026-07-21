# frozen_string_literal: true

# Tests for scripts/eval_context_builder.rb using Ruby stdlib minitest.
# Run with:  ruby spec/eval_context_builder_spec.rb
#
# No Gemfile required — minitest/autorun ships with the Ruby stdlib.

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "pathname"

require_relative "../scripts/eval_context_builder"

module McpSkills
  class EvalContextBuilderTest < Minitest::Test
    def setup
      @repo_root = Pathname.new(Dir.mktmpdir("eval_ctx_repo"))
      @skill_dir = @repo_root.join("skills", "testing", "sample-skill")
      FileUtils.mkdir_p(@skill_dir)
      @skill_md = @skill_dir.join("SKILL.md")
      @skill_md.write(<<~SKILL)
        ---
        name: sample-skill
        type: atomic
        description: Use when testing the eval context builder.
        ---

        # Sample Skill

        Body text for the sample skill.
      SKILL
    end

    def teardown
      FileUtils.rm_rf(@repo_root)
    end

    def test_call_renders_xml_for_valid_skill
      builder = EvalContextBuilder.new(repo_root: @repo_root)
      xml = builder.call(target_path: @skill_md)
      assert_includes xml, %(<skill_context target_type="skill" target_name="sample-skill">)
      assert_includes xml, "<primary"
      assert_includes xml, "Body text for the sample skill."
    end

    def test_call_raises_on_invalid_target_type
      builder = EvalContextBuilder.new(repo_root: @repo_root)
      err = assert_raises(EvalContextBuilder::Error) do
        builder.call(target_path: @skill_md, target_type: "bogus")
      end
      assert_match(/target_type/, err.message)
      assert_match(/bogus/, err.message)
    end

    def test_call_accepts_persona_and_workflow_target_types
      builder = EvalContextBuilder.new(repo_root: @repo_root)
      ["skill", "persona", "workflow"].each do |valid|
        xml = builder.call(target_path: @skill_md, target_type: valid)
        assert_includes xml, %(target_type="#{valid}")
      end
    end

    def test_estimate_tokens_returns_positive_integer
      builder = EvalContextBuilder.new(repo_root: @repo_root)
      estimate = builder.estimate_tokens(target_path: @skill_md)
      assert_kind_of Integer, estimate
      assert_operator estimate, :>, 0
    end

    def test_estimate_tokens_scales_with_content_size
      builder = EvalContextBuilder.new(repo_root: @repo_root)
      small = builder.estimate_tokens(target_path: @skill_md)

      # Add a large companion resource.
      big_asset = @skill_dir.join("EXAMPLES.md")
      big_asset.write("x" * 4000)

      large = builder.estimate_tokens(target_path: @skill_md)
      assert_operator large, :>, small
    end

    def test_size_guard_rejects_oversize_companion_file
      # Create a companion file larger than the guard threshold.
      oversize = @skill_dir.join("EXAMPLES.md")
      oversize.write("x" * (EvalContextBuilder::MAX_FILE_SIZE_BYTES + 1))

      builder = EvalContextBuilder.new(repo_root: @repo_root)
      err = assert_raises(EvalContextBuilder::Error) do
        builder.call(target_path: @skill_md)
      end
      assert_match(/EXAMPLES.md/, err.message)
      assert_match(/size|exceeds|too large/i, err.message)
    end

    def test_size_guard_allows_under_threshold_file
      within = @skill_dir.join("EXAMPLES.md")
      within.write("x" * 100)

      builder = EvalContextBuilder.new(repo_root: @repo_root)
      xml = builder.call(target_path: @skill_md)
      assert_includes xml, "EXAMPLES.md"
    end
  end
end
