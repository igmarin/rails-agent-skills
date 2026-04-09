# frozen_string_literal: true

require "rails_helper"

RSpec.describe WeatherService::Auth do
  let(:client_id)     { "test-client-id" }
  let(:client_secret) { "test-client-secret" }
  let(:auth)          { described_class.new(client_id: client_id, client_secret: client_secret) }

  describe "#initialize" do
    it "raises ArgumentError when client_id is blank" do
      expect { described_class.new(client_id: "", client_secret: client_secret) }
        .to raise_error(ArgumentError, "Missing required credentials")
    end

    it "raises ArgumentError when client_secret is blank" do
      expect { described_class.new(client_id: client_id, client_secret: nil) }
        .to raise_error(ArgumentError, "Missing required credentials")
    end
  end

  describe "#token" do
    context "when the OAuth request succeeds" do
      let(:token_response) do
        instance_double(HTTParty::Response,
          success?: true,
          parsed_response: { "access_token" => "abc123" },
          code: 200,
          body: '{"access_token":"abc123"}'
        )
      end

      before do
        allow(described_class).to receive(:post).and_return(token_response)
      end

      it "returns the access token" do
        expect(auth.token).to eq("abc123")
      end

      it "caches the token on subsequent calls" do
        auth.token
        auth.token

        expect(described_class).to have_received(:post).once
      end
    end

    context "when the OAuth request fails" do
      let(:error_response) do
        instance_double(HTTParty::Response,
          success?: false,
          code: 401,
          body: "Unauthorized"
        )
      end

      before do
        allow(described_class).to receive(:post).and_return(error_response)
      end

      it "raises Auth::Error" do
        expect { auth.token }.to raise_error(WeatherService::Auth::Error, /Auth failed \(401\)/)
      end
    end
  end

  describe ".default" do
    before do
      allow(Rails.configuration).to receive(:weather_service).and_return(
        client_id:     "cfg-id",
        client_secret: "cfg-secret",
        auth_base_uri: "https://auth.weather.example.com"
      )
    end

    it "returns an Auth instance" do
      expect(described_class.default).to be_a(described_class)
    end
  end
end
