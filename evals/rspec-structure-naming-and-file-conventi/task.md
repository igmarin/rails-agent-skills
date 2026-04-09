# User Notification Service Specs

## Problem/Feature Description

A SaaS platform sends users notifications when important events occur: account suspension warnings, password change confirmations, and billing failures. The backend team recently completed `Notifications::UserNotifier`, a service object that dispatches different notification types via email. A code review flagged that this service has no test coverage, and the PR cannot be merged until specs are in place.

You have been asked to write a comprehensive RSpec spec file for `Notifications::UserNotifier`. The service lives at `app/services/notifications/user_notifier.rb`. Your spec file should be organized to reflect the structure of the service and provide clear, readable examples that any team member can understand at a glance.

Note: This project does NOT use test-prof or any performance-enhancing spec helpers beyond standard RSpec.

## Input Files

The following file is provided. Extract it before beginning.

=============== FILE: app/services/notifications/user_notifier.rb ===============
# frozen_string_literal: true

module Notifications
  class UserNotifier
    VALID_EVENTS = %w[suspension_warning password_changed billing_failure].freeze
    DEFAULT_SENDER = 'noreply@example.com'.freeze

    def self.call(user_id:, event_type:)
      new(user_id: user_id, event_type: event_type).call
    end

    def initialize(user_id:, event_type:)
      @user_id = user_id
      @event_type = event_type
    end

    def call
      return { success: false, response: { error: 'Invalid event type' } } unless VALID_EVENTS.include?(@event_type)
      return { success: false, response: { error: 'User not found' } } if @user_id.nil?

      # TODO: load user from database and dispatch email
      { success: true, response: { delivered: true, event: @event_type } }
    end

    private

    def valid_event?
      VALID_EVENTS.include?(@event_type)
    end
  end
end

## Output Specification

Produce a single spec file for the service. The spec should cover:
- Successful notification dispatch for a valid event type
- Failure when the event type is not one of the recognised values
- Failure when user_id is nil

The spec file should be placed at the mirrored path under spec/ and follow standard RSpec conventions for structure and test data setup.
