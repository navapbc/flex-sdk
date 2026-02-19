# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Auth::Strategies::ApiKey do
  let(:api_key) { "super_secret_api_key" }
  let(:digest) { api_key_digest(api_key: api_key) }
  let(:strategy) { described_class.new(api_key_digest: digest) }

  describe "#authenticate!" do
    context "with valid API key" do
      it "returns true" do
        headers = api_key_auth_headers(api_key: api_key)
        request = mock_api_request(body: "", headers: headers)

        expect(strategy.authenticate!(request)).to be true
      end
    end

    context "with missing X-API-Key header" do
      it "raises MissingCredentials error" do
        request = mock_api_request(body: "", headers: {})

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::MissingCredentials, "Missing X-API-Key header")
      end
    end

    context "with empty X-API-Key header" do
      it "raises MissingCredentials error" do
        headers = { "X-API-Key" => "" }
        request = mock_api_request(body: "", headers: headers)

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::MissingCredentials, "Missing X-API-Key header")
      end
    end

    context "with wrong API key" do
      it "raises InvalidSignature error" do
        headers = api_key_auth_headers(api_key: "wrong_key")
        request = mock_api_request(body: "", headers: headers)

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::InvalidSignature, "Invalid API key")
      end
    end

    context "with slightly modified API key" do
      it "raises InvalidSignature error" do
        tampered_key = api_key + "x"
        headers = api_key_auth_headers(api_key: tampered_key)
        request = mock_api_request(body: "", headers: headers)

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::InvalidSignature, "Invalid API key")
      end
    end
  end
end
