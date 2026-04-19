# frozen_string_literal: true

module ModuleName
  class ServiceName
    MISSING_PARAM = 'Missing required parameter'

    # @param params [Hash] :key1, :key2
    # @return [Hash] { success: Boolean, response: Hash }
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @key1 = params[:key1]
      @key2 = params[:key2]
    end

    # @return [Hash] { success: Boolean, response: Hash }
    def call
      return { success: false, response: { error: { message: MISSING_PARAM } } } if @key1.blank?

      # TODO: implement business logic
      { success: true, response: {} }
    rescue StandardError => e
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace.first(5).join("\n"))
      { success: false, response: { error: { message: e.message } } }
    end
  end
end
