# Service object skeleton

Purpose: Comprehensive reference skeleton showing all conventions. Use `template.rb` for the minimal bootstrap.

## Standard service (with transaction, validation, YARD)

```ruby
# frozen_string_literal: true

module ModuleName
  class ServiceName
    PROCESSING_FAILED = 'Processing could not be completed'

    # @param params [Hash] :required_key
    # @return [Hash] { success: Boolean, response: Hash }
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @required_key = params[:required_key]
    end

    # @return [Hash] { success: Boolean, response: Hash }
    def call
      return { success: false, response: { error: { message: 'Missing required_key' } } } if @required_key.blank?

      result = ActiveRecord::Base.transaction do
        # multi-step DB operations
      end
      { success: true, response: { record: result } }
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Validation Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, response: { error: { message: e.message } } }
    rescue StandardError => e
      Rails.logger.error("Processing Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, response: { error: { message: PROCESSING_FAILED } } }
    end
  end
end
```

## Orchestrator (≤20-line `call`, no rescue)

```ruby
# frozen_string_literal: true

module ModuleName
  class OrchestratorName
    # @param params [Hash]
    # @return [Hash] { success: Boolean, response: Hash }
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    # @return [Hash] { success: Boolean, response: Hash }
    def call
      step1_result = Step1Service.call(@params)
      return step1_result unless step1_result[:success]

      step2_result = Step2Service.call(step1_result[:response])
      return step2_result unless step2_result[:success]

      { success: true, response: step2_result[:response] }
    end
  end
end
```

## Class-only validator (no instance state)

```ruby
# frozen_string_literal: true

class ValidatorName
  RULE = 'Description of the rule'

  # @param input [Hash]
  # @return [nil, String] nil if valid, error message otherwise
  def self.validate(input)
    return RULE if input[:field].blank?
    nil
  end
end
```
