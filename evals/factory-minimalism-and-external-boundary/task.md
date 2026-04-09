# Email Campaign Delivery Service Specs

## Problem/Feature Description

A marketing platform sends bulk email campaigns to user segments. The `Campaigns::DeliveryService` service object coordinates the process: it retrieves the campaign and user segment from the database, then calls an external email provider (`SendgridClient`) to dispatch the emails. A junior developer wrote the initial implementation but left it entirely untested. The service is going into production next week and the team needs full spec coverage before the release.

You have been asked to write RSpec specs for this service along with the FactoryBot factory definitions needed to support the tests. The service needs to be thoroughly tested, including the success path, failures from the email provider, and record-not-found scenarios for a missing campaign or segment.

## Input Files

The following file is provided. Extract it before beginning.

=============== FILE: app/services/campaigns/delivery_service.rb ===============
# frozen_string_literal: true

module Campaigns
  class DeliveryService
    def self.call(campaign_id:, segment_id:)
      new(campaign_id: campaign_id, segment_id: segment_id).call
    end

    def initialize(campaign_id:, segment_id:)
      @campaign_id = campaign_id
      @segment_id = segment_id
    end

    def call
      campaign = Campaign.find(@campaign_id)
      segment = UserSegment.find(@segment_id)
      recipients = segment.users

      result = SendgridClient.deliver(
        to: recipients.map(&:email),
        subject: campaign.subject,
        body: campaign.body
      )

      if result[:success]
        { success: true, response: { delivered_count: recipients.count } }
      else
        { success: false, response: { error: result[:error] } }
      end
    rescue ActiveRecord::RecordNotFound => e
      { success: false, response: { error: e.message } }
    end
  end
end

## Output Specification

Produce:
- `spec/services/campaigns/delivery_service_spec.rb` — comprehensive RSpec spec for the service
- `spec/factories/campaigns.rb` — FactoryBot factory definitions needed to support the specs

The spec must cover: successful email delivery, a delivery failure returned by the email provider, and a not-found error for a missing campaign or segment.

For the FactoryBot factories, define only what the tests actually need — the factories should be lean and focused on the attributes the specs depend on.
