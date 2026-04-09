# frozen_string_literal: true

require "rails_helper"

RSpec.describe WeatherService::Reading do
  let(:client)  { instance_double(WeatherService::Client) }
  let(:fetcher) { instance_double(WeatherService::Fetcher) }

  describe "ATTRIBUTES" do
    it "includes all required weather fields" do
      expect(described_class::ATTRIBUTES).to match_array(
        %w[temperature humidity wind_speed region_id recorded_at]
      )
    end
  end

  describe ".fetcher" do
    it "returns a Fetcher instance" do
      allow(WeatherService::Client).to receive(:default).and_return(client)
      result = described_class.fetcher
      expect(result).to be_a(WeatherService::Fetcher)
    end

    it "accepts an optional client override" do
      result = described_class.fetcher(client: client)
      expect(result).to be_a(WeatherService::Fetcher)
    end
  end

  describe ".find" do
    let(:reading_hashes) do
      [
        { "temperature" => 18.5, "humidity" => 65.0, "wind_speed" => 12.3,
          "region_id" => "eu-central-1", "recorded_at" => "2024-01-15T10:00:00Z" }
      ]
    end

    before do
      allow(WeatherService::Client).to receive(:default).and_return(client)
      allow(WeatherService::Fetcher).to receive(:new).and_return(fetcher)
      allow(fetcher).to receive(:execute_query).and_return(reading_hashes)
    end

    it "returns an array of reading hashes" do
      result = described_class.find(region_id: "eu-central-1")
      expect(result).to eq(reading_hashes)
    end

    it "passes the region_id in the query" do
      described_class.find(region_id: "eu-central-1")
      expect(fetcher).to have_received(:execute_query).with(
        hash_including(region_id: "eu-central-1")
      )
    end

    it "raises Client::Error when the API request fails" do
      allow(fetcher).to receive(:execute_query).and_raise(WeatherService::Client::Error, "API error 503")
      expect { described_class.find(region_id: "eu-central-1") }
        .to raise_error(WeatherService::Client::Error, "API error 503")
    end
  end
end
