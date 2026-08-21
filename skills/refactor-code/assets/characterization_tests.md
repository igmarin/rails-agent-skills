# Characterization Tests Template

Purpose: Capture current behavior with minimal, focused tests before refactoring.

Template:

- Identify a small, reproducible behavior (unit or integration)
- Write a test that asserts current output/state
- Avoid assertions that encode implementation details; prefer observable outputs

Example (RSpec):

RSpec.describe 'LegacyFormatter', type: :model do
  it 'returns legacy CSV with expected headers' do
    input = File.read('spec/fixtures/legacy_input.txt')
    expect(LegacyFormatter.new(input).to_s.lines.first).to include('ID,Name,Value')
  end
end

Guidelines:
- Keep tests fast (<100ms ideally)
- Use real fixtures to capture current behavior
- Label tests clearly with the behavior they protect
- Commit tests before refactoring and ensure they fail if behavior changes
