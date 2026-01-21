# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Auth::Strategies::Hmac do
  let(:secret) { "test_secret_key_12345678901234567890" }
  let(:strategy) { described_class.new(secret_key: secret) }
  let(:body) { { "member_id" => "123", "hours" => 80 }.to_json }

  describe "#authenticate!" do
    context "with valid signature" do
      it "returns true" do
        headers = api_auth_headers(body: body, secret: secret)
        request = mock_api_request(body: body, headers: headers)

        expect(strategy.authenticate!(request)).to be true
      end

      it "allows the request body to be read again" do
        headers = api_auth_headers(body: body, secret: secret)
        request = mock_api_request(body: body, headers: headers)

        strategy.authenticate!(request)

        expect(request.body.read).to eq(body)
      end
    end

    context "with missing Authorization header" do
      it "raises MissingCredentials error" do
        request = mock_api_request(body: body, headers: {})

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::MissingCredentials, "Missing Authorization header")
      end
    end

    context "with malformed Authorization header" do
      it "raises MissingCredentials error" do
        headers = { "Authorization" => "HMAC sig=" }
        request = mock_api_request(body: body, headers: headers)

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::MissingCredentials, "Invalid Authorization header format")
      end

      it "raises error when prefix is missing" do
        signature = Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", secret, body))
        headers = { "Authorization" => signature }
        request = mock_api_request(body: body, headers: headers)

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::MissingCredentials, "Invalid Authorization header format")
      end
    end

    context "with invalid signature" do
      it "raises InvalidSignature error" do
        headers = api_auth_headers(body: body, secret: "wrong_secret")
        request = mock_api_request(body: body, headers: headers)

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::InvalidSignature, "Signature verification failed")
      end
    end

    context "with tampered body" do
      it "raises InvalidSignature error" do
        headers = api_auth_headers(body: body, secret: secret)
        request = mock_api_request(body: "tampered body", headers: headers)

        expect { strategy.authenticate!(request) }.to raise_error(Strata::Auth::InvalidSignature, "Signature verification failed")
      end
    end
  end
end
