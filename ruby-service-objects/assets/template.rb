# frozen_string_literal: true

# Template service object file
class TemplateService
  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(**kwargs)
    @kwargs = kwargs
  end

  def call
    # TODO: implement minimal behavior
    { success: true, response: {} }
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.first(5).join("\n"))
    { success: false, response: { error: e.message } }
  end
end
