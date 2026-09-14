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

    def test_includes_nested_references_and_linked_pack_documentation_once
      FileUtils.mkdir_p(@skill_dir.join("references"))
      @skill_dir.join("references", "workflow.md").write("Workflow proof")
      FileUtils.mkdir_p(@repo_root.join("docs"))
      @repo_root.join("docs", "contract.md").write("Shared contract")
      @skill_md.write(@skill_md.read + "\n[Contract](../../../docs/contract.md)\n[Again](../../../docs/contract.md)\n")

      xml = EvalContextBuilder.new(repo_root: @repo_root).call(target_path: @skill_md)
      assert_includes xml, "Workflow proof"
      assert_equal 1, xml.scan("Shared contract").length
    end

    def test_infers_persona_and_workflow_from_nested_skills_layout
      %w[personas workflows].each do |directory|
        path = @repo_root.join("skills", directory, "sample", "SKILL.md")
        FileUtils.mkdir_p(path.dirname)
        path.write(@skill_md.read)
        xml = EvalContextBuilder.new(repo_root: @repo_root).call(target_path: path)
        assert_includes xml, %(target_type="#{directory.delete_suffix('s')}")
      end
    end

    def test_rejects_missing_local_resource_instead_of_silently_omitting_it
      @skill_md.write(@skill_md.read + "\n[Missing](references/missing.md)\n")
      assert_raises(EvalContextBuilder::Error) do
        EvalContextBuilder.new(repo_root: @repo_root).call(target_path: @skill_md)
      end
    end

    def test_resource_cycles_terminate_and_external_urls_are_not_loaded
      @skill_dir.join("EXAMPLES.md").write("[Back](SKILL.md)\nExample evidence")
      @skill_md.write(@skill_md.read + "\n[Web](https://example.invalid/private.md)\n")
      xml = EvalContextBuilder.new(repo_root: @repo_root).call(target_path: @skill_md)
      assert_equal 1, xml.scan('Example evidence').length
      assert_equal 1, xml.scan('<primary ').length
    end

    def test_symlink_cannot_pull_a_resource_from_outside_the_pack
      Dir.mktmpdir do |outside|
        secret = Pathname.new(outside).join('outside.md')
        secret.write('outside content')
        File.symlink(secret, @skill_dir.join('EXAMPLES.md'))
        error = assert_raises(EvalContextBuilder::Error) do
          EvalContextBuilder.new(repo_root: @repo_root).call(target_path: @skill_md)
        end
        assert_match(/escapes repository/, error.message)
      end
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
