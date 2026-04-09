# frozen_string_literal: true

require "rails_helper"

RSpec.describe WeatherService::Client do
  let(:token)   { "valid-bearer-token" }
  let(:host)    { "https://api.weather.example.com" }
  let(:client)  { described_class.new(token: token, host: host, max_retries: 1) }
  let(:payload) { { region_id: "us-west-1" } }

  describe "#initialize" do
    it "raises Client::Error when token is blank" do
      expect { described_class.new(token: nil, host: host) }
        .to raise_error(WeatherService::Client::Error, WeatherService::Client::MISSING_CONFIGURATION_ERROR)
    end

    it "raises Client::Error when host is blank" do
      expect { described_class.new(token: token, host: "") }
        .to raise_error(WeatherService::Client::Error, WeatherService::Client::MISSING_CONFIGURATION_ERROR)
    end
  end

  describe "#execute_query" do
    context "when the API returns a successful response" do
      let(:api_body) do
        { "data" => [{ "region_id" => "us-west-1", "temperature" => 22.5 }] }.to_json
      end
      let(:success_response) do
        instance_double(HTTParty::Response,
          success?: true,
          code: 200,
          body: api_body
        )
      end

      before do
        allow(described_class).to receive(:post).and_return(success_response)
      end

      it "returns the parsed response hash" do
        result = client.execute_query(payload)
        expect(result).to eq("data" => [{ "region_id" => "us-west-1", "temperature" => 22.5 }])
      end

      it "sends the correct Authorization header" do
        client.execute_query(payload)
        expect(described_class).to have_received(:post).with(
          anything,
          hash_including(headers: hash_including("Authorization" => "Bearer #{token}"))
        )
      end
    end

    context "when the API returns an error status" do
      let(:error_response) do
        instance_double(HTTParty::Response,
          success?: false,
          code: 503,
          body: "Service Unavailable"
        )
      end

      before do
        allow(described_class).to receive(:post).and_return(error_response)
      end

      it "raises Client::Error with status code" do
        expect { client.execute_query(payload) }
          .to raise_error(WeatherService::Client::Error, /API error 503/)
      end
    end

    context "when the response body is invalid JSON" do
      let(:bad_response) do
        instance_double(HTTParty::Response,
          success?: true,
          code: 200,
          body: "not-json"
        )
      end

      before do
        allow(described_class).to receive(:post).and_return(bad_response)
      end

      it "raises Client::Error" do
        expect { client.execute_query(payload) }
          .to raise_error(WeatherService::Client::Error, /Invalid JSON response/)
      end
    end

    context "when a transient network error occurs" do
      before do
        allow(described_class).to receive(:post).and_raise(Net::ReadTimeout)
      end

      it "raises Client::Error after exhausting retries" do
        expect { client.execute_query(payload) }
          .to raise_error(WeatherService::Client::Error, /Request failed/)
      end
    end
  end
end
