# frozen_string_literal: true
# spec/spec_helper.rb (engine spec template)
require "rails_helper"

RSpec.describe "Engine basic lifecycle" do
  it "loads the engine constant" do
    expect(defined?(MyEngine::Engine)).to eq("constant")
  end
end
